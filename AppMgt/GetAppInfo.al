codeunit 50110 GetAppInfo
{
    trigger OnRun()
    begin
        GetAppInformation();
    end;

    procedure GetAppInformation()
    var
        ClientId: Text[100];
        ClientSecret: Text[250];
        TenantId: Text[100];
        Scope: Text[250];
        AccessToken: Text[1000];
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ResponseText: Text;
        TokenUrl: Text;
        GraphApiUrl: Text;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        AccessTokenValue: JsonValue;
    begin
        // Initialize OAuth 2.0 parameters
        ClientId := 'YOUR_CLIENT_ID';
        ClientSecret := 'YOUR_CLIENT_SECRET';
        TenantId := 'YOUR_TENANT_ID';
        Scope := 'https://graph.microsoft.com/.default';

        // Acquire access token using client credentials flow
        AccessToken := GetAccessToken(ClientId, ClientSecret, TenantId, Scope);

        if AccessToken <> '' then begin
            // Call Microsoft Graph API to get applications
            GetInstalledAppsAndDependencies(AccessToken);
        end else begin
            Message('Failed to acquire access token');
        end;
    end;

    local procedure GetAccessToken(ClientId: Text; ClientSecret: Text; TenantId: Text; Scope: Text): Text
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        HttpContent: HttpContent;
        ResponseText: Text;
        TokenUrl: Text;
        RequestBody: Text;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        AccessTokenValue: JsonValue;
    begin
        TokenUrl := 'https://login.microsoftonline.com/' + TenantId + '/oauth2/v2.0/token';

        // Prepare the request body for OAuth 2.0 client credentials flow
        RequestBody := 'grant_type=client_credentials';
        RequestBody += '&client_id=' + ClientId;
        RequestBody += '&client_secret=' + ClientSecret;
        RequestBody += '&scope=' + Scope;

        // Set up the HTTP request
        RequestMessage.SetRequestUri(TokenUrl);
        RequestMessage.Method('POST');
        RequestMessage.GetHeaders(RequestHeaders);

        // Set content
        HttpContent.WriteFrom(RequestBody);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        RequestMessage.Content(HttpContent);

        // Send the request
        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode then begin
                // Parse JSON response to extract access token
                if JsonResponse.ReadFrom(ResponseText) then begin
                    if JsonResponse.Get('access_token', JsonToken) then begin
                        AccessTokenValue := JsonToken.AsValue();
                        exit(AccessTokenValue.AsText());
                    end;
                end;
            end else begin
                Message('Token request failed: %1', ResponseText);
            end;
        end;

        exit('');
    end;

    local procedure GetInstalledAppsAndDependencies(AccessToken: Text)
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseText: Text;
        GraphApiUrl: Text;
        JsonResponse: JsonObject;
        JsonToken: JsonToken;
        AppsArray: JsonArray;
        AppToken: JsonToken;
        AppObject: JsonObject;
        AppName: Text;
        AppId: Text;
        Publisher: Text;
        i: Integer;
    begin
        GraphApiUrl := 'https://graph.microsoft.com/v1.0/applications';

        // Set up the HTTP request
        RequestMessage.SetRequestUri(GraphApiUrl);
        RequestMessage.Method('GET');
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        // Send the request
        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            if ResponseMessage.IsSuccessStatusCode then begin
                // Parse JSON response
                if JsonResponse.ReadFrom(ResponseText) then begin
                    if JsonResponse.Get('value', JsonToken) then begin
                        AppsArray := JsonToken.AsArray();

                        // Process each application
                        for i := 0 to AppsArray.Count - 1 do begin
                            AppsArray.Get(i, AppToken);
                            AppObject := AppToken.AsObject();

                            // Extract application details
                            if AppObject.Get('displayName', JsonToken) then
                                AppName := JsonToken.AsValue().AsText();
                            if AppObject.Get('appId', JsonToken) then
                                AppId := JsonToken.AsValue().AsText();
                            if AppObject.Get('publisherDisplayName', JsonToken) then
                                Publisher := JsonToken.AsValue().AsText();

                            // Display or process the application information
                            Message('App: %1, ID: %2, Publisher: %3', AppName, AppId, Publisher);
                        end;
                    end;
                end;
            end else begin
                Message('Graph API request failed: %1', ResponseText);
            end;
        end;
    end;
}
