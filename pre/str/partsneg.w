define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-doc-code     like ub.trn-doc.doc-code no-undo .
define input  parameter p-line-mode    as character no-undo .
define input-output parameter p-part-recid  as recid no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Просмотр и вызов редактирования отрицательных партий".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define temp-table goods-cache no-undo
  field artic     like ub.parts.artic
  field prod-type like ub.parts.prod-type
  field prod-code like ub.parts.prod-code
  field root-node as integer
  field b-code    like ub.bar-code.b-code
  field gds-name  like ub.goods.gds-name
  index pk is unique primary artic prod-type prod-code
.
def var parts-b-code    like ub.bar-code.b-code no-undo .
def var parts-gds-name  like ub.goods.gds-name no-undo .
def var parts-part-code as character no-undo COLUMN-LABEL "Партия" FORMAT "x(14)" .
def var parts-prod      as character no-undo COLUMN-LABEL "Производитель" FORMAT "x(12)" .
def var parts-supp      as character no-undo COLUMN-LABEL "Поставщик"     FORMAT "x(16)" .
def var filter-point     as character no-undo .
def var sort-column-name as character no-undo .
FUNCTION get-goods-bar-code RETURNS INTEGER
  ( p-artic as character, p-prod-type as character, p-prod-code as integer )  FORWARD.
FUNCTION get-goods-gds-name RETURNS CHARACTER
  ( p-artic as character, p-prod-type as character, p-prod-code as integer )  FORWARD.
DEFINE BUTTON b-b-alt
     LABEL "Доп.&БК"
     SIZE 8 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     SIZE 6 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 6 BY 1.
DEFINE BUTTON b-gds
     LABEL "&Товар"
     SIZE 6 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 6 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-in
     LABEL "П&Н"
     SIZE 6 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просм"
     SIZE 6 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-pl
     LABEL "&Место"
     SIZE 6 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 6 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE fi-curr-base AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-curr-cli AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-curr-rubl AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 9.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-prod-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-supp-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE s-code AS INTEGER FORMAT "999999999":U INITIAL 0
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 95.75 BY 8.25.
DEFINE RECTANGLE rect-flt
     EDGE-PIXELS 0
     SIZE 0.1 BY 0.1
     BGCOLOR 8 .
DEFINE QUERY br-parts FOR
      ub.parts SCROLLING.
DEFINE BROWSE br-parts
  QUERY br-parts DISPLAY
      get-goods-bar-code(ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code) @ parts-b-code
      ub.parts.artic
      get-goods-gds-name(ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code) @ parts-gds-name
      ub.parts.price-base
      ub.parts.price-rubl
      ub.parts.qnty COLUMN-LABEL "По док./ Свобод."
      ub.parts.fact-qnty COLUMN-LABEL "Факт / Остаток"
      (if ub.parts.part-code = "" then "------" else ub.parts.part-code) @ parts-part-code
      (ub.parts.prod-type + " " + string (ub.parts.prod-code)) @ parts-prod
      (ub.parts.supp-type + " " + string (ub.parts.supp-code)) @ parts-supp
      is-supp FORMAT "+/-" COLUMN-LABEL "П"
  ENABLE
      parts.qnty
      parts.fact-qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 11.33
         BGCOLOR 15 .
