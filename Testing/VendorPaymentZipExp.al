codeunit 70100 "Vendor Payment ZIP Export"
{
    procedure ExportVendorPaymentsToZip(PostingDate: Date)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        TempBlobZip: Codeunit "Temp Blob";
        TempBlobReport: Codeunit "Temp Blob";
        DataCompression: Codeunit "Data Compression";
        ReportSelections: Record "Report Selections";
        OutStrZip: OutStream;
        InStrReport: InStream;
        FileMgt: Codeunit "File Management";
        ReportUsage: Enum "Report Selection Usage";
        ReportID: Integer;
    begin
        ReportUsage := Enum::"Report Selection Usage"::"V.Remittance";
        ReportSelections.SetRange(Usage, ReportUsage);
        if not ReportSelections.FindFirst() then
            Error('No report configured for Vendor Remittance - Posted Entries.');
        ReportID := ReportSelections."Report ID";

        DataCompression.CreateZipArchive();
        Clear(ProcessedVendors);

        SetVendorLedgerFilters(VendorLedgerEntry, PostingDate);
        if VendorLedgerEntry.FindSet() then
            repeat
                if Vendor.Get(VendorLedgerEntry."Vendor No.") then
                    if not ProcessedVendors.Contains(Vendor."No.") then begin
                        ProcessedVendors.Add(Vendor."No.");
                        GenerateVendorReport(Vendor, PostingDate, TempBlobReport, ReportID);
                        TempBlobReport.CreateInStream(InStrReport);
                        DataCompression.AddEntry(InStrReport, GetFileName(Vendor));
                        Clear(TempBlobReport);
                    end;
            until VendorLedgerEntry.Next() = 0;

        if ProcessedVendors.Count() = 0 then
            Error('No payments found for Posting Date %1.', PostingDate);

        TempBlobZip.CreateOutStream(OutStrZip);
        DataCompression.SaveZipArchive(OutStrZip);
        TempBlobZip.CreateInStream(InStrReport);
        FileMgt.BLOBExport(TempBlobZip, GetZipFileName(PostingDate), true);
    end;

    local procedure GenerateVendorReport(Vendor: Record Vendor; PostingDate: Date; var TempBlob: Codeunit "Temp Blob"; ReportID: Integer)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        OutStr: OutStream;
        RecRef: RecordRef;
    begin
        SetVendorLedgerFilters(VendorLedgerEntry, PostingDate);
        VendorLedgerEntry.SetRange("Vendor No.", Vendor."No.");
        if VendorLedgerEntry.FindSet() then begin
            TempBlob.CreateOutStream(OutStr);
            RecRef.GetTable(VendorLedgerEntry);
            Report.SaveAs(ReportID, '', ReportFormat::Pdf, OutStr, RecRef);
        end;
    end;

    local procedure SetVendorLedgerFilters(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date)
    begin
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange("Posting Date", PostingDate);
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.SetRange("Open", true);
    end;

    local procedure GetFileName(Vendor: Record Vendor): Text
    begin
        exit(StrSubstNo('%1 - %2.pdf', Vendor."No.", Vendor.Name));
    end;

    local procedure GetZipFileName(PostingDate: Date): Text
    begin
        exit(StrSubstNo('VendorPayments_%1.zip', Format(PostingDate, 0, '<Year4><Month,2><Day,2>')));
    end;

    var
        ProcessedVendors: List of [Code[20]];
}
