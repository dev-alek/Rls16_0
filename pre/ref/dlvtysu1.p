block-level on error undo, throw.
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-deliv-type-code like ub.delivery-type-subject.deliv-type-code no-undo .
define input parameter p-deliv-subj-code like ub.delivery-type-subject.deliv-subj-code no-undo .
define input parameter p-des like ub.delivery-type-subject.des no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dlvtysu1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dlvtysu1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке типа доставки от субъекта".
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
define buffer buf_delivery-type  for ub.delivery-type.
define buffer buf_delivery-type-subject  for ub.delivery-type-subject.
define buffer buf_delivery-subject  for ub.delivery-subject.
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
  run err-mess (substitute("Нельзя изменять запись ТИП ДОСТАВКИ ОТ СУБЪЕКТА в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.
find first buf_delivery-type no-lock where
            buf_delivery-type.deliv-type-code = p-deliv-type-code  no-error .
if not available buf_delivery-type then do:
  run err-mess (substitute("Неправильная ссылка на ТИП ДОСТАВКИ, код типа доставки: &1"
                , p-deliv-type-code) ).
  undo, return error "deliv-type-code":U.
end.
find first buf_delivery-subject no-lock where
            buf_delivery-subject.deliv-subj-code = p-deliv-subj-code  no-error .
if not available buf_delivery-subject then do:
  run err-mess (substitute("Неправильная ссылка на СУБЪЕКТ ДОСТАВКИ, код субъекта доставки: &1"
                , p-deliv-subj-code) ).
  undo, return error "deliv-subj-code":U.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  find first buf_delivery-type-subject no-lock where
            buf_delivery-type-subject.deliv-type-code = p-deliv-type-code
        AND buf_delivery-type-subject.deliv-subj-code = p-deliv-subj-code
              no-error .
  if available buf_delivery-type-subject then do:
    run err-mess (substitute("Уже есть запись ТИПА ДОСТАВКИ ОТ СУБЪЕКТА, у которой код типа доставки: &1 и код субъекта доставки: &2"
                  , p-deliv-type-code
                  , p-deliv-subj-code) ).
    undo, return error "deliv-type-code":U.
  end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.delivery-type-subject.
    assign
    ub.delivery-type-subject.deliv-type-code = p-deliv-type-code
    ub.delivery-type-subject.deliv-subj-code = p-deliv-subj-code
    p-doc-rec = recid(ub.delivery-type-subject)
    .
  end.
  else do:
    FIND FIRST ub.delivery-type-subject where
              recid(ub.delivery-type-subject) = p-doc-rec No-ERROR.
    if not available ub.delivery-type-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ТИП ДОСТАВКИ ОТ СУБЪЕКТА - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.delivery-type-subject.deliv-type-code <> p-deliv-type-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код типа доставки" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
    if ub.delivery-type-subject.deliv-subj-code <> p-deliv-subj-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код субъекта доставки" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.delivery-type-subject.des                 = p-des
  ub.delivery-type-subject.sts                 =  (if p-mode = 'ДОБАВЛЕНИЕ':U
                             then 0
                             else ub.delivery-type-subject.sts)
  .
  release ub.delivery-type-subject no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи ТИП ДОСТАВКИ ОТ СУБЪЕКТА: тип доставки &1, код субъекта &2 : &3: &4"
                             , p-deliv-type-code
                             , p-deliv-subj-code
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo, return error "":U.
 end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.
