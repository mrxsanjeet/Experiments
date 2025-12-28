codeunit 80110 "BC Middleware Client"
{
    // Enhanced HttpClient wrapper with retry logic and error handling for Azure Functions middleware

    var
        ErrorHandler: Codeunit "BC Middleware Error Handler";
        HttpClient: HttpClient;
        RequestHeaders: HttpHeaders;
        ResponseHeaders: HttpHeaders;
        TimeoutMs: Integer;

    trigger OnRun()
    begin
        InitializeClient();
    end;

    procedure InitializeClient()
    begin
        HttpClient.Clear();
        // Note: SetTimeout is not available in AL HttpClient
        TimeoutMs := 30000; // 30 second default timeout
        ErrorHandler.InitializeRetrySettings();
    end;

    procedure SetTimeout(Timeout: Integer)
    begin
        TimeoutMs := Timeout;
        // Note: SetTimeout is not available in AL HttpClient
    end;

    procedure SetDefaultHeaders()
    begin
        HttpClient.DefaultRequestHeaders.Clear();
        HttpClient.DefaultRequestHeaders.Add('Accept', 'application/json');
        HttpClient.DefaultRequestHeaders.Add('User-Agent', 'Business-Central-Middleware/1.0');
        HttpClient.DefaultRequestHeaders.Add('Content-Type', 'application/json');
    end;

    procedure AddHeader(Name: Text; Value: Text)
    begin
        HttpClient.DefaultRequestHeaders.Add(Name, Value);
    end;

    procedure RemoveHeader(Name: Text)
    begin
        HttpClient.DefaultRequestHeaders.Remove(Name);
    end;

    procedure CallAzureFunctionGET(FunctionUrl: Text; FunctionKey: Text; var ResponseText: Text): Boolean
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
    begin
        RequestMessage.SetRequestUri(FunctionUrl);
        RequestMessage.Method('GET');

        if RequestMessage.GetHeaders(Headers) then begin
            Headers.Clear();
            Headers.Add('Accept', 'application/json');
            if FunctionKey <> '' then
                Headers.Add('x-functions-key', FunctionKey);
        end;

        if ErrorHandler.ExecuteWithRetry(HttpClient, RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            exit(true);
        end else begin
            ResponseText := GetErrorMessage(ResponseMessage);
            exit(false);
        end;
    end;

    procedure CallAzureFunctionPOST(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; var ResponseText: Text): Boolean
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
    begin
        RequestMessage.SetRequestUri(FunctionUrl);
        RequestMessage.Method('POST');

        if RequestMessage.GetHeaders(Headers) then begin
            Headers.Clear();
            Headers.Add('Accept', 'application/json');
            if FunctionKey <> '' then
                Headers.Add('x-functions-key', FunctionKey);
        end;

        if RequestBody <> '' then begin
            HttpContent.WriteFrom(RequestBody);
            if HttpContent.GetHeaders(ContentHeaders) then begin
                ContentHeaders.Remove('Content-Type');
                ContentHeaders.Add('Content-Type', 'application/json');
            end;
            RequestMessage.Content(HttpContent);
        end;

        if ErrorHandler.ExecuteWithRetry(HttpClient, RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            exit(true);
        end else begin
            ResponseText := GetErrorMessage(ResponseMessage);
            exit(false);
        end;
    end;

    procedure CallAzureFunctionPUT(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; var ResponseText: Text): Boolean
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
    begin
        RequestMessage.SetRequestUri(FunctionUrl);
        RequestMessage.Method('PUT');

        if RequestMessage.GetHeaders(Headers) then begin
            Headers.Clear();
            Headers.Add('Accept', 'application/json');
            if FunctionKey <> '' then
                Headers.Add('x-functions-key', FunctionKey);
        end;

        if RequestBody <> '' then begin
            HttpContent.WriteFrom(RequestBody);
            if HttpContent.GetHeaders(ContentHeaders) then begin
                ContentHeaders.Remove('Content-Type');
                ContentHeaders.Add('Content-Type', 'application/json');
            end;
            RequestMessage.Content(HttpContent);
        end;

        if ErrorHandler.ExecuteWithRetry(HttpClient, RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            exit(true);
        end else begin
            ResponseText := GetErrorMessage(ResponseMessage);
            exit(false);
        end;
    end;

    procedure CallAzureFunctionDELETE(FunctionUrl: Text; FunctionKey: Text; var ResponseText: Text): Boolean
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
    begin
        RequestMessage.SetRequestUri(FunctionUrl);
        RequestMessage.Method('DELETE');

        if RequestMessage.GetHeaders(Headers) then begin
            Headers.Clear();
            Headers.Add('Accept', 'application/json');
            if FunctionKey <> '' then
                Headers.Add('x-functions-key', FunctionKey);
        end;

        if ErrorHandler.ExecuteWithRetry(HttpClient, RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            exit(true);
        end else begin
            ResponseText := GetErrorMessage(ResponseMessage);
            exit(false);
        end;
    end;

    procedure CallAzureFunctionWithQuery(FunctionUrl: Text; FunctionKey: Text; QueryParams: Dictionary of [Text, Text]; var ResponseText: Text): Boolean
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        FullUrl: Text;
        QueryString: Text;
        ParamKey: Text;
        FirstParam: Boolean;
    begin
        FullUrl := FunctionUrl;
        FirstParam := true;

        // Build query string
        foreach ParamKey in QueryParams.Keys do begin
            if FirstParam then begin
                QueryString := '?';
                FirstParam := false;
            end else begin
                QueryString += '&';
            end;
            QueryString += ParamKey + '=' + QueryParams.Get(ParamKey);
        end;

        FullUrl += QueryString;

        RequestMessage.SetRequestUri(FullUrl);
        RequestMessage.Method('GET');

        if RequestMessage.GetHeaders(Headers) then begin
            Headers.Clear();
            Headers.Add('Accept', 'application/json');
            if FunctionKey <> '' then
                Headers.Add('x-functions-key', FunctionKey);
        end;

        if ErrorHandler.ExecuteWithRetry(HttpClient, RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            exit(true);
        end else begin
            ResponseText := GetErrorMessage(ResponseMessage);
            exit(false);
        end;
    end;

    procedure CallAzureFunctionAsync(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text; var ResponseText: Text): Boolean
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        ContentHeaders: HttpHeaders;
    begin
        // Async call - uses background processing
        RequestMessage.SetRequestUri(FunctionUrl);
        RequestMessage.Method('POST');

        if RequestMessage.GetHeaders(Headers) then begin
            Headers.Clear();
            Headers.Add('Accept', 'application/json');
            if FunctionKey <> '' then
                Headers.Add('x-functions-key', FunctionKey);
        end;

        if RequestBody <> '' then begin
            HttpContent.WriteFrom(RequestBody);
            if HttpContent.GetHeaders(ContentHeaders) then begin
                ContentHeaders.Remove('Content-Type');
                ContentHeaders.Add('Content-Type', 'application/json');
            end;
            RequestMessage.Content(HttpContent);
        end;

        if ErrorHandler.ExecuteWithRetryAsync(HttpClient, RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            exit(true);
        end else begin
            ResponseText := GetErrorMessage(ResponseMessage);
            exit(false);
        end;
    end;

    local procedure GetErrorMessage(var ResponseMessage: HttpResponseMessage): Text
    var
        ErrorText: Text;
    begin
        if ResponseMessage.HttpStatusCode <> 0 then
            ErrorText := StrSubstNo('HTTP Error %1: %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase)
        else
            ErrorText := 'Network connection failed';

        exit(ErrorText);
    end;

    procedure TestConnection(FunctionUrl: Text; FunctionKey: Text): Boolean
    var
        ResponseText: Text;
    begin
        exit(CallAzureFunctionGET(FunctionUrl, FunctionKey, ResponseText));
    end;

    procedure GetResponseHeaders(var ResponseHeaders: HttpHeaders)
    begin
        ResponseHeaders := ResponseHeaders;
    end;

    procedure SetRetrySettings(MaxAttempts: Integer; BaseDelay: Integer; MaxDelay: Integer)
    begin
        ErrorHandler.SetRetrySettings(MaxAttempts, BaseDelay, MaxDelay);
    end;

    procedure GetRetrySettings(var MaxAttempts: Integer; var BaseDelay: Integer; var MaxDelay: Integer)
    begin
        ErrorHandler.GetRetrySettings(MaxAttempts, BaseDelay, MaxDelay);
    end;

    // Circuit breaker pattern implementation
    procedure IsCircuitOpen(): Boolean
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
    begin
        // Check if circuit breaker is open for this endpoint
        exit(CircuitBreaker.IsCircuitOpen());
    end;

    procedure RecordFailure(Endpoint: Text; ErrorCode: Integer)
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
    begin
        CircuitBreaker.RecordFailure(Endpoint, ErrorCode);
    end;

    procedure RecordSuccess(Endpoint: Text)
    var
        CircuitBreaker: Record "Middleware Circuit Breaker";
    begin
        CircuitBreaker.RecordSuccess(Endpoint);
    end;
}