DEFINE FRAME Dialog-Frame
     s-code AT ROW 1.21 COL 67.63 COLON-ALIGNED
     b-exit AT ROW 1.25 COL 1
     b-lkp AT ROW 1.25 COL 7
     b-gds AT ROW 1.25 COL 13
     b-in AT ROW 1.25 COL 19
     b-sch AT ROW 1.25 COL 25
     b-b-alt AT ROW 1.25 COL 25
     b-pl AT ROW 1.25 COL 37
     b-help AT ROW 1.25 COL 43
     b-print AT ROW 1.25 COL 49
     br-parts AT ROW 2.42 COL 1
     parts.artic AT ROW 14 COL 17.75 COLON-ALIGNED
          LABEL "Артикул"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     parts.prod-type AT ROW 15.08 COL 17.75 COLON-ALIGNED
          LABEL "Производитель"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     parts.prod-code AT ROW 15.08 COL 27.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          FGCOLOR 4
     fi-prod-name AT ROW 15.08 COL 34.25 COLON-ALIGNED NO-LABEL
     parts.price-base AT ROW 16.25 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     fi-curr-base AT ROW 16.25 COL 36.25 COLON-ALIGNED NO-LABEL
     parts.SLT-pc AT ROW 16.42 COL 52.75 COLON-ALIGNED
          LABEL "НП"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          FGCOLOR 4
     parts.SLT-type AT ROW 16.42 COL 59.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     parts.price-rubl AT ROW 17.5 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     fi-curr-rubl AT ROW 17.5 COL 36.25 COLON-ALIGNED NO-LABEL
     parts.VAT-pc AT ROW 17.5 COL 52.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          FGCOLOR 4
     parts.VAT-type AT ROW 17.5 COL 59.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY 1
          FGCOLOR 4
     parts.price-cli AT ROW 18.67 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     fi-curr-cli AT ROW 18.67 COL 36.25 COLON-ALIGNED NO-LABEL
     parts.qnty AT ROW 19.83 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
          FGCOLOR 4
     parts.fact-qnty AT ROW 19.92 COL 52.75 COLON-ALIGNED
          LABEL "Факт"
          VIEW-AS FILL-IN
          SIZE 18 BY 1
          FGCOLOR 4
     parts.supp-type AT ROW 21 COL 17.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     parts.supp-code AT ROW 21 COL 28 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     fi-supp-name AT ROW 21 COL 38.75 COLON-ALIGNED NO-LABEL
     parts.is-supp AT ROW 21.08 COL 67.75
          LABEL "Поставка"
          VIEW-AS TOGGLE-BOX
          SIZE 11.5 BY .83
     rect-flt AT ROW 1 COL 25
     "Информация из документа" VIEW-AS TEXT
          SIZE 23.75 BY .67 AT ROW 13.33 COL 36.25
     RECT-1 AT ROW 13.83 COL 1.25
     SPACE(0.49) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Порожденные партии по документу"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.
ASSIGN
       b-print:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       br-parts:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 2.
ON GO OF FRAME Dialog-Frame
DO:
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-b-alt IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if available ub.parts then do:
    def var v-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer parts
  ,output v-b-code
  )  .
    run ref/alt-bc.w
      (
       input parparentproc
      ,input ub.trn-doc.obj-type
      ,input ub.trn-doc.obj-code
      ,input v-b-code
      ).
  end.
  apply "entry":u to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  def var tbl      as character no-undo.
  def var join-tbl as character no-undo.
  def var fld      as character no-undo.
  def var lab      as character no-undo.
  def var spr      as character no-undo.
  def var dim      as character no-undo.
  assign
    tbl      = 'ub.parts'
    join-tbl = ''
    fld      = 'substring(parts.artic^0541^0543),in-code,artic,prod-type*prod-code,obj-type*obj-code,supp-type*supp-code,part-code,status_,qnty,fact-qnty,fact-date,pay-code,doc-type,price-base,price-rubl,price-cli,exch-code,is-supp'
    lab      = 'Артик 3,Номер ПН,,Производитель,Объект,Поставщик,,Закр,Кол.док.,Факт.кол.,Дата,Код Оплаты,Тип Докум.,Цена (вал),Цена (руб),Цена пост. (вал),Валюта пост.,Поставка'
    spr      = 'function_character,,,,cli,cli,cli,,,,,,pay,trn-type,,,curr,'
    dim      = '18'
  .
  do on stop undo, leave:
    run gbl/filter.w (parparentproc, filter-point, tbl, join-tbl, fld, lab, spr, dim).
    run reopen-query .
  end.
