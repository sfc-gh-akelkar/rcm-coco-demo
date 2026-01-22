# Snowflake ML End-to-End Production Demo

A comprehensive, production-ready demonstration of Snowflake's ML capabilities, including Feature Store, Model Registry, Distributed Hyperparameter Optimization, Model Monitoring, and Explainability.

## 🎯 Overview

This demo showcases a complete MLOps workflow on Snowflake, demonstrating:

- **Feature Engineering** with Snowpark DataFrames
- **Feature Store** for centralized feature management and lineage tracking
- **Model Training** with XGBoost (baseline and optimized versions)
- **Distributed Hyperparameter Optimization (HPO)** using Snowflake ML
- **Model Registry** for version control and lifecycle management
- **Model Explainability** with SHAP values
- **Model Monitoring** for drift detection and performance tracking
- **Production Deployment** using Snowflake Stored Procedures

## 📋 Prerequisites

### Snowflake Requirements

- Snowflake account with appropriate privileges
- Warehouse with compute resources (recommended: Medium or larger)
- Database and schema for the demo
- Ability to create stages, tables, stored procedures, and models

### Python Requirements

```bash
pip install snowflake-ml-python==1.11.0
pip install shap
```

### Knowledge Requirements

- Basic understanding of Snowflake and SQL
- Familiarity with Python and machine learning concepts
- Understanding of Snowpark DataFrames (helpful but not required)

## 🚀 Getting Started

### Step 1: Set Up Your Snowflake Environment

1. Log into your Snowflake account
2. Create or identify a database and schema for the demo:
   ```sql
   CREATE DATABASE IF NOT EXISTS YOUR_DATABASE;
   CREATE SCHEMA IF NOT EXISTS YOUR_DATABASE.YOUR_SCHEMA;
   USE DATABASE YOUR_DATABASE;
   USE SCHEMA YOUR_SCHEMA;
   ```

3. Create or identify a warehouse:
   ```sql
   CREATE WAREHOUSE IF NOT EXISTS YOUR_WAREHOUSE
       WAREHOUSE_SIZE = 'MEDIUM'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE;
   ```

### Step 2: Prepare Your Data

This demo is designed to work with any tabular classification dataset. You'll need:

- A **CSV file** with your training data
- A **target variable** (binary classification)
- **Features** (numerical and/or categorical)
- A **timestamp column** (for monitoring and time-series features)
- An **ID column** (unique identifier for each record)

**Upload your data:**
1. In Snowsight, navigate to your schema
2. Create a stage (or use the one created by the notebook)
3. Upload your CSV file to the stage

### Step 3: Open the Notebook in Snowflake

1. In Snowsight, navigate to **Projects** → **Notebooks**
2. Click **+ Notebook** → **Import .ipynb file**
3. Upload `ML_E2E_PRODUCTION_DEMO.ipynb`
4. Select your warehouse

### Step 4: Configure the Notebook

At the top of the notebook, you'll find a configuration section:

```python
# ===== CONFIGURATION SECTION =====
VERSION_NUM = '0'  # Version your experiments
DB = "YOUR_DATABASE"  # Replace with your database name
SCHEMA = "YOUR_SCHEMA"  # Replace with your schema name
COMPUTE_WAREHOUSE = "YOUR_WAREHOUSE"  # Replace with your warehouse name
```

Update these values to match your environment.

### Step 5: Customize Feature Engineering

The notebook contains example feature engineering code based on a mortgage lending dataset. **You must customize this section** based on your data:

**Key areas to customize:**
- Feature engineering logic (`feature_eng_dict`)
- Entity definition (what are you predicting about?)
- Target variable name
- Timestamp column name
- ID column name
- Feature names and descriptions

Look for **`===== CUSTOMIZE THIS SECTION =====`** comments throughout the notebook.

### Step 6: Run the Notebook

Execute cells sequentially, following the markdown explanations. The workflow includes:

1. **Data Ingestion** (Cells 1-11)
2. **Feature Engineering** (Cells 12-20)
3. **Feature Store Setup** (Cells 21-36)
4. **Data Preprocessing** (Cells 37-44)
5. **Baseline Model Training** (Cells 45-51)
6. **Model Registry** (Cells 52-67)
7. **Distributed HPO** (Cells 68-83)
8. **Model Explainability** (Cells 84-97)
9. **Model Monitoring** (Cells 98-118)

## 📊 What You'll Learn

### Feature Store

- How to create and manage a Feature Store in Snowflake
- Defining entities and feature views
- Point-in-time correctness for training datasets
- Feature lineage tracking

### Model Registry

- Logging models with metadata and metrics
- Version control and lifecycle management
- Model tagging (PROD, DEV, etc.)
- Inference from registered models

### Distributed HPO

- Configuring hyperparameter search spaces
- Running distributed optimization across compute nodes
- Comparing baseline vs. optimized models
- Preventing overfitting through proper tuning

### Model Explainability

- Generating SHAP values for model interpretability
- Built-in Snowflake visualization functions
- Understanding feature importance and impact

### Model Monitoring

