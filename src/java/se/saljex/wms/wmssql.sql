--Detta är initiala uppläggningar av databasen för WMS. Ändringar och anpassningar kan ske direkt i databasen




CREATE OR REPLACE FUNCTION ppgexportorder(pl_wmsordernr varchar, pl_anvandare varchar default '00')
  RETURNS varchar AS
$BODY$

begin
perform wmsordernr from wmsorder1 where lastdatum is null and status='Sparad' and wmsordernr=$1;
if not found then raise exception 'Order % hittades inte eller var låst av annan användare eller har inte status sparad.', $1; end if;

if (substring($1,1,2)) = 'AS' then
	update sxasfakt.order1 set status='Utskr' where ordernr = (select orgordernr from wmsorder1 where wmsordernr=$1);
	insert into sxasfakt.orderhand (ordernr, datum, tid, anvandare, handelse ) select orgordernr, current_date,current_time,$2,'WMS' from wmsorder1 where wmsordernr=$1;
else
	update sxfakt.order1 set status='Utskr' where ordernr = (select orgordernr from wmsorder1 where wmsordernr=$1);
	insert into sxfakt.orderhand (ordernr, datum, tid, anvandare, handelse ) select orgordernr, current_date,current_time,$2,'WMS' from wmsorder1 where wmsordernr=$1;
end if;


insert into ppgorderexport (ordernr, kund, levadr12, levadr3, marke, transportor, artnr, artnamn, plockinstruktion , best, forpackinfo, refnr, pos, status, priority, deadline)

select
o1.wmsordernr || case when o2.best < 0 then '-R' else '' end
, o1.namn, o1.levadr1 || ' ' || o1.levadr2, o1.levadr3, 'Godsmärke:' || o1.marke, o1.fraktbolag || ' ' || o1.linjenr1 || ' ' || o1.linjenr2 || ' ' || o1.linjenr3,  
case when substring(o2.artnr,1,1)='*' then replace(o2.artnr,'*','#') || '-' || substring(o1.wmsordernr,1,2) || o2.stjid else replace(o2.artnr,'*','#') end,
 o2.namn, a.plockinstruktion, o2.best * -1, 
 o2.enh || ' Förp: ' || case when a.forpack <= 0 then 1 else a.forpack end || '/' || kop_pack || ' Odelbart: ' || case when a.minsaljpack <=0 then 1 else a.minsaljpack end, 
 a.bestnr || ' ' || rsk || ' ' || enummer || ' ' || refnr , o2.pos,
 0, case when o1.fraktbolag='HOT PICK' then 4 else 0 end,
 case when levdat is not null then levdat else current_date end
from wmsorder1 o1 join wmsorder2 o2 on o1.wmsordernr=o2.wmsordernr left outer join 
sxfakt.artikel a on a.nummer=o2.artnr 
where o2.artnr <> '' and o2.artnr is not null and o2.wmsordernr=$1 and o2.best <> 0 order by o2.wmsordernr, o2.pos;
return $1;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ppgexportorder(integer)
  OWNER TO sxfakt;

















-- View: wmsorder2
-- DROP VIEW wmsorder2;
CREATE OR REPLACE VIEW wmsorder2 AS 
 SELECT 'AB-'::text || order2.ordernr AS wmsordernr,
    order2.ordernr AS orgordernr,
    order2.pos,
    order2.prisnr,
    order2.dellev,
    order2.artnr::varchar,
    order2.namn::varchar,
    order2.levnr::varchar,
    order2.best,
    order2.rab,
    order2.lev,
    order2.text::varchar,
    order2.pris,
    order2.summa,
    order2.konto::varchar,
    order2.netto,
    order2.enh::varchar,
    order2.levdat,
    order2.utskrivendatum,
    order2.utskriventid,
    order2.stjid
   FROM order2
UNION ALL
 SELECT 'AS-'::text || order2.ordernr AS wmsordernr,
    order2.ordernr AS orgordernr,
    order2.pos,
    order2.prisnr,
    order2.dellev,
    order2.artnr::varchar,
    order2.namn::varchar,
    order2.levnr,
    order2.best,
    order2.rab,
    order2.lev,
    order2.text::varchar,
    order2.pris,
    order2.summa,
    order2.konto::varchar,
    order2.netto,
    order2.enh::varchar,
    order2.levdat,
    order2.utskrivendatum,
    order2.utskriventid,
    order2.stjid
   FROM sxasfakt.order2
