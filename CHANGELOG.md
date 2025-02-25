# Changelog

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
