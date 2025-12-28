/// <summary>
/// PromptDialog page for Sales Copilot Agent
/// This is the main Copilot interface for sales users
/// </summary>
page 50101 "SJT Sales Copilot Proposal"
{
    Caption = 'Sales Copilot';
    PageType = PromptDialog;
    IsPreview = true;
    Extensible = false;
    DataCaptionExpression = CopilotCaption;

    layout
    {
        area(Prompt)
        {
            field(UserPrompt; UserPromptText)
            {
                Caption = 'What would you like help with?';
                MultiLine = true;
                ApplicationArea = All;
                ToolTip = 'Enter your question or request for the Sales Copilot.';

                trigger OnValidate()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
        area(Content)
        {
            group(SuggestionGroup)
            {
                Caption = 'Copilot Suggestion';
                Visible = HasSuggestion;

                field(SuggestionSummary; SuggestionSummaryText)
                {
                    Caption = 'Summary';
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Summary of the Copilot analysis and recommendation.';
                }
                field(RecommendedValue; RecommendedValueText)
                {
                    Caption = 'Recommended Action';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'The recommended action or value from Copilot.';
                }
                field(ConfidenceLevel; ConfidenceLevelText)
                {
                    Caption = 'Confidence';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Confidence level of the recommendation.';
                }
            }
            group(AnalysisDetails)
            {
                Caption = 'Analysis Details';
                Visible = HasSuggestion;

                field(CustomerTierInfo; CustomerTierInfoText)
                {
                    Caption = 'Customer Tier';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Customer tier classification based on purchase history.';
                }
                field(MarginInfo; MarginInfoText)
                {
                    Caption = 'Margin Impact';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Impact on profit margin.';
                }
                field(InventoryInfo; InventoryInfoText)
                {
                    Caption = 'Inventory Status';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Relevant inventory information.';
                }
            }
            group(AnomalyGroup)
            {
                Caption = 'Detected Anomalies';
                Visible = HasAnomalies;

                field(AnomalyCount; AnomalyCountText)
                {
                    Caption = 'Anomalies Found';
                    ApplicationArea = All;
                    Editable = false;
                    Style = Attention;
                    StyleExpr = true;
                    ToolTip = 'Number of anomalies detected in the order.';
                }
                field(AnomalyDetails; AnomalyDetailsText)
                {
                    Caption = 'Details';
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Details of detected anomalies.';
                }
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate Copilot suggestions based on your input.';

                trigger OnAction()
                begin
                    GenerateSuggestion();
                end;
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate the suggestion with different parameters.';

                trigger OnAction()
                begin
                    GenerateSuggestion();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Apply';
                ToolTip = 'Apply the suggested changes.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
                ToolTip = 'Discard the suggestion and close.';
            }
        }
        area(PromptGuide)
        {
            action(DiscountHelp)
            {
                Caption = 'Suggest optimal discount';
                ToolTip = 'Ask Copilot to suggest an optimal discount for this order.';

                trigger OnAction()
                begin
                    UserPromptText := 'Suggest an optimal discount for this sales order based on customer history and margin targets.';
                    CurrPage.Update(false);
                end;
            }
            action(AnomalyCheck)
            {
                Caption = 'Check for anomalies';
                ToolTip = 'Ask Copilot to check this order for any anomalies.';

                trigger OnAction()
                begin
                    UserPromptText := 'Check this order for any unusual patterns or anomalies.';
                    CurrPage.Update(false);
                end;
            }
            action(CustomerAnalysis)
            {
                Caption = 'Analyze customer';
                ToolTip = 'Get insights about this customer.';

                trigger OnAction()
                begin
                    UserPromptText := 'Analyze this customer and provide insights about their purchasing behavior.';
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        SalesCopilotImpl: Codeunit "SJT Sales Copilot Impl";
        CopilotCaption: Text;
        UserPromptText: Text;
        SuggestionSummaryText: Text;
        RecommendedValueText: Text;
        ConfidenceLevelText: Text;
        CustomerTierInfoText: Text;
        MarginInfoText: Text;
        InventoryInfoText: Text;
        AnomalyCountText: Text;
        AnomalyDetailsText: Text;
        HasSuggestion: Boolean;
        HasAnomalies: Boolean;
        SourceDocType: Enum "Sales Document Type";
        SourceDocNo: Code[20];
        SourceCustomerNo: Code[20];
        SuggestedDiscountPct: Decimal;
        ActionApplied: Boolean;

    /// <summary>
    /// Initializes the Copilot dialog with source document context
    /// </summary>
    procedure Initialize(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; pCustomerNo: Code[20])
    begin
        SourceDocType := pDocType;
        SourceDocNo := pDocNo;
        SourceCustomerNo := pCustomerNo;
        CopilotCaption := StrSubstNo('Sales Copilot - %1 %2', pDocType, pDocNo);
    end;

    /// <summary>
    /// Generates Copilot suggestion based on user prompt
    /// </summary>
    local procedure GenerateSuggestion()
    var
        result: JsonObject;
    begin
        if UserPromptText = '' then begin
            Message('Please enter a question or select a prompt guide option.');
            exit;
        end;

        // Determine action type from prompt
        if ContainsText(UserPromptText, 'discount') then
            result := SalesCopilotImpl.GenerateDiscountRecommendation(SourceDocType, SourceDocNo, SourceCustomerNo)
        else if ContainsText(UserPromptText, 'anomal') or ContainsText(UserPromptText, 'unusual') then
            result := SalesCopilotImpl.DetectOrderAnomalies(SourceDocType, SourceDocNo, SourceCustomerNo)
        else if ContainsText(UserPromptText, 'customer') or ContainsText(UserPromptText, 'analyze') then
            result := SalesCopilotImpl.AnalyzeCustomer(SourceCustomerNo)
        else
            result := SalesCopilotImpl.GenerateDiscountRecommendation(SourceDocType, SourceDocNo, SourceCustomerNo);

        ParseResult(result);
        CurrPage.Update(false);
    end;

    local procedure ContainsText(pSource: Text; pSearch: Text): Boolean
    begin
        exit(StrPos(LowerCase(pSource), LowerCase(pSearch)) > 0);
    end;

    local procedure ParseResult(pResult: JsonObject)
    var
        token: JsonToken;
        anomalyToken: JsonToken;
    begin
        HasSuggestion := true;

        if pResult.Get('summary', token) then
            SuggestionSummaryText := token.AsValue().AsText();

        if pResult.Get('recommendation', token) then
            RecommendedValueText := token.AsValue().AsText();

        if pResult.Get('confidence', token) then
            ConfidenceLevelText := token.AsValue().AsText();

        if pResult.Get('customerTier', token) then
            CustomerTierInfoText := token.AsValue().AsText();

        if pResult.Get('marginImpact', token) then
            MarginInfoText := token.AsValue().AsText();

        if pResult.Get('inventoryStatus', token) then
            InventoryInfoText := token.AsValue().AsText();

        if pResult.Get('suggestedDiscount', token) then
            SuggestedDiscountPct := token.AsValue().AsDecimal();

        if pResult.Get('hasAnomalies', anomalyToken) then begin
            HasAnomalies := anomalyToken.AsValue().AsBoolean();
            if HasAnomalies then begin
                if pResult.Get('anomalyCount', token) then
                    AnomalyCountText := Format(token.AsValue().AsInteger()) + ' anomalies detected';
                if pResult.Get('anomalyDetails', token) then
                    AnomalyDetailsText := token.AsValue().AsText();
            end;
        end;
    end;

    /// <summary>
    /// Returns the suggested discount percentage
    /// </summary>
    procedure GetSuggestedDiscount(): Decimal
    begin
        exit(SuggestedDiscountPct);
    end;

    /// <summary>
    /// Returns whether the action was applied
    /// </summary>
    procedure WasActionApplied(): Boolean
    begin
        exit(ActionApplied);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            ActionApplied := true;
    end;
}

