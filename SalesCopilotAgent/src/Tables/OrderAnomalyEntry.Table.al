/// <summary>
/// Table for storing detected order anomalies
/// </summary>
table 50102 "SJT Order Anomaly Entry"
{
    Caption = 'Order Anomaly Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Detected DateTime"; DateTime)
        {
            Caption = 'Detected DateTime';
        }
        field(10; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(11; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(12; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(13; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(20; "Anomaly Type"; Enum "SJT Anomaly Type")
        {
            Caption = 'Anomaly Type';
        }
        field(21; "Severity"; Option)
        {
            Caption = 'Severity';
            OptionMembers = Low,Medium,High,Critical;
            OptionCaption = 'Low,Medium,High,Critical';
        }
        field(22; "Description"; Text[500])
        {
            Caption = 'Description';
        }
        field(23; "Recommendation"; Text[500])
        {
            Caption = 'Recommendation';
        }
        field(30; "Expected Value"; Decimal)
        {
            Caption = 'Expected Value';
            DecimalPlaces = 2 : 5;
        }
        field(31; "Actual Value"; Decimal)
        {
            Caption = 'Actual Value';
            DecimalPlaces = 2 : 5;
        }
        field(32; "Deviation Pct"; Decimal)
        {
            Caption = 'Deviation %';
            DecimalPlaces = 2 : 2;
        }
        field(40; "Reviewed"; Boolean)
        {
            Caption = 'Reviewed';
        }
        field(41; "Reviewed By"; Code[50])
        {
            Caption = 'Reviewed By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(42; "Reviewed DateTime"; DateTime)
        {
            Caption = 'Reviewed DateTime';
        }
        field(43; "Review Notes"; Text[500])
        {
            Caption = 'Review Notes';
        }
        field(50; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(51; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(52; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 2 : 5;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Document; "Document Type", "Document No.")
        {
        }
        key(Customer; "Customer No.", "Detected DateTime")
        {
        }
        key(Severity; "Severity", "Reviewed")
        {
        }
    }

    trigger OnInsert()
    begin
        "Detected DateTime" := CurrentDateTime;
    end;

    /// <summary>
    /// Marks the anomaly as reviewed
    /// </summary>
    procedure MarkAsReviewed(pNotes: Text[500])
    begin
        Reviewed := true;
        "Reviewed By" := CopyStr(UserId, 1, MaxStrLen("Reviewed By"));
        "Reviewed DateTime" := CurrentDateTime;
        "Review Notes" := pNotes;
        Modify(true);
    end;
}

