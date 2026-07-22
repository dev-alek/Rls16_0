block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.drt-prop.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи свойств шаблона правил скидок и расписаний".
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
      p-vss-parameters = substitute('&1|&2'
                         , ub.drt-prop.templ-rl-root
                         , ub.drt-prop.node-code
                         )
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable v-start-level as integer no-undo .
define variable level as integer no-undo .
define variable v-p as character no-undo .
define variable v-confirmed as logical no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  and g#db-num > 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись свойств ПРАВИЛ СКИДОК И РАСПИСАНИЙ в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news then do:
    assign
    v-start-level = 2
    .
    assign
      level = v-start-level
    .
    _repeat:
    repeat while program-name( level ) <> ? :
      v-p = program-name( level ).
      if substring(v-p, length(v-p) - length("disrul0.p") + 1) = "disrul0.p":U
      or substring(v-p, length(v-p) - length("disrul0.p") + 1) = "disrul0.r":U
      or substring(v-p, length(v-p) - length("distrul0.p") + 1) = "distrul0.p":U
      or substring(v-p, length(v-p) - length("distrul0.p") + 1) = "distrul0.r":U
      or substring(v-p, length(v-p) - length("fixdr.p") + 1) = "fixdr.p":U
      or substring(v-p, length(v-p) - length("fixdr.p") + 1) = "fixdr.r":U
      then do:
        v-confirmed = yes.
        leave _repeat.
      end.
      assign
        level = level + 1
      .
    end.
    if not v-confirmed then do:
      message
        vss-workfile vss-revision vss-description skip
        "Физическое удаление записи конфигурации скидок в системе запрещено" skip
        view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  run nws/cmd-del.p
    ( input 'drt-prop':U
     ,input (buffer ub.drt-prop:handle)
     ,input '':U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input 'delete':U
        , input 'drt-prop':U
        , input ( buffer ub.drt-prop:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.