END.
ON CHOOSE OF b-gds IN FRAME Dialog-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if available ub.parts
  then do:
    define variable v-gds-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pargocod in g#library
  (input  recid(ub.parts)
  ,output v-gds-code
  )  .
    run str/showgds.p
      (input parparentproc
      ,input ?
      ,input v-gds-code
      ,input 'ПРОСМОТР':U
      ).
  end.
  apply "entry":u to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF b-in IN FRAME Dialog-Frame
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if available ub.parts then do:
    run str/showdoc.p
      (input parparentproc
      ,input ub.parts.in-code
      ,input ub.parts.artic
      ,input ub.parts.prod-type
      ,input ub.parts.prod-code
      ,input true
      ).
  end.
  apply "entry":u to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  if available ub.parts then do:
    define buffer buf_doc-line for ub.doc-line .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = ub.parts.artic
        and buf_doc-line.prod-type = ub.parts.prod-type
        and buf_doc-line.prod-code = ub.parts.prod-code
      no-error .
    if not available buf_doc-line then do:
      message
        vss-workfile vss-revision vss-description skip
        "На найдена строка документа" skip
        "Документ" p-doc-code
        "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code
        view-as alert-box error .
      undo, return no-apply .
    end.
    run str/partsedt.p
      (input parparentproc
      ,buffer buf_doc-line
      ,input  true
      ,input  true
      ,input  0
      ) no-error .
    if p-line-mode = 'ИЗМЕНЕНИЕ':U
    then do:
      assign
        p-part-recid = recid(parts)
      .
      run reopen-query .
    end.
  end.
  else do:
    message
      "Не выбрана строка"
      view-as alert-box .
    return no-apply.
  end.
END.
ON CHOOSE OF b-pl IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if available ub.parts
  then do:
    run str/pl-lkp.w
      (
        input parparentproc
       ,input recid(parts)
      ) .
  end.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
END.
ON MOUSE-SELECT-DBLCLICK OF br-parts IN FRAME Dialog-Frame
DO:
  if b-lkp :sensitive then do:
    apply "choose":u to b-lkp in frame Dialog-Frame.
  end.
END.
ON RETURN OF br-parts IN FRAME Dialog-Frame
DO:
  if b-lkp :sensitive then do:
    apply "choose":u to b-lkp in frame Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF br-parts IN FRAME Dialog-Frame
DO:
  run display-parts-info .
END.
ON LEAVE OF s-code IN FRAME Dialog-Frame
DO:
  def var v-s-code as integer no-undo .
  assign
    v-s-code = input frame Dialog-Frame s-code
  .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods    .
  define buffer buf_parts    for ub.parts    .
  find first buf_bar-code no-lock
    where buf_bar-code.b-code = v-s-code
    no-error .
  if available buf_bar-code then do:
    find first buf_goods no-lock
      where buf_goods.gds-code = buf_bar-code.gds-code
      .
    for each buf_parts no-lock
      where buf_parts.artic     = buf_goods.artic
        and buf_parts.prod-type = buf_goods.prod-type
        and buf_parts.prod-code = buf_goods.prod-code
        and buf_parts.in-code   = buf_bar-code.in-code
        and buf_parts.part-code = buf_bar-code.part-code
    :
      reposition br-parts to recid recid(buf_parts) no-error.
      if not error-status :error then do:
        run reposition-query in this-procedure
          (input recid(buf_parts)
          ).
        return no-apply.
      end.
    end.
  end.
  message
    "Бар-код не найден !"
    view-as alert-box .
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-parts :handle
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
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
run init-filter-point .
assign
  parts.qnty      :read-only in browse br-parts = true
  parts.fact-qnty :read-only in browse br-parts = true
.
if browse br-parts:set-repositioned-row(3, "CONDITIONAL" ) then .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-parts as INT EXTENT 11 no-undo.
DEF VAR varmvibr-parts       as INT no-undo.
DEF VAR varmvjbr-parts       as INT no-undo.
DEF VAR varmvkbr-parts       as INT no-undo.
DEF VAR varmvlbr-parts       as INT no-undo.
DEF VAR move-elementbr-parts as INT no-undo.
def var jjbr-parts           as int no-undo.
do varmvibr-parts = 1 to EXTENT(cur-clmn-numbr-parts):
  ASSIGN cur-clmn-numbr-parts[varmvibr-parts] = varmvibr-parts.
