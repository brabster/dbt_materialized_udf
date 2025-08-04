WITH examples AS (
    SELECT 'foo' input, 'ACBD18DB4CC2F85CEDEF654FCCC4A4D8' expected
    UNION ALL SELECT 'microsoft', '5F532A3FC4F1EA403F37070F59A7A53A'
    UNION ALL SELECT 'tesla', 'BC250E0D83C37B0953ADA14E7BBC1DFD'
    UNION ALL SELECT '', 'D41D8CD98F00B204E9800998ECF8427E'
),

test AS (
    SELECT
        *,
        {{ ref('url_safe_hash') }}(input) actual
    FROM examples
)

SELECT
    *
FROM test
WHERE actual IS DISTINCT FROM expected