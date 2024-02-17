# Supporters

<a href="https://equalexperts.com">
    <img alt="Equal Experts logo"
        src="https://www.equalexperts.com/wp-content/themes/equalexperts/assets/logos/colour/equal-experts-logo-colour.png"
        style="height:75px">
    </img>
</a>

# Overview

Spend less time setting up and get to insights faster with this opinionated template for a standalone DBT-based project.

# Walkthrough Video

[Walkthrough Video on YouTube](https://youtu.be/KQg6D0Mkyks?si=PY3dnfYNa9G-8E62)

# Pre-Reqs

- Python == 3.11 (see https://docs.getdbt.com/faqs/Core/install-python-compatibility)
- [RECOMMENDED] VSCode to use built-in tasks
- Access to GCP Project enabled for BigQuery
- [RECOMMENDED] set environment variable `PIP_REQUIRE_VIRTUALENV=true`
    - Prevents accidentally installing to your system Python installation (if you have permissions to do so)

# Setup

## Setup Local

Setting up the local software without any need for Data Warehouse credentials.

A VSCode task triggers a shell script [.dev_scripts/init_and_update.sh](.dev_scripts/init_and_update.sh)
which should take care of setting up a virtualenv if necessary, then installing/updating software and running a vulnerability scan.

> Note - the vulnerability scan is performed using [safety](https://pypi.org/project/safety/), which is *not free for commercial use* and has limitations on freshness and completeness of the vulnerability database.

That script describes the steps involved in a full setup if you are unable to run a bash script and need to translate to some other language.

## Connect to Data Warehouse

Set up credentials and environment and test connectivity.

- update .env with appropriate values
    - note project ID not project name (manifests as 404 error)
    - `. .env` to update values in use in terminal
- get credentials
    - if no valid credential, then error message says default credentials not found
    - must be application default credential
    - `gcloud auth application-default login`
- `dbt debug` should now succeed and list settings/versions
    - if `dbt` is not found, you may need to activate your venv at the terminal as described earlier

# Assumptions

This repo is setup based on assumptions of specific ways of working that I have found to work well.
I'll try and describe them here.

The aim is to apply tried and tested practices that I generally refer to as "engineering" to analytics, so that trust and value can develop.
The following set of principles help explain the choices in this repo structure.

## Data-as-a-Product

Whilst this repo can be used for ad-hoc exploration, it's intended to support a shared set of data that consumers can influence and then build on with confidence.

## You Build It You Run It

A team is responsible for actively developing the data product this repository describes. That team is responsible for operating the product, resolving issues, and maintaining appropriate stability and robustness to build trust with consumers.

## Trunk-Based Development

There is a `main` branch, which is the current version of the data product. This is the only long-lived branch, and will persist from creation of the repository until it is decommissioned. Engineers will branch from `main` to implement a change, then a Pull Request process with appropriate approvals will control the merge of that change back to `main` as the next iteration of the data product.

## Developer Sandbox Datasets

In order to develop in a branching style without risk of collision between different work-in-progress, engineers will need a  sandbox dataset to work in. I've found that personal sandboxes in the same project as `main` is a simple approach that works well.
This repo assumes that developers will have such a sandbox (or will have permissions to create one, see `on-run-start` hook in [dbt_project.yml](dbt_project.yml)) and have set their local, personal `.env` variables to refer to it.

## Always Up-To-Date

There are several supply chains providing dependencies for this repo. When developing interactively, important sources are:

- Your Python runtime, including the venv module
- `pip` package manager in the virtualenv
- Python packages via PyPI
- dbt packages

Aside from the Python runtime which must be present to bootstrap the repo, these sources are set by default to update automatically to the latest available versions. A VSCode task is included to automatically update your local environment, and the CI system will update to latest on each run.

I believe this setup minimises the risk related to software dependencies that users of this template are exposed to by default.

## Self-Contained and Self-Describing

The repo aims to be as self-contained as possible, minimising what's needed in an engineer's development environment, and making the CI setup as similar as possible to that of the engineer's environment.