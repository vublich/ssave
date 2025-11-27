# APK Build Pipeline (Docker + GitHub Actions)

Questo progetto mostra come:
- Decompilare un APK con `apktool`
- Modificare file smali
- Ricompilare e firmare l'APK
- Automatizzare il processo con Docker e GitHub Actions

⚠️ **Nota**: Usa solo APK open-source o di tua proprietà. Non pubblicare script che violano TOS o leggi.

## Come funziona
1. Carica il tuo APK nella root del repo.
2. Push su `main` → GitHub Actions esegue il build.
3. Scarica l'artefatto firmato dalla sezione Actions.

## Comandi locali (opzionale)
```bash
docker build -t apk-builder .
docker run --rm -v $(pwd):/app apk-builder bash build.sh
