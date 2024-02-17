Any seed data you need goes here.

See https://docs.getdbt.com/docs/build/seeds

# Gotchas

## Type Inference

dbt will try and infer types from column contents in your seed data.

That causes problems when seed data is updated and the inference chooses a different data type for a column.
For example, a column that happens to contain only numbers gets a new value that's not a number.

See: https://docs.getdbt.com/reference/resource-configs/column_types.


