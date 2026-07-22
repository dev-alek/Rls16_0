define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-pl-rowid as rowid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отключение повторных сообщений АТД" .
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
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
define variable v-attr-shift-date   as date     no-undo .
define variable v-attr-shift-num    as integer  no-undo .
define buffer buf_clients for ub.clients .
define buffer buf_place for ub.place .
define buffer buf_place-attr for ub.place-attr .
define buffer buf_shift-obj for ub.shift-obj .
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE t-level AS LOGICAL INITIAL no
     LABEL "Отключить сообщения о переполнении"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY .81 NO-UNDO.
DEFINE VARIABLE t-water AS LOGICAL INITIAL no
     LABEL "Отключить сообщения по воде"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY .81 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.38 COL 2
     b-cancel AT ROW 1.38 COL 16.8
     t-water AT ROW 3.14 COL 2.2 WIDGET-ID 2
     t-level AT ROW 4.38 COL 2.2 WIDGET-ID 4
     SPACE(3.79) SKIP(0.75)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отключение повторных сообщений"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-ok IN FRAME Dialog-Frame
DO:
  define variable t-water-chr as character no-undo .
  define variable t-level-chr as character no-undo .
  assign
    t-water
    t-level
  .
  if t-water
  then t-water-chr = "disable" .
  else t-water-chr = "enable" .
  if t-level
  then t-level-chr = "disable" .
  else t-level-chr = "enable" .
  find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = "disable-water-alarm"
                                             and buf_place-attr.obj-code    = buf_place.obj-code
                                             and buf_place-attr.obj-type    = buf_place.obj-type
                                             and buf_place-attr.pl-code     = buf_place.pl-code
                                             no-error .
  if not available buf_place-attr
  then do :
    create buf_place-attr .
    assign
      buf_place-attr.attr-code   = "disable-water-alarm"
      buf_place-attr.obj-code    = buf_place.obj-code
      buf_place-attr.obj-type    = buf_place.obj-type
      buf_place-attr.pl-code     = buf_place.pl-code
    .
  end .
  assign
    buf_place-attr.attr-value = t-water-chr + chr(4) + string(buf_shift-obj.shift-date) + chr(4) + string(buf_shift-obj.shift-num)
  .
  if v-cntxt-db-num = 0
  then do :
    run nws/cr-route.p ( input 'send-cmd':U
                        ,input "command":U + chr(1) +
                               "place-attr":U + chr(1) +
                               buf_place-attr.obj-type + chr(1) +
                               string(buf_place-attr.obj-code) + chr(1) +
                               string(buf_place-attr.pl-code) + chr(1) +
                               buf_place-attr.attr-code + chr(1) +
                               buf_place-attr.attr-value
                        ,input ?
                        ,input string(buf_clients.db-num)
                       ).
  end .
  find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = "disable-level-alarm"
                                             and buf_place-attr.obj-code    = buf_place.obj-code
                                             and buf_place-attr.obj-type    = buf_place.obj-type
                                             and buf_place-attr.pl-code     = buf_place.pl-code
                                             no-error .
  if not available buf_place-attr
  then do :
    create buf_place-attr .
    assign
      buf_place-attr.attr-code   = "disable-level-alarm"
      buf_place-attr.obj-code    = buf_place.obj-code
      buf_place-attr.obj-type    = buf_place.obj-type
      buf_place-attr.pl-code     = buf_place.pl-code
    .
  end .
  assign
    buf_place-attr.attr-value = t-level-chr + chr(4) + string(buf_shift-obj.shift-date) + chr(4) + string(buf_shift-obj.shift-num)
  .
  if v-cntxt-db-num = 0
  then do :
    run nws/cr-route.p ( input 'send-cmd':U
                        ,input "command":U + chr(1) +
                               "place-attr":U + chr(1) +
                               buf_place-attr.obj-type + chr(1) +
                               string(buf_place-attr.obj-code) + chr(1) +
                               string(buf_place-attr.pl-code) + chr(1) +
                               buf_place-attr.attr-code + chr(1) +
                               buf_place-attr.attr-value
                        ,input ?
                        ,input string(buf_clients.db-num)
                       ).
  end .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
  find first buf_clients no-lock where buf_clients.obj-type = p-obj-type
                                   and buf_clients.obj-code = p-obj-code
                                   .
  find first buf_shift-obj where buf_shift-obj.obj-type = p-obj-type
                             and buf_shift-obj.obj-code = p-obj-code
                             and buf_shift-obj.status_ = 'тек':U
                             use-index stts no-lock no-error .
  if not available buf_shift-obj
  then do :
    message "Нет открытой смены на объекте!" view-as alert-box warning .
    return .
  end .
  find first buf_place no-lock where rowid(buf_place) = p-pl-rowid .
  for first buf_place-attr no-lock where buf_place-attr.attr-code   = "disable-level-alarm"
                                     and buf_place-attr.obj-code    = buf_place.obj-code
                                     and buf_place-attr.obj-type    = buf_place.obj-type
                                     and buf_place-attr.pl-code     = buf_place.pl-code
                                     :
    if num-entries(buf_place-attr.attr-value, chr(4)) = 3
    then do :
      v-attr-shift-date = date(entry(2, buf_place-attr.attr-value, chr(4))) .
      v-attr-shift-num = integer(entry(3, buf_place-attr.attr-value, chr(4))) .
      if v-attr-shift-date = buf_shift-obj.shift-date
      and v-attr-shift-num = buf_shift-obj.shift-num
      and entry(1, buf_place-attr.attr-value, chr(4)) = "disable"
      then do :
        t-level = yes .
      end .
    end .
  end .
  for first buf_place-attr no-lock where buf_place-attr.attr-code   = "disable-water-alarm"
                                     and buf_place-attr.obj-code    = buf_place.obj-code
                                     and buf_place-attr.obj-type    = buf_place.obj-type
                                     and buf_place-attr.pl-code     = buf_place.pl-code
                                     :
    if num-entries(buf_place-attr.attr-value, chr(4)) = 3
    then do :
      v-attr-shift-date = date(entry(2, buf_place-attr.attr-value, chr(4))) .
      v-attr-shift-num = integer(entry(3, buf_place-attr.attr-value, chr(4))) .
      if v-attr-shift-date = buf_shift-obj.shift-date
      and v-attr-shift-num = buf_shift-obj.shift-num
      and entry(1, buf_place-attr.attr-value, chr(4)) = "disable"
      then do :
        t-water = yes .
      end .
    end .
  end .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY t-water t-level
      WITH FRAME Dialog-Frame.
  ENABLE b-ok b-cancel t-water t-level
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
