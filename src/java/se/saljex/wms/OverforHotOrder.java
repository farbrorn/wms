/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.awt.print.PrinterException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import static se.saljex.wms.PrintUtil.printPdf;
import se.saljex.wms.print.OrderPdf;
import se.saljex.wms.print.OrderPlockatillPdf;

/**
 *
 * @author ulf
 */
public class OverforHotOrder implements Runnable{
    private ResultSet rs;

    @Override
    public void run() {
        
            Connection conSx=null;
            try {
                Context initContext = new InitialContext();
                conSx=((DataSource) initContext.lookup("sxadm")).getConnection();
                rs = conSx.createStatement().executeQuery("select ppgexportorder(wmsordernr,'00') from wmsorder1 where status='Sparad' and lastdatum is null and fraktbolag='HOT PICK'");
                int rowCn=0;
                
                while(rs.next()) {
                    rowCn++;
                    Const.log("Rad: " + rowCn + " HOT PICK order: " + rs.getString(1));
                    try { 
                        printPdf(OrderPlockatillPdf.getPdf(conSx, rs.getString(1)),"ORDER", "Order", 1); 
                    } catch(PrinterException e) { Const.log("Kan inte skriva ut"); e.printStackTrace(); }
                    
                }
            } catch (Exception e) {
                Const.log("Fel vid anrop från Timer overforHotOrder: " + e.getMessage());
                e.printStackTrace();
            }
            finally {
                try { conSx.close(); } catch (Exception e) {}
            }
    }
    
    
}
