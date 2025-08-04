# Usage examples for dbt_materialized_udf

This dbt project serves as a example and set of test cases for the custom materializations defined in the parent `dbt_materialized_udf` project. It demonstrates how to define user-defined functions (UDFs), user-defined aggregate functions (UDAFs), and define and call stored procedures directly within your dbt models, treating them as first-class citizens in your data transformation workflow.

As configured in this project's `dbt_project.yml`, models for these custom types are organized into the `udfs/`, `udafs/`, and `procedures/` directories.

## Custom materializations

Below is a summary of the available materializations and how to use them.

### `udf`

This materialization allows you to define a scalar User-Defined Function as a dbt model.

**Use Case:** Creating a stable, portable, and reusable hashing algorithm.

**Example ([`udfs/url_safe_hash.sql`](udfs/url_safe_hash.sql)):**
```sql
{{ config(
    materialized='udf',
    parameter_list='val STRING',
    description='Returns a portable hash of the input value.'
) }}
UPPER(TO_HEX(MD5(val)))
```

**Tests:**
- [`tests/udfs/test_url_safe_hash.sql`](tests/udfs/test_url_safe_hash.sql)

### `udaf`

This materialization allows you to define a User-Defined Aggregate Function as a dbt model.

**Use Case:** Capturing logic to count members of a group, but nullifying the result if the count is below a certain privacy threshold.

**Example ([`udafs/privacy_preserving_count.sql`](udafs/privacy_preserving_count.sql)):**
```sql
{{ config(
    materialized='udaf',
    parameter_list='threshold INT NOT AGGREGATE',
    description='Returns the count of rows, unless the count is less than threshold, when it returns NULL. NULL as threshold behaves as zero.'
) }}
IF(COUNT(1) < threshold, NULL, COUNT(1))
```

**Tests:**
- [`tests/udafs/test_privacy_preserving_count_5.sql`](tests/udafs/test_privacy_preserving_count_5.sql)
- [`tests/udafs/test_privacy_preserving_count_null.sql`](tests/udafs/test_privacy_preserving_count_null.sql)

### `procedure`

Defines a stored procedure as a dbt model.

**Use Case:** Count the rows in a given relation, where the relation is a parametrized.

**Example ([`procedures/row_count.sql`](procedures/row_count.sql)):**
```sql
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
```

**Tests:**
I've found stored procedures producing output like this are trickier to test directly in the style of dbt, but the next materialization helped.

### `procedure_output`

This materialization enables you to materialize the result of a stored procedure call as a dbt model.

**Use Case:** Running a chi-squared statistical test from BigQuery's `bqutil` public dataset and capturing the results in a table. I used the `bigquery-public-data.ml_datasets.penguins` dataset from the BigQuery public datasets for the example. Do penguin species prefer certain islands?

**Example (`models/procedures/chi_squared_test.sql`):**
```sql
{{ config(
    materialized='procedure_output',
    output_select='result.x AS chi_square_statistic, result.dof AS degrees_of_freedom, result.p AS p_value',
) }}
DECLARE result STRUCT<x FLOAT64, dof FLOAT64, p FLOAT64>;

CALL (bqutil.procedure.chi_square
    'bigquery-public-data.ml_datasets.penguins',
    'island',
    'species',
    result
);
```

**Tests:**
- [`tests/models/test_penguins.sql`](tests/models/test_penguins.sql)


## Abstracting external dependencies

In the `procedure_output` example above, the procedure `bqutil.procedure_eu.chi_square` is hardcoded. dbt's "source" abstraction allows me to reference a procedure, udf or udaf external to the current project.

I've demonstrated that idea in [`models/source_bqutil.yml`](models/source_bqutil.yml):

```yaml
version: 2

sources:
    - name: bqutil
      database: bqutil
      schema: procedure
      tables:
        - name: chi_square
```    

My procedure call now becomes:

```sql
CALL ({{ source('bqutil', 'chi_square') }}
    'bigquery-public-data.ml_datasets.penguins',
...
```

This allows you to reference the procedure as `{{ source('bqutil', 'chi_square') }}` in your model. I've found this is useful in maintaining visibility of where I have external dependencies, as well as allowing me to add my own documentation about the procedure, udf or udaf in the schema file.

## dbt run evidence

I haven't set up GitHub actions automation for this project, but here's the output of a `dbt build` running in my codespace against a BigQuery sandbox account:

```session
(venv) vscode@codespaces-xxxxx:/workspaces/dbt_materialized_udf/usage_example$ dbt build
09:25:54  Running with dbt=1.10.6
09:25:56  Registered adapter: bigquery=1.10.1
09:25:57  Found 6 models, 5 data tests, 1 source, 500 macros
09:25:57  
09:25:57  Concurrency: 8 threads (target='current')
09:25:57  
09:25:58  2 of 11 START sql procedure_output model sandbox.penguins ...................... [RUN]
09:25:58  3 of 11 START sql udaf model sandbox.privacy_preserving_count .................. [RUN]
09:25:58  4 of 11 START sql procedure model sandbox.row_count ............................ [RUN]
09:25:58  5 of 11 START sql udf model sandbox.url_safe_hash .............................. [RUN]
09:25:58  1 of 11 START sql udf model sandbox.array_intersection ......................... [RUN]
09:25:59  1 of 11 OK created sql udf model sandbox.array_intersection .................... [None (0 processed) in 0.93s]
09:25:59  5 of 11 OK created sql udf model sandbox.url_safe_hash ......................... [None (0 processed) in 0.94s]
09:25:59  6 of 11 START test test_array_intersection ..................................... [RUN]
09:25:59  7 of 11 START test test_url_safe_hash .......................................... [RUN]
09:25:59  3 of 11 OK created sql udaf model sandbox.privacy_preserving_count ............. [None (0 processed) in 0.99s]
09:25:59  8 of 11 START test test_privacy_preserving_count_5 ............................. [RUN]
09:25:59  9 of 11 START test test_privacy_preserving_count_null .......................... [RUN]
09:26:00  4 of 11 OK created sql procedure model sandbox.row_count ....................... [SCRIPT (0 processed) in 1.30s]
09:26:00  7 of 11 PASS test_url_safe_hash ................................................ [PASS in 1.04s]
09:26:00  8 of 11 PASS test_privacy_preserving_count_5 ................................... [PASS in 1.05s]
09:26:01  9 of 11 PASS test_privacy_preserving_count_null ................................ [PASS in 1.13s]
09:26:01  6 of 11 PASS test_array_intersection ........................................... [PASS in 1.26s]
09:26:03  2 of 11 OK created sql procedure_output model sandbox.penguins ................. [SCRIPT (15.3 KiB processed) in 4.90s]
09:26:03  10 of 11 START test test_penguins .............................................. [RUN]
09:26:04  10 of 11 PASS test_penguins .................................................... [PASS in 1.11s]
09:26:04  11 of 11 START sql procedure_output model sandbox.penguins_row_count ........... [RUN]
09:26:08  11 of 11 OK created sql procedure_output model sandbox.penguins_row_count ...... [SCRIPT (0 processed) in 3.15s]
09:26:08  
09:26:08  Finished running 1 procedure model, 2 procedure output models, 5 data tests, 1 udaf model, 2 udf models in 0 hours 0 minutes and 10.29 seconds (10.29s).
09:26:08  
09:26:08  Completed successfully
09:26:08  
09:26:08  Done. PASS=11 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=11
```