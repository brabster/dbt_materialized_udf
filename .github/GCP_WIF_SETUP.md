Based on https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions

Setting up a Workload Identity Federation for GitHub action.
Assumes $DBT_PROJECT is set to the project you want the pool/provider in.

# Setup WIF in-project

Unsure whether setting up a WIF pool/provider for each project is the best way, but it seems like the least risky.

## Gather some info

```console
export WIF_PROJECT_NUMBER=$(gcloud projects describe "${DBT_PROJECT}" --format="value(projectNumber)")
export WIF_POOL=dbt-pool
export WIF_PROVIDER=dbt-provider
export WIF_GITHUB_REPO=$(git remote get-url origin|cut -d: -f2|cut -d. -f1)
export WIF_SERVICE_ACCOUNT=pypi-vulnerabilities
```
## Ensure IAM APIs enabled

```console
gcloud services enable iamcredentials.googleapis.com --project "${DBT_PROJECT}"
```

## Setup Service Account

```console
gcloud iam service-accounts create "${WIF_SERVICE_ACCOUNT}" \
    --project="${DBT_PROJECT}" \
    --description="DBT service account" \
    --display-name="${WIF_SERVICE_ACCOUNT}"
```

## Setup Workload Identity Provider

```console
gcloud iam workload-identity-pools create "${WIF_POOL}" \
  --project="${DBT_PROJECT}" \
  --location="global" \
  --display-name="DBT Pool"
```

```console
gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER}" \
  --project="${DBT_PROJECT}" \
  --location="global" \
  --workload-identity-pool="${WIF_POOL}" \
  --display-name="DBT provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

## Collect up IDs of the Workload Identity Pool and Provider

```console
export WIF_POOL_PROVIDER_ID=$(gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER}" --location=global --project "${DBT_PROJECT}" --workload-identity-pool "${WIF_POOL}" --format="value(name)")
export WIF_POOL_ID=$(gcloud iam workload-identity-pools describe "${WIF_POOL}" --location=global --project "${DBT_PROJECT}" --format="value(name)")
```

## Setup IAM to allow GitHub to assume role

```console
gcloud iam service-accounts add-iam-policy-binding "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" \
  --project="${DBT_PROJECT}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WIF_POOL_ID}/attribute.repository/${WIF_GITHUB_REPO}"
```

```console
gcloud iam service-accounts add-iam-policy-binding "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" \
  --project="${DBT_PROJECT}" \
  --role="roles/iam.serviceAccountTokenCreator" \
  --member="serviceAccount:${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" 
```

## Grant Service Account BigQuery admin in the project

(You may need to make this policy more specific!)

```console
gcloud projects add-iam-policy-binding "${DBT_PROJECT}" \
  --role="roles/bigquery.admin" \
  --member="serviceAccount:${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com" 
```

## Recover Secrets for GitHub

Populate secrets for this build as described below

```console
echo "GitHub Secret: GCP_WORKLOAD_IDENTITY_PROVIDER"
gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER}" --location=global --project "${DBT_PROJECT}" --workload-identity-pool "${WIF_POOL}" --format="value(name)"
```

```console
echo "GitHub Secret: GCP_SERVICE_ACCOUNT"
echo "${WIF_SERVICE_ACCOUNT}@${DBT_PROJECT}.iam.gserviceaccount.com"
```

