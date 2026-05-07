[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"silver customer" = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "silver", Item = "customer"]}[Data],
  #"Merged queries" = Table.NestedJoin(#"Navigation 2", {"customer_id"}, #"silver orders", {"customer_id"}, "silver orders", JoinKind.LeftOuter),
  #"Removed columns" = Table.RemoveColumns(#"Merged queries", {"last_modified", "month", "year", "day"}),
  #"Expanded silver orders" = Table.ExpandTableColumn(#"Removed columns", "silver orders", {"order_id", "customer_id", "order_date", "amount", "status"}, {"order_id", "customer_id.1", "order_date", "amount", "status"}),
  #"Merged queries 1" = Table.NestedJoin(#"Expanded silver orders", {"customer_id"}, #"silver payments", {"customer_id"}, "silver payments", JoinKind.LeftOuter),
  #"Expanded silver payments" = Table.ExpandTableColumn(#"Merged queries 1", "silver payments", {"payment_id", "customer_id", "payment_date", "payment_method", "payment_status", "amount"}, {"payment_id", "customer_id.2", "payment_date", "payment_method", "payment_status", "amount.1"})
in
  #"Expanded silver payments";
shared #"silver orders" = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "silver", Item = "orders"]}[Data]
in
  #"Navigation 2";
shared #"silver payments" = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "silver", Item = "payments"]}[Data]
in
  #"Navigation 2";
shared #"silver support" = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "silver", Item = "support"]}[Data]
in
  #"Navigation 2";
shared #"silver web" = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "silver", Item = "web"]}[Data]
in
  #"Navigation 2";
shared Merge = let
  Source = Table.NestedJoin(#"silver customer", {"customer_id"}, #"silver support", {"customer_id"}, "silver support", JoinKind.LeftOuter),
  #"Expanded silver support" = Table.ExpandTableColumn(Source, "silver support", {"ticket_id", "customer_id", "issue_type", "ticket_date", "resolution_status"}, {"ticket_id", "customer_id.3", "issue_type", "ticket_date", "resolution_status"})
in
  #"Expanded silver support";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Merge (2)_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "customer_id", DestinationColumnName = "customer_id"], [SourceColumnName = "name", DestinationColumnName = "name"], [SourceColumnName = "gender", DestinationColumnName = "gender"], [SourceColumnName = "email", DestinationColumnName = "email"], [SourceColumnName = "dob", DestinationColumnName = "dob"], [SourceColumnName = "location", DestinationColumnName = "location"], [SourceColumnName = "order_id", DestinationColumnName = "order_id"], [SourceColumnName = "customer_id.1", DestinationColumnName = "customer_id.1"], [SourceColumnName = "order_date", DestinationColumnName = "order_date"], [SourceColumnName = "amount", DestinationColumnName = "amount"], [SourceColumnName = "status", DestinationColumnName = "status"], [SourceColumnName = "payment_id", DestinationColumnName = "payment_id"], [SourceColumnName = "customer_id.2", DestinationColumnName = "customer_id.2"], [SourceColumnName = "payment_date", DestinationColumnName = "payment_date"], [SourceColumnName = "payment_method", DestinationColumnName = "payment_method"], [SourceColumnName = "payment_status", DestinationColumnName = "payment_status"], [SourceColumnName = "amount.1", DestinationColumnName = "amount.1"], [SourceColumnName = "ticket_id", DestinationColumnName = "ticket_id"], [SourceColumnName = "customer_id.3", DestinationColumnName = "customer_id.3"], [SourceColumnName = "issue_type", DestinationColumnName = "issue_type"], [SourceColumnName = "ticket_date", DestinationColumnName = "ticket_date"], [SourceColumnName = "resolution_status", DestinationColumnName = "resolution_status"], [SourceColumnName = "session_id", DestinationColumnName = "session_id"], [SourceColumnName = "customer_id.4", DestinationColumnName = "customer_id.4"], [SourceColumnName = "page_viewed", DestinationColumnName = "page_viewed"], [SourceColumnName = "session_time", DestinationColumnName = "session_time"], [SourceColumnName = "device_type", DestinationColumnName = "device_type"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"Merge (2)" = let
  Source = Table.NestedJoin(Merge, {"customer_id"}, #"silver web", {"customer_id"}, "silver web", JoinKind.LeftOuter),
  #"Expanded silver web" = Table.ExpandTableColumn(Source, "silver web", {"session_id", "customer_id", "page_viewed", "session_time", "device_type"}, {"session_id", "customer_id.4", "page_viewed", "session_time", "device_type"})
in
  #"Expanded silver web";
shared #"Merge (2)_DataDestination" = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "2effab8c-7fe4-4bfd-b678-34e1fd29d8ab"]}[Data],
  Navigation_2 = Navigation_1{[warehouseId = "4a2ecce9-6539-4d54-91bf-38ab15bfdb35"]}[Data],
  TableNavigation = Navigation_2{[Schema = "gold", Item = "customer360"]}[Data]
in
  TableNavigation;
