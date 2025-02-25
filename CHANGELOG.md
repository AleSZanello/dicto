# Changelog

## 0.1.0 (Minor Upgrade)

- Added new calls and optimized files

## 0.0.13 (Fixes)

- Fixed comma on some dictionaries files

## 0.0.12 (Performance)

- Reduced unused languages and only added current support to 8 (en,es,pt,fr,it,de,ru,nl)

## 0.0.11 (Feature Added)

- Minor fixes

## 0.0.10 (Feature Added)

- Minor fixes

## 0.0.9 (Feature Added)

- Added Dicto.syncLocale(String locale) - Allow to sync the DB with just the desired locale (would delete any other locale on it)
- Added Dicto.isInitialized - Allow to check if the DB is initialized (just for some checkers if needed)

## 0.0.8 (Fixes)

- Fixed .Get to .get (camelCase)

## 0.0.7 (Fixes)

- Fixed the asset path from the package

## 0.0.6 (Fixes)

- Fixed an error where Dicto was trying to get a Table from a DB that didn't initialized yet

## 0.0.5 (Changes)

- changed Dicto.dictoGet() to Dicto.Get() and return empty string if not found the word on the DB

## 0.0.4 (Minor fixes)

- Fixed format and small change on README.md

## 0.0.3 (Add examples)

- Added example folder on how to use it correctly & few fixes.

## 0.0.2 (Update dependencies)

- Just a quick update on dependencies

## 0.0.1 (Initial Release)

- Introduced the Dicto package for high-performance, multi-lingual dictionary lookups.
- Implemented an SQLite‑based dictionary lookup mechanism.
- Added self‑initializing database creation that reads dictionary assets from compressed (.txt.gz) files.
- Supported dynamic locale switching and incremental updates (only missing locales are added).
- Allowed flexible initialization by accepting either a single locale string or a list of locale strings.
- Updated the lookup API to return just the locale (or null if the word is not found).
- Included comprehensive unit tests covering initialization scenarios, lookup correctness, and error handling.
