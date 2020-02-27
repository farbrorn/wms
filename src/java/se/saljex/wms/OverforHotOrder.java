/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.sql.DataSource;

/**
 *
 * @author ulf
 */
public class OverforHotOrder implements Runnable{
    private Connection con;
    private ResultSet rs;
    public OverforHotOrder(Connection con) {
        super();
        this.con=con;
    }

    @Override
    public void run() {
            try {
                rs = con.createStatement().executeQuery("select ppgexportorder(wmsordernr,'00') from wmsorder1 where status='Sparad' and lastdatum is null and fraktbolag='HOT PICK'");
                while(rs.next()) {
                    System.out.println("HOT PICK order " + rs.getString(1));
                }
            } catch (SQLException e) {
                System.out.println("Fel vid anrop från Timer. SQL: " + e.getMessage());
            }
    }
    
    
}
