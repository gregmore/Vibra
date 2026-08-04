import json

translations = {
    'de': {
        "settingsLogoutAll": "Von allen Geräten abmelden",
        "settingsLogoutAllConfirmTitle": "Von allen Geräten abmelden",
        "settingsLogoutAllConfirmBody": "Möchten Sie sich wirklich von allen Geräten abmelden? Sie werden überall abgemeldet."
    },
    'es': {
        "settingsLogoutAll": "Cerrar sesión en todos los dispositivos",
        "settingsLogoutAllConfirmTitle": "Cerrar sesión en todos los dispositivos",
        "settingsLogoutAllConfirmBody": "¿Estás seguro de que quieres cerrar sesión en todos los dispositivos? Se cerrará tu sesión en todas partes."
    },
    'fr': {
        "settingsLogoutAll": "Se déconnecter de tous les appareils",
        "settingsLogoutAllConfirmTitle": "Se déconnecter de tous les appareils",
        "settingsLogoutAllConfirmBody": "Êtes-vous sûr de vouloir vous déconnecter de tous les appareils ? Vous serez déconnecté partout."
    }
}

for lang, trans in translations.items():
    filepath = f"lib/l10n/app_{lang}.arb"
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data.update(trans)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

print("Translations added successfully!")
