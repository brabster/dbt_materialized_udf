WITH examples AS (
    SELECT [1, 2, 3, 4] test_table, NULL expected
    UNION ALL SELECT [1, 2, 3, 4, 5], 5
    UNION ALL SELECT [1, 2], NULL
    UNION ALL SELECT [1, 2, 3], NULL
),

test AS (
    SELECT
      test_table,
      expected,
      {{ ref('privacy_preserving_count') }}(5) actual
    FROM examples
      CROSS JOIN UNNEST(test_table) test_rows
    GROUP BY ALL
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) IS DISTINCT FROM TO_JSON_STRING(expected)