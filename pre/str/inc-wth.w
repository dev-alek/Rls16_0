DEFINE BUFFER buf02_clients FOR ub.clients.
DEFINE BUFFER buf02_wth-place FOR ub.wth-place.
DEFINE BUFFER buf03_clients FOR ub.clients.
DEFINE BUFFER buf03_wth-place FOR ub.wth-place.
DEFINE BUFFER buf04_clients FOR ub.clients.
DEFINE BUFFER buf04_wth-place FOR ub.wth-place.
DEFINE BUFFER buf05_clients FOR ub.clients.
DEFINE BUFFER buf05_wth-place FOR ub.wth-place.
DEFINE BUFFER buf07_clients FOR ub.clients.
DEFINE BUFFER buf07_wth-place FOR ub.wth-place.
define input parameter parparentproc as widget-handle no-undo .
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
DEFINE VARIABLE vss-revision    as character no-undo init "$Revision$":u .
DEFINE VARIABLE vss-author      as character no-undo init "$Author$":u .
DEFINE VARIABLE vss-date        as character no-undo init "$Date$":u .
DEFINE VARIABLE vss-workfile    as character no-undo init "$Workfile$":u .
DEFINE VARIABLE vss-archive     as character no-undo init "$Archive$":u .
DEFINE VARIABLE vss-description as character no-undo init "Формирование автоматические документов МЦ на основе МЦ чеков" .
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE VARIABLE cas-shft as logical no-undo init no.
DEFINE VARIABLE l-shift-on as logical no-undo init no.
DEFINE VARIABLE f-date     AS DATE NO-UNDO.
DEFINE VARIABLE f-time     AS INT  NO-UNDO.
DEFINE VARIABLE s-date     AS DATE NO-UNDO.
DEFINE VARIABLE s-num      AS INT  NO-UNDO.
DEFINE VARIABLE s-name     AS CHAR NO-UNDO.
define variable v-obj-db-num as integer no-undo .
DEFINE VARIABLE v-can-back-shift AS LOGICAL NO-UNDO.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE temp-cre-doc No-UNDO
FIELD chk-type like ub.chk-doc.chk-type
FIELD inter_ like ub.wth-doc.inter_
FIELD exter_ like ub.wth-doc.exter_
FIELD doc-type like ub.wth-doc.doc-type
FIELD ext-doc-type like ub.wth-doc.ext-doc-type
FIELD cli-type like ub.wth-doc.cli-type
FIELD cli-code like ub.wth-doc.cli-code
FIELD out-w-p-code like ub.wth-place.w-p-code
FIELD doc-date like ub.wth-doc.doc-date
FIELD fact-date like ub.wth-doc.fact-date
FIELD shift-date like ub.wth-doc.shift-date
FIELD shift-num like ub.wth-doc.shift-num
FIELD shift-name like ub.wth-doc.shift-name
index pi is unique primary
chk-type
.
DEFINE BUTTON B-cli-02
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-cli-03
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-cli-04
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-cli-05
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-cli-07
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-place-02
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-place-03
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-place-04
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-place-05
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-place-07
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-shift
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 4 BY 1.
DEFINE VARIABLE cli-type-02 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE cli-type-03 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE cli-type-04 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE cli-type-05 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE cli-type-07 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 1
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code-02 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code-03 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code-04 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code-05 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE cli-code-07 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE cli-name-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.
DEFINE VARIABLE cli-name-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.
DEFINE VARIABLE cli-name-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.
DEFINE VARIABLE cli-name-05 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.
DEFINE VARIABLE cli-name-07 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.4 BY .67 NO-UNDO.
DEFINE VARIABLE doc-type-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.
DEFINE VARIABLE doc-type-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.
DEFINE VARIABLE doc-type-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.
DEFINE VARIABLE doc-type-05 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.
DEFINE VARIABLE doc-type-07 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.
DEFINE VARIABLE move-02 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса ->"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.
DEFINE VARIABLE move-03 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса <-"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.
DEFINE VARIABLE move-04 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса <->"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.
DEFINE VARIABLE move-05 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса ->"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.
DEFINE VARIABLE move-07 AS CHARACTER FORMAT "X(256)":U INITIAL "Касса <->"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.
DEFINE VARIABLE varshift-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата учета (дата смены)"
     VIEW-AS FILL-IN
     SIZE 11.4 BY 1 NO-UNDO.
DEFINE VARIABLE varshift-name AS CHARACTER FORMAT "X(2)":U
     LABEL "№"
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1 NO-UNDO.
DEFINE VARIABLE varshift-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "П"
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1 NO-UNDO.
DEFINE VARIABLE w-p-code-02 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE w-p-code-03 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE w-p-code-04 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE w-p-code-05 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE w-p-code-07 AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.
DEFINE VARIABLE w-p-name-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.
DEFINE VARIABLE w-p-name-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.
DEFINE VARIABLE w-p-name-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.
DEFINE VARIABLE w-p-name-05 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.
DEFINE VARIABLE w-p-name-07 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21 BY .67 NO-UNDO.
DEFINE VARIABLE exter-inter-02 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внешний", 1,
"Внутриобъ", 2
     SIZE 13.1 BY 1.83 NO-UNDO.
DEFINE VARIABLE exter-inter-03 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внутриобъ", 2
     SIZE 13.1 BY 1 NO-UNDO.
DEFINE VARIABLE exter-inter-04 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внешний", 1
     SIZE 13.1 BY 1 NO-UNDO.
DEFINE VARIABLE exter-inter-05 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внешний", 1,
"Внутриобъ", 2
     SIZE 13.1 BY 1.83 NO-UNDO.
DEFINE VARIABLE exter-inter-07 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Внешний", 1
     SIZE 13.1 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-02
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.9 BY 3.5.
DEFINE RECTANGLE RECT-03
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 3.5.
DEFINE RECTANGLE RECT-04
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 3.5.
DEFINE RECTANGLE RECT-05
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 3.5.
DEFINE RECTANGLE RECT-07
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 99 BY 3.5.
DEFINE VARIABLE T-02 AS LOGICAL INITIAL yes
     LABEL "Инкассация"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE T-03 AS LOGICAL INITIAL yes
     LABEL "Кассовый фонд"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE T-04 AS LOGICAL INITIAL yes
     LABEL "Перевод оплаты"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE T-05 AS LOGICAL INITIAL yes
     LABEL "Расход из кассы"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.
