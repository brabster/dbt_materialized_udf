{{ config(
    materialized='procedure_output',
    output_select='result.x AS chi_square_statistic, result.dof AS degrees_of_freedom, result.p AS p_value',
) }}
DECLARE result STRUCT<x FLOAT64, dof FLOAT64, p FLOAT64>;

CALL bqutil.procedure.chi_square(
    'bigquery-public-data.ml_datasets.penguins',
    'island',
    'species',
    result
);