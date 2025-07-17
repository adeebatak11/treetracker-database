CREATE MATERIALIZED VIEW active_tree_region AS
    SELECT tree_region.id,
    tree_id,
    region.id AS region_id,
    region.centroid,
    region.type_id,
    tree_region.zoom_level
   FROM tree_region
     JOIN trees ON trees.id = tree_region.tree_id
     JOIN region ON region.id = tree_region.region_id
  WHERE trees.active = true;

CREATE MATERIALIZED VIEW trees_active AS 
    SELECT trees.id,
    trees.time_created,
    trees.time_updated,
    trees.missing,
    trees.priority,
    trees.cause_of_death_id,
    trees.planter_id AS user_id,
    trees.primary_location_id,
    trees.settings_id,
    trees.override_settings_id,
    trees.dead,
    trees.photo_id,
    trees.image_url,
    trees.certificate_id,
    trees.estimated_geometric_location,
    trees.lat,
    trees.lon,
    trees.gps_accuracy,
    trees.active,
    trees.planter_photo_url,
    trees.planter_identifier,
    trees.device_id,
   -- trees.sequence,
    trees.note,
    trees.verified,
    trees.uuid,
    trees.approved,
    trees.status,
    trees.cluster_regions_assigned
   FROM trees
  WHERE trees.active = true;

-- mark views as migrated

INSERT INTO migrations (name, run_on)
VALUES 
  ('20200715213554-CreateMaterializedViewActiveTreeRegion', NOW()),
  ('20200821194726-FixImageUrlColumnType', NOW());