/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

/**
 *
 * @author ulf
 */
public class NewClass {
    String q = "select \n" +
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
"end,\n" +
"tl1.namn t1_namn, tl1.d1 as t1_d1, tl1.d2 as t1_d2, tl1.d3 as t1_d3, tl1.d4 as t1_d4,  tl1.d5 as t1_d5\n" +
"\n" +
" from order1 o1 \n" +
"left outer join turlinje tl1 on (tl1.linjenr=o1.linjenr1 or tl1.linjenr=o1.linjenr2 or tl1.linjenr=o1.linjenr3) and tl1.franfilial=o1.lagernr\n" +
"where lagernr=0 and o1.status='Sparad'\n" +
"order by o1.ordernr desc\n";
}
