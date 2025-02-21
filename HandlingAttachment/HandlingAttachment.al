table 60167 HandlingAttachment
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; MyField; Integer)
        {
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(Key1; MyField)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    procedure HandlingAttachments()
    var
        Attachment: Record Attachment;
        outStr: OutStream;
        inStr: InStream;
        tempfilename: text;
        FileMgt: Codeunit "File Management";
        DialogTitle: Label 'Please select a File...';
    begin
        if UploadIntoStream(DialogTitle, '', 'All Files (*.*)|*.*', tempfilename, inStr) then begin
            Attachment.Init();
            Attachment.Insert(true);
            //Attachment."Storage Type" := Attachment."Storage Type "::Embedded;
            Attachment."Storage Pointer" := '';
            Attachment."File Extension" :=
            FileMgt.GetExtension(tempfilename);
            Attachment."Attachment File".CreateOutStream(outStr);
            CopyStream(outStr, inStr);
            Attachment.Modify(true);
        end;

    end;

}