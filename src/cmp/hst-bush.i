/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание кустов истории

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/06/07
Author: Bakhtadze Natalya
Creation date: 05/06/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table hst-bush no-undo
field table-name as character
field bush-head as character
field where-phrase as character
field if-phrase as character
field is-main as logical
field joined-buffers as character
index pi is unique primary
table-name
bush-head
index imain is-main
.

define temp-table hst-bind no-undo
field src-table-name as character
field rec-table-name as character
field where-phrase as character
field if-phrase as character
index pi is unique primary
src-table-name
rec-table-name
.



define variable hst-bush_bush-head as character no-undo extent 15 init
[
    {&table_c-gds-hist}
  , {&table_c-cli-hist}
  , {&table_c-dc-hist}
  , {&table_c-tax-hist}
  , {&table_c-gds-grp-hist}
  , {&table_c-wth-hist}
  , {&table_c-fbr-gds-grp-hist}
  , {&table_c-plc-hist}
  , {&table_c-pmp-hist}
  , {&table_c-nzl-hist}
  , {&table_c-sht-hist}
  , {&table_c-recipe-hist}
  , {&table_c-usr-hist}
  , {&table_c-table-bind}
]
 .

define variable hst-psevdo-bush_bush-head as character no-undo extent 15 init
[
  {&table_c-auto-tank}
,{&table_c-cash-desk}
,{&table_c-cash-pay}
,{&table_c-dis-card-type}
,{&table_c-fbr-prn}
,{&table_c-prop-head}
,{&table_c-ruledict}
,{&table_c-scales}
,{&table_c-sert}
 ]
 .



