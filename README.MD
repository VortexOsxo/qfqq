# Qfqq


## Serveur
Commande pour run le serveur:
`flask run --debug`

## Client
Commande pour run le client:
`flutter run -d windows --dart-define-from-file=env/dev.json`

## Build iOS

Le build iOS doit être créé sur macOS avec Xcode installé. Avant le premier build,
ouvrez `client/ios/Runner.xcworkspace` dans Xcode, sélectionnez la cible **Runner**,
puis configurez **Signing & Capabilities** avec votre équipe Apple Developer et le
Bundle Identifier de l'application.

La version et le numéro de build sont définis dans `client/pubspec.yaml`
Incrémentez le numéro après le `+` pour chaque nouvelle soumission à App Store Connect.
```sh
flutter build ipa --release --dart-define-from-file=env/prod.json
```
