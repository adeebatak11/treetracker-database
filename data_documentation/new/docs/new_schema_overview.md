# New Schema Overview

This document provides an overview of the new PostgreSQL schema for the Treetracker system. It summarizes key tables, their relationships, and notable features to support migration and development efforts.

## Tables



### Key Tables

1. **tree** – Main record for each tree.
2. **capture** – Observations/photos of trees.
3. **grower_account** – Information about tree planters.
4. **tag** – Tag definitions.
5. **stakeholder** – Organizations & people.
6. **session** – Data collection sessions.
7. **region** – Geographic regions.
8. **collection** – Geographic collections.
9. **wallet** – Digital wallet records.
10. **token** – Represents digital/tree ownership.
11. **transaction** – Token movement history.

### All Tables

1. **api_key** – API key management.
2. **app_config** – Application configuration.
3. **app_installation** – App installation records.
4. **capture** – Tree observations/photos.
5. **capture_denormalized** – Reporting-friendly capture data.
6. **capture_tag** – Links captures and tags (many-to-many).
7. **collection** – Geographic collections.
8. **device_configuration** – Device/app metadata.
9. **domain_event** – Domain event log (partitioned).
10. **domain_event_handled** – Handled domain events (partitioned).
11. **domain_event_received** – Received domain events (partitioned).
12. **domain_event_raised** – Raised domain events (partitioned).
13. **domain_event_sent** – Sent domain events (partitioned).
14. **grower_account** – Tree planter information.
15. **grower_account_image** – Images for grower accounts.
16. **grower_account_org** – Links grower accounts and organizations (many-to-many).
17. **migrations** – Database migration tracking.
18. **raw_capture** – Raw capture data.
19. **region** – Geographic regions.
20. **session** – Data collection sessions.
21. **session_segment** – Segments of sessions.
22. **spatial_ref_sys** – PostGIS spatial reference system.
23. **stakeholder** – Organizations & people.
24. **stakeholder_relation** – Stakeholder hierarchies (many-to-many).
25. **tag** – Tag definitions.
26. **token** – Digital/tree ownership tokens.
27. **track** – Tracking data.
28. **transaction** – Token movement history.
29. **transfer** – Transfer records.
30. **transfer_audit** – Transfer audit logs.
31. **tree** – Tree records.
32. **tree_denormalized** – Reporting-friendly tree data.
33. **tree_tag** – Links trees and tags (many-to-many).
34. **wallet** – Digital wallet records.
35. **wallet_event** – Wallet event logs.
36. **wallet_registration** – Wallet registration records.
37. **wallet_trust** – Trust relationships between wallets.
38. **wallet_trust_log** – Wallet trust log entries.


## Materialized Views

1. **capture_tree_match** – Matches captures to trees based on spatial and temporal proximity.


## Foreign Keys & Relationships

1. `capture.tree_id` → `tree.id`
2. `capture.grower_account_id` → `grower_account.id`
3. `capture.device_configuration_id` → `device_configuration.id`
4. `capture.session_id` → `session.id`
5. `capture.species_id` → `tree.species_id` (if present)
6. `capture_tag.capture_id` → `capture.id`
7. `capture_tag.tag_id` → `tag.id`
8. `tree_tag.tree_id` → `tree.id`
9. `tree_tag.tag_id` → `tag.id`
10. `grower_account_org.grower_account_id` → `grower_account.id`
11. `grower_account_image.grower_account_id` → `grower_account.id`
12. `region.collection_id` → `collection.id`
13. `session.device_configuration_id` → `device_configuration.id`
14. `session.originating_wallet_registration_id` → `wallet_registration.id`
15. `session_segment.session_id` → `session.id`
16. `raw_capture.session_id` → `session.id`
17. `raw_capture.session_segment_id` → `session_segment.id`
18. `app_config.stakeholder_id` → `stakeholder.id`
19. `app_installation.app_config_id` → `app_config.id`
20. `token.capture_id` → `capture.id`
21. `token.wallet_id` → `wallet.id`
22. `track.session_id` → `session.id`
23. `stakeholder_relation.parent_id` → `stakeholder.id`
24. `stakeholder_relation.child_id` → `stakeholder.id`
25. `wallet_event.wallet_id` → `wallet.id`
26. `wallet_registration.grower_account_id` → `grower_account.id`
27. `wallet_trust.actor_wallet_id` → `wallet.id`
28. `wallet_trust.target_wallet_id` → `wallet.id`
29. `wallet_trust.originator_wallet_id` → `wallet.id`
30. `wallet_trust_log.wallet_trust_id` → `wallet_trust.id`
31. `wallet_trust_log.actor_wallet_id` → `wallet.id`
32. `wallet_trust_log.target_wallet_id` → `wallet.id`
33. `wallet_trust_log.originator_wallet_id` → `wallet.id`


## Join Tables

These tables facilitate many-to-many relationships:

1. **capture_tag** – Connects captures and tags.
2. **tree_tag** – Connects trees and tags.
3. **grower_account_org** – Connects grower accounts and organizations.
4. **stakeholder_relation** – Connects stakeholders in a hierarchy.


## PostGIS Support Tables

PostGIS spatial metadata tables used to enable geospatial functionality:

1. **spatial_ref_sys**

> **Note:** Many tables use PostGIS geometry/geography columns for spatial data (notably tree, capture, region, session_segment).  
> `geometry_columns` and `geography_columns` are PostGIS system views (not physical tables), but are important for spatial metadata and may be referenced by spatial applications.


## Other Notable Aspects

- **Partitioned Tables:** `domain_event` and related event tables are partitioned for scale and performance.
- **Blockchain/Tokenization:** `token`, `transfer`, `transaction`, and audit tables enable digital asset management.
- **Denormalized Reporting:** `capture_denormalized` and `tree_denormalized` provide reporting-friendly flat data.
- **Device/App Tracking:** `session`, `device_configuration`, and `app_installation` support robust mobile data collection.
- **Trust Relationships:** `wallet_trust` and `wallet_trust_log` model complex trust and authorization flows.
- **Spatial Data:** Many tables use PostGIS geometry/geography columns for spatial data (notably tree, capture, region, session_segment).
- **Materialized Views:** `capture_tree_match` is present for spatial/temporal matching of captures to trees.