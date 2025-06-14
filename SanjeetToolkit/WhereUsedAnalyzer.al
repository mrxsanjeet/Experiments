// // Clean placeholder for WhereUsedAnalyzer
// // The actual implementation is in WhereUsedAnalyzer_Fixed.al
// page 60006 "Sanjeet Where Used Analyzers"
// {
//     PageType = Card;
//     Caption = 'Where Used Analyzer - OLD VERSION (PLACEHOLDER)';
//     ApplicationArea = All;

//     layout
//     {
//         area(Content)
//         {
//             group(General)
//             {
//                 field(Message; 'This page has been replaced. Use WhereUsedAnalyzer_Fixed.al for the actual implementation.')
//                 {
//                     ApplicationArea = All;
//                     Editable = false;
//                 }
//             }
//         }
//     }
// }
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Search Type';
//                     ToolTip = 'Select what type of object to search for';

//                     trigger OnValidate()
//                     begin
//                         ClearSearchResults();
//                         UpdateSearchFields();
//                     end;
//                 }

//                 field(ObjectType; ObjectType)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Object Type';
//                     ToolTip = 'Type of object to analyze';
//                     Visible = SearchType = SearchType::Object;

//                     trigger OnValidate()
//                     begin
//                         ClearSearchResults();
//                     end;
//                 }

//                 field(ObjectID; ObjectID)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Object ID';
//                     ToolTip = 'ID of the object to analyze';
//                     Visible = SearchType = SearchType::Object;

//                     trigger OnValidate()
//                     begin
//                         ClearSearchResults();
//                         if ObjectID <> 0 then
//                             GetObjectName();
//                     end;
//                 }

//                 field(ObjectName; ObjectName)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Object Name';
//                     ToolTip = 'Name of the object being analyzed';
//                     Editable = false;
//                     Visible = SearchType = SearchType::Object;
//                 }

//                 field(TableID; TableID)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Table ID';
//                     ToolTip = 'ID of the table containing the field';
//                     Visible = SearchType = SearchType::Field;

//                     trigger OnValidate()
//                     begin
//                         ClearSearchResults();
//                         if TableID <> 0 then
//                             GetTableName();
//                     end;
//                 }

//                 field(TableName; TableName)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Table Name';
//                     ToolTip = 'Name of the table containing the field';
//                     Editable = false;
//                     Visible = SearchType = SearchType::Field;
//                 }

//                 field(FieldID; FieldID)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Field ID';
//                     ToolTip = 'ID of the field to analyze';
//                     Visible = SearchType = SearchType::Field;

//                     trigger OnValidate()
//                     begin
//                         ClearSearchResults();
//                         if (TableID <> 0) and (FieldID <> 0) then
//                             GetFieldName();
//                     end;
//                 }

//                 field(FieldName; FieldName)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Field Name';
//                     ToolTip = 'Name of the field being analyzed';
//                     Editable = false;
//                     Visible = SearchType = SearchType::Field;
//                 }

//                 field(ProcedureName; ProcedureName)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Procedure Name';
//                     ToolTip = 'Name of the procedure to search for';
//                     Visible = SearchType = SearchType::Procedure;

//                     trigger OnValidate()
//     begin
//         ClearSearchResults();
//     end;
// }

//                 field(SearchScope; SearchScope)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Search Scope';
//                     ToolTip = 'Scope of the where-used search';

//                     trigger OnValidate()
//                     begin
//                         ClearSearchResults();
//                     end;
//                 }
//             }

//             group("Analysis Summary")
//             {
//                 Caption = 'Analysis Summary';
//                 Visible = ShowSummary;

//                 field(TotalReferences; TotalReferences)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Total References';
//                     Editable = false;
//                     Style = Strong;
//                     ToolTip = 'Total number of references found';
//                 }

//                 field(ObjectsAffected; ObjectsAffected)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Objects Affected';
//                     Editable = false;
//                     Style = Attention;
//                     ToolTip = 'Number of objects that reference this item';
//                 }

//                 field(RiskLevel; RiskLevel)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Impact Risk';
//                     Editable = false;
//                     StyleExpr = RiskLevelStyle;
//                     ToolTip = 'Risk level for changes to this item';
//                 }

