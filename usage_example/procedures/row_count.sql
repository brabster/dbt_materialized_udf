{{
  config(
    materialized='procedure',
    parameter_list='relation_name STRING, OUT row_count INT64',
    description='Accepts a relation name as a string and returns the row count.'
  )
}}

EXECUTE IMMEDIATE FORMAT("""
  SELECT COUNT(1) FROM %s
""", relation_name)
INTO row_count;