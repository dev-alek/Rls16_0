DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE TT-gds-obj NO-UNDO LIKE ub.gds-obj.
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods.
CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр текущих остатков по объекту".
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
define shared variable varparentproc as widget-handle no-undo.
define variable varqnty as integer no-undo.
define variable g-log as logical no-undo.
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL " БАЗОВАЯ ВАЛЮТА"
      VIEW-AS TEXT
     SIZE 16.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL " abbr_rubli_allshift"
      VIEW-AS TEXT
     SIZE 7 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.3 BY 5.03.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.3 BY 5.03.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79.4 BY 2.07.
DEFINE FRAME F-Main
     TT-gds-obj.fact-qnty AT ROW 1.53 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     TT-gds-obj.price-sale AT ROW 2.43 COL 55.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 22.9 BY 1
     TT-gds-obj.fact-cli-qnty AT ROW 2.8 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     TT-gds-obj.free-qnty AT ROW 3.93 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     TT-gds-obj.fact-sale AT ROW 4 COL 55.6 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     TT-gds-obj.avrg-qnty AT ROW 5.13 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     TT-gds-obj.fact-base AT ROW 7.53 COL 23.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 22.9 BY 1
     TT-gds-obj.fact-rubl AT ROW 7.53 COL 52.1 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     FILL-IN-1 AT ROW 6.5 COL 24 COLON-ALIGNED NO-LABEL
     FILL-IN-2 AT ROW 6.5 COL 52.5 COLON-ALIGNED NO-LABEL
     "Положительные партии" VIEW-AS TEXT
          SIZE 21 BY .93 AT ROW 5.13 COL 2.8
     "Факт.кол-во" VIEW-AS TEXT
          SIZE 21 BY .93 AT ROW 1.67 COL 2.8
     "Сумма в прод.ценах" VIEW-AS TEXT
          SIZE 18.1 BY .93 AT ROW 4.03 COL 38.9
     "Сумма в учетных ценах" VIEW-AS TEXT
          SIZE 21.9 BY .93 AT ROW 7.53 COL 2.5
     "Продажная цена" VIEW-AS TEXT
          SIZE 17.9 BY .93 AT ROW 2.43 COL 39.1
     "Факт.кол-во(ед.пост.)" VIEW-AS TEXT
          SIZE 21 BY .93 AT ROW 2.8 COL 2.8
     "Свободно" VIEW-AS TEXT
          SIZE 21 BY .93 AT ROW 4 COL 2.8
     RECT-1 AT ROW 1.2 COL 1.1
     RECT-2 AT ROW 1.2 COL 37.9
     RECT-3 AT ROW 6.93 COL 1.6
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
      adm-object-hdl = FRAME F-Main:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartObject~`':U +
     '~`':U +
     'NO ~`':U +
     '~`':U +
     '~`':U +
     'TT-gds-obj~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Initial-Lock,Hide-on-Init,Disable-on-Init,Key-Name,Layout,Create-On-Add~`':U +
     'Record-Source,Record-Target,TableIO-Target~`':U +
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
    DISABLE RECT-1 RECT-2 RECT-3 FILL-IN-1 FILL-IN-2 WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-1 RECT-2 RECT-3 FILL-IN-1 FILL-IN-2 WITH FRAME F-Main.
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
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-display-fields :
    RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-open-query :
  RETURN.
END PROCEDURE.
PROCEDURE adm-row-changed :
      IF VALID-HANDLE(adm-object-hdl) THEN
        RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
      RUN notify ('row-available':U).
      RETURN.
END PROCEDURE.
PROCEDURE reposition-query :
    DEFINE INPUT PARAMETER p-requestor-hdl     AS HANDLE NO-UNDO.
    RUN set-attribute-list ('REPOSITION-PENDING = NO':U).
    RETURN.
END PROCEDURE.
  DEFINE VARIABLE adm-first-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-second-table        AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-third-table         AS ROWID NO-UNDO.
  DEFINE VARIABLE adm-adding-record       AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE adm-return-status       AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-first-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-second-prev-rowid   AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-third-prev-rowid    AS ROWID     NO-UNDO.
  DEFINE VARIABLE adm-first-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-second-tmpl-recid   AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-third-tmpl-recid    AS RECID     NO-UNDO INIT ?.
  DEFINE VARIABLE adm-index-pos           AS INTEGER   NO-UNDO.
  DEFINE VARIABLE adm-query-empty         AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-complete     AS LOGICAL   NO-UNDO.
  DEFINE VARIABLE adm-create-on-add       AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-assign-target     AS LOGICAL   NO-UNDO INIT ?.
  DEFINE VARIABLE group-target-list       AS CHARACTER NO-UNDO INIT ?.
  IF "TT-gds-obj":U = "":U THEN
    RUN modify-list-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, "REMOVE":U, "SUPPORTED-LINKS":U, "TABLEIO-TARGET":U).
  RUN use-create-on-add(?).
