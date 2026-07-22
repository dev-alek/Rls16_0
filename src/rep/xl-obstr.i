/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать строки оборотки в excel

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 08/28/01
*/

if use-column[21] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round({1}oborot-{&bef-Disc} [1],2 ), num#str# , num#col#   ).     end.
if use-column[23] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round({1}oborot-{&bef-eff}  [1],2 ), num#str# , num#col#   ).     end.
if use-column[24] then do: Assign num#col#  = num#col#  + 1.   run macr_excel_dec ( Round({1}oborot-{&bef-prc}  [1],2 ), num#str# , num#col#   ).     end.
def var l-nk as integer no-undo .
  Assign
    LL = 0
    KK = 1
  .
  if xShowCost      Then DO: KK = KK + 1. End.
  if xShowCostNDS   Then DO: KK = KK + 1. End.
  if xShowCrsa      Then DO: KK = KK + 1. End.
  if xShowCrsaNds   Then DO: KK = KK + 1. End.
  if xShowSale      Then DO: KK = KK + 1. End.
  if xShowSaleNds   Then DO: KK = KK + 1. End.
  if xShowSaleslt   Then DO: KK = KK + 1. End.
  if xShowmediator  Then DO: KK = KK + 1. End.
  if x-tog-wt       then do: KK = KK + 1. End.
  if x-tog-ms       then do: KK = KK + 1. End.
  if xDens          then do: KK = KK + 1. End.

  repeat i = 1 to {&e-col} :
    if i = 7 then next.
    if NOT xShowCost      and i = 2   Then  next.
    if NOT xShowCostNDS   and i = 3   Then  next.
    if NOT xShowCrsa      and i = 5   Then  next.
    if NOT xShowCrsaNds   and i = 6   Then  next.
    if NOT xShowSale      and i = 8   Then  next.
    if NOT xShowSaleNds   and i = 9   Then  next.
    if NOT xShowSaleSlt   and i = 10  Then  next.
    if NOT xShowmediator  and i = 4   Then  next.
    if not x-tog-wt       and i = 11  then  next.
    if not x-tog-ms       and i = 12  then  next.
    if not xDens          and i = 13  then  next.
    assign
      LL = LL + 1
      l-nk = mp-1
    .
  if x-vat or i <> 2  then do:
  if use-column[6]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}ostatok-start                          [i] ,  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_pri_vnesh}          [i] ,  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_pri_perem}          [i] ,  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_pri_prvo}           [i] ,  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_ras_vnesh}          [i] ,  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_ras_perem}          [i] ,  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_ras_prvo}           [i] ,  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_spi_vnesh}          [i] ,  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_ras_vnesh_kass}     [i] ,  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass} [i] ,  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_vozvrat_vnesh}      [i] ,  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_ras_vnesh_vp}       [i] ,  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_vozvrat_perem}      [i] ,  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_inv}                [i] ,  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_overturn}           [i] ,  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}ostatok-end                            [i] ,  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_corr_acc_price} [i] ,  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , {1}oborot-{&bef-tdedt_chg_purch_code} [i] ,  i). end.
  if i = 13 then do: /*плотность*/
    if "{1}" = "b1-" or "{1}" = "b2-" or "{1}" = "bi-" or "{1}" = "bo-" then do:
       if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , 0 ,  i). end.
    end.
    else do:
      if use-column[27] then do: l-nk = l-nk + 1 .  run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ( if ABS({1}oborot-{&bef-tdedt_ras_vnesh}         [1] +
                                                                                                                                    {1}oborot-{&bef-tdedt_vozvrat_vnesh}     [1] +
                                                                                                                                    {1}oborot-{&bef-tdedt_ras_vnesh_kass}    [1] +
                                                                                                                                    {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass}[1] ) <> 0
                                                                                                                            then
                                                                                                                                ABS({1}oborot-{&bef-tdedt_ras_vnesh}         [11] +
                                                                                                                                    {1}oborot-{&bef-tdedt_vozvrat_vnesh}     [11] +
                                                                                                                                    {1}oborot-{&bef-tdedt_ras_vnesh_kass}    [11] +
                                                                                                                                    {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass}[11] )
                                                                                                                                /
                                                                                                                                ABS({1}oborot-{&bef-tdedt_ras_vnesh}         [1] +
                                                                                                                                    {1}oborot-{&bef-tdedt_vozvrat_vnesh}     [1] +
                                                                                                                                    {1}oborot-{&bef-tdedt_ras_vnesh_kass}    [1] +
                                                                                                                                    {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass}[1] )
                                                                                                                            else 0 )
      ,  i). end.
    end.
  end.
  else do:
  if use-column[27] then do: l-nk = l-nk + 1 .    run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  , ({1}oborot-{&bef-tdedt_ras_vnesh}         [i] +
                                                                                                                        {1}oborot-{&bef-tdedt_vozvrat_vnesh}     [i] +
                                                                                                                        {1}oborot-{&bef-tdedt_ras_vnesh_kass}    [i] +
                                                                                                                        {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass}[i] )
  ,  i). end.
  end.
  end.
  if x-vat = false  and i = 2 then do:
  if use-column[6]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}ostatok-start                          [i] -  {1}ostatok-start                          [3] ),  i). end.
  if use-column[7]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_pri_vnesh}          [i] -  {1}oborot-{&bef-tdedt_pri_vnesh}          [3] ),  i). end.
  if use-column[8]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_pri_perem}          [i] -  {1}oborot-{&bef-tdedt_pri_perem}          [3] ),  i). end.
  if use-column[9]  then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_pri_prvo}           [i] -  {1}oborot-{&bef-tdedt_pri_prvo}           [3] ),  i). end.
  if use-column[10] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_ras_vnesh}          [i] -  {1}oborot-{&bef-tdedt_ras_vnesh}          [3] ),  i). end.
  if use-column[11] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_ras_perem}          [i] -  {1}oborot-{&bef-tdedt_ras_perem}          [3] ),  i). end.
  if use-column[12] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_ras_prvo}           [i] -  {1}oborot-{&bef-tdedt_ras_prvo}           [3] ),  i). end.
  if use-column[13] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_spi_vnesh}          [i] -  {1}oborot-{&bef-tdedt_spi_vnesh}          [3] ),  i). end.
  if use-column[14] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_ras_vnesh_kass}     [i] -  {1}oborot-{&bef-tdedt_ras_vnesh_kass}     [3] ),  i). end.
  if use-column[15] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass} [i] -  {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass} [3] ),  i). end.
  if use-column[16] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_vozvrat_vnesh}      [i] -  {1}oborot-{&bef-tdedt_vozvrat_vnesh}      [3] ),  i). end.
  if use-column[17] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_ras_vnesh_vp}       [i] -  {1}oborot-{&bef-tdedt_ras_vnesh_vp}       [3] ),  i). end.
  if use-column[18] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_vozvrat_perem}      [i] -  {1}oborot-{&bef-tdedt_vozvrat_perem}      [3] ),  i). end.
  if use-column[19] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_inv}                [i] -  {1}oborot-{&bef-tdedt_inv}                [3] ),  i). end.
  if use-column[20] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_overturn}           [i] -  {1}oborot-{&bef-tdedt_overturn}           [3] ),  i). end.
  if use-column[22] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}ostatok-end                            [i] -  {1}ostatok-end                            [3] ),  i). end.
  if use-column[25] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_corr_acc_price} [i] -  {1}oborot-{&bef-tdedt_corr_acc_price}[3] ),  i). end.
  if use-column[26] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,( {1}oborot-{&bef-tdedt_chg_purch_code} [i] -  {1}oborot-{&bef-tdedt_chg_purch_code}[3] ),  i). end.
  if i = 13 then do : /* плотность */
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure (mp-1 + ll + (kk * (l-nk - mp))  , 0 /* нет веса без НДС */ , i ). end.
  end.
  else do:
    if use-column[27] then do: l-nk = l-nk + 1 . run ex-display in this-procedure  (mp-1 + ll + (kk * (l-nk - mp))  ,
    (                                                                                      ({1}oborot-{&bef-tdedt_ras_vnesh}         [i] +
                                                                                            {1}oborot-{&bef-tdedt_vozvrat_vnesh}     [i] +
                                                                                            {1}oborot-{&bef-tdedt_ras_vnesh_kass}    [i] +
                                                                                            {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass}[i]) -
                                                                                          ({1}oborot-{&bef-tdedt_ras_vnesh}         [3] +
                                                                                            {1}oborot-{&bef-tdedt_vozvrat_vnesh}     [3] +
                                                                                            {1}oborot-{&bef-tdedt_ras_vnesh_kass}    [3] +
                                                                                            {1}oborot-{&bef-tdedt_vozvrat_vnesh_kass}[3] ) ) , i ). end.
  end.
  end.
  end.

 run new-tmp-page .
 /* $Workfile$ e n d */