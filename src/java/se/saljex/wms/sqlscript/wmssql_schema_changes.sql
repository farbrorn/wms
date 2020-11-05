alter table order2 add column wmslock timestamp default null;
create or replace function wms_order2_wmslock_raiseexception() returns trigger as  $$ begin raise exception 'Ordern % är överförd till wms-system och kan inte ändras utan att den frigörs från wms-systemet.', OLD.ordernr; end $$ language plpgsql;
create trigger order2_wmslock_check before update of artnr, namn, best, pos, ordernr or delete on order2 
	for each row when (OLD.wmslock is not null) execute procedure wms_order2_wmslock_raiseexception();
alter table order2 add column hindrarestorder boolean ;



CREATE OR REPLACE FUNCTION orderaddrow(
    in_anvandare character varying,
    in_ordernr integer,
    in_artnr character varying,
    in_antal real,
    in_pris real default null,
    in_rab real default null)
  RETURNS integer AS
$BODY$
declare
	this_lagernr integer;
        this_pos integer;
begin
	if not exists (select from order1 where ordernr=in_ordernr) then raise exception 'Ordernummer % saknas', in_ordernr; end if;
	
	if not exists (select from saljare where forkortning=in_anvandare or in_anvandare='00') then raise exception 'Användare % saknas', in_anvandare; end if;
	if not exists (select from artikel where nummer = in_artnr) then raise exception 'Artikel % finns inte', in_artnr; end if;
	if in_antal is null then raise exception 'Antal för artikel % är null', in_artnr; end if;
	
	select into this_lagernr lagernr from order1 where ordernr=in_ordernr;
	
	insert into orderhand (ordernr, datum, tid, anvandare, handelse, nyordernr, antalkolli, totalvikt) 
		values (in_ordernr, current_date, current_time, in_anvandare, 'Ny rad', 0, 0, 0); 

        select into this_pos coalesce(max(pos),0)+1 from order2 where ordernr=in_ordernr;
	insert into order2 (ordernr, pos, prisnr, dellev, artnr, namn, levnr, best, lev, pris, rab, summa, konto, netto, enh, stjid)
		select o1.ordernr, this_pos , 1, 1, a.nummer, a.namn, a.lev, in_antal , in_antal, 
		case when in_pris is not null then in_pris else least (
			case when kn.kundnetto_staf2>0 then  kn.kundnetto_staf2 else a.utpris end, 
			case when kn.kundnetto_staf1>0 then  kn.kundnetto_staf1 else a.utpris end,
			kn.kundnetto_bas
		) end,
		coalesce(in_rab,0), 
		
		case when in_pris is not null then in_pris else least (
			case when kn.kundnetto_staf2>0 then  kn.kundnetto_staf2 else a.utpris end, 
			case when kn.kundnetto_staf1>0 then  kn.kundnetto_staf1 else a.utpris end,
			kn.kundnetto_bas
		) end * in_antal *(1-coalesce(in_rab,0)/100), 
		
		konto, a.getinnetto, enhet, 0
		from artikel A JOIN order1 o1 on o1.ordernr=in_ordernr join kundnetto kn on kn.artnr=a.nummer and kn.kundnr=o1.kundnr 
		where a.nummer=in_artnr;
		
	if not exists (select from lager where artnr = in_artnr and lagernr = this_lagernr) then 
		insert into lager (artnr, lagernr, ilager, bestpunkt, maxlager, best, iorder, hindrafilialbest) 
			values (in_artnr, this_lagernr, 0,0,0,0,0,0); 
	end if;
	update lager set iorder=iorder+in_antal where artnr=in_artnr and lagernr=this_lagernr;
        return this_pos;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


grant all on function orderaddrow (character varying,
    integer,
    character varying,
    real,
    real ,
    real )
 to sxfakt;








