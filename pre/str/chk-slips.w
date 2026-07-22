define input parameter p-db-num as integer no-undo .
define input parameter p-CheckId as character no-undo .
define input parameter p-RRN as character no-undo .
define variable print-type as character no-undo.
define buffer chk-slip-head for ub.chk-slip-head .
function func-proc-type returns character
(input v-int-type as integer):
  case v-int-type :
    when 1 then return "Банковский" .
    when 2 then return "Лояльность" .
    when 3 then return "Топливный" .
    otherwise return " - " .
  end case .
end function .
DEFINE MENU MENU-B-print
       MENU-ITEM m_one         LABEL "Текущий"
       MENU-ITEM m_all         LABEL "Все"  .
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "Сохранить в файл"
     SIZE 17 BY 1.14
     BGCOLOR 8 .
define query br-chk-slip-head for chk-slip-head scrolling .
define browse br-chk-slip-head
  query br-chk-slip-head display
  chk-slip-head.ID
  func-proc-type(chk-slip-head.proc-type) label "Тип процессинга"
  chk-slip-head.RRN
WITH SEPARATORS SIZE 70 BY 6 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.1 COL 2
     b-print AT ROW 1.1 COL 18.8 WIDGET-ID 2
     br-chk-slip-head at row 2.3 col 2
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Слипы"
         CANCEL-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON RETURN OF br-chk-slip-head IN FRAME Dialog-Frame
OR mouse-select-dblclick of br-chk-slip-head in frame Dialog-Frame
do:
  if not available chk-slip-head
  then do :
    return no-apply .
  end .
  run str/chk-slip.w (input chk-slip-head.db-num,
                      input chk-slip-head.ID,
                      input chk-slip-head.CheckID,
                      input chk-slip-head.RRN)
                      .
end.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  if not available chk-slip-head
  then do :
    return no-apply .
  end .
  if print-type = "" then do:
    run gbl/pop-up.p ( input b-print:handle, input no) no-error.
    if error-status:error then return no-apply.
  end.
  if print-type = "" then return no-apply.
  run str/chk-slip-print.p (input chk-slip-head.db-num,
                            input chk-slip-head.ID,
                            input chk-slip-head.CheckID,
                            input chk-slip-head.RRN,
                            input print-type)
                            .
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
    print-type = "one":U.
    apply "choose" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_all
DO:
    if p-RRN = ?
    then do :
      print-type = "all":U.
    end .
    else do :
      print-type = "all_pay":U.
    end .
    apply "choose" to b-print in frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  b-print:MENU-MOUSE = 1 .
  if p-RRN = ?
  then do :
    find first chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                       and chk-slip-head.CheckID = p-CheckId
                                       and chk-slip-head.is-report = 0
                                       no-error.
    if not available chk-slip-head
    then do :
      message "Слипы не найдены!" view-as alert-box .
      return .
    end .
  end .
  else do :
    find first chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                       and chk-slip-head.CheckID = p-CheckId
                                       and chk-slip-head.RRN = p-RRN
                                       and chk-slip-head.is-report = 0
                                       no-error.
    if not available chk-slip-head
    then do :
      message "Слипы не найдены!" view-as alert-box .
      return .
    end .
  end .
  RUN enable_UI.
  if p-RRN = ?
  then do :
    open query br-chk-slip-head for each chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                                                 and chk-slip-head.CheckID = p-CheckId
                                                                 and chk-slip-head.is-report = 0 .
  end .
  else do :
    open query br-chk-slip-head for each chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                                                 and chk-slip-head.CheckID = p-CheckId
                                                                 and chk-slip-head.RRN = p-RRN
                                                                 and chk-slip-head.is-report = 0
                                                                 .
  end .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-print br-chk-slip-head
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
