# Greenstand Domain Migration Overview

Greenstand is currently undertaking a comprehensive domain migration to transition from a legacy monolithic architecture centered around the `trees` table to a service-oriented architecture with domain boundaries and cohesive language.

## Schema Evolution Overview

![Domain Migration Schema Change Overview](domain_migration_delta_ERD.svg)

The ERD above illustrates the transformation from legacy schema (red tables) to new schema (green tables), with denormalized tables (yellow) for reporting purposes.

## Key Migration Principles

### 1. Separation of Captures and Trees
**Legacy Problem**: The `trees` table mixed two distinct concepts:
- **Capture**: Event data proving something happened (photo, GPS, timestamp)
- **Tree**: The actual physical asset being tracked

**New Solution**: 
- `capture` table in the **treetracker service** for approved capture events
- `tree` table representing the actual physical trees
- `raw_capture` table in **field data service** for unverified device data

### 2. Service-Oriented Architecture
**Legacy**: Monolithic database with direct table access across services
**New**: Domain-bounded services with API contracts.

| Service | Domain Responsibility | Key Tables |
|---------|----------------------|------------|
| **Field Data Service** | Raw, unverified device data | `raw_capture`, `session`, `device` |
| **Treetracker Service** | Approved captures and trees | `capture`, `tree`, `ground_user` |
| **Stakeholder Service** | Organizations and hierarchies | `entity`, `entity_relationship` |
| **Wallet Service** | Digital assets and transfers | `wallet`, `token`, `transfer` |
| **Web Map Service** | Denormalized views for display | Event-driven materialized views |

### 3. Unified Domain Language
**Legacy Terminology** → **New Terminology**
- `planter`, `grower`, `fielduser` → `ground_user`
- `planteridentifier` → `ground_username`
- Mixed tree/capture concepts → Separated `capture` and `tree`
- Implicit tokens → Explicit `impact_token` with clear relationships.