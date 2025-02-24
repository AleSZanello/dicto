# Changelog

## 0.0.1 (Initial Release)

- Introduced the Dicto package for high-performance, multi-lingual dictionary lookups.
- Implemented an SQLite‑based dictionary lookup mechanism.
- Added self‑initializing database creation that reads dictionary assets from compressed (.txt.gz) files.
- Supported dynamic locale switching and incremental updates (only missing locales are added).
- Allowed flexible initialization by accepting either a single locale string or a list of locale strings.
- Updated the lookup API to return just the locale (or null if the word is not found).
- Included comprehensive unit tests covering initialization scenarios, lookup correctness, and error handling.
