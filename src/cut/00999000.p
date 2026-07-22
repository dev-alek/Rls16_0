block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00999000.p $
$Archive: cut/00999000.p $

Файл пирога обрезания. Относится к категории 999.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09



Обработка таблиц:

grp-acto
ext-file
ext-file-line
ext-file-par
ext-file-attr
ext-file-line-attr
ext-file-par-attr
feature
feature-attr
feature-scale
feature-scale-attr
gen-attr
lang
lang-attr
prog-message
prog-message-attr
prog-message-lang
prog-message-lang-attr
res-lang
res-lang-attr
resource
resource-attr
rpt-option
rpt-option-attr
user-conn
usr-stko
user-db
doc-filter
doc-filter-attr
doc-filter-head
doc-filter-head-attr
h-route
h-route-dump
host-lk
cd-trans
cd-trans-attr
nws-outline
usr-stko-attr
whole-send-news
gds-obj-flag
gds-obj-flag-attr
gds-obj-prop
gds-obj-prop-attr
c-gds-obj-prop

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00999000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00999000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 999.".

{ cmp/str-glbl.i }
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
output stream str-gen close.
return "Игнорированы таблицы: cash-rest cash-rest-attr ext-file ext-file-line ext-file-par ext-file-attr ext-file-line-attr ext-file-line-par " +
"feature feature-attr feature-scale feature-scale-attr gen-attr lang lang-attr prod-bc-db prog-message prog-message-attr prog-message-lang prog-message-lang-attr " +
"res-lang res-lang-attr resource resource-attr rpt-option rpt-option-attr user-conn usr-stko user-db." +
"doc-filter doc-filter-attr doc-filter-head doc-filter-head-attr h-route h-route-dump host-lk cd-trans cd-trans-attr nws-outlitne usr-stko-attr whole-send-news ".
end.