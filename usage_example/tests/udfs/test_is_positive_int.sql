WITH examples AS (
    SELECT '10' input, TRUE expected
    UNION ALL SELECT '-4', FALSE expected
    UNION ALL SELECT '+8', TRUE expected
    UNION ALL SELECT '1.0', FALSE expected
),

test AS (
    SELECT
        *,
        {{ ref('is_positive_int') }}(input) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE actual IS DISTINCT FROM expected