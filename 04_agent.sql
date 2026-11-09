-- Run only after 01_setup_and_data.sql and 02_semantic_view.sql succeed.
-- Replace YOUR_WAREHOUSE with an existing warehouse you are authorized to use.
-- The role needs Cortex Agent privileges plus USAGE on DB/schema/warehouse and SELECT
-- on underlying objects. Ask an account admin to grant privileges if needed.
USE DATABASE MSI_COPILOT;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE AGENT AG_SUPPLIER_INTELLIGENCE
  COMMENT = 'Answers governed questions about supplier delivery performance and manufacturing risk'
  PROFILE = '{"display_name": "Supplier Intelligence Copilot"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  instructions:
    response: "You are a manufacturing supplier analytics assistant. Be concise and business-focused. State the metric and time scope. Never invent data. If the question is ambiguous, ask a clarifying question. For delivery performance questions, use the Supplier_Analyst tool. Distinguish correlation from root cause; do not claim causation from delivery metrics alone."
    orchestration: "Use Supplier_Analyst for structured questions about supplier deliveries, plants, parts, on-time delivery, delays, quantities, and order values."
    sample_questions:
      - question: "Which suppliers have the lowest on-time delivery percentage?"
      - question: "Show monthly OTD for India PHP."
      - question: "Which plant has the highest average delay?"

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "Supplier_Analyst"
        description: "Queries governed supplier delivery metrics using the SV_SUPPLIER_INTELLIGENCE semantic view."

  tool_resources:
    Supplier_Analyst:
      semantic_view: "MSI_COPILOT.ANALYTICS.SV_SUPPLIER_INTELLIGENCE"
      execution_environment:
        type: "warehouse"
        warehouse: "YOUR_WAREHOUSE"
  $$;

DESCRIBE AGENT MSI_COPILOT.ANALYTICS.AG_SUPPLIER_INTELLIGENCE;

-- Then open Snowsight > AI & ML > Agents and test the sample questions.
-- For application integration, use the Cortex Agents Run REST API documented by Snowflake.
