define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "$Дополнительная информация договора":U.
DEFINE INPUT  PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT  PARAMETER parBackHandle  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT  PARAMETER p-Ref-mode     AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER p-Doc-type     AS CHARACTER  NO-UNDO.
DEFINE INPUT  PARAMETER iRid           AS RECID      NO-UNDO.
DEFINE OUTPUT PARAMETER cError         AS CHARACTER  NO-UNDO INITIAL "".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-gl-UVEDOMLENIE as CHARACTER NO-UNDO INITIAL "Uvedomlenie":U.
FUNCTION Get-Contract-Attr RETURN CHARACTER(
         INPUT iHost-Code AS INTEGER,
         INPUT iContract-Code  AS INTEGER,
         INPUT cAttr-code      AS CHARACTER):
   DEFINE BUFFER buf_Contract-Attr FOR ub.Contract-Attr.
   FIND FIRST buf_Contract-Attr WHERE
              buf_Contract-Attr.Host-code     = iHost-Code
          AND buf_Contract-Attr.Contract-code = iContract-Code
          AND buf_Contract-Attr.Attr-code     = cAttr-code
        NO-LOCK NO-ERROR.
   RETURN (IF AVAILABLE buf_Contract-Attr THEN buf_Contract-Attr.Attr-value ELSE ?).
END FUNCTION.
PROCEDURE Modify-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      FIND FIRST buf_Contract-Attr WHERE
                 buf_Contract-Attr.Host-Code      = iHost-Code
             AND buf_Contract-Attr.Contract-Code  = iContract-Code
             AND buf_Contract-Attr.Attr-code      = cAttr-code
           NO-LOCK NO-ERROR.
      IF NOT AVAILABLE buf_Contract-Attr THEN DO:
         CREATE buf_Contract-Attr NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END. ELSE DO:
         FIND CURRENT buf_Contract-Attr EXCLUSIVE-LOCK NO-ERROR.
         IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      END.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
PROCEDURE Create-Contract-Attr:
   DEFINE INPUT  PARAMETER iHost-Code      AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER iContract-Code  AS INTEGER   NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-code      AS CHARACTER NO-UNDO.
   DEFINE INPUT  PARAMETER cAttr-value     AS CHARACTER NO-UNDO.
   DEFINE OUTPUT PARAMETER cError          AS CHARACTER NO-UNDO INITIAL "".
   DEFINE BUFFER buf_Contract-Attr FOR  ub.Contract-Attr.
   Tran:
   DO TRANSACTION
      ON ENDKEY UNDO Tran, RETRY Tran
      ON ERROR  UNDO Tran, RETRY Tran
      ON QUIT   UNDO Tran, RETRY Tran
      ON STOP   UNDO Tran, RETRY Tran:
      IF RETRY THEN DO:       cError = "Ошибка транзакции:":U + PROGRAM-NAME(1) + ERROR-STATUS:GET-MESSAGE(1) + " " + RETURN-VALUE.        UNDO Tran, LEAVE Tran.    END.
      CREATE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      ASSIGN
         buf_Contract-Attr.Host-Code      = iHost-Code
         buf_Contract-Attr.Contract-Code  = iContract-Code
         buf_Contract-Attr.Attr-code      = cAttr-code
         buf_Contract-Attr.Attr-value     = cAttr-value
         NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
      RELEASE buf_Contract-Attr NO-ERROR.
      IF ERROR-STATUS:ERROR THEN          UNDO Tran, RETRY Tran.
   END.
   RETURN.
END PROCEDURE.
DEFINE BUFFER buf_Contract FOR ub.contract.
DEFINE BUTTON b-Exit
     LABEL "&Отмена"
     SIZE 11.5 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON b-Ok
     LABEL "&Ввод"
     SIZE 12.5 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE v-EdUvd AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 83 BY 12.5 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-Ok AT ROW 1 COL 1
     b-Exit AT ROW 1 COL 13.5
     v-EdUvd AT ROW 2.67 COL 2.5 NO-LABEL WIDGET-ID 16
     SPACE(1.12) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительная информация" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       v-EdUvd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON ENTRY OF FRAME Dialog-Frame
DO:
   IF p-Ref-mode <> 'ИЗМЕНЕНИЕ':U THEN DO:
      ASSIGN
          b-Exit:HIDDEN = TRUE
          b-Ok:LABEL     = "&Выход"
          .
   END.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-Exit IN FRAME Dialog-Frame
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
   APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-Ok IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   IF v-EdUvd:SENSITIVE AND v-EdUvd:MODIFIED THEN DO:
      ASSIGN
         v-EdUvd.
      RUN Modify-Contract-Attr IN THIS-PROCEDURE(
          buf_Contract.Host-code,
          buf_Contract.Contract-code,
          v-gl-Uvedomlenie,
          v-EdUvd,
          OUTPUT cError
          ).
   END.
   APPLY "GO":U TO SELF.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
FIND FIRST buf_Contract WHERE
           RECID(buf_Contract) = iRid
     NO-LOCK NO-ERROR.
IF NOT AVAILABLE buf_Contract THEN DO:
   MESSAGE
       "Не найден договор RECID(buf_Contract) = " iRid
       VIEW-AS ALERT-BOX INFO BUTTONS OK.
   RETURN.
END.
ASSIGN
   FRAME Dialog-Frame:TITLE = FRAME Dialog-Frame:TITLE +
         " для договора: " + buf_Contract.contract-prn-code + " " +
         "Фирма: " + buf_Contract.own-name + " (Уведомление)" .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  ASSIGN
     v-EdUvd = Get-contract-attr(
               buf_Contract.Host-code,
               buf_Contract.Contract-code,
               v-gl-Uvedomlenie).
  IF p-Ref-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
     ASSIGN
        v-EdUvd:READ-ONLY = FALSE.
  END.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-EdUvd
      WITH FRAME Dialog-Frame.
  ENABLE b-Ok b-Exit v-EdUvd
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
