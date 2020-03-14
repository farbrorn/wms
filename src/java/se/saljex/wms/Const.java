/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Date;
import javax.servlet.http.HttpServletRequest;

/**
 *
 * @author ulf
 */
public class Const {
    private static final SimpleDateFormat simpleDateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.S");
    private static final SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
                         
    public static Connection getConnection(HttpServletRequest request) {
        return (Connection)request.getAttribute("sxconnection");
    }
 public static Connection getPPGConnection(HttpServletRequest request) {
        return (Connection)request.getAttribute("ppgconnection");
    }
 
	public static final  String ORDER_STATUS_SPARAD = "Sparad";
	public static final  String ORDER_STATUS_DIREKTLEV = "Direkt";
	public static final  String ORDER_STATUS_SIMPLEORDER = "Simple";
	public static final  String ORDER_STATUS_VANTAR = "Väntar";
	public static final  String ORDER_STATUS_AVVAKT = "Avvakt";
	public static final  String ORDER_STATUS_OVERFORD = "Överf";
	public static final  String ORDER_STATUS_SAMFAK = "Samfak";
	public static final  String ORDER_STATUS_HAMT = "Hamt";
	public static final  String ORDER_STATUS_FORSKOTT = "Försk";

	
	public static final  String ORDERHAND_SKAPAD = "Skapad";
	public static final  String ORDERHAND_RADERAD = "Raderad";
	public static final  String ORDERHAND_ANDRAD = "Ändrad";
	public static final  String ORDERHAND_FAKTURERAD = "Fakturerad";
	public static final  String ORDERHAND_UTSKRIVEN = "Utskriven";

	public static final  String HANDELSE_SKAPAD = "Skapad";
	public static final  String HANDELSE_RADERAD = "Raderad";
	public static final  String HANDELSE_ANDRAD = "Ändrad";

        public static String getBarcodeFontLinkHTML() {
            return "<link href=\"https://fonts.googleapis.com/css?family=Libre+Barcode+39&display=swap\" rel=\"stylesheet\">";        
        }
        
        //Databas schema namn med tillhörande offsset för att lägga till ordernummret.
        //Observera att array-elementen hör ihop
//        private static final String[] dbSchemas = new String[]{"sxfakt","sxasfakt"};
//        private static final int[] dbSchemasOrdernrOffsets = new int[]{100000000, 200000000};
//        private static final String[] ordernrPrefix = new String[]{"AB-", "AS-"};
//        public static String[] getDbSchemas() { return dbSchemas; }
        //public static int[] getDbSchemasOrdernrOffsets() { return dbSchemasOrdernrOffsets; }
//        public static String[] getOrdernrPrefix() { return ordernrPrefix; }

        public static void log(String s) {
            System.out.println(Const.getFormatDateTime(new Date()) + " " + s);        
        }
        
        public static int getLagerNr() { return 0; }
        public static String getLogoUrl(Connection con, String dbSchema) throws SQLException {
            String dbPrefix = dbSchema + ".";
            PreparedStatement ps = con.prepareStatement("select varde from " + dbPrefix + "sxreg where id=?");
            ps.setString(1, "Hemsida-LogoUrl");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString(1); else return null;
        }
        
        public static String getBildUrl() {
            return "https://www.saljex.se/p/s50/";
        }
        
        public static boolean doesUserExists(Connection con, String anvandare) throws SQLException{
            if (Const.isEmpty(anvandare)) return false;
            PreparedStatement ps = con.prepareStatement("select namn from saljare where forkortning=?");
            ps.setString(1, anvandare);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return true; else return false;
        }
        public static String getSchema(Connection con, int wmsOrdernr) throws SQLException {
            PreparedStatement ps = con.prepareStatement("select wmsdbschema from  wmsorder1 o1 where wmsordernr=? and o1.orgordernr= wmsordernr2int(?)" );
            ps.setInt(1, wmsOrdernr);
            ps.setInt(2, wmsOrdernr);
            ResultSet rs=ps.executeQuery();
            return rs.getString(1);
        }
  
/*        
        public static String getOrder1Union(String columnList) {
            StringBuilder sb = new StringBuilder();
            sb.append("(");
            int sLen = getDbSchemas().length;
            for (int i=0; i<sLen; i++) {
                if (i>0) sb.append(" union all ");
                String schema = getDbSchemas()[i];
                String schemaPrefix;
                if (schema==null) schema="";
                if (schema.length()<1)  schemaPrefix=""; else schemaPrefix=schema+".";
                sb.append("select ");
                sb.append("'" + getOrdernrPrefix()[i] + "'");
                sb.append(" || ordernr::varchar");
//                sb.append("select ordernr+");
//                sb.append(getDbSchemasOrdernrOffsets()[i]); 
                sb.append(" as wmsordernr, '");
                sb.append(schema);
                sb.append( "' as dbschema ");
                if (Const.toStr(columnList).length()>0) {
                    sb.append(",");
                    sb.append(columnList);
                }
                sb.append(" from ");
                sb.append(schemaPrefix);
                sb.append("order1 ");
            }
            sb.append(")");
            return sb.toString();
        }
        
        public static String getOrder2Union(String columnList) {
            StringBuilder sb = new StringBuilder();
            sb.append("(");
            int sLen = getDbSchemas().length;
            for (int i=0; i<sLen; i++) {
                if (i>0) sb.append(" union all ");
                String schema = getDbSchemas()[i];
                String schemaPrefix;
                if (schema==null) schema="";
                if (schema.length()<1)  schemaPrefix=""; else schemaPrefix=schema+".";
                sb.append("select ");
                sb.append("'" + getOrdernrPrefix()[i] + "'");
                sb.append(" || ordernr::varchar");
//                sb.append("select ordernr+");
//                sb.append(getDbSchemasOrdernrOffsets()[i]); 
                sb.append(" as wmsordernr, '");
                sb.append(schema);
                sb.append( "' as dbschema ");
                if (Const.toStr(columnList).length()>0) {
                    sb.append(",");
                    sb.append(columnList);
                }
                sb.append(" from ");
                sb.append(schemaPrefix);
                sb.append("order2 ");
            }
            sb.append(")");
            return sb.toString();
        }
*/        
    
