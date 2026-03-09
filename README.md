# Cortex Code Demo — Healthcare RCM (Revenue Cycle Management)

## Overview
Live walkthrough of Cortex Code for a healthcare data engineering team. Demonstrates how AI-assisted development accelerates a SQL Server → Snowflake EDW migration across Emergency Medicine, Radiology, and Anesthesiology service lines.

## Scenario
A healthcare RCM company is migrating their legacy SQL Server EDW to Snowflake. Their workloads include DML-heavy transformations, COPY ingestion, stored procs, Streams, and Dynamic Tables. This demo shows how Cortex Code accelerates every phase of that migration.

## Demo Structure (~40 min)

| Part | Topic | Time | Key Asset |
|------|-------|------|-----------|
| 1 | The Hook — T-SQL → Snowflake conversion | 5 min | `tsql-samples/em_collections_sproc.sql` |
| 2 | Schema Exploration & Data Discovery | 5 min | `sql/01_schema_ddl.sql` + `sql/02_sample_data.sql` |
| 3 | Pipeline Development — DML transformations | 10 min | `sql/03_staging_to_mart.sql` |
| 4 | Dynamic Tables — Declarative pipelines | 5 min | `sql/04_dynamic_tables.sql` |
| 5 | AI/ML Tease — Denial prediction UDF | 5 min | `snowpark/denial_prediction_udf.py` |
| 6 | Developer Productivity Features | 5 min | Live demo of shortcuts |
| 7 | The Close — Migration timeline impact | 5 min | `scripts/DEMO_SCRIPT.md` |

## Pre-Demo Setup
```bash
# 1. Create the demo schema
snowsql -f sql/01_schema_ddl.sql

# 2. Load sample data
snowsql -f sql/02_sample_data.sql

# 3. Launch Cortex Code
cd cortex-code-rcm-demo
cortex
```

## Files
```
├── README.md                           # This file
├── tsql-samples/
│   └── em_collections_sproc.sql        # T-SQL stored proc for Part 1 conversion demo
├── sql/
│   ├── 01_schema_ddl.sql               # Demo schema: claims, providers, payers, encounters
│   ├── 02_sample_data.sql              # Realistic sample data
│   ├── 03_staging_to_mart.sql          # Staging → mart transformation (answer key)
│   └── 04_dynamic_tables.sql           # DT conversion example (answer key)
├── snowpark/
│   └── denial_prediction_udf.py        # Snowpark denial prediction scaffold (answer key)
└── scripts/
    └── DEMO_SCRIPT.md                  # Full talk track with prompts
```