DEFINE VARIABLE T-07 AS LOGICAL INITIAL yes
     LABEL "Декл. ден.ящика"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     varshift-name AT ROW 1 COL 60.5 COLON-ALIGNED
     varshift-num AT ROW 1 COL 71 COLON-ALIGNED
     B-shift AT ROW 1 COL 80.5 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     varshift-date AT ROW 1.03 COL 45.1 COLON-ALIGNED
     T-02 AT ROW 4.47 COL 2.3
     exter-inter-02 AT ROW 4.47 COL 21.1 NO-LABEL
     cli-type-02 AT ROW 5.5 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-02 AT ROW 5.5 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-02 AT ROW 5.5 COL 64
     w-p-code-02 AT ROW 5.5 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-02 AT ROW 5.5 COL 91.3
     T-03 AT ROW 8.27 COL 2.3
     exter-inter-03 AT ROW 8.27 COL 21.1 NO-LABEL
     cli-type-03 AT ROW 9.27 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-03 AT ROW 9.27 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-03 AT ROW 9.27 COL 64
     w-p-code-03 AT ROW 9.27 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-03 AT ROW 9.27 COL 91.3
     T-04 AT ROW 12 COL 2.3
     exter-inter-04 AT ROW 12 COL 21.1 NO-LABEL
     cli-type-04 AT ROW 13 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-04 AT ROW 13 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-04 AT ROW 13 COL 64
     w-p-code-04 AT ROW 13 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-04 AT ROW 13 COL 91.3
     exter-inter-05 AT ROW 15.7 COL 21.1 NO-LABEL
     T-05 AT ROW 15.77 COL 2.3
     cli-type-05 AT ROW 16.77 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-05 AT ROW 16.77 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-05 AT ROW 16.77 COL 64
     w-p-code-05 AT ROW 16.77 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-05 AT ROW 16.77 COL 91.3
     exter-inter-07 AT ROW 19.2 COL 21.1 NO-LABEL
     T-07 AT ROW 19.27 COL 2.3
     cli-type-07 AT ROW 20.5 COL 43 COLON-ALIGNED NO-LABEL
     cli-code-07 AT ROW 20.5 COL 49.6 COLON-ALIGNED NO-LABEL
     B-cli-07 AT ROW 20.5 COL 64
     w-p-code-07 AT ROW 20.5 COL 76.5 COLON-ALIGNED NO-LABEL
     B-place-07 AT ROW 20.5 COL 91.3
     doc-type-02 AT ROW 4.47 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-02 AT ROW 4.47 COL 43 COLON-ALIGNED NO-LABEL
     move-02 AT ROW 4.47 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-02 AT ROW 4.47 COL 76.5 COLON-ALIGNED NO-LABEL
     doc-type-03 AT ROW 8.27 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-03 AT ROW 8.27 COL 43 COLON-ALIGNED NO-LABEL
     move-03 AT ROW 8.27 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-03 AT ROW 8.27 COL 76.5 COLON-ALIGNED NO-LABEL
     doc-type-04 AT ROW 12 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-04 AT ROW 12 COL 43 COLON-ALIGNED NO-LABEL
     move-04 AT ROW 12 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-04 AT ROW 12 COL 76.5 COLON-ALIGNED NO-LABEL
     doc-type-05 AT ROW 15.7 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-05 AT ROW 15.7 COL 43 COLON-ALIGNED NO-LABEL
     move-05 AT ROW 15.7 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-05 AT ROW 15.7 COL 76.5 COLON-ALIGNED NO-LABEL
     doc-type-07 AT ROW 19.27 COL 33.5 COLON-ALIGNED NO-LABEL
     cli-name-07 AT ROW 19.3 COL 43 COLON-ALIGNED NO-LABEL
     move-07 AT ROW 19.33 COL 66.8 COLON-ALIGNED NO-LABEL
     w-p-name-07 AT ROW 19.33 COL 76.5 COLON-ALIGNED NO-LABEL
     "Контрагент" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 2.33 COL 46.6
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     "Тип документа МЦ" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 2.43 COL 22.5
          FGCOLOR 4
     "Направление перемещения" VIEW-AS TEXT
          SIZE 26.5 BY 1 AT ROW 2.27 COL 70.5
          FGCOLOR 4
     "Типы чеков" VIEW-AS TEXT
          SIZE 17.5 BY 1 AT ROW 2.47 COL 1.8
          FGCOLOR 4
     RECT-07 AT ROW 18.5 COL 1.5
     RECT-03 AT ROW 7.47 COL 1.6
     RECT-02 AT ROW 3.7 COL 1.6
     RECT-05 AT ROW 14.97 COL 1.6
     RECT-04 AT ROW 11.2 COL 1.6
     SPACE(0.03) SKIP(7.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Формирование автоматических документов по чекам МЦ"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-cli-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       B-place-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       cli-type-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       doc-type-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       exter-inter-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       move-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       w-p-name-07:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-cli-02 IN FRAME Dialog-Frame
DO:
 define variable v_rid as character no-undo.
 define variable v-ref-rec as recid no-undo .
   FIND FIRST buf02_clients NO-LOCK WHERE
            buf02_clients.obj-type = INPUT FRAME Dialog-Frame cli-type-02 AND
            buf02_clients.obj-code = INPUT FRAME Dialog-Frame cli-code-02  NO-ERROR.
   IF available(buf02_clients) then do:
    run ref/cli-all.w ( INPUT parparentproc
                  , INPUT "b-sel":U
                  , (INPUT FRAME Dialog-Frame cli-type-02)
                  , 'все':U
                  , 'все':U
                  , RECID( buf02_clients )
                  , ",,,,,,NO"
                  , ?
                  , OUTPUT v_rid ).
  END.
  ELSE DO:
    run ref/cli-all.w ( parparentproc
                  ,  INPUT "b-sel":U
                  , 'орг':U
                  , 'все':U
                  , 'текущие':U
                  , ?
                  , ",,,,,,NO"
                  , ?
                  , OUTPUT v_rid ).
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf02_clients NO-LOCK WHERE
               RECID( buf02_clients ) = v-ref-rec NO-ERROR.
    IF AVAIL buf02_clients THEN DO:
      if buf02_clients.obj-type = 'скл':U or buf02_clients.obj-type = 'маг':U then do:
        message "Неверно выбран контрагент"
        view-as alert-box error.
        return no-apply.
      end.
      ASSIGN
      cli-code-02 = buf02_clients.obj-code
      cli-type-02 = buf02_clients.obj-type
      cli-name-02 = buf02_clients.obj-name
      .
      DISPLAY
      cli-type-02
      cli-code-02
      cli-name-02
      WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-cli-05 IN FRAME Dialog-Frame
DO:
  define variable v_rid as character no-undo.
  define variable v-ref-rec as recid no-undo .
   FIND FIRST buf05_clients NO-LOCK WHERE
            buf05_clients.obj-type = INPUT FRAME Dialog-Frame cli-type-05 AND
            buf05_clients.obj-code = INPUT FRAME Dialog-Frame cli-code-05  NO-ERROR.
   IF available(buf02_clients) then do:
    run ref/cli-all.w (parparentproc
                  , INPUT "b-sel":U
                  , (INPUT FRAME Dialog-Frame cli-type-05)
                  , 'все':U
                  , 'все':U
                  , RECID( buf05_clients )
                  , ",,,,,,NO"
                  , ?
                    , OUTPUT v_rid ).
  END.
  ELSE DO:
    run ref/cli-all.w ( parparentproc
                  , INPUT "b-sel":U
                  , 'орг':U
                  , 'все':U
                  , 'текущие':U
                  , ?
                  , ",,,,,,NO"
                  , ?
                    , OUTPUT v_rid ).
  END.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf05_clients NO-LOCK WHERE
               RECID( buf05_clients ) = v-ref-rec NO-ERROR.
    IF AVAIL buf05_clients THEN DO:
      if buf05_clients.obj-type = 'скл':U or buf05_clients.obj-type = 'маг':U then do:
        message "Неверно выбран контрагент"
        view-as alert-box error.
        return no-apply.
      end.
      ASSIGN
      cli-code-05 = buf05_clients.obj-code
      cli-type-05 = buf05_clients.obj-type
      cli-name-05 = buf05_clients.obj-name
      .
      DISPLAY
      cli-type-05
      cli-code-05
      cli-name-05
      WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  define variable v-parameter as character no-undo .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run assign-fields in this-procedure no-error.
  if error-status:error then return no-apply.
  run check-fields in this-procedure no-error.
  if error-status:error then return no-apply.
  assign
  v-parameter = string(parhost-code) + chr(4) +
                 parobj-type + chr(4) +
                 string(parobj-code) + chr(4) +
                 string(0)
  .
  run str/diallog.w (
        input parParentProc
      , input this-procedure
      , input ("str/inc-wthr.p":U + chr(4) +
              "1":U  + chr(4) +
              "1":U + chr(4) +
              "1":U)
      , input v-parameter
      , input no
      , input "":U
      , input substitute("Формирование и обработка документов МЦ &2&3", parobj-type, parobj-code)
  ) no-error.
  if error-status:error
  and return-value <> "error"
  then do:
    message
    substitute("&1 &2"
              , error-status:get-message(1)
              , return-value )
    view-as alert-box error .
    return no-apply. .
  end.
  if return-value = "error":U then do:
    return no-apply. .
  end.
END.
ON CHOOSE OF B-place-02 IN FRAME Dialog-Frame
DO:
   define variable was_found  AS LOG  NO-UNDO.
   define variable v_rid as character no-undo.
   define variable v-ref-rec as recid no-undo .
  IF cli-type-02 = 'маг':U THEN DO:
    IF CAN-FIND( ub.clients NO-LOCK WHERE
         ub.clients.obj-type = INPUT FRAME Dialog-Frame cli-type-02   AND
         ub.clients.obj-code = INPUT FRAME Dialog-Frame cli-code-02 )
    THEN DO:
          FIND FIRST ub.shop  NO-LOCK WHERE
                            ub.shop.host-code = parhost-code  AND
                            ub.shop.obj-code  = INPUT FRAME Dialog-Frame cli-code-02  NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.shop ).
    END.
  END.
  FIND buf02_wth-place NO-LOCK WHERE
                    buf02_wth-place.host-code = parhost-code               AND
                    buf02_wth-place.obj-type    = cli-type-02  AND
                    buf02_wth-place.obj-code    = cli-code-02  AND
                    buf02_wth-place.w-p-code    = INPUT FRAME Dialog-Frame w-p-code-02 NO-ERROR.
  IF AVAIL buf02_wth-place THEN DO:
        ASSIGN
        v_rid = string(RECID( buf02_wth-place ))
        .
  END.
  ASSIGN .
  run ref/wthplref.w (
                     input parparentproc
                    ,INPUT "b-sel":U
                    ,INPUT parhost-code
                    ,INPUT cli-type-02
                    ,INPUT cli-code-02
                    ,input 'объект':U
                    ,input-OUTPUT v_rid ).
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND buf02_wth-place NO-LOCK WHERE
            RECID( buf02_wth-place ) = v-ref-rec NO-ERROR.
    IF AVAIL buf02_wth-place THEN DO:
      DISPLAY
      buf02_wth-place.w-p-code @ w-p-code-02
      buf02_wth-place.w-p-name @ w-p-name-02
      WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-place-03 IN FRAME Dialog-Frame
