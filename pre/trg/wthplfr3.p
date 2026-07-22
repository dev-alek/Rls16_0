block-level on error undo, throw.
define input parameter parw-p-code      like ub.wth-place.w-p-code no-undo .
define input parameter parhost-code     like ub.wth-place.host-code no-undo .
define input parameter parobj-type      like ub.wth-place.obj-type no-undo .
define input parameter parobj-code      like ub.wth-place.obj-code  no-undo .
define input parameter parw-p-name      like ub.wth-place.w-p-name no-undo .
define input parameter par-status_      like ub.wth-place.status_  no-undo .
define input parameter parcash-desk     like ub.wth-place.cash-desk  no-undo .
define input parameter parmain-cash-desk like ub.wth-place.main-cash-desk  no-undo .
define input parameter par-PS            like ub.wth-place.ps  no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности при сохранении изменений в записи МХ МЦ".
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
DEFINE VARIABLE var-entry as character no-undo .
define buffer buf_clients  for ub.clients .
define buffer buf_wth-place for ub.wth-place .
FIND FIRST ub.sysconf No-LOCK WHERE
           ub.sysconf.host-code = parhost-code No-ERROR.
IF NOT AVAIL ub.sysconf THEN DO:
  MESSAGE "Не найдена фирма!"
  VIEW-AS ALERT-BOX ERROR.
  return error var-entry.
END.
FIND FIRST buf_clients No-LOCK WHERE
          buf_clients.obj-type = parobj-type AND
          buf_clients.obj-code = parobj-code NO-ERROR.
IF NOT AVAIL buf_clients or
  NOT  (buf_clients.obj-type = 'маг':U OR buf_clients.obj-type = 'скл':U) THEN DO:
  MESSAGE "Не найден или неверно определен объект!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry =  "obj-type":U.
  return error var-entry.
END.
if buf_clients.obj-type = 'скл':U then do:
  if parcash-desk <> 0 then do:
     message "Нельзя определить кассу как МХ МЦ для объекта типа склад"
     view-as alert-box error .
     var-entry = "cash-desk":U.
     return error var-entry.
  end.
end.
else do:
  if parcash-desk <>0 then do:
    FIND FIRST ub.cash-desk No-LOCK WHERE
               ub.cash-desk.db-num = buf_clients.db-num AND
              ub.cash-desk.obj-code = parobj-code AND
              ub.cash-desk.cash-num = parcash-desk No-ERROR.
    if not available ub.cash-desk then do:
      message "Не найдена касса N " parcash-desk "в магазине" parobj-code
      view-as alert-box error .
      var-entry = "cash-desk":U.
      return error var-entry.
    end.
    FIND FIRST buf_wth-place NO-LOCK WHERE
               buf_wth-place.host-code = parhost-code and
              buf_wth-place.obj-type = parobj-type and
              buf_wth-place.obj-code = parobj-code and
              buf_wth-place.cash-desk = parcash-desk and
              buf_wth-place.w-p-code <> parw-p-code No-ERROR.
    if available buf_wth-place then do:
      message
      "Касса" parcash-desk "магазина" parobj-code skip
      "уже привязана к МХ" buf_wth-place.w-p-code
      view-as alert-box .
      var-entry = "cash-desk":U.
      return error var-entry.
    end.
  end.
  if parmain-cash-desk = yes then do:
    FIND FIRST buf_wth-place NO-LOCK WHERE
               buf_wth-place.host-code = parhost-code and
              buf_wth-place.obj-type = parobj-type and
              buf_wth-place.obj-code = parobj-code and
              buf_wth-place.main-cash-desk = yes and
              buf_wth-place.w-p-code <> parw-p-code No-ERROR.
    if available buf_wth-place then do:
      message "Уже определена главная касса в магазине" parobj-code
      view-as alert-box error .
      var-entry = "main-cash-desk":U.
      return error var-entry.
    end.
  end.
end.
