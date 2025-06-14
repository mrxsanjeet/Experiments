page 70202 "Customer Import Selection"
{
    Caption = 'Customer Import Selection';
    PageType = List;
    SourceTable = "Customer Import Buffer";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Customers)
            {
                field("External ID"; Rec."External ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external ID of the customer.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address of the customer.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number of the customer.';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address of the customer.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city of the customer.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country/region code of the customer.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportSelected)
            {
                ApplicationArea = All;
                Caption = 'Import Selected';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Import the selected customer into Business Central.';

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    if Rec.Count > 1 then
                        Error('Please select only one customer to import.');

                    CurrPage.Close();
                end;
            }
        }
    }
}