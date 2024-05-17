-- convert the date list implementation into the base-2 integer 
-- datelist representation as shown in the fact data modeling day 2 lab
WITH
    today AS (
        -- select all columns from 'user_devices_cumulated' table for the date '2023-01-02'
        SELECT
            *
        FROM
            mariavyso.user_devices_cumulated
        WHERE
            date = DATE ('2023-01-02')
    ),
    date_list_int AS (
        -- select user_id and browser_type
        SELECT
            user_id,
            browser_type,
            -- calculate an integer representation of the active dates
            CAST(
                SUM(
                    CASE
                    -- check if 'dates_active' contains the 'sequence_date'
                        WHEN CONTAINS (dates_active, sequence_date) THEN
                        -- calculate a bit value based on the position of the date
                        POW (2, 31 - DATE_DIFF ('day', sequence_date, date))
                        ELSE 0
                    END
                ) AS BIGINT
            ) AS dates_active
        FROM
            today
            -- cross join with a sequence of dates from '2023-01-01' to '2023-01-02'
            CROSS JOIN UNNEST (
                SEQUENCE (DATE ('2023-01-01'), DATE ('2023-01-02'))
            ) AS t (sequence_date)
        GROUP BY
            -- group by user_id and browser_type
            user_id,
            browser_type
    )
    -- select all columns from 'date_list_int' CTE
SELECT
    *,
    -- convert the integer representation of active dates to a binary string
    TO_BASE (dates_active, 2) AS dates_in_binary
FROM
    date_list_int
