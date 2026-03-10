# Cortex Code Demo Script — Healthcare RCM

**Duration:** ~40 minutes
**Audience:** Healthcare data engineering team migrating from SQL Server to Snowflake
**Goal:** Show how Cortex Code accelerates a SQL Server → Snowflake EDW migration

---

## Platform Notes

This demo works on both Cortex Code surfaces. Key differences:

| Feature | CLI (`cortex`) | Snowsight |
|---------|---------------|-----------|
| File references | `@path/to/file.sql` | Paste file contents directly into chat |
| Table references | `#DB.SCHEMA.TABLE` (auto-injects schema + sample rows) | Type the fully-qualified table name; CoCo resolves it |
| Run SQL | `/sql SELECT ...` | CoCo generates SQL → click **Run** in the worksheet |
| Bash commands | `!git status`, `!dbt run` | Not available |
| Plan Mode | `Shift+Tab` before sending | Not available (CoCo always plans internally) |
| Todo list | `Ctrl+D` to toggle | Not available |
| Fork conversation | `/fork` | Not available |
| Compact context | `/compact` | Not available |
| Custom Skills | `$skill-name` | Not available |
| Write/edit files | CoCo writes files directly to your project | CoCo generates code in chat; copy to worksheet or notebook |

> **Recommendation:** Use **CLI** for the full demo experience (Parts 1–6). Use **Snowsight** when the audience prefers a browser-based experience or doesn't have CLI installed — skip Part 6 productivity features or adapt them.

---

## Pre-Demo Checklist

- [ ] Run `sql/01_schema_ddl.sql` to create schema
- [ ] Run `sql/02_sample_data.sql` to load data
- [ ] Verify data: `SELECT COUNT(*) FROM CORTEX_CODE_RCM_DEMO.RAW.CLAIMS;` (should be ~500)
- [ ] **CLI path:** Open Cortex Code in the project directory (`cd rcm-coco-demo && cortex`)
- [ ] **Snowsight path:** Open Snowsight → Cortex Code panel; have `tsql-samples/em_collections_sproc.sql` content copied to clipboard
- [ ] Have `tsql-samples/em_collections_sproc.sql` ready to paste

---

## Part 1: The Hook — T-SQL Conversion (5 min)

**Setup:** Open `tsql-samples/em_collections_sproc.sql` in a separate tab.

**Talk track:**
> "Your team is migrating hundreds of SQL Server stored procedures to Snowflake. Let's see how Cortex Code handles this."

**Prompt to type:**

> **CLI:**
> ```
> @tsql-samples/em_collections_sproc.sql
>
> Convert this T-SQL stored procedure to Snowflake SQL. Handle all dialect
> differences including: GETDATE → CURRENT_TIMESTAMP, ISNULL → COALESCE,
> temp tables → CTEs or transient tables, DATEDIFF syntax, STRING_AGG → LISTAGG,
> and CAST patterns. Keep the same business logic.
> ```

> **Snowsight:**
> Paste the full T-SQL stored procedure from `em_collections_sproc.sql` into the chat, then type:
> ```
> Convert this T-SQL stored procedure to Snowflake SQL. Handle all dialect
> differences including: GETDATE → CURRENT_TIMESTAMP, ISNULL → COALESCE,
> temp tables → CTEs or transient tables, DATEDIFF syntax, STRING_AGG → LISTAGG,
> and CAST patterns. Keep the same business logic.
> ```

**What to point out:**
- CoCo identifies ~10 dialect differences automatically
- Converts temp table pattern to CTE (cleaner for Snowflake)
- Handles `WITH (NOLOCK)` removal (no lock contention in Snowflake)
- Converts `DATEADD(MONTH, DATEDIFF(MONTH, 0, date), 0)` → `DATE_TRUNC('MONTH', date)`
- Converts `STRING_AGG` → `LISTAGG`
- **CLI bonus:** CoCo can write the converted SQL directly to a new file in your project

**Transition:** "That took 30 seconds. In a manual migration, that's 30-60 minutes per proc. Now let's explore the data it works with."

---

## Part 2: Schema Exploration (5 min)

**Prompt:**

