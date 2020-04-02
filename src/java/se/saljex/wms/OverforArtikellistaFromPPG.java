/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.sql.Array;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

/**
 *
 * @author ulf
 */
public class OverforArtikellistaFromPPG implements Runnable {
        @Override
    public void run() {
            Connection conPpg=null;
            Connection conSx=null;
                    
            
            Const.log(" se.saljex.wms.OverforArtikellistaFromPPG.run()");
        try {
            Context initContext = new InitialContext();
//            Context envContext = (Context) initContext.lookup("java:comp/env");
//            DataSource ppgdb = (DataSource) envContext.lookup("ppgdb");
            DataSource ppgdb = (DataSource) initContext.lookup("ppgdb");
            conPpg=ppgdb.getConnection();
            DataSource sxadm = (DataSource) initContext.lookup("sxadm");
            conSx=sxadm.getConnection();
            ResultSet rs = conPpg.prepareStatement("select materialname from materialbase").executeQuery();
            PreparedStatement ps = conSx.prepareStatement("select ppgsaveppgartikellista(?)");
            ArrayList<String> al = new ArrayList<>(12000);
            while (rs.next()) { al.add(rs.getString(1)); }
            java.sql.Array ar  = conSx.createArrayOf("varchar", al.toArray());
            ps.setArray(1, ar);
            ps.executeQuery();
            
            rs = conPpg.prepareStatement("SELECT mb.MaterialName, sum(lc.QuantityCurrent) as ilager\n" +
                "from Materialbase mb join LocContent lc on lc.MaterialId = mb.MaterialId \n" +
                "where mb.MaterialName in (select MaterialName from History where QuantityConfirmed <> 0)\n" +
                "group by mb.MaterialName\n" +
                "having sum(lc.QuantityCurrent) <> 0").executeQuery();
                // returnera endast artiklar med 0-saldo som någon gång har varit hanteerade av ppg
                ps = conSx.prepareStatement("select ppgsaveppglagerlista(?,?)");
                al = new ArrayList<>(12000);
                ArrayList<Double> alAntal = new ArrayList<>(12000);
                while (rs.next()) { 
                    al.add(rs.getString(1));
                    alAntal.add(rs.getDouble(2));
                }
                ar  = conSx.createArrayOf("varchar", al.toArray());
                java.sql.Array arAntal  = conSx.createArrayOf("numeric", alAntal.toArray());
                ps.setArray(1, ar);
                ps.setArray(2, arAntal);
                ps.executeQuery();
                
                
        } catch(Exception e) {
            Const.log("Kan inte föra vöver artikellista från ppg. " + e.getMessage());
            e.printStackTrace();
        }
        finally {
            try { conSx.close(); } catch (Exception e) {}
            try { conPpg.close(); } catch (Exception e) {}
        }
            Const.log(" se.saljex.wms.OverforArtikellistaFromPPG.run() klar");
    }
    
}
