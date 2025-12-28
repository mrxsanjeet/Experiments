/// <summary>
/// Page extension to add Copilot actions to Sales Order page
/// </summary>
pageextension 50106 "SJT Sales Order Ext" extends "Sales Order"
{
    actions
    {
        addlast(processing)
        {
            group(SalesCopilotGroup)
            {
                Caption = 'Sales Copilot';
                Image = Sparkle;

                action(AskCopilotDiscount)
                {
                    Caption = 'Suggest Discount';
                    ToolTip = 'Ask Copilot to suggest an optimal discount for this order based on customer history and margin targets.';
                    ApplicationArea = All;
                    Image = Discount;

                    trigger OnAction()
                    var
                        copilotPage: Page "SJT Sales Copilot Proposal";
                        salesLine: Record "Sales Line";
                        suggestedDiscount: Decimal;
                    begin
                        copilotPage.Initialize(Rec."Document Type", Rec."No.", Rec."Sell-to Customer No.");
                        if copilotPage.RunModal() = Action::OK then begin
                            suggestedDiscount := copilotPage.GetSuggestedDiscount();
                            if suggestedDiscount > 0 then begin
                                if Confirm('Apply %1% discount to all lines?', true, suggestedDiscount) then begin
                                    salesLine.SetRange("Document Type", Rec."Document Type");
                                    salesLine.SetRange("Document No.", Rec."No.");
                                    salesLine.SetFilter(Type, '<>%1', salesLine.Type::" ");
                                    if salesLine.FindSet() then
                                        repeat
                                            salesLine.Validate("Line Discount %", suggestedDiscount);
                                            salesLine.Modify(true);
                                        until salesLine.Next() = 0;
                                    Message('Discount of %1% applied to all lines.', suggestedDiscount);
                                end;
                            end;
                        end;
                    end;
                }
                action(CheckAnomalies)
                {
                    Caption = 'Check Anomalies';
                    ToolTip = 'Ask Copilot to check this order for any unusual patterns or anomalies.';
                    ApplicationArea = All;
                    Image = Warning;

                    trigger OnAction()
                    var
                        copilotPage: Page "SJT Sales Copilot Proposal";
                    begin
                        copilotPage.Initialize(Rec."Document Type", Rec."No.", Rec."Sell-to Customer No.");
                        copilotPage.RunModal();
                    end;
                }
                action(ViewAnomalyHistory)
                {
                    Caption = 'View Anomaly History';
                    ToolTip = 'View all detected anomalies for this order.';
                    ApplicationArea = All;
                    Image = History;
                    RunObject = page "SJT Order Anomaly List";
                    RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                }
            }
        }
        addlast(Promoted)
        {
            group(Category_Copilot)
            {
                Caption = 'Copilot';

                actionref(AskCopilotDiscount_Promoted; AskCopilotDiscount) { }
                actionref(CheckAnomalies_Promoted; CheckAnomalies) { }
            }
        }
    }
}

