-- Auto Generated (Do not modify) ECD07EC7298762BB30FBDC9999FA920ABB61F6C6D057CFF167C3A1661CAA410B
create view "jaffle_shop"."customer" as -- ============================================================
-- dbt model: base_customer.sql
-- Description: Base model for the [dbo].[customer] table.
-- This model selects all columns from the raw customer table.
-- ============================================================
SELECT
    *
FROM [silver].[customer];;