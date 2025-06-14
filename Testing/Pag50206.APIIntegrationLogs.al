page 70206 "API Integration Logs"
{
    Caption = 'API Integration Logs';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "API Integration Log";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Logs)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number of the log.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source type of the log.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message.';
                }
                field("Date Time"; Rec."Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the log was created.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearLogs)
            {
                ApplicationArea = All;
                Caption = 'Clear Logs';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete all log entries.';

                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to delete all log entries?') then
                        Rec.DeleteAll();
                end;
            }
        }
    }
}