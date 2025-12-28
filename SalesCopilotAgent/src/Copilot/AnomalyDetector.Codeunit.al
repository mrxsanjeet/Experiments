/// <summary>
/// Codeunit for detecting anomalies in sales orders
/// Checks for quantity spikes, price deviations, and unusual patterns
/// </summary>
codeunit 50102 "SJT Anomaly Detector"
{
    Access = Public;

    var
        Setup: Record "SJT Sales Copilot Setup";
        SetupLoaded: Boolean;

    /// <summary>
    /// Main entry point for anomaly detection
    /// Returns a JSON array of detected anomalies
    /// </summary>
    procedure DetectAnomalies(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; pCustomerNo: Code[20]): JsonArray
    var
        anomalies: JsonArray;
    begin
        LoadSetup();

        // Check for quantity spikes
        CheckQuantitySpikes(pDocType, pDocNo, pCustomerNo, anomalies);

        // Check for price deviations
        CheckPriceDeviations(pDocType, pDocNo, anomalies);

        // Check for new shipping address
        if Setup."Check New Ship-to Address" then
            CheckNewShipToAddress(pDocType, pDocNo, pCustomerNo, anomalies);

        // Store anomalies in database
        StoreAnomalies(pDocType, pDocNo, pCustomerNo, anomalies);

        exit(anomalies);
    end;

    /// <summary>
    /// Checks if any line quantities exceed the customer's average by the configured multiplier
    /// </summary>
    local procedure CheckQuantitySpikes(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; pCustomerNo: Code[20]; var pAnomalies: JsonArray)
    var
        salesLine: Record "Sales Line";
        avgQty: Decimal;
        anomaly: JsonObject;
    begin
        salesLine.SetRange("Document Type", pDocType);
        salesLine.SetRange("Document No.", pDocNo);
        salesLine.SetRange(Type, salesLine.Type::Item);

        if salesLine.FindSet() then
            repeat
                avgQty := GetCustomerAverageQuantity(pCustomerNo, salesLine."No.");
                if (avgQty > 0) and (salesLine.Quantity > avgQty * Setup."Qty Spike Multiplier") then begin
                    Clear(anomaly);
                    anomaly.Add('type', 'Quantity Spike');
                    anomaly.Add('description', StrSubstNo(
                        'Item %1: Quantity %2 is %3x the customer average of %4',
                        salesLine."No.",
                        salesLine.Quantity,
                        Round(salesLine.Quantity / avgQty, 0.1),
                        Round(avgQty, 0.01)
                    ));
                    anomaly.Add('severity', 'Medium');
                    anomaly.Add('lineNo', salesLine."Line No.");
                    anomaly.Add('itemNo', salesLine."No.");
                    anomaly.Add('expectedValue', avgQty);
                    anomaly.Add('actualValue', salesLine.Quantity);
                    pAnomalies.Add(anomaly);
                end;
            until salesLine.Next() = 0;
    end;

    /// <summary>
    /// Gets the average quantity ordered by a customer for a specific item
    /// </summary>
    local procedure GetCustomerAverageQuantity(pCustomerNo: Code[20]; pItemNo: Code[20]): Decimal
    var
        salesInvLine: Record "Sales Invoice Line";
        totalQty: Decimal;
        lineCount: Integer;
        startDate: Date;
    begin
        startDate := CalcDate(StrSubstNo('<-%1M>', Setup."Order History Months"), Today);

        salesInvLine.SetRange("Sell-to Customer No.", pCustomerNo);
        salesInvLine.SetRange("No.", pItemNo);
        salesInvLine.SetRange(Type, salesInvLine.Type::Item);
        salesInvLine.SetFilter("Posting Date", '>=%1', startDate);

        if salesInvLine.FindSet() then
            repeat
                totalQty += salesInvLine.Quantity;
                lineCount += 1;
            until salesInvLine.Next() = 0;

        if lineCount > 0 then
            exit(totalQty / lineCount)
        else
            exit(0);
    end;

    /// <summary>
    /// Checks if any line prices deviate significantly from standard prices
    /// </summary>
    local procedure CheckPriceDeviations(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; var pAnomalies: JsonArray)
    var
        salesLine: Record "Sales Line";
        item: Record Item;
        deviationPct: Decimal;
        anomaly: JsonObject;
    begin
        salesLine.SetRange("Document Type", pDocType);
        salesLine.SetRange("Document No.", pDocNo);
        salesLine.SetRange(Type, salesLine.Type::Item);

        if salesLine.FindSet() then
            repeat
                if item.Get(salesLine."No.") and (item."Unit Price" > 0) then begin
                    deviationPct := ((item."Unit Price" - salesLine."Unit Price") / item."Unit Price") * 100;
                    if deviationPct > Setup."Price Deviation Pct" then begin
                        Clear(anomaly);
                        anomaly.Add('type', 'Price Deviation');
                        anomaly.Add('description', StrSubstNo(
                            'Item %1: Unit price %2 is %3% below standard price %4',
                            salesLine."No.",
                            salesLine."Unit Price",
                            Round(deviationPct, 0.1),
                            item."Unit Price"
                        ));
                        anomaly.Add('severity', 'High');
                        anomaly.Add('lineNo', salesLine."Line No.");
                        anomaly.Add('itemNo', salesLine."No.");
                        anomaly.Add('expectedValue', item."Unit Price");
                        anomaly.Add('actualValue', salesLine."Unit Price");
                        anomaly.Add('deviationPct', deviationPct);
                        pAnomalies.Add(anomaly);
                    end;
                end;
            until salesLine.Next() = 0;
    end;

    /// <summary>
    /// Checks if the order uses a new shipping address for an established customer
    /// </summary>
    local procedure CheckNewShipToAddress(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; pCustomerNo: Code[20]; var pAnomalies: JsonArray)
    var
        salesHeader: Record "Sales Header";
        shipToAddress: Record "Ship-to Address";
        salesInvHeader: Record "Sales Invoice Header";
        isNewAddress: Boolean;
        orderCount: Integer;
        anomaly: JsonObject;
    begin
        if not salesHeader.Get(pDocType, pDocNo) then
            exit;

        // Count historical orders to determine if customer is established
        salesInvHeader.SetRange("Sell-to Customer No.", pCustomerNo);
        orderCount := salesInvHeader.Count;

        // Only check for established customers (5+ orders)
        if orderCount < 5 then
            exit;

        // Check if ship-to code exists in customer's ship-to addresses
        isNewAddress := true;
        if salesHeader."Ship-to Code" <> '' then begin
            if shipToAddress.Get(pCustomerNo, salesHeader."Ship-to Code") then
                isNewAddress := false;
        end else begin
            // Check if address matches any existing ship-to or customer address
            isNewAddress := not IsKnownAddress(pCustomerNo, salesHeader."Ship-to Address", salesHeader."Ship-to City");
        end;

        if isNewAddress then begin
            Clear(anomaly);
            anomaly.Add('type', 'New Ship-to Address');
            anomaly.Add('description', StrSubstNo(
                'Order uses a new shipping address: %1, %2. Customer has %3 previous orders.',
                salesHeader."Ship-to Address",
                salesHeader."Ship-to City",
                orderCount
            ));
            anomaly.Add('severity', 'Medium');
            pAnomalies.Add(anomaly);
        end;
    end;

    /// <summary>
    /// Checks if an address is known for the customer
    /// </summary>
    local procedure IsKnownAddress(pCustomerNo: Code[20]; pAddress: Text[100]; pCity: Text[30]): Boolean
    var
        customer: Record Customer;
        shipToAddress: Record "Ship-to Address";
        salesInvHeader: Record "Sales Invoice Header";
    begin
        // Check customer's main address
        if customer.Get(pCustomerNo) then
            if (customer.Address = pAddress) and (customer.City = pCity) then
                exit(true);

        // Check ship-to addresses
        shipToAddress.SetRange("Customer No.", pCustomerNo);
        if shipToAddress.FindSet() then
            repeat
                if (shipToAddress.Address = pAddress) and (shipToAddress.City = pCity) then
                    exit(true);
            until shipToAddress.Next() = 0;

        // Check historical invoices
        salesInvHeader.SetRange("Sell-to Customer No.", pCustomerNo);
        if salesInvHeader.FindSet() then
            repeat
                if (salesInvHeader."Ship-to Address" = pAddress) and (salesInvHeader."Ship-to City" = pCity) then
                    exit(true);
            until salesInvHeader.Next() = 0;

        exit(false);
    end;

    /// <summary>
    /// Stores detected anomalies in the database for tracking
    /// </summary>
    local procedure StoreAnomalies(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; pCustomerNo: Code[20]; pAnomalies: JsonArray)
    var
        anomalyEntry: Record "SJT Order Anomaly Entry";
        token: JsonToken;
        anomaly: JsonObject;
        typeToken: JsonToken;
        descToken: JsonToken;
        severityToken: JsonToken;
        lineNoToken: JsonToken;
        itemNoToken: JsonToken;
        expectedToken: JsonToken;
        actualToken: JsonToken;
        deviationToken: JsonToken;
        i: Integer;
    begin
        for i := 0 to pAnomalies.Count - 1 do begin
            pAnomalies.Get(i, token);
            anomaly := token.AsObject();

            anomalyEntry.Init();
            anomalyEntry."Document Type" := pDocType;
            anomalyEntry."Document No." := pDocNo;
            anomalyEntry."Customer No." := pCustomerNo;

            if anomaly.Get('type', typeToken) then
                anomalyEntry."Anomaly Type" := ParseAnomalyType(typeToken.AsValue().AsText());

            if anomaly.Get('description', descToken) then
                anomalyEntry.Description := CopyStr(descToken.AsValue().AsText(), 1, MaxStrLen(anomalyEntry.Description));

            if anomaly.Get('severity', severityToken) then
                anomalyEntry.Severity := ParseSeverity(severityToken.AsValue().AsText());

            if anomaly.Get('lineNo', lineNoToken) then
                anomalyEntry."Line No." := lineNoToken.AsValue().AsInteger();

            if anomaly.Get('itemNo', itemNoToken) then
                anomalyEntry."Item No." := CopyStr(itemNoToken.AsValue().AsText(), 1, MaxStrLen(anomalyEntry."Item No."));

            if anomaly.Get('expectedValue', expectedToken) then
                anomalyEntry."Expected Value" := expectedToken.AsValue().AsDecimal();

            if anomaly.Get('actualValue', actualToken) then
                anomalyEntry."Actual Value" := actualToken.AsValue().AsDecimal();

            if anomaly.Get('deviationPct', deviationToken) then
                anomalyEntry."Deviation Pct" := deviationToken.AsValue().AsDecimal();

            anomalyEntry.Recommendation := GetRecommendation(anomalyEntry."Anomaly Type");
            anomalyEntry.Insert(true);
        end;
    end;

    local procedure ParseAnomalyType(pType: Text): Enum "SJT Anomaly Type"
    begin
        case pType of
            'Quantity Spike':
                exit("SJT Anomaly Type"::"Quantity Spike");
            'Price Deviation':
                exit("SJT Anomaly Type"::"Price Deviation");
            'New Ship-to Address':
                exit("SJT Anomaly Type"::"New Ship-to Address");
            else
                exit("SJT Anomaly Type"::None);
        end;
    end;

    local procedure ParseSeverity(pSeverity: Text): Integer
    begin
        case pSeverity of
            'Low':
                exit(0);
            'Medium':
                exit(1);
            'High':
                exit(2);
            'Critical':
                exit(3);
            else
                exit(0);
        end;
    end;

    local procedure GetRecommendation(pType: Enum "SJT Anomaly Type"): Text[500]
    begin
        case pType of
            "SJT Anomaly Type"::"Quantity Spike":
                exit('Verify the quantity with the customer. Check if this is a special order or bulk purchase.');
            "SJT Anomaly Type"::"Price Deviation":
                exit('Review the pricing. Ensure proper authorization for discounts below standard price.');
            "SJT Anomaly Type"::"New Ship-to Address":
                exit('Confirm the new shipping address with the customer before processing.');
            else
                exit('Review the order details before processing.');
        end;
    end;

    local procedure LoadSetup()
    begin
        if SetupLoaded then
            exit;
        Setup.GetSetup();
        SetupLoaded := true;
    end;
}

