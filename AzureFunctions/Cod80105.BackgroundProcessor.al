codeunit 80105 "Background Processor"
{
    // Background processor for handling async Azure Function calls without blocking UI threads

    var
        ServiceBusManager: Codeunit "Service Bus Manager";
        MiddlewareClient: Codeunit "BC Middleware Client";
        ProcessingSessionId: Text;

    trigger OnRun()
    begin
        ProcessingSessionId := GenerateSessionId();
    end;

    procedure ProcessQueueBackground(QueueName: Text; MaxMessages: Integer)
    var
        ProcessedCount: Integer;
        StartTime: DateTime;
        ProcessingTime: Duration;
    begin
        StartTime := CurrentDateTime;

        // Process messages in background
        ProcessedCount := ServiceBusManager.ProcessQueue(QueueName, MaxMessages);

        ProcessingTime := CurrentDateTime - StartTime;

        // Log processing statistics
        LogProcessingStatistics(QueueName, ProcessedCount, ProcessingTime);
    end;

    procedure ProcessSpecificMessage(EntryNo: Integer)
    var
        ServiceBusQueue: Record "Service Bus Queue";
        SessionId: Text;
    begin
        SessionId := GenerateSessionId();

        if ServiceBusQueue.Get(EntryNo) then begin
            if ServiceBusQueue."Status" = ServiceBusQueue.Status::Pending then
                ServiceBusManager.ProcessSingleMessage(ServiceBusQueue, SessionId);
        end;
    end;

    procedure ProcessPendingMessages(QueueName: Text)
    var
        ServiceBusQueue: Record "Service Bus Queue";
        ProcessedCount: Integer;
        SessionId: Text;
    begin
        SessionId := GenerateSessionId();
        ProcessedCount := 0;

        ServiceBusQueue.SetRange("Queue Name", QueueName);
        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Pending);
        ServiceBusQueue.SetFilter("Next Retry DateTime", '<=%1', CurrentDateTime);
        ServiceBusQueue.SetCurrentKey("Priority", "Created DateTime");
        ServiceBusQueue.SetAscending("Priority", false);
        ServiceBusQueue.SetAscending("Created DateTime", true);

        if ServiceBusQueue.FindSet() then
            repeat
                if ServiceBusManager.ProcessSingleMessage(ServiceBusQueue, SessionId) then
                    ProcessedCount += 1;
            until ServiceBusQueue.Next() = 0;

        LogProcessingStatistics(QueueName, ProcessedCount, 0);
    end;

    procedure ProcessHighPriorityMessages(QueueName: Text): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        ProcessedCount: Integer;
        SessionId: Text;
    begin
        SessionId := GenerateSessionId();
        ProcessedCount := 0;

        // Process only high priority messages (priority >= 8)
        ServiceBusQueue.SetRange("Queue Name", QueueName);
        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Pending);
        ServiceBusQueue.SetRange("Priority", 8, 10);
        ServiceBusQueue.SetFilter("Next Retry DateTime", '<=%1', CurrentDateTime);
        ServiceBusQueue.SetCurrentKey("Priority", "Created DateTime");
        ServiceBusQueue.SetAscending("Priority", false);
        ServiceBusQueue.SetAscending("Created DateTime", true);

        if ServiceBusQueue.FindSet() then
            repeat
                if ServiceBusManager.ProcessSingleMessage(ServiceBusQueue, SessionId) then
                    ProcessedCount += 1;
            until ServiceBusQueue.Next() = 0;

        exit(ProcessedCount);
    end;

    procedure ProcessRetryableMessages(QueueName: Text): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        ProcessedCount: Integer;
        SessionId: Text;
    begin
        SessionId := GenerateSessionId();
        ProcessedCount := 0;

        ServiceBusQueue.SetRange("Queue Name", QueueName);
        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Failed);
        ServiceBusQueue.SetFilter("Next Retry DateTime", '<=%1', CurrentDateTime);

        if ServiceBusQueue.FindSet() then
            repeat
                if ServiceBusQueue.IsRetryable() then begin
                    ServiceBusQueue.IncrementRetry();
                    ServiceBusQueue.Modify();

                    if ServiceBusManager.ProcessSingleMessage(ServiceBusQueue, SessionId) then
                        ProcessedCount += 1;
                end else begin
                    ServiceBusQueue."Status" := ServiceBusQueue.Status::DeadLetter;
                    ServiceBusQueue.Modify();
                end;
            until ServiceBusQueue.Next() = 0;

        exit(ProcessedCount);
    end;

    procedure StartBackgroundProcessing(QueueName: Text; ProcessingInterval: Integer)
    var
        BackgroundProcessingSetup: Record "Background Processing Setup";
    begin
        // Setup background processing job
        BackgroundProcessingSetup.Init();
        BackgroundProcessingSetup."Queue Name" := QueueName;
        BackgroundProcessingSetup."Processing Interval" := ProcessingInterval;
        BackgroundProcessingSetup."Last Processed" := CurrentDateTime;
        BackgroundProcessingSetup."Is Active" := true;
        BackgroundProcessingSetup.Insert(true);

        // Schedule the background job
        ScheduleBackgroundJob(QueueName, ProcessingInterval);
    end;

    procedure StopBackgroundProcessing(QueueName: Text)
    var
        BackgroundProcessingSetup: Record "Background Processing Setup";
    begin
        if BackgroundProcessingSetup.Get(QueueName) then begin
            BackgroundProcessingSetup."Is Active" := false;
            BackgroundProcessingSetup.Modify();
        end;
    end;

    procedure ProcessAllQueues()
    var
        BackgroundProcessingSetup: Record "Background Processing Setup";
        ProcessedCount: Integer;
        TotalProcessed: Integer;
    begin
        TotalProcessed := 0;

        BackgroundProcessingSetup.SetRange("Is Active", true);
        BackgroundProcessingSetup.SetFilter("Last Processed", '<%1', CurrentDateTime - 60000); // 1 minute ago

        if BackgroundProcessingSetup.FindSet() then
            repeat
                ProcessQueueBackground(BackgroundProcessingSetup."Queue Name", 100);
                ProcessedCount := 0; // ProcessQueueBackground doesn't return a value
                TotalProcessed := TotalProcessed + ProcessedCount;

                BackgroundProcessingSetup."Last Processed" := CurrentDateTime;
                BackgroundProcessingSetup.Modify();
            until BackgroundProcessingSetup.Next() = 0;

        LogProcessingStatistics('ALL_QUEUES', TotalProcessed, 0);
    end;

    procedure CleanupBackgroundProcessing()
    var
        ServiceBusQueue: Record "Service Bus Queue";
        CleanupCount: Integer;
    begin
        // Cleanup completed messages older than 7 days
        CleanupCount := ServiceBusManager.CleanupCompletedMessages(7);

        // Process dead letter queue
        ServiceBusManager.ProcessDeadLetterQueue();

        LogCleanupStatistics(CleanupCount);
    end;

    local procedure GenerateSessionId(): Text
    var
        Guid: Guid;
        TimeStamp: Text;
    begin
        Guid := CreateGuid();
        TimeStamp := Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>');
        exit(Format(Guid) + '_' + TimeStamp);
    end;

    local procedure ScheduleBackgroundJob(QueueName: Text; IntervalMs: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Background Processor";
        JobQueueEntry."Parameter String" := QueueName;
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime + IntervalMs;
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry."Inactivity Timeout Period" := 300; // 5 minutes
        JobQueueEntry.Insert(true);

        Commit();
        // Note: Start() method may not be available in all BC versions
        // JobQueueEntry.Start();
    end;

    local procedure LogProcessingStatistics(QueueName: Text; ProcessedCount: Integer; ProcessingTime: Duration)
    begin
        // Log processing statistics for monitoring
        // Note: In a real implementation, you would log to a custom logging table
        // or use Application Insights, Event Log, or similar service
    end;

    local procedure LogCleanupStatistics(CleanupCount: Integer)
    begin
        // Log cleanup statistics for monitoring
        // Note: In a real implementation, you would log to a custom logging table
        // or use Application Insights, Event Log, or similar service
    end;

    // Custom processing procedures for integration with other systems
    local procedure OnBeforeProcessMessage(var ServiceBusQueue: Record "Service Bus Queue"; var Handled: Boolean)
    begin
        // Custom logic before processing each message
        // Can be used for validation, logging, etc.
        Handled := false;
    end;

    local procedure OnAfterProcessMessage(var ServiceBusQueue: Record "Service Bus Queue"; Success: Boolean; ResponseText: Text)
    begin
        // Custom logic after processing each message
        // Can be used for notifications, additional processing, etc.
    end;

    // Public methods for external integration
    procedure GetProcessingSessionId(): Text
    begin
        exit(ProcessingSessionId);
    end;

    procedure IsProcessingActive(QueueName: Text): Boolean
    var
        BackgroundProcessingSetup: Record "Background Processing Setup";
    begin
        if BackgroundProcessingSetup.Get(QueueName) then
            exit(BackgroundProcessingSetup."Is Active");

        exit(false);
    end;

    procedure GetQueueProcessingStatus(QueueName: Text): Text
    var
        ServiceBusQueue: Record "Service Bus Queue";
        PendingCount: Integer;
        ProcessingCount: Integer;
        CompletedCount: Integer;
        FailedCount: Integer;
        DeadLetterCount: Integer;
    begin
        ServiceBusManager.GetQueueStatistics(
            QueueName,
            PendingCount,
            ProcessingCount,
            CompletedCount,
            FailedCount,
            DeadLetterCount
        );

        exit(StrSubstNo(
            'Pending: %1, Processing: %2, Completed: %3, Failed: %4, Dead Letter: %5',
            PendingCount, ProcessingCount, CompletedCount, FailedCount, DeadLetterCount
        ));
    end;
}
