USE DATABASE MSI_COPILOT;
USE SCHEMA ANALYTICS;

-- Native semantic view: current semantic-view DDL, not legacy stage YAML syntax.
CREATE OR REPLACE SEMANTIC VIEW SV_SUPPLIER_INTELLIGENCE
  TABLES (
    deliveries AS VW_SUPPLIER_DELIVERY_ANALYTICS
      PRIMARY KEY (DELIVERY_ID)
      WITH SYNONYMS = ('deliveries', 'supplier shipments', 'purchase order receipts')
      COMMENT = 'One row per supplier delivery record, joined to supplier, plant, and part attributes'
  )
  DIMENSIONS (
    deliveries.supplier_name AS SUPPLIER_NAME
      WITH SYNONYMS = ('supplier', 'vendor', 'supplier company')
      COMMENT = 'Business name of the supplier',
    deliveries.supplier_code AS SUPPLIER_CODE
      COMMENT = 'Unique business code for a supplier',
    deliveries.supplier_country AS SUPPLIER_COUNTRY
      COMMENT = 'Country where the supplier is based',
    deliveries.supplier_tier AS SUPPLIER_TIER
      COMMENT = 'Supplier relationship tier',
    deliveries.plant_name AS PLANT_NAME
      WITH SYNONYMS = ('plant', 'factory', 'manufacturing site')
      COMMENT = 'Manufacturing plant receiving the delivery',
    deliveries.plant_region AS PLANT_REGION
      COMMENT = 'Geographic region of the receiving plant',
    deliveries.part_number AS PART_NUMBER
      WITH SYNONYMS = ('part', 'component', 'item number')
      COMMENT = 'Manufacturing part identifier',
    deliveries.part_description AS PART_DESCRIPTION
      COMMENT = 'Description of the part',
    deliveries.part_criticality AS PART_CRITICALITY
      COMMENT = 'Business criticality level of the part',
    deliveries.promised_date AS PROMISED_DATE
      COMMENT = 'Date on which supplier promised delivery',
    deliveries.actual_date AS ACTUAL_DATE
      COMMENT = 'Date the delivery was actually received',
    deliveries.promised_month AS PROMISED_MONTH
      WITH SYNONYMS = ('delivery month', 'month')
      COMMENT = 'Month of the promised delivery date'
  )
  FACTS (
    deliveries.order_qty AS ORDER_QTY
      COMMENT = 'Quantity ordered',
    deliveries.received_qty AS RECEIVED_QTY
      COMMENT = 'Quantity received',
    deliveries.order_value AS ORDER_VALUE
      COMMENT = 'Ordered quantity multiplied by unit cost',
    deliveries.on_time_flag AS ON_TIME_FLAG
      COMMENT = '1 if actual delivery date is on or before promised date, else 0',
    deliveries.delay_days AS DELAY_DAYS
      COMMENT = 'Number of calendar days late; zero for on-time deliveries',
    deliveries.fill_complete_flag AS FILL_COMPLETE_FLAG
      COMMENT = '1 if received quantity meets or exceeds ordered quantity',
    deliveries.received_value AS RECEIVED_VALUE
      COMMENT = 'Received quantity multiplied by unit cost'
  )
  METRICS (
    deliveries.delivery_count AS COUNT(DELIVERY_ID)
      COMMENT = 'Number of delivery records',
    deliveries.on_time_delivery_pct AS 100.0 * SUM(ON_TIME_FLAG) / NULLIF(COUNT(DELIVERY_ID), 0)
      COMMENT = 'Percentage of delivery records received on or before the promised date',
    deliveries.average_delay_days AS AVG(DELAY_DAYS)
      COMMENT = 'Average calendar days late across all deliveries, with on-time deliveries counted as zero',
    deliveries.total_order_value AS SUM(ORDER_VALUE)
      COMMENT = 'Total ordered value',
    deliveries.total_received_value AS SUM(RECEIVED_VALUE)
      COMMENT = 'Total value received',
    deliveries.quantity_fill_pct AS 100.0 * SUM(RECEIVED_QTY) / NULLIF(SUM(ORDER_QTY), 0)
      COMMENT = 'Received quantity divided by ordered quantity, expressed as a percentage'
  )
  COMMENT = 'Governed supplier delivery analytics semantic layer for the Manufacturing Supplier Intelligence Copilot'
  AI_SQL_GENERATION 'Use on_time_delivery_pct for on-time delivery performance. Do not describe a supplier as best or worst without stating the metric and time scope. Use PROMISED_MONTH for trends by promised month. A delivery is on time when ACTUAL_DATE is less than or equal to PROMISED_DATE. Average delay days includes zero for on-time deliveries.';

-- Sanity-check the semantic object definition:
DESCRIBE SEMANTIC VIEW SV_SUPPLIER_INTELLIGENCE;

-- Example query through the semantic view. If the semantic view fails validation,
-- fix it before wiring Cortex Analyst or an Agent.
SELECT *
FROM SEMANTIC_VIEW(
  SV_SUPPLIER_INTELLIGENCE
  DIMENSIONS deliveries.supplier_name
  METRICS deliveries.delivery_count, deliveries.on_time_delivery_pct
)
ORDER BY ON_TIME_DELIVERY_PCT;
