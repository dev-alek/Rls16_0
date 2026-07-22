block-level on error undo, throw.
define input-output parameter p-rec as recid no-undo.
define input parameter        p-mode             as character no-undo .
define input parameter        p-OKEI           like ub.units.OKEI no-undo .
define input parameter        p-long-name      like ub.units.long-name no-undo .
define input parameter        p-type           like ub.units.type no-undo .
define input parameter        p-unit-name      like ub.units.unit-name  no-undo .
define variable vss-revision    as character no-undo init "$Revision: ce1e41b5e8d1, 1173, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:20:27 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: units01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/units01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке единицы измерени".
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
define variable v-log         as logical   no-undo .
define buffer buf_units for ub.units.
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.
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
run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
if v-value = "no"  then do:
if v-db-num <> 0
then do:
  run err-mess (substitute("Нельзя изменять запись ЕД.ИЗМ в УБД: Номер текущей БД &1 ", v-db-num ) ).
  undo, return error "":U.
end.
end.
if p-long-name = "":U then do:
  run err-mess ("Укажите полное наименование ед.изм").
  undo, return error "long-name":U.
end.
if p-unit-name = "":U or p-unit-name = ? then do:
  run err-mess ("Укажите аббревиатуру ед.изм").
  undo, return error "unit-name":U.
end.
if
can-find(first buf_units no-lock where
                  buf_units.unit-name = p-unit-name
              AND (p-mode = 'ДОБАВЛЕНИЕ':U OR p-rec <> recid(buf_units))
              ) then do:
  run err-mess (substitute("Уже есть такая ЕД.ИЗМ &1", p-unit-name) ).
  return error "unit-name":U.
end.
if LOOKUP(entry(1, p-type),  'шту,дро,сер,вес,топ,сте':U) = 0 then do:
  run err-mess (substitute("Неверный тип единицы измерения &1: &2", p-unit-name, entry(1, p-type)) ).
  return error "type":U.
end.
if num-entries(p-type) > 1 then do:
  if LOOKUP(entry(2, p-type),  'шту':U + chr(44) + 'дро':U + chr(44) + '2ед':U + chr(44) + 'доп':U) = 0  then do:
    run err-mess (substitute("Неверный тип2 единицы измерения &1: &2", p-unit-name, entry(2, p-type)) ).
    return error "type":U.
  end.
end.
if p-OKEI <> 0
and
can-find(first buf_units no-lock where
                  buf_units.OKEI = p-OKEI
              AND (p-mode = 'ДОБАВЛЕНИЕ':U OR p-rec <> recid(buf_units))
              ) then do:
                if v-value = "no" then do:
    message substitute("Уже есть  ЕД.ИЗМ &1 c таким же кодом ОКЕИ &2", p-unit-name, p-okei) skip "Добавить?" view-as alert-box information buttons YES-NO update v-log.
    if v-log = no then do:
      return error "okei":U.
    end.
    end.
    else do:
      run err-mess (substitute("Уже есть  ЕД.ИЗМ &1 c таким же кодом ОКЕИ &2", p-unit-name, p-okei) ).
    end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.units.
    assign
    ub.units.unit-name = p-unit-name
    p-rec = recid(ub.units)
    .
  end.
  else do:
    FIND FIRST ub.units where
              recid(ub.units) = p-rec No-ERROR.
    if not available ub.units then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ед.изм - p-rec" p-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.units.unit-name <> p-unit-name
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся ЕД.ИЗМ. нельзя изменить аббревиатуру" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.units.unit-name = p-unit-name
  ub.units.long-name  = p-long-name
  ub.units.type       = p-type
  ub.units.OKEI       = p-OKEI
  ub.units.stts    =  (if p-mode = 'ДОБАВЛЕНИЕ':U
                             then 0
                             else ub.units.stts)
  .
  release ub.units no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи ЕД.ИЗМ &1: &2: &3", p-unit-name, return-value, ERROR-STATUS:GET-message(1))).
    undo, return error "":U.
 end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  if v-value = "yes" then do:
    p-mess .
  end.
  else do:
      message
      p-mess
      view-as alert-box error .
  end.
END PROCEDURE.
