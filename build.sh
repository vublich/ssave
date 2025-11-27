#!/bin/bash
set -euo pipefail

APK_NAME="StorySave.apk"
MOD_DIR="StorySave"

# Verifica APK
if [ ! -f "$APK_NAME" ]; then
    echo "$APK_NAME not found. Upload it or let the workflow download it."
    exit 1
fi

echo "==> Apktool version:"
apktool -version || true

# Decompila (forza overwrite se la cartella esiste)
echo "==> Decompilo $APK_NAME"
rm -rf "$MOD_DIR" || true
apktool d "$APK_NAME" -o "$MOD_DIR"

# Modifica esempio (mantieni la tua sed)
echo "==> Applico modifica smali"
sed -e 's/52.0.0.0.35/92.0.0.15.114/g' -i.bak "./$MOD_DIR/smali/sn.smali"

# (Opzionale) Fix rapido per nomi risorse con '$' se presenti
if ls "$MOD_DIR"/res/drawable-v21/\$* >/dev/null 2>&1; then
  echo "==> Rinomino risorse con prefisso \$ per evitare errori aapt1 (fallback)"
  for f in "$MOD_DIR"/res/drawable-v21/\$*; do
    base="$(basename "$f")"
    new="${base/\$/}" # rimuove il carattere '$'
    mv "$f" "$(dirname "$f")/$new"
    # Aggiorna eventuali riferimenti (best-effort)
    grep -rl -- "$base" "$MOD_DIR/res" | xargs -r sed -i "s/$base/$new/g"
  done
fi

# Ricompila con aapt2 (fondamentale per aggirare gli errori su nomi risorse)
echo "==> Ricompilo con aapt2"
apktool b "$MOD_DIR" --use-aapt2

# Percorsi build-tools
BT="/opt/android-sdk/build-tools/33.0.2"

# Allinea APK
echo "==> Zipalign"
"$BT/zipalign" -v 4 "$MOD_DIR/dist/$APK_NAME" aligned.apk

# Genera keystore se manca
if [ ! -f "StorySaveMod.keystore" ]; then
  echo "==> Genero keystore"
  keytool -genkey -noprompt \
    -alias StorySaveMod \
    -dname "CN=StorySaveMod, OU=StorySaveMod, O=StorySaveMod, L=StorySaveMod, S=StorySaveMod, C=US" \
    -keystore StorySaveMod.keystore \
    -validity 100000 \
    -storepass password \
    -keypass password \
    -keyalg RSA
fi

# Firma con apksigner (scheme v2/v3)
echo "==> Firma con apksigner"
"$BT/apksigner" sign --ks StorySaveMod.keystore --ks-pass pass:password aligned.apk

echo "✅ Build completato: aligned.apk"
