codeunit 70200 "Customer API Integration"
{
    procedure FetchAndImportCustomers()
    var
        TempCustomerBuffer: Record "Customer Import Buffer" temporary;
        HttpClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        JsonResponse: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        ErrorText: Text;
    begin
        // Call external API to fetch customer data
        if not HttpClient.Get('https://api.example.com/customers', ResponseMessage) then begin
            LogError('Failed to connect to the API');
            Error('Failed to connect to the API');
        end;

        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(ErrorText);
            LogError(StrSubstNo('API returned error: %1 - %2', ResponseMessage.HttpStatusCode, ErrorText));
            Error('API returned error: %1', ResponseMessage.HttpStatusCode);
        end;

        // Parse JSON response
        ResponseMessage.Content.ReadAs(ResponseText);
        if not JsonResponse.ReadFrom(ResponseText) then begin
            LogError('Invalid JSON response');
            Error('Invalid JSON response');
        end;

        // Extract customer data from JSON
        if not JsonResponse.Get('customers', JsonToken) then begin
            LogError('JSON does not contain customers array');
            Error('JSON does not contain customers array');
        end;

        JsonArray := JsonToken.AsArray();
        foreach JsonToken in JsonArray do begin
            JsonObject := JsonToken.AsObject();
            PopulateCustomerBuffer(TempCustomerBuffer, JsonObject);
        end;

        // Display customer list and let user select
        if TempCustomerBuffer.IsEmpty() then begin
            LogError('No customers found in API response');
            Error('No customers found in API response');
        end;

        if Page.RunModal(Page::"Customer Import Selection", TempCustomerBuffer) = Action::LookupOK then begin
            // User selected a customer, create it in BC
            CreateCustomerFromBuffer(TempCustomerBuffer);
        end;
    end;

    local procedure PopulateCustomerBuffer(var TempCustomerBuffer: Record "Customer Import Buffer" temporary; JsonObject: JsonObject)
    var
        JsonToken: JsonToken;
        EntryNo: Integer;
    begin
        TempCustomerBuffer.Reset();
        if TempCustomerBuffer.FindLast() then
            EntryNo := TempCustomerBuffer."Entry No." + 1
        else
            EntryNo := 1;

        TempCustomerBuffer.Init();
        TempCustomerBuffer."Entry No." := EntryNo;

        if JsonObject.Get('id', JsonToken) then
            TempCustomerBuffer."External ID" := JsonToken.AsValue().AsText();

        if JsonObject.Get('name', JsonToken) then
            TempCustomerBuffer.Name := JsonToken.AsValue().AsText();

        if JsonObject.Get('email', JsonToken) then
            TempCustomerBuffer."E-Mail" := JsonToken.AsValue().AsText();

        if JsonObject.Get('phone', JsonToken) then
            TempCustomerBuffer."Phone No." := JsonToken.AsValue().AsText();

        if JsonObject.Get('address', JsonToken) then
            TempCustomerBuffer.Address := JsonToken.AsValue().AsText();

        if JsonObject.Get('city', JsonToken) then
            TempCustomerBuffer.City := JsonToken.AsValue().AsText();

        if JsonObject.Get('country', JsonToken) then
            TempCustomerBuffer."Country/Region Code" := JsonToken.AsValue().AsText();

        TempCustomerBuffer.Insert();
    end;

    local procedure CreateCustomerFromBuffer(var TempCustomerBuffer: Record "Customer Import Buffer" temporary): Boolean
    var
        Customer: Record Customer;
        CustomerNo: Code[20];
    begin
        if not ValidateCustomerData(TempCustomerBuffer) then
            exit(false);

        // Create new customer
        Customer.Init();
        CustomerNo := GetNextCustomerNo();
        Customer.Validate("No.", CustomerNo);
        Customer.Insert(true);

        // Set customer fields
        Customer.Validate(Name, TempCustomerBuffer.Name);
        Customer.Validate("E-Mail", TempCustomerBuffer."E-Mail");
        Customer.Validate("Phone No.", TempCustomerBuffer."Phone No.");
        Customer.Validate(Address, TempCustomerBuffer.Address);
        Customer.Validate(City, TempCustomerBuffer.City);
        Customer.Validate("Country/Region Code", TempCustomerBuffer."Country/Region Code");
        Customer.Validate("External ID", TempCustomerBuffer."External ID");

        if Customer.Modify(true) then begin
            Message('Customer %1 created successfully.', CustomerNo);
            exit(true);
        end else begin
            LogError(StrSubstNo('Failed to create customer from external ID %1', TempCustomerBuffer."External ID"));
            exit(false);
        end;
    end;

    local procedure ValidateCustomerData(var TempCustomerBuffer: Record "Customer Import Buffer" temporary): Boolean
    var
        Customer: Record Customer;
        CountryRegion: Record "Country/Region";
        ErrorMessage: Text;
    begin
        // Validate required fields
        if TempCustomerBuffer.Name = '' then begin
            ErrorMessage := 'Name is required';
            LogError(ErrorMessage);
            Error(ErrorMessage);
        end;

        // Check if customer with same external ID already exists
        if TempCustomerBuffer."External ID" <> '' then begin
            Customer.SetRange("External ID", TempCustomerBuffer."External ID");
            if not Customer.IsEmpty then begin
                ErrorMessage := StrSubstNo('Customer with External ID %1 already exists', TempCustomerBuffer."External ID");
                LogError(ErrorMessage);
                Error(ErrorMessage);
            end;
        end;

        // Validate country code if provided
        if TempCustomerBuffer."Country/Region Code" <> '' then begin
            if not CountryRegion.Get(TempCustomerBuffer."Country/Region Code") then begin
                ErrorMessage := StrSubstNo('Invalid Country/Region Code: %1', TempCustomerBuffer."Country/Region Code");
                LogError(ErrorMessage);
                Error(ErrorMessage);
            end;
        end;

        exit(true);
    end;

    local procedure GetNextCustomerNo(): Code[20]
    var
        Customer: Record Customer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        exit(NoSeriesMgt.GetNextNo(SalesSetup."Customer Nos.", WorkDate(), true));
    end;

    local procedure LogError(ErrorMessage: Text)
    var
        APIIntegrationLog: Record "API Integration Log";
    begin
        APIIntegrationLog.Init();
        APIIntegrationLog."Entry No." := 0;
        APIIntegrationLog."Source Type" := APIIntegrationLog."Source Type"::Customer;
        APIIntegrationLog."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(APIIntegrationLog."Error Message"));
        APIIntegrationLog."Date Time" := CurrentDateTime;
        APIIntegrationLog.Insert(true);
    end;
}