/// This codeunit is responsible for exporting vendor receipts within a specified date range into a ZIP file.
codeunit 60100 "Vendor Receipt Export"
{
    Subtype = Normal;

    /// Exports vendor receipts within the specified date range into a ZIP file.
    /// @param StartDate The start date of the range.
    /// @param EndDate The end date of the range.
    /// @param VendorReceiptReportID The ID of the vendor receipt report to generate.
    /// @return A Codeunit "Temp Blob" containing the ZIP file.
    procedure ExportVendorReceipts(StartDate: Date; EndDate: Date; VendorReceiptReportID: Integer): Codeunit "Temp Blob"
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry"; // Record to hold vendor ledger entries.
        TempBlob: Codeunit "Temp Blob"; // Codeunit to handle temporary blob storage.
        DataCompression: Codeunit "Data Compression"; // Codeunit to handle data compression.
        VendorNo: Code[20]; // Variable to store vendor number.
        VendorReportStream: InStream; // Stream to hold the vendor report.
        OutStream: OutStream; // Stream for output operations.
        ZipStream: OutStream; // Stream for ZIP file content.
        VendorReportName: Text; // Variable to store the name of the vendor report.
    begin
        // Initialize TempBlob for ZIP content
        TempBlob.CreateOutStream(ZipStream);

        // Start creating the ZIP file
        DataCompression.OpenZipArchive(VendorReportStream, true);

        // Filter Vendor Ledger Entries
        VendorLedgerEntry.Reset();
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
        VendorLedgerEntry.SetRange("Posting Date", StartDate, EndDate);

        // Loop through the filtered vendor ledger entries
        if VendorLedgerEntry.FindSet() then begin
            repeat
                VendorNo := VendorLedgerEntry."Vendor No."; // Get the vendor number.
                VendorReportName := 'Vendor_' + VendorNo + '_Receipt.pdf'; // Create the vendor report name.

                // Generate the Vendor Receipt Report as a PDF stream
                VendorReportStream := GenerateVendorReceiptReport(VendorLedgerEntry, VendorReceiptReportID);

                // Add the PDF stream to the ZIP archive
                DataCompression.AddEntry(VendorReportStream, VendorReportName);
            until VendorLedgerEntry.Next() = 0; // Continue until no more entries.
        end;

        // Finalize the ZIP archive
        DataCompression.CloseZipArchive();

        // Return the Blob containing the ZIP file
        TempBlob.CreateInStream(VendorReportStream);
        exit(TempBlob);
    end;

    /// Generates the vendor receipt report as a PDF stream.
    /// @param VendorLedgerEntry The vendor ledger entry record.
    /// @param ReportID The ID of the report to generate.
    /// @return An InStream containing the generated report.
    local procedure GenerateVendorReceiptReport(VendorLedgerEntry: Record "Vendor Ledger Entry"; ReportID: Integer): InStream
    var
        TempBlob: Codeunit "Temp Blob"; // Codeunit to handle temporary blob storage.
        OutStream: OutStream; // Stream for output operations.
        VendorReportStream: InStream; // Stream to hold the vendor report.
    begin
        TempBlob.CreateOutStream(OutStream); // Create an output stream for the temporary blob.

        // Run the report and output it to the stream
        Report.Run(ReportID, false, false, VendorLedgerEntry);
        TempBlob.CreateInStream(VendorReportStream); // Create an input stream for the temporary blob.
        exit(VendorReportStream); // Return the input stream containing the report.
    end;
}
