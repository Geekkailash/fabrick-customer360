CREATE TABLE [integration].[SilverLayerEntityWH] (
    [SilverLayerEntityId] INT            IDENTITY (1, 1) NOT NULL,
    [BronzeLayerEntityId] INT            NOT NULL,
    [WarehouseId]         INT            NOT NULL,
    [Schema]              NVARCHAR (100) NULL,
    [Name]                NVARCHAR (255) NOT NULL,
    [PrimaryKeys]         NVARCHAR (MAX) NULL,
    [FileType]            NVARCHAR (50)  NULL,
    [CleansingRules]      NVARCHAR (MAX) NULL,
    [IsActive]            BIT            DEFAULT ((1)) NOT NULL,
    [LayerType]           NVARCHAR (50)  NULL,
    [DataflowId]          NVARCHAR (50)  NULL,
    [PKColumn]            NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([SilverLayerEntityId] ASC)
);


GO

