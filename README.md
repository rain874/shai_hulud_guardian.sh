# shai_hulud_guardian.sh
This script is designed to detect and alert about the presence of npm packages compromised by the “Shai‑Hulud” supply‑chain attack. It helps you verify whether your system (both globally and locally in your projects) is using any npm packages that are known to be malicious, based on a maintained list.


What It Does

Logo & Identification
When run, the script displays an ASCII art logo with its name Shai‑Hulud Guardian, making clear that it’s a security/audit tool specifically for the Shai‑Hulud incident.

Environment Check
It checks whether node and npm are installed on the system, and logs their versions. If npm is missing, it skips further npm‑related checks.

Fetch Compromised Package List
It downloads a curated text file from a GitHub raw URL. This file contains lines of the form package@version, listing npm packages and specific versions known to be compromised by the Shai‑Hulud attack.

Global Package Scan
If npm is present, the script lists globally installed npm packages (version by version) and compares them against the compromised list. If any match (same package and version), it logs a warning.

Local Projects Scan
The script recursively searches from the current directory for all package.json files (excluding inside node_modules/). For each project folder found:

It runs npm ls --json to list that project’s dependencies and their versions.

Compares those local packages + versions against the compromised list.

Logs any matches found, specifying project path and violating package.

Summary & Logging

All findings (global and local) are written into a timestamped log file (e.g. shai_hulud_guardian_YYYYMMDD_HHMMSS.log).

At the end, the script reports how many compromised packages were found (if any), with clear markers.

Cleanup of temporary files after run.


Why It’s Useful

Since the Shai‑Hulud attack involves malicious post‑install scripts, stolen tokens, and self‑propagation across packages, this kind of detection helps catch if you’re already affected.

The script works across your system and all local projects in a directory tree, so you can audit across many projects easily.

It uses an external list you maintain (or you can update) to keep up with newly discovered compromised package versions.


Limitations & Notes

Only checks exact matches of package@version. If a version is not in the list, it isn’t flagged (even if it might be vulnerable but not yet publicly listed).

It depends on the external text file being up to date and accurate.

It assumes npm ls --json works in projects (if there are dependency conflicts or missing modules, that may fail or produce incomplete output).

Doesn’t check things like post‑install scripts content, hash mismatches, or CI/CD workflows. 
