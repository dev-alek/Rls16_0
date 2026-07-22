DEFINE BUFFER X_condition-keeping FOR ub.condition-keeping.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type LIKE ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code LIKE ub.clients.obj-code no-undo .
define output parameter destin_ like ub.goods.destin no-undo .
define output parameter attrib_ like ub.goods.attrib no-undo .
define output parameter user-rule_ like ub.goods.user-rule no-undo .
define output parameter sert_ like ub.goods.sert no-undo .
define output parameter struct_ like ub.goods.struct no-undo .
define output parameter deadline_ like ub.goods.deadline no-undo .
define output parameter sort_ like ub.goods.sort no-undo .
define output parameter nationality_       like ub.goods.nationality no-undo .
define output parameter tnved_       like ub.goods.tnved format "x(10)" no-undo .
define output parameter unit-cst_       like ub.goods.unit-cst no-undo .
define output parameter cst-base-rate_       like ub.goods.cst-base-rate no-undo .
define output parameter normal-wastage_ like ub.goods.normal-wastage no-undo .
define output parameter normal-waste_ like ub.goods.normal-waste no-undo .
define output parameter cond-keep-code_ like ub.goods.cond-keep-code no-undo .
define output parameter proof_      like goods.proof no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
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
define variable rid-tnved as recid no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
DEFINE  SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод":L
     size 10 by 1
     BGCOLOR 8 .
DEFINE BUTTON r-cnd-keep
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     size 2.75 by 0.92.
DEFINE BUTTON r-cst
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     size 2.75 by 0.92.
DEFINE VARIABLE Attrib AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     size 55 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE cond-keep-code AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE cond-keep-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.5 BY .67 NO-UNDO.
DEFINE VARIABLE cst-base-rate AS DECIMAL FORMAT ">>,>>9.9999999999" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE DeadLine AS INTEGER FORMAT ">>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     size 9.75 by 0.92
     BGCOLOR 12 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Destin AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     size 57.63 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE n-attrib AS CHARACTER FORMAT "X(256)":U INITIAL "Характеристики"
      VIEW-AS TEXT
     SIZE 13.88 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-cond-keep-code AS CHARACTER FORMAT "X(256)":U INITIAL "Код услов.хран."
      VIEW-AS TEXT
     SIZE 15 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-cst-base-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Коэффициент"
      VIEW-AS TEXT
     SIZE 12.75 BY 1 NO-UNDO.
DEFINE VARIABLE n-deadline AS CHARACTER FORMAT "X(256)":U INITIAL "Срок хранения"
      VIEW-AS TEXT
     SIZE 14.25 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-deadline-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Срок хранения"
      VIEW-AS TEXT
     SIZE 14.25 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-destin AS CHARACTER FORMAT "X(256)":U INITIAL "Назначение"
      VIEW-AS TEXT
     SIZE 11.25 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-nationality AS CHARACTER FORMAT "X(256)":U INITIAL "Статус (национальность)"
      VIEW-AS TEXT
     SIZE 24.38 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-normal-wastage AS CHARACTER FORMAT "X(256)":U INITIAL "Ест.убыль"
      VIEW-AS TEXT
     SIZE 11.63 BY 1
     BGCOLOR 8 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-normal-waste AS CHARACTER FORMAT "X(256)":U INITIAL "Отходы"
      VIEW-AS TEXT
     SIZE 11.63 BY 1
     BGCOLOR 8 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-sert AS CHARACTER FORMAT "X(256)":U INITIAL "Сертификат"
      VIEW-AS TEXT
     SIZE 13.88 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-sort AS CHARACTER FORMAT "X(256)":U INITIAL "Сорт"
      VIEW-AS TEXT
     SIZE 4.88 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-struct AS CHARACTER FORMAT "X(256)":U INITIAL "Состав(комплектность)"
      VIEW-AS TEXT
     SIZE 22.75 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-tnved AS CHARACTER FORMAT "X(256)":U INITIAL "Код ТНВЭД"
      VIEW-AS TEXT
     SIZE 12.75 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-unit-cst AS CHARACTER FORMAT "X(256)":U INITIAL "Тамож.ед"
      VIEW-AS TEXT
     SIZE 9.75 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE n-userrule AS CHARACTER FORMAT "X(256)":U INITIAL "Пра-ла экспл."
      VIEW-AS TEXT
     SIZE 13.88 BY 1
     FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE normal-wastage AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.38 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE normal-waste AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.38 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE proof AS DECIMAL FORMAT ">9.99%":U INITIAL 0
     LABEL "Алкоголь"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Sert AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     SIZE 56.5 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Sort AS CHARACTER FORMAT "X(30)":U
     VIEW-AS FILL-IN
     size 10.25 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Struct AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     size 47 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE TNVED AS CHARACTER FORMAT "x(10)"
     VIEW-AS FILL-IN
     SIZE 10 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE tnved-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 44 BY 1 NO-UNDO.