define variable hst-bush_bush-contain as character no-undo .
define variable hst-bush_bush-main as character no-undo .
define variable hst-bush_bush-join as character no-undo .
if p-unload-history then do:
create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name =  {&table_c-goods}
hst-bush.is-main    = yes
hst-bush.where-phrase    = " true ~
, first ub.c-gds-hist no-lock where ub.c-gds-hist.gds-code = ub.c-goods.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-goods.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-goods.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-gds-obj-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist  no-lock where ub.c-gds-hist.gds-code = ub.c-gds-obj-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-gds-obj-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-gds-obj-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-bar-code-obj-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist  no-lock where ub.c-gds-hist.gds-code = ub.c-bar-code-obj-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-bar-code-obj-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-bar-code-obj-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-gds-host-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-gds-host-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-gds-host-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-gds-host-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-goods-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-goods-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-goods-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-goods-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-fbr-gds-obj}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-fbr-gds-obj.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-fbr-gds-obj.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-fbr-gds-obj.chip-num ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-s-coeff}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-s-coeff.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-s-coeff.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-s-coeff.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-prod-bc}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.b-code = ub.c-prod-bc.b-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-prod-bc.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-prod-bc.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-bar-code}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-bar-code.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-bar-code.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-bar-code.chip-num ~
and ub.c-gds-hist.subject <> {&table_prod-bc} ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-bar-code-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-bar-code-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-bar-code-attr.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-bar-code-attr.chip-num ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-varianty-delivery-gds-obj}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-varianty-delivery-gds-obj.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-varianty-delivery-gds-obj.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-varianty-delivery-gds-obj.chip-num ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-gds-season}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-gds-season.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-gds-season.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-gds-season.chip-num ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_tax-rate-gds}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
,each ub.c-gds-hist outer-join no-lock  where ub.c-gds-hist.gds-code = ub.tax-rate-gds.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.tax-rate-gds.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.tax-rate-gds.chip-num ~
" .


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-assortment-matrix-goods}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-assortment-matrix-goods.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-assortment-matrix-goods.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-assortment-matrix-goods.chip-num ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-gds-obj-prop}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-gds-obj-prop.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-gds-obj-prop.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-gds-obj-prop.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-pl-gds}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-pl-gds-attr}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-attr.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-attr.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-pl-gds-pump}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num  ~
,first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds-pump.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-dis-gds-rule}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-dis-gds-rule.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-dis-gds-rule.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-dis-gds-rule.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-ext-artic}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-ext-artic.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-ext-artic.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-ext-artic.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-sert}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-sert} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-sert.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-sert.chip-num  ~
,first ub.c-gds-hist no-lock  where ub.c-gds-hist.b-code = ub.c-sert.b-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-recipe}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-recipe} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-recipe.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-recipe.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-recipe.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-hist}
hst-bush.table-name = {&table_c-recipe-gds}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-recipe-gds}  ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-recipe-gds.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-recipe-gds.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-recipe-gds.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-clients}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = ub.c-clients.obj-type ~
and ub.c-cli-hist.obj-code  = ub.c-clients.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-clients.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-clients.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-clients-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = ub.c-clients-attr.obj-type ~
and ub.c-cli-hist.obj-code  = ub.c-clients-attr.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-clients-attr.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-clients-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-sysconf}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock where ub.c-cli-hist.obj-type  = {&cmp} ~
and ub.c-cli-hist.obj-code  = ub.c-sysconf.host-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-sysconf.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-sysconf.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-person}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = {&prs} ~
and ub.c-cli-hist.obj-code  = ub.c-person.psn-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-person.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-person.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-firm}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = {&cmp} ~
and ub.c-cli-hist.obj-code  = ub.c-firm.firm-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-firm.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-firm.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-shop}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = {&shop} ~
and ub.c-cli-hist.obj-code  = ub.c-shop.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-shop.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-shop.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-store}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = {&stock} ~
and ub.c-cli-hist.obj-code  = ub.c-store.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-store.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-store.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-staff}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = {&prs} ~
and ub.c-cli-hist.obj-code  = ub.c-staff.psn-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-staff.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-staff.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-dis-thbj-rule}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = ub.c-dis-thbj-rule.obj-type ~
and ub.c-cli-hist.obj-code  = ub.c-dis-thbj-rule.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-dis-thbj-rule.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-dis-thbj-rule.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cli-hist}
hst-bush.table-name = {&table_c-thbj-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cli-hist no-lock  where ub.c-cli-hist.obj-type  = ub.c-thbj-attr.obj-type ~
and ub.c-cli-hist.obj-code  = ub.c-thbj-attr.obj-code ~
and ub.c-cli-hist.corr-user-db-num = ub.c-thbj-attr.corr-user-db-num ~
and ub.c-cli-hist.chip-num = ub.c-thbj-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dc-hist}
hst-bush.table-name = {&table_c-dis-card}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-card.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-card.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-card.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dc-hist}
hst-bush.table-name = {&table_c-dis-obj}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-obj.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-obj.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-obj.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dc-hist}
hst-bush.table-name = {&table_c-dis-host}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-host.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-host.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-host.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dc-hist}
hst-bush.table-name = {&table_c-dis-card-property}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-card-property.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-card-property.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-card-property.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dc-hist}
hst-bush.table-name = {&table_c-dis-dc-rule}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dc-hist no-lock  where ub.c-dc-hist.d-card  = ub.c-dis-dc-rule.d-card ~
and ub.c-dc-hist.corr-user-db-num = ub.c-dis-dc-rule.corr-user-db-num ~
and ub.c-dc-hist.chip-num = ub.c-dis-dc-rule.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-tax-hist}
hst-bush.table-name = {&table_c-tax}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-tax-hist no-lock  where ub.c-tax-hist.tax-code  = ub.c-tax.tax-code ~
and ub.c-tax-hist.corr-user-db-num = ub.c-tax.corr-user-db-num ~
and ub.c-tax-hist.chip-num = ub.c-tax.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-tax-hist}
hst-bush.table-name = {&table_c-tax-rate}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-tax-hist no-lock  where ub.c-tax-hist.tax-code  = ub.c-tax-rate.tax-code ~
and ub.c-tax-hist.corr-user-db-num = ub.c-tax-rate.corr-user-db-num ~
and ub.c-tax-hist.chip-num = ub.c-tax-rate.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-tax-hist}
hst-bush.table-name = {&table_tax-rate-value}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, each ub.c-tax-hist no-lock outer-join where ub.c-tax-hist.tax-code  = ub.tax-rate-value.tax-code ~
and ub.c-tax-hist.rate-code  = ub.tax-rate-value.rate-code ~
and ub.c-tax-hist.corr-user-db-num = ub.tax-rate-value.corr-user-db-num ~
and ub.c-tax-hist.chip-num = ub.tax-rate-value.chip-num ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-tax-hist}
hst-bush.table-name = {&table_c-tax-units}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-tax-hist no-lock  where ub.c-tax-hist.tax-code  = ub.c-tax-units.tax-code ~
and ub.c-tax-hist.corr-user-db-num = ub.c-tax-units.corr-user-db-num ~
and ub.c-tax-hist.chip-num = ub.c-tax-units.chip-num ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-grp-hist}
hst-bush.table-name = {&table_c-gds-grp}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-gds-grp.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-gds-grp.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-gds-grp.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-grp-hist}
hst-bush.table-name = {&table_c-gds-grp-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-gds-grp-attr.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-gds-grp-attr.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-gds-grp-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-grp-hist}
hst-bush.table-name = {&table_c-gds-grp-obj}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-gds-grp-obj.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-gds-grp-obj.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-gds-grp-obj.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-grp-hist}
hst-bush.table-name = {&table_c-tax-rate-gds-grp}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-tax-rate-gds-grp.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-tax-rate-gds-grp.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-tax-rate-gds-grp.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-gds-grp-hist}
hst-bush.table-name = {&table_c-dis-grp-rule}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
 ub.c-dis-grp-rule.classif-type = {&table_gds-grp}, first ub.c-gds-grp-hist no-lock  where ub.c-gds-grp-hist.node-code  = ub.c-dis-grp-rule.node-code ~
