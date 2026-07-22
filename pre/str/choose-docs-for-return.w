define input parameter p-reason as integer no-undo .
define input parameter p-is-edo as logical no-undo .
define input parameter in-doc-code as character no-undo .
define output parameter p-doc-code as character no-undo .
define temp-table tt-trn-doc no-undo like ub.trn-doc .
define buffer buf_trn-doc for tt-trn-doc .
define buffer in_trn-doc for ub.trn-doc .
define buffer chs_trn-doc for ub.trn-doc .
define buffer buf_utd for ub.utd .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выбор"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE QUERY br-docs FOR
      buf_trn-doc SCROLLING.
DEFINE BROWSE br-docs
  QUERY br-docs NO-LOCK DISPLAY
      buf_trn-doc.status_ FORMAT "X(8)":U WIDTH 8.2
      buf_trn-doc.flag_ FORMAT "+/-":U
      buf_trn-doc.doc-code FORMAT "X(14)":U
      buf_trn-doc.doc-date FORMAT "99/99/99":U
      buf_trn-doc.fact-date FORMAT "99/99/99":U
      buf_trn-doc.shift-date FORMAT "99/99/99":U
      buf_trn-doc.shift-name FORMAT "X(2)":U
      buf_trn-doc.cli-name FORMAT "X(40)":U
      buf_trn-doc.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
      buf_trn-doc.fact-qnty FORMAT "->>,>>>,>>9.<<<":U
      buf_trn-doc.tot-doc FORMAT "->>>,>>>,>>9.99":U
      buf_trn-doc.tot-fact FORMAT "->>>,>>>,>>9.99":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 14.05 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1.24 COL 2
     Btn_OK AT ROW 1.24 COL 17
     br-docs AT ROW 2.91 COL 3 WIDGET-ID 200
     SPACE(2.19) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выберите документ-источник"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
  if not available buf_trn-doc
  then return no-apply .
  p-doc-code = buf_trn-doc.doc-code .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run fill-tt .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure fill-tt :
  empty temp-table tt-trn-doc .
  find first in_trn-doc no-lock where in_trn-doc.doc-code = in-doc-code .
  for each chs_trn-doc no-lock where chs_trn-doc.cli-type = in_trn-doc.cli-type
                                 and chs_trn-doc.cli-code = in_trn-doc.cli-code
                                 and chs_trn-doc.host-code = in_trn-doc.host-code
                                 and chs_trn-doc.ext-doc-type = "ie"
                                 and chs_trn-doc.contract-code = in_trn-doc.contract-code
                                 and chs_trn-doc.status_ = "факт"
                                 :
    if p-is-edo
    then do :
      if p-reason = 23
      then do :
        create tt-trn-doc.
        buffer-copy chs_trn-doc to tt-trn-doc .
      end .
      if p-reason = 25
      then do :
        if can-find(first buf_utd no-lock where buf_utd.doc-code = chs_trn-doc.doc-code)
        then do :
          create tt-trn-doc.
          buffer-copy chs_trn-doc to tt-trn-doc .
        end .
      end .
    end .
    else do :
      if not can-find(first buf_utd no-lock where buf_utd.doc-code = chs_trn-doc.doc-code)
      then do :
        create tt-trn-doc.
        buffer-copy chs_trn-doc to tt-trn-doc .
      end .
    end .
  end .
end procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_Cancel Btn_OK br-docs
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-docs FOR EACH buf_trn-doc no-lock by buf_trn-doc.fact-date desc INDEXED-REPOSITION.
END PROCEDURE.
