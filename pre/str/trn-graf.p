block-level on error undo, throw.
define input    parameter pardoc-code   like ub.trn-doc.doc-code no-undo.
define input    parameter parcur-db-num like ub.db.db-num        no-undo.
define input    parameter parmode       as   character           no-undo.
define output   parameter parstatus     like ub.trn-doc.status_  no-undo.
define output   parameter parflag       like ub.trn-doc.flag_    no-undo.
define output   parameter parcopystatus like ub.trn-doc.status_  no-undo.
define output   parameter parcopyflag   like ub.trn-doc.flag_    no-undo.
define buffer   bf_cur-db       for  ub.db.
define buffer   bf_db           for  ub.db.
define buffer   bf_trn-doc      for  ub.trn-doc.
define buffer   bf_clients      for  ub.clients.
define buffer   bf_store        for  ub.store.
define variable varactive       like ub.store.active no-undo.
define variable varext-oper     as   character       no-undo.
define variable p-is-hold as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trn-graf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/trn-graf.p $":U .
define variable vss-description as character no-undo init "Стандартный граф переходов складских документов".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3':u,pardoc-code,parcur-db-num,parmode)
    .
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
do on error undo, return error substitute ("Ошибка при вызове программы trn-graf.p: &1 &2 &3 при работе с документом &4.", error-status:get-message(1), error-status:get-message(2), return-value, pardoc-code):
  if parmode <> '<закрытие документа>':U      and
     parmode <> '<открытие документа>':U       and
     parmode <> '<закрытие документа на факт>':U     and
     parmode <> '<резервирование по документу>':U     then do:
     return error substitute ("Неверный режим обработки документа &1.", parmode).
  end.
  if parcur-db-num = ? or
     parcur-db-num < 0 then do:
     return error substitute ("Неверный номер &1 текущей БД.", parcur-db-num).
  end.
  find first bf_cur-db where bf_cur-db.db-num = parcur-db-num no-lock no-error.
  if not available bf_cur-db then do:
     return error substitute ("Не найдена текущая БД с номером &1.", parcur-db-num).
  end.
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
  if not available bf_trn-doc then do:
     return error substitute ("Не найден документ с номером &1 .", bf_trn-doc.doc-code).
  end.
  find first bf_clients where bf_clients.obj-type = bf_trn-doc.obj-type and
                              bf_clients.obj-code = bf_trn-doc.obj-code no-lock no-error.
  if not available bf_clients then do:
     return error substitute ("Не найден объект &1 &2 для документа &3.", bf_trn-doc.obj-type, bf_trn-doc.obj-code, bf_trn-doc.doc-code).
  end.
  if bf_clients.db-num = ? or
     bf_clients.db-num < 0 then do:
     return error substitute ("Неверный номер базы данных &1 объекта &2 &3.", bf_clients.db-num, bf_clients.obj-type, bf_clients.obj-code).
  end.
  find first bf_db where bf_db.db-num = bf_clients.db-num no-lock no-error.
  if not available bf_db then do:
     return error substitute("Не найдена БД &1 документа &2.", bf_clients.db-num, pardoc-code).
  end.
  case bf_clients.obj-type:
    when 'маг':U then do:
       assign varactive = yes.
    end.
    when 'скл':U then do:
      find first bf_store where bf_store.obj-code = bf_clients.obj-code no-lock no-error.
      if not available bf_store then do:
        return error substitute ("Ошибка при поиске склада с номером &1.", bf_clients.obj-code).
      end.
      assign varactive = bf_store.active.
    end.
    otherwise do:
      return error substitute ("Неверный тип объекта &1 документа.", bf_trn-doc.obj-type, bf_trn-doc.doc-code).
    end.
  end case.
  if varactive = ? then do:
     return error substitute ("Неизвестный признак '?' активности объекта &1 &2", bf_trn-doc.obj-type, bf_trn-doc.obj-code).
  end.
  if bf_trn-doc.internal = ? then do:
      return error substitute ("Неверный указан признак документа внешний/внутренний &1 - '?'.", bf_trn-doc.doc-code).
  end.
  if bf_trn-doc.flag_ = ? then do:
     return error substitute ("Неверный флаг документа &1 - '?'.", bf_trn-doc.doc-code).
  end.
  if bf_trn-doc.status_ = 'факт':U then do:
     return error substitute ("Документ &1 закрыт до факта. " + chr(10) + "Операции с ним не допустимы.", bf_trn-doc.doc-code).
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  bf_trn-doc.doc-code
  ,output p-is-hold
  )  .
  run str/trn-grfp.p (input  bf_trn-doc.doc-type,
                  input  bf_trn-doc.ext-doc-type,
                  input  bf_trn-doc.status_,
                  input  bf_trn-doc.flag_,
                  input  bf_trn-doc.internal,
                  input  parmode,
                  input  parcur-db-num,
                  input  bf_trn-doc.cr-db-num,
                  input  bf_cur-db.db-name,
                  input  bf_clients.db-num,
                  input  bf_db.db-name,
                  input  bf_clients.obj-type,
                  input  bf_clients.obj-code,
                  input  varactive,
                  input  p-is-hold ,
                  output parstatus,
                  output parflag,
                  output parcopystatus,
                  output parcopyflag) no-error.
  if error-status:error then do:
     return error substitute ("Ошибка:  &1"          + chr(10)
                              + "по операции: &2"        + chr(10)
                              + "номер документа &3" + chr(10)
                              + "тип &4"             + chr(10)
                              + "статус &5"          + chr(10)
                              + "флаг &6.",
                              return-value,
                              parmode,
                              bf_trn-doc.doc-code,
                              bf_trn-doc.doc-type,
                              bf_trn-doc.status_,
                              bf_trn-doc.flag_).
  end.
end.
