pageextension 50500 "Our own headline" extends "Headline RC Business Manager"
{
    layout
    {
        addbefore(Control1)
        {
            field(HeadlineTxt; HeadlineTxt)
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                begin
                    Hyperlink('https://www.youtube.com');
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        HeadlineTxt := 'Hello <emphasize>Sanjeet!</emphasize> from AAVYA';
    end;

    var
        HeadlineTxt: Text;
}