CREATE OR REPLACE FUNCTION wmsordersamfak(
    in_anvandare character varying,
    in_wmsordernr varchar)
  RETURNS void AS
$BODY$
declare
	this_ordernr integer;
	this_nyordernr integer;
	this_antalrestorder integer;
	this_tillannanfilial  boolean;
	this_isfelpris boolean;
	this_isejfakturerbar boolean;
	this_endastspara boolean;	
	this_ejrestorder boolean;
	this_sparstatus varchar;
	this_status varchar;
begin
	if substring(in_wmsordernr,1,2) not in ('AB','AS') then raise exception 'Felaktigt prefix på ordernumret %', in_wmsordernr; end if;
	if not exists (select from wmsorder1 where wmsordernr=in_wmsordernr) then raise exception 'Ordernummer % saknas', in_wmsordernr; end if;
	if exists (select from wmsorder2 o2 left outer join wmsorderplock wp on wp.wmsordernr=o2.wmsordernr and o2.pos=wp.pos and o2.artnr=wp.artnr where o2.wmsordernr=in_wmsordernr and wp.pos is null) 
		then raise exception 'Det finns ej behandlade rader på order %', in_wmsordernr; end if;

	select into this_status, this_ordernr, this_tillannanfilial  status, orgordernr, case when tillannanfilial <> 0 then true else false end from wmsorder1 where wmsordernr=in_wmsordernr;

	if this_status not in ('Sparad','Utskriven','Avvakt') then raise exception 'Order % har status % och kan inte behandlas. Tillåtna statusar är Utskr, Sparad och Avvakt.', in_wmsordernr, this_status; end if;

	this_isfelpris = false;
	this_endastspara=false;
	this_ejrestorder=false;

