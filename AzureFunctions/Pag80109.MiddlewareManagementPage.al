page 80109 "Middleware Management Page"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Azure Functions Middleware Management';

    layout
    {
        area(Content)
        {
            group(Configuration)
            {
                Caption = 'Configuration';

                field(FunctionUrl; FunctionUrl)
                {
                    ApplicationArea = All;
                    Caption = 'Azure Function URL';
                    ToolTip = 'Enter the URL of your Azure Function';
                }

                field(FunctionKey; FunctionKey)
                {
                    ApplicationArea = All;
                    Caption = 'Function Key';
                    ToolTip = 'Enter the function key for authentication';
                    ExtendedDatatype = Masked;
                }

                field(QueueName; QueueName)
                {
                    ApplicationArea = All;
                    Caption = 'Queue Name';
                    ToolTip = 'Enter the queue name for async processing';
                }

                field(RequestBody; RequestBody)
                {
                    ApplicationArea = All;
                    Caption = 'Request Body (JSON)';
                    ToolTip = 'Enter JSON request body for POST requests';
                    MultiLine = true;
                }

                field(HttpMethod; HttpMethod)
                {
                    ApplicationArea = All;
                    Caption = 'HTTP Method';
                    ToolTip = 'Select the HTTP method for the request';
                }

                field(Priority; Priority)
                {
                    ApplicationArea = All;
                    Caption = 'Priority (1-10)';
                    ToolTip = 'Enter message priority (1=low, 10=high)';
                    MinValue = 1;
                    MaxValue = 10;
                }
            }

            group(RetrySettings)
            {
                Caption = 'Retry Settings';

                field(MaxRetryAttempts; MaxRetryAttempts)
                {
                    ApplicationArea = All;
                    Caption = 'Max Retry Attempts';
                    ToolTip = 'Maximum number of retry attempts';
                    MinValue = 1;
                    MaxValue = 10;
                }

                field(BaseDelayMs; BaseDelayMs)
                {
                    ApplicationArea = All;
                    Caption = 'Base Delay (ms)';
                    ToolTip = 'Base delay between retries in milliseconds';
                    MinValue = 100;
                    MaxValue = 10000;
                }

                field(MaxDelayMs; MaxDelayMs)
                {
                    ApplicationArea = All;
                    Caption = 'Max Delay (ms)';
                    ToolTip = 'Maximum delay between retries in milliseconds';
                    MinValue = 1000;
                    MaxValue = 60000;
                }
            }

            group(CircuitBreakerSettings)
            {
                Caption = 'Circuit Breaker Settings';

                field(FailureThreshold; FailureThreshold)
                {
                    ApplicationArea = All;
                    Caption = 'Failure Threshold';
                    ToolTip = 'Number of failures before opening circuit';
                    MinValue = 1;
                    MaxValue = 100;
                }

                field(TimeoutPeriodMs; TimeoutPeriodMs)
                {
                    ApplicationArea = All;
                    Caption = 'Timeout Period (ms)';
                    ToolTip = 'Time to wait before trying half-open state';
                    MinValue = 1000;
                    MaxValue = 3600000;
                }
            }

            group(Response)
            {
                Caption = 'Response';

                field(ResponseText; ResponseText)
                {
                    ApplicationArea = All;
                    Caption = 'Response';
                    ToolTip = 'Response from Azure Function';
                    MultiLine = true;
                    Editable = false;
                }

                field(ProcessingStatus; ProcessingStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Processing Status';
                    ToolTip = 'Current processing status';
                    MultiLine = true;
                    Editable = false;
                }
            }

            group(Statistics)
            {
                Caption = 'Statistics';

                field(QueueStatistics; QueueStatistics)
                {
                    ApplicationArea = All;
                    Caption = 'Queue Statistics';
                    ToolTip = 'Current queue statistics';
                    MultiLine = true;
                    Editable = false;
                }

                field(CircuitBreakerStatus; CircuitBreakerStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Circuit Breaker Status';
                    ToolTip = 'Circuit breaker status for the endpoint';
                    MultiLine = true;
                    Editable = false;
                }

                field(SystemHealth; SystemHealth)
                {
                    ApplicationArea = All;
                    Caption = 'System Health';
                    ToolTip = 'Overall system health status';
                    MultiLine = true;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(SynchronousOperations)
            {
                Caption = 'Synchronous Operations';

                action(TestConnection)
                {
                    ApplicationArea = All;
                    Caption = 'Test Connection';
                    Image = TestDatabase;
                    ToolTip = 'Test connection to Azure Function';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        if FunctionUrl = '' then
                            Error('Please enter a Function URL');

                        if EnhancedIntegration.TestEndpointHealth(FunctionUrl) then begin
                            Message('Connection test successful!');
                            ProcessingStatus := 'Connection successful';
                        end else begin
                            Message('Connection test failed!');
                            ProcessingStatus := 'Connection failed';
                        end;
                        CurrPage.Update();
                    end;
                }

                action(CallSynchronous)
                {
                    ApplicationArea = All;
                    Caption = 'Call Synchronously';
                    Image = ExecuteBatch;
                    ToolTip = 'Call Azure Function synchronously with retry logic';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        if FunctionUrl = '' then
                            Error('Please enter a Function URL');

                        // Configure retry settings
                        EnhancedIntegration.ConfigureRetrySettings(MaxRetryAttempts, BaseDelayMs, MaxDelayMs);

                        // Configure circuit breaker
                        EnhancedIntegration.ConfigureCircuitBreaker(FunctionUrl, FailureThreshold, TimeoutPeriodMs);

                        if EnhancedIntegration.CallAzureFunctionWithRetry(
                            FunctionUrl, FunctionKey, RequestBody, HttpMethod, ResponseText) then begin
                            Message('Azure Function call successful!');
                            ProcessingStatus := 'Synchronous call completed successfully';
                        end else begin
                            Message('Azure Function call failed: %1', ResponseText);
                            ProcessingStatus := 'Synchronous call failed: ' + ResponseText;
                        end;
                        CurrPage.Update();
                    end;
                }

                action(CallWithCircuitBreaker)
                {
                    ApplicationArea = All;
                    Caption = 'Call with Circuit Breaker';
                    Image = ExecuteBatch;
                    ToolTip = 'Call Azure Function with circuit breaker protection';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        if FunctionUrl = '' then
                            Error('Please enter a Function URL');

                        if EnhancedIntegration.CallAzureFunctionWithCircuitBreaker(
                            FunctionUrl, FunctionKey, RequestBody, HttpMethod, ResponseText) then begin
                            Message('Azure Function call successful!');
                            ProcessingStatus := 'Circuit breaker call completed successfully';
                        end else begin
                            Message('Azure Function call failed: %1', ResponseText);
                            ProcessingStatus := 'Circuit breaker call failed: ' + ResponseText;
                        end;
                        CurrPage.Update();
                    end;
                }
            }

            group(AsynchronousOperations)
            {
                Caption = 'Asynchronous Operations';

                action(EnqueueMessage)
                {
                    ApplicationArea = All;
                    Caption = 'Enqueue Message';
                    Image = Process;
                    ToolTip = 'Enqueue message for async processing';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                        EntryNo: Integer;
                    begin
                        if FunctionUrl = '' then
                            Error('Please enter a Function URL');
                        if QueueName = '' then
                            Error('Please enter a Queue Name');

                        EntryNo := EnhancedIntegration.CallAzureFunctionAsync(
                            FunctionUrl, FunctionKey, RequestBody, HttpMethod, QueueName, Priority);

                        Message('Message enqueued successfully! Entry No.: %1', EntryNo);
                        ProcessingStatus := StrSubstNo('Message enqueued with Entry No.: %1', EntryNo);
                        CurrPage.Update();
                    end;
                }

                action(ProcessQueue)
                {
                    ApplicationArea = All;
                    Caption = 'Process Queue';
                    Image = Process;
                    ToolTip = 'Process messages in the queue';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                        ProcessedCount: Integer;
                    begin
                        if QueueName = '' then
                            Error('Please enter a Queue Name');

                        ProcessedCount := EnhancedIntegration.ProcessQueueMessages(QueueName, 10);
                        Message('Processed %1 messages from queue: %2', ProcessedCount, QueueName);
                        ProcessingStatus := StrSubstNo('Processed %1 messages from queue', ProcessedCount);
                        CurrPage.Update();
                    end;
                }

                action(ProcessHighPriority)
                {
                    ApplicationArea = All;
                    Caption = 'Process High Priority';
                    Image = Process;
                    ToolTip = 'Process high priority messages only';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                        ProcessedCount: Integer;
                    begin
                        if QueueName = '' then
                            Error('Please enter a Queue Name');

                        ProcessedCount := EnhancedIntegration.ProcessHighPriorityMessages(QueueName);
                        Message('Processed %1 high priority messages', ProcessedCount);
                        ProcessingStatus := StrSubstNo('Processed %1 high priority messages', ProcessedCount);
                        CurrPage.Update();
                    end;
                }

                action(ProcessRetryable)
                {
                    ApplicationArea = All;
                    Caption = 'Process Retryable';
                    Image = Process;
                    ToolTip = 'Process retryable failed messages';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                        ProcessedCount: Integer;
                    begin
                        if QueueName = '' then
                            Error('Please enter a Queue Name');

                        ProcessedCount := EnhancedIntegration.ProcessRetryableMessages(QueueName);
                        Message('Processed %1 retryable messages', ProcessedCount);
                        ProcessingStatus := StrSubstNo('Processed %1 retryable messages', ProcessedCount);
                        CurrPage.Update();
                    end;
                }
            }

            group(BackgroundProcessing)
            {
                Caption = 'Background Processing';

                action(StartBackground)
                {
                    ApplicationArea = All;
                    Caption = 'Start Background Processing';
                    Image = Start;
                    ToolTip = 'Start background processing for the queue';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        if QueueName = '' then
                            Error('Please enter a Queue Name');

                        EnhancedIntegration.StartBackgroundProcessing(QueueName, 30000); // 30 seconds
                        Message('Background processing started for queue: %1', QueueName);
                        ProcessingStatus := 'Background processing started';
                        CurrPage.Update();
                    end;
                }

                action(StopBackground)
                {
                    ApplicationArea = All;
                    Caption = 'Stop Background Processing';
                    Image = Stop;
                    ToolTip = 'Stop background processing for the queue';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        if QueueName = '' then
                            Error('Please enter a Queue Name');

                        EnhancedIntegration.StopBackgroundProcessing(QueueName);
                        Message('Background processing stopped for queue: %1', QueueName);
                        ProcessingStatus := 'Background processing stopped';
                        CurrPage.Update();
                    end;
                }
            }

            group(Monitoring)
            {
                Caption = 'Monitoring';

                action(RefreshStatistics)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh Statistics';
                    Image = Refresh;
                    ToolTip = 'Refresh all statistics and status information';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                        PendingCount: Integer;
                        ProcessingCount: Integer;
                        CompletedCount: Integer;
                        FailedCount: Integer;
                        DeadLetterCount: Integer;
                    begin
                        // Refresh queue statistics
                        if QueueName <> '' then begin
                            EnhancedIntegration.GetQueueStatistics(
                                QueueName, PendingCount, ProcessingCount, CompletedCount, FailedCount, DeadLetterCount);
                            QueueStatistics := StrSubstNo(
                                'Pending: %1, Processing: %2, Completed: %3, Failed: %4, Dead Letter: %5',
                                PendingCount, ProcessingCount, CompletedCount, FailedCount, DeadLetterCount);
                        end;

                        // Refresh circuit breaker status
                        if FunctionUrl <> '' then
                            CircuitBreakerStatus := EnhancedIntegration.GetCircuitBreakerStatus(FunctionUrl);

                        // Refresh system health
                        SystemHealth := EnhancedIntegration.GetSystemHealth();

                        Message('Statistics refreshed successfully!');
                        CurrPage.Update();
                    end;
                }

                action(MonitorEndpoints)
                {
                    ApplicationArea = All;
                    Caption = 'Monitor All Endpoints';
                    Image = TestDatabase;
                    ToolTip = 'Monitor all configured endpoints';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        Message(EnhancedIntegration.MonitorEndpoints());
                    end;
                }

                action(ResetCircuitBreaker)
                {
                    ApplicationArea = All;
                    Caption = 'Reset Circuit Breaker';
                    Image = ResetStatus;
                    ToolTip = 'Reset circuit breaker for the endpoint';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        if FunctionUrl = '' then
                            Error('Please enter a Function URL');

                        EnhancedIntegration.ResetCircuitBreaker(FunctionUrl);
                        Message('Circuit breaker reset for endpoint: %1', FunctionUrl);
                        ProcessingStatus := 'Circuit breaker reset';
                        CurrPage.Update();
                    end;
                }
            }

            group(Maintenance)
            {
                Caption = 'Maintenance';

                action(CleanupSystem)
                {
                    ApplicationArea = All;
                    Caption = 'Cleanup System';
                    Image = Process;
                    ToolTip = 'Cleanup old completed messages and circuit breaker entries';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                        CleanupCount: Integer;
                    begin
                        CleanupCount := EnhancedIntegration.CleanupSystem(7); // 7 days old
                        Message('Cleanup completed. Removed %1 entries.', CleanupCount);
                        ProcessingStatus := StrSubstNo('Cleanup completed: %1 entries removed', CleanupCount);
                        CurrPage.Update();
                    end;
                }

                action(EmergencyStop)
                {
                    ApplicationArea = All;
                    Caption = 'Emergency Stop All Processing';
                    Image = Stop;
                    ToolTip = 'Emergency stop all background processing';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        if Confirm('Are you sure you want to stop all background processing?') then begin
                            EnhancedIntegration.EmergencyStopAllProcessing();
                            Message('All background processing stopped!');
                            ProcessingStatus := 'Emergency stop executed';
                            CurrPage.Update();
                        end;
                    end;
                }

                action(EmergencyResume)
                {
                    ApplicationArea = All;
                    Caption = 'Emergency Resume Processing';
                    Image = Start;
                    ToolTip = 'Resume high priority background processing';

                    trigger OnAction()
                    var
                        EnhancedIntegration: Codeunit "Enhanced Azure Function Int.";
                    begin
                        if Confirm('Are you sure you want to resume background processing?') then begin
                            EnhancedIntegration.EmergencyResumeProcessing();
                            Message('High priority background processing resumed!');
                            ProcessingStatus := 'Emergency resume executed';
                            CurrPage.Update();
                        end;
                    end;
                }
            }
        }
    }

    var
        FunctionUrl: Text;
        FunctionKey: Text;
        QueueName: Text;
        RequestBody: Text;
        HttpMethod: Option GET,POST,PUT,DELETE;
        Priority: Integer;
        MaxRetryAttempts: Integer;
        BaseDelayMs: Integer;
        MaxDelayMs: Integer;
        FailureThreshold: Integer;
        TimeoutPeriodMs: Integer;
        ResponseText: Text;
        ProcessingStatus: Text;
        QueueStatistics: Text;
        CircuitBreakerStatus: Text;
        SystemHealth: Text;

    trigger OnOpenPage()
    begin
        // Set default values
        FunctionUrl := 'https://yourfunctionapp.azurewebsites.net/api/YourFunction';
        FunctionKey := 'YOUR_FUNCTION_KEY_HERE';
        QueueName := 'DEFAULT_QUEUE';
        RequestBody := '{"message": "Hello from Business Central Middleware!", "timestamp": "' + Format(CurrentDateTime) + '"}';
        HttpMethod := HttpMethod::POST;
        Priority := 5;
        MaxRetryAttempts := 3;
        BaseDelayMs := 1000;
        MaxDelayMs := 30000;
        FailureThreshold := 5;
        TimeoutPeriodMs := 60000;
        ResponseText := '';
        ProcessingStatus := 'Ready';
        QueueStatistics := 'Not loaded';
        CircuitBreakerStatus := 'Not configured';
        SystemHealth := 'Not loaded';
    end;
}
