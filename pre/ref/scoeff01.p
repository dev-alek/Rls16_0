block-level on error undo, throw.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter p-gds-code like ub.s-coeff.gds-code no-undo .
define input parameter p-host-code like ub.s-coeff.host-code no-undo .
define input parameter p-obj-type like ub.s-coeff.obj-type no-undo .
define input parameter p-obj-code like ub.s-coeff.obj-code no-undo .
define input parameter p-s-date like ub.s-coeff.s-date no-undo .
define input parameter p-coeff-value like ub.s-coeff.coeff-value no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scoeff01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/scoeff01.p $":U .
define variable vss-description as character no-undo init "Сезонный коэффициент для товара".
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
define variable var-entry as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_s-coeff for ub.s-coeff.
if par-mode <> 'ДОБАВЛЕНИЕ':U AND par-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.
if p-gds-code = 0
or not can-find(first ub.goods no-lock where
                      ub.goods.gds-code = p-gds-code)
then do:
  assign
  var-entry = "gds-code":U
  .
  message
  vss-workfile vss-revision vss-description skip
  "Укажите товар"
  view-as alert-box error .
  return error var-entry.
end.
if p-host-code <> 0 then do:
  find first buf_sysconf no-lock where
              buf_sysconf.host-code = p-host-code no-error .
  if not available buf_sysconf then do:
    assign
    var-entry = "host-code":U
    .
    message
    vss-workfile vss-revision vss-description skip
    "Укажите фирму"
    view-as alert-box error .
    return error var-entry.
  end.
end.
if p-obj-type <> "":u
or p-obj-code <> 0 then do:
  find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
      AND  buf_clients.obj-code = p-obj-code no-error .
  if not available buf_clients
  then do:
    assign
    var-entry = "obj-code":U
    .
    message
    vss-workfile vss-revision vss-description skip
    "Укажите объект"
    view-as alert-box error .
    return error var-entry.
  end.
  if LOOKUP(p-obj-type, ('маг':U + chr(44) + 'скл':U)) = 0 then do:
    assign
    var-entry = "obj-type":U
    .
    message
    vss-workfile vss-revision vss-description skip
    "Объект может быть только " 'маг':U "или"
    view-as alert-box error .
    return error var-entry.
  end.
end.
if p-coeff-value >= 100 then do:
  message
  "Значение сезонного коэффициента не может быть больше или равно 100"
  view-as alert-box error .
  assign
  var-entry = "obj-type":U
  .
  return error var-entry.
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
_main:
do
on error undo _main, return error
:
  CASE par-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
      find first buf_s-coeff no-lock where
                 buf_s-coeff.gds-code = p-gds-code
             AND buf_s-coeff.host-code = p-host-code
             AND buf_s-coeff.obj-type = p-obj-type
             AND buf_s-coeff.obj-code = p-obj-code
             AND buf_s-coeff.s-date = p-s-date
             no-error .
      if available buf_s-coeff then do:
        assign
        var-entry = "p-gds-code"
        .
        message
        "Для товара" p-gds-code skip
        "уже определен сезонный коэффициент" skip
        "фирма" p-host-code "объект" p-obj-type p-obj-code "дата" string(string(DAY(p-s-date)) + chr(47) + string(Month(p-s-date)))
        view-as alert-box error .
        return error var-entry.
      end.
      create ub.s-coeff.
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
      find first ub.s-coeff exclusive-lock where
                recid(ub.s-coeff) = par-rid no-error .
      if not available ub.s-coeff
      then do:
        assign
        var-entry = "gds-code":U
        .
        message
        "Не определен сезонный коэффициент для товара" p-gds-code skip
        "фирма" p-host-code "объект" p-obj-type p-obj-code "дата" string(string(DAY(p-s-date)) + chr(47) + string(Month(p-s-date)))
        view-as alert-box error .
        return error var-entry.
      end.
      IF ub.s-coeff.host-code <> p-host-code
      OR ub.s-coeff.obj-type <> p-obj-type
      OR ub.s-coeff.obj-code <> p-obj-code
      then do:
        assign
        var-entry = "obj-code":U
        .
        message
        "Нельзя изменить фирму и/или объект, для которого определен сезонный коэффициент"  skip
        "товар" p-gds-code skip
        "фирма" p-host-code "объект" p-obj-type p-obj-code "дата" string(string(DAY(p-s-date)) + chr(47) + string(Month(p-s-date)))
        view-as alert-box error .
        return error var-entry.
      end.
      IF ub.s-coeff.gds-code <> p-gds-code
      then do:
        assign
        var-entry = "gds-code":U
        .
        message
        "Нельзя изменить товар, для которого определен сезонный коэффициент"  skip
        "группа" p-gds-code skip
        "фирма" p-host-code "объект" p-obj-type p-obj-code "дата" string(string(DAY(p-s-date)) + chr(47) + string(Month(p-s-date)))
        view-as alert-box error .
        return error var-entry.
      end.
    end.
  END CASE.
  assign
  ub.s-coeff.gds-code = p-gds-code
  ub.s-coeff.host-code = p-host-code
  ub.s-coeff.obj-type = p-obj-type
  ub.s-coeff.obj-code = p-obj-code
  ub.s-coeff.s-date = p-s-date
  ub.s-coeff.coeff-value = p-coeff-value
  ub.s-coeff.credate = today
  ub.s-coeff.creid = G#userid
  par-rid = recid(ub.s-coeff)
  .
  release ub.s-coeff no-error .
  if error-status:error then do:
    message
    "Ошибка при сохранении записи СЕЗОННОГО КОЭФФИЦИЕНТА"
    "товар" p-gds-code skip
    "фирма" p-host-code "объект" p-obj-type p-obj-code "дата" string(string(DAY(p-s-date)) + chr(47) + string(Month(p-s-date))) skip
    ERROR-STATUS:GET-message(1) skip
    return-value
     view-as alert-box error.
  undo, return error "":U.
 end.
end.
