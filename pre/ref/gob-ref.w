define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Справочник товаров - режим товары на объекте".
DEFINE INPUT        PARAMETER parParentProc   AS   WIDGET-HANDLE       NO-UNDO.
DEFINE INPUT        PARAMETER bttns           AS   CHARACTER           NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-stat          AS   CHARACTER           NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-list          AS   CHARACTER           NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-cond          AS   CHARACTER           NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-rep           AS   RECID               NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER g-grp           LIKE ub.goods.grp-name   NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-producer-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-producer-code LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-obj-type      LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-obj-code      LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-gds-name-width as decimal              NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-grp-name-width as decimal              NO-UNDO.
define input-output parameter p-other as character no-undo .
define input-output parameter rid-list as character no-undo.
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
      p-vss-parameters = substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5|&6':u,parParentProc,bttns,g-stat,g-list,g-cond,g-rep),substitute('&1|&2|&3|&4|&5|&6':u,g-grp,p-producer-type,p-producer-code,p-obj-type,p-obj-code,p-other))
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
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
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable v-curr-r-b as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdshattr-name :
define input  parameter p-code           as character no-undo .
define output parameter p-type           as character no-undo .
define output parameter p-format         as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-tooltip :
define input  parameter p-code    as character no-undo .
define output parameter p-tooltip as character no-undo .
define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-value :
define input  parameter p-code as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as int no-undo .
define input  parameter p-gds-code as int no-undo .
define output parameter p-value as character no-undo .
define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-value in g#attr-lib
    (input  p-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure gdshattr-h-value :
define input  parameter p-code as character no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-gds-code as int no-undo .
define output parameter p-value as character no-undo .
define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-h-value in g#attr-lib
    (input  p-code
    ,input  p-host-code
    ,input  p-gds-code
    ,output p-value
    ,output p-type
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure gdshattr-write :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define input parameter p-value    like ub.gds-host-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-EXIST :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define OUTPUT parameter p-EXIST   AS LOGICAL no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-DELETE :
define input parameter p-gds-code like ub.gds-host-attr.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type   no-undo .
define input parameter p-obj-code like ub.clients.obj-code   no-undo .
define input parameter p-code     like ub.gds-host-attr.attr-code  no-undo .
define output parameter p-DELETED  AS LOGICAL no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-news :
define input  parameter p-code           as character no-undo .
define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-news in g#attr-lib
      (
       input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gdshattr-copy :
define input  parameter p-code           as character no-undo .
define output parameter p-copy           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdshattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.
procedure uf-name :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .
  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .
  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
    case p-code :
            when 'cli-all-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'oldscode':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника неиспользуемых весовых кодов"     p-tooltip = "Настройки справочника неиспользуемых весовых кодов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-ref-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(8)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = yes      p-label = "Параметры вызова справочника товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп товаров"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fbr-gds-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп блюд"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп блюд"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-grp-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника групп клиентов"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника групп клиентов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findoci-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'findocs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника платежей"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-obi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова карточки платежа"     p-tooltip = "Параметры по умолчанию, используемые для вызова карточки платежа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'seqeallo':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Порядок колонок в АВТО-ЗАКАЗЕ"     p-tooltip = "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'skm-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова выгрузки файла данных по продажам по СКМ"     p-tooltip = "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'imp-goods':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Импорт в карточке товара"     p-tooltip = "Заполнение по умолчанию параметров импорта товаров из карточки товара"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'discards-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник ДК"     p-tooltip = "Справочник дисконтных карт"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'finsttms-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Параметры вызова справочника банковских выписок"     p-tooltip = "Параметры по умолчанию, используемые для вызова справочника банковских выписок"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'fin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список фин.обязательств"     p-tooltip = "Список фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'mpl-gds-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список цен по товару"     p-tooltip = "Список цен по товару"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'tpl-mode-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список мод"     p-tooltip = "Список мод"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-sost-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Состояние заказа"     p-tooltip = "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'planplat-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Планирование платежей"     p-tooltip = "Планирование платежей"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа"     p-tooltip = "Форма ввода заказа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОП"     p-tooltip = "Форма ввода заказа ОП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pФП':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ФП"     p-tooltip = "Форма ввода заказа ФП"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cli-zakz-pОФ':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Форма ввода заказа ОФ"     p-tooltip = "Форма ввода заказа ОФ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'list-abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список заголовков ABC-анализа"     p-tooltip = "Список заголовков ABC-анализа"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'abc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "ABC-анализ"     p-tooltip = "ABC-анализ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ord-rc-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Заказ О-РЦ"     p-tooltip = "Заказ О-РЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cfin-ob-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список удаленных фин.обязательств"     p-tooltip = "Список удаленных фин.обязательств"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'color-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = yes      p-use-type-price = no      p-use-type-val = no      p-label = "Раскрасить экран"     p-tooltip = "Изменение цветовой палитры брауза"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bon1-rep':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(1)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-tooltip = "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-shift':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Сменный отчет"     p-tooltip = "Сменный отчет"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'all-docs-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Список накладных"     p-tooltip = "Список накладных"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsreffi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Справочник товаров - доп поля"     p-tooltip = "Справочник товаров - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'gdsfrmfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Карточка товара - доп поля"     p-tooltip = "Карточка товара - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-p':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'contspec-g':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Спецификация"     p-tooltip = "Спецификаци "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrst':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = YES      p-use-type-val =       p-label = "Остатки МЦ"     p-tooltip = "Остатки МЦ"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthcom':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = YES      p-use-type-price = no      p-use-type-val =       p-label = "Сводный отчет о реализованных талонах"     p-tooltip = "Сводный отчет о реализованных талонах"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'users-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Пользователи"     p-tooltip = "Список пользователей системы 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'bge-active-vbrr':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов"     p-tooltip = "Параметры для выгрузки документов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'bge-dper-new':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Параметры для выгрузки документов(расширенный)"     p-tooltip = "Параметры для выгрузки документов(расширенный)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/i-egais.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Интерфейс импорта классификатора ЕГАИС"     p-tooltip = "Интерфейс импорта классификатора ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'alc-rees':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр документов ЕГАИС"     p-tooltip = "Реестр документов ЕГАИС"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-optprc.w':U then do:     assign     p-use-List_ = no      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оптовый прайс-лист"     p-tooltip = "Оптовый прайс-лист"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'cus/iecliart.w':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Процедуры импорта экспорта артикулов поставщиков"     p-tooltip = "Процедуры импорта экспорта артикулов поставщиков"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = YES      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 1"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-exp-sl-2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Выгрузка для Nielsen 1"     p-tooltip = "Выгрузка для Nielsen 2"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthps-zone':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthparts-obj':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when '&bef-wthsref-stts}':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft =       p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthrd':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthob':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-type':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthref-stts':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = " "     p-tooltip = " "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl1':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = yes      p-use-sort-gr = yes      p-use-type-price = yes      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wrsttl2':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Реестр отоваренных талонов"     p-tooltip = "Реестр отоваренных талонов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-sup':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'wthobr-wth':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = yes      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Оборотная ведомость серийных МЦ по контрагентам"     p-tooltip = "Оборотная ведомость серийных МЦ по контрагентам"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-ptlbal':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'ctrasm':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val =       p-label = "Контроль ассортиментной матрицы"     p-tooltip = "Контроль ассортиментной матрицы"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'e-eslg-e':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Оперативный балансовый отчет движения нефтепродуктов"     p-tooltip = "Оперативный балансовый отчет движения нефтепродуктов"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'prphoto':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(2256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(2256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Прайс-лист с фото товаров"     p-tooltip = "Прайс-лист с фото товаров"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkgdsfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Товарная строка чека - доп поля"     p-tooltip = "Товарная строка чека - доп поля "     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'chkdocfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Чек - доп поля"     p-tooltip = "Чек - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'barcodfi':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Бар-код - доп поля"     p-tooltip = "Бар-код - доп поля"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
             when 'UPD':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника Электронного документоборота"     p-tooltip = "Настройки справочника Электронного документоборота"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
            when 'LK_RECEIPT':U then do:     assign     p-use-List_ = yes      p-type-List_ = 'C':U      p-format-List_ = "X(256)"     p-use-Naim = no      p-type-Naim = 'C':U      p-format-Naim = "X(256)"     p-use-print-graft = no      p-use-sort-gr = no      p-use-type-price = no      p-use-type-val = no      p-label = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-tooltip = "Настройки справочника документов Вывода из оборота (ОСУ)"     p-user-can-edit  = no     p-output-display = no     p-other = ""     .   end.
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end.
end procedure.
procedure uf-get :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .
    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
       (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.
end procedure.
procedure uf-set :
  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .
  do
  on error undo, return error
  :
    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .
    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .
    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run uf-name in this-procedure
      (input  entry(1, p-code, chr(4))
      ,output v-use-List_
      ,output v-type-List_
      ,output v-format-List_
      ,output v-use-Naim
      ,output v-type-Naim
      ,output v-format-Naim
      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val
      ,output v-label
      ,output v-tooltip
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function native-string returns character ( input p-string as character
                                          ,input p-data-type as character
                                          ,input p-format as character):
define variable v-string as character no-undo .
case p-data-type:
  when 'character':U then do:
    assign
    v-string = string(p-string, p-format)
    no-error .
  end.
  when 'date':U then do:
    assign
    v-string = string(date(p-string), p-format)
    no-error .
  end.
  when 'decimal':U then do:
    assign
    v-string = string(decimal(p-string), p-format)
    no-error .
  end.
  when 'integer':U then do:
    assign
    v-string = string(integer(p-string), p-format)
    no-error .
  end.
  when 'logical':U then do:
    assign
    v-string = string(logical(p-string), p-format)
    no-error .
  end.
end case.
return v-string.
end function.
FUNCTION gdsreffi_cond-keep-name returns character ( buffer buf_goods for ub.goods):
define buffer buf_condition-keeping for ub.condition-keeping.
find first buf_condition-keeping no-lock where
         buf_condition-keeping.cond-keep-code = buf_goods.cond-keep-code no-error.
IF AVAIL buf_condition-keeping then do:
  return buf_condition-keeping.cond-keep-name.
end.
return "[!!Неизвестные УСЛОВИЯ ХРАНЕНИЯ]".
end function.
function gdsreffi_prod-grp-name returns character ( buffer buf_goods for ub.goods):
define buffer buf_clients for ub.clients.
find first buf_clients no-lock WHERE
          buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code no-error.
if available buf_clients then do:
  return buf_clients.grp-name.
end.
return "[!!Неизвестная группа ПРОИЗВОДИТЕЛЯ]".
end function.
function gdsreffi_prod-name returns character ( buffer buf_goods for ub.goods):
define buffer buf_clients for ub.clients.
find first buf_clients no-lock WHERE
          buf_clients.obj-type = buf_goods.prod-type
      and buf_clients.obj-code = buf_goods.prod-code no-error.
if available buf_clients then do:
  return buf_clients.obj-name.
end.
return "[!!Неизвестный ПРОИЗВОДИТЕЛЬ]".
end function.
function gdsreffi_prt-root-name returns character ( buffer buf_goods for ub.goods):
define buffer buf_gds-prt for ub.gds-prt.
find first buf_gds-prt no-lock where
        buf_gds-prt.upper-code = buf_goods.prt-root NO-ERROR.
if available buf_gds-prt then do:
  return buf_gds-prt.node-name.
end.
return "[!!Неизвестный корень ШКАЛЫ]".
end function.
function gdsreffi_last-inv returns character ( buffer buf_goods for ub.goods
                                              ,input p-obj-type as character
                                              ,input p-obj-code as integer  ):
define variable v-last-inv-date-num as character format "X(45)" no-undo.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_trn-doc  for ub.trn-doc.
find last buf_doc-line no-lock where
          buf_doc-line.artic = buf_goods.artic
      and buf_doc-line.prod-code = buf_goods.prod-code
      and buf_doc-line.prod-type = buf_goods.prod-type
      and buf_doc-line.obj-code = p-obj-code
      and buf_doc-line.obj-type = p-obj-type
      and buf_doc-line.status_ = 'факт':U
      and buf_doc-line.ext-doc-type = 'vt':U no-error.
if available buf_doc-line then do :
  find first buf_trn-doc no-lock where
             buf_trn-doc.doc-code = buf_doc-line.doc-code no-error.
  if available buf_trn-doc then do :
    assign
      v-last-inv-date-num = string(buf_trn-doc.fact-date) + " № " + buf_trn-doc.doc-code
    .
    return v-last-inv-date-num.
  end.
end.
return "[!!Нет инвентаризаций по данному товару]" .
end function.
function gdsreffi_slt-pc returns decimal ( buffer buf_goods for ub.goods
                                          ,input p-obj-type as character
                                          ,input p-obj-code as integer):
define variable v-host-code as integer no-undo .
define variable v-slt-pc as decimal no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-slt-pc
  ) no-error .
if not error-status:error then do:
  return v-slt-pc.
end.
else do:
  return ?.
end.
end function.
function gdsreffi_vat-pc returns decimal ( buffer buf_goods for ub.goods
                                          ,input p-obj-type as character
                                          ,input p-obj-code as integer):
define variable v-host-code as integer no-undo .
define variable v-vat-pc as decimal no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-vat-pc
  ) no-error .
if not error-status:error then do:
  return v-vat-pc.
end.
else do:
  return ?.
end.
end function.
FUNCTION gdsreffi_last-pcnt returns decimal ( buffer buf_goods for ub.goods
                                          ,input p-obj-type as character
                                          ,input p-obj-code as integer):
define buffer buf_gds-obj for ub.gds-obj.
define variable v-value as decimal no-undo .
find first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_goods.gds-code
      AND  buf_gds-obj.obj-type = p-obj-type
      AND  buf_gds-obj.obj-code = p-obj-code no-error .
if available buf_gds-obj then do:
  assign
  v-value =
            (buf_gds-obj.price-sale / (if v-curr-r-b = 'base':U
                                      then buf_gds-obj.last-base
                                      else buf_gds-obj.last-rubl)
              * 100 - 100)
  no-error
  .
end.
else do:
  v-value = ?  .
end.
return v-value.
end FUNCTION.
FUNCTION gdsreffi_in-doc-cli-name returns character ( buffer buf_goods for ub.goods
                                          ,input p-obj-type as character
                                          ,input p-obj-code as integer):
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_clients for ub.clients.
define buffer buf_parts for ub.parts.
define variable v-value as decimal no-undo .
for first buf_gds-obj no-lock where
            buf_gds-obj.gds-code = buf_goods.gds-code
      AND  buf_gds-obj.obj-type = p-obj-type
      AND  buf_gds-obj.obj-code = p-obj-code ,
          first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_gds-obj.in-code,
          first buf_clients no-lock where buf_clients.obj-type = buf_trn-doc.cli-type and  buf_clients.obj-code = buf_trn-doc.cli-code:
        return buf_clients.obj-name .
end.
for first buf_parts no-lock where
           buf_parts.artic = buf_goods.artic
      and  buf_parts.prod-type = buf_goods.prod-type
      and  buf_parts.prod-code = buf_goods.prod-code
      AND  buf_parts.obj-type = p-obj-type
      AND  buf_parts.obj-code = p-obj-code
      and  buf_parts.out-code = 'free-zone':U ,
          first buf_clients no-lock where buf_clients.obj-type = buf_parts.supp-type and  buf_clients.obj-code = buf_parts.supp-code:
        return buf_clients.obj-name .
end.
end FUNCTION.
PROCEDURE gds-ref-fi:
DEFINE PARAMETER BUFFER fi-goods for ub.goods.
DEFINE PARAMETER BUFFER fi-gds-obj for ub.gds-obj.
DEFINE INPUT PARAMETER v-obj-type like ub.clients.obj-type.
DEFINE INPUT PARAMETER v-obj-code like ub.clients.obj-code.
DEFINE INPUT PARAMETER v-gds-ref-fi as char no-undo.
define input parameter p-excel as logical no-undo .
DEFINE INPUT-OUTPUT PARAMETER fi-1 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-2 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-3 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-4 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-5 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-6 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-7 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER fi-8 as char no-undo.
DEFINE VARiable II AS INTEGER NO-UNDO.
DEFINE BUFFER fi-gds-prt for ub.gds-prt.
define buffer fi-condition-keeping for ub.condition-keeping .
DEFINE variable myfi as char no-undo extent 8.
DEFINE VARiable jj as integer no-undo init 1.
DEFINE variable Myformat as character no-undo.
DEFINE VARiable vNum-entries as integer no-undo.
DEFINE VARiable entry-ii as character no-undo.
DEFINE VARiable vvalue as character no-undo.
DEFINE VARiable vtype as character no-undo.
DEFINE VARiable vlabel as character no-undo.
define buffer buf_usr-flt_custom-labels for usr-flt_custom-labels.
  IF v-gds-ref-fi = "" then
  v-gds-ref-fi = 'goods.gds-name,goods.#prod-name,goods.#prt-root-name,goods.negative-rest,gds-obj.#VAT-PC,goods.ALPHA1,gds-obj.in-date':U.
 if avail fi-goods then do:
vNum-entries = NUm-ENTRIES(v-gds-ref-fi).
  DO ii = 1 to vNum-entries:
    entry-ii = ENTRY(ii, v-gds-ref-fi).
    find first buf_usr-flt_custom-labels where
              buf_usr-flt_custom-labels.tbl-name = entry(1, entry-ii, ".")
         and  buf_usr-flt_custom-labels.fld-name = entry(2, entry-ii, ".")
         and  buf_usr-flt_custom-labels.call-point =  'gdsreffi':U
         and  buf_usr-flt_custom-labels.call-type = 'add-fields':U no-error.
    if  available buf_usr-flt_custom-labels then do:
      case buf_usr-flt_custom-labels.tbl-name:
        when 'goods':U then do:
          if entry(2, entry-ii, ".") begins "#" then do:
            assign
            myfi[jj] =
            buf_usr-flt_custom-labels.custom-label  + chr(32) +
                       string(dynamic-function(buf_usr-flt_custom-labels.custom-view-func, buffer fi-goods)
                              , buf_usr-flt_custom-labels.custom-format) no-error .
          end.
          else do:
            myfi[jj] =
            buf_usr-flt_custom-labels.custom-label  + chr(32) +
                        string(buffer fi-goods:buffer-field(buf_usr-flt_custom-labels.fld-name):buffer-value, buf_usr-flt_custom-labels.custom-format).
          end.
        end.
        when 'gds-obj':U then do:
          if entry(2, entry-ii, ".") begins "#" then do:
            assign
            myfi[jj] =
            buf_usr-flt_custom-labels.custom-label  + chr(32) +
                       string(dynamic-function(buf_usr-flt_custom-labels.custom-view-func
                                      ,buffer fi-goods
                                      ,input v-obj-type
                                      ,input v-obj-code
                                      )
                       , buf_usr-flt_custom-labels.custom-format) no-error .
          end.
          else do:
            if available fi-gds-obj then do:
              myfi[jj] =
                          buf_usr-flt_custom-labels.custom-label  + chr(32) +
                          string(buffer fi-gds-obj:buffer-field(buf_usr-flt_custom-labels.fld-name):buffer-value, buf_usr-flt_custom-labels.custom-format).
            end.
            else do:
              myfi[jj] =
              buf_usr-flt_custom-labels.custom-label +
              ""
              .
            end.
          end.
        end.
        when 'goods-attr':U then do:
          if entry(2, entry-ii, ".") begins "#" then do:
          end.
          else do:
            vvalue = "[!!Ошибка]".
            run gds-attr-value in this-procedure ( fi-goods.gds-code
                                                  ,input entry(2, buf_usr-flt_custom-labels.fld-name, "_")
                                                  ,output vvalue
                                                  ,output vtype) no-error.
            myfi[jj] =
            buf_usr-flt_custom-labels.custom-label  + chr(32) +
                       native-string(vvalue, buf_usr-flt_custom-labels.fld-data-type, buf_usr-flt_custom-labels.custom-format).
          end.
        end.
        when 'gds-obj-attr':U then do:
          if entry(2, entry-ii, ".") begins "#" then do:
          end.
          else do:
            vvalue = "[!!Ошибка]".
            run gdsoattr-value in this-procedure (
                                                  input  entry(2, buf_usr-flt_custom-labels.fld-name, "_")
                                                 ,input  fi-goods.gds-code
                                                 ,input v-obj-type
                                                 ,input v-obj-code
                                                 ,output vvalue
                                                 ,output vtype
                                                 ) no-error .
            myfi[jj] =
            buf_usr-flt_custom-labels.custom-label  + chr(32) +
                       native-string(vvalue, buf_usr-flt_custom-labels.fld-data-type, buf_usr-flt_custom-labels.custom-format).
          end.
        end.
        when 'gds-host-attr':U then do:
          if entry(2, entry-ii, ".") begins "#" then do:
          end.
          else do:
            vvalue = "[!!Ошибка]".
            run gdshattr-value in this-procedure (
                                                  input  entry(2, buf_usr-flt_custom-labels.fld-name, "_")
                                                 ,input  fi-goods.gds-code
                                                 ,input v-obj-type
                                                 ,input v-obj-code
                                                 ,output vvalue
                                                 ,output vtype
                                                 ) no-error .
            myfi[jj] =
            buf_usr-flt_custom-labels.custom-label  + chr(32) +
                       native-string(vvalue, buf_usr-flt_custom-labels.fld-data-type, buf_usr-flt_custom-labels.custom-format).
          end.
        end.
      end case.
      if p-excel then do:
        if buf_usr-flt_custom-labels.fld-data-type = 'decimal':U
        or buf_usr-flt_custom-labels.fld-data-type = 'integer':U
        then do:
          myfi[jj] = replace(myfi[jj], chr(44), "").
        end.
      end.
      jj = jj + 1.
      if jj = 9 then LEAVE.
    end.
      else if entry(1, entry-ii, ".") = 'goods-attr':U then  do:
        vvalue = "[!!Ошибка]".
                run gds-attr-value in this-procedure ( fi-goods.gds-code
                                                      ,input (SUBSTRING (entry-ii,INDEX(entry-ii,"_") + 1))
                                                      ,output vvalue
                                                      ,output vtype) no-error.
                myfi[jj] = vvalue.
      end.
  END.
  end.
  assign
  fi-1 = myfi[1]
  fi-2 = myfi[2]
  fi-3 = myfi[3]
  fi-4 = myfi[4]
  fi-5 = myfi[5]
  fi-6 = myfi[6]
  fi-7 = myfi[7]
  fi-8 = myfi[8]
  .
END PROCEDURE.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE gds-ref-to:
DEFINE INPUT PARAMETER v-gds-ref-fi as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-1 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-2 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-3 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-4 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-5 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-6 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-7 as char no-undo.
DEFINE INPUT-OUTPUT PARAMETER to-8 as char no-undo.
DEFINE VARiable II AS INTEGER NO-UNDO.
DEFINE variable myto as char no-undo extent 8.
DEFINE variable mypr as char no-undo extent 8.
DEFINE VARiable jj as integer no-undo init 1.
DEFINE VARiable vNum-entries as integer no-undo.
DEFINE VARiable entry-ii as char no-undo.
define buffer buf_custom-labels for ub.custom-labels.
define buffer buf_usr-flt_custom-labels for usr-flt_custom-labels.
IF v-gds-ref-fi = "" then
v-gds-ref-fi = 'goods.gds-name,goods.#prod-name,goods.#prt-root-name,goods.negative-rest,gds-obj.#VAT-PC,goods.ALPHA1,gds-obj.in-date':U.
vNum-entries = NUm-ENTRIES(v-gds-ref-fi).
for each usr-flt_custom-labels:
  delete usr-flt_custom-labels.
end.
DO ii = 1 to vNum-entries:
   entry-ii = ENTRY(ii, v-gds-ref-fi).
  find first buf_custom-labels no-lock where
          buf_custom-labels.tbl-name = entry(1, entry-ii, ".":U)
      and buf_custom-labels.fld-name = entry(2, entry-ii, ".":U)
      and buf_custom-labels.call-point = 'gdsreffi':U
      and buf_custom-labels.call-type = 'add-fields':U
      no-error.
   if available buf_custom-labels then do:
     create buf_usr-flt_custom-labels.
     buffer-copy buf_custom-labels to buf_usr-flt_custom-labels.
      assign
      myto[jj] =  buf_custom-labels.custom-tooltip
      .
   end.
   else do:
    message "Для пользователя " v-cntxt-userid skip "настройки доп.поле справочника товаров содержат неопознанный элемент " ENTRY-ii skip "Обратитесь к администратору системы" skip error-status:get-message(1) skip return-value skip view-as alert-box ERROR.
   END.
   jj = jj + 1.
   if jj = 9 then LEAVE.
END.
assign
to-1 = myto[1]
to-2 = myto[2]
to-3 = myto[3]
to-4 = myto[4]
to-5 = myto[5]
to-6 = myto[6]
to-7 = myto[7]
to-8 = myto[8]
.
END PROCEDURE.
PROCEDURE gds-ref-to-description:
define variable v-ok  as logical no-undo .
  run ref/cstmlabs.w ( input parparentproc
                     ,input 'add-fields':U
                     ,input 'gdsreffi':U
                     ,input no
                     ,input 8
                     ,output v-ok
                     ) no-error.
if v-ok then do:
  message
  "Изменения вступят в силу при следующем входе в справочник товаров"
  view-as alert-box warning.
end.
END PROCEDURE.
define new global shared variable g#libbcrcn as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION prep-nameorcode RETURNS CHARACTER
  ( input p-nameorcode as character ) :
define variable v-nameorcode as character no-undo .
define variable v-dopi as character no-undo .
if trim(p-nameorcode) = '' then  return ''.
v-nameorcode = trim( trim( p-NameOrCode) , "*" ) .
if index(v-NameOrCode, chr(34) ,1 ) = 1
and R-index(v-NameOrCode, chr(34) ,1 ) = 1 then do:
  assign
  v-NameOrCode = trim(v-NameOrCode, chr(34))
  .
end.
assign
v-dopi = substring(v-NameOrCode, length(v-NameOrCode), 1)
.
if index("abcdefghijklmnopqrstuvwxyzабвгдеёжзийклмнопрстуфхцчшщъыьэюя", v-dopi) > 0
or index("1234567890", v-dopi) > 0
then do:
  v-NameOrCode = v-NameOrCOde + "*".
end.
v-NameOrCode = LC(v-NameOrCode).
RETURN v-nameorcode.
END FUNCTION.
def var vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info19 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info19, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info19, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info19, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info19, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info19 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info19, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info19 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info19, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info19, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info19, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info19, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info19, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info19, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info19 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info19 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info19, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info19, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info19, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info19 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info19 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info19, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info19, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION check-ban-sales-via-cd return logical ( input p-gds-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
   if p-gds-code <> 0 then do:
    find first lc_goods where lc_goods.gds-code = p-gds-code.
    v-upper-code = lc_goods.grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
    end.
    if v-value = "" or logical(v-value) = false then return false .
end.
FUNCTION check-ban-sales-via-cd-grp return logical ( input p-grp-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
    v-upper-code = p-grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input v-cntxt-host-code-obj,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
end.
define buffer g-producer for ub.clients .
define variable g#log as logical no-undo .
define variable gds-rec as recid no-undo .
define variable line-rec as recid no-undo .
define variable flt-rec as recid no-undo .
define variable old-value-emrc as character no-undo .
define variable ref-list as character no-undo.
define variable copymode as logical no-undo.
define variable start as logical no-undo initial no.
define variable from-b-sch as logical no-undo initial no.
define buffer cli-shops for ub.clients.
define variable for-title     as character no-undo.
define variable dopinf-option as character no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-doc-prt as logical no-undo.
define variable v-spis as character no-undo .
define variable v-is-ptrl   as character no-undo.
define variable v-data-type as character no-undo.
define variable filter-label0 as character no-undo .
define variable filter-label as character no-undo .
DEFINE VARIABLE filter-point as character no-undo .
DEFINE VARIABLE filter-point0 as character no-undo .
DEFINE VARIABLE sort-column-name as character no-undo .
define variable v-filter-name as character no-undo .
DEFINE VARIABLE mphcol AS LOGICAL INITIAL NO NO-UNDO.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table tt-goods no-undo like ub.goods.
define new shared temp-table tt-clients no-undo like ub.clients.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
DEFINE VARIABLE mImagePath     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageDir      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImagePreDir   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageTrash    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPhotomgd      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mImagePh       AS LOGICAL     NO-UNDO.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.
PROCEDURE imagelist_loaddef:
    DEFINE VARIABLE vPar-val       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vPar-type      AS CHARACTER   NO-UNDO.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'photo':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output vPar-val
  ,output vPar-type
  ) no-error .
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
    IF mImagePh THEN .
    ELSE RETURN.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
    IF LENGTH (vPar-val) = 0 THEN
        RUN verify-ini-entry("ph-dir":U, "REP-SETS":U, "":U, YES, OUTPUT vPar-val) NO-ERROR.
    IF LENGTH (vPar-val) = 0 THEN vPar-val = "c:\temp\":U.
    ASSIGN
        mImagePath   = RIGHT-TRIM (vPar-val, "~\~/":U)
        mImagePath   = mImagePath + (IF LENGTH (mImagePath) > 0 THEN "\":U ELSE "":U)
        mImagePreDir = mImagePath
        mImageDir    = mImagePreDir
        mImageTrash  = mImagePath + "trash\":U
        .
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
            run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
        mPhotomgd = IF v-val-integer = 2 then yes else no.
END PROCEDURE.
PROCEDURE imagelist_decode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE INPUT  PARAMETER iImageGdsCode AS int    NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF SUBSTRING (vCh, 1, 2) = "~\~\":U THEN .
        ELSE
        DO:
            ASSIGN
                vCh = REPLACE (vCh, "~/":U, "\":U)
                vCh = REPLACE (vCh, "~\":U, "\":U)
                .
            IF SUBSTRING (vCh, 2, 2) = ":\":U OR vCh BEGINS mImageDir THEN .
            ELSE vCh = mImagePreDir + (if mPhotomgd then string(iImageGdsCode) + "\":U else '':U ) +  vCh.
            ENTRY (vInt, oImageList, ",":U) = vCh.
        END.
    END.
END PROCEDURE.
PROCEDURE imagelist_encode:
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vLen               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        vLen       = LENGTH (mImageDir)
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, ",":U):
        vCh =ENTRY (vInt, iImageList, ",":U).
        IF LENGTH (vCh) > 0 AND vLen > 0 AND vCh BEGINS mImageDir THEN
            ENTRY (vInt, oImageList, ",":U) =
                SUBSTRING (vCh, vLen + 1).
    END.
END PROCEDURE.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-arch
     LABEL "Ар&хив":L
     SIZE 10 BY 1.
DEFINE BUTTON add-inf
     LABEL "Доп.инф":L
     SIZE 10 BY 1.
DEFINE BUTTON b-hist
     LABEL "История":L
     SIZE 10 BY 1.
DEFINE BUTTON b-price
     LABEL "&Цены":L
     SIZE 10 BY 1.
DEFINE BUTTON b-rest
     LABEL "&Остат":L
     SIZE 10 BY 1.
DEFINE BUTTON b-card
     LABEL "Оборот&ы":L
     SIZE 10 BY 1.
DEFINE BUTTON b-chk
     LABEL "&Чеки  ":L
     SIZE 10 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просм":L
     SIZE 10 BY 1.
DEFINE BUTTON b-prt
     LABEL "&Шкала":L
     SIZE 10 BY 1.
DEFINE BUTTON b-parts
     LABEL "Пар&тии":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-alt-bc
     LABEL "&Коды":L
     SIZE 10 BY 1.
DEFINE BUTTON b-mark
     LABEL " &* ":L
     SIZE 3 BY 1.
DEFINE BUTTON b-add
     LABEL "&Добав. товар":L
     SIZE 15 BY 1.
DEFINE BUTTON b-add-office
     LABEL "Добав. услугу":L
     SIZE 15 BY 1.
DEFINE BUTTON b-copy
     LABEL "Копи&я"
    SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Измен":L
     SIZE 10 BY 1.
DEFINE BUTTON b-grp
     LABEL "&Группа":L
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 10 BY 1.
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B-obj"
     SIZE 3 BY 1.
DEFINE BUTTON b-place
     LABEL "С.&места":L
     SIZE 10 BY 1.
DEFINE BUTTON b-dinamo
     LABEL "Динам.":L
     SIZE 10 BY 1.
DEFINE BUTTON b-recip
     LABEL "Рецепт":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sch
     LABEL "Фил&ьтр":L
     SIZE 10 BY 1.
DEFINE BUTTON b-sert
     LABEL "&Сертиф":L
     SIZE 10 BY 1.
DEFINE BUTTON b-gdsreffi
     image file "cmp/b-must.bmp":u
     SIZE 3 BY 4.
DEFINE BUTTON b-extart
     LABEL "Внеш.Арт":L
     SIZE 10 BY 1.
DEFINE VARIABLE rs-list AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Все",          'все':U,
"Производитель",'Производитель':U,
"Группа",       'группа':U
     SIZE 30 BY 1 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE rs-stat AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Текущие&+",   'текущие':U,
"Все&!",       'все':U,
"Неактив&-", 'удаленные':U
     SIZE 30 BY 1   FGCOLOR 0   NO-UNDO.
DEFINE VARIABLE rs-sort AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Артикул",'Артикул':U,
"Цена прод.",'цена':U,
"Количество",'Количество':U
SIZE 35 BY 1 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE rs-cond AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Все",'все':U,
"Объект",'объект':U,
"Факт",'факт':U,
"Свободно",'свободно':U
SIZE 32.5 BY 1 FGCOLOR 0  NO-UNDO.
define shared variable loc-art  as character view-as fill-in size 18 by 1 fgcolor 12 no-undo format "x(16)":U.
define shared variable loc-name as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define shared variable loc-code as character view-as fill-in size 17 by 1 fgcolor 12 no-undo.
define variable NameContext as character view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define shared variable a-n-c as character view-as radio-set horizontal radio-buttons
"Артик","art",
"Нач.назв","name",
"Нач.слова","context",
"Код","code",
"DM","DataMatrix"
size 39 by 1    fgcolor 0  no-undo.
DEFINE MENU m-add
       MENU-ITEM m-add-1 LABEL "Товар"   ACCELERATOR "ALT-1"
       MENU-ITEM m-add-2 LABEL "Услуга"  ACCELERATOR "ALT-2"
.
DEFINE MENU m-dopinf
       MENU-ITEM m-dopinf-1 LABEL "Доп.инфо по карточке товара"                                  ACCELERATOR "ALT-1"
       MENU-ITEM m-dopinf-2 LABEL "Фото"                                                                         ACCELERATOR "ALT-2"
       RULE
       MENU-ITEM m-dopinf-lgattr LABEL "Просмотр Глобальных атрибутов товара"                       ACCELERATOR "ALT-3"
       MENU-ITEM m-dopinf-lhattr LABEL "Просмотр Атрибутов товара на фирме"                         ACCELERATOR "ALT-4"
       MENU-ITEM m-dopinf-loattr LABEL "Просмотр Атрибутов товара на объекте"                       ACCELERATOR "ALT-5"
       MENU-ITEM m-dopinf-moattr LABEL "Просмотр Атрибутов товара на объектах фирмы"                ACCELERATOR "ALT-6"
       MENU-ITEM m-dopinf-lfgds  LABEL "Просмотр Атрибутов товара (РЕСТОРАН) на объекте"            ACCELERATOR "ALT-7"
       MENU-ITEM m-dopinf-ldgr   LABEL "Просмотр Скидок на товар, действующих на объекте"           ACCELERATOR "ALT-8"
       MENU-ITEM m-dopinf-mdgr   LABEL "Просмотр Скидок на товар, действующих на объектах фирмы"    ACCELERATOR "ALT-9"
       MENU-ITEM m-dopinf-lscoef LABEL "Просмотр Сезонных коэффициентов для товара в производстве"  ACCELERATOR "ALT-f1"
       MENU-ITEM m-dopinf-lprop  LABEL "Просмотр Индикаторов товара на объекте"                     ACCELERATOR "ALT-f2"
       MENU-ITEM m-dopinf-lprop-ord  LABEL "Просмотр Атрибутов на объекте для ЗАКАЗА"               ACCELERATOR "ALT-f3"
       MENU-ITEM m-dopinf-lprop-ordf LABEL "Просмотр Атрибутов на фирме   для ЗАКАЗА"
       RULE
       MENU-ITEM m-dopinf-cgattr LABEL "Изменение Глобальных атрибутов товара"                       ACCELERATOR "ALT-f4"
       MENU-ITEM m-dopinf-chattr LABEL "Изменение Атрибутов товара на фирме"                         ACCELERATOR "ALT-f5"
       MENU-ITEM m-dopinf-coattr LABEL "Изменение Атрибутов товара на объекте"                       ACCELERATOR "ALT-f6"
       MENU-ITEM m-dopinf-cfgds  LABEL "Изменение Атрибутов товара (РЕСТОРАН) на объекте"            ACCELERATOR "ALT-f7"
       MENU-ITEM m-dopinf-cdgr   LABEL "Изменение Скидок на товар, действующих на объекте"           ACCELERATOR "ALT-f8"
       MENU-ITEM m-dopinf-cscoef LABEL "Изменение Сезонных коэффициентов для товара в производстве"  ACCELERATOR "ALT-f9"
       MENU-ITEM m-dopinf-cprop  LABEL "Изменение Индикаторов товара на объекте"                     ACCELERATOR "ALT-f10"
       MENU-ITEM m-dopinf-cprop-ord LABEL "Изменение Атрибутов товара на объекте для ЗАКАЗА"                    ACCELERATOR "ALT-f11"
       MENU-ITEM m-dopinf-cprop-ordf LABEL "Изменение Атрибутов товара на фирме   для ЗАКАЗА"
       RULE
       MENU-ITEM m-dopinf-AM     LABEL "Вхождение в Ассортиментные матрицы"
       MENU-ITEM m-dopinf-CONTR  LABEL "Вхождение в Спецификации"
       RULE
       MENU-ITEM m-dopinf-msf    LABEL "Классификация мясных полуфабрикатов"
       RULE
       MENU-ITEM m-dopinf-alt-unit    LABEL "Дополнительные единицы измерения"
.
def MENU m-price
    MENU-ITEM m-price-1 LABEL "Цены"
    MENU-ITEM m-price-2 LABEL "Переоценки"
.
define shared variable sch-rec AS recid no-undo.
define variable free-q as decimal no-undo column-label "Свободно" format "->,>>>,>>>.<<<":U.
define variable fact-q as decimal no-undo column-label "Факт"     format "->,>>>,>>>.<<<":U.
define variable price          like ub.price-list.price-sale column-label "Цена"                              no-undo.
define variable for-cash-parts like ub.gds-obj.cash-parts    column-label "П"                 format "+/-":U.
define variable for-last-price like ub.gds-obj.last-rubl     column-label "Цена посл.прихода"                 no-undo.
define variable for-last-pcnt-str as character column-label "Торг.нацен.%" format "x(12)":U no-undo.
define variable v-lookup-cost as logical no-undo .
define variable val-VAT like ub.tax-rate-value.rate-value no-undo .
define variable val-SLT like ub.tax-rate-value.rate-value no-undo .
define variable free-q-cli as decimal no-undo column-label "Свободно (е.п.)" format "->>,>>>,>>>.<<<":U.
define variable fact-q-cli as decimal no-undo column-label "Факт (е.п.)"     format "->>,>>>,>>>.<<<":U.
define variable v-indicator-life-gds like  ub.gds-obj-prop.gdop-igt        column-label "ИЖТ" format "x(25)" no-undo .
define variable v-assort-min         like  ub.gds-obj-prop.gdop-assort-min column-label "AMin" format "*/ " no-undo .
define variable mark        as character no-undo.
define variable mark-recipe as character no-undo.
define variable mark-num    as integer   no-undo.
define variable contin      as logical   initial no.
define buffer l-goo-doc for ub.goods.
define buffer l-gob-doc for ub.gds-obj.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable dops      as character no-undo format "x(250)":U .
define variable dopst     as character no-undo format "x(1)":U .
define variable is-fbr    as logical   no-undo .
define variable is-prt    as logical   no-undo .
DEFINE NEW SHARED BUFFER gob-doc FOR ub.gds-obj.
DEFINE NEW SHARED BUFFER goo-doc FOR ub.goods.
DEFINE NEW SHARED BUFFER gam-doc FOR ub.assortment-matrix-goods.
define variable e-name like goo-doc.engl-name            no-undo.
define variable gds-n  like goo-doc.gds-name             no-undo.
define variable unit-b like goo-doc.unit-base            no-undo.
define variable qnty-c like goo-doc.qnty-cart            no-undo.
define variable VAT-p  like ub.tax-rate-value.rate-value no-undo.
define variable SLT-p  like ub.tax-rate-value.rate-value no-undo.
define variable gds-t  like goo-doc.gds-type             no-undo.
define variable choice as   integer                      no-undo.
define variable gdsreffi  as character no-undo.
define variable myto      as character no-undo extent 8.
define variable mypr      as character no-undo extent 8.
define variable main-code as integer   no-undo.
define variable v-chg-rec as recid     no-undo.
define variable FI-1 as character view-as text size 76 by 1 no-undo format "x(80)":U.
define variable FI-2 as character view-as text size 76 by 1 no-undo format "x(80)":U.
define variable FI-3 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-4 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-5 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-6 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-7 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable FI-8 as character view-as text size 45 by 1 no-undo format "x(49)":U.
define variable v-obj-type as character view-as fill-in size  4 by 1 fgcolor 12 no-undo.
define variable v-obj-code as integer   view-as fill-in size  6 by 1 fgcolor 12 no-undo.
define variable v-obj-name as character view-as fill-in size 30 by 1 fgcolor 12 no-undo format "x(30)":U.
FUNCTION Get-good RETURNS CHARACTER
  ( buffer loc-goods for goo-doc, buffer loc-gds-obj for gob-doc )  FORWARD.
DEFINE NEW SHARED QUERY br-gds FOR gob-doc  SCROLLING.
DEFINE BROWSE br-gds QUERY br-gds NO-LOCK DISPLAY
   get-good( buffer goo-doc, buffer gob-doc ) format "x(1)":U column-label "*"
  (IF mphcol THEN "+":U ELSE "-":U) FORMAT "x(1)":U COLUMN-LABEL "Ф"
  gds-t format "x(1)":U column-label "У"
  mark-recipe format "x(1)":U column-label "Р"
  gob-doc.artic
  gds-n format "x(48)":U column-label "Название"
  free-q  COLUMN-LABEL "Своб-но" format  "->>,>>>,>>>.<<<":U
  fact-q  COLUMN-LABEL "Факт" format  "->>,>>>,>>>.<<<":U
  price
  unit-b column-label  "Изм."
  qnty-c column-label  "Кол. в упак."
  gob-doc.grp-name format "x(120)":U
  VAT-p format ">9.99%":U column-label "НДС"
  SLT-p format ">9.99%":U column-label "НП"
  e-name format "x(40)":U
  for-cash-parts
  for-last-price
  for-last-pcnt-str
  free-q-cli COLUMN-LABEL "Своб-но (е.п.)" format  "->>,>>>,>>>.<<<":U
  fact-q-cli COLUMN-LABEL "Факт (е.п.)" format  "->>,>>>,>>>.<<<":U
  v-indicator-life-gds
  v-assort-min
  WITH SIZE 98 BY 11 SEPARATORS.
DEFINE RECTANGLE RECT-list
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 49 BY 2.4.
DEFINE RECTANGLE RECT-cond
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 49 BY 2.4.
DEFINE RECTANGLE RECT-gds-ref-fi
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 4.5.
DEFINE IMAGE g-image
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 16.63   BY 4.17.
DEFINE MENU m-ostatki
       MENU-ITEM m-ostatki-1 LABEL "Остатки по объектам"     ACCELERATOR "ALT-1"
       MENU-ITEM m-ostatki-2 LABEL "Остатки по поставщикам"  ACCELERATOR "ALT-2"
    .
DEFINE MENU m-oborot
       MENU-ITEM m-oborot-1 LABEL "Оборотная ведомость"      ACCELERATOR "ALT-1"
       MENU-ITEM m-oborot-2 LABEL "Обороты по контрагентам"  ACCELERATOR "ALT-2"
    .
DEFINE FRAME d-gob-doc-ref
  b-exit at row 1 col 1
  b-sel at row 1 col 19
  b-arch at row 1 col 29
  b-price at row 1 col 39
  b-rest at row 1 col 49
  b-card at row 1 col 59
  b-dinamo at row 1 col 69
  b-sch at row 1 col 79
  b-help at row 1 col 89
  b-mark at row 1 col 13
  mark-num at row 2 col 1 colon-aligned no-label view-as fill-in size 9 by 1 fgcolor 4
  b-alt-bc at row 2 col 9
  b-recip at row 2 col 19
  b-extart at row 2 col 29
  b-chk at row 2 col 39
  b-prt at row 2 col 49
  b-parts at row 2 col 59
  b-place at row 2 col 69
  b-sert at row 2 col 79
  b-hist at row 2 col 89
  v-obj-type at row 3 col 2 No-LABEL
  v-obj-code at row 3 col 6 No-LABEL
  b-obj at row 3 col 12
  v-obj-name at row 3 col 15 No-LABEL
  b-add at row 3 col 9
  b-add-office at row 3 col 24
  b-copy at row 3 col 39
  b-lkp  at row 3 col 49
  b-chg at row 3 col 59
  b-del at row 3 col 69
  add-inf at row 3 col 79
  b-grp at row 3 col 89
  "Поиск по:" VIEW-AS TEXT SIZE 9 BY 1 fgcolor 4 AT ROW 4 COL 1
  a-n-c at row 4 col 10 no-label
  NameContext AT ROW 4 COL 56 COLON-ALIGNED label "Контекст" format "x(40)":U
  loc-art AT ROW 4 COL 56 COLON-ALIGNED no-label
  loc-name AT ROW 4 COL 56 COLON-ALIGNED label "Нач. назв." format "x(40)":U
  loc-code AT ROW 4 COL 59 COLON-ALIGNED label "Код(весь)":U format "x(300)":U
  goo-doc.gds-code at row 4 col 82  colon-aligned label "Код" fgcolor 4 format "9999999999":U
  br-gds AT ROW 5 COL 1
  rect-gds-ref-fi at row 16.1 COL 1
  fi-1 at row 16.2 col 5 No-LABEL fgcolor 4
  b-gdsreffi AT ROW 16.25 col 1.5
  fi-2 at row 17.0 col 5 No-LABEL  fgcolor 4
  fi-3 at row 17.8 col 5 No-LABEL
  fi-4 at row 17.8 col 51 No-LABEL
  fi-5 at row 18.6 col 5 No-LABEL
  fi-6 at row 18.6 col 51 No-LABEL
  fi-7 at row 19.4 col 5 No-LABEL
  fi-8 at row 19.4 col 51 NO-LABEL
  rect-list at row 20.7 col 1
  rect-cond at row 20.7 col 50
  g-image AT ROW 16.27 COL 81.85
  "Справочник :" VIEW-AS TEXT SIZE 12 BY 1 fgcolor 4 AT ROW 20.9 COL 2
  rs-list at row 20.9 col 12 colon-aligned no-label
  "Фильтр :" VIEW-AS TEXT SIZE 9 BY 1 fgcolor 4 AT ROW 20.9 COL 51
  rs-cond at row 20.9 col 60 colon-aligned no-label
  "Статус :" VIEW-AS TEXT SIZE 9 BY 1 fgcolor 4 AT ROW 21.9 COL 2
  rs-stat at row 21.9 col 12 colon-aligned no-label
  "Сортировка :" VIEW-AS TEXT SIZE 13 BY 1 fgcolor 4 AT ROW 21.9 COL 51
  rs-sort at row 21.9 col 61 colon-aligned no-label
  SPACE(0) SKIP(0) WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE TITLE 'справочник':U.
ASSIGN FRAME d-gob-doc-ref :SCROLLABLE = FALSE.
ASSIGN br-gds :NUM-LOCKED-COLUMNS IN FRAME d-gob-doc-ref = 4 .
ASSIGN b-rest  :POPUP-MENU IN FRAME d-gob-doc-ref = MENU m-ostatki :HANDLE.
ASSIGN b-rest  :MENU-MOUSE = 1.
ASSIGN b-card  :POPUP-MENU IN FRAME d-gob-doc-ref = MENU m-oborot  :HANDLE.
ASSIGN b-card  :MENU-MOUSE = 1.
ASSIGN add-inf :POPUP-MENU IN FRAME d-gob-doc-ref = MENU m-dopinf  :HANDLE.
ASSIGN add-inf :MENU-MOUSE = 1.
ASSIGN b-price:POPUP-MENU IN FRAME d-gob-doc-ref = MENU m-price:HANDLE.
ASSIGN b-price:MENU-MOUSE = 1.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-gds as INT EXTENT 15 no-undo.
DEF VAR varmvibr-gds       as INT no-undo.
DEF VAR varmvjbr-gds       as INT no-undo.
DEF VAR varmvkbr-gds       as INT no-undo.
DEF VAR varmvlbr-gds       as INT no-undo.
DEF VAR move-elementbr-gds as INT no-undo.
def var jjbr-gds           as int no-undo.
do varmvibr-gds = 1 to EXTENT(cur-clmn-numbr-gds):
  ASSIGN cur-clmn-numbr-gds[varmvibr-gds] = varmvibr-gds.
END.
RUN start-mv-clmnbr-gds.
PROCEDURE start-mv-clmnbr-gds:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-gds do:
  RUN re-move-clmnbr-gds ( 6, 15).
END.
ON ctrl-cursor-left OF BROWSE br-gds do:
  RUN re-move-clmnbr-gds (15, 6).
END.
PROCEDURE re-move-clmnbr-gds:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
    if cur-clmn-numbr-gds[varmvibr-gds] = source-column THEN cur-clmn-numbr-gds[varmvibr-gds] = -1.
  END.
  if br-gds:MOVE-COLUMN(source-column, target-column) IN FRAME d-gob-doc-ref then.
  if source-column > target-column THEN
  DO varmvjbr-gds = source-column - 1 to target-column BY -1:
    DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
        if cur-clmn-numbr-gds[varmvibr-gds] = varmvjbr-gds THEN DO:
          cur-clmn-numbr-gds[varmvibr-gds] = cur-clmn-numbr-gds[varmvibr-gds] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-gds = source-column + 1 to target-column:
    DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
      if cur-clmn-numbr-gds[varmvibr-gds] = varmvjbr-gds THEN DO:
        cur-clmn-numbr-gds[varmvibr-gds] = cur-clmn-numbr-gds[varmvibr-gds] - 1.
      END.
    END.
  END.
  DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
    if cur-clmn-numbr-gds[varmvibr-gds] = -1 THEN cur-clmn-numbr-gds[varmvibr-gds] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-gds:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 6 then do:
    return .
  end.
  DO varmvibr-gds = 1 TO EXTENT(cur-clmn-numbr-gds):
    if cur-clmn-numbr-gds[varmvibr-gds] = cur-clmn-loc THEN move-elementbr-gds = varmvibr-gds.
  END.
  RUN re-move-clmnbr-gds (cur-clmn-loc, 6).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-gds:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-gds = 6 to EXTENT(cur-clmn-numbr-gds):
    RUN re-move-clmnbr-gds (cur-clmn-numbr-gds[varmvlbr-gds], varmvlbr-gds).
  END.
  RUN start-mv-clmnbr-gds.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref25 as character no-undo .
define variable varpgscales-pref25 as character no-undo.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type26 as character no-undo.
varscales-pref25  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref25
  ,output varscales-pref-type26
  ) no-error .
if varscales-pref25 = ? then do:
  assign
  varscales-pref25 = '21,23,25':U.
end.
define variable varpgscales-pref-type26 as character no-undo.
varpgscales-pref25  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref25
  ,output varpgscales-pref-type26
  ) no-error .
if varpgscales-pref25 = ? then do:
  assign
  varpgscales-pref25 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
on value-changed of a-n-c in frame d-gob-doc-ref do:
  run proc-valchg-a-n-c in this-procedure  no-error.
  return no-apply.
end.
on any-printable of br-gds in frame d-gob-doc-ref do:
  run proc-any-printable-br-gds in this-procedure   no-error.
  return no-apply.
end.
on backspace of br-gds in frame d-gob-doc-ref do:
  run proc-backspace-br-gds in this-procedure   no-error.
  return no-apply.
end.
ON return OF loc-code IN FRAME d-gob-doc-ref do:
  run proc-mouse-dbl-click-loc-code in this-procedure   no-error.
  return no-apply.
end.
ON return, Ctrl-J OF loc-name IN FRAME d-gob-doc-ref do:
  run proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.
ON return OF NameContext IN FRAME d-gob-doc-ref do:
  run proc-mouse-dbl-click-namec in this-procedure   no-error.
  return no-apply.
end.
PROCEDURE proc-valchg-a-n-c:
  case input frame d-gob-doc-ref a-n-c :
    when "art" then do:
      apply "entry" to br-gds in frame d-gob-doc-ref.
      hide loc-name loc-code
      in frame d-gob-doc-ref.
      loc-art = "".
        NameContext = "" .
        hide NameContext in frame d-gob-doc-ref.
        if a-n-c <> a-n-c:screen-value then do:
          assign a-n-c.
          RUN openbr in this-procedure ( input no, input yes ,input no, input '').
        end.
    end.
    when "name" then do:
      enable loc-name with frame d-gob-doc-ref.
      disp loc-name with frame d-gob-doc-ref.
      hide loc-art loc-code
      in frame d-gob-doc-ref.
      NameContext = "" .
      hide NameContext in frame d-gob-doc-ref.
      if a-n-c <> a-n-c:screen-value then do:
        assign a-n-c.
        RUN openbr in this-procedure ( input no, input yes ,input no, input '').
      end.
      apply "entry" to loc-name in frame d-gob-doc-ref.
    end.
    when "code"
 or when "DataMatrix" then
    do:
      enable loc-code with frame d-gob-doc-ref.
      disp loc-code with frame d-gob-doc-ref.
      hide loc-art loc-name
      in frame d-gob-doc-ref.
      NameContext = "" .
      hide NameContext in frame d-gob-doc-ref.
      if a-n-c <> a-n-c:screen-value then do:
        assign a-n-c.
        RUN openbr in this-procedure ( input no, input yes ,input no, input '').
      end.
      apply "entry" to loc-code in frame d-gob-doc-ref.
    end.
    when "context" then do:
      assign a-n-c .
      enable NameContext with frame d-gob-doc-ref.
      disp NameContext with frame d-gob-doc-ref.
      apply "entry" to NameContext in frame d-gob-doc-ref.
      HIDE loc-art loc-name loc-code in frame d-gob-doc-ref.
    end .
  end CASE.
END PROCEDURE.
PROCEDURE proc-any-printable-br-gds :
  if input frame d-gob-doc-ref a-n-c = "art" then do:
    if last-event:label = " " and
       loc-art = "" then
    return error.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  case g-list :
    when 'все':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.obj-type = p-obj-type                                  and l-gob-doc.obj-code = p-obj-code AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
        when 'факт':U then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
        when 'свободно':U then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
      end.
    end.
    when 'Производитель':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
        when 'факт':U then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
        when 'свободно':U then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
      end.
    end.
    when 'группа':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
        when 'факт':U then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
        when 'свободно':U then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0) else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins (loc-art + last-event:label) no-lock no-error.
        end.
      end.
    end.
  end.
    if available l-gob-doc then do:
      loc-art = loc-art + last-event:label.
      disp loc-art with frame d-gob-doc-ref.
      line-rec = recid (l-gob-doc).
      reposition br-gds to recid line-rec no-error.
      if error-status:error then do:     run ref/gdsrepos.p (input 1,                    input g-cond,                    input g-list,                    input g-stat,                    input flt-rec,                    output g#log,                    output contin).     if g#log then do:       run full-sch.       return error.     end.   end.   apply "VALUE-changed" to br-gds in frame d-gob-doc-ref.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-backspace-br-gds:
  if input frame d-gob-doc-ref a-n-c = "art" then do:
    if loc-art = "" then
      return error.
    loc-art = substr (loc-art, 1, length (loc-art) - 1).
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  case g-list :
    when 'все':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.obj-type = p-obj-type                                  and l-gob-doc.obj-code = p-obj-code AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
        when 'факт':U then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
        when 'свободно':U then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
      end.
    end.
    when 'Производитель':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
        when 'факт':U then do:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
        when 'свободно':U then do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
      end.
    end.
    when 'группа':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
        when 'факт':U then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
        when 'свободно':U then do:
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 AND (if g-stat = 'все':U then true else (if g-stat = 'текущие':U then (l-gob-doc.stts = 0)else (l-gob-doc.stts = 1)))
                                  and l-gob-doc.artic begins loc-art no-lock no-error.
        end.
      end.
    end.
  end.
    disp loc-art with frame d-gob-doc-ref.
    line-rec = recid (l-gob-doc).
    reposition br-gds to recid line-rec no-error.
    if error-status:error then do:     run ref/gdsrepos.p (input 1,                    input g-cond,                    input g-list,                    input g-stat,                    input flt-rec,                    output g#log,                    output contin).     if g#log then do:       run full-sch.       return error.     end.   end.   apply "VALUE-changed" to br-gds in frame d-gob-doc-ref.
  end.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-loc-code:
def var str-code as integer no-undo.
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
define buffer l-goods for ub.goods.
define buffer l-bar-code for ub.bar-code.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
  assign
  frame d-gob-doc-ref
  loc-code
  a-n-c.
  if a-n-c = "datamatrix"
  then do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_dm-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  p-obj-type
,input  p-obj-code
,input  yes
,input  no
,input  varscales-pref25
,input  varpgscales-pref25
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
     if varresult eq "prod-bc"
     then
        loc-code:screen-value in frame d-gob-doc-ref = buf_prod-bc.b-str.
  end.
  else do:
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  loc-code
,input  ?
,input  p-obj-type
,input  p-obj-code
,input  yes
,input  no
,input  varscales-pref25
,input  varpgscales-pref25
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
  end.
  if available buf_bar-code then do:
    find first l-gob-doc where
               l-gob-doc.gds-code = buf_bar-code.gds-code AND
               l-gob-doc.obj-type = p-obj-type AND
               l-gob-doc.obj-code = p-obj-code no-lock no-error.
    if not available l-gob-doc then
    find first l-gob-doc where
                buf_bar-code.gds-code = l-gob-doc.gds-code
               no-lock no-error.
    if available l-gob-doc then do:
      line-rec = recid (l-gob-doc).
      reposition br-gds to recid line-rec no-error.
      if error-status:error then do:     run ref/gdsrepos.p (input 1,                    input g-cond,                    input g-list,                    input g-stat,                    input flt-rec,                    output g#log,                    output contin).     if g#log then do:       run full-sch.       return error.     end.   end.   apply "VALUE-changed" to br-gds in frame d-gob-doc-ref.
      if b-mark:sensitive then apply "choose" to b-mark in frame d-gob-doc-ref.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.
  end.
  else
    message "Бар-код не найден."
            view-as alert-box error.
  apply "entry" to loc-code in frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE  proc-mouse-dbl-click-loc-name:
  if
  frame d-gob-doc-ref
  loc-name <> loc-name:screen-value OR
     last-event:label = "Ctrl-J" then
    contin = no.
  assign
  frame d-gob-doc-ref
  loc-name.
  REPEAT :
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  case g-list :
    when 'все':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.obj-type = p-obj-type                                  and l-gob-doc.obj-code = p-obj-code and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.obj-type = p-obj-type                                  and l-gob-doc.obj-code = p-obj-code and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
        when 'факт':U then do:
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
        when 'свободно':U then do:
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
      end.
    end.
    when 'Производитель':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
        when 'факт':U then do:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
        when 'свободно':U then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.prod-type = g-producer.obj-type                                  and l-gob-doc.prod-code = g-producer.obj-code                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
      end.
    end.
    when 'группа':U then do:
      case g-cond :
        when 'объект':U then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
        when 'факт':U then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.fact-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
        when 'свободно':U then do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run waitfram-show in this-procedure ("Ждите... Поиск по названию, когда Фильтр не все - это долго.").
  if last-event:label = "Ctrl-J"  or contin then do:
    find next l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
    if avail(l-gob-doc) then contin = no.
    end.
  else do:
    find first l-gob-doc where l-gob-doc.grp-name begins g-grp                                  and l-gob-doc.obj-type    = p-obj-type                                  and l-gob-doc.obj-code   = p-obj-code                                  and l-gob-doc.free-qnty > 0 and
    can-find (ub.goods where ub.goods.artic          = l-gob-doc.artic
                                  and ub.goods.prod-type = l-gob-doc.prod-type
                                  and ub.goods.prod-code = l-gob-doc.prod-code
                                  and ub.goods.gds-name begins loc-name no-lock) no-lock no-error.
        contin = no.
    end.
  run waitfram-hide in this-procedure .
        end.
      end.
    end.
  end.
    if available l-gob-doc then do:
      line-rec = recid (l-gob-doc).
      reposition br-gds to recid line-rec no-error.
         if error-status:error then do:     run ref/gdsrepos.p (input 2,                    input g-cond,                    input g-list,                    input g-stat,                    input flt-rec,                    output g#log,                    output contin).     if not contin then do:       run full-sch.       return error.     end.     end.   apply "VALUE-changed" to br-gds in frame d-gob-doc-ref.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
      contin = no.
    end.
    if not contin then
      leave.
    if contin = ? then
      return error.
  end.
  apply "entry" to loc-name in frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE proc-mouse-dbl-click-namec:
  assign
  frame d-gob-doc-ref
  NameContext .
  NameContext = prep-nameorcode (NameContext).
  if NameContext = "" then  return error .
  display
  trim(namecontext, "*") @ namecontext
  with frame d-gob-doc-ref .
  run openbr in this-procedure ( input no, input yes ,input no, input '').
  apply "entry" to NameContext in frame d-gob-doc-ref.
END PROCEDURE.
on value-changed of br-gds in frame d-gob-doc-ref do:
if not available gob-doc or recid (gob-doc) <> line-rec then do:
    hide loc-art in frame d-gob-doc-ref.
    loc-art = "".
end.
FIND FIRST goo-doc NO-LOCK WHERE
           goo-doc.artic     = gob-doc.artic
       AND goo-doc.prod-code = gob-doc.prod-code
       AND goo-doc.prod-type = gob-doc.prod-type
       USE-INDEX pi NO-ERROR.
    if available gob-doc then do:
      assign
        g-rep = recid( gob-doc )
      .
    end.
    IF mImagePh THEN
    DO:
        IF AVAILABLE goo-doc THEN
        DO:
            DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
            DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
            RUN gds-attr-value (goo-doc.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
            RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, goo-doc.gds-code, OUTPUT vImageList).
            vCh = ENTRY (1, vImageList, ",":U).
        END.
        g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    END.
    if vCh <> "" then do:
      ASSIGN
        FI-4:FORMAT in frame d-gob-doc-ref = "X(30)"
        FI-4:WIDTH-CHARS in frame d-gob-doc-ref = 30
        FI-6:FORMAT in frame d-gob-doc-ref = "X(30)"
        FI-6:WIDTH-CHARS in frame d-gob-doc-ref = 30
        FI-8:FORMAT in frame d-gob-doc-ref = "X(30)"
        FI-8:WIDTH-CHARS in frame d-gob-doc-ref = 30
      .
    end.
    else do:
     ASSIGN
        FI-4:FORMAT in frame d-gob-doc-ref = "X(49)"
        FI-4:WIDTH-CHARS in frame d-gob-doc-ref = 45
        FI-6:FORMAT in frame d-gob-doc-ref = "X(49)"
        FI-6:WIDTH-CHARS in frame d-gob-doc-ref = 45
        FI-8:FORMAT in frame d-gob-doc-ref = "X(49)"
        FI-8:WIDTH-CHARS in frame d-gob-doc-ref = 45
      .
    end.
    RUN gds-ref-fi IN THIS-PROCEDURE ( BUFFER       goo-doc,
                                       BUFFER       gob-doc,
                                       INPUT        p-obj-type,
                                       INPUT        p-obj-code,
                                       INPUT        gdsreffi,
                                       input        no  ,
                                       INPUT-OUTPUT fi-1,
                                       INPUT-OUTPUT fi-2,
                                       INPUT-OUTPUT fi-3,
                                       INPUT-OUTPUT fi-4,
                                       INPUT-OUTPUT fi-5,
                                       INPUT-OUTPUT fi-6,
                                       INPUT-OUTPUT fi-7,
                                       INPUT-OUTPUT fi-8
                                     ) NO-ERROR.
    if available goo-doc then do:
      assign
        main-code = ?
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goo-doc.gds-code
  ,input  ?
  ,output main-code
  )  .
    end.
    DISPLAY
      fi-1
      fi-2
      fi-3
      fi-4
      fi-5
      fi-6
      fi-7
      fi-8
      main-code @ goo-doc.gds-code
    WITH FRAME d-gob-doc-ref.
end.
ON ROW-DISPLAY OF br-gds  in frame d-gob-doc-ref do:
      run assort-polit in this-procedure (  input  gob-doc.gds-code ,
                                            input  p-obj-type           ,
                                            input  p-obj-code           ,
                                            output v-indicator-life-gds ,
                                            output v-assort-min          )
                                            no-error.
                                            if error-status :error then  message error-status :get-message(1)  .
     case v-indicator-life-gds :
        when 'Новинка':U then do:
           v-indicator-life-gds:bgcolor  in browse br-gds   = 14 .
        end.
        when 'На вывод из ассортимента':U then do:
           v-indicator-life-gds:bgcolor  in browse br-gds   = 12 .
        end.
        when 'Нештатный':U then do:
           v-indicator-life-gds:bgcolor  in browse br-gds   = 8 .
        end.
     end case.
     v-indicator-life-gds:screen-value = v-indicator-life-gds .
     v-assort-min:screen-value = string(v-assort-min,"*/ ").
end.
on choose of b-gdsreffi in frame d-gob-doc-ref do:
  run gds-ref-to-description in this-procedure .
end.
on value-changed of rs-list in frame d-gob-doc-ref do:
  run proc-rs-list in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on value-changed of rs-cond in frame d-gob-doc-ref do:
  run proc-vc-rs-cond in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
ON value-changed OF rs-stat in frame d-gob-doc-ref
DO:
  run proc-rs-stat in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
END.
ON value-changed OF rs-sort in frame d-gob-doc-ref
DO:
  run proc-rs-sort in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
END.
on end-error, stop of frame d-gob-doc-ref do:
  apply "choose":U to b-exit in frame d-gob-doc-ref.
  return no-apply.
end.
on endkey of frame d-gob-doc-ref do:
    run gbl/markqwa.p (
                            input b-mark :sensitive
                          , input rid-list          ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on return, MOUSE-SELECT-DBLCLICK of br-gds in frame d-gob-doc-ref do:
  run proc-br-gds in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-price-1 in menu m-price DO:
  run proc-b-price(input 1 , buffer goo-doc, buffer gob-doc) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-price-2 in menu m-price DO:
  run proc-b-price(input 2 , buffer goo-doc, buffer gob-doc) no-error.
  if error-status:error then return no-apply.
end.
on choose of b-exit in frame d-gob-doc-ref do:
  run gbl/markqwa.p (
                            input b-mark :sensitive
                          , input rid-list          ) no-error.
  if error-status :error then do: return no-apply. end.
  run proc-b-exit in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-sel in frame d-gob-doc-ref do:
  run proc-b-sel in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-arch in frame d-gob-doc-ref do:
  if available goo-doc then do:
    run local-gds_inf in this-procedure.
  end.
end.
ON CHOOSE OF b-sch in frame d-gob-doc-ref
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
END.
on choose of b-recip in frame d-gob-doc-ref do:
  run b-recip-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-rest in frame d-gob-doc-ref do:
  run gbl/pop-up.p ( input self :handle, input no ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-ostatki-1 in menu m-ostatki DO:
  run proc-m-ostatki-1 in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-ostatki-2 in menu m-ostatki DO:
  run proc-m-ostatki-2 in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-card in frame d-gob-doc-ref do:
  run gbl/pop-up.p ( input self :handle, input no ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-oborot-1 in menu m-oborot DO:
  run proc-m-oborot-1 in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-oborot-2 in menu m-oborot DO:
  run proc-m-oborot-2 in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-chk in frame d-gob-doc-ref do:
  run b-chk-proc in this-procedure ( buffer goo-doc, buffer gob-doc ).
end.
on choose of b-sert in frame d-gob-doc-ref do:
  run proc-b-sert in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-lkp in frame d-gob-doc-ref do:
  run proc-b-lkp in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-prt in frame d-gob-doc-ref do:
  run proc-b-prt in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-parts in frame d-gob-doc-ref do:
  run b-parts-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-gob-doc-ref anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-gob-doc-ref. END.
  return no-apply.
end.
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-gob-doc-ref anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-gob-doc-ref. END.
  return no-apply.
end.
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-gob-doc-ref anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-gob-doc-ref. END.
  return no-apply.
end.
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-gob-doc-ref anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-gob-doc-ref. END.
  return no-apply.
end.
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-gob-doc-ref anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-gob-doc-ref. END.
  return no-apply.
end.
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame d-gob-doc-ref anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame d-gob-doc-ref. END.
  return no-apply.
end.
on choose of b-mark in frame d-gob-doc-ref do:
    run b-mark-proc in this-procedure .
end.
on choose of b-alt-bc in frame d-gob-doc-ref
do:
  run b-alt-bc-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
  apply "entry":U to br-gds in frame d-gob-doc-ref.
end.
on choose of b-copy in frame d-gob-doc-ref
do:
  run b-copy-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-add in frame d-gob-doc-ref
do:
  run proc-b-add in this-procedure ( buffer goo-doc, buffer gob-doc, input yes ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-add-office in frame d-gob-doc-ref
do:
  run proc-b-add in this-procedure ( buffer goo-doc, buffer gob-doc, input no ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-chg in frame d-gob-doc-ref
do:
  run proc-b-chg in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-grp in frame d-gob-doc-ref do:
  run proc-b-grp in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-del in frame d-gob-doc-ref do:
  run b-del-proc in this-procedure ( buffer goo-doc, buffer gob-doc ) no-error.
  if error-status :error then do: return no-apply. end.
  else do:
    run openbr in this-procedure ( input yes, input yes, input no, input '':U ).
  end.
end.
on choose of b-place in frame d-gob-doc-ref do:
  run b-place-proc in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  APPLY "ENTRY":U TO b-place IN FRAME d-gob-doc-ref.
end.
on choose of b-dinamo in frame d-gob-doc-ref do:
  run b-dinamo-proc in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  APPLY "ENTRY":U TO b-dinamo IN FRAME d-gob-doc-ref.
end.
on choose of b-hist in frame d-gob-doc-ref do:
  run b-hist-proc in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
  APPLY "ENTRY":U TO b-hist IN FRAME d-gob-doc-ref.
end.
ON CHOOSE OF add-inf IN FRAME d-gob-doc-ref
DO:
  if dopinf-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if dopinf-option = "":U then do: return no-apply. end.
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
END.
on choose of MENU-ITEM m-dopinf-1 in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-2 in menu m-dopinf DO:
  assign
    dopinf-option = "foto":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-lgattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-gbl":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-lhattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-host":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-loattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-obj-one":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-ldgr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-dgr-one":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-mdgr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-dgr-cmp":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-moattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-obj-cmp":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-lfgds in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-fbr-gds-obj":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-lscoef in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-s-coeff":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ПРОСМОТР':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-lprop in menu m-dopinf DO:
  assign
    dopinf-option = "indicators":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ПРОСМОТР':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-AM in menu m-dopinf DO:
  assign
    dopinf-option = "AM":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ПРОСМОТР':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-msf in menu m-dopinf DO:
  assign
    dopinf-option = "msf":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ПРОСМОТР':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-contr in menu m-dopinf DO:
  assign
    dopinf-option = "contr":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ПРОСМОТР':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-lprop-ord in menu m-dopinf DO:
  assign
    dopinf-option = "orders":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ПРОСМОТР':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-lprop-ordf in menu m-dopinf DO:
  assign
    dopinf-option = "ordersf":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ПРОСМОТР':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-cgattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-gbl":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ИЗМЕНЕНИЕ':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-chattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-host":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ИЗМЕНЕНИЕ':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-coattr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-obj-one":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ИЗМЕНЕНИЕ':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-cdgr in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-dgr-one":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ИЗМЕНЕНИЕ':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-cfgds in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-fbr-gds-obj":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ИЗМЕНЕНИЕ':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-cscoef in menu m-dopinf DO:
  assign
    dopinf-option = "dop-inf-s-coeff":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ИЗМЕНЕНИЕ':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of MENU-ITEM m-dopinf-cprop in menu m-dopinf DO:
  assign
    dopinf-option = "indicators":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ИЗМЕНЕНИЕ':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-cprop-ord in menu m-dopinf DO:
  assign
    dopinf-option = "orders":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ИЗМЕНЕНИЕ':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-cprop-ordf in menu m-dopinf DO:
  assign
    dopinf-option = "ordersf":U
  .
  run proc-b-add-inf  in this-procedure  (input-output dopinf-option, 'ИЗМЕНЕНИЕ':U) no-error.
  if error-status:error then return no-apply.
end.
on choose of MENU-ITEM m-dopinf-alt-unit in menu m-dopinf DO:
  assign
    dopinf-option = "alt-unit":U
  .
  run proc-b-add-inf in this-procedure ( input-output dopinf-option, 'ИЗМЕНЕНИЕ':U ) no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-obj in frame d-gob-doc-ref do:
  run proc-b-obj in this-procedure ( input "change":U ).
end.
on choose of b-extart in frame d-gob-doc-ref do:
  run proc-b-extart in this-procedure ( buffer goo-doc , buffer gob-doc ) no-error .
  if error-status :error then do :
    return no-apply.
  end.
end.
ON ANY-KEY OF loc-code IN FRAME d-gob-doc-ref
DO:
  if a-n-c = "DataMatrix" then
    if lastkey = 308 then
      return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME d-gob-doc-ref
DO:
    DEFINE VARIABLE v-main-code LIKE ub.bar-code.b-code NO-UNDO.
    RUN ref/imagelist.w (parParentProc, "":U, goo-doc.gds-code, 'ПРОСМОТР':U).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-gob-doc-ref:PARENT eq ?
THEN FRAME d-gob-doc-ref:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-gob-doc-ref APPLY "END-ERROR":U TO SELF.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-gob-doc-ref
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame d-gob-doc-ref
do:
  apply "help":u to frame d-gob-doc-ref .
end.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame d-gob-doc-ref:width - 0.3
                fh            = frame d-gob-doc-ref:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-gob-doc-ref :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-gob-doc-ref :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-gob-doc-ref :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-gob-doc-ref :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-gob-doc-ref :height = v-frame-height
          .
          if frame d-gob-doc-ref :scrollable = true
          then do:
            assign
              frame d-gob-doc-ref :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-gob-doc-ref :scrollable = true
          then do:
            assign
              frame d-gob-doc-ref :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-gob-doc-ref :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame d-gob-doc-ref :height
      v-frame-virtual-height = frame d-gob-doc-ref :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-gob-doc-ref :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-gob-doc-ref
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-gob-doc-ref :scrollable = true
      then do:
        assign
          frame d-gob-doc-ref :virtual-height = frame d-gob-doc-ref :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-gob-doc-ref :height = frame d-gob-doc-ref :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-gob-doc-ref :height = frame d-gob-doc-ref :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-gob-doc-ref :scrollable = true
      then do:
        assign
          frame d-gob-doc-ref :virtual-height = frame d-gob-doc-ref :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame d-gob-doc-ref :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame d-gob-doc-ref :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-gob-doc-ref :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-gob-doc-ref :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-gob-doc-ref :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-gob-doc-ref :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-gob-doc-ref :width = v-frame-width
          .
          if frame d-gob-doc-ref :scrollable = true
          then do:
            assign
              frame d-gob-doc-ref :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-gob-doc-ref :scrollable = true
          then do:
            assign
              frame d-gob-doc-ref :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-gob-doc-ref :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame d-gob-doc-ref :width
      v-frame-virtual-width = frame d-gob-doc-ref :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-gob-doc-ref :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-gob-doc-ref
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-gob-doc-ref :scrollable = true
      then do:
        assign
          frame d-gob-doc-ref :virtual-width = frame d-gob-doc-ref :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-gob-doc-ref :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame d-gob-doc-ref :width = frame d-gob-doc-ref :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-gob-doc-ref :scrollable = true
      then do:
        assign
          frame d-gob-doc-ref :virtual-width = frame d-gob-doc-ref :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame d-gob-doc-ref :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame d-gob-doc-ref :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-gob-doc-ref
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-gob-doc-ref :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-gob-doc-ref :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-gob-doc-ref :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-gob-doc-ref :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame d-gob-doc-ref
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame d-gob-doc-ref :height
      v-col-delta = v-new-col - frame d-gob-doc-ref :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame d-gob-doc-ref :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-gob-doc-ref :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-gob-doc-ref :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-gob-doc-ref :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame d-gob-doc-ref :width
      v-diasize-current-frame-height = frame d-gob-doc-ref :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame d-gob-doc-ref
    :
      assign
        v-diasize-orig-frame-height = frame d-gob-doc-ref :height
        v-diasize-orig-frame-width  = frame d-gob-doc-ref :width
        v-diasize-browse-handle     = browse br-gds :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-gob-doc-ref :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-gds :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame d-gob-doc-ref anywhere
do:
   if available goo-doc then gds-rec = recid(goo-doc). RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '' ).
    apply "VALUE-CHANGED" to br-gds.
end.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-gob-doc-ref:
    if p-filter-name > "" then do:
      assign
        frame d-gob-doc-ref:title
          = frame d-gob-doc-ref:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run main-block-proc in this-procedure no-error.
  if error-status :error then do: return error. end.
  WAIT-FOR GO OF FRAME d-gob-doc-ref FOCUS br-gds.
END.
assign
p-gds-name-width = gds-n:width in browse br-gds
p-grp-name-width = gob-doc.grp-name:width in browse br-gds
.
RUN disable_UI IN THIS-PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-gob-doc-ref NO-PAUSE.
END PROCEDURE.
PROCEDURE openbr :
define input parameter p-repos-message as logical no-undo .
define input parameter p-open-query as logical   no-undo .
define input parameter p-find-next as logical   no-undo .
define input parameter p-find-condition as character no-undo .
DEFINE VARIABLE pos-rec AS RECID NO-UNDO .
define buffer pos_goods for ub.goods.
define buffer cur-obj   for ub.clients.
FIND FIRST cur-obj NO-LOCK WHERE
          cur-obj.obj-type = p-obj-type
      AND cur-obj.obj-code = p-obj-code .
ASSIGN
FRAME d-gob-doc-ref rs-sort
.
assign
  filter-point = "gob-doc" + "_" + string( g-stat )
  filter-label = "Все_товары_по_объекту" + "_" + string( g-stat )
.
  run ref/gds-refb.p ( input  p-open-query                         ,input  p-find-next                         ,input  p-find-condition                                                  ,input a-n-c                         ,input NameContext                         ,input rs-sort                         ,input g-cond                          ,input g-list                          ,input g-stat                          ,input g-grp                           ,input p-obj-type                         ,input p-obj-code                         ,buffer g-producer                         ,buffer cur-obj                            ,output for-title                                                  ,input filter-point                          ,input filter-point0                         ,input sort-column-name                         ,output v-filter-name                         ,input-output g-rep                         ).
assign
frame d-gob-doc-ref :title = for-title
.
if g-list = "ptrl"
or g-list = "lgas"
or g-list = "ptrlsug"
or g-list = "only-np"
then do:
  assign
  rs-list = 'все':U
  rs-stat = 'текущие':U
  rs-cond = 'все':U
  .
  DISPLAY
  rs-list rs-cond rs-stat
  WITH FRAME d-gob-doc-ref.
  disable
  rs-list rs-cond rs-stat
  WITH FRAME d-gob-doc-ref.
end.
else do:
  assign
  rs-list = g-list
  rs-stat = g-stat
  rs-cond = g-cond
  .
  DISPLAY
  rs-list rs-cond rs-stat
  WITH FRAME d-gob-doc-ref.
end.
run set-filter-name in this-procedure (INPUT v-filter-name) no-error .
if g-rep <> ? then do:
  reposition br-gds to recid g-rep no-error.
  if error-status :error then do:
    if p-repos-message and g-rep = v-chg-rec then do:
      pos-rec = g-rep.
      find first pos_goods no-lock where       recid( pos_goods ) = pos-rec no-error .   message     "Невозможно позиционироваться на товаре" skip      string( if available pos_goods              then  ( pos_goods.artic + chr(32) + pos_goods.prod-type + " ":U +              string( pos_goods.prod-code ) + " ":U + pos_goods.gds-name )              else "":U ) skip     "Товар был добавлен (или изменен или удален) -" skip     "и теперь не попадает в текущую выборку"   view-as alert-box WARNING.
      v-chg-rec = ?.
    end.
    if num-results( "br-gds" ) <> 0 then do:
      g#log = br-gds :select-row( 1 ) .
      g#log = br-gds :scroll-to-selected-row( 1 ) .
    end.
  end.
end.
apply "entry":U to br-gds in frame d-gob-doc-ref.
if available gob-doc then do:
  assign
    g#log = br-gds :SELECT-PREV-ROW( )
  .
  if g#log = yes then do:
    assign
      g#log = br-gds :SELECT-NEXT-ROW( )
    .
  end.
end.
apply "value-changed":U to br-gds in frame d-gob-doc-ref.
if ( g-list = g-cond or ( g-cond = 'объект':U and g-list = 'все':U ) ) and rs-sort = 'Артикул':U then do:
  assign
    start = yes
  .
end.
if start and not from-b-sch then do:
  run UI-on in this-procedure.
  if v-chg-rec <> ? then do:
    reposition br-gds to recid v-chg-rec no-error.
    if error-status :error then do:
      if p-repos-message then do:
        pos-rec = v-chg-rec.
        find first pos_goods no-lock where       recid( pos_goods ) = pos-rec no-error .   message     "Невозможно позиционироваться на товаре" skip      string( if available pos_goods              then  ( pos_goods.artic + chr(32) + pos_goods.prod-type + " ":U +              string( pos_goods.prod-code ) + " ":U + pos_goods.gds-name )              else "":U ) skip     "Товар был добавлен (или изменен или удален) -" skip     "и теперь не попадает в текущую выборку"   view-as alert-box WARNING.
      end.
      if num-results( "br-gds" ) <> 0 then do:
        assign
        g#log = br-gds :select-row( 1 )
        .
        assign
        g#log = br-gds :scroll-to-selected-row( 1 )
        .
      end.
    end.
    assign
    v-chg-rec = ?
    .
  end.
end.
RUN buttons IN THIS-PROCEDURE.
assign
start = no
.
END PROCEDURE.
PROCEDURE full-sch :
        FIND FIRST goo-doc NO-LOCK WHERE
                   goo-doc.artic     = l-gob-doc.artic     AND
                   goo-doc.prod-type = l-gob-doc.prod-type AND
                   goo-doc.prod-code = l-gob-doc.prod-code .
        assign
          g-rep = recid( goo-doc )
        .
        if a-n-c = "art" then do:
          assign
            sch-rec = g-rep
          .
        end.
        assign
          g-stat = 'все':U
          g-cond = 'все':U
          g-list = 'все':U
        .
        apply "go":U to frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE buttons :
  if lookup( "b-add", bttns ) > 0
  AND ub.db.add-goods AND NOT transaction and lookup( "no-object":U, p-other, chr(4) ) = 0
  then do:
    enable
    b-add
    b-add-office
    b-grp
    b-del    b-copy b-chg
    with frame d-gob-doc-ref.
  end.
  else do:
    disable
    b-add
    b-add-office
    b-grp
    b-del
    b-copy
    b-chg
    with frame d-gob-doc-ref.
  end.
  if not ub.db.add-goods
  and v-cntxt-db-num = 0 then do:
    enable
    b-grp
    with frame d-gob-doc-ref .
  end.
  if is-fbr = yes then do:
    enable
      b-recip
    with frame d-gob-doc-ref.
  end.
  else do:
    disable
      b-recip
    with frame d-gob-doc-ref.
  end.
  if is-fbr <> yes then do:
    assign
    menu-item m-dopinf-lfgds :sensitive in menu m-dopinf = no
    menu-item m-dopinf-lscoef :sensitive in menu m-dopinf = no
    menu-item m-dopinf-cfgds :sensitive in menu m-dopinf = no
    menu-item m-dopinf-cscoef :sensitive in menu m-dopinf = no
    .
  end.
END PROCEDURE.
PROCEDURE controls :
ENABLE
b-exit b-arch b-price b-rest b-card b-chk b-lkp b-prt b-parts b-gdsreffi b-place b-dinamo b-sert b-hist add-inf
b-alt-bc
b-help
rs-list rs-cond rs-stat rs-sort a-n-c br-gds
b-sch
b-sel  WHEN LOOKUP( "b-sel",  bttns ) > 0
b-mark WHEN LOOKUP( "b-mark", bttns ) > 0
b-extart
WITH FRAME d-gob-doc-ref.
IF mImagePh THEN
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
if lookup( "no-object":U, p-other, chr(4) ) > 0 then do:
  if v-obj-name = "":U then do:
    run proc-b-obj in this-procedure ( input "":U ).
  end.
  hide
  b-add b-add-office
  b-grp b-del b-copy b-chg
  in frame d-gob-doc-ref .
  display
  b-obj
  v-obj-type
  v-obj-code
  v-obj-name
  with frame d-gob-doc-ref .
  enable
  b-obj
  with frame d-gob-doc-ref .
end.
if a-n-c = "art" then do:
  display
  loc-art
  with frame d-gob-doc-ref.
end.
else do:
  hide loc-art loc-name loc-code NameContext in frame d-gob-doc-ref.
end.
CASE g-cond :
  when 'все':U then do:
    assign
    rs-sort = 'Артикул':U
    .
    display
    rs-sort
    with frame d-gob-doc-ref .
    disable
    rs-sort
    with frame d-gob-doc-ref .
  end.
  when 'объект':U then do:
    assign
    rs-sort = 'Артикул':U
    .
    enable
    rs-sort
    with frame d-gob-doc-ref .
    assign
    g#log = rs-sort :disable("Количество")
    .
    display
    rs-sort
    with frame d-gob-doc-ref .
  end.
  otherwise do:
    enable
    rs-sort
    with frame d-gob-doc-ref .
    assign
    g#log = rs-sort :enable("Количество")
    .
    display
    rs-sort
    with frame d-gob-doc-ref .
  end.
END CASE .
END PROCEDURE.
PROCEDURE enable_UI :
RUN buttons  IN THIS-PROCEDURE.
RUN controls IN THIS-PROCEDURE.
RUN openbr  IN THIS-PROCEDURE ( INPUT NO, input yes, input no, input '':U).
END PROCEDURE.
PROCEDURE UI-on :
DEFINE VARIABLE var-disable-sort AS LOGICAL NO-UNDO .
if flt-rec <> ? then do:
  if var-disable-sort then do:
    DISABLE
    rs-sort
    WITH FRAME d-gob-doc-ref.
  end.
  else do:
    ENABLE
    rs-sort
    WITH FRAME d-gob-doc-ref.
  end.
end.
else do:
  ENABLE
  rs-sort
  WITH FRAME d-gob-doc-ref.
  if from-b-sch then do:
    RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '' ) .
  end.
end.
apply "entry":U             to br-gds in frame d-gob-doc-ref.
apply "value-changed":U to br-gds in frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE b-mark-proc:
    if not available gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST goo-doc WHERE goo-doc.artic     = gob-doc.artic                      AND goo-doc.prod-type = gob-doc.prod-type                      AND goo-doc.prod-code = gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( goo-doc ) .
    define variable v-num-entry as integer no-undo .
    assign
      v-num-entry = lookup( string( recid( goo-doc ) ), rid-list )
    .
    if v-num-entry > 0 then do:
      assign
        entry( v-num-entry, rid-list ) = "":U
      .
      assign
        rid-list = trim( replace( rid-list, chr(44) + chr(44), chr(44) ), chr(44) )
      .
    end.
    else do:
      if num-entries( rid-list ) >= 4000 then do:
        message "Превышено максимально допустимое количество выбранных товаров"
                "Воспользуйстесь добавлением товаров через список товаров, если это возможно"
        view-as alert-box WARNING.
        undo, return error.
      end.
      assign
        rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + string( recid( goo-doc) )
      .
    end.
    assign
      g#log = br-gds :refresh( ) in frame d-gob-doc-ref
    .
    if num-entries( rid-list ) = 0 then do:
        hide
          mark-num in frame d-gob-doc-ref.
    end.
    else do:
        display
          num-entries( rid-list ) @ mark-num
        with frame d-gob-doc-ref.
    end.
    if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,Return" ) = 0 then
        do:
            assign
              g#log = br-gds :select-next-row () in frame d-gob-doc-ref
            .
            apply "value-changed":U to br-gds in frame d-gob-doc-ref.
        end.
    apply "entry":U to br-gds in frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE b-del-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  define variable v-stts like ub.goods.stts no-undo .
  define buffer loc_gds-obj for ub.gds-obj.
    if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
    assign
      g#log = FALSE
    .
    CASE loc-goo-doc.gds-type :
      when 'т':U then do:
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_deletion':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  loc-goo-doc.grp-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
      end.
      when 'у':U then do:
define variable vss-include-info71 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference-services_deletion':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  loc-goo-doc.grp-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип товара" skip
          "Тип товара" loc-goo-doc.gds-type skip
          "Код товара" loc-goo-doc.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    END CASE.
    if NOT g#log then do: return error . end.
    v-stts = ?.
    run ref/goods02.p (
                   input gds-rec
                  ,input no
                  ,input-output v-stts) no-error.
    if error-status:error then do:
      apply "entry":U to br-gds in frame d-gob-doc-ref.
      return error.
    end.
    assign
    g-rep            = recid( loc-gob-doc )
    v-chg-rec        = g-rep.
END PROCEDURE.
PROCEDURE local-find:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  assign
    vat-p = ?
    SLT-p = ?
  .
  FIND FIRST loc-goo-doc NO-LOCK WHERE
             loc-goo-doc.artic     = loc-gob-doc.artic     AND
             loc-goo-doc.prod-code = loc-gob-doc.prod-code AND
             loc-goo-doc.prod-type = loc-gob-doc.prod-type
                                  USE-INDEX pi NO-ERROR.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  loc-goo-doc.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output vat-p
  ) no-error .
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  loc-goo-doc.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output slt-p
  ) no-error .
  assign
    e-name = loc-goo-doc.engl-name
    gds-n  = (if loc-goo-doc.stts = 0 then loc-goo-doc.gds-name else  (substring( loc-goo-doc.gds-name, 1, 15 ) + chr(32) + '<':U + CAPS(entry (lookup (string(loc-goo-doc.stts), '0,1,50,51':U), 'тек,удал,блок.для.смены.арт.,смена.арт.':U)) + '>':U  ))
    gds-t  = ( if loc-goo-doc.gds-type = 'т':U then "-" else "+" )
    unit-b = loc-goo-doc.unit-base
    qnty-c = loc-goo-doc.qnty-cart
  .
END PROCEDURE.
PROCEDURE b-chk-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  DEFINE VARIABLE rid-list    AS   CHARACTER          NO-UNDO .
  DEFINE VARIABLE v-main-code LIKE ub.bar-code.b-code NO-UNDO .
  DEFINE BUFFER buf_units FOR ub.units.
  do
  on error undo, return error
  :
    if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  loc-goo-doc.gds-code
  ,input  ?
  ,output v-main-code
  )  .
    FIND FIRST ub.gds-prt NO-LOCK WHERE
               ub.gds-prt.upper-code = loc-goo-doc.prt-root.
    find first buf_units No-LOCK WHERE
               buf_units.unit-name = loc-goo-doc.unit-base .
    if ub.gds-prt.node-name = '_Пустая шкала':U
    or not v-doc-prt = yes then do:
      if lookup( 'сер':U, buf_units.type ) > 0 then do:
        run ref/gds-chks.w (  INPUT parparentproc
                       ,  INPUT RECID( loc-goo-doc )
                       ,  INPUT "":U
                       ,  INPUT 'объект':U
                       ,  INPUT ?
                       ,  INPUT p-obj-type
                       ,  INPUT p-obj-code
                       ,  INPUT "":U
                       ,  INPUT "":U
                       , OUTPUT rid-list
                       ) .
      end.
      else do:
        run ref/gds-chk.w (  INPUT parparentproc
                      ,  INPUT v-main-code
                      ,  INPUT "":U
                      ,  INPUT 'объект':U
                      ,  INPUT ?
                      ,  INPUT p-obj-type
                      ,  INPUT p-obj-code
                      ,  INPUT "":U
                      ,  INPUT "":U
                      , OUTPUT rid-list
                      ) .
      end.
    end.
    else do:
      message
        "Товар делится на признаки - смотрите чеки через шкалу."
      view-as alert-box.
    end.
    apply "entry":U to br-gds in frame d-gob-doc-ref.
  end.
END PROCEDURE.
PROCEDURE proc-m-ostatki-1:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
    if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return error. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
    FIND FIRST ub.gds-prt NO-LOCK WHERE
               ub.gds-prt.upper-code = loc-goo-doc.prt-root .
    run rep/gds-objs.w (
                     INPUT parparentproc,
                     INPUT loc-goo-doc.artic,
                     INPUT loc-goo-doc.prod-type,
                     INPUT loc-goo-doc.prod-code,
                     INPUT v-host-code,
                     INPUT -1
                   ).
    apply "entry":U to br-gds in frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE proc-m-ostatki-2:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return error. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
  run ref/cli-gdss.w
                 (input parparentproc
                 ,input 'Товар,Остатки':U
                 ,input recid( loc-goo-doc )
                 ,input ?
                 )
  .
  apply "entry":U to br-gds in frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE proc-m-oborot-1:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return error. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
  assign
    g#log = no
  .
  message "Вывод отчета предполагает РАСЧЕТ АРХИВОВ по товарам" skip
          "Продолжать?"
  view-as alert-box QUESTION buttons YES-NO update g#log.
  if g#log = yes then do:
    run rep/e-good2.w ( input parParentProc,
                    input loc-gob-doc.artic,
                    input loc-gob-doc.prod-type,
                    input loc-gob-doc.prod-code,
                    input ?,
                    input ?,
                    input p-obj-type,
                    input p-obj-code          ) no-error.
  end.
  apply "entry":U to br-gds in frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE proc-m-oborot-2:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return error. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
  run ref/cli-gdss.w (
                   input parparentproc
                 , input 'Товар,Обороты':U
                 , input recid( loc-goo-doc )
                 , input ?
                 ).
  apply "entry":U to br-gds in frame d-gob-doc-ref.
END PROCEDURE.
PROCEDURE proc-b-sch:
run init-flt in this-procedure no-error.
if error-status :error then do:
  return error.
 end.
DO ON STOP UNDO, LEAVE :
  run gbl/filter.w ( INPUT parparentproc
                    ,INPUT (filter-point + chr(4) + filter-label)
                    ,INPUT tbl
                    ,INPUT join-tbl
                    ,INPUT fld
                    ,INPUT lab
                    ,INPUT spr
                    ,INPUT dim
                    )
                        .
  ASSIGN
  from-b-sch = YES
  .
  RUN UI-on IN THIS-PROCEDURE.
  ASSIGN
  from-b-sch = NO
  .
END.
run buttons in this-procedure.
END PROCEDURE.
PROCEDURE proc-find:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  define variable for-last-pcnt as decimal column-label "Торг.наценка" format "->>>,>>9.99%" no-undo.
  assign
    val-vat = ?
    val-SLT = ?
  .
  FIND FIRST ub.recipe NO-LOCK WHERE
             ub.recipe.prod-type = loc-goo-doc.prod-type
         AND ub.recipe.prod-code = loc-goo-doc.prod-code
         AND ub.recipe.artic     = loc-goo-doc.artic
         AND
           (
           ( ub.recipe.obj-type  = loc-gob-doc.obj-type
         AND ub.recipe.obj-code  = loc-gob-doc.obj-code
           )
          OR
           ( ub.recipe.obj-type  = "":U
         AND ub.recipe.obj-code  = 0
           )
           )
         NO-ERROR.
    assign
      mark-recipe = ( if available ub.recipe then ub.recipe.recipe-type else "":U )
      mark        = ( if lookup( string( recid( loc-goo-doc ) ), rid-list ) > 0 then "*" else "":U )
    .
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  loc-goo-doc.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output val-vat
  ) no-error .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  loc-goo-doc.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output val-slt
  ) no-error .
    if available loc-gob-doc then do:
      assign
        fact-q         = loc-gob-doc.fact-qnty
        free-q         = loc-gob-doc.free-qnty
        price          = loc-gob-doc.price-sale
        for-cash-parts = loc-gob-doc.cash-parts
        for-last-price = ( if v-lookup-cost then loc-gob-doc.last-base else ? )
        for-last-pcnt  = ( if v-lookup-cost then ( price /
                         ( if v-curr-r-b = 'base':U then loc-gob-doc.last-base else loc-gob-doc.last-rubl ) *
                           100 - 100 )      else ? )
      .
      if abs( for-last-pcnt ) > 999999.99 then do:
        assign
          for-last-pcnt-str = "############":U
        .
      end.
      else do:
        assign
          for-last-pcnt-str = string( for-last-pcnt, "->>>,>>9.99%":U )
        .
      end.
      if v-is-ptrl = "yes" then do:
        run get-petrol-weight-qty in this-procedure ( buffer loc-goo-doc,
                                                      buffer loc-gob-doc,
                                                      output free-q-cli,
                                                      output fact-q-cli ) no-error.
        if error-status :error then do: return error return-value. end.
      end.
    end.
    else do:
      assign
        fact-q         = 0
        free-q         = 0
        price          = 0
        for-cash-parts = no
        for-last-price = 0
        for-last-pcnt  = ?
        free-q-cli    = 0.0
        fact-q-cli    = 0.0
        v-indicator-life-gds = ""
        v-assort-min         = no
      .
    end.
END PROCEDURE.
PROCEDURE b-recip-proc:
DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
if is-fbr then do:
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
  if loc-goo-doc.gds-type = 'у':U then do:
    BELL.
    return error.
  end.
  FIND FIRST ub.units NO-LOCK WHERE ub.units.unit-name = loc-goo-doc.unit-base .
  if lookup( ub.units.type, 'сер':U ) > 0 then do:
    message "Для серийного товара" skip
            "рецепт задать нельзя !"
    view-as alert-box INFORMATION .
  end.
  else do:
    FIND FIRST ub.gds-prt NO-LOCK WHERE ub.gds-prt.upper-code = loc-goo-doc.prt-root .
    if lookup( ub.gds-prt.node-name, '_Пустая шкала':U ) > 0 then do:
      run ref/rcp-all.w (
                      input parparentproc
                    , input ( if loc-goo-doc.stts = 0
                                  AND ub.db.add-goods
                                  AND NOT transaction
                                then "b-add"
                                else "":U )
                    , input 'все':U
                    , input recid( loc-goo-doc )
                    , input p-obj-type
                    , input p-obj-code
                    , output ref-list
                    ) .
      FIND FIRST ub.recipe NO-LOCK WHERE
                  ub.recipe.prod-type = loc-goo-doc.prod-type
              AND ub.recipe.prod-code = loc-goo-doc.prod-code
              AND ub.recipe.artic     = loc-goo-doc.artic
              AND
                (
                ( ub.recipe.obj-type  = loc-gob-doc.obj-type
              AND ub.recipe.obj-code  = loc-gob-doc.obj-code
                )
              OR
                ( ub.recipe.obj-type  = "":U
              AND ub.recipe.obj-code  = 0
                )
                )
              NO-ERROR.
      assign
        mark-recipe = ( if available ub.recipe then substring( ub.recipe.recipe-type, 1, 1 ) else " ":U )
      .
      DISPLAY
        mark-recipe
      WITH BROWSE br-gds.
    end.
    else do:
      message "Рецепт можно определить" skip
              "только для товара БЕЗ ПРИЗНАКОВ."
      view-as alert-box INFORMATION .
    end.
  end.
  apply "entry":U to br-gds in frame d-gob-doc-ref.
end.
END PROCEDURE.
PROCEDURE proc-rs-list:
  define variable i-rs-list like rs-list no-undo .
  define variable ref-rec   as   recid   no-undo .
    assign
        i-rs-list = input frame d-gob-doc-ref rs-list
    .
    CASE i-rs-list :
        when 'Производитель':U then do:
          assign
            ref-list = "":U
          .
          run ref/cli-all.w (
                           input parparentproc
                        ,  input "b-sel"
                        ,  input 'про':U
                        ,  input 'все':U
                        ,  input 'текущие':U
                        ,  input ?
                        ,  input ",,,,,,NO,,,"
                        ,  input ?
                        , output ref-list
                        ) .
          if ref-list = "":U then do:
            assign
              g-list = 'все':U
            .
            RUN enable_UI IN THIS-PROCEDURE.
            return error.
          end.
          ref-rec = integer( ref-list ).
          FIND FIRST g-producer NO-LOCK WHERE
              RECID( g-producer ) = ref-rec .
          if available g-producer then do:
            assign
              p-producer-type = g-producer.obj-type
              p-producer-code = g-producer.obj-code
            .
          end.
        end.
        when 'группа':U then do:
          ASSIGN
            g-grp = "":U
          .
          run ref/gds-grp.w ( input parparentproc
                          ,INPUT "b-sel"
                          , input p-obj-type
                          , input p-obj-code
                          , INPUT-OUTPUT g-grp ).
          IF g-grp = "":U THEN DO:
            ASSIGN
              g-list = 'все':U
            .
            RUN enable_UI IN THIS-PROCEDURE.
            RETURN ERROR.
          END.
          FIND FIRST ub.gds-grp NO-LOCK WHERE
              RECID( ub.gds-grp ) = INTEGER( g-grp ) .
          ASSIGN
            g-grp = "":U
          .
          RUN grplib-get-full-name IN THIS-PROCEDURE ( INPUT gds-grp.node-code, OUTPUT g-grp ).
        end.
    END CASE .
    assign
      g-list = input frame d-gob-doc-ref rs-list
      a-n-c :screen-value = "art"
    .
    apply "value-changed":U to a-n-c in frame d-gob-doc-ref .
    RUN enable_UI IN THIS-PROCEDURE.
END PROCEDURE.
FUNCTION Get-good RETURNS CHARACTER
  ( buffer loc-goods for goo-doc, buffer loc-gds-obj for gob-doc ) :
  define variable for-last-pcnt as decimal column-label "Торг.наценка" format "->>>,>>9.99%" no-undo.
  DEFINE VARIABLE vImageList AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE vCh        AS CHARACTER  NO-UNDO.
  mphcol = NO.
    FIND FIRST loc-goods NO-LOCK WHERE
               loc-goods.artic     = loc-gds-obj.artic     AND
               loc-goods.prod-code = loc-gds-obj.prod-code AND
               loc-goods.prod-type = loc-gds-obj.prod-type
                                    USE-INDEX pi NO-ERROR.
    if not available loc-goods then do:
      assign
        e-name         = "?"
        gds-n          = "?"
        gds-t          = "?"
        unit-b         = "?"
        qnty-c         = ?
        VAT-p          = ?
        SLT-p          = ?
        mark-recipe    = "":U
        mark           = "":U
        fact-q         = 0
        free-q         = 0
        price          = 0
        for-cash-parts = no
        for-last-price = 0
        for-last-pcnt  = ?
        free-q-cli    = 0.0
        fact-q-cli    = 0.0
        v-indicator-life-gds = ""
        v-assort-min         = no
      .
      RETURN MARK.
    END.
    assign
      e-name = loc-goods.engl-name
      gds-t  = ( if loc-goods.gds-type = 'т':U then "-" else "+" )
      unit-b = loc-goods.unit-base
      qnty-c = loc-goods.qnty-cart
    .
    IF mImagePh THEN
    DO:
        RUN gds-attr-value (loc-goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
        mphcol = LENGTH (vImageList) > 0.
    END.
    gds-n  = (if loc-goods.stts = 0 then loc-goods.gds-name else  (substring( loc-goods.gds-name, 1, 15 ) + chr(32) + '<':U + CAPS(entry (lookup (string(loc-goods.stts), '0,1,50,51':U), 'тек,удал,блок.для.смены.арт.,смена.арт.':U)) + '>':U )).
    FIND FIRST ub.recipe NO-LOCK WHERE
               ub.recipe.prod-type = loc-goods.prod-type
           AND ub.recipe.prod-code = loc-goods.prod-code
           AND ub.recipe.artic     = loc-goods.artic
           AND
             (
             (
               ub.recipe.obj-type  = loc-gds-obj.obj-type
           AND ub.recipe.obj-code  = loc-gds-obj.obj-code
             )
            OR
             (
               ub.recipe.obj-type  = "":U
           AND ub.recipe.obj-code  = 0
             )
             )
               NO-ERROR.
    assign
      mark-recipe = ( if available ub.recipe then ub.recipe.recipe-type else "":U )
      mark        = ( if lookup( string( recid( loc-goods ) ), rid-list ) > 0 then "*" else "":U )
    .
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  loc-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output vat-p
  ) no-error .
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  loc-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output slt-p
  ) no-error .
    if available loc-gds-obj then do:
      assign
        fact-q         = loc-gds-obj.fact-qnty
        free-q         = loc-gds-obj.free-qnty
        price          = loc-gds-obj.price-sale
        for-cash-parts = loc-gds-obj.cash-parts
        for-last-price = ( if v-lookup-cost then loc-gds-obj.last-base  else ? )
        for-last-pcnt  = ( if v-lookup-cost then ( price /
                         ( if v-curr-r-b = 'base':U then loc-gds-obj.last-base else loc-gds-obj.last-rubl ) *
                                                            100 - 100 ) else ? )
      .
      if abs(for-last-pcnt) > 999999.99 then do:
        assign
          for-last-pcnt-str = "############":U
        .
      end.
      else do:
        assign
          for-last-pcnt-str = string( for-last-pcnt, "->>>,>>9.99%":U )
        .
      end.
      if v-is-ptrl = "yes" then do:
        run get-petrol-weight-qty in this-procedure ( buffer loc-goods,
                                                      buffer loc-gds-obj,
                                                      output free-q-cli,
                                                      output fact-q-cli ) no-error.
        if error-status :error then do: return error return-value. end.
      end.
    end.
    else do:
      assign
        fact-q         = 0
        free-q         = 0
        price          = 0
        for-cash-parts = no
        for-last-price = 0
        for-last-pcnt  = ?
        fact-q-cli    = 0.0
        free-q-cli    = 0.0
        v-indicator-life-gds = ""
        v-assort-min         = no
      .
    end.
       IF mImagePh THEN
      DO:
        RUN gds-attr-value (loc-goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
        mphcol = LENGTH (vImageList) > 0.
      END.
 RETURN mark.
END FUNCTION.
PROCEDURE b-place-proc:
  define variable old-list-mode as character no-undo.
  define variable old-gds-rec   as recid     no-undo.
  define variable rid-list      as character no-undo.
  run ref/pl-gdss.w (
                 input parparentproc
                ,input "":U
                ,input p-obj-type
                ,input p-obj-code
                ,input 'ТОВАР':U
                ,input recid(goo-doc)
                ,input ?
                ,output rid-list
                ).
END PROCEDURE.
PROCEDURE b-dinamo-proc:
  define variable old-list-mode as character no-undo.
  define variable old-gds-rec   as recid     no-undo.
  define variable rid-list      as character no-undo.
  run rep/g-dinamo.p ( input parparentproc
                 , input goo-doc.gds-code ) no-error .
END PROCEDURE.
PROCEDURE b-hist-proc:
  define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  run ref/cgdshist.w (
                   input        parparentproc
                 , input        v-host-code
                 , input        p-obj-type
                 , input        p-obj-code
                 , input        "":U
                 , input        "one":U
                 , input        goo-doc.gds-code
                 , input        ?
                 , input        ?
                 , input        ?
                 , input        ?
                 , input        "":U
                 , input        "":U
                 , input        v-cntxt-db-num
                 , input-output v-rid-list
                 ) no-error .
END PROCEDURE.
PROCEDURE proc-b-add-inf:
  DEFINE INPUT-OUTPUT PARAMETER loc-DOPINF-option AS CHARACTER NO-UNDO.
  define input parameter         loc-mode         as character no-undo .
  define variable destin_         like ub.goods.destin         no-undo .
  define variable attrib_         like ub.goods.attrib         no-undo .
  define variable user-rule_      like ub.goods.user-rule      no-undo .
  define variable sert_           like ub.goods.sert           no-undo .
  define variable struct_         like ub.goods.struct         no-undo .
  define variable deadline_       like ub.goods.deadline       no-undo .
  define variable sort_           like ub.goods.sort           no-undo .
  define variable proof_          like ub.goods.proof          no-undo .
  define variable tnved_          like ub.goods.tnved          no-undo format "x(10)":U .
  define variable unit-cst_       like ub.goods.unit-cst       no-undo .
  define variable cst-base-rate_  like ub.goods.cst-base-rate  no-undo .
  define variable nationality_    like ub.goods.nationality    no-undo .
  define variable normal-wastage_ like ub.goods.normal-wastage no-undo .
  define variable normal-waste_   like ub.goods.normal-waste   no-undo .
  define variable cond-keep-code_ like ub.goods.cond-keep-code no-undo .
  define variable is-alc          as logical                   no-undo .
  define variable is-alc-mark     as logical                   no-undo .
  define variable choose-alc-prod_ as integer                  no-undo .
  define variable prodaddress as character no-undo .
  define variable v-recid     as recid     no-undo .
  define variable v-template  as character no-undo .
  define variable loc#log     as logical no-undo .
  define variable v-update-attr as logical no-undo .
  define variable v-update-dgr as logical no-undo .
  define variable v-is-error as logical no-undo .
  define buffer loc-goods   for ub.goods.
  define buffer buf_clients for ub.clients.
  define buffer buf_firm    for ub.firm.
  define buffer buf_person  for ub.person.
  case LOC-DOPINF-option:
    when "dop-inf":U then do:
        if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info79 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
              if not g#log then do: return error . end.
        end.
      find first loc-goods no-lock where
                 loc-goods.gds-code = goo-doc.gds-code no-error .
      if available loc-goods then do:
        find first buf_clients no-lock where
                   buf_clients.obj-type = loc-goods.prod-type
              AND  buf_clients.obj-code = loc-goods.prod-code no-error .
        if available buf_clients then do:
          case buf_clients.obj-type :
            when 'орг':U then do:
              find first buf_firm no-lock where
                         buf_firm.firm-code = buf_clients.obj-code.
            end.
            when 'чел':U then do:
              find first buf_person no-lock where
                         buf_person.psn-code = buf_clients.obj-code.
            end.
          end case.
        end.
      end.
        define VARIABLE v-attr-value as character no-undo .
        define VARIABLE v-attr-mark-value as character no-undo .
        define VARIABLE v-value as character no-undo .
        RUN gds-attr-value (
          INPUT loc-goods.gds-code,
          INPUT 'alcohol-prod':U,
          OUTPUT v-attr-value,
          OUTPUT v-value
          ).
          if v-attr-value = "YES" then do:
            find first ub.alc-type-gds no-lock
              where ub.alc-type-gds.gds-code = loc-goods.gds-code and
              ub.alc-type-gds.create-user-db-num = 0 no-error.
            if available ub.alc-type-gds then do:
            assign
              choose-alc-prod_ = ub.alc-type-gds.alc-type-inner-code
              is-alc           = yes
              .
            RUN gds-attr-value (
              INPUT loc-goods.gds-code,
              INPUT 'mark':U,
              OUTPUT v-attr-mark-value,
              OUTPUT v-value
              ).
              if v-attr-mark-value = "yes" then is-alc-mark = yes .
            end.
            if not available ub.alc-type-gds then do:
              assign
              is-alc = no
              is-alc-mark = no .
            end.
          end.
      if not available loc-goods or not available buf_clients then do:
        assign
          loc-dopinf-option = "":U
        .
        return error.
      end.
      assign
        destin_         = loc-goods.destin
        attrib_         = loc-goods.attrib
        user-rule_      = loc-goods.user-rule
        sert_           = loc-goods.sert
        struct_         = loc-goods.struct
        deadline_       = loc-goods.deadline
        sort_           = loc-goods.sort
        proof_          = loc-goods.proof
        tnved_          = loc-goods.tnved
        unit-cst_       = loc-goods.unit-cst
        cst-base-rate_  = loc-goods.cst-base-rate
        nationality_    = loc-goods.nationality
        normal-wastage_ = loc-goods.normal-wastage
        normal-waste_   = loc-goods.normal-waste
        cond-keep-code_ = loc-goods.cond-keep-code
        prodaddress     =
                          ( if buf_clients.obj-type = 'орг':U
                            then string( trim( buf_firm.city )    + " ":U +
                                         trim( buf_firm.addres1 ) + " ":U + trim( buf_firm.addres2 ) )
                            else string( trim( buf_person.city )  + " ":U + trim( buf_person.address ) ) )
      .
      run ref/p51121.w (
                     input        parparentproc
                   , input        p-obj-type
                   , input        p-obj-code
                   , input        'ПРОСМОТР':U
                   , input        loc-goods.gds-name
                   , input        buf_clients.obj-name
                   , input        prodaddress
                   , input        loc-goods.unit-base
                   , input-output destin_
                   , input-output attrib_
                   , input-output user-rule_
                   , input-output sert_
                   , input-output struct_
                   , input-output deadline_
                   , input-output sort_
                   , input-output tnved_
                   , input-output unit-cst_
                   , input-output cst-base-rate_
                   , input-output nationality_
                   , input-output normal-wastage_
                   , input-output normal-waste_
                   , input-output cond-keep-code_
                   , input-output proof_
                   , input-output is-alc
                   , INPUT-OUTPUT is-alc-mark
                   , input-output choose-alc-prod_
                   ) .
    end.
    WHEN "foto":U THEN DO:
      run ref/gds-ph.p
        (input parparentproc
        ,buffer goo-doc
                ,input loc-mode
        ).
    END.
    WHEN "dop-inf-gbl":U THEN DO:
      do
      on error undo, return error
      :
      if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo_gbl':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
        end.
        else do:
           loc#log = false .
        end.
        run ref/g-attir.p (
                       input parparentproc
                      ,input (if loc#log
                              then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                      ,input goo-doc.gds-code
                      ,input yes
                      ,output v-update-attr
                      ,output v-is-error
                      ) no-error .
        if error-status:error
        or v-is-error
        then do:
          message
          "Ошибка при вызове списка глобальных атрибутов товара" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box .
          assign
          loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end.
    END.
    WHEN "dop-inf-host":U THEN DO:
      do
      on error undo, return error
      :
      if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info81 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo_firm':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
        end.
        else do:
        loc#log = false .
        end.
        run ref/gh-attir.p (
                       input parparentproc
                      ,input (if loc#log
                              then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                      ,input goo-doc.gds-code
                      ,input v-host-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input yes
                      ,output v-update-attr
                      ,output v-is-error
                      ) no-error .
        if error-status:error
        or v-is-error
        then do:
          message
          "Ошибка при вызове списка атрибутов товара на фирме" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box .
          assign
          loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end.
    END.
    WHEN "dop-inf-fbr-gds-obj":U then do:
        if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info82 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
      end.
      else do:
      loc#log = false .
      end.
      v-template = "":U.
      run ref/fgdsobji.w (
                       input parparentproc
                     , input  (if loc#log then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                     , input  goo-doc.gds-code
                     , input  p-obj-type
                     , input  p-obj-code
                     , input  yes
                     , input-output v-template
                     , output v-update-attr
                     , input-output v-recid
                     ) no-error.
      if error-status :error then do:
        assign
          loc-DOPINF-option = "":U
        .
        return error.
      end.
    END.
    WHEN "dop-inf-s-coeff":U then do:
       if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info83 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
        end.
        else do:
        loc#log = false .
        end.
      run ref/s-coeffr.p (
                      input parparentproc
                    ,input (if loc#log
                            then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                    ,input goo-doc.gds-code
                    ,input v-host-code
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input yes
                    ,output v-update-attr
                    ,output v-is-error
                    ) no-error .
      if error-status:error
      or v-is-error
      then do:
        message
        "Ошибка при вызове справочника сезонных коэффициентов товара" skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box .
        assign
        loc-DOPINF-option = "":U
        .
        undo, return error.
      end.
    END.
    WHEN "dop-inf-obj-one":U
    or
    when "dop-inf-obj-cmp":U
    then do:
      do
      on error undo, return error
      :
      if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info84 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
        end.
        else do:
        loc#log = false .
        end.
        run ref/go-attir.p (
                       input parparentproc
                      ,input (if loc#log
                              and LOC-DOPINF-option = "dop-inf-obj-one":U
                              then 'ИЗМЕНЕНИЕ':U else 'ПРОСМОТР':U)
                      ,input (if LOC-DOPINF-option = "dop-inf-obj-one":U
                              then 'объект':U
                              else 'орг':U)
                      ,input goo-doc.gds-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input yes
                      ,output v-update-attr
                      ,output v-is-error
                      ) no-error .
        if error-status :error
        or v-is-error
        then do:
          message
          "Ошибка при вызове списка атрибутов товара на объекте" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box .
          assign
          loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end.
      END.
    WHEN "dop-inf-dgr-one":U
    or
    WHEN "dop-inf-dgr-cmp":U
    then do:
      do
      on error undo, return error:
        run ref/dgrattir.p (
                       input parparentproc
                      ,input (if loc-mode = 'ИЗМЕНЕНИЕ':U
                              and LOC-DOPINF-option = "dop-inf-dgr-one":U
                              then 'ИЗМЕНЕНИЕ':U
                              else 'ПРОСМОТР':U)
                      ,input (if LOC-DOPINF-option = "dop-inf-dgr-one":U
                                              then 'объект':U
                                              else 'орг':U)
                      ,input goo-doc.gds-code
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input yes
                      ,output v-update-dgr
                      ,output v-is-error
                      ) no-error .
        if error-status :error
        or v-is-error
        then do:
          message
          "Ошибка при вызове списка скидок товара" skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box .
          assign
          loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end.
    END.
    WHEN "indicators":U then do:
    if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info85 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
       end.
       else do:
            loc#log = false .
       end.
        run ref/gds-indr.p (
              input parparentproc
            ,input "indicators":U
            ,input (if loc#log
                    then 'ИЗМЕНЕНИЕ':U
                    else 'ПРОСМОТР':U)
            ,input goo-doc.gds-code
            ,input v-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input yes
            ,output v-update-attr
            ,output v-is-error
          ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      END.
    WHEN "AM":U then do:
        run ref/assmatrg.w
            (input parparentproc
            , "":U
            ,input goo-doc.gds-code
            ,input p-obj-type
            ,input p-obj-code
            ,input ?
            ,input ?
            ,input-output v-spis
          ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      END.
    WHEN "contr":U then do:
        run str/gds-cnts.w
            (input parparentproc
            ,input goo-doc.gds-code
            , "":U
            ,output v-spis
          ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      END.
      WHEN "orders":U then do:
      if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info86 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
        end.
        else do:
           loc#log = false .
        end.
        run ref/gds-indr.p
            (input parparentproc
            ,input "orders":U
            ,input (if loc#log
                    then 'ИЗМЕНЕНИЕ':U
                    else 'ПРОСМОТР':U)
            ,input goo-doc.gds-code
            ,input v-host-code
            ,input p-obj-type
            ,input p-obj-code
            ,input yes
            ,output v-update-attr
            ,output v-is-error
          ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end.
      WHEN "ordersf":U then do:
          if loc-mode = 'ИЗМЕНЕНИЕ':U then do:
define variable vss-include-info87 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update_dopinfo_firm':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  goo-doc.grp-code
    ,input  0
    ,input  true
    ,output loc#log
    )  .
end.
        end.
        else do:
           loc#log = false .
        end.
        run ref/gds-indr.p (input parparentproc
                      , "ordersf":U
                      ,input (if loc#log
                              then 'ИЗМЕНЕНИЕ':U
                              else 'ПРОСМОТР':U)
                      ,input goo-doc.gds-code
                      ,input v-host-code
                      ,input 'орг':U
                      ,input v-host-code
                      ,input yes
                      ,output v-update-attr
                      ,output v-is-error
                    ) no-error.
        if error-status :error
        or v-is-error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      END.
      WHEN "Msf":U then do:
        define variable v-uniq-key-rec as character no-undo .
        define variable v-rid-list as character no-undo .
        run gen-key-rec in this-procedure ( input 'goods':U
                                           ,input (buffer goo-doc:handle)
                                           ,output v-uniq-key-rec).
        run ref/gds-msfs.w ( INPUT parparentproc
                            ,INPUT (if b-add:sensitive in frame d-gob-doc-ref then 'b-add' else '')
                            ,INPUT "uniq-key-rec"
                            ,INPUT 0
                            ,input v-uniq-key-rec
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
        if error-status :error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      END.
      when "alt-unit" then do:
        define variable v-ret-unit-name  as character no-undo .
        define variable v-ret-unit-coeff as decimal no-undo .
        run ref/alt-units.w (input parParentProc,
                             input 'ИЗМЕНЕНИЕ':U,
                             input goo-doc.gds-code,
                             input "",
                             output v-ret-unit-name,
                             output v-ret-unit-coeff) .
        if error-status :error
        then do:
          assign
            loc-DOPINF-option = "":U
          .
          undo, return error.
        end.
      end.
    end case.
  assign
  loc-DOPINF-option = "":U
  .
  if loc#log then do:
     run openbr in this-procedure ( input yes, input yes, input no, input '':U ).
  end.
END.
PROCEDURE b-copy-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
    assign
      gds-rec  = recid( loc-goo-doc )
      copymode = yes
    .
    CASE loc-goo-doc.gds-type:
      when 'т':U then do:
        apply "choose":U to b-add in frame d-gob-doc-ref.
      end.
      when  'у':U then do:
        apply "choose":U to b-add-office in frame d-gob-doc-ref.
      end.
    END CASE.
    assign
      copymode = no
    .
END.
PROCEDURE b-parts-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  define variable v-prt-rec as recid no-undo .
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
define variable vss-include-info88 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
   IF NOT g#log THEN DO: RETURN ERROR. END.
   run str/parts-l.w
     (
        input parparentproc
     ,  input p-obj-type
     ,  input p-obj-code
     ,  input loc-goo-doc.gds-code
     ,  input "":U
     ,  input 'ПРОСМОТР':U
     ,  input 'остатки':U
     ,  input 'текущий':U
     ,  input 'справочник':U
     , output v-prt-rec
     ) .
   apply "entry":U to br-gds in frame d-gob-doc-ref.
END.
PROCEDURE proc-vc-rs-cond:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
    if rs-cond :screen-value in frame d-gob-doc-ref = 'все':U
    and dbtype("ub") = 'PROGRESS'
    then do:
      assign
        g#log = a-n-c :enable( "Нач.слова" )
      .
    end.
    else do:
      assign
        g#log = a-n-c :disable( "Нач.слова" )
      .
    end.
    DISPLAY
      a-n-c
    WITH FRAME d-gob-doc-ref .
    if input frame d-gob-doc-ref rs-cond = 'все':U or g-cond = 'все':U then do:
            assign
              g-cond = input frame d-gob-doc-ref rs-cond
            .
                FIND FIRST loc-goo-doc NO-LOCK WHERE
                           loc-goo-doc.artic     = loc-gob-doc.artic     AND
                           loc-goo-doc.prod-type = loc-gob-doc.prod-type AND
                           loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-ERROR.
                assign
                  g-rep = ( if available loc-goo-doc then recid( loc-goo-doc ) else g-rep )
                .
            a-n-c = "".
            apply "go":U to frame d-gob-doc-ref.
            return error.
        end.
    assign
        g-cond = input frame d-gob-doc-ref rs-cond
        a-n-c :screen-value in frame d-gob-doc-ref = "art"
    .
    apply "value-changed":U to a-n-c in frame d-gob-doc-ref .
    RUN enable_UI IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE proc-b-add:
DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
DEFINE INPUT PARAMETER p-goods AS LOGICAL NO-UNDO .
define variable old-gds-rec as recid.
define variable v-handle as handle no-undo .
assign
  old-gds-rec = gds-rec
  g#log       = FALSE
.
CASE p-goods :
  when yes then do:
define variable vss-include-info89 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_add':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  end.
  when no  then do:
define variable vss-include-info90 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference-services_add':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  end.
END CASE.
if NOT g#log then do:
  BELL.
  return error .
end.
run ref/gds-form.w ( input parparentproc,
                  input ( if copymode then 'КОПИРОВАНИЕ':U  else 'ДОБАВЛЕНИЕ':U    ) + chr(44) +
                        ( if p-goods  then 'т':U else 'у':U )
                , input p-obj-type
                , input p-obj-code
                , input v-handle
                , input-output gds-rec
                ) .
if gds-rec = ? then DO:
  apply "entry":U to br-gds in frame d-gob-doc-ref.
end.
else if gds-rec <> old-gds-rec then do:
  assign
    g-rep     = gds-rec
    v-chg-rec = g-rep
  .
  RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '':U ).
end.
END PROCEDURE.
PROCEDURE b-alt-bc-proc:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  define variable r-bar-code like ub.bar-code.b-code no-undo.
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
  assign
    gds-rec = recid( loc-goo-doc )
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  loc-goo-doc.gds-code
  ,input  ?
  ,output r-bar-code
  ) no-error .
  run ref/alt-bc.w ( input parparentproc, input p-obj-type, input p-obj-code, input r-bar-code ).
END PROCEDURE.
PROCEDURE proc-b-chg:
DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
define variable for-gds-name  like ub.goods.gds-name  no-undo.
define variable for-engl-name like ub.goods.engl-name no-undo.
define variable for-chk-name  like ub.goods.chk-name  no-undo.
define variable v-handle as handle no-undo .
if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
assign
  g#log = FALSE
.
CASE loc-goo-doc.gds-type :
  when 'т':U then do:
define variable vss-include-info91 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  loc-goo-doc.grp-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  end.
  when 'у':U then do:
define variable vss-include-info92 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference-services_update':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  loc-goo-doc.grp-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  end.
END CASE.
if NOT g#log or loc-goo-doc.stts <> 0 then do:
  BELL.
  return no-apply.
end.
assign
  gds-rec       = recid (loc-goo-doc)
  for-engl-name = loc-goo-doc.engl-name
  for-gds-name  = loc-goo-doc.gds-name
  for-chk-name  = loc-goo-doc.chk-name
.
run ref/gds-form.w (
                  input parparentproc
                , input 'ИЗМЕНЕНИЕ':U
                , input p-obj-type
                , input p-obj-code
                , input v-handle
                , input-output gds-rec
                ) .
if gds-rec = ? then do:
  apply "entry":U to br-gds in frame d-gob-doc-ref.
end.
else do:
  FIND FIRST loc-goo-doc NO-LOCK WHERE RECID( loc-goo-doc ) = gds-rec NO-ERROR.
  if available loc-goo-doc then do:
    FIND FIRST loc-gob-doc NO-LOCK WHERE
                loc-goo-doc.artic     = loc-gob-doc.artic
            AND loc-goo-doc.prod-type = loc-gob-doc.prod-type
            AND loc-goo-doc.prod-code = loc-gob-doc.prod-code
            AND loc-gob-doc.obj-type  = p-obj-type
            AND loc-gob-doc.obj-code  = p-obj-code NO-ERROR.
    if available loc-gob-doc then do:
      assign
        g-rep     = recid( loc-gob-doc )
        v-chg-rec = g-rep
      .
    end.
    else do:
      assign
        v-chg-rec = ?
      .
    end.
  end.
  RUN openbr    IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '':U ).
  run gds-ref-fi IN THIS-PROCEDURE (   BUFFER       loc-goo-doc
                                      ,BUFFER       loc-gob-doc
                                      ,INPUT        p-obj-type
                                      ,INPUT        p-obj-code
                                      ,INPUT        gdsreffi
                                      ,input        no
                                      ,INPUT-OUTPUT fi-1
                                      ,INPUT-OUTPUT fi-2
                                      ,INPUT-OUTPUT fi-3
                                      ,INPUT-OUTPUT fi-4
                                      ,INPUT-OUTPUT fi-5
                                      ,INPUT-OUTPUT fi-6
                                      ,INPUT-OUTPUT fi-7
                                      ,INPUT-OUTPUT fi-8
                                    ) NO-ERROR.
  DISPLAY
    fi-1
    fi-2
    fi-3
    fi-4
    fi-5
    fi-6
    fi-7
    fi-8
    loc-goo-doc.gds-code @ goo-doc.gds-code
  WITH FRAME d-gob-doc-ref.
end.
END PROCEDURE.
PROCEDURE proc-b-grp:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  define variable was-deleted as integer initial 0 no-undo.
  define variable loc_g-grp as character no-undo .
  define variable lns-cnt as integer no-undo .
  define variable v-ok as logical no-undo .
  define variable v-old-code as integer no-undo .
  define buffer buf_gds-grp for ub.gds-grp.
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
  assign
    g#log = FALSE
  .
define variable vss-include-info93 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_upd-group':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  loc-goo-doc.grp-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if NOT g#log then do:
    return no-apply .
  end.
  assign
    g#log = yes
  .
  v-old-code = loc-goo-doc.grp-code .
  message
    "Выберите группу, в которую нужно переместить товар(ы)."
  view-as alert-box question buttons OK-Cancel update g#log.
  if not g#log then do:
    apply "entry":U to br-gds in frame d-gob-doc-ref.
    return no-apply.
  end.
  run ref/gds-grp.w (
                    input parparentproc
                  , input 'терм':U + ',b-sel'
                  , input p-obj-type
                  , input p-obj-code
                  , input-output loc_g-grp ).
  if loc_g-grp = "":U then do:
    apply "entry":U to br-gds in frame d-gob-doc-ref.
    return no-apply.
  end.
  FIND FIRST buf_gds-grp WHERE RECID( buf_gds-grp ) = INTEGER( loc_g-grp ) .
  if rid-list = "":U then do:
    assign
      rid-list = string( recid( loc-goo-doc ) )
    .
  end.
define variable vss-include-info94 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_upd-group':U
    ,input  'object':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  buf_gds-grp.node-code
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if NOT g#log then do:
    return no-apply .
  end.
  assign
    g#log = yes
  .
  assign
    lns-cnt = 1
  .
if session :set-wait-state( "compiler" ) then.
  DO TRANSACTION WHILE lns-cnt <= NUM-ENTRIES( rid-list ) :
    assign
      gds-rec = integer( entry( lns-cnt, rid-list ) )
    .
    FIND FIRST loc-goo-doc WHERE RECID( loc-goo-doc ) = gds-rec.
    IF loc-goo-doc.stts <> 0 then do:
      assign
        was-deleted = was-deleted + 1
        lns-cnt     = lns-cnt     + 1
      .
      next.
    end.
    FIND FIRST loc-goo-doc WHERE RECID( loc-goo-doc ) = gds-rec .
    assign
      lns-cnt   = lns-cnt + 1
      v-chg-rec = gds-rec
    .
    run recalc-assgds in this-procedure  ( input loc-goo-doc.gds-code,
                                           input loc-goo-doc.grp-code,
                                           input buf_gds-grp.node-code,
                                           output v-ok    ) .
    if v-ok then loc-goo-doc.grp-code = buf_gds-grp.node-code.
         if check-ban-sales-via-cd-grp(loc-goo-doc.grp-code) then do:
           run str/diallog.w (parparentproc, this-procedure, 'str/del-grp.p':U, string(v-cntxt-obj-code) + chr(4) + string(loc-goo-doc.grp-code), no,
                             'Прервать', 'Удаление товаров с касс') .
        end.
     define variable v-value-emrc as character no-undo .
     define variable v-type-emrc  as character no-undo .
     old-value-emrc = "" .
     for first ub.gds-grp-obj-attr no-lock
        where ub.gds-grp-obj-attr.node-code   = v-old-code
        and ub.gds-grp-obj-attr.host-code   = 0
        and ub.gds-grp-obj-attr.obj-type    = ""
        and ub.gds-grp-obj-attr.obj-code    = 0
        and ub.gds-grp-obj-attr.attr-code   = 'emrc-type':U:
        old-value-emrc = ub.gds-grp-obj-attr.attr-value .
     end.
     for first ub.gds-grp exclusive-lock where ub.gds-grp.node-code = loc-goo-doc.grp-code:
        for first ub.gds-grp-obj-attr no-lock
           where ub.gds-grp-obj-attr.node-code   = loc-goo-doc.grp-code
           and ub.gds-grp-obj-attr.host-code   = 0
           and ub.gds-grp-obj-attr.obj-type    = ""
           and ub.gds-grp-obj-attr.obj-code    = 0
           and ub.gds-grp-obj-attr.attr-code   = 'emrc-type':U:
           v-value-emrc = ub.gds-grp-obj-attr.attr-value .
        end.
        define variable v-attr-emrc as character no-undo .
        define variable v-attr-type as character no-undo .
        define variable v-del       as logical   no-undo .
        define buffer buf_goods-attr for ub.goods-attr .
        define variable v-emrc-name as character no-undo .
        for first buf_goods-attr no-lock where buf_goods-attr.attr-code = 'emrc-type':U and
           buf_goods-attr.gds-code = loc-goo-doc.gds-code:
           v-attr-emrc = buf_goods-attr.attr-value .
        end.
        if v-value-emrc <> old-value-emrc and v-attr-emrc = "" then
        do:
           find first ub.code no-lock where ub.Code.parent = "EMC" and ub.Code.code = v-value-emrc no-error .
           if not available (ub.Code) then v-emrc-name = "Нет" .
           else v-emrc-name = ub.Code.CodeName .
           message "При переносе в группу " + string(ub.gds-grp.node-name) + " для товара " + string(loc-goo-doc.gds-name) skip
              "будет наследоваться значение новой группы тип ЕМЦ - " + v-emrc-name + ". " skip
              "При утвердительном ответе товар переносится в новую группу, значение тип ЕМЦ - " + v-emrc-name
              view-as alert-box question buttons yes-no-cancel update choice as logical .
           CASE choice:
              WHEN TRUE THEN
                 DO:
                 END.
              WHEN FALSE THEN
                 DO:
                    run gds-attr-write IN THIS-PROCEDURE(
                       input loc-goo-doc.gds-code
                       ,INPUT 'emrc-type':U
                       ,INPUT old-value-emrc ) .
                 END.
              OTHERWISE
              DO:
                 loc-goo-doc.grp-code = v-old-code .
              end.
           END CASE.
        end.
        if v-value-emrc <> v-attr-emrc and v-attr-emrc <> "" then do:
           define variable ichoice as integer no-undo .
           find first ub.code no-lock where ub.Code.parent = "EMC" and ub.Code.code = v-attr-emrc no-error .
           if not available (ub.Code) then v-emrc-name = "Нет" .
           else v-emrc-name = ub.Code.CodeName .
                  run gbl/d-askw.w (
                     input "Сообщение"
                     ,input  "На товар установлен атрибут «тип ЕМЦ» - " + v-emrc-name + ". При переносе товара значение может быть изменено."
                     ,input "|"
                     ,input "Наследовать|Оставить|Отмена"
                     ,input "Наследовать атрибут от новой группы|Оставить текущее значение атрибута|Отмена"
                     ,input 1
                     ,input 3
                     ,output ichoice).
           CASE iChoice:
              WHEN 1 THEN
                 DO:
              if v-value-emrc = "" then do:
              run gds-attr-delete IN THIS-PROCEDURE(
                 input loc-goo-doc.gds-code
                 ,INPUT 'emrc-type':U
                 ,output v-del ) .
              end.
              else do:
              run gds-attr-write IN THIS-PROCEDURE(
                 input loc-goo-doc.gds-code
                 ,INPUT 'emrc-type':U
                 ,INPUT v-value-emrc ) NO-ERROR.
              end.
                 END.
              WHEN 2 THEN
                 DO:
              run gds-attr-write IN THIS-PROCEDURE(
                 input loc-goo-doc.gds-code
                 ,INPUT 'emrc-type':U
                 ,INPUT v-attr-emrc ) .
                 END.
              OTHERWISE DO:
              loc-goo-doc.grp-code = v-old-code .
              end.
           END CASE.
        end.
     end.
  END .
if session :set-wait-state( "compiler" ) then.
  assign
    rid-list = "":U
    mark-num = 0
  .
  if was-deleted > 0 then do:
    message ("Из " + string(lns-cnt - 1) + " товаров удалось перенести в другую группу " +
            string (lns-cnt  - 1 - was-deleted) + chr(44)) skip
            "остальные товары являются неактивными -" skip
            "для них перенос ЗАПРЕЩЕН!"
    view-as alert-box WARNING.
  end.
  hide mark-num in frame d-gob-doc-ref.
  RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '':U ).
END PROCEDURE.
PROCEDURE proc-rs-stat:
ASSIGN
FRAME d-gob-doc-ref
rs-stat
g-stat = rs-stat
a-n-c :SCREEN-VALUE = "art"
.
APPLY "VALUE-CHANGED":U TO a-n-c IN FRAME d-gob-doc-ref.
RUN openbr IN THIS-PROCEDURE ( INPUT YES, input yes, input no, input '':U ).
END PROCEDURE.
PROCEDURE proc-rs-sort:
assign
a-n-c :screen-value in frame d-gob-doc-ref = "art"
.
apply "value-changed":U to a-n-c in frame d-gob-doc-ref .
if rs-sort :screen-value <> 'Артикул':U then do:
  message "При большой товарной номенклатуре" skip
          "по текущему объекту" skip
          "процесс сортировки товаров" skip
          "по выбранному Вами условию" skip
          "может занять длительное время." skip(1)
          "Продолжать ?" skip
          " "
  view-as alert-box INFORMATION buttons YES-NO update g#log .
  if g#log = yes then do:
    assign
      frame d-gob-doc-ref rs-sort
    .
    RUN openbr IN THIS-PROCEDURE ( INPUT NO, input yes, input no, input '':U ).
  end.
  else do:
    assign
      rs-sort :screen-value in frame d-gob-doc-ref = 'Артикул':U
    .
  end.
end.
else do:
  assign
    frame d-gob-doc-ref rs-sort
  .
  RUN openbr IN THIS-PROCEDURE ( INPUT NO, input yes, input no, input '':U ).
end.
END PROCEDURE.
PROCEDURE proc-br-gds:
  if b-sel :sensitive in frame d-gob-doc-ref then do:
      apply "choose":U to b-sel in frame d-gob-doc-ref.
  end.
  else do:
    if b-lkp :sensitive then do:
      apply "choose":U to b-lkp in frame d-gob-doc-ref.
    end.
  end.
END PROCEDURE.
PROCEDURE proc-b-exit:
  assign
    a-n-c    = "вых":U
    rid-list = ""
  .
END PROCEDURE.
PROCEDURE proc-b-sel:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  if rid-list = "" then do:
    if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
    rid-list = string (recid (loc-goo-doc)).
  end.
  assign
    a-n-c = "вых":U
  .
END PROCEDURE.
PROCEDURE proc-b-price:
define input  parameter p-var as integer   no-undo .
define parameter buffer loc-goo-doc for ub.goods.
define parameter buffer loc-gob-doc for ub.gds-obj.
define variable v-fact-order     as decimal no-undo .
define variable v-plt-id         as integer no-undo .
define variable v-plt-db-num     as integer no-undo .
define variable v-pdf-id         as integer no-undo .
define variable v-pdf-db-num     as integer no-undo .
define variable v-sale-price-doc as decimal no-undo .
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
  if p-var = 2 then do:
  run str/chg-sale.w
   ( input parparentproc,
     input p-obj-type ,
     input p-obj-code ,
     BUFFER loc-goo-doc ).
  end.
  else do:
  run str/chmplgds.w
  ( input  parparentproc ,
    input  loc-goo-doc.gds-code ,
    input  p-obj-type    ,
    input  p-obj-code    ,
    input  v-fact-order  ,
    output v-plt-id      ,
    output v-plt-db-num  ,
    output v-pdf-id      ,
    output v-pdf-db-num  ,
    output v-sale-price-doc ).
  end.
  APPLY "ENTRY":U TO br-gds IN FRAME d-gob-doc-ref.
END PROCEDURE.
PROCEDURE proc-b-lkp:
DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
define variable v-handle as handle no-undo .
if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
ASSIGN
gds-rec = RECID( loc-goo-doc )
v-handle = this-procedure :handle.
.
run ref/gds-form.w (
                  INPUT parparentproc
                , INPUT 'ПРОСМОТР':U
                , INPUT p-obj-type
                , INPUT p-obj-code
                , input v-handle
                , input-output gds-rec
                ) .
APPLY "ENTRY":U TO br-gds IN FRAME d-gob-doc-ref.
END PROCEDURE.
PROCEDURE proc-b-prt:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
  define variable v-sel-node-code as integer   no-undo .
  run str/prt-ref.w
    (
       input parparentproc
    ,  input loc-goo-doc.gds-code
    ,  input 'ПРОСМОТР':U
    ,  input p-obj-type
    ,  input p-obj-code
    ,  input "":U
    ,  input ( if a-n-c = "code" then loc-code else "":U )
    , output v-sel-node-code
    ) .
  apply "entry":U to br-gds in frame d-gob-doc-ref.
END PROCEDURE.
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure local-gds_inf :
  for each tt-goods
  :
    delete tt-goods.
  end.
  for each tt-clients
  :
    delete tt-clients.
  end.
  create tt-goods.
  buffer-copy goo-doc to tt-goods.
  create tt-clients.
  assign
    tt-clients.obj-type = p-obj-type
    tt-clients.obj-code = p-obj-code
  .
  if not available gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST goo-doc WHERE goo-doc.artic     = gob-doc.artic                      AND goo-doc.prod-type = gob-doc.prod-type                      AND goo-doc.prod-code = gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( goo-doc ) .
  define variable v-ok as logical   no-undo .
  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-clients.obj-type
  ,input  tt-clients.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info97 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_archive':U
    ,input  'firm':U
    ,input  v-chk-act-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok then do:
    run arc/gds_inf.w (parparentproc, tt-clients.obj-type, tt-clients.obj-code).
  end.
end procedure.
PROCEDURE proc-b-SErt:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
   run ref/gds-sert.w (   input parparentproc
                    , input p-obj-type
                    , input p-obj-code
                    , input ( if NOT b-add :sensitive in frame d-gob-doc-ref then 'ПРОСМОТР':U else 'ИЗМЕНЕНИЕ':U )
                    , input "gds"
                    , input loc-goo-doc.gds-code
                    , input ?
                    , input ?
                    , input ?
                    ) no-error.
END PROCEDURE.
procedure proc-b-extart:
  DEFINE PARAMETER BUFFER loc-goo-doc FOR ub.goods.
  DEFINE PARAMETER BUFFER loc-gob-doc FOR ub.gds-obj.
  if not available loc-gob-doc then do:   message     "Неправильно выбран товар."   view-as alert-box error.   return no-apply. end. FIND FIRST loc-goo-doc WHERE loc-goo-doc.artic     = loc-gob-doc.artic                          AND loc-goo-doc.prod-type = loc-gob-doc.prod-type                          AND loc-goo-doc.prod-code = loc-gob-doc.prod-code NO-LOCK. assign   gds-rec = recid( loc-goo-doc ) .
    run ref/eartform.w ( input parParentProc
                       , input 'ИЗМЕНЕНИЕ':U
                       , input loc-goo-doc.gds-code
                       ) no-error .
 if error-status :error then do:
  message error-status :get-message(1) view-as alert-box information .
 end.
end procedure.
Procedure main-block-proc:
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
FIND FIRST ub.db NO-LOCK WHERE ub.db.db-num = v-cntxt-db-num .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
assign
  is-prt = ( if error-status :error or dops <> "yes" then no else yes )
.
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'doc-prt=request':U
  ,output v-doc-prt
  ) no-error .
assign
  v-doc-prt = ( is-prt and v-doc-prt )
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fbr'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
assign
  is-fbr = ( dops = "yes" )
.
define variable vss-include-info101 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-lookup-cost
    )  .
end.
def var v-str-temp as character no-undo.
run uf-get in this-procedure (
    input 'gdsreffi':U
  ,input  v-cntxt-userid
  ,output v-uf-List_
  ,output v-uf-Naim
  ,output v-uf-print-graft
  ,output v-uf-sort-gr
  ,output v-uf-type-price
  ,output v-uf-type-val
  )  no-error.
if not error-status :error then do:
  assign
  gdsreffi = entry(1, v-uf-list_,  chr(4) ) no-error.
  v-str-temp = entry(2, v-uf-list_,  chr(4) ) no-error.
  if v-str-temp = "ptrl"
  or v-str-temp = "lgas"
  or v-str-temp = "ptrlsug"
  then do:
    entry(2, v-uf-list_,  chr(4) ) = 'текущие':U.
  end.
end.
RUN gds-ref-to IN THIS-PROCEDURE (
                                     INPUT        gdsreffi
                                    ,INPUT-OUTPUT myto[1]
                                    ,INPUT-OUTPUT myto[2]
                                    ,INPUT-OUTPUT myto[3]
                                    ,INPUT-OUTPUT myto[4]
                                    ,INPUT-OUTPUT myto[5]
                                    ,INPUT-OUTPUT myto[6]
                                    ,INPUT-OUTPUT myto[7]
                                    ,INPUT-OUTPUT myto[8]
                                  ) NO-ERROR.
assign
fi-1 :tooltip in frame d-gob-doc-ref = myto[1]
fi-2 :tooltip      = myto[2]
fi-3 :tooltip      = myto[3]
fi-4 :tooltip      = myto[4]
fi-5 :tooltip      = myto[5]
fi-6 :tooltip      = myto[6]
fi-7 :tooltip      = myto[7]
fi-8 :tooltip      = myto[8]
.
find first g-producer no-lock where
            g-producer.obj-type = p-producer-type
      AND  g-producer.obj-code = p-producer-code no-error.
if ( g-list = 'Производитель':U ) AND ( NOT available g-producer ) then do:
  assign
    g-list = 'все':U
  .
end.
if num-entries (rid-list) = 0 then do:
  hide mark-num in frame d-gob-doc-ref.
end.
else do:
  display
    num-entries( rid-list ) @ mark-num
  with frame d-gob-doc-ref.
end.
br-gds :SET-REPOSITIONED-ROW( 5, "CONDITIONAL":U ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-ptrl
  ,output v-data-type
  ) no-error .
if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do:
  assign
    v-is-ptrl = "no"
  .
end.
if v-is-ptrl <> "yes" then do:
  assign
    free-q-cli :visible in browse br-gds = no
    fact-q-cli :visible in browse br-gds = no
  .
end.
assign
gds-n:resizable in browse br-gds = true
price:label in browse br-gds = substitute("Цена (&1)", (if v-curr-r-b = 'rubl':U then "нац.вал." else "баз.вал."))
gds-n:width in browse br-gds = p-gds-name-width
gob-doc.grp-name:resizable in browse br-gds = true
gob-doc.grp-name:width in browse br-gds = p-grp-name-width
v-indicator-life-gds:resizable in browse br-gds = true .
v-indicator-life-gds:width in browse br-gds = 8 .
.
RUN enable_UI IN THIS-PROCEDURE.
RUN buttons   IN THIS-PROCEDURE.
g#log = ( if rs-cond :screen-value in frame d-gob-doc-ref = 'все':U
          and dbtype("ub") = 'PROGRESS'
          then a-n-c :enable(  "Нач.слова" )
          else a-n-c :disable( "Нач.слова" ) ).
if a-n-c <> "вых" then do:
DISPLAY
  a-n-c
WITH FRAME d-gob-doc-ref .
end.
END PROCEDURE.
PROCEDURE init-flt:
  assign
    tbl = 'gds-obj'
    join-tbl = 'gob-doc'
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
  .
  run fltfield-add in this-procedure('artic', '', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('prod-type*prod-code', 'Производитель', 'cli'
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('grp-name', '', 'gdsgrp'
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('free-qnty', 'Свободно (кол-во)', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-qnty', 'Факт (кол-во)', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-cli-qnty', 'Факт в ед.пост-ка', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-sale', 'Продажная цена', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cash-parts', 'Продажа по партиям', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('place-rsrv', 'Резерв по скл.местам', ''
  , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
define variable vss-include-info102 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_lookup':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
    if g#log = yes then do:
      run fltfield-add in this-procedure('in-code', 'Номер приходной накладной', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      run fltfield-add in this-procedure('in-date', 'Дата приходной накладной', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.
define variable vss-include-info103 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
    if g#log = yes then do:
      run fltfield-add in this-procedure('avrg-base', '', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      run fltfield-add in this-procedure('last-base', '', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      run fltfield-add in this-procedure('avrg-rubl', '', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
      run fltfield-add in this-procedure('last-rubl', '', ''
      , input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.
END PROCEDURE.
procedure proc-b-obj :
  define input parameter p-mode as character no-undo .
  define variable v-host-code   as integer   no-undo .
  define variable v-user-select as logical   no-undo .
  define variable v-obj-type    as character no-undo .
  define variable v-obj-code    as integer   no-undo .
  define buffer buf_clients  for ub.clients.
  do
  on error undo, return error
  :
    if p-mode = "change":U
    then do:
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-one in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  ,output v-obj-type
  ,output v-obj-code
  )  .
      if v-user-select <> true
      then do:
        return .
      end.
    end.
    else do:
      assign
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
      .
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if not available buf_clients
    then do:
      undo, return error.
    end.
    assign
      p-obj-type = buf_clients.obj-type
      p-obj-code = buf_clients.obj-code
      v-obj-type = buf_clients.obj-type
      v-obj-code = buf_clients.obj-code
      v-obj-name = buf_clients.obj-name
    .
    run main-block-proc in this-procedure .
  end.
end procedure.
procedure get-petrol-weight-qty :
  define        parameter buffer loc-goo-doc   for ub.goods.
  define        parameter buffer loc-gob-doc   for ub.gds-obj.
  define output parameter        p-free-q-cli as  decimal no-undo initial 0.0.
  define output parameter        p-fact-q-cli as  decimal no-undo initial 0.0.
  define variable is-petrol as logical no-undo.
  define variable is-pieces as logical no-undo.
  define buffer buf_pl-gds for ub.pl-gds .
  do on error undo, return error return-value :
    if available loc-goo-doc then do:
      assign
        p-free-q-cli = 0.0
        p-fact-q-cli = 0.0
      .
      if v-is-ptrl = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input loc-goo-doc.artic
  ,  input loc-goo-doc.prod-type
  ,  input loc-goo-doc.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
        if error-status :error then do:
          return error return-value.
        end.
        if is-petrol = true
          and is-pieces = false
        then do:
          for each buf_pl-gds no-lock
            where buf_pl-gds.gds-code = loc-goo-doc.gds-code
              and buf_pl-gds.obj-type = p-obj-type
              and buf_pl-gds.obj-code = p-obj-code
          on error undo, return error return-value
          :
            assign
              p-fact-q-cli = p-fact-q-cli + buf_pl-gds.cli-fact-qnty
              p-free-q-cli = p-free-q-cli + buf_pl-gds.cli-free-qnty
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure assort-polit :
do
on error undo, return error return-value
:
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-indicator-life-gds like  ub.gds-obj-prop.gdop-igt                     no-undo .
define output parameter p-assort-min         like  ub.gds-obj-prop.gdop-assort-min format "*/ " no-undo .
 define variable p-gdop-min-stock              as decimal   no-undo .
 define variable p-grop-max-stock              as decimal   no-undo .
 define variable p-grop-level-always-presence  as decimal   no-undo .
 define variable p-grop-min-order              as decimal   no-undo .
if p-gds-code = 0 or p-gds-code = ? then message 444.
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  p-gds-code
  ,output p-assort-min
  ,output p-indicator-life-gds
  ,output p-gdop-min-stock
  ,output p-grop-max-stock
  ,output p-grop-level-always-presence
  ,output p-grop-min-order
  )  .
end.
end procedure.
PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
  case p-direction :
    when "first":U
    then do:
      get first br-gds.
    end.
    when "last":U
    then do:
      get last br-gds.
    end.
    when "prev":U
    then do:
      get prev br-gds.
      if not available gob-doc then do:
        message
        "Это первый товар списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-gds.
      if not available gob-doc then do:
        message
        "Это последний товар списка"
        view-as alert-box.
      end.
    end.
  end case .
  run reposition-query in this-procedure
    (input recid(gob-doc)
    ).
  assign
  p-recid = recid(goo-doc)
  .
END PROCEDURE.
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .
if p-recid <> ?
then do:
  reposition br-gds to recid p-recid no-error.
end.
do with frame d-gob-doc-ref:
  apply "entry":u to browse br-gds .
  apply "VALUE-CHANGED":u to browse br-gds .
end.
END PROCEDURE.
procedure recalc-assgds :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-old-grp as integer   no-undo .
define input  parameter p-new-grp as integer   no-undo .
define output parameter p-ok      as logical    no-undo .
define buffer buf_assortment-matrix       for ub.assortment-matrix  .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
  do
  on error undo, return error return-value
  :
  find first buf_assortment-matrix-goods no-lock where
               buf_assortment-matrix-goods.gds-code =  p-gds-code and
               buf_assortment-matrix-goods.obj-type <> "" and
               buf_assortment-matrix-goods.asmg-status =  0 no-error.
  if not AVAILABLE buf_assortment-matrix-goods then do: p-ok = yes .
  end.
  else do:
  for each buf_assortment-matrix-goods no-lock where
           buf_assortment-matrix-goods.gds-code =  p-gds-code and
           buf_assortment-matrix-goods.obj-type <> "" and
           buf_assortment-matrix-goods.asmg-status =  0 ,
      first buf_assortment-matrix no-lock where
            buf_assortment-matrix.asmt-status =  0 and
            buf_assortment-matrix.obj-type <> "" and
            buf_assortment-matrix.asmt-id = buf_assortment-matrix-goods.asmt-id  and
            buf_assortment-matrix.db-num  = buf_assortment-matrix-goods.db-num
           :
       run utl/uassmgrp.p ( p-old-grp, p-new-grp, buf_assortment-matrix.asmt-id , buf_assortment-matrix.db-num, output p-ok ) no-error.
  end.
  end.
  end.
end procedure.
