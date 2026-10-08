# Testplan

Fyll inn resultatene etter kjøring i Godot på Windows. Status er **ikke testet** inntil noen faktisk har gjennomført testen.

| ID | Test | Forventet resultat | Status |
| --- | --- | --- | --- |
| T01 | Start med `bygg.bat` | Spillet starter uten feil | Ikke testet |
| T02 | Se deg rundt og gå | Kamera og WASD fungerer | Ikke testet |
| T03 | Start oppdraget | Nedtellingen starter på 15:00 | Ikke testet |
| T04 | Åpne tre nyhetsartikler | Alle tekstene kan leses | Ikke testet |
| T05 | Skriv feil kode i rom 1 | Nytt forsøk mulig | Ikke testet |
| T06 | Skriv 417 i rom 1 | Rom 2 låses opp | Ikke testet |
| T07 | Sjekk tre filer i rom 2 | Bare Reklame.exe er korrekt karantene | Ikke testet |
| T08 | Ordne tidslinjen | 2023 laget → 2023 publisert → 2026 delt | Ikke testet |
| T09 | Fullfør siste rom | Mystisk sluttmelding vises | Ikke testet |
| T10 | Prøv F12 og F10 | PNG lagres og bildemappe åpnes | Ikke testet |
| T11 | Spill på 1280×720 | HUD overlapper ikke 3D-interaksjon | Ikke testet |
| T12 | Bruk knappene i dialoger | Tekst og knapper er fullt synlige | Ikke testet |

## V3 – utvidet bane og droner

- [ ] Spilleren starter innenfor den nye banen og kan gå til alle tre terminalene.
- [ ] Dekningskasser hindrer gjennomgang, men blokkerer ikke fremdrift.
- [ ] En drone oppdager, jager og angriper når spilleren kommer nær.
- [ ] Skjoldet synker ved treff og regenererer utenfor deteksjon.
- [ ] Ved tomt skjold: retur til inngang, minus 12 sekunder, innsamlede spor beholdes.
- [ ] Droner står stille mens lesefelt eller oppgavevindu er åpent.
- [ ] Rom 2 og 3 har to droner, men alle gåter kan fullføres.
- [ ] Test på Windows med F12-skjermbilder før de publiseres på GitHub.

- [ ] Søk etter spor på forskjellige steder og sjekk kompakt avstandshint.
- [ ] Kasser sperrer veien og skjuler spilleren for dronenes deteksjon.
- [ ] Klikk på en terminal langt unna: vis beskjed, ikke åpne dokumentet.