DO:
  define variable was_found  AS LOG  NO-UNDO.
 define variable v_rid as character no-undo.
 define variable v-ref-rec as recid no-undo .
  IF cli-type-03 = 'маг':U THEN DO:
    IF CAN-FIND( ub.clients NO-LOCK WHERE
         ub.clients.obj-type = INPUT FRAME Dialog-Frame cli-type-03   AND
         ub.clients.obj-code = INPUT FRAME Dialog-Frame cli-code-03 )
    THEN DO:
          FIND FIRST ub.shop  NO-LOCK WHERE
                            ub.shop.host-code = parhost-code  AND
                            ub.shop.obj-code  = INPUT FRAME Dialog-Frame cli-code-03  NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.shop ).
    END.
  END.
  FIND buf03_wth-place NO-LOCK WHERE
                    buf03_wth-place.host-code = parhost-code               AND
                    buf03_wth-place.obj-type    = cli-type-03  AND
                    buf03_wth-place.obj-code    = cli-code-03  AND
                    buf03_wth-place.w-p-code    = INPUT FRAME Dialog-Frame w-p-code-03 NO-ERROR.
  IF AVAIL buf03_wth-place THEN DO:
        ASSIGN v_rid = string(RECID( buf03_wth-place )).
  END.
  run ref/wthplref.w (
                    input parparentproc
                   ,INPUT "b-sel":U
                   ,INPUT parhost-code
                   ,INPUT cli-type-03
                   ,INPUT cli-code-03
                   ,input 'объект':U
                   ,input-OUTPUT v_rid ).
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND buf03_wth-place NO-LOCK WHERE
            RECID( buf03_wth-place ) = v-ref-rec NO-ERROR.
    IF AVAIL buf03_wth-place THEN DO:
      DISPLAY
      buf03_wth-place.w-p-code @ w-p-code-03
      buf03_wth-place.w-p-name @ w-p-name-03
      WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-place-05 IN FRAME Dialog-Frame
