page 51100 "Search Tables"
{

    ApplicationArea = All;
    Caption = 'Search Setup';
    PageType = List;
    SourceTable = "Search Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                }
                field("Search Primary Key"; Rec."Search Primary Key")
                {
                    ApplicationArea = All;
                }
                field("Full Text Search"; Rec."Full Text Search")
                {
                    ApplicationArea = All;
                }
                field("Full Text Search Limit"; Rec."Full Text Search Limit")
                {
                    ApplicationArea = All;
                }
                field("Card Page"; Rec."Card Page")
                {
                    ApplicationArea = All;
                }
            }
        }
    }


}
