-- insert data into the 'host_activity_reduced' table from 'daily_web_metrics'
INSERT INTO
    mariavyso.host_activity_reduced
WITH
    yesterday AS (
        -- select all columns from 'host_activity_reduced' table for the month starting '2023-08-01'
        SELECT
            *
        FROM
            mariavyso.host_activity_reduced
        WHERE
            month_start = '2023-08-01'
    ),
    today AS (
        -- select all columns from 'daily_web_metrics' table for the date '2023-08-04'
        SELECT
            *
        FROM
            mariavyso.daily_web_metrics
        WHERE
            DATE = DATE('2023-08-04')
    )
SELECT
    COALESCE(t.host, y.host) AS host,
    COALESCE(t.metric_name, y.metric_name) AS metric_name,
    -- combine metric arrays from 'yesterday' and 'today'
    COALESCE(
        y.metric_array,
        -- if 'y.metric_array' is NULL, create an array with NULL values
        REPEAT(
            NULL,
            -- calculate the difference in days between '2023-08-01' and 't.date' and cast it as INTEGER
            CAST(
                DATE_DIFF('day', DATE('2023-08-01'), t.date) AS INTEGER
            )
        )
    ) || ARRAY[t.metric_value] AS metric_array,
    -- set the month_start for the inserted records to '2023-08-01'
    '2023-08-01' AS month_start
FROM
    today t
    FULL OUTER JOIN yesterday y ON t.host = y.host
    AND t.metric_name = y.metric_name
