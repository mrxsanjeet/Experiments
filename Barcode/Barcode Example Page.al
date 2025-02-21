page 80101 "Barcode Example Page"
{
    PageType = Card;
    SourceTable = "Barcode Example";
    //ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Group)
            {
                field("ID"; Rec."ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }

                field("Barcode"; Rec."Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Generated barcode for the item.';
                }

                // Display the barcode visually
                field("Barcode Image"; Rec."Barcode")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Barcode Image';
                    ToolTip = 'Displays the barcode image.';
                    // You can use a barcode font or an image link here
                }
            }
        }
    }
}
