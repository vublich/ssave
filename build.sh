# This script mods StorySave to bypass checkpoint_required/challenge_required in 2023

# exit when any command fails
set -e

# make sure StorySave.apk exists
if [ ! -f "StorySave.apk" ]; then
    echo "StorySave.apk does not exist."
    echo "Download latest StorySave apk from APK Mirror and then rename it to StorySave.apk"
    echo "https://www.apkmirror.com/apk/liam-cottle/storysave/storysave-1-26-2-release/storysave-1-26-2-android-apk-download/"
    exit -1
fi

# decompile apk
apktool d StorySave.apk

# change ig version from 52.0.0.0.35 to 92.0.0.15.114
sed -e 's/52.0.0.0.35/92.0.0.15.114/g' -i.bak ./StorySave/smali/sn.smali

# build new apk
apktool b StorySave

# create keystore for signing apk (if not exists)
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

# sign apk
jarsigner -keystore StorySaveMod.keystore \
 -storepass "password" \
 -keypass "password" \
 -verbose \
 StorySave/dist/StorySave.apk StorySaveMod

# uninstall existing app from device
adb uninstall io.storysave.android

# install modded apk
adb install -r StorySave/dist/StorySave.apk
