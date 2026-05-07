CREATE TABLE [integration].[GoldLayerEntity] (
    [GoldLayerEntityId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [WarehouseId]       INT            NOT NULL,
    [PipelineGuid]      NVARCHAR (100) NULL,
    [GoldSchema]        NVARCHAR (100) NULL,
    [Name]              NVARCHAR (200) NULL,
    [IsActive]          BIT            NOT NULL,
    CONSTRAINT [PK_integration_GOLDLayerEntity] PRIMARY KEY CLUSTERED ([GoldLayerEntityId] ASC),
    CONSTRAINT [UC_integration_GOLDLayerEntity] UNIQUE NONCLUSTERED ([WarehouseId] ASC, [GoldSchema] ASC, [Name] ASC)
);


GO