UNION ALL
 SELECT 'IN-'::text || id AS wmsordernr,
    id AS orgordernr,
    rad as pos,  
    null as prisnr,
    null as dellev,
    artnr as artnr,
    artnamn as namn,
    null as levnr,
    antal as best,
    null as rab,
    antal as lev,
    null as text,
    null as pris,
    null as summa,
    null as konto,
    null as netto,
    enh as enh,
    null as levdat,
    null as utskrivendatum,
    null as utskriventid,
    stjid as stjid
   FROM sxfakt.INLEV2
UNION ALL
 SELECT 'BE-'::text || bestnr AS wmsordernr,
    bestnr AS orgordernr,
    rad as pos,  
    null as prisnr,
    null as dellev,
    artnr as artnr,
    artnamn as namn,
    null as levnr,
    best as best, 
    null as rab,
    best as lev,
    null as text,
    null as pris,
    null as summa,
    null as konto,
    null as netto,
    enh as enh,
    null as levdat,
    null as utskrivendatum,
    null as utskriventid,
    stjid as stjid
   FROM sxfakt.best2
   ;

ALTER TABLE wmsorder2
  OWNER TO sxfakt;






















-- View: wmsorder1

-- DROP VIEW wmsorder1;

CREATE OR REPLACE VIEW wmsorder1 AS 
 SELECT 'AB-'::text || order1.ordernr AS wmsordernr,
    order1.ordernr AS orgordernr,
    order1.dellev,
    order1.namn,
    order1.adr1,
    order1.adr2,
    order1.adr3,
    order1.levadr1,
    order1.levadr2,
    order1.levadr3,
    order1.saljare,
    order1.referens,
    order1.kundnr,
    order1.marke,
    order1.datum,
    order1.moms,
    order1.status,
    order1.ktid,
    order1.bonus,
    order1.faktor,
    order1.levdat,
    order1.levvillkor,
    order1.mottagarfrakt,
    order1.fraktkundnr,
    order1.fraktbolag,
    order1.fraktfrigrans,
    order1.lagernr,
    order1.direktlevnr,
    order1.returorder,
    order1.lastav,
    order1.lastdatum,
    order1.lasttid,
    order1.tid,
    order1.veckolevdag,
    order1.doljdatum,
    order1.tillannanfilial,
    order1.utlevbokad,
    order1.annanlevadress,
    order1.ordermeddelande,
    order1.tidigastfaktdatum,
    order1.wordernr,
    order1.linjenr1,
    order1.linjenr2,
    order1.linjenr3,
    order1.kundordernr,
    order1.forskatt,
    order1.forskattbetald,
    order1.betalsatt
   FROM order1
UNION ALL
 SELECT 'AS-'::text || order1.ordernr AS wmsordernr,
    order1.ordernr AS orgordernr,
    order1.dellev,
    order1.namn,
    order1.adr1,
    order1.adr2,
    order1.adr3,
    order1.levadr1,
    order1.levadr2,
    order1.levadr3,
    order1.saljare,
    order1.referens,
    order1.kundnr,
    order1.marke,
    order1.datum,
    order1.moms,
    order1.status,
    order1.ktid,
    order1.bonus,
    order1.faktor,
    order1.levdat,
    order1.levvillkor,
    order1.mottagarfrakt,
    order1.fraktkundnr,
    order1.fraktbolag,
    order1.fraktfrigrans,
    order1.lagernr,
    order1.direktlevnr,
    order1.returorder,
    order1.lastav,
    order1.lastdatum,
    order1.lasttid,
    order1.tid,
    order1.veckolevdag,
    order1.doljdatum,
    order1.tillannanfilial,
    order1.utlevbokad,
    order1.annanlevadress,
    order1.ordermeddelande,
    order1.tidigastfaktdatum,
    order1.wordernr,
    order1.linjenr1,
    order1.linjenr2,
    order1.linjenr3,
    order1.kundordernr,
    order1.forskatt,
    order1.forskattbetald,
    order1.betalsatt
   FROM sxasfakt.order1
