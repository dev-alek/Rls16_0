block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: disp-lib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/disp-lib.p $":U .
define variable vss-description as character no-undo init "Библионтека для обслуживания банковских карт (Сбербанк)".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#disp-lib as handle no-undo.
if valid-handle (g#disp-lib)
and g#disp-lib <> this-procedure :handle
and g#disp-lib :get-signature('library_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#disp-lib skip
    g#disp-lib :type skip
    g#disp-lib :file-name skip
    valid-handle(g#disp-lib) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#disp-lib = this-procedure :handle
  .
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
on delete of this-procedure do:
  assign
    g#disp-lib = ?
  .
end.
DEFINE VARIABLE v-disp          AS COM-HANDLE     NO-UNDO .
define variable v-disp-type    as integer      no-undo.
define variable v-disp-Open    as logical      no-undo.
define variable v-str-len      as integer      no-undo.
DEFINE VARIABLE CtrlFrame-2     AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame-2   AS COMPONENT-HANDLE NO-UNDO.
DEFINE FRAME Dialog-Frame-2
           SPACE(9.13) SKIP(1.57)
        WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         .
procedure disp-init :
define input parameter  p-first-string          as character      no-undo .
define input parameter  p-second-string         as character      no-undo .
define input parameter  p-customer-display-type as character        no-undo .
define input parameter  p-customer-display-port as integer        no-undo .
define output parameter p-message               as character      no-undo .
define output parameter p-ok                    as logical        no-undo .
bl:
do
on error undo, return error
:
   RELEASE OBJECT v-disp NO-ERROR.
   v-disp = ?.
   CASE p-customer-display-type:
      WHEN 'Shtrih-M_v_A1.40':U
      THEN DO:
         CREATE "DrvDspl.v1_2":U v-disp NO-ERROR.
         IF ERROR-STATUS:ERROR
         OR NOT VALID-HANDLE(v-disp)
         THEN DO:
            ASSIGN
               p-message = "Не найден COM-сервер для дисплея покупателя"
            .
            RETURN.
         END.
         assign
            v-disp-Open = YES
            v-disp-type = 201
            v-str-len   = 20
         .
         v-disp:CONNECT() NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.
         v-disp:InitialDispl () NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.
         v-disp:Test () NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.
         run disp-str IN THIS-PROCEDURE ( INPUT  p-first-string
                                       , INPUT  p-second-string
                                       , OUTPUT p-message
                                       , OUTPUT p-ok
                                       ) .
      END.
      WHEN 'Posiflex-pd2800-320':U THEN
      DO:
       DEF VAR v-pd     AS COM-HANDLE NO-UNDO .
       run control_load in this-procedure  .
       DEF VAR v-i AS INT NO-UNDO .
       v-pd = chCtrlFrame-2:controls .
       v-disp = v-pd:ITEM(1) .
       IF VALID-HANDLE(v-disp) THEN
       DO:
           v-i = v-disp:OPEN("pd320") .
           v-i = v-disp:ClaimDevice(0) .
           IF v-disp:claimed THEN
           DO:
             assign
               v-disp:DeviceEnabled = YES
               v-disp-open = yes
               v-disp:CharacterSet = 866
               v-str-len = v-disp:DeviceColumns
               v-disp-type = 320
               .
               run disp-str IN THIS-PROCEDURE ( INPUT  p-first-string
                                       , INPUT  p-second-string
                                       , OUTPUT p-message
                                       , OUTPUT p-ok
                                       ) .
           END.
       END.
      END.
      OTHERWISE DO:
      end.
   END CASE.
   assign
      p-ok = TRUE
   .
end.
end procedure.
PROCEDURE disp-str :
define input parameter  p-first-string    as character        no-undo.
define input parameter  p-second-string   as character        no-undo.
define output parameter p-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
define variable v-line    as character    no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN 201 THEN DO:
         run disp-clear IN THIS-PROCEDURE ( OUTPUT p-message
                                          , OUTPUT  p-ok
                                          ) .
         run disp-fmt IN THIS-PROCEDURE ( INPUT  p-first-string
                                        , INPUT  p-second-string
                                        , OUTPUT v-line
                                        , OUTPUT p-message
                                        , OUTPUT  p-ok
                                        ) .
         v-disp:EnterStr( INPUT 0, INPUT v-line ) NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.
      END.
      WHEN 320 THEN DO:
            run disp-clear IN THIS-PROCEDURE ( OUTPUT p-message
                                          , OUTPUT  p-ok
                                          ) .
               v-disp:DisplayTextAT(2,1,
                     codepage-convert(substr(p-first-string,1,v-str-len),"ibm866",SESSION:CHARSET),6)
                     .
               v-disp:DisplayTextAT(1,1,
                         codepage-convert(substr(p-second-string,1,v-str-len),"ibm866",SESSION:CHARSET),6)
                         .
      END.
      OTHERWISE DO:
      end.
   END CASE.
   ASSIGN
      p-ok = TRUE
   .
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE disp-fmt :
define input parameter  p-line-1    as character        no-undo.
define input parameter  p-line-2    as character        no-undo.
define output parameter p-out-line  as character        no-undo.
define output parameter p-message   as character        no-undo.
define output parameter p-ok        as logical          no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   IF num-entries(p-line-1, chr(4)) >= 2
   THEN DO:
      assign
         p-line-2 = entry(2, p-line-1, chr(4))
         p-line-1 = entry(1, p-line-1, chr(4))
      .
   END.
   ASSIGN
      p-line-1 = TRIM(p-line-1)
      p-line-2 = TRIM(p-line-2)
   .
   IF LENGTH(p-line-1) <= v-str-len
   THEN DO:
      ASSIGN
         p-line-1 = p-line-1 + FILL(" ", v-str-len - LENGTH(p-line-1) )
      .
   END.
   ELSE DO:
      ASSIGN
         p-line-1 = SUBSTRING(p-line-1, 1, v-str-len)
      .
   END.
   IF LENGTH(p-line-2) <= v-str-len
   THEN DO:
      ASSIGN
         p-line-2 = p-line-2 + FILL(" ", v-str-len - LENGTH(p-line-2) )
      .
   END.
   ELSE DO:
      ASSIGN
         p-line-2 = SUBSTRING(p-line-2, 1, v-str-len)
      .
   END.
   ASSIGN
      p-out-line = p-line-1 + p-line-2
      p-ok = TRUE
   .
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE disp-clear :
define output parameter p-message as character        no-undo.
define output parameter p-ok          as logical          no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN 201 THEN DO:
         v-disp:ClearDispl () NO-ERROR.
         IF ERROR-STATUS:ERROR
         THEN DO:
            ASSIGN
               p-message = RETURN-VALUE
               p-ok = FALSE
            .
            RETURN.
         END.
         ASSIGN
            p-ok = TRUE
         .
      END.
      WHEN 320 THEN DO:
         v-disp:ClearText() .
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      end.
   END CASE.
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE disp-beg :
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN 201 THEN DO:
         ASSIGN
            p-ok = TRUE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE disp-terminate :
define output parameter p-message as character        no-undo.
define output parameter p-ok      as logical          no-undo.
IF VALID-HANDLE(v-disp)
THEN DO
ON ERROR UNDO, RETURN ERROR
:
   CASE v-disp-type :
      WHEN 201 THEN DO:
         ASSIGN
            p-ok = TRUE
         .
      END.
      WHEN 320 THEN DO:
        v-disp:ReleaseDevice() .
        v-disp:close() .
      END.
      OTHERWISE DO:
      end.
   END CASE.
assign
      p-ok = yes .
END.
ELSE DO:
   ASSIGN
      p-ok = TRUE
   .
END.
END PROCEDURE.
PROCEDURE control_load :
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.
CREATE CONTROL-FRAME CtrlFrame-2 ASSIGN
       FRAME           = frame dialog-frame-2:handle
       ROW             = 3.38
       COLUMN          = 18
       HEIGHT          = 4.76
       WIDTH           = 20
       WIDGET-ID       = 8
       HIDDEN          = yes
       SENSITIVE       = yes.
OCXFile = SEARCH( "gbl\dp2800_320.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U)
                     + "wrx":U).
IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame-2 = CtrlFrame-2:COM-HANDLE
    UIB_S = chCtrlFrame-2:LoadControls( OCXFile, "CtrlFrame-2":U)
    CtrlFrame-2:NAME = "CtrlFrame-2":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "gbl/dp2800_320.wrx":U SKIP(1)
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".
END PROCEDURE.
