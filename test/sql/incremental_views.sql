\set SHOW_CONTEXT never
SET client_min_messages TO WARNING;

CREATE EXTENSION IF NOT EXISTS pg_ivm;
CREATE EXTENSION IF NOT EXISTS timeseries CASCADE;

CREATE TABLE ivm_events (
  user_id bigint,
  event_id bigint,
  event_time timestamptz NOT NULL,
  value float
) PARTITION BY RANGE (event_time);
SELECT enable_ts_table('ivm_events');

COPY ivm_events FROM STDIN WITH (FORMAT 'csv');
1,1,"2020-11-04 15:51:02.226999-08",1.1
1,2,"2020-11-04 15:53:02.226999-08",1.2
1,3,"2020-11-04 15:55:02.226999-08",1.3
1,4,"2020-11-04 15:57:02.226999-08",1.4
1,5,"2020-11-04 15:58:02.226999-08",1.5
1,6,"2020-11-04 15:59:02.226999-08",1.6
2,7,"2020-11-04 15:51:02.226999-08",1.7
2,8,"2020-11-04 15:53:02.226999-08",1.8
2,9,"2020-11-04 15:55:02.226999-08",1.9
2,10,"2020-11-04 15:57:02.226999-08",2.0
2,11,"2020-11-04 15:58:02.226999-08",2.1
2,12,"2020-11-04 15:59:02.226999-08",2.2
\.

CREATE VIEW ivm_events_5m AS
  SELECT
    user_id,
    date_bin('5 minutes',
             event_time,
             TIMESTAMPTZ '1970-01-01') AS event_time,
    max(value),
    min(value)
    FROM ivm_events
    GROUP BY 1, 2;

CREATE VIEW ivm_events_totals AS
  SELECT
    user_id,
    sum(value),
    count(user_id)
  FROM ivm_events
  GROUP BY 1;

SELECT make_view_incremental('ivm_events_5m');
SELECT make_view_incremental('ivm_events_totals');

SELECT * FROM ivm_events_5m ORDER BY 1, 2;
SELECT * FROM ivm_events_totals ORDER BY 1;
INSERT INTO ivm_events VALUES (3, 1, '2020-11-04 15:51:02.226999-08', 1.1);
DELETE FROM ivm_events WHERE event_id = 12;

SELECT * FROM ivm_events_5m ORDER BY 1, 2;
SELECT * FROM ivm_events_totals ORDER BY 1;
