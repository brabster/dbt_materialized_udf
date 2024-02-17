You can put multiple models and sources into the same `.yml`, as is done in [the jaffle shop example project](https://github.com/dbt-labs/jaffle_shop/blob/main/models/schema.yml).

I have found that this quickly becomes difficult to manage.
The approach demonstrated here splits out each model into its own `.yml` config file, named for the associated `.sql` file.


This way, even when you have tens of models:
- it's easy to check that every model has an associated config
- it's easy to find the config associated with a `.sql` file as it will be immediately below in the file listing

# overview.md

You can set a custom overview for your project that appears in your dbt docs site.
See https://docs.getdbt.com/docs/collaborate/documentation#setting-a-custom-overview