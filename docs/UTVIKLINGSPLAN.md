# Utviklingsplan – steg for steg

| Steg | Status | Arbeid |
| --- | --- | --- |
| 1 | Ferdig | Bestemme mål: et 15-minutters spill om kildekritikk |
| 2 | Ferdig | Lage historie og læringsmål |
| 3 | Ferdig | Planlegge rom 1, rom 2 og rom 3 |
| 4 | Ferdig | Lage første 3D-prototype i Godot |
| 5 | Pågår | Rydde HUD og forbedre lesbarhet |
| **6** | **Pågår** | Publisere profesjonelt på GitHub og dokumentere med skjermbilder |
| **7** | **Neste** | Prøvespille hele rom 1 og rette eventuelle feil |
| 8 | Planlagt | Teste rom 2 og 3 med andre spillere |
| 9 | Planlagt | Forbedre tilgjengelighet, animasjoner og lyd |
| 10 | Planlagt | Lage en testet Windows-utgivelse med EXE |

## Akkurat nå

1. Klon prosjektet eller last det ned fra GitHub.
2. Kjør `bygg.bat` på Windows.
3. Ta ekte skjermbilder med `F12`; åpne mappen med `F10`.
4. Send skjermbilder og eventuelle feil. Deretter forbedrer vi ett rom av gangen.

Ikke kryss av for tester som ikke er gjennomført.

## Neste milepæl – V3: større baner og sikkerhetsdroner

- Utvidet miljø med tre fjerne terminaler i hvert rom.
- Droner patruljerer; én i rom 1, to i rom 2 og 3.
- Energiangrep, skjold og retur til inngang uten tap av funn.
- Kasser kan brukes til dekning; HUD viser avstand til nærmeste uleste spor.
- GitHub Actions kjører en dedikert 3D-/drone-smoketest.

**Neste lille steg:** Åpne spillet på Windows, test rom 1 med én drone og ta ekte F12-skjermbilder. Finjuster vanskelighetsgrad og lys før vi bygger flere fiendetyper.