and ub.c-gds-grp-hist.corr-user-db-num = ub.c-tax-rate-gds-grp.corr-user-db-num ~
and ub.c-gds-grp-hist.chip-num = ub.c-tax-rate-gds-grp.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-wth-hist}
hst-bush.table-name = {&table_c-wealth}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-wth-hist no-lock  where ub.c-wth-hist.wth-code  = ub.c-wealth.wth-code ~
and ub.c-wth-hist.corr-user-db-num = ub.c-wealth.corr-user-db-num ~
and ub.c-wth-hist.chip-num = ub.c-wealth.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-wth-hist}
hst-bush.table-name = {&table_c-wth-par}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-wth-hist no-lock  where ub.c-wth-hist.wth-code  = ub.c-wth-par.wth-code ~
and ub.c-wth-hist.corr-user-db-num = ub.c-wth-par.corr-user-db-num ~
and ub.c-wth-hist.chip-num = ub.c-wth-par.chip-num ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-fbr-gds-grp-hist}
hst-bush.table-name = {&table_c-fbr-gds-grp}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-fbr-gds-grp-hist no-lock  where ub.c-fbr-gds-grp-hist.obj-type  = ub.c-fbr-gds-grp.obj-type ~
and ub.c-fbr-gds-grp-hist.obj-code  = ub.c-fbr-gds-grp.obj-code ~
and ub.c-fbr-gds-grp-hist.node-code  = ub.c-fbr-gds-grp.node-code ~
and ub.c-fbr-gds-grp-hist.corr-user-db-num = ub.c-fbr-gds-grp.corr-user-db-num ~
and ub.c-fbr-gds-grp-hist.chip-num = ub.c-fbr-gds-grp.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-fbr-gds-grp-hist}
hst-bush.table-name = {&table_c-fbr-gds-grp-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-fbr-gds-grp-hist no-lock  where ub.c-fbr-gds-grp-hist.obj-type  = ub.c-fbr-gds-grp-attr.obj-type ~
and ub.c-fbr-gds-grp-hist.obj-code  = ub.c-fbr-gds-grp-attr.obj-code ~
and ub.c-fbr-gds-grp-hist.node-code  = ub.c-fbr-gds-grp-attr.node-code ~
and ub.c-fbr-gds-grp-hist.corr-user-db-num = ub.c-fbr-gds-grp-attr.corr-user-db-num ~
and ub.c-fbr-gds-grp-hist.chip-num = ub.c-fbr-gds-grp-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-plc-hist}
hst-bush.table-name = {&table_c-place}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-place.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-place.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-place.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-place.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-place.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-plc-hist}
hst-bush.table-name = {&table_c-pl-level}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-place.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-level.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-level.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-level.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-level.chip-num ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-plc-hist}
hst-bush.table-name = {&table_c-pl-gds}
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-gds-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-gds.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-gds.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-gds.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-gds.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-gds.chip-num ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-plc-hist}
hst-bush.table-name = {&table_c-pl-gds-pump}
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-gds-hist,buf_c-table-bind,c-pmp-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-gds-pump.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-gds-pump.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-gds-pump.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-gds-pump.chip-num ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num ~
,first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds-pump.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num  ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec  ~
,first buf_c-table-bind no-lock  where buf_c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and buf_c-table-bind.tbl-name-rec = {&table_c-pmp-hist} ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num  ~
and buf_c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num ~
,first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type = ub.c-pl-gds-pump.obj-type  ~
and ub.c-pmp-hist.obj-code = ub.c-pl-gds-pump.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-gds-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num  ~
and ub.c-pmp-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-plc-hist}
hst-bush.table-name = {&table_c-pl-pump}
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-pmp-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-pump.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump.chip-num ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-pmp-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump.chip-num ~
,first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type = ub.c-pl-pump.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-plc-hist}
hst-bush.table-name = {&table_c-pl-pump-nozzle}
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-pmp-hist,buf_c-table-bind,c-nzl-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump-nozzle.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump-nozzle.chip-num  ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-pmp-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num ~
,first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump-nozzle.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num  ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
,first buf_c-table-bind no-lock  where buf_c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and buf_c-table-bind.tbl-name-rec = {&table_c-nzl-hist} ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num  ~
and buf_c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num ~
,first ub.c-nzl-hist no-lock  where ub.c-nzl-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-nzl-hist.nozzle-code = ub.c-pl-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num  ~
and ub.c-nzl-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-plc-hist}
hst-bush.table-name = {&table_c-place-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-place-attr.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-place-attr.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-place-attr.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-place-attr.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-place-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-plc-hist}
hst-bush.table-name = {&table_c-pl-gds-attr}
hst-bush.is-main    =  yes
hst-bush.joined-buffers = "c-table-bind,c-gds-hist"
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock  where ub.c-plc-hist.obj-type  = ub.c-pl-gds-attr.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-gds-attr.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-gds-attr.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-gds-attr.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-gds-attr.chip-num ~
,first ub.c-table-bind no-lock  where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-attr.corr-user-db-num  ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-attr.chip-num, ~
first ub.c-gds-hist no-lock  where ub.c-gds-hist.gds-code = ub.c-pl-gds-attr.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
" .


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-pmp-hist}
hst-bush.table-name = {&table_c-pump}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type  = ub.c-pump.obj-type ~
and ub.c-pmp-hist.obj-code  = ub.c-pump.obj-code ~
and ub.c-pmp-hist.pump-code  = ub.c-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-pump.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-pump.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-pmp-hist}
hst-bush.table-name = {&table_c-pump-nozzle}
hst-bush.is-main    =  yes
hst-bush.joined-buffers =  "c-table-bind,c-nzl-hist"
hst-bush.where-phrase = " true ~
, first ub.c-pmp-hist no-lock  where ub.c-pmp-hist.obj-type  = ub.c-pump-nozzle.obj-type  ~
and ub.c-pmp-hist.obj-code  = ub.c-pump-nozzle.obj-code ~
and ub.c-pmp-hist.pump-code  = ub.c-pump-nozzle.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-pump-nozzle.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-pmp-hist} ~
and ub.c-table-bind.corr-user-db-num     = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-table-bind.chip-num-src     = ub.c-pump-nozzle.chip-num ~
,first ub.c-nzl-hist no-lock where ub.c-nzl-hist.nozzle-code = ub.c-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.obj-type = ub.c-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pump-nozzle.obj-code ~
and ub.c-nzl-hist.corr-user-db-num = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-pmp-hist}
hst-bush.table-name = {&table_c-pl-gds-pump}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock where ub.c-plc-hist.obj-type  = ub.c-pl-gds-pump.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-gds-pump.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-gds-pump.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-gds-pump.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-gds-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num and ~
and ub.c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num, ~
first ub.c-gds-hist no-lock where ub.c-gds-hist.gds-code = ub.c-pl-gds-pump.gds-code ~
and ub.c-gds-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-gds-hist.chip-num = ub.c-table-bind.chip-num-rec ~
,first buf_c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and buf_c-table-bind.tbl-name-rec = {&table_c-pmp-hist} ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-gds-pump.corr-user-db-num and ~
and buf_c-table-bind.chip-num-src = ub.c-pl-gds-pump.chip-num, ~
,first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type = ub.c-pl-gds-pump.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-gds-pump.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-gds-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-pmp-hist}
hst-bush.table-name = {&table_c-pl-pump}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock where ub.c-plc-hist.obj-type  = ub.c-pl-pump.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-pmp-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump.corr-user-db-num ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump.chip-num ~
,first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type = ub.c-pl-pump.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-pmp-hist}
hst-bush.table-name = {&table_c-pl-pump-nozzle}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock where ub.c-plc-hist.obj-type  = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump-nozzle.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump-nozzle.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-pmp-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num and ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num, ~
,first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump-nozzle.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
,first buf_c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and buf_c-table-bind.tbl-name-rec = {&table_c-nzl-hist} ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num and ~
and buf_c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num, ~
,first ub.c-nzl-hist no-lock where ub.c-nzl-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-nzl-hist.nozzle-code = ub.c-pl-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-pmp-hist}
hst-bush.table-name = {&table_c-pump-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type  = ub.c-pump-attr.obj-type ~
and ub.c-pmp-hist.obj-code  = ub.c-pump-attr.obj-code ~
and ub.c-pmp-hist.pump-code  = ub.c-pump-attr.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-pump-attr.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-pump-attr.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-nzl-hist}
hst-bush.table-name = {&table_c-nozzle}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-nzl-hist no-lock where ub.c-nzl-hist.obj-type  = ub.c-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code  = ub.c-nozzle.obj-code ~
and ub.c-nzl-hist.nozzle-code  = ub.c-nozzle.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = ub.c-nozzle.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = ub.c-nozzle.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-nzl-hist}
hst-bush.table-name = {&table_c-pump-nozzle}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type  = ub.c-pump.obj-type ~
and ub.c-pmp-hist.obj-code  = ub.c-pump.obj-code ~
and ub.c-pmp-hist.pump-code  = ub.c-pump.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-pump.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-pump.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-pmp-hist} ~
and ub.c-table-bind.corr-user-db-num     = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-table-bind.chip-num-src     = ub.c-pump-nozzle.chip-num ~
,first ub.c-nzl-hist no-lock where ub.c-nzl-hist.nozzle-code = ub.c-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.obj-type = ub.c-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pump-nozzle.obj-code ~
and ub.c-nzl-hist.corr-user-db-num = ub.c-pump-nozzle.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = ub.c-table-bind.chip-num-rec ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-nzl-hist}
hst-bush.table-name = {&table_c-pl-pump-nozzle}
hst-bush.is-main    =  no
hst-bush.where-phrase = " true ~
, first ub.c-plc-hist no-lock where ub.c-plc-hist.obj-type  = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-plc-hist.obj-code  = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-plc-hist.pl-code  = ub.c-pl-pump-nozzle.pl-code ~
and ub.c-plc-hist.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num ~
and ub.c-plc-hist.chip-num = ub.c-pl-pump-nozzle.chip-num ~
,first ub.c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and ub.c-table-bind.tbl-name-rec = {&table_c-pmp-hist} ~
and ub.c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num and ~
and ub.c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num, ~
,first ub.c-pmp-hist no-lock where ub.c-pmp-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-pmp-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-pmp-hist.pump-code = ub.c-pl-pump-nozzle.pump-code ~
and ub.c-pmp-hist.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
and ub.c-pmp-hist.chip-num = ub.c-table-bind.chip-num-rec ~
,first buf_c-table-bind no-lock where ub.c-table-bind.tbl-name-src = {&table_c-plc-hist} ~
and buf_c-table-bind.tbl-name-rec = {&table_c-nzl-hist} ~
and buf_c-table-bind.corr-user-db-num = ub.c-pl-pump-nozzle.corr-user-db-num and ~
and buf_c-table-bind.chip-num-src = ub.c-pl-pump-nozzle.chip-num, ~
,first ub.c-nzl-hist no-lock where ub.c-nzl-hist.obj-type = ub.c-pl-pump-nozzle.obj-type ~
and ub.c-nzl-hist.obj-code = ub.c-pl-pump-nozzle.obj-code ~
and ub.c-nzl-hist.nozzle-code = ub.c-pl-pump-nozzle.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = buf_c-table-bind.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = buf_c-table-bind.chip-num-rec ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-nzl-hist}
hst-bush.table-name = {&table_c-nozzle-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-nzl-hist no-lock where ub.c-nzl-hist.obj-type  = ub.c-nozzle-attr.obj-type ~
and ub.c-nzl-hist.obj-code  = ub.c-nozzle-attr.obj-code ~
and ub.c-nzl-hist.nozzle-code  = ub.c-nozzle-attr.nozzle-code ~
and ub.c-nzl-hist.corr-user-db-num = ub.c-nozzle-attr.corr-user-db-num ~
and ub.c-nzl-hist.chip-num = ub.c-nozzle-attr.chip-num ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-sht-hist}
hst-bush.table-name = {&table_c-shift-obj}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-sht-hist no-lock where ub.c-sht-hist.obj-type  = ub.c-shift-obj.obj-type ~
and ub.c-sht-hist.obj-code  = ub.c-shift-obj.obj-code ~
and ub.c-sht-hist.shift-date  = ub.c-shift-obj.shift-date ~
and ub.c-sht-hist.shift-num  = ub.c-shift-obj.shift-num ~
and ub.c-sht-hist.corr-user-db-num = ub.c-shift-obj.corr-user-db-num ~
and ub.c-sht-hist.chip-num = ub.c-shift-obj.chip-num ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-sht-hist}
hst-bush.table-name = {&table_c-shift-staff}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-sht-hist no-lock where ub.c-sht-hist.obj-type  = ub.c-shift-staff.obj-type ~
and ub.c-sht-hist.obj-code  = ub.c-shift-staff.obj-code ~
and ub.c-sht-hist.shift-date  = ub.c-shift-staff.shift-date ~
and ub.c-sht-hist.shift-num  = ub.c-shift-staff.shift-num ~
and ub.c-sht-hist.corr-user-db-num = ub.c-shift-staff.corr-user-db-num ~
and ub.c-sht-hist.chip-num = ub.c-shift-staff.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-recipe-hist}
hst-bush.table-name = {&table_c-recipe}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-recipe-hist no-lock where ub.c-recipe-hist.corr-user-db-num = ub.c-recipe.corr-user-db-num ~
and ub.c-recipe-hist.chip-num = ub.c-recipe.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-recipe-hist}
hst-bush.table-name = {&table_c-recipe-gds}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-recipe-hist no-lock where ub.c-recipe-hist.corr-user-db-num = ub.c-recipe-gds.corr-user-db-num ~
and ub.c-recipe-hist.chip-num = ub.c-recipe-gds.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-usr-hist}
hst-bush.table-name = {&table_c-user-account}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-usr-hist no-lock where ub.c-usr-hist.user-id = ub.c-user-account.user-id ~
and ub.c-usr-hist.corr-user-db-num = ub.c-user-account.corr-user-db-num ~
and ub.c-usr-hist.chip-num = ub.c-user-account.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-usr-hist}
hst-bush.table-name = {&table_c-user-login}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-usr-hist no-lock where ub.c-usr-hist.user-id = ub.c-user-login.user-id ~
and ub.c-usr-hist.corr-user-db-num = ub.c-user-login.corr-user-db-num ~
and ub.c-usr-hist.chip-num = ub.c-user-login.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-auto-tank}
hst-bush.table-name = {&table_c-auto-tank}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
ub.c-auto-tank.subject = {&table_auto-tank} ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cash-desk}
hst-bush.table-name = {&table_c-cash-desk}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
ub.c-cash-desk.subject = {&table_cash-desk} ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cash-desk}
hst-bush.table-name = {&table_c-cash-desk-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cash-desk no-lock where ub.c-cash-desk.db-num = ub.c-cash-desk-attr.db-num ~
and  ub.c-cash-desk.obj-code = ub.c-cash-desk-attr.obj-code  ~
and  ub.c-cash-desk.pos-type = ub.c-cash-desk-attr.pos-type  ~
and  ub.c-cash-desk.cash-num = ub.c-cash-desk-attr.cash-num  ~
and  ub.c-cash-desk.corr-user-db-num = ub.c-cash-desk-attr.corr-user-db-num ~
and ub.c-cash-desk.chip-num = ub.c-cash-desk-attr.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cash-pay}
hst-bush.table-name = {&table_c-cash-pay}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
ub.c-cash-pay.subject = {&table_cash-pay} ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cash-pay}
hst-bush.table-name = {&table_c-cash-pay-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cash-pay no-lock where ub.c-cash-pay.cdpay-code = ub.c-cash-pay-attr.cdpay-code ~
and  ub.c-cash-pay.curr-code = ub.c-cash-pay-attr.curr-code  ~
and  ub.c-cash-pay.corr-user-db-num = ub.c-cash-pay-attr.corr-user-db-num ~
and ub.c-cash-pay.chip-num = ub.c-cash-pay-attr.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-cash-pay}
hst-bush.table-name = {&table_c-dis-cp-rule}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-cash-pay no-lock where ub.c-cash-pay.cdpay-code = ub.c-dis-cp-rule.cdpay-code ~
and  ub.c-cash-pay.curr-code = ub.c-dis-cp-rule.curr-code  ~
and  ub.c-cash-pay.corr-user-db-num = ub.c-dis-cp-rule.corr-user-db-num ~
and ub.c-cash-pay.chip-num = ub.c-dis-cp-rule.chip-num  ~
".



