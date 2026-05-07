-- Auto Generated (Do not modify) D9551ED83557F5800BCC1AFE36746461C3057070CB95C41B8DAB117D94C4E7EC
create view "jaffle_shop"."payments" as -- ============================================================
-- dbt model: base_payments.sql
-- Description: Base model for the [dbo].[payments] table.
-- This model selects all columns from the raw payments table.
-- ============================================================
SELECT
    *
FROM [silver].[payments];;