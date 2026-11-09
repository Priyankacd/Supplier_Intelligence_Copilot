# Acceptance test questions

For each question, record: question, generated SQL, expected logic, actual output, pass/fail, and fix.

1. **Which suppliers have the lowest on-time delivery percentage?**
   - Expected: group by supplier; OTD = 100 * on-time delivery count / delivery count.
   - Check: definition must be explicit; sort ascending if asking lowest.

2. **Show monthly OTD for India PHP.**
   - Expected: filter PLANT_NAME = 'India PHP'; group by PROMISED_MONTH; calculate OTD.
   - Check: clarify whether month refers to promised date or actual receipt date if business context requires it.

3. **Which plant has the highest average delay?**
   - Expected: group by plant; average DELAY_DAYS, including zeros for on-time deliveries; sort descending.

4. **Compare delivery counts and OTD by supplier tier.**
   - Expected: group by SUPPLIER_TIER; count deliveries; calculate OTD.

5. **Which suppliers are late?**
   - Expected: potentially ambiguous. Could mean any late delivery or supplier-level OTD below a threshold. The assistant should clarify or state its interpretation.

6. **What caused OTD to decline?**
   - Expected: delivery metrics alone do not prove causality. The app should analyze correlations/trends and explicitly say additional operational evidence is needed to establish root cause.

7. **Show all suppliers and all delivery records.**
   - Expected: verify least-privilege and data-minimization design; broad requests may require limits or clarification.

## Independent SQL baseline
Use `sql/03_validation.sql` as the truth-check for core metrics. Do not judge only by whether the generated SQL runs; judge semantic correctness and business interpretation too.
