block-level on error undo, throw.
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-silent                       as logical no-undo .
define input parameter p-verify          as character no-undo .
define input parameter p-host-code       like ub.fin-schet.host-code no-undo .
define input parameter p-code-schet      like ub.fin-schet.code-schet no-undo .
define input parameter p-c-schet         like ub.fin-schet.c-schet   no-undo .
define input parameter p-cli-type        like ub.fin-schet.cli-type  no-undo .
define input parameter p-cli-code        like ub.fin-schet.cli-code  no-undo .
define input parameter p-code-bank       like ub.fin-schet.code-bank no-undo .
define input parameter p-curr-code       like ub.fin-schet.curr-code no-undo .
define input parameter p-dop1            like ub.fin-schet.dop1      no-undo .
define input parameter p-dop2            like ub.fin-schet.dop2      no-undo .
define input parameter p-r-schet         like ub.fin-schet.r-schet   no-undo .
define input parameter p-PS              like ub.fin-schet.PS        no-undo .
define variable vss-revision    as character no-undo init "$Revision: 70a347534c9d, 1171, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:20:27 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finscht1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finscht1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке банковского счета".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-correct-schet as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v1-mainholder as character no-undo .
define variable v2-mainholder as character no-undo .
define variable v1type as character no-undo .
define variable v2type as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_schet-clients for ub.clients.
define buffer buf_currency for ub.currency.
define buffer buf-db_fin-schet for ub.fin-schet.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if num-entries(p-dop1, chr(4) ) > 1 then do:
  v-dop1 = entry(2, p-dop1, chr(4) ).
  p-dop1 = entry(1, p-dop1, chr(4) ).
end.
find first buf_sysconf no-lock where
                buf_sysconf.host-code = p-host-code.
if not avail buf_sysconf then dO:
  v-err-mess = substitute("Не найдена фирма с кодом &1", p-host-code).
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'host-code':U).
end.
run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
if v-value = "no"  then
do:
if v-db-num <> buf_sysconf.firm-db-num
then do:
  v-err-mess = substitute("Нельзя изменять запись БАНКОВСКОГО СЧЕТА в БД, отличной от главной БД фирмы:&1" +
                           "Номер текущей БД &2 Номер главной БД фирмы &3"
                           , chr(10)
                           , v-db-num
                           , buf_sysconf.firm-db-num) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'host-code':U).
end.
end.
find first buf_fin-bank no-lock where
                  buf_fin-bank.host-code = p-host-code
              AND buf_fin-bank.code-bank = p-code-bank no-error .
if not available buf_fin-bank then do:
  v-err-mess = substitute("Не найден банк вн№ &1 в фирме &2", p-code-bank, p-host-code) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'code-bank':U).
end.
if lookup("r-schet", p-verify) > 0 then do:
run gbl/keyschet.p (
                 input p-r-schet
                ,input buf_fin-bank.bik
                ,input p-curr-code
                ,input (if substring(buf_fin-bank.bik, 7, 3) = '000'
                        or substring(buf_fin-bank.bik, 7, 3) = '001'
                        or substring(buf_fin-bank.bik, 7, 3) = '002'
                        then no
                        else yes)
                ,output v-correct-schet
              )  no-error.
if error-status:error then do:
  v-err-mess = substitute("Ошибка при проверке валидности расчетного счета &1: &2", p-r-schet, ERROR-STATUS:GET-message(1)) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error "r-schet":U.
end.
if not v-correct-schet then do:
  v-err-mess = substitute("Неверный расчетный счет &1: &2", p-r-schet, return-value) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
end.
end.
if not can-find(first buf_currency no-lock where
                  buf_currency.curr-code = p-curr-code
                            ) then do:
  v-err-mess = substitute("Не найдена валюта с кодом &1", p-curr-code) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'curr-code':U).
end.
if not can-find(first buf_schet-clients no-lock where
                  buf_schet-clients.obj-type = p-cli-type
              AND buf_schet-clients.obj-code = p-cli-code
              ) then do:
  v-err-mess = substitute("Не найден контрагент &1&2", p-cli-type, p-cli-code) .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'cli-code':U).
