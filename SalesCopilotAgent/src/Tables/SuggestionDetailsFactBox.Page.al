/// <summary>
/// FactBox for displaying suggestion details
/// </summary>
page 50105 "SJT Suggestion Details FactBox"
{
    Caption = 'Suggestion Details';
    PageType = CardPart;
    SourceTable = "SJT Copilot Suggestion Log";

    layout
    {
        area(Content)
        {
            field("Order Amount"; Rec."Order Amount")
            {
                Caption = 'Order Amount';
                ApplicationArea = All;
                ToolTip = 'Order amount at time of suggestion.';
            }
            field("Calculated Margin Pct"; Rec."Calculated Margin Pct")
            {
                Caption = 'Margin %';
                ApplicationArea = All;
                ToolTip = 'Calculated margin percentage.';
            }
            field("Suggested Value"; Rec."Suggested Value")
            {
                Caption = 'Suggested';
                ApplicationArea = All;
                ToolTip = 'Value suggested by Copilot.';
            }
            field("Applied Value"; Rec."Applied Value")
            {
                Caption = 'Applied';
                ApplicationArea = All;
                ToolTip = 'Value actually applied.';
            }
            field(Status; Rec.Status)
            {
                Caption = 'Status';
                ApplicationArea = All;
                ToolTip = 'Current status of the suggestion.';
            }
        }
    }
}

