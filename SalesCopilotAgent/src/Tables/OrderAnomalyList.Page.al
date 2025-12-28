/// <summary>
/// List page for viewing detected order anomalies
/// </summary>
page 50102 "SJT Order Anomaly List"
{
    Caption = 'Order Anomalies';
    PageType = List;
    SourceTable = "SJT Order Anomaly Entry";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "SJT Order Anomaly Card";

    layout
    {
        area(Content)
        {
            repeater(AnomalyList)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Unique identifier for the anomaly entry.';
                }
                field("Detected DateTime"; Rec."Detected DateTime")
                {
                    ToolTip = 'Date and time when the anomaly was detected.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Type of sales document.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Document number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Customer number.';
                }
                field("Anomaly Type"; Rec."Anomaly Type")
                {
                    ToolTip = 'Type of anomaly detected.';
                }
                field(Severity; Rec.Severity)
                {
                    ToolTip = 'Severity level of the anomaly.';
                    StyleExpr = SeverityStyle;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Description of the anomaly.';
                }
                field(Reviewed; Rec.Reviewed)
                {
                    ToolTip = 'Indicates if the anomaly has been reviewed.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Notes; Notes) { }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MarkReviewed)
            {
                Caption = 'Mark as Reviewed';
                ToolTip = 'Mark the selected anomaly as reviewed.';
                ApplicationArea = All;
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.MarkAsReviewed('');
                    CurrPage.Update(false);
                end;
            }
            action(OpenDocument)
            {
                Caption = 'Open Document';
                ToolTip = 'Open the related sales document.';
                ApplicationArea = All;
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    salesHeader: Record "Sales Header";
                begin
                    if salesHeader.Get(Rec."Document Type", Rec."Document No.") then
                        Page.Run(Page::"Sales Order", salesHeader);
                end;
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