if substring(in_wmsordernr,1,2)='AB' then

	if exists (select from sxfakt.order2 where ordernr=this_ordernr and ((pris*(1-rab/100) < netto and netto <>0) or (pris=0 and artnr not like '*UD%') )) then this_isfelpris=true; end if;

	select into this_isejfakturerbar case when ejfakturerbar <> 0 then true else false end from sxfakt.kund where nummer = (select kundnr from sxfakt.order1 where ordernr=this_ordernr);

	if (this_tillannanfilial or this_isfelpris or this_isejfakturerbar) then this_endastspara=true; end if;
	if (this_tillannanfilial or this_isejfakturerbar) then this_ejrestorder=true; end if;

	if (this_endastspara) then this_sparstatus = 'W-Klar'; else this_sparstatus = 'Samfak'; end if;

	update sxfakt.order2 set wmslock=null where ordernr=this_ordernr;
	update sxfakt.order1 set status=this_sparstatus where ordernr=this_ordernr;
	update sxfakt.order2 o2 set lev=(select bekraftat from wmsorderplock wp where wp.wmsordernr=in_wmsordernr and wp.pos=o2.pos) 
		where ordernr=this_ordernr;

	update sxfakt.lager set iorder = iorder - s.best 
		from (select o1.lagernr, o2.artnr, o2.best from sxfakt.order1 o1 join order2 o2 on o1.ordernr=o2.ordernr where o1.ordernr=this_ordernr and o2.artnr not like '*%') s
		where lager.lagernr=s.lagernr and lager.artnr=s.artnr; 
	
	select into this_antalrestorder count(*) from sxfakt.order2 where ordernr=this_ordernr and 
		case when best>=0 then case when lev < best then best-lev else 0 end else case when lev > best then best-lev else 0 end end <> 0;
		
	if (this_antalrestorder > 0 and not this_ejrestorder) then
		select fdordernr.ordernr into this_nyordernr from sxfakt.fdordernr;
		update sxfakt.fdordernr set ordernr = ordernr+1;
		insert into sxfakt.order1 	(ordernr, dellev, namn, adr1, adr2, adr3, levadr1, levadr2, levadr3, saljare, referens, kundnr, marke, 
						datum, moms, status, ktid, bonus, faktor, levdat, levvillkor, mottagarfrakt, fraktkundnr, 
						fraktbolag, fraktfrigrans, lagernr, direktlevnr, returorder, veckolevdag, tillannanfilial, utlevbokad, 
						annanlevadress, ordermeddelande, tidigastfaktdatum, wordernr, linjenr1, linjenr2, linjenr3, kundordernr, 
						forskatt, forskattbetald, betalsatt)
				select 		this_nyordernr, dellev+1, namn, adr1, adr2, adr3, levadr1, levadr2, levadr3, saljare, referens, kundnr, marke,
						current_date, moms, 'Sparad',  ktid, bonus, faktor, levdat, levvillkor, mottagarfrakt, fraktkundnr,
						fraktbolag, fraktfrigrans, lagernr, direktlevnr, returorder, veckolevdag, tillannanfilial, utlevbokad, 
						annanlevadress, ordermeddelande, tidigastfaktdatum, wordernr, linjenr1, linjenr2, linjenr3, kundordernr, 
						forskatt, forskattbetald, betalsatt
				from sxfakt.order1 where ordernr=this_ordernr;
		insert into sxfakt.order2 	(ordernr, pos, prisnr, dellev, artnr, namn, levnr, rab,
						best,
						lev,
						text, pris, summa, konto,
						netto, enh, levdat, utskrivendatum, utskriventid, stjid)
				select		this_nyordernr, pos, prisnr, dellev+1, artnr, namn, levnr, rab,
						case when best>=0 then case when lev < best then best-lev else 0 end else case when lev > best then best-lev else 0 end end, 
						case when best>=0 then case when lev < best then best-lev else 0 end else case when lev > best then best-lev else 0 end end, 
						text, pris, summa, konto,
						netto, enh, levdat, utskrivendatum, utskriventid, stjid
				from sxfakt.order2 where ordernr=this_ordernr and case when best>=0 then case when lev < best then best-lev else 0 end else case when lev > best then best-lev else 0 end end <> 0;
		
		update sxfakt.order2 set summa=round((pris*best*(1-rab/100))::numeric,2) where ordernr=this_nyordernr;
		
		insert into sxfakt.orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
			values (this_nyordernr, current_date, current_time, in_anvandare, 'Skapad', 0, 0, 0); 
			
		update sxfakt.lager set iorder = iorder + s.best 
			from (select o1.lagernr, o2.artnr, o2.best from sxfakt.order1 o1 join sxfakt.order2 o2 on o1.ordernr=o2.ordernr where o1.ordernr=this_nyordernr and o2.artnr not like '*%') s
			where lager.lagernr=s.lagernr and lager.artnr=s.artnr; 
	end if;
	
	update sxfakt.order2 set best=lev where ordernr=this_ordernr;
	update sxfakt.lager set iorder = iorder + s.best 
		from (select o1.lagernr, o2.artnr, o2.best from sxfakt.order1 o1 join sxfakt.order2 o2 on o1.ordernr=o2.ordernr where o1.ordernr=this_ordernr and o2.artnr not like '*%') s
		where lager.lagernr=s.lagernr and lager.artnr=s.artnr; 
	insert into sxfakt.orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
		values (this_ordernr, current_date, current_time, in_anvandare, 'WMS ' || this_sparstatus, 0, 0, 0); 

