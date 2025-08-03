{{ config(
    materialized='udf',
    parameter_list='ls ANY TYPE, rs ANY TYPE',
    description='Array of common elements in arrays ls and rs. Empty array if one argument is NULL'
) }}
(SELECT
    COALESCE(ARRAY_AGG(intersection_elements), ARRAY[]) intersection_array
FROM (
    SELECT DISTINCT
        element intersection_elements
    FROM UNNEST(ls) element
    WHERE element IN (SELECT element FROM UNNEST(rs) element)
))