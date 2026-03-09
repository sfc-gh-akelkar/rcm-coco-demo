-- ============================================================================
-- Cortex Code Demo — Sample Data
-- Realistic RCM data: Emergency Medicine billing across 3 facilities
-- ============================================================================

USE SCHEMA CORTEX_CODE_RCM_DEMO.RAW;

-- Facilities
INSERT INTO FACILITIES (FACILITY_ID, FACILITY_NAME, FACILITY_TYPE, STATE, CITY, BED_COUNT, CONTRACT_START_DATE, IS_ACTIVE) VALUES
(101, 'Memorial Regional Medical Center', 'Hospital', 'TX', 'Dallas', 450, '2023-01-15', TRUE),
(102, 'Lakewood Community Hospital', 'Hospital', 'TX', 'Houston', 280, '2023-04-01', TRUE),
(103, 'Sunrise Health System', 'Hospital', 'FL', 'Tampa', 350, '2023-06-15', TRUE),
(104, 'Pacific Northwest Medical', 'Hospital', 'WA', 'Seattle', 500, '2024-01-01', TRUE),
(105, 'Centennial Physicians Group', 'Clinic', 'CO', 'Denver', 0, '2024-03-01', TRUE);

-- Providers
INSERT INTO PROVIDERS (PROVIDER_NPI, PROVIDER_NAME, PROVIDER_SPECIALTY, CREDENTIAL, FACILITY_ID, HIRE_DATE, IS_ACTIVE) VALUES
('1234567890', 'Dr. Sarah Chen', 'Emergency Medicine', 'MD', 101, '2020-03-15', TRUE),
('1234567891', 'Dr. James Wilson', 'Emergency Medicine', 'MD', 101, '2019-08-01', TRUE),
('1234567892', 'Dr. Maria Garcia', 'Emergency Medicine', 'DO', 102, '2021-01-10', TRUE),
('1234567893', 'Dr. Robert Kim', 'Emergency Medicine', 'MD', 102, '2022-05-20', TRUE),
('1234567894', 'Dr. Emily Brooks', 'Emergency Medicine', 'MD', 103, '2020-11-01', TRUE),
('1234567895', 'Dr. David Patel', 'Emergency Medicine', 'MD', 103, '2023-02-15', TRUE),
('1234567896', 'Dr. Lisa Tran', 'Emergency Medicine', 'DO', 104, '2023-07-01', TRUE),
('1234567897', 'Dr. Michael Santos', 'Emergency Medicine', 'MD', 104, '2021-09-15', TRUE),
('1234567898', 'Dr. Jennifer Liu', 'Radiology', 'MD', 101, '2022-01-15', TRUE),
('1234567899', 'Dr. Andrew Fox', 'Anesthesiology', 'MD', 101, '2021-06-01', TRUE);

-- Payers
INSERT INTO PAYERS (PAYER_ID, PAYER_NAME, PAYER_TYPE, STATE, CONTRACT_RATE_PCT, IS_IN_NETWORK) VALUES
(201, 'Blue Cross Blue Shield TX', 'Commercial', 'TX', 82.50, TRUE),
(202, 'Aetna', 'Commercial', 'TX', 78.00, TRUE),
(203, 'UnitedHealthcare', 'Commercial', 'TX', 80.00, TRUE),
(204, 'Medicare Part A', 'Government', 'TX', 100.00, TRUE),
(205, 'Medicare Part B', 'Government', 'TX', 100.00, TRUE),
(206, 'Texas Medicaid', 'Government', 'TX', 100.00, TRUE),
(207, 'Cigna', 'Commercial', 'FL', 76.50, TRUE),
(208, 'Humana', 'Commercial', 'FL', 74.00, TRUE),
(209, 'Premera Blue Cross', 'Commercial', 'WA', 79.00, TRUE),
(210, 'Self-Pay', 'Self-Pay', NULL, NULL, FALSE);

