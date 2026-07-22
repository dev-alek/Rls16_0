block-level on error undo, throw.
define input  parameter p-host-code           like ub.fin-statement.host-code    no-undo .
define input  parameter p-fin-sttm-code       like ub.fin-statement.sttm-code    no-undo .
define input  parameter p-mode                as character                 no-undo .
define input  parameter p-author              as character                 no-undo .
define input  parameter p-status-current      like ub.fin-statement.status_      no-undo .
define input  parameter p-status-date         like ub.fin-statement.fact-date    no-undo .
define output parameter p-status_             like ub.fin-statement.status_      no-undo .
define output parameter p-ask-date            as logical                   no-undo .
define output parameter p-ask-message         as character                 no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Стандартный граф переходов банковских выписок".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-author as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-statement for ub.fin-statement.
define buffer bf_clients for ub.clients.
define buffer bf_db for ub.db .
do on error undo, return error substitute ("Ошибка при вызове программы finsgraf.p: &1 &2 &3 &4 при работе с документом &4.", error-status:get-message(1), error-status:get-message(2), return-value, p-host-code, p-fin-sttm-code):
  if p-mode <> '<закрытие документа>':U
  AND p-mode <> '<открытие документа>':U
  AND p-mode <> '<закрытие документа на факт>':U
     then do:
     return error substitute ("Неверный режим обработки документа &1.", p-mode).
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  ) no-error .
  if error-status:error then do:
    return error "Ошибка при определении номер текущей БД".
  end.
  find first buf_sysconf where
             buf_sysconf.host-code = p-host-code no-error.
  if not available buf_sysconf then do:
     return error substitute ("Не найдена фирма с номером &1 для платежа", p-host-code, p-fin-sttm-code).
  end.
  find first buf_fin-statement where
            buf_fin-statement.host-code = p-host-code
        AND buf_fin-statement.sttm-code = p-fin-sttm-code no-lock no-error.
  if not available buf_fin-statement then do:
     return error substitute ("Не найдена выписка: фирма &1 с номером &2.", p-host-code, p-fin-sttm-code).
  end.
  if buf_sysconf.firm-db-num = ? or
     buf_sysconf.firm-db-num < 0 then do:
     return error substitute ("Неверный номер базы данных &1 фирмы &2.", buf_sysconf.firm-db-num, buf_sysconf.host-code).
  end.
  find first bf_db where bf_db.db-num = buf_sysconf.firm-db-num no-lock no-error.
  if not available bf_db then do:
     return error substitute("Не найдена БД &1 документа &2 для фирмы &3.", buf_sysconf.firm-db-num, p-fin-sttm-code, buf_sysconf.host-code).
  end.
  if v-db-num <> buf_sysconf.firm-db-num then do:
    return error substitute("Нельзя изменять запись БАНКОВСКОЙ ВЫПИСКИ в БД, отличной от главной БД фирмы:&3" +
                            "номер текущей БД &1, номер главной БД фирмы &2"
                            , v-db-num
                            , buf_sysconf.firm-db-num
                            , chr(10)
                            ).
  end.
  if buf_fin-statement.status_ = 'факт':U then do:
     return error substitute ("Банковская выписка &1 для фирмы &2 закрыта до факта.&3"
                              + "Операции с ней не допустимы."
                              , buf_fin-statement.prn-doc-code
                              , buf_sysconf.host-code
                              , chr(10)
                              ).
  end.
  run trg/finsgrfp.p (
                   input this-procedure:handle
                  ,input  buf_fin-statement.fins-doc-type
                  ,input  buf_fin-statement.fins-ext-doc-type
                  ,input  buf_fin-statement.status_
                  ,input  p-mode
                  ,input  p-author
                  ,input  p-status-date
                  ,output p-status_
                  ,output p-ask-date
                  ,output p-ask-message
                  ) no-error.
  if error-status:error then do:
     return error substitute ("Ошибка:  &1&2"
                              + "по операции: &3&2"
                              + "номер документа &4&2"
                              + "тип &5&2"
                              + "расш.тип &6&2"
                              + "статус &7"
                              ,return-value
                              ,chr(10)
                              ,p-mode
                              ,buf_fin-statement.sttm-code
                              ,buf_fin-statement.fins-doc-type
                              ,buf_fin-statement.fins-ext-doc-type
                              ,buf_fin-statement.status_
                              ).
  end.
end.
procedure check-cl-bank :
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-bank  for ub.fin-bank.
  do
  on error undo, return error
  :
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = buf_fin-statement.host-code
        AND buf_fin-schet.code-schet = buf_fin-statement.code-schet .
  find first buf_fin-bank no-lock where
            buf_fin-bank.host-code = buf_fin-statement.host-code
        AND buf_fin-bank.code-bank = buf_fin-statement.code-bank.
  if buf_fin-bank.cl-bank <> '':U then do:
    return error substitute("Выписка &1 (вн.№ &2) для фирмы &3 проходит по счету банка &4,&5" +
                            "который подключен к системе КЛИЕНТ-БАНК. ВРУЧНУЮ обработать невозможно"
                            , buf_fin-statement.prn-doc-code
                            , buf_fin-statement.sttm-code
                            , buf_fin-statement.host-code
                            , chr(10)
                            , buf_fin-bank.bank-name).
  end.
  end.
end procedure.
