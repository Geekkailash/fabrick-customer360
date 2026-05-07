[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared start_time = "NULL" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
shared end_time = "2026-05-02T19:46:38.253" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type text];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "orders_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "order_id", DestinationColumnName = "order_id"], [SourceColumnName = "customer_id", DestinationColumnName = "customer_id"], [SourceColumnName = "order_date", DestinationColumnName = "order_date"], [SourceColumnName = "amount", DestinationColumnName = "amount"], [SourceColumnName = "status", DestinationColumnName = "status"], [SourceColumnName = "year", DestinationColumnName = "year"], [SourceColumnName = "month", DestinationColumnName = "month"], [SourceColumnName = "day", DestinationColumnName = "day"], [SourceColumnName = "HashedPKColumn", DestinationColumnName = "HashedPKColumn"], [SourceColumnName = "HashedNonKeyColumns", DestinationColumnName = "HashedNonKeyColumns"], [SourceColumnName = "RecordLoadDate", DestinationColumnName = "RecordLoadDate"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared orders = let
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
  #"Navigation 2" = #"Navigation 1"{[Id = "orders", ItemKind = "Table"]}[Data],

  #"Changed Type" =
    Table.TransformColumnTypes(
      #"Navigation 2",
      {
        {"order_id", type text},
        {"RecordLoadDate", type datetime}
      }
    ),
  Custom = Table.TransformColumns(#"Changed Type", {{"status", Text.Proper, type text}}),
  #"Transform columns" = Table.TransformColumns(Custom, {{"order_date", each let
                    v = _,
                    try1 = try Date.FromText(v),
                    try2 = try Date.From(DateTime.FromText(v)),
                    try3 = try Date.From(Date.FromText(Text.Replace(v, "/", "-"))),
                    try4 = try if Text.Length(v) = 8 and Text.Select(v, {"0".."9"}) = v then
                        let
                            y = Text.Start(v, 4),
                            m = Text.Range(v, 4, 2),
                            d = Text.End(v, 2)
                        in
                            Date.FromText(y & "-" & m & "-" & d)
                    else
                        null,
                    try5 = try if Text.Length(v) = 8 and Text.Select(v, {"0".."9"}) = v then
                        let
                            d = Text.Start(v, 2),
                            m = Text.Range(v, 2, 2),
                            y = Text.End(v, 4)
                        in
                            Date.FromText(y & "-" & m & "-" & d)
                    else
                        null,
                    try6 = try if Text.Contains(v, "/") and Text.Length(v) = 10 then
                        let
                            parts = Text.Split(v, "/"),
                            isDMY = Number.FromText(parts{0}) <= 31 and Number.FromText(parts{1}) <= 12,
                            dateVal = if isDMY then Date.FromText(parts{2} & "-" & parts{1} & "-" & parts{0}) else null
                        in
                            dateVal
                    else
                        null
                in
                    if try1[HasError] = false then try1[Value]
                    else if try2[HasError] = false then try2[Value]
                    else if try3[HasError] = false then try3[Value]
                    else if try4[HasError] = false then try4[Value]
                    else if try5[HasError] = false then try5[Value]
                    else if try6[HasError] = false then try6[Value]
                    else null, type date}}),
  #"Transform columns 1" = Table.TransformColumns(#"Transform columns", {{"amount", each try Number.FromText(_) otherwise null, type number}}),
  #"Change type" = Table.TransformColumnTypes(#"Transform columns 1", {{"order_id", Int64.Type}, {"customer_id", Int64.Type}})
in
  #"Change type";
shared orders_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false]),
  Navigation_1 = Pattern{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  TableNavigation = Navigation_2{[Schema = "temp", Item = "orders"]}[Data]
in
  TableNavigation;