END.
RUN start-mv-clmnbr-parts.
PROCEDURE start-mv-clmnbr-parts:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-parts do:
  RUN re-move-clmnbr-parts ( 3, 11).
END.
ON ctrl-cursor-left OF BROWSE br-parts do:
  RUN re-move-clmnbr-parts (11, 3).
END.
PROCEDURE re-move-clmnbr-parts:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
    if cur-clmn-numbr-parts[varmvibr-parts] = source-column THEN cur-clmn-numbr-parts[varmvibr-parts] = -1.
  END.
  if br-parts:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-parts = source-column - 1 to target-column BY -1:
    DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
        if cur-clmn-numbr-parts[varmvibr-parts] = varmvjbr-parts THEN DO:
          cur-clmn-numbr-parts[varmvibr-parts] = cur-clmn-numbr-parts[varmvibr-parts] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-parts = source-column + 1 to target-column:
    DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
      if cur-clmn-numbr-parts[varmvibr-parts] = varmvjbr-parts THEN DO:
        cur-clmn-numbr-parts[varmvibr-parts] = cur-clmn-numbr-parts[varmvibr-parts] - 1.
      END.
    END.
  END.
  DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
    if cur-clmn-numbr-parts[varmvibr-parts] = -1 THEN cur-clmn-numbr-parts[varmvibr-parts] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-parts:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 3 then do:
    return .
  end.
  DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
    if cur-clmn-numbr-parts[varmvibr-parts] = cur-clmn-loc THEN move-elementbr-parts = varmvibr-parts.
  END.
  RUN re-move-clmnbr-parts (cur-clmn-loc, 3).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-parts:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-parts = 3 to EXTENT(cur-clmn-numbr-parts):
    RUN re-move-clmnbr-parts (cur-clmn-numbr-parts[varmvlbr-parts], varmvlbr-parts).
  END.
  RUN start-mv-clmnbr-parts.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-parts   as character no-undo .
def var sort-clmnbr-parts    as handle    no-undo .
def var cur-clmnbr-parts     as handle    no-undo .
def var cur-clmn-locbr-parts as integer   no-undo .
def var re-querybr-parts     as logical   initial no no-undo .
on start-search, ctrl-o of br-parts in frame Dialog-Frame do:
   run sort-brbr-parts
     (input (if available ub.parts
             then recid(ub.parts)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-parts :
  define input parameter p-recid as recid no-undo .
  if re-querybr-parts = no then do:
    assign
       cur-clmnbr-parts = br-parts:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-parts <> ? then sort-clmnbr-parts:column-fgcolor = 0.
    if cur-clmnbr-parts = sort-clmnbr-parts then do:
      assign
         sort-labelbr-parts = ""
         sort-clmnbr-parts = ?
      .
     end.
     else do:
       assign
         sort-labelbr-parts = cur-clmnbr-parts:label
         sort-clmnbr-parts  = cur-clmnbr-parts
         sort-clmnbr-parts:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-parts = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-parts:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-parts then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-parts = cur-clmn-locbr-parts + 1
    .
  end.
  case sort-labelbr-parts:
        when ub.parts.artic:label in browse br-parts then DO:    assign       sort-column-name = "ub.parts.artic"     .     run reopen-query.   . END.
        when parts-prod:label in browse br-parts then DO:    assign       sort-column-name = "parts-prod"     .     run reopen-query.   . END.
        when ub.parts.qnty:label in browse br-parts then DO:    assign       sort-column-name = "ub.parts.qnty"     .     run reopen-query.   . END.
        when ub.parts.fact-qnty:label in browse br-parts then DO:    assign       sort-column-name = "ub.parts.fact-qnty"     .     run reopen-query.   . END.
        when ub.parts.price-base:label in browse br-parts then DO:    assign       sort-column-name = "ub.parts.price-base"     .     run reopen-query.   . END.
        when ub.parts.price-rubl:label in browse br-parts then DO:    assign       sort-column-name = "ub.parts.price-rubl"     .     run reopen-query.   . END.
        when parts-part-code:label in browse br-parts then DO:    assign       sort-column-name = "parts-part-code"     .     run reopen-query.   . END.
        when parts-b-code :label in browse br-parts  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-goods-bar-code&1,&1&2&1,&1&3&1,&1&4&1)', chr(34) ,ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code)     .     run reopen-query.   . END.
        when parts-gds-name :label in browse br-parts  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-goods-gds-name&1,&1&2&1,&1&3&1,&1&4&1)', chr(34) ,ub.parts.artic, ub.parts.prod-type, ub.parts.prod-code)     .     run reopen-query.   . END.
        when is-supp:label in browse br-parts then DO:    assign       sort-column-name = "is-supp"     .     run reopen-query.   . END.
        when parts-supp:label in browse br-parts then DO:    assign       sort-column-name = "parts-supp"     .     run reopen-query.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run reopen-query.
      if sort-labelbr-parts <> "" then do:
        assign
          cur-clmnbr-parts:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-parts = ?
      .
    end.
  end case.
    if cur-clmn-locbr-parts <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-parts') then do:
        run ch-clmnbr-parts in this-procedure (cur-clmn-locbr-parts).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-parts to recid p-recid no-error.
    apply "value-changed" to br-parts in frame Dialog-Frame.
  end.
  apply "entry" to br-parts in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-parts:
