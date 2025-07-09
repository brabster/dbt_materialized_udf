{% materialization udf, adapter="bigquery" %}
{%- set target = adapter.quote(this.database ~ '.' ~ this.schema ~ '.' ~ this.identifier) -%}

{%- set target_relation = api.Relation.create(identifier=this.identifier, schema=this.schema, database=this.database) -%}

{%- set parameter_list=config.get('parameter_list') -%}
{%- set ret=config.get('returns') -%}
{%- set description=config.get('description') -%}

{%- set create_sql -%}
CREATE OR REPLACE FUNCTION {{ target }}({{ parameter_list }})
{%- if ret %}
RETURNS {{ ret }}
{%- endif %}
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

{{ return({'relations': [target_relation]}) }}

{% endmaterialization %}