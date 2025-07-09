{% materialization procedure_output, adapter="bigquery" %}
{%- set target = adapter.quote(this.database ~ '.' ~ this.schema ~ '.' ~ this.identifier) -%}

{%- set target_relation = api.Relation.create(identifier=this.identifier, schema=this.schema, database=this.database) -%}

{%- set output_select=config.get('output_select') -%}

{%- set create_sql -%}
BEGIN

  {{ sql }}

  CREATE OR REPLACE TABLE {{ target }}
  AS SELECT {{ output_select }};

END
{%- endset -%}

{% call statement('main') -%}
  {{ create_sql }}
{%- endcall %}

{{ return({'relations': [target_relation]}) }}

{% endmaterialization %}