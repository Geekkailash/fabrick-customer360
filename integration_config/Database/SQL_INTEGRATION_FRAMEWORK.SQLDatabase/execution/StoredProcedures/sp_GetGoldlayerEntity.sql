--DROP PROCEDURE [execution].[sp_GetGoldlayerEntity]

--exec [execution].[sp_GetSilverlayerEntity] @workspaceId='2effab8c-7fe4-4bfd-b678-34e1fd29d8ab'
--drop  PROCEDURE [execution].[sp_GetGoldlayerEntity]
CREATE   PROCEDURE [execution].[sp_GetGoldlayerEntity]
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
                    '{"path": "NB_FMD_LOAD_GOLD", "params": {'
                ),
                '"GoldLayerEntityId": ', '"', LOWER(CONVERT(NVARCHAR(36), GoldLayerEntityId)), '"',
                ',"WarehouseId": ', '"', LOWER(CONVERT(NVARCHAR(36), WarehouseId)), '"',
                ',"GoldSchema": ', '"', CONVERT(NVARCHAR(36), GoldSchema), '"',
                ',"Name": ', '"', CONVERT(NVARCHAR(36), Name), '"',
                ',"PipelineGuid": ', '"', CONVERT(NVARCHAR(36), PipelineGuid), '"',
                '}}'
            ),
            ','
        ) WITHIN GROUP (ORDER BY GoldLayerEntityId),
        ']'
    ) AS NotebookParams
    FROM [integration].[GoldLayerEntity]  WHERE isActive=1
END;

GO