create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dis-card-type}
hst-bush.table-name = {&table_c-dis-card-type}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
ub.c-dis-card-type.subject = {&table_dis-card-type} ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dis-card-type}
hst-bush.table-name = {&table_c-dis-card-type-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.emitent-host-code = ub.c-dis-card-type-attr.emitent-host-code ~
and  ub.c-dis-card-type.type = ub.c-dis-card-type-attr.type  ~
and  ub.c-dis-card-type.host-code = ub.c-dis-card-type-attr.host-code  ~
and  ub.c-dis-card-type.obj-type = ub.c-dis-card-type-attr.obj-type  ~
and  ub.c-dis-card-type.obj-code = ub.c-dis-card-type-attr.obj-code  ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-dis-card-type-attr.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-dis-card-type-attr.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dis-card-type}
hst-bush.table-name = {&table_c-dis-card-mask}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = {&table_dis-card-mask} ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-dis-card-mask.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-dis-card-mask.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dis-card-type}
hst-bush.table-name = {&table_c-rp-by-call}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ub.c-rp-by-call.call_id begins ({&table_dis-card-type} + {&delim-key}) ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = {&table_rp-by-call} ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-rp-by-call.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-rp-by-call.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dis-card-type}
hst-bush.table-name = {&table_c-rule-by-call}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ub.c-rule-by-call.call_id begins ({&table_dis-card-type}  + {&delim-key}) ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = {&table_rule-by-call} ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-rule-by-call.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-rule-by-call.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dis-card-type}
hst-bush.table-name = {&table_c-rule-call-param}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ub.c-rule-call-param.call_id begins ({&table_dis-card-type}  + {&delim-key}) ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = {&table_rule-call-param} ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-rule-call-param.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-rule-call-param.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dis-card-type}
hst-bush.table-name = {&table_c-dis-dct-rule}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-dis-card-type no-lock where ub.c-dis-card-type.subject = {&table_dis-dct-rule} ~
and  ub.c-dis-card-type.corr-user-db-num = ub.c-dis-dct-rule.corr-user-db-num ~
and ub.c-dis-card-type.chip-num = ub.c-dis-dct-rule.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-dis-card-type}
hst-bush.table-name = {&table_c-hist-nws-option}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ub.c-hist-nws-option.subject-group = {&table_c-dc-hist} ~
, first ub.ctable-bind no-lock where ub.c-table-bind.corr-user-db-num = ub.c-dis-card-type.corr-user-db-num ~
AND ub.c-table-bind.tbl-name-rec     = ~{&table_c-dis-card-type~}  ~
AND ub.c-table-bind.chip-num-rec     = uB.c-dis-card-type.chip-num ~
,first UB.c-hist-nws-option no-lock where ~
    UB.c-hist-nws-option.subject-group = ~{&table_c-dc-hist~}  ~
