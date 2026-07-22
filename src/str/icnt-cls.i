/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедуры закрытия документов инвентаризации счетчиков ТРК

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/

procedure icnt-cls:
define input parameter parrec-id as recid no-undo.
define buffer bf_icnt-doc    for ub.icnt-doc.
define buffer bf_pump-nozzle for ub.pump-nozzle.
define buffer bf_icnt-line   for ub.icnt-line.
define variable varchk-prs      as character no-undo .
define variable varchk-prs-type as character no-undo.
define variable glog as logical no-undo .
do on error undo, return error return-value :
find bf_icnt-doc where recid (bf_icnt-doc) = parrec-id.

{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'chk-prs'   then varchk-prs     = thbjattr_thbj-attr.property-value-logical .
end.

if varchk-prs then do:
  if not can-find (clients where clients.obj-type = {&prs} and clients.obj-code = bf_icnt-doc.boss no-lock) then do:
     message "Не указан или неправильный менеджер.".
     return error.
  end.
  if not can-find (clients where clients.obj-type = {&prs} and clients.obj-code = bf_icnt-doc.agnt no-lock)  then do:
     message "Не указан или неправильный исполнитель.".
     return error.
  end.
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_icnt-doc_fact':U
  {&cntxt-object}
  bf_icnt-doc.host-code
  bf_icnt-doc.obj-type
  bf_icnt-doc.obj-code
  0
  0
  0
  true
  glog
}
{&if-not-clos}
tr:
do transaction on end-key undo tr, return error
               on error   undo tr, return error
               on stop    undo tr, return error :
   /*проверяем то, что структура документа инвентаризации соответствует конфигурации бензоколонки*/
   find first bf_pump-nozzle where bf_pump-nozzle.obj-type = bf_icnt-doc.obj-type and
                                   bf_pump-nozzle.obj-code = bf_icnt-doc.obj-code and
                                   bf_pump-nozzle.is-meas  = yes                  and
                                   not can-find (first bf_icnt-line where  bf_icnt-line.doc-code    = bf_icnt-doc.doc-code      and
                                                                           bf_icnt-line.obj-type    = bf_pump-nozzle.obj-type     and
                                                                           bf_icnt-line.obj-code    = bf_pump-nozzle.obj-code     and
                                                                           bf_icnt-line.pump-code   = bf_pump-nozzle.pump-code    and
                                                                           bf_icnt-line.nozzle-code = bf_pump-nozzle.nozzle-code) no-lock no-error.
    if available bf_pump-nozzle then do:
       message "Структура документа инвентаризации счетчиков ТРК не соответствует конфигурации бензоколонки." skip
               "Нет строки инвентаризации по ТРК № " bf_pump-nozzle.pump-code " пистолету № " bf_pump-nozzle.nozzle-code "." skip
       view-as alert-box error.
       undo tr, return error.
    end.
    find first bf_icnt-line where  bf_icnt-line.doc-code    = bf_icnt-doc.doc-code  and
                                   not can-find (first bf_pump-nozzle where bf_pump-nozzle.obj-type    = bf_icnt-line.obj-type    and
                                                                            bf_pump-nozzle.obj-code    = bf_icnt-line.obj-code    and
                                                                            bf_pump-nozzle.pump-code   = bf_icnt-line.pump-code   and
                                                                            bf_pump-nozzle.nozzle-code = bf_icnt-line.nozzle-code no-lock) no-error.
    if available bf_icnt-line then do:
       message "Структура документа инвентаризации счетчиков ТРК не соответствует конфигурации бензоколонки." skip
               "Есть строка инвентаризации по ТРК № " bf_icnt-line.pump-code " пистолету № " bf_icnt-line.nozzle-code " не соответствующая конфигурации ТРК." skip
       view-as alert-box error.
       undo tr, return error.
    end.
    /* Проверим, что информация по документу может использоваться */
    for each bf_icnt-line where bf_icnt-line.doc-code = bf_icnt-doc.doc-code:
        if bf_icnt-line.state-el-cnt = ? then do:
           message "Не определено показание электронного счетчика по ТРК № " bf_icnt-line.pump-code "  и пистолету № " bf_icnt-line.nozzle-code "."
           view-as alert-box error.
           undo tr, return error.
        end.
        if bf_icnt-line.state-mh-cnt = ? then do:
           message "Не определено показание механического счетчика по ТРК № " bf_icnt-line.pump-code "  и пистолету № " bf_icnt-line.nozzle-code "."
           view-as alert-box error.
           undo tr, return error.
        end.
    end.
    ASSIGN bf_icnt-doc.status_ = {&fact}.
    run gbl/factdate.p (input        bf_icnt-doc.obj-type,
                    input        bf_icnt-doc.obj-code,
                    input-output bf_icnt-doc.fact-date,
                    input-output bf_icnt-doc.fact-time,
                    input-output bf_icnt-doc.shift-date,
                    input-output bf_icnt-doc.shift-num,
                    input-output bf_icnt-doc.shift-name,
                    input        yes) no-error.
    if error-status :error then do:
       message "Ошибка при установке даты в документе инвентаризации счетчиков ТРК."
       view-as alert-box.
       undo tr, return error.
    end.
END. /* transaction */
end.
end procedure.

/* end of procedure */
/* $Workfile$ e n d */