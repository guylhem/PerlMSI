create table valorisation_rsa_2006 as select rsa, ghs,
supplements.datedebut, supplements.datefin,
supplements.rea*supplement_rea*1.25 as valo_rea,
supplements.sra*supplement_rea*1.25 as valo_sra,
supplements.sirea*supplement_si_de_rea*1.25 as valo_si_de_rea,
supplements.stf*supplement_stf*1.25 as valo_stf,
supplements.src*supplement_src*1.25 as valo_src,
supplements.nn1*supplement_nn1*1.25 as valo_nn1,
supplements.nn2*supplement_nn2*1.25 as valo_nn2,
supplements.nn3*supplement_nn3*1.25 as valo_nn3
from
(select datedebut, datefin,
 max(case when type='REA' then valeur else null end) as rea,
 max(case when type='SRA' then valeur else null end) as sra,
 max(case when type='STF' then valeur else null end) as sirea,
 max(case when type='STF' then valeur else null end) as stf,
 max(case when type='SRC' then valeur else null end) as src,
 max(case when type='NN1' then valeur else null end) as nn1,
 max(case when type='NN2' then valeur else null end) as nn2,
 max(case when type='NN3' then valeur else null end) as nn3
 from supplements
 group by datedebut, datefin)
as supplements,
rsa_2006 where supplements.datefin>date(annee_sortie||'
'||mois_sortie|| ' 01') and supplements.datedebut<=date(annee_sortie||'
'||mois_sortie|| ' 01') order by rsa desc;

select sum(valo_ghs-valo_exb+valo_exh+supp_rea+supp_sirea+supp_stf+supp_src+supp_ssc+supp_nn1+supp_nn2+supp_nn3+supp_sireasupp_po+actes_ghm24z05z+actes_ghm24z06z+actes_ghm24z07z) from valorisation_rsa_2006;

select sum(valo_ghs) as valo_ghs, sum(valo_exb) as valo_exb, sum(valo_exh) as valo_exh, sum(supp_rea) as supp_rea, sum(supp_sirea) as supp_sirea, sum(supp_stf) as supp_stf, sum(supp_src) as supp_src, sum(supp_ssc) as supp_ssc, sum(supp_nn1) as supp_nn1, sum(supp_nn2) as supp_nn2, sum(supp_nn3) as supp_nn3, sum(supp_po) as supp_po, sum(actes_ghm24z05z) as actes_ghm24z05z, sum(actes_ghm24z06z) as actes_ghm24z06z, sum(actes_ghm24z07z) as actes_ghm24z07z from valorisation_rsa_2006;
