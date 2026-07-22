CREATE WIDGET-POOL.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter rec-id as recid no-undo.
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Информация по бар-кодам" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE in-bc NO-UNDO
     FIELD nm        as INTEGER
     FIELD bar-str   AS CHARACTER
     FIELD bar-code  as CHARACTER
     FIELD rez       as CHARACTER
     FIELD err-msg   as CHARACTER
     FIELD des       as CHARACTER
     INDEX pi IS PRIMARY nm.
DEFINE OUTPUT PARAMETER TABLE FOR in-bc.
DEFINE  SHARED TEMP-TABLE un-bc NO-UNDO
     FIELD nm             as INTEGER
     FIELD bar-code       as CHARACTER
     FIELD entity         as character
     FIELD b-c            as INTEGER
     FIELD rate           as DECIMAL
     FIELD TYPE-bc        as CHARACTER
     FIELD wt             as DECIMAL
     FIELD file-qnty      as decimal
     FIELD scn-qnty       as DECIMAL
     FIELD scn-pl         as CHARACTER
     FIELD artic          LIKE ub.goods.artic
     FIELD prod-type      LIKE ub.goods.prod-type
     FIELD prod-code      LIKE ub.goods.prod-code
     FIELD gds-name       LIKE ub.goods.gds-name
     FIELD prod-name      LIKE ub.clients.obj-name
     FIELD unit-base      LIKE ub.goods.unit-base
     FIELD units-type     LIKE ub.units.type
     FIELD f-name         LIKE ub.gds-prt.f-name
     FIELD in-code        LIKE ub.parts.in-code
     FIELD fact-date      LIKE ub.parts.fact-date
     FIELD part-code      LIKE ub.parts.part-code
     FIELD rez            as CHARACTER
     FIELD err-msg        as CHARACTER
     FIELD des            as CHARACTER
     FIELD pl-name        AS CHARACTER
     FIELD loc1           AS CHARACTER
     FIELD loc2           AS CHARACTER
     FIELD loc3           AS CHARACTER
     FIELD loc4           AS CHARACTER
     FIELD unit-name      LIKE ub.units.unit-name
     FIELD long-name      LIKE ub.units.long-name
     FIELD b-c-base       LIKE ub.bar-code.b-code
     FIELD unit-name-base LIKE ub.units.unit-name
     FIELD long-name-base LIKE ub.units.long-name
     INDEX pi IS PRIMARY  nm
     INDEX bar-code bar-code
     INDEX b-c b-c
     INDEX file-qnty file-qnty.
DEFINE  SHARED TEMP-TABLE anlz-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD err-msg  as CHARACTER
     FIELD des      as CHARACTER
     FIELD upd-line as logical initial no
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
DEFINE  SHARED TEMP-TABLE main-bc NO-UNDO
     FIELD nm       as INTEGER
     FIELD b-c      as integer
     FIELD scn-qnty as DECIMAL
     FIELD scn-pl   as CHARACTER
     FIELD rez      as CHARACTER
     FIELD des      as CHARACTER
     INDEX pi IS PRIMARY nm
     INDEX b-c b-c.
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1.
DEFINE BUTTON b-goods
     LABEL "&Товар"
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON b-parts
     LABEL "&Партия"
     SIZE 10 BY 1.
DEFINE BUTTON b-place
     LABEL "&Место"
     SIZE 10 BY 1.
DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 19.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varb-c AS INTEGER FORMAT ">>>>>>>>>>>>>>9":U INITIAL 0
     LABEL "Основной код"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varb-c-cli AS INTEGER FORMAT ">>>>>>>>>>>>>>9":U INITIAL 0
     LABEL "Собственный код"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varbar-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Исходный код"
     VIEW-AS FILL-IN
     SIZE 52.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varadd-info AS CHARACTER FORMAT "X(256)":U
     LABEL "Доп инф"
     VIEW-AS FILL-IN
     SIZE 64.88 BY 1 NO-UNDO.