> **CLI:**
> ```
> #CORTEX_CODE_RCM_DEMO.RAW.CLAIMS
>
> What does this table contain? What's the distribution of claim statuses?
> Are there any data quality issues I should know about?
> ```

> **Snowsight:**
> ```
> Look at the table CORTEX_CODE_RCM_DEMO.RAW.CLAIMS.
>
> What does this table contain? What's the distribution of claim statuses?
> Are there any data quality issues I should know about?
> ```

**What to point out:**
- **CLI:** `#` auto-injects schema + sample rows — no manual DESCRIBE needed
- **Snowsight:** CoCo resolves the table name and queries schema/samples behind the scenes
- CoCo understands the domain (RCM, claims, CPT codes)
- It proactively identifies NULL patterns and data quality issues

**Follow-up prompt (same on both):**
```
Show me the relationship between CLAIMS, ENCOUNTERS, PROVIDERS, and PAYERS.
Which columns are the join keys?
```

**Transition:** "New engineers see this on day 1 and understand the data model immediately. Now let's build something."

---

## Part 3: Pipeline Development (10 min)

### Step 3a: Build the transformation

**Prompt:**

> **CLI:**
> ```
> Using #CORTEX_CODE_RCM_DEMO.RAW.CLAIMS, #CORTEX_CODE_RCM_DEMO.RAW.FACILITIES,
> #CORTEX_CODE_RCM_DEMO.RAW.PROVIDERS, and #CORTEX_CODE_RCM_DEMO.RAW.PAYERS:
>
> Create a mart table CORTEX_CODE_RCM_DEMO.MARTS.MART_EM_COLLECTIONS_PER_VISIT that:
> 1. Deduplicates claims by CLAIM_ID (keep latest by LAST_UPDATED)
> 2. Filters to EM service line and paid/denied/partial/adjudicated statuses
> 3. Joins with facilities, providers, and payers
> 4. Ranks claims per encounter (keep highest billed)
> 5. Aggregates by facility, provider, and month to calculate:
>    - Collections per visit
>    - Collection rate (paid/billed %)
>    - Denial rate
>    - Average days to payment
>    - Average EM level
> ```

> **Snowsight:** Same prompt, but replace `#DB.SCHEMA.TABLE` with plain `DB.SCHEMA.TABLE` references (no `#` prefix).

**What to point out:**
- CoCo uses Snowflake-native functions (IFF, COALESCE, DATE_TRUNC)
- It generates the dedup + ranking pattern correctly
- **CLI bonus:** Notice the todo list (`Ctrl+D`) showing its plan
- **Snowsight:** CoCo generates the SQL in chat — click **Run** to execute in a worksheet

**Compare with answer key:** `sql/03_staging_to_mart.sql`

### Step 3b: Add denial rate calculation

**Prompt (same on both):**
```
Add a denial rate calculation that breaks down by denial reason code, and
filter to only paid/adjudicated claims for the collections metrics
but keep denied claims for the denial rate calculation.
```

### Step 3c: Make it incremental

**Prompt (same on both):**
```
Now make this incremental:
1. Create a Stream on CORTEX_CODE_RCM_DEMO.STAGING.STG_CLAIMS_DAILY
2. Create a Task that runs every hour when the stream has data
3. MERGE new claims into the RAW.CLAIMS table
4. Chain a second Task that refreshes the mart after the load completes
```

**What to point out:**
- CoCo generates the SYSTEM$STREAM_HAS_DATA condition
- Proper MERGE with WHEN MATCHED / NOT MATCHED
- Task chaining with AFTER clause
- Reminder to resume tasks (child first, then parent)

**Transition:** "This works great. But there's an even simpler approach..."

---

## Part 4: Dynamic Tables (5 min)

**Prompt (same on both):**
```
Convert the Task + Stream pipeline from Part 3 into Dynamic Tables.
I want the same business logic but using declarative DTs with a 1-hour target lag.
Create a chain: enriched claims DT → collections mart DT → denial analysis DT.
```

**What to point out:**
- No orchestration code needed — Snowflake handles refresh automatically
- DT chaining (`DT2 reads from DT1`) creates a declarative DAG
- Same business logic, 70% less code
- Explain tradeoff: Tasks give fine-grained control, DTs give simplicity

