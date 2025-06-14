page 60003 "Sanjeet Field Viewer"
{
    Caption = 'Sanjeet Field Viewer';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = Field;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                }
                field(FieldName; Rec.FieldName)
                {
                    ApplicationArea = All;
                }
                field(IsPartOfPrimaryKey; Rec.IsPartOfPrimaryKey)
                {
                    ApplicationArea = All;
                }
                field(TableNo; Rec.TableNo)
                {
                    ApplicationArea = All;
                }
                field(TableName; Rec.TableName)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Type Name"; Rec."Type Name")
                {
                    ApplicationArea = All;
                }
                field(Class; Rec.Class)
                {
                    ApplicationArea = All;
                }
                field(ExtensionName; ExtensionName)
                {
                    ApplicationArea = All;
                    Style = Strong;
                }
                field("App Package ID"; Rec."App Package ID")
                {
                    ApplicationArea = All;
                }
                field("App Runtime Package ID"; Rec."App Runtime Package ID")
                {
                    ApplicationArea = All;
                }
                field(RelationTableNo; Rec.RelationTableNo)
                {
                    ApplicationArea = All;
                }
                field(RelationFieldNo; Rec.RelationFieldNo)
                {
                    ApplicationArea = All;
                }
                field(ExternalName; Rec.ExternalName)
                {
                    ApplicationArea = All;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = All;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ApplicationArea = All;
                }
                field(SystemRowVersion; Rec.SystemRowVersion)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("WhereUsedField")
            {
                ApplicationArea = All;
                Caption = 'Where Used Analysis';
                ToolTip = 'Analyze where this field is used throughout the system';
                Image = Find;

                trigger OnAction()
                begin
                    Message('WHERE USED ANALYSIS FOR FIELD\n\nField: %1.%2 (%3)\nTable: %4\n\nThis feature would analyze:\n- Pages using this field\n- Reports displaying this field\n- Codeunits referencing this field\n- Table relations involving this field\n\nImplementation: Use Symbol References API or parse AL source code for field usage patterns.',
                        Rec.TableNo, Rec."No.", Rec.FieldName, Rec.TableName);
                end;
            }

            action("RunTable")
            {
                ApplicationArea = All;
                Caption = 'Run Table';
                ToolTip = 'Run the table containing this field';
                Image = Table;

                trigger OnAction()
                var
                    RecVar: Variant;
                    RecRef: RecordRef;
                begin
                    RecRef.Open(Rec.TableNo);
                    RecVar := RecRef;
                    Page.Run(0, RecVar);
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
    begin
    end;

    trigger OnAfterGetRecord()
    var
        //ExtRec: Record "All Profile Extension";
        NavApp: Record "NAV App Installed App";
    begin
        ExtensionName := '';
        NavApp.Reset;
        NavApp.SetRange("Package ID", Rec."App Package ID");
        if NavApp.FindFirst() then
            ExtensionName := NavApp.Name
        else begin
            NavApp.SetRange("Package ID", Rec."App Runtime Package ID");
            if NavApp.FindFirst() then
                ExtensionName := NavApp.Name
            else
                ExtensionName := 'Could not be retrieved.';
        end;
    end;

    var
        ExtensionName: Text;
}