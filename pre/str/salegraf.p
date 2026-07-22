block-level on error undo, throw.
define input  parameter p-inkas-code          like ub.inkas.inkas-code     no-undo .
define input  parameter p-mode                as character                 no-undo .
define input  parameter p-status-current      like ub.inkas.status_        no-undo .
define input  parameter p-flag-current        like ub.trn-doc.flag_        no-undo .
define output parameter p-status_             like ub.inkas.status_        no-undo .
define output parameter p-flag_               like ub.trn-doc.flag_        no-undo .
define output parameter p-ask-message         as character                 no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salegraf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salegraf.p $":U .
define variable vss-description as character no-undo init "Стандартный граф переходов продаж".
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
define variable v-db-num like ub.db.db-num no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_clients for ub.clients.
define buffer bf_db for ub.db .
do on error undo, return error
substitute ("Ошибка при вызове программы salegraf.p:&1&2&1&3&1&4 при работе с документом &4."
, chr(10)
, error-status:get-message(1)
, error-status:get-message(2)
, return-value
, p-inkas-code):
  if p-mode <> '<закрытие документа>':U
  AND p-mode <> '<открытие документа>':U
  AND p-mode <> '<закрытие документа на факт>':U
     then do:
     return error substitute ("Неверный режим обработки документа &1.", p-mode).
  end.
  find first buf_inkas where
            buf_inkas.inkas-code = p-inkas-code no-lock no-error.
  if not available buf_inkas then do:
     return error substitute ("Не найдена продажа с номером &1.", p-inkas-code).
  end.
  find first buf_trn-doc where
            buf_trn-doc.doc-code = p-inkas-code no-lock no-error .
  if not available buf_trn-doc then do:
    return error substitute("Не найдена накладная расхода по продаже &1", p-inkas-code).
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  ) no-error .
  if error-status:error then do:
    return error "Ошибка при определении номер текущей БД".
  end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-obj-db-num
  )  .
  if v-db-num <> v-obj-db-num then do:
   return error  substitute("Нельзя изменять запись ПРОДАЖИ в БД, отличной от БД объекта продажи:&1" +
                            "номер продажи &6" +
                            "номер текущей БД &2, номер БД объекта &3&4 - &5"
                             , chr(10)
                             , v-db-num
                             , buf_inkas.obj-type
                             , buf_inkas.obj-code
                             , v-obj-db-num
                             , buf_inkas.inkas-code
                             ).
  end.
  find first buf_clients where buf_clients.obj-type = buf_trn-doc.cli-type and
                              buf_clients.obj-code = buf_trn-doc.cli-code no-lock no-error.
  if not available buf_clients then do:
     return error substitute ("Не найден КОНТРАГЕНТ-РЕАЛИЗАЦИЯ В МАГАЗИНЕ &1 &2 для продажи &3.", buf_trn-doc.cli-type, buf_trn-doc.cli-code, buf_inkas.inkas-code).
  end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-host-code
  )  .
  find first buf_sysconf where
             buf_sysconf.host-code = v-host-code no-error.
  if not available buf_sysconf then do:
     return error substitute ("Не найдена фирма с номером &1 для продажи &2", v-host-code, p-inkas-code).
  end.
  if not (buf_clients.obj-type = buf_sysconf.sale-type AND
         buf_clients.obj-code = buf_sysconf.sale-code ) then do:
    return error substitute ("КОНТРАГЕНТ для накладных продажи &1 = &2&3 а настройки для фирмы &4 КОНТРАГЕНТ-РЕАЛИЗАЦИЯ В МАГАЗИНЕ = &5&6."
                            , buf_inkas.inkas-code
                            , buf_trn-doc.cli-type
                            , buf_trn-doc.cli-code
                            , buf_sysconf.host-code
                            , buf_sysconf.sale-type
                            , buf_sysconf.sale-code
                            ).
  end.
  if buf_inkas.status_ = 'факт':U
  or buf_inkas.status_ = 'запрос':U
  then do:
    return error substitute ("Продажа &1 для &2&3 закрыта до статуса. &4&5" +
                                "Операции с ней недопустимы."
                                , buf_inkas.inkas-code
                                , buf_inkas.obj-type
                                , buf_inkas.obj-code
                                , buf_inkas.status_
                                , chr(10)
                                ).
  end.
  run str/salegrfp.p (
                   input  buf_inkas.status_
                  ,input  buf_inkas.flag_
                  ,input  buf_trn-doc.status_
                  ,input  p-mode
                  ,output p-status_
                  ,output p-flag_
                  ,output p-ask-message
                  ) no-error.
  if error-status:error then do:
     return error substitute ("Ошибка:  &1"          + chr(10)
                              + "по операции: &2"    + chr(10)
                              + "номер документа &3" + chr(10)
                              + "статус &4&5"
                              ,
                              return-value,
                              p-mode,
                              buf_inkas.inkas-code,
                              buf_inkas.status_,
                              string(buf_inkas.flag_, "+/")
                              ).
  end.
  return ''.
end.