DO:
   define variable was_found  AS LOG  NO-UNDO.
   define variable v_rid as character no-undo.
   define variable v-ref-rec as recid no-undo .
  IF cli-type-05 = 'маг':U THEN DO:
    IF CAN-FIND( ub.clients NO-LOCK WHERE
         ub.clients.obj-type = INPUT FRAME Dialog-Frame cli-type-05   AND
         ub.clients.obj-code = INPUT FRAME Dialog-Frame cli-code-05 )
    THEN DO:
          FIND FIRST ub.shop  NO-LOCK WHERE
                            ub.shop.host-code = parhost-code  AND
                            ub.shop.obj-code  = INPUT FRAME Dialog-Frame cli-code-05  NO-ERROR.
          ASSIGN was_found = ( AVAIL ub.shop ).
    END.
  END.
  FIND buf05_wth-place NO-LOCK WHERE
                    buf05_wth-place.host-code = parhost-code               AND
                    buf05_wth-place.obj-type    = cli-type-05  AND
                    buf05_wth-place.obj-code    = cli-code-05  AND
                    buf05_wth-place.w-p-code    = INPUT FRAME Dialog-Frame w-p-code-05 NO-ERROR.
  IF AVAIL buf05_wth-place THEN DO:
        ASSIGN v_rid = string(RECID( buf05_wth-place )).
  END.
  run ref/wthplref.w (
                    input parparentproc
                   ,INPUT "b-sel":U
                   ,INPUT parhost-code
                   ,INPUT cli-type-05
                   ,INPUT cli-code-05
                   ,input 'объект':U
                  ,input-OUTPUT v_rid ).
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN v-ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND buf05_wth-place NO-LOCK WHERE
            RECID( buf05_wth-place ) = v-ref-rec NO-ERROR.
    IF AVAIL buf05_wth-place THEN DO:
      DISPLAY
      buf05_wth-place.w-p-code @ w-p-code-05
      buf05_wth-place.w-p-name @ w-p-name-05
      WITH FRAME Dialog-Frame.
    END.
    ELSE DO:
        RETURN NO-APPLY.
    END.
  END.
  ELSE DO:
    RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF B-shift IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
define buffer buf_shift-obj for ub.shift-obj.
run str/sht-all.w (
            input parparentproc
          , INPUT parobj-type
          , input parobj-code
          , input 'b-sel'
          , input 'obj'
          , INPUT parobj-type
          , input parobj-code
          , input '':u
          , input-output v-rid-list) no-error.
if v-rid-list = '':U then do:
  return no-apply.
end.
find first buf_shift-obj no-lock where
        recid(buf_shift-obj) = integer(v-rid-list) .
if not (buf_shift-obj.obj-type = parobj-type
        and
        buf_shift-obj.obj-code = parobj-code
        )
or not (buf_shift-obj.status_ = 'зкр':U
       or
       buf_shift-obj.status_ = 'тек':U) then do:
  message
  substitute("Вы должны Выбрать ЗАКРЫТУЮ или ТЕКУЩУЮ смену по &1&2"
            , parobj-type
            , parobj-code)
  view-as alert-box error .
  return no-apply.
end.
assign
varshift-name = buf_shift-obj.shift-name
varshift-num = buf_shift-obj.shift-num
varshift-date = buf_shift-obj.shift-date
.
display
varshift-name
varshift-num
varshift-date
with frame Dialog-Frame .
END.
ON LEAVE OF cli-code-02 IN FRAME Dialog-Frame
DO:
  run proc-cli-code-02 in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF cli-code-02 IN FRAME Dialog-Frame
DO:
  run proc-cli-code-02 in this-procedure no-error.
    if error-status:error then return no-apply.
END.
ON LEAVE OF cli-code-05 IN FRAME Dialog-Frame
DO:
  run proc-cli-code-05 in this-procedure no-error.
    if error-status:error then return no-apply.
END.
ON RETURN OF cli-code-05 IN FRAME Dialog-Frame
DO:
  run proc-cli-code-05 in this-procedure no-error.
    if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF cli-type-02 IN FRAME Dialog-Frame
DO:
   FIND FIRST buf02_clients NO-LOCK WHERE
          buf02_clients.obj-type = INPUT FRAME Dialog-Frame cli-type-02 AND
          buf02_clients.obj-code = INPUT FRAME Dialog-Frame cli-code-02 NO-ERROR.
IF AVAIL buf02_clients THEN DO:
    DISPLAY
    buf02_clients.obj-name @ cli-name-02 WITH FRAME Dialog-Frame.
  END.
END.
ON VALUE-CHANGED OF cli-type-05 IN FRAME Dialog-Frame
DO:
     FIND FIRST buf05_clients NO-LOCK WHERE
          buf05_clients.obj-type = INPUT FRAME Dialog-Frame cli-type-05 AND
          buf05_clients.obj-code = INPUT FRAME Dialog-Frame cli-code-05 NO-ERROR.
IF AVAIL buf05_clients THEN DO:
    DISPLAY
    buf05_clients.obj-name @ cli-name-05 WITH FRAME Dialog-Frame.
  END.
END.
ON VALUE-CHANGED OF exter-inter-02 IN FRAME Dialog-Frame
DO:
  assign exter-inter-02.
   run proc-inter-02 in this-procedure(exter-inter-02) no-error.
   if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF exter-inter-05 IN FRAME Dialog-Frame
DO:
   assign exter-inter-05.
   run proc-inter-05 in this-procedure(exter-inter-05) no-error.
   if error-status:error then return no-apply.
END.
ON LEAVE OF w-p-code-02 IN FRAME Dialog-Frame
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
   run proc-w-p-code-02 in this-procedure no-error.
   if error-status:error then return no-apply.
END.
ON RETURN OF w-p-code-02 IN FRAME Dialog-Frame
DO:
   run proc-w-p-code-02 in this-procedure no-error.
   if error-status:error then return no-apply.
END.
ON LEAVE OF w-p-code-05 IN FRAME Dialog-Frame
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
   run proc-w-p-code-05 in this-procedure no-error.
   if error-status:error then return no-apply.
