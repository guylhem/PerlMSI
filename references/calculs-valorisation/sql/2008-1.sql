create table valorisation_rsa_2008 as 
select rsa, ghs, supplements.datedebut, supplements.datefin,
supplements.rea*supplement_sra*1.25 as valo_sra,
supplements.sirea*supplement_si_de_rea*1.25 as valo_si_de_rea,
supplements.stf*supplement_stf*1.25 as valo_stf,
supplements.src*supplement_src*1.25 as valo_src,
supplements.nn1*supplement_nn1*1.25 as valo_nn1,
supplements.nn2*supplement_nn2*1.25 as valo_nn2,
supplements.nn3*supplement_nn3*1.25 as valo_nn3,
supplements.nn3*supplement_nn3*1.25 as valo_nn3,
supplements.rep*supplement_rep*1.25 as valo_rep
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
as supplements,
rsa_2008 where supplements.datefin>date(annee_sortie||'
'||mois_sortie|| ' 01') and supplements.datedebut<=date(annee_sortie||'
'||mois_sortie|| ' 01') order by rsa desc;

select sum (valo_rea) as rea, sum(valo_sra) as sra, sum(valo_si_de_rea)
+ sum(valo_stf) as sirea_plus_stf, sum (valo_src) as src, sum (valo_nn1)
as nn1, sum (valo_nn2) as nn2, sum (valo_nn3) as nn3, sum (valo_rep) as
rep  from valorisation_rsa_2008;
