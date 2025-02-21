page 80100 "Rolling 12-Month Trial Balance"
{
    PageType = List;
    //ApplicationArea = All;
    SourceTable = "Trial Balance Entity Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Name"; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Account Name';
                }

                field("Current Month"; GetBalance(0))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(0)';
                }

                field("Previous Month 1"; GetBalance(-1))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-1)';
                }

                field("Previous Month 2"; GetBalance(-2))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-2)';
                }

                field("Previous Month 3"; GetBalance(-3))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-3)';
                }

                field("Previous Month 4"; GetBalance(-4))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-4)';
                }

                field("Previous Month 5"; GetBalance(-5))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-5)';
                }

                field("Previous Month 6"; GetBalance(-6))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-6)';
                }

                field("Previous Month 7"; GetBalance(-7))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-7)';
                }

                field("Previous Month 8"; GetBalance(-8))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-8)';
                }

                field("Previous Month 9"; GetBalance(-9))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-9)';
                }

                field("Previous Month 10"; GetBalance(-10))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-10)';
                }

                field("Previous Month 11"; GetBalance(-11))
                {
                    ApplicationArea = All;
                    Caption = 'FormatMonth(-11)';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Refresh Balances")
            {
                ApplicationArea = All;
                Caption = 'Refresh Balances';
                trigger OnAction()
                begin
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        DateTimeMgt: Codeunit "Date-Time Management";

    local procedure GetBalance(MonthOffset: Integer): Decimal
    var
        TrialBalanceBuffer: Record "Trial Balance Entity Buffer";
        StartDate, EndDate : Date;
    begin
        // Calculate the month range based on offset
        StartDate := DateTimeMgt.GetStartOfMonth(DateTimeMgt.AddMonths(Today(), MonthOffset));
        EndDate := DateTimeMgt.GetEndOfMonth(DateTimeMgt.AddMonths(Today(), MonthOffset));

        // Filter and calculate the balance
        TrialBalanceBuffer.Reset();
        TrialBalanceBuffer.SetRange("Date Filter", StartDate, EndDate);//sanjeet
        if TrialBalanceBuffer.FindSet() then begin
            exit(SumTrialBalance(TrialBalanceBuffer));
        end;

        exit(0);
    end;

    local procedure SumTrialBalance(TrialBalanceBuffer: Record "Trial Balance Entity Buffer"): Decimal
    var
        Balance: Decimal;
    begin
        Balance := 0;
        repeat
            if TrialBalanceBuffer."Account Type" = TrialBalanceBuffer."Account Types"::Posting then//sanjeet
                Balance -= TrialBalanceBuffer."Balance Amount"
            else
                Balance += TrialBalanceBuffer."Balance Amount";
        until TrialBalanceBuffer.Next() = 0;

        exit(Balance);
    end;

    local procedure FormatMonth(MonthOffset: Integer): Text[30]
    begin
        exit(Format(DateTimeMgt.AddMonths(Today(), MonthOffset), 0, '<Month Text>') + ' ' + Format(DateTimeMgt.AddMonths(Today(), MonthOffset), 0, '<Year>'));
    end;
}
