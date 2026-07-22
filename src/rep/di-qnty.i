/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 08/17/01
Author: Svetlana Chernova
Creation date: 08/17/01

*/

 if line-counter( OutStream )  > page-size( OutStream ) then DO : display STREAM OutStream    with frame top-frame. end.
 /* */
  p = p + 1.
  &if trim("{8}") <> "" &Then  if use-column[28] then c-str-num:screen-value           = &if "{8}" = "0" &then '' &else string( {8} ) &endif . &endif
  &if trim("{3}") <> "" &Then  if use-column[1] then  c-s-bar-code:screen-value        = {3}. &endif
  &if trim("{4}") <> "" &Then  if use-column[2] then  c-gds-zap-artic:screen-value     = {4}. &endif
  &if trim("{5}") <> "" &Then  if use-column[3] then  c-gds-zap-gds-name:screen-value  = {5}. &endif
  &if trim("{6}") <> "" &Then  if use-column[4] then  c-gds-zap-unit-base:screen-value = {6}. &endif
  &if trim("{1}") <> "" &Then  if use-column[5] then  c-gds-type:screen-value          = "{1}"   .   &endif
  &if "{2}" = "1" &Then  if use-column[21] then C-oborot-{&bef-disc}:screen-value  = string( {7}oborot-{&bef-disc} [1]) .
  /* &else */  /* if use-column[21] then assign C-oborot-{&bef-disc}:screen-value  = "" . */
  &endif
  &if "{2}" = "1" &Then  if use-column[23] then C-oborot-{&bef-eff}:screen-value  = string( {7}oborot-{&bef-eff} [1]) .
  &else /*  if use-column[23] then  assign C-oborot-{&bef-eff}:screen-value  = "" . */
  &endif
  &if "{2}" = "1" &Then  if use-column[24] then C-oborot-{&bef-prc}:screen-value  = string( {7}oborot-{&bef-prc} [1]) .
  &else  /* if use-column[24] then  assign C-oborot-{&bef-prc}:screen-value  = "" .     */
  &endif

  if use-column[6]  then C-ostatok-start:screen-value                          = string( {7}ostatok-start  [{2}])                         .
  if use-column[7]  then C-oborot-{&bef-TDEDT_Pri_Vnesh}:screen-value          = string( {7}oborot-{&bef-TDEDT_Pri_Vnesh} [{2}]        )  .
  if use-column[8]  then C-oborot-{&bef-TDEDT_Pri_Perem}:screen-value          = string( {7}oborot-{&bef-TDEDT_Pri_Perem} [{2}]        )  .
  if use-column[9]  then C-oborot-{&bef-TDEDT_Pri_Prvo}:screen-value           = string( {7}oborot-{&bef-TDEDT_Pri_Prvo}  [{2}]        )  .
  if use-column[10] then C-oborot-{&bef-TDEDT_Ras_Vnesh}:screen-value          = string( {7}oborot-{&bef-TDEDT_Ras_Vnesh} [{2}]        )  .
  if use-column[11] then C-oborot-{&bef-TDEDT_Ras_Perem}:screen-value          = string( {7}oborot-{&bef-TDEDT_Ras_Perem} [{2}]        )  .
  if use-column[12] then C-oborot-{&bef-TDEDT_Ras_Prvo}:screen-value           = string( {7}oborot-{&bef-TDEDT_Ras_Prvo}  [{2}]        )  .
  if use-column[13] then C-oborot-{&bef-TDEDT_Spi_Vnesh}:screen-value          = string( {7}oborot-{&bef-TDEDT_Spi_Vnesh}         [{2}])  .
  if use-column[14] then C-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}:screen-value     = string( {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [{2}])  .
  if use-column[15] then C-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}:screen-value = string( {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[{2}])  .
  if use-column[16] then C-oborot-{&bef-TDEDT_Vozvrat_Vnesh}:screen-value      = string( {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [{2}])  .
  if use-column[17] then C-oborot-{&bef-TDEDT_RAS_Vnesh_VP}:screen-value       = string( {7}oborot-{&bef-TDEDT_RAS_Vnesh_VP}      [{2}])  .
  if use-column[18] then C-oborot-{&bef-TDEDT_Vozvrat_Perem}:screen-value      = string( {7}oborot-{&bef-TDEDT_Vozvrat_Perem}     [{2}])  .
  if use-column[19] then C-oborot-{&bef-TDEDT_Inv}:screen-value                = string( {7}oborot-{&bef-TDEDT_Inv}               [{2}])  .
  if use-column[20] then C-oborot-{&bef-TDEDT_Overturn}:screen-value           = string( {7}oborot-{&bef-TDEDT_Overturn}          [{2}])  .
  if use-column[22] then C-ostatok-end:screen-value                            = string( {7}ostatok-end                           [{2}])  .
  if use-column[25] then C-oborot-{&bef-TDEDT_Corr_Acc_Price}:screen-value     = string( {7}oborot-{&bef-TDEDT_Corr_Acc_Price}    [{2}])  .
  if use-column[26] then C-oborot-{&bef-TDEDT_Chg_Purch_Code}:screen-value     = string( {7}oborot-{&bef-TDEDT_Chg_Purch_Code}    [{2}])  .
  if use-column[27] then C-oborot-{&bef-r-v}:screen-value                      = string( {7}oborot-{&bef-TDEDT_Ras_Vnesh}         [{2}] +
                                                                                         {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [{2}] +
                                                                                         {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [{2}] +
                                                                                         {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[{2}] ).
  DISPLAY stream  OutStream  {&WFz} .  {&FRAME-d}.
  /* $Workfile$ e n d */