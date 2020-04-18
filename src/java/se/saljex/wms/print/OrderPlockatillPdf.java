/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms.print;

import com.itextpdf.barcodes.Barcode128;
import com.itextpdf.io.font.FontConstants;
import com.itextpdf.io.font.FontProgram;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.property.TextAlignment;
import com.itextpdf.layout.property.UnitValue;
import com.itextpdf.layout.property.VerticalAlignment;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import se.saljex.wms.Const;

/**
 *
 * @author ulf
 */
public class OrderPlockatillPdf {
    public static ByteArrayOutputStream getPdf(Connection con, String wmsOrdernr) throws SQLException, IOException {        
        PreparedStatement pso1 = con.prepareStatement("select * from wmsorder1 where wmsordernr=?");
        PreparedStatement pso2 = con.prepareStatement("select * from wmsorder2 where wmsordernr=? order by pos");
        pso1.setString(1, wmsOrdernr);
        pso2.setString(1, wmsOrdernr);
        ResultSet o1 = pso1.executeQuery();
        ResultSet o2 = pso2.executeQuery();
        if (!o1.next()) throw new SQLException("Kan inte hitta order " + wmsOrdernr);

        String formatOrdernr;
        int le = wmsOrdernr.length();
        if (le > 6) {
            formatOrdernr=wmsOrdernr.substring(0, le-3) + " " + wmsOrdernr.substring(le-3, le); 
        } else {
            formatOrdernr = wmsOrdernr;
        }
        
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfDocument pdfDoc = new PdfDocument(new PdfWriter(baos));
        PageSize pageSize = PageSize.A4;
        try (Document doc = new Document(pdfDoc, pageSize)) {
            Barcode128 code128 = new Barcode128(pdfDoc);
            code128.setSize(20);
            code128.setFont(null);
            code128.setCode(wmsOrdernr);
            code128.setCodeType(Barcode128.CODE128);
            Image code128Image = new Image(code128.createFormXObject(pdfDoc));
            
            
            Table hTable = new Table(1);
            hTable.setWidth(UnitValue.createPercentValue(100));
            hTable.addHeaderCell(new Cell()
                    .add(new Paragraph(wmsOrdernr + "          " + o1.getString("datum")))
                    .add(code128Image)
                    .setBorder(Border.NO_BORDER));
            
            Table table;
            
            hTable.addCell(new Cell()
                    .add(new Paragraph(formatOrdernr).setFontSize(60))
                    .setBorder(Border.NO_BORDER));
            
            table = new Table(new float[]{1, 1});
            hTable.addCell(table);
            table.setWidth(UnitValue.createPercentValue(100));
            table.addCell(new Cell()
                    .add(new Paragraph("Kund").setFontSize(8))
                    .add(new Paragraph(Const.toStr(o1.getString("namn"))))
                    .add(new Paragraph(Const.toStr(o1.getString("adr1"))))
                    .add(new Paragraph(Const.toStr(o1.getString("adr2"))))
                    .add(new Paragraph(Const.toStr(o1.getString("adr3"))))
                    .add(new Paragraph("Fraktbolag").setFontSize(8).setMarginTop(6))
                    .add(new Paragraph(Const.toStr(o1.getString("fraktbolag"))))
                    .add(new Paragraph("Märke").setFontSize(8).setMarginTop(6))
                    .add(new Paragraph(Const.toStr(o1.getString("marke"))))
                    .setBorder(Border.NO_BORDER));
            table.addCell(new Cell()
                    .add(new Paragraph("Leveransadress").setFontSize(8))
                    .add(new Paragraph(Const.toStr(o1.getString("levadr1"))))
                    .add(new Paragraph(Const.toStr(o1.getString("levadr2"))))
                    .add(new Paragraph(Const.toStr(o1.getString("levadr3"))))
                    .add(new Paragraph("Leveransdatum").setFontSize(8).setMarginTop(6))
                    .add(new Paragraph(Const.toStr(o1.getString("levdat"))))
                    .setBorder(Border.NO_BORDER));
         
            table = new Table(new float[]{13, 35, 10, 4});
            hTable.addCell(table);
            table.setWidth(UnitValue.createPercentValue(100));
            table.addHeaderCell(new Cell().add(new Paragraph("Artnr").setBold().setFontSize(8)).setBorder(Border.NO_BORDER));
            table.addHeaderCell(new Cell().add(new Paragraph("Benämning").setBold().setFontSize(8)).setBorder(Border.NO_BORDER));
            table.addHeaderCell(new Cell().add(new Paragraph("Antal").setBold().setFontSize(8)).setBorder(Border.NO_BORDER));
            table.addHeaderCell(new Cell().add(new Paragraph("Enh").setBold().setFontSize(8)).setBorder(Border.NO_BORDER));

            while(o2.next()) {
                if (o2.getString("artnr")==null || o2.getString("artnr").length()<1 ) {
                    table.addCell(new Cell(1,4).add( new Paragraph(Const.toStr(o2.getString("text")))).setBorder(Border.NO_BORDER));
                } else {
                    table.addCell(new Cell().add(new Paragraph(Const.toStr(o2.getString("artnr")))).setBorder(Border.NO_BORDER));
                    table.addCell(new Cell().add(new Paragraph(Const.toStr(o2.getString("namn")))).setBorder(Border.NO_BORDER));
                    table.addCell(new Cell().add(new Paragraph(Const.getFormatNumber0To2Dec(o2.getDouble("lev")))).setBorder(Border.NO_BORDER).setTextAlignment(TextAlignment.RIGHT));
                    table.addCell(new Cell().add(new Paragraph(Const.toStr(o2.getString("enh")))).setBorder(Border.NO_BORDER));
                }
            }
            doc.add(hTable);
            
            int numberOfPages = pdfDoc.getNumberOfPages();
            for (int i = 1; i <= numberOfPages; i++) {
                doc.showTextAligned(new Paragraph(String.format("%s/%s", i, numberOfPages)),
                    559, 806, i, TextAlignment.RIGHT, VerticalAlignment.TOP, 0);
            }            
            
            doc.close();
        }
        return baos;
    }
    
}
