/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ќпределение временной таблицы используемой при закачке чеков в Ѕƒ или далее в продажу

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

def var cr as integer no-undo.

&if "{2}" = "inc-sale" &then

/*закачка чеков в продажу*/

DEFINE {3} TEMP-TABLE t-gds No-UNDO
FIELD b-code like ub.chk-gds.b-code
FIELD gds-code like ub.goods.gds-code
FIELD VAT-sum-rubl like ub.chk-gds.VAT-sum-rubl
FIELD pump like ub.chk-gds.pump
FIELD nozzle-code like ub.chk-gds.nozzle-code
FIELD loc1 like ub.chk-gds.loc1
field pl-code like ub.chk-gds.pl-code
field density as decimal
FIELD fbr-obj-type like ub.clients.obj-type
FIELD fbr-obj-code like ub.clients.obj-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD doc-qnty like ub.chk-gds.doc-qnty
FIELD price-base like ub.chk-gds.price-base
FIELD price-sum like ub.chk-gds.price-base
FIELD discnt like ub.chk-gds.discnt
FIELD discnt-sum like ub.chk-gds.discnt
FIELD price-service like ub.chk-gds.price-service
FIELD service-sum like ub.chk-gds.price-service
FIELD road-tax like ub.chk-gds.road-tax
FIELD road-sum like ub.chk-gds.road-tax
FIELD new-price like ub.chk-gds.price-base
FIELD cashparts as logical
FIELD rdoc-line as recid
FIELD rgds-dtl as recid
FIELD unit-base like ub.goods.unit-base
FIELD unit-cli like ub.goods.unit-cli
FIELD node-code like ub.bar-code.node-code
FIELD num-lines as integer
FIELD vat-pc like ub.doc-line.vat-pc
FIELD SLT-pc like ub.doc-line.slt-pc
FIELD crf as integer
FIELD drc as recid
FIELD grc as recid /*будет отличен от нул€ только дл€ товаров дл€ которых нужно класть раздельно строчки чеков!!*/
FIELD prt-root like ub.goods.prt-root
FIELD excise as decimal
FIELD type like ub.units.type
FIELD is-modificator as logical
FIELD is-null-price as logical
FIELD doc-code like ub.trn-doc.doc-code
FIELD marks as character
index pi is PRIMARY doc-code b-code artic prod-type prod-code node-code pump nozzle-code pl-code
index ifbr b-code fbr-obj-type fbr-obj-code
index crfi crf.

&endif

&if "{2}" = "excl-chk" &then

/*исключение чеков из продажи*/

DEFINE {3} TEMP-TABLE t-gds No-UNDO
FIELD b-code like ub.chk-gds.b-code
FIELD gds-code like ub.goods.gds-code
FIELD artic like ub.goods.artic
FIELD prod-type like ub.goods.prod-type
FIELD prod-code like ub.goods.prod-code
FIELD doc-qnty like ub.chk-gds.doc-qnty
FIELD price-base like ub.chk-gds.price-base
FIELD price-sum like ub.chk-gds.price-base
FIELD discnt like ub.chk-gds.discnt
FIELD discnt-sum like ub.chk-gds.discnt
FIELD price-service like ub.chk-gds.price-service
FIELD road-tax like ub.chk-gds.road-tax
FIELD road-sum like ub.chk-gds.road-tax
FIELD new-price like ub.chk-gds.price-base
FIELD cashparts as logical
FIELD cashplace as logical
FIELD pl-code like ub.doc-pl.pl-code
field density as decimal
FIELD rdoc-line as recid
FIELD rgds-dtl as recid
FIELD unit-base like ub.goods.unit-base
FIELD node-code like ub.bar-code.node-code
FIELD num-lines as integer
FIELD pump like ub.chk-gds.pump
FIELD fbr-obj-type like ub.clients.obj-type
FIELD fbr-obj-code like ub.clients.obj-code
FIELD type like ub.units.type
FIELD grc as recid /*будет отличен от нул€ только дл€ товаров дл€ которых нужно класть раздельно строчки чеков!!*/
FIELD is-modificator as logical
FIELD is-null-price as logical
FIELD doc-code like ub.trn-doc.doc-code
FIELD marks as character
index pi is PRIMARY doc-code gds-code b-code artic prod-type prod-code node-code pl-code pump grc
index ifbr b-code fbr-obj-type fbr-obj-code
.

&endif

&if "{2}" = "chk" &then

/*закачка чеков в Ѕƒ*/

DEFINE {3} TEMP-TABLE t-gds No-UNDO
FIELD b-code like ub.chk-gds.b-code
FIELD doc-qnty like ub.chk-gds.doc-qnty
FIELD VAT-pc like ub.chk-gds.VAT-pc
FIELD price-base like ub.chk-gds.price-base
FIELD price-sum like ub.chk-gds.price-base
FIELD discnt-sum like ub.chk-gds.discnt
FIELD unit-base like ub.goods.unit-base
FIELD num-lines as integer
FIELD was-return as logical
FIELD was-write-off as logical
FIELD is-modificator as logical
FIELD is-null-price as logical
FIELD crf as integer
FIELD drc as recid
FIELD grc as recid /*будет отличен от нул€ только дл€ товаров дл€ которых нужно класть раздельно строчки чеков!!*/
FIELD type like ub.units.type
field corr-discnt-rank as decimal
field first-line-num as integer
field last-included-in-sale as integer
index pi is PRIMARY b-code
index crfi crf
index icorr-discnt drc corr-discnt-rank
.

&endif




&endif

/* $Workfile$ e n d */