DEFINE VARIABLE varentity AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 26.13 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varf-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 83.63 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varfact-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 53.38 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varin-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Накладная"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varloc1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Коорд1"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varloc2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Коорд2"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varloc3 AS CHARACTER FORMAT "X(256)":U
     LABEL "Коорд3"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varloc4 AS CHARACTER FORMAT "X(256)":U
     LABEL "Коорд4"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varpart-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 20.75 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varpl-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.88 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varprod-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.75 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varprod-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 53.25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varprod-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 5.75 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varrate AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0
     LABEL "Коэффициент"
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varTempAdd AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 94.88 BY .75
     BGCOLOR 7 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE varTempBarCode AS CHARACTER FORMAT "X(256)":U INITIAL "СОБСТВЕННЫЙ КОД"
      VIEW-AS TEXT
     SIZE 94.88 BY .75
     BGCOLOR 7 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE varTempGoods AS CHARACTER FORMAT "X(256)":U INITIAL "ТОВАР"
      VIEW-AS TEXT
     SIZE 94.88 BY .75
     BGCOLOR 7 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE vartype-bc AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип кода"
     VIEW-AS FILL-IN
     SIZE 65.13 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varunit-base-long AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varunit-base-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Ед. изм."
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varunit-cli-long AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varunit-cli-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Ед. изм."
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE varwt AS DECIMAL FORMAT ">>9.99":U INITIAL ?
     LABEL "Вес"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 94.88 BY 4.25.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 94.88 BY 2.08.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 94.88 BY 4.21.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 94.88 BY 3.13.
