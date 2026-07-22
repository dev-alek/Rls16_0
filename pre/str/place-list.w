define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter p-obj-type  as character no-undo.
define input parameter p-obj-code  as integer   no-undo.
define input parameter p-gds-code  as integer   no-undo.
define input-output parameter p-list-tank as character no-undo.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_place for ub.place.
define temp-table tt-pl
  field pl-code as integer label "Место хранения"
  field pl-name as character label "Название"
  field pl-coord as character label "Коорд1".
DEFINE BUTTON btn_cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 7 BY 1.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 6 BY 1
     BGCOLOR 8 .
DEFINE BUTTON btn_mark
     LABEL "*"
     SIZE 3 BY 1.
DEFINE QUERY BROWSE-2 FOR
      tt-pl SCROLLING.
DEFINE BROWSE BROWSE-2
    QUERY BROWSE-2 DISPLAY
  tt-pl.pl-code format "99999999999"
  tt-pl.pl-name
  tt-pl.pl-coord
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53 BY 10
         TITLE "Места хранения по линии накладной" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.08 COL 1.63
     btn_cancel AT ROW 1.08 COL 10.88 WIDGET-ID 2
     BROWSE-2 AT ROW 2.25 COL 1.5 WIDGET-ID 200
     SPACE(0.49) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Места хранения"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON choose OF Btn_ok IN FRAME Dialog-Frame
do:
  p-list-tank = "".
  p-list-tank = left-trim (tt-pl.pl-coord).
  end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  for each buf_pl-gds no-lock where buf_pl-gds.obj-type = p-obj-type
                                and buf_pl-gds.obj-code = p-obj-code
                                and buf_pl-gds.gds-code = p-gds-code
                                :
    find first buf_place no-lock where buf_place.obj-type = buf_pl-gds.obj-type
                                   and buf_place.obj-code = buf_pl-gds.obj-code
                                   and buf_place.pl-code  = buf_pl-gds.pl-code
                                   and buf_place.status_  = ""
                                   no-error.
    if available buf_place
    then do :
      create tt-pl.
      assign
        tt-pl.pl-code  = buf_place.pl-code
        tt-pl.pl-name  = buf_place.pl-name
        tt-pl.pl-coord = buf_place.loc1
      .
    end .
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_OK btn_mark btn_cancel BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH tt-pl.
END PROCEDURE.
