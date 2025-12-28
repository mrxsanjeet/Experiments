/// <summary>
/// List page for viewing Copilot suggestion history
/// </summary>
page 50104 "SJT Suggestion Log List"
{
    Caption = 'Copilot Suggestion History';
    PageType = List;
    SourceTable = "SJT Copilot Suggestion Log";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(SuggestionList)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Unique identifier for the suggestion entry.';
                }
                field("Created DateTime"; Rec."Created DateTime")
                {
                    ToolTip = 'Date and time when the suggestion was created.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'User who requested the suggestion.';
                }
                field("Action Type"; Rec."Action Type")
                {
                    ToolTip = 'Type of Copilot action.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ToolTip = 'Source document number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Customer number.';
                }
                field("Customer Tier"; Rec."Customer Tier")
                {
                    ToolTip = 'Customer tier at time of suggestion.';
                }
                field("Suggested Value"; Rec."Suggested Value")
                {
                    ToolTip = 'Value suggested by Copilot.';
                }
                field("Applied Value"; Rec."Applied Value")
                {
                    ToolTip = 'Value actually applied.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Status of the suggestion.';
                    StyleExpr = StatusStyle;
                }
            }
        }
        area(FactBoxes)
        {
            part(SuggestionDetails; "SJT Suggestion Details FactBox")
            {
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewDetails)
            {
                Caption = 'View Details';
                ToolTip = 'View full suggestion details.';
                ApplicationArea = All;
                Image = View;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Message(Rec."Suggestion Text");
                end;
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Accepted:
                StatusStyle := 'Favorable';
            Rec.Status::Rejected:
                StatusStyle := 'Unfavorable';
            Rec.Status::Modified:
                StatusStyle := 'Ambiguous';
            else
                StatusStyle := 'Standard';
        end;
    end;
}

