/*
codeunit 80100 "AzureFunctionIntegration"
{
    var
        HttpClient: DotNet HttpClient;
        Response: DotNet System.Net.Http.HttpResponseMessage;
        Content: DotNet System.Net.Http.HttpContent;
        Stream: DotNet System.IO.Stream;
        StreamReader: DotNet System.IO.StreamReader;
        AzureFunctionUrl: Text[250];

    procedure CallAzureFunction();
    begin
        // Replace 'YourAzureFunctionUrl' with the actual URL of your Azure function
        AzureFunctionUrl := 'https://yourfunctionapp.azurewebsites.net/api/YourFunction';

        // Initialize the HttpClient
        HttpClient := HttpClient.HttpClient;

        // Prepare the request
        HttpClient.BaseAddress := Uri.Uri(AzureFunctionUrl);
        HttpClient.DefaultRequestHeaders.Clear();
        HttpClient.DefaultRequestHeaders.Accept.Add(System.Net.Http.Headers.MediaTypeWithQualityHeaderValue.MediaTypeWithQualityHeaderValue('application/json'));

        // Make an HTTP GET request (you can change it to POST or other methods as needed)
        Response := HttpClient.GetAsync(HttpClient.BaseAddress).Result;

        // Check if the request was successful (status code 200)
        if Response.IsSuccessStatusCode then
        begin
            // Get the response content
            Content := Response.Content;

            // Read the response content as a stream
            Stream := Content.ReadAsStreamAsync().Result;

            // Read the stream using a StreamReader
            StreamReader := System.IO.StreamReader.StreamReader(Stream);

            // Read the content as text
            Message('Azure Function Response: %1', StreamReader.ReadToEnd());
        end
        else
        begin
            // Handle the error (e.g., log or throw an exception)
            Error('Error calling Azure function. Status code: %1', Response.StatusCode);
        end;
    end;

    trigger OnRun()
    begin
        // Call the Azure function
        CallAzureFunction();
    end;
}

*/
