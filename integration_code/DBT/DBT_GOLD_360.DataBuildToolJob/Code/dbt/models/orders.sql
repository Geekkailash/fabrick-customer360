-- ============================================================
-- dbt model: base_orders.sql
-- Description: Base model for the [dbo].[orders] table.
-- This model selects all columns from the raw orders table.
-- ============================================================
SELECT
    *
FROM [silver].[orders];