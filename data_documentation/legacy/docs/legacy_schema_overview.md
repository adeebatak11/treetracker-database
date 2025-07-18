# Legacy Schema Overview

This document provides an overview of the legacy PostgreSQL schema used by the Treetracker system, as visualized in the ERD and confirmed via direct schema inspection. Currently, it summarizes key tables, views, and their relationships to support domain migration efforts.

This document aims to deepen the level of detail about the legacy schema to support best practices in data governance and documentation.

## Tables

### Key Tables

1. **trees** – Central table for tree records, including time, status, user, location, settings, photos, certificate, and coordinates.
2. **users** – Stores user information such as name, email, organization, phone, and password reset details.
3. **locations** – Contains latitude, longitude, GPS accuracy, and associated user.
4. **photos** – Records images with metadata, linked to users and locations.
5. **tree_species** – Reference table listing species names, descriptions, and status.
6. **donors** – Tracks donor information, linked to organizations.
7. **certificates** – Certificates issued to donors for verified contributions.
8. **organizations** – Stores names of associated organizations.
9. **note_trees** – Join table linking notes and trees (many-to-many).
10. **photo_trees** – Join table linking photos and trees (many-to-many).

### All Tables (Alphabetical)

1. **admin_role** – Admin role definitions.
2. **admin_user** – Admin user accounts.
3. **admin_user_role** – Links admin users to roles.
4. **api_key** – API key management.
5. **audit** – Audit logs for system actions.
6. **bulk_tree_upload** – Bulk tree upload tracking.
7. **certificates** – Certificates issued to donors.
8. **clusters** – Spatial clusters of trees.
9. **contract** – Contract records.
10. **devices** – Device metadata.
11. **domain_event** – Domain event log (partitioned).
12. **domain_event_handled** – Handled domain events (partitioned).
13. **domain_event_handled_2021** – Handled domain events for 2021.
14. **domain_event_handled_2022** – Handled domain events for 2022.
15. **domain_event_handled_2023** – Handled domain events for 2023.
16. **domain_event_raised** – Raised domain events.
17. **domain_event_received** – Received domain events.
18. **domain_event_sent** – Sent domain events (partitioned).
19. **domain_event_sent_2021** – Sent domain events for 2021.
20. **domain_event_sent_2022** – Sent domain events for 2022.
21. **domain_event_sent_2023** – Sent domain events for 2023.
22. **donors** – Donor information.
23. **entity** – Entity records for relationships.
24. **entity_manager** – Entity manager status.
25. **entity_relationship** – Relationships between entities.
26. **entity_role** – Entity role definitions.
27. **locations** – Tree planting locations.
28. **migrations** – Database migration tracking.
29. **note_trees** – Links notes and trees (many-to-many).
30. **notes** – User-generated notes.
31. **organizations** – Organization names.
32. **payment** – Payment records.
33. **pending_update** – Pending updates for trees/locations.
34. **photo_trees** – Links photos and trees (many-to-many).
35. **photos** – Tree photos and metadata.
36. **planter** – Planter user records.
37. **planter_registrations** – Planter registration records.
38. **region** – Geographic regions.
39. **region_type** – Region type definitions.
40. **region_zoom** – Region zoom levels.
41. **settings** – User/tree settings.
42. **spatial_ref_sys** – PostGIS spatial reference system.
43. **tag** – Tag definitions.
44. **token** – User authentication tokens.
45. **transaction** – Transaction records.
46. **transfer** – Transfer records.
47. **tree_attributes** – Tree attribute metadata.
48. **tree_name** – Tree name records.
49. **tree_region** – Links trees to regions.
50. **tree_species** – Tree species reference.
51. **tree_tag** – Tree tag assignments.
52. **trees** – Tree records.
53. **users** – User accounts.


## Materialized Views

1. **active_tree_region** – A materialized view linking active trees to their regions for efficient spatial queries.
2. **trees_active** – A materialized view providing a cached list of all active trees for performance optimization in queries involving active status.


## Foreign Keys & Relationships



1. `locations.planter_id` → `planter.id`
2. `notes.planter_id` → `planter.id`
3. `pending_update.planter_id` → `planter.id`
4. `trees.payment_id` → `payment.id`
5. `trees.planter_id` → `planter.id`
6. `trees.planting_organization_id` → `entity.id`
7. `planter.organization_id` → `entity.id`
8. `planter.person_id` → `entity.id`
9. `payment.receiver_entity_id` → `entity.id`
10. `payment.sender_entity_id` → `entity.id`
11. `token.entity_id` → `entity.id`
12. `token.tree_id` → `trees.id`
13. `transaction.receiver_entity_id` → `entity.id`
14. `transaction.sender_entity_id` → `entity.id`
15. `transaction.token_id` → `token.id`
16. `entity_role.entity_id` → `entity.id`
17. `entity_manager.child_entity_id` → `entity.id`
18. `entity_manager.parent_entity_id` → `entity.id`


## Join Tables

These tables facilitate many-to-many relationships:

1. **note_trees** – Connects notes and trees.
2. **photo_trees** – Connects photos and trees.


## PostGIS Support Tables

PostGIS spatial metadata tables used to enable geospatial functionality:

1. **spatial_ref_sys**

> **Note:** `geometry_columns` and `geography_columns` are PostGIS system views (not physical tables), but are important for spatial metadata and may be referenced by spatial applications.
