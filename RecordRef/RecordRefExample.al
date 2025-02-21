codeunit 50013 "RecordRefExample"
{
    procedure PreventDataDeletionIfUsed(RecRef: RecordRef)
    var
        Field: Record Field;
        invposting: Record "Invoice Posting Buffer";
        RecRef2: RecordRef;
        DataUsedLbl: Label 'The value %1 exists in the field %2 of %3 table. Deletion is not allowed.';
    begin
        //Gets the record Field to filter the Type of Field table with the info. from the RecordRef parameter
        Field.Get(RecRef.Number, RecRef.KeyIndex(1).FieldIndex(1).Number);
        Field.SetRange(Type, Field.Type);
        //Filters RelationTable No with the RecordRef table Number
        Field.SetRange(RelationTableNo, RecRef.Number);
        //Only filter no Obsoleted tables
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
        //Loop for searching in every table
        if Field.FindSet(false) then begin
            repeat
                //Opens the table provided by Field table
                RecRef2.Open(Field.TableNo);
                //Filters the field with the value of the primary key of RecordRef
                RecRef2.Field(Field."No.").SetRange(RecRef.KeyIndex(1).FieldIndex(1).Value);
                //If values are found we can´t delete it
                if not RecRef2.IsEmpty then begin
                    Error(DataUsedLbl, RecRef.KeyIndex(1).FieldIndex(1).Value, Field."Field Caption", RecRef2.Caption);
                end;
                //Closes the table
                RecRef2.Close();
            until Field.Next() = 0;
        end;
    end;
}

tableextension 50000 "Pyment Method" extends "Payment Method"
{
    trigger OnBeforeDelete()
    var
        RecordRefExample: Codeunit RecordRefExample;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        RecordRefExample.PreventDataDeletionIfUsed(RecRef);
    end;
}