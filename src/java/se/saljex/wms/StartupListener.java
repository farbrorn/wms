/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.annotation.Resource;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import javax.sql.DataSource;

/**
 *
 * @author ulf
 */
@WebListener
public class StartupListener implements ServletContextListener {
     private ScheduledExecutorService scheduler;
	@Resource(mappedName = "sxadm")
	private DataSource sxadm;

        Connection con;
        
    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        System.out.println("Startar timerservice");
        try {
            con = sxadm.getConnection();
            scheduler = Executors.newSingleThreadScheduledExecutor();
            scheduler.scheduleAtFixedRate(new OverforHotOrder(con), 0, 10, TimeUnit.SECONDS);
        } catch (SQLException e) {
            System.out.println("Fel vid skapande av SQL Connection: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {
        try {
            con.close();
        } catch (SQLException e) {
            System.out.println("Fel sql: " + e.getMessage());
        }
    }    
}
