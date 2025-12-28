/// <summary>
/// Permission set for Sales Copilot administrators
/// Full access to all Copilot features and configuration
/// </summary>
permissionset 50100 "SJTSalesCopilotAdmin"
{
    Caption = 'Sales Copilot - Admin';
    Assignable = true;

    Permissions =
        // Tables
        tabledata "SJT Sales Copilot Setup" = RIMD,
        tabledata "SJT Copilot Suggestion Log" = RIMD,
        tabledata "SJT Order Anomaly Entry" = RIMD,
        tabledata "SJT Customer Insight" = RIMD,

        // Codeunits
        codeunit "SJT Sales Copilot Impl" = X,
        codeunit "SJT Discount Calculator" = X,
        codeunit "SJT Anomaly Detector" = X,
        codeunit "SJT Customer Insight Calc" = X,
        codeunit "SJT Sales Copilot Telemetry" = X,

        // Pages
        page "SJT Sales Copilot Setup" = X,
        page "SJT Sales Copilot Proposal" = X,
        page "SJT Order Anomaly List" = X,
        page "SJT Order Anomaly Card" = X,
        page "SJT Suggestion Log List" = X,
        page "SJT Suggestion Details FactBox" = X;
}

