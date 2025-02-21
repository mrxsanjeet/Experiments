/*
pageextension 80200 MyPageExtension extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
    }
    actions
    {
        // Add changes to page actions here
        addafter("&Customer")
        {
            // Add your custom action
            action(50100; "MyCustomAction")
        {
            ApplicationArea = All;
            Promoted = true;
            Caption = 'My Custom Action';
            Image = 'MyImage.png';

            // Link the JavaScript file
            controladdin
            {
                Name = 'JavascriptCode\MyScript.js';
                AddinType = Extension;
                Library = true;
            }
        }
    }

    */



