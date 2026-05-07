-- Auto Generated (Do not modify) 8007E64D8C55643CB716C67515363714574240457F2A25C07F28BB8B366EA12E
create view "jaffle_shop"."web" as -- ============================================================
-- dbt model: base_web.sql
-- Description: Base model for the [dbo].[web] table.
-- This model selects all columns from the raw web table.
-- ============================================================
SELECT
    *
FROM [silver].[web];;