-- Denial Codes
INSERT INTO DENIAL_CODES (DENIAL_REASON_CODE, DENIAL_CATEGORY, DENIAL_DESCRIPTION, IS_APPEALABLE, TYPICAL_RESOLUTION) VALUES
('CO-4', 'Coding', 'Procedure code inconsistent with modifier or missing modifier', TRUE, 'Resubmit with correct modifier'),
('CO-16', 'Missing Info', 'Claim lacks information needed for adjudication', TRUE, 'Resubmit with required documentation'),
('CO-18', 'Duplicate', 'Exact duplicate claim/service', FALSE, 'Verify original claim status'),
('CO-22', 'Coordination', 'Payment adjusted per coordination of benefits', TRUE, 'Bill secondary payer'),
('CO-29', 'Timely Filing', 'Time limit for filing has expired', FALSE, 'File appeal with proof of timely submission'),
('CO-45', 'Contractual', 'Charges exceed fee schedule/maximum allowable', FALSE, 'Write off per contract'),
('CO-50', 'Non-Covered', 'These are non-covered services because this is not deemed a medical necessity', TRUE, 'Appeal with clinical documentation'),
('CO-97', 'Bundling', 'Payment included in allowance for another procedure', TRUE, 'Appeal with modifier 59 if distinct'),
('PR-1', 'Patient Resp', 'Deductible amount', FALSE, 'Bill patient'),
('PR-2', 'Patient Resp', 'Coinsurance amount', FALSE, 'Bill patient');

-- Encounters (200 encounters across facilities, Oct 2025 - Feb 2026)
INSERT INTO ENCOUNTERS (ENCOUNTER_ID, PATIENT_ACCOUNT_NUM, FACILITY_ID, PROVIDER_NPI, PAYER_ID, ENCOUNTER_DATE, DISCHARGE_DATE, CHIEF_COMPLAINT, ACUITY_LEVEL, DISPOSITION, LENGTH_OF_STAY_MIN)
SELECT
    'ENC-' || LPAD(SEQ4()::VARCHAR, 7, '0'),
    'PA-' || LPAD((SEQ4() * 3 + 1000)::VARCHAR, 8, '0'),
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 101 WHEN 1 THEN 102 WHEN 2 THEN 103 ELSE 104
    END,
    '123456789' || MOD(SEQ4(), 8)::VARCHAR,
    CASE MOD(SEQ4(), 10)
        WHEN 0 THEN 201 WHEN 1 THEN 202 WHEN 2 THEN 203 WHEN 3 THEN 204
        WHEN 4 THEN 205 WHEN 5 THEN 206 WHEN 6 THEN 207 WHEN 7 THEN 208
        WHEN 8 THEN 209 ELSE 210
    END,
    DATEADD('DAY', -MOD(SEQ4() * 7, 150), '2026-02-28')::TIMESTAMP,
    DATEADD('MINUTE',
        CASE MOD(SEQ4(), 5)
            WHEN 0 THEN 45 WHEN 1 THEN 120 WHEN 2 THEN 180 WHEN 3 THEN 240 ELSE 360
        END,
        DATEADD('DAY', -MOD(SEQ4() * 7, 150), '2026-02-28')::TIMESTAMP
    ),
    CASE MOD(SEQ4(), 8)
        WHEN 0 THEN 'Chest pain' WHEN 1 THEN 'Abdominal pain' WHEN 2 THEN 'Shortness of breath'
        WHEN 3 THEN 'Laceration' WHEN 4 THEN 'Fall injury' WHEN 5 THEN 'Headache'
        WHEN 6 THEN 'Fever' ELSE 'Back pain'
    END,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Discharged' WHEN 1 THEN 'Admitted' WHEN 2 THEN 'Transferred' ELSE 'AMA'
    END,
    30 + MOD(SEQ4() * 13, 400)
FROM TABLE(GENERATOR(ROWCOUNT => 200));

-- Claims (500 claims linked to encounters, mix of statuses)
INSERT INTO CLAIMS (CLAIM_ID, ENCOUNTER_ID, PATIENT_ACCOUNT_NUM, FACILITY_ID, PROVIDER_NPI, PAYER_ID,
    SERVICE_DATE, CPT_CODE, CPT_DESCRIPTION, PRIMARY_DIAGNOSIS_CODE, DIAGNOSIS_DESCRIPTION,
    SERVICE_LINE_CODE, BILLED_AMOUNT, ALLOWED_AMOUNT, PAID_AMOUNT, PATIENT_RESPONSIBILITY,
    ADJUSTMENT_AMOUNT, CLAIM_STATUS, DENIAL_REASON_CODE, DENIAL_REASON_DESC,
    FIRST_SUBMISSION_DATE, FIRST_PAYMENT_DATE, LAST_UPDATED)
