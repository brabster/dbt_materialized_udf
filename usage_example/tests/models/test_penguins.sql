SELECT
    *
FROM {{ ref('penguins') }}
WHERE
    degrees_of_freedom != 4.0
    OR p_value != 0
    OR FLOOR(chi_square_statistic) != 192
