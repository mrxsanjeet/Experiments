codeunit 80108 "Enhanced Azure Function Int."
{
    // Enhanced Azure Function integration with retry logic, circuit breaker, and async processing

    var
        MiddlewareClient: Codeunit "BC Middleware Client";
        ServiceBusManager: Codeunit "Service Bus Manager";
        BackgroundProcessor: Codeunit "Background Processor";
        ErrorHandler: Codeunit "BC Middleware Error Handler";

    procedure CallAzureFunctionWithRetry(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; HttpMethod: Option; var ResponseText: Text): Boolean
    var
        StartTime: DateTime;
        ResponseTime: Integer;
        CircuitBreaker: Record "Middleware Circuit Breaker";
    begin
        StartTime := CurrentDateTime;

        // Check circuit breaker
        if CircuitBreaker.Get(FunctionUrl) and CircuitBreaker.IsCircuitOpen() then begin
            ResponseText := 'Circuit breaker is open for endpoint: ' + FunctionUrl;
            exit(false);
        end;

        // Make the HTTP call with retry logic
        case HttpMethod of
            0: // GET
                if MiddlewareClient.CallAzureFunctionGET(FunctionUrl, FunctionKey, ResponseText) then begin
                    ResponseTime := CurrentDateTime - StartTime;
                    CircuitBreaker.RecordSuccess(FunctionUrl, ResponseTime);
                    exit(true);
                end else begin
                    CircuitBreaker.RecordFailure(FunctionUrl, 0);
                    exit(false);
                end;
            1: // POST
                if MiddlewareClient.CallAzureFunctionPOST(FunctionUrl, FunctionKey, RequestBody, ResponseText) then begin
                    ResponseTime := CurrentDateTime - StartTime;
                    CircuitBreaker.RecordSuccess(FunctionUrl, ResponseTime);
                    exit(true);
                end else begin
                    CircuitBreaker.RecordFailure(FunctionUrl, 0);
                    exit(false);
                end;
            2: // PUT
                if MiddlewareClient.CallAzureFunctionPUT(FunctionUrl, FunctionKey, RequestBody, ResponseText) then begin
                    ResponseTime := CurrentDateTime - StartTime;
                    CircuitBreaker.RecordSuccess(FunctionUrl, ResponseTime);
                    exit(true);
                end else begin
                    CircuitBreaker.RecordFailure(FunctionUrl, 0);
                    exit(false);
                end;
            3: // DELETE
                if MiddlewareClient.CallAzureFunctionDELETE(FunctionUrl, FunctionKey, ResponseText) then begin
                    ResponseTime := CurrentDateTime - StartTime;
                    CircuitBreaker.RecordSuccess(FunctionUrl, ResponseTime);
                    exit(true);
                end else begin
                    CircuitBreaker.RecordFailure(FunctionUrl, 0);
                    exit(false);
                end;
        end;

        exit(false);
    end;

    procedure CallAzureFunctionAsync(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; HttpMethod: Option; QueueName: Text; Priority: Integer): Integer
    begin
        // Queue the request for async processing
        exit(ServiceBusManager.EnqueueAzureFunctionCall(
            FunctionUrl,
            FunctionKey,
            RequestBody,
            HttpMethod,
            QueueName,
            Priority
        ));
    end;

    procedure CallAzureFunctionWithCircuitBreaker(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; HttpMethod: Option; var ResponseText: Text): Boolean
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
        HealthScore: Integer;
    begin
        // Check circuit breaker health
        if CircuitBreaker.Get(FunctionUrl) and CircuitBreaker.IsCircuitOpen() then begin
            ResponseText := 'Circuit breaker is open. Endpoint: ' + FunctionUrl;
            exit(false);
        end;

        HealthScore := CircuitBreaker.GetHealthScore(FunctionUrl);
        if HealthScore < 30 then begin
            ResponseText := 'Endpoint health score too low: ' + Format(HealthScore) + '%';
            exit(false);
        end;

        // Proceed with the call
        exit(CallAzureFunctionWithRetry(FunctionUrl, FunctionKey, RequestBody, HttpMethod, ResponseText));
    end;

    procedure ProcessQueueMessages(QueueName: Text; MaxMessages: Integer): Integer
    begin
        exit(ServiceBusManager.ProcessQueue(QueueName, MaxMessages));
    end;

    procedure ProcessHighPriorityMessages(QueueName: Text): Integer
    begin
        exit(BackgroundProcessor.ProcessHighPriorityMessages(QueueName));
    end;

    procedure ProcessRetryableMessages(QueueName: Text): Integer
    begin
        exit(BackgroundProcessor.ProcessRetryableMessages(QueueName));
    end;

    procedure StartBackgroundProcessing(QueueName: Text; ProcessingInterval: Integer)
    begin
        BackgroundProcessor.StartBackgroundProcessing(QueueName, ProcessingInterval);
    end;

    procedure StopBackgroundProcessing(QueueName: Text)
    begin
        BackgroundProcessor.StopBackgroundProcessing(QueueName);
    end;

    procedure GetQueueStatistics(QueueName: Text; var PendingCount: Integer; var ProcessingCount: Integer; var CompletedCount: Integer; var FailedCount: Integer; var DeadLetterCount: Integer)
    begin
        ServiceBusManager.GetQueueStatistics(
            QueueName,
            PendingCount,
            ProcessingCount,
            CompletedCount,
            FailedCount,
            DeadLetterCount
        );
    end;

    procedure GetCircuitBreakerStatus(Endpoint: Text): Text
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
        HealthScore: Integer;
    begin
        if not CircuitBreaker.Get(Endpoint) then
            exit('Circuit breaker not configured for endpoint');

        HealthScore := CircuitBreaker.GetHealthScore(Endpoint);

        exit(StrSubstNo(
            'State: %1, Health Score: %2%%, Failure Rate: %3%%, Avg Response Time: %4ms',
            CircuitBreaker."State",
            HealthScore,
            CircuitBreaker."Failure Rate",
            CircuitBreaker."Average Response Time"
        ));
    end;

    procedure ResetCircuitBreaker(Endpoint: Text)
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
    begin
        CircuitBreaker.ResetCircuit(Endpoint);
    end;

    procedure ConfigureRetrySettings(MaxAttempts: Integer; BaseDelay: Integer; MaxDelay: Integer)
    begin
        MiddlewareClient.SetRetrySettings(MaxAttempts, BaseDelay, MaxDelay);
    end;

    procedure ConfigureCircuitBreaker(Endpoint: Text; FailureThreshold: Integer; TimeoutMs: Integer)
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
    begin
        if not CircuitBreaker.Get(Endpoint) then begin
            CircuitBreaker.Init();
            CircuitBreaker."Endpoint" := Endpoint;
        end;

        CircuitBreaker."Failure Threshold" := FailureThreshold;
        CircuitBreaker."Timeout Period" := TimeoutMs;
        CircuitBreaker."Is Enabled" := true;
        CircuitBreaker.Insert(true);
    end;

    procedure TestEndpointHealth(Endpoint: Text): Boolean
    var
        ResponseText: Text;
        TestBody: Text;
        JsonObject: JsonObject;
    begin
        // Create a simple health check request
        JsonObject.Add('healthCheck', true);
        JsonObject.Add('timestamp', Format(CurrentDateTime));
        JsonObject.WriteTo(TestBody);

        exit(CallAzureFunctionWithRetry(Endpoint, '', TestBody, 1, ResponseText)); // POST method
    end;

    procedure GetSystemHealth(): Text
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
        ServiceBusQueue: Record "Service Bus Queue";
        BackgroundSetup: Record "Background Processing Setup";
        TotalEndpoints: Integer;
        HealthyEndpoints: Integer;
        TotalMessages: Integer;
        ActiveQueues: Integer;
        HealthStatus: Text;
    begin
        // Circuit breaker health
        TotalEndpoints := CircuitBreaker.Count();
        CircuitBreaker.SetRange("Is Enabled", true);
        CircuitBreaker.SetFilter("Failure Rate", '<50');
        HealthyEndpoints := CircuitBreaker.Count();

        // Queue health
        TotalMessages := ServiceBusQueue.Count();
        ServiceBusQueue.SetRange("Status", ServiceBusQueue.Status::Pending);
        TotalMessages += ServiceBusQueue.Count();

        // Background processing health
        BackgroundSetup.SetRange("Is Active", true);
        ActiveQueues := BackgroundSetup.Count();

        HealthStatus := StrSubstNo(
            'System Health - Endpoints: %1/%2 healthy, Messages: %3 pending, Active Queues: %4',
            HealthyEndpoints, TotalEndpoints, TotalMessages, ActiveQueues
        );

        exit(HealthStatus);
    end;

    procedure CleanupSystem(DaysOld: Integer): Integer
    var
        ServiceBusQueue: Record "Service Bus Queue";
        CircuitBreaker: Record "Middleware Circuit Breaker";
        CleanupCount: Integer;
    begin
        CleanupCount := 0;

        // Cleanup completed messages
        CleanupCount += ServiceBusManager.CleanupCompletedMessages(DaysOld);

        // Cleanup old circuit breaker entries
        // Note: CleanupOldEntries is a procedure, not a function
        CircuitBreaker.CleanupOldEntries(DaysOld);

        exit(CleanupCount);
    end;

    procedure GetProcessingStatistics(QueueName: Text): Text
    var
        PendingCount: Integer;
        ProcessingCount: Integer;
        CompletedCount: Integer;
        FailedCount: Integer;
        DeadLetterCount: Integer;
    begin
        GetQueueStatistics(QueueName, PendingCount, ProcessingCount, CompletedCount, FailedCount, DeadLetterCount);

        exit(StrSubstNo(
            'Queue: %1 - Pending: %2, Processing: %3, Completed: %4, Failed: %5, Dead Letter: %6',
            QueueName, PendingCount, ProcessingCount, CompletedCount, FailedCount, DeadLetterCount
        ));
    end;

    procedure MonitorEndpoints(): Text
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
        MonitoringResults: Text;
        EndpointStatus: Text;
    begin
        MonitoringResults := 'Endpoint Monitoring Results:' + '\n';

        if CircuitBreaker.FindSet() then
            repeat
                EndpointStatus := GetCircuitBreakerStatus(CircuitBreaker."Endpoint");
                MonitoringResults += StrSubstNo('%1: %2\n', CircuitBreaker."Endpoint", EndpointStatus);
            until CircuitBreaker.Next() = 0;

        exit(MonitoringResults);
    end;

    procedure EmergencyStopAllProcessing()
    var
        BackgroundSetup: Record "Background Processing Setup";
    begin
        // Stop all background processing
        if BackgroundSetup.FindSet() then
            repeat
                BackgroundSetup."Is Active" := false;
                BackgroundSetup.Modify();
            until BackgroundSetup.Next() = 0;

        // Clear all pending processing
        BackgroundSetup.SetRange("Is Active", true);
        if BackgroundSetup.FindSet() then
            repeat
                StopBackgroundProcessing(BackgroundSetup."Queue Name");
            until BackgroundSetup.Next() = 0;
    end;

    procedure EmergencyResumeProcessing()
    var
        BackgroundSetup: Record "Background Processing Setup";
    begin
        // Resume background processing for critical queues
        BackgroundSetup.SetRange("Is Active", false);
        BackgroundSetup.SetRange("Priority Threshold", 8, 10); // High priority only

        if BackgroundSetup.FindSet() then
            repeat
                BackgroundSetup."Is Active" := true;
                BackgroundSetup.Modify();
                StartBackgroundProcessing(BackgroundSetup."Queue Name", BackgroundSetup."Processing Interval");
            until BackgroundSetup.Next() = 0;
    end;

    // Custom integration procedures for hooks
    local procedure OnBeforeAzureFunctionCall(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; HttpMethod: Option; var Handled: Boolean)
    begin
        // Custom logic before making Azure Function calls
        // Can be used for authentication, logging, etc.
        Handled := false;
    end;

    local procedure OnAfterAzureFunctionCall(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; HttpMethod: Option; Success: Boolean; ResponseText: Text)
    begin
        // Custom logic after making Azure Function calls
        // Can be used for notifications, additional processing, etc.
    end;

    local procedure OnCircuitBreakerStateChanged(Endpoint: Text; OldState: Option; NewState: Option)
    begin
        // Custom logic when circuit breaker state changes
        // Can be used for alerts, logging, etc.
    end;
}
