/// <summary>
/// Enum defining the types of anomalies that can be detected in sales orders
/// </summary>
enum 50101 "SJT Anomaly Type"
{
    Extensible = true;
    Caption = 'Anomaly Type';

    value(0; "None")
    {
        Caption = 'None';
    }
    value(1; "Quantity Spike")
    {
        Caption = 'Quantity Spike';
    }
    value(2; "Price Deviation")
    {
        Caption = 'Price Deviation';
    }
    value(3; "New Ship-to Address")
    {
        Caption = 'New Ship-to Address';
    }
    value(4; "Unusual Product Mix")
    {
        Caption = 'Unusual Product Mix';
    }
    value(5; "Credit Limit Exceeded")
    {
        Caption = 'Credit Limit Exceeded';
    }
    value(6; "Multiple Anomalies")
    {
        Caption = 'Multiple Anomalies';
    }
}

