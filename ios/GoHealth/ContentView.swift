import SwiftUI

struct ContentView: View {
    @StateObject private var health = HealthStore()
    private let accent = Color(red: 0.73, green: 0.20, blue: 0.47)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Label("GoHealth", systemImage: "heart.circle.fill")
                        .font(.largeTitle.bold()).foregroundStyle(accent)
                    Text("Din hälsa, samlad.").font(.title2.bold())
                    Text("Läs de mätningar som din Garmin har delat till Apple Hälsa.")
                        .foregroundStyle(.secondary)
                    Label("Testversion · data stannar på din iPhone", systemImage: "lock.shield")
                        .font(.caption).padding(12).frame(maxWidth: .infinity, alignment: .leading)
                        .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    Button {
                        Task { await health.connect() }
                    } label: {
                        HStack {
                            if health.isLoading { ProgressView().tint(.white) }
                            Text("Anslut Apple Hälsa").fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "arrow.right")
                        }.padding()
                    }
                    .buttonStyle(.borderedProminent).tint(accent).disabled(health.isLoading)
                    reading("Senaste puls", icon: "heart.fill", unit: "slag/min", value: health.pulse)
                    reading("Steg idag", icon: "figure.walk", unit: "steg", value: health.steps)
                    reading("Registrerad sömn", icon: "moon.fill", unit: "timmar / 24 h", value: health.sleep)
                    Text(health.message).font(.footnote).foregroundStyle(.secondary)
                    if let lastRead = health.lastRead {
                        Text("Senast läst: \(lastRead.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption).foregroundStyle(.secondary)
                        Button("Uppdatera mätningar") { Task { await health.refresh() } }
                            .disabled(health.isLoading)
                    }
                    Text("Inga uppgifter skickas till läkarportalen ännu. Värdena är inte en medicinsk bedömning. Apple Hälsa kan innehålla data från flera enheter och appar.")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Min hälsa")
            .navigationBarTitleDisplayMode(.inline)
        }.tint(accent)
    }

    private func reading(_ title: String, icon: String, unit: String, value: HealthReading?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon).foregroundStyle(accent)
            HStack(alignment: .firstTextBaseline) {
                Text(value?.value ?? "—").font(.system(size: 36, weight: .bold, design: .rounded))
                Text(unit).font(.caption).foregroundStyle(.secondary)
            }
            Text(value?.detail ?? "Inga läsbara mätningar").font(.caption).foregroundStyle(.secondary)
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview { ContentView() }
