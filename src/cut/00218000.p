block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00218000.p $
$Archive: cut/00218000.p $

Файл пирога обрезания. Относится к категории 218.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/22/09
Author: Bakhtadze Natalya
Creation date: 09/22/09


Обработка таблиц:

abc-analysis
abc-analysis-attr
abc-analysis-cli
abc-analysis-cli-attr
abc-analysis-doc
abc-analysis-doc-attr
abc-analysis-gds-obj
abc-analysis-gds-obj-attr
abc-analysis-goods
abc-analysis-goods-attr
abc-analysis-grp
abc-analysis-grp-attr
abc-analysis-obj
abc-analysis-obj-attr
abc-analysis-period
abc-analysis-period-attr
abc-analysis-prod
abc-analysis-prod-attr
abcxyz-analysis
abcxyz-analysis-attr
abcxyz-analysis-goods
abcxyz-analysis-goods-attr
doc-abc-def
doc-abc-def-attr
doc-abc-def-doc
doc-abc-def-doc-attr
doc-abc-def-obj
doc-abc-def-obj-attr
doc-xyz-def
doc-xyz-def-attr
doc-xyz-def-doc
doc-xyz-def-doc-attr
doc-xyz-def-obj
doc-xyz-def-obj-attr



xyz-analysis
xyz-analysis-attr
xyz-analysis-doc
xyz-analysis-doc-attr
xyz-analysis-gds-obj
xyz-analysis-gds-obj-attr
xyz-analysis-goods
xyz-analysis-goods-attr
xyz-analysis-obj
xyz-analysis-obj-attr
xyz-analysis-period
xyz-analysis-period-attr
xyz-analysis-cli
xyz-analysis-cli-attr
xyz-analysis-grp
xyz-analysis-grp-attr
xyz-analysis-prod
xyz-analysis-prod-attr


rang-abc-def
rang-abc-def-attr
rang-abc-def-obj
rang-abc-def-obj-attr
rang-xyz-def
rang-xyz-def-attr
rang-xyz-def-obj
rang-xyz-def-obj-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00218000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00218000.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 999.".

{ cmp/str-glbl.i }
do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }
output stream str-gen close.
return "Игнорированы таблицы: abc-analysis abc-analysis-attr abc-analysi-cli abc-analysis-cli-attr abc-analysis-doc abc-analysis-doc-attr abc-analysis-gds-obj abc-analysis-gds-obj-attr " +
" abc-analysis-goods abc-analysis-goods-attr abc-analysis-grp abc-analysis-grp-attr abc-analysis-obj abc-analysis-obj-attr abc-analysis-period abc-analysis-period-attr " +
" abc-analysis-prod abc-analysis-prod-attr abcxyz-analysis abcxyz-analysis-attr abcxyz-analysis-goods abcxyz-analysis-goods-attr " +
" doc-abc-def doc-abc-def-attr doc-abc-def-doc doc-abc-def-doc-attr doc-abc-def-obj doc-abc-def-obj-attr " +
" doc-xyz-def doc-xyz-def-attr doc-xyz-def-doc doc-xyz-def-doc-attr doc-xyz-def-obj doc-xyz-def-obj-attr " +
" xyz-analysis xyz-analysis-attr xyz-analysis-doc xyz-analysis-doc-attr xyz-analysis-gds-obj xyz-analysis-gds-obj-attr xyz-analysis-goods xyz-analysis-goods-attr " +
" xyz-analysis-obj xyz-analysis-obj-attr xyz-analysis-period xyz-analysis-period-attr " +
" xyz-analysis-cli xyz-analysis-cli-attr xyz-analysis-grp xyz-analysis-grp-attr xyz-analysis-prod xyz-analysis-prod-attr "
.

end.