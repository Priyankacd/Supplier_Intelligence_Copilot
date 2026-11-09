# Interview guide: Supplier Intelligence Copilot

## 90-second project pitch
"I built a Manufacturing Supplier Intelligence Copilot on Snowflake to demonstrate governed conversational analytics. The data layer models suppliers, plants, parts, and delivery records. A curated analytical view defines row-level business attributes such as on-time flags and delay days. A native semantic view defines business dimensions and metrics, including on-time delivery percentage, average delay, and quantity fill percentage. A Streamlit application sends user questions to the Cortex Analyst REST API and displays natural-language response blocks and generated SQL. I also scripted a Cortex Agent that uses the semantic view through an Analyst tool. I validated the metric definitions against independent SQL, and designed the app not to blindly execute arbitrary model-generated SQL. In a production version, I would add consumer-role testing, observability, verified-query coverage, latency and cost tracking, and optionally Cortex Search for supplier procedures."

## Concepts to explain precisely
- Cortex Analyst: converts natural-language analytical questions into SQL using semantic metadata; it is not itself the same as an Agent.
- Cortex Agent: orchestration layer that can select tools, maintain conversation context through threads, and combine structured analytics with other capabilities.
- Semantic view: governed database object representing business concepts, logical tables, dimensions, facts, metrics, and relationships.
- Dimension: descriptive grouping/filter attribute, e.g. plant or supplier.
- Fact: row-level numeric or event attribute used to construct measures.
- Metric: aggregation/business measure, e.g. OTD percentage.
- Verified query: reviewed question-to-SQL example that helps guide expected query patterns.
- RBAC: authorize access through Snowflake roles and grants; prompt text is not an access-control mechanism.
- Generated SQL may execute successfully but still be semantically wrong (wrong grain, join, date scope, or metric).
- Performance controls: concise semantic model, sensible warehouse sizing, query timeout, result limits, caching where appropriate, and monitoring.
- API integration: secure token handling, correct endpoint, JSON request/response parsing, timeouts, status-code handling, and secret rotation.

## Technical interview questions with answer outlines

1. **How does Cortex Analyst work end to end?**
   - User question + semantic model/view -> model interprets business metadata -> SQL response or clarification -> governed execution/results -> app renders answer. API request/response may include text, suggestions, and SQL blocks.

2. **Why is semantic modeling necessary?**
   - Physical column names rarely encode business meaning. Definitions, synonyms, joins, grain, and metric formulas constrain interpretation and improve consistent SQL generation.

3. **Semantic model YAML vs semantic view?**
   - Legacy Cortex Analyst semantic models are often staged YAML files. Native semantic views are database objects authored with semantic-view DDL/YAML and can be queried and used by Cortex Analyst/Agents. Do not assume their YAML formats are interchangeable.

4. **Cortex Analyst vs Cortex Agent?**
   - Analyst focuses on structured natural-language-to-SQL. Agent is an orchestration layer that can choose Analyst, Search, custom tools, and other supported capabilities.

5. **Why might a query run but return the wrong answer?**
   - Incorrect grain, incorrect join cardinality, ambiguous metric, wrong date field, null handling, bad synonyms, missing filters, or a mistaken assumption.

6. **How do you improve answer accuracy?**
   - Clear descriptions/synonyms, one row grain documented per logical table, accurate relationships and metrics, verified queries, a representative test set, feedback review, and regressions after model changes.

7. **How would you secure this app?**
   - Least-privilege role, governed views, object grants, secure authentication, secrets outside code, role-aware testing, no arbitrary SQL execution, logging without sensitive payloads, and auditability.

8. **What if Analyst returns a SQL block but no text?**
   - Parse response content by type rather than assuming a single text field; render SQL safely and handle suggestions/unknown blocks for forward compatibility.

9. **How would you integrate Teams or Slack?**
   - Bot or app receives the user message, authenticates the user, calls a secured backend/API, forwards to the Agent/Analyst endpoint, maps response blocks to chat cards, and records telemetry. Do not expose a shared PAT to clients.

10. **How do you measure performance and quality?**
    - Accuracy against reviewed SQL/result expectations, clarification rate, failure rate, latency percentiles, query duration, warehouse credits, user feedback, and drift/regression after semantic changes.

11. **How would you prove a root cause for declining OTD?**
    - Metrics identify patterns, not causality. Join to supplier capacity, logistics, quality holds, purchase-order changes, and plant constraints; compare time windows and validate with domain owners.

12. **How would you scale this to production?**
    - Version-controlled semantic definitions, CI checks, automated SQL/result tests, staged deployment, separate development/production roles, API retries with limits, telemetry, cost budgets, and rollback.

## Whiteboard flow
Question -> Streamlit -> secured API -> Cortex Agent (optional orchestration) -> Cortex Analyst -> semantic view -> curated Snowflake objects -> SQL/results -> response and visualization.

## Honesty rule
Clearly distinguish what was implemented and tested from what is a planned extension. Never claim production deployment, measured accuracy improvements, or root-cause detection unless you actually verified them.
