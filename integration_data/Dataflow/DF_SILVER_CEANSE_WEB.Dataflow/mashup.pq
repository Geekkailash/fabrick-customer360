[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[Description = "end_time"]
shared start_time = "" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
shared end_time = "2026-05-02T19:46:38.253" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "web_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "session_id", DestinationColumnName = "session_id"], [SourceColumnName = "customer_id", DestinationColumnName = "customer_id"], [SourceColumnName = "page_viewed", DestinationColumnName = "page_viewed"], [SourceColumnName = "session_time", DestinationColumnName = "session_time"], [SourceColumnName = "device_type", DestinationColumnName = "device_type"], [SourceColumnName = "year", DestinationColumnName = "year"], [SourceColumnName = "month", DestinationColumnName = "month"], [SourceColumnName = "day", DestinationColumnName = "day"], [SourceColumnName = "HashedPKColumn", DestinationColumnName = "HashedPKColumn"], [SourceColumnName = "HashedNonKeyColumns", DestinationColumnName = "HashedNonKeyColumns"], [SourceColumnName = "RecordLoadDate", DestinationColumnName = "RecordLoadDate"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared web = let
  StartTimeValue =
    if start_time = null or Text.Trim(Text.From(start_time)) = "" then
      #datetime(2000, 1, 1, 0, 0, 0)
    else
      DateTime.FromText(Text.From(start_time)),

  EndTimeValue =
    if end_time = null or Text.Trim(Text.From(end_time)) = "" then
      DateTime.LocalNow()
    else
      DateTime.FromText(Text.From(end_time)),

  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "71329364-5fc3-4b71-a75a-0b851ee4e3ba"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "web", ItemKind = "Table"]}[Data],
  #"Change type" = Table.TransformColumnTypes(#"Navigation 2", {{"session_id", type text}}),
  #"Change type 1" = Table.TransformColumnTypes(#"Change type", {{"customer_id", Int64.Type}, {"page_viewed", type text}}),
  #"Transform columns" = Table.TransformColumns(#"Change type 1", {{"session_time", each if _ = null or _ = "" then null
                else 
                    let
                        value = _,
                        try1 = try Date.FromText(value),
                        try2 = try Date.From(DateTime.FromText(value)),
                        try3 = try Date.From(Date.FromText(Text.Replace(value, "/", "-"))),
                        try4 = try 
                            if Text.Length(value) = 8 and Text.Select(value, {"0".."9"}) = value then
                                let
                                    y = Text.Start(value, 4),
                                    m = Text.Range(value, 4, 2),
                                    d = Text.End(value, 2)
                                in
                                    Date.FromText(y & "-" & m & "-" & d)
                            else
                                error "not 8 digit",
                        try5 = try 
                            if Text.Length(value) = 10 and Text.Range(value, 2, 1) = "-" and Text.Range(value, 5, 1) = "-" then
                                let
                                    d = Text.Start(value, 2),
                                    m = Text.Range(value, 3, 2),
                                    y = Text.End(value, 4)
                                in
                                    Date.FromText(y & "-" & m & "-" & d)
                            else
                                error "not dd-mm-yyyy",
                        result = 
                            if try1[HasError] = false then try1[Value]
                            else if try2[HasError] = false then try2[Value]
                            else if try3[HasError] = false then try3[Value]
                            else if try4[HasError] = false then try4[Value]
                            else if try5[HasError] = false then try5[Value]
                            else null
                    in
                        result, type nullable date}})
in
  #"Transform columns";
shared web_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  TableNavigation = Navigation_2{[Schema = "temp", Item = "web"]}[Data]
in
  TableNavigation;