if cur-clmnbr-parts = ? then do:
   run reopen-query.
end.
else do:
   assign re-querybr-parts = yes.
   run sort-brbr-parts
     (input (if available ub.parts
             then recid(ub.parts)
             else ?
            )
     ).
   assign re-querybr-parts = no.
end.
end.
MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  run main-block-procedure no-error .
  if error-status :error then do:
    undo MAIN-BLOCK, LEAVE MAIN-BLOCK .
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-parts-info :
  define buffer buf_clients  for ub.clients .
  def var v-b-code like ub.bar-code.b-code no-undo .
  do with frame Dialog-Frame:
    if available ub.parts then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer ub.parts
  ,output v-b-code
  ) no-error .
      display
        v-b-code @ s-code
        with frame Dialog-Frame.
      find buf_clients no-lock
        where buf_clients.obj-type = parts.prod-type
          and buf_clients.obj-code = parts.prod-code
        no-error .
      if available buf_clients then do:
        assign
          fi-prod-name :screen-value = buf_clients.obj-name
        .
      end.
      find buf_clients no-lock
        where buf_clients.obj-type = parts.supp-type
          and buf_clients.obj-code = parts.supp-code
        no-error .
      if available buf_clients then do:
        assign
          fi-supp-name :screen-value = buf_clients.obj-name
        .
      end.
      display
        parts.artic
        parts.prod-type
        parts.prod-code
        parts.supp-type
        parts.supp-code
        parts.is-supp
        parts.price-base
        parts.price-rubl
        parts.price-cli
        parts.SLT-pc
        parts.SLT-type
        parts.VAT-pc
        parts.VAT-type
        parts.qnty
        parts.fact-qnty
        with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY s-code fi-prod-name fi-curr-base fi-curr-rubl fi-curr-cli fi-supp-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.parts THEN
    DISPLAY parts.artic parts.prod-type parts.prod-code parts.price-base
          parts.SLT-pc parts.SLT-type parts.price-rubl parts.VAT-pc
          parts.VAT-type parts.price-cli parts.qnty parts.fact-qnty
          parts.supp-type parts.supp-code parts.is-supp
      WITH FRAME Dialog-Frame.
  ENABLE rect-flt s-code b-exit b-lkp b-gds b-in b-sch b-b-alt b-pl b-help
         br-parts RECT-1
      WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-goods-cache :
  define input parameter p-artic     like ub.goods.artic     no-undo .
  define input parameter p-prod-type like ub.goods.prod-type no-undo .
  define input parameter p-prod-code like ub.goods.prod-code no-undo .
  define parameter buffer buf_goods-cache for goods-cache .
  find first buf_goods-cache no-lock
    where buf_goods-cache.artic     = p-artic
      and buf_goods-cache.prod-type = p-prod-type
      and buf_goods-cache.prod-code = p-prod-code
    no-error .
  if not available buf_goods-cache then do:
    create buf_goods-cache .
    assign
      buf_goods-cache.artic     = p-artic
      buf_goods-cache.prod-type = p-prod-type
      buf_goods-cache.prod-code = p-prod-code
    .
    define buffer buf_goods for ub.goods .
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    assign
      buf_goods-cache.gds-name = buf_goods.gds-name
    .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output buf_goods-cache.root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_goods-cache.root-node
  ,output buf_goods-cache.b-code
  )  .
  end.
