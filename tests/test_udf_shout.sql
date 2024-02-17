-- See https://www.equalexperts.com/blog/our-thinking/testing-and-deploying-udfs-with-dbt
WITH examples AS (
    SELECT 'hello' AS say, 'HELLO!' AS expected
    UNION ALL SELECT NULL AS say, NULL AS expected
    UNION ALL SELECT '' AS say, '!' AS expected
),

test AS (
    SELECT
        *,
        {{ target.schema }}.shout(say) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE TO_JSON_STRING(actual) != TO_JSON_STRING(expected)
