codeunit 80104 "Service Bus Manager"
{
    // Service Bus Manager for handling async message queuing and processing

    var
        MiddlewareClient: Codeunit "BC Middleware Client";
        ErrorHandler: Codeunit "BC Middleware Error Handler";

    procedure EnqueueMessage(QueueName: Text; MessageBody: Text; MessageProperties: Text; Priority: Integer; TargetEndpoint: Text; FunctionKey: Text; HttpMethod: Option): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        EntryNo: Integer;
    begin
        ServiceBusQueue.Init();
        ServiceBusQueue."Queue Name" := CopyStr(QueueName, 1, 50);
        ServiceBusQueue.SetMessageBody(MessageBody);
        ServiceBusQueue.SetMessageProperties(MessageProperties);
        ServiceBusQueue."Priority" := Priority;
        ServiceBusQueue."Target Endpoint" := CopyStr(TargetEndpoint, 1, 250);
        ServiceBusQueue."Function Key" := CopyStr(FunctionKey, 1, 100);
        ServiceBusQueue."HTTP Method" := HttpMethod;
        ServiceBusQueue."Status" := ServiceBusQueue.Status::Pending;
        ServiceBusQueue."Source System" := 'Business Central';
        ServiceBusQueue.Insert(true);

        exit(ServiceBusQueue."Entry No.");
    end;

    procedure EnqueueAzureFunctionCall(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; HttpMethod: Option; QueueName: Text; Priority: Integer): Integer
    var
        MessageProperties: Text;
        JsonProperties: JsonObject;
    begin
        // Create message properties for the Azure Function call
        JsonProperties.Add('functionUrl', FunctionUrl);
        JsonProperties.Add('httpMethod', Format(HttpMethod));
        JsonProperties.Add('timestamp', Format(CurrentDateTime));
        JsonProperties.WriteTo(MessageProperties);

        exit(EnqueueMessage(
            QueueName,
            RequestBody,
            MessageProperties,
            Priority,
            FunctionUrl,
            FunctionKey,
            HttpMethod
        ));
    end;

    procedure ProcessQueue(QueueName: Text; MaxMessages: Integer): Integer
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
        ServiceBusQueue.SetAscending("Priority", false); // Higher priority first
        ServiceBusQueue.SetAscending("Created DateTime", true); // FIFO for same priority

        if MaxMessages > 0 then
            ServiceBusQueue.SetRange("Entry No.", 0, ServiceBusQueue.Count);

        if ServiceBusQueue.FindSet() then
            repeat
                if ProcessSingleMessage(ServiceBusQueue, SessionId) then
                    ProcessedCount += 1;
            until (ServiceBusQueue.Next() = 0) or (ProcessedCount >= MaxMessages);

        exit(ProcessedCount);
    end;

    procedure ProcessSingleMessage(var ServiceBusQueue: Record "Service Bus Queue"; SessionId: Text): Boolean
    var
        ResponseText: Text;
        Success: Boolean;
        MessageBody: Text;
        MessageProperties: Text;
    begin
        // Mark message as processing
        ServiceBusQueue.MarkAsProcessing(SessionId);
        ServiceBusQueue.Modify();

        MessageBody := ServiceBusQueue.GetMessageBody();
        MessageProperties := ServiceBusQueue.GetMessageProperties();

        // Process based on HTTP method
        case ServiceBusQueue."HTTP Method" of
            ServiceBusQueue."HTTP Method"::GET:
                Success := MiddlewareClient.CallAzureFunctionGET(
                    ServiceBusQueue."Target Endpoint",
                    ServiceBusQueue."Function Key",
                    ResponseText
                );
            ServiceBusQueue."HTTP Method"::POST:
                Success := MiddlewareClient.CallAzureFunctionPOST(
                    ServiceBusQueue."Target Endpoint",
                    ServiceBusQueue."Function Key",
                    MessageBody,
                    ResponseText
                );
            ServiceBusQueue."HTTP Method"::PUT:
                Success := MiddlewareClient.CallAzureFunctionPUT(
                    ServiceBusQueue."Target Endpoint",
                    ServiceBusQueue."Function Key",
                    MessageBody,
                    ResponseText
                );
            ServiceBusQueue."HTTP Method"::DELETE:
                Success := MiddlewareClient.CallAzureFunctionDELETE(
                    ServiceBusQueue."Target Endpoint",
                    ServiceBusQueue."Function Key",
                    ResponseText
                );
        end;

        if Success then begin
            ServiceBusQueue.MarkAsCompleted();
            ServiceBusQueue.Modify();
            exit(true);
        end else begin
            ServiceBusQueue.MarkAsFailed(ResponseText);
            ServiceBusQueue.Modify();
            exit(false);
        end;
    end;

    procedure ProcessDeadLetterQueue(): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        ProcessedCount: Integer;
    begin
        ProcessedCount := 0;

        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::DeadLetter);
        ServiceBusQueue.SetCurrentKey("Created DateTime");

        if ServiceBusQueue.FindSet() then
            repeat
                // Log dead letter for manual intervention
                LogDeadLetterMessage(ServiceBusQueue);
                ProcessedCount += 1;
            until ServiceBusQueue.Next() = 0;

        exit(ProcessedCount);
    end;

    procedure RetryFailedMessages(): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        RetryCount: Integer;
    begin
        RetryCount := 0;

        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Failed);
        ServiceBusQueue.SetFilter("Next Retry DateTime", '<=%1', CurrentDateTime);

        if ServiceBusQueue.FindSet() then
            repeat
                if ServiceBusQueue.IsRetryable() then begin
                    ServiceBusQueue.IncrementRetry();
                    ServiceBusQueue.Modify();
                    RetryCount += 1;
                end else begin
                    ServiceBusQueue."Status" := ServiceBusQueue.Status::DeadLetter;
                    ServiceBusQueue.Modify();
                end;
            until ServiceBusQueue.Next() = 0;

        exit(RetryCount);
    end;

    procedure CleanupCompletedMessages(DaysOld: Integer): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        CleanupCount: Integer;
        CutoffDateTime: DateTime;
    begin
        CleanupCount := 0;
        CutoffDateTime := CurrentDateTime - (DaysOld * 24 * 60 * 60 * 1000);

        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Completed);
        ServiceBusQueue.SetFilter("Processed DateTime", '<%1', CutoffDateTime);

        if ServiceBusQueue.FindSet(true) then
            repeat
                ServiceBusQueue.Delete(true);
                CleanupCount += 1;
            until ServiceBusQueue.Next() = 0;

        exit(CleanupCount);
    end;

    procedure GetQueueStatistics(QueueName: Text; var PendingCount: Integer; var ProcessingCount: Integer; var CompletedCount: Integer; var FailedCount: Integer; var DeadLetterCount: Integer)
    var
        ServiceBusQueue: Record "Service Bus Queue";
    begin
        PendingCount := 0;
        ProcessingCount := 0;
        CompletedCount := 0;
        FailedCount := 0;
        DeadLetterCount := 0;

        ServiceBusQueue.SetRange("Queue Name", QueueName);

        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Pending);
        PendingCount := ServiceBusQueue.Count();

        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Processing);
        ProcessingCount := ServiceBusQueue.Count();

        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Completed);
        CompletedCount := ServiceBusQueue.Count();

        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Failed);
        FailedCount := ServiceBusQueue.Count();

        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::DeadLetter);
        DeadLetterCount := ServiceBusQueue.Count();
    end;

    local procedure GenerateSessionId(): Text
    var
        Guid: Guid;
    begin
        Guid := CreateGuid();
        exit(Format(Guid));
    end;

    local procedure LogDeadLetterMessage(var ServiceBusQueue: Record "Service Bus Queue")
    begin
        // Log dead letter messages for monitoring
        // Note: In a real implementation, you would log to a custom logging table
        // or use Application Insights, Event Log, or similar service
    end;

    procedure PurgeQueue(QueueName: Text; Status: Option): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        PurgeCount: Integer;
    begin
        PurgeCount := 0;

        ServiceBusQueue.SetRange("Queue Name", QueueName);
        ServiceBusQueue.SetRange("Status", Status);

        if ServiceBusQueue.FindSet(true) then
            repeat
                ServiceBusQueue.Delete(true);
                PurgeCount += 1;
            until ServiceBusQueue.Next() = 0;

        exit(PurgeCount);
    end;

    procedure GetNextRetryableMessages(QueueName: Text; MaxCount: Integer): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        Count: Integer;
    begin
        Count := 0;

        ServiceBusQueue.SetRange("Queue Name", QueueName);
        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Failed);
        ServiceBusQueue.SetFilter("Next Retry DateTime", '<=%1', CurrentDateTime);

        if ServiceBusQueue.FindSet() then
            repeat
                if ServiceBusQueue.IsRetryable() then begin
                    ServiceBusQueue.IncrementRetry();
                    ServiceBusQueue.Modify();
                    Count += 1;
                end;
            until (ServiceBusQueue.Next() = 0) or (Count >= MaxCount);

        exit(Count);
    end;
}