END PROCEDURE.
PROCEDURE init-filter-point :
  assign
    filter-point = entry(1, entry(2, vss-workfile, ' '), '.')
  .
END PROCEDURE.
PROCEDURE main-block-procedure :
  do
  on error   undo , return error
  on end-key undo , return error
  :
    find first ub.trn-doc no-lock
      where ub.trn-doc.doc-code = p-doc-code
      no-error .
    if not available ub.trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Документ не найден" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-part-recid = ?
    .
    if p-line-mode = 'ИЗМЕНЕНИЕ':U
    then do:
      do with frame Dialog-Frame:
        assign
          b-lkp :label = "&Измен"
        .
      end.
    end.
    RUN enable_UI .
    run reopen-query .
    WAIT-FOR GO OF FRAME Dialog-Frame focus br-parts .
  end.
END PROCEDURE.
PROCEDURE reopen-query :
  run UI-on .
END PROCEDURE.
PROCEDURE reposition-parts :
  define input  parameter p-direction   as character no-undo .
  define output parameter p-parts-recid as recid no-undo .
  case p-direction :
    when "first":U then do:
      get first br-parts.
    end.
    when "last":U then do:
      get last br-parts.
    end.
    when "prev":U then do:
      get prev br-parts.
    end.
    when "next":U then do:
      get next br-parts.
    end.
    otherwise do:
      reposition br-parts to recid integer(p-direction) no-error .
    end.
  end case .
  assign
    p-parts-recid = recid(ub.parts)
  .
  run reposition-query in this-procedure
    (input p-parts-recid
    ).
END PROCEDURE.
PROCEDURE reposition-query :
  define input parameter p-recid as recid no-undo .
  if p-recid <> ? then do:
    reposition br-parts to recid p-recid no-error.
  end.
  do with frame Dialog-Frame:
    apply "entry":u to browse br-parts .
  end.
  run display-parts-info .
END PROCEDURE.
PROCEDURE set-filter-name :
  define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        rect-flt :BGCOLOR = RED_COLOR
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        rect-flt :BGCOLOR = GREY_COLOR
        b-sch :TOOLTIP = ""
      .
    end.
  end.
END PROCEDURE.
PROCEDURE UI-on :
def var l-query-was-opened as logical no-undo .
assign
  l-query-was-opened = false
