/// <summary>
/// Permission set for Sales Copilot users
/// Access to use Copilot features but not configure them
/// </summary>
permissionset 50101 "SJTSalesCopilotUser"
{
    Caption = 'Sales Copilot - User';
    Assignable = true;

    Permissions =
        // Tables - Read only for setup, full for logs
        tabledata "SJT Sales Copilot Setup" = R,
        tabledata "SJT Copilot Suggestion Log" = RIM,
        tabledata "SJT Order Anomaly Entry" = RIM,
        tabledata "SJT Customer Insight" = RI,

        // Codeunits
        codeunit "SJT Sales Copilot Impl" = X,
        codeunit "SJT Discount Calculator" = X,
        codeunit "SJT Anomaly Detector" = X,
        codeunit "SJT Customer Insight Calc" = X,
        codeunit "SJT Sales Copilot Telemetry" = X,

        // Pages
        page "SJT Sales Copilot Proposal" = X,
        page "SJT Order Anomaly List" = X,
        page "SJT Order Anomaly Card" = X,
        page "SJT Suggestion Log List" = X,
        page "SJT Suggestion Details FactBox" = X;
}

