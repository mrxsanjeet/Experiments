codeunit 60170 workingXML
{
    trigger OnRun()
    begin

    end;

    local procedure ImportXML()
    var
        TempBlob: Codeunit "Temp Blob";
        TargetXmlDoc: XmlDocument;
        XmlDec: XmlDeclaration;
        Instr: InStream;
        filename: Text;
    begin
        // Create the Xml Document
        TargetXmlDoc := XmlDocument.Create;
        xmlDec := xmlDeclaration.Create('1.0', 'UTF-8', '');
        TargetXmlDoc.SetDeclaration(xmlDec);
        // Create an Instream object & upload the XML file into it 
        TempBlob.CreateInStream(Instr);
        filename := 'data.xml';
        UploadIntoStream('Import XML', '', '', filename, Instr);
        // Read stream into new xml document 
        Xmldocument.ReadFrom(Instr, TargetXmlDoc);
    end;

    local procedure XMLDocumentCreation()
    var
        xmldoc: XmlDocument;
        xmlDec: XmlDeclaration;
        node1: XmlElement;
        node2: XmlElement;
    begin
        xmldoc := XmlDocument.Create();
        xmlDec := xmlDeclaration.Create('1.0', 'UTF-8', '');
        xmlDoc.SetDeclaration(xmlDec);
        node1 := XmlElement.Create('node1');
        xmldoc.Add(node1);
        node2 := XmlElement.Create('node2');
        node2.SetAttribute('ID', '3');
        node1.Add(node2);
    end;

    procedure CreateJsonOrder(OrderNo: Code[20])
    var
        JsonObjectHeader: JsonObject;
        JsonObjectLines: JsonObject;
        JsonOrderArray: JsonArray;
        JsonArrayLines: JsonArray;
        SalesHeader: Record "Sales Header";
        SalesLines: Record "Sales Line";
    begin
        //Retrieves the Sales Header
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        //Creates the JSON header details
        JsonObjectHeader.Add('sales_order_no', SalesHeader."No.");
        JsonObjectHeader.Add(' bill_to_customer_no', SalesHeader."Bill-to Customer No.");
        JsonObjectHeader.Add('bill_to_name', SalesHeader."Bill-to Name");
        JsonObjectHeader.Add('order_date', SalesHeader."Order Date");
        JsonOrderArray.Add(JsonObjectHeader);
        //Retrieves the Sales Lines
        SalesLines.SetRange("Document Type", SalesLines."Document Type"::Order);
        SalesLines.SetRange("Document No.", SalesHeader."No.");
        if SalesLines.FindSet then
            // JsonObject Init
            JsonObjectLines.Add('line_no', '');
        JsonObjectLines.Add('item_no', '');
        JsonObjectLines.Add('description', '');
        JsonObjectLines.Add('location_code', '');
        JsonObjectLines.Add('quantity', '');
        repeat
            JsonObjectLines.Replace('line_no', SalesLines."Line No.");
            JsonObjectLines.Replace('item_no', SalesLines."No.");
            JsonObjectLines.Replace('description', SalesLines.Description);
            JsonObjectLines.Replace('location_code', SalesLines."Location Code");
            JsonObjectLines.Replace('quantity', SalesLines.Quantity);
            JsonArrayLines.Add(JsonObjectLines);
        until SalesLines.Next() = 0;
        JsonOrderArray.Add(JsonArrayLines);
    end;

    local procedure IsolatedStorageTest()
    var
        keyValue: Text;
    begin
        IsolatedStorage.Set('mykey', 'myvalue', DataScope::Company);
        if IsolatedStorage.Contains('mykey', DataScope::Company) then begin
            IsolatedStorage.Get('mykey', DataScope::Company, keyValue);
            Message('Key value retrieved is %1', keyValue);
        end;
        IsolatedStorage.Delete('mykey', DataScope::Company);
    end;

    local procedure StoreLicense()
    var
        StorageKey: Text;
        LicenseText: Text;
        EncryptManagement: Codeunit "Cryptography Management";
    //License: Record License temporary;
    begin
        StorageKey := GetStorageKey();
        //LicenseText := License.WriteLicenseToJson();
        if EncryptManagement.IsEncryptionEnabled() and EncryptManagement.
       IsEncryptionPossible() then
           // LicenseText := EncryptManagement.Encrypt(LicenseText);
        if IsolatedStorage.Contains(StorageKey, DataScope::Module) then
            IsolatedStorage.Delete(StorageKey);
        IsolatedStorage.Set(StorageKey, LicenseText, DataScope::Module);
    end;

    local procedure GetStorageKey(): Text
    var
        //Returns a GUID
        StorageKeyTxt: Label 'dd03d28e-4acb-48d9-9520-c854495362b6', Locked = true;
    begin
        exit(StorageKeyTxt);
    end;

    local procedure ReadLicense()
    var
        StorageKey: Text;
        LicenseText: Text;
        EncryptManagement: Codeunit "Cryptography Management";
    // License: Record License temporary;
    begin
        StorageKey := GetStorageKey();
        if IsolatedStorage.Contains(StorageKey, DataScope::Module) then
            IsolatedStorage.Get(StorageKey, DataScope::Module, LicenseText);
        if EncryptManagement.IsEncryptionEnabled() and EncryptManagement.
       IsEncryptionPossible() then
            LicenseText := EncryptManagement.Decrypt(LicenseText);
        //License.ReadLicenseFromJson(LicenseText);
    end;


}