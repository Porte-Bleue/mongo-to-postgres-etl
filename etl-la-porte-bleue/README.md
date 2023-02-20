<!--
title: 'AWS Python Example'
description: 'This template demonstrates how to deploy a Python function running on AWS Lambda using the traditional Serverless Framework.'
layout: Doc
framework: v3
platform: AWS
language: python
priority: 2
authorLink: 'https://github.com/serverless'
authorName: 'Serverless, inc.'
authorAvatar: 'https://avatars1.githubusercontent.com/u/13742415?s=200&v=4'
-->


# Deploy ETL Python Script running on AWS Lambda using the Serverless Framework

## Deployment Guide

1. Install Serverless

    ```
    npm install -g serverless
    ```

2. Install `serverless-python-requirements`

  To include third-party dependencies, we need to use a plugin called `serverless-python-requirements`. You can set it up by running the following command:

    ```
    serverless plugin install -n serverless-python-requirements
    ```

3. Define necessaery environment variables

  Append MongoDB & PostgreSQL databases' connection string into a file called serverless.env.yml, like this
  $ cat serverless.env.yml
  ```
  MONGO_DB: <your_token>
  POSTGRES_DB: <your_token>
  ```

4. Deploy the function 

  ```
  $ serverless deploy
  ```

  After running deploy, you should see output similar to:

  ```bash
  Deploying etl-la-porte-bleue to stage dev (us-east-1, "la-porte-bleue" provider)

  ✔ Service deployed to stack etl-la-porte-bleue-dev (112s)

  functions:
    main: etl-la-porte-bleue-dev-main (12 MB)
  ```

### Invocation

After successful deployment, you can invoke the deployed function by using the following command:

```bash
serverless invoke --function main
```

Which should result in response similar to the following:

```
extracting collection: products

loading table: products

extracting collection: families

loading table: families

extracting collection: family_members

loading table: family_members

extracting collection: visit_events

loading table: visit_events

extracting collection: operations

loading table: operations
```
