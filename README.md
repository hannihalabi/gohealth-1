# GoHealth läkarportal

En lokal, interaktiv förhandsversion av läkarportalen med syntetiska patientdata.

## Kör

```sh
npm install
npm run dev
```

Öppna adressen som Vite visar. `npm run build` bygger frontend för statisk distribution.

## Funktioner

- Patientöversikt med sökning och statusfilter.
- Uppföljningskö med pågående och ännu inte granskade ärenden.
- Patientvy med vilopuls, sömn och aktivitet för 7 eller 14 dagar.
- Anteckningar och statusändringar som sparas lokalt i webbläsaren.
- Markering av äldre mätningar och tydlig källmärkning av demodata.

## Avgränsning

Detta är en prototyp, utan backend, autentisering, journalintegration eller anslutning till Apple Hälsa. Använd endast fiktiva uppgifter. Demostatus är inte en medicinsk klassificering. Ingen automatisk klinisk larmregel eller AI-bedömning är implementerad.

Nästa steg är autentiserad backend med serverstyrd patientåtkomst, säker datalagring, spårbarhet och API för iPhone-import. Plattformens övergripande dataflöde finns i `docs/platform-outline.md`.