PROCEDURE adm-add-record :
   DEFINE VARIABLE trans-hdl-string  AS CHARACTER NO-UNDO.
   DEFINE VARIABLE cntr              AS INTEGER   NO-UNDO.
   DEFINE VARIABLE temp-rowid        AS ROWID     NO-UNDO.
   DEFINE VARIABLE saved-dictdb      AS CHARACTER NO-UNDO.
      IF group-assign-target = ? THEN
        RUN init-group-assign.
      IF NOT group-assign-target THEN
        RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
      ASSIGN adm-first-table = ROWID(TT-gds-obj)
             adm-new-record = yes
             adm-adding-record = yes
             adm-query-empty = IF AVAILABLE(TT-gds-obj)
                               THEN no ELSE yes.
      RUN set-attribute-list ("ADM-NEW-RECORD=yes,ADM-QUERY-EMPTY-ON-ADD=":U +
        IF adm-query-empty THEN "yes":U ELSE "no":U).
      RUN dispatch('enable-fields':U).
      IF (adm-create-on-add = no) AND (adm-first-tmpl-recid = ?) AND
         (DBTYPE(LDBNAME(BUFFER TT-gds-obj)) EQ "PROGRESS":U)
      THEN DO:
          saved-dictdb = LDBNAME("DICTDB":U).
          CREATE ALIAS DICTDB FOR DATABASE
            VALUE(LDBNAME(BUFFER TT-gds-obj)).
          RUN adm/objects/get-init.p (INPUT "TT-gds-obj":U,
            OUTPUT adm-first-tmpl-recid).
          CREATE ALIAS DICTDB FOR DATABASE
            VALUE(saved-dictdb).
        END.
          IF adm-create-on-add = no THEN
          DO:
           IF DBTYPE(LDBNAME(BUFFER TT-gds-obj))
             EQ "PROGRESS":U THEN
           DO:
            FIND TT-gds-obj WHERE
              RECID(TT-gds-obj) = adm-first-tmpl-recid
                NO-LOCK.
            DISPLAY UNLESS-HIDDEN TT-gds-obj.fact-qnty TT-gds-obj.price-sale TT-gds-obj.fact-cli-qnty TT-gds-obj.free-qnty TT-gds-obj.fact-sale TT-gds-obj.avrg-qnty TT-gds-obj.fact-base TT-gds-obj.fact-rubl
              WITH FRAME F-Main NO-ERROR.
           END.
          END.
          ELSE DO:
           DO TRANSACTION ON STOP  UNDO, RETURN "ADM-ERROR":U
                          ON ERROR UNDO, RETURN "ADM-ERROR":U:
             adm-create-complete = no.
             RUN dispatch ('create-record':U).
             IF RETURN-VALUE = "ADM-ERROR":U THEN UNDO, RETURN "ADM-ERROR":U.
             DISPLAY UNLESS-HIDDEN TT-gds-obj.fact-qnty TT-gds-obj.price-sale TT-gds-obj.fact-cli-qnty TT-gds-obj.free-qnty TT-gds-obj.fact-sale TT-gds-obj.avrg-qnty TT-gds-obj.fact-base TT-gds-obj.fact-rubl
                WITH FRAME F-Main NO-ERROR.
           END.
           adm-create-complete = yes.
          END.
      RUN notify ('add-record, GROUP-ASSIGN-TARGET':U).
      RUN new-state('update':U).
      RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-assign-record :
        IF group-assign-target = ? THEN
          RUN init-group-assign.
        adm-updating-record = yes.
        IF adm-new-record THEN DO:
          IF (NOT adm-adding-record) OR
              (NOT adm-create-on-add) THEN
          DO:
             RUN dispatch ('create-record':U).
             IF RETURN-VALUE = "ADM-ERROR":U THEN UNDO, RETURN "ADM-ERROR":U.
          END.
          IF adm-create-on-add = yes THEN
          DO:
            RUN dispatch ('current-changed':U).
            IF RETURN-VALUE = "ADM-ERROR":U THEN
               RETURN "ADM-ERROR":U.
          END.
        END.
        ELSE DO:
            RUN dispatch ('current-changed':U).
            IF RETURN-VALUE = "ADM-ERROR":U THEN
               RETURN "ADM-ERROR":U.
        END.
        RUN dispatch ('assign-statement':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
            UNDO, RETURN "ADM-ERROR":U.
        RUN notify ('assign-record,GROUP-ASSIGN-TARGET':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN UNDO, RETURN "ADM-ERROR":U.
        IF adm-new-record THEN
        DO:
            RUN get-attribute('Query-Position':U).
            IF RETURN-VALUE = 'no-record-available':U THEN
            DO:
              RUN new-state('record-available':U).
              RUN set-attribute-list('Query-Position = record-available':U).
            END.
            RUN dispatch('display-fields':U).
        END.
   RETURN.
  END PROCEDURE.
PROCEDURE adm-assign-statement :
        ASSIGN FRAME F-Main TT-gds-obj.fact-base TT-gds-obj.fact-rubl
              NO-ERROR.
    IF ERROR-STATUS:ERROR THEN
    DO:
      RUN dispatch('show-errors':U).
      UNDO, RETURN "ADM-ERROR":U.
    END.
  RETURN.
END PROCEDURE.
PROCEDURE adm-cancel-record :
  DEFINE VARIABLE source-str          AS CHARACTER NO-UNDO.
   RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
   IF adm-new-record THEN
   DO:
      IF (adm-adding-record = yes) AND
         (adm-create-on-add = no)
      THEN DO:
        RELEASE TT-gds-obj NO-ERROR.
      END.
      ELSE IF (adm-adding-record = yes) AND
        (adm-create-on-add = yes) AND
          (adm-create-complete = yes)
      THEN RUN dispatch ('delete-record':U).
          IF adm-new-record THEN
          DO:
            IF group-assign-target THEN
            DO:
              RUN request-attribute IN adm-broker-hdl
                (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U,
                 'ADM-QUERY-EMPTY-ON-ADD':U).
              adm-query-empty = IF RETURN-VALUE = "YES":U THEN yes
                ELSE IF RETURN-VALUE = "NO":U THEN no ELSE ?.
            END.
            IF adm-query-empty THEN
            DO:
              RUN dispatch ('disable-fields':U).
              RUN dispatch ('display-fields':U).
            END.
          END.
      adm-new-record = no.
      RUN set-attribute-list ("ADM-NEW-RECORD=no":U).
   END.
   ELSE RUN dispatch ('display-fields':U).
   RUN notify ('cancel-record, GROUP-ASSIGN-TARGET':U).
   RUN dispatch ('apply-entry':U).
   RUN get-link-handle IN adm-broker-hdl
       (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, OUTPUT source-str).
   adm-updating-record = no.
   IF source-str EQ "":U THEN
     RUN new-state('update-complete':U).
   RETURN.
  END PROCEDURE.
PROCEDURE adm-copy-record :
   DEFINE VARIABLE trans-hdl-string AS CHARACTER NO-UNDO.
      IF group-assign-target = ? THEN
        RUN init-group-assign.
      IF NOT group-assign-target THEN
        RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
      ASSIGN adm-first-table = ROWID(TT-gds-obj)
             adm-new-record = yes
             adm-adding-record = no.
      RUN set-attribute-list ("ADM-NEW-RECORD=yes":U).
      RUN dispatch('enable-fields':U).
          RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
      RUN notify ('copy-record, GROUP-ASSIGN-TARGET':U).
      RUN new-state('update':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-create-record :
    DEFINE VARIABLE source-str          AS CHARACTER NO-UNDO.
    DEFINE VARIABLE source-rowid-str    AS CHARACTER NO-UNDO.
       IF group-assign-target = yes THEN
       DO:
         RUN get-link-handle IN adm-broker-hdl
           (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U,
              OUTPUT source-str).
         RUN send-records IN WIDGET-HANDLE (source-str)
             (INPUT "TT-gds-obj":U,
              OUTPUT source-rowid-str).
         FIND TT-gds-obj WHERE
             ROWID (TT-gds-obj) =
                 TO-ROWID(source-rowid-str) NO-ERROR.
         IF ERROR-STATUS:ERROR THEN
         DO:
           RUN dispatch('show-errors':U).
           UNDO, RETURN "ADM-ERROR":U.
         END.
       END.
       ELSE DO:
           CREATE TT-gds-obj NO-ERROR.
           IF ERROR-STATUS:ERROR THEN
           DO:
             RUN dispatch('show-errors':U).
             UNDO, RETURN "ADM-ERROR":U.
           END.
       END.
   RETURN.
END PROCEDURE.
PROCEDURE adm-current-changed :
   ASSIGN adm-first-table = ROWID(TT-gds-obj).
  IF NOT group-assign-target THEN
  DO:
    FIND CURRENT TT-gds-obj EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    IF NOT AVAILABLE TT-gds-obj THEN
    DO:
      RUN dispatch('show-errors':U).
      IF ERROR-STATUS:GET-NUMBER(1) = 138 THEN
          RUN dispatch('get-next':U).
      ELSE FIND TT-gds-obj WHERE
          ROWID(TT-gds-obj) = adm-first-table NO-LOCK NO-ERROR.
      RETURN "ADM-ERROR":U.
    END.
    ELSE IF CURRENT-CHANGED TT-gds-obj THEN
    DO:
      MESSAGE  SUBSTITUTE
          ("Sorry, this &1 has been changed by another user. ",
            "TT-gds-obj") SKIP
            "Please note any differences and re-enter your changes."
                   VIEW-AS ALERT-BOX.
      RUN dispatch ('display-fields':U).
      UNDO, RETURN "ADM-ERROR":U.
    END.
  END.
  RETURN.
END PROCEDURE.
PROCEDURE adm-delete-record :
   DEFINE VARIABLE delete-failed AS LOGICAL NO-UNDO INIT no.
   IF group-assign-target = ? THEN
     RUN init-group-assign.
      DO TRANSACTION ON STOP UNDO, LEAVE ON ERROR UNDO, LEAVE:
        IF group-assign-target NE yes THEN
        DO:
          FIND CURRENT TT-gds-obj EXCLUSIVE-LOCK NO-WAIT
            NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
          DO:
            RUN dispatch('show-errors':U).
            UNDO, RETURN "ADM-ERROR":U.
          END.
          DELETE TT-gds-obj NO-ERROR.
        END.
        IF ERROR-STATUS:ERROR THEN
        DO:
          RUN dispatch('show-errors':U).
          delete-failed = yes.
        END.
      END.
         IF (NOT delete-failed) AND
            (NOT adm-new-record) THEN
         RUN new-state ('delete-complete':U).
      IF delete-failed THEN
          UNDO, RETURN "ADM-ERROR":U.
    RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-disable-fields :
           DISABLE UNLESS-HIDDEN TT-gds-obj.fact-base TT-gds-obj.fact-rubl
             WITH FRAME F-Main.
           RUN set-editors('DISABLE':U).
       RUN set-attribute-list ("FIELDS-ENABLED=no":U).
      RUN notify ('disable-fields, GROUP-ASSIGN-TARGET':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-enable-fields :
        RUN get-attribute ("FIELDS-ENABLED":U).
        IF RETURN-VALUE NE "YES":U THEN
        DO:
          IF NOT adm-new-record THEN
          DO:
            IF AVAILABLE(TT-gds-obj) AND
              adm-initial-lock = "SHARE-LOCK":U OR
                adm-initial-lock = "EXCLUSIVE-LOCK":U THEN
            DO:
                IF adm-initial-lock = "SHARE-LOCK":U THEN
                  FIND CURRENT TT-gds-obj SHARE-LOCK NO-WAIT
                    NO-ERROR.
                ELSE IF AVAILABLE (TT-gds-obj) THEN
                DO TRANSACTION:
                  FIND CURRENT TT-gds-obj
                   EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                END.
                IF ERROR-STATUS:ERROR THEN
                DO:
                  RUN dispatch('show-errors':U).
                  UNDO, RETURN "ADM-ERROR":U.
                END.
                RUN dispatch ('display-fields':U).
            END.
         END.
                ENABLE UNLESS-HIDDEN TT-gds-obj.fact-base TT-gds-obj.fact-rubl
                  WITH FRAME F-Main.
                RUN set-editors('ENABLE':U).
            RUN set-attribute-list ("FIELDS-ENABLED=yes":U).
        END.
        RUN notify ('enable-fields, GROUP-ASSIGN-TARGET':U).
        RUN dispatch ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-end-update :
  DEFINE VARIABLE source-str          AS CHARACTER NO-UNDO.
   IF ERROR-STATUS:ERROR THEN
       RUN dispatch('show-errors':U).
   RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
   RUN get-link-handle IN adm-broker-hdl
      (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, OUTPUT source-str).
   IF adm-new-record AND NOT TRANSACTION THEN DO:
          adm-new-record = no.
          RUN set-attribute-list ("ADM-NEW-RECORD=no":U).
          ASSIGN adm-first-table = ROWID(TT-gds-obj).
          IF source-str EQ "":U THEN
          DO:
              RUN set-link-attribute IN adm-broker-hdl
                  (THIS-PROCEDURE, 'RECORD-SOURCE':U,
                   'REPOSITION-PENDING=yes':U).
              RUN notify('open-query':U).
              RUN request IN adm-broker-hdl (INPUT THIS-PROCEDURE,
                  INPUT 'RECORD-SOURCE':U, INPUT 'reposition-query':U).
          END.
   END.
    FIND CURRENT TT-gds-obj NO-LOCK NO-ERROR.
    RUN notify('end-update, GROUP-ASSIGN-TARGET':U).
    IF source-str EQ "":U THEN
        RUN new-state('update-complete':U).
    adm-updating-record = no.
    RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-reset-record :
     RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
     RUN notify ('reset-record, GROUP-ASSIGN-TARGET':U).
     RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-update-record :
      DEFINE VARIABLE cRecordSrc AS CHARACTER NO-UNDO.
      DEFINE VARIABLE hRecordSrc AS HANDLE     NO-UNDO.
      DEFINE BUFFER bNewRecord FOR TT-gds-obj.
      DO TRANSACTION ON STOP  UNDO, RETURN "ADM-ERROR":U
                     ON ERROR UNDO, RETURN "ADM-ERROR":U :
        RUN dispatch ('assign-record':U).
        IF  RETURN-VALUE = "ADM-ERROR":U THEN
            RETURN "ADM-ERROR":U.
      END.
      RUN dispatch ('end-update':U).
      FIND FIRST bNewRecord NO-LOCK NO-ERROR.
      IF NOT ERROR-STATUS:ERROR AND ROWID(bNewRecord) = ROWID (TT-gds-obj) THEN
      DO:
        RUN get-link-handle IN adm-broker-hdl
            (INPUT THIS-PROCEDURE,
             INPUT "RECORD-SOURCE",
             OUTPUT cRecordSrc).
        hRecordSrc = WIDGET-HANDLE(cRecordSrc).
        IF VALID-HANDLE(hRecordSrc) THEN
        DO:
            RUN get-attribute IN hRecordSrc ("TYPE":U).
            IF RETURN-VALUE = "SmartQuery":U AND
               CAN-DO(hRecordSrc:INTERNAL-ENTRIES,"new-first-record") THEN
               RUN new-first-record IN hRecordSrc (INPUT ROWID (TT-gds-obj)).
        END.
      END.
   RETURN.
END PROCEDURE.
PROCEDURE check-modified :
DEFINE INPUT PARAMETER check-state AS CHARACTER NO-UNDO.
DEFINE VARIABLE curr-widget       AS HANDLE      NO-UNDO.
DEFINE VARIABLE container-hdl-str AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i                 AS INTEGER     NO-UNDO.
  IF NOT VALID-HANDLE(adm-object-hdl) THEN RETURN.
  IF group-assign-target = ? THEN
    RUN init-group-assign.
  IF check-state = "check":U AND group-assign-target THEN
    RETURN "":U.
  ELSE IF check-state = "group-check":U THEN
     check-state = "check":U.
  IF VALID-HANDLE(FRAME F-Main:HANDLE) AND
      AVAILABLE(TT-gds-obj) THEN
  DO:
    ASSIGN curr-widget = FRAME F-Main:FIRST-CHILD.
    ASSIGN curr-widget = curr-widget:FIRST-CHILD.
    DO WHILE VALID-HANDLE (curr-widget):
        IF LOOKUP (curr-widget:TYPE,
        "FILL-IN,COMBO-BOX,EDITOR,RADIO-SET,SELECTION-LIST,SLIDER,TOGGLE-BOX":U)
            NE 0 AND
                 (adm-check-modified-all = yes OR curr-widget:SENSITIVE) AND
                 (adm-check-modified-all = yes OR curr-widget:TABLE NE ?)
                 AND curr-widget:MODIFIED THEN
        DO:
            IF check-state = "check":U THEN
            DO:
                RUN check-modified-message(curr-widget:TABLE).
                RETURN.
            END.
            ELSE IF check-state = "clear":U THEN
                curr-widget:MODIFIED = no.
        END.
        ASSIGN curr-widget = curr-widget:NEXT-SIBLING.
    END.
  END.
  IF check-state = "check":U THEN
  DO:
    RUN get-link-handle IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT 'GROUP-ASSIGN-TARGET':U,
         OUTPUT group-target-list).
    IF group-target-list NE "":U THEN
    DO i = 1 TO NUM-ENTRIES(group-target-list):
      curr-widget = WIDGET-HANDLE(ENTRY(i, group-target-list)).
      RUN check-modified IN curr-widget ('group-check':U).
      IF RETURN-VALUE NE "":U THEN
      DO:
        RUN check-modified-message(RETURN-VALUE).
        RETURN "":U.
      END.
    END.
  END.
  RETURN "":U.
END PROCEDURE.
PROCEDURE check-modified-message :
  DEFINE INPUT PARAMETER p-changed-table AS CHARACTER NO-UNDO.
     RUN request-attribute IN adm-broker-hdl (THIS-PROCEDURE,
        'CONTAINER-SOURCE':U, 'HIDDEN':U).
     IF RETURN-VALUE = "YES":U THEN
        RUN notify ('view,CONTAINER-SOURCE':U).
     MESSAGE IF p-changed-table NE ? THEN
        SUBSTITUTE ("Current &1 record has been changed.", p-changed-table)
        ELSE "Current values have been changed."
        SKIP "  Do you wish to save those changes?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE ANS AS LOGICAL.
     IF ANS THEN
     DO:
        IF group-assign-target THEN
          RUN notify('update-record,GROUP-ASSIGN-SOURCE':U).
        ELSE RUN dispatch('update-record':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
            MESSAGE "Changes to the previous record were not saved."
              VIEW-AS ALERT-BOX ERROR.
            IF group-assign-target THEN
              RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
            ELSE RUN dispatch ('cancel-record':U).
        END.
     END.
     ELSE DO:
       IF group-assign-target THEN
          RUN notify('cancel-record,GROUP-ASSIGN-SOURCE':U).
       ELSE RUN dispatch('cancel-record':U).
     END.
     RETURN.
END PROCEDURE.
PROCEDURE get-rowid :
    DEFINE OUTPUT PARAMETER p-table           AS ROWID NO-UNDO.
    ASSIGN
    p-table   =   adm-first-table.
    RETURN.
END PROCEDURE.
PROCEDURE init-group-assign :
    RUN request-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, 'GROUP-ASSIGN-SOURCE':U, 'ENABLED-TABLES':U).
    IF LOOKUP("TT-gds-obj":U, RETURN-VALUE, " ":U) NE 0 THEN
      group-assign-target = yes.
    ELSE group-assign-target = no.
    RETURN.
END PROCEDURE.
PROCEDURE set-editors :
    DEFINE INPUT PARAMETER p-field-setting  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE curr-widget             AS HANDLE    NO-UNDO.
    DEFINE VARIABLE read-only-list          AS CHARACTER NO-UNDO INIT "":U.
    ASSIGN curr-widget = FRAME F-Main:CURRENT-ITERATION.
    ASSIGN curr-widget = curr-widget:FIRST-CHILD.
    DO WHILE VALID-HANDLE (curr-widget):
        IF curr-widget:TYPE = "EDITOR":U AND curr-widget:TABLE NE ? AND
           curr-widget:HIDDEN = no THEN DO:
          CASE p-field-setting:
            WHEN "INITIALIZE":U THEN
            DO:
              IF curr-widget:READ-ONLY = yes THEN read-only-list =
                  read-only-list +
                    (IF read-only-list NE "":U THEN ",":U ELSE "":U) +
                     STRING(curr-widget).
            END.
            WHEN "DISABLE":U OR
            WHEN "ENABLE":U THEN
            DO:
                curr-widget:SENSITIVE = yes.
                RUN get-attribute ('Read-Only-Editors':U).
                IF RETURN-VALUE = ? OR
                  LOOKUP (STRING(curr-widget), RETURN-VALUE) EQ 0 THEN
                    curr-widget:READ-ONLY =
                      IF p-field-setting = "ENABLE":U THEN no ELSE yes.
            END.
            WHEN "CLEAR":U THEN
                curr-widget:SCREEN-VALUE = "":U.
          END CASE.
        END.
        ASSIGN curr-widget = curr-widget:NEXT-SIBLING.
    END.
    IF p-field-setting = "INITIALIZE":U AND read-only-list NE "":U THEN
      RUN set-attribute-list ('Read-Only-Editors = "':U + read-only-list
        + '"':U).
    RETURN.
END PROCEDURE.
PROCEDURE use-check-modified-all :
 DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-check-modified-all = IF p-attr-value = "YES":U THEN yes ELSE no.
  RETURN.
END PROCEDURE.
PROCEDURE use-create-on-add :
DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
      ASSIGN adm-create-on-add =
          IF (p-attr-value EQ "NO":U) OR
             (p-attr-value NE "YES":U AND
           DBTYPE(LDBNAME(BUFFER TT-gds-obj)) EQ "PROGRESS":U)
          THEN no ELSE yes.
   RETURN.
END PROCEDURE.
PROCEDURE use-initial-lock :
  DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-initial-lock = p-attr-value.
  RETURN.
END PROCEDURE.
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in varparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
assign
  FILL-IN-2 = " РУБЛИ"
.
display
  fill-in-1
  fill-in-2
  with frame F-Main .
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.
  for each tt-gds-obj:
      delete tt-gds-obj.
  end.
  assign varqnty = 0.
  for each tt-goods,
      each tt-clients:
      assign varqnty = varqnty + 1.
      find first ub.gds-obj where ub.gds-obj.obj-type  = tt-clients.obj-type and
                                  ub.gds-obj.obj-code  = tt-clients.obj-code and
                                  ub.gds-obj.artic     = tt-goods.artic      and
                                  ub.gds-obj.prod-type = tt-goods.prod-type  and
                                  ub.gds-obj.prod-code = tt-goods.prod-code  no-lock no-error.
      if available ub.gds-obj then do:
         find first tt-gds-obj no-lock no-error.
         if not available tt-gds-obj then do:
            create tt-gds-obj.
            buffer-copy gds-obj to tt-gds-obj.
         end.
         else do:
             assign
             tt-gds-obj.fact-qnty     = tt-gds-obj.fact-qnty     + ub.gds-obj.fact-qnty
             tt-gds-obj.fact-cli-qnty = tt-gds-obj.fact-cli-qnty + ub.gds-obj.fact-cli-qnty
             tt-gds-obj.free-qnty     = tt-gds-obj.free-qnty     + ub.gds-obj.free-qnty
             tt-gds-obj.avrg-qnty     = tt-gds-obj.avrg-qnty     + ub.gds-obj.avrg-qnty
             tt-gds-obj.fact-sale     = tt-gds-obj.fact-sale     + ub.gds-obj.fact-sale
             tt-gds-obj.fact-base     = tt-gds-obj.fact-base     + ub.gds-obj.fact-base
             tt-gds-obj.fact-rubl     = tt-gds-obj.fact-rubl     + ub.gds-obj.fact-rubl.
         end.
      end.
  end.
  if varqnty > 1
  then do:
    assign tt-gds-obj.price-sale = ?.
  end.
  if available tt-gds-obj
  then do:
    display tt-gds-obj.fact-qnty tt-gds-obj.fact-cli-qnty tt-gds-obj.free-qnty tt-gds-obj.avrg-qnty
            tt-gds-obj.fact-sale
            tt-gds-obj.price-sale
            with frame F-Main.
    define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-gds-obj.obj-type
  ,input  tt-gds-obj.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  tt-gds-obj.obj-type
    ,input  tt-gds-obj.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
    if g-log then display tt-gds-obj.fact-base tt-gds-obj.fact-rubl
                          with frame F-Main.
           else hide tt-gds-obj.fact-base tt-gds-obj.fact-rubl
                     in frame F-Main.
  end.
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
    WHEN 'update-begin':U THEN DO:
        RUN dispatch('enable-fields':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
          RUN new-state('update-failed,TABLEIO-SOURCE':U).
          RUN new-state('update-complete':U).
        END.
        ELSE RUN new-state ('update':U).
    END.
    WHEN 'update-complete':U THEN DO:
        RUN new-state ('update-complete':U).
    END.
  END CASE.
END PROCEDURE.
