{% macro ensure_udfs() %}
-- See https://www.equalexperts.com/blog/our-thinking/testing-and-deploying-udfs-with-dbt
CREATE OR REPLACE FUNCTION {{ target.schema }}.shout(say STRING)
RETURNS STRING
OPTIONS (description='Shouts the say string. NULL when argument is NULL')
AS (
  UPPER(say) || '!'
);

{% endmacro %}
