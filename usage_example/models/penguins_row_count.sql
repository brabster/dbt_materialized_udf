{{ config(
    materialized='procedure_output',
    output_select='result AS row_count',
) }}
DECLARE result INT64;

CALL {{ ref('row_count') }}('{{ ref('penguins') }}', result);