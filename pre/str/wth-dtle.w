DEFINE TEMP-TABLE tt-par-dtl NO-UNDO LIKE ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам ()"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!()"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
 .
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER par-mode as character no-undo .
define input parameter parline-rec as recid no-undo.
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define input parameter pardoc-sum like ub.wth-line.doc-sum no-undo .
define input parameter parfact-sum like ub.wth-line.fact-sum no-undo .
define input parameter parbef-sum like ub.wth-line.bef-sum no-undo .
define input parameter paraft-sum like ub.wth-line.aft-sum no-undo .
DEFINE INPUT PARAMETER pardoc-type like ub.wth-doc.doc-type no-undo .
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input-output parameter table for tt-par-dtl.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Детализация по номиналам для документов обмена МЦ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE TEMP-TABLE tt-dtl-income NO-UNDO LIKE ub.wth-par
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
DEFINE TEMP-TABLE tt-dtl-expense NO-UNDO LIKE ub.wth-par
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
DEFine VARiable d_doc-sum LIKE ub.wth-doc.doc-sum NO-UNDO.
DEFine VARiable d_fact-sum LIKE ub.wth-doc.doc-sum NO-UNDO.
DEFINE VARIABLE vardoc-status_ like ub.wth-doc.status_ no-undo .
define buffer buf_wth-par   for ub.wth-par.
define buffer buf_wth-doc   for ub.wth-doc.
define buffer buf_wth-parts for ub.wth-parts.
define buffer buf_wth-line    for ub.wth-line.
define buffer buf_wealth      for ub.wealth.
DEFINE BUTTON B-exit
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-partsExp
     LABEL "&ПартВыдано"
     SIZE 11 BY 1.
DEFINE BUTTON B-partsInc
     LABEL "&ПартПрин"
     SIZE 11 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE tot-dtl-exp AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "По товарам:   кол-во"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-dtl-inc AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "По товарам:   кол-во"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-qty-exp AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "Кол-во МЦ"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-qty-inc AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Кол-во МЦ"
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-sum-exp AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "сумма"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tot-sum-inc AS DECIMAL FORMAT "->>>,>>>,>>9.99":U INITIAL 0
     LABEL "сумма"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BR-exp FOR
      tt-dtl-expense SCROLLING.
DEFINE QUERY BR-inc FOR
      tt-dtl-income SCROLLING.
DEFINE BROWSE BR-exp
  QUERY BR-exp DISPLAY
      tt-dtl-expense.par-val
tt-dtl-expense.par-unit
tt-dtl-expense.q-ty-doc
tt-dtl-expense.doc-sum
tt-dtl-expense.q-ty-fact
tt-dtl-expense.fact-sum
tt-dtl-expense.sum-gds-rubl
tt-dtl-expense.sum-gds-base
tt-dtl-expense.price-rubl
tt-dtl-expense.price-base
tt-dtl-expense.gds-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.5 BY 6.5
         TITLE "Выдано" FIT-LAST-COLUMN.
DEFINE BROWSE BR-inc
  QUERY BR-inc DISPLAY
      tt-dtl-income.par-val
