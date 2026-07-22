define input        parameter parparentproc as handle    no-undo .
define variable place-list as character no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE rs-place AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 23 BY 2.14 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.24 COL 2
     Btn_Cancel AT ROW 1.24 COL 17
     rs-place AT ROW 4.33 COL 5 NO-LABEL WIDGET-ID 2
     "Резервуары:" VIEW-AS TEXT
          SIZE 17 BY 1.19 AT ROW 2.71 COL 4 WIDGET-ID 6
     SPACE(18.99) SKIP(3.76)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Повторная инициализация"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON choose OF Btn_Ok in frame Dialog-Frame
DO:
  case rs-place :
    when 1
    then do :
      run utl/init-shift-period.p (input "all") .
    end .
    when 2
    then do :
      if place-list = ""
      then do :
        message "Не выбрано ни одного резервуара!" view-as alert-box .
        return no-apply .
      end .
      run utl/init-shift-period.p (input place-list) .
    end .
  end case .
END.
ON VALUE-CHANGED OF rs-place IN FRAME Dialog-Frame
DO:
  assign rs-place .
  if rs-place = 2
  then do :
    run ref/pl-list.w (
     input parparentproc
    ,input "b-sel,b-mark"
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input 'объект':U + chr(4) + "only-np"
    ,input-output place-list).
    if place-list = "cancel"
    then do :
      place-list = "" .
      return no-apply .
    end .
  end .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-place
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel rs-place
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
