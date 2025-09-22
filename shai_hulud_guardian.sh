#!/bin/bash

###############################################################################
#    ____  _    _    _   _       _   _ _     _     _   _           _       #
#   / ___|| |__| |__| | | | ___ | |_| (_)_ __| | __| | (_)_   _ ___| |_ ___ #
#   \___ \|  __|  __| | | |/ _ \| __| | | '__| |/ _` | | | | | / __| __/ _ \#
#    ___) | |  | |  | |_| | (_) | |_| | | |  | | (_| | | | |_| \__ \ ||  __/#
#   |____/|_|  |_|   \___/ \___/ \__|_|_|_|  |_|\__,_| |_|\__,_|___/\__\___|#
#                                                                             #
#             S H A I ‑ H U L U D   G U A R D I A N                         #
# "We scan. We detect. We secure. Against the npm worm Shai‑Hulud."         #
###############################################################################

# ---------------------------
# Konfiguration
# ---------------------------

LOGFILE="shai_hulud_guardian_$(date +%Y%m%d_%H%M%S).log"
# URL zu deiner GitHub Raw Datei mit kompromittierten Paketen (jede Zeile: paketname@version)
COMPROMISED_LIST_URL="https://raw.githubusercontent.com/username/repo/branch/path/to/kompromittierte_pakete.txt"
TEMPFILE=$(mktemp)
MATCHES=0

# ---------------------------
# Hilfsfunktionen
# ---------------------------

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

check_command() {
    if command -v "$1" &>/dev/null; then
        log "$1 ist installiert: Version $($1 -v 2>&1)"
    else
        log "$1 ist **nicht installiert**."
    fi
}

fetch_compromised_list() {
    log "📥 Lade Liste kompromittierter Pakete von GitHub ..."
    if curl -s -f -o "$TEMPFILE" "$COMPROMISED_LIST_URL"; then
        log "✅ Liste erfolgreich geladen."
    else
        log "❌ Fehler beim Laden der kompromittierten Paketliste von: $COMPROMISED_LIST_URL"
        rm -f "$TEMPFILE"
        exit 1
    fi
}

scan_global_packages() {
    if ! command -v npm &>/dev/null; then
        log "⚠️ npm nicht installiert – global scan übersprungen."
        return
    fi

    log "🌐 Prüfe global installierte npm Pakete..."
    npm ls -g --depth=0 --json > npm_global_packages.json 2>/dev/null

    jq -r '.dependencies | to_entries[] | "\(.key)@\(.value.version)"' npm_global_packages.json > global_installed.txt

    while IFS= read -r compromised; do
        # Für jede Zeile in kompromittierter Liste
        if grep -Fxq "$compromised" global_installed.txt; then
            log "🚨 GLOBAL: Kompromittiertes Paket gefunden: $compromised"
            ((MATCHES++))
        fi
    done < "$TEMPFILE"
}

scan_local_projects() {
    log "📂 Starte rekursiven Scan lokaler Projekte..."

    find . -type f -name "package.json" ! -path "*/node_modules/*" | while read -r package_json; do
        project_dir=$(dirname "$package_json")
        log "🔍 Projekt erkannt: $project_dir"

        pushd "$project_dir" > /dev/null

        # npm ls im Projekt, falls installiert
        npm ls --json > npm_local_packages.json 2>/dev/null

        if [[ -s npm_local_packages.json ]]; then
            jq -r '.dependencies // {} | to_entries[] | "\(.key)@\(.value.version)"' npm_local_packages.json > local_installed.txt

            while IFS= read -r compromised; do
                if grep -Fxq "$compromised" local_installed.txt; then
                    log "🚨 LOKAL in $project_dir: Kompromittiertes Paket: $compromised"
                    ((MATCHES++))
                fi
            done < "$TEMPFILE"

            rm -f local_installed.txt
        else
            log "⚠️ Projekt $project_dir: Keine oder fehlerhafte Abhängigkeiten gefunden"
        fi

        rm -f npm_local_packages.json
        popd > /dev/null
    done
}

cleanup() {
    rm -f "$TEMPFILE" global_installed.txt npm_global_packages.json
}

# ---------------------------
# Hauptlogik
# ---------------------------

log "🚀 Starte Shai‑Hulud Guardian: Sicherheitsprüfung gegen npm Supply‑Chain Angriff"

check_command node
check_command npm

if command -v npm &>/dev/null; then
    fetch_compromised_list
    scan_global_packages
    scan_local_projects
else
    log "npm ist nicht vorhanden – lokale Scans übersprungen."
fi

if [[ $MATCHES -eq 0 ]]; then
    log "✅ Keine kompromittierten Pakete gefunden."
else
    log "❗ $MATCHES kompromittierte Paket(e) entdeckt – bitte prüfen und ggf. entfernen/aktualisieren."
fi

cleanup

log "✅ Überprüfung abgeschlossen. Logdatei: $LOGFILE"
