page 60167 "Json buffer bcg"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = 1236;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
                field(Depth; Rec.Depth)
                {
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                Field("Token type"; Rec."Token type")
                {
                    ApplicationArea = All;
                }

                field(Path; Rec.Path)
                {
                    ApplicationArea = All;
                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}