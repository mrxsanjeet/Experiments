/// <summary>
/// Codeunit for calculating intelligent discounts based on multiple factors
/// </summary>
codeunit 50101 "SJT Discount Calculator"
{
    Access = Public;

    var
        Setup: Record "SJT Sales Copilot Setup";
        SetupLoaded: Boolean;

    /// <summary>
    /// Calculates customer tier based on total sales history
    /// </summary>
    procedure CalculateCustomerTier(pCustomerNo: Code[20]): Enum "SJT Customer Tier"
    var
        custLedgerEntry: Record "Cust. Ledger Entry";
        totalSales: Decimal;
    begin
        LoadSetup();

        custLedgerEntry.SetRange("Customer No.", pCustomerNo);
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Invoice);
        custLedgerEntry.CalcSums("Sales (LCY)");
        totalSales := Abs(custLedgerEntry."Sales (LCY)");

        if totalSales >= Setup."Platinum Tier Min Amount" then
            exit("SJT Customer Tier"::Platinum)
        else if totalSales >= Setup."Gold Tier Min Amount" then
            exit("SJT Customer Tier"::Gold)
        else if totalSales >= Setup."Silver Tier Min Amount" then
            exit("SJT Customer Tier"::Silver)
        else if totalSales >= Setup."Bronze Tier Min Amount" then
            exit("SJT Customer Tier"::Bronze)
        else
            exit("SJT Customer Tier"::Standard);
    end;

    /// <summary>
    /// Gets the discount bonus percentage for a customer tier
    /// </summary>
    procedure GetTierDiscountBonus(pTier: Enum "SJT Customer Tier"): Decimal
    begin
        LoadSetup();

        case pTier of
            "SJT Customer Tier"::Platinum:
                exit(Setup."Platinum Discount Bonus Pct");
            "SJT Customer Tier"::Gold:
                exit(Setup."Gold Discount Bonus Pct");
            "SJT Customer Tier"::Silver:
                exit(Setup."Silver Discount Bonus Pct");
            "SJT Customer Tier"::Bronze:
                exit(Setup."Bronze Discount Bonus Pct");
            else
                exit(0);
        end;
    end;

    /// <summary>
    /// Calculates base discount based on order amount
    /// Uses a tiered approach: larger orders get better base discounts
    /// </summary>
    procedure CalculateBaseDiscount(pOrderAmount: Decimal): Decimal
    begin
        // Base discount tiers based on order value
        if pOrderAmount >= 50000 then
            exit(5)
        else if pOrderAmount >= 25000 then
            exit(3)
        else if pOrderAmount >= 10000 then
            exit(2)
        else if pOrderAmount >= 5000 then
            exit(1)
        else
            exit(0);
    end;

    /// <summary>
    /// Calculates total order amount from sales lines
    /// </summary>
    procedure CalculateOrderAmount(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]): Decimal
    var
        salesLine: Record "Sales Line";
        totalAmount: Decimal;
    begin
        salesLine.SetRange("Document Type", pDocType);
        salesLine.SetRange("Document No.", pDocNo);
        salesLine.SetFilter(Type, '<>%1', salesLine.Type::" ");

        if salesLine.FindSet() then
            repeat
                totalAmount += salesLine."Line Amount";
            until salesLine.Next() = 0;

        exit(totalAmount);
    end;

    /// <summary>
    /// Calculates the average margin percentage for the order
    /// </summary>
    procedure CalculateOrderMargin(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]): Decimal
    var
        salesLine: Record "Sales Line";
        totalRevenue: Decimal;
        totalCost: Decimal;
        marginPct: Decimal;
    begin
        salesLine.SetRange("Document Type", pDocType);
        salesLine.SetRange("Document No.", pDocNo);
        salesLine.SetRange(Type, salesLine.Type::Item);

        if salesLine.FindSet() then
            repeat
                totalRevenue += salesLine."Line Amount";
                totalCost += salesLine."Unit Cost (LCY)" * salesLine.Quantity;
            until salesLine.Next() = 0;

        if totalRevenue > 0 then
            marginPct := ((totalRevenue - totalCost) / totalRevenue) * 100
        else
            marginPct := 0;

        exit(marginPct);
    end;

    /// <summary>
    /// Checks if order contains slow-moving inventory items
    /// </summary>
    procedure HasSlowMovingItems(pDocType: Enum "Sales Document Type"; pDocNo: Code[20]; var pSlowMovingItems: Text): Boolean
    var
        salesLine: Record "Sales Line";
        itemLedgerEntry: Record "Item Ledger Entry";
        hasSlowMoving: Boolean;
        itemList: TextBuilder;
        lastReceiptDate: Date;
        ageInDays: Integer;
    begin
        LoadSetup();
        hasSlowMoving := false;

        salesLine.SetRange("Document Type", pDocType);
        salesLine.SetRange("Document No.", pDocNo);
        salesLine.SetRange(Type, salesLine.Type::Item);

        if salesLine.FindSet() then
            repeat
                // Find oldest inventory for this item
                itemLedgerEntry.SetRange("Item No.", salesLine."No.");
                itemLedgerEntry.SetRange("Entry Type", itemLedgerEntry."Entry Type"::Purchase);
                itemLedgerEntry.SetFilter("Remaining Quantity", '>0');
                if itemLedgerEntry.FindFirst() then begin
                    lastReceiptDate := itemLedgerEntry."Posting Date";
                    ageInDays := Today - lastReceiptDate;
                    if ageInDays > Setup."Inventory Age Threshold Days" then begin
                        hasSlowMoving := true;
                        if itemList.Length > 0 then
                            itemList.Append(', ');
                        itemList.Append(salesLine."No.");
                    end;
                end;
            until salesLine.Next() = 0;

        pSlowMovingItems := itemList.ToText();
        exit(hasSlowMoving);
    end;

    /// <summary>
    /// Calculates final discount ensuring margin target is met
    /// </summary>
    procedure CalculateFinalDiscount(pProposedDiscount: Decimal; pCurrentMargin: Decimal; pMinMargin: Decimal; pMaxDiscount: Decimal): Decimal
    var
        maxAllowedDiscount: Decimal;
        finalDiscount: Decimal;
    begin
        // Calculate maximum discount that still maintains minimum margin
        maxAllowedDiscount := pCurrentMargin - pMinMargin;
        if maxAllowedDiscount < 0 then
            maxAllowedDiscount := 0;

        // Apply constraints
        finalDiscount := pProposedDiscount;

        // Don't exceed max allowed by margin
        if finalDiscount > maxAllowedDiscount then
            finalDiscount := maxAllowedDiscount;

        // Don't exceed configured maximum
        if finalDiscount > pMaxDiscount then
            finalDiscount := pMaxDiscount;

        // Round to 2 decimal places
        finalDiscount := Round(finalDiscount, 0.01);

        exit(finalDiscount);
    end;

    local procedure LoadSetup()
    begin
        if SetupLoaded then
            exit;
        Setup.GetSetup();
        SetupLoaded := true;
    end;
}

