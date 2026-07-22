block-level on error undo, throw.
/*

$Revision: 6e7a63c8908d, 2425, rls $
$Author: ASMorozov $
$Date: Ср июн 10 21:13:46 2020 +0300 $
$Workfile: inv-lst.p $
$Archive: str/inv-lst.p $

Формирование списка документов, мешающих инвентаризации

Автор: Чернова Светлана Александровна
Дата создания: 01/28/10
Author: Svetlana Chernova
Creation date: 01/28/10


Автор1: Суслов Алексей Юрьевич
Дата создания: 04/12/06
*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input param inv-code like trn-doc.doc-code no-undo.          /* номер инвентаризации */

define variable vss-revision    as character no-undo init "$Revision: 6e7a63c8908d, 2425, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:46 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inv-lst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inv-lst.p $":U .
define variable vss-description as character no-undo init "Формирование списка документов, мешающих инвентаризации ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/waitfram.i }


define variable fill-gds-list as log no-undo. /* сформировать список товаров, мешающих включению инвентаризации */
define variable doc-cnt as integer no-undo. /* счетчик документов, т.к. doc-cnt используется в gds-list.i */
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .

fill-gds-list = no.
message
"Сформировать также и список ТОВАРОВ, мешающих инвентаризации?" skip (2)
"Да - сформировать, Нет - пропустить"
view-as alert-box question buttons YES-NO update fill-gds-list.

lst-calc:
do on stop undo lst-calc, return error on error undo lst-calc, return error :
  run waitfram-show in this-procedure ("Очистка старого списка документов.  ЖДИТЕ ...").
  for each trn-doc where trn-doc.inv-num = inv-code
       on stop undo lst-calc, return error on error undo lst-calc, return error :
    /* если резервы уже сняты, оставляем ссылку */
    if trn-doc.status_ = {&inquiry} then next.
    /* если мешала другая инвентаризация, а теперь резервы по ней уже сняты, оставляем ссылку */
    if trn-doc.doc-type = {&inventory} and trn-doc.status_ = {&wayb} then next.
    trn-doc.inv-num = "".
  end.
  run waitfram-show in this-procedure ("Формирование списка документов, мешающих инвентаризации.  ЖДИТЕ ...").
  assign
    doc-cnt = 0
    lns-cnt = 0           /* для gds-list.i */
    .
  for each doc-line where doc-line.doc-code = inv-code no-lock,
       { str/invchkrs.i inv-code parts doc-line}
       on stop undo lst-calc, return error on error undo lst-calc, return error :
       /* todo - проверить, что условие здесь сформулировано правильно */

    /* есть резерв, завязанный не на текущую инвентаризацию */
    find trn-doc where trn-doc.doc-code = parts.out-code no-error.
    if not available trn-doc or trn-doc.inv-num = inv-code then next.
    trn-doc.inv-num = inv-code.
    doc-cnt = doc-cnt + 1.
    if fill-gds-list then do:
        find first goods no-lock
             where goods.artic     = doc-line.artic
               and goods.prod-type = doc-line.prod-type
               and goods.prod-code = doc-line.prod-code
        .
        { cmp/gds-list.i gds-list assign }
    end.
    if (doc-cnt modulo 5 = 0) or (lns-cnt modulo 5 = 0) then
      run waitfram-show in this-procedure ("Документов в списке : " + string (doc-cnt) + "     Товаров в списке : " + string (lns-cnt)).
  end.
  run waitfram-hide in this-procedure .

end.
message
"Мешают включению инвентаризации :" doc-cnt "документов," skip
"Или :" lns-cnt "товаров.".
if fill-gds-list then do:
  run str/gds-list.w (parparentproc, p-curr-host-code, p-curr-obj-type, p-curr-obj-code).
end.