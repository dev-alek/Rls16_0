block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ef-serv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ef-serv.p $":U .
define variable vss-description as character no-undo init "Обслуживание мобильного блока EasyFuel".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable v-operations as character no-undo .
define variable v-operation-codes as character no-undo .
define variable v-selected-operation as character no-undo .
define variable v-operation-name as character no-undo .
define variable v-run-file-name as character no-undo .
define variable v-can-init as logical no-undo .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_easyfuel_initialization':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-can-init
    )  .
end.
assign
v-operations = "":U
v-operation-codes = "":U
v-selected-operation = "start"
.
if v-can-init then do:
  assign
  v-operations = "Первоначальная прошивка в МБ данных транспортного средства и лимитов" + chr(4) +
                "Изменение номера и марки трансп. средства" + chr(4) +
                "Изменение топлив, привязанных к МБ и их лимитов" + chr(4) +
                "Восстановление данных на МБ согласно данным, хранящимся в системе"  + chr(4) +
                "Считывание данных с МБ и сравнение их с хранящимися в системе"
  v-operation-codes  = "initialize" + chr(4) +
                       "reg-num" + chr(4) +
                       "petrol" + chr(4) +
                       "restore" + chr(4) +
                       "read"
  .
end.
else do:
  assign
  v-operations = "Считывание данных с МБ и сравнение их с хранящимися в системе"
  v-operation-codes  = "read"
  .
end.
do while v-selected-operation <> "":
  run gbl/d-list.w (
                INPUT "b-sel":U
                ,INPUT "Выберите операцию с МБ EasyFuel"
                ,INPUT v-operation-codes
                ,INPUT v-operations
                ,INPUT chr(4)
                ,INPUT "":U
                ,output v-selected-operation).
  IF v-selected-operation = "":u THEN do:
    RETURN "".
  end.
  assign
  v-operation-name = entry(lookup(v-selected-operation, v-operation-codes, chr(4)) , v-operations, chr(4))
  .
  case v-selected-operation:
    when "" then do:
      return ''.
    end.
    when "initialize" then do:
      v-run-file-name = "utl/ef-init.p".
    end.
    when "reg-num" then do:
      v-run-file-name = "utl/efregnum.p".
    end.
    when "petrol" then do:
      v-run-file-name = "utl/eflimits.p".
    end.
    when "restore" then do:
    end.
    when "read" then do:
      v-run-file-name = "utl/ef-read.p".
    end.
  end case.
  if v-run-file-name = "" then do:
    message
    "under construction"
    view-as alert-box .
  end.
  else do:
    run str/diallog.w ( input parparentproc
                , input this-procedure
                , input v-run-file-name
                , input ""
                , input yes
                , input ''
                , input v-operation-name) no-error .
    if error-status:error
    or return-value = "error"
    then do:
      message
      substitute("Ошибки при выполнение операции &1:&2" +
                  "&3&2&4"
                  , v-operation-name
                  , chr(10)
                  , error-status:get-message(1)
                  , return-value )
      view-as alert-box error .
    end.
  end.
end.
