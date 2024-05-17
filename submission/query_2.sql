-- create a cumulating user activity table by device
CREATE OR REPLACE TABLE mariavyso.user_devices_cumulated (
    user_id BIGINT,
    browser_type VARCHAR,
    dates_active ARRAY(DATE),
    date DATE
)
WITH
    (
        format = 'PARQUET',
        partitioning = ARRAY['date']
    )