END.
ON RETURN OF w-p-code-05 IN FRAME Dialog-Frame
DO:
   run proc-w-p-code-05 in this-procedure no-error.
   if error-status:error then return no-apply.
END.
ON LEAVE OF w-p-code-07 IN FRAME Dialog-Frame
DO:
    run proc-w-p-code-07 in this-procedure no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if parobj-type  <> 'маг':U then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parobj-type" parobj-type
    view-as alert-box.
    return error.
    end.
    find first ub.sysconf No-LOCK WHERE
                ub.sysconf.host-code = parhost-code No-error.
  if not available ub.sysconf then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parhost-code" parhost-code
    view-as alert-box.
    return error.
  end.
  find first ub.shop No-LOCK WHERE
                 ub.shop.obj-code = parobj-code No-ERROR.
  if not available ub.shop then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова parobj-code" parobj-code
    view-as alert-box.
    return error.
  end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  'маг':U
  ,input  ub.shop.obj-code
  ,output v-obj-db-num
  )  .
  if v-obj-db-num <> v-cntxt-db-num then do:
    message
    substitute("Нельзя вызывать Формирование автоматических документов МЦ на основе МЦ чеков на чужой БД&1"  +
               "БД объекта &2, текущая БД &3"
               , chr(10)
               , v-obj-db-num
               , v-cntxt-db-num)
    view-as alert-box .
  end.
  Run fill-tables in this-procedure no-error.
  if error-status:error then return error.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-fields :
assign
varshift-date
varshift-num
varshift-name
frame Dialog-Frame T-02
frame Dialog-Frame T-03
frame Dialog-Frame T-04
frame Dialog-Frame T-05
frame Dialog-Frame T-07
exter-inter-02
exter-inter-03
exter-inter-04
exter-inter-05
exter-inter-07
cli-code-02 cli-code-03 cli-code-04 cli-code-05 cli-code-07
cli-type-02 cli-type-03 cli-type-04 cli-type-05 cli-code-07
w-p-code-02 w-p-code-03 w-p-code-04 w-p-code-05 w-p-code-07
.
for each temp-cre-doc:
    delete temp-cre-doc.
end.
if t-02 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 2
    temp-cre-doc.inter_ = (exter-inter-02 = 2)
    temp-cre-doc.exter_ = (exter-inter-02 = 1)
    temp-cre-doc.doc-type = doc-type-02
    temp-cre-doc.ext-doc-type = if  temp-cre-doc.inter_ then 'ej':U else 'ee':U
    temp-cre-doc.cli-type = cli-type-02
    temp-cre-doc.cli-code= cli-code-02
    temp-cre-doc.out-w-p-code = (if temp-cre-doc.inter_ then w-p-code-02 else 0)
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num  = varshift-num
    temp-cre-doc.shift-name = varshift-name
    .
end.
if t-03 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 3
    temp-cre-doc.inter_ = (exter-inter-03 = 2)
    temp-cre-doc.exter_ = (exter-inter-03 = 1)
    temp-cre-doc.doc-type = doc-type-03
    temp-cre-doc.cli-type = cli-type-03
    temp-cre-doc.cli-code= cli-code-03
    temp-cre-doc.out-w-p-code = w-p-code-03
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num = varshift-num
    temp-cre-doc.shift-name = varshift-name
    temp-cre-doc.ext-doc-type = 'ij':U.
end.
if t-04 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 4
    temp-cre-doc.inter_ = (exter-inter-04 = 2)
    temp-cre-doc.exter_ = (exter-inter-04 = 1)
    temp-cre-doc.doc-type = doc-type-04
    temp-cre-doc.cli-type = cli-type-04
    temp-cre-doc.cli-code= cli-code-04
    temp-cre-doc.out-w-p-code = w-p-code-04
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num = varshift-num
    temp-cre-doc.shift-name = varshift-name
    temp-cre-doc.ext-doc-type = 'iy':U
     .
end.
if t-05 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 5
    temp-cre-doc.inter_ = (exter-inter-05 = 2)
    temp-cre-doc.exter_ = (exter-inter-05 = 1)
    temp-cre-doc.doc-type = doc-type-05
    temp-cre-doc.cli-type = cli-type-05
    temp-cre-doc.cli-code= cli-code-05
    temp-cre-doc.out-w-p-code = (if temp-cre-doc.inter_ then w-p-code-05 else 0)
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num = varshift-num
    temp-cre-doc.shift-name = varshift-name
    temp-cre-doc.ext-doc-type =  if  temp-cre-doc.inter_ then 'ej':U else 'ee':U
    .
end.
if t-07 then do:
    create temp-cre-doc.
    assign
    temp-cre-doc.chk-type = 7
    temp-cre-doc.inter_ = (exter-inter-07 = 2)
    temp-cre-doc.exter_ = (exter-inter-07 = 1)
    temp-cre-doc.doc-type = doc-type-07
    temp-cre-doc.cli-type = cli-type-07
    temp-cre-doc.cli-code= cli-code-07
    temp-cre-doc.out-w-p-code = w-p-code-07
    temp-cre-doc.doc-date = varshift-date
    temp-cre-doc.shift-date = if l-shift-on then varshift-date else ?
    temp-cre-doc.shift-num = varshift-num
    temp-cre-doc.ext-doc-type = 'de':U
    .
end.
END PROCEDURE.
PROCEDURE check-fields :
define variable dops as character no-undo.
define buffer check_clients for ub.clients.
define buffer check_wth-place for ub.wth-place.
run gbl/chk-date.p (
                  INPUT parobj-type
                 ,INPUT parobj-code
                 ,INPUT varshift-date
                 ,INPUT time
                 ,INPUT varshift-date
                 ,INPUT varshift-num,
                 yes
                   ) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN DO:
   return error.
 END.
