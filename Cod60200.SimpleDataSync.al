codeunit 60200 "Simple Data Sync"
{
    procedure SyncAllData(): Boolean
    var
        setup: Record "Simple Data Exchange Setup";
        success: Boolean;
    begin
        setup := setup.GetSetup();

        if (setup."Source BC URL" = '') or (setup.Username = '') or (setup.Password = '') then begin
            Message('Please configure the data exchange setup first.');
            exit(false);
        end;

        setup."Last Sync DateTime" := CurrentDateTime;
        setup."Last Sync Status" := 'In Progress';
        setup.Modify();

        success := true;

        if setup."Sync Enabled" then
            if not SyncCustomers(setup) then
                success := false;

        if success then
            setup."Last Sync Status" := 'Success'
        else
            setup."Last Sync Status" := 'Failed';

        setup.Modify();
        exit(success);
    end;

    local procedure SyncCustomers(var pSetup: Record "Simple Data Exchange Setup"): Boolean
    var
        httpClient: HttpClient;
        requestMessage: HttpRequestMessage;
        responseMessage: HttpResponseMessage;
        requestHeaders: HttpHeaders;
        responseText: Text;
        apiUrl: Text;
        base64Convert: Codeunit "Base64 Convert";
        authValue: Text;
        jsonArray: JsonArray;
        jsonToken: JsonToken;
        jsonObject: JsonObject;
        customer: Record Customer;
        i: Integer;
        customerNo: Code[20];
        customerName: Text[100];
        recordsProcessed: Integer;
    begin
        // Build API URL
        apiUrl := pSetup."Source BC URL";
        if not apiUrl.EndsWith('/') then
            apiUrl += '/';
        apiUrl += StrSubstNo('api/v2.0/companies(%1)/customers', pSetup."Source Company ID");

        // Setup request
        requestMessage.SetRequestUri(apiUrl);
        requestMessage.Method('GET');
        requestMessage.GetHeaders(requestHeaders);
        requestHeaders.Add('Accept', 'application/json');

        // Add Basic Authentication
        authValue := base64Convert.ToBase64(pSetup.Username + ':' + pSetup.Password);
        requestHeaders.Add('Authorization', 'Basic ' + authValue);

        // Send request
        if not httpClient.Send(requestMessage, responseMessage) then begin
            Message('Failed to connect to source system');
            exit(false);
        end;

        if not responseMessage.IsSuccessStatusCode then begin
            Message('HTTP Error: %1', responseMessage.HttpStatusCode);
            exit(false);
        end;

        responseMessage.Content.ReadAs(responseText);

        // Parse JSON response
        if not jsonArray.ReadFrom(responseText) then begin
            // Try to get value array from response
            if jsonObject.ReadFrom(responseText) then
                if jsonObject.Get('value', jsonToken) then
                    jsonArray := jsonToken.AsArray()
                else begin
                    Message('Invalid response format');
                    exit(false);
                end
            else begin
                Message('Failed to parse response');
                exit(false);
            end;
        end;

        // Process customers
        recordsProcessed := 0;
        for i := 0 to jsonArray.Count - 1 do begin
            jsonArray.Get(i, jsonToken);
            jsonObject := jsonToken.AsObject();

            if GetJsonValue(jsonObject, 'number', customerNo) and GetJsonValue(jsonObject, 'displayName', customerName) then begin
                if customer.Get(customerNo) then begin
                    customer.Name := CopyStr(customerName, 1, MaxStrLen(customer.Name));
                    UpdateCustomerFromJson(customer, jsonObject);
                    if customer.Modify() then
                        recordsProcessed += 1;
                end else begin
                    customer.Init();
                    customer."No." := customerNo;
                    customer.Name := CopyStr(customerName, 1, MaxStrLen(customer.Name));
                    UpdateCustomerFromJson(customer, jsonObject);
                    if customer.Insert() then
                        recordsProcessed += 1;
                end;
            end;
        end;

        Message('Customers synchronized: %1 records processed', recordsProcessed);
        exit(true);
    end;

    local procedure GetJsonValue(pJsonObject: JsonObject; pPropertyName: Text; var pValue: Text): Boolean
    var
        jsonToken: JsonToken;
    begin
        if not pJsonObject.Get(pPropertyName, jsonToken) then
            exit(false);
        if jsonToken.IsValue then begin
            pValue := jsonToken.AsValue().AsText();
            exit(true);
        end;
        exit(false);
    end;

    local procedure GetJsonValue(pJsonObject: JsonObject; pPropertyName: Text; var pValue: Code[20]): Boolean
    var
        textValue: Text;
    begin
        if GetJsonValue(pJsonObject, pPropertyName, textValue) then begin
            pValue := CopyStr(textValue, 1, MaxStrLen(pValue));
            exit(true);
        end;
        exit(false);
    end;

    local procedure UpdateCustomerFromJson(var pCustomer: Record Customer; pJsonObject: JsonObject)
    var
        textValue: Text;
    begin
        if GetJsonValue(pJsonObject, 'addressLine1', textValue) then
            pCustomer.Address := CopyStr(textValue, 1, MaxStrLen(pCustomer.Address));
        if GetJsonValue(pJsonObject, 'city', textValue) then
            pCustomer.City := CopyStr(textValue, 1, MaxStrLen(pCustomer.City));
        if GetJsonValue(pJsonObject, 'phoneNumber', textValue) then
            pCustomer."Phone No." := CopyStr(textValue, 1, MaxStrLen(pCustomer."Phone No."));
        if GetJsonValue(pJsonObject, 'email', textValue) then
            pCustomer."E-Mail" := CopyStr(textValue, 1, MaxStrLen(pCustomer."E-Mail"));
    end;



    procedure TestConnection(): Boolean
    var
        setup: Record "Simple Data Exchange Setup";
        httpClient: HttpClient;
        requestMessage: HttpRequestMessage;
        responseMessage: HttpResponseMessage;
        requestHeaders: HttpHeaders;
        testUrl: Text;
        base64Convert: Codeunit "Base64 Convert";
        authValue: Text;
    begin
        setup := setup.GetSetup();

        if (setup."Source BC URL" = '') or (setup.Username = '') or (setup.Password = '') then begin
            Message('Please configure the setup first.');
            exit(false);
        end;

        testUrl := setup."Source BC URL";
        if not testUrl.EndsWith('/') then
            testUrl += '/';
        testUrl += 'api/v2.0/companies';

        requestMessage.SetRequestUri(testUrl);
        requestMessage.Method('GET');
        requestMessage.GetHeaders(requestHeaders);

        authValue := base64Convert.ToBase64(setup.Username + ':' + setup.Password);
        requestHeaders.Add('Authorization', 'Basic ' + authValue);

        if httpClient.Send(requestMessage, responseMessage) then begin
            if responseMessage.IsSuccessStatusCode then begin
                Message('Connection test successful!');
                exit(true);
            end else begin
                Message('Connection failed: HTTP %1', responseMessage.HttpStatusCode);
                exit(false);
            end;
        end else begin
            Message('Failed to connect to server');
            exit(false);
        end;
    end;
}