DEFINE FRAME D-Dialog
     b-exit AT ROW 1.21 COL 2
     b-help AT ROW 1.21 COL 12
     b-goods AT ROW 1.21 COL 22
     b-parts AT ROW 1.21 COL 32
     b-place AT ROW 1.21 COL 42
     varbar-code AT ROW 3.67 COL 14.88 COLON-ALIGNED
     varentity AT ROW 3.67 COL 67.63 COLON-ALIGNED NO-LABEL
     vartype-bc AT ROW 4.88 COL 14.88 COLON-ALIGNED
     varwt AT ROW 4.92 COL 87 COLON-ALIGNED
     varadd-info AT ROW 6.25 COL 15 COLON-ALIGNED
     varb-c-cli AT ROW 8.42 COL 20.25 COLON-ALIGNED
     varunit-cli-name AT ROW 8.42 COL 56.75 COLON-ALIGNED
     varunit-cli-long AT ROW 8.42 COL 62.88 COLON-ALIGNED NO-LABEL
     varrate AT ROW 9.71 COL 56.75 COLON-ALIGNED
     varb-c AT ROW 12.04 COL 20.25 COLON-ALIGNED
     varunit-base-name AT ROW 12.04 COL 56.75 COLON-ALIGNED
     varunit-base-long AT ROW 12.04 COL 62.88 COLON-ALIGNED NO-LABEL
     varartic AT ROW 13.29 COL 20.25 COLON-ALIGNED
     vargds-name AT ROW 13.29 COL 40.5 COLON-ALIGNED NO-LABEL
     varprod-type AT ROW 14.33 COL 20.25 COLON-ALIGNED
     varprod-code AT ROW 14.33 COL 26.38 COLON-ALIGNED NO-LABEL
     varprod-name AT ROW 14.33 COL 40.5 COLON-ALIGNED NO-LABEL
     varf-name AT ROW 17 COL 4.75 NO-LABEL
     varpart-code AT ROW 17 COL 6.5 COLON-ALIGNED
     varloc1 AT ROW 17 COL 32.5 COLON-ALIGNED
     varloc2 AT ROW 17 COL 47.63 COLON-ALIGNED
     varin-code AT ROW 17 COL 52.38 COLON-ALIGNED
     varloc3 AT ROW 17 COL 61.75 COLON-ALIGNED
     varfact-date AT ROW 17 COL 74 COLON-ALIGNED
     varloc4 AT ROW 17 COL 78 COLON-ALIGNED
     varTempBarCode AT ROW 7.54 COL 1.88 NO-LABEL
     varTempGoods AT ROW 11.38 COL 1.88 NO-LABEL
     varTempAdd AT ROW 16.17 COL 1.88 NO-LABEL
     varpl-name AT ROW 17 COL 1.5 COLON-ALIGNED NO-LABEL
     "ИСКОМЫЙ КОД" VIEW-AS TEXT
          SIZE 94.88 BY .75 AT ROW 2.92 COL 1.75
          BGCOLOR 7 FGCOLOR 15
     RECT-4 AT ROW 3.25 COL 1.75
     RECT-5 AT ROW 7.96 COL 1.88
     RECT-1 AT ROW 11.58 COL 1.88
     RECT-2 AT ROW 16.38 COL 1.88
     SPACE(0.23) SKIP(1.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Информация по коду (бар-коду)".
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
    ASSIGN adm-object-hdl = FRAME D-Dialog:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartDialog~`':U +
     'DIALOG-BOX~`':U +
     'NO ~`':U +
     '~`':U +
     '~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Layout,Hide-on-Init~`':U +
     '~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE b-exit b-help b-goods b-parts b-place RECT-4 RECT-5 RECT-1 RECT-2 varpl-name WITH FRAME D-Dialog.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN b-exit b-help b-goods b-parts b-place RECT-4 RECT-5 RECT-1 RECT-2 varpl-name WITH FRAME D-Dialog.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
        DEFINE VARIABLE parent-hdl AS HANDLE NO-UNDO.
        IF adm-object-hdl:TYPE = "WINDOW":U THEN
        DO:
          IF p-row = 0 THEN p-row =
            (SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2.
          IF p-col = 0 THEN p-col =
            (SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2.
        END.
        ELSE IF adm-object-hdl:TYPE = "DIALOG-BOX":U THEN
        DO:
          parent-hdl = adm-object-hdl:PARENT.
          IF p-row = 0 THEN p-row =
            ((SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2) -
              parent-hdl:ROW.
          IF p-col = 0 THEN p-col =
            ((SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2) -
              parent-hdl:COL.
        END.
        IF p-row GE 0 AND p-row < 1 THEN p-row = 1.
        IF p-col GE 0 AND p-col < 1 THEN p-col = 1.
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
RUN set-attribute-list ("CURRENT-PAGE=0,ADM-OBJECT-HANDLE=":U +
    STRING(adm-object-hdl)).
PAUSE 0 BEFORE-HIDE.
PROCEDURE adm-change-page :
  RUN broker-change-page IN adm-broker-hdl (INPUT THIS-PROCEDURE) NO-ERROR.
  END PROCEDURE.
PROCEDURE delete-page :
  DEFINE INPUT PARAMETER p-page# AS INTEGER NO-UNDO.
  RUN broker-delete-page IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-page#).
  END PROCEDURE.
PROCEDURE init-object :
  DEFINE INPUT PARAMETER  p-proc-name   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER  p-parent-hdl  AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER  p-attr-list   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-proc-hdl    AS HANDLE    NO-UNDO.
  RUN broker-init-object IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-proc-name, INPUT p-parent-hdl,
       INPUT p-attr-list, OUTPUT p-proc-hdl) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE init-pages :
  DEFINE INPUT PARAMETER p-page-list      AS CHARACTER NO-UNDO.
  RUN broker-init-pages IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page-list) NO-ERROR.
  END PROCEDURE.
PROCEDURE select-page :
  DEFINE INPUT PARAMETER p-page#     AS INTEGER   NO-UNDO.
  RUN broker-select-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#) NO-ERROR.
  END PROCEDURE.
PROCEDURE view-page :
  DEFINE INPUT PARAMETER p-page#      AS INTEGER   NO-UNDO.
  RUN broker-view-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#).
  END PROCEDURE.
ON WINDOW-CLOSE OF FRAME D-Dialog
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-goods IN FRAME D-Dialog
DO:
  find first goods where goods.artic = varartic and
                         goods.prod-type = varprod-type and
                         goods.prod-code = varprod-code no-lock no-error.
  if not available goods then do:
    message "Товар не найден." view-as alert-box.
    return no-apply.
  end.
  run str/showgds.p ( input parparentproc
                     ,input ?
                     ,input goods.gds-code
                     ,input 'ПРОСМОТР':U).
END.
ON CHOOSE OF b-parts IN FRAME D-Dialog
DO:
def var rid-list as char no-undo.
define variable prt-rec as recid no-undo .
find goods where goods.artic     = varartic     and
                goods.prod-type = varprod-type and
                goods.prod-code = varprod-code no-lock no-error.
if not available goods then do:
  message "Товар не найден."
  view-as alert-box error.
  return no-apply.
end.
   run str/parts-l.w
     (input parparentproc
     ,input p-obj-type
     ,input p-obj-code
     ,input goods.gds-code
     ,input ""
     ,input 'ПРОСМОТР':U
     ,input 'все':U
     ,input 'все':U
     ,input 'справочник':U
     ,output prt-rec
     ) .
END.
ON CHOOSE OF b-place IN FRAME D-Dialog
DO:
def var rid-list as char no-undo.
find place where place.obj-type = p-obj-type and
                 place.obj-code = p-obj-code and
                 place.pl-code  = int (varbar-code) no-lock no-error.
if not available place then do:
  message "Складское место не найдено." view-as alert-box error.
  return no-apply.
end.
run ref/pl-list.w (
                  input parparentproc
                , input ""
                , input p-obj-type
                , input p-obj-code
                , input 'объект':U
                , input-output rid-list).
END.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame D-Dialog
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
on choose of b-help in frame D-Dialog
do:
  apply "help":u to frame D-Dialog .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame D-Dialog:width - 0.3
                fh            = frame D-Dialog:first-child
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
IF THIS-PROCEDURE:PERSISTENT THEN DO:
    MESSAGE "A SmartDialog is not intended ":U SKIP
            "to be run Persistent or to be placed ":U SKIP
            "in another SmartObject at UIB design time.":U
            VIEW-AS ALERT-BOX ERROR.
    RUN disable_UI.
    DELETE PROCEDURE THIS-PROCEDURE.
    RETURN.
END.
RUN dispatch ('create-objects':U).
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME D-Dialog:PARENT eq ?
THEN FRAME D-Dialog:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  WAIT-FOR GO OF FRAME D-Dialog.
END.
RUN dispatch IN THIS-PROCEDURE ('destroy':U).
PROCEDURE adm-create-objects :
END PROCEDURE.
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
RUN notify IN THIS-PROCEDURE ('row-available':U).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME D-Dialog.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY varbar-code varentity vartype-bc varwt varadd-info varb-c-cli
          varunit-cli-name varunit-cli-long varrate varb-c varunit-base-name
          varunit-base-long varartic vargds-name varprod-type varprod-code
          varprod-name varf-name varpart-code varloc1 varloc2 varin-code varloc3
          varfact-date varloc4 varTempBarCode varTempGoods varTempAdd varpl-name
      WITH FRAME D-Dialog.
  ENABLE b-exit b-help b-goods b-parts b-place RECT-4 RECT-5 RECT-1 RECT-2
         varpl-name
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
END PROCEDURE.
PROCEDURE local-initialize :
  find un-bc where recid(un-bc) = rec-id.
  assign
  varbar-code       = un-bc.bar-code
  varentity         = un-bc.entity
  vartype-bc        = un-bc.type-bc
  varrate           = un-bc.rate
  varwt             = un-bc.wt
  varb-c-cli        = un-bc.b-c
  varunit-cli-name  = un-bc.unit-name
  varunit-cli-long  = un-bc.long-name
  varb-c            = un-bc.b-c-base
  varunit-base-name = un-bc.unit-name-base
  varunit-base-long = un-bc.long-name-base
  varartic          = un-bc.artic
  varprod-type      = un-bc.prod-type
  varprod-code      = un-bc.prod-code
  vargds-name       = un-bc.gds-name
  varprod-name      = un-bc.prod-name
  varpl-name        = un-bc.pl-name
  varloc1           = un-bc.loc1
  varloc2           = un-bc.loc2
  varloc3           = un-bc.loc3
  varloc4           = un-bc.loc4
  varf-name         = un-bc.f-name
  varin-code        = un-bc.in-code
  varfact-date      = un-bc.fact-date
  varpart-code      = un-bc.part-code
  varTempAdd        = varentity
  .
  if length (varbar-code) = 13 then do:
    run gbl/bcextinf.p
      (input 'EAN13':U
      ,input varbar-code
      ,output varadd-info
      ) .
  end.
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  IF varentity <> 'ТОВАР':U    AND
     varentity <> 'ПРИЗНАК':U AND
     varentity <> 'ПАРТИЯ':U     THEN
     HIDE varrate           in frame D-Dialog
          varb-c-cli        in frame D-Dialog
          varunit-cli-name  in frame D-Dialog
          varunit-cli-long  in frame D-Dialog
          varb-c            in frame D-Dialog
          varunit-base-name in frame D-Dialog
          varunit-base-long in frame D-Dialog
          varartic          in frame D-Dialog
          vargds-name       in frame D-Dialog
          varprod-type      in frame D-Dialog
          varprod-code      in frame D-Dialog
          varprod-name      in frame D-Dialog
          b-goods           in frame D-Dialog
          RECT-1            in frame D-Dialog
          RECT-5            in frame D-Dialog
          varTempBarCode    in frame D-Dialog
          varTempGoods      in frame D-Dialog.
  IF varentity <> 'СКЛАДСКОЕ МЕСТО':U  AND
     varentity <> 'ПРИЗНАК':U     AND
     varentity <> 'ПАРТИЯ':U         THEN
     HIDE
       RECT-2     in frame D-Dialog
       varTempAdd in frame D-Dialog.
  IF varentity <> 'ПРИЗНАК':U THEN
     HIDE varf-name in frame D-Dialog.
  IF varentity <> 'ПАРТИЯ':U  THEN
     HIDE varfact-date in frame D-Dialog
          varin-code   in frame D-Dialog
          varpart-code in frame D-Dialog
          b-parts      in frame D-Dialog.
  IF varentity <> 'СКЛАДСКОЕ МЕСТО':U THEN
     HIDE varpl-name in frame D-Dialog
          varloc1 in frame D-Dialog
          varloc2 in frame D-Dialog
          varloc3 in frame D-Dialog
          varloc4 in frame D-Dialog
          b-place in frame D-Dialog.
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.