//                 field(LastAnalyzed; LastAnalyzed)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Last Analyzed';
//                     Editable = false;
//                     ToolTip = 'When this analysis was last performed';
//                 }
//             }

//             repeater(References)
//             {
//                 Caption = 'Where Used References';

//                 field(ID; Rec.ID)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Reference #';
//                     ToolTip = 'Reference number';
//                     Style = Strong;
//                 }

//                 field(Name; Rec.Name)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Found In';
//                     ToolTip = 'Object where the reference was found';
//                     Style = Favorable;
//                 }

//                 field(Value; Rec.Value)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Reference Details';
//                     ToolTip = 'Details about how the item is referenced';
//                 }

//                 field(ReferenceType; GetReferenceType())
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Reference Type';
//                     Editable = false;
//                     ToolTip = 'Type of reference (Direct, Indirect, etc.)';
//                     StyleExpr = GetReferenceTypeStyle();
//                 }

//                 field(ObjectTypeRef; GetObjectTypeFromReference())
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Object Type';
//                     Editable = false;
//                     ToolTip = 'Type of object containing the reference';
//                 }

//                 field(ImpactLevel; GetImpactLevel())
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Impact Level';
//                     Editable = false;
//                     ToolTip = 'Potential impact level of changes';
//                     StyleExpr = GetImpactLevelStyle();
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             group("Analysis")
//             {
//                 Caption = 'Where Used Analysis';

//                 action(PerformAnalysis)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Analyze Where Used';
//                     ToolTip = 'Perform where-used analysis for the specified item';
//                     Image = Find;
//                     Promoted = true;
//                     PromotedCategory = Process;

//                     trigger OnAction()
//                     begin
//                         PerformWhereUsedAnalysis();
//                     end;
//                 }

//                 action(RefreshAnalysis)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Refresh Analysis';
//                     ToolTip = 'Refresh the current where-used analysis';
//                     Image = Refresh;

//                     trigger OnAction()
//                     begin
//                         if ValidateSearchCriteria() then
//                             PerformWhereUsedAnalysis();
//                     end;
//                 }

//                 action(ClearResults)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Clear Results';
//                     ToolTip = 'Clear current analysis results';
//                     Image = ClearFilter;

//                     trigger OnAction()
//                     begin
//                         ClearSearchResults();
//                         CurrPage.Update();
//                     end;
//                 }
//             }

//             group("Navigation")
//             {
//                 Caption = 'Navigation';

//                 action(OpenReferencedObject)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Open Object';
//                     ToolTip = 'Open the object containing this reference';
//                     Image = Navigate;

//                     trigger OnAction()
//                     begin
//                         OpenReferencedObjectProc();
//                     end;
//                 }

//                 action(ShowObjectDetails)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Object Details';
//                     ToolTip = 'Show detailed information about the referenced object';
//                     Image = Info;

//                     trigger OnAction()
//                     begin
//                         ShowObjectDetailsProc();
//                     end;
//                 }
//             }

//             group("Export")
//             {
//                 Caption = 'Export & Reports';

//                 action(ExportAnalysis)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Export Analysis';
//                     ToolTip = 'Export where-used analysis to Excel';
//                     Image = Export;

//                     trigger OnAction()
//                     begin
//                         ExportWhereUsedAnalysis();
//                     end;
//                 }

//                 action(GenerateImpactReport)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Impact Report';
//                     ToolTip = 'Generate detailed impact analysis report';
//                     Image = Report;

//                     trigger OnAction()
//                     var
//                         ReportMsg: Text;
//                     begin
//                         ReportMsg := GenerateImpactReportText();
//                         Message(ReportMsg);
//                     end;
//                 }

//                 local procedure GenerateImpactReportText() ReportText: Text
//                 begin
//                     ReportText := StrSubstNo('IMPACT ANALYSIS REPORT\n\n🎯 ANALYSIS TARGET:\n');
                    
//                     case SearchType of
//                         SearchType::Object:
//                             ReportText += StrSubstNo('Object: %1 %2 (%3)\n', ObjectType, ObjectID, ObjectName);
//                         SearchType::Field:
//                             ReportText += StrSubstNo('Field: Table %1.%2 (%3.%4)\n', TableID, FieldID, TableName, FieldName);
//                         SearchType::Procedure:
//                             ReportText += StrSubstNo('Procedure: %1\n', ProcedureName);
//                     end;
                    
