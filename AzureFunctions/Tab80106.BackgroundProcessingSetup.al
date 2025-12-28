table 80106 "Background Processing Setup"
{
    DataClassification = CustomerContent;
    Caption = 'Background Processing Setup';

    fields
    {
        field(1; "Queue Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Queue Name';
            NotBlank = true;
        }

        field(2; "Processing Interval"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Processing Interval (ms)';
            InitValue = 30000; // 30 seconds default
        }

        field(3; "Max Messages Per Batch"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Max Messages Per Batch';
            InitValue = 100;
        }

        field(4; "Is Active"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Active';
            InitValue = true;
        }

        field(5; "Last Processed"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Processed';
        }

        field(6; "Next Processing"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Next Processing';
        }

        field(7; "Processing Timeout"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Processing Timeout (ms)';
            InitValue = 300000; // 5 minutes default
        }

        field(8; "Retry Failed Messages"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Retry Failed Messages';
            InitValue = true;
        }

        field(9; "Cleanup Completed Messages"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Cleanup Completed Messages';
            InitValue = true;
        }

        field(10; "Cleanup Days"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Cleanup Days';
            InitValue = 7;
        }

        field(11; "Created By"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By';
            Editable = false;
        }

        field(12; "Created DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created DateTime';
            Editable = false;
        }

        field(13; "Modified By"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Modified By';
            Editable = false;
        }

        field(14; "Modified DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Modified DateTime';
            Editable = false;
        }

        field(15; "Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }

        field(16; "Priority Threshold"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Priority Threshold';
            InitValue = 5;
        }

        field(17; "Circuit Breaker Enabled"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Circuit Breaker Enabled';
            InitValue = true;
        }

        field(18; "Circuit Breaker Threshold"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Circuit Breaker Threshold';
            InitValue = 10;
        }

        field(19; "Circuit Breaker Timeout"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Circuit Breaker Timeout (ms)';
            InitValue = 60000; // 1 minute
        }

        field(20; "Health Check Interval"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Health Check Interval (ms)';
            InitValue = 300000; // 5 minutes
        }
    }

    keys
    {
        key(Key1; "Queue Name")
        {
            Clustered = true;
        }
        key(Key2; "Is Active", "Next Processing")
        {
        }
        key(Key3; "Last Processed")
        {
        }
    }

    trigger OnInsert()
    begin
        "Created By" := UserId();
        "Created DateTime" := CurrentDateTime;
        "Modified By" := UserId();
        "Modified DateTime" := CurrentDateTime;

        if "Next Processing" = 0DT then
            "Next Processing" := CurrentDateTime + "Processing Interval";
    end;

    trigger OnModify()
    begin
        "Modified By" := UserId();
        "Modified DateTime" := CurrentDateTime;

        // Recalculate next processing time if interval changed
        if xRec."Processing Interval" <> "Processing Interval" then
            "Next Processing" := CurrentDateTime + "Processing Interval";
    end;

    trigger OnDelete()
    begin
        // Stop any running background processing for this queue
        StopBackgroundProcessing();
    end;

    local procedure StopBackgroundProcessing()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Background Processor");
        JobQueueEntry.SetRange("Parameter String", "Queue Name");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready);

        if JobQueueEntry.FindSet() then
            repeat
                JobQueueEntry.Cancel();
            until JobQueueEntry.Next() = 0;
    end;

    procedure IsReadyForProcessing(): Boolean
    begin
        exit("Is Active" and ("Next Processing" <= CurrentDateTime));
    end;

    procedure UpdateNextProcessingTime()
    begin
        "Next Processing" := CurrentDateTime + "Processing Interval";
        "Last Processed" := CurrentDateTime;
    end;

    procedure ShouldRetryFailedMessages(): Boolean
    begin
        exit("Retry Failed Messages");
    end;

    procedure ShouldCleanupCompletedMessages(): Boolean
    begin
        exit("Cleanup Completed Messages");
    end;

    procedure GetCleanupDays(): Integer
    begin
        exit("Cleanup Days");
    end;

    procedure GetProcessingTimeout(): Integer
    begin
        exit("Processing Timeout");
    end;

    procedure GetMaxMessagesPerBatch(): Integer
    begin
        exit("Max Messages Per Batch");
    end;

    procedure GetPriorityThreshold(): Integer
    begin
        exit("Priority Threshold");
    end;

    procedure IsCircuitBreakerEnabled(): Boolean
    begin
        exit("Circuit Breaker Enabled");
    end;

    procedure GetCircuitBreakerThreshold(): Integer
    begin
        exit("Circuit Breaker Threshold");
    end;

    procedure GetCircuitBreakerTimeout(): Integer
    begin
        exit("Circuit Breaker Timeout");
    end;

    procedure GetHealthCheckInterval(): Integer
    begin
        exit("Health Check Interval");
    end;

    procedure ValidateProcessingInterval()
    begin
        if "Processing Interval" < 1000 then
            Error('Processing interval must be at least 1000ms (1 second)');

        if "Processing Interval" > 3600000 then
            Error('Processing interval cannot exceed 3600000ms (1 hour)');
    end;

    procedure ValidateMaxMessagesPerBatch()
    begin
        if "Max Messages Per Batch" < 1 then
            Error('Max messages per batch must be at least 1');

        if "Max Messages Per Batch" > 1000 then
            Error('Max messages per batch cannot exceed 1000');
    end;

    procedure ValidateCleanupDays()
    begin
        if "Cleanup Days" < 1 then
            Error('Cleanup days must be at least 1');

        if "Cleanup Days" > 365 then
            Error('Cleanup days cannot exceed 365');
    end;

    procedure ValidateProcessingTimeout()
    begin
        if "Processing Timeout" < 10000 then
            Error('Processing timeout must be at least 10000ms (10 seconds)');

        if "Processing Timeout" > 3600000 then
            Error('Processing timeout cannot exceed 3600000ms (1 hour)');
    end;

    procedure ValidateCircuitBreakerThreshold()
    begin
        if "Circuit Breaker Threshold" < 1 then
            Error('Circuit breaker threshold must be at least 1');

        if "Circuit Breaker Threshold" > 100 then
            Error('Circuit breaker threshold cannot exceed 100');
    end;

    procedure ValidateCircuitBreakerTimeout()
    begin
        if "Circuit Breaker Timeout" < 1000 then
            Error('Circuit breaker timeout must be at least 1000ms (1 second)');

        if "Circuit Breaker Timeout" > 3600000 then
            Error('Circuit breaker timeout cannot exceed 3600000ms (1 hour)');
    end;

    procedure ValidateHealthCheckInterval()
    begin
        if "Health Check Interval" < 60000 then
            Error('Health check interval must be at least 60000ms (1 minute)');

        if "Health Check Interval" > 86400000 then
            Error('Health check interval cannot exceed 86400000ms (24 hours)');
    end;

    // Note: OnValidate trigger is not available for table fields in AL
    // Validation should be done in the calling codeunit or page
}