DEFINE VARIABLE unit-cst AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 6.38 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE UserRule AS CHARACTER FORMAT "X(100)":U
     VIEW-AS FILL-IN
     size 53.25 by 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE IMAGE l-attrib
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-cond-keep-code
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-cst-base-rate
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-deadline
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-destin
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-nationality
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-normal-wastage
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-normal-waste
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-proof
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-sert
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-sort
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-struct
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-tnved
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-unit-cst
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE IMAGE l-userrule
     FILENAME "adeicon\lock":U
     SIZE 2.38 BY 1.
DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.5 BY 6.
DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 74.5 BY 1.5.
DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 74.5 BY 12.13
     BGCOLOR 0 FGCOLOR 0 .
DEFINE VARIABLE NATIONALITY AS CHARACTER INITIAL "Российский"
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "Российский","Иностранный"
     SIZE 24.63 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE FRAME DLGOKCAN
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     TNVED AT ROW 4.04 COL 18 COLON-ALIGNED NO-LABEL
     tnved-name AT ROW 4.04 COL 30.13 COLON-ALIGNED NO-LABEL
     unit-cst AT ROW 5.25 COL 17.38 COLON-ALIGNED NO-LABEL
     r-cst AT ROW 5.33 COL 26.5
     cst-base-rate AT ROW 5.38 COL 55 COLON-ALIGNED NO-LABEL
     NATIONALITY AT ROW 6.58 COL 43.25 NO-LABEL
     Destin AT ROW 9.29 COL 16.63 COLON-ALIGNED NO-LABEL
     Attrib AT ROW 10.71 COL 19.25 COLON-ALIGNED NO-LABEL
     UserRule AT ROW 12.13 COL 21 COLON-ALIGNED NO-LABEL
     Sert AT ROW 13.54 COL 17.75 COLON-ALIGNED NO-LABEL
     Struct AT ROW 14.96 COL 27.25 COLON-ALIGNED NO-LABEL
     DeadLine AT ROW 16.54 COL 42.75 COLON-ALIGNED NO-LABEL
     Sort AT ROW 16.54 COL 62.5 COLON-ALIGNED NO-LABEL
     normal-wastage AT ROW 17.75 COL 16.75 COLON-ALIGNED NO-LABEL
     normal-waste AT ROW 17.88 COL 42.13 COLON-ALIGNED NO-LABEL
     cond-keep-code AT ROW 19.5 COL 20.5 COLON-ALIGNED NO-LABEL
     r-cnd-keep AT ROW 19.5 COL 28
     proof AT ROW 21.25 COL 20.5 COLON-ALIGNED WIDGET-ID 6
     n-tnved AT ROW 4 COL 7 NO-LABEL
     n-unit-cst AT ROW 5.29 COL 9.5 NO-LABEL
     n-cst-base-rate AT ROW 5.42 COL 43.25 NO-LABEL
     n-nationality AT ROW 6.54 COL 17.75 NO-LABEL
     n-destin AT ROW 9.25 COL 7.13 NO-LABEL
     n-attrib AT ROW 10.71 COL 7.25 NO-LABEL
     n-userrule AT ROW 12.13 COL 7.13 NO-LABEL
     n-sert AT ROW 13.5 COL 5.75 NO-LABEL
     n-struct AT ROW 15.04 COL 5.88 NO-LABEL
     n-deadline-2 AT ROW 16.5 COL 29.75 NO-LABEL
     n-sort AT ROW 16.5 COL 59.13 NO-LABEL
     n-deadline AT ROW 16.54 COL 29.5 NO-LABEL
     n-normal-wastage AT ROW 17.75 COL 6.25 NO-LABEL
     n-normal-waste AT ROW 17.88 COL 31.63 NO-LABEL
     n-cond-keep-code AT ROW 19.25 COL 6.5 NO-LABEL
     cond-keep-name AT ROW 19.5 COL 29.5 COLON-ALIGNED NO-LABEL
     "Таможенные характеристики" VIEW-AS TEXT
          SIZE 25.88 BY 1 AT ROW 2 COL 24
          BGCOLOR 3
     l-normal-waste AT ROW 17.79 COL 29.5
     l-attrib AT ROW 10.71 COL 4.25
     RECT-9 AT ROW 8.5 COL 2.5
     l-tnved AT ROW 4.29 COL 4.25
     l-destin AT ROW 9.25 COL 4.25
     l-normal-wastage AT ROW 17.79 COL 4
     l-userrule AT ROW 12.04 COL 4
     l-sert AT ROW 13.5 COL 3.63
     l-struct AT ROW 15.08 COL 3.5
     l-unit-cst AT ROW 5.38 COL 6.88
     l-cst-base-rate AT ROW 5.38 COL 41
     l-deadline AT ROW 16.54 COL 27
     l-sort AT ROW 16.5 COL 56.63
     RECT-10 AT ROW 2.25 COL 2.5
     l-nationality AT ROW 6.5 COL 15
     l-cond-keep-code AT ROW 19.25 COL 3.5
     RECT-12 AT ROW 21 COL 2.5 WIDGET-ID 10
     l-proof AT ROW 21.25 COL 9.5 WIDGET-ID 12
     SPACE(66.74) SKIP(0.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 1 "Введите изменения атрибутов товара для пакетной обработки":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.
ON RIGHT-MOUSE-CLICK OF Attrib IN FRAME DLGOKCAN
DO:
    assign
    n-attrib:fgcolor = 15
    attrib = ""
    l-attrib:visible = true.
    display attrib with frame DLGOKCAN.
    disable attrib with frame DLGOKCAN.
END.
ON CHOOSE OF Btn_Cancel IN FRAME DLGOKCAN
DO:
    return "отказ" .
END.
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN
DO:
define variable choice as log no-undo .
            assign
                Destin
                Attrib
                UserRule
                Sert
                Struct
                DeadLine
                Sort
                cst-base-rate
                NATIONALITY = IF NATIONALITY:SCREEN-VALUE = ? THEN "Российский" else
                                 NATIONALITY:SCREEN-VALUE
                TNVED
                unit-cst
                normal-wastage
                normal-waste
                cond-keep-code
                proof
                .
            assign
            destin_ = (if destin:sensitive  then Destin else ?)
            attrib_ = if Attrib:sensitive then Attrib else ?
            user-rule_ = if userrule:sensitive  then userrule else ?
            sert_ = if sert:sensitive then Sert else ?
            struct_ = if struct:sensitive then Struct else ?
            deadline_ = if Deadline:sensitive then Deadline else ?
            sort_ = if Sort:sensitive then Sort else ?
            cst-base-rate_ = if Cst-base-rate:sensitive  then cst-base-rate else ?
            NATIONALITY_ = if Nationality:sensitive then nationality else ?
            TNVED_ = if tnved:sensitive then tnved else ?
            unit-cst_ = if unit-cst:sensitive then unit-cst else ?
            normal-wastage_ = if normal-wastage:sensitive then normal-wastage else ?
            normal-waste_ = if normal-waste:sensitive then normal-waste else ?
            cond-keep-code_ = if cond-keep-code:sensitive then cond-keep-code else ?
            proof_ = if proof:sensitive then proof else ?
            .
END.
ON LEAVE OF cond-keep-code IN FRAME DLGOKCAN
DO:
      RUN proc-leave-cond-keep-code IN THIS-PROCEDURE (INPUT LASTKEY) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON RIGHT-MOUSE-CLICK OF cond-keep-code IN FRAME DLGOKCAN
DO:
  assign
    n-cond-keep-code:fgcolor = 15
    cond-keep-code = ?
    l-cond-keep-code:visible = true.
    display cond-keep-code with frame DLGOKCAN.
    disable cond-keep-code r-cnd-keep with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF cst-base-rate IN FRAME DLGOKCAN
DO:
    assign
    n-cst-base-rate:fgcolor = 15
    cst-base-rate = ?
    l-cst-base-rate:visible = true.
    display cst-base-rate with frame DLGOKCAN.
    disable cst-base-rate with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF DeadLine IN FRAME DLGOKCAN
DO:
    assign
    n-deadline:fgcolor = 15
    deadline = ?
    l-deadline:visible = true.
    display deadline with frame DLGOKCAN.
    disable deadline with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF Destin IN FRAME DLGOKCAN
DO:
    assign
    n-destin:fgcolor = 15
    destin = ""
    l-destin:visible = true.
    display destin with frame DLGOKCAN.
    disable destin with frame DLGOKCAN.
END.
ON MOUSE-SELECT-CLICK OF l-attrib IN FRAME DLGOKCAN
DO:
    IF l-attrib:visible then do:
    assign
    n-attrib:fgcolor = ?
    l-attrib:visible = false.
    enable attrib with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-cond-keep-code IN FRAME DLGOKCAN
DO:
    IF l-cond-keep-code:visible then do:
    assign
    n-cond-keep-code:fgcolor = ?
    l-cond-keep-code:visible = false.
    enable cond-keep-code r-cnd-keep with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-cst-base-rate IN FRAME DLGOKCAN
DO:
    IF l-cst-base-rate:visible then do:
    assign
    n-cst-base-rate:fgcolor = ?
    l-cst-base-rate:visible = false.
    enable cst-base-rate with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-deadline IN FRAME DLGOKCAN
DO:
    IF l-deadline:visible then do:
    assign
    n-deadline:fgcolor = ?
    l-deadline:visible = false.
    enable deadline with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-destin IN FRAME DLGOKCAN
DO:
    IF l-destin:visible then do:
    assign
    n-destin:fgcolor = ?
    l-destin:visible = false.
    enable destin with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-nationality IN FRAME DLGOKCAN
DO:
    IF l-nationality:visible then do:
    assign
    n-nationality:fgcolor = ?
    l-nationality:visible = false.
    enable nationality with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-normal-wastage IN FRAME DLGOKCAN
DO:
    assign
    n-normal-wastage:fgcolor = ?
    l-normal-wastage:visible = false.
    enable normal-wastage with frame DLGOKCAN.
END.
ON MOUSE-SELECT-CLICK OF l-normal-waste IN FRAME DLGOKCAN
DO:
    IF l-normal-waste:visible then do:
    assign
    n-normal-waste:fgcolor = ?
    l-normal-waste:visible = false.
    enable normal-waste with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-proof IN FRAME DLGOKCAN
DO:
    IF l-proof:visible then do:
    assign
    proof:fgcolor = ?
    l-proof:visible = false.
    enable proof with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-sert IN FRAME DLGOKCAN
DO:
    IF l-sert:visible then do:
    assign
    n-sert:fgcolor = ?
    l-sert:visible = false.
    enable sert with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-sort IN FRAME DLGOKCAN
DO:
    IF l-sort:visible then do:
    assign
    n-sort:fgcolor = ?
    l-sort:visible = false.
    enable sort with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-struct IN FRAME DLGOKCAN
DO:
    IF l-struct:visible then do:
    assign
    n-struct:fgcolor = ?
    l-struct:visible = false.
    enable struct with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-tnved IN FRAME DLGOKCAN
DO:
    IF l-tnved:visible then do:
    assign
    n-tnved:fgcolor = ?
    l-tnved:visible = false.
    enable tnved with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-unit-cst IN FRAME DLGOKCAN
DO:
    IF l-unit-cst:visible then do:
    assign
    n-unit-cst:fgcolor = ?
    l-unit-cst:visible = false.
    enable unit-cst with frame DLGOKCAN.
    enable r-cst with frame DLGOKCAN.
  end.
END.
ON MOUSE-SELECT-CLICK OF l-userrule IN FRAME DLGOKCAN
DO:
    IF l-userrule:visible then do:
    assign
    n-userrule:fgcolor = ?
    l-userrule:visible = false.
    enable userrule with frame DLGOKCAN.
  end.
END.
ON RIGHT-MOUSE-CLICK OF NATIONALITY IN FRAME DLGOKCAN
DO:
    assign
    n-nationality:fgcolor = 15
    nationality = ""
    l-nationality:visible = true.
    display nationality with frame DLGOKCAN.
    disable nationality with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF normal-wastage IN FRAME DLGOKCAN
DO:
    assign
    n-normal-wastage:fgcolor = 15
    normal-wastage = ?
    l-normal-wastage:visible = true.
    display normal-wastage with frame DLGOKCAN.
    disable normal-wastage with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF normal-waste IN FRAME DLGOKCAN
DO:
    assign
    n-normal-waste:fgcolor = 15
    normal-waste = ?
    l-normal-waste:visible = true.
    display normal-waste with frame DLGOKCAN.
    disable normal-waste with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF proof IN FRAME DLGOKCAN
DO:
    assign
    proof:fgcolor = 15
    proof = ?
    l-proof:visible = true.
    display proof with frame DLGOKCAN.
    disable proof with frame DLGOKCAN.
END.
ON CHOOSE OF r-cnd-keep IN FRAME DLGOKCAN
DO:
    RUN proc-b-cond-keep-code IN THIS-PROCEDURE NO-ERROR.
      IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF r-cst IN FRAME DLGOKCAN
DO:
define variable ref-rec as recid no-undo .
    run ref/units.w ( input parparentproc, input yes, output ref-rec ).
    if ref-rec = ? then do:
      apply "entry" to r-cst in frame DLGOKCAN.
      return no-apply.
    end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ unit-cst with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF Sert IN FRAME DLGOKCAN
DO:
    assign
    n-sert:fgcolor = 15
    sert = ""
    l-sert:visible = true.
    display sert with frame DLGOKCAN.
    disable sert with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF Sort IN FRAME DLGOKCAN
DO:
    assign
    n-sort:fgcolor = 15
    sort = ""
    l-sort:visible = true.
    display sort with frame DLGOKCAN.
    disable sort with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF Struct IN FRAME DLGOKCAN
DO:
    assign
    n-struct:fgcolor = 15
    struct = ""
    l-struct:visible = true.
    display struct with frame DLGOKCAN.
    disable struct with frame DLGOKCAN.
END.
ON LEAVE OF TNVED IN FRAME DLGOKCAN
DO:
    FIND FIRST TT-tnved WHERE TT-tnved.tnved = input frame DLGOKCAN tnved no-error.
  if not available TT-tnved then do:
    message "Код ТНВЭД не найден в справочнике." view-as alert-box error.
    display ? @ tnved with frame DLGOKCAN.
    run ch-tnved.
    return no-apply.
  end.
  else
  if length(trim(input frame DLGOKCAN tnved)) <> 10 then do:
     message "Код ТНВЭД привязки к товару должен быть 10-ти символьный." view-as alert-box error.
     display ? @ tnved with frame DLGOKCAN.
     run ch-tnved.
     return no-apply.
   end.
  else
  display TT-tnved.f-name @ tnved-name with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF TNVED IN FRAME DLGOKCAN
DO:
    assign
    n-tnved:fgcolor = 15
    tnved = ""
    l-tnved:visible = true.
    display tnved with frame DLGOKCAN.
    disable tnved with frame DLGOKCAN.
END.
ON LEAVE OF unit-cst IN FRAME DLGOKCAN
DO:
  APPLY "RETURN" to unit-cst.
END.
ON RETURN OF unit-cst IN FRAME DLGOKCAN
DO:
define variable ref-rec as recid no-undo .
  if not can-find( ub.units where
                           ub.units.unit-name = input frame DLGOKCAN unit-cst ) then do:
      run ref/units.w ( input parparentproc, input yes, output ref-rec ).
    if ref-rec = ? then  do:
            apply "entry" to unit-cst in frame DLGOKCAN.
            return no-apply.
    end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ unit-cst with frame DLGOKCAN.
end.
END.
ON RIGHT-MOUSE-CLICK OF unit-cst IN FRAME DLGOKCAN
DO:
    assign
    n-unit-cst:fgcolor = 15
    unit-cst = ""
    l-unit-cst:visible = true.
    display unit-cst with frame DLGOKCAN.
    disable unit-cst with frame DLGOKCAN.
    disable r-cst with frame DLGOKCAN.
END.
ON RIGHT-MOUSE-CLICK OF UserRule IN FRAME DLGOKCAN
DO:
    assign
    n-userrule:fgcolor = 15
    userrule = ""
    l-userrule:visible = true.
    display userrule with frame DLGOKCAN.
    disable userrule with frame DLGOKCAN.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    RUN enable_UI.
    WAIT-FOR GO OF FRAME DLGOKCAN.
END.
RUN disable_UI.
PROCEDURE ch-tnved :
  run ref/t-tnved.w (yes, output rid-tnved).
  find first tt-tnved where RECID(tt-tnved) = rid-tnved no-lock no-error.
  if available tt-tnved then disp tt-tnved.tnved @ tnved
                                  tt-tnved.f-name @ tnved-name with frame DLGOKCAN.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY       n-attrib n-cst-base-rate n-deadline
                n-deadline-2 n-destin n-nationality
                n-sert n-sort n-struct
                n-tnved n-unit-cst n-userrule n-normal-wastage n-normal-waste n-cond-keep-code proof
    with frame DLGOKCAN.
  ENABLE        Btn_OK Btn_Cancel b-help
                n-attrib n-cst-base-rate n-deadline
                n-deadline-2 n-destin n-nationality
                n-sert n-sort n-struct
                n-tnved n-unit-cst n-userrule
                l-attrib l-cst-base-rate l-deadline
                l-destin l-nationality
                l-sert l-sort l-struct
                l-tnved l-unit-cst l-userrule l-normal-wastage l-normal-waste l-cond-keep-code l-proof
      WITH FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE proc-b-cond-keep-code :
define variable v-rid-list as character no-undo.
define variable v-sts as integer no-undo.
define variable v-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo.
DEFINE BUFFER buf_condition-keeping FOR ub.condition-keeping.
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
assign
v-cond-keep-code = FRAME DLGOKCAN cond-keep-code
cond-keep-code
v-sts = INTEGER('0':U)
    .
IF available X_condition-keeping THEN v-rid-list = string(RECID(X_condition-keeping)) .
run ref/cndkeeps.w (
                INPUT parParentProc
               ,input p-curr-obj-type
               ,input p-curr-obj-code
               ,input "b-sel":U
               ,input 'все':U
               ,input-output v-sts
               ,input-output v-rid-list).
    if v-rid-list <> "":U then do:
        FIND FIRST buf_condition-keeping WHERE
             recid( buf_condition-keeping ) = integer(v-rid-list) NO-LOCK .
        FIND FIRST X_condition-keeping WHERE
        RECID(X_condition-keeping) = RECID(buf_condition-keeping).
        assign
        cond-keep-code = buf_condition-keeping.cond-keep-code
        cond-keep-name = buf_condition-keeping.cond-keep-name
               .
        DISPLAY
        cond-keep-code
        cond-keep-name
        with frame DLGOKCAN .
        RETURN.
    end.
    IF v-cond-keep-code = ? THEN DO:
       ASSIGN
       cond-keep-code = v-cond-keep-code
       cond-keep-name = "":U
       .
       RELEASE X_condition-keeping.
       DISPLAY
       cond-keep-code
       cond-keep-name
       with frame DLGOKCAN .
    END.
END PROCEDURE.
PROCEDURE proc-leave-cond-keep-code :
DEFINE INPUT PARAMETER p-lastkey AS integer NO-UNDO.
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
define variable v-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo.
DEFINE BUFFER buf_condition-keeping FOR ub.condition-keeping.
ASSIGN
v-cond-keep-code = FRAME DLGOKCAN cond-keep-code
cond-keep-code.
FIND FIRST buf_condition-keeping WHERE
 buf_condition-keeping.cond-keep-code = cond-keep-code NO-LOCK NO-error.
if not available buf_condition-keeping then do:
    IF v-cond-keep-code <> ? THEN DO:
        MESSAGE
        "Нет условий хранения с кодом" cond-keep-code
        VIEW-AS ALERT-BOX ERROR.
        IF LASTKEY = KEYCODE("return") THEN DO:
            RUN proc-b-cond-keep-code  IN THIS-PROCEDURE NO-error.
            RETURN NO-APPLY.
        END.
        ELSE DO:
            assign
            cond-keep-code = v-cond-keep-code.
        END.
    END.
    ELSE DO:
      IF p-LASTKEY = KEYCODE("return") THEN DO:
            MESSAGE
         "Нет условий хранения с кодом" cond-keep-code
         VIEW-AS ALERT-BOX ERROR.
      END.
    END.
    ASSIGN
    cond-keep-code = ?
    cond-keep-name = "":U
    .
    display
    cond-keep-code
    cond-keep-name
    with frame DLGOKCAN.
    IF p-LASTKEY = KEYCODE("return") THEN DO:
      RUN proc-b-cond-keep-code  IN THIS-PROCEDURE NO-error.
      IF ERROR-STATUS:ERROR THEN RETURN error.
    END.
end.
else do:
  FIND FIRST X_condition-keeping NO-LOCK WHERE
            recid(X_condition-keeping) = RECID(buf_condition-keeping).
  assign
  cond-keep-name = buf_condition-keeping.cond-keep-name
  .
    display
    cond-keep-name
    cond-keep-code
    with frame DLGOKCAN.
    .
END.
END PROCEDURE.
