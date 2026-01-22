# Snowflake ML End-to-End Demo | Quadax Hands-On Lab

**Duration:** 90 minutes  
**Audience:** Data Scientists evaluating Snowflake ML vs Azure ML  
**Focus:** Feature Store, Model Registry, Deployment, Scalability

---

## Overview

This hands-on lab demonstrates Snowflake's complete MLOps platform through a mortgage lending classification use case. The workflow maps directly to Quadax's denial avoidance ML use case.

**What You'll Experience:**
- **Memory & Scalability** - See how Snowpark eliminates OOM errors
- **Feature Store** - Centralized, versioned feature management
- **Model Registry** - Version control with PROD/DEV tagging
- **Distributed HPO** - Hyperparameter tuning on warehouse compute
- **Deployment Options** - SQL inference, Stored Procedures, SPCS endpoints
- **PySpark Migration** - Side-by-side API comparison

---

## Why Snowflake ML vs Azure ML?

| Challenge (Azure) | Snowflake Solution |
|-------------------|-------------------|
| OOM errors on large datasets | Data stays in warehouse, only pointers in notebook |
| VM resize requires restart | Warehouse scales instantly, no code changes |
| Data movement to compute | Compute comes to data |
| Separate feature store tools | Native Feature Store |
| MLflow + external monitoring | Unified Registry + Monitoring |
| Complex Spark cluster management | Warehouse auto-scales |

---

## HOL Structure & Checkpoints

The notebook includes 5 checkpoints for pacing. Target timing:

| Checkpoint | Section | Target Time | Duration |
|------------|---------|-------------|----------|
| **1** | Memory & Scalability Demo | 0:15 | 15 min |
| **2a/2b** | Feature Store Setup | 0:35 | 20 min |
| **3** | Model Registry & Batch Inference | 0:55 | 20 min |
| **4** | Distributed HPO | 1:10 | 15 min |
| **5** | Deployment & Wrap-up | 1:30 | 20 min |

**Time-Saving Tips:**
- HPO takes ~5-10 min - pre-run before live demo or discuss while running
- Explainability section can be summarized if short on time
- Monitoring setup is optional for 90-min version

---

## Quick Start

### 1. Snowflake Setup

```sql
USE DATABASE SANDBOX;
USE SCHEMA E2E_ML;
USE WAREHOUSE APP_WH;
```

### 2. Open Notebook

1. In Snowsight: **Projects** → **Notebooks** → **Import .ipynb**
2. Upload `ML_E2E_PRODUCTION_DEMO.ipynb`
3. Select warehouse (Medium or larger recommended)

### 3. Configure Version

```python
VERSION_NUM = '0'  # Increment for each run
```

### 4. Run Sequentially

Execute cells in order, pausing at checkpoints for discussion.

---

## Notebook Cell Map

| Cells | Section | Key Concepts |
|-------|---------|--------------|
| 0-11 | Setup & Data Loading | Stages, COPY INTO, schema inference |
| 12-15 | **Memory & Scalability** | Snowpark vs Pandas memory, warehouse scaling |
| 16-27 | Feature Engineering | Snowpark transformations, DMFs |
| 28-43 | **Feature Store** | Entity, FeatureView, generate_dataset |
| 44-53 | Data Preprocessing | OHE, train/test split |
| 54-60 | Model Training | XGBoost baseline |
| 61-77 | **Model Registry** | log_model, tags, batch inference |
| 78-94 | **Distributed HPO** | tune.Tuner, model comparison |
| 95-119 | Explainability & Monitoring | SHAP, drift detection |
| 120-128 | Monitoring Setup | Model monitors, segmentation |
| 129-134 | **Wrap-up & Migration Guide** | PySpark comparison, use case mapping |

---

## PySpark to Snowpark Migration

Your existing PySpark skills transfer directly:

| PySpark | Snowpark |
|---------|----------|
| `spark.read.parquet(path)` | `session.table("TABLE")` |
| `df.select("col")` | `df.select("col")` |
| `df.filter(df.col > 5)` | `df.filter(col("COL") > 5)` |
| `df.groupBy("col").agg(...)` | `df.group_by("col").agg(...)` |
| `df.withColumn("new", expr)` | `df.with_column("NEW", expr)` |
| `df.toPandas()` | `df.to_pandas()` |

**Key Differences:**
- Column names default to UPPERCASE in Snowflake
- Use `col('"lowercase"')` for case-sensitive names
- Both are lazy-evaluated - same mental model

---

## Mapping to Denial Avoidance Use Case

| Demo Component | Your Equivalent |
|----------------|-----------------|
| `LOAN_ENTITY` / `LOAN_ID` | `CLAIM_ENTITY` / `CLAIM_ID` |
| Mortgage approval prediction | Denial probability prediction |
| Feature Store versioning | Audit trail for feature changes |
| Model Registry PROD tag | Production model promotion |
| Batch inference | Nightly denial risk scoring |
| SHAP explainability | "Why was this claim flagged?" |
| Drift monitoring | Alert when patterns shift |

**Suggested Migration Timeline:**
- Week 1: Load claims data, create Entity/FeatureView
- Week 2: Train baseline model, log to Registry
- Week 3: HPO tuning, deploy with Stored Procedure
- Week 4: Monitoring, alerts, scheduled refreshes

---

## Deployment Options

| Method | Use Case | Latency |
|--------|----------|---------|
| `MODEL!predict()` SQL | Batch jobs, ad-hoc queries | Seconds |
| Stored Procedure | Pipeline integration | Seconds |
| SPCS HTTP Endpoint | Real-time APIs | Milliseconds |

```sql
-- SQL batch inference example
SELECT *, MODEL!predict(*)::VARIANT:prediction AS PREDICTION
FROM TEST_DATA;
```

---

## Files in This Repository

```
quadax-ml-e2e-demo/
├── ML_E2E_PRODUCTION_DEMO.ipynb   # Main HOL notebook (135 cells)
├── MORTGAGE_LENDING_DEMO_DATA.csv # Sample dataset
└── README.md                      # This file
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Object not found" errors | Verify DATABASE/SCHEMA/WAREHOUSE settings |
| HPO takes too long | Reduce `num_trials` or pre-run before demo |
| SHAP computation slow | Reduce sample size to 500 rows |
| Memory errors (shouldn't happen!) | Demonstrates why Snowflake > local Python |

---

## Resources

- [Snowflake ML Documentation](https://docs.snowflake.com/en/developer-guide/snowpark-ml/index)
- [Feature Store Guide](https://docs.snowflake.com/en/developer-guide/snowpark-ml/feature-store/overview)
- [Model Registry Guide](https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-registry/overview)
- [Model Monitoring Guide](https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-management/model-monitoring/overview)

---

**Ready to see ML without the infrastructure headaches?** Let's get started.
