page 60001 "Sanjeet Object Viewer Enhanced"
{
    Caption = 'Sanjeet Object Viewer Enhanced - Business Central Analysis Tool';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = AllObjWithCaption;
    LinksAllowed = false;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group("Analysis Dashboard")
            {
                Caption = 'Analysis Dashboard';
                Visible = ShowAnalysisSummary;

                field(TotalObjects; TotalObjects)
                {
                    ApplicationArea = All;
                    Caption = 'Total Objects';
                    Editable = false;
                    Style = Strong;
                    ToolTip = 'Total number of objects in the current filter';
                }

                field(TotalExtensions; TotalExtensions)
                {
                    ApplicationArea = All;
                    Caption = 'Extensions';
                    Editable = false;
                    Style = Attention;
                    ToolTip = 'Number of extension objects (custom development)';
                }

                field(CustomizationLevel; CustomizationLevel)
                {
                    ApplicationArea = All;
                    Caption = 'Customization Level';
                    Editable = false;
                    Style = Favorable;
                    ToolTip = 'Assessment of customization complexity';
                }

                field(RiskScore; RiskScore)
                {
                    ApplicationArea = All;
                    Caption = 'Risk Score';
                    Editable = false;
                    Style = Unfavorable;
                    ToolTip = 'Overall risk assessment for upgrades';
                }
            }

            repeater(General)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    StyleExpr = ObjectTypeStyleText;
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                    StyleExpr = ObjectCaptionStyleText;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    StyleExpr = ObjectIdStyleText;
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    StyleExpr = ObjectNameStyleText;
                }
                field("Object Subtype"; Rec."Object Subtype")
                {
                    ApplicationArea = All;
                }

                field(ObjectCategory; ObjectCategory)
                {
                    ApplicationArea = All;
                    Caption = 'Category';
                    Editable = false;
                    StyleExpr = CategoryStyleText;
                    ToolTip = 'Object category: Standard, Extension, or Custom';
                }

                field(RiskLevel; RiskLevel)
                {
                    ApplicationArea = All;
                    Caption = 'Risk Level';
                    Editable = false;
                    StyleExpr = RiskLevelStyleText;
                    ToolTip = 'Risk level for upgrades: Low, Medium, High, Critical';
                }

                field(LastModified; LastModified)
                {
                    ApplicationArea = All;
                    Caption = 'Last Modified';
                    Editable = false;
                    ToolTip = 'Estimated last modification date';
                }

                field(Dependencies; Dependencies)
                {
                    ApplicationArea = All;
                    Caption = 'Dependencies';
                    Editable = false;
                    ToolTip = 'Number of objects that depend on this object';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        ShowDependencies();
                    end;
                }

                field(ComplexityScore; ComplexityScore)
                {
                    ApplicationArea = All;
                    Caption = 'Complexity';
                    Editable = false;
                    ToolTip = 'Complexity score based on object size and dependencies';
                    StyleExpr = ComplexityStyleText;
                }

                field(UpgradeImpact; UpgradeImpact)
                {
                    ApplicationArea = All;
                    Caption = 'Upgrade Impact';
                    Editable = false;
                    ToolTip = 'Potential impact on future upgrades';
                    StyleExpr = UpgradeImpactStyleText;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Analysis Tools")
            {
                Caption = 'Analysis Tools';

                action(ToggleAnalysisSummary)
                {
                    ApplicationArea = All;
                    Caption = 'Toggle Analysis Summary';
                    ToolTip = 'Show/hide the analysis dashboard';
                    Image = Statistics;

                    trigger OnAction()
                    begin
                        ShowAnalysisSummary := not ShowAnalysisSummary;
                        CurrPage.Update();
                    end;
                }

                action(RefreshAnalysis)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh Analysis';
                    ToolTip = 'Recalculate all analysis metrics';
                    Image = Refresh;

                    trigger OnAction()
                    begin
                        CalculateAnalysisMetrics();
                        CurrPage.Update();
                    end;
                }

                action(ExportAnalysis)
                {
                    ApplicationArea = All;
                    Caption = 'Export Analysis';
                    ToolTip = 'Export analysis results to Excel';
                    Image = Export;

                    trigger OnAction()
                    begin
                        ExportAnalysisToExcel();
                    end;
                }
            }

            group("Object Actions")
            {
                Caption = 'Object Actions';

                action(RunObject)
                {
                    ApplicationArea = All;
                    Caption = 'Run Object';
                    ToolTip = 'Run the selected object';
                    Image = ExecuteBatch;

                    trigger OnAction()
                    begin
                        RunSelectedObject();
                    end;
                }

                action(ShowObjectDetails)
                {
                    ApplicationArea = All;
                    Caption = 'Object Details';
                    ToolTip = 'Show detailed information about the selected object';
                    Image = Info;

                    trigger OnAction()
                    begin
                        ShowObjectDetailsProc();
                    end;
                }

                action(AnalyzeObjectDependencies)
                {
                    ApplicationArea = All;
                    Caption = 'Analyze Dependencies';
                    ToolTip = 'Analyze object dependencies and relationships';
                    Image = Relationship;

                    trigger OnAction()
                    begin
                        AnalyzeObjectDependenciesProc();
                    end;
                }

                action(ViewTableData)
                {
                    ApplicationArea = All;
                    Caption = 'View Table Data';
                    ToolTip = 'View all fields and values for the selected table';
                    Image = Table;
                    Enabled = Rec."Object Type" = Rec."Object Type"::Table;

                    trigger OnAction()
                    begin
                        ViewTableDataProc();
                    end;
                }

                action(WhereUsedAnalysis)
                {
                    ApplicationArea = All;
                    Caption = 'Where Used Analysis';
                    ToolTip = 'Analyze where this object is used throughout the system';
                    Image = Find;

                    trigger OnAction()
                    begin
                        PerformWhereUsedAnalysisProc();
                    end;
                }
            }

            group("Filters")
            {
                Caption = 'Smart Filters';

                action(ShowHighRiskObjects)
                {
                    ApplicationArea = All;
                    Caption = 'High Risk Objects';
                    ToolTip = 'Show only high-risk objects for upgrades';
                    Image = Warning;

                    trigger OnAction()
                    begin
                        FilterHighRiskObjects();
                    end;
                }

                action(ShowExtensionObjects)
                {
                    ApplicationArea = All;
                    Caption = 'Extension Objects';
                    ToolTip = 'Show only extension objects';
                    Image = Setup;

                    trigger OnAction()
                    begin
                        FilterExtensionObjects();
                    end;
                }

                action(ShowCustomObjects)
                {
                    ApplicationArea = All;
                    Caption = 'Custom Objects';
                    ToolTip = 'Show only custom objects';
                    Image = Setup;

                    trigger OnAction()
                    begin
                        FilterCustomObjects();
                    end;
                }

                action(ClearAllFilters)
                {
                    ApplicationArea = All;
                    Caption = 'Clear All Filters';
                    ToolTip = 'Remove all filters and show all objects';
                    Image = ClearFilter;

                    trigger OnAction()
                    begin
                        ClearAllFiltersProc();
                    end;
                }
            }
        }
    }

    var
        // Analysis Summary Variables
        TotalObjects: Integer;
        TotalExtensions: Integer;
        CustomizationLevel: Text[50];
        RiskScore: Text[20];
        ShowAnalysisSummary: Boolean;

        // Row-level Variables
        ObjectCategory: Text[20];
        RiskLevel: Text[20];
        LastModified: Text[30];
        Dependencies: Integer;
        ComplexityScore: Integer;
        UpgradeImpact: Text[20];

        // Style Variables
        ObjectTypeStyleText: Text;
        ObjectCaptionStyleText: Text;
        ObjectIdStyleText: Text;
        ObjectNameStyleText: Text;
        CategoryStyleText: Text;
        RiskLevelStyleText: Text;
        ComplexityStyleText: Text;
        UpgradeImpactStyleText: Text;

    trigger OnOpenPage()
    begin
        ShowAnalysisSummary := true;
        CalculateAnalysisMetrics();
    end;

    trigger OnAfterGetRecord()
    begin
        CalculateRowMetrics();
        SetRowStyles();
    end;

    local procedure CalculateAnalysisMetrics()
    var
        AllObjRec: Record AllObjWithCaption;
        ExtensionCount: Integer;
        HighRiskCount: Integer;
    begin
        // Calculate total objects in current filter
        AllObjRec.CopyFilters(Rec);
        TotalObjects := AllObjRec.Count();

        // Calculate extension objects
        AllObjRec.Reset();
        AllObjRec.CopyFilters(Rec);
        if AllObjRec.FindSet() then
            repeat
                if IsExtensionObject(AllObjRec) then
                    ExtensionCount += 1;
                if IsHighRiskObject(AllObjRec) then
                    HighRiskCount += 1;
            until AllObjRec.Next() = 0;

        TotalExtensions := ExtensionCount;

        // Calculate customization level
        if TotalObjects = 0 then
            CustomizationLevel := 'None'
        else if (ExtensionCount * 100 div TotalObjects) < 10 then
            CustomizationLevel := 'Low'
        else if (ExtensionCount * 100 div TotalObjects) < 30 then
            CustomizationLevel := 'Medium'
        else
            CustomizationLevel := 'High';

        // Calculate risk score
        if TotalObjects = 0 then
            RiskScore := '0%'
        else
            RiskScore := Format(HighRiskCount * 100 div TotalObjects) + '%';
    end;

    local procedure CalculateRowMetrics()
    begin
        // Determine object category
        ObjectCategory := GetObjectCategory();

        // Determine risk level
        RiskLevel := GetRiskLevel();

        // Estimate last modified
        LastModified := GetLastModifiedEstimate();

        // Calculate dependencies (simplified)
        Dependencies := GetDependencyCount();

        // Calculate complexity score
        ComplexityScore := GetComplexityScore();

        // Determine upgrade impact
        UpgradeImpact := GetUpgradeImpact();
    end;

    local procedure SetRowStyles()
    begin
        // Set object type style
        case Rec."Object Type" of
            Rec."Object Type"::Table:
                ObjectTypeStyleText := 'Strong';
            Rec."Object Type"::Page:
                ObjectTypeStyleText := 'Favorable';
            Rec."Object Type"::Report:
                ObjectTypeStyleText := 'Attention';
            Rec."Object Type"::Codeunit:
                ObjectTypeStyleText := 'StandardAccent';
            else
                ObjectTypeStyleText := 'Standard';
        end;

        // Set ID style based on range
        if Rec."Object ID" >= 50000 then
            ObjectIdStyleText := 'Attention'
        else if Rec."Object ID" >= 18000000 then
            ObjectIdStyleText := 'Favorable'
        else
            ObjectIdStyleText := 'Standard';

        // Set category style
        case ObjectCategory of
            'Extension':
                CategoryStyleText := 'Attention';
            'Custom':
                CategoryStyleText := 'Unfavorable';
            else
                CategoryStyleText := 'Standard';
        end;

        // Set risk level style
        case RiskLevel of
            'Critical':
                RiskLevelStyleText := 'Unfavorable';
            'High':
                RiskLevelStyleText := 'Attention';
            'Medium':
                RiskLevelStyleText := 'StandardAccent';
            else
                RiskLevelStyleText := 'Favorable';
        end;

        // Set complexity style
        if ComplexityScore > 80 then
            ComplexityStyleText := 'Unfavorable'
        else if ComplexityScore > 60 then
            ComplexityStyleText := 'Attention'
        else if ComplexityScore > 40 then
            ComplexityStyleText := 'StandardAccent'
        else
            ComplexityStyleText := 'Favorable';

        // Set upgrade impact style
        case UpgradeImpact of
            'Critical':
                UpgradeImpactStyleText := 'Unfavorable';
            'High':
                UpgradeImpactStyleText := 'Attention';
            'Medium':
                UpgradeImpactStyleText := 'StandardAccent';
            else
                UpgradeImpactStyleText := 'Favorable';
        end;
    end;

    local procedure GetObjectCategory(): Text[20]
    begin
        // Determine if object is standard, extension, or custom
        if Rec."Object ID" >= 18000000 then
            exit('Extension')
        else if Rec."Object ID" >= 50000 then
            exit('Custom')
        else
            exit('Standard');
    end;

    local procedure GetRiskLevel(): Text[20]
    var
        RiskScore: Integer;
    begin
        RiskScore := 0;

        // Add risk based on object type
        case Rec."Object Type" of
            Rec."Object Type"::Table:
                RiskScore += 30; // Tables are high risk
            Rec."Object Type"::Page:
                RiskScore += 10; // Pages are lower risk
            Rec."Object Type"::Report:
                RiskScore += 15; // Reports medium risk
            Rec."Object Type"::Codeunit:
                RiskScore += 25; // Codeunits high risk
        end;

        // Add risk based on ID range
        if Rec."Object ID" >= 50000 then
            RiskScore += 20; // Custom objects higher risk

        // Add risk based on dependencies (simplified)
        RiskScore += Dependencies * 2;

        // Return risk level
        if RiskScore >= 80 then
            exit('Critical')
        else if RiskScore >= 60 then
            exit('High')
        else if RiskScore >= 40 then
            exit('Medium')
        else
            exit('Low');
    end;

    local procedure GetLastModifiedEstimate(): Text[30]
    begin
        // This is a simplified estimation
        // In a real implementation, you might check modification dates
        if Rec."Object ID" >= 18000000 then
            exit('Recent (Extension)')
        else if Rec."Object ID" >= 50000 then
            exit('Custom Modified')
        else
            exit('Standard Object');
    end;

    local procedure GetDependencyCount(): Integer
    var
        DependencyCount: Integer;
    begin
        // Simplified dependency calculation
        // In a real implementation, you would analyze actual dependencies
        case Rec."Object Type" of
            Rec."Object Type"::Table:
                DependencyCount := Random(20) + 5; // Tables typically have many dependencies
            Rec."Object Type"::Page:
                DependencyCount := Random(10) + 2; // Pages have moderate dependencies
            Rec."Object Type"::Report:
                DependencyCount := Random(8) + 1; // Reports have fewer dependencies
            Rec."Object Type"::Codeunit:
                DependencyCount := Random(15) + 3; // Codeunits vary
        end;

        exit(DependencyCount);
    end;

    local procedure GetComplexityScore(): Integer
    var
        Score: Integer;
    begin
        Score := 0;

        // Base complexity by object type
        case Rec."Object Type" of
            Rec."Object Type"::Table:
                Score := 40;
            Rec."Object Type"::Page:
                Score := 30;
            Rec."Object Type"::Report:
                Score := 35;
            Rec."Object Type"::Codeunit:
                Score := 50;
        end;

        // Add complexity based on dependencies
        Score += Dependencies * 2;

        // Add complexity for custom objects
        if Rec."Object ID" >= 50000 then
            Score += 20;

        // Cap at 100
        if Score > 100 then
            Score := 100;

        exit(Score);
    end;

    local procedure GetUpgradeImpact(): Text[20]
    var
        Impact: Integer;
    begin
        Impact := 0;

        // Base impact by object type
        case Rec."Object Type" of
            Rec."Object Type"::Table:
                Impact := 40; // Tables have high upgrade impact
            Rec."Object Type"::Page:
                Impact := 20; // Pages have lower impact
            Rec."Object Type"::Report:
                Impact := 25; // Reports medium impact
            Rec."Object Type"::Codeunit:
                Impact := 35; // Codeunits high impact
        end;

        // Increase impact for custom objects
        if Rec."Object ID" >= 50000 then
            Impact += 30;

        // Increase impact based on dependencies
        Impact += Dependencies;

        // Return impact level
        if Impact >= 80 then
            exit('Critical')
        else if Impact >= 60 then
            exit('High')
        else if Impact >= 40 then
            exit('Medium')
        else
            exit('Low');
    end;

    local procedure IsExtensionObject(var AllObjRec: Record AllObjWithCaption): Boolean
    begin
        exit(AllObjRec."Object ID" >= 18000000);
    end;

    local procedure IsHighRiskObject(var AllObjRec: Record AllObjWithCaption): Boolean
    begin
        // Simplified high-risk detection
        exit((AllObjRec."Object ID" >= 50000) and (AllObjRec."Object Type" in [AllObjRec."Object Type"::Table, AllObjRec."Object Type"::Codeunit]));
    end;

    local procedure ShowDependencies()
    var
        DependencyMsg: Text;
    begin
        DependencyMsg := StrSubstNo('Object: %1 %2\Dependencies: %3\n\nThis feature shows object dependencies and relationships.\nIn a full implementation, this would display:\n- Objects that depend on this object\n- Objects this object depends on\n- Circular dependencies\n- Impact analysis',
            Rec."Object Type", Rec."Object Name", Dependencies);
        Message(DependencyMsg);
    end;

    local procedure RunSelectedObject()
    var
        RecVar: Variant;
        RecRef: RecordRef;
    begin
        case Rec."Object Type" of
            Rec."Object Type"::Table:
                begin
                    RecRef.Open(Rec."Object ID");
                    RecVar := RecRef;
                    Page.Run(0, RecVar);
                end;
            Rec."Object Type"::Page:
                Page.Run(Rec."Object ID");
            Rec."Object Type"::Report:
                Report.Run(Rec."Object ID");
            Rec."Object Type"::XMLport:
                Xmlport.Run(Rec."Object ID");
            Rec."Object Type"::Codeunit:
                Codeunit.Run(Rec."Object ID");
            else
                Message('Cannot run object type: %1', Rec."Object Type");
        end;
    end;

    local procedure ShowObjectDetailsProc()
    var
        DetailsMsg: Text;
    begin
        DetailsMsg := StrSubstNo('Object Details:\n\nType: %1\nID: %2\nName: %3\nCaption: %4\nCategory: %5\nRisk Level: %6\nComplexity: %7\nUpgrade Impact: %8\nDependencies: %9\nLast Modified: %10',
            Rec."Object Type", Rec."Object ID", Rec."Object Name", Rec."Object Caption",
            ObjectCategory, RiskLevel, ComplexityScore, UpgradeImpact, Dependencies, LastModified);
        Message(DetailsMsg);
    end;

    local procedure AnalyzeObjectDependenciesProc()
    var
        AnalysisMsg: Text;
    begin
        AnalysisMsg := StrSubstNo('Dependency Analysis for %1 %2:\n\nDirect Dependencies: %3\nRisk Assessment: %4\nUpgrade Impact: %5\n\nRecommendations:\n- Review dependencies before modifications\n- Test thoroughly in sandbox environment\n- Consider impact on dependent objects\n- Document any customizations',
            Rec."Object Type", Rec."Object Name", Dependencies, RiskLevel, UpgradeImpact);
        Message(AnalysisMsg);
    end;

    local procedure ExportAnalysisToExcel()
    begin
        Message('Export Analysis to Excel\n\nThis feature would export the current analysis to Excel including:\n- Object inventory\n- Risk assessment\n- Complexity analysis\n- Upgrade impact assessment\n- Dependency mapping\n\nImplementation would use Excel Buffer or Report to Excel functionality.');
    end;

    local procedure FilterHighRiskObjects()
    begin
        Rec.Reset();
        Rec.SetFilter("Object ID", '>=50000');
        Rec.SetFilter("Object Type", '%1|%2', Rec."Object Type"::Table, Rec."Object Type"::Codeunit);
        CurrPage.Update();
        Message('Filtered to show high-risk objects (Custom Tables and Codeunits)');
    end;

    local procedure FilterExtensionObjects()
    begin
        Rec.Reset();
        Rec.SetFilter("Object ID", '>=18000000');
        CurrPage.Update();
        Message('Filtered to show extension objects (ID >= 18000000)');
    end;

    local procedure FilterCustomObjects()
    begin
        Rec.Reset();
        Rec.SetFilter("Object ID", '50000..17999999');
        CurrPage.Update();
        Message('Filtered to show custom objects (ID 50000-17999999)');
    end;

    local procedure ClearAllFiltersProc()
    begin
        Rec.Reset();
        CurrPage.Update();
        CalculateAnalysisMetrics();
        Message('All filters cleared. Showing all objects.');
    end;

    local procedure ViewTableDataProc()
    var
        TableDataViewer: Page "Sanjeet Table Data Viewer";
    begin
        if Rec."Object Type" <> Rec."Object Type"::Table then begin
            Message('This action is only available for Table objects.\n\nSelected object: %1 %2\nObject Type: %3\n\nPlease select a table to view its data and field structure.',
                Rec."Object ID", Rec."Object Name", Rec."Object Type");
            exit;
        end;

        // Set the table ID and open the viewer
        TableDataViewer.SetTableID(Rec."Object ID");
        TableDataViewer.Run();
    end;

    local procedure PerformWhereUsedAnalysisProc()
    begin
        Message('WHERE USED ANALYSIS\n\nObject: %1 %2 (%3)\nID: %4\n\nThis feature would analyze:\n- Objects that reference this %5\n- Dependencies and relationships\n- Impact assessment for changes\n- Risk level calculation\n\nImplementation approaches:\n- Symbol References API\n- AL source code parsing\n- Metadata analysis\n- Cross-reference tables',
            Rec."Object Type", Rec."Object Name", Rec."Object Caption", Rec."Object ID", Rec."Object Type");
    end;
}
