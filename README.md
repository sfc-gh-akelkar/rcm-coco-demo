# Snowflake ML End-to-End Demo | Quadax HOL

**Duration:** 90 minutes  
**Audience:** Data Scientists evaluating Snowflake ML  
**Prerequisites:** Basic Python/SQL knowledge

---

## Overview

This hands-on lab demonstrates Snowflake's complete ML platform through two notebooks:

| Notebook | Duration | Focus |
|----------|----------|-------|
| **STEP_1_BASIC_DATA_EXPLORATION** | 20 min | Snowpark DataFrames, transformations, data analysis |
| **E2E_ML_NOTEBOOK** | 70 min | Feature Store, Model Registry, HPO, Monitoring, Deployment |

---

## What You'll Learn

### Step 1: Data Exploration
- Snowpark DataFrames vs Pandas (memory comparison)
- Transformations: select, filter, group_by, sort
- Data analysis: describe, aggregations, schema inspection
- Persisting results with `save_as_table`

### Step 2: End-to-End ML Workflow
- **Feature Engineering** with Snowpark APIs
- **Feature Store** - Entity registration, Feature Views, dataset generation
- **Model Training** - XGBoost baseline + distributed HPO
- **Model Registry** - Versioning, tagging (DEV/PROD), metadata
- **Inference** - Batch predictions with `model.run()`
- **Explainability** - SHAP values with built-in visualization
- **Monitoring** - Model monitors for drift detection
- **Deployment** - Stored procedures + SPCS containers

---

## Quick Start

### 1. Import Notebooks to Snowflake

1. In Snowsight: **Projects** → **Notebooks** → **Import .ipynb**
2. Upload both notebooks
3. Select a Medium (or larger) warehouse

### 2. Run Step 1 First

Start with `STEP_1_BASIC_DATA_EXPLORATION.ipynb` to understand Snowpark basics.

### 3. Run E2E ML Notebook

Continue with `E2E_ML_NOTEBOOK.ipynb` for the complete ML workflow.

---

## Key Concepts

| Concept | What It Does |
|---------|--------------|
| **Feature Store** | Centralized feature management with versioning and lineage |
| **Model Registry** | Version control, tagging, and lifecycle management for models |
| **Distributed HPO** | Hyperparameter tuning across warehouse compute nodes |
| **Model Monitors** | Track prediction drift and performance over time |
| **SPCS Deployment** | Real-time inference endpoints via containers |

---

## Files

```
quadax-ml-e2e-demo/
├── STEP_1_BASIC_DATA_EXPLORATION.ipynb  # Data exploration basics
├── E2E_ML_NOTEBOOK.ipynb                # Full ML workflow
└── README.md                            # This file
```

---

## Resources

- [Snowflake ML Documentation](https://docs.snowflake.com/en/developer-guide/snowpark-ml/index)
- [Feature Store Guide](https://docs.snowflake.com/en/developer-guide/snowpark-ml/feature-store/overview)
- [Model Registry Guide](https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-registry/overview)
- [Model Monitoring Guide](https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-management/model-monitoring/overview)

---

**Ready to build ML workflows without infrastructure headaches?** Let's go!
