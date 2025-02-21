tableextension 50101 "Trial Balance Entity BufferExt" extends "Trial Balance Entity Buffer"
{
    fields
    {
        field(1000; "Account Types"; Enum "G/L Account Type")
        {
            Caption = 'Account Type';
            //OptionMembers = Debit, Credit;
            DataClassification = ToBeClassified;
        }

        field(1001; "Balance Amount"; Decimal)
        {
            Caption = 'Balance Amount';
            DataClassification = ToBeClassified;
        }
    }
}
