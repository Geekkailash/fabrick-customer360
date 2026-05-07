CREATE TABLE [silver].[support] (

	[ticket_id] varchar(8000) NULL, 
	[customer_id] bigint NULL, 
	[issue_type] varchar(8000) NULL, 
	[ticket_date] date NULL, 
	[resolution_status] varchar(8000) NULL, 
	[year] int NULL, 
	[month] int NULL, 
	[day] int NULL, 
	[last_modified] datetime2(6) NULL
);