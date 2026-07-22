/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение переменных для разбора записи goods

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf_bar-code     for ub.bar-code .
define buffer buf_prod-bc      for ub.prod-bc .
define buffer buf_tax-rate-gds      for ub.tax-rate-gds .

define buffer dst-units        for ub.units .
define buffer src-units        for ub.units .

define variable counter        as   integer           no-undo .
define variable rec-full       as   character         no-undo .
define variable rec-name       as   character         no-undo .
define variable the-same-goods as   logical           no-undo .
define variable imp-goods      as   logical           no-undo .
define variable load-tax       as   logical           no-undo .
define variable error-message  as   character         no-undo .
define variable old-gds-code   like ub.goods.gds-code no-undo .
define variable v-cmd          as   character         no-undo .

for each locb-bar-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:

  delete locb-bar-code.
end.
for each locb-prod-bc
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:

  delete locb-prod-bc.
end.
for each locb-tax-rate-gds
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:

  delete locb-tax-rate-gds.
end.



/* $Workfile$ e n d */