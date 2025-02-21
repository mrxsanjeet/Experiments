codeunit 60166 RequestPOSTBasicAuthExample
{
    trigger OnRun()
    begin

    end;

    procedure HttpRequestPOSTWithBasicAuth(Url: Text[2048]; Username: Text[100]; Password: Text[100])
    var
        HttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        Base64Convert: Codeunit "Base64 Convert";
        Response: Text;
        JsonObject: JsonObject;
        JsonBuffer: Record "JSON Buffer" temporary;
        salesline: Record "Sales Line";

        ContentHeaders: HttpHeaders;
        HttpContent: HttpContent;
    begin
        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method('POST');
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', 'Basic ' + Base64Convert.ToBase64(Username + ':' + Password));

        HttpContent.WriteFrom('{"number": "BCG0001","displayName": "BCG", "type": "Inventory"}');
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        HttpContent.GetHeaders(ContentHeaders);
        RequestMessage.Content(HttpContent);

        if HttpClient.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(Response);
            if ResponseMessage.IsSuccessStatusCode then begin
                JsonBuffer.ReadFromText(Response);
                Page.Run(Page::"JSON Buffer BCG", JsonBuffer);
            end else
                Message('Request failed!: %1', Response);
        end;
    end;
}