//                     ReportText += StrSubstNo('\n📊 IMPACT SUMMARY:\n- Total References: %1\n- Objects Affected: %2\n- Risk Level: %3\n- Last Analyzed: %4',
//                         TotalReferences, ObjectsAffected, RiskLevel, LastAnalyzed);
//                 end;
//             }

//             group("View Options")
//             {
//                 Caption = 'View Options';

//                 action(ToggleSearchPanel)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Toggle Search Panel';
//                     ToolTip = 'Show/hide search criteria panel';
//                     Image = View;

//                     trigger OnAction()
//                     begin
//                         ShowSearchPanel := not ShowSearchPanel;
//                         CurrPage.Update();
//                     end;
//                 }

//                 action(ToggleSummary)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Toggle Summary';
//                     ToolTip = 'Show/hide analysis summary';
//                     Image = Statistics;

//                     trigger OnAction()
//                     begin
//                         ShowSummary := not ShowSummary;
//                         CurrPage.Update();
//                     end;
//                 }
//             }
//         }
//     }

//     var
//         // Search Criteria
//         SearchType: Option Object,Field,Procedure;
//         ObjectType: Option Table,Page,Report,Codeunit,Query,XMLport,MenuSuite,ControlAddIn,PageExtension,TableExtension,Profile,PageCustomization,Entitlement,PermissionSet,PermissionSetExtension,ReportExtension,Enum,EnumExtension,Interface;
//         ObjectID: Integer;
//         ObjectName: Text[100];
//         TableID: Integer;
//         TableName: Text[100];
//         FieldID: Integer;
//         FieldName: Text[100];
//         ProcedureName: Text[100];
//         SearchScope: Option "Current Extension","All Extensions","System Objects","All Objects";

//         // Analysis Results
//         TotalReferences: Integer;
//         ObjectsAffected: Integer;
//         RiskLevel: Text[20];
//         RiskLevelStyle: Text;
//         LastAnalyzed: DateTime;

//         // UI Control
//         ShowSearchPanel: Boolean;
//         ShowSummary: Boolean;

//     trigger OnOpenPage()
//     begin
//         ShowSearchPanel := true;
//         ShowSummary := true;
//         SearchType := SearchType::Object;
//         SearchScope := SearchScope::"All Objects";
//         UpdateSearchFields();
//     end;

//     local procedure UpdateSearchFields()
//     begin
//         // Clear previous search data when search type changes
//         ObjectID := 0;
//         ObjectName := '';
//         TableID := 0;
//         TableName := '';
//         FieldID := 0;
//         FieldName := '';
//         ProcedureName := '';
//         CurrPage.Update();
//     end;

//     local procedure ValidateSearchCriteria(): Boolean
//     begin
//         case SearchType of
//             SearchType::Object:
//                 begin
//                     if ObjectID = 0 then begin
//                         Message('Please specify an Object ID to analyze.');
//                         exit(false);
//                     end;
//                 end;
//             SearchType::Field:
//                 begin
//                     if (TableID = 0) or (FieldID = 0) then begin
//                         Message('Please specify both Table ID and Field ID to analyze.');
//                         exit(false);
//                     end;
//                 end;
//             SearchType::Procedure:
//                 begin
//                     if ProcedureName = '' then begin
//                         Message('Please specify a Procedure Name to analyze.');
//                         exit(false);
//                     end;
//                 end;
//         end;
//         exit(true);
//     end;

//     local procedure GetObjectName()
//     var
//         AllObjWithCaption: Record AllObjWithCaption;
//     begin
//         ObjectName := '';
//         AllObjWithCaption.Reset();
//         AllObjWithCaption.SetRange("Object Type", ObjectType);
//         AllObjWithCaption.SetRange("Object ID", ObjectID);
//         if AllObjWithCaption.FindFirst() then
//             ObjectName := AllObjWithCaption."Object Name"
//         else
//             ObjectName := 'Object not found';
//     end;

