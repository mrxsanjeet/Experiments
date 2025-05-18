tableextension 50100 itemtabext extends item
{
    fields
    {
        field(50100; "item category test"; Text[500])
        {
            Caption = 'item category test';
            DataClassification = ToBeClassified;
        }
        field(50101; "item test "; Boolean)
        {
            Caption = 'item test ';
            DataClassification = ToBeClassified;
        }
    }
}
