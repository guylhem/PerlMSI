create table valorisation_rsa_2008_cpam as 

select
rsa_2008.ghm_mis, rsa_2008.rsa,
base.tarifghs*1.25 as valo_ghs,
inferieur_bornebasse*0.5*base.tarifghs*1.25 as valo_exb,
depassement_bornehaute*base.tarifexh*1.25 as valo_exh,
supplement_rea*sup.rea*1.25 as valo_rea,
supplement_si_de_rea*sup.sirea*1.25 as valo_si_de_rea,
supplement_stf*sup.stf*1.25 as valo_stf,
supplement_src*sup.src*1.25 as valo_src,
supplement_nn1*sup.nn1*1.25 as valo_nn1,
supplement_nn2*sup.nn2*1.25 as valo_nn2,
supplement_nn3*sup.nn3*1.25 as valo_nn3,
supplement_rep*sup.rep*1.25 as valo_rep,
type_prelevement_organe*(case when mois_sortie<3 then 7947 else 7283 end)*1.25 as valo_po1,
nbr_actes_ghs_9510*ghs_9510*1.25 as valo_9510,
nbr_actes_ghs_9511*ghs_9511*1.25 as valo_9511,
nbr_actes_ghs_9512*ghs_9512*1.25 as valo_9512,
supplement_caisson_hyperbare*ghs_9514*1.25 as valo_9514,
nbr_actes_ghs_9515*ghs_9515*1.25 as valo_9515,
nbr_actes_ghs_9524*ghs_9524*1.25 as valo_9524
from
(select datedebut, datefin,
 max(case when type='REA' then valeur else null end) as rea,
 max(case when type='STF' then valeur else null end) as sirea,
 max(case when type='STF' then valeur else null end) as stf,
 max(case when type='SRC' then valeur else null end) as src,
 max(case when type='NN1' then valeur else null end) as nn1,
 max(case when type='NN2' then valeur else null end) as nn2,
 max(case when type='NN3' then valeur else null end) as nn3,
 max(case when type='REP' then valeur else null end) as rep
 from supplements
 group by datedebut, datefin)
as sup,
(select datedebut, datefin, ghs_9510, ghs_9511, ghs_9512, ghs_9514, ghs_9515, ghs_9524 from (
 select datedebut, datefin,
  max(case when ghs=9510 then tarifghs else null end) as ghs_9510,
  max(case when ghs=9511 then tarifghs else null end) as ghs_9511,
  max(case when ghs=9512 then tarifghs else null end) as ghs_9512,
  max(case when ghs=9514 then tarifghs else null end) as ghs_9514,
  max(case when ghs=9515 then tarifghs else null end) as ghs_9515,
  max(case when ghs=9524 then tarifghs else null end) as ghs_9524
  from a_tarif	
  group by datedebut, datefin
 ) as ghs where ghs_9514 is not null or ghs_9511 is not null or ghs_9515 is not null or ghs_9524 is not null)
 as ghs,
 rsa_2008, rssrsa_2008, a_tarif base
where
 base.ghs=rsa_2008.ghs::smallint and
 base.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and base.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and
 rsa_2008.rsa=rssrsa_2008.rsa and rssrsa_2008.rss not in (select * from zz_anohosp_pascpam08) and
 sup.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and sup.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and
 ghs.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and ghs.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01')
order by rsa desc;


select sum (valo_po1) as po1, sum (valo_9510) asg9510, sum(valo_9511) as g9511, sum(valo_9512) as g9512,  sum(valo_9514) as g9514, sum(valo_9515) as g9515, sum(valo_9524) as g9524 from valorisation_rsa_2008_cpam;

# FIXME: pas d'accord sur SRC SIREA STF, attention : po1 doit inclure non cpam</=date(annee_sortie||'>
