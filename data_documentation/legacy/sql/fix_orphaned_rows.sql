-- Remove orphaned pending_update rows before FK enforcement
SELECT * FROM pending_update 
WHERE planter_id NOT IN (SELECT id FROM planter);

DELETE FROM pending_update 
WHERE planter_id NOT IN (SELECT id FROM planter);

-- Remove orphaned locations rows before FK enforcement
SELECT * FROM locations
WHERE planter_id IS NOT NULL
  AND planter_id NOT IN (SELECT id FROM planter);

DELETE FROM locations
WHERE planter_id IS NOT NULL
  AND planter_id NOT IN (SELECT id FROM planter);

-- Remove orphaned notes rows before FK enforcement
SELECT * FROM notes
WHERE planter_id IS NOT NULL
  AND planter_id NOT IN (SELECT id FROM planter);

DELETE FROM notes 
WHERE planter_id IS NOT NULL 
AND planter_id NOT IN (SELECT id FROM planter);