tt-dtl-income.par-unit
tt-dtl-income.q-ty-doc
tt-dtl-income.doc-sum
tt-dtl-income.q-ty-fact
tt-dtl-income.fact-sum
tt-dtl-income.sum-gds-rubl
tt-dtl-income.sum-gds-base
tt-dtl-income.price-rubl
tt-dtl-income.price-base
tt-dtl-income.gds-code
    WITH NO-ROW-MARKERS SEPARATORS SIZE 101.5 BY 6.25
         TITLE "Принято" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13 WIDGET-ID 6
     b-quit AT ROW 1 COL 11.13 WIDGET-ID 12
     B-partsInc AT ROW 1 COL 36 WIDGET-ID 14
     B-partsExp AT ROW 1 COL 47 WIDGET-ID 4
     B-Help AT ROW 1 COL 92.5 WIDGET-ID 8
     BR-inc AT ROW 3.25 COL 1 WIDGET-ID 300
     BR-exp AT ROW 11.75 COL 1 WIDGET-ID 200
     tot-qty-inc AT ROW 10 COL 26.5 COLON-ALIGNED WIDGET-ID 22
     tot-dtl-inc AT ROW 10 COL 62 COLON-ALIGNED WIDGET-ID 30
     tot-sum-inc AT ROW 10 COL 85.5 COLON-ALIGNED WIDGET-ID 24
     tot-qty-exp AT ROW 18.75 COL 26.5 COLON-ALIGNED WIDGET-ID 18
     tot-dtl-exp AT ROW 18.75 COL 62 COLON-ALIGNED WIDGET-ID 28
     tot-sum-exp AT ROW 18.75 COL 85 COLON-ALIGNED WIDGET-ID 20
     "ИТОГО принято:" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 10 COL 2 WIDGET-ID 26
          FGCOLOR 4
     "ИТОГО выдано:" VIEW-AS TEXT
          SIZE 13 BY .67 AT ROW 18.75 COL 3 WIDGET-ID 16
          FGCOLOR 4
     SPACE(86.50) SKIP(0.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Детализация по номиналам при обмене" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  IF par-mode = 'ПРОСМОТР':U THEN DO:
    RETURN NO-APPLY.
  END.
  run proc-save no-error.
  if error-status:error then return.
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
  APPLY "GO":U TO FRAME Dialog-Frame.
END.
ON CHOOSE OF B-partsExp IN FRAME Dialog-Frame
DO:
apply 'entry':U to br-exp.
if not available tt-dtl-expense then return.
run str/wthparts.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input 'document':U
                ,input (if par-mode = 'ПРОСМОТР':U then 'ПРОСМОТР':U else 'ИЗМЕНЕНИЕ':U)
                ,input parwth-code
                ,input tt-dtl-expense.par-code
                ,INPUT 0
                ,input 0
                ,INPUT buf_wth-doc.doc-code
                ,INPUT parw-p-code
                ,INPUT buf_wth-doc.cli-type
                ,INPUT buf_wth-doc.cli-code
                ,input 'рас':U ) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) view-as alert-box error title 'Ошибка при запуске wthparts.w'.
  return no-apply.
end.
if par-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-dtl-expense.q-ty-doc  = 0
tt-dtl-expense.q-ty-fact = 0
tt-dtl-expense.doc-sum   = 0
tt-dtl-expense.fact-sum  = 0
tt-dtl-expense.sum-gds-rubl = 0
tt-dtl-expense.sum-gds-base = 0
.
for each buf_wth-parts no-lock where buf_wth-parts.w-p-code = tt-dtl-expense.w-p-code
                       and buf_wth-parts.wth-code = tt-dtl-expense.wth-code
                       and buf_wth-parts.par-code = tt-dtl-expense.par-code
                       and buf_wth-parts.out-code = tt-dtl-expense.doc-code
                       and buf_wth-parts.type     = 'рас':U:
      assign
      tt-dtl-expense.q-ty-doc     =  tt-dtl-expense.q-ty-doc  + buf_wth-parts.qnty-doc
      tt-dtl-expense.q-ty-fact    =  tt-dtl-expense.q-ty-fact + buf_wth-parts.fact-qnty
      tt-dtl-expense.sum-gds-rubl =  tt-dtl-expense.sum-gds-rubl + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
      tt-dtl-expense.sum-gds-base =  tt-dtl-expense.sum-gds-base + buf_wth-parts.price-base * buf_wth-parts.fact-qnty
      no-error
      .
end.
assign
  tt-dtl-expense.doc-sum     =  tt-dtl-expense.q-ty-doc  * tt-dtl-expense.par-rate
  tt-dtl-expense.fact-sum    =  tt-dtl-expense.q-ty-fact * tt-dtl-expense.par-rate
  no-error
.
    DISPLAY
    tt-dtl-expense.q-ty-doc
    tt-dtl-expense.doc-sum
    tt-dtl-expense.q-ty-fact
    tt-dtl-expense.fact-sum
    tt-dtl-expense.sum-gds-rubl
    tt-dtl-expense.sum-gds-base
    tt-dtl-expense.price-rubl
    tt-dtl-expense.price-base
    WITH BROWSE br-exp.
  run calc-tot('exp':U).
 end.
