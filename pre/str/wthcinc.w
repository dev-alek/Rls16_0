DEFINE BUFFER buf_c-wth-line FOR ub.c-wth-line.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_deliver FOR ub.clients.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_operator FOR ub.clients.
DEFINE BUFFER buf_receiver FOR ub.clients.
DEFINE BUFFER buf_wth FOR ub.wealth.
DEFINE BUFFER current-place FOR ub.wth-place.
DEFINE BUFFER first_c-wth-line FOR ub.c-wth-line.
DEFINE BUFFER out-place FOR ub.wth-place.
DEFINE TEMP-TABLE tt-c-wth-doc NO-UNDO LIKE ub.c-wth-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter parcli-type like ub.clients.obj-type no-undo.
define input parameter parcli-code like ub.clients.obj-code no-undo.
define input parameter par-type AS CHARACTER NO-UNDO.
define input parameter parauto-fill like ub.c-wth-doc.auto-fill no-undo .
define input-output parameter p-doc-rec     as recid no-undo .
define input parameter p-call-prog  as handle no-undo .
define input-output parameter p-next-prev as character no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "перемещение МЦ: добавление, изменение, просмотр":U.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define buffer bf_c-wth-doc for ub.c-wth-doc.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE v_rid      AS CHAR NO-UNDO.
DEFINE VARIABLE l-shift-on AS LOG  NO-UNDO.
DEFINE VARIABLE lock-doc as logical no-undo.
DEFINE VARIABLE locked-out as logical no-undo .
DEFINE VARIABLE locked-current as logical no-undo .
DEFINE VARIABLE locked-inter_ as logical no-undo .
DEFINE VARIABLE locked-cli as logical no-undo .
define buffer auto-c-wth-doc-lock_batchprocess for ub.batchprocess .
define buffer bind_c-wth-doc for ub.c-wth-doc.
define buffer bind_inkas for ub.inkas.
DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (рубл)"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(рубл)"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
 .
DEFINE BUTTON B-chk
     LABEL "Че&ки"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE for-current-w-p-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Место"
      VIEW-AS TEXT
     SIZE 10 BY .67 NO-UNDO.
DEFINE VARIABLE for-current-w-p-name AS CHARACTER FORMAT "X(20)"
      VIEW-AS TEXT
     SIZE 21.1 BY 1 NO-UNDO.
DEFINE VARIABLE for-deliver AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-object AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-operator AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-out-w-p-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
     LABEL "Место"
      VIEW-AS TEXT
     SIZE 10 BY .67 NO-UNDO.
DEFINE VARIABLE for-out-w-p-name AS CHARACTER FORMAT "X(20)"
      VIEW-AS TEXT
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE for-receiver AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 24.5 BY 1 NO-UNDO.
DEFINE QUERY BR-lines FOR
      buf_c-wth-line,
      buf_wth SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-c-wth-doc,
      buf_obj,
      buf_clients,
      first_c-wth-line,
      out-place,
      buf_operator,
      buf_deliver,
      buf_receiver SCROLLING.
