# Exemple avec un coefficien géographique de 25% (1.25)

create table valorisation_rsa_2004 as
select ghm_mis, rsa,
tarifghs*1.25 as valo_ghs,
tarifghs*1.25*inferieur_bornebasse*0.5 as valo_exb,
tarifexh*1.25*depassement_bornehaute as valo_exh,
duree_rea*932.62*1.25 as supp_rea,
nbr_actes_dialyse::int*428.05*1.25 as actes_dialyse,
nbr_actes_ghm_24z05z*604.42*1.25 as actes_ghm24z05z,
nbr_actes_ghm_24z06z*202.7*1.25 as actes_ghm24z06z,
nbr_actes_ghm_24z07z*166.06*1.25 as actes_ghm24z07z
from rsa_2004, tarifs
where tarifs.ghs=rsa_2004.ghs::smallint and datefin>date(annee_sortie||' '||mois_sortie|| ' 01') and datedebut<=date(annee_sortie||' '||mois_sortie|| ' 01');

select sum(valo_ghs+valo_exh-valo_exb+supp_rea+actes_dialyse+actes_ghm24z05z+actes_ghm24z06z+actes_ghm24z07z) from valorisation_rsa_2004;

select sum(valo_ghs) as valo_ghs, sum(valo_exh) as valo_exh, sum(valo_exb) as valo_exb, sum(supp_rea) as supp_rea, sum(actes_dialyse) as actes_dialyse, sum(actes_ghm24z05z) as actes_ghm24z05z, sum(actes_ghm24z06z) as actes_ghm24z06z, sum(actes_ghm24z07z) as ghm24z07z from valorisation_rsa_2004;