END.
ON CHOOSE OF B-partsInc IN FRAME Dialog-Frame
DO:
if not available tt-dtl-income then return.
run str/wthparts.w (
                 input parparentproc
                ,input p-curr-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input 'document':U
                ,input (if par-mode = 'ПРОСМОТР':U then 'ПРОСМОТР':U else 'ИЗМЕНЕНИЕ':U)
                ,input parwth-code
                ,input tt-dtl-income.par-code
                ,INPUT 0
                ,input 0
                ,INPUT buf_wth-doc.doc-code
                ,INPUT parw-p-code
                ,INPUT buf_wth-doc.cli-type
                ,INPUT buf_wth-doc.cli-code
                ,input 'при':U ) no-error.
if error-status:error then do:
  message return-value error-status:get-message(1) view-as alert-box error title 'Ошибка при запуске wthparts.w'.
  return no-apply.
end.
if par-mode <> 'ПРОСМОТР':U then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-dtl-income.q-ty-doc  = 0
tt-dtl-income.q-ty-fact = 0
tt-dtl-income.doc-sum   = 0
tt-dtl-income.fact-sum  = 0
tt-dtl-income.sum-gds-rubl = 0
tt-dtl-income.sum-gds-base = 0
.
for each buf_wth-parts no-lock where buf_wth-parts.w-p-code = tt-dtl-income.w-p-code
                       and buf_wth-parts.wth-code = tt-dtl-income.wth-code
                       and buf_wth-parts.par-code = tt-dtl-income.par-code
                       and buf_wth-parts.out-code = tt-dtl-income.doc-code
                       and buf_wth-parts.type     = 'при':U:
      assign
      tt-dtl-income.q-ty-doc     =  tt-dtl-income.q-ty-doc  + buf_wth-parts.qnty-doc
      tt-dtl-income.q-ty-fact    =  tt-dtl-income.q-ty-fact + buf_wth-parts.fact-qnty
      tt-dtl-income.sum-gds-rubl =  tt-dtl-income.sum-gds-rubl + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
      tt-dtl-income.sum-gds-base =  tt-dtl-income.sum-gds-base + buf_wth-parts.price-base * buf_wth-parts.fact-qnty
      no-error
      .
end.
assign
  tt-dtl-income.doc-sum     =  tt-dtl-income.q-ty-doc  * tt-dtl-income.par-rate
  tt-dtl-income.fact-sum    =  tt-dtl-income.q-ty-fact * tt-dtl-income.par-rate
  no-error
