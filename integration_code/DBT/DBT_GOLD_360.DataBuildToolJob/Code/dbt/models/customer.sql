-- ============================================================
-- dbt model: base_customer.sql
-- Description: Base model for the [dbo].[customer] table.
-- This model selects all columns from the raw customer table.
-- ============================================================
SELECT
    *
FROM [silver].[customer];