pageextension 70204 "Customer List Ext" extends "Customer List"
{
    actions
    {
        addlast(processing)
        {
            action(ImportFromAPI)
            {
                ApplicationArea = All;
                Caption = 'Import from API';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Import customers from external API.';

                trigger OnAction()
                var
                    CustomerAPIIntegration: Codeunit "Customer API Integration";
                begin
                    CustomerAPIIntegration.FetchAndImportCustomers();
                end;
            }
        }
    }
}