AND ub.c-hist-nws-option.charkey_one = ub.c-dis-card-type.type ~
AND ub.c-hist-nws-option.host-code = ub.c-dis-card-type.emitent-host-code ~
AND ub.c-hist-nws-option.corr-user-db-num = ub.c-table-bind.corr-user-db-num ~
AND ub.c-hist-nws-option.chip-num = ub.c-table-bind.chip-num-src  ~
".



create hst-bush.
assign
hst-bush.bush-head    = {&table_c-fbr-prn}
hst-bush.table-name = {&table_c-fbr-prn}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
  ub.c-fbr-prn.subject = {&table_fbr-prn} ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-fbr-prn}
hst-bush.table-name = {&table_c-fbr-prn-gds}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-fbr-prn no-lock where ub.c-fbr-prn.subject = {&table_fbr-prn-gds} ~
and  ub.c-fbr-prn.corr-user-db-num = ub.c-fbr-prn-gds.corr-user-db-num ~
and ub.c-fbr-prn.chip-num = ub.c-fbr-prn-gds.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-fbr-prn}
hst-bush.table-name = {&table_c-fbr-prn-grp}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-fbr-prn no-lock where ub.c-fbr-prn.subject = {&table_fbr-prn-grp} ~
and  ub.c-fbr-prn.corr-user-db-num = ub.c-fbr-prn-grp.corr-user-db-num ~
and ub.c-fbr-prn.chip-num = ub.c-fbr-prn-grp.chip-num  ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-prop-head}
hst-bush.table-name = {&table_c-prop-ref}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-prop-head no-lock where ub.c-prop-head.subject = {&table_prop-ref} ~
and  ub.c-prop-head.corr-user-db-num = ub.c-prop-ref.corr-user-db-num ~
and ub.c-prop-head.chip-num = ub.c-prop-ref.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-scales}
hst-bush.table-name = {&table_c-scales}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
  ub.c-scales.subject = {&table_c-scales} ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-scales}