.
    DISPLAY
    tt-dtl-income.q-ty-doc
    tt-dtl-income.doc-sum
    tt-dtl-income.q-ty-fact
    tt-dtl-income.fact-sum
    tt-dtl-income.sum-gds-rubl
    tt-dtl-income.sum-gds-base
    tt-dtl-income.price-rubl
    tt-dtl-income.price-base
    WITH BROWSE br-inc.
    run calc-tot('inc':U).
 end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-exp :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if par-mode <> 'ИЗМЕНЕНИЕ':U and par-mode <> 'ДОБАВЛЕНИЕ':U and par-mode <> 'ПРОСМОТР':U then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  if par-mode = 'ПРОСМОТР':U then do:
        FIND FIRST buf_wth-line No-LOCK WHERE
                   recid(buf_wth-line) = parline-rec No-ERROR.
  end.
  if par-mode = 'ИЗМЕНЕНИЕ':U then do:
        FIND FIRST buf_wth-line EXCLUSIVE-LOCK WHERE
                   recid(buf_wth-line) = parline-rec NO-WAIT No-ERROR.
      IF LOCKED buf_wth-line then do:
        message
        vss-workfile vss-revision vss-description skip
        "Занята запись строки документа движения МЦ"
        view-as alert-box.
        return error.
      end.
      IF NOT avail buf_wth-line then do:
        message
        vss-workfile vss-revision vss-description skip
        "Не найдена строка документа движения МЦ"
        view-as alert-box.
        return error.
      end.
  assign
  pardoc-code = buf_wth-line.doc-code
  parwth-code = buf_wth-line.wth-code
  .
  end.
  FIND FIRST buf_wth-doc No-LOCK WHERE
             buf_wth-doc.doc-code = pardoc-code No-ERROR.
  IF NOT AVAIL buf_wth-doc THEN DO:
    MESSAGE  "Не найден документ движения МЦ"
    VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  END.
  if par-mode = 'ИЗМЕНЕНИЕ':U and buf_wth-doc.status_ = 'факт':U then do:
       message "Документ движения МЦ с N" buf_wth-doc.doc-code  "имеет статус" buf_wth-doc.status_ SKIP
                      "Изменения не допускаются"
        view-as alert-box error.
        return error.
  end.
  if LOOKUP(buf_wth-doc.ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u) = 0 then do:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "Неверный вызов - документ МЦ имеет тип" buf_wth-doc.doc-type
    VIEW-AS ALERT-BOX ERROR.
    RETURN error.
  end.
  vardoc-status_ = buf_wth-doc.status_.
  FIND FIRST buf_wealth No-LOCK WHERE
              buf_wealth.wth-code = parwth-code NO-ERROR.
  IF NOT AVAIL buf_wealth THEN DO:
      MESSAGE
        "Не найдена материальная ценность в справочнике!"
      VIEW-AS ALERT-BOX ERROR.
      RETURN error.
  END.
  run fill-tables in this-Procedure no-error.
  if error-status:error then return error.
  RUN calc-tot("":U).
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE calc-tot :
DEFINE INPUT PARAMETER p-calc AS CHAR.
if p-calc = '':U or p-calc = 'inc':U then do:
  assign tot-qty-inc = 0
         tot-sum-inc = 0
         tot-dtl-inc = 0
  .
  for each tt-dtl-income no-lock:
    tot-qty-inc = tot-qty-inc + tt-dtl-income.fact-sum.
    tot-sum-inc = tot-sum-inc + tt-dtl-income.sum-gds-rubl.
    tot-dtl-inc = tot-dtl-inc + tt-dtl-income.fact-sum * tt-dtl-income.par-val.
  end.
  disp tot-qty-inc
       tot-sum-inc
       tot-dtl-inc
  with frame Dialog-Frame.
end.
if p-calc = '':U or p-calc = 'exp':U then do:
  assign tot-qty-exp = 0
         tot-sum-exp = 0
         tot-dtl-exp = 0
  .
  for each tt-dtl-expense no-lock:
    tot-qty-exp = tot-qty-exp + tt-dtl-expense.fact-sum.
    tot-sum-exp = tot-sum-exp + tt-dtl-expense.sum-gds-rubl.
    tot-dtl-exp = tot-dtl-exp + tt-dtl-expense.fact-sum * tt-dtl-expense.par-val.
  end.
  disp tot-qty-exp
       tot-sum-exp
       tot-dtl-exp
  with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY tot-qty-inc tot-dtl-inc tot-sum-inc tot-qty-exp tot-dtl-exp
          tot-sum-exp
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help BR-inc BR-exp tot-qty-inc tot-dtl-inc tot-sum-inc
         tot-qty-exp tot-dtl-exp tot-sum-exp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-exp FOR EACH tt-dtl-expense.    OPEN QUERY BR-inc FOR EACH tt-dtl-income.
