#!/bin/bash
# Script per lanciare il Bot Esploratore (Integration Test Demo)
# Assicurati di avere un emulatore o un dispositivo fisico avviato.

echo "==========================================="
echo "   VIBRA - BOT ESPLORATORE DEMO            "
echo "==========================================="
echo "Avviando il bot sull'emulatore collegato..."

# Naviga nella cartella root di Vibra se non ci siamo
cd "$(dirname "$0")/.."

# Esegue il test di integrazione
flutter test integration_test/bot_demo_test.dart
