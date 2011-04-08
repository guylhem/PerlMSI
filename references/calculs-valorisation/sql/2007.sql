
fonction ghm-> ghs

pour un rss si ghm=23Z02Z : si une des uf=3144  alors ghs=7957 sinon ghs=7956

271103Z 

À IMPLÉMENTER




fonction duree_jo  : cf tableau

extract (day from date_fin_hospit-date_debut_hospit)
  case when sortie=9 and duree>0 :duree+1
  sinon =1


si duree>bornehaute alors valeurtot=tarifghs+tarifexh*(duree-bornehaute)
si duree<bornebasse alors
  si sortie=9 alors tarifsghs;
  sinon sortie!=9 alors tarifghs/2

vérifier que si tarif ghs pas das tarif_jo (ex: ghm 90H0!{2,3}Z)  ou ivg 24Z15Z)

du


SELECT valo07.rss, duree, tarif_jo.ghm, tarif_jo.ghs, tarif_jo.tarifghs, tarif_jo.tarifexh, tarif_jo.bornebasse, tarif_jo.bornehaute, case when (duree>tarif_jo.bornehaute) then tarif_jo.tarifghs+tarif_jo.tarifexh*(duree-tarif_jo.bornehaute) end as tothaut, case when (duree<tarif_jo.bornebasse and sortie=9) then tarif_jo.tarifghs end as totbas, case when (duree<tarif_jo.bornebasse and sortie !=9) then tarif_jo.tarifghs/2 end as totdcd, case when(duree>tarif_jo.bornebasse and duree<tarif_jo.bornehaute) then tarifghs end as totnorm from valo07, tarif_jo where valo07.ghs=tarif_jo.ghs and fin<tarif_jo.datefin and fin>=datedebut;


SELECT valo07.rss,  
case when (duree>tarif_jo.bornehaute) then tarif_jo.tarifghs+tarif_jo.tarifexh*(duree-tarif_jo.bornehaute) end as tothaut, case when (duree<tarif_jo.bornebasse and sortie=9) then tarif_jo.tarifghs end as totbas,
 case when (duree<tarif_jo.bornebasse and sortie !=9) then tarif_jo.tarifghs/2 end as totdcd,
 case when(duree>tarif_jo.bornebasse and duree<tarif_jo.bornehaute) then tarifghs end as totnorm

 from valo07, tarif_jo where valo07.ghs=tarif_jo.ghs and fin<tarif_jo.datefin and fin>=datedebut;


select rss, totnorm+totdcd+tothaut+totbas as total, totnorm, totdcd, tothaut, totbas  from (SELECT valo07.rss,
case when (duree>tarif_jo.bornehaute) then tarif_jo.tarifghs+tarif_jo.tarifexh*(duree-tarif_jo.bornehaute) else 0 end as tothaut, case when (duree<tarif_jo.bornebasse and sortie=9) then tarif_jo.tarifghs else 0 end as totbas,
 case when (duree<tarif_jo.bornebasse and sortie !=9) then tarif_jo.tarifghs/2 else 0 end as totdcd,
 case when(duree>=tarif_jo.bornebasse and duree<=tarif_jo.bornehaute) then tarifghs else 0 end as totnorm
 from valo07, tarif_jo where valo07.ghs=tarif_jo.ghs and fin<tarif_jo.datefin and fin>=datedebut) as totaux;


select rss, uf_nbr, uf, totnorm+totdcd+tothaut+totbas as total, totnorm, totdcd, tothaut, totbas  from (SELECT valo07.rss, unitees as uf_nbr, case when (unitees=1) then unite else 0 end as uf,
case when (duree>tarif_jo.bornehaute) then tarif_jo.tarifghs+tarif_jo.tarifexh*(duree-tarif_jo.bornehaute) else 0 end as tothaut, case when (duree<tarif_jo.bornebasse and sortie=9) then tarif_jo.tarifghs else 0 end as totbas,
 case when (duree<tarif_jo.bornebasse and sortie !=9) then tarif_jo.tarifghs/2 else 0 end as totdcd,
 case when(duree>=tarif_jo.bornebasse and duree<=tarif_jo.bornehaute) then tarifghs else 0 end as totnorm
 from valo07, tarif_jo where valo07.ghs=tarif_jo.ghs and fin<tarif_jo.datefin and fin>=datedebut) as totaux where totdcd>0;


