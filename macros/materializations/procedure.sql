{% materialization procedure, adapter="bigquery" %}
{%- set target = adapter.quote(this.database ~ '.' ~ this.schema ~ '.' ~ this.identifier) -%}

{%- set target_relation = api.Relation.create(identifier=this.identifier, schema=this.schema, database=this.database) -%}

{%- set parameter_list=config.get('parameter_list') -%}
{%- set description=config.get('description') -%}

{%- set create_sql -%}
CREATE OR REPLACE PROCEDURE {{ target }}({{ parameter_list }})
OPTIONS (
  description='{{ description }}'
)
BEGIN
  {{ sql }}
END;
{%- endset -%}

{% call statement('main') -%}
  {{ create_sql }}
{%- endcall %}

{{ return({'relations': [target_relation]}) }}

{% endmaterialization %}