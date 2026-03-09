# ============================================================================
# Cortex Code Demo — Snowpark Python UDF: Claim Denial Prediction
# Demo Part 5: AI/ML Tease — scaffold for denial probability prediction
# "Answer key" — Cortex Code should produce something similar when prompted
# ============================================================================

import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col, udf
from snowflake.snowpark.types import FloatType, StringType, IntegerType
import pandas as pd
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import json


def train_denial_model(session: snowpark.Session) -> dict:
    claims_df = session.sql("""
        SELECT
            c.PAYER_ID,
            py.PAYER_TYPE,
            c.CPT_CODE,
            c.PRIMARY_DIAGNOSIS_CODE,
            c.PROVIDER_NPI,
            c.FACILITY_ID,
            c.BILLED_AMOUNT,
            DAYOFWEEK(c.SERVICE_DATE) AS SERVICE_DOW,
            MONTH(c.SERVICE_DATE) AS SERVICE_MONTH,
            IFF(c.CLAIM_STATUS = 'DENIED', 1, 0) AS IS_DENIED
        FROM CORTEX_CODE_RCM_DEMO.RAW.CLAIMS c
        JOIN CORTEX_CODE_RCM_DEMO.RAW.PAYERS py ON c.PAYER_ID = py.PAYER_ID
        WHERE c.SERVICE_LINE_CODE = 'EM'
          AND c.CLAIM_STATUS IN ('PAID', 'DENIED', 'PARTIAL', 'ADJUDICATED')
    """).to_pandas()

    encoders = {}
    categorical_cols = ['PAYER_TYPE', 'CPT_CODE', 'PRIMARY_DIAGNOSIS_CODE', 'PROVIDER_NPI']
    for c in categorical_cols:
        le = LabelEncoder()
        claims_df[c + '_ENC'] = le.fit_transform(claims_df[c].astype(str))
        encoders[c] = le

    feature_cols = [c + '_ENC' for c in categorical_cols] + [
        'PAYER_ID', 'FACILITY_ID', 'BILLED_AMOUNT', 'SERVICE_DOW', 'SERVICE_MONTH'
    ]

    X = claims_df[feature_cols]
    y = claims_df['IS_DENIED']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    model = GradientBoostingClassifier(
        n_estimators=100,
        max_depth=4,
        learning_rate=0.1,
        random_state=42
    )
    model.fit(X_train, y_train)

    accuracy = model.score(X_test, y_test)
    feature_importance = dict(zip(feature_cols, model.feature_importances_.tolist()))

    return {
        'model': model,
        'encoders': encoders,
        'accuracy': accuracy,
        'feature_importance': feature_importance,
        'feature_cols': feature_cols
    }


def register_prediction_udf(session: snowpark.Session, model_artifacts: dict):
    model = model_artifacts['model']
    encoders = model_artifacts['encoders']
    feature_cols = model_artifacts['feature_cols']

    @udf(
        name="CORTEX_CODE_RCM_DEMO.MARTS.PREDICT_DENIAL_PROBABILITY",
        is_permanent=True,
        stage_location="@CORTEX_CODE_RCM_DEMO.MARTS.UDF_STAGE",
        replace=True,
        packages=['scikit-learn', 'pandas'],
        input_types=[IntegerType(), StringType(), StringType(), StringType(), StringType(),
                     IntegerType(), FloatType(), IntegerType(), IntegerType()],
        return_type=FloatType(),
        session=session
    )
    def predict_denial_probability(
        payer_id: int,
        payer_type: str,
        cpt_code: str,
        diagnosis_code: str,
        provider_npi: str,
        facility_id: int,
        billed_amount: float,
        service_dow: int,
        service_month: int
    ) -> float:
        import pandas as pd

        categorical_values = {
            'PAYER_TYPE': payer_type,
            'CPT_CODE': cpt_code,
            'PRIMARY_DIAGNOSIS_CODE': diagnosis_code,
            'PROVIDER_NPI': provider_npi
        }

        encoded_values = {}
        for col_name, value in categorical_values.items():
            le = encoders[col_name]
            if value in le.classes_:
                encoded_values[col_name + '_ENC'] = le.transform([value])[0]
            else:
                encoded_values[col_name + '_ENC'] = -1

        features = pd.DataFrame([{
            **encoded_values,
            'PAYER_ID': payer_id,
            'FACILITY_ID': facility_id,
            'BILLED_AMOUNT': billed_amount,
            'SERVICE_DOW': service_dow,
            'SERVICE_MONTH': service_month
        }])[feature_cols]

        probability = model.predict_proba(features)[0][1]
        return float(round(probability, 4))

    return "UDF registered: CORTEX_CODE_RCM_DEMO.MARTS.PREDICT_DENIAL_PROBABILITY"


def main(session: snowpark.Session):
    print("Training denial prediction model...")
    artifacts = train_denial_model(session)

    print(f"Model accuracy: {artifacts['accuracy']:.3f}")
    print(f"Top features: {json.dumps(artifacts['feature_importance'], indent=2)}")

    session.sql("CREATE STAGE IF NOT EXISTS CORTEX_CODE_RCM_DEMO.MARTS.UDF_STAGE").collect()

    print("Registering UDF...")
    result = register_prediction_udf(session, artifacts)
    print(result)

    print("\nSample prediction query:")
    print("""
    SELECT
        CLAIM_ID,
        PAYER_ID,
        CPT_CODE,
        BILLED_AMOUNT,
        CLAIM_STATUS,
        CORTEX_CODE_RCM_DEMO.MARTS.PREDICT_DENIAL_PROBABILITY(
            PAYER_ID,
            'Commercial',
            CPT_CODE,
            PRIMARY_DIAGNOSIS_CODE,
            PROVIDER_NPI,
            FACILITY_ID,
            BILLED_AMOUNT,
            DAYOFWEEK(SERVICE_DATE),
            MONTH(SERVICE_DATE)
        ) AS DENIAL_PROBABILITY
    FROM CORTEX_CODE_RCM_DEMO.RAW.CLAIMS
    WHERE SERVICE_LINE_CODE = 'EM'
    ORDER BY DENIAL_PROBABILITY DESC
    LIMIT 20;
    """)


if __name__ == "__main__":
    from snowflake.snowpark import Session
    import os
    session = Session.builder.configs({
        "connection_name": os.getenv("SNOWFLAKE_CONNECTION_NAME", "default")
    }).create()
    main(session)
