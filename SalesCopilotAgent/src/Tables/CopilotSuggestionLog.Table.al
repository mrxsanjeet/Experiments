/// <summary>
/// Table for logging all Copilot suggestions for analysis and learning
/// </summary>
table 50101 "SJT Copilot Suggestion Log"
{
    Caption = 'Copilot Suggestion Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
        }
        field(3; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Action Type"; Enum "SJT Sales Copilot Action")
        {
            Caption = 'Action Type';
        }
        field(11; "Source Document Type"; Option)
        {
            Caption = 'Source Document Type';
            OptionMembers = "Sales Order","Sales Quote","Sales Invoice","Customer";
            OptionCaption = 'Sales Order,Sales Quote,Sales Invoice,Customer';
        }
        field(12; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
        }
        field(13; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(20; "Suggestion Text"; Text[2048])
        {
            Caption = 'Suggestion Text';
        }
        field(21; "Suggested Value"; Decimal)
        {
            Caption = 'Suggested Value';
            DecimalPlaces = 2 : 5;
        }
        field(22; "Applied Value"; Decimal)
        {
            Caption = 'Applied Value';
            DecimalPlaces = 2 : 5;
        }
        field(30; "Status"; Enum "SJT Suggestion Status")
        {
            Caption = 'Status';
        }
        field(31; "Status Changed DateTime"; DateTime)
        {
            Caption = 'Status Changed DateTime';
        }
        field(32; "Status Changed By"; Code[50])
        {
            Caption = 'Status Changed By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(40; "Analysis Details"; Blob)
        {
            Caption = 'Analysis Details';
            Subtype = Json;
        }
        field(50; "Customer Tier"; Enum "SJT Customer Tier")
        {
            Caption = 'Customer Tier';
        }
        field(51; "Order Amount"; Decimal)
        {
            Caption = 'Order Amount';
        }
        field(52; "Calculated Margin Pct"; Decimal)
        {
            Caption = 'Calculated Margin %';
            DecimalPlaces = 2 : 2;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(DateTime; "Created DateTime")
        {
        }
        key(Customer; "Customer No.", "Created DateTime")
        {
        }
        key(Status; "Status", "Action Type")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime;
        "User ID" := CopyStr(UserId, 1, MaxStrLen("User ID"));
    end;

    /// <summary>
    /// Sets the analysis details as JSON blob
    /// </summary>
    procedure SetAnalysisDetails(pDetails: JsonObject)
    var
        outStream: OutStream;
        jsonText: Text;
    begin
        pDetails.WriteTo(jsonText);
        Clear("Analysis Details");
        "Analysis Details".CreateOutStream(outStream, TextEncoding::UTF8);
        outStream.WriteText(jsonText);
    end;

    /// <summary>
    /// Gets the analysis details from JSON blob
    /// </summary>
    procedure GetAnalysisDetails() result: JsonObject
    var
        inStream: InStream;
        jsonText: Text;
    begin
        if not "Analysis Details".HasValue then
            exit;
        CalcFields("Analysis Details");
        "Analysis Details".CreateInStream(inStream, TextEncoding::UTF8);
        inStream.ReadText(jsonText);
        result.ReadFrom(jsonText);
    end;
}

