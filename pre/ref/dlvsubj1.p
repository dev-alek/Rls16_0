block-level on error undo, throw.
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-deliv-subj-code like ub.delivery-subject.deliv-subj-code no-undo .
define input parameter p-deliv-subj-name like ub.delivery-subject.deliv-subj-name no-undo .
define input parameter p-reg-code        like ub.delivery-subject.reg-code no-undo .
define input parameter p-des like ub.delivery-subject.des no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dlvsubj1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dlvsubj1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке субъекта доставки".
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
define buffer buf_regions for ub.regions.
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
if v-db-num <> 0 then do:
  run err-mess (substitute("Нельзя изменять запись СУБЪЕКТ ДОСТАВКИ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.
if p-deliv-subj-name = "":U then do:
  run err-mess in this-procedure ( input "Название СУБЪЕКТА ДОСТАВКИ не может быть пустым").
  return error "deliv-subj-name":U.
end.
if p-reg-code <> 0 then do:
  find first buf_regions no-lock where
            buf_regions.reg-code = p-reg-code no-error.
  if not available buf_regions then do:
    run err-mess in this-procedure (input substitute("Не найден регион с кодом &1", p-reg-code)).
    return error "deliv-subj-name":U.
  end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.delivery-subject.
    assign
    ub.delivery-subject.deliv-subj-code = next-value(delivery, ub)
    p-doc-rec = recid(ub.delivery-subject)
    .
  end.
  else do:
    FIND FIRST ub.delivery-subject where
              recid(ub.delivery-subject) = p-doc-rec No-ERROR.
    if not available ub.delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СУБЪЕКТ ДОСТАВКИ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo _main, return error '':u.
    end.
    if ub.delivery-subject.deliv-subj-code <> p-deliv-subj-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код" skip
      view-as alert-box ERROR.
      undo _main, return error '':U.
    end.
  end.
  assign
  ub.delivery-subject.deliv-subj-name     = p-deliv-subj-name
  ub.delivery-subject.des                 = p-des
  ub.delivery-subject.reg-code            = p-reg-code
  ub.delivery-subject.sts                 =  (if p-mode = 'ДОБАВЛЕНИЕ':U
                                              then 0
                                              else ub.delivery-subject.sts)
  .
  release ub.delivery-subject no-error.
  if error-status:error then do:
     run err-mess in this-procedure ( input
                                           substitute("Ошибка при сохранении записи СУБЪЕКТ ДОСТАВКИ с кодом &1: &2: &3"
                                                      , p-deliv-subj-code
                                                      , ERROR-STATUS:GET-message(1)
                                                      , return-value
                                                      )
                   ).
    undo _main, return error "":U.
 end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.
