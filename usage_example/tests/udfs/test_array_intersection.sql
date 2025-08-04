WITH str_examples AS (
    SELECT ARRAY['a', 'b', 'c'] ls, ARRAY['b', 'c', 'd'] rs, ARRAY['b', 'c'] expected
    UNION ALL SELECT ARRAY['a', 'b', 'c'] ls, ARRAY['c', 'd'] rs, ARRAY['c'] expected
    UNION ALL SELECT ARRAY['a', 'b', 'c'] ls, NULL rs, ARRAY[] expected
),

int_examples AS (
    SELECT ARRAY[1,2,3] ls, ARRAY[2,3,4] rs, ARRAY[2,3] expected
    UNION ALL SELECT ARRAY[1,2,3] ls, ARRAY[3,4] rs, ARRAY[3] expected
    UNION ALL SELECT ARRAY[1,2,3] ls, NULL rs, ARRAY[] expected
),

test AS (
    SELECT
        TO_JSON_STRING(ls) ls,
        TO_JSON_STRING(rs) rs,
        TO_JSON_STRING(expected) expected,
        TO_JSON_STRING({{ ref('array_intersection') }}(ls, rs)) actual
    FROM str_examples
    UNION ALL
    SELECT
        TO_JSON_STRING(ls) ls,
        TO_JSON_STRING(rs) rs,
        TO_JSON_STRING(expected) expected,
        TO_JSON_STRING({{ ref('array_intersection') }}(ls, rs)) actual
    FROM int_examples
)

SELECT
    *
FROM test
WHERE actual IS DISTINCT FROM expected