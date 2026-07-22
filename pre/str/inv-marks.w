using ibs.th.str.alcohol.*.
define temp-table tt-marks
    field exciseMark   as character label "Марка"    format "X(150)"
    field alc-code     as character label "Алк. код" format "X(20)"
    field artic        as character label "Артикл"   format "X(20)"
    field prod-type    as character
    field prod-code    as integer
    field gds-code     as integer
    field doc-code     as character
    field partID       as character
    field refB         as character
    field rowid-part   as rowid
    field line-num     as integer
    field isCurr       as logical
    index pi as primary unique
        exciseMark
.
define temp-table tt-alc-qnty
    field artic        as character label "Артикл"   format "X(20)"
    field prod-type    as character
    field prod-code    as integer
    field gds-code     as integer
    field alc-code     as character label "Алк. код" format "X(20)"
    field qnty         as integer   label "Кол."
    field isCurr       as logical
    index pi as primary unique
        artic prod-type prod-code alc-code
.
define temp-table TempTrnDoc no-undo
  field line-num     as integer
  field ext-doc-code as character
  field doc-date     as date
  field ext-doc-type as character
  field cli-type     as character
  field cli-code     as integer
  field obj-type     as character
  field obj-code     as integer
  field ps           as character
  field Status_      as character
  field Flags_       as integer
  index pi line-num ext-doc-code .
define temp-table TempDocLine no-undo
  field line-num     as integer
  field gds-code     as integer
  field doc-qnty     as decimal
  field fact-qnty    as decimal
  field price-rubl   as decimal
  field RowSum       as decimal
  field vat-pc       as decimal
  field b-code       as character
  field is-tsd-qnty  as logical   init no
  field aclMarksList as character
  field PartIDTH     as character
  field Flags_       as integer
  field NotDict      as logical
  index pi
  line-num
  gds-code
  .
define temp-table TempDocLineIsTSD like TempDocLine.
define temp-table TempDocLineTSD no-undo
  field gds-code     as integer
  field doc-qnty     as decimal
  field fact-qnty    as decimal
  field artic        as character
  field prod-code    as integer
  field prod-type    as character
  field Flags_error  as logical
  field mark-type    as character
  field mark         as character
  field mark-parent  as character
  index pi
  artic
  prod-code
  prod-type
  mark
  .
define temp-table TempMarkLine no-undo
  field DocName    as character
  field MarkCode   as character
  field PartIDTH   as character
  field Sts        as character
  field MarkParent as character
  field QntyBox    as character
  index pi
  DocName
  MarkCode
  .
  define temp-table TempTSDSetting no-undo
  field sn   as character
  field obj-code  as integer
  field obj-type as character
  field version_ as character
  field lastDate as datetime
  index pi
  sn
  .
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-trn-code as character no-undo.
define input parameter p-recid as recid no-undo.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_parts for ub.parts.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds for ub.goods.
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
define variable excMarks as class excisemarks no-undo.
define new shared variable g#auto-user-id as character no-undo .
define new shared variable g#LogStr       as character no-undo .
DEFINE BUTTON btn_accept
     LABEL "Сохр."
     SIZE 6 BY 1.
DEFINE BUTTON btn_imp
     LABEL "Импорт"
     SIZE 7 BY 1.
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выход"
     SIZE 6 BY 1
     BGCOLOR 8 .
DEFINE QUERY BROWSE-2 FOR
      tt-alc-qnty SCROLLING.
DEFINE QUERY BROWSE-5 FOR
      tt-alc-qnty SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 DISPLAY
  tt-alc-qnty.artic
  tt-alc-qnty.alc-code
  tt-alc-qnty.qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53 BY 23.5
         TITLE "Импортировано" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-5
  QUERY BROWSE-5 DISPLAY
  tt-alc-qnty.artic
  tt-alc-qnty.alc-code
  tt-alc-qnty.qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53 BY 23.5
         TITLE "Текущее состояние" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.08 COL 1.25
     btn_accept AT ROW 1.08 COL 7.25 WIDGET-ID 2
     btn_imp AT ROW 1.08 COL 13.5 WIDGET-ID 4
     BROWSE-2 AT ROW 2.25 COL 1.5 WIDGET-ID 200
     BROWSE-5 AT ROW 2.25 COL 55.5 WIDGET-ID 300
     SPACE(0.49) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Марки по партии."
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF btn_accept IN FRAME Dialog-Frame
DO:
  define variable v-ok-doc as integer no-undo.
  define variable isClear  as logical no-undo.
  find first buf_trn-doc where buf_trn-doc.doc-code = p-trn-code no-lock.
  create TempTrnDoc.
  assign
    TempTrnDoc.doc-date = buf_trn-doc.doc-date
    TempTrnDoc.ext-doc-type = buf_trn-doc.ext-doc-type
    TempTrnDoc.ext-doc-code = buf_trn-doc.doc-code
    TempTrnDoc.cli-type = ""
    TempTrnDoc.cli-code = -2
    TempTrnDoc.obj-type = buf_trn-doc.obj-type
    TempTrnDoc.obj-code = buf_trn-doc.obj-code
    TempTrnDoc.ps = string (isClear)
  .
  for each buf_doc-line no-lock where buf_doc-line.doc-code = p-trn-code:
    find first buf_gds no-lock where buf_gds.artic = buf_doc-line.artic
      and buf_gds.prod-type = buf_doc-line.prod-type
      and buf_gds.prod-code = buf_doc-line.prod-code
    .
    create TempDocLine.
    assign
      TempDocLine.line-num  = buf_doc-line.line-num
      TempDocLine.gds-code  = buf_gds.gds-code
      TempDocLine.fact-qnty = buf_doc-line.fact-qnty
      .
  end.
  run ibs/th/skt/Adapters/AdapteeProcOra-i506.p
    (
      table TempTrnDoc,
      table TempDocLine,
      table tt-marks,
      v-cntxt-userid
    ) no-error.
  if error-status:error
  then do:
    message "Ошикба: " return-value view-as alert-box error.
  end.
END.
ON CHOOSE OF btn_imp IN FRAME Dialog-Frame
DO:
  run str/imp-marks-temp.p (output table tt-marks, output table tt-alc-qnty, p-trn-code).
  OPEN QUERY BROWSE-2 FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = false.    OPEN QUERY BROWSE-5 FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = true.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  excMarks = new excisemarks (v-cntxt-obj-type, v-cntxt-obj-code).
  if p-recid = ?
  then do:
    for each buf_doc-line where buf_doc-line.doc-code = p-trn-code:
      for each buf_parts no-lock where
        buf_parts.obj-type = buf_doc-line.obj-type and
        buf_parts.obj-code = buf_doc-line.obj-code and
        buf_parts.artic = buf_doc-line.artic and
        buf_parts.prod-type = buf_doc-line.prod-type and
        buf_parts.prod-code = buf_doc-line.prod-code and
        buf_parts.out-code = buf_doc-line.doc-code:
        excMarks:GetTableMarksForPartsAppend(buffer buf_parts, input-output table tt-marks).
      end.
    end.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_OK btn_accept btn_imp BROWSE-2 BROWSE-5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = false.    OPEN QUERY BROWSE-5 FOR EACH tt-alc-qnty where tt-alc-qnty.isCurr = true.
END PROCEDURE.
