-- SECURITY EXERCISE — adapt names and grants to your own account.
-- Do not grant broad privileges casually. Run admin-only statements only as an authorized admin.
-- Goal: app role can read only the curated analytical view and invoke Cortex features as permitted.

-- Example role names:
-- CREATE ROLE IF NOT EXISTS MSI_ANALYST_ROLE;
-- GRANT USAGE ON DATABASE MSI_COPILOT TO ROLE MSI_ANALYST_ROLE;
-- GRANT USAGE ON SCHEMA MSI_COPILOT.ANALYTICS TO ROLE MSI_ANALYST_ROLE;
-- GRANT SELECT ON VIEW MSI_COPILOT.ANALYTICS.VW_SUPPLIER_DELIVERY_ANALYTICS TO ROLE MSI_ANALYST_ROLE;
-- GRANT USAGE ON WAREHOUSE YOUR_WAREHOUSE TO ROLE MSI_ANALYST_ROLE;
-- GRANT DATABASE ROLE SNOWFLAKE.CORTEX_AGENT_USER TO ROLE MSI_ANALYST_ROLE;
-- GRANT USAGE ON AGENT MSI_COPILOT.ANALYTICS.AG_SUPPLIER_INTELLIGENCE TO ROLE MSI_ANALYST_ROLE;

-- Important:
-- 1. Verify exact privileges and supported grants in your account/docs.
-- 2. A view's owner/underlying object grants and semantic-view access must be designed deliberately.
-- 3. Test with the intended consumer role, not only ACCOUNTADMIN.
-- 4. Avoid putting secrets in SQL scripts, Streamlit source, Git, screenshots, or logs.
