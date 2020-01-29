/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ulf
 */
public class OrderGrupper {
   private Connection con;

    public OrderGrupper(Connection con) {
        this.con=con;
    }
    
    public List<OrderGrupp> getFromDatabase(Integer lagern, String status) throws SQLException {
        ResultSet rs;
        PreparedStatement ps;
    String q = "select fraktbolag, count(distinct ordernr) as antal from (select \n" +
"o1.ordernr,\n" +
"case when fraktbolag='Turbil' and (tl1.linjenr is null ) then \n" +
"	'Lämpligt' \n" +
"else \n" +
"	case when fraktbolag='Turbil' then \n" +
"		'Turbil ' || tl1.linjenr --|| tl1.namn || ', ' || tl2.namn || ', ' || tl3.namn || ', ' \n" +
"	else\n" +
"		case when fraktbolag is null or trim(fraktbolag)='' then \n" +
"			case when tl1.linjenr is null  then \n" +
"				'Lämpligt' \n" +
"			else \n" +
"				'Turbil ' || tl1.linjenr\n" +
"			end\n" +
"		else \n" +
"			fraktbolag \n" +
"		end\n" +
"	end\n" +
"end as fraktbolag,\n" +
"tl1.namn t1_namn, tl1.d1 as t1_d1, tl1.d2 as t1_d2, tl1.d3 as t1_d3, tl1.d4 as t1_d4,  tl1.d5 as t1_d5\n" +
"\n" +
" from order1 o1 \n" +
"left outer join turlinje tl1 on (tl1.linjenr=o1.linjenr1 or tl1.linjenr=o1.linjenr2 or tl1.linjenr=o1.linjenr3) and tl1.franfilial=o1.lagernr\n" +
"where lagernr=? and o1.status=? ) o \n" +
"group by fraktbolag order by fraktbolag\n";
        ps=con.prepareStatement(q);
        ps.setInt(1, 0);
        ps.setString(2, "Sparad");
        rs = ps.executeQuery();
        List<OrderGrupp> og = new ArrayList<>();
        while (rs.next()) {
            og.add(new OrderGrupp(rs.getString("transportor"), "", rs.getInt("antal")));
        }
        return og;
    }
    
    public class OrderGrupp {
        private String transportor;
        private String linjenr;
        private Integer antalOrdrar;

        public OrderGrupp(String transportor, String linjenr, Integer antalOrdrar) {
            this.transportor = transportor;
            this.linjenr = linjenr;
            this.antalOrdrar = antalOrdrar;
        }

        public String getTransportor() {
            return transportor;
        }

        public void setTransportor(String transportor) {
            this.transportor = transportor;
        }

        public String getLinjenr() {
            return linjenr;
        }

        public void setLinjenr(String linjenr) {
            this.linjenr = linjenr;
        }

        public Integer getAntalOrdrar() {
            return antalOrdrar;
        }

        public void setAntalOrdrar(Integer antalOrdrar) {
            this.antalOrdrar = antalOrdrar;
        }
        
    }

}
