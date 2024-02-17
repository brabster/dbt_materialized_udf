DBT does not directly manage datasets/schemas and their permissions.

If you want to manage your dataset ACL as part of the build,
you can provide a JSON document describing the permissions you want as dataset_acl.json
and uncomment the commented-out `bq update` command in the workflow file dataset job.

See https://cloud.google.com/bigquery/docs/control-access-to-resources-iam#grant_access_to_a_dataset

```json
{
    "access": [

        {
            "role": "READER",
            "specialGroup": "projectReaders"
        },
        {
            "role": "WRITER",
            "specialGroup": "projectWriters"
        },
        {
            "role": "OWNER",
            "specialGroup": "projectOwners"
        }
    ]
}
```

Terraform is the other obvious option to manage datasets, but this adds complexity and a new toolset/supply chain

