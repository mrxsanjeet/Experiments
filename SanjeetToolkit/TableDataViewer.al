page 60004 "Sanjeet Table Data Viewer"
{
    PageType = List;
    Caption = 'Table Data Viewer - Fields and Values';
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            group("Table Information")
            {
                Caption = 'Table Information';
                Visible = ShowTableInfo;

                field(TableID; TableID)
                {
                    ApplicationArea = All;
                    Caption = 'Table ID';
                    Editable = false;
                    Style = Strong;
                    ToolTip = 'ID of the table being viewed';
                }

                field(TableName; TableName)
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    Editable = false;
                    Style = Strong;
                    ToolTip = 'Name of the table being viewed';
                }

                field(RecordCount; RecordCount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Records';
                    Editable = false;
                    Style = Attention;
                    ToolTip = 'Total number of records in the table';
                }

                field(CurrentRecordNo; CurrentRecordNo)
                {
                    ApplicationArea = All;
                    Caption = 'Current Record';
                    Editable = false;
                    Style = Favorable;
                    ToolTip = 'Current record number being displayed';
                }

                field(FieldCount; FieldCount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Fields';
                    Editable = false;
                    Style = StandardAccent;
                    ToolTip = 'Total number of fields in the table';
                }
            }

            repeater(FieldData)
            {
                Caption = 'Field Data';

                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    Caption = 'Field No.';
                    ToolTip = 'Field number in the table';
                    Style = Strong;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                    ToolTip = 'Name of the field';
                    Style = Favorable;
                }

                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    Caption = 'Field Value';
                    ToolTip = 'Current value of the field';
                    // StyleExpr = GetValueStyle(); // Removed due to client expression limitation
                }

                field(FieldType; GetFieldType())
                {
                    ApplicationArea = All;
                    Caption = 'Field Type';
                    Editable = false;
                    ToolTip = 'Data type of the field';
                    Style = StandardAccent;
                }

                field(FieldLength; GetFieldLength())
                {
                    ApplicationArea = All;
                    Caption = 'Length';
                    Editable = false;
                    ToolTip = 'Length of the field (for text fields)';
                }

                field(FieldClass; GetFieldClass())
                {
                    ApplicationArea = All;
                    Caption = 'Field Class';
                    Editable = false;
                    ToolTip = 'Class of the field (Normal, FlowField, FlowFilter)';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("RecordNavigation")
            {
                Caption = 'Record Navigation';

                action(FirstRecord)
                {
                    ApplicationArea = All;
                    Caption = 'First Record';
                    ToolTip = 'Go to the first record in the table';
                    Image = PreviousRecord;

                    trigger OnAction()
                    begin
                        NavigateToRecord('FIRST');
                    end;
                }

                action(PreviousRecord)
                {
                    ApplicationArea = All;
                    Caption = 'Previous Record';
                    ToolTip = 'Go to the previous record';
                    Image = PreviousRecord;

                    trigger OnAction()
                    begin
                        NavigateToRecord('PREVIOUS');
                    end;
                }

                action(NextRecord)
                {
                    ApplicationArea = All;
                    Caption = 'Next Record';
                    ToolTip = 'Go to the next record';
                    Image = NextRecord;

                    trigger OnAction()
                    begin
                        NavigateToRecord('NEXT');
                    end;
                }

                action(LastRecord)
                {
                    ApplicationArea = All;
                    Caption = 'Last Record';
                    ToolTip = 'Go to the last record in the table';
                    Image = NextRecord;

                    trigger OnAction()
                    begin
                        NavigateToRecord('LAST');
                    end;
                }
            }

            group("Analysis")
            {
                Caption = 'Data Analysis';

                action(RefreshData)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh Data';
                    ToolTip = 'Refresh the current record data';
                    Image = Refresh;

                    trigger OnAction()
                    begin
                        LoadCurrentRecordData();
                        CurrPage.Update();
                        Message('Data refreshed for record %1 of %2', CurrentRecordNo, RecordCount);
                    end;
                }

                action(ShowTableStructure)
                {
                    ApplicationArea = All;
                    Caption = 'Table Structure';
                    ToolTip = 'Show detailed table structure information';
                    Image = Info;

                    trigger OnAction()
                    begin
                        ShowTableStructureInfo();
                    end;
                }

                action(ExportFieldData)
                {
                    ApplicationArea = All;
                    Caption = 'Export Field Data';
                    ToolTip = 'Export current record field data';
                    Image = Export;

                    trigger OnAction()
                    begin
                        ExportCurrentRecordData();
                    end;
                }

                action(FindRecord)
                {
                    ApplicationArea = All;
                    Caption = 'Find Record';
                    ToolTip = 'Find a specific record by field value';
                    Image = Find;

                    trigger OnAction()
                    begin
                        FindSpecificRecord();
                    end;
                }
            }

            group("View Options")
            {
                Caption = 'View Options';

                action(ToggleTableInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Toggle Table Info';
                    ToolTip = 'Show/hide table information panel';
                    Image = View;

                    trigger OnAction()
                    begin
                        ShowTableInfo := not ShowTableInfo;
                        CurrPage.Update();
                    end;
                }

                action(ShowOnlyDataFields)
                {
                    ApplicationArea = All;
                    Caption = 'Data Fields Only';
                    ToolTip = 'Show only normal data fields (hide system fields)';
                    Image = Filter;

                    trigger OnAction()
                    begin
                        FilterToDataFieldsOnly();
                    end;
                }

                action(ShowAllFields)
                {
                    ApplicationArea = All;
                    Caption = 'Show All Fields';
                    ToolTip = 'Show all fields including system fields';
                    Image = ClearFilter;

                    trigger OnAction()
                    begin
                        LoadCurrentRecordData();
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    var
        CurrentRecordRef: RecordRef;
        CurrentFieldRef: FieldRef;
        TableID: Integer;
        TableName: Text[100];
        RecordCount: Integer;
        CurrentRecordNo: Integer;
        FieldCount: Integer;
        ShowTableInfo: Boolean;

    trigger OnOpenPage()
    begin
        ShowTableInfo := true;
        if TableID = 0 then
            Error('Table ID must be specified before opening this page.');

        InitializeTableViewer();
    end;

    procedure SetTableID(NewTableID: Integer)
    begin
        TableID := NewTableID;
    end;

    local procedure InitializeTableViewer()
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        // Get table name
        AllObjWithCaption.Reset();
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableID);
        if AllObjWithCaption.FindFirst() then
            TableName := AllObjWithCaption."Object Name"
        else
            TableName := 'Unknown Table';

        // Open the table
        CurrentRecordRef.Open(TableID);

        // Get record count
        RecordCount := CurrentRecordRef.Count();

        // Get field count
        FieldCount := CurrentRecordRef.FieldCount();

        // Go to first record
        if CurrentRecordRef.FindFirst() then begin
            CurrentRecordNo := 1;
            LoadCurrentRecordData();
        end else begin
            CurrentRecordNo := 0;
            Message('Table %1 (%2) contains no records.', TableName, TableID);
        end;
    end;

    local procedure LoadCurrentRecordData()
    var
        FieldIndex: Integer;
        FieldValue: Text;
    begin
        // Clear existing data
        Rec.Reset();
        Rec.DeleteAll();

        // Load all fields for current record
        for FieldIndex := 1 to CurrentRecordRef.FieldCount() do begin
            CurrentFieldRef := CurrentRecordRef.FieldIndex(FieldIndex);

            // Get field value as text
            FieldValue := GetFieldValueAsText();

            // Add to buffer
            Rec.Init();
            Rec.ID := CurrentFieldRef.Number;
            Rec.Name := CurrentFieldRef.Name;
            Rec.Value := CopyStr(FieldValue, 1, MaxStrLen(Rec.Value));
            Rec.Insert();
        end;

        // Go to first record in the buffer
        if Rec.FindFirst() then;
    end;

    local procedure GetFieldValueAsText(): Text
    var
        FieldValue: Text;
    begin
        case CurrentFieldRef.Type of
            CurrentFieldRef.Type::Text,
            CurrentFieldRef.Type::Code:
                FieldValue := CurrentFieldRef.Value;
            CurrentFieldRef.Type::Integer:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::Decimal:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::Boolean:
                if CurrentFieldRef.Value then
                    FieldValue := 'Yes'
                else
                    FieldValue := 'No';
            CurrentFieldRef.Type::Date:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::Time:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::DateTime:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::Option:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::BigInteger:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::GUID:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::RecordID:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::TableFilter:
                FieldValue := Format(CurrentFieldRef.Value);
            CurrentFieldRef.Type::Blob:
                FieldValue := '<BLOB Data>';
            CurrentFieldRef.Type::Media:
                FieldValue := '<Media Data>';
            CurrentFieldRef.Type::MediaSet:
                FieldValue := '<MediaSet Data>';
            else
                FieldValue := Format(CurrentFieldRef.Value);
        end;

        exit(FieldValue);
    end;

    local procedure GetFieldType(): Text[50]
    var
        TempFieldRef: FieldRef;
    begin
        TempFieldRef := CurrentRecordRef.Field(Rec.ID);
        exit(Format(TempFieldRef.Type));
    end;

    local procedure GetFieldLength(): Integer
    var
        TempFieldRef: FieldRef;
    begin
        TempFieldRef := CurrentRecordRef.Field(Rec.ID);
        exit(TempFieldRef.Length);
    end;

    local procedure GetFieldClass(): Text[20]
    var
        TempFieldRef: FieldRef;
    begin
        TempFieldRef := CurrentRecordRef.Field(Rec.ID);
        exit(Format(TempFieldRef.Class));
    end;

    local procedure GetValueStyle(): Text
    var
        TempFieldRef: FieldRef;
    begin
        TempFieldRef := CurrentRecordRef.Field(Rec.ID);

        case TempFieldRef.Class of
            TempFieldRef.Class::FlowField:
                exit('Attention');
            TempFieldRef.Class::FlowFilter:
                exit('StandardAccent');
            else
                if Rec.Value = '' then
                    exit('Subordinate')
                else
                    exit('Standard');
        end;
    end;

    local procedure NavigateToRecord(Direction: Text)
    var
        TempRecordRef: RecordRef;
        NewRecordNo: Integer;
    begin
        TempRecordRef.Open(TableID);

        case Direction of
            'FIRST':
                begin
                    if TempRecordRef.FindFirst() then begin
                        CurrentRecordRef := TempRecordRef;
                        CurrentRecordNo := 1;
                        LoadCurrentRecordData();
                        CurrPage.Update();
                        Message('Moved to first record');
                    end;
                end;
            'LAST':
                begin
                    if TempRecordRef.FindLast() then begin
                        CurrentRecordRef := TempRecordRef;
                        CurrentRecordNo := RecordCount;
                        LoadCurrentRecordData();
                        CurrPage.Update();
                        Message('Moved to last record');
                    end;
                end;
            'NEXT':
                begin
                    CurrentRecordRef.Copy(TempRecordRef);
                    if CurrentRecordRef.Next() <> 0 then begin
                        CurrentRecordNo += 1;
                        LoadCurrentRecordData();
                        CurrPage.Update();
                        Message('Moved to record %1 of %2', CurrentRecordNo, RecordCount);
                    end else
                        Message('Already at the last record');
                end;
            'PREVIOUS':
                begin
                    if CurrentRecordNo > 1 then begin
                        // Find previous record
                        TempRecordRef.FindFirst();
                        NewRecordNo := 1;
                        while (NewRecordNo < CurrentRecordNo - 1) and (TempRecordRef.Next() <> 0) do
                            NewRecordNo += 1;

                        CurrentRecordRef := TempRecordRef;
                        CurrentRecordNo := NewRecordNo;
                        LoadCurrentRecordData();
                        CurrPage.Update();
                        Message('Moved to record %1 of %2', CurrentRecordNo, RecordCount);
                    end else
                        Message('Already at the first record');
                end;
        end;
    end;

    local procedure ShowTableStructureInfo()
    var
        StructureMsg: Text;
        FieldIndex: Integer;
        TempFieldRef: FieldRef;
    begin
        StructureMsg := StrSubstNo('TABLE STRUCTURE INFORMATION\n\nTable ID: %1\nTable Name: %2\nTotal Records: %3\nTotal Fields: %4\n\nFIELD DETAILS:\n',
            TableID, TableName, RecordCount, FieldCount);

        for FieldIndex := 1 to CurrentRecordRef.FieldCount() do begin
            TempFieldRef := CurrentRecordRef.FieldIndex(FieldIndex);
            StructureMsg += StrSubstNo('• Field %1: %2 (%3)\n', TempFieldRef.Number, TempFieldRef.Name, TempFieldRef.Type);
        end;

        Message(StructureMsg);
    end;

    local procedure ExportCurrentRecordData()
    begin
        Message('EXPORT CURRENT RECORD DATA\n\nTable: %1 (%2)\nRecord: %3 of %4\n\nThis feature would export the current record''s field data to:\n• Excel file\n• CSV format\n• JSON format\n• XML format\n\nImplementation would use:\n• Excel Buffer for Excel export\n• File Management for CSV/JSON\n• XMLport for XML export',
            TableName, TableID, CurrentRecordNo, RecordCount);
    end;

    local procedure FindSpecificRecord()
    var
        SearchFieldNo: Integer;
        SearchValue: Text;
        TempRecordRef: RecordRef;
        TempFieldRef: FieldRef;
        RecordNo: Integer;
        Found: Boolean;
    begin
        if not (Evaluate(SearchFieldNo, InputBox('Enter Field Number to search:', 'Find Record', '1'))) then
            exit;

        SearchValue := InputBox('Enter value to search for:', 'Find Record', '');
        if SearchValue = '' then
            exit;

        TempRecordRef.Open(TableID);
        Found := false;
        RecordNo := 0;

        if TempRecordRef.FindSet() then
            repeat
                RecordNo += 1;
                TempFieldRef := TempRecordRef.Field(SearchFieldNo);
                if Format(TempFieldRef.Value).ToLower().Contains(SearchValue.ToLower()) then begin
                    CurrentRecordRef := TempRecordRef;
                    CurrentRecordNo := RecordNo;
                    LoadCurrentRecordData();
                    CurrPage.Update();
                    Found := true;
                    Message('Found record %1 of %2 with matching value in field %3', CurrentRecordNo, RecordCount, SearchFieldNo);
                end;
            until (TempRecordRef.Next() = 0) or Found;

        if not Found then
            Message('No record found with value "%1" in field %2', SearchValue, SearchFieldNo);
    end;

    local procedure FilterToDataFieldsOnly()
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        TempFieldRef: FieldRef;
    begin
        // Save current data
        TempNameValueBuffer.Copy(Rec, true);

        // Clear and reload only normal fields
        Rec.Reset();
        Rec.DeleteAll();

        TempNameValueBuffer.Reset();
        if TempNameValueBuffer.FindSet() then
            repeat
                TempFieldRef := CurrentRecordRef.Field(TempNameValueBuffer.ID);
                if TempFieldRef.Class = TempFieldRef.Class::Normal then begin
                    Rec := TempNameValueBuffer;
                    Rec.Insert();
                end;
            until TempNameValueBuffer.Next() = 0;

        if Rec.FindFirst() then;
        CurrPage.Update();
        Message('Filtered to show only normal data fields');
    end;

    local procedure InputBox(Prompt: Text; Title: Text; DefaultValue: Text): Text
    var
        UserInput: Text;
    begin
        // Simple input simulation - in real implementation you might use a dialog page
        UserInput := DefaultValue;
        // This is a simplified version - you could create a proper input dialog page
        exit(UserInput);
    end;
}
