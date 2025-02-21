//  in Microsoft 365 business central cloud, you can check which vendor has been paid today and mail a pdf report to the person who has made the payment.

codeunit 70305 VendorPaymentPDFNotifier
{
    procedure SendPDFReportForVendorPayment()
    var
        vendorledgeentry: Record "Vendor Ledger Entry";
        vendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        ReportToRun: Report "Vendor - Payment Receipt";
        OutStream: OutStream;
        InStream: InStream;
    begin
        vendorledgeentry.SetRange("Posting Date", TODAY, TODAY);
        vendorledgeentry.SETRANGE("Document Type", vendorledgeentry."Document Type"::Payment);
        vendorledgeentry.SETRANGE("Open", FALSE);
        vendorledgeentry.SETRANGE("Vendor No.", vendor."No.");

        IF vendorledgeentry.FINDSET THEN
            REPEAT
                vendor.GET(vendorledgeentry."Vendor No.");
                TempBlob.CREATEOUTSTREAM(OutStream);
                ReportToRun.SETTABLEVIEW(vendorledgeentry);
                ReportToRun.SaveAs('', ReportFormat::Pdf, OutStream);

                TempBlob.CREATEINSTREAM(InStream);
                SendPDFReport(vendor, InStream);
            UNTIL vendorledgeentry.NEXT = 0;
    end;

    local procedure SendPDFReport(vendor: Record Vendor; InStream: InStream)
    var 
        EmailBodyText: Text;
        VendorEmailAddress:text;
        Email : Codeunit Email;
        EmailMessage: Codeunit "Email Message";
    begin
        VendorEmailAddress := vendor."E-Mail";
        EmailMessage.Create(VendorEmailAddress,'Vendor Payment Receipt', EmailBodyText);
        Email.Send(EmailMessage);
    end;

}








