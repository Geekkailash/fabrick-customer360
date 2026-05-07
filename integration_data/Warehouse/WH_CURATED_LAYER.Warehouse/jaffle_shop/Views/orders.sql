-- Auto Generated (Do not modify) F10316F3EA0F01A109AF6B5EFF26246A37CD80F149DFF476F1FF88982B4FA422
create view "jaffle_shop"."orders" as -- ============================================================
-- dbt model: base_orders.sql
-- Description: Base model for the [dbo].[orders] table.
-- This model selects all columns from the raw orders table.
-- ============================================================
SELECT
    *
FROM [silver].[orders];;