/// <summary>
/// Enum defining customer tiers for discount calculations
/// </summary>
enum 50103 "SJT Customer Tier"
{
    Extensible = true;
    Caption = 'Customer Tier';

    value(0; "Standard")
    {
        Caption = 'Standard';
    }
    value(1; "Bronze")
    {
        Caption = 'Bronze';
    }
    value(2; "Silver")
    {
        Caption = 'Silver';
    }
    value(3; "Gold")
    {
        Caption = 'Gold';
    }
    value(4; "Platinum")
    {
        Caption = 'Platinum';
    }
}