DEFINE BROWSE BR-lines
  QUERY BR-lines NO-LOCK DISPLAY
      buf_c-wth-line.wth-code FORMAT ">>>>>>>>9":U
      buf_wth.wth-name FORMAT "X(40)":U
      buf_c-wth-line.doc-sum FORMAT "->,>>>,>>>,>>9.99":U
      buf_c-wth-line.fact-sum FORMAT "->,>>>,>>>,>>9.99":U
      buf_c-wth-line.sum-gds-rubl FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Сумма по связ. тов. (rub.)'
      buf_c-wth-line.sum-gds-base FORMAT "->,>>>,>>>,>>9.99":U COLUMN-LABEL 'Сумма по связ. тов. (б.в.)'
      buf_c-wth-line.credate FORMAT "99/99/99":U
      buf_c-wth-line.creid FORMAT "X(16)":U
  ENABLE
      buf_c-wth-line.creid
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.1 BY 7.27.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-prev AT ROW 1 COL 40
     B-next AT ROW 1 COL 44.1
     B-Help AT ROW 1 COL 95
     tt-c-wth-doc.obj-type AT ROW 3.77 COL 14 COLON-ALIGNED
          LABEL "Объект"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6 BY 1
     tt-c-wth-doc.cli-type AT ROW 5.27 COL 14 COLON-ALIGNED
          LABEL "Контрагент"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 6 BY 1
     BR-lines AT ROW 12.87 COL 1
     B-lookup AT ROW 20.27 COL 1
     B-chk AT ROW 20.27 COL 11
     tt-c-wth-doc.corr-user-name AT ROW 1 COL 65.5 COLON-ALIGNED
          LABEL "Корр."
           VIEW-AS TEXT
          SIZE 12 BY .67
          FGCOLOR 12
     tt-c-wth-doc.corr-date AT ROW 1.03 COL 82 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 12
     tt-c-wth-doc.doc-code AT ROW 2.5 COL 7.3 COLON-ALIGNED
          LABEL "Номер"
           VIEW-AS TEXT
          SIZE 16.1 BY .67
          FGCOLOR 4
     tt-c-wth-doc.doc-date AT ROW 2.5 COL 29 COLON-ALIGNED
          LABEL "Дата"
           VIEW-AS TEXT
          SIZE 10 BY .67
     tt-c-wth-doc.fact-date AT ROW 2.5 COL 48.4 COLON-ALIGNED
          LABEL "Факт"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-date AT ROW 2.5 COL 65.5 COLON-ALIGNED
          LABEL "Смена"
           VIEW-AS TEXT
          SIZE 10 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-name AT ROW 2.5 COL 82 COLON-ALIGNED
          LABEL "№"
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-c-wth-doc.shift-num AT ROW 2.5 COL 92 COLON-ALIGNED
          LABEL "П."
           VIEW-AS TEXT
          SIZE 4 BY .67
          FGCOLOR 4
     tt-c-wth-doc.obj-code AT ROW 3.77 COL 21 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 7.5 BY .67
     for-object AT ROW 3.77 COL 29 COLON-ALIGNED NO-LABEL
     for-current-w-p-code AT ROW 3.77 COL 65.5 COLON-ALIGNED
     for-current-w-p-name AT ROW 3.77 COL 76 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.cli-name AT ROW 5.07 COL 29 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 24.5 BY 1
     for-out-w-p-code AT ROW 5.07 COL 65.5 COLON-ALIGNED
     for-out-w-p-name AT ROW 5.07 COL 76 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.cli-code AT ROW 5.27 COL 21 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.8 BY .67
     tt-c-wth-doc.fact-sum AT ROW 6.5 COL 65.5 COLON-ALIGNED
          LABEL "Кол-во факт"
           VIEW-AS TEXT
          SIZE 24.1 BY .67
     tt-c-wth-doc.doc-sum AT ROW 6.77 COL 21 COLON-ALIGNED
          LABEL "Кол-во по документу"
           VIEW-AS TEXT
          SIZE 18.4 BY .67
     tt-c-wth-doc.sum-gds-rubl AT ROW 8 COL 27 COLON-ALIGNED WIDGET-ID 4
          LABEL "Сумма по тов. (abbr_rubl.)"
           VIEW-AS TEXT
          SIZE 14 BY .67
     tt-c-wth-doc.sum-gds-base AT ROW 8 COL 65.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "Сумма по тов.(баз. вал)" FORMAT "->>>,>>>,>>9.99"
           VIEW-AS TEXT
          SIZE 14 BY .67
     tt-c-wth-doc.operator AT ROW 9.27 COL 14 COLON-ALIGNED
          LABEL "Составил"
           VIEW-AS TEXT
          SIZE 12.3 BY .67
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     for-operator AT ROW 9.27 COL 29 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.deliver AT ROW 10.43 COL 14 COLON-ALIGNED
          LABEL "Передал"
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     for-deliver AT ROW 10.5 COL 29 COLON-ALIGNED NO-LABEL
     for-receiver AT ROW 11.5 COL 29 COLON-ALIGNED NO-LABEL
     tt-c-wth-doc.receiver AT ROW 11.57 COL 14 COLON-ALIGNED
          LABEL "Получил"
           VIEW-AS TEXT
          SIZE 12.3 BY .67
     SPACE(71.57) SKIP(9.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ движения материальных ценностей: история"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  p-next-prev = "QUIT".
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-chk IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE loc-ref-list as character no-undo.
  DEFINE VARIABLE var-doc-code like ub.c-wth-doc.doc-code no-undo .
  if tt-c-wth-doc.borned then do:
    assign
    var-doc-code = tt-c-wth-doc.source-ref.
  end.
  else do:
    var-doc-code = tt-c-wth-doc.doc-code.
  end.
  run str/chk-docs.w (
                 input parparentproc
                ,input '':U
                ,input 'out-code':U
                ,input ?
                ,input parobj-type
                ,input parobj-code
                ,input var-doc-code
                ,input ''
                ,input 0
                ,input ?
                ,input ?
                ,input 0
                ,output loc-ref-list) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame
DO:
define variable v-doc-rec as recid no-undo .
define variable v-line-rec as recid no-undo .
 if not avail buf_c-wth-line then return no-apply.
  ASSIGN
  v-line-rec = RECID( buf_c-wth-line )
  v-doc-rec = recid(bf_c-wth-doc)
  FOR-CURRENT-W-P-CODE
  FOR-OUT-W-P-CODE
  .
  run str/wthcinca.w (input parparentproc,
                  INPUT 'ПРОСМОТР':U,
                  input v-doc-rec,
                  input for-current-w-p-code,
                  input for-out-w-p-code,
                  input-output v-LINE-REC,
                  INPUT tt-c-wth-doc.doc-type ) no-error.
  apply "entry" to br-lines.
END.
ON CHOOSE OF B-next IN FRAME Dialog-Frame
DO:
     run reposition-c-wth-doc in this-procedure
  (input 'next':U
  ) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-prev IN FRAME Dialog-Frame
DO:
   run reposition-c-wth-doc in this-procedure
  (input 'prev':U
  ) no-error .
if error-status:error then return no-apply.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
    p-next-prev = "QUIT".
END.
ON VALUE-CHANGED OF tt-c-wth-doc.cli-type IN FRAME Dialog-Frame
DO:
 run control-out in this-procedure.
 FIND FIRST buf_clients NO-LOCK WHERE
          buf_clients.obj-type = INPUT FRAME Dialog-Frame tt-c-wth-doc.cli-type AND
          buf_clients.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.cli-code NO-ERROR.
IF AVAIL buf_clients THEN DO:
    DISPLAY
    buf_clients.obj-name @ tt-c-wth-doc.cli-name WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF tt-c-wth-doc.deliver IN FRAME Dialog-Frame
DO:
      FIND FIRST buf_deliver NO-LOCK WHERE
            buf_deliver.obj-type = 'чел':U AND
            buf_deliver.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.deliver NO-ERROR.
  IF AVAIL buf_deliver THEN DO:
    DISPLAY
    buf_deliver.obj-name @ for-deliver
        WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF for-current-w-p-code IN FRAME Dialog-Frame
DO:
    FIND FIRST current-place NO-LOCK WHERE
            current-place.host-code = tt-c-wth-doc.host-code AND
            current-place.obj-type = tt-c-wth-doc.obj-type      AND
            current-place.obj-code = tt-c-wth-doc.obj-code      AND
            current-place.w-p-code = INPUT FRAME Dialog-Frame for-current-w-p-code NO-ERROR.
  IF AVAIL current-place THEN DO:
    DISPLAY
    current-place.w-p-name @ for-current-w-p-name
    WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF for-out-w-p-code IN FRAME Dialog-Frame
DO:
    FIND FIRST out-place NO-LOCK WHERE
            out-place.host-code = tt-c-wth-doc.host-code AND
            out-place.obj-type = tt-c-wth-doc.obj-type AND
            out-place.obj-code = tt-c-wth-doc.obj-code AND
            out-place.w-p-code = INPUT FRAME Dialog-Frame for-out-w-p-code NO-ERROR.
  IF AVAIL out-place THEN DO:
    DISPLAY
    out-place.w-p-name @ for-out-w-p-name
        WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF tt-c-wth-doc.operator IN FRAME Dialog-Frame
DO:
    FIND FIRST buf_operator NO-LOCK WHERE
            buf_operator.obj-type = 'чел':U AND
            buf_operator.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.operator NO-ERROR.
  IF AVAIL buf_operator THEN DO:
    DISPLAY
    buf_operator.obj-name @ for-operator
    WITH FRAME Dialog-Frame.
  END.
END.
ON LEAVE OF tt-c-wth-doc.receiver IN FRAME Dialog-Frame
DO:
    FIND FIRST buf_receiver NO-LOCK WHERE
            buf_receiver.obj-type = 'чел':U AND
            buf_receiver.obj-code = INPUT FRAME Dialog-Frame tt-c-wth-doc.receiver NO-ERROR.
  IF AVAIL buf_receiver THEN DO:
    DISPLAY
    buf_receiver.obj-name @ for-receiver
    WITH FRAME Dialog-Frame.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-lines :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
p-next-prev = "":U.
n-p: do while p-next-prev = '':U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if par-mode <> 'ПРОСМОТР':U then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова par-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if not par-mode = 'ПРОСМОТР':U then
    p-next-prev = "QUIT".
    find first ub.sysconf No-LOCK WHERE
                     ub.sysconf.host-code = parhost-code No-ERROR.
    if not avail ub.sysconf then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parhost-code"
            view-as alert-box ERROR.
            return error.
    end.
    find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = parobj-type AND
                ub.clients.obj-code = parobj-code No-ERROR.
    if not avail ub.clients then do:
        message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова parobj-type/parobj-code"
            view-as alert-box ERROR.
            return error.
    end.
    if parcli-type <> '':U or parcli-code <> 0 then do:
        find first ub.clients No-LOCK WHERE
                    ub.clients.obj-type = parcli-type AND
                    ub.clients.obj-code = parcli-code No-ERROR.
        if not avail ub.clients then do:
            message vss-workfile vss-revision vss-description skip
                            "Неверный параметр вызова parcli-type/parcli-code"
                view-as alert-box ERROR.
                return error.
        end.
    end.
    if LOOKUP(par-type, "при,рас,спи") = 0 then do:
            message vss-workfile vss-revision vss-description skip
                            "Неверный параметр вызова par-type"
                view-as alert-box ERROR.
                return error.
    end.
    tt-c-wth-doc.cli-type:list-items = 'орг':U + chr(44) +
                                    'чел':U + chr(44) +
                                    'маг':U + chr(44) +
                                    'скл':U + chr(44).
    tt-c-wth-doc.obj-type:list-items = 'орг':U + chr(44) +
                                    'чел':U + chr(44) +
                                    'маг':U + chr(44) +
                                    'скл':U + chr(44).
  Run fill-tables no-error.
  if error-status:error then return error.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
end.
RUN disable_UI.
PROCEDURE control-line :
DEFINE OUTPUT PARAMETER lock-doc as logical no-undo.
IF CAN-FIND(FIRST ub.c-wth-line No-LOCK WHERE
                  ub.c-wth-line.doc-code = tt-c-wth-doc.doc-code
              AND ub.c-wth-line.chip-num = tt-c-wth-doc.chip-num
              AND ub.c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num
              ) then
lock-doc = yes.
else lock-doc = no.
END PROCEDURE.
PROCEDURE control-out :
 IF INPUT FRAME Dialog-Frame tt-c-wth-doc.cli-type = 'чел':U   OR
    INPUT FRAME Dialog-Frame tt-c-wth-doc.cli-type = 'орг':U THEN DO:
    DISABLE
    for-out-w-p-code
    WITH FRAME Dialog-Frame.
    HIDE
    for-out-w-p-code IN FRAME Dialog-Frame
    for-out-w-p-name IN FRAME Dialog-Frame
    .
    locked-out = yes.
  END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-c-wth-doc SHARE-LOCK,              EACH buf_obj WHERE buf_obj.obj-type = tt-c-wth-doc.obj-type   AND buf_obj.obj-code = tt-c-wth-doc.obj-code SHARE-LOCK,              EACH buf_clients WHERE buf_clients.obj-type = tt-c-wth-doc.cli-type   AND buf_clients.obj-code = tt-c-wth-doc.cli-code SHARE-LOCK,              EACH first_c-wth-line WHERE first_c-wth-line.doc-code = tt-c-wth-doc.doc-code   AND first_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num   AND first_c-wth-line.chip-num = tt-c-wth-doc.chip-num SHARE-LOCK,              EACH out-place WHERE out-place.w-p-code = first_c-wth-line.out-code SHARE-LOCK,              EACH buf_operator WHERE buf_operator.obj-code = tt-c-wth-doc.operator   AND buf_operator.obj-type = 'чел':U SHARE-LOCK,              EACH buf_deliver WHERE buf_deliver.obj-code = tt-c-wth-doc.deliver   AND buf_deliver.obj-type = 'чел':U SHARE-LOCK,              EACH buf_receiver WHERE buf_receiver.obj-code = tt-c-wth-doc.receiver   AND buf_receiver.obj-type = 'чел':U SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY for-object for-current-w-p-code for-current-w-p-name for-out-w-p-code
          for-out-w-p-name for-operator for-deliver for-receiver
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-wth-doc THEN
    DISPLAY tt-c-wth-doc.obj-type tt-c-wth-doc.cli-type
          tt-c-wth-doc.corr-user-name tt-c-wth-doc.corr-date
          tt-c-wth-doc.doc-code tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date
          tt-c-wth-doc.shift-date tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num
          tt-c-wth-doc.obj-code tt-c-wth-doc.cli-name tt-c-wth-doc.cli-code
          tt-c-wth-doc.fact-sum tt-c-wth-doc.doc-sum tt-c-wth-doc.sum-gds-rubl
          tt-c-wth-doc.sum-gds-base tt-c-wth-doc.operator tt-c-wth-doc.deliver
          tt-c-wth-doc.receiver
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-prev B-next B-Help BR-lines B-lookup B-chk
         tt-c-wth-doc.corr-user-name tt-c-wth-doc.corr-date
         tt-c-wth-doc.doc-date tt-c-wth-doc.fact-date tt-c-wth-doc.shift-date
         tt-c-wth-doc.shift-name tt-c-wth-doc.shift-num tt-c-wth-doc.obj-code
         for-object for-current-w-p-code for-current-w-p-name
         tt-c-wth-doc.cli-name for-out-w-p-code for-out-w-p-name
         tt-c-wth-doc.cli-code tt-c-wth-doc.fact-sum tt-c-wth-doc.doc-sum
         tt-c-wth-doc.sum-gds-rubl tt-c-wth-doc.sum-gds-base
         tt-c-wth-doc.operator for-operator tt-c-wth-doc.deliver for-deliver
         for-receiver tt-c-wth-doc.receiver
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
for each tt-c-wth-doc:
    delete tt-c-wth-doc.
end.
  if par-mode = 'ПРОСМОТР':U then do:
    FIND FIRST bf_c-wth-doc NO-LOCK WHERE
                recid(bf_c-wth-doc) = p-doc-rec.
  end.
  IF NOT AVAIL bf_c-wth-doc then
  return error.
  if bf_c-wth-doc.status_ = 'факт':U and par-mode <> 'ПРОСМОТР':U then do:
     message "Документ движения МЦ с N" bf_c-wth-doc.doc-code  "имеет статус" bf_c-wth-doc.status_ SKIP
                      "Изменения не допускаются"
        view-as alert-box error.
        return error.
    end.
  create tt-c-wth-doc.
  buffer-copy bf_c-wth-doc to tt-c-wth-doc.
    FIND FIRST buf_obj No-LOCK WHERe
                buf_obj.obj-type = tt-c-wth-doc.obj-type AND
                buf_obj.obj-code = tt-c-wth-doc.obj-code No-ERROR.
    if not avail buf_obj then do:
      message "Документ движения МЦ N" bf_c-wth-doc.doc-code  skip
              "Неверный объект" bf_c-wth-doc.obj-type bf_c-wth-doc.obj-code
      view-as alert-box ERROR.
      return error.
    end.
    FIND FIRST buf_clients No-LOCK WHERe
                buf_clients.obj-type = tt-c-wth-doc.cli-type AND
                buf_clients.obj-code = tt-c-wth-doc.cli-code No-ERROR.
    if not avail buf_clients then do:
      message "Документ движения МЦ N" bf_c-wth-doc.doc-code  skip
              "Неверный контрагент" bf_c-wth-doc.cli-type bf_c-wth-doc.cli-code
      view-as alert-box ERROR.
      return error.
    end.
    FIND FIRST buf_operator No-LOCK WHERe
                        buf_operator.obj-type = 'чел':U AND
                        buf_operator.obj-code = tt-c-wth-doc.operator No-ERROR.
    FIND FIRST buf_deliver No-LOCK WHERe
                        buf_deliver.obj-type = 'чел':U AND
                        buf_deliver.obj-code = tt-c-wth-doc.deliver No-ERROR.
    FIND FIRST buf_receiver No-LOCK WHERe
                        buf_receiver.obj-type = 'чел':U AND
                        buf_receiver.obj-code = tt-c-wth-doc.receiver No-ERROR.
    FIND FIRST buf_c-wth-line No-LOCK where
               BUF_c-wth-line.DOC-CODE = TT-c-wth-doc.doc-code
          AND buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num
          AND buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num
               nO-ERROR.
    if avail buf_c-wth-line then do:
      find first current-place No-LOCK WHERE
                    current-place.w-p-code = buf_c-wth-line.w-p-code NO-ERROR.
      if avail current-place then
      assign
      for-current-w-p-code = current-place.w-p-code
      for-current-w-p-name = current-place.w-p-name
      .
      find first out-place No-LOCK WHERE
                    out-place.w-p-code = buf_c-wth-line.out-code NO-ERROR.
      if avail out-place then
      assign
      for-out-w-p-code = out-place.w-p-code
      for-out-w-p-name = out-place.w-p-name
      .
    end.
    CASE tt-c-wth-doc.source-type:
      when 'док.МЦ':U then do:
        FIND FIRST bind_c-wth-doc NO-LOCK WHERE
                   bind_c-wth-doc.doc-code = tt-c-wth-doc.source-ref NO-ERROR.
      end.
      when 'касса':U then do:
        FIND FIRST bind_inkas NO-LOCK WHERE
                   bind_inkas.inkas-code = tt-c-wth-doc.source-ref NO-ERROR.
      end.
    END CASE.
END PROCEDURE.
PROCEDURE lock-proc :
DEFINE INPUT PARAMETER lock-doc as logical no-undo.
if lock-doc then do:
    DISABLE
    tt-c-wth-doc.cli-type
    tt-c-wth-doc.cli-code
    for-current-w-p-code
    for-out-w-p-code
    with frame Dialog-Frame
    .
end.
END PROCEDURE.
PROCEDURE MyEnable :
assign
buf_c-wth-line.sum-gds-rubl:label in browse br-lines = "Сумма по связ. тов. (рубл.)".
 buf_c-wth-line.creid:READ-ONLY IN BROWSE BR-lines = YES.
 IF AVAILABLE buf_clients and par-mode = 'ДОБАВЛЕНИЕ':U THEN dO:
    DISPLAY buf_clients.obj-name @ tt-c-wth-doc.cli-name
      WITH FRAME Dialog-Frame.
  end.
  else
  display
  tt-c-wth-doc.cli-name
  with frame Dialog-Frame.
  IF AVAILABLE buf_deliver THEN
    DISPLAY buf_deliver.obj-name @ for-deliver
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_obj THEN
    DISPLAY buf_obj.obj-name @ for-object
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_operator THEN
    DISPLAY buf_operator.obj-name @ for-operator
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_receiver THEN
    DISPLAY buf_receiver.obj-name @ for-receiver
      WITH FRAME Dialog-Frame.
  IF AVAILABLE current-place THEN
    DISPLAY
    current-place.w-p-code @ for-current-w-p-code
    current-place.w-p-name @ for-current-w-p-name
  WITH FRAME Dialog-Frame .
  IF AVAILABLE out-place THEN
    DISPLAY
    out-place.w-p-code @ for-out-w-p-code
    out-place.w-p-name @ for-out-w-p-name
  WITH FRAME Dialog-Frame .
  IF AVAILABLE tt-c-wth-doc THEN
    DISPLAY
    tt-c-wth-doc.fact-date
    tt-c-wth-doc.doc-code
    tt-c-wth-doc.doc-date
    tt-c-wth-doc.shift-name
    tt-c-wth-doc.shift-num
    tt-c-wth-doc.shift-date
    tt-c-wth-doc.obj-code
    tt-c-wth-doc.obj-type
    tt-c-wth-doc.cli-code
    tt-c-wth-doc.cli-type
    tt-c-wth-doc.fact-sum
    tt-c-wth-doc.doc-sum
    tt-c-wth-doc.operator
    tt-c-wth-doc.deliver
    tt-c-wth-doc.receiver
    tt-c-wth-doc.sum-gds-base
    tt-c-wth-doc.sum-gds-rubl
    usrfulnf(tt-c-wth-doc.corr-user-name) @ tt-c-wth-doc.corr-user-name
    tt-c-wth-doc.corr-date
    WITH FRAME Dialog-Frame.
    IF par-mode = 'ПРОСМОТР':U  THEN DO:
      assign
      b-quit:label = "&Выход"
      b-quit:col = 1
      .
      ENABLE
      B-Prev
      B-Next
      b-quit
      WITH FRAME Dialog-Frame.
      assign
      locked-out = yes
      locked-current = yes
      .
    END.
    if not tt-c-wth-doc.inter_ then do:
      HIDE
      for-out-w-p-code
      for-out-w-p-name
      in frame Dialog-Frame.
    end.
    ENABLE
    b-help
    br-lines
    b-lookup
    WITH FRAME Dialog-Frame.
    Hide b-chk
    in frame Dialog-Frame.
    OPEN QUERY BR-lines FOR EACH buf_c-wth-line WHERE         buf_c-wth-line.doc-code = tt-c-wth-doc.doc-code     AND buf_c-wth-line.corr-user-db-num = tt-c-wth-doc.corr-user-db-num     AND buf_c-wth-line.chip-num = tt-c-wth-doc.chip-num NO-LOCK,            first buf_wth WHERE buf_wth.wth-code = buf_c-wth-line.wth-code NO-LOCK.
    IF ERROR-STATUS:ERROR THEN DO:
        REPOSITION br-lines TO ROW 1 NO-ERROR.
    END.
    APPLY "ENTRY":U TO br-lines IN FRAME Dialog-Frame.
    APPLY "VALUE-CHANGED":U TO br-lines IN FRAME Dialog-Frame.
    IF par-mode <> 'ПРОСМОТР':U THEN DO:
      APPLY "VALUE-CHANGED":U TO tt-c-wth-doc.cli-type IN FRAME Dialog-Frame.
    END.
   run control-line in this-procedure ( output lock-doc).
   run lock-proc in this-procedure ( input  lock-doc).
   ASSIGN
   FRAME Dialog-Frame :TITLE = substitute("Удаленный документ № &1 движения материальных ценностей (&2  - &3)"
                                            ,tt-c-wth-doc.doc-code
                                            ,ENTRY(LOOKUP(tt-c-wth-doc.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u), 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u)
                                            ,CAPS( par-mode )).
  .
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-add :
END PROCEDURE.
PROCEDURE proc-b-del :
END PROCEDURE.
PROCEDURE proc-save-doc :
END PROCEDURE.
PROCEDURE reposition-c-wth-doc :
define input parameter p-direction as character no-undo .
define variable v-new-c-wth-doc-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-c-wth-doc in p-call-prog
      (input  p-direction
      ,output v-new-c-wth-doc-recid
      ).
    if v-new-c-wth-doc-recid <> ?
    then do:
      define buffer buf_c-wth-doc for ub.c-wth-doc .
      find first buf_c-wth-doc no-lock
        where recid(buf_c-wth-doc) = v-new-c-wth-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-c-wth-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов МЦ не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.