elsif substring(in_wmsordernr,1,2)='AS' then
	if exists (select from sxasfakt.order2 where ordernr=this_ordernr and ((pris*(1-rab/100) < netto and netto <>0) or (pris=0 and artnr not like '*UD%') )) then this_isfelpris=true; end if;

	select into this_isejfakturerbar case when ejfakturerbar <> 0 then true else false end from sxasfakt.kund where nummer = (select kundnr from sxasfakt.order1 where ordernr=this_ordernr);

	if (this_tillannanfilial or this_isfelpris or this_isejfakturerbar) then this_endastspara=true; end if;
	if (this_tillannanfilial or this_isejfakturerbar) then this_ejrestorder=true; end if;

	if (this_endastspara) then this_sparstatus = 'W-Klar'; else this_sparstatus = 'Samfak'; end if;

	update sxasfakt.order2 set wmslock=null where ordernr=this_ordernr;
	update sxasfakt.order1 set status=this_sparstatus where ordernr=this_ordernr;
	update sxasfakt.order2 o2 set lev=(select bekraftat from wmsorderplock wp where wp.wmsordernr=in_wmsordernr and wp.pos=o2.pos) 
		where ordernr=this_ordernr;

	update sxasfakt.lager set iorder = iorder - s.best 
		from (select o1.lagernr, o2.artnr, o2.best from sxasfakt.order1 o1 join order2 o2 on o1.ordernr=o2.ordernr where o1.ordernr=this_ordernr and o2.artnr not like '*%') s
		where lager.lagernr=s.lagernr and lager.artnr=s.artnr; 
	
	select into this_antalrestorder count(*) from sxasfakt.order2 where ordernr=this_ordernr and 
		case when best>=0 then case when lev < best then best-lev else 0 end else case when lev > best then best-lev else 0 end end <> 0;
		
	if (this_antalrestorder > 0 and not this_ejrestorder) then
		select fdordernr.ordernr into this_nyordernr from sxasfakt.fdordernr;
		update sxasfakt.fdordernr set ordernr = ordernr+1;
		insert into sxasfakt.order1 	(ordernr, dellev, namn, adr1, adr2, adr3, levadr1, levadr2, levadr3, saljare, referens, kundnr, marke, 
						datum, moms, status, ktid, bonus, faktor, levdat, levvillkor, mottagarfrakt, fraktkundnr, 
						fraktbolag, fraktfrigrans, lagernr, direktlevnr, returorder, veckolevdag, tillannanfilial, utlevbokad, 
						annanlevadress, ordermeddelande, tidigastfaktdatum, wordernr, linjenr1, linjenr2, linjenr3, kundordernr, 
						forskatt, forskattbetald, betalsatt)
				select 		this_nyordernr, dellev+1, namn, adr1, adr2, adr3, levadr1, levadr2, levadr3, saljare, referens, kundnr, marke,
						current_date, moms, 'Sparad',  ktid, bonus, faktor, levdat, levvillkor, mottagarfrakt, fraktkundnr,
						fraktbolag, fraktfrigrans, lagernr, direktlevnr, returorder, veckolevdag, tillannanfilial, utlevbokad, 
						annanlevadress, ordermeddelande, tidigastfaktdatum, wordernr, linjenr1, linjenr2, linjenr3, kundordernr, 
						forskatt, forskattbetald, betalsatt
				from sxasfakt.order1 where ordernr=this_ordernr;
		insert into sxasfakt.order2 	(ordernr, pos, prisnr, dellev, artnr, namn, levnr, rab,
						best,
						lev,
						text, pris, summa, konto,
						netto, enh, levdat, utskrivendatum, utskriventid, stjid)
				select		this_nyordernr, pos, prisnr, dellev+1, artnr, namn, levnr, rab,
						case when best>=0 then case when lev < best then best-lev else 0 end else case when lev > best then best-lev else 0 end end, 
						case when best>=0 then case when lev < best then best-lev else 0 end else case when lev > best then best-lev else 0 end end, 
						text, pris, summa, konto,
						netto, enh, levdat, utskrivendatum, utskriventid, stjid
				from sxasfakt.order2 where ordernr=this_ordernr and case when best>=0 then case when lev < best then best-lev else 0 end else case when lev > best then best-lev else 0 end end <> 0;
		
		update sxasfakt.order2 set summa=round((pris*best*(1-rab/100))::numeric,2) where ordernr=this_nyordernr;
		
		insert into sxasfakt.orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
			values (this_nyordernr, current_date, current_time, in_anvandare, 'Skapad', 0, 0, 0); 
			
		update sxasfakt.lager set iorder = iorder + s.best 
			from (select o1.lagernr, o2.artnr, o2.best from sxasfakt.order1 o1 join sxasfakt.order2 o2 on o1.ordernr=o2.ordernr where o1.ordernr=this_nyordernr and o2.artnr not like '*%') s
			where lager.lagernr=s.lagernr and lager.artnr=s.artnr; 
	end if;
	
	update sxasfakt.order2 set best=lev where ordernr=this_ordernr;
	update sxasfakt.lager set iorder = iorder + s.best 
		from (select o1.lagernr, o2.artnr, o2.best from sxasfakt.order1 o1 join sxasfakt.order2 o2 on o1.ordernr=o2.ordernr where o1.ordernr=this_ordernr and o2.artnr not like '*%') s
		where lager.lagernr=s.lagernr and lager.artnr=s.artnr; 
	insert into sxasfakt.orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
		values (this_ordernr, current_date, current_time, in_anvandare, 'WMS ' || this_sparstatus, 0, 0, 0); 


end  if;
	
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

