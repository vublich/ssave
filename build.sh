#!/bin/bash
set -e

APK_NAME="StorySave.apk"
MOD_DIR="StorySave"

# Verifica che l'APK sia presente
if [ ! -f "$APK_NAME" ]; then
    echo "$APK_NAME not found. Upload it to the repo root."
    exit 1
fi

# Decompila l'APK
apktool d "$APK_NAME"

# Modifica (esempio: cambia versione IG)
sed -e 's/52.0.0.0.35/92.0.0.15.114/g' -i.bak "./$MOD_DIR/smali/sn.smali"

# Ricompila
apktool b "$MOD_DIR"

# Allinea APK
zipalign -v 4 "$MOD_DIR/dist/$APK_NAME" aligned.apk

# Genera keystore se non esiste
if [ ! -f "StorySaveMod.keystore" ]; then
    keytool -genkey -noprompt \
     -alias StorySaveMod \
     -dname "CN=StorySaveMod, OU=StorySaveMod, O=StorySaveMod, L=StorySaveMod, S=StorySaveMod, C=US" \
     -keystore StorySaveMod.keystore \
     -validity 100000 \
     -storepass password \
     -keypass password \
     -keyalg rsa
fi

# Firma APK con apksigner
apksigner sign --ks StorySaveMod.keystore --ks-pass pass:password aligned.apk

echo "✅ APK signed successfully: aligned.apk"
