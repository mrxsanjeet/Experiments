page 60000 "Sanjeet Object Viewer"
{
    Caption = 'Sanjeet Object Viewer';
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


            repeater(General)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                }
                field("Object Subtype"; Rec."Object Subtype")
                {
                    ApplicationArea = All;
                }
                field(NoOfRealFields; NoOfRealFields)
                {
                    ApplicationArea = All;
                    Lookup = true;
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        FieldRec: Record Field;
                    begin
                        if (Rec."Object Type" <> Rec."Object Type"::Table) then Error('Object Type must be Table');
                        FieldRec.Reset;
                        FieldRec.SetRange(Class, FieldRec.Class::Normal);
                        FieldRec.SetRange(TableNo, Rec."Object ID");
                        Page.Run(60003, FieldRec);
                    end;
                }
                field(NoOfStandardFields; NoOfStandardFields)
                {
                    ApplicationArea = All;
                    Lookup = true;
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        FieldRec: Record Field;
                    begin
                        if (Rec."Object Type" <> Rec."Object Type"::Table) then Error('Object Type must be Table');
                        FieldRec.Reset;
                        FieldRec.SetRange("App Package ID", Rec."App Package ID");
                        FieldRec.SetRange(TableNo, Rec."Object ID");
                        Page.Run(60003, FieldRec);
                    end;
                }
                field(NoOfExtensionFields; NoOfExtensionFields)
                {
                    ApplicationArea = All;
                    Lookup = true;
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        FieldRec: Record Field;
                    begin
                        if (Rec."Object Type" <> Rec."Object Type"::Table) then Error('Object Type must be Table');
                        FieldRec.Reset;
                        FieldRec.SetFilter("App Package ID", '<>%1', Rec."App Package ID");
                        FieldRec.SetRange(TableNo, Rec."Object ID");
                        Page.Run(60003, FieldRec);
                    end;
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
            action("Run Object")
            {
                Image = Table;

                trigger OnAction()
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
            }
            action("Fields")
            {
                Image = List;

                trigger OnAction()
                var
                    FieldRec: Record Field;
                begin
                    if (Rec."Object Type" <> Rec."Object Type"::Table) then Error('Object Type must be Table');
                    FieldRec.Reset;
                    FieldRec.SetRange(TableNo, Rec."Object ID");
                    Page.Run(60003, FieldRec);
                end;
            }

            action("ViewTableData")
            {
                ApplicationArea = All;
                Caption = 'View Table Data';
                ToolTip = 'View all fields and values for the selected table';
                Image = Database;
                Enabled = Rec."Object Type" = Rec."Object Type"::Table;

                trigger OnAction()
                var
                    TableDataViewer: Page "Sanjeet Table Data Viewer";
                begin
                    if Rec."Object Type" <> Rec."Object Type"::Table then begin
                        Message('This action is only available for Table objects.');
                        exit;
                    end;

                    TableDataViewer.SetTableID(Rec."Object ID");
                    TableDataViewer.Run();
                end;
            }
            action("Log Telemetry")
            {
                Image = List;

                trigger OnAction()
                var
                    AdditionalProperties: Dictionary of [Text, Text];
                begin
                    AdditionalProperties.Add('UserId', Format(UserId));
                    AdditionalProperties.Add('PageId', Format(CurrPage.ObjectId()));
                    Session.LogMessage('Event Id', 'UserActionPerformed', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, AdditionalProperties);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetRange("Object Type", Rec."Object Type"::Table);
    end;

    trigger OnAfterGetRecord()
    var
        FieldRec: Record Field;
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
        NoOfFields := 0;
        NoOfExtensionFields := 0;
        NoOfRealFields := 0;
        NoOfStandardFields := 0;
        if (Rec."Object Type" <> Rec."Object Type"::Table) then exit;
        FieldRec.Reset;
        FieldRec.SetRange(TableNo, Rec."Object ID");
        if FieldRec.FindSet() then NoOfFields := FieldRec.Count();
        FieldRec.SetRange(Class, FieldRec.Class::Normal);
        if FieldRec.FindSet() then NoOfRealFields := FieldRec.Count();
        FieldRec.SetRange("App Package ID", Rec."App Package ID");
        if FieldRec.FindSet() then NoOfStandardFields := FieldRec.Count;
        FieldRec.SetFilter("App Package ID", '<>%1', Rec."App Package ID");
        if FieldRec.FindSet() then NoOfExtensionFields := FieldRec.Count;
        //NoOfExtensionFields := NoOfRealFields - NoOfStandardFields;
    end;

    var
        NoOfFields: Integer;
        NoOfRealFields: Integer;
        NoOfStandardFields: Integer;
        NoOfExtensionFields: Integer;
        ExtensionName: Text;
}