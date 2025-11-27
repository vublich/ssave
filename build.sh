#!/bin/bash
set -euo pipefail

APK_NAME="StorySave.apk"
MOD_DIR="StorySave"

if [ ! -f "$APK_NAME" ]; then
    echo "$APK_NAME not found."
    exit 1
fi

echo "==> Apktool version:"
apktool -version

# Decompila
echo "==> Decompilo $APK_NAME"
rm -rf "$MOD_DIR" || true
apktool d "$APK_NAME" -o "$MOD_DIR"

# Modifica smali
echo "==> Applico modifica smali"
sed -e 's/52.0.0.0.35/92.0.0.15.114/g' -i.bak "./$MOD_DIR/smali/sn.smali"

# Ricompila con aapt2
echo "==> Ricompilo con aapt2"
apktool b "$MOD_DIR" --use-aapt2

# Percorsi build-tools
BT="/opt/android-sdk/build-tools/33.0.2"

# Zipalign
echo "==> Zipalign"
"$BT/zipalign" -v 4 "$MOD_DIR/dist/$APK_NAME" aligned.apk

# Keystore
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

# Firma
echo "==> Firma con apksigner"
"$BT/apksigner" sign --ks StorySaveMod.keystore --ks-pass pass:password aligned.apk
