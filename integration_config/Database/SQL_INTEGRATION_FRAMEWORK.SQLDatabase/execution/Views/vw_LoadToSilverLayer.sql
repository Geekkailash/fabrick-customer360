    CREATE VIEW [execution].[vw_LoadToSilverLayer]
    AS

    WITH PipelineData AS (
        SELECT 
            BronzeLayerEntityId,
            MAX(CASE WHEN IsProcessed = 1 THEN PipelineBronzeLayerEntityId END) AS MaxProcessedId,
            MAX(CASE WHEN IsProcessed = 1 THEN InsertDateTime END) AS ProcessedDateTime,
            MAX(CASE WHEN IsProcessed = 0 THEN PipelineBronzeLayerEntityId END) AS MaxUnprocessedId,
            MAX(CASE WHEN IsProcessed = 0 THEN InsertDateTime END) AS UnprocessedDateTime
        FROM (
            SELECT 
                t.*,
                ROW_NUMBER() OVER (
                    PARTITION BY t.BronzeLayerEntityId, t.IsProcessed
                    ORDER BY t.PipelineBronzeLayerEntityId DESC
                ) AS rn
            FROM [execution].[PipelineBronzeLayerEntity] t
        ) x
        WHERE rn = 1
        GROUP BY BronzeLayerEntityId
    )

    SELECT 
        LZE.[LandingzoneEntityId],
        BLE.[BronzeLayerEntityId],
        SLE.[SilverLayerEntityId] AS [EntityId],
        BLE.[Schema] AS [SourceSchema],
        BLE.[Name] AS [SourceName],
        BLE.[FileType] AS [SourceFileType],
        SLE.[Schema] AS [TargetSchema],
        SLE.[Name] AS [TargetName],
        SLE.[FileType] AS [TargetFileType],
        WT.[WorkspaceGuid] AS [TargetWorkspaceId],
        WS.[WorkspaceGuid] AS [SourceWorkspaceId],
        SWH.[WarehouseGuid] AS [TargetWarehouseId],
        BLH.[LakehouseGuid] AS [SourceLakehouseId],
        SWH.[Name] AS [TargetWarehouseName],
        BLH.[Name] AS [SourceLakehouseName],
        SLE.[LayerType] AS [LayerType],
        SLE.[DataflowId] AS [DataflowId],
        SLE.[PKColumn] AS [PKColumn],
        PBLE.[MaxProcessedId],
        PBLE.[ProcessedDateTime],
        PBLE.[MaxUnprocessedId],
        PBLE.[UnprocessedDateTime],

        REPLACE(
            REPLACE(
                REPLACE(
                    CAST(SLE.[CleansingRules] AS NVARCHAR(MAX)),
                    CHAR(13), ''
                ),
                CHAR(10), ''
            ),
            CHAR(9), ''
        ) AS [CleansingRules],

        DS.[Namespace] AS [DataSourceNamespace]

    FROM [integration].[SilverLayerEntityWH] SLE
    INNER JOIN [integration].[BronzeLayerEntity] BLE
        ON SLE.[BronzeLayerEntityId] = BLE.[BronzeLayerEntityId]
    INNER JOIN [integration].[LandingzoneEntity] LZE
        ON LZE.[LandingzoneEntityId] = BLE.[LandingzoneEntityId]
    INNER JOIN PipelineData PBLE
        ON BLE.[BronzeLayerEntityId] = PBLE.[BronzeLayerEntityId]
    INNER JOIN [integration].[DataSource] DS
        ON DS.[DataSourceId] = LZE.[DataSourceId]
    INNER JOIN [integration].[Lakehouse] BLH
        ON BLE.[LakehouseId] = BLH.[LakehouseId]
    INNER JOIN [integration].[Warehouse] SWH
        ON SLE.[WarehouseId] = SWH.[WarehouseId]
    INNER JOIN [integration].[Workspace] WT
        ON WT.[WorkspaceGuid] = SWH.[WorkspaceGuid]
    INNER JOIN [integration].[Workspace] WS
        ON WS.[WorkspaceGuid] = BLH.[WorkspaceGuid]
    WHERE 
        LZE.[IsActive] = 1
        AND BLE.[IsActive] = 1
        AND SLE.[IsActive] = 1
        AND PBLE.[MaxUnprocessedId] IS NOT NULL

GO

