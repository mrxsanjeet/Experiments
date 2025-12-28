/// <summary>
/// Permission set containing all objects in the Sanjeet Toolkit
/// Used for granting access to toolkit features
/// </summary>
permissionset 60000 "Sanjeet Toolkit"
{
    Caption = 'Sanjeet Toolkit - All Objects';
    Assignable = true;
    Access = Public;

    Permissions =
        // Pages
        page "Sanjeet Object Viewer" = X,
        page "Sanjeet Object Viewer Enhanced" = X,
        page "BC Analysis Report" = X,
        page "Sanjeet Field Viewer" = X;
}

