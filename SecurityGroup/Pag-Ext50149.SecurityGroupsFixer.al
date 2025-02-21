
/*
pageextension 50149 "Security Groups Fixer" extends "Security Groups"
{
    actions
    {
        addafter(Delete)
        {
            action(RemoveOrphanedGroups)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Remove Orphaned Security Groups';
                Image = DeleteRow;
                ToolTip = 'Remove Orphaned Security Groups.';
                trigger OnAction()
                begin
                    RemoveHiddenGroups();
                end;
            }
        }
        addafter(Delete_Promoted)
        {
            actionref(RemoveOrphanedGroups_Promoted; RemoveOrphanedGroups)
            {
            }
        }
    }
    procedure RemoveHiddenGroups();
    var
        User: Record User;
        SecurityGroupBuffer: Record "Security Group Buffer";
        SecurityGroup: Codeunit "Security Group";
        OrphanedUsers: List of [Guid];
        OrphanedUser: Guid;
    begin
        SecurityGroup.GetGroups(SecurityGroupBuffer);
        User.SetRange("License Type", User."License Type"::"AAD Group");
        if User.FindSet() then
            repeat
                SecurityGroupBuffer.SetRange("Group User SID", User."User Security ID");
                if SecurityGroupBuffer.IsEmpty() then
                    OrphanedUsers.Add(User."User Security ID");
            until User.Next() = 0;
 
        Message('Removing %1 orphaned groups.', OrphanedUsers.Count());
        foreach OrphanedUser in OrphanedUsers do
            if User.Get(OrphanedUser) then
                User.Delete();
    end;
}

*/