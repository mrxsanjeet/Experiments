/*
codeunit 80300 "TextFileImportExample"
{
    var
        TextFileName: Text[100];
        TextStream: InStream;
        TextReader: DotNet System.IO.StreamReader;
        CurrentLine: Text[100];
        DataArray: Array[3] of Text[50];

    procedure ReadAndImportTextFile()
    begin
        // Replace 'C:\Path\To\Your\SampleData.txt' with the actual path to your text file
        TextFileName := 'C:\Path\To\Your\SampleData.txt';

        // Open the text file
        TextStream.OPEN(TextFileName);


        // Initialize the TextReader
        TextReader := System.IO.StreamReader.StreamReader(TextStream);

        // Read lines from the text file
        WHILE NOT TextReader.EndOfStream DO BEGIN
            CurrentLine := TextReader.ReadLine();

            // Split the line into an array using a comma as the delimiter
            DataArray := STRSUBSTNO(CurrentLine, ',', 3);

            // Import data into different tables (customize based on your tables)
            ImportData(DataArray[1], DataArray[2], DataArray[3]);
        END;

        // Close the text file
        TextReader.Close();
        TextStream.CLOSE();
    end;

    procedure ImportData(FirstName: Text[50]; LastName: Text[50]; Age: Text[50])
    var
        CustomerRec: Record Customer;
        EmployeeRec: Record Employee;
    begin
        // Import data into the Customer table
        CustomerRec.RESET;
        CustomerRec.INIT;
        //CustomerRec.FirstName := FirstName;
        //CustomerRec.LastName := LastName;
        //CustomerRec.Age := STR2INT(Age);
        CustomerRec.INSERT(TRUE);

        // Import data into the Employee table
        EmployeeRec.RESET;
        EmployeeRec.INIT;
        //EmployeeRec.FirstName := FirstName;
        //EmployeeRec.LastName := LastName;
        //EmployeeRec.Age := STR2INT(Age);
        EmployeeRec.INSERT(TRUE);
    end;

    trigger OnRun()
    begin
        // Call the function to read and import data from the text file
        ReadAndImportTextFile();
    end;
}

*/