for each temp-cre-doc:
    dops = '':U.
    assign dops = entry (lookup (trim(string(temp-cre-doc.chk-type)),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U) no-error.
    find first check_clients No-LOCK WHERE
                 check_clients.obj-type = temp-cre-doc.cli-type AND
                 check_clients.obj-code = temp-cre-doc.cli-code No-ERROR.
    if not avail check_clients or
       (temp-cre-doc.inter_ = yes and
         NOT(temp-cre-doc.cli-type = parobj-type AND
                 temp-cre-doc.cli-code = parobj-code)
       ) or
       (
        temp-cre-doc.exter_ = yes and
         (temp-cre-doc.cli-type = 'маг':U or temp-cre-doc.cli-type = 'скл':U)
       )
       or (temp-cre-doc.doc-type = 'инв':U AND
           NOT ( temp-cre-doc.cli-type = 'орг':U and
                temp-cre-doc.cli-code = parhost-code)
          )
       then do:
       message
       "Неверный контрагент для автоматических документов по чекам  МЦ" dops
       view-as alert-box ERROR.
       return error.
    end.
    if temp-cre-doc.inter_ = temp-cre-doc.exter_ then do:
      message
       "Неверный тип документа для автоматических документов по чекам  МЦ" dops
       view-as alert-box ERROR.
       return error.
    end.
    if temp-cre-doc.inter_ then do:
        FIND FIRST check_wth-place No-LOCK WHERE
                          check_wth-place.obj-type = parobj-type AND
                          check_wth-place.obj-code = parobj-code AND
                          check_wth-place.w-p-code = temp-cre-doc.out-w-p-code No-ERROR.
        if not available check_wth-place then do:
      message
       "Неверный код МХ МЦ назначения для автоматических документов по чекам  МЦ" dops
       view-as alert-box ERROR.
       return error.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varshift-name varshift-num varshift-date T-02 exter-inter-02
          cli-type-02 cli-code-02 w-p-code-02 T-03 exter-inter-03 cli-type-03
          cli-code-03 w-p-code-03 T-04 exter-inter-04 cli-type-04 cli-code-04
          w-p-code-04 exter-inter-05 T-05 cli-type-05 cli-code-05 w-p-code-05
          cli-type-07 cli-code-07 w-p-code-07 doc-type-02 cli-name-02 move-02
          w-p-name-02 doc-type-03 cli-name-03 move-03 w-p-name-03 doc-type-04
          cli-name-04 move-04 w-p-name-04 doc-type-05 cli-name-05 move-05
          w-p-name-05 cli-name-07 w-p-name-07
      WITH FRAME Dialog-Frame.
  ENABLE RECT-07 RECT-03 RECT-02 RECT-05 B-exit RECT-04 b-quit varshift-name
         varshift-num B-shift B-Help varshift-date T-02 exter-inter-02
         cli-type-02 cli-code-02 B-cli-02 w-p-code-02 B-place-02 T-03
         exter-inter-03 cli-type-03 cli-code-03 B-cli-03 w-p-code-03 B-place-03
         T-04 exter-inter-04 cli-type-04 cli-code-04 w-p-code-04 B-place-04
         exter-inter-05 T-05 cli-type-05 cli-code-05 B-cli-05 w-p-code-05
         B-place-05 exter-inter-07 T-07 cli-code-07 w-p-code-07 doc-type-02
         cli-name-02 move-02 w-p-name-02 doc-type-03 cli-name-03 move-03
         w-p-name-03 doc-type-04 cli-name-04 move-04 w-p-name-04 doc-type-05
         cli-name-05 move-05 w-p-name-05 doc-type-07 cli-name-07 move-07
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
DEFINE VARIABLE v-host-code AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type9 as character no-undo .
define variable v-value-character9 as character no-undo .
define variable v-value-date9 as date no-undo .
define variable v-value-decimal9 as decimal no-undo .
define variable v-value-integer9 as INTEGER no-undo .
define variable v-tth9 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character9
    ,output v-value-date9
    ,output v-value-decimal9
    ,output v-value-integer9
    ,output cas-shft
    ,output v-param-type9
    ,INPUT-OUTPUT table-handle v-tth9
    )  .
delete object v-tth9.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
if l-shift-on and not cas-shft then do:
  message
  "Внимание! На текущем объекте требуется использование смен" skip
  "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
  view-as alert-box ERROR.
  return ERROR.
end.
if l-shift-on then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-host-code
  )  .
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_wth-doc_create-back-shift':U
    ,input  'object':U
    ,input  v-host-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-can-back-shift
    )  .
end.
end.
run gbl/factdate.p (
                 INPUT        parobj-type,
                 INPUT        parobj-code,
                 INPUT-OUTPUT f-date,
                 INPUT-OUTPUT f-time,
                 INPUT-OUTPUT s-date,
                 INPUT-OUTPUT s-num,
                 INPUT-OUTPUT s-name,
                 INPUT        YES
                   ) NO-ERROR.
 IF ERROR-STATUS:ERROR
 and not v-can-back-shift THEN DO:
   return error.
 END.
FIND FIRST buf02_clients No-LOCK WHERE
                 buf02_clients.obj-type = parobj-type and
                 buf02_clients.obj-code = parobj-code No-ERROR.
FIND FIRST buf03_clients No-LOCK WHERE
                 buf03_clients.obj-type = parobj-type and
                 buf03_clients.obj-code = parobj-code No-ERROR.
FIND FIRST buf04_clients No-LOCK WHERE
                 buf04_clients.obj-type = 'орг':U and
                 buf04_clients.obj-code = parhost-code No-ERROR.
FIND FIRST buf05_clients No-LOCK WHERE
                 buf05_clients.obj-type = parobj-type and
                 buf05_clients.obj-code = parobj-code No-ERROR.
FIND FIRST buf07_clients No-LOCK WHERE
                 buf07_clients.obj-type = 'орг':U and
                 buf07_clients.obj-code = parhost-code No-ERROR.
FIND FIRST buf02_wth-place No-LOCK WHERE
                  buf02_wth-place.obj-type = parobj-type AND
                  buf02_wth-place.obj-code = parobj-code AND
                  buf02_wth-place.main-cash-desk = yes No-ERROR.
FIND FIRST buf03_wth-place No-LOCK WHERE
                  buf03_wth-place.obj-type = parobj-type AND
                  buf03_wth-place.obj-code = parobj-code AND
                  buf03_wth-place.main-cash-desk = yes No-ERROR.
FIND FIRST buf05_wth-place No-LOCK WHERE
                  buf05_wth-place.obj-type = parobj-type AND
                  buf05_wth-place.obj-code = parobj-code AND
                  buf05_wth-place.main-cash-desk = yes No-ERROR.
END PROCEDURE.
PROCEDURE MyEnable :
assign
exter-inter-02 = 2
exter-inter-03 = 2
exter-inter-04 = 1
exter-inter-05 = 2
exter-inter-07 = 1
doc-type-02 = 'рас':U
doc-type-03 = 'при':U
doc-type-04 = 'инв':U
doc-type-05 = 'рас':U
doc-type-07 = 'декл':U
cli-type-02:list-items in frame Dialog-Frame = 'орг':U + chr(44) +
                                    'чел':U + chr(44)  +
                                                                        'маг':U + chr(44)
