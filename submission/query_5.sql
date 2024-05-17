-- create a hosts_cumulated table
CREATE OR REPLACE TABLE mariavyso.hosts_cumulated (
    host VARCHAR,
    host_activity_datelist ARRAY(DATE),
    date DATE
)
WITH (
    format = 'PARQUET',
    partitioning = ARRAY['date']
)
