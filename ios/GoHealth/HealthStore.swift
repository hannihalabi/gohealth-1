import Foundation
import HealthKit
import Combine

struct HealthReading {
    let value: String
    let detail: String
}

@MainActor
final class HealthStore: ObservableObject {
    @Published var pulse: HealthReading?
    @Published var steps: HealthReading?
    @Published var sleep: HealthReading?
    @Published var isLoading = false
    @Published var message = "Anslut Apple Hälsa för att läsa dina delade mätningar."
    @Published var lastRead: Date?

    private let store = HKHealthStore()
    private let pulseType = HKQuantityType(.heartRate)
    private let stepsType = HKQuantityType(.stepCount)
    private let sleepType = HKCategoryType(.sleepAnalysis)

    func connect() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            message = "Apple Hälsa är inte tillgängligt på den här enheten."
            return
        }
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            // A completed request does not reveal whether read access was granted.
            try await store.requestAuthorization(toShare: [], read: [pulseType, stepsType, sleepType])
            try await read()
        } catch {
            message = "Mätningarna kunde inte läsas. Kontrollera Apple Hälsa och försök igen."
        }
    }

    func refresh() async {
        guard HKHealthStore.isHealthDataAvailable(), !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do { try await read() }
        catch { message = "Uppdateringen misslyckades. Tidigare visade värden kan vara inaktuella." }
    }

    private func read() async throws {
        let end = Date()
        let start = end.addingTimeInterval(-24 * 60 * 60)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        // Keep the previous snapshot intact if one of the queries fails.
        let heart = try await samples(type: pulseType, predicate: predicate, limit: 1)
        let stepValue = try await todaySteps(end: end)
        let nights = try await samples(type: sleepType, predicate: predicate)

        var nextPulse: HealthReading?
        if let sample = heart.first as? HKQuantitySample {
            let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            nextPulse = HealthReading(value: String(Int(bpm.rounded())), detail: "\(sample.sourceRevision.source.name) · \(sample.endDate.formatted(date: .abbreviated, time: .shortened))")
        }

        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]
        // Merge overlaps to avoid counting the same sleep twice across sources.
        let intervals = nights.compactMap { sample -> DateInterval? in
            guard let sample = sample as? HKCategorySample,
                  asleepValues.contains(sample.value) else { return nil }
            let lower = max(start, sample.startDate)
            let upper = min(end, sample.endDate)
            return upper > lower ? DateInterval(start: lower, end: upper) : nil
        }.sorted { $0.start < $1.start }
        var merged: [DateInterval] = []
        for interval in intervals {
            if let previous = merged.last, interval.start <= previous.end {
                merged[merged.count - 1] = DateInterval(start: previous.start, end: max(previous.end, interval.end))
            } else { merged.append(interval) }
        }
        let hours = merged.reduce(0) { $0 + $1.duration } / 3600
        pulse = nextPulse
        steps = stepValue.map { HealthReading(value: Int($0.rounded()).formatted(), detail: "Idag · alla läsbara källor i Apple Hälsa") }
        sleep = intervals.isEmpty ? nil : HealthReading(value: hours.formatted(.number.precision(.fractionLength(1))), detail: "Registrerad sömn senaste 24 timmarna · alla läsbara källor")
        lastRead = end
        message = "Värden läses från Apple Hälsa. Saknade värden kan bero på att data eller läsbehörighet saknas."
    }

    private func samples(type: HKSampleType, predicate: NSPredicate, limit: Int = HKObjectQueryNoLimit) async throws -> [HKSample] {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: samples ?? []) }
            }
            store.execute(query)
        }
    }

    private func todaySteps(end: Date) async throws -> Double? {
        let start = Calendar.current.startOfDay(for: end)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: statistics?.sumQuantity()?.doubleValue(for: .count())) }
            }
            store.execute(query)
        }
    }
}
