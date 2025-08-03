{{ config(
    materialized='udaf',
    parameter_list='threshold INT NOT AGGREGATE',
    description='Returns the count of rows, unless the count is less than threshold, when it returns NULL. NULL as threshold behaves as zero.'
) }}
IF(COUNT(1) < threshold, NULL, COUNT(1))
