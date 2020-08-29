/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms.infoscreen;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.wms.Const;

/**
 *
 * @author ulf
 */
@WebServlet(name = "InfoScreenDataServlet", urlPatterns = {"/infoscreen/data"})
public class InfoScreenDataServlet extends HttpServlet {

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
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            Connection con=Const.getPPGConnection(request);
            PreparedStatement ps;
            ResultSet rs;
            
            try {
                ps = con.prepareStatement(getSql());
                rs = ps.executeQuery();
                rs.next();

                String json = "{" +
                        "\"" + "ordrar" + "\"" + ":\"" + rs.getInt("ordrar") + "\"" +
                        ", \"" + "ordrarhotpick" + "\"" + ":\"" + rs.getInt("ordrarhotpick") + "\"" +
                        ", \"" + "ordrarhotpickdagens" + "\"" + ":\"" + rs.getInt("ordrarhotpickdagens") + "\"" +
                        ", \"" + "orderrader" + "\"" + ":\"" + rs.getInt("orderrader") + "\"" +
                        ", \"" + "hotpickorderrader" + "\"" + ":\"" + rs.getInt("hotpickorderrader") + "\"" +
                        ", \"" + "hotpickorderraderdagens" + "\"" + ":\"" + rs.getInt("hotpickorderraderdagens") + "\"" +
                        ", \"" + "plockadedagens" + "\"" + ":\"" + rs.getInt("plockadedagens") + "\"" +
                        ", \"" + "inlagradedagens" + "\"" + ":\"" + rs.getInt("inlagradedagens") + "\"" +
                        ", \"" + "plockade14dagarsnitt" + "\"" + ":\"" + rs.getInt("plockade14dagarsnitt") + "\"" +
                        ", \"" + "inlagrade14dagarsnitt" + "\"" + ":\"" + rs.getInt("inlagrade14dagarsnitt") + "\"" +
                        ", \"" + "plockade140dagarsnitt" + "\"" + ":\"" + rs.getInt("plockade140dagarsnitt") + "\"" +
                        ", \"" + "inlagrade140dagarsnitt" + "\"" + ":\"" + rs.getInt("inlagrade140dagarsnitt") + "\"" +
                        "}";

                out.write(json);
                out.flush();
            }
            catch (Exception e) { e.printStackTrace(); }
            finally { 
                try { con.close(); } catch (Exception e) {} 
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


    private String getSql() {
        return "select *\n" +
"from (\n" +
"select \n" +
"count(DISTINCT wo.Masterorderid) as ordrar,\n" +
"count(DISTINCT case  when wo.Priority=4 then wo.masterorderid else null end) as ordrarhotpick,\n" +
"count(DISTINCT case  when wo.Priority=4 and convert(date,wo.Creationdate)=convert(date,CURRENT_TIMESTAMP) then wo.masterorderid else null end) as ordrarhotpickdagens,\n" +
"count(*) as orderrader,\n" +
"sum (case when wo.Priority=4 then 1 else 0 end) as hotpickorderrader,\n" +
"sum (case when wo.Priority=4 and convert(date,wo.Creationdate)=convert(date,CURRENT_TIMESTAMP) then 1 else 0 end) as hotpickorderraderdagens\n" +
"\n" +
"from Masterorder wo join Masterorderline wol on wol.MasterorderId = wo.MasterorderId\n" +
"where wo.DirectionType=2 ) mo\n" +
"join(\n" +
"select \n" +
"sum(case when type in (2,4) and convert(date, creationdate) = convert(date,CURRENT_TIMESTAMP)  then 1 else 0 end) as plockadedagens,\n" +
"sum(case when type in (1,3) and convert(date, creationdate) = convert(date,CURRENT_TIMESTAMP) then 1 else 0 end) as inlagradedagens,\n" +
"sum(case when type in (2,4) and creationdate >= dateadd(day,-10, CURRENT_TIMESTAMP) then 1 else 0 end) as plockade14dagar,\n" +
"\n" +
"sum(case when type in (2,4) and cast (creationdate as date) between  cast(dateadd(day,-15, CURRENT_TIMESTAMP) as date) and cast(dateadd(day,-1, CURRENT_TIMESTAMP) as date) then 1 else 0 end) / \n" +
"nullif(count (DISTINCT case when type in (2,4) and cast (creationdate as date) between  cast(dateadd(day,-15, CURRENT_TIMESTAMP) as date) and cast(dateadd(day,-1, CURRENT_TIMESTAMP) as date) then convert(date, creationdate) else null end),0)\n" +
"as plockade14dagarsnitt,\n" +
"\n" +
"sum(case when type in (1,3) and cast (creationdate as date) between  cast(dateadd(day,-15, CURRENT_TIMESTAMP) as date) and cast(dateadd(day,-1, CURRENT_TIMESTAMP) as date) then 1 else 0 end) / \n" +
"nullif(count (DISTINCT case when type in (1,3) and cast (creationdate as date) between  cast(dateadd(day,-15, CURRENT_TIMESTAMP) as date) and cast(dateadd(day,-1, CURRENT_TIMESTAMP) as date) then convert(date, creationdate) else null end),0)\n" +
"as inlagrade14dagarsnitt,\n" +
"\n" +
"sum(case when type in (2,4) and cast (creationdate as date) between  cast(dateadd(day,-141, CURRENT_TIMESTAMP) as date) and cast(dateadd(day,-1, CURRENT_TIMESTAMP) as date) then 1 else 0 end) / \n" +
"nullif(count (DISTINCT case when type in (2,4) and cast (creationdate as date) between  cast(dateadd(day,-141, CURRENT_TIMESTAMP) as date) and cast(dateadd(day,-1, CURRENT_TIMESTAMP) as date) then convert(date, creationdate) else null end),0)\n" +
"as plockade140dagarsnitt,\n" +
"\n" +
"sum(case when type in (1,3) and cast (creationdate as date) between  cast(dateadd(day,-141, CURRENT_TIMESTAMP) as date) and cast(dateadd(day,-1, CURRENT_TIMESTAMP) as date) then 1 else 0 end) / \n" +
"nullif(count (DISTINCT case when type in (1,3) and cast (creationdate as date) between  cast(dateadd(day,-141, CURRENT_TIMESTAMP) as date) and cast(dateadd(day,-1, CURRENT_TIMESTAMP) as date) then convert(date, creationdate) else null end),0)\n" +
"as inlagrade140dagarsnitt\n" +
"\n" +
"from history \n" +
"where QuantityConfirmed <> 0 and cast(creationdate as date) >= cast(dateadd(day,-141, CURRENT_TIMESTAMP) as date)  and type in (1,2,3,4)\n" +
") h1 on 1=1\n" +
"";
    }
}
