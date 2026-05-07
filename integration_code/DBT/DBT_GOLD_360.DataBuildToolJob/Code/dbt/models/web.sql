
-- ============================================================
-- dbt model: base_web.sql
-- Description: Base model for the [dbo].[web] table.
-- This model selects all columns from the raw web table.
-- ============================================================
SELECT
    *
FROM [silver].[web];