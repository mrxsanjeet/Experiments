/// <summary>
/// Page extension to add Copilot insights to Customer Card
/// </summary>
pageextension 50107 "SJT Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addafter(General)
        {
            group(CopilotInsights)
            {
                Caption = 'Copilot Insights';
                Visible = HasInsights;

                field(CustomerTier; CustomerTierText)
                {
                    Caption = 'Customer Tier';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Customer tier classification based on purchase history.';
                    Style = Strong;
                    StyleExpr = true;
                }
                field(ChurnRiskLevel; ChurnRiskText)
                {
                    Caption = 'Churn Risk';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Predicted risk of customer churning based on order patterns.';
                    StyleExpr = ChurnRiskStyle;
                }
                field(DaysSinceLastOrder; DaysSinceLastOrderValue)
                {
                    Caption = 'Days Since Last Order';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Number of days since the customer last placed an order.';
                }
                field(AverageOrderValue; AverageOrderValueText)
                {
                    Caption = 'Average Order Value';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Average value of customer orders.';
                }
                field(TotalOrders; TotalOrdersValue)
                {
                    Caption = 'Total Orders';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Total number of orders placed by this customer.';
                }
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(SalesCopilotGroup)
            {
                Caption = 'Sales Copilot';
                Image = Sparkle;

                action(AnalyzeCustomer)
                {
                    Caption = 'Analyze Customer';
                    ToolTip = 'Get AI-powered insights about this customer.';
                    ApplicationArea = All;
                    Image = Sparkle;

                    trigger OnAction()
                    var
                        copilotPage: Page "SJT Sales Copilot Proposal";
                    begin
                        copilotPage.Initialize("Sales Document Type"::Order, '', Rec."No.");
                        copilotPage.RunModal();
                    end;
                }
                action(RefreshInsights)
                {
                    Caption = 'Refresh Insights';
                    ToolTip = 'Recalculate customer insights.';
                    ApplicationArea = All;
                    Image = Refresh;

                    trigger OnAction()
                    var
                        insightCalc: Codeunit "SJT Customer Insight Calc";
                    begin
                        insightCalc.CalculateCustomerInsight(Rec."No.");
                        LoadInsights();
                        CurrPage.Update(false);
                        Message('Customer insights refreshed.');
                    end;
                }
                action(ViewSuggestionHistory)
                {
                    Caption = 'Suggestion History';
                    ToolTip = 'View all Copilot suggestions for this customer.';
                    ApplicationArea = All;
                    Image = History;
                    RunObject = page "SJT Suggestion Log List";
                    RunPageLink = "Customer No." = field("No.");
                }
            }
        }
        addlast(Promoted)
        {
            group(Category_Copilot)
            {
                Caption = 'Copilot';

                actionref(AnalyzeCustomer_Promoted; AnalyzeCustomer) { }
                actionref(RefreshInsights_Promoted; RefreshInsights) { }
            }
        }
    }

    var
        CustomerInsight: Record "SJT Customer Insight";
        HasInsights: Boolean;
        CustomerTierText: Text;
        ChurnRiskText: Text;
        ChurnRiskStyle: Text;
        AverageOrderValueText: Text;
        DaysSinceLastOrderValue: Integer;
        TotalOrdersValue: Integer;

    trigger OnAfterGetRecord()
    begin
        LoadInsights();
    end;

    local procedure LoadInsights()
    begin
        HasInsights := CustomerInsight.Get(Rec."No.");
        if HasInsights then begin
            CustomerTierText := Format(CustomerInsight."Customer Tier");
            ChurnRiskText := Format(CustomerInsight."Churn Risk Level");
            ChurnRiskStyle := GetChurnRiskStyle(CustomerInsight."Churn Risk Level");
            AverageOrderValueText := Format(CustomerInsight."Average Order Value", 0, '<Precision,2:2><Standard Format,0>');
            DaysSinceLastOrderValue := CustomerInsight."Days Since Last Order";
            TotalOrdersValue := CustomerInsight."Total Orders";
        end else begin
            CustomerTierText := 'Not calculated';
            ChurnRiskText := 'Not calculated';
            ChurnRiskStyle := 'Standard';
            AverageOrderValueText := '';
            DaysSinceLastOrderValue := 0;
            TotalOrdersValue := 0;
        end;
    end;

    local procedure GetChurnRiskStyle(pRiskLevel: Option Low,Medium,High,Critical): Text
    begin
        case pRiskLevel of
            pRiskLevel::Critical:
                exit('Unfavorable');
            pRiskLevel::High:
                exit('Attention');
            pRiskLevel::Medium:
                exit('Ambiguous');
            else
                exit('Favorable');
        end;
    end;
}

