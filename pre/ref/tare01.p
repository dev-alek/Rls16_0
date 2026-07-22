block-level on error undo, throw.
define input-output parameter p-rec as recid no-undo.
define input parameter        p-silent         as logical no-undo .
define input parameter        p-mode             as character no-undo .
define input parameter        p-tare-name      like ub.tare.tare-name no-undo .
define input parameter        p-tare-code      like ub.tare.tare-code  no-undo .
define input parameter        p-key#_one       as integer no-undo .
define input parameter        p-key#_two       as integer no-undo .
define input parameter        p-charkey_one    as character no-undo .
define input parameter        p-charkey_two    as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tare01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/tare01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке ТАРЫ".
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
define variable v-log         as logical   no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_tare for ub.tare.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-db-num <> 0
then do:
  v-err-mess = substitute("Нельзя изменять запись ТАРЫ в УБД: Номер текущей БД &1 ", v-db-num ).
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "":U).
end.
if p-tare-name = "":U then do:
  v-err-mess = substitute("Не указано полное наименование тары" ).
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "tare-name":U).
end.
if p-tare-code = "":U
or p-tare-code = ?
then do:
  v-err-mess = "Не указан код (аббревиатура) тары".
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "tare-code":U).
end.
if trim(p-tare-code) <> p-tare-code
then do:
  v-err-mess = "В коде (аббревиатуре) тары присутствуют недопустимые символы".
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "tare-code":U).
end.
if can-find(first buf_tare no-lock where
                  buf_tare.tare-code = p-tare-code
              AND (p-mode = 'ДОБАВЛЕНИЕ':U OR p-rec <> recid(buf_tare))
              ) then do:
  v-err-mess = substitute("Уже есть такая ТАРА &1", p-tare-code).
  run err-mess in this-procedure ( input-output v-err-mess).
  undo, return error (if p-silent then v-err-mess else "tare-code":U).
end.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create buf_tare.
    assign
    buf_tare.tare-code = p-tare-code
    .
  end.
  else do:
    FIND FIRST buf_tare where
              recid(buf_tare) = p-rec No-ERROR.
    if not available buf_tare then do:
      v-err-mess = substitute("&1 &2 &3&4Не найдена запись ТАРЫ - p-rec=&5"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              , chr(10)
                              ,p-rec).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
    if buf_tare.tare-code <> p-tare-code
    then do:
      v-err-mess = substitute("&1 &2 &3&4Для уже имеющейся записи нельзя изменить код тары&4ранее был &5 - попытка изменить на &6"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              , chr(10)
                              ,buf_tare.tare-code
                              ,p-tare-code
                               ).
      run err-mess in this-procedure ( input-output v-err-mess).
      undo main-block, return error (if p-silent then v-err-mess else "":U).
    end.
  end.
  assign
  buf_tare.tare-code = p-tare-code
  buf_tare.tare-name  = p-tare-name
  buf_tare.key#_one = p-key#_one
  buf_tare.key#_two = p-key#_two
  buf_tare.charkey_one = p-charkey_one
  buf_tare.charkey_two = p-charkey_two
  buf_tare.stts    =  (if p-mode = 'ДОБАВЛЕНИЕ':U
                             then 0
                             else buf_tare.stts)
  p-rec = recid(buf_tare)
  .
  release buf_tare no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при попытке сохранения записи:&1&2&1&3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    undo main-block, return error (if p-silent then v-err-mess else "":U).
  end.
end.
PROCEDURE err-mess:
DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
if p-silent then do:
  assign
  p-mess = substitute("ТАРА: код &1&2:&3"
                      , (if p-mode = 'ДОБАВЛЕНИЕ':U or not available buf_tare then p-tare-code else buf_tare.tare-code)
                      , chr(10)
                      , p-mess)
  .
end.
else do:
  message
  p-mess
  view-as alert-box error .
end.
END PROCEDURE.