- Setting up drift detection
- Tracking performance metrics over time
- Segmented monitoring for different cohorts
- Production deployment with stored procedures

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Data Ingestion                                              │
│ • Stage → Table (Schema Inference)                          │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ Feature Engineering (Snowpark)                              │
│ • Temporal features                                         │
│ • Derived features                                          │
│ • Window aggregations                                       │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ Feature Store                                               │
│ • Entity registration                                       │
│ • Feature View creation                                     │
│ • Dataset generation (point-in-time)                        │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ Model Training                                              │
│ • Baseline XGBoost (intentionally overfit)                  │
│ • Distributed HPO (optimized)                               │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ Model Registry                                              │
│ • Log both versions                                         │
│ • Compare metrics                                           │
│ • Tag production model                                      │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ Production Deployment                                       │
│ • Stored Procedure for inference                            │
│ • Model Monitors for drift detection                        │
│ • SHAP explanations for interpretability                    │
└─────────────────────────────────────────────────────────────┘
```

## 🎓 Key Concepts Demonstrated

### Why Train Two Models?

The notebook intentionally trains a **baseline model with poor hyperparameters** and then an **optimized model via HPO**. This demonstrates:

1. **Impact of Hyperparameter Tuning**: See the dramatic difference in generalization
2. **Overfitting Detection**: Compare train vs. test performance
3. **Production Best Practices**: Always optimize before deployment
4. **Model Comparison**: Use Model Registry to track multiple versions

### Why Use Feature Store?

Feature Stores provide:

- **Consistency**: Same features in training and inference
- **Reusability**: Share features across models and teams
- **Lineage**: Track data sources and dependencies
- **Point-in-Time Correctness**: Prevent data leakage
- **Automation**: Scheduled refresh of features

### Why Use Model Registry?

Model Registry enables:

- **Version Control**: Track all model versions
- **Lifecycle Management**: Promote/demote models
- **Metadata Tracking**: Store metrics, tags, comments
- **Production Deployment**: Serve models from registry
- **Governance**: Audit trail and access control

### Why Monitor Models?

Model Monitoring detects:

- **Data Drift**: Input distribution changes
- **Prediction Drift**: Output distribution changes
- **Performance Degradation**: Accuracy decline
- **Data Quality Issues**: Missing or anomalous values

## 🔧 Customization Guide

### For Different Use Cases

**Customer Churn:**
- Entity: `CUSTOMER` (join key: `CUSTOMER_ID`)
- Target: `CHURN` (1 = churned, 0 = retained)
- Features: Usage metrics, engagement scores, tenure

**Fraud Detection:**
- Entity: `TRANSACTION` (join key: `TRANSACTION_ID`)
- Target: `IS_FRAUD` (1 = fraud, 0 = legitimate)
- Features: Amount, merchant, location, time, user behavior

**Predictive Maintenance:**
- Entity: `EQUIPMENT` (join key: `EQUIPMENT_ID`)
- Target: `FAILURE` (1 = will fail, 0 = won't fail)
- Features: Sensor readings, age, maintenance history

### For Different Model Types

**Regression (instead of classification):**
- Replace `XGBClassifier` with `XGBRegressor`
- Update metrics: Use RMSE, MAE, R² instead of F1, Precision, Recall
- Modify Model Monitor configuration for regression

**Multi-class Classification:**
- Ensure target has >2 classes
- Update metrics: Use macro/micro averages
- Adjust SHAP visualizations for multi-class

## 📁 Repository Structure

```
snowflake-ml-e2e-demo/
├── ML_E2E_PRODUCTION_DEMO.ipynb   # Main demo notebook
├── README.md                      # This file
└── .gitignore                     # Git ignore rules
```

## 🤝 Contributing

This is a template repository designed to be customized for your specific use case. Feel free to:

- Fork and adapt for your organization
- Add your own feature engineering logic
- Experiment with different models
- Share improvements and feedback

## 📚 Additional Resources

- **Snowflake ML Documentation**: https://docs.snowflake.com/en/developer-guide/snowpark-ml/index
- **Feature Store Guide**: https://docs.snowflake.com/en/developer-guide/snowpark-ml/feature-store/overview
- **Model Registry Guide**: https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-registry/overview
- **Model Monitoring Guide**: https://docs.snowflake.com/en/developer-guide/snowpark-ml/model-management/model-monitoring/overview
- **Snowpark ML API Reference**: https://docs.snowflake.com/en/developer-guide/snowpark-ml/reference/latest/index

## ⚠️ Important Notes

1. **Cost Awareness**: This demo uses Snowflake compute. Monitor your credit usage, especially during HPO (runs 8 parallel trials).

2. **Data Privacy**: Ensure your data complies with your organization's data governance policies before uploading to Snowflake.

3. **Customization Required**: This notebook contains example code. You MUST customize feature engineering, entity definitions, and model configuration for your use case.

4. **Production Readiness**: While this demo follows MLOps best practices, additional considerations (CI/CD, automated testing, alerting) are needed for full production deployment.

## 💡 Tips for Success

- **Start Small**: Begin with a subset of your data to iterate quickly
- **Version Everything**: Use `VERSION_NUM` to track experiments
- **Document Features**: Add detailed descriptions in Feature Store
- **Compare Models**: Use Model Registry to track all experiments
- **Monitor Continuously**: Set up Model Monitors from day one
- **Explain Decisions**: Use SHAP values for stakeholder communication

## 🐛 Troubleshooting

**Issue: Notebook cells fail with "object not found" errors**
- Solution: Ensure you've updated all configuration variables (DB, SCHEMA, WAREHOUSE)

**Issue: HPO takes a long time**
- Solution: Reduce `num_trials` or use a smaller dataset for initial testing

**Issue: SHAP computation is slow**
- Solution: Reduce sample size (e.g., from 2500 to 500 rows)

**Issue: Model Monitor not refreshing**
- Solution: Check warehouse is running and `REFRESH_INTERVAL` has passed

## 📧 Support

For Snowflake-specific questions, consult:
- Snowflake Documentation
- Snowflake Community Forums
- Your Snowflake account team

## 📜 License

This demo is provided as-is for educational and demonstration purposes. Adapt freely for your organization's needs.

---

**Happy MLOps on Snowflake!** ❄️🚀