########
create table test_valo as select rss, duree, uf_nbr, uf, totnorm+totdcd+tothaut+totbas as total, totnorm, totdcd, tothaut, totbas  from (SELECT valo07.rss, duree, unitees as uf_nbr, case when (unitees=1) then unite else 0 end as uf, case when (duree>tarif_jo.bornehaute) then tarif_jo.tarifghs+tarif_jo.tarifexh*(duree-tarif_jo.bornehaute) else 0 end as tothaut, case when (duree<tarif_jo.bornebasse and sortie=9) then tarif_jo.tarifghs else 0 end as totdcd,
 case when (duree<tarif_jo.bornebasse and sortie !=9) then tarif_jo.tarifghs/2 else 0 end as totbas,
 case when(duree>=tarif_jo.bornebasse and duree<=tarif_jo.bornehaute) then tarifghs else 0 end as totnorm
 from valo07, tarif_jo where valo07.ghs=tarif_jo.ghs and fin<tarif_jo.datefin and fin>=datedebut) as totaux;

erreur RSS 
377043 : valo à 5402.84 fx 
or erreur : considéré comme 4 états différents - un par uf !!!

faut réécrire cette fonction en utilisant transmis (et année ici 2008 car bug import)
 - > besoin date_debut_hospit
 - > besoin date_fin_hospit
 - > besoin uf_nbr
 - > besoin duree_uf
 - > besoin duree_pmsi


######
create table test_pmj as select uf, sum(total)/sum(duree) as pmj from test_valo where uf_nbr=1 and duree>=2 group by uf order by uf; SELECT

####### fixme: mettre duréee au sens pmsi

select rss, uf, extract (day from date_sortie_uf-date_entree_uf) as duree_rum from transmis where annee=2007;


####### erreur dans transmis à corriger : annee pas vraie lors de import rss

#### fixme très FAUX, non utilisé
select uf, sum(cout_fictif) as cout_fictif_uf, sum(duree_rum) as duree_fictive_uf from (select test_pmj.uf, extract (day from date_sortie_uf-date_entree_uf) as duree_rum, extract (day from date_sortie_uf-date_entree_uf)*pmj as cout_fictif from transmis, test_pmj  where transmis.annee=2007 and transmis.uf=test_pmj.uf group by test_pmj.uf,  date_sortie_uf, date_entree_uf, pmj) as moche group by uf;


#### valo fictive rss
create table valo_fictive_rss as select rss, sum(cout_fictif) from (select rss, test_pmj.uf, extract (day from date_sortie_uf-date_entree_uf) as duree_rum, extract (day from date_sortie_uf-date_entree_uf)*pmj as cout_fictif from transmis, test_pmj  where transmis.annee=2007 and transmis.uf=test_pmj.uf) as test group by rss;

#### valo fictive par uf
create table valo_fictive_uf as select rss, test_pmj.uf, extract (day from date_sortie_uf-date_entree_uf) as duree_rum, extract (day from date_sortie_uf-date_entree_uf)*pmj as cout_fictif from transmis, test_pmj  where transmis.annee=2007 and transmis.uf=test_pmj.uf;

// select valo_fictive_uf.rss, uf, duree_rum, cout_fictif, valo_fictive_rss.sum as total_fictif_rss from valo_fictive_uf, valo_fictive_rss where valo_fictive_rss.rss=valo_fictive_uf.rss

create table test_coeff as select valo_fictive_uf.rss, uf, duree_rum, cout_fictif, valo_fictive_rss.sum as total_fictif_rss, case when cout_fictif>0 then cout_fictif/valo_fictive_rss.sum else 0 end as coeff from valo_fictive_uf, valo_fictive_rss where valo_fictive_rss.rss=valo_fictive_uf.rss;

create table valeur_par_uf as select test_coeff.uf, sum(total*coeff) as valeur from test_coeff, test_valo where test_coeff.rss=test_valo.rss group by test_coeff.uf order by test_coeff.uf;

select sum (valeur) from valeur_par_uf; select sum(total) from test_valo ;
## GRRR !! DEVRAIT TOMBER SUR LE MEME CHIFFRE

422837 = 2007 dams test_valo et valo07
55891 = 2006 dans test_coeff et valo06
