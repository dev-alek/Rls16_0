/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать полей количество топлива в кг (аналог  d i - q n t y . i)

Автор: Булгаков Андрей Николаевич
Дата создания: 03/30/05
Author: Andrew Bulgakoff
Creation date: 03/30/05

*/

if line-counter( OutStream ) > page-size( OutStream ) then do: display stream OutStream with frame top-frame. end.
assign p = p + 1.
&if trim( "{3}" ) <> "" &then if use-column[  1 ] = yes then do: assign c-s-bar-code         :screen-value =  {3}.  end. &endif
&if trim( "{4}" ) <> "" &then if use-column[  2 ] = yes then do: assign c-gds-zap-artic      :screen-value =  {4}.  end. &endif
&if trim( "{5}" ) <> "" &then if use-column[  3 ] = yes then do: assign c-gds-zap-gds-name   :screen-value =  {5}.  end. &endif
&if trim( "{6}" ) <> "" &then if use-column[  4 ] = yes then do: assign c-gds-zap-unit-base  :screen-value =  {6}.  end. &endif
&if trim( "{1}" ) <> "" &then if use-column[  5 ] = yes then do: assign c-gds-type           :screen-value = "{1}". end. &endif
&if "{2}" = "1" &then if use-column[ 21 ] = yes then do: assign C-oborot-{&bef-disc} :screen-value = string( {7}oborot-{&bef-disc}[ 11 ] ). end. &endif
&if "{2}" = "1" &then if use-column[ 23 ] = yes then do: assign C-oborot-{&bef-eff}  :screen-value = string( {7}oborot-{&bef-eff} [ 11 ] ). end. &endif
&if "{2}" = "1" &then if use-column[ 24 ] = yes then do: assign C-oborot-{&bef-prc}  :screen-value = string( {7}oborot-{&bef-prc} [ 11 ] ). end. &endif
if use-column[  6 ] = yes then do: assign C-ostatok-start                          :screen-value = string( {7}ostatok-start                         [ {2} ] ). end.
if use-column[  7 ] = yes then do: assign C-oborot-{&bef-TDEDT_Pri_Vnesh}          :screen-value = string( {7}oborot-{&bef-TDEDT_Pri_Vnesh}         [ {2} ] ). end.
if use-column[  8 ] = yes then do: assign C-oborot-{&bef-TDEDT_Pri_Perem}          :screen-value = string( {7}oborot-{&bef-TDEDT_Pri_Perem}         [ {2} ] ). end.
if use-column[  9 ] = yes then do: assign C-oborot-{&bef-TDEDT_Pri_Prvo}           :screen-value = string( {7}oborot-{&bef-TDEDT_Pri_Prvo}          [ {2} ] ). end.
if use-column[ 10 ] = yes then do: assign C-oborot-{&bef-TDEDT_Ras_Vnesh}          :screen-value = string( {7}oborot-{&bef-TDEDT_Ras_Vnesh}         [ {2} ] ). end.
if use-column[ 11 ] = yes then do: assign C-oborot-{&bef-TDEDT_Ras_Perem}          :screen-value = string( {7}oborot-{&bef-TDEDT_Ras_Perem}         [ {2} ] ). end.
if use-column[ 12 ] = yes then do: assign C-oborot-{&bef-TDEDT_Ras_Prvo}           :screen-value = string( {7}oborot-{&bef-TDEDT_Ras_Prvo}          [ {2} ] ). end.
if use-column[ 13 ] = yes then do: assign C-oborot-{&bef-TDEDT_Spi_Vnesh}          :screen-value = string( {7}oborot-{&bef-TDEDT_Spi_Vnesh}         [ {2} ] ). end.
if use-column[ 14 ] = yes then do: assign C-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}     :screen-value = string( {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [ {2} ] ). end.
if use-column[ 15 ] = yes then do: assign C-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass} :screen-value = string( {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ {2} ] ). end.
if use-column[ 16 ] = yes then do: assign C-oborot-{&bef-TDEDT_Vozvrat_Vnesh}      :screen-value = string( {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [ {2} ] ). end.
if use-column[ 17 ] = yes then do: assign C-oborot-{&bef-TDEDT_RAS_Vnesh_VP}       :screen-value = string( {7}oborot-{&bef-TDEDT_RAS_Vnesh_VP}      [ {2} ] ). end.
if use-column[ 18 ] = yes then do: assign C-oborot-{&bef-TDEDT_Vozvrat_Perem}      :screen-value = string( {7}oborot-{&bef-TDEDT_Vozvrat_Perem}     [ {2} ] ). end.
if use-column[ 19 ] = yes then do: assign C-oborot-{&bef-TDEDT_Inv}                :screen-value = string( {7}oborot-{&bef-TDEDT_Inv}               [ {2} ] ). end.
if use-column[ 20 ] = yes then do: assign C-oborot-{&bef-TDEDT_Overturn}           :screen-value = string( {7}oborot-{&bef-TDEDT_Overturn}          [ {2} ] ). end.
if use-column[ 22 ] = yes then do: assign C-ostatok-end                            :screen-value = string( {7}ostatok-end                           [ {2} ] ). end.
if use-column[ 25 ] = yes then do: assign C-oborot-{&bef-TDEDT_Corr_Acc_Price}     :screen-value = string( {7}oborot-{&bef-TDEDT_Corr_Acc_Price}    [ {2} ] ). end.
if use-column[ 26 ] = yes then do: assign C-oborot-{&bef-TDEDT_Chg_Purch_Code}     :screen-value = string( {7}oborot-{&bef-TDEDT_Chg_Purch_Code}    [ {2} ] ). end.
if use-column[ 27 ] = yes then do: assign C-oborot-{&bef-r-v}                      :screen-value = string( {7}oborot-{&bef-TDEDT_Ras_Vnesh}         [ {2} ] +
                                                                                                           {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh}     [ {2} ] +
                                                                                                           {7}oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    [ {2} ] +
                                                                                                           {7}oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ {2} ] ). end.
display stream OutStream {&WFz}.
{&FRAME-d}.

/* $Workfile$   E n d */