**Compare with answer key:** `sql/04_dynamic_tables.sql`

**Transition:** "Once your EDW is in Snowflake, here's what becomes possible..."

---

## Part 5: AI/ML Tease (5 min)

**Prompt (same on both):**
```
Help me build a Snowpark Python UDF that predicts claim denial probability.
It should take payer_id, payer_type, CPT code, diagnosis code, provider NPI,
facility ID, billed amount, and service date features. Use a
GradientBoostingClassifier and register it as a permanent UDF in
CORTEX_CODE_RCM_DEMO.MARTS.
```

**What to point out:**
- CoCo scaffolds the full ML pipeline: data prep → train → register → query
- Uses Snowpark native patterns (session.sql, @udf decorator)
- Generates a sample prediction query they can run immediately
- This is a real use case: RCM companies save millions catching denials early
- **CLI bonus:** CoCo writes the Python file directly to `snowpark/denial_prediction_udf.py`
- **Snowsight:** Copy the generated code into a Snowflake notebook or local file

**Compare with answer key:** `snowpark/denial_prediction_udf.py`

**Transition:** "Let me show you a few more things that make daily development faster."

---

## Part 6: Developer Productivity (5 min)

### CLI Version

Run through these quickly:

| Demo | Command | Talk track |
|------|---------|------------|
| Execute SQL inline | `/sql SELECT COUNT(*) FROM CORTEX_CODE_RCM_DEMO.RAW.CLAIMS WHERE CLAIM_STATUS = 'DENIED'` | "Test queries without leaving the conversation" |
| Bash commands | `!git status` | "Run any shell command inline — git, dbt, snow cli" |
| Plan Mode | `Shift+Tab` before a complex prompt | "Review the plan before CoCo executes — governance for production changes" |
| Compact | `/compact` | "Long migration sessions? Compress the context without losing history" |
| Fork | `/fork` | "Try two approaches — keep both, pick the winner" |
| File reference | `@sql/03_staging_to_mart.sql explain this transformation` | "Pull any project file into context" |

**Skills teaser:**
> "You can also create custom Skills — imagine an 'RCM Coding Standards' skill that enforces your naming conventions, your CPT validation rules, and your EM-specific business logic every time someone writes SQL."

### Snowsight Version

> These CLI-specific features aren't available in Snowsight. Instead, highlight:

| Demo | How | Talk track |
|------|-----|------------|
| Run generated SQL | Click **Run** on any SQL CoCo generates | "One click to execute — no copy-paste to a separate worksheet" |
| Multi-turn iteration | Just keep chatting | "Refine your query iteratively — CoCo remembers the full conversation" |
| Schema awareness | Ask about any table by name | "CoCo knows your schema — ask about any table and it pulls the structure automatically" |

---

## Part 7: The Close (5 min)

**Talk track:**
> "Let's step back and think about what we just built in 30 minutes."

- Converted a complex T-SQL stored procedure to Snowflake SQL
- Explored and understood the data model conversationally
- Built a full staging → mart transformation pipeline
- Made it incremental with Streams and Tasks
- Converted to Dynamic Tables for zero-orchestration pipelines
- Scaffolded an ML model for denial prediction

> "Every one of these tasks would normally take hours of manual work. Cortex Code compresses that to minutes — and it makes every engineer on the team as productive as your best engineer."

> "Once the EDW is in Snowflake, the AI/ML use cases — denial prediction, coding optimization, collections forecasting — they become natural next steps."

**Ask:**
> "What questions do you have? Want to try any of these prompts yourselves?"

---

## Backup Prompts (if time allows or Q&A steers this way)

**dbt integration:**
```
Create a dbt model for the EM collections mart. Include a schema.yml
with tests for not_null on key columns and accepted_values for CLAIM_STATUS.
```

**Debugging:**
```
This query is running slowly on XS warehouse:
[paste a problematic query]
Help me optimize it for Snowflake.
```

**Documentation:**
```
Generate documentation for the CORTEX_CODE_RCM_DEMO schema — describe each
table, its purpose in the RCM workflow, and key columns.
```
