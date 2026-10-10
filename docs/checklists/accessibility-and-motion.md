# Barrierefreiheit & Animationen

## Animationen („cool, aber richtig“)

- [ ] Jede Animation hat einen Zweck: Orientierung (woher/wohin), Feedback (Aktion erkannt) oder Freude (Erfolg)
- [ ] Dauern und Kurven kommen aus dem Design-System (`designsystem/motion` bzw. `Core/DesignSystem/Motion`), nicht hartcodiert
- [ ] Shared-Element-/Zoom-Übergänge zwischen Liste und Detail (Court, Game, Profil) auf beiden Plattformen
- [ ] Animationen sind unterbrechbar (Zurück-Geste mitten in der Animation funktioniert)
- [ ] „Bewegung reduzieren“ respektiert: Android `Settings.Global.ANIMATOR_DURATION_SCALE` / iOS `accessibilityReduceMotion`
- [ ] 60/120 fps auf einem älteren Gerät (Android: Profiler / JankStats, iOS: Instruments)
- [ ] Haptik passend zur Animation (Erfolg, Fehler, Auswahl), abschaltbar
- [ ] Lottie/Rive-Dateien klein gehalten, nicht im Startpfad

## Barrierefreiheit

- [ ] TalkBack und VoiceOver: alle Bedienelemente haben Labels, Reihenfolge sinnvoll
- [ ] Touch-Ziele mindestens 48 dp / 44 pt
- [ ] Kontrast nach WCAG AA (auch im Dark Mode)
- [ ] Große Schrift / Dynamic Type bis zur größten Stufe ohne abgeschnittenen Text
- [ ] Information nie nur über Farbe (z. B. Game-Status zusätzlich mit Icon/Text)
- [ ] Karte hat eine Listen-Alternative
