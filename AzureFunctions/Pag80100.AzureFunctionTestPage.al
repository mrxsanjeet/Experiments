page 80102 "Azure Function Test Page"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Azure Function Test Page';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Azure Function Configuration';

                field(FunctionUrl; FunctionUrl)
                {
                    ApplicationArea = All;
                    Caption = 'Function URL';
                    ToolTip = 'Enter the URL of your Azure Function';
                }

                field(FunctionKey; FunctionKey)
                {
                    ApplicationArea = All;
                    Caption = 'Function Key';
                    ToolTip = 'Enter the function key for authentication';
                    ExtendedDatatype = Masked;
                }

                field(RequestBody; RequestBody)
                {
                    ApplicationArea = All;
                    Caption = 'Request Body (JSON)';
                    ToolTip = 'Enter JSON request body for POST requests';
                    MultiLine = true;
                }

                field(TestUrl; TestUrl)
                {
                    ApplicationArea = All;
                    Caption = 'Test URL for QR Code';
                    ToolTip = 'Enter a URL to generate QR code';
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
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                ApplicationArea = All;
                Caption = 'Test Connection';
                Image = TestDatabase;
                ToolTip = 'Test connection to Azure Function';

                trigger OnAction()
                var
                    AzureFunctionIntegration: Codeunit "AzureFunctionIntegration";
                begin
                    if FunctionUrl = '' then
                        Error('Please enter a Function URL');

                    if AzureFunctionIntegration.TestAzureFunctionConnection(FunctionUrl, FunctionKey) then
                        Message('Connection test successful!')
                    else
                        Message('Connection test failed!');
                end;
            }

            action(CallGET)
            {
                ApplicationArea = All;
                Caption = 'Call GET';
                Image = GetEntries;
                ToolTip = 'Call Azure Function with GET method';

                trigger OnAction()
                var
                    AzureFunctionIntegration: Codeunit "AzureFunctionIntegration";
                begin
                    if FunctionUrl = '' then
                        Error('Please enter a Function URL');

                    AzureFunctionIntegration.CallAzureFunctionWithAuth(FunctionUrl, FunctionKey);
                end;
            }

            action(CallPOST)
            {
                ApplicationArea = All;
                Caption = 'Call POST';
                Image = PostDocument;
                ToolTip = 'Call Azure Function with POST method';

                trigger OnAction()
                var
                    AzureFunctionIntegration: Codeunit "AzureFunctionIntegration";
                begin
                    if FunctionUrl = '' then
                        Error('Please enter a Function URL');

                    ResponseText := AzureFunctionIntegration.CallAzureFunctionPOST(FunctionUrl, FunctionKey, RequestBody);
                    CurrPage.Update();
                end;
            }

            action(GenerateQRCode)
            {
                ApplicationArea = All;
                Caption = 'Generate QR Code';
                Image = BarCode;
                ToolTip = 'Generate QR Code using Azure Function';

                trigger OnAction()
                var
                    AzureFunctionIntegration: Codeunit "AzureFunctionIntegration";
                begin
                    if TestUrl = '' then
                        Error('Please enter a URL for QR code generation');

                    if AzureFunctionIntegration.CallQRGeneratorFunction('TEST001', TestUrl) then
                        Message('QR Code generated successfully!')
                    else
                        Message('Failed to generate QR Code');
                end;
            }

            action(CallWithQuery)
            {
                ApplicationArea = All;
                Caption = 'Call with Query Parameters';
                Image = GetSourceDoc;
                ToolTip = 'Call Azure Function with query parameters';

                trigger OnAction()
                var
                    AzureFunctionIntegration: Codeunit "AzureFunctionIntegration";
                    QueryParams: Dictionary of [Text, Text];
                begin
                    if FunctionUrl = '' then
                        Error('Please enter a Function URL');

                    // Example query parameters
                    QueryParams.Add('name', 'Business Central');
                    QueryParams.Add('version', '25.0');
                    QueryParams.Add('environment', 'Docker');

                    ResponseText := AzureFunctionIntegration.CallAzureFunctionWithQuery(FunctionUrl, FunctionKey, QueryParams);
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        FunctionUrl: Text;
        FunctionKey: Text;
        RequestBody: Text;
        ResponseText: Text;
        TestUrl: Text;

    trigger OnOpenPage()
    begin
        // Set default values for testing
        FunctionUrl := 'https://yourfunctionapp.azurewebsites.net/api/YourFunction';
        FunctionKey := 'YOUR_FUNCTION_KEY_HERE';
        RequestBody := '{"message": "Hello from Business Central Docker!"}';
        TestUrl := 'https://www.microsoft.com';
    end;
}
