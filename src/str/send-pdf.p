block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: send-pdf.p $
$Archive: str/send-pdf.p $

Пересылка и удаление товаров из переоценок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter  action as character no-undo .
define input parpameter p-doc-num like ub.price-doc-forming.doc-num.
define input parameter i-obj-code like ub.clients.obj-code no-undo.
*/

&SCOPED-DEFINE called   pdf

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-pdf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-pdf.p $":U .
define variable vss-description as character no-undo init "Пересылка и удаление товаров из ДНЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
define variable v-cntxt-db-num        as integer   no-undo . /* текущая БД            */
define variable v-cntxt-userid        as character no-undo . /* текущий пользователь  */


define variable action as character no-undo init "U".
define variable pdf-action as character no-undo.
define variable p-doc-num like ub.price-doc-forming.pdf-id no-undo .
define variable p-pdf-db like ub.price-doc-forming.pdf-db no-undo .
define variable p-plt-id like ub.price-doc-forming.plt-id no-undo .
define variable p-plt-db-num like ub.price-doc-forming.plt-db-num no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo.
define variable p-batch as logical no-undo .
define variable p-other    as character no-undo .
define buffer p-doc for ub.price-doc-forming .

assign
pdf-action = entry(1, p-parameter, {&delim-par})
p-plt-id = integer(entry(2, p-parameter, {&delim-par}))
p-plt-db-num = integer(entry(3, p-parameter, {&delim-par}))
p-doc-num = integer(entry(4, p-parameter, {&delim-par}))
p-pdf-db = integer(entry(5, p-parameter, {&delim-par}))
i-obj-code = integer(entry(6, p-parameter, {&delim-par}))
no-error
.
if  error-status:error then return error .
find first p-doc no-lock where
         p-doc.plt-id = p-plt-id
     and p-doc.plt-db-num = p-plt-db-num
     and p-doc.pdf-id = p-doc-num
     and p-doc.pdf-db = p-pdf-db
         no-error .
if not available p-doc then return error substitute("Не найден ДНЦ &1 по БД &2 (ТПЛ &3 от БД &4)"
                                                     ,p-doc-num
                                                     ,p-pdf-db
                                                     ,p-plt-id
                                                     ,p-plt-db-num).

if not g#news
and not g#auto then do:

run get-userid in parparentproc ( output v-cntxt-userid) .
run get-db-num in parparentproc ( output v-cntxt-db-num) .
end.

{ str/sendgood.i }