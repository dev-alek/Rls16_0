DEFINE TEMP-TABLE tt-wth-ser NO-UNDO LIKE ub.wth-ser.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter pser-code as integer no-undo.
define input parameter pdb-num   as integer no-undo.
define input parameter pwth-code as integer no-undo.
define input parameter ppar-code as integer no-undo.
define input parameter par-mode as character no-undo.
define output PARAMETER p-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог добавлени\изменения серии(маски) МЦ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEF BUFFER LOCKED_wealth FOR ub.wealth.
DEF BUFFER LOCKED_wth-ser FOR ub.wth-ser.
DEF BUFFER locked_wth-par FOR ub.wth-par.
DEF BUFFER b-wth-par FOR ub.wth-par.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-par
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-wth
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE FILL-par AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-wth AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 7.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 5.5.
DEFINE QUERY Dialog-Frame FOR
      tt-wth-ser SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13 WIDGET-ID 2
     b-quit AT ROW 1 COL 11.13 WIDGET-ID 8
     B-hist AT ROW 1 COL 61 WIDGET-ID 6
     B-Help AT ROW 1 COL 81 WIDGET-ID 4
     tt-wth-ser.series AT ROW 3.5 COL 13.5 COLON-ALIGNED WIDGET-ID 16
          LABEL "Наименование"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tt-wth-ser.wth-code AT ROW 4.75 COL 13.5 COLON-ALIGNED WIDGET-ID 18
          LABEL "Код МЦ"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-wth AT ROW 4.75 COL 26 WIDGET-ID 32
     tt-wth-ser.par-code AT ROW 4.75 COL 67 COLON-ALIGNED WIDGET-ID 14
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     B-par AT ROW 4.75 COL 73.5 WIDGET-ID 34
     tt-wth-ser.maska AT ROW 6.5 COL 15.5 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR NO-WORD-WRAP MAX-CHARS 19
          SIZE 20 BY 1 TOOLTIP "Маска"
     tt-wth-ser.authr AT ROW 6.5 COL 42.12 WIDGET-ID 10
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Да",1,
                     "Нет",0
          DROP-DOWN-LIST
          SIZE 7 BY 1
     tt-wth-ser.range-rule AT ROW 8.75 COL 20 COLON-ALIGNED WIDGET-ID 72
          LABEL "Диапазон: с симв." FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.range-smb AT ROW 8.75 COL 29 COLON-ALIGNED WIDGET-ID 74
          LABEL "по" FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.chk-ser AT ROW 10 COL 15.12 WIDGET-ID 54
          LABEL "Серия"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Да",1,
                     "Нет",0
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.ser-rule AT ROW 10 COL 55 COLON-ALIGNED WIDGET-ID 78 FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.ser-smb AT ROW 10 COL 84 COLON-ALIGNED WIDGET-ID 80
          LABEL "Значение" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 9.5 BY 1
     tt-wth-ser.chk-gds AT ROW 11.25 COL 10 WIDGET-ID 50
          LABEL "Код товара"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Да",1,
                     "Нет",0
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.gds-rule AT ROW 11.25 COL 55 COLON-ALIGNED WIDGET-ID 28 FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.gds-smb AT ROW 11.25 COL 84 COLON-ALIGNED WIDGET-ID 30
          LABEL "Значение" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 9.5 BY 1
     tt-wth-ser.chk-par AT ROW 12.5 COL 13 WIDGET-ID 52
          LABEL "Номинал"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Да",1,
                     "Нет",0
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.par-rule AT ROW 12.5 COL 55 COLON-ALIGNED WIDGET-ID 66 FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.par-smb AT ROW 12.5 COL 84 COLON-ALIGNED WIDGET-ID 68
          LABEL "Значение" FORMAT "X(100)"
          VIEW-AS FILL-IN
          SIZE 9.5 BY 1
     tt-wth-ser.chk-bdt AT ROW 14.75 COL 9 WIDGET-ID 46
          LABEL "Дата начала"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Правило",1,
                     "Нет",0,
                     "Дата",2
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.beg-dt AT ROW 14.75 COL 55 COLON-ALIGNED WIDGET-ID 38
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.
DEFINE FRAME Dialog-Frame
     tt-wth-ser.beg-yy AT ROW 15.75 COL 55 COLON-ALIGNED WIDGET-ID 42
          LABEL "Год начала с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.beg-yy-smb AT ROW 15.75 COL 87.5 COLON-ALIGNED WIDGET-ID 44
          LABEL "Кол-во симв." FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.beg-mm AT ROW 16.75 COL 55 COLON-ALIGNED WIDGET-ID 40
          LABEL "Месяц начала с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.beg-dd AT ROW 16.75 COL 87.5 COLON-ALIGNED WIDGET-ID 36
          LABEL "День начала с симв." FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.chk-edt AT ROW 18 COL 6.12 WIDGET-ID 48
          LABEL "Дата окончания"
          VIEW-AS COMBO-BOX
          LIST-ITEM-PAIRS "Правило",1,
                     "Нет",0,
                     "Дата",2
          DROP-DOWN-LIST
          SIZE 9.5 BY 1
     tt-wth-ser.end-dt AT ROW 18 COL 55 COLON-ALIGNED WIDGET-ID 58
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-wth-ser.end-yy AT ROW 19 COL 55 COLON-ALIGNED WIDGET-ID 62
          LABEL "Год окончания с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.end-yy-smb AT ROW 19 COL 87.5 COLON-ALIGNED WIDGET-ID 64
          LABEL "Кол-во симв." FORMAT "X(2)"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.end-mm AT ROW 20 COL 55 COLON-ALIGNED WIDGET-ID 60
          LABEL "Месяц окончания с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.end-dd AT ROW 20 COL 87.5 COLON-ALIGNED WIDGET-ID 56
          LABEL "День окончания с симв."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-wth-ser.PS AT ROW 21.5 COL 1.5 NO-LABEL WIDGET-ID 70
          VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL
          SIZE 96.5 BY 1.25
     tt-wth-ser.ser-code AT ROW 2.5 COL 13.5 COLON-ALIGNED WIDGET-ID 76
          LABEL "Код" FORMAT "999999999"
           VIEW-AS TEXT
          SIZE 9 BY .67
          FGCOLOR 4
     FILL-wth AT ROW 5 COL 27.5 COLON-ALIGNED NO-LABEL WIDGET-ID 82
     FILL-par AT ROW 5 COL 76.5 COLON-ALIGNED NO-LABEL WIDGET-ID 84
     "Срок годности" VIEW-AS TEXT
          SIZE 15 BY .67 AT ROW 14 COL 2.5 WIDGET-ID 96
          FGCOLOR 4
     "Структура маски" VIEW-AS TEXT
          SIZE 16 BY .67 AT ROW 8 COL 2.5 WIDGET-ID 94
          FGCOLOR 4
     "Маска:" VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 6.75 COL 8.5 WIDGET-ID 86
     RECT-2 AT ROW 14.25 COL 1.5 WIDGET-ID 90
     RECT-3 AT ROW 8.25 COL 1.5 WIDGET-ID 92
     SPACE(0.37) SKIP(9.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-par:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-wth:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error .
    if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF tt-wth-ser.authr IN FRAME Dialog-Frame
DO:
  IF SELF:SCREEN-VALUE = '0' THEN DO:
  END.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
   define variable v-rid-list  as   character            no-undo .
   define variable v-host-code like ub.sysconf.host-code no-undo .
   run ref/cwthhist.w (
                    input        parparentproc
                  , input        p-curr-host-code
                  , input        p-curr-obj-type
                  , input        p-curr-obj-code
                  , input        "":U
                  , input        "subject":U
                  , input        int(tt-wth-ser.wth-code:screen-value)
                  , INPUT        0
                  , input        ?
                  , input        ?
                  , input        ?
                  , input        ?
                  , input        "":U
                  , input        'wth-ser':U
                  , input        v-cntxt-db-num
                  , input        tt-wth-ser.ser-code
                  , input        tt-wth-ser.db-num
                  , input-output v-rid-list
                  ) no-error .
END.
ON CHOOSE OF B-par IN FRAME Dialog-Frame
DO:
  define variable v-rid-list as character no-undo .
  run ref/wthp-ref.w (
                  input parparentproc
                 ,input  "b-sel,b-add"
                 ,input p-curr-host-code
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input ( if int(tt-wth-ser.wth-code:screen-value) > 0 then 'МЦ':U else '')
                 ,input int(tt-wth-ser.wth-code:screen-value)
                 ,input-output v-rid-list).
        find first locked_wth-par exclusive-LOCK WHERE
              recid(locked_wth-par) = integer(entry(1, v-rid-list)) NO-ERROR.
      if available locked_wth-par then ASSIGN tt-wth-ser.par-code:SCREEN-VALUE = string(LOCKED_wth-par.par-code)
                                              fill-par:SCREEN-VALUE = STRING(LOCKED_wth-par.par-val).
END.
ON CHOOSE OF B-wth IN FRAME Dialog-Frame
DO:
      v-rid-list = ''.
      run ref/wth-ref.w (
                         input parparentproc
                        ,input "b-sel"
                        ,input p-curr-host-code
                        ,input p-curr-obj-type
                        ,input p-curr-obj-code
                        ,input 'wth-ser':U
                        ,input-output v-rid-list) no-error.
      if v-rid-list = "" then return .
      find first locked_wealth exclusive-LOCK WHERE
              recid(locked_wealth) = integer(entry(1, v-rid-list)) NO-ERROR.
      if available locked_wealth then do:
          ASSIGN tt-wth-ser.wth-code:SCREEN-VALUE = string(LOCKED_wealth.wth-code)
                 fill-wth:SCREEN-VALUE = LOCKED_wealth.wth-name.
         FIND b-wth-par WHERE b-wth-par.wth-code = LOCKED_wealth.wth-code NO-ERROR.
         IF AVAILABLE b-wth-par THEN do:
             tt-wth-ser.par-code:SCREEN-VALUE = string(b-wth-par.par-code).
             APPLY 'leave':U TO tt-wth-ser.par-code.
         END.
      END.
END.
ON VALUE-CHANGED OF tt-wth-ser.chk-bdt IN FRAME Dialog-Frame
DO :
  IF SELF:SCREEN-VALUE = '1' THEN DO WITH FRAME Dialog-Frame:
      ENABLE tt-wth-ser.beg-dd
             tt-wth-ser.beg-mm
             tt-wth-ser.beg-yy
             tt-wth-ser.beg-yy-smb
     .
      DISABLE tt-wth-ser.beg-dt .
      tt-wth-ser.beg-dt:screen-value = "":U.
  END.
  ELSE IF SELF:SCREEN-VALUE = '2' THEN DO WITH FRAME Dialog-Frame:
      DISABLE tt-wth-ser.beg-dd
             tt-wth-ser.beg-mm
             tt-wth-ser.beg-yy
             tt-wth-ser.beg-yy-smb
     .
      ENABLE tt-wth-ser.beg-dt .
      tt-wth-ser.beg-dd:screen-value = "":U.
      tt-wth-ser.beg-mm:screen-value = "":U.
      tt-wth-ser.beg-yy:screen-value = "":U.
      tt-wth-ser.beg-yy-smb:screen-value = "":U.
  END.
  ELSE  do:
  DISABLE    tt-wth-ser.beg-dd
             tt-wth-ser.beg-mm
             tt-wth-ser.beg-yy
             tt-wth-ser.beg-yy-smb
             tt-wth-ser.beg-dt
       WITH FRAME Dialog-Frame.
       tt-wth-ser.beg-dd:screen-value = "":U.
       tt-wth-ser.beg-mm:screen-value = "":U.
       tt-wth-ser.beg-yy:screen-value = "":U.
       tt-wth-ser.beg-yy-smb:screen-value = "":U.
       tt-wth-ser.beg-dt:screen-value = "":U.
  end.
  apply 'tab':U to self.
END.
ON VALUE-CHANGED OF tt-wth-ser.chk-edt IN FRAME Dialog-Frame
DO:
    IF SELF:SCREEN-VALUE = '1' THEN DO WITH FRAME Dialog-Frame:
      ENABLE tt-wth-ser.end-dd
             tt-wth-ser.end-mm
             tt-wth-ser.end-yy
             tt-wth-ser.end-yy-smb
     .
      DISABLE tt-wth-ser.end-dt .
      tt-wth-ser.end-dt:screen-value = "":U.
  END.
  ELSE IF SELF:SCREEN-VALUE = '2' THEN DO WITH FRAME Dialog-Frame:
      DISABLE tt-wth-ser.end-dd
             tt-wth-ser.end-mm
             tt-wth-ser.end-yy
             tt-wth-ser.end-yy-smb
     .
      ENABLE tt-wth-ser.end-dt .
      tt-wth-ser.end-dd:screen-value = "":U.
      tt-wth-ser.end-mm:screen-value = "":U.
      tt-wth-ser.end-yy:screen-value = "":U.
      tt-wth-ser.end-yy-smb:screen-value = "":U.
  END.
  ELSE  do:
     DISABLE    tt-wth-ser.end-dd
             tt-wth-ser.end-mm
             tt-wth-ser.end-yy
             tt-wth-ser.end-yy-smb
             tt-wth-ser.end-dt
       WITH FRAME Dialog-Frame.
       tt-wth-ser.end-dd:screen-value = "":U.
       tt-wth-ser.end-mm:screen-value = "":U.
       tt-wth-ser.end-yy:screen-value = "":U.
       tt-wth-ser.end-yy-smb:screen-value = "":U.
       tt-wth-ser.end-dt:screen-value = "":U.
  END.
  apply 'tab':U to self.
END.
ON VALUE-CHANGED OF tt-wth-ser.chk-gds IN FRAME Dialog-Frame
DO:
  IF SELF:SCREEN-VALUE = '1' THEN DO:
    ENABLE  tt-wth-ser.gds-smb
            tt-wth-ser.gds-rule
    WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
    DISABLE    tt-wth-ser.gds-smb
                  tt-wth-ser.gds-rule
    WITH FRAME Dialog-Frame.
    tt-wth-ser.gds-smb:screen-value = '':U.
    tt-wth-ser.gds-rule:screen-value = '':U.
  END.
  apply 'tab':U to self.
END.
ON VALUE-CHANGED OF tt-wth-ser.chk-par IN FRAME Dialog-Frame
DO:
  IF SELF:SCREEN-VALUE = '1' THEN DO:
    ENABLE  tt-wth-ser.par-smb
            tt-wth-ser.par-rule
    WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
    DISABLE    tt-wth-ser.par-smb
               tt-wth-ser.par-rule
    WITH FRAME Dialog-Frame.
    tt-wth-ser.par-smb:screen-value = '':U.
    tt-wth-ser.par-rule:screen-value = '':U.
  END.
  apply 'tab':U to self.
END.
ON VALUE-CHANGED OF tt-wth-ser.chk-ser IN FRAME Dialog-Frame
DO:
  IF SELF:SCREEN-VALUE = '1' THEN do:
    ENABLE  tt-wth-ser.ser-smb
            tt-wth-ser.ser-rule
    WITH FRAME Dialog-Frame.
  END.
  ELSE do:
    DISABLE    tt-wth-ser.ser-smb
               tt-wth-ser.ser-rule
       WITH FRAME Dialog-Frame.
    tt-wth-ser.ser-smb:screen-value = '':U.
    tt-wth-ser.ser-rule:screen-value = '':U.
  END.
  apply 'tab':U to self.
END.
ON LEAVE OF tt-wth-ser.par-code IN FRAME Dialog-Frame
DO:
    IF NOT SELF:MODIFIED THEN RETURN.
      find first locked_wth-par exclusive-LOCK WHERE
              locked_wth-par.par-code = integer(SELF:SCREEN-VALUE)
              AND  locked_wth-par.wth-code = integer(tt-wth-ser.wth-code:SCREEN-VALUE)      NO-ERROR.
      if available locked_wth-par then ASSIGN tt-wth-ser.par-code:SCREEN-VALUE = string(LOCKED_wth-par.par-code)
                                              fill-par:SCREEN-VALUE = STRING(LOCKED_wth-par.par-val).
    SELF:MODIFIED = NO.
END.
ON LEAVE OF tt-wth-ser.wth-code IN FRAME Dialog-Frame
DO:
  if not self:modified then return.
        find first locked_wealth exclusive-LOCK WHERE
              locked_wealth.wth-code = integer(SELF:SCREEN-VALUE) NO-ERROR.
      if available locked_wealth then do:
          ASSIGN tt-wth-ser.wth-code:SCREEN-VALUE = string(LOCKED_wealth.wth-code)
                 fill-wth:SCREEN-VALUE = LOCKED_wealth.wth-name.
         FIND b-wth-par WHERE b-wth-par.wth-code = LOCKED_wealth.wth-code NO-ERROR.
         IF AVAILABLE b-wth-par THEN do:
             tt-wth-ser.par-code:SCREEN-VALUE = string(b-wth-par.par-code).
             APPLY 'leave':U TO tt-wth-ser.par-code.
         END.
      END.
      SELF:MODIFIED = NO.
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(par-mode, 'ДОБАВЛЕНИЕ':U + chr(44) +
                      'ИЗМЕНЕНИЕ':U + chr(44) +
                      'ПРОСМОТР':U) = 0 THEN DO:
    MESSAGE
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.
  IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    CREATE tt-wth-ser.
      IF pwth-code <> 0  THEN do:
        FIND FIRST LOCKED_wealth EXCLUSIVE-LOCK WHERE
                 LOCKED_wealth.wth-code = pwth-code NO-ERROR.
        IF NOT AVAILABLE LOCKED_wealth THEN DO:
            message vss-workfile vss-revision vss-description skip
            "Не найдена материальная ценность с кодом " pwth-code
            view-as alert-box error.
            return error.
        END.
        tt-wth-ser.wth-code = LOCKED_wealth.wth-code.
          IF ppar-code <> 0  THEN do:
            FIND FIRST LOCKED_wth-par EXCLUSIVE-LOCK WHERE
                     LOCKED_wth-par.wth-code = pwth-code
                AND  LOCKED_wth-par.par-code = ppar-code NO-ERROR.
            IF NOT AVAILABLE LOCKED_wth-par THEN DO:
                message vss-workfile vss-revision vss-description skip
                "Не найдена материальная ценность с кодом " ppar-code
                view-as alert-box error.
                return error.
            END.
            tt-wth-ser.par-code = LOCKED_wth-par.par-code.
          END.
      END.
  END.
  ELSE DO:
     IF par-mode = 'ПРОСМОТР':U THEN DO:
       FIND FIRST LOCKED_wth-ser NO-LOCK WHERE
                LOCKED_wth-ser.ser-code = pser-code
           AND  LOCKED_wth-ser.db-num = pdb-num NO-ERROR.
     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-ser exclusive-LOCK WHERE
                LOCKED_wth-ser.ser-code = pser-code
           AND  LOCKED_wth-ser.db-num = pdb-num NO-ERROR.
     END.
     IF NOT AVAILABLE LOCKED_wth-ser THEN DO:
        MESSAGE
        SUBSTITUTE("Не найден номинал с кодом &1 для МЦ с  кодом &2", ppar-code, pwth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    IF par-mode = 'ПРОСМОТР':U THEN DO:
       FIND FIRST LOCKED_wealth NO-LOCK WHERE
                LOCKED_wealth.wth-code = LOCKED_wth-ser.wth-code NO-ERROR.
     END.
     ELSE DO:
         FIND FIRST LOCKED_wealth exclusive-LOCK WHERE
                    LOCKED_wealth.wth-code = LOCKED_wth-ser.wth-code NO-ERROR.
     END.
     IF NOT AVAILABLE LOCKED_wealth THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена МЦ с кодом &1 ",LOCKED_wth-ser.wth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    IF par-mode = 'ПРОСМОТР':U THEN DO:
       FIND FIRST LOCKED_wth-par NO-LOCK WHERE
                LOCKED_wth-par.par-code = LOCKED_wth-ser.par-code
           AND  LOCKED_wth-par.wth-code = LOCKED_wth-ser.wth-code          NO-ERROR.
     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-par exclusive-LOCK WHERE
            LOCKED_wth-par.par-code = LOCKED_wth-ser.par-code
            AND  LOCKED_wth-par.wth-code = LOCKED_wth-ser.wth-code            NO-ERROR.
     END.
     IF NOT AVAILABLE LOCKED_wth-par THEN DO:
        MESSAGE
        SUBSTITUTE("Не найден номинал с кодом &1 для МЦ с  кодом &2", LOCKED_wth-ser.par-code,  LOCKED_wth-ser.wth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    CREATE tt-wth-ser.
    BUFFER-COPY LOCKED_wth-ser TO tt-wth-ser.
  END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-wth-ser SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY FILL-wth FILL-par
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-ser THEN
    DISPLAY tt-wth-ser.series tt-wth-ser.wth-code tt-wth-ser.par-code
          tt-wth-ser.maska tt-wth-ser.authr tt-wth-ser.range-rule
          tt-wth-ser.range-smb tt-wth-ser.chk-ser tt-wth-ser.ser-rule
          tt-wth-ser.ser-smb tt-wth-ser.chk-gds tt-wth-ser.gds-rule
          tt-wth-ser.gds-smb tt-wth-ser.chk-par tt-wth-ser.par-rule
          tt-wth-ser.par-smb tt-wth-ser.chk-bdt tt-wth-ser.beg-dt
          tt-wth-ser.beg-yy tt-wth-ser.beg-yy-smb tt-wth-ser.beg-mm
          tt-wth-ser.beg-dd tt-wth-ser.chk-edt tt-wth-ser.end-dt
          tt-wth-ser.end-yy tt-wth-ser.end-yy-smb tt-wth-ser.end-mm
          tt-wth-ser.end-dd tt-wth-ser.PS tt-wth-ser.ser-code
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 RECT-3 B-exit b-quit B-hist B-Help tt-wth-ser.series
         tt-wth-ser.par-code tt-wth-ser.range-rule tt-wth-ser.range-smb
         tt-wth-ser.PS tt-wth-ser.ser-code FILL-wth FILL-par
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
ENABLE
B-exit WHEN par-mode <> 'ПРОСМОТР':U
b-quit
B-Help
b-hist WHEN par-mode = 'ИЗМЕНЕНИЕ':U OR par-mode = 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    ENABLE
    tt-wth-ser.series
    tt-wth-ser.wth-code when not available locked_wealth
    tt-wth-ser.par-code when not available locked_wth-par
    b-wth when not available locked_wealth
    b-par when not available locked_wth-par
    WITH FRAME Dialog-Frame.
    tt-wth-ser.authr = 1.
    tt-wth-ser.chk-ser = 1.
END.
DISPLAY
   tt-wth-ser.series tt-wth-ser.wth-code tt-wth-ser.par-code tt-wth-ser.maska tt-wth-ser.authr tt-wth-ser.range-rule tt-wth-ser.range-smb tt-wth-ser.chk-ser tt-wth-ser.ser-rule tt-wth-ser.ser-smb tt-wth-ser.chk-gds tt-wth-ser.gds-rule tt-wth-ser.gds-smb tt-wth-ser.chk-par tt-wth-ser.par-rule tt-wth-ser.par-smb tt-wth-ser.chk-bdt tt-wth-ser.beg-dt tt-wth-ser.beg-yy tt-wth-ser.beg-yy-smb tt-wth-ser.beg-mm tt-wth-ser.beg-dd tt-wth-ser.chk-edt tt-wth-ser.end-dt tt-wth-ser.end-yy tt-wth-ser.end-yy-smb tt-wth-ser.end-mm tt-wth-ser.end-dd tt-wth-ser.PS tt-wth-ser.ser-code
WITH FRAME Dialog-Frame  .
VIEW FRAME Dialog-Frame.
IF par-mode = 'ДОБАВЛЕНИЕ':U or par-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
    ENABLE
    tt-wth-ser.chk-ser
    tt-wth-ser.chk-par
    tt-wth-ser.chk-gds
    tt-wth-ser.chk-edt
    tt-wth-ser.chk-bdt
    tt-wth-ser.range-smb
    tt-wth-ser.range-rule
    tt-wth-ser.authr
    tt-wth-ser.maska
    tt-wth-ser.PS
    tt-wth-ser.series
 WITH FRAME Dialog-Frame.
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-ser .
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-par.
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-gds .
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-edt.
    APPLY "VALUE-CHANGED":U TO tt-wth-ser.chk-bdt.
END.
IF AVAILABLE LOCKED_wealth THEN fill-wth:SCREEN-VALUE = LOCKED_wealth.wth-name.
IF AVAILABLE LOCKED_wth-par THEN fill-par:SCREEN-VALUE = string(LOCKED_wth-par.par-val).
IF par-mode = 'ПРОСМОТР':U THEN DO:
  HIDE
  b-exit IN FRAME Dialog-Frame
  .
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
frame Dialog-Frame:title = substitute("Серия номинала &1 &4 материальной ценности &2  &3"
                                     ,if available LOCKED_wth-par then string (LOCKED_wth-par.par-val) else ""
                                     ,if available locked_wealth then locked_wealth.wth-name else ""
                                     ,par-mode
                                     ,if available LOCKED_wth-par then LOCKED_wth-par.par-unit else ""
                                      ).
APPLY 'entry':U TO tt-wth-ser.series.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
IF par-mode = 'ПРОСМОТР':U THEN UNDO, RETURN ERROR.
assign
FRAME Dialog-Frame tt-wth-ser.series tt-wth-ser.wth-code tt-wth-ser.par-code tt-wth-ser.maska tt-wth-ser.authr tt-wth-ser.range-rule tt-wth-ser.range-smb tt-wth-ser.chk-ser tt-wth-ser.ser-rule tt-wth-ser.ser-smb tt-wth-ser.chk-gds tt-wth-ser.gds-rule tt-wth-ser.gds-smb tt-wth-ser.chk-par tt-wth-ser.par-rule tt-wth-ser.par-smb tt-wth-ser.chk-bdt tt-wth-ser.beg-dt tt-wth-ser.beg-yy tt-wth-ser.beg-yy-smb tt-wth-ser.beg-mm tt-wth-ser.beg-dd tt-wth-ser.chk-edt tt-wth-ser.end-dt tt-wth-ser.end-yy tt-wth-ser.end-yy-smb tt-wth-ser.end-mm tt-wth-ser.end-dd tt-wth-ser.PS tt-wth-ser.ser-code.
if  par-mode = 'ИЗМЕНЕНИЕ':U then v-rec = recid(locked_wth-ser).
run ref/wth-ser.p ( INPUT par-mode
                    , tt-wth-ser.ser-code
                    , tt-wth-ser.db-num
                    , tt-wth-ser.maska
                    , tt-wth-ser.series
                    , tt-wth-ser.authr
                    , tt-wth-ser.wth-code
                    , tt-wth-ser.par-code
                    , tt-wth-ser.beg-dd
                    , tt-wth-ser.beg-dt
                    , tt-wth-ser.beg-mm
                    , tt-wth-ser.beg-yy-smb
                    , tt-wth-ser.beg-yy
                    , tt-wth-ser.chk-bdt
                    , tt-wth-ser.chk-edt
                    , tt-wth-ser.chk-gds
                    , tt-wth-ser.chk-par
                    , tt-wth-ser.chk-ser
                    , tt-wth-ser.end-dd
                    , tt-wth-ser.end-dt
                    , tt-wth-ser.end-mm
                    , tt-wth-ser.end-yy-smb
                    , tt-wth-ser.end-yy
                    , tt-wth-ser.gds-rule
                    , tt-wth-ser.gds-smb
                    , tt-wth-ser.par-rule
                    , tt-wth-ser.par-smb
                    , tt-wth-ser.PS
                    , tt-wth-ser.qnty
                    , tt-wth-ser.range-rule
                    , tt-wth-ser.range-smb
                    , tt-wth-ser.ser-rule
                    , tt-wth-ser.ser-smb
                    ,INPUT NO
                    ,INPUT-OUTPUT v-rec  ) no-error .
if error-status:error then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.
