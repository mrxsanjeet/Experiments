/// <summary>
/// Codeunit for calculating and updating customer insights
/// Used for customer tier classification and churn risk prediction
/// </summary>
codeunit 50103 "SJT Customer Insight Calc"
{
    Access = Public;

    var
        Setup: Record "SJT Sales Copilot Setup";
        SetupLoaded: Boolean;

    /// <summary>
    /// Calculates and stores insights for a specific customer
    /// </summary>
    procedure CalculateCustomerInsight(pCustomerNo: Code[20])
    var
        insight: Record "SJT Customer Insight";
        discountCalc: Codeunit "SJT Discount Calculator";
        isNew: Boolean;
    begin
        LoadSetup();

        isNew := not insight.Get(pCustomerNo);
        if isNew then begin
            insight.Init();
            insight."Customer No." := pCustomerNo;
        end;

        // Calculate tier
        insight."Customer Tier" := discountCalc.CalculateCustomerTier(pCustomerNo);

        // Calculate sales metrics
        CalculateSalesMetrics(pCustomerNo, insight);

        // Calculate order frequency
        CalculateOrderFrequency(pCustomerNo, insight);

        // Calculate discount history
        CalculateDiscountHistory(pCustomerNo, insight);

        // Calculate churn risk
        CalculateChurnRisk(insight);

        // Calculate ship-to address info
        CalculateShipToInfo(pCustomerNo, insight);

        insight."Last Calculated DateTime" := CurrentDateTime;

        if isNew then
            insight.Insert(true)
        else
            insight.Modify(true);
    end;

    /// <summary>
    /// Calculates total sales, order count, and average order value
    /// </summary>
    local procedure CalculateSalesMetrics(pCustomerNo: Code[20]; var pInsight: Record "SJT Customer Insight")
    var
        salesInvHeader: Record "Sales Invoice Header";
        salesInvLine: Record "Sales Invoice Line";
        totalAmount: Decimal;
        orderCount: Integer;
        itemQty: Dictionary of [Code[20], Decimal];
        itemNo: Code[20];
        maxQty: Decimal;
        qty: Decimal;
    begin
        salesInvHeader.SetRange("Sell-to Customer No.", pCustomerNo);
        orderCount := salesInvHeader.Count;

        salesInvLine.SetRange("Sell-to Customer No.", pCustomerNo);
        salesInvLine.SetRange(Type, salesInvLine.Type::Item);
        if salesInvLine.FindSet() then
            repeat
                totalAmount += salesInvLine."Line Amount";

                // Track most ordered item
                if itemQty.ContainsKey(salesInvLine."No.") then begin
                    qty := itemQty.Get(salesInvLine."No.") + salesInvLine.Quantity;
                    itemQty.Set(salesInvLine."No.", qty);
                end else
                    itemQty.Add(salesInvLine."No.", salesInvLine.Quantity);
            until salesInvLine.Next() = 0;

        pInsight."Total Sales Amount" := totalAmount;
        pInsight."Total Orders" := orderCount;

        if orderCount > 0 then
            pInsight."Average Order Value" := totalAmount / orderCount
        else
            pInsight."Average Order Value" := 0;

        // Find most ordered item
        maxQty := 0;
        foreach itemNo in itemQty.Keys do begin
            qty := itemQty.Get(itemNo);
            if qty > maxQty then begin
                maxQty := qty;
                pInsight."Most Ordered Item No." := itemNo;
                pInsight."Most Ordered Item Qty" := qty;
            end;
        end;
    end;

    /// <summary>
    /// Calculates order frequency and days since last order
    /// </summary>
    local procedure CalculateOrderFrequency(pCustomerNo: Code[20]; var pInsight: Record "SJT Customer Insight")
    var
        salesInvHeader: Record "Sales Invoice Header";
        firstOrderDate: Date;
        lastOrderDate: Date;
        orderCount: Integer;
        daysBetween: Integer;
    begin
        salesInvHeader.SetRange("Sell-to Customer No.", pCustomerNo);
        salesInvHeader.SetCurrentKey("Posting Date");

        if salesInvHeader.FindFirst() then
            firstOrderDate := salesInvHeader."Posting Date";

        if salesInvHeader.FindLast() then begin
            lastOrderDate := salesInvHeader."Posting Date";
            pInsight."Last Order Date" := lastOrderDate;
            pInsight."Days Since Last Order" := Today - lastOrderDate;
        end;

        orderCount := salesInvHeader.Count;
        if orderCount > 1 then begin
            daysBetween := lastOrderDate - firstOrderDate;
            pInsight."Average Order Frequency Days" := daysBetween / (orderCount - 1);
        end else
            pInsight."Average Order Frequency Days" := 0;
    end;

    /// <summary>
    /// Calculates average and maximum discounts given to customer
    /// </summary>
    local procedure CalculateDiscountHistory(pCustomerNo: Code[20]; var pInsight: Record "SJT Customer Insight")
    var
        salesInvLine: Record "Sales Invoice Line";
        totalDiscount: Decimal;
        lineCount: Integer;
        maxDiscount: Decimal;
    begin
        salesInvLine.SetRange("Sell-to Customer No.", pCustomerNo);
        salesInvLine.SetFilter("Line Discount %", '>0');

        if salesInvLine.FindSet() then
            repeat
                totalDiscount += salesInvLine."Line Discount %";
                lineCount += 1;
                if salesInvLine."Line Discount %" > maxDiscount then
                    maxDiscount := salesInvLine."Line Discount %";
            until salesInvLine.Next() = 0;

        if lineCount > 0 then
            pInsight."Average Discount Pct" := totalDiscount / lineCount
        else
            pInsight."Average Discount Pct" := 0;

        pInsight."Max Discount Given Pct" := maxDiscount;
    end;

    /// <summary>
    /// Calculates churn risk based on order frequency decline
    /// Score: 0-100 where higher = higher risk
    /// </summary>
    local procedure CalculateChurnRisk(var pInsight: Record "SJT Customer Insight")
    var
        riskScore: Decimal;
        frequencyFactor: Decimal;
        recencyFactor: Decimal;
    begin
        // Factor 1: Days since last order vs average frequency
        if pInsight."Average Order Frequency Days" > 0 then begin
            frequencyFactor := pInsight."Days Since Last Order" / pInsight."Average Order Frequency Days";
            // If days since last order > 2x average frequency, high risk
            if frequencyFactor > 3 then
                riskScore += 50
            else if frequencyFactor > 2 then
                riskScore += 35
            else if frequencyFactor > 1.5 then
                riskScore += 20
            else if frequencyFactor > 1 then
                riskScore += 10;
        end;

        // Factor 2: Absolute recency
        recencyFactor := pInsight."Days Since Last Order";
        if recencyFactor > 180 then
            riskScore += 50
        else if recencyFactor > 90 then
            riskScore += 30
        else if recencyFactor > 60 then
            riskScore += 15
        else if recencyFactor > 30 then
            riskScore += 5;

        // Cap at 100
        if riskScore > 100 then
            riskScore := 100;

        pInsight."Churn Risk Score" := riskScore;

        // Set risk level
        if riskScore >= 70 then
            pInsight."Churn Risk Level" := pInsight."Churn Risk Level"::Critical
        else if riskScore >= 50 then
            pInsight."Churn Risk Level" := pInsight."Churn Risk Level"::High
        else if riskScore >= 25 then
            pInsight."Churn Risk Level" := pInsight."Churn Risk Level"::Medium
        else
            pInsight."Churn Risk Level" := pInsight."Churn Risk Level"::Low;
    end;

    /// <summary>
    /// Calculates ship-to address information
    /// </summary>
    local procedure CalculateShipToInfo(pCustomerNo: Code[20]; var pInsight: Record "SJT Customer Insight")
    var
        shipToAddress: Record "Ship-to Address";
        salesInvHeader: Record "Sales Invoice Header";
        shipToCount: Dictionary of [Code[10], Integer];
        shipToCode: Code[10];
        maxCount: Integer;
        count: Integer;
    begin
        // Count ship-to addresses
        shipToAddress.SetRange("Customer No.", pCustomerNo);
        pInsight."Ship-to Address Count" := shipToAddress.Count;

        // Find most used ship-to code
        salesInvHeader.SetRange("Sell-to Customer No.", pCustomerNo);
        if salesInvHeader.FindSet() then
            repeat
                shipToCode := salesInvHeader."Ship-to Code";
                if shipToCount.ContainsKey(shipToCode) then begin
                    count := shipToCount.Get(shipToCode) + 1;
                    shipToCount.Set(shipToCode, count);
                end else
                    shipToCount.Add(shipToCode, 1);
            until salesInvHeader.Next() = 0;

        maxCount := 0;
        foreach shipToCode in shipToCount.Keys do begin
            count := shipToCount.Get(shipToCode);
            if count > maxCount then begin
                maxCount := count;
                pInsight."Primary Ship-to Code" := shipToCode;
            end;
        end;
    end;

    /// <summary>
    /// Batch calculates insights for all customers
    /// </summary>
    procedure CalculateAllCustomerInsights()
    var
        customer: Record Customer;
        progressDialog: Dialog;
        counter: Integer;
        total: Integer;
    begin
        total := customer.Count;
        counter := 0;

        progressDialog.Open('Calculating customer insights...\Customer: #1#####\Progress: #2### of #3###');

        if customer.FindSet() then
            repeat
                counter += 1;
                progressDialog.Update(1, customer."No.");
                progressDialog.Update(2, counter);
                progressDialog.Update(3, total);

                CalculateCustomerInsight(customer."No.");
            until customer.Next() = 0;

        progressDialog.Close();
        Message('Customer insights calculated for %1 customers.', counter);
    end;

    local procedure LoadSetup()
    begin
        if SetupLoaded then
            exit;
        Setup.GetSetup();
        SetupLoaded := true;
    end;
}

