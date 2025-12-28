/// <summary>
/// Permission set containing all objects in the Sales Copilot extension
/// Used as a base for other permission sets
/// </summary>
permissionset 50102 "SJT Sales Copilot Objects"
{
    Caption = 'Sales Copilot - All Objects';
    Assignable = false;
    Access = Internal;

    Permissions =
        // Tables
        table "SJT Sales Copilot Setup" = X,
        table "SJT Copilot Suggestion Log" = X,
        table "SJT Order Anomaly Entry" = X,
        table "SJT Customer Insight" = X,

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