//     local procedure GetTableName()
//     var
//         AllObjWithCaption: Record AllObjWithCaption;
//     begin
//         TableName := '';
//         AllObjWithCaption.Reset();
//         AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
//         AllObjWithCaption.SetRange("Object ID", TableID);
//         if AllObjWithCaption.FindFirst() then
//             TableName := AllObjWithCaption."Object Name"
//         else
//             TableName := 'Table not found';
//     end;

//     local procedure GetFieldName()
//     var
//         FieldRec: Record Field;
//     begin
//         FieldName := '';
//         FieldRec.Reset();
//         FieldRec.SetRange(TableNo, TableID);
//         FieldRec.SetRange("No.", FieldID);
//         if FieldRec.FindFirst() then
//             FieldName := FieldRec.FieldName
//         else
//             FieldName := 'Field not found';
//     end;

//     local procedure ClearSearchResults()
//     begin
//         Rec.Reset();
//         Rec.DeleteAll();
//         TotalReferences := 0;
//         ObjectsAffected := 0;
//         RiskLevel := '';
//         RiskLevelStyle := '';
//         LastAnalyzed := 0DT;
//         ShowSummary := false;
//         if Rec.FindFirst() then;
//     end;

//     local procedure PerformWhereUsedAnalysis()
//     begin
//         if not ValidateSearchCriteria() then
//             exit;

//         ClearSearchResults();

//         case SearchType of
//             SearchType::Object:
//                 AnalyzeObjectUsage();
//             SearchType::Field:
//                 AnalyzeFieldUsage();
//             SearchType::Procedure:
//                 AnalyzeProcedureUsage();
//         end;

//         CalculateAnalysisSummary();
//         ShowSummary := true;
//         LastAnalyzed := CurrentDateTime;
//         CurrPage.Update();

//         Message('Where-used analysis completed.\nTotal References: %1\nObjects Affected: %2\nRisk Level: %3',
//             TotalReferences, ObjectsAffected, RiskLevel);
//     end;

//     local procedure AnalyzeObjectUsage()
//     var
//         AllObjWithCaption: Record AllObjWithCaption;
//         RefCount: Integer;
//     begin
//         RefCount := 0;

//         // Analyze table usage in pages, reports, and codeunits
//         if ObjectType = ObjectType::Table then
//             AnalyzeTableUsage(RefCount);

//         // Analyze page usage in actions, codeunits
//         if ObjectType = ObjectType::Page then
//             AnalyzePageUsage(RefCount);

//         // Analyze codeunit usage in other objects
//         if ObjectType = ObjectType::Codeunit then
//             AnalyzeCodeunitUsage(RefCount);

//         // Analyze report usage
//         if ObjectType = ObjectType::Report then
//             AnalyzeReportUsage(RefCount);

//         // Add extension analysis
//         AnalyzeExtensionUsage(RefCount);

//         TotalReferences := RefCount;
//     end;

//     local procedure AnalyzeTableUsage(var RefCount: Integer)
//     var
//         AllObjWithCaption: Record AllObjWithCaption;
//         FieldRec: Record Field;
//         TableRelationRec: Record "Table Relations Metadata";
//     begin
//         // Find pages using this table as source
//         AllObjWithCaption.Reset();
//         AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Page);
//         if AllObjWithCaption.FindSet() then
//             repeat
//                 // Simulate page source table analysis
//                 if Random(10) > 7 then begin // Simplified simulation
//                     AddReference(RefCount,
//                         StrSubstNo('Page %1 (%2)', AllObjWithCaption."Object ID", AllObjWithCaption."Object Name"),
//                         'Source Table',
//                         'Direct');
//                 end;
//             until AllObjWithCaption.Next() = 0;
//     end;

//     local procedure AnalyzePageUsage(var RefCount: Integer)
//     var
//         AllObjWithCaption: Record AllObjWithCaption;
//     begin
//         // Find references to this page in other objects
//         AllObjWithCaption.Reset();
//         AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Codeunit);
//         if AllObjWithCaption.FindSet() then
//             repeat
//                 // Simulate codeunit using this page
//                 if Random(10) > 8 then begin
//                     AddReference(RefCount,
//                         StrSubstNo('Codeunit %1 (%2)', AllObjWithCaption."Object ID", AllObjWithCaption."Object Name"),
//                         'Page Reference',
//                         'Indirect');
//                 end;
//             until AllObjWithCaption.Next() = 0;
//     end;

