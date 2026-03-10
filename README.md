# Cortex Code Demo — Healthcare RCM (Revenue Cycle Management)

## Overview
Live walkthrough of Cortex Code for a healthcare data engineering team. Demonstrates how AI-assisted development accelerates a SQL Server → Snowflake EDW migration across Emergency Medicine, Radiology, and Anesthesiology service lines.

## Scenario
A healthcare RCM company is migrating their legacy SQL Server EDW to Snowflake. Their workloads include DML-heavy transformations, COPY ingestion, stored procs, Streams, and Dynamic Tables. This demo shows how Cortex Code accelerates every phase of that migration.

## Choose Your Surface

This demo runs on **both** Cortex Code surfaces:

| | CLI (`cortex`) | Snowsight |
|-|---------------|-----------|
| **Best for** | Full-featured demo, developer-focused audiences | Browser-based audiences, quick show-and-tell |
| **Setup** | Clone repo + `cortex` in terminal | Open Cortex Code panel in Snowsight |
| **Unique features** | `@file`, `#table`, `!bash`, `/sql`, `/fork`, `/compact`, Plan Mode, Skills | One-click SQL execution, integrated worksheets |
| **Parts supported** | All (1–7) | Parts 1–5, 7 (Part 6 is CLI-specific; Snowsight alternatives provided) |

See `scripts/DEMO_SCRIPT.md` for platform-specific prompts throughout.

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

### 1. Create schema and load data (both surfaces)
```sql
-- Run in Snowsight worksheet, SnowSQL, or via Cortex Code
-- sql/01_schema_ddl.sql   → creates CORTEX_CODE_RCM_DEMO database + tables
-- sql/02_sample_data.sql  → loads ~500 claims, 200 encounters, reference data
```

### 2a. CLI setup
```bash
git clone https://github.com/sfc-gh-akelkar/rcm-coco-demo.git
cd rcm-coco-demo
cortex
```

### 2b. Snowsight setup
1. Open Snowsight → Click the **Cortex Code** panel (or "Ask Cortex Code")
2. Have `tsql-samples/em_collections_sproc.sql` contents ready to paste
3. No repo clone needed — all prompts are typed directly into chat

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
    └── DEMO_SCRIPT.md                  # Full talk track with CLI + Snowsight prompts
```
