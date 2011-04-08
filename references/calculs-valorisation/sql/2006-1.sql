# Exemple avec un coefficien géographique de 25% (1.25)

create table valorisation_rsa_2006 as
select ghm_mis, rsa,
base.tarifghs*1.25 as valo_ghs,
base.tarifghs*1.25*inferieur_bornebasse*0.5 as valo_exb,
base.tarifexh*1.25*depassement_bornehaute as valo_exh,
supplement_sra*1.25*sra.valeur as supp_sra,
supplement_rea*1.25*rea.valeur as supp_rea,
supplement_si_de_rea*1.25*stf.valeur as supp_sirea,
supplement_stf*1.25*stf.valeur as supp_stf,
supplement_ssc*1.25*ssc.valeur as supp_ssc,
supplement_src*1.25*src.valeur as supp_src,
supplement_nn1*1.25*nn1.valeur as supp_nn1,
supplement_nn2*1.25*nn2.valeur as supp_nn2,
supplement_nn3*1.25*nn3.valeur as supp_nn3,
type_prelevement_organe*1.25*7243 as supp_po,
nbr_actes_ghm_24z05z_ou_28z11z*g511.tarifghs*1.25 as actes_g511,
nbr_actes_ghm_24z06z_ou_28z12z*g612.tarifghs*1.25 as actes_g612,
nbr_actes_ghm_24z07z_ou_28z13z*g713.tarifghs*1.25 as actes_g713
from rsa_2006, tarifs base, supplements sra, supplements rea, supplements stf, supplements ssc, supplements src, supplements nn1, supplements nn2, supplements nn3, tarifs g511, tarifs g612, tarifs g713
where base.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and base.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and base.ghs=rsa_2006.ghs::smallint and 
sra.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and sra.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and sra.type='SRA' and
rea.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and rea.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and rea.type='REA' and
stf.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and stf.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and stf.type='STF' and
ssc.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and ssc.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and ssc.type='SSC' and
src.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and src.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and src.type='SRC' and
nn1.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and nn1.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and nn1.type='NN1' and
nn2.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and nn2.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and nn2.type='NN2' and
nn3.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and nn3.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and nn3.type='NN3' and
g511.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and g511.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and (g511.ghs=8303 or g511.ghs=9510) and
g612.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and g612.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and (g612.ghs=8304 or g612.ghs=9511) and
g713.datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and g713.datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01') and (g713.ghs=8305 or g713.ghs=9512);

select sum(valo_ghs-valo_exb+valo_exh+supp_rea+supp_sirea+supp_stf+supp_src+supp_ssc+supp_nn1+supp_nn2+supp_nn3+supp_sireasupp_po+actes_ghm24z05z+actes_ghm24z06z+actes_ghm24z07z) from valorisation_rsa_2006;

select sum(valo_ghs) as valo_ghs, sum(valo_exb) as valo_exb, sum(valo_exh) as valo_exh, sum(supp_rea) as supp_rea, sum(supp_sirea) as supp_sirea, sum(supp_stf) as supp_stf, sum(supp_src) as supp_src, sum(supp_ssc) as supp_ssc, sum(supp_nn1) as supp_nn1, sum(supp_nn2) as supp_nn2, sum(supp_nn3) as supp_nn3, sum(supp_po) as supp_po, sum(actes_ghm24z05z) as actes_ghm24z05z, sum(actes_ghm24z06z) as actes_ghm24z06z, sum(actes_ghm24z07z) as actes_ghm24z07z from valorisation_rsa_2006;