UNION ALL
 SELECT 'IN-'::text || i1.id AS wmsordernr,
    i1.id AS orgordernr,
    NULL::smallint AS dellev,
    i1.levnamn AS namn,
    NULL::character varying AS adr1,
    NULL::character varying AS adr2,
    NULL::character varying AS adr3,
    (i1.levadr0::text || ' '::text) || i1.levadr1::text AS levadr1,
    i1.levadr2,
    i1.levadr3,
    NULL::character varying AS saljare,
    NULL::character varying AS referens,
    i1.levnr AS kundnr,
    i1.marke,
    i1.datum,
    NULL::smallint AS moms,
    'Sparad'  AS status,
    NULL::smallint AS ktid,
    NULL::smallint AS bonus,
    NULL::smallint AS faktor,
    NULL::date AS levdat,
    NULL::character varying AS levvillkor,
    NULL::smallint AS mottagarfrakt,
    NULL::character varying AS fraktkundnr,
    NULL::character varying AS fraktbolag,
    NULL::real AS fraktfrigrans,
    i1.lagernr,
    NULL::integer AS direktlevnr,
    NULL::smallint AS returorder,
    NULL::character varying AS lastav,
    NULL::date AS lastdatum,
    NULL::time without time zone AS lasttid,
    NULL::time without time zone AS tid,
    NULL::smallint AS veckolevdag,
    NULL::date AS doljdatum,
    NULL::smallint AS tillannanfilial,
    NULL::smallint AS utlevbokad,
    NULL::smallint AS annanlevadress,
    NULL::character varying AS ordermeddelande,
    NULL::date AS tidigastfaktdatum,
    NULL::integer AS wordernr,
    NULL::character varying AS linjenr1,
    NULL::character varying AS linjenr2,
    NULL::character varying AS linjenr3,
    NULL::integer AS kundordernr,
    NULL::smallint AS forskatt,
    NULL::smallint AS forskattbetald,
    NULL::character varying AS betalsatt
   FROM inlev1 i1
UNION ALL
 SELECT 'BE-'::text || b1.bestnr AS wmsordernr,
    b1.bestnr AS orgordernr,
    NULL::smallint AS dellev,
    b1.levnamn AS namn,
    NULL::character varying AS adr1,
    NULL::character varying AS adr2,
    NULL::character varying AS adr3,
    (b1.levadr0::text || ' '::text) || b1.levadr1::text AS levadr1,
    b1.levadr2,
    b1.levadr3,
    NULL::character varying AS saljare,
    NULL::character varying AS referens,
    b1.levnr AS kundnr,
    b1.marke,
    b1.datum,
    NULL::smallint AS moms,
    'Sparad' AS status,
    NULL::smallint AS ktid,
    NULL::smallint AS bonus,
    NULL::smallint AS faktor,
    NULL::date AS levdat,
    NULL::character varying AS levvillkor,
    NULL::smallint AS mottagarfrakt,
    NULL::character varying AS fraktkundnr,
    NULL::character varying AS fraktbolag,
    NULL::real AS fraktfrigrans,
    b1.lagernr,
    NULL::integer AS direktlevnr,
    NULL::smallint AS returorder,
    NULL::character varying AS lastav,
    NULL::date AS lastdatum,
    NULL::time without time zone AS lasttid,
    NULL::time without time zone AS tid,
    NULL::smallint AS veckolevdag,
    NULL::date AS doljdatum,
    NULL::smallint AS tillannanfilial,
    NULL::smallint AS utlevbokad,
    NULL::smallint AS annanlevadress,
    NULL::character varying AS ordermeddelande,
    NULL::date AS tidigastfaktdatum,
    NULL::integer AS wordernr,
    NULL::character varying AS linjenr1,
    NULL::character varying AS linjenr2,
    NULL::character varying AS linjenr3,
    NULL::integer AS kundordernr,
    NULL::smallint AS forskatt,
    NULL::smallint AS forskattbetald,
    NULL::character varying AS betalsatt
   FROM best1 b1;

ALTER TABLE wmsorder1
  OWNER TO sxfakt;