hst-bush.table-name = {&table_c-scales-attr}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-scales no-lock where ub.c-scales.subject = {&table_scales-attr} ~
and  ub.c-scales.corr-user-db-num = ub.c-scales-attr.corr-user-db-num ~
and ub.c-scales.chip-num = ub.c-scales-attr.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-scales}
hst-bush.table-name = {&table_c-scales-gds}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
, first ub.c-scales no-lock where ub.c-scales.subject = {&table_scales-gds} ~
and  ub.c-scales.corr-user-db-num = ub.c-scales-gds.corr-user-db-num ~
and ub.c-scales.chip-num = ub.c-scales-gds.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-scales}
hst-bush.table-name = {&table_c-scales-grp}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " true ~
,first ub.c-scales no-lock where ub.c-scales.subject = {&table_scales-grp} ~
and  ub.c-scales.corr-user-db-num = ub.c-scales-grp.corr-user-db-num ~
and ub.c-scales.chip-num = ub.c-scales-grp.chip-num  ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-sert}
hst-bush.table-name = {&table_c-sert}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
  ub.c-sert.subject = {&table_c-sert} ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-ruledict}
hst-bush.table-name = {&table_c-ruledict}
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
 ub.c-ruledict.subject = {&table_ruledict} ~
".


create hst-bush.
assign
hst-bush.bush-head    = {&table_c-sum-grp}
hst-bush.table-name = {&table_c-dis-grp-rule} + "_1":U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
 c-dis-grp-rule_1.classif-type = {&table_sum-grp}, first ub.c-sum-grp no-lock  where ub.c-sum-grp.grp-code = c-dis-grp-rule_1.node-code ~
