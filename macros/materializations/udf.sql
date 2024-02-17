{% materialization udf, adapter="bigquery" %}
{%- set target = adapter.quote(this.database ~ '.' ~ this.schema ~ '.' ~ this.identifier) -%}

{%- set parameter_list=config.get('parameter_list') -%}
{%- set ret=config.get('returns') -%}
{%- set description=config.get('description') -%}

{%- set create_sql -%}
CREATE OR REPLACE FUNCTION {{ target }}({{ parameter_list }})
RETURNS {{ ret }}
OPTIONS (
  description='{{ description }}'
)
AS (
  {{ sql }}
);
{%- endset -%}

{% call statement('main') -%}
  {{ create_sql }}
{%- endcall %}

{{ return({'relations': []}) }}

{% endmaterialization %}