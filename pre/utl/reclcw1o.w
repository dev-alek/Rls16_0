define input parameter parparentproc as handle no-undo.
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита пересчета остатков МЦ для одного выбранного объекта".
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
def buffer buf_clients for ub.clients.
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE v-obj-type AS CHARACTER FORMAT "X(3)"
     LABEL "Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6.38 BY 1.
DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-obj-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 10 BY 1.
DEFINE FRAME Dialog-Frame
     B-Help AT ROW 1.25 COL 61.5
     v-obj-type AT ROW 2.5 COL 13.5 COLON-ALIGNED WIDGET-ID 8
     v-obj-code AT ROW 2.5 COL 20.5 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     B-cli AT ROW 2.5 COL 33 WIDGET-ID 4
     Btn_OK AT ROW 4.25 COL 18
     Btn_Cancel AT ROW 4.25 COL 35.5
     for-object AT ROW 2.5 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     SPACE(9.62) SKIP(2.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилита пересчета остатков МЦ"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame v-obj-type
                           v-obj-code.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = v-obj-type AND
          buf_clients.obj-code = v-obj-code NO-ERROR.
IF AVAIL buf_clients THEN DO:
  run utl/reclcwth.p (buf_clients.obj-type, buf_clients.obj-code) no-error.
    if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при пересчете объекта" skip
    buf_clients.obj-type buf_clients.obj-code.
    end.
END.
ELSE DO:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден объект для пересчета" skip.
END.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
 define variable v_rid as character no-undo.
 define variable ref-rec as recid no-undo .
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = INPUT FRAME Dialog-Frame v-obj-type AND
            buf_clients.obj-code = INPUT FRAME Dialog-Frame v-obj-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                 input parparentproc
               ,input "b-sel":U
               ,input v-obj-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-obj-type
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
    assign
    v-obj-type =  buf_clients.obj-type
    v-obj-code =  buf_clients.obj-code
    for-object =  buf_clients.obj-name
    .
      DISPLAY
      v-obj-type
      v-obj-code
      for-object
      WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-Help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
  MESSAGE "Help for File: c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\utl\reclcw1o.w" VIEW-AS ALERT-BOX INFORMATION.
END.
ON LEAVE OF v-obj-code IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame v-obj-type
                           v-obj-code.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = v-obj-type AND
          buf_clients.obj-code = v-obj-code NO-ERROR.
IF AVAIL buf_clients THEN DO:
    DISPLAY
    buf_clients.obj-name @ for-object WITH FRAME Dialog-Frame.
END.
ELSE DO:
    DISPLAY
    "":U @ for-object WITH FRAME Dialog-Frame.
END.
END.
ON VALUE-CHANGED OF v-obj-type IN FRAME Dialog-Frame
DO:
assign frame Dialog-Frame v-obj-type
                           v-obj-code.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = v-obj-type AND
          buf_clients.obj-code = v-obj-code NO-ERROR.
IF AVAIL buf_clients THEN DO:
    DISPLAY
    buf_clients.obj-name @ for-object WITH FRAME Dialog-Frame.
END.
ELSE DO:
    DISPLAY
    "":U @ for-object WITH FRAME Dialog-Frame.
END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
       v-obj-type:list-items =     'маг':U + chr(44) +
                                    'скл':U + chr(44).
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-obj-type v-obj-code for-object
      WITH FRAME Dialog-Frame.
  ENABLE B-Help v-obj-type v-obj-code B-cli Btn_OK Btn_Cancel for-object
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
