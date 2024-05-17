-- query to incrementally populate the hosts_cumulated table from the web_events table
INSERT INTO
    mariavyso.hosts_cumulated
WITH
    yesterday AS (
        -- select all columns from 'hosts_cumulated' table for the date '2023-01-04'
        SELECT
            *
        FROM
            mariavyso.hosts_cumulated
        WHERE
            date = DATE('2023-01-04')
    ),
    today AS (
        -- select host and the truncated date of event_time as host_activity_datelist
        SELECT
            host,
            CAST(date_trunc('day', event_time) AS DATE) AS host_activity_datelist,
            count(1)
        FROM
            bootcamp.web_events
        WHERE
            -- filter events to include only those from '2023-01-05'
            date_trunc('day', event_time) = DATE('2023-01-05')
        GROUP BY
            -- Group by host and the truncated date of event_time
            host,
            CAST(date_trunc('day', event_time) AS DATE)
    )
SELECT
    -- use COALESCE to handle cases where either 'yesterday' or 'today' has a missing host
    COALESCE(y.host, t.host) AS host,
    -- combine activity date lists from 'yesterday' and 'today'
    CASE
        WHEN y.host_activity_datelist IS NOT NULL THEN ARRAY[t.host_activity_datelist] || y.host_activity_datelist
        ELSE ARRAY[t.host_activity_datelist]
    END AS host_activity_datelist,
    -- set the date for the inserted records to '2023-01-05'
    DATE('2023-01-05') AS date
FROM
    -- perform a full outer join on 'host' between 'yesterday' and 'today' CTEs
    yesterday y
    FULL OUTER JOIN today t ON y.host = t.host
