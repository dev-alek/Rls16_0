/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение таблиц, связанных с товарами

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/08
Author: Bakhtadze Natalya
Creation date: 08/06/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table {1} no-undo like ub.chk-gds before-table {2}
field src-price-rubl as decimal
field src-discnt-rubl as decimal
field src-sum-rubl as decimal
field src-r-discnt-sum  as decimal
field src-discnt-sum    as decimal
field src-discnt-sum-rubl    as decimal
field r-sum  as decimal

field without-gds-discnt as integer
help {&dr-flddf_gline_without-gds-discnt}
field without-subtotal-discnt as integer
help {&dr-flddf_gline_without-subtotal-discnt}
field recalc-line-num as integer
help {&dr-flddf_gline_recalc-line-num}

field src-price-netto   as decimal /*текущая эффективная цена - src-price - src-discnt */
help {&dr-flddf_gline_src-price-netto}
field price-base-netto   as decimal /*текущая эффективная цена - src-price-netto * cli-base-rate */
help {&dr-flddf_gline_price-base-netto}

field start-src-price   as decimal
help {&dr-flddf_gline_start-src-price}
field main-bar-code     like ub.bar-code.b-code
field gds-code          like ub.goods.gds-code
help {&dr-flddf_gline_gds-code}
field unit-base         like ub.goods.unit-base
field unit-base-type    like ub.units.type
field unit-cli          like ub.bar-code.unit-cli
field unit-cli-type     like ub.units.type
field min-rate          like ub.goods.min-rate
field max-rate          like ub.goods.max-rate
field in-code           like ub.bar-code.in-code
field part-code         like ub.bar-code.part-code
field cash-parts        like ub.gds-obj.cash-parts
field prt-root          like ub.goods.prt-root
field root-node-code    like ub.gds-prt.node-code
field empty-scale       as logical
field chk-name as character
field second-name as character
field is-weight-pbc as logical
field is-pgweight-pbc as logical
field will-price-base as decimal
help {&dr-flddf_gline_price-base}
field will-doc-qnty as decimal
help {&dr-flddf_gline_doc-qnty}
field cli-base-rate as decimal
help {&dr-flddf_gline_cli-base-rate}
field free-price as logical
field line-direction as integer
field node-code         like ub.bar-code.node-code
field sum-grp-code as integer
help {&dr-flddf_gline_sum-grp-code}

field manual-discnt-id as integer
field manual-discnt-sum as decimal

field is-undo as logical

index ln is unique primary
doc-code
line-num
index ib-code
b-code
index igds
gds-code
index igrp
sum-grp-code
index inode
node-code



.
/* $Workfile$ e n d */