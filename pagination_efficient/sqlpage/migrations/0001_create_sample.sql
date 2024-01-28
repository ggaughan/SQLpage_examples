-- note: creates a large sample table
CREATE TABLE sample AS
    WITH RECURSIVE generate_series(value) AS (
      SELECT 1
      UNION ALL
      SELECT value+1 FROM generate_series WHERE value+1<=1000000
    )
    SELECT 
        value as sample_id, 
        lower(hex(randomblob(12))) as name, 
        upper(hex(randomblob(20))) as note, 
        random() as size 
    FROM generate_series
;
CREATE INDEX sample_name_id ON sample(name, sample_id);