//     local procedure AnalyzeCodeunitUsage(var RefCount: Integer)
//     var
//         AllObjWithCaption: Record AllObjWithCaption;
//     begin
//         // Find references to this codeunit in other objects
//         AllObjWithCaption.Reset();
//         AllObjWithCaption.SetFilter("Object Type", '%1|%2|%3',
//             AllObjWithCaption."Object Type"::Codeunit,
//             AllObjWithCaption."Object Type"::Page,
//             AllObjWithCaption."Object Type"::Report);
//         if AllObjWithCaption.FindSet() then
//             repeat
//                 // Simulate objects using this codeunit
//                 if Random(10) > 7 then begin
//                     AddReference(RefCount,
//                         StrSubstNo('%1 %2 (%3)',
//                             Format(AllObjWithCaption."Object Type"),
//                             AllObjWithCaption."Object ID",
//                             AllObjWithCaption."Object Name"),
//                         'Codeunit Call',
//                         'Direct');
//                 end;
//             until AllObjWithCaption.Next() = 0;
//     end;

//     local procedure AnalyzeReportUsage(var RefCount: Integer)
//     var
//         AllObjWithCaption: Record AllObjWithCaption;
//     begin
//         // Find references to this report in other objects
//         AllObjWithCaption.Reset();
//         AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Page);
//         if AllObjWithCaption.FindSet() then
//             repeat
//                 // Simulate pages using this report
//                 if Random(10) > 8 then begin
//                     AddReference(RefCount,
//                         StrSubstNo('Page %1 (%2)', AllObjWithCaption."Object ID", AllObjWithCaption."Object Name"),
//                         'Report Action',
//                         'Direct');
//                 end;
//             until AllObjWithCaption.Next() = 0;
//     end;

//     local procedure AnalyzeExtensionUsage(var RefCount: Integer)
//     var
//         AllObjWithCaption: Record AllObjWithCaption;
//     begin
//         // Find extensions related to this object
//         if Random(10) > 5 then begin
//             AddReference(RefCount,
//                 'Extension Objects',
//                 'Various extension points',
//                 'Indirect');
//         end;
//     end;

//     local procedure AnalyzeFieldUsage(var RefCount: Integer)
//     begin
//         // Placeholder for field usage analysis
//         AddReference(RefCount, 'Field Usage Analysis', 'Field references found', 'Various');
//         RefCount += 1;
//     end;

//     local procedure AnalyzeProcedureUsage(var RefCount: Integer)
//     begin
//         // Placeholder for procedure usage analysis
//         AddReference(RefCount, 'Procedure Usage Analysis', 'Procedure calls found', 'Various');
//         RefCount += 1;
//     end;

//     local procedure AddReference(var RefCount: Integer; ObjectName: Text; ReferenceDetails: Text; ReferenceType: Text)
//     begin
//         RefCount += 1;
//         Rec.Init();
//         Rec.ID := RefCount;
//         Rec.Name := CopyStr(ObjectName, 1, MaxStrLen(Rec.Name));
//         Rec.Value := CopyStr(ReferenceDetails, 1, MaxStrLen(Rec.Value));
//         Rec."Reference Type" := CopyStr(ReferenceType, 1, MaxStrLen(Rec."Reference Type"));
//         Rec.Insert();
//     end;

//     local procedure CalculateAnalysisSummary()
//     var
//         RefCount: Integer;
//         ObjCount: Integer;
//     begin
//         Rec.Reset();
//         RefCount := Rec.Count;
        
//         // Count unique objects (simplified)
//         ObjCount := RefCount;
//         if ObjCount > 5 then
//             ObjCount := 5;
            
//         TotalReferences := RefCount;
//         ObjectsAffected := ObjCount;
        
//         // Set risk level based on reference count
//         if RefCount > 20 then begin
//             RiskLevel := 'High';
//             RiskLevelStyle := 'Unfavorable';
//         end else if RefCount > 10 then begin
//             RiskLevel := 'Medium';
//             RiskLevelStyle := 'Ambiguous';
//         end else begin
//             RiskLevel := 'Low';
//             RiskLevelStyle := 'Favorable';
//         end;
//     end;

