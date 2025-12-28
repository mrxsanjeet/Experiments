permissionset 60200 "Simple Data Exchange"
{
    Assignable = true;
    Caption = 'Simple Data Exchange';

    Permissions =
        // Tables
        tabledata "Simple Data Exchange Setup" = RIMD,

        // Table Objects
        table "Simple Data Exchange Setup" = X,

        // Pages
        page "Simple Data Exchange Setup" = X,

        // Codeunits
        codeunit "Simple Data Sync" = X,

        // Standard tables for data sync
        tabledata Customer = RIMD;
}
