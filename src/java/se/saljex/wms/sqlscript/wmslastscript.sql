CREATE OR REPLACE FUNCTION wmsorderlasta(
    in_anvandare character varying,
    in_wmsordernr character varying,
    in_antal real default 1)
  RETURNS void AS
$BODY$
begin
	if not exists (select from wmsorder1 where wmsordernr=in_wmsordernr) then raise exception 'Ordernummer % saknas', in_wmsordernr; end if;
	if substring(in_wmsordernr,1,2) = 'AB' then
                insert into sxfakt.orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
                        values (this_ordernr, current_date, current_time, in_anvandare, 'WMS Lastad', 0, in_antal, 0); 
	elsif substring(in_wmsordernr,1,2) = 'AS' then
                insert into sxasfakt.orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
                        values (this_ordernr, current_date, current_time, in_anvandare, 'WMS Lastad', 0, in_antal, 0); 
	end if;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;




CREATE OR REPLACE FUNCTION wmsorderlastaav(
    in_anvandare character varying,
    in_wmsordernr character varying,
    in_antal real default 1)
  RETURNS void AS
$BODY$
begin
	if not exists (select from wmsorder1 where wmsordernr=in_wmsordernr) then raise exception 'Ordernummer % saknas', in_wmsordernr; end if;
	if substring(in_wmsordernr,1,2) = 'AB' then
                insert into sxfakt.orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
                        values (this_ordernr, current_date, current_time, in_anvandare, 'WMS Avlastad', 0, in_antal*-1, 0); 
	elsif substring(in_wmsordernr,1,2) = 'AS' then
                insert into sxasfakt.orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
                        values (this_ordernr, current_date, current_time, in_anvandare, 'WMS Avlastad', 0, in_antal*-1, 0); 
	end if;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;




