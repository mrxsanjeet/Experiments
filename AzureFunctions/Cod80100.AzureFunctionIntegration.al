
codeunit 50700 "AzureFunctionIntegration"
{
    procedure CallAzureFunction()
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseText: Text;
        AzureFunctionUrl: Text;
    begin
        // Replace with your actual Azure Function URL
        AzureFunctionUrl := 'https://yourfunctionapp.azurewebsites.net/api/YourFunction';

        // Set up the HTTP request
        RequestMessage.SetRequestUri(AzureFunctionUrl);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');

        // Send the request
        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode then begin
                Message('Azure Function Response: %1', ResponseText);
            end else begin
                Error('Error calling Azure function. Status code: %1, Response: %2', ResponseMessage.HttpStatusCode, ResponseText);
            end;
        end else begin
            Error('Failed to send HTTP request to Azure Function');
        end;
    end;

    procedure CallAzureFunctionWithAuth(FunctionUrl: Text; FunctionKey: Text)
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseText: Text;
    begin
        // Set up the HTTP request with function key authentication
        RequestMessage.SetRequestUri(FunctionUrl);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');
        RequestHeaders.Add('x-functions-key', FunctionKey);

        // Send the request
        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode then begin
                Message('Azure Function Response: %1', ResponseText);
            end else begin
                Error('Error calling Azure function. Status code: %1, Response: %2', ResponseMessage.HttpStatusCode, ResponseText);
            end;
        end else begin
            Error('Failed to send HTTP request to Azure Function');
        end;
    end;

    procedure CallAzureFunctionPOST(FunctionUrl: Text; FunctionKey: Text; RequestBody: Text): Text
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ResponseText: Text;
    begin
        // Set up the HTTP POST request
        RequestMessage.SetRequestUri(FunctionUrl);
        RequestMessage.Method('POST');
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');

        // Add function key authentication
        if FunctionKey <> '' then
            RequestHeaders.Add('x-functions-key', FunctionKey);

        // Set request body
        if RequestBody <> '' then begin
            HttpContent.WriteFrom(RequestBody);
            HttpContent.GetHeaders(ContentHeaders);
            ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', 'application/json');
            RequestMessage.Content(HttpContent);
        end;

        // Send the request
        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode then begin
                exit(ResponseText);
            end else begin
                Error('Error calling Azure function. Status code: %1, Response: %2', ResponseMessage.HttpStatusCode, ResponseText);
            end;
        end else begin
            Error('Failed to send HTTP request to Azure Function');
        end;
    end;

    procedure CallAzureFunctionWithQuery(FunctionUrl: Text; FunctionKey: Text; QueryParams: Dictionary of [Text, Text]): Text
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseText: Text;
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

        // Set up the HTTP request
        RequestMessage.SetRequestUri(FullUrl);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');

        // Add function key authentication
        if FunctionKey <> '' then
            RequestHeaders.Add('x-functions-key', FunctionKey);

        // Send the request
        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode then begin
                exit(ResponseText);
            end else begin
                Error('Error calling Azure function. Status code: %1, Response: %2', ResponseMessage.HttpStatusCode, ResponseText);
            end;
        end else begin
            Error('Failed to send HTTP request to Azure Function');
        end;
    end;

    procedure CallQRGeneratorFunction(CustomerNo: Code[20]; URL: Text): Boolean
    var
        FunctionUrl: Text;
        FunctionKey: Text;
        RequestBody: Text;
        ResponseText: Text;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        InStream: InStream;
        OutStream: OutStream;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        Base64Data: Text;
        FileName: Text;
    begin
        // Configure your QR Generator function
        FunctionUrl := 'https://sdqrcodegenerator.azurewebsites.net/api/QRGenerator';
        FunctionKey := 'YOUR_FUNCTION_KEY_HERE';

        // Prepare JSON request body
        RequestBody := '{"url": "' + URL + '"}';

        // Call the Azure Function
        ResponseText := CallAzureFunctionPOST(FunctionUrl, FunctionKey, RequestBody);

        if ResponseText <> '' then begin
            // If the response contains base64 image data, process it
            if JsonResponse.ReadFrom(ResponseText) then begin
                if JsonResponse.Get('imageData', JsonToken) then begin
                    Base64Data := JsonToken.AsValue().AsText();

                    // Convert base64 to stream and download
                    TempBlob.CreateOutStream(OutStream);
                    Base64Convert.FromBase64(Base64Data, OutStream);
                    TempBlob.CreateInStream(InStream);

                    FileName := CustomerNo + '_QRCode.jpg';
                    DownloadFromStream(InStream, 'QR Code', '', '', FileName);
                    exit(true);
                end;
            end else begin
                // If response is direct binary data, treat as base64
                TempBlob.CreateOutStream(OutStream);
                Base64Convert.FromBase64(ResponseText, OutStream);
                TempBlob.CreateInStream(InStream);

                FileName := CustomerNo + '_QRCode.jpg';
                DownloadFromStream(InStream, 'QR Code', '', '', FileName);
                exit(true);
            end;
        end;

        exit(false);
    end;

    procedure TestAzureFunctionConnection(FunctionUrl: Text; FunctionKey: Text): Boolean
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseText: Text;
    begin
        // Test connection to Azure Function
        RequestMessage.SetRequestUri(FunctionUrl);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');

        if FunctionKey <> '' then
            RequestHeaders.Add('x-functions-key', FunctionKey);

        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode then begin
                Message('Connection successful! Response: %1', ResponseText);
                exit(true);
            end else begin
                Message('Connection failed. Status: %1, Response: %2', ResponseMessage.HttpStatusCode, ResponseText);
                exit(false);
            end;
        end else begin
            Message('Failed to connect to Azure Function');
            exit(false);
        end;
    end;

    trigger OnRun()
    begin
        // Call the Azure function
        CallAzureFunction();
    end;
}