cli-type-03:list-items =  'маг':U + chr(44)
cli-type-04:list-items = 'орг':U + chr(44)
cli-type-05:list-items = 'орг':U + chr(44) +
                                    'чел':U + chr(44)   +
                                                                        'маг':U + chr(44)
cli-type-07:list-items = 'орг':U + chr(44)
.
assign
varshift-date = (if s-date = ? then f-date else s-date)
varshift-num = s-num
varshift-name = s-name
.
if available buf02_clients then
assign
cli-type-02 = buf02_clients.obj-type
cli-code-02 = buf02_clients.obj-code
cli-name-02 = buf02_clients.obj-name
.
if available buf03_clients then
assign
cli-type-03 = buf03_clients.obj-type
cli-code-03 = buf03_clients.obj-code
cli-name-03 = buf03_clients.obj-name
.
if available buf04_clients then
assign
cli-type-04 = buf04_clients.obj-type
cli-code-04 = buf04_clients.obj-code
cli-name-04 = buf04_clients.obj-name
.
if available buf05_clients then
assign
cli-type-05 = buf05_clients.obj-type
cli-code-05 = buf05_clients.obj-code
cli-name-05 = buf05_clients.obj-name
.
if available buf07_clients then
assign
cli-type-07 = buf07_clients.obj-type
cli-code-07 = buf07_clients.obj-code
cli-name-07 = buf07_clients.obj-name
.
if available buf02_wth-place then
assign
w-p-code-02 = buf02_wth-place.w-p-code
w-p-name-02 = buf02_wth-place.w-p-name
.
if available buf03_wth-place then
assign
w-p-code-03 = buf03_wth-place.w-p-code
w-p-name-03 = buf03_wth-place.w-p-name
.
if available buf04_wth-place then
assign
w-p-code-04 = buf04_wth-place.w-p-code
w-p-name-04 = buf04_wth-place.w-p-name
.
if available buf05_wth-place then
assign
w-p-code-05 = buf05_wth-place.w-p-code
w-p-name-05 = buf05_wth-place.w-p-name
.
if available buf07_wth-place then
assign
w-p-code-07 = buf07_wth-place.w-p-code
w-p-name-07 = buf07_wth-place.w-p-name
.
DISPLAY
varshift-date
varshift-num
T-02 exter-inter-02 cli-type-02 cli-code-02 cli-name-02 w-p-code-02 doc-type-02 w-p-name-02 move-02
T-03 exter-inter-03  cli-type-03  cli-code-03 cli-name-03 w-p-code-03 doc-type-03 w-p-name-03 move-03
T-04 exter-inter-04  cli-type-04  cli-code-04 cli-name-04  doc-type-04  move-04
T-05 exter-inter-05  cli-type-05  cli-code-05 cli-name-05 w-p-code-05 doc-type-05 w-p-name-05 move-05
T-07 exter-inter-07  cli-type-07  cli-code-07 cli-name-07 doc-type-07 move-07
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-quit
B-Help
varshift-date when not l-shift-on
varshift-num when cas-shft
T-02 exter-inter-02 cli-type-02 cli-code-02 B-cli-02 w-p-code-02 B-place-02 doc-type-02
T-03 exter-inter-03                 w-p-code-03     B-place-03                 doc-type-03
T-04 exter-inter-04                                         doc-type-04
T-05 exter-inter-05  cli-type-05 cli-code-05 b-cli-05 w-p-code-05 B-place-05 doc-type-05
T-07 exter-inter-07  doc-type-07
b-shift WHEN (l-shift-on AND v-can-back-shift)
WITH FRAME Dialog-Frame .
IF NOT (l-shift-on AND v-can-back-shift) THEN DO:
  HIDE
  b-shift IN FRAME Dialog-Frame.
END.
HIDE
b-cli-03
b-cli-04
b-cli-07
b-place-04
b-place-07
in frame Dialog-Frame.
VIEW FRAME Dialog-Frame.
APPLY "VALUE-CHANGED" to exter-inter-02 in frame Dialog-Frame.
APPLY "VALUE-CHANGED" to exter-inter-05 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-cli-code-02 :
      FIND FIRST buf02_clients NO-LOCK WHERE
                buf02_clients.obj-type = INPUT FRAME Dialog-Frame cli-type-02 AND
                buf02_clients.obj-code = INPUT FRAME Dialog-Frame cli-code-02 NO-ERROR.
  IF AVAIL buf02_clients THEN DO:
    CASE buf02_clients.obj-type:
      when 'маг':U then dO:
        find first ub.shop No-LOCK WHERE
                   ub.shop.obj-code = buf02_clients.obj-code No-ERROR.
        if ub.shop.host-code <> parhost-code then do:
          message "Нельзя выбрать магазин другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-02 in frame Dialog-Frame.
          return error.
        end.
      end.
      when 'скл':U then do:
        find first ub.store No-LOCK WHERE
                   ub.store.obj-code = buf02_clients.obj-code No-ERROR.
        if ub.store.host-code <> parhost-code then do:
          message "Нельзя выбрать склад другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-02 in frame Dialog-Frame.
          return error.
        end.
      end.
    end CASE.
    DISPLAY
    buf02_clients.obj-name @ cli-name-02 WITH FRAME Dialog-Frame.
  END.
END PROCEDURE.
PROCEDURE proc-cli-code-05 :
      FIND FIRST buf05_clients NO-LOCK WHERE
                buf05_clients.obj-type = INPUT FRAME Dialog-Frame cli-type-05 AND
                buf05_clients.obj-code = INPUT FRAME Dialog-Frame cli-code-05 NO-ERROR.
  IF AVAIL buf05_clients THEN DO:
    CASE buf05_clients.obj-type:
      when 'маг':U then dO:
        find first ub.shop No-LOCK WHERE
                   ub.shop.obj-code = buf05_clients.obj-code No-ERROR.
        if ub.shop.host-code <> parhost-code then do:
          message "Нельзя выбрать магазин другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-05 in frame Dialog-Frame.
          return error.
        end.
      end.
      when 'скл':U then do:
        find first ub.store No-LOCK WHERE
                   ub.store.obj-code = buf05_clients.obj-code No-ERROR.
        if ub.store.host-code <> parhost-code then do:
          message "Нельзя выбрать склад другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-05 in frame Dialog-Frame.
          return error.
        end.
      end.
    end CASE.
    DISPLAY
    buf05_clients.obj-name @ cli-name-05 WITH FRAME Dialog-Frame.
  END.