    public static String getSQLTransportorOmkodad(String colnameFraktbolag, String colnameLinjenr) {
        return 
"case when "+colnameFraktbolag+"='Turbil' and ("+colnameLinjenr+" is null ) then \n" +
"	'Lämpligt' \n" +
"else \n" +
"	case when "+colnameFraktbolag+"='Turbil' then \n" +
"		'Turbil ' || "+colnameLinjenr+" " +
"	else\n" +
"		case when "+colnameFraktbolag+" is null or trim("+colnameFraktbolag+")='' then \n" +
"			case when "+colnameLinjenr+" is null  then \n" +
"				'Lämpligt' \n" +
"			else \n" +
"				'Turbil ' || "+colnameLinjenr+"\n" +
"			end\n" +
"		else \n" +
"			"+colnameFraktbolag+" \n" +
"		end\n" +
"	end\n" +
"end ";                 
    }
        
    public static String getFormatDate(Date d) {
		 if (d != null) {
			 return simpleDateFormat.format(d);
		 } else { return ""; }
    }
    public static String getFormatDateTime(Date d) {
		 if (d != null) {
			 return simpleDateTimeFormat.format(d);
		 } else { return ""; }
    }
    
    public static String getFormatNumber(Double tal, int decimaler) {
		  if (tal == null) return "";
        NumberFormat nf;
		  nf = NumberFormat.getInstance();
		  nf.setMaximumFractionDigits(decimaler);
		  nf.setMinimumFractionDigits(decimaler);
        return nf.format(tal);
    }

    public static String getFormatNumber(Float tal, int decimaler) {
		 return getFormatNumber(new Double(tal));
    }

    public static String getFormatNumber(Double tal) {
        return getFormatNumber(tal,2);
    }
    public static String getFormatNumber(Float tal) {
        return getFormatNumber(new Double(tal));
    }

	public static Double getRoundedDecimal(Double a) {	
		//Returnerar värdet avrundat till två decimaler
		return Math.round(a*100.0) / 100.0;
	}
    public static Date addDate(Date d, int dagar) {
       Calendar calendar = Calendar.getInstance();
       calendar.setTime(d);
       calendar.add(Calendar.DATE, dagar);
       return calendar.getTime();
    }

	 public static boolean isEmpty(String s) {
		 if (s==null || s.trim().isEmpty()) return true; else return false;
	 }

	 public static Integer noNull(Integer a) {
		 if (a==null) return 0; else return a;
	 }
	 public static Double noNull(Double a) {
		 if (a==null) return 0.0; else return a;
	 }
	 
	 public static String toStr(String s) {
		 if (s == null) return ""; else return s;
	 }
	 public static String urlEncode(String s) {
		 if (s == null) return ""; else try { return URLEncoder.encode(s, "UTF-8"); } catch (UnsupportedEncodingException e) {}
		 return "";//Om vi får exception retureneras ""
	 }
	 
	public static String toHtml(String string) {
		// Baserat på kod från http://www.rgagnon.com/javadetails/java-0306.html av S. Bayer
		if (string == null) return "";
		StringBuffer sb = new StringBuffer(string.length());
		// true if last char was blank
		boolean lastWasBlankChar = false;
		int len = string.length();
		char c;

		for (int i = 0; i < len; i++)	{
			c = string.charAt(i);
			if (c == ' ') {
				// blank gets extra work,
				// this solves the problem you get if you replace all
				// blanks with &nbsp;, if you do that you loss 
				// word breaking
				if (lastWasBlankChar) {
					 lastWasBlankChar = false;
					 sb.append("&nbsp;");
				 } else {
					 lastWasBlankChar = true;
					 sb.append(' ');
				}
			} else {
            lastWasBlankChar = false;
				// HTML Special Chars
				if (c == '"') sb.append("&quot;");
				else if (c == '&') sb.append("&amp;");
				else if (c == '<') sb.append("&lt;");
				else if (c == '>') sb.append("&gt;");
				else if (c == '\n') sb.append("<br/>");
				else sb.append(c);
			}
		}
		return sb.toString();
	}
        
}
