/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms.print;

import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.property.TextAlignment;
import com.itextpdf.layout.property.UnitValue;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.wms.Const;

/**
 *
 * @author ulf
 */
public class OrderPdf {
    public static ByteArrayOutputStream getPdf(Connection con, String wmsOrdernr) throws SQLException {
        PreparedStatement pso1 = con.prepareStatement("select * from wmsorder1 where wmsordernr=?");
        PreparedStatement pso2 = con.prepareStatement("select * from wmsorder2 where wmsordernr=? order by pos");
        pso1.setString(1, wmsOrdernr);
        pso2.setString(1, wmsOrdernr);
        ResultSet o1 = pso1.executeQuery();
        ResultSet o2 = pso2.executeQuery();
        if (!o1.next()) throw new SQLException("Kan inte hitta order " + wmsOrdernr);
        
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfDocument pdfDoc = new PdfDocument(new PdfWriter(baos));
        PageSize pageSize = PageSize.A4;
        try (Document doc = new Document(pdfDoc, pageSize)) {
            Table hTable = new Table(1);
            hTable.setWidth(UnitValue.createPercentValue(100));
            hTable.addHeaderCell(new Cell().add(new Paragraph("Ordernr: " + wmsOrdernr)));
            
            Table table;
            table = new Table(new float[]{1, 1});
            hTable.addCell(table);
            table.setWidth(UnitValue.createPercentValue(100));
            table.addCell(new Cell().add(new Paragraph("Kund").add(o1.getString("namn"))));
         
            table = new Table(new float[]{13, 35, 10, 4});
            hTable.addCell(table);
            table.setWidth(UnitValue.createPercentValue(100));            
            table.addHeaderCell(new Cell().add(new Paragraph("Artnr").setBold()));
            table.addHeaderCell(new Cell().add(new Paragraph("Benämning")));
            table.addHeaderCell(new Cell().add(new Paragraph("Antal")));
            table.addHeaderCell(new Cell().add(new Paragraph("Enh")));

            while(o2.next()) {
                if (o2.getString("artnr")==null || o2.getString("artnr").length()<1 ) {
                    table.addCell(new Cell(1,4).add( new Paragraph(o2.getString("text"))));
                } else {
                    table.addCell(new Cell().add(new Paragraph(o2.getString("artnr"))).setBorderRight(Border.NO_BORDER));
                    table.addCell(new Cell().add(new Paragraph(o2.getString("namn"))).setBorderRight(Border.NO_BORDER).setBorderLeft(Border.NO_BORDER));
                    table.addCell(new Cell().add(new Paragraph(Const.getFormatNumber0To2Dec(o2.getDouble("lev")))).setBorderLeft(Border.NO_BORDER).setBorderRight(Border.NO_BORDER).setTextAlignment(TextAlignment.RIGHT));
                    table.addCell(new Cell().add(new Paragraph(o2.getString("enh"))).setBorderRight(Border.NO_BORDER).setBorderLeft(Border.NO_BORDER));
                }
            }
            doc.add(hTable);
            doc.close();
        }
        return baos;
    }
}