SELECT
    'CLM-' || LPAD(SEQ4()::VARCHAR, 8, '0'),
    'ENC-' || LPAD(MOD(SEQ4(), 200)::VARCHAR, 7, '0'),
    'PA-' || LPAD((MOD(SEQ4(), 200) * 3 + 1000)::VARCHAR, 8, '0'),
    CASE MOD(MOD(SEQ4(), 200), 4)
        WHEN 0 THEN 101 WHEN 1 THEN 102 WHEN 2 THEN 103 ELSE 104
    END,
    '123456789' || MOD(MOD(SEQ4(), 200), 8)::VARCHAR,
    CASE MOD(MOD(SEQ4(), 200), 10)
        WHEN 0 THEN 201 WHEN 1 THEN 202 WHEN 2 THEN 203 WHEN 3 THEN 204
        WHEN 4 THEN 205 WHEN 5 THEN 206 WHEN 6 THEN 207 WHEN 7 THEN 208
        WHEN 8 THEN 209 ELSE 210
    END,
    DATEADD('DAY', -MOD(SEQ4() * 7, 150), '2026-02-28')::DATE,
    CASE MOD(SEQ4(), 12)
        WHEN 0 THEN '99281' WHEN 1 THEN '99282' WHEN 2 THEN '99283' WHEN 3 THEN '99284'
        WHEN 4 THEN '99285' WHEN 5 THEN '99291' WHEN 6 THEN '99292'
        WHEN 7 THEN '12001' WHEN 8 THEN '12002' WHEN 9 THEN '36556'
        WHEN 10 THEN '71046' ELSE '93010'
    END,
    CASE MOD(SEQ4(), 12)
        WHEN 0 THEN 'ED visit level 1' WHEN 1 THEN 'ED visit level 2' WHEN 2 THEN 'ED visit level 3'
        WHEN 3 THEN 'ED visit level 4' WHEN 4 THEN 'ED visit level 5'
        WHEN 5 THEN 'Critical care first hour' WHEN 6 THEN 'Critical care addl 30 min'
        WHEN 7 THEN 'Simple repair scalp/trunk' WHEN 8 THEN 'Repair scalp/trunk 2.6-7.5cm'
        WHEN 9 THEN 'Central venous catheter' WHEN 10 THEN 'Chest X-ray 2 views'
        ELSE 'Electrocardiogram'
    END,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'R07.9' WHEN 1 THEN 'R10.9' WHEN 2 THEN 'R06.00'
        WHEN 3 THEN 'S01.01' WHEN 4 THEN 'W19.XXXA' ELSE 'R51.9'
    END,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'Chest pain, unspecified' WHEN 1 THEN 'Abdominal pain, unspecified'
        WHEN 2 THEN 'Dyspnea, unspecified' WHEN 3 THEN 'Laceration of scalp'
        WHEN 4 THEN 'Unspecified fall' ELSE 'Headache'
    END,
    'EM',
    ROUND(50 + UNIFORM(0::FLOAT, 2500::FLOAT, RANDOM(SEQ4())), 2),
    CASE WHEN MOD(SEQ4(), 20) = 0 THEN NULL
         ELSE ROUND((50 + UNIFORM(0::FLOAT, 2500::FLOAT, RANDOM(SEQ4()))) * UNIFORM(0.55::FLOAT, 0.85::FLOAT, RANDOM(SEQ4() + 1)), 2)
    END,
    CASE
        WHEN MOD(SEQ4(), 7) = 0 THEN 0
        WHEN MOD(SEQ4(), 20) = 0 THEN NULL
        ELSE ROUND((50 + UNIFORM(0::FLOAT, 2500::FLOAT, RANDOM(SEQ4()))) * UNIFORM(0.45::FLOAT, 0.80::FLOAT, RANDOM(SEQ4() + 2)), 2)
    END,
    ROUND(UNIFORM(0::FLOAT, 200::FLOAT, RANDOM(SEQ4() + 3)), 2),
    ROUND(UNIFORM(0::FLOAT, 500::FLOAT, RANDOM(SEQ4() + 4)), 2),
    CASE MOD(SEQ4(), 7)
        WHEN 0 THEN 'DENIED'
        WHEN 1 THEN 'PARTIAL'
        WHEN 6 THEN 'SUBMITTED'
        ELSE 'PAID'
    END,
    CASE WHEN MOD(SEQ4(), 7) = 0 THEN
        CASE MOD(SEQ4(), 8)
            WHEN 0 THEN 'CO-4' WHEN 1 THEN 'CO-16' WHEN 2 THEN 'CO-18' WHEN 3 THEN 'CO-50'
            WHEN 4 THEN 'CO-97' WHEN 5 THEN 'CO-29' WHEN 6 THEN 'CO-22' ELSE 'CO-45'
        END
    ELSE NULL END,
    CASE WHEN MOD(SEQ4(), 7) = 0 THEN 'Claim denied - see denial reason code' ELSE NULL END,
    DATEADD('DAY', 1 + MOD(SEQ4(), 5), DATEADD('DAY', -MOD(SEQ4() * 7, 150), '2026-02-28'))::DATE,
    CASE WHEN MOD(SEQ4(), 7) NOT IN (0, 6) THEN
        DATEADD('DAY', 15 + MOD(SEQ4() * 3, 45), DATEADD('DAY', -MOD(SEQ4() * 7, 150), '2026-02-28'))::DATE
    ELSE NULL END,
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- Seed a few rows into staging for Stream demo
USE SCHEMA CORTEX_CODE_RCM_DEMO.STAGING;

