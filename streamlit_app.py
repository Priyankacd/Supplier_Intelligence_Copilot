import json
import requests
import pandas as pd
import streamlit as st
import plotly.express as px

st.set_page_config(page_title="Supplier Intelligence Copilot", page_icon="🏭", layout="wide")
st.title("🏭 Manufacturing Supplier Intelligence Copilot")
st.caption("Interview demo · Synthetic supplier delivery data · Snowflake Cortex Analyst")

with st.sidebar:
    st.header("Connection")
    st.write("Configure `app/.streamlit/secrets.toml` before starting.")
    st.info("This starter app calls Cortex Analyst and displays generated SQL. It does not auto-execute returned SQL.")
    st.markdown("[Cortex Analyst API docs](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/rest-api)")

def get_config():
    cfg = st.secrets
    return {
        "account_url": cfg["cortex"]["account_url"].rstrip("/"),
        "pat": cfg["cortex"]["pat"],
        "semantic_view": cfg["cortex"]["semantic_view"],
    }

def ask_analyst(question: str):
    cfg = get_config()
    url = f'{cfg["account_url"]}/api/v2/cortex/analyst/message'
    headers = {
        "Authorization": f'Bearer {cfg["pat"]}',
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-Snowflake-Authorization-Token-Type": "PROGRAMMATIC_ACCESS_TOKEN",
    }
    payload = {
        "messages": [
            {"role": "user", "content": [{"type": "text", "text": question}]}
        ],
        "semantic_view": cfg["semantic_view"],
        "stream": False,
    }
    response = requests.post(url, headers=headers, json=payload, timeout=90)
    response.raise_for_status()
    return response.json()

def extract_blocks(response_json):
    blocks = []
    message = response_json.get("message", {})
    for item in message.get("content", []):
        item_type = item.get("type", "unknown")
        if item_type == "text":
            blocks.append(("text", item.get("text", "")))
        elif item_type == "sql":
            blocks.append(("sql", item.get("statement", item.get("sql", json.dumps(item, indent=2)))))
        elif item_type == "suggestions":
            blocks.append(("suggestions", item.get("suggestions", item)))
        else:
            blocks.append((item_type, item))
    return blocks

if "history" not in st.session_state:
    st.session_state.history = []

examples = [
    "Which suppliers have the lowest on-time delivery percentage?",
    "Show monthly OTD for India PHP.",
    "Which plant has the highest average delay?",
    "Compare delivery counts and OTD by supplier tier.",
]
st.subheader("Try a business question")
cols = st.columns(2)
for idx, q in enumerate(examples):
    if cols[idx % 2].button(q, use_container_width=True):
        st.session_state.pending_question = q

for entry in st.session_state.history:
    with st.chat_message(entry["role"]):
        st.markdown(entry["content"])
        if entry.get("sql"):
            with st.expander("Generated SQL"):
                st.code(entry["sql"], language="sql")
        if entry.get("raw"):
            with st.expander("Raw API response"):
                st.json(entry["raw"])

prompt = st.chat_input("Ask about suppliers, plants, delivery performance, or delays...")
if not prompt and st.session_state.get("pending_question"):
    prompt = st.session_state.pop("pending_question")

if prompt:
    st.session_state.history.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)
    with st.chat_message("assistant"):
        try:
            with st.spinner("Asking Cortex Analyst..."):
                result = ask_analyst(prompt)
            blocks = extract_blocks(result)
            texts, sqls = [], []
            for kind, content in blocks:
                if kind == "text":
                    texts.append(content)
                elif kind == "sql":
                    sqls.append(str(content))
                elif kind == "suggestions":
                    st.write("Clarification suggestions:", content)
                else:
                    st.caption(f"Additional response block: {kind}")
            answer = "\n\n".join(texts) or "Cortex Analyst returned no text block. Inspect the response details."
            st.markdown(answer)
            sql_text = "\n\n".join(sqls)
            if sql_text:
                with st.expander("Generated SQL"):
                    st.code(sql_text, language="sql")
            st.session_state.history.append({
                "role": "assistant",
                "content": answer,
                "sql": sql_text,
                "raw": result,
            })
        except requests.HTTPError as exc:
            detail = exc.response.text[:3000] if exc.response is not None else str(exc)
            st.error("Cortex Analyst API returned an HTTP error. Check the endpoint, token, role, semantic view access, and account feature availability.")
            st.code(detail)
        except requests.RequestException as exc:
            st.error(f"Network/API request failed: {exc}")
        except Exception as exc:
            st.error(f"Application error: {exc}")

st.divider()
st.subheader("Demo checklist")
st.markdown("""
- Ask at least three questions and inspect the generated SQL.
- Verify metric definitions against `sql/03_validation.sql`.
- Test an ambiguous question and see whether the API returns clarification suggestions.
- Do not execute generated SQL without a deliberate, governed execution design.
- Explain how a Cortex Agent would orchestrate Analyst and, optionally, Search tools.
""")
