-- Auto Generated (Do not modify) 50036440FDEA6A1513BAC1B9A6F313D4CDE8613C6EA828FD2B77E1103DFA66C5
create view "jaffle_shop"."support" as -- ============================================================
-- dbt model: base_support.sql
-- Description: Base model for the [dbo].[support] table.
-- This model selects all columns from the raw support table.
-- ============================================================
SELECT
    *
FROM [silver].[support];;