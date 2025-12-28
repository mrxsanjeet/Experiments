/// <summary>
/// Setup page for configuring Sales Copilot Agent behavior
/// </summary>
page 50100 "SJT Sales Copilot Setup"
{
    Caption = 'Sales Copilot Setup';
    PageType = Card;
    SourceTable = "SJT Sales Copilot Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(DiscountRecommendation)
            {
                Caption = 'Discount Recommendation Settings';

                field("Enable Discount Copilot"; Rec."Enable Discount Copilot")
                {
                    ToolTip = 'Enable or disable the Discount Recommendation Copilot feature.';
                }
                field("Min Margin Pct"; Rec."Min Margin Pct")
                {
                    ToolTip = 'Minimum margin percentage that must be maintained when suggesting discounts.';
                }
                field("Max Discount Pct"; Rec."Max Discount Pct")
                {
                    ToolTip = 'Maximum discount percentage that can be suggested by Copilot.';
                }
                field("Inventory Age Threshold Days"; Rec."Inventory Age Threshold Days")
                {
                    ToolTip = 'Number of days after which inventory is considered slow-moving.';
                }
                field("Slow Moving Discount Bonus Pct"; Rec."Slow Moving Discount Bonus Pct")
                {
                    ToolTip = 'Additional discount percentage to add for slow-moving inventory items.';
                }
            }
            group(AnomalyDetection)
            {
                Caption = 'Anomaly Detection Settings';

                field("Enable Anomaly Detection"; Rec."Enable Anomaly Detection")
                {
                    ToolTip = 'Enable or disable automatic order anomaly detection.';
                }
                field("Qty Spike Multiplier"; Rec."Qty Spike Multiplier")
                {
                    ToolTip = 'Multiplier for average quantity to trigger quantity spike anomaly (e.g., 3 = 3x average).';
                }
                field("Price Deviation Pct"; Rec."Price Deviation Pct")
                {
                    ToolTip = 'Percentage deviation from standard price to trigger price anomaly.';
                }
                field("Check New Ship-to Address"; Rec."Check New Ship-to Address")
                {
                    ToolTip = 'Flag orders with new shipping addresses for established customers.';
                }
                field("Order History Months"; Rec."Order History Months")
                {
                    ToolTip = 'Number of months of order history to analyze for patterns.';
                }
            }
            group(CustomerTiers)
            {
                Caption = 'Customer Tier Thresholds';

                field("Bronze Tier Min Amount"; Rec."Bronze Tier Min Amount")
                {
                    ToolTip = 'Minimum total sales amount for Bronze tier classification.';
                }
                field("Silver Tier Min Amount"; Rec."Silver Tier Min Amount")
                {
                    ToolTip = 'Minimum total sales amount for Silver tier classification.';
                }
                field("Gold Tier Min Amount"; Rec."Gold Tier Min Amount")
                {
                    ToolTip = 'Minimum total sales amount for Gold tier classification.';
                }
                field("Platinum Tier Min Amount"; Rec."Platinum Tier Min Amount")
                {
                    ToolTip = 'Minimum total sales amount for Platinum tier classification.';
                }
            }
            group(TierDiscounts)
            {
                Caption = 'Tier Discount Bonuses';

                field("Bronze Discount Bonus Pct"; Rec."Bronze Discount Bonus Pct")
                {
                    ToolTip = 'Additional discount percentage for Bronze tier customers.';
                }
                field("Silver Discount Bonus Pct"; Rec."Silver Discount Bonus Pct")
                {
                    ToolTip = 'Additional discount percentage for Silver tier customers.';
                }
                field("Gold Discount Bonus Pct"; Rec."Gold Discount Bonus Pct")
                {
                    ToolTip = 'Additional discount percentage for Gold tier customers.';
                }
                field("Platinum Discount Bonus Pct"; Rec."Platinum Discount Bonus Pct")
                {
                    ToolTip = 'Additional discount percentage for Platinum tier customers.';
                }
            }
            group(Telemetry)
            {
                Caption = 'Telemetry & Logging';

                field("Enable Telemetry"; Rec."Enable Telemetry")
                {
                    ToolTip = 'Enable telemetry for Copilot usage analytics.';
                }
                field("Log Suggestions"; Rec."Log Suggestions")
                {
                    ToolTip = 'Log all Copilot suggestions for review and analysis.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}

