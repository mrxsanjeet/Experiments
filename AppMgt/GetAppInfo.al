// codeunit 50100 GetAppInfo
// {
//     //Subtype = WebService;

//     trigger OnRun()
//     begin
//         GetAppInformation();
//     end;

//     procedure GetAppInformation()
//     var
//         ClientId: Text[100] := 'YOUR_CLIENT_ID';
//         ClientSecret: Text[250] := 'YOUR_CLIENT_SECRET';
//         TenantId: Text[100] := 'YOUR_TENANT_ID';
//         Scope: Text[250] := 'https://graph.microsoft.com/.default';
//         AccessToken: Text[1000];
//         Response: Record "AppInfo";
//     begin
//         // Acquire access token using client credentials flow
//         AccessToken := MicrosoftGraph.GetAccessToken(ClientId, ClientSecret, TenantId, Scope);

//         // Call function to get installed apps and their dependencies
//         MicrosoftGraph.GetInstalledAppsAndDependencies(AccessToken, Response);
//     end;
// }
