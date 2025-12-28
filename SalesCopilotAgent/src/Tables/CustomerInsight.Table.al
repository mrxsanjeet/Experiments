/// <summary>
/// Table for storing calculated customer insights for Copilot analysis
/// </summary>
table 50103 "SJT Customer Insight"
{
    Caption = 'Customer Insight';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(10; "Customer Tier"; Enum "SJT Customer Tier")
        {
            Caption = 'Customer Tier';
        }
        field(11; "Total Sales Amount"; Decimal)
        {
            Caption = 'Total Sales Amount';
            DecimalPlaces = 2 : 2;
        }
        field(12; "Total Orders"; Integer)
        {
            Caption = 'Total Orders';
        }
        field(13; "Average Order Value"; Decimal)
        {
            Caption = 'Average Order Value';
            DecimalPlaces = 2 : 2;
        }
        field(20; "Last Order Date"; Date)
        {
            Caption = 'Last Order Date';
        }
        field(21; "Days Since Last Order"; Integer)
        {
            Caption = 'Days Since Last Order';
        }
        field(22; "Average Order Frequency Days"; Decimal)
        {
            Caption = 'Average Order Frequency (Days)';
            DecimalPlaces = 1 : 1;
        }
        field(30; "Most Ordered Item No."; Code[20])
        {
            Caption = 'Most Ordered Item No.';
            TableRelation = Item."No.";
        }
        field(31; "Most Ordered Item Qty"; Decimal)
        {
            Caption = 'Most Ordered Item Qty';
            DecimalPlaces = 0 : 2;
        }
        field(40; "Average Discount Pct"; Decimal)
        {
            Caption = 'Average Discount %';
            DecimalPlaces = 2 : 2;
        }
        field(41; "Max Discount Given Pct"; Decimal)
        {
            Caption = 'Max Discount Given %';
            DecimalPlaces = 2 : 2;
        }
        field(50; "Churn Risk Score"; Decimal)
        {
            Caption = 'Churn Risk Score';
            DecimalPlaces = 2 : 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(51; "Churn Risk Level"; Option)
        {
            Caption = 'Churn Risk Level';
            OptionMembers = Low,Medium,High,Critical;
            OptionCaption = 'Low,Medium,High,Critical';
        }
        field(60; "Last Calculated DateTime"; DateTime)
        {
            Caption = 'Last Calculated DateTime';
        }
        field(70; "Ship-to Address Count"; Integer)
        {
            Caption = 'Ship-to Address Count';
        }
        field(71; "Primary Ship-to Code"; Code[10])
        {
            Caption = 'Primary Ship-to Code';
        }
    }

    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
        key(Tier; "Customer Tier")
        {
        }
        key(ChurnRisk; "Churn Risk Score")
        {
        }
    }
}

