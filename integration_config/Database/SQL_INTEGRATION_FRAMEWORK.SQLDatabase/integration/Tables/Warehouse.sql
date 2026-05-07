CREATE TABLE [integration].[Warehouse] (
    [WarehouseId]   INT              IDENTITY (1, 1) NOT NULL,
    [WarehouseGuid] UNIQUEIDENTIFIER NOT NULL,
    [WorkspaceGuid] UNIQUEIDENTIFIER NOT NULL,
    [Name]          VARCHAR (100)    NOT NULL,
    [IsActive]      BIT              DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_integration_Warehouse] PRIMARY KEY CLUSTERED ([WarehouseId] ASC),
    CONSTRAINT [FK_Warehouse_Workspace] FOREIGN KEY ([WorkspaceGuid]) REFERENCES [integration].[Workspace] ([WorkspaceGuid]),
    CONSTRAINT [UC_integration_Warehouse] UNIQUE NONCLUSTERED ([WarehouseGuid] ASC)
);


GO

