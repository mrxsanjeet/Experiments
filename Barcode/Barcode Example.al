table 80101 "Barcode Example"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ID"; Integer)
        {
            //DataClassification = SystemId;
        }

        field(2; "Item No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(3; "Barcode"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PrimaryKey; "ID")
        {
            Clustered = true;
        }
    }
}