//     local procedure GetReferenceType() RefType: Text
//     begin
//         RefType := Rec."Reference Type";
//         if RefType = '' then
//             RefType := 'Unknown';
//     end;

//     local procedure GetReferenceTypeStyle() StyleText: Text
//     begin
//         case Rec."Reference Type" of
//             'Direct':
//                 StyleText := 'Attention';
//             'Indirect':
//                 StyleText := 'Standard';
//             else
//                 StyleText := 'Subordinate';
//         end;
//     end;

//     local procedure GetObjectTypeFromReference() ObjType: Text
//     var
//         Parts: List of [Text];
//         FirstPart: Text;
//     begin
//         // Extract object type from reference name (simplified)
//         if StrPos(Rec.Name, ' ') > 0 then begin
//             FirstPart := SelectStr(1, Rec.Name);
//             if FirstPart in ['Table', 'Page', 'Report', 'Codeunit', 'Query', 'XMLport'] then
//                 ObjType := FirstPart
//             else
//                 ObjType := 'Other';
//         end else
//             ObjType := 'Unknown';
//     end;

//     local procedure GetImpactLevel() ImpactText: Text
//     begin
//         case Rec."Reference Type" of
//             'Direct':
//                 ImpactText := 'High';
//             'Indirect':
//                 ImpactText := 'Medium';
//             else
//                 ImpactText := 'Low';
//         end;
//     end;

//     local procedure GetImpactLevelStyle() StyleText: Text
//     var
//         ImpactLevel: Text;
//     begin
//         ImpactLevel := GetImpactLevel();
//         case ImpactLevel of
//             'High':
//                 StyleText := 'Unfavorable';
//             'Medium':
//                 StyleText := 'Ambiguous';
//             else
//                 StyleText := 'Favorable';
//         end;
//     end;

//     local procedure OpenReferencedObjectProc()
//     begin
//         Message('Opening referenced object: %1', Rec.Name);
//         // Actual implementation would open the object
//     end;

//     local procedure ShowObjectDetailsProc()
//     begin
//         Message('Object Details for %1:\n%2', Rec.Name, Rec.Value);
//         // Actual implementation would show detailed information
//     end;

//     local procedure ExportWhereUsedAnalysis()
//     begin
//         Message('Exporting analysis to Excel...');
//         // Actual implementation would export to Excel
//     end;

//     local procedure GenerateImpactAnalysisReport()
//     var
//         ReportMsg: Text;
//     begin
//         ReportMsg := StrSubstNo('IMPACT ANALYSIS REPORT\n\n🎯 ANALYSIS TARGET:\n');

//         case SearchType of
//             SearchType::Object:
//                 ReportMsg += StrSubstNo('Object: %1 %2 (%3)\n', ObjectType, ObjectID, ObjectName);
//             SearchType::Field:
//                 ReportMsg += StrSubstNo('Field: Table %1.%2 (%3.%4)\n', TableID, FieldID, TableName, FieldName);
//             SearchType::Procedure:
//                 ReportMsg += StrSubstNo('Procedure: %1\n', ProcedureName);
//         end;

//         ReportMsg += StrSubstNo('\n📊 IMPACT SUMMARY:\n- Total References: %1\n- Objects Affected: %2\n- Risk Level: %3\n- Last Analyzed: %4',
//             TotalReferences, ObjectsAffected, RiskLevel, LastAnalyzed);
            
//         Message(ReportMsg);
//     end;

//     procedure SetSearchCriteria(NewSearchType: Option; NewObjectType: Option; NewObjectID: Integer; NewTableID: Integer; NewFieldID: Integer; NewProcedureName: Text[100])
//     begin
//         SearchType := NewSearchType;
//         ObjectType := NewObjectType;
//         ObjectID := NewObjectID;
//         TableID := NewTableID;
//         FieldID := NewFieldID;
//         ProcedureName := NewProcedureName;

//         // Auto-populate names
//         if (SearchType = SearchType::Object) and (ObjectID <> 0) then
//             GetObjectName();
//         if (SearchType = SearchType::Field) and (TableID <> 0) then begin
//             GetTableName();
//             if FieldID <> 0 then
//                 GetFieldName();
//         end;

//         UpdateSearchFields();
//     end;
// }




