/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author ulf
 */
@WebServlet(name = "ActionServlet", urlPatterns = {"/ac"})
public class ActionServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            Connection con=Const.getConnection(request);
            PreparedStatement ps;
            Statement st;
            ResultSet rs;
            String ac=request.getParameter("ac");
            JsonBuilder jb = new JsonBuilder();
            if ("doesuserexist".equals(ac)) {
                try {
                    if (Const.doesUserExists(con,request.getParameter("anvandare"))) jb.addResponseTrue();
                    else jb.addResponseFalse();
                    out.print(jb.getJsonString());
                } catch (SQLException e) { out.print("error - SQLException");  }

            } else if ("isorderlocked".equals(ac)) {
                try {
                    Integer ordernr= Integer.parseInt(request.getParameter("ordernr"));
                    if (Const.isOrderLocked(con,ordernr)) { 
                        jb.addResponseTrue();
                    }
                    else jb.addResponseFalse();
                    out.print(jb.getJsonString());
                } 
                catch (SQLException e) {
                    jb.addResponseError("SQLException: " + e.toString());
                    out.print(jb.getJsonString());
                }
                catch(NumberFormatException e) {
                    jb.addResponseError("Ogiltigt format på ordernr.");
                    out.print(jb.getJsonString());
                }

            } else if ("test".equals(ac)) {
                jb.addResponseOK();
                jb.addMessage("Hej på dig!");
                jb.addField("test", "Testvärde");
                out.print(jb.getJsonString());

            } else if ("markorderwms".equals(ac)) {
                try {
                    con.setAutoCommit(false);
                    String wmsOrdernr= request.getParameter("ordernr");
                    String anvandare=request.getParameter("anvandare");
                    if (!Const.doesUserExists(con, anvandare)) throw new ErrorException("Användare är ogiltigt.");

                    ps = con.prepareStatement("select * from " + Const.getOrder1Union("ordernr, lastdatum, lastav, status") + "o1 where wmsordernr=?");
                    ps.setString(1, wmsOrdernr);
                    rs = ps.executeQuery();
                    if (!rs.next()) throw new ErrorException("Order " + wmsOrdernr + " finns inte.");
                    if (rs.getDate("lastdatum")!=null) throw new ErrorException("Ordern är låst " + rs.getString("lastdatum") + " av " + rs.getString("lastav") + ". Lås upp innan överföring."); 
                    if (!"Sparad".equals(rs.getString("status"))) throw new ErrorException("Orderstatus är " + rs.getString("status") + ". Endast sparade order kan hanteras."); 
                    int ordernr=rs.getInt("ordernr");
                    String schemaPrefix = rs.getString("dbschema") + ".";

                    ps = con.prepareStatement("update " + schemaPrefix + "order1 set status='Utskr' where ordernr=?");
                    ps.setInt(1, ordernr);
                    if (ps.executeUpdate()==0) throw new ErrorException("Något okänt gick fel vid SQL update order1 (rowcount=0)");

                    ps = con.prepareStatement("insert into " + schemaPrefix + "orderhand (ordernr, datum, tid, anvandare, handelse ) values (?,current_date,current_time,?,?)");
                    ps.setInt(1, ordernr);
                    ps.setString(2, anvandare);
                    ps.setString(3, "Utskriven");
                    if (ps.executeUpdate()==0) throw new ErrorException("Något okänt gick fel vid SQL insert orderhand (rowcount=0)");

                    ps = con.prepareStatement("select " + schemaPrefix + "ppgexportorder(?)");
                    ps.setInt(1, ordernr);
                    ps.executeQuery();
                   
//                    con.createStatement().executeUpdate("");

                    con.commit();
                    jb.addResponseOK();
                }
                catch (SQLException e) {
                    jb.addResponseError("SQLException: " + e.toString());
                    try { con.rollback(); } catch (SQLException ee) {}
                    System.out.print(e.toString());
                }
                catch(NumberFormatException e) {
                    jb.addResponseError("Ogiltigt format på ordernr.");
                    try { con.rollback(); } catch (SQLException ee) {}
                }
                catch(ErrorException e) {
                    jb.addResponseError(e.getMessage());
                    try { con.rollback(); } catch (SQLException ee) {}
                }
                finally {
                    out.print(jb.getJsonString());
                }
 
            } else {
                jb.addResponseError("Ogiltigt kommando");
                out.print(jb.getJsonString());
            }
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
