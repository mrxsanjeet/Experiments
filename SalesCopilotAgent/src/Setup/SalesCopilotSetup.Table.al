/// <summary>
/// Table for storing Sales Copilot configuration settings
/// Singleton table (Primary Key = '') for global settings
/// </summary>
table 50100 "SJT Sales Copilot Setup"
{
    Caption = 'Sales Copilot Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        // Discount Recommendation Settings
        field(10; "Enable Discount Copilot"; Boolean)
        {
            Caption = 'Enable Discount Copilot';
            InitValue = true;
        }
        field(11; "Min Margin Pct"; Decimal)
        {
            Caption = 'Minimum Margin %';
            InitValue = 20;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2 : 2;
        }
        field(12; "Max Discount Pct"; Decimal)
        {
            Caption = 'Maximum Discount %';
            InitValue = 30;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2 : 2;
        }
        field(13; "Inventory Age Threshold Days"; Integer)
        {
            Caption = 'Inventory Age Threshold (Days)';
            InitValue = 90;
            MinValue = 0;
        }
        field(14; "Slow Moving Discount Bonus Pct"; Decimal)
        {
            Caption = 'Slow Moving Discount Bonus %';
            InitValue = 5;
            MinValue = 0;
            MaxValue = 20;
            DecimalPlaces = 2 : 2;
        }
        // Anomaly Detection Settings
        field(20; "Enable Anomaly Detection"; Boolean)
        {
            Caption = 'Enable Anomaly Detection';
            InitValue = true;
        }
        field(21; "Qty Spike Multiplier"; Decimal)
        {
            Caption = 'Quantity Spike Multiplier';
            InitValue = 3;
            MinValue = 1.5;
            DecimalPlaces = 1 : 1;
        }
        field(22; "Price Deviation Pct"; Decimal)
        {
            Caption = 'Price Deviation Threshold %';
            InitValue = 20;
            MinValue = 5;
            MaxValue = 50;
            DecimalPlaces = 2 : 2;
        }
        field(23; "Check New Ship-to Address"; Boolean)
        {
            Caption = 'Check New Ship-to Address';
            InitValue = true;
        }
        field(24; "Order History Months"; Integer)
        {
            Caption = 'Order History Months';
            InitValue = 12;
            MinValue = 3;
            MaxValue = 36;
        }
        // Customer Tier Settings
        field(30; "Bronze Tier Min Amount"; Decimal)
        {
            Caption = 'Bronze Tier Min Amount';
            InitValue = 10000;
            MinValue = 0;
        }
        field(31; "Silver Tier Min Amount"; Decimal)
        {
            Caption = 'Silver Tier Min Amount';
            InitValue = 50000;
            MinValue = 0;
        }
        field(32; "Gold Tier Min Amount"; Decimal)
        {
            Caption = 'Gold Tier Min Amount';
            InitValue = 100000;
            MinValue = 0;
        }
        field(33; "Platinum Tier Min Amount"; Decimal)
        {
            Caption = 'Platinum Tier Min Amount';
            InitValue = 250000;
            MinValue = 0;
        }
        // Tier Discount Bonuses
        field(40; "Bronze Discount Bonus Pct"; Decimal)
        {
            Caption = 'Bronze Discount Bonus %';
            InitValue = 2;
            DecimalPlaces = 2 : 2;
        }
        field(41; "Silver Discount Bonus Pct"; Decimal)
        {
            Caption = 'Silver Discount Bonus %';
            InitValue = 5;
            DecimalPlaces = 2 : 2;
        }
        field(42; "Gold Discount Bonus Pct"; Decimal)
        {
            Caption = 'Gold Discount Bonus %';
            InitValue = 8;
            DecimalPlaces = 2 : 2;
        }
        field(43; "Platinum Discount Bonus Pct"; Decimal)
        {
            Caption = 'Platinum Discount Bonus %';
            InitValue = 12;
            DecimalPlaces = 2 : 2;
        }
        // Telemetry and Logging
        field(50; "Enable Telemetry"; Boolean)
        {
            Caption = 'Enable Telemetry';
            InitValue = true;
        }
        field(51; "Log Suggestions"; Boolean)
        {
            Caption = 'Log All Suggestions';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Gets the singleton setup record, creating it if it doesn't exist
    /// </summary>
    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;
}

