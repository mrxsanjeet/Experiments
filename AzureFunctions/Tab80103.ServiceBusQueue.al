table 80103 "Service Bus Queue"
{
    DataClassification = CustomerContent;
    Caption = 'Service Bus Queue';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Message ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Message ID';
        }

        field(3; "Queue Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Queue Name';
        }

        field(4; "Message Body"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Message Body';
        }

        field(5; "Message Properties"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Message Properties';
        }

        field(6; "Priority"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Priority';
            InitValue = 5;
        }

        field(7; "Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            OptionMembers = Pending,Processing,Completed,Failed,DeadLetter;
            OptionCaption = 'Pending,Processing,Completed,Failed,Dead Letter';
        }

        field(8; "Created DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created DateTime';
        }

        field(9; "Processed DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed DateTime';
        }

        field(10; "Retry Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Retry Count';
            InitValue = 0;
        }

        field(11; "Max Retries"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Max Retries';
            InitValue = 3;
        }

        field(12; "Next Retry DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Next Retry DateTime';
        }

        field(13; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }

        field(14; "Processing Session ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Processing Session ID';
        }

        field(15; "Source System"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Source System';
        }

        field(16; "Target Endpoint"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Target Endpoint';
        }

        field(17; "Function Key"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Function Key';
            ExtendedDatatype = Masked;
        }

        field(18; "HTTP Method"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'HTTP Method';
            OptionMembers = GET,POST,PUT,DELETE;
            OptionCaption = 'GET,POST,PUT,DELETE';
        }

        field(19; "Correlation ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Correlation ID';
        }

        field(20; "User ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'User ID';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Status", "Priority", "Created DateTime")
        {
        }
        key(Key3; "Next Retry DateTime", "Status")
        {
        }
        key(Key4; "Correlation ID")
        {
        }
        key(Key5; "Queue Name", "Status")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Created DateTime" = 0DT then
            "Created DateTime" := CurrentDateTime;

        if "User ID" = '' then
            "User ID" := UserId();

        if "Message ID" = '' then
            "Message ID" := GenerateMessageId();

        if "Correlation ID" = '' then
            "Correlation ID" := GenerateCorrelationId();
    end;

    trigger OnModify()
    begin
        if (xRec.Status <> Status) and (Status = Status::Processing) then
            "Processed DateTime" := CurrentDateTime;
    end;

    local procedure GenerateMessageId(): Text[50]
    var
        Guid: Guid;
    begin
        Guid := CreateGuid();
        exit(CopyStr(Format(Guid), 1, 50));
    end;

    local procedure GenerateCorrelationId(): Text[50]
    var
        Guid: Guid;
    begin
        Guid := CreateGuid();
        exit(CopyStr(Format(Guid), 1, 50));
    end;

    procedure SetMessageBody(JsonText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(JsonText);
        // Note: Direct assignment may not work in all BC versions
        // Alternative: Use InStream/OutStream approach
    end;

    procedure GetMessageBody(): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        MessageText: Text;
    begin
        TempBlob.FromRecord(Rec, FieldNo("Message Body"));
        TempBlob.CreateInStream(InStream);
        InStream.ReadText(MessageText);
        exit(MessageText);
    end;

    procedure SetMessageProperties(PropertiesJson: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(PropertiesJson);
        // Note: Direct assignment may not work in all BC versions
        // Alternative: Use InStream/OutStream approach
    end;

    procedure GetMessageProperties(): Text
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        PropertiesText: Text;
    begin
        TempBlob.FromRecord(Rec, FieldNo("Message Properties"));
        TempBlob.CreateInStream(InStream);
        InStream.ReadText(PropertiesText);
        exit(PropertiesText);
    end;

    procedure IsRetryable(): Boolean
    begin
        exit(("Retry Count" < "Max Retries") and (Status in [Status::Failed, Status::Processing]));
    end;

    procedure CalculateNextRetryDateTime(): DateTime
    var
        DelayMs: Integer;
        BaseDelay: Integer;
        ExponentialFactor: Decimal;
    begin
        BaseDelay := 1000; // 1 second base delay
        ExponentialFactor := Power(2, "Retry Count");
        DelayMs := Round(BaseDelay * ExponentialFactor, 1);

        // Cap at 5 minutes
        if DelayMs > 300000 then
            DelayMs := 300000;

        exit(CurrentDateTime + DelayMs);
    end;

    procedure IncrementRetry()
    begin
        "Retry Count" += 1;
        "Next Retry DateTime" := CalculateNextRetryDateTime();
        "Status" := Status::Pending;
        "Error Message" := '';
        "Processing Session ID" := '';
    end;

    procedure MarkAsCompleted()
    begin
        "Status" := Status::Completed;
        "Processed DateTime" := CurrentDateTime;
        "Processing Session ID" := '';
    end;

    procedure MarkAsFailed(ErrorMessage: Text)
    begin
        "Error Message" := CopyStr(ErrorMessage, 1, 250);
        if IsRetryable() then
            IncrementRetry()
        else
            "Status" := Status::DeadLetter;
    end;

    procedure MarkAsProcessing(SessionId: Text)
    begin
        "Status" := Status::Processing;
        "Processing Session ID" := CopyStr(SessionId, 1, 50);
    end;
}
