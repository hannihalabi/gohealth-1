# GoHealth – plattformens grundflöde

## Syfte

Samla patientens delade hälsodata från Apple Hälsa, visa utvecklingen för vårdteamet och stödja dokumenterad uppföljning.

## Delar

Vald integrationsväg: Garmin → Garmin Connect → Apple Hälsa på iPhone → egen GoHealth-app med HealthKit → GoHealth-backend → läkarportal. Terra används inte eftersom abonnemanget inte ryms i nuvarande budget. Användaren har redan kopplat Garmin till Apple Hälsa. Kopplingen från Apple Hälsa till GoHealth återstår.

1. iPhone-app: begär läsbehörighet i HealthKit och skickar godkända mätningar till GoHealth.
2. Backend: kopplar mätningar till rätt patient, hanterar dubbletter, samtycke och åtkomst samt sparar mättid, källa och mottagningstid.
3. Läkarportal: patientlista, trender, senaste synkronisering och uppföljningsärenden med ansvarig och status.

## Första fungerande flöde

Patient ansluter → ger behörighet → data importeras → läkaren ser värden och datans ålder → läkaren skapar och avslutar ett uppföljningsärende.

Utvecklingen börjar med syntetiska patientdata. Verklig patientdata kräver färdig autentisering, behörighetskontroll och säker drift.

## Datakontrakt

Varje mätning innehåller ett stabilt käll-ID, typ, värde, enhet, start- och sluttid och källa. Patientidentitet härleds från autentiserad session, inte från ett fritt patient-ID i klientens uppladdning. Importen måste stödja idempotens och borttagningar från HealthKit.

## Begränsningar som påverkar implementationen

- Apple Hälsa nås genom en native iPhone-app med HealthKit.
- Garmin anger att överföring sker efter lyckad enhetssynkronisering. Flödet ska därför visa datans ålder och inte anta realtid.
- Tillgängliga datatyper måste verifieras för vald Garmin-modell och faktisk överföring till Apple Hälsa. Body Battery, stress, rytm och blodtryck får inte förutsättas vara tillgängliga.
- Automatiska kliniska larm kräver separat definierade och validerade regler. Första versionen stödjer mänsklig uppföljning.

## Källor

- Garmin: https://support.garmin.com/en-AU/?faq=lK5FPB9iPF5PXFkIpFlFPA
- Apple HealthKit: https://developer.apple.com/documentation/healthkit/executing-observer-queries
- Apple behörigheter: https://developer.apple.com/documentation/xcode/configuring-healthkit-access

## Beslut som återstår

- Första leveransens omfattning: hela grundflödet, läkarportal eller iPhone-integration.
- Garmin-modell och faktiska tillgängliga datatyper.
- Driftmiljö och inloggningslösning inför patientpilot.
