tableextension 70205 "Customer Ext" extends Customer
{
    fields
    {
        field(50200; "External ID"; Text[50])
        {
            Caption = 'External ID';
            DataClassification = CustomerContent;
        }
    }
}