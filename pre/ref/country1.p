block-level on error undo, throw.
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-alpha1          like ub.country.alpha1 no-undo .
define input parameter p-alpha2          like ub.country.alpha1 no-undo .
define input parameter p-num-code        like ub.country.num-code no-undo .
define input parameter p-short-name      like ub.country.short-name no-undo .
define input parameter p-long-name       like ub.country.long-name no-undo .
define variable vss-revision    as character no-undo init "$Revision: 1e1fd253f7ac, 1111, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: country1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/country1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке страны".
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
define variable v-msg as character no-undo.
define shared variable g#esys as logical no-undo.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  run err-mess (string (vss-workfile + vss-revision + vss-description + chr(10) +
    "Неверный параметр p-mode" + p-mode) ).
  return error v-msg + '':u.
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-db-num <> 0 then do:
  run err-mess (substitute("Нельзя изменять запись СТРАНЫ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error v-msg + "":U.
end.
if p-short-name = "":U
then do:
  run err-mess ("Короткое название СТРАНЫ не может быть пустым").
  undo, return error v-msg + "short-name":U.
end.
if p-long-name = "":U
then do:
  run err-mess ("Длинное название СТРАНЫ не может быть пустым").
  undo, return error v-msg + "short-name":U.
end.
if p-num-code = 0
or p-num-code = ?
then do:
  run err-mess ("Цифровой код СТРАНЫ не может равняться 0").
  undo, return error v-msg + "num-code":U.
end.
if p-alpha1 = "":U
then do:
  run err-mess ("Буквенный код СТРАНЫ не может быть пустым").
  undo, return error v-msg + "alpha1":U.
end.
if p-alpha2 = "":U
then do:
  run err-mess ("Буквенный код СТРАНЫ не может быть пустым").
  undo, return error v-msg + "alpha2":U.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if can-find(first ub.country no-lock where ub.country.alpha1 = p-alpha1) then do:
    run err-mess (substitute("Уже есть страна с буквенным кодом -1, равным &1", p-alpha1)).
    undo, return error v-msg + "alpha2":U.
  end.
  if can-find(first ub.country no-lock where ub.country.alpha1 = p-alpha2) then do:
    run err-mess (substitute("Уже есть страна с буквенным кодом - 2, равным &1", p-alpha2)).
    undo, return error v-msg + "alpha2":U.
 end.
  if can-find(first ub.country no-lock where ub.country.num-code = p-num-code) then do:
    run err-mess (substitute("Уже есть страна с цифровым кодом, равным &1", p-num-code)).
    undo, return error v-msg + "num-code":U.
 end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.country.
    assign
    ub.country.alpha1 = p-alpha1
    ub.country.num-code = p-num-code
    p-doc-rec = recid(ub.country)
    .
  end.
  else do:
    FIND FIRST ub.country where
              recid(ub.country) = p-doc-rec No-ERROR.
    if not available ub.country then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись СТРАНЫ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error v-msg + '':u.
    end.
    if ub.country.alpha1 <> p-alpha1
    or ub.country.num-code <> p-num-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "цифровой код и/или буквенный код - 1" skip
      view-as alert-box ERROR.
      undo, return error v-msg + '':U.
    end.
  end.
  assign
  ub.country.alpha2     = p-alpha2
  ub.country.short-name = p-short-name
  ub.country.long-name  = p-long-name
  .
  release ub.country no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи СТРАНЫ с буквенным кодом &1: &2: &3"
                             , p-alpha1
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo, return error v-msg + "":U.
 end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  if not g#esys
    then
      message
      p-mess
      view-as alert-box error .
    else v-msg = p-mess.
END PROCEDURE.
