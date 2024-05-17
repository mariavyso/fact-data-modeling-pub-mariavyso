-- create a monthly host_activity_reduced table
CREATE OR REPLACE TABLE mariavyso.host_activity_reduced (
    host VARCHAR,
    metric_name VARCHAR,
    metric_array ARRAY(integer),
    month_start VARCHAR
)
WITH
    (
        format = 'PARQUET',
        partitioning = ARRAY['metric_name', 'month_start']
    )
