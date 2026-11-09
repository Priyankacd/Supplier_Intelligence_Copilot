# Manufacturing Supplier Intelligence Copilot
A two-day interview-preparation project for the Infocepts AI Engineer (Snowflake) JD.

## What this project demonstrates
- Snowflake SQL and curated analytical views
- Native semantic views (business dimensions and metrics)
- Cortex Analyst REST API integration
- Streamlit chat interface with SQL/result inspection
- A manually configured Cortex Agent using the semantic view
- Validation queries and interview-ready design explanations

All data is synthetic. Do not upload employer-confidential data or credentials.

## Architecture
Streamlit UI -> Cortex Analyst REST API -> semantic view -> curated Snowflake views/tables.
Optional extension: Cortex Agent routes structured questions to Cortex Analyst and can route document questions to Cortex Search.

## Important environment notes
Snowflake feature availability and account privileges vary. If a command fails, record the exact error and check the official documentation linked below. Do not blindly run account-level grants or enable cross-region inference.
The local Streamlit app calls Cortex Analyst with a Snowflake Programmatic Access Token (PAT). Keep the PAT in `.streamlit/secrets.toml` or environment variables; never commit it.
The semantic view DDL uses current native semantic-view syntax, not the legacy stage-based semantic-model YAML API. A legacy YAML model is included for learning the structure, but its API payload syntax and semantic-view YAML specification are not interchangeable.

## Day 1 — Build the data and semantic layer
1. Open Snowsight and choose a role with privileges to create a database/schema and tables.
2. Run `sql/01_setup_and_data.sql`.
3. Run `sql/02_semantic_view.sql`.
4. Run `sql/03_validation.sql`. Fix any errors before moving on.
5. In Snowsight, inspect the semantic view and test business questions in Cortex Analyst / Agent UI if available.

## Day 2 — Build the app and Agent
1. Install local dependencies: `pip install -r requirements.txt`
2. Create `app/.streamlit/secrets.toml` from the example below.
3. Run `streamlit run app/streamlit_app.py`.
4. Follow `sql/04_agent.sql` to create an Agent with Cortex Analyst as a tool. Replace `YOUR_WAREHOUSE` with a warehouse your role can use.
5. Test every question in `tests/test_questions.md`; compare the generated SQL and result to expected business logic.
6. Rehearse the project pitch and interview questions in `INTERVIEW_GUIDE.md`.

## Local secrets example
Create `app/.streamlit/secrets.toml`:
```toml
[snowflake]
account = "YOUR_ACCOUNT_IDENTIFIER"
user = "YOUR_USERNAME"
password = "YOUR_PASSWORD"
warehouse = "YOUR_WAREHOUSE"
database = "MSI_COPILOT"
schema = "ANALYTICS"
role = "YOUR_ROLE"

[cortex]
account_url = "https://YOUR_ACCOUNT_IDENTIFIER.snowflakecomputing.com"
pat = "YOUR_PROGRAMMATIC_ACCESS_TOKEN"
semantic_view = "MSI_COPILOT.ANALYTICS.SV_SUPPLIER_INTELLIGENCE"
```
Use a PAT suitable for your account's authentication policies. Avoid storing a PAT in source control. For local development, consider using an environment variable or a secret manager instead of a password.

## Notes about app behavior
The sample app uses the Cortex Analyst REST endpoint and displays returned text and SQL. It does not automatically execute arbitrary SQL from the response. This is intentional: review generated SQL first, then implement a narrowly scoped, role-governed execution path if needed. In a production design, prefer governed Agent/Analyst execution and Snowflake's access controls over trusting model-generated SQL.

## Official documentation
- Cortex Analyst REST API: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/rest-api
- Semantic views overview: https://docs.snowflake.com/en/user-guide/views-semantic/overview
- CREATE SEMANTIC VIEW: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- Cortex Agents get started: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-get-started
- Create/manage Agents: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-manage
- Streamlit in Snowflake: https://docs.snowflake.com/en/developer-guide/streamlit/getting-started/overview
