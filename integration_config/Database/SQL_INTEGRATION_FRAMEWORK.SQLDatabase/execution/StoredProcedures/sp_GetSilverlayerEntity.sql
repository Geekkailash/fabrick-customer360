--DROP PROCEDURE [execution].[sp_GetSilverlayerEntity]

--exec [execution].[sp_GetSilverlayerEntity] @workspaceId='2effab8c-7fe4-4bfd-b678-34e1fd29d8ab'
--drop  PROCEDURE [execution].[sp_GetSilverlayerEntity]
CREATE   PROCEDURE [execution].[sp_GetSilverlayerEntity]
(    @WorkspaceId UNIQUEIDENTIFIER  
    )
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CONCAT(
        '[',
        STRING_AGG(
            CONCAT(
                CONVERT(NVARCHAR(MAX),
                    '{"path": "NB_FMD_LOAD_BRONZE_SILVER", "params": {'
                ),
                '"SourceSchema": ', '"', REPLACE(REPLACE(SourceSchema, '\', '\\'), '"', '\"'), '"',
                ',"SourceName": ' , '"', REPLACE(REPLACE(SourceName,  '\', '\\'), '"', '\"'), '"',
                ',"TargetSchema": ', '"', REPLACE(REPLACE(TargetSchema,'\', '\\'), '"', '\"'), '"',
                ',"TargetName": ' , '"', REPLACE(REPLACE(TargetName,  '\', '\\'), '"', '\"'), '"',
                ',"SourceFileType": ', '"', REPLACE(REPLACE(SourceFileType,'\', '\\'), '"', '\"'), '"',
                ',"TargetWareehouse": ', '"', LOWER(CONVERT(NVARCHAR(36), TargetWarehouseId)), '"',
                ',"SourceLakehouse": ', '"', LOWER(CONVERT(NVARCHAR(36), SourceLakehouseId)), '"',
                ',"TargetWorkspace": ', '"', LOWER(CONVERT(NVARCHAR(36), TargetWorkspaceId)), '"',
                ',"SourceWorkspace": ', '"', LOWER(CONVERT(NVARCHAR(36), SourceWorkspaceId)), '"',
                ',"TargetWarehouseName": ', '"', REPLACE(REPLACE(TargetWarehouseName,'\', '\\'), '"', '\"'), '"',
                ',"SourceLakehouseName": ', '"', REPLACE(REPLACE(SourceLakehouseName,'\', '\\'), '"', '\"'), '"',
                ',"BronzeLayerEntityId" : ', '"', LOWER(CONVERT(NVARCHAR(36), [BronzeLayerEntityId])), '"',
                ',"SilverLayerEntityId": ', '"', LOWER(CONVERT(NVARCHAR(36), EntityId)), '"',
                ',"DataSourceNamespace" : ', '"', LOWER(CONVERT(NVARCHAR(30), [DataSourceNamespace])), '"',
                ',"cleansing_rules" : ', '"', REPLACE(REPLACE([CleansingRules], '\', '\\'), '"', '\"'), '"',
                ',"layer_type": ', '"', CONVERT(NVARCHAR(36), LayerType), '"',
                ',"data_flow_id": ', '"', CONVERT(NVARCHAR(36), DataflowId), '"',
                ',"p_k_column": ', '"', CONVERT(NVARCHAR(36), PKColumn), '"',
                ',"MaxProcessedId": ', '"', LOWER(CONVERT(NVARCHAR(36), MaxProcessedId)), '"',
                ',"ProcessedDateTime": ', '"', CONVERT(VARCHAR(33), ProcessedDateTime, 126), '"',
                ',"MaxUnprocessedId": ', '"', LOWER(CONVERT(NVARCHAR(36), MaxUnprocessedId)), '"',
                ',"UnprocessedDateTime": ', '"', CONVERT(VARCHAR(33), UnprocessedDateTime, 126), '"',
                '}}'
            ),
            ','
        ) WITHIN GROUP (ORDER BY EntityId),
        ']'
    ) AS NotebookParams
    FROM [execution].[vw_LoadToSilverLayer]  WHERE SourceWorkspaceId = @WorkspaceId
END;

GO

