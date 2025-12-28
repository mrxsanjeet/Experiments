/// <summary>
/// Card page for viewing and reviewing order anomaly details
/// </summary>
page 50103 "SJT Order Anomaly Card"
{
    Caption = 'Order Anomaly';
    PageType = Card;
    SourceTable = "SJT Order Anomaly Entry";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Unique identifier for the anomaly entry.';
                    Editable = false;
                }
                field("Detected DateTime"; Rec."Detected DateTime")
                {
                    ToolTip = 'Date and time when the anomaly was detected.';
                    Editable = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Type of sales document.';
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Document number.';
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Customer number.';
                    Editable = false;
                }
            }
            group(AnomalyDetails)
            {
                Caption = 'Anomaly Details';

                field("Anomaly Type"; Rec."Anomaly Type")
                {
                    ToolTip = 'Type of anomaly detected.';
                    Editable = false;
                }
                field(Severity; Rec.Severity)
                {
                    ToolTip = 'Severity level of the anomaly.';
                    Editable = false;
                    StyleExpr = SeverityStyle;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Description of the anomaly.';
                    Editable = false;
                    MultiLine = true;
                }
                field(Recommendation; Rec.Recommendation)
                {
                    ToolTip = 'Recommended action for this anomaly.';
                    Editable = false;
                    MultiLine = true;
                }
            }
            group(Values)
            {
                Caption = 'Values';

                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Item number if applicable.';
                    Editable = false;
                }
                field("Expected Value"; Rec."Expected Value")
                {
                    ToolTip = 'Expected value based on historical data.';
                    Editable = false;
                }
                field("Actual Value"; Rec."Actual Value")
                {
                    ToolTip = 'Actual value in the order.';
                    Editable = false;
                }
                field("Deviation Pct"; Rec."Deviation Pct")
                {
                    ToolTip = 'Percentage deviation from expected.';
                    Editable = false;
                }
            }
            group(Review)
            {
                Caption = 'Review';

                field(Reviewed; Rec.Reviewed)
                {
                    ToolTip = 'Indicates if the anomaly has been reviewed.';
                }
                field("Reviewed By"; Rec."Reviewed By")
                {
                    ToolTip = 'User who reviewed the anomaly.';
                    Editable = false;
                }
                field("Reviewed DateTime"; Rec."Reviewed DateTime")
                {
                    ToolTip = 'Date and time of review.';
                    Editable = false;
                }
                field("Review Notes"; Rec."Review Notes")
                {
                    ToolTip = 'Notes from the review.';
                    MultiLine = true;
                }
            }
        }
    }

    var
        SeverityStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Severity of
            Rec.Severity::Critical:
                SeverityStyle := 'Unfavorable';
            Rec.Severity::High:
                SeverityStyle := 'Attention';
            Rec.Severity::Medium:
                SeverityStyle := 'Ambiguous';
            else
                SeverityStyle := 'Standard';
        end;
    end;
}

