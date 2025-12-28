page 60200 "Simple Data Exchange Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Simple Data Exchange Setup";
    Caption = 'Simple Data Exchange Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Connection Settings';

                field("Source BC URL"; Rec."Source BC URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the URL of the source Business Central instance';
                }
                field(Username; Rec.Username)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the username for Basic Authentication';
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the password for Basic Authentication';
                }
                field("Source Company ID"; Rec."Source Company ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the Company ID from the source instance';
                }
            }

            group(SyncOptions)
            {
                Caption = 'Sync Options';

                field("Sync Enabled"; Rec."Sync Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable customer data synchronization';
                }
            }

            group(Status)
            {
                Caption = 'Status';

                field("Last Sync DateTime"; Rec."Last Sync DateTime")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Sync Status"; Rec."Last Sync Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection';
                Image = TestDatabase;
                ToolTip = 'Test the connection to the source Business Central instance';

                trigger OnAction()
                var
                    dataSync: Codeunit "Simple Data Sync";
                begin
                    dataSync.TestConnection();
                end;
            }

            action(SyncNow)
            {
                ApplicationArea = All;
                Caption = 'Sync Now';
                Image = Refresh;
                ToolTip = 'Start data synchronization immediately';

                trigger OnAction()
                var
                    dataSync: Codeunit "Simple Data Sync";
                    confirmMsg: Label 'This will synchronize data from the source system. Continue?';
                begin
                    if Confirm(confirmMsg) then begin
                        if dataSync.SyncAllData() then
                            Message('Data synchronization completed successfully!')
                        else
                            Message('Data synchronization failed. Please check the setup.');
                        CurrPage.Update();
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('DEFAULT') then begin
            Rec.Init();
            Rec."Primary Key" := 'DEFAULT';
            Rec.Insert();
        end;
    end;
}