END PROCEDURE.
PROCEDURE Fill-tables :
empty temp-table tt-dtl-income.
empty temp-table tt-dtl-expense.
if not can-find(first tt-par-dtl) then do:
    FOR EACH ub.wth-par NO-LOCK WHERE
             ub.wth-par.wth-code = buf_wealth.wth-code :
      FIND FIRST tt-par-dtl WHERE
                 tt-par-dtl.par-code = ub.wth-par.par-code NO-ERROR.
      IF NOT AVAIL tt-par-dtl THEN DO:
        CREATE tt-par-dtl.
        ASSIGN
          tt-par-dtl.wth-code = ub.wth-par.wth-code
          tt-par-dtl.w-p-code = parw-p-code
          tt-par-dtl.doc-code = pardoc-code
          tt-par-dtl.par-code = ub.wth-par.par-code
          tt-par-dtl.par-val  = ub.wth-par.par-val
          tt-par-dtl.par-unit = ub.wth-par.par-unit
          tt-par-dtl.par-feat = ub.wth-par.par-feat
          tt-par-dtl.par-rate = ub.wth-par.par-rate
          tt-par-dtl.q-ty-doc = 0
          tt-par-dtl.doc-sum  = 0
          tt-par-dtl.q-ty-fact = 0
          tt-par-dtl.fact-sum  = 0
       .
      END.
    END.
    FOR EACH ub.wth-dtl NO-LOCK WHERE
            ub.wth-dtl.doc-code = pardoc-code AND
            ub.wth-dtl.wth-code = parwth-code AND
            ub.wth-dtl.w-p-code = parw-p-code
    BY
    ub.wth-dtl.par-code :
      FIND FIRST tt-par-dtl WHERE
                 tt-par-dtl.par-code = ub.wth-dtl.par-code NO-ERROR.
      IF NOT AVAIL tt-par-dtl THEN DO:
        NEXT.
      END.
      buffer-copy ub.wth-dtl using doc-sum fact-sum sum-gds-rubl sum-gds-base price-rubl price-base gds-code to tt-par-dtl.
    END.
end.
for each tt-par-dtl no-lock:
    create tt-dtl-income.
    buffer-copy tt-par-dtl using wth-code
                                 w-p-code
                                 doc-code
                                 par-code
                                 par-val
                                 par-unit
                                 par-feat
                                 par-rate
             to tt-dtl-income.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-dtl-income.q-ty-doc  = 0
tt-dtl-income.q-ty-fact = 0
tt-dtl-income.doc-sum   = 0
tt-dtl-income.fact-sum  = 0
tt-dtl-income.sum-gds-rubl = 0
tt-dtl-income.sum-gds-base = 0
.
for each buf_wth-parts no-lock where buf_wth-parts.w-p-code = tt-dtl-income.w-p-code
                       and buf_wth-parts.wth-code = tt-dtl-income.wth-code
                       and buf_wth-parts.par-code = tt-dtl-income.par-code
                       and buf_wth-parts.out-code = tt-dtl-income.doc-code
                       and buf_wth-parts.type     = 'при':U:
      assign
      tt-dtl-income.q-ty-doc     =  tt-dtl-income.q-ty-doc  + buf_wth-parts.qnty-doc
      tt-dtl-income.q-ty-fact    =  tt-dtl-income.q-ty-fact + buf_wth-parts.fact-qnty
      tt-dtl-income.sum-gds-rubl =  tt-dtl-income.sum-gds-rubl + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
      tt-dtl-income.sum-gds-base =  tt-dtl-income.sum-gds-base + buf_wth-parts.price-base * buf_wth-parts.fact-qnty
      no-error
      .
end.
assign
  tt-dtl-income.doc-sum     =  tt-dtl-income.q-ty-doc  * tt-dtl-income.par-rate
  tt-dtl-income.fact-sum    =  tt-dtl-income.q-ty-fact * tt-dtl-income.par-rate
  no-error
.
    create tt-dtl-expense.
    buffer-copy tt-par-dtl using wth-code
                                 w-p-code
                                 doc-code
                                 par-code
                                 par-val
                                 par-unit
                                 par-feat
                                 par-rate
             to tt-dtl-expense.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
tt-dtl-expense.q-ty-doc  = 0
tt-dtl-expense.q-ty-fact = 0
tt-dtl-expense.doc-sum   = 0
tt-dtl-expense.fact-sum  = 0
tt-dtl-expense.sum-gds-rubl = 0
tt-dtl-expense.sum-gds-base = 0
.
for each buf_wth-parts no-lock where buf_wth-parts.w-p-code = tt-dtl-expense.w-p-code
                       and buf_wth-parts.wth-code = tt-dtl-expense.wth-code
                       and buf_wth-parts.par-code = tt-dtl-expense.par-code
                       and buf_wth-parts.out-code = tt-dtl-expense.doc-code
                       and buf_wth-parts.type     = 'рас':U:
      assign
      tt-dtl-expense.q-ty-doc     =  tt-dtl-expense.q-ty-doc  + buf_wth-parts.qnty-doc
      tt-dtl-expense.q-ty-fact    =  tt-dtl-expense.q-ty-fact + buf_wth-parts.fact-qnty
      tt-dtl-expense.sum-gds-rubl =  tt-dtl-expense.sum-gds-rubl + buf_wth-parts.price-rubl * buf_wth-parts.fact-qnty
      tt-dtl-expense.sum-gds-base =  tt-dtl-expense.sum-gds-base + buf_wth-parts.price-base * buf_wth-parts.fact-qnty
      no-error
      .
