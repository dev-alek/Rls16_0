block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: icntdoc2.p $
$Archive: str/icntdoc2.p $

Закрытие документа счетчиков ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/07
Author: Bakhtadze Natalya
Creation date: 07/16/07

*/

define input parameter p-rec as recid no-undo .
define input parameter p-silent as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: icntdoc2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/icntdoc2.p $":U .
define variable vss-description as character no-undo init "Закрытие документа счетчиков ТРК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/getsect.i def }
define variable v-mess as character no-undo .
define variable conf-par    as character no-undo.
define variable varshift-name   as character no-undo.
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
define buffer buf_pump-nozzle for ub.pump-nozzle.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_icnt-doc exclusive-lock where
          recid(buf_icnt-doc) = p-rec .


{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'chk-prs' then conf-par = string(thbjattr_thbj-attr.property-value-logical,"yes/no") .
end.

  if conf-par <> "no" then do:
    if not can-find (ub.clients where ub.clients.obj-type = {&prs}
                   and ub.clients.obj-code = buf_icnt-doc.boss no-lock) then do:
      v-mess =  "Не указан или неправильный менеджер.".
      run err-mess in this-procedure ( input-output v-mess) .
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
    if not can-find (ub.clients where ub.clients.obj-type = {&prs}
                 and ub.clients.obj-code = buf_icnt-doc.agnt no-lock)  then do:
      v-mess =  "Не указан или неправильный исполнитель.".
      run err-mess in this-procedure ( input-output v-mess) .
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
  end.

  if buf_icnt-doc.doc-type = {&icnt-doc} then do:
    /*проверяем то, что структура документа инвентаризации соответствует конфигурации бензоколонки*/
    for each buf_pump-nozzle where
              buf_pump-nozzle.obj-type = buf_icnt-doc.obj-type
          and  buf_pump-nozzle.obj-code = buf_icnt-doc.obj-code
          and  buf_pump-nozzle.is-meas  = yes
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

      if not can-find (first buf_icnt-line where
                          buf_icnt-line.doc-code    = buf_icnt-doc.doc-code
                    and  buf_icnt-line.obj-type    = buf_pump-nozzle.obj-type
                    and  buf_icnt-line.obj-code    = buf_pump-nozzle.obj-code
                    and  buf_icnt-line.pump-code   = buf_pump-nozzle.pump-code
                    and  buf_icnt-line.nozzle-code = buf_pump-nozzle.nozzle-code) then do:
       v-mess =  substitute("Структура документа инвентаризации счетчиков ТРК не соответствует конфигурации бензоколонки.&1" +
                 "Нет строки инвентаризации по ТРК № &2 пистолету № &3&1"
                 , {&new-line}
                 , buf_pump-nozzle.pump-code
                 , buf_pump-nozzle.nozzle-code).
       run err-mess in this-procedure ( input-output v-mess) .
       undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    for each buf_icnt-line where
            buf_icnt-line.doc-code    = buf_icnt-doc.doc-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if not can-find (first buf_pump-nozzle where
                           buf_pump-nozzle.obj-type    = buf_icnt-line.obj-type
                       and buf_pump-nozzle.obj-code    = buf_icnt-line.obj-code
                       and buf_pump-nozzle.pump-code   = buf_icnt-line.pump-code
                       and buf_pump-nozzle.nozzle-code = buf_icnt-line.nozzle-code ) then do:

       v-mess =  substitute("Структура документа инвентаризации счетчиков ТРК не соответствует конфигурации бензоколонки.&1" +
                 "Есть строка инвентаризации по ТРК № &2 пистолету № &3 не соответствующая конфигурации ТРК."
                 , {&new-line}
                 , buf_icnt-line.pump-code
                 , buf_icnt-line.nozzle-code).
      run err-mess in this-procedure ( input-output v-mess) .
       undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end. /*if icntdocf_doc-type(buf_icnt-doc.doc-code) = {&inventory} then do:*/
  /*Проверим, что информация по документу может использоваться*/
  for each buf_icnt-line where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    if buf_icnt-line.state-el-cnt = ? then do:
      v-mess =  substitute("Не определено показание электронного счетчика по ТРК № &1 и пистолету № &2"
                 ,buf_icnt-line.pump-code
                 ,buf_icnt-line.nozzle-code).
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_icnt-line.state-mh-cnt = ? then do:
      v-mess =  substitute("Не определено показание механического счетчика по ТРК № &1 и пистолету № &2"
                 ,buf_icnt-line.pump-code
                 ,buf_icnt-line.nozzle-code).
      run err-mess in this-procedure ( input-output v-mess) .
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  run gbl/factdate.p
    ( input        buf_icnt-doc.obj-type
    , input        buf_icnt-doc.obj-code
    , input-output buf_icnt-doc.fact-date
    , input-output buf_icnt-doc.fact-time
    , input-output buf_icnt-doc.shift-date
    , input-output buf_icnt-doc.shift-num
    , input-output buf_icnt-doc.shift-name
    ,input         not p-silent
    ) no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при установке даты в документе инвентаризации счетчиков ТРК:&1&2&1&3"
                       , {&new-line}
                       , error-status:get-message(1)
                       , return-value ).
    run err-mess in this-procedure ( input-output v-mess) .
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  assign
    buf_icnt-doc.status_ = {&fact}
  .
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Документ по счетчикам ТРК &1 &2&3&4&5"
                         , buf_icnt-doc.doc-code
                         , buf_icnt-doc.obj-type
                         , buf_icnt-doc.obj-code
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.