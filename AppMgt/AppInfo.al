table 50121 AppInfo
{
    DataClassification = ToBeClassified;
    Caption = 'App Information';
    //DataRetentionPeriod = 365D; // Set appropriate retention period

    fields
    {
        field(1; Name; Text[100])
        {
            Caption = 'App Name';
            DataClassification = ToBeClassified;
        }

        field(2; AppId; Code[50])
        {
            Caption = 'App ID';
            DataClassification = ToBeClassified;
        }

        field(3; Publisher; Text[100])
        {
            Caption = 'Publisher';
            DataClassification = ToBeClassified;
        }
        field(4; dependency; Text[100])
        {
            Caption = 'Dependency';
            DataClassification = ToBeClassified;
        }
        field(5; DependencyAppId; Code[50])
        {
            Caption = 'Dependency App ID';
            DataClassification = ToBeClassified;
        }
        field(6; DependencyPublisher; Text[100])
        {
            Caption = 'Dependency Publisher';
            DataClassification = ToBeClassified;
        }
        field(7; DependencyVersion; Text[100])
        {
            Caption = 'Dependency Version';
            DataClassification = ToBeClassified;
        }
        field(8; DependencyType; Text[100])
        {
            Caption = 'Dependency Type';
            DataClassification = ToBeClassified;
        }
        field(9; DependencyStatus; Text[100])
        {
            Caption = 'Dependency Status';
            DataClassification = ToBeClassified;
        }
    }
}