.
def var sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  when "parts-out-code" then do:
    assign
      sort-column-phrase = "by parts.out-code"
    .
  end.
  when "parts-prod" then do:
    assign
      sort-column-phrase = "by parts.prod-type by parts.prod-code"
    .
  end.
  when "parts-supp" then do:
    assign
      sort-column-phrase = "by parts.supp-type by parts.supp-code"
    .
  end.
  when "parts-part-code" then do:
    assign
      sort-column-phrase = "by parts.part-code"
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
assign
  frame Dialog-Frame:title = "Порожденные партии по документу " + string(p-doc-code)
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-16  as logical   no-undo .
define variable  l-filter-open-16    as logical   .
define variable  flt-rec-16       as recid     no-undo .
define variable  filter-name-16      as character no-undo .
define variable  where-phrase-16     as character no-undo .
define variable  sort-phrase-16      as character no-undo .
define variable  where-phrase-rus-16 as character no-undo .
define variable  sort-phrase-rus-16  as character no-undo .
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-16
  ,output filter-name-16
  ,output where-phrase-16
  ,output sort-phrase-16
  ,output where-phrase-rus-16
  ,output sort-phrase-rus-16
  ).
    run set-filter-name in this-procedure
      (INPUT filter-name-16
      ) no-error .
  assign
    l-filter-open-16 = false
  .
  if flt-rec-16 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-16 as character no-undo .
    define variable  parameter-3-16 as character no-undo .
    define variable  parameter-4-16 as character no-undo .
    define variable  parameter-5-16 as character no-undo .
    define variable  parameter-6-16 as character no-undo .
    define variable  parameter-7-16 as character no-undo .
      assign
      parameter-3-16 =
                              "FOR EACH ub.parts"
      parameter-4-16 =
        (
          if ("ub.parts.out-code  = ub.trn-doc.doc-code               and ub.parts.obj-type = ub.trn-doc.obj-type               and ub.parts.obj-code = ub.trn-doc.obj-code               and ub.parts.in-code  = ub.trn-doc.doc-code " + " " + where-phrase-16) <> ""
          then  substitute('                    ub.parts.out-code = &1&2&1                and ub.parts.obj-type = &1&3&1                and ub.parts.obj-code = &4                   and ub.parts.in-code  = &1&5&1                   '  , chr(34)                   ,ub.trn-doc.doc-code                      ,ub.trn-doc.obj-type                      ,ub.trn-doc.obj-code                      ,ub.trn-doc.doc-code )  + " " + where-phrase-16
          else "true"
        )
      parameter-5-16 = (" " + "" + " " + "")
      parameter-6-16 = if sort-phrase-16 = ''
                           then
        (
        " " + " use-index out-code " +
          " " + sort-column-phrase +
        " " + "by ub.parts.artic by ub.parts.prod-type by ub.parts.prod-code"
        )
                           else
        (
        " " + " use-index out-code " +
          " " + sort-column-phrase +
        " " + sort-phrase-16
        )
      parameter-7-16 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-16 =
          ("ub.parts.out-code  = ub.trn-doc.doc-code               and ub.parts.obj-type = ub.trn-doc.obj-type               and ub.parts.obj-code = ub.trn-doc.obj-code               and ub.parts.in-code  = ub.trn-doc.doc-code " + " " + where-phrase-16 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-16
                          ,input parameter-4-16
                          ,input parameter-5-16
                          ,input parameter-6-16
                          ,input parameter-7-16
                          )
      .
      assign
        l-filter-open-16 = true
      .
    end.
    if l-filter-open-16 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-16 = false then do:
    open query br-parts for each ub.parts no-lock
      where ub.parts.out-code  = ub.trn-doc.doc-code               and ub.parts.obj-type = ub.trn-doc.obj-type               and ub.parts.obj-code = ub.trn-doc.obj-code               and ub.parts.in-code  = ub.trn-doc.doc-code
       use-index out-code
      by ub.parts.artic by ub.parts.prod-type by ub.parts.prod-code
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
run reposition-query in this-procedure
  (input p-part-recid
  ).
if v-fltopend-rowid[1] <> ? then
query br-parts:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
END PROCEDURE.
FUNCTION get-goods-bar-code RETURNS INTEGER
  ( p-artic as character, p-prod-type as character, p-prod-code as integer ) :
   def var v-b-code as integer no-undo .
   define buffer buf_goods-cache for goods-cache .
   run get-goods-cache
     (input  p-artic
     ,input  p-prod-type
     ,input  p-prod-code
     ,buffer buf_goods-cache
     ).
   assign
     v-b-code = buf_goods-cache.b-code
   .
   return v-b-code .
END FUNCTION.
FUNCTION get-goods-gds-name RETURNS CHARACTER
  ( p-artic as character, p-prod-type as character, p-prod-code as integer ) :
   def var v-gds-name as character no-undo .
   define buffer buf_goods-cache for goods-cache .
   run get-goods-cache
     (input  p-artic
     ,input  p-prod-type
     ,input  p-prod-code
     ,buffer buf_goods-cache
     ).
   assign
     v-gds-name = buf_goods-cache.gds-name
   .
   return v-gds-name .
END FUNCTION.
