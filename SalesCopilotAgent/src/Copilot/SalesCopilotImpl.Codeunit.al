/// <summary>
/// Main implementation codeunit for Sales Copilot Agent
/// Contains business logic for discount recommendations and anomaly detection
/// </summary>
codeunit 50100 "SJT Sales Copilot Impl"
{
    Access = Public;

    var
        Setup: Record "SJT Sales Copilot Setup";
        SetupLoaded: Boolean;

    /// <summary>
    /// Generates intelligent discount recommendation for a sales order
    /// Analyzes: customer tier, order volume, inventory aging, margin targets
    /// </summary>
    procedure GenerateDiscountRecommendation(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; pCustomerNo: Code[20]) result: JsonObject
    var
        salesHeader: Record "Sales Header";
        customerInsight: Record "SJT Customer Insight";
        discountCalc: Codeunit "SJT Discount Calculator";
        baseDiscount: Decimal;
        tierBonus: Decimal;
        inventoryBonus: Decimal;
        finalDiscount: Decimal;
        marginPct: Decimal;
        orderAmount: Decimal;
        customerTier: Enum "SJT Customer Tier";
        hasSlowMoving: Boolean;
        slowMovingItems: Text;
    begin
        LoadSetup();

        if not Setup."Enable Discount Copilot" then begin
            result.Add('summary', 'Discount Copilot is disabled in setup.');
            result.Add('recommendation', 'Please enable Discount Copilot in Sales Copilot Setup.');
            result.Add('confidence', 'N/A');
            exit;
        end;

        // Get sales header
        if not salesHeader.Get(pDocType, pDocNo) then begin
            result.Add('summary', 'Sales document not found.');
            result.Add('recommendation', 'Unable to analyze - document not found.');
            result.Add('confidence', 'N/A');
            exit;
        end;

        // Calculate customer tier and get insights
        customerTier := discountCalc.CalculateCustomerTier(pCustomerNo);
        EnsureCustomerInsight(pCustomerNo, customerInsight);

        // Calculate order amount and margin
        orderAmount := discountCalc.CalculateOrderAmount(pDocType, pDocNo);
        marginPct := discountCalc.CalculateOrderMargin(pDocType, pDocNo);

        // Check for slow-moving inventory
        hasSlowMoving := discountCalc.HasSlowMovingItems(pDocType, pDocNo, slowMovingItems);

        // Calculate discount components
        baseDiscount := discountCalc.CalculateBaseDiscount(orderAmount);
        tierBonus := discountCalc.GetTierDiscountBonus(customerTier);
        inventoryBonus := 0;
        if hasSlowMoving then
            inventoryBonus := Setup."Slow Moving Discount Bonus Pct";

        // Calculate final discount ensuring margin target is met
        finalDiscount := discountCalc.CalculateFinalDiscount(
            baseDiscount + tierBonus + inventoryBonus,
            marginPct,
            Setup."Min Margin Pct",
            Setup."Max Discount Pct"
        );

        // Build result
        result.Add('summary', BuildDiscountSummary(customerTier, orderAmount, finalDiscount, marginPct, hasSlowMoving));
        result.Add('recommendation', StrSubstNo('Recommended discount: %1%', Format(finalDiscount, 0, '<Precision,2:2><Standard Format,0>')));
        result.Add('confidence', GetConfidenceLevel(customerInsight."Total Orders"));
        result.Add('customerTier', Format(customerTier));
        result.Add('marginImpact', StrSubstNo('Maintains %1% margin after discount', Format(marginPct - finalDiscount, 0, '<Precision,1:1><Standard Format,0>')));
        result.Add('inventoryStatus', GetInventoryStatus(hasSlowMoving, slowMovingItems));
        result.Add('suggestedDiscount', finalDiscount);
        result.Add('hasAnomalies', false);

        // Log suggestion
        LogSuggestion(
            "SJT Sales Copilot Action"::"Discount Recommendation",
            pDocNo,
            pCustomerNo,
            result,
            finalDiscount,
            customerTier,
            orderAmount,
            marginPct
        );
    end;

    local procedure BuildDiscountSummary(pTier: Enum "SJT Customer Tier"; pAmount: Decimal; pDiscount: Decimal; pMargin: Decimal; pHasSlowMoving: Boolean): Text
    var
        summary: TextBuilder;
    begin
        summary.AppendLine(StrSubstNo('Customer Tier: %1', pTier));
        summary.AppendLine(StrSubstNo('Order Value: %1', Format(pAmount, 0, '<Precision,2:2><Standard Format,0>')));
        summary.AppendLine(StrSubstNo('Current Margin: %1%', Format(pMargin, 0, '<Precision,1:1><Standard Format,0>')));
        if pHasSlowMoving then
            summary.AppendLine('Contains slow-moving inventory items - additional discount applied.');
        summary.AppendLine(StrSubstNo('Recommended Discount: %1%', Format(pDiscount, 0, '<Precision,2:2><Standard Format,0>')));
        exit(summary.ToText());
    end;

    local procedure GetConfidenceLevel(pOrderCount: Integer): Text
    begin
        if pOrderCount >= 20 then
            exit('High (based on 20+ historical orders)')
        else if pOrderCount >= 10 then
            exit('Medium (based on 10-19 historical orders)')
        else if pOrderCount >= 5 then
            exit('Low (based on 5-9 historical orders)')
        else
            exit('Very Low (limited order history)');
    end;

    local procedure GetInventoryStatus(pHasSlowMoving: Boolean; pItems: Text): Text
    begin
        if pHasSlowMoving then
            exit(StrSubstNo('Slow-moving items detected: %1', pItems))
        else
            exit('All items have normal inventory turnover.');
    end;

    local procedure LoadSetup()
    begin
        if SetupLoaded then
            exit;
        Setup.GetSetup();
        SetupLoaded := true;
    end;

    local procedure EnsureCustomerInsight(pCustomerNo: Code[20]; var pInsight: Record "SJT Customer Insight")
    var
        insightCalc: Codeunit "SJT Customer Insight Calc";
    begin
        if not pInsight.Get(pCustomerNo) then begin
            insightCalc.CalculateCustomerInsight(pCustomerNo);
            pInsight.Get(pCustomerNo);
        end else if pInsight."Last Calculated DateTime" < CreateDateTime(Today - 1, 0T) then begin
            insightCalc.CalculateCustomerInsight(pCustomerNo);
            pInsight.Get(pCustomerNo);
        end;
    end;

    /// <summary>
    /// Detects anomalies in a sales order
    /// Checks: quantity spikes, price deviations, new shipping addresses
    /// </summary>
    procedure DetectOrderAnomalies(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; pCustomerNo: Code[20]) result: JsonObject
    var
        anomalyDetector: Codeunit "SJT Anomaly Detector";
        anomalies: JsonArray;
        anomalyCount: Integer;
        detailsText: TextBuilder;
        hasAnomalies: Boolean;
    begin
        LoadSetup();

        if not Setup."Enable Anomaly Detection" then begin
            result.Add('summary', 'Anomaly Detection is disabled in setup.');
            result.Add('recommendation', 'Please enable Anomaly Detection in Sales Copilot Setup.');
            result.Add('hasAnomalies', false);
            exit;
        end;

        // Run anomaly detection
        anomalies := anomalyDetector.DetectAnomalies(pDocType, pDocNo, pCustomerNo);
        anomalyCount := anomalies.Count;
        hasAnomalies := anomalyCount > 0;

        if hasAnomalies then begin
            result.Add('summary', StrSubstNo('%1 potential anomalies detected in this order. Please review before processing.', anomalyCount));
            result.Add('recommendation', 'Review the flagged items and verify with the customer if necessary.');
            detailsText := BuildAnomalyDetails(anomalies);
            result.Add('anomalyDetails', detailsText.ToText());
        end else begin
            result.Add('summary', 'No anomalies detected. This order appears normal based on customer history.');
            result.Add('recommendation', 'Order can be processed normally.');
        end;

        result.Add('hasAnomalies', hasAnomalies);
        result.Add('anomalyCount', anomalyCount);
        result.Add('confidence', 'High');
    end;

    local procedure BuildAnomalyDetails(pAnomalies: JsonArray): TextBuilder
    var
        details: TextBuilder;
        token: JsonToken;
        anomaly: JsonObject;
        typeToken: JsonToken;
        descToken: JsonToken;
        i: Integer;
    begin
        for i := 0 to pAnomalies.Count - 1 do begin
            pAnomalies.Get(i, token);
            anomaly := token.AsObject();
            if anomaly.Get('type', typeToken) and anomaly.Get('description', descToken) then begin
                details.AppendLine(StrSubstNo('• %1: %2', typeToken.AsValue().AsText(), descToken.AsValue().AsText()));
            end;
        end;
        exit(details);
    end;

    /// <summary>
    /// Analyzes customer and provides insights
    /// </summary>
    procedure AnalyzeCustomer(pCustomerNo: Code[20]) result: JsonObject
    var
        customer: Record Customer;
        customerInsight: Record "SJT Customer Insight";
        discountCalc: Codeunit "SJT Discount Calculator";
        customerTier: Enum "SJT Customer Tier";
        summary: TextBuilder;
    begin
        if not customer.Get(pCustomerNo) then begin
            result.Add('summary', 'Customer not found.');
            result.Add('hasAnomalies', false);
            exit;
        end;

        EnsureCustomerInsight(pCustomerNo, customerInsight);
        customerTier := discountCalc.CalculateCustomerTier(pCustomerNo);

        summary.AppendLine(StrSubstNo('Customer: %1 - %2', customer."No.", customer.Name));
        summary.AppendLine(StrSubstNo('Tier: %1', customerTier));
        summary.AppendLine(StrSubstNo('Total Sales: %1', Format(customerInsight."Total Sales Amount", 0, '<Precision,2:2><Standard Format,0>')));
        summary.AppendLine(StrSubstNo('Total Orders: %1', customerInsight."Total Orders"));
        summary.AppendLine(StrSubstNo('Average Order Value: %1', Format(customerInsight."Average Order Value", 0, '<Precision,2:2><Standard Format,0>')));
        summary.AppendLine(StrSubstNo('Days Since Last Order: %1', customerInsight."Days Since Last Order"));
        summary.AppendLine(StrSubstNo('Churn Risk: %1', customerInsight."Churn Risk Level"));

        result.Add('summary', summary.ToText());
        result.Add('recommendation', GetCustomerRecommendation(customerInsight));
        result.Add('confidence', GetConfidenceLevel(customerInsight."Total Orders"));
        result.Add('customerTier', Format(customerTier));
        result.Add('hasAnomalies', false);
    end;

    local procedure GetCustomerRecommendation(pInsight: Record "SJT Customer Insight"): Text
    begin
        case pInsight."Churn Risk Level" of
            pInsight."Churn Risk Level"::Critical:
                exit('URGENT: Customer at high risk of churning. Consider proactive outreach with special offer.');
            pInsight."Churn Risk Level"::High:
                exit('Customer showing signs of reduced engagement. Recommend follow-up call.');
            pInsight."Churn Risk Level"::Medium:
                exit('Customer engagement is moderate. Monitor for changes.');
            else
                exit('Customer is actively engaged. Maintain current relationship.');
        end;
    end;

    local procedure LogSuggestion(pAction: Enum "SJT Sales Copilot Action"; pDocNo: Code[20]; pCustomerNo: Code[20]; pResult: JsonObject; pSuggestedValue: Decimal; pTier: Enum "SJT Customer Tier"; pOrderAmount: Decimal; pMarginPct: Decimal)
    var
        suggestionLog: Record "SJT Copilot Suggestion Log";
        summaryToken: JsonToken;
    begin
        if not Setup."Log Suggestions" then
            exit;

        suggestionLog.Init();
        suggestionLog."Action Type" := pAction;
        suggestionLog."Source Document Type" := suggestionLog."Source Document Type"::"Sales Order";
        suggestionLog."Source Document No." := pDocNo;
        suggestionLog."Customer No." := pCustomerNo;
        if pResult.Get('summary', summaryToken) then
            suggestionLog."Suggestion Text" := CopyStr(summaryToken.AsValue().AsText(), 1, MaxStrLen(suggestionLog."Suggestion Text"));
        suggestionLog."Suggested Value" := pSuggestedValue;
        suggestionLog.Status := suggestionLog.Status::Pending;
        suggestionLog."Customer Tier" := pTier;
        suggestionLog."Order Amount" := pOrderAmount;
        suggestionLog."Calculated Margin Pct" := pMarginPct;
        suggestionLog.SetAnalysisDetails(pResult);
        suggestionLog.Insert(true);
    end;
}

