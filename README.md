# Shai‑Hulud Guardian

**A security audit script to detect compromised npm packages from the “Shai‑Hulud” supply‑chain attack.**

---

## What It Does

1. **Logo & Identification**  
   When run, the script displays an ASCII art logo with its name *Shai‑Hulud Guardian*, making clear that it’s a security/audit tool specifically for the Shai‑Hulud incident.

2. **Environment Check**  
   It verifies whether `node` and `npm` are installed on the system, and logs their versions. If `npm` is missing, it skips further `npm`‑related checks.

3. **Fetch Compromised Package List**  
   Downloads a curated text file from a GitHub raw URL.  
   The file contains lines formatted as `package@version`, listing npm packages & specific versions known to be compromised by the Shai‑Hulud attack.

4. **Global Package Scan**  
   If `npm` is present:  
   - Lists globally installed npm packages (with versions)  
   - Compares them against the compromised list  
   - Logs warnings if any exact matches (same package **and** version) are found

5. **Local Projects Scan**  
   Recursively searches from the current directory for all `package.json` files (excluding those in `node_modules/`). For each project folder found:  
   - Runs `npm ls --json` to list that project’s dependencies and their versions  
   - Compares local packages + versions against the compromised list  
   - Logs any matches found, specifying the project path and offending package

6. **Summary & Logging**  
   - All findings (both global and local) are written into a timestamped log file, e.g.  
     `shai_hulud_guardian_YYYYMMDD_HHMMSS.log`  
   - At the end, the script reports how many compromised packages were found (if any), with clear markers  
   - Cleans up temporary files after the run

---

## Why It’s Useful

- The Shai‑Hulud attack involves malicious post‑install scripts, stolen tokens, and self‑propagation across packages. This detection helps you find out if you’re already affected.  
- Works for both globally installed npm packages and those in your local projects — useful when working across multiple repositories.  
- Uses an external list you can update, so you can keep pace with newly discovered compromised package versions.

---

## Limitations & Notes

- Only exact matches of `package@version` are detected. If a version isn’t in the list, it won’t be flagged — even if it's vulnerable but not yet publicly disclosed.  
- Depends on the external text file being kept up to date and accurate.  
- Assumes `npm ls --json` works in each project. If there are dependency conflicts or broken modules, output may be partial or fail.  
- Does **not** check contents of `postinstall` scripts, does **not** verify file‑hashes or CI/CD workflows. Additional tools or manual audits are needed for those checks.

---

## Usage

```bash
./shai_hulud_guardian.sh
