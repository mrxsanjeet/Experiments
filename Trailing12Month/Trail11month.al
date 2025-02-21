pageextension 55021 "G/L Account Balance Ext" extends "G/L Account Balance"
{
    layout
    {
        addafter(GLBalanceLines)
        {
            group("Rolling 12-Month Balances")
            {
                Caption = 'Rolling 12-Month Balances';
                field("Balance - Current Month"; GetBalanceForMonth(0))
                {
                    ApplicationArea = All;
                    Caption = 'Current Month';
                    ToolTip = 'Specifies the balance for Current Month.';
                    Editable = false;
                }
                field("Balance - Previous Month 1"; GetBalanceForMonth(1))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 1';
                    ToolTip = 'Specifies the balance for Previous Month 1.';
                    Editable = false;
                }
                field("Balance - Previous Month 2"; GetBalanceForMonth(2))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 2';
                    ToolTip = 'Specifies the balance for Previous Month 2.';
                    Editable = false;
                }
                field("Balance - Previous Month 3"; GetBalanceForMonth(3))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 3';
                    ToolTip = 'Specifies the balance for Previous Month 3.';
                    Editable = false;
                }
                field("Balance - Previous Month 4"; GetBalanceForMonth(4))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 4';
                    ToolTip = 'Specifies the balance for Previous Month 4.';
                    Editable = false;
                }
                field("Balance - Previous Month 5"; GetBalanceForMonth(5))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 5';
                    ToolTip = 'Specifies the balance for Previous Month 5.';
                    Editable = false;
                }
                field("Balance - Previous Month 6"; GetBalanceForMonth(6))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 6';
                    ToolTip = 'Specifies the balance for Previous Month 6.';
                    Editable = false;
                }
                field("Balance - Previous Month 7"; GetBalanceForMonth(7))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 7';
                    ToolTip = 'Specifies the balance for Previous Month 7.';
                    Editable = false;
                }
                field("Balance - Previous Month 8"; GetBalanceForMonth(8))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 8';
                    ToolTip = 'Specifies the balance for Previous Month 8.';
                    Editable = false;
                }
                field("Balance - Previous Month 9"; GetBalanceForMonth(9))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 9';
                    ToolTip = 'Specifies the balance for Previous Month 9.';
                    Editable = false;
                }
                field("Balance - Previous Month 10"; GetBalanceForMonth(10))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 10';
                    ToolTip = 'Specifies the balance for Previous Month 10.';
                    Editable = false;
                }
                field("Balance - Previous Month 11"; GetBalanceForMonth(11))
                {
                    ApplicationArea = All;
                    Caption = 'Previous Month 11';
                    ToolTip = 'Specifies the balance for Previous Month 11.';
                    Editable = false;
                }
            }
        }
    }

    local procedure GetBalanceForMonth(MonthOffset: Integer): Decimal
    var
        GLEntry: Record "G/L Entry";
        StartDate: Date;
        EndDate: Date;
        Balance: Decimal;
    begin
        // Calculate the start and end dates for the given month offset
        StartDate := CalculateMonthStartDate(MonthOffset);
        EndDate := CalculateMonthEndDate(MonthOffset);

        // Calculate the balance for the specified period
        GLEntry.SetRange("G/L Account No.", Rec."No.");
        GLEntry.SetRange("Posting Date", StartDate, EndDate);
        GLEntry.CalcSums(Amount);

        Balance := GLEntry.Amount;

        // If the balance is a credit, display it as a negative figure
        if Balance > 0 then
            Balance := -Balance;

        exit(Balance);
    end;

    local procedure CalculateMonthStartDate(MonthOffset: Integer): Date
    begin
        // Calculate the first day of the month for the given offset
        exit(CalcDate('<-' + Format(MonthOffset) + 'M>', DMY2Date(1, Date2DMY(WorkDate(), 2), Date2DMY(WorkDate(), 3))));
    end;

    local procedure CalculateMonthEndDate(MonthOffset: Integer): Date
    begin
        // Calculate the last day of the month for the given offset
        exit(CalcDate('<CM>', CalculateMonthStartDate(MonthOffset)));
    end;

    local procedure GetMonthCaption(MonthOffset: Integer): Text
    begin
        case MonthOffset of
            0: exit('Current Month');
            1: exit('Previous Month 1');
            2: exit('Previous Month 2');
            3: exit('Previous Month 3');
            4: exit('Previous Month 4');
            5: exit('Previous Month 5');
            6: exit('Previous Month 6');
            7: exit('Previous Month 7');
            8: exit('Previous Month 8');
            9: exit('Previous Month 9');
            10: exit('Previous Month 10');
            11: exit('Previous Month 11');
            else exit('Unknown Month');
        end;
    end;
}
