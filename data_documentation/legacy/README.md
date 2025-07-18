# Legacy Database Schema Visualization

This folder documents the legacy Treetracker database schema, reverse-engineered as part of [Issue #158: Data Overview, Schema, and Dictionary Development](https://github.com/Greenstand/Greenstand-Overview/issues/158) to support domain migration, foreign key normalization, and improved onboarding for contributors at Greenstand.

> **Latest Update:** Use the PNG diagrams and `legacy_schema_overview.md` in `docs/` to understand the legacy data model.
---

## Folder Overview

**docs/**  
- `legacy_schema_overview.md` – Detailed, up-to-date overview of all tables, materialized views, and relationships in the legacy schema, supporting onboarding and migration.
- `schema_legacy_all.png` – Full legacy schema including all tables and relationships (including operations & pipeline.) 
- `schema_legacy_main.png` – Focused view of main tables (e.g., trees, capture, grower_account)  
- `schema_pre_migration.png` – Snapshot of schema before major restructuring

**scripts/seeds/**  
- `treetracker_seed.pgsql` – Original SQL dump used to recreate the legacy database locally

**sql/**  
- `all_schema_dump.sql` – Raw pg_dump output with comments and ownership 
- `public_schema_dump.sql` – Dump of only the 'public' schema  
- `psql_extensions.sql` – Script to enable PostGIS and uuid-ossp extensions  
- `create_materialized_views.sql` – Views used by the legacy codebase  
- `add_primary_keys.sql` – Script to manually add missing primary keys  
- `fix_orphaned_rows.sql` – Patch to clean up bad foreign key references


