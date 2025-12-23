\set SHOW_CONTEXT never
SET client_min_messages TO WARNING;

CREATE EXTENSION IF NOT EXISTS citus;
CREATE EXTENSION IF NOT EXISTS citus_columnar;
CREATE EXTENSION IF NOT EXISTS timeseries CASCADE;

CREATE TABLE compression_test_measurements (
  metric_name text,
  metric_value numeric,
  metric_time timestamptz NOT NULL
) PARTITION BY RANGE (metric_time);

SELECT enable_ts_table('compression_test_measurements');

SELECT COUNT(*) > 10 AS has_partitions FROM ts_part_info WHERE table_id='compression_test_measurements'::regclass;
SELECT COUNT(*) > 0 AS "compressed?" FROM ts_part_info WHERE table_id='compression_test_measurements'::regclass AND access_method = 'columnar';

SELECT apply_compression_policy('compression_test_measurements', '1 day');
SELECT COUNT(*) > 0 AS "compressed?" FROM ts_part_info WHERE table_id='compression_test_measurements'::regclass AND access_method = 'columnar';