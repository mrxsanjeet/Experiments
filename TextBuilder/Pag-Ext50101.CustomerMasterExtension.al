// pageextension 50188 CustomerMasterExtension extends "Customer List"
// {
//     actions
//     {
//         addlast(General)
//         {
//             action(DataExport)
//             {
//                 Caption='Data Export to Text';
//                 ApplicationArea=All;
//                 PromotedCategory=Process;
//                 Promoted=true;
//                 Image=ExportDatabase;
//                 trigger OnAction()
//                 var
//                 CustomerMaster :Record Customer;
//                 Tempblob:Codeunit "Temp Blob";
//                 TextFileBuilder :TextBuilder;
//                 FileName:Text;
//                 InStreamData:InStream;
//                 OutStreamData:OutStream;
//                 begin 
//                     FileName:='CustomerData.Txt';
//                     TextFileBuilder.AppendLine('Customer No'+','+'Customer Name'+','+'Balance');
//                     If CustomerMaster.FindSet() then repeat
//                         CustomerMaster.SetAutoCalcFields(CustomerMaster.Balance);
//                         TextFileBuilder.AppendLine(CustomerMaster."No."+','+CustomerMaster.Name+','+Format(CustomerMaster.Balance));
//                     until CustomerMaster.Next()=0;
//                     Tempblob.CreateOutStream(OutStreamData);
//                     OutStreamData.WriteText(TextFileBuilder.ToText());
//                     Tempblob.CreateInStream(InStreamData);
//                     DownloadFromStream(InStreamData,'','','',FileName);
//                 end;
//             }
//         }
//     }
// }