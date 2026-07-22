block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-icnt.p $
$Archive: str/chk-icnt.p $

Проверка документов счетчиков ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/12/99
Author: Dmitry Ukhanov
Creation date: 08/12/99

Автор1: Суслов Алексей Юрьевич
Дата создания: 03/27/06

*/

define input parameter parrecid as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-icnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chk-icnt.p $":U .
define variable vss-description as character no-undo init "Проверка документов счетчиков ТРК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
define buffer aft_icnt-doc for ub.icnt-doc.
tr:
do transaction on error   undo tr, return error
               on end-key undo tr, return error
               on stop    undo tr, return error:
find buf_icnt-doc where recid(buf_icnt-doc) = parrecid exclusive no-error.
if not available buf_icnt-doc then undo tr, return error "Ошибка при поиске документа инвентаризации счетчиков ТРК (файл chk-icnt.p)".
/*Проверка того, что нет документов инвентаризации счетчиков ТРК со следующей сменой*/
if buf_icnt-doc.doc-type = {&icnt-doc} then do:
  find first aft_icnt-doc where aft_icnt-doc.obj-type   = buf_icnt-doc.obj-type       and
                                aft_icnt-doc.obj-code   = buf_icnt-doc.obj-code       and
                                aft_icnt-doc.doc-type   = {&icnt-doc}                 and
                              (aft_icnt-doc.shift-date > buf_icnt-doc.shift-date or
                                aft_icnt-doc.shift-date = buf_icnt-doc.shift-date and
                                aft_icnt-doc.shift-num  > buf_icnt-doc.shift-num    ) and
                                aft_icnt-doc.status_     = {&fact}           no-lock no-error.
  if available aft_icnt-doc then undo tr, return error "Уже имеется более поздний документ инвентаризации счетчиков ТРК: " + aft_icnt-doc.doc-code +  " Смена: " + string(aft_icnt-doc.shift-date) + " " + string(aft_icnt-doc.shift-num).
end.
if buf_icnt-doc.status_ = {&fact} then do:
   /*Проверка того что заданы значения*/
   for each buf_icnt-line where buf_icnt-line.doc-code = buf_icnt-doc.doc-code no-lock:
       if buf_icnt-line.state-el-cnt = ? then do:
         if buf_icnt-doc.doc-type = {&icnt-doc} then do:
            undo tr, return error substitute("Не задано количество по электронному счетчику ТРК: &1 пистолет &2."
                                            ,buf_icnt-line.pump-code
                                            ,buf_icnt-line.nozzle-code).
         end.
         if buf_icnt-doc.doc-type = {&icnt-err} then do:
            undo tr, return error substitute("Не задано количество по счетчику ТРК: &1 пистолет &2."
                                            ,buf_icnt-line.pump-code
                                            ,buf_icnt-line.nozzle-code).
         end.
       end.
       if buf_icnt-line.state-mh-cnt = ? then do:
         if buf_icnt-doc.doc-type = {&icnt-doc} then do:
           undo tr, return error substitute("Не задано количество по механическому счетчику ТРК: &1 пистолет &2."
                                            ,buf_icnt-line.pump-code
                                            ,buf_icnt-line.nozzle-code) .
         end.
         if buf_icnt-doc.doc-type = {&icnt-err} then do:
           undo tr, return error substitute("Не задано количество по мернику для ТРК: &1 пистолет &2."
                                            ,buf_icnt-line.pump-code
                                            ,buf_icnt-line.nozzle-code) .
         end.
       end.

   end.
   /*Проверка даты*/
   run gbl/chk-date.p
     (input buf_icnt-doc.obj-type
     ,input buf_icnt-doc.obj-code
     ,input buf_icnt-doc.fact-date
     ,input buf_icnt-doc.fact-time
     ,input buf_icnt-doc.shift-date
     ,input buf_icnt-doc.shift-num
     ,input true
     ) no-error .
   if error-status:error then undo tr, return error
    substitute("Неверная дата и время в документе счетчиков ТРК:&1"  +
               "fact-date=&2 fact-time = &3 shift-date=&4 shift-num=&5"
               ,{&new-line}
               ,buf_icnt-doc.fact-date
               ,buf_icnt-doc.fact-time
               ,buf_icnt-doc.shift-date
               ,buf_icnt-doc.shift-num)
   .
  end.
end. /*transaction*/