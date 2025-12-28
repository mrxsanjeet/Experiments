table 60200 "Simple Data Exchange Setup"
{
    Caption = 'Simple Data Exchange Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Source BC URL"; Text[250])
        {
            Caption = 'Source BC URL';
            DataClassification = CustomerContent;
            ToolTip = 'URL of source Business Central instance (e.g., http://server:port/instance)';
        }
        field(11; "Username"; Text[100])
        {
            Caption = 'Username';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Password"; Text[100])
        {
            Caption = 'Password';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        field(20; "Source Company ID"; Guid)
        {
            Caption = 'Source Company ID';
            DataClassification = CustomerContent;
        }
        field(30; "Sync Enabled"; Boolean)
        {
            Caption = 'Sync Enabled';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(40; "Last Sync DateTime"; DateTime)
        {
            Caption = 'Last Sync DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(41; "Last Sync Status"; Text[50])
        {
            Caption = 'Last Sync Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Primary Key" = '' then
            "Primary Key" := 'DEFAULT';
    end;

    procedure GetSetup(): Record "Simple Data Exchange Setup"
    var
        setup: Record "Simple Data Exchange Setup";
    begin
        if not setup.Get('DEFAULT') then begin
            setup.Init();
            setup."Primary Key" := 'DEFAULT';
            setup.Insert();
        end;
        exit(setup);
    end;
}
