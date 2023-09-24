codeunit 60101 BlobStorageManagement
{
    trigger OnRun()
    var
        ContainerClient: Codeunit "ABS Container Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        Containers: Record "ABS Container";
        BlobClient: Codeunit "ABS Blob Client";
        ContainerContent: Record "ABS Container Content";
        ContainerContentText: Text;
    begin
        Authorization := StorageServiceAuthorization.CreateSharedKey('MY_KEY');
        ContainerClient.Initialize('MY_STORAGE_ACCOUNT', Authorization);
        //Create container
        Response := ContainerClient.CreateContainer('mycontainer');
        //List containers
        Response := ContainerClient.ListContainers(Containers);
        if Response.IsSuccessful() then begin
            if Containers.FindSet() then
                repeat
                    message('Container Name: %1', Containers.Name);
                until Containers.Next() = 0;
        end
        else
            Message('Error: %1', Response.GetError());

        //Init Blob Client
        BlobClient.Initialize('MY_STORAGE_ACCOUNT', 'mycontainer', Authorization);
        //Create a blob (text content)
        Response := BlobClient.PutBlobBlockBlobText('MyBlob', 'This is the content of my blob');
        if not Response.IsSuccessful() then
            Message('Blob creation error: %1', Response.GetError());

        //List blobs
        Response := BlobClient.ListBlobs(ContainerContent);
        if Response.IsSuccessful() then begin
            if ContainerContent.FindSet() then
                repeat
                    Message('ContainerContent Name: %1', ContainerContent.Name);
                    BlobClient.GetBlobAsText(ContainerContent.Name, ContainerContentText);
                    Message('%1 content: %2', ContainerContent.Name, ContainerContentText);

                //BlobClient.GetBlobAsStream()
                //BlobClient.GetBlobAsFile()
                until ContainerContent.Next() = 0;
        end;
    end;


}