-- ============================================================
-- dbt model: base_payments.sql
-- Description: Base model for the [dbo].[payments] table.
-- This model selects all columns from the raw payments table.
-- ============================================================
SELECT
    *
FROM [silver].[payments];