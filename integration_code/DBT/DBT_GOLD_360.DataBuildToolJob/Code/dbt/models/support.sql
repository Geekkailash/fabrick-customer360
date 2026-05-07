-- ============================================================
-- dbt model: base_support.sql
-- Description: Base model for the [dbo].[support] table.
-- This model selects all columns from the raw support table.
-- ============================================================
SELECT
    *
FROM [silver].[support];