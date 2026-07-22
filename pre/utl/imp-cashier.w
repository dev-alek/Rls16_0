 DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .
define input parameter parparentproc as widget-handle no-undo .
DEFINE BUTTON B-file-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE b-file AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 2 COL 6
     B-quit AT ROW 2 COL 16.5
     b-file AT ROW 5 COL 11 COLON-ALIGNED WIDGET-ID 2
     B-file-2 AT ROW 5 COL 52.5 WIDGET-ID 4
     SPACE(12.49) SKIP(5.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт кассиров"
        DEFAULT-BUTTON Btn_OK CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-file-2 IN FRAME Dialog-Frame
DO:
      define variable ff as character no-undo.
    define variable v_os-file   AS CHAR NO-UNDO INIT "".
    define variable ll_commit AS LOG    NO-UNDO INIT NO.
    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
        "excel (*.xls , *.xlsx)"   "*.xls, *.xlsx",
        " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".xls , .xlsx"
        USE-FILENAME
        MUST-EXIST
        UPDATE ll_commit
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN b-file = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP b-file WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
define variable firm-pairs as char no-undo.
define variable person-pairs as char no-undo.
define variable mydelimiter as char no-undo.
  assign
  b-file
  .
  if search(b-file) = ? then do:
    message "Не выбран файл импорта"
    view-as alert-box ERROR.
    return no-apply.
  end.
run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'utl/in-imp-cashier.p':U
              , input b-file
              , INPUT no
              , INPUT "&Стоп"
              , INPUT 'Импорт кассиров') .
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
  DISPLAY b-file
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK b-file B-file-2 B-quit
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