and ub.c-sum-grp.corr-user-db-num = c-dis-grp-rule_1.corr-user-db-num ~
and ub.c-sum-grp.chip-num = c-dis-grp-rule_1.chip-num ~
".

create hst-bush.
assign
hst-bush.bush-head    = {&table_c-sum-grp-obj}
hst-bush.table-name = {&table_c-dis-grp-rule} + "_2":U
hst-bush.is-main    =  yes
hst-bush.where-phrase = " ~
 c-dis-grp-rule_2.classif-type = {&table_sum-grp-obj}, first ub.c-sum-grp-obj no-lock  where ub.c-sum-grp-obj.grp-code = c-dis-grp-rule_2.node-code ~
and ub.c-sum-grp-obj.obj-type = c-dis-grp-rule_2.obj-type ~
and ub.c-sum-grp-obj.obj-code = c-dis-grp-rule_2.obj-code ~
and ub.c-sum-grp-obj.corr-user-db-num = c-dis-grp-rule_2.corr-user-db-num ~
and ub.c-sum-grp-obj.chip-num = c-dis-grp-rule_2.chip-num ~
".

end. /*if p-unload-history*/

define variable hst-bush_bind-list as character no-undo init
"~
{&bef-table_c-pl-gds}-{&bef-table_c-gds-hist}~
,{&bef-table_c-pl-gds-attr}-{&bef-table_c-gds-hist}~
,{&bef-table_c-pl-gds-pump}-{&bef-table_c-gds-hist}~
,{&bef-table_c-recipe-gds}-{&bef-table_c-gds-hist}~
,{&bef-table_c-recipe}-{&bef-table_c-gds-hist}~
,{&bef-table_c-pump-nozzle}-{&bef-table_c-nzl-hist}~
,{&bef-table_c-pl-pump-nozzle}-{&bef-table_c-nzl-hist}~
,{&bef-table_c-pl-gds-pump}-{&bef-table_c-pmp-hist}~
,{&bef-table_c-pl-pump-nozzle}-{&bef-table_c-pmp-hist}~
,{&bef-table_c-pl-pump}-{&bef-table_c-pmp-hist}~
,{&bef-table_c-hist-nws-option}-{&bef-table_c-dis-card-type}~
"
.

/* $Workfile$ e n d */