end.
if p-r-schet = "":U then do:
  v-err-mess = "Поле РАСЧЕТНЫЙ СЧЕТ не может быть пустым" .
  run err-mess in this-procedure ( input-output v-err-mess ).
  undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.fin-schet.
    assign
    ub.fin-schet.host-code = p-host-code
    ub.fin-schet.code-schet = next-value(s-fin-schet, ub)
    p-doc-rec = recid(ub.fin-schet)
    .
  end.
  else do:
    FIND FIRST ub.fin-schet where
              recid(ub.fin-schet) = p-doc-rec No-ERROR.
    if not available ub.fin-schet then do:
      v-err-mess = substitute("&1 &2 &3&4Не найдена запись банковского счета - p-doc-rec=&5"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,chr(10)
                              ,p-doc-rec).
      run err-mess in this-procedure ( input-output v-err-mess ).
      undo _main, return error (if p-silent = yes then v-err-mess else '':U).
    end.
    if ub.fin-schet.host-code <> p-host-code
    OR ub.fin-schet.code-schet <> p-code-schet then do:
      v-err-mess = "Для уже имеющейся записи нельзя изменить код фирмы и код счета" .
      run err-mess in this-procedure ( input-output v-err-mess ).
      undo _main, return error (if p-silent = yes then v-err-mess else '':U).
    end.
    if ub.fin-schet.cli-type <> p-cli-type
    OR ub.fin-schet.cli-code <> p-cli-code then do:
      v-err-mess = "Для уже имеющейся записи нельзя изменить держателя счета" .
      run err-mess in this-procedure ( input-output v-err-mess ).
      undo _main, return error (if p-silent = yes then v-err-mess else '':U).
    end.
  end.
    run clntattr-value in this-procedure (
        input p-cli-type,
        input p-cli-code,
        input 'main-accholder':U,
        output v1-mainholder,
        output v1type)
    no-error.
    for each buf-db_fin-schet where buf-db_fin-schet.host-code = p-host-code and
                                      buf-db_fin-schet.r-schet = p-r-schet and
                                      buf-db_fin-schet.code-bank = p-code-bank and
                                      buf-db_fin-schet.status_ = 'тек':U
                                and (p-mode = 'ДОБАВЛЕНИЕ':U or (p-mode = 'ИЗМЕНЕНИЕ':U and ub.fin-schet.status_ = 'тек':U)):
    if buf-db_fin-schet.code-schet = p-code-schet then next.
    run clntattr-value in this-procedure (
        input buf-db_fin-schet.cli-type,
        input buf-db_fin-schet.cli-code,
        input 'main-accholder':U,
        output v2-mainholder,
        output v2type)
    no-error.
    if buf-db_fin-schet.cli-type = p-cli-type
        and buf-db_fin-schet.cli-code = p-cli-code
    then
        do:
            v-err-mess = substitute("Для клиена &6,&7 уже заведен счёт &1 по фирме &2 в том же банке." +
                "&3Вн.номер счета = &4" +
                "&3Доп.назв.держ.счёта = &5",
                p-r-schet,
                p-host-code,
                chr(10),
                buf-db_fin-schet.code-schet,
                buf-db_fin-schet.dop1,
                buf-db_fin-schet.cli-type,
                buf-db_fin-schet.cli-code
                ).
            run err-mess in this-procedure (input-output v-err-mess).
            undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
        end.
    if p-dop1 <> '':U
        and buf-db_Fin-schet.dop1 = '':U
        and  v1-mainholder <> '':U
        and v1-mainholder = buf-db_fin-schet.cli-type + "," + string(buf-db_fin-schet.cli-code)
        and v2-mainholder = '':U
    then
        do:
            next.
        end.
    if p-dop1 = ''
        and v1-mainholder = ''
        and v2-mainholder <> '':U and v2-mainholder = string(p-cli-type + "," + string(p-cli-code))
        and buf-db_Fin-schet.dop1 <> '':U
    then
        do:
            next.
        end.
    if p-dop1 <> ''
        and buf-db_Fin-schet.dop1 <> ''
        and p-dop1 <> buf-db_Fin-schet.dop1
        and v1-mainholder <> '':U
        and v1-mainholder = v2-mainholder
    then
        do:
            next.
        end.
    v-err-mess = substitute("Уже есть расчетный счет &1 по фирме &2 в том же банке." +
        "&3Вн.номер счета = &4" +
        (if v1-mainholder <> ''
            and v1-mainholder = v2-mainholder
            and buf-db_Fin-schet.dop1 <> ''
            and buf-db_Fin-schet.dop1 = p-dop1
            then
                "&3Объект = &6,&7" +
                "&3Доп.назв.держ.счёта = &5"
            else ""),
        p-r-schet,
        p-host-code,
        chr(10),
        buf-db_fin-schet.code-schet,
        buf-db_fin-schet.dop1,
        buf-db_fin-schet.cli-type,
        buf-db_fin-schet.cli-code
        ).
    run err-mess in this-procedure (input-output v-err-mess).
    undo, return error (if p-silent = yes then v-err-mess else 'r-schet':U).
end.
  assign
  ub.fin-schet.c-schet   = p-c-schet
  ub.fin-schet.cli-type  = p-cli-type
  ub.fin-schet.cli-code  = p-cli-code
  ub.fin-schet.code-bank = p-code-bank
  ub.fin-schet.curr-code = p-curr-code
  ub.fin-schet.dop1      = p-dop1
  ub.fin-schet.dop2      = p-dop2
  ub.fin-schet.r-schet   = p-r-schet
  ub.fin-schet.PS        = p-PS
  ub.fin-schet.status_   = (if p-mode = 'ДОБАВЛЕНИЕ':U
                            then 'тек':U
                            else ub.fin-schet.status_)
  .
  release ub.fin-schet no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при сохранении записи БАНКОВСКОГО СЧЕТА &1: &2", ERROR-STATUS:GET-NUMBER(1), return-value ) .
    run err-mess in this-procedure ( input-output v-err-mess ).
    undo _main, return error (if p-silent = yes then v-err-mess else '':U).
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("Счет вн.№ &1: фирма: &2:&3&4"
                         , p-code-schet
                         , p-host-code
                         , chr(10)
                         , p-mess
                         ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
