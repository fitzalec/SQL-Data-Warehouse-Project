# Data Warehouse Architecture

This page shows the data warehouse ingestion and modeling flow for the project as a Mermaid diagram.

```mermaid
flowchart LR
  %% Sources
  CSV[/"Source CSV files\n(ERP & CRM)"/]

  %% Database and layers
  subgraph DW["DataWarehouse (SQL Server)"]
    direction TB
    subgraph Bronze["bronze schema (raw ingest)"]
      direction TB
      b_crm_cust[(crm_cust_info)]
      b_crm_prd[(crm_prd_info)]
      b_crm_sales[(crm_sales_details)]
      b_erp_loc[(erp_loc_a101)]
      b_erp_cust[(erp_cust_az12)]
      b_erp_px[(erp_px_cat_g1v2)]
    end

    subgraph Silver["silver schema (cleaned / integrated)"]
      s_cleansed[/Cleaned & Joined Tables/]
    end

    subgraph Gold["gold schema (business model / star)"]
      g_dim_cust[(dim_customer)]
      g_dim_prd[(dim_product)]
      g_fact_sales[(fact_sales)]
    end
  end

  %% Orchestration & DDL/ETL scripts
  init_db["init_database.sql\n(create DB & schemas)"]
  ddl_bronze["scripts/ddl_bronze.sql\n(create bronze tables)"]
  proc_load["scripts/proc_load_bronze.sql\n(BULK INSERT loader)"]

  %% Flow: Source -> Bronze
  CSV -->|BULK INSERT (proc_load_bronze.sql)| b_crm_cust
  CSV -->|BULK INSERT (proc_load_bronze.sql)| b_crm_prd
  CSV -->|BULK INSERT (proc_load_bronze.sql)| b_crm_sales
  CSV -->|BULK INSERT (proc_load_bronze.sql)| b_erp_loc
  CSV -->|BULK INSERT (proc_load_bronze.sql)| b_erp_cust
  CSV -->|BULK INSERT (proc_load_bronze.sql)| b_erp_px

  %% Bronze -> Silver (cleanse / validate)
  b_crm_cust -->|Cleansing / Type checks / Enrich| s_cleansed
  b_crm_prd  -->|Cleansing / Dedup| s_cleansed
  b_crm_sales -->|Date / Amount corrections| s_cleansed
  b_erp_loc -->|Lookup / Standardize| s_cleansed
  b_erp_cust -->|Join / Normalize| s_cleansed
  b_erp_px -->|Category mapping| s_cleansed

  %% Silver -> Gold (integration & modeling)
  s_cleansed -->|Build dimensions & facts (star schema)| g_dim_cust
  s_cleansed -->|Build dimensions & facts (star schema)| g_dim_prd
  s_cleansed -->|Build dimensions & facts (star schema)| g_fact_sales

  %% Consumption
  g_dim_cust -->|Used by| Reports[/"Analytics & Reporting\n(SQL-based queries, dashboards)"/]
  g_dim_prd -->|Used by| Reports
  g_fact_sales -->|Used by| Reports

  %% Orchestration links
  init_db -->|setup schemas| Bronze
  init_db --> Silver
  init_db --> Gold
  ddl_bronze -->|creates bronze tables| Bronze
  proc_load -->|runs loader| CSV

  %% Styling
  classDef db fill:#f7f9fb,stroke:#2b6cb0,stroke-width:1px;
  class CSV,Reports init_db,ddl_bronze,proc_load db;
  class Bronze,Silver,Gold db;
```
