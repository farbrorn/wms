/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.awt.print.PrinterException;
import java.awt.print.PrinterJob;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.SQLException;

import javax.print.DocFlavor;
import javax.print.PrintException;
import javax.print.PrintService;
import javax.print.PrintServiceLookup;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.printing.PDFPageable;
import se.saljex.wms.print.OrderPdf;

/**
 *
 * @author ulf
 */
public class PrintUtil {
    public static PrintService getPrintService() {
        return PrintServiceLookup.lookupDefaultPrintService();
    }
    public static PrintService getPrintService(String skrivarnamn) {
        for (PrintService pps2 : PrintServiceLookup.lookupPrintServices(null, null)) {
            if (skrivarnamn.equalsIgnoreCase(pps2.getName())) return pps2;
        }
        return getPrintService();
    }
    public static void printPdf(ByteArrayOutputStream baos, String printerName, String jobName, int copies) throws PrinterException, IOException {
        Const.log("printPdf. Size:" + baos.size());
        PrintService ps = getPrintService(printerName);
        PrinterJob job = PrinterJob.getPrinterJob();
        Const.log("Printservice.name: " + ps.getName());

        try (PDDocument pdDocument = PDDocument.load(baos.toByteArray())){
            job.setPageable(new PDFPageable(pdDocument));
            job.setPrintService(ps);
            job.setJobName(jobName);
            job.setCopies(copies);
            job.print();
        }
    }
    
    public static void pr(Connection con, String wmsordernr) throws PrinterException, IOException, SQLException{
        for (PrintService pps2 : PrintServiceLookup.lookupPrintServices(null, null)) {
            System.out.println("-----");
            System.out.println(pps2.getName());
            for (DocFlavor f :  pps2.getSupportedDocFlavors()) {
                System.out.println(f.getMediaType() + ":" + f.getMimeType() + ":" + f.getRepresentationClassName());    
            }
        }

        printPdf(OrderPdf.getPdf(con, wmsordernr),"ORDER", "order", 1);
        
//        Doc doc=new SimpleDoc("Testutskrift", DocFlavor.STRING.TEXT_PLAIN, null);
    }
}
