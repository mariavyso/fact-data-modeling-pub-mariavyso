-- the incremental query to populate the table 'user_devices_cumulated' from the 'web_events' and 'devices' tables
INSERT INTO
    mariavyso.user_devices_cumulated
WITH
    yesterday AS (
        -- select all columns from 'user_devices_cumulated' table for the date '2023-01-01'
        SELECT
            *
        FROM
            mariavyso.user_devices_cumulated
        WHERE
            date = DATE ('2023-01-01')
    ),
    today AS (
        -- select user_id and browser_type, and aggregate distinct active dates for each user and browser type
        SELECT
            we.user_id,
            d.browser_type,
            array_agg (
                DISTINCT CAST(date_trunc ('day', we.event_time) AS DATE)
            ) AS dates_active,
            count(1) as event_count
        FROM
            bootcamp.devices d
            -- left join the 'devices' table with the 'web_events' table on device_id
            LEFT JOIN bootcamp.web_events we ON d.device_id = we.device_id
        WHERE
            -- filter events to include only those from '2023-01-02'
            date_trunc ('day', we.event_time) = DATE ('2023-01-02')
            -- Group by user_id and browser_type
        GROUP BY
            we.user_id,
            d.browser_type
    )
    -- select and combine data from 'yesterday' and 'today' CTEs
SELECT
    -- use COALESCE to handle cases where either 'yesterday' or 'today' has a missing user_id or browser_type
    COALESCE(y.user_id, t.user_id) AS user_id,
    COALESCE(y.browser_type, t.browser_type) AS browser_type,
    -- combine active dates from 'yesterday' and 'today'
    CASE
        WHEN y.dates_active IS NOT NULL THEN t.dates_active || y.dates_active
        ELSE t.dates_active
    END AS dates_active,
    -- set the date for the inserted records to '2023-01-02'
    DATE ('2023-01-02') AS date
FROM
    -- perform a full outer join on 'user_id' between 'yesterday' and 'today' CTEs
    yesterday y
    FULL OUTER JOIN today t ON y.user_id = t.user_id
