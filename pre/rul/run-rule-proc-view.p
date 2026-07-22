block-level on error undo, throw.
define input parameter p-pchain-type as character no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск просмотра процессов в RUM".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-pchain-link-rule no-undo
field pchain-type as character
field pchain-id as character
field start-from as integer
field link-id as integer
field codex_id as integer
field ruleset_id as integer
field run-DB0 as integer
field run-RDB as integer
field order_id as integer
field rule_id as integer
field profile_id as integer
field once-more as integer
field can-calc as logical
field can-run as logical
field link-btwn-profiles as integer
index pi is unique primary
pchain-type
pchain-id
start-from
link-id
order_id
.
define variable v-ii as integer no-undo .
define variable v-codes as character no-undo .
define variable v-labels as character no-undo .
define variable v-sel-code as character no-undo .
define variable v-pchain-id-list as character no-undo .
define variable v-pchain-id-name as character no-undo .
define variable v-found as logical no-undo .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule-process for ub.rule-process.
case p-pchain-type:
  when 'dis-card-type':U then do:
    v-pchain-id-list = 'sale-close,sale-delete,trn-doc-close,trn-doc-delete,sale-xml-import,text-import,text-export,one-card-recalc,one-card-check,one-card-add,batch-card-recalc,stop-list-import,payment-on-card,fin-doc-on-card,delete-fin-doc-from-card':U.
  end.
  when 'goods':U then do:
    v-pchain-id-list = 'gdsadd,gdsupdate,rengdscode,addlcode,dellcode,updatelcode,addprcode,delprcode,updateprcode,xml-file-import,xml-esys-import,batchwork-export,batchwork-routing,rest-update,goods-cd-send,goods-batchwork,add-good-to-asm,del-good-from-asm':U.
  end.
  when 'clients':U then do:
    v-pchain-id-list = 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import,text-import,text-export,cliadd,cliupdate':U.
  end.
  when 'gds-grp':U then do:
    v-pchain-id-list = 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import':U.
  end.
  when 'cli-grp':U then do:
    v-pchain-id-list = 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import':U.
  end.
  when 'chk-doc':U + "_" + 'IBS-TH':U then do:
    v-pchain-id-list = 'gline-discnt-calc,pline-discnt-calc,subtotal-discnt-calc':U.
  end.
  when 'chk-doc':U + "_" + 'IBS-TH-MOB':U then do:
    v-pchain-id-list = 'gline-discnt-calc,pline-discnt-calc,subtotal-discnt-calc':U.
  end.
  when 'edoc':U then do:
    v-pchain-id-list = 'batchwork-export_order,batchwork-routing_order,xml-esys-import_order,xml-file-import_order,batchwork-export_rcv,batchwork-routing_rcv,xml-esys-import_rcv,xml-file-import_rcv,batchwork-routing_price-doc,xml-esys-import_price-doc,xml-esys-import_trn-doc,batchwork-routing_trn-doc,xml-esys-import_inv-doc,xml-esys-import_contract,batchwork-routing_intorder,xml-esys-import_intorder,batchwork-routing_inkas,event_order,event_rcv,event_trn-doc,event_inv-doc,event_intorder,event_price-doc,event_inkas,text-export_specif,excel-export_specif,text-import_specif,excel-import_specif':U.
  end.
  when 'thref':U then do:
    v-pchain-id-list = 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import,recadd,recupdate,ref-event':U.
  end.
  when 'pdf':U then do:
    v-pchain-id-list = 'pdf-main-doc-close,overvalue-act-close':U.
  end.
  when 'rep':U then do:
    v-pchain-id-list = 'batchwork,close-shift':U.
  end.
  otherwise do:
  end.
