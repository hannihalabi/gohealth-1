# GoHealth för iPhone

Ett SwiftUI-projekt för iOS 17 eller senare med läsbehörighet för puls, steg och sömn i HealthKit. Inga externa paket eller Terra-kopplingar används.

## Öppna och kör

1. Installera Xcode från Mac App Store. Den här datorn har för närvarande endast Command Line Tools.
2. Öppna `GoHealth.xcodeproj` i Xcode.
3. Välj GoHealth-target → Signing & Capabilities, välj ditt utvecklarteam och vid behov ett unikt Bundle Identifier. HealthKit är redan konfigurerat i projektet.
4. Välj en ansluten iPhone som kör iOS 17 eller senare och kör appen. HealthKit-signering måste stödjas av ditt team/provisioning.
5. Tryck på **Anslut Apple Hälsa** och välj de uppgifter du vill tillåta.

## Vad appen visar

- Senaste läsbara pulsmätning inom 24 timmar, med källa och mättid. Detta är inte vilopuls.
- Steg idag via HealthKits statistikfråga.
- Registrerad sömn senaste 24 timmarna. Överlappande sömnintervall slås ihop; vaken tid och tid i säng räknas inte som sömn.

Apple Hälsa kan innehålla flera källor. Denna första version filtrerar inte allt till Garmin. Saknade data visas som ett streck, inte som noll. HealthKit avslöjar inte om läsbehörighet nekats; en slutförd behörighetsdialog innebär inte att alla värden är åtkomliga.

## Nuvarande avgränsning

Alla frågor körs på användarens initiativ. Ingen bakgrundssynkronisering, datalagring utanför Apple Hälsa, nätverkstrafik, serveruppladdning eller klinisk larmfunktion är implementerad.

Projektstruktur, plist-filer och Swift-syntax kan kontrolleras på denna dator. Full kompilering och enhetstest behöver Xcode med iOS SDK. Garmin-dataflödet måste verifieras på en fysisk iPhone.

Nästa steg: prova de faktiska tillgängliga Garmin-värdena, sedan implementera autentiserad serverkoppling och inkrementell HealthKit-import.
