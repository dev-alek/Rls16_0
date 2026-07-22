/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
repeat kk = 1 to {&e-col} :
assign
{1}-oborot-{&bef-tdedt_pri_vnesh}         [kk] = 0
{1}-oborot-{&bef-tdedt_ras_vnesh}         [kk] = 0
{1}-oborot-{&bef-tdedt_ras_vnesh_vp}      [kk] = 0
{1}-oborot-{&bef-tdedt_ras_vnesh_kass}    [kk] = 0
{1}-oborot-{&bef-tdedt_vozvrat_vnesh}     [kk] = 0
{1}-oborot-{&bef-tdedt_vozvrat_vnesh_kass} [kk] = 0
{1}-oborot-{&bef-tdedt_spi_vnesh}         [kk] = 0
{1}-oborot-{&bef-tdedt_inv}               [kk] = 0
{1}-oborot-{&bef-tdedt_pri_perem}         [kk] = 0
{1}-oborot-{&bef-tdedt_ras_perem}         [kk] = 0
{1}-oborot-{&bef-tdedt_vozvrat_perem}     [kk] = 0
{1}-oborot-{&bef-tdedt_ras_prvo}          [kk] = 0
{1}-oborot-{&bef-tdedt_spi_prvo}          [kk] = 0
{1}-oborot-{&bef-tdedt_pri_prvo}          [kk] = 0
{1}-oborot-{&bef-tdedt_overturn}          [kk] = 0
{1}-oborot-{&bef-disc}                    [kk] = 0
{1}-oborot-{&bef-eff}                     [kk] = 0
{1}-oborot-{&bef-prc}                     [kk] = 0
{1}-ostatok-end                           [kk] = 0
{1}-ostatok-start                         [kk] = 0
{1}-oborot-sum-sale                       [kk] = 0
{1}-oborot-sum-cost                       [kk] = 0
{1}-oborot-{&bef-tdedt_corr_acc_price} [kk] = 0
{1}-oborot-{&bef-tdedt_chg_purch_code} [kk] = 0
.
end.