{{ config(
    materialized='udf',
    parameter_list='str STRING',
    returns='STRING',
    description='Generates a hash of the input string, encoded to avoid any characters that cause UX problems in URLs. Uses well-established and portable functions'
) }}
UPPER(TO_HEX(MD5(str)))