INSERT INTO STG_CLAIMS_DAILY (CLAIM_ID, ENCOUNTER_ID, PATIENT_ACCOUNT_NUM, FACILITY_ID, PROVIDER_NPI,
    PAYER_ID, SERVICE_DATE, CPT_CODE, PRIMARY_DIAGNOSIS_CODE, SERVICE_LINE_CODE,
    BILLED_AMOUNT, ALLOWED_AMOUNT, PAID_AMOUNT, PATIENT_RESPONSIBILITY, ADJUSTMENT_AMOUNT,
    CLAIM_STATUS, DENIAL_REASON_CODE, FIRST_PAYMENT_DATE, LOADED_AT)
SELECT
    'CLM-NEW-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'ENC-' || LPAD((200 + SEQ4())::VARCHAR, 7, '0'),
    'PA-' || LPAD((5000 + SEQ4())::VARCHAR, 8, '0'),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 101 WHEN 1 THEN 102 WHEN 2 THEN 103 ELSE 104 END,
    '123456789' || MOD(SEQ4(), 8)::VARCHAR,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 201 WHEN 1 THEN 203 WHEN 2 THEN 204 WHEN 3 THEN 207 ELSE 209 END,
    DATEADD('DAY', -MOD(SEQ4(), 7), CURRENT_DATE()),
    CASE MOD(SEQ4(), 5) WHEN 0 THEN '99283' WHEN 1 THEN '99284' WHEN 2 THEN '99285' WHEN 3 THEN '99291' ELSE '99282' END,
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'R07.9' WHEN 1 THEN 'R10.9' ELSE 'R06.00' END,
    'EM',
    ROUND(200 + UNIFORM(0::FLOAT, 2000::FLOAT, RANDOM(SEQ4())), 2),
    ROUND(150 + UNIFORM(0::FLOAT, 1500::FLOAT, RANDOM(SEQ4() + 1)), 2),
    ROUND(100 + UNIFORM(0::FLOAT, 1200::FLOAT, RANDOM(SEQ4() + 2)), 2),
    ROUND(UNIFORM(0::FLOAT, 150::FLOAT, RANDOM(SEQ4() + 3)), 2),
    ROUND(UNIFORM(0::FLOAT, 300::FLOAT, RANDOM(SEQ4() + 4)), 2),
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'DENIED' ELSE 'PAID' END,
    CASE WHEN MOD(SEQ4(), 5) = 0 THEN 'CO-50' ELSE NULL END,
    CASE WHEN MOD(SEQ4(), 5) != 0 THEN DATEADD('DAY', -MOD(SEQ4(), 3), CURRENT_DATE()) ELSE NULL END,
    CURRENT_TIMESTAMP()
FROM TABLE(GENERATOR(ROWCOUNT => 25));
