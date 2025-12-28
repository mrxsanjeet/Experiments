codeunit 80101 "BC Middleware Error Handler"
{
    // Error Handler Codeunit for handling transient faults with exponential backoff

    var
        MaxRetryAttempts: Integer;
        BaseDelayMs: Integer;
        MaxDelayMs: Integer;

    trigger OnRun()
    begin
        InitializeRetrySettings();
    end;

    procedure InitializeRetrySettings()
    begin
        // Configurable retry settings - can be moved to setup table
        MaxRetryAttempts := 3;
        BaseDelayMs := 1000; // 1 second base delay
        MaxDelayMs := 30000; // 30 seconds max delay
    end;

    procedure SetRetrySettings(MaxAttempts: Integer; BaseDelay: Integer; MaxDelay: Integer)
    begin
        MaxRetryAttempts := MaxAttempts;
        BaseDelayMs := BaseDelay;
        MaxDelayMs := MaxDelay;
    end;

    procedure ExecuteWithRetry(var HttpClient: HttpClient; var RequestMessage: HttpRequestMessage; var ResponseMessage: HttpResponseMessage): Boolean
    var
        Attempt: Integer;
        DelayMs: Integer;
        IsRetryable: Boolean;
    begin
        Attempt := 1;
        repeat
            if HttpClient.Send(RequestMessage, ResponseMessage) then begin
                if ResponseMessage.IsSuccessStatusCode then
                    exit(true);

                // Check if error is retryable
                IsRetryable := IsRetryableError(ResponseMessage.HttpStatusCode);
                if not IsRetryable then
                    exit(false);
            end else begin
                // Network error - always retryable
                IsRetryable := true;
            end;

            // If this is the last attempt, don't wait
            if Attempt >= MaxRetryAttempts then
                exit(false);

            // Calculate exponential backoff delay
            DelayMs := CalculateExponentialDelay(Attempt);

            // Log retry attempt
            LogRetryAttempt(Attempt, ResponseMessage.HttpStatusCode, DelayMs);

            // Wait before retry
            Sleep(DelayMs);

            Attempt += 1;
        until Attempt > MaxRetryAttempts;

        exit(false);
    end;

    procedure ExecuteWithRetryAsync(HttpClient: HttpClient; RequestMessage: HttpRequestMessage; var ResponseMessage: HttpResponseMessage): Boolean
    var
        Attempt: Integer;
        DelayMs: Integer;
        IsRetryable: Boolean;
        TempHttpClient: HttpClient;
    begin
        // For async operations, use a temporary HttpClient to avoid state issues
        TempHttpClient := HttpClient;

        Attempt := 1;
        repeat
            if TempHttpClient.Send(RequestMessage, ResponseMessage) then begin
                if ResponseMessage.IsSuccessStatusCode then
                    exit(true);

                IsRetryable := IsRetryableError(ResponseMessage.HttpStatusCode);
                if not IsRetryable then
                    exit(false);
            end else begin
                IsRetryable := true;
            end;

            if Attempt >= MaxRetryAttempts then
                exit(false);

            DelayMs := CalculateExponentialDelay(Attempt);
            LogRetryAttempt(Attempt, ResponseMessage.HttpStatusCode, DelayMs);
            Sleep(DelayMs);

            Attempt += 1;
        until Attempt > MaxRetryAttempts;

        exit(false);
    end;

    local procedure IsRetryableError(StatusCode: Integer): Boolean
    begin
        // HTTP status codes that are typically retryable
        case StatusCode of
            408, // Request Timeout
            429, // Too Many Requests
            500, // Internal Server Error
            502, // Bad Gateway
            503, // Service Unavailable
            504: // Gateway Timeout
                exit(true);
            else
                exit(false);
        end;
    end;

    local procedure CalculateExponentialDelay(Attempt: Integer): Integer
    var
        Delay: Decimal;
        Jitter: Decimal;
    begin
        // Exponential backoff: baseDelay * (2 ^ (attempt - 1))
        Delay := BaseDelayMs * Power(2, Attempt - 1);

        // Add jitter to prevent thundering herd (random factor between 0.8 and 1.2)
        Jitter := 0.8 + (Random(40) / 100); // Random between 0.8 and 1.2
        Delay := Delay * Jitter;

        // Cap at maximum delay
        if Delay > MaxDelayMs then
            Delay := MaxDelayMs;

        exit(Round(Delay, 1));
    end;

    local procedure LogRetryAttempt(Attempt: Integer; StatusCode: Integer; DelayMs: Integer)
    begin
        // Log retry attempts for monitoring and debugging
        // Note: In a real implementation, you would log to a custom logging table
        // or use Application Insights, Event Log, or similar service
    end;

    procedure HandleTransientFault(ExceptionMessage: Text): Boolean
    begin
        // Handle transient faults that might occur during HTTP operations
        // Check for common transient fault indicators
        if StrPos(ExceptionMessage, 'timeout') > 0 then
            exit(true);
        if StrPos(ExceptionMessage, 'connection') > 0 then
            exit(true);
        if StrPos(ExceptionMessage, 'network') > 0 then
            exit(true);
        if StrPos(ExceptionMessage, 'temporary') > 0 then
            exit(true);

        exit(false);
    end;

    procedure GetRetrySettings(var MaxAttempts: Integer; var BaseDelay: Integer; var MaxDelay: Integer)
    begin
        MaxAttempts := MaxRetryAttempts;
        BaseDelay := BaseDelayMs;
        MaxDelay := MaxDelayMs;
    end;

    // Custom retry logic procedures
    local procedure OnBeforeRetry(var HttpClient: HttpClient; var RequestMessage: HttpRequestMessage; Attempt: Integer; var Handled: Boolean)
    begin
        // Custom logic before retry attempt
        // Can be used to modify headers, add circuit breaker logic, etc.
        Handled := false;
    end;

    local procedure OnAfterRetry(var HttpClient: HttpClient; var RequestMessage: HttpRequestMessage; Attempt: Integer; Success: Boolean)
    begin
        // Custom logic after retry attempt
        // Can be used for logging, metrics, etc.
    end;
}