END PROCEDURE.
PROCEDURE proc-cli-code-07 :
      FIND FIRST buf07_clients NO-LOCK WHERE
                buf07_clients.obj-type = INPUT FRAME Dialog-Frame cli-type-07 AND
                buf07_clients.obj-code = INPUT FRAME Dialog-Frame cli-code-07 NO-ERROR.
  IF AVAIL buf07_clients THEN DO:
    CASE buf07_clients.obj-type:
      when 'маг':U then dO:
        find first ub.shop No-LOCK WHERE
                   ub.shop.obj-code = buf07_clients.obj-code No-ERROR.
        if ub.shop.host-code <> parhost-code then do:
          message "Нельзя выбрать магазин другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-07 in frame Dialog-Frame.
          return error.
        end.
      end.
      when 'скл':U then do:
        find first ub.store No-LOCK WHERE
                   ub.store.obj-code = buf07_clients.obj-code No-ERROR.
        if ub.store.host-code <> parhost-code then do:
          message "Нельзя выбрать склад другой фирмы!"
          view-as alert-box error .
          APPLY "ENTRY" to cli-code-07 in frame Dialog-Frame.
          return error.
        end.
      end.
    end CASE.
    DISPLAY
    buf07_clients.obj-name @ cli-name-07 WITH FRAME Dialog-Frame.
  END.
END PROCEDURE.
PROCEDURE proc-inter-02 :
define input parameter loc-inter as integer no-undo.
CASE loc-inter :
    when 2 then do:
        cli-type-02:list-items in frame Dialog-Frame = 'маг':U + chr(44).
        assign
        cli-type-02 = parobj-type
        cli-code-02 = parobj-code
        .
        display
        cli-type-02
        cli-code-02
        with frame Dialog-Frame.
        disable
        cli-type-02
        cli-code-02
        b-cli-02
        with frame Dialog-Frame.
        enable
        b-place-02
        w-p-code-02
        with frame Dialog-Frame.
        APPLY "VALUE-CHANGED" to cli-type-02.
        APPLY "LEAVE" to w-p-code-02 in frame Dialog-Frame.
    end.
    when 1 then do:
        cli-type-02:list-items in frame Dialog-Frame = 'орг':U + chr(44) +
                                    'чел':U + chr(44)  .
        assign
        cli-type-02 = 'орг':U
        cli-code-02 = 0
        .
        display
        cli-type-02
        cli-code-02
        '':U @ cli-name-02
        with frame Dialog-Frame.
        ENABLE
        cli-type-02
        cli-code-02
        b-cli-02
        with frame Dialog-Frame.
        hide
        w-p-code-02
        b-place-02
        w-p-name-02
        in frame Dialog-Frame.
    end.
    END CASE.
END PROCEDURE.
PROCEDURE proc-inter-05 :
define input parameter loc-inter as integer no-undo.
CASE loc-inter :
    when 2 then do:
            cli-type-05:list-items in frame Dialog-Frame = 'маг':U + chr(44).
        assign
        cli-type-05 = parobj-type
        cli-code-05 = parobj-code
        .
        display
        cli-type-05
        cli-code-05
        with frame Dialog-Frame.
        disable
        cli-type-05
        cli-code-05
        b-cli-05
        with frame Dialog-Frame.
        enable
        b-place-05
        w-p-code-05
        with frame Dialog-Frame.
        APPLY "VALUE-CHANGED" to cli-type-05.
            APPLY "LEAVE" to w-p-code-02 in frame Dialog-Frame.
    end.
    when 1 then do:
            cli-type-05:list-items in frame Dialog-Frame = 'орг':U + chr(44) +
                                    'чел':U + chr(44)  .
        assign
        cli-type-05 = 'орг':U
        cli-code-05 = 0
        .
        display
        cli-type-05
        cli-code-05
        '':U @ cli-name-05
        with frame Dialog-Frame.
        ENABLE
        cli-type-05
        cli-code-05
        b-cli-05
        with frame Dialog-Frame.
        hide
        w-p-code-05
        b-place-05
        w-p-name-05
        in frame Dialog-Frame.
    end.
    END CASE.
END PROCEDURE.
PROCEDURE proc-w-p-code-02 :
IF INPUT FRAME Dialog-Frame T-02 = YES  THEN DO:
  FIND FIRST buf02_wth-place NO-LOCK WHERE
            buf02_wth-place.obj-type = buf02_clients.obj-type      AND
            buf02_wth-place.obj-code = buf02_clients.obj-code      AND
            buf02_wth-place.w-p-code = INPUT FRAME Dialog-Frame w-p-code-02 NO-ERROR.
  IF AVAIL buf02_wth-place THEN DO:
    DISPLAY
    buf02_wth-place.w-p-name @ w-p-name-02
    WITH FRAME Dialog-Frame.
  END.
  else return error.
end.
END PROCEDURE.
PROCEDURE proc-w-p-code-05 :
IF INPUT FRAME Dialog-Frame T-05 = YES  THEN DO:
  FIND FIRST buf05_wth-place NO-LOCK WHERE
            buf05_wth-place.obj-type = buf05_clients.obj-type      AND
            buf05_wth-place.obj-code = buf05_clients.obj-code      AND
            buf05_wth-place.w-p-code = INPUT FRAME Dialog-Frame w-p-code-05 NO-ERROR.
  IF AVAIL buf05_wth-place THEN DO:
    DISPLAY
    buf05_wth-place.w-p-name @ w-p-name-05
    WITH FRAME Dialog-Frame.
  END.
  else return error.
end.
END PROCEDURE.
PROCEDURE proc-w-p-code-07 :
IF INPUT FRAME Dialog-Frame T-07 = YES  THEN DO:
  FIND FIRST buf07_wth-place NO-LOCK WHERE
            buf07_wth-place.obj-type = buf07_clients.obj-type      AND
            buf07_wth-place.obj-code = buf07_clients.obj-code      AND
            buf07_wth-place.w-p-code = INPUT FRAME Dialog-Frame w-p-code-07 NO-ERROR.
  IF AVAIL buf07_wth-place THEN DO:
    DISPLAY
    buf07_wth-place.w-p-name @ w-p-name-07
    WITH FRAME Dialog-Frame.
  END.
  else return error.
end.
END PROCEDURE.
