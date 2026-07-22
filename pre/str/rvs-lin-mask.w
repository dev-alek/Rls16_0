define  input parameter parparentproc   as handle    no-undo.
define  input parameter parrec-rvs-line as recid     no-undo.
define  input parameter parmode         as character no-undo.
define  input parameter partitle        as character no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Экран работы со строкой сверки":U.
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
define variable v-return-val as character no-undo initial "":U.
define variable rec-rvs-line-attr as recid  no-undo.
define buffer buf_rvs-line for ub.rvs-line.
define buffer buf_rvs-line-attr for ub.rvs-line-attr.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE fill-in-cap-count AS DECIMAL FORMAT ">>,>>>,>>9.99":U INITIAL 0
     LABEL "Показания счетчика"
     VIEW-AS FILL-IN
     SIZE 15 BY .95 NO-UNDO.
DEFINE VARIABLE fill-in-cap-pres AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     LABEL "Остаточное давление"
     VIEW-AS FILL-IN
     SIZE 15 BY .95 NO-UNDO.
DEFINE VARIABLE fill-in-mag-count AS DECIMAL FORMAT ">>,>>>,>>9.99":U INITIAL 0
     LABEL "Показания счетчика"
     VIEW-AS FILL-IN
     SIZE 15 BY .95 NO-UNDO.
DEFINE VARIABLE fill-in-mag-pres AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     LABEL "Входящее давление"
     VIEW-AS FILL-IN
     SIZE 15 BY .95 NO-UNDO.
DEFINE VARIABLE fill-in-mag-temper AS DECIMAL FORMAT "99.99":U INITIAL 0
     LABEL "Температура"
     VIEW-AS FILL-IN
     SIZE 15 BY .95 NO-UNDO.
DEFINE RECTANGLE RECT-C
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 57 BY 3.57.
DEFINE RECTANGLE RECT-M
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 57 BY 5.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     fill-in-mag-count AT ROW 3.38 COL 35 COLON-ALIGNED WIDGET-ID 26
     fill-in-mag-pres AT ROW 4.81 COL 35 COLON-ALIGNED WIDGET-ID 28
     fill-in-mag-temper AT ROW 6.24 COL 35 COLON-ALIGNED WIDGET-ID 30
     fill-in-cap-count AT ROW 9.57 COL 34 COLON-ALIGNED WIDGET-ID 36
     fill-in-cap-pres AT ROW 11 COL 34 COLON-ALIGNED WIDGET-ID 38
     "Данные по накопительной емкости" VIEW-AS TEXT
          SIZE 38 BY .71 AT ROW 8.14 COL 24 WIDGET-ID 32
     "Данные о заборе газа из магистрали" VIEW-AS TEXT
          SIZE 40 BY .71 AT ROW 2.19 COL 22 WIDGET-ID 22
     RECT-M AT ROW 2.91 COL 12 WIDGET-ID 24
     RECT-C AT ROW 8.86 COL 12 WIDGET-ID 34
     SPACE(11.19) SKIP(0.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ сверки"
         CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  v-return-val = "cancel".
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  v-return-val = "cancel".
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
find first buf_rvs-line where recid(buf_rvs-line) = parrec-rvs-line no-error.
find first buf_rvs-line-attr where recid(buf_rvs-line-attr) = rec-rvs-line-attr no-error.
assign frame Dialog-Frame fill-in-cap-count
                           fill-in-cap-pres
                           fill-in-mag-count
                           fill-in-mag-pres
                           fill-in-mag-temper.
if not available buf_rvs-line-attr then do:
    create buf_rvs-line-attr.
    assign
        buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
        buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
        buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
        buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
        buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
        buf_rvs-line-attr.attr-code = "mask"
        buf_rvs-line-attr.attr-value = substitute("&1;&2;&3",fill-in-mag-count,fill-in-mag-pres,fill-in-mag-temper)
        buf_rvs-line.state-level-petrol = fill-in-cap-count
        buf_rvs-line.state-level-total = fill-in-cap-pres.
        buf_rvs-line.state-density = 0.666.
end.
else do:
    assign
        buf_rvs-line-attr.attr-value = substitute("&1;&2;&3",fill-in-mag-count,fill-in-mag-pres,fill-in-mag-temper)
        buf_rvs-line.state-level-petrol = fill-in-cap-count
        buf_rvs-line.state-level-total = fill-in-cap-pres.
end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run get-values in this-procedure.
  run enable_UI in this-procedure.
  assign frame Dialog-Frame :title = frame Dialog-Frame :title + " - " + parmode + " - " +  partitle.
  run ui-on in this-procedure.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
return v-return-val.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fill-in-mag-count fill-in-mag-pres fill-in-mag-temper
          fill-in-cap-count fill-in-cap-pres
      WITH FRAME Dialog-Frame.
  ENABLE b-save RECT-M RECT-C b-cancel fill-in-mag-count
         fill-in-mag-pres fill-in-mag-temper fill-in-cap-count fill-in-cap-pres
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
procedure ui-on:
if parmode = 'ПРОСМОТР':U then
    disable b-save fill-in-mag-count fill-in-mag-pres
            fill-in-mag-temper fill-in-cap-count fill-in-cap-pres
            with frame Dialog-Frame.
end procedure.
procedure get-values:
find first buf_rvs-line no-lock where recid(buf_rvs-line) = parrec-rvs-line no-error.
find first buf_rvs-line-attr where buf_rvs-line-attr.obj-code = buf_rvs-line.obj-code
                                       and buf_rvs-line-attr.obj-type = buf_rvs-line.obj-type
                                       and buf_rvs-line-attr.gds-code = buf_rvs-line.gds-code
                                       and buf_rvs-line-attr.pl-code = buf_rvs-line.pl-code
                                       and buf_rvs-line-attr.rvs-code = buf_rvs-line.rvs-code
                                       and buf_rvs-line-attr.attr-code = "mask" no-error.
rec-rvs-line-attr = recid(buf_rvs-line-attr) no-error.
if not available buf_rvs-line then do:
   message "Неверно переданы параметры."
           "Не найдена строка сверки с recid " parrec-rvs-line " ."
   view-as alert-box error.
   return error.
end.
assign
    fill-in-cap-count = buf_rvs-line.state-level-petrol
    fill-in-cap-pres = buf_rvs-line.state-level-total
    fill-in-mag-count = integer(entry(1,buf_rvs-line-attr.attr-value, ";"))
    fill-in-mag-pres = integer(entry(2,buf_rvs-line-attr.attr-value, ";"))
    fill-in-mag-temper = integer(entry(3,buf_rvs-line-attr.attr-value, ";")) no-error.
end procedure.
