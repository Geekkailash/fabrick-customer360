CREATE TABLE [dbo].[payments] (

	[payment_id] varchar(8000) NULL, 
	[customer_id] bigint NULL, 
	[payment_date] date NULL, 
	[payment_method] varchar(8000) NULL, 
	[payment_status] varchar(8000) NULL, 
	[amount] float NULL, 
	[year] int NULL, 
	[month] int NULL, 
	[day] int NULL, 
	[HashedPKColumn] varchar(8000) NULL, 
	[HashedNonKeyColumns] varchar(8000) NULL, 
	[RecordLoadDate] datetime2(6) NULL
);