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
if line-counter( OutStream ) > page-size( OutStream ) then DO: display STREAM OutStream with frame top-frame. end.
p = p + 1.
&if trim("{3}") <> "" &Then  if use-column[1] then  c-s-bar-code:screen-value        = {3}. &endif
&if trim("{4}") <> "" &Then  if use-column[2] then  c-gds-zap-artic:screen-value     = {4}. &endif
&if trim("{5}") <> "" &Then  if use-column[3] then  c-gds-zap-gds-name:screen-value  = {5}. &endif
&if trim("{6}") <> "" &Then  if use-column[4] then  c-gds-zap-unit-base:screen-value = {6}. &endif
&if trim("{1}") <> "" &Then  if use-column[5] then  c-gds-type:screen-value          = {1}. &endif
&if "{2}" = "1" &Then  if use-column[21] then C-oborot-{&bef-disc}:screen-value  = string( {7}oborot-{&bef-disc} [1]) .
&endif
&if "{2}" = "1" &Then  if use-column[23] then C-oborot-{&bef-eff}:screen-value  = string( {7}oborot-{&bef-eff} [1]) .
&endif
&if "{2}" = "1" &Then  if use-column[24] then C-oborot-{&bef-prc}:screen-value  = string( {7}oborot-{&bef-prc} [1]) .
&endif
if use-column[6]  then C-ostatok-start:screen-value                          = if x-vat then  string( {7}ostatok-start  [{2}]                         ) else  string( {7}ostatok-start  [{2}]                        - {7}ostatok-start  [3]                       )  .
if use-column[7]  then C-oborot-{&bef-TDEDT_Pri_Vnesh}:screen-value          = if x-vat then  string( {7}oborot-{&bef-TDEDT_Pri_Vnesh} [{2}]          ) else  string( {7}oborot-{&bef-TDEDT_Pri_Vnesh} [{2}]         - {7}oborot-{&bef-TDEDT_Pri_Vnesh} [3]        )  .
if use-column[8]  then C-oborot-{&bef-TDEDT_Pri_Perem}:screen-value          = if x-vat then  string( {7}oborot-{&bef-TDEDT_Pri_Perem} [{2}]          ) else  string( {7}oborot-{&bef-TDEDT_Pri_Perem} [{2}]         - {7}oborot-{&bef-TDEDT_Pri_Perem} [3]        )  .
if use-column[9]  then C-oborot-{&bef-TDEDT_Pri_Prvo}:screen-value           = if x-vat then  string( {7}oborot-{&bef-TDEDT_Pri_Prvo}  [{2}]          ) else  string( {7}oborot-{&bef-TDEDT_Pri_Prvo}  [{2}]         - {7}oborot-{&bef-TDEDT_Pri_Prvo}  [3]        )  .
if use-column[10] then C-oborot-{&bef-TDEDT_Ras_Vnesh}:screen-value          = if x-vat then  string( {7}oborot-{&bef-TDEDT_Ras_Vnesh} [{2}]          ) else  string( {7}oborot-{&bef-TDEDT_Ras_Vnesh} [{2}]         - {7}oborot-{&bef-TDEDT_Ras_Vnesh} [3]        )  .
if use-column[11] then C-oborot-{&bef-TDEDT_Ras_Perem}:screen-value          = if x-vat then  string( {7}oborot-{&bef-TDEDT_Ras_Perem} [{2}]          ) else  string( {7}oborot-{&bef-TDEDT_Ras_Perem} [{2}]         - {7}oborot-{&bef-TDEDT_Ras_Perem} [3]        )  .
if use-column[12] then C-oborot-{&bef-TDEDT_Ras_Prvo}:screen-value           = if x-vat then  string( {7}oborot-{&bef-TDEDT_Ras_Prvo}  [{2}]          ) else  string( {7}oborot-{&bef-TDEDT_Ras_Prvo}  [{2}]         - {7}oborot-{&bef-TDEDT_Ras_Prvo}  [3]        )  .
if use-column[13] then C-oborot-{&bef-TDEDT_Spi_Vnesh}:screen-value          = if x-vat then  string( {7}oborot-{&bef-TDEDT_Spi_Vnesh}         [{2}]  ) else  string( {7}oborot-{&bef-TDEDT_Spi_Vnesh}         [{2}] - {7}oborot-{&bef-TDEDT_Spi_Vnesh}         [3])  .
if use-column[14] then C-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}:screen-value     = if x-vat then  string( {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [{2}]  ) else  string( {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [{2}] - {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [3])  .
if use-column[15] then C-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}:screen-value = if x-vat then  string( {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[{2}]  ) else  string( {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[{2}] - {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[3])  .
if use-column[16] then C-oborot-{&bef-TDEDT_Vozvrat_Vnesh}:screen-value      = if x-vat then  string( {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [{2}]  ) else  string( {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [{2}] - {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [3])  .
if use-column[17] then C-oborot-{&bef-TDEDT_RAS_Vnesh_VP}:screen-value       = if x-vat then  string( {7}oborot-{&bef-TDEDT_RAS_Vnesh_VP}      [{2}]  ) else  string( {7}oborot-{&bef-TDEDT_RAS_Vnesh_VP}      [{2}] - {7}oborot-{&bef-TDEDT_RAS_Vnesh_VP}      [3])  .
if use-column[18] then C-oborot-{&bef-TDEDT_Vozvrat_Perem}:screen-value      = if x-vat then  string( {7}oborot-{&bef-TDEDT_Vozvrat_Perem}     [{2}]  ) else  string( {7}oborot-{&bef-TDEDT_Vozvrat_Perem}     [{2}] - {7}oborot-{&bef-TDEDT_Vozvrat_Perem}     [3])  .
if use-column[19] then C-oborot-{&bef-TDEDT_Inv}:screen-value                = if x-vat then  string( {7}oborot-{&bef-TDEDT_Inv}               [{2}]  ) else  string( {7}oborot-{&bef-TDEDT_Inv}               [{2}] - {7}oborot-{&bef-TDEDT_Inv}               [3])  .
if use-column[20] then C-oborot-{&bef-TDEDT_Overturn}:screen-value           = if x-vat then  string( {7}oborot-{&bef-TDEDT_Overturn}          [{2}]  ) else  string( {7}oborot-{&bef-TDEDT_Overturn}          [{2}] - {7}oborot-{&bef-TDEDT_Overturn}          [3])  .
if use-column[22] then C-ostatok-end:screen-value                            = if x-vat then  string( {7}ostatok-end                           [{2}]  ) else  string( {7}ostatok-end                           [{2}] - {7}ostatok-end                           [3])  .
if use-column[25] then C-oborot-{&bef-TDEDT_Corr_Acc_Price}:screen-value     = if x-vat then  string( {7}oborot-{&bef-TDEDT_Corr_Acc_Price}    [{2}])   else  string( {7}oborot-{&bef-TDEDT_Corr_Acc_Price} [{2}]    - {7}oborot-{&bef-TDEDT_Corr_Acc_Price} [3]   )  .
if use-column[26] then C-oborot-{&bef-TDEDT_Chg_Purch_Code}:screen-value     = if x-vat then  string( {7}oborot-{&bef-TDEDT_Chg_Purch_Code}    [{2}])   else  string( {7}oborot-{&bef-TDEDT_Chg_Purch_Code} [{2}]    - {7}oborot-{&bef-TDEDT_Chg_Purch_Code} [3]   )  .
if use-column[27] then C-oborot-r-v:screen-value                             = if x-vat then  string(
                                                                                        {7}oborot-{&bef-TDEDT_Ras_Vnesh}         [{2}] +
                                                                                        {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [{2}] +
                                                                                        {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [{2}] +
                                                                                        {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[{2}]
                                                                                        )
                                                                                         else  string(
                                                                                       ({7}oborot-{&bef-TDEDT_Ras_Vnesh}         [{2}] +
                                                                                        {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [{2}] +
                                                                                        {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [{2}] +
                                                                                        {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[{2}]) -
                                                                                       ({7}oborot-{&bef-TDEDT_Ras_Vnesh}         [3] +
                                                                                        {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [3] +
                                                                                        {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [3] +
                                                                                        {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[3] )
                                                                                         ).
DISPLAY stream OutStream {&WFz}.  {&FRAME-d}.
/* $Workfile$   E n d */