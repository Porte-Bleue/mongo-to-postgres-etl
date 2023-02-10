## Install dbt

```sh
pip install dbt-postgres
```

### Clone dbt repo:
```
git clone https://github.com/marielestavel/mongo-to-postgres-etl.git
```

### Install dependencies 

```sh
export DBT_ENV_SECRET_GIT_CREDENTIAL=$GITHUB_TOKEN
```

### Check dbt version and update dbt dependencies
```
dbt --version
dbt deps
```

### Configure dbt
To be able to interact with the SQL database, the dbt profile should be configured. 
Add the following configuration to your profiles.yml, keep in mind that you need to replace %%YOUR USER%% and %%YOUR_PW%% with your
own credentials:
```
la_porte_bleue:
  target: dev
  outputs:
    prod:
      type: postgres
      host: %%DB_HOST%%
      user: %%YOUR_USER%%
      password: %%YOUR_PW%%
      port: 5432
      dbname: %%DB_NAME%%
      schema: analytics
      threads: 4

    dev:
      type: postgres
      host: %%DB_HOST%%
      user: %%YOUR_USER%%
      password: %%YOUR_PW%%
      port: 5432
      dbname: %%DB_NAME%%
      schema: dbt_<YOUR_NAME>
      threads: 4
```


```sh
export DBT_PROFILES_DIR=$(pwd)
```

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