END case.
DO v-ii = 1 TO NUM-ENTRIES(v-pchain-id-list):
  for each buf_rule-process
  where buf_rule-process.pchain-type = p-pchain-type
  and buf_rule-process.pchain-id = entry(v-ii, v-pchain-id-list)
  break
  by buf_rule-process.pchain-type
  by buf_rule-process.pchain-id
  by buf_rule-process.start-from
  :
    if first-of(buf_rule-process.pchain-id) then do:
      case p-pchain-type:
        when 'dis-card-type':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'sale-close,sale-delete,trn-doc-close,trn-doc-delete,sale-xml-import,text-import,text-export,one-card-recalc,one-card-check,one-card-add,batch-card-recalc,stop-list-import,payment-on-card,fin-doc-on-card,delete-fin-doc-from-card':U) + 1, ',' + 'Закрытие продажи на факт,Удаление закрытой продажи,Закрытие накл. с ДК на факт,Удаление накл. с ДК,Импорт продаж в XML виде,Импорт данных в текст.виде,Экспорт данных в текст.виде,Пересчет по одной карте,Проверка одной карты,Добавление одной карты,Пересчет карт,Импорт стоплиста,Внесение средств на карту,Внес.пл-жа на карту через сист.взаиморасчетов,Удал.пл-жа с карты через сист.взаиморасчетов':U).
        end.
        when 'goods':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'gdsadd,gdsupdate,rengdscode,addlcode,dellcode,updatelcode,addprcode,delprcode,updateprcode,xml-file-import,xml-esys-import,batchwork-export,batchwork-routing,rest-update,goods-cd-send,goods-batchwork,add-good-to-asm,del-good-from-asm':U) + 1, ',' + 'Добавление товара,Изменение товара,Смена кода товара,Добавление лок.кода,Удаление лок.кода,Изменение лок.кода,Добавление Доп.БК,Удаление Доп.БК,Изменение Доп.БК,Импорт из xml-файла,Импорт из ВС,Операции по списку-экспорт,Операции по списку-маршрутизация,Изменение остатка,Передача товаров на кассу,Работа в атоматическом режиме,add-good-to-asm,del-good-from-asm':U).
        end.
        when 'clients':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import,text-import,text-export,cliadd,cliupdate':U) + 1, ',' + 'Операции по списку-экспорт,Операции по списку-маршрутизация,Импорт из xml-файла,Импорт из ВС,Импорт данных в текст.виде,Экспорт данных в текст.виде,Добавление клиента,Изменение клиента':U).
        end.
        when 'gds-grp':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import':U) + 1, ',' + 'Операции по списку-экспорт,Операции по списку-маршрутизация,Импорт из xml-файла,Импорт из ВС':U).
        end.
        when 'cli-grp':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import':U) + 1, ',' + 'Операции по списку-экспорт,Операции по списку-маршрутизация,Импорт из xml-файла,Импорт из ВС':U).
        end.
        when 'chk-doc':U + "_" + 'IBS-TH':U
        or
        when 'chk-doc':U + "_" + 'IBS-TH-MOB':U
        then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'gline-discnt-calc,pline-discnt-calc,subtotal-discnt-calc':U) + 1, ',' + 'Расчет скидки по строке товара,Расчет скидки по строке оплат,Расчет скидки на подитог':U).
        end.
        when 'edoc':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export_order,batchwork-routing_order,xml-esys-import_order,xml-file-import_order,batchwork-export_rcv,batchwork-routing_rcv,xml-esys-import_rcv,xml-file-import_rcv,batchwork-routing_price-doc,xml-esys-import_price-doc,xml-esys-import_trn-doc,batchwork-routing_trn-doc,xml-esys-import_inv-doc,xml-esys-import_contract,batchwork-routing_intorder,xml-esys-import_intorder,batchwork-routing_inkas,event_order,event_rcv,event_trn-doc,event_inv-doc,event_intorder,event_price-doc,event_inkas,text-export_specif,excel-export_specif,text-import_specif,excel-import_specif':U) + 1, ',' + 'Заказы поставщику-экспорт,Заказы поставщику-маршрутизация,Заказы поставщику-импорт из ВС,Заказы поставщику-импорт из xml-файла,Поставки поставщика-экспорт,Поставки поставщика-маршрутизация,Поставка поставщика-импорт из ВС,Поставка поставщика-импорт из xml-файла,ДНЦ/переоценка-маршрутизация,ДНЦ-импорт из ВС,Накладные-импорт из ВС,Накладные-маршрутизация,Инвентаризации-импорт из ВС,Дог-ра и специф-ции-импорт из ВС,Заявки РЦ-маршрутизация,Заявки РЦ-импорт из ВС,Док-ты продажи-маршрутизация,Заказы поставщику-событие,Поставки поставщика-событие,Накладные-событие,Инвентаризация-событие,Заявки РЦ-событие,ДНЦ/переоценка-событие,Документ продажи-событие,Экспорт спецификации в текст.файл,Экспорт спецификации в Excel,Импорт спецификации из текст.файла,Импорт спецификации из Excel':U).
        end.
        when 'thref':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import,recadd,recupdate,ref-event':U) + 1, ',' + 'Операции по списку-экспорт,Операции по списку-маршрутизация,Импорт из xml-файла,Импорт из ВС,Добавление записи,Изменение записи,События справочников':U).
        end.
        when 'pdf':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'pdf-main-doc-close,overvalue-act-close':U) + 1, ',' + 'Закрытие ДНЦ по ГТПЛ,Закрытие переоценки на факт':U).
        end.
        when 'rep':U then do:
          v-pchain-id-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork,close-shift':U) + 1, ',' + 'Выполнение отчета по расписанию,Выполнение отчета при закрытии смены':U).
        end.
      end case.
    end.
    if first-of(buf_rule-process.start-from) then do:
      v-found = no.
    end.
    if p-profile-id > 0 then do:
      find first buf_rule-by-profile no-lock where
                buf_rule-by-profile.codex_id = buf_rule-process.codex_id
            and buf_rule-by-profile.ruleset_id = buf_rule-process.ruleset_id
            and buf_rule-by-profile.profile_id = p-profile-id no-error.
      if available buf_rule-by-profile then v-found = yes.
    end.
    if last-of(buf_rule-process.start-from) then do:
      if p-profile-id = 0
      or v-found = yes then do:
        assign
        v-codes = v-codes +
                (if v-codes = '':U then "" else "|") +
                substitute("&1=&2"
                            ,entry(v-ii, v-pchain-id-list)
                            ,(if buf_rule-process.start-from = 0 then "0" else "1")
              )
        v-labels = v-labels +
                (if v-labels = '':U then "" else "|") +
                substitute("&1 Активная сторона - &2"
                          ,string(v-pchain-id-name, "X(50)")
                          ,(if buf_rule-process.start-from > 0 then "УБД" else "ГБД")
              ).
      end.
    end.
  end.
end.
run gbl/d-list.w (
               INPUT "b-sel":U
              ,INPUT "Выберите процесс"
              ,INPUT v-codes
              ,INPUT v-labels
              ,INPUT "|"
              ,INPUT "":U
              ,output v-sel-code).
IF v-sel-code = "":u THEN do:
  RETURN ''.
end.
run rul/rule-proc-view.p ( input p-pchain-type
                          ,input entry(1, v-sel-code, "=")
                          ,input integer(entry(2, v-sel-code, "="))
                          ,input p-call-id
                          ,input p-profile-id
                          ,input -1
                          ,input p-mode
                          ,input ?
                          ) no-error.
if error-status:error then do:
  return error return-value .
end.
