/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.awt.print.PrinterException;
import java.awt.print.PrinterJob;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.Enumeration;
import javax.print.Doc;
import javax.print.DocPrintJob;
import javax.print.PrintException;
import javax.print.PrintService;
import javax.print.PrintServiceLookup;
import javax.print.SimpleDoc;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import static se.saljex.wms.PrintUtil.printPdf;
import se.saljex.wms.print.OrderPdf;
import se.saljex.wms.print.OrderPlockatillPdf;

/**
 *
 * @author ulf
 */
 @MultipartConfig
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
        try (PrintWriter out = response.getWriter()) {
            String wmsOrdernr= request.getParameter("wmsordernr");
            String anvandare=request.getParameter("anvandare");
            Connection con=Const.getConnection(request);
            PreparedStatement ps;
            Statement st;
            ResultSet rs;
            String ac=request.getParameter("ac");
            JsonBuilder jb = new JsonBuilder();
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            if ("test".equals(ac)) {
                response.setContentType("text/html;charset=UTF-8");      
                try {
                    out.print("start");
                    PrintUtil.pr(Const.getConnection(request), request.getParameter("wmsordernr"));
                    out.print("slut");
                } catch (PrinterException e) { out.print("fel" + e.getMessage());e.printStackTrace(); } 
                catch (Exception e) { out.print(e.getMessage()); e.printStackTrace(); }
            } else if ("avbrytwmsorder".equals(ac)) {
                response.setContentType("application/json;charset=UTF-8");
                try {
                    if (!Const.doesUserExists(con, anvandare)) throw new ErrorException("Användare är ogiltigt.");

                    ps = con.prepareStatement("select wmsavbrytorder(?,?)");
                    ps.setString(1, wmsOrdernr);
                    ps.setString(2, anvandare);
                    ps.executeQuery();
                   
                    jb.addResponseOK();
                }
                catch (SQLException e) {
                    jb.addResponseError("SQLException: " + e.toString());
                    try { con.rollback(); } catch (SQLException ee) {}
                    Const.log(e.toString());
                }
                catch(ErrorException e) {
                    jb.addResponseError(e.getMessage());
                    try { con.rollback(); } catch (SQLException ee) {}
                }
                finally {
                    out.print(jb.getJsonString());
                }
        
            } else if ("addorderrad".equals(ac)) {
                response.setContentType("application/json;charset=UTF-8");
                try {
                    if (!Const.doesUserExists(con, anvandare)) throw new ErrorException("Användare är ogiltigt.");
                    Double antal = null;
                    try { antal=Double.parseDouble(request.getParameter("antal")); } catch (Exception  e) {}
                    if (antal==null) antal = 1.0;
                                                        
                    ps = con.prepareStatement("insert into wmsorderplock (wmsordernr, pos, artnr ,bekraftat) values (?,wmsorderaddrow(?,?,?,?::REAL),?,?::real) on conflict do nothing ");
                    ps.setString(1, wmsOrdernr);
                    ps.setString(2, anvandare);
                    ps.setString(3, wmsOrdernr);
                    ps.setString(4, request.getParameter("artnr"));
                    ps.setDouble(5, antal);
                    ps.setString(6, request.getParameter("artnr"));
                    ps.setDouble(7, antal);
                    ps.executeUpdate();
                   
                    jb.addResponseOK();
                }
                catch (SQLException e) {
                    jb.addResponseError("SQLException: " + e.toString());
                    try { con.rollback(); } catch (SQLException ee) {}
                    Const.log(e.toString());
                }
                catch(ErrorException e) {
                    jb.addResponseError(e.getMessage());
                    try { con.rollback(); } catch (SQLException ee) {}
                }
                finally {
                    out.print(jb.getJsonString());
                }
        
            } else if ("saveredigeradorder".equals(ac)) {
                response.setContentType("application/json;charset=UTF-8");
                try {
                    con.setAutoCommit(false);
                    ps = con.prepareStatement("select * from wmsorder1 o1 where wmsordernr=? and orgordernr=wmsordernr2int(?)");
                    ps.setString(1, wmsOrdernr);
                    ps.setString(2, wmsOrdernr);
                    rs = ps.executeQuery();
                    if (!rs.next()) throw new ErrorException("Order " + wmsOrdernr + " finns inte.");
                    if (rs.getDate("lastdatum")!=null) throw new ErrorException("Ordern är låst " + rs.getString("lastdatum") + " av " + rs.getString("lastav") + ". Lås upp innan du kan spara."); 
                    if ("Sparad".equals(rs.getString("status"))) throw new ErrorException("Orderstatus är " + rs.getString("status") + ". Skriv ut ordern innan redigering."); 

                    ps = con.prepareStatement("select pos, artnr from wmsorder2 o2 where o2.wmsordernr=? and o2.orgordernr=wmsordernr2int(?)");
                    ps.setString(1, wmsOrdernr);
                    ps.setString(2, wmsOrdernr);
                    rs = ps.executeQuery();
                    
                    PreparedStatement psInsert = con.prepareStatement("insert into ppgorderpick (status, masterordername, hostidentification, materialname, quantityconfirmed) values (2,?,?,?,?)");
                    String artnr;
                    Double bekraftat;
                    final String nbsp = Character.toString((char)160);// non breaking space
                    String tal="";
                    while (rs.next()) {
                        int pos;
                        if (rs.getString("artnr") != null && rs.getString("artnr").length()>0) {
                            pos = rs.getInt("pos");
                            Integer arrPos=null;                            
                            for (int i=0; i<100000; i++) {
                                try {
                                    if (Integer.parseInt(request.getParameter("pos" + i)) == pos) {
                                        arrPos = i;
                                        break;
                                    }
                                } catch (Exception e) { 
                                    if (i>0) break; /*Prova igen, för pos 0 är nästan aldrig nyttjad */ 
                                }
                            }
                            if (arrPos != null) {
                                artnr=request.getParameter("artnr" + arrPos);
                                if (artnr!=null) {
                                    psInsert.setString(1, wmsOrdernr);
                                    psInsert.setInt(2, pos);
                                    psInsert.setString(3, artnr);
                                    psInsert.executeUpdate();

                                        

                                    try { 
                                        tal = request.getParameter("bekraftat" + arrPos).replace(",",".").replace(" ", "").replace(nbsp, "").replace("\u2212","-");
                                        bekraftat = Double.parseDouble(tal); 
                                    }
                                    catch (NullPointerException ne) { bekraftat=null; }
                                    catch (NumberFormatException fe) { if(request.getParameter("bekraftat" + arrPos).length()<1) bekraftat=null; else throw new ErrorException("Felaktigt värde artikel " + artnr + " (" + request.getParameter("bekraftat" + arrPos) + ") bekraftat position " + arrPos); }

                                    if (bekraftat!=null) {
                                        psInsert.setString(1, wmsOrdernr);
                                        psInsert.setString(2, ""+pos);
                                        psInsert.setString(3, artnr);
                                        psInsert.setDouble(4, bekraftat);
                                        psInsert.executeUpdate();
                                    }
                                }
                            }
                        }
                    }
                    if ("true".equals(request.getParameter("fardigmarkera"))) {
                        ps = con.prepareStatement("select wmsfardigmarkeraorder(?), wmsordersamfak(?,?,?);");
                        ps.setString(1, wmsOrdernr);
                        ps.setString(2, request.getParameter("anvandare"));
                        ps.setString(3, wmsOrdernr);
                        ps.setBoolean(4, "true".equals(request.getParameter("hindrasamfakstatus")));
                        ps.executeQuery();
                    }
                    con.commit();
                    jb.addResponseOK();
                }
                catch (SQLException e) {
                    jb.addResponseError("SQLException: " + e.toString());
                    try { con.rollback(); } catch (SQLException ee) {}
                    Const.log(e.toString());
                }
                catch(ErrorException e) {
                    jb.addResponseError(e.getMessage());
                    try { con.rollback(); } catch (SQLException ee) {}
                }
                catch (Exception e) {
                    e.printStackTrace();
                    jb.addResponseError(e.getMessage());
                    try { con.rollback(); } catch (SQLException ee) {}                    
                }
                finally {
                    out.print(jb.getJsonString());
                }
 
                
                
            } else if ("markorderwms".equals(ac)) {
                response.setContentType("application/json;charset=UTF-8");
                try {
                    con.setAutoCommit(false);
                    if (!Const.doesUserExists(con, anvandare)) throw new ErrorException("Användare är ogiltigt.");

                    ps = con.prepareStatement("select * from wmsorder1 o1 where wmsordernr=?");
                    ps.setString(1, wmsOrdernr);
                    rs = ps.executeQuery();
                    if (!rs.next()) throw new ErrorException("Order " + wmsOrdernr + " finns inte.");
                    if (rs.getDate("lastdatum")!=null) throw new ErrorException("Ordern är låst " + rs.getString("lastdatum") + " av " + rs.getString("lastav") + ". Lås upp innan överföring."); 
                    if (!"Sparad".equals(rs.getString("status"))) throw new ErrorException("Orderstatus är " + rs.getString("status") + ". Endast sparade order kan hanteras."); 


                    ps = con.prepareStatement("select ppgexportorder(?,?)");
                    ps.setString(1, wmsOrdernr);
                    ps.setString(2, anvandare);
                    ps.executeQuery();
                   
//                    con.createStatement().executeUpdate("");

                    con.commit();
                    jb.addResponseOK();
                    try { printPdf(OrderPlockatillPdf.getPdf(con, wmsOrdernr),"ORDER", "Order", 1); }catch(PrinterException e) { Const.log("Kan inte skriva ut"); e.printStackTrace(); }
                }
                catch (SQLException e) {
                    jb.addResponseError("SQLException: " + e.toString());
                    try { con.rollback(); } catch (SQLException ee) {}
                    Const.log(e.toString());
                }
                catch(ErrorException e) {
                    jb.addResponseError(e.getMessage());
                    try { con.rollback(); } catch (SQLException ee) {}
                }
                finally {
                    out.print(jb.getJsonString());
                }
 
                
            } else if ("markinlevwms".equals(ac)) {
                response.setContentType("application/json;charset=UTF-8");
                try {
                    con.setAutoCommit(false);
                    if (!Const.doesUserExists(con, anvandare)) throw new ErrorException("Användare är ogiltigt.");
                    ps = con.prepareStatement("select ppgexportinlev(?,?)");
                    ps.setString(1, wmsOrdernr);
                    ps.setString(2, anvandare);
                    ps.executeQuery();
                    con.commit();
                    jb.addResponseOK();
                }
                catch (SQLException e) {
                    jb.addResponseError("SQLException: " + e.toString());
                    try { con.rollback(); } catch (SQLException ee) {}
                    Const.log(e.toString());
                }
                catch(ErrorException e) {
                    jb.addResponseError(e.getMessage());
                    try { con.rollback(); } catch (SQLException ee) {}
                }
                finally {
                    out.print(jb.getJsonString());
                }
 
                
                
            } else if ("getkollilist".equals(ac)) {
                response.setContentType("text/html;charset=UTF-8");        
                request.setAttribute("wmsordernr", wmsOrdernr);
                request.getRequestDispatcher("WEB-INF/getkollilist.jsp").include(request, response);
            } else if ("deletekolli".equals(ac)) {
                response.setContentType("text/html;charset=UTF-8");        
                Integer kolliid=null;
                try { kolliid = Integer.parseInt(request.getParameter("kolliid"));  } catch (NumberFormatException e) {  }
                if (kolliid!=null) {
                    try {
                        ps=con.prepareStatement("select wmsordernr from wmskollin where kolliid=?");
                        ps.setInt(1, kolliid);
                        rs = ps.executeQuery();
                        if (rs.next()) request.setAttribute("wmsordernr", rs.getString(1));
                    
                        ps = con.prepareStatement("delete from wmskollin where kolliid=?");
                        ps.setInt(1, kolliid);
                        ps.executeUpdate();
                        
                    } catch (SQLException e) { out.print("Kan inte radera kolli " + kolliid + ". " + e.getMessage()); }
                }
                request.getRequestDispatcher("WEB-INF/getkollilist.jsp").include(request, response);
                
            } else if ("addkolli".equals(ac)) {
                response.setContentType("text/html;charset=UTF-8");        
                String kollityp = request.getParameter("kollityp");
                Integer langdcm = null;
                Integer breddcm = null;
                Integer hojdcm = null;
                Integer viktkg = null;
                int antal = 0;
                try { antal = Integer.parseInt(request.getParameter("antal"));  } catch (NumberFormatException e) { antal = 1; }
                try { viktkg = Integer.parseInt(request.getParameter("viktkg"));  } catch (NumberFormatException e) {  }
                try { langdcm = Integer.parseInt(request.getParameter("langdcm"));  } catch (NumberFormatException e) {  }
                try { breddcm = Integer.parseInt(request.getParameter("breddcm"));  } catch (NumberFormatException e) {  }
                try { hojdcm = Integer.parseInt(request.getParameter("hojdcm"));  } catch (NumberFormatException e) {  }
                if(antal > 0 && antal <= 100 ) {
                    try {
                        ps = con.prepareStatement("insert into wmskollin (wmsordernr, kollityp, langdcm, breddcm, hojdcm, viktkg) select wmsordernr, ?,?,?,?,? from wmsorder1 where wmsordernr=?");
                        for (int i=0; i<antal; i++) {
                            ps.setString(6, wmsOrdernr);
                            ps.setString(1, kollityp);
                            if (langdcm==null) ps.setNull(2,java.sql.Types.INTEGER); else ps.setInt(2,langdcm );
                            if (breddcm==null) ps.setNull(3,java.sql.Types.INTEGER); else ps.setInt(3,breddcm );
                            if (hojdcm==null) ps.setNull(4,java.sql.Types.INTEGER); else ps.setInt(4,hojdcm );
                            if (viktkg==null) ps.setNull(5,java.sql.Types.INTEGER); else ps.setInt(5,viktkg );
                            int res = ps.executeUpdate();
                            if (res==0) throw new SQLException("Wmsordernr " + wmsOrdernr + " finns inte.");
                        }
                    }catch (SQLException e) { out.print("Fel: " + e.getMessage() + "<br>");}
                } else {
                    out.print("Felaktigt antal: " + antal);
                }
                request.setAttribute("wmsordernr", wmsOrdernr);
                request.getRequestDispatcher("WEB-INF/getkollilist.jsp").include(request, response);
            } else {
                jb.addResponseError("Ogiltigt kommando: " + ac );
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
