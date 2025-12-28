/// <summary>
/// Enum defining the status of Copilot suggestions
/// </summary>
enum 50102 "SJT Suggestion Status"
{
    Extensible = true;
    Caption = 'Suggestion Status';

    value(0; "Pending")
    {
        Caption = 'Pending';
    }
    value(1; "Accepted")
    {
        Caption = 'Accepted';
    }
    value(2; "Rejected")
    {
        Caption = 'Rejected';
    }
    value(3; "Modified")
    {
        Caption = 'Modified';
    }
    value(4; "Expired")
    {
        Caption = 'Expired';
    }
}

