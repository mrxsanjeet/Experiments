codeunit 80102 "Date-Time Management"
{
    Subtype = Normal;
    //ApplicationArea = All;

    procedure GetStartOfMonth(InputDate: Date): Date
    var
        FirstDay: Date;
    begin
        // Calculate the first day of the given month
        FirstDay := DMY2Date(1, Date2DMY(InputDate, 2), Date2DMY(InputDate, 3));
        exit(FirstDay);
    end;

    procedure GetEndOfMonth(InputDate: Date): Date
    var
        LastDay: Date;
        NextMonth: Date;
    begin
        // Calculate the last day of the given month
        NextMonth := CalcDate('<+1M>', GetStartOfMonth(InputDate));
        LastDay := CalcDate('<-1D>', NextMonth);
        exit(LastDay);
    end;

    procedure AddMonths(InputDate: Date; MonthOffset: Integer): Date
    var
        Day, Month, Year : Integer;
        NewDate: Date;
    begin
        // Add months to the given date while preserving the day and adjusting for overflows
        Day := Date2DMY(InputDate, 1);
        Month := Date2DMY(InputDate, 2) + MonthOffset;
        Year := Date2DMY(InputDate, 3);

        // Adjust for overflows (e.g., month > 12)
        while Month > 12 do begin
            Month := Month - 12;
            Year := Year + 1;
        end;
        while Month < 1 do begin
            Month := Month + 12;
            Year := Year - 1;
        end;

        // Construct the new date
        NewDate := DMY2Date(Day, Month, Year);

        // Ensure the date is valid (e.g., February 30 becomes February 28/29)
        if Day <> Date2DMY(NewDate, 1) then
            NewDate := DMY2Date(1, Month + 1, Year) - 1;

        exit(NewDate);
    end;

    procedure Today(): Date
    begin
        // Return the current system date
        exit(Today());
    end;
}
