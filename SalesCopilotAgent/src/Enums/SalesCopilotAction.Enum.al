/// <summary>
/// Enum defining the types of Copilot actions available in Sales Copilot Agent
/// </summary>
enum 50100 "SJT Sales Copilot Action"
{
    Extensible = true;
    Caption = 'Sales Copilot Action';

    value(0; "Discount Recommendation")
    {
        Caption = 'Discount Recommendation';
    }
    value(1; "Anomaly Detection")
    {
        Caption = 'Anomaly Detection';
    }
    value(2; "Customer Analysis")
    {
        Caption = 'Customer Analysis';
    }
    value(3; "Product Bundling")
    {
        Caption = 'Product Bundling';
    }
}

