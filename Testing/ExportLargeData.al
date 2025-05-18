codeunit 80100 "CSV Export In Batches"
{
    Subtype = Normal;

    procedure ExportItemLedgerEntriesToCSV()
    var
        ILE: Record "Item Ledger Entry"; // Record variable for Item Ledger Entry table
        TempILE: Record "Item Ledger Entry" temporary; // Temporary record to store batch data
        FileMgt: Codeunit "File Management"; // File management codeunit for file operations
        OutStr: OutStream; // OutStream for writing data to file
        FileName: Text; // Name of the output file
        CSVText: Text; // Text variable for CSV lines
        LineCount: Integer; // Counter for number of files/parts
        ChunkSize: Integer; // Number of records per batch
        FilePath: Text; // File path (not used in this code)
        RecCount: Integer; // Counter for records processed
    begin
        ChunkSize := 10000; // Set batch size for export
        LineCount := 0; // Initialize file/part counter
        RecCount := 0; // Initialize record counter
        FileName := 'ItemLedgerExport_' + Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hour24><Minute><Second>') + '.csv'; // Generate unique file name with timestamp

        // Create temp record with required filters (customize if needed)
        ILE.SetRange("Posting Date", DMY2Date(1, 1, 2023), DMY2Date(31, 12, 2023)); // Filter entries by posting date
        if ILE.FindSet() then begin // Find filtered records
            repeat
                TempILE := ILE; // Copy current record to temporary record
                TempILE.Insert(); // Insert into temporary table
                RecCount += 1; // Increment record counter

                if RecCount mod ChunkSize = 0 then begin // If batch size reached
                    WriteCSV(TempILE, FileName + '_Part' + Format(LineCount + 1), OutStr); // Write batch to CSV file
                    TempILE.DeleteAll(); // Clear temporary table for next batch
                    LineCount += 1; // Increment file/part counter
                end;
            until ILE.Next() = 0; // Move to next record
        end;

        // Final remaining records
        if TempILE.FindSet() then begin // If any records left in temp table
            WriteCSV(TempILE, FileName + '_Part' + Format(LineCount + 1), OutStr); // Write remaining records to CSV
        end;
    end;

    local procedure WriteCSV(TempILE: Record "Item Ledger Entry" temporary; FileName: Text; var OutStr: OutStream)
    var
        TempBlob: Codeunit "Temp Blob"; // Temp Blob for stream operations
        FileMgt: Codeunit "File Management"; // File management codeunit
        CSVText: Text; // Text variable for CSV line
    begin
        TempBlob.CreateOutStream(OutStr); // Create OutStream for writing
        // Header
        OutStr.WriteText('Entry No.,Item No.,Posting Date,Quantity'); // Write CSV header

        if TempILE.FindSet() then // Find records in temporary table
            repeat
                CSVText := Format(TempILE."Entry No.") + ',' + // Format Entry No.
                    TempILE."Item No." + ',' + // Add Item No.
                    Format(TempILE."Posting Date") + ',' + // Add Posting Date
                    Format(TempILE.Quantity); // Add Quantity
                OutStr.WriteText(CSVText); // Write CSV line
            until TempILE.Next() = 0; // Move to next record

        // Download file
        //FileMgt.DownloadFromStream(TempBlob, '', '', '', FileName); // Download the generated CSV file
    end;
}
