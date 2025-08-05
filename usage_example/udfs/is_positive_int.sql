{{ config(
    materialized='udf',
    parameter_list='a_string STRING',
    description='True if the value is a positive int'
) }}
REGEXP_CONTAINS(a_string, r'^\+?[0-9]+$')