end.
assign
  tt-dtl-expense.doc-sum     =  tt-dtl-expense.q-ty-doc  * tt-dtl-expense.par-rate
  tt-dtl-expense.fact-sum    =  tt-dtl-expense.q-ty-fact * tt-dtl-expense.par-rate
  no-error
.
  if tt-par-dtl.doc-sum <> tt-dtl-income.doc-sum - tt-dtl-expense.doc-sum then do:
  end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
 ASSIGN FRAME Dialog-Frame:TITLE = 'Детализация по номиналам. МЦ ' + CAPS( buf_wealth.wth-name ).
  DISPLAY
  WITH FRAME Dialog-Frame.
  ENABLE
  b-quit
  b-help
  b-partsexp
  b-partsinc
  br-inc
  br-exp
  WITH FRAME Dialog-Frame.
  IF par-mode <> 'ПРОСМОТР':U THEN DO:
    ENABLE
    b-exit
    WITH FRAME Dialog-Frame.
  END.
OPEN QUERY BR-inc FOR EACH tt-dtl-income.
OPEN QUERY BR-exp FOR EACH tt-dtl-expense.
END PROCEDURE.
PROCEDURE proc-save :
 run calc-tot('':U).
 if tot-sum-inc <> tot-sum-exp then do:
    message 'Сумма по связанным товарам выданных и принятых МЦ не совпадают.' skip
            'Выдано  ' tot-sum-exp  skip
            'Принято ' tot-sum-inc
    view-as alert-box error.
    return error.
 end.
 if tot-dtl-inc <> tot-dtl-exp then do:
    message 'Количества по номиналам выданных и принятых МЦ не совпадают.' skip
            'Выдано  ' tot-dtl-exp  skip
            'Принято ' tot-dtl-inc
    view-as alert-box error.
    return error.
 end.
 for each tt-par-dtl:
  assign tt-par-dtl.doc-sum = 0
         tt-par-dtl.fact-sum = 0
         tt-par-dtl.sum-gds-base = 0
         tt-par-dtl.sum-gds-rubl = 0.
  for each tt-dtl-income where tt-par-dtl.wth-code = tt-dtl-income.wth-code
                          and  tt-par-dtl.par-code = tt-dtl-income.par-code:
    assign
         tt-par-dtl.doc-sum      = tt-par-dtl.doc-sum     +  tt-dtl-income.doc-sum
         tt-par-dtl.fact-sum     = tt-par-dtl.fact-sum    +  tt-dtl-income.fact-sum
         tt-par-dtl.sum-gds-base = tt-par-dtl.sum-gds-base + tt-dtl-income.sum-gds-base
         tt-par-dtl.sum-gds-rubl = tt-par-dtl.sum-gds-rubl + tt-dtl-income.sum-gds-rubl
     .
  end.
  for each tt-dtl-expense where tt-par-dtl.wth-code = tt-dtl-expense.wth-code
                           and  tt-par-dtl.par-code = tt-dtl-expense.par-code:
    assign
         tt-par-dtl.doc-sum      = tt-par-dtl.doc-sum     -  tt-dtl-expense.doc-sum
         tt-par-dtl.fact-sum     = tt-par-dtl.fact-sum    -  tt-dtl-expense.fact-sum
         tt-par-dtl.sum-gds-base = tt-par-dtl.sum-gds-base - tt-dtl-expense.sum-gds-base
         tt-par-dtl.sum-gds-rubl = tt-par-dtl.sum-gds-rubl - tt-dtl-expense.sum-gds-rubl
     .
  end.
  tt-par-dtl.q-ty-doc    = tt-par-dtl.doc-sum / tt-par-dtl.par-rate .
 end.
END PROCEDURE.
