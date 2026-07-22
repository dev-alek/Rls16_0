block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clearrtd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/clearrtd.p $":U .
define variable vss-description as character no-undo init "Очистка мусора в таблица маршрутизации".
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-ind-av as integer   no-undo .
  define variable v-ind-d  as integer   no-undo .
  define frame f-info
    v-ind-av label "Просмотрено" format ">>>>>>>>>9" skip
    v-ind-d  label "Удалено"     format ">>>>>>>>>9" skip
    with view-as dialog-box side-labels 1 columns three-d title "Очистка таблиц маршрутизации"
  .
  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
      view-as alert-box error
    .
    return error .
  end.
  assign
    v-ind-av = 0
    v-ind-d  = 0
  .
  view frame f-info .
  for each route-dump exclusive-lock
  on error undo, next
  :
    assign
      v-ind-av = v-ind-av + 1
    .
    pause 0.
    display
      v-ind-av
      v-ind-d
      with frame f-info.
    find first route exclusive-lock
      where route.dump-ord = route-dump.dump-ord
      no-error.
    if not available route then do:
      for each route-dump-link exclusive-lock
        where route-dump-link.dump-ord = route-dump.dump-ord
          and route-dump-link.rec-ord  = route-dump.rec-ord
      on error undo, return error
      :
        delete route-dump-link.
      end.
      delete route-dump.
      assign
        v-ind-d = v-ind-d + 1
      .
    end.
  end.
  hide frame f-info NO-PAUSE.
  message
    substitute( "Просмотрено записей: &1", v-ind-av ) skip
    substitute( "Удалено записей: &1", v-ind-d ) skip
    view-as alert-box information.
  return .
end.
