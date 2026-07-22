define input parameter p-db-num as integer no-undo .
define input parameter p-ID as character no-undo .
define input parameter p-CheckId as character no-undo .
define input parameter p-RRN as character no-undo .
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Сохранить в файл"
     SIZE 17 BY 1.14
     BGCOLOR 8 .
define query br-chk-slip-string for chk-slip-string scrolling .
define browse br-chk-slip-string
  query br-chk-slip-string display
  chk-slip-string.str-value format "X(70)"
WITH no-separators no-labels no-row-markers SIZE 70 BY 26 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.1 COL 2
     b-print AT ROW 1.1 COL 17 WIDGET-ID 2
     br-chk-slip-string at row 2.3 col 2
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет"
         CANCEL-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  run str/chk-slip-print.p (input p-db-num,
                            input p-ID,
                            input p-CheckID,
                            input p-RRN,
                            input "one")
                            .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  open query br-chk-slip-string for each chk-slip-string no-lock where chk-slip-string.db-num = p-db-num
                                                                   and chk-slip-string.ID = p-ID
                                                                   and chk-slip-string.CheckID = p-CheckId
                                                                   and chk-slip-string.RRN = p-RRN
                                                                   and chk-slip-string.str-num < 10000
                                                                   by chk-slip-string.str-num
                                                                   .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-print br-chk-slip-string
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
