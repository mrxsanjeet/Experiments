// pageextension 50102 VendorListExt extends "Vendor List"
// {
//     actions
//     {
//         addfirst(Process)
//         {
//             action(NotifyPaidVendors)
//             {
//                 Caption = 'Send Payment Report';
//                 ApplicationArea = All;

//                 trigger OnAction()
//                 var
//                     PaymentNotifier: Codeunit "VendorPaymentNotifier";
//                 begin
//                     PaymentNotifier.NotifyPaidVendors();
//                 end;
//             }
//         }
//     }
// }
