CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр шапки документа".
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
DEFINE QUERY external_tables FOR ub.trn-doc.
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
DEFINE FRAME F-Main
     ub.trn-doc.tot-rubl AT ROW 1.17 COL 72.5 COLON-ALIGNED
          LABEL "tot-rubl"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     ub.trn-doc.tot-other AT ROW 1.2 COL 38 COLON-ALIGNED
          LABEL "tot-other"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.fact-qnty AT ROW 1.3 COL 12 COLON-ALIGNED
          LABEL "fact-qnty"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     ub.trn-doc.tot-sale AT ROW 2.3 COL 72.5 COLON-ALIGNED
          LABEL "tot-sale"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.fact-base AT ROW 2.37 COL 38 COLON-ALIGNED
          LABEL "fact-base"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.doc-qnty AT ROW 2.5 COL 12 COLON-ALIGNED
          LABEL "doc-qnty"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     ub.trn-doc.tot-transp AT ROW 3.5 COL 72.5 COLON-ALIGNED
          LABEL "tot-transp"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.fact-rubl AT ROW 3.53 COL 38 COLON-ALIGNED
          LABEL "fact-rubl"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     ub.trn-doc.discnt-type AT ROW 3.67 COL 12 COLON-ALIGNED
          LABEL "discnt-type"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     ub.trn-doc.exch-code AT ROW 4.57 COL 38 COLON-ALIGNED
          LABEL "exch-code"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.trn-doc.VAT-base AT ROW 4.67 COL 72.5 COLON-ALIGNED
          LABEL "VAT-base"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.print-rubl AT ROW 4.7 COL 12 COLON-ALIGNED
          LABEL "print-rubl"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.trn-doc.exch-date AT ROW 5.7 COL 38 COLON-ALIGNED
          LABEL "exch-date"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     ub.trn-doc.VAT-rubl AT ROW 5.77 COL 72.5 COLON-ALIGNED
          LABEL "VAT-rubl"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     ub.trn-doc.shift-date AT ROW 5.97 COL 12 COLON-ALIGNED
          LABEL "shift-date"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     ub.trn-doc.exch-rate AT ROW 6.8 COL 38 COLON-ALIGNED
          LABEL "exch-rate"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     ub.trn-doc.VAT-type AT ROW 6.93 COL 72.5 COLON-ALIGNED
          LABEL "VAT-type"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     ub.trn-doc.shift-num AT ROW 7.2 COL 12 COLON-ALIGNED
          LABEL "shift-num"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     ub.trn-doc.exch-scale AT ROW 7.87 COL 38 COLON-ALIGNED
          LABEL "exch-scale"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     ub.trn-doc.SLT-base AT ROW 8 COL 72.5 COLON-ALIGNED
          LABEL "SLT-base"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.ship-date AT ROW 8.33 COL 12 COLON-ALIGNED
          LABEL "ship-date"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     ub.trn-doc.pay-code AT ROW 8.87 COL 38 COLON-ALIGNED
          LABEL "pay-code"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     ub.trn-doc.SLT-rubl AT ROW 9.17 COL 72.5 COLON-ALIGNED
          LABEL "SLT-rubl"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     ub.trn-doc.tot-ov AT ROW 9.53 COL 12 COLON-ALIGNED
          LABEL "tot-ov"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .
DEFINE FRAME F-Main
     ub.trn-doc.tot-calc AT ROW 10.03 COL 38 COLON-ALIGNED
          LABEL "tot-calc"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.SLT-type AT ROW 10.3 COL 72.5 COLON-ALIGNED
          LABEL "SLT-type"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     ub.trn-doc.base-rate AT ROW 10.8 COL 12 COLON-ALIGNED
          LABEL "base-rate"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     ub.trn-doc.road-tax AT ROW 11.27 COL 72.5 COLON-ALIGNED
          LABEL "road-tax"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     ub.trn-doc.tot-cli AT ROW 11.33 COL 38 COLON-ALIGNED
          LABEL "tot-cli"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.base-scale AT ROW 11.97 COL 12 COLON-ALIGNED
          LABEL "base-scale"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     ub.trn-doc.excise AT ROW 12.37 COL 72.5 COLON-ALIGNED
          LABEL "excise"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     ub.trn-doc.tot-doc AT ROW 12.5 COL 38 COLON-ALIGNED
          LABEL "tot-doc"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.discnt-pc AT ROW 13.27 COL 12 COLON-ALIGNED
          LABEL "discnt-pc"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     ub.trn-doc.tot-fact AT ROW 13.53 COL 38 COLON-ALIGNED
          LABEL "tot-fact"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     ub.trn-doc.discnt-rubl AT ROW 13.53 COL 72.5 COLON-ALIGNED
          LABEL "discnt-rubl"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
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
     'ub.trn-doc~`':U +
     '~`':U +
     'ub.trn-doc~`':U +
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
    DISABLE  WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN  WITH FRAME F-Main.
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
      IF AVAILABLE ub.trn-doc THEN
          DISPLAY UNLESS-HIDDEN ub.trn-doc.tot-rubl ub.trn-doc.tot-other ub.trn-doc.fact-qnty ub.trn-doc.tot-sale ub.trn-doc.fact-base ub.trn-doc.doc-qnty ub.trn-doc.tot-transp ub.trn-doc.fact-rubl ub.trn-doc.discnt-type ub.trn-doc.exch-code ub.trn-doc.VAT-base ub.trn-doc.print-rubl ub.trn-doc.exch-date ub.trn-doc.VAT-rubl ub.trn-doc.shift-date ub.trn-doc.exch-rate ub.trn-doc.VAT-type ub.trn-doc.shift-num ub.trn-doc.exch-scale ub.trn-doc.SLT-base ub.trn-doc.ship-date ub.trn-doc.pay-code ub.trn-doc.SLT-rubl ub.trn-doc.tot-ov ub.trn-doc.tot-calc ub.trn-doc.SLT-type ub.trn-doc.base-rate ub.trn-doc.road-tax ub.trn-doc.tot-cli ub.trn-doc.base-scale ub.trn-doc.excise ub.trn-doc.tot-doc ub.trn-doc.discnt-pc ub.trn-doc.tot-fact ub.trn-doc.discnt-rubl
            WITH FRAME F-Main NO-ERROR.
      ELSE DO:
          CLEAR FRAME F-Main ALL NO-PAUSE.
          RUN set-editors('CLEAR':U).
      END.
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
  IF "ub.trn-doc":U = "":U THEN
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
      ASSIGN adm-first-table = ROWID(ub.trn-doc)
             adm-new-record = yes
             adm-adding-record = yes
             adm-query-empty = IF AVAILABLE(ub.trn-doc)
                               THEN no ELSE yes.
      RUN set-attribute-list ("ADM-NEW-RECORD=yes,ADM-QUERY-EMPTY-ON-ADD=":U +
        IF adm-query-empty THEN "yes":U ELSE "no":U).
      RUN dispatch('enable-fields':U).
      IF (adm-create-on-add = no) AND (adm-first-tmpl-recid = ?) AND
         (DBTYPE(LDBNAME(BUFFER ub.trn-doc)) EQ "PROGRESS":U)
      THEN DO:
          saved-dictdb = LDBNAME("DICTDB":U).
          CREATE ALIAS DICTDB FOR DATABASE
            VALUE(LDBNAME(BUFFER ub.trn-doc)).
          RUN adm/objects/get-init.p (INPUT "ub.trn-doc":U,
            OUTPUT adm-first-tmpl-recid).
          CREATE ALIAS DICTDB FOR DATABASE
            VALUE(saved-dictdb).
        END.
          IF adm-create-on-add = no THEN
          DO:
           IF DBTYPE(LDBNAME(BUFFER ub.trn-doc))
             EQ "PROGRESS":U THEN
           DO:
            FIND ub.trn-doc WHERE
              RECID(ub.trn-doc) = adm-first-tmpl-recid
                NO-LOCK.
            DISPLAY UNLESS-HIDDEN ub.trn-doc.tot-rubl ub.trn-doc.tot-other ub.trn-doc.fact-qnty ub.trn-doc.tot-sale ub.trn-doc.fact-base ub.trn-doc.doc-qnty ub.trn-doc.tot-transp ub.trn-doc.fact-rubl ub.trn-doc.discnt-type ub.trn-doc.exch-code ub.trn-doc.VAT-base ub.trn-doc.print-rubl ub.trn-doc.exch-date ub.trn-doc.VAT-rubl ub.trn-doc.shift-date ub.trn-doc.exch-rate ub.trn-doc.VAT-type ub.trn-doc.shift-num ub.trn-doc.exch-scale ub.trn-doc.SLT-base ub.trn-doc.ship-date ub.trn-doc.pay-code ub.trn-doc.SLT-rubl ub.trn-doc.tot-ov ub.trn-doc.tot-calc ub.trn-doc.SLT-type ub.trn-doc.base-rate ub.trn-doc.road-tax ub.trn-doc.tot-cli ub.trn-doc.base-scale ub.trn-doc.excise ub.trn-doc.tot-doc ub.trn-doc.discnt-pc ub.trn-doc.tot-fact ub.trn-doc.discnt-rubl
              WITH FRAME F-Main NO-ERROR.
           END.
          END.
          ELSE DO:
           DO TRANSACTION ON STOP  UNDO, RETURN "ADM-ERROR":U
                          ON ERROR UNDO, RETURN "ADM-ERROR":U:
             adm-create-complete = no.
             RUN dispatch ('create-record':U).
             IF RETURN-VALUE = "ADM-ERROR":U THEN UNDO, RETURN "ADM-ERROR":U.
             DISPLAY UNLESS-HIDDEN ub.trn-doc.tot-rubl ub.trn-doc.tot-other ub.trn-doc.fact-qnty ub.trn-doc.tot-sale ub.trn-doc.fact-base ub.trn-doc.doc-qnty ub.trn-doc.tot-transp ub.trn-doc.fact-rubl ub.trn-doc.discnt-type ub.trn-doc.exch-code ub.trn-doc.VAT-base ub.trn-doc.print-rubl ub.trn-doc.exch-date ub.trn-doc.VAT-rubl ub.trn-doc.shift-date ub.trn-doc.exch-rate ub.trn-doc.VAT-type ub.trn-doc.shift-num ub.trn-doc.exch-scale ub.trn-doc.SLT-base ub.trn-doc.ship-date ub.trn-doc.pay-code ub.trn-doc.SLT-rubl ub.trn-doc.tot-ov ub.trn-doc.tot-calc ub.trn-doc.SLT-type ub.trn-doc.base-rate ub.trn-doc.road-tax ub.trn-doc.tot-cli ub.trn-doc.base-scale ub.trn-doc.excise ub.trn-doc.tot-doc ub.trn-doc.discnt-pc ub.trn-doc.tot-fact ub.trn-doc.discnt-rubl
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
        ASSIGN FRAME F-Main ub.trn-doc.tot-rubl ub.trn-doc.tot-other ub.trn-doc.fact-qnty ub.trn-doc.tot-sale ub.trn-doc.fact-base ub.trn-doc.doc-qnty ub.trn-doc.tot-transp ub.trn-doc.fact-rubl ub.trn-doc.discnt-type ub.trn-doc.exch-code ub.trn-doc.VAT-base ub.trn-doc.print-rubl ub.trn-doc.exch-date ub.trn-doc.VAT-rubl ub.trn-doc.shift-date ub.trn-doc.exch-rate ub.trn-doc.VAT-type ub.trn-doc.shift-num ub.trn-doc.exch-scale ub.trn-doc.SLT-base ub.trn-doc.ship-date ub.trn-doc.pay-code ub.trn-doc.SLT-rubl ub.trn-doc.tot-ov ub.trn-doc.tot-calc ub.trn-doc.SLT-type ub.trn-doc.base-rate ub.trn-doc.road-tax ub.trn-doc.tot-cli ub.trn-doc.base-scale ub.trn-doc.excise ub.trn-doc.tot-doc ub.trn-doc.discnt-pc ub.trn-doc.tot-fact ub.trn-doc.discnt-rubl
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
        RELEASE ub.trn-doc NO-ERROR.
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
      ASSIGN adm-first-table = ROWID(ub.trn-doc)
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
             (INPUT "ub.trn-doc":U,
              OUTPUT source-rowid-str).
         FIND ub.trn-doc WHERE
             ROWID (ub.trn-doc) =
                 TO-ROWID(source-rowid-str) NO-ERROR.
         IF ERROR-STATUS:ERROR THEN
         DO:
           RUN dispatch('show-errors':U).
           UNDO, RETURN "ADM-ERROR":U.
         END.
       END.
       ELSE DO:
           CREATE ub.trn-doc NO-ERROR.
           IF ERROR-STATUS:ERROR THEN
           DO:
             RUN dispatch('show-errors':U).
             UNDO, RETURN "ADM-ERROR":U.
           END.
       END.
   RETURN.
END PROCEDURE.
PROCEDURE adm-current-changed :
   ASSIGN adm-first-table = ROWID(ub.trn-doc).
  IF NOT group-assign-target THEN
  DO:
    FIND CURRENT ub.trn-doc EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    IF NOT AVAILABLE ub.trn-doc THEN
    DO:
      RUN dispatch('show-errors':U).
      IF ERROR-STATUS:GET-NUMBER(1) = 138 THEN
          RUN dispatch('get-next':U).
      ELSE FIND ub.trn-doc WHERE
          ROWID(ub.trn-doc) = adm-first-table NO-LOCK NO-ERROR.
      RETURN "ADM-ERROR":U.
    END.
    ELSE IF CURRENT-CHANGED ub.trn-doc THEN
    DO:
      MESSAGE  SUBSTITUTE
          ("Sorry, this &1 has been changed by another user. ",
            "ub.trn-doc") SKIP
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
          FIND CURRENT ub.trn-doc EXCLUSIVE-LOCK NO-WAIT
            NO-ERROR.
          IF ERROR-STATUS:ERROR THEN
          DO:
            RUN dispatch('show-errors':U).
            UNDO, RETURN "ADM-ERROR":U.
          END.
          DELETE ub.trn-doc NO-ERROR.
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
           DISABLE UNLESS-HIDDEN ub.trn-doc.tot-rubl ub.trn-doc.tot-other ub.trn-doc.fact-qnty ub.trn-doc.tot-sale ub.trn-doc.fact-base ub.trn-doc.doc-qnty ub.trn-doc.tot-transp ub.trn-doc.fact-rubl ub.trn-doc.discnt-type ub.trn-doc.exch-code ub.trn-doc.VAT-base ub.trn-doc.print-rubl ub.trn-doc.exch-date ub.trn-doc.VAT-rubl ub.trn-doc.shift-date ub.trn-doc.exch-rate ub.trn-doc.VAT-type ub.trn-doc.shift-num ub.trn-doc.exch-scale ub.trn-doc.SLT-base ub.trn-doc.ship-date ub.trn-doc.pay-code ub.trn-doc.SLT-rubl ub.trn-doc.tot-ov ub.trn-doc.tot-calc ub.trn-doc.SLT-type ub.trn-doc.base-rate ub.trn-doc.road-tax ub.trn-doc.tot-cli ub.trn-doc.base-scale ub.trn-doc.excise ub.trn-doc.tot-doc ub.trn-doc.discnt-pc ub.trn-doc.tot-fact ub.trn-doc.discnt-rubl
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
            IF AVAILABLE(ub.trn-doc) AND
              adm-initial-lock = "SHARE-LOCK":U OR
                adm-initial-lock = "EXCLUSIVE-LOCK":U THEN
            DO:
                IF adm-initial-lock = "SHARE-LOCK":U THEN
                  FIND CURRENT ub.trn-doc SHARE-LOCK NO-WAIT
                    NO-ERROR.
                ELSE IF AVAILABLE (ub.trn-doc) THEN
                DO TRANSACTION:
                  FIND CURRENT ub.trn-doc
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
                ENABLE UNLESS-HIDDEN ub.trn-doc.tot-rubl ub.trn-doc.tot-other ub.trn-doc.fact-qnty ub.trn-doc.tot-sale ub.trn-doc.fact-base ub.trn-doc.doc-qnty ub.trn-doc.tot-transp ub.trn-doc.fact-rubl ub.trn-doc.discnt-type ub.trn-doc.exch-code ub.trn-doc.VAT-base ub.trn-doc.print-rubl ub.trn-doc.exch-date ub.trn-doc.VAT-rubl ub.trn-doc.shift-date ub.trn-doc.exch-rate ub.trn-doc.VAT-type ub.trn-doc.shift-num ub.trn-doc.exch-scale ub.trn-doc.SLT-base ub.trn-doc.ship-date ub.trn-doc.pay-code ub.trn-doc.SLT-rubl ub.trn-doc.tot-ov ub.trn-doc.tot-calc ub.trn-doc.SLT-type ub.trn-doc.base-rate ub.trn-doc.road-tax ub.trn-doc.tot-cli ub.trn-doc.base-scale ub.trn-doc.excise ub.trn-doc.tot-doc ub.trn-doc.discnt-pc ub.trn-doc.tot-fact ub.trn-doc.discnt-rubl
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
          ASSIGN adm-first-table = ROWID(ub.trn-doc).
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
    FIND CURRENT ub.trn-doc NO-LOCK NO-ERROR.
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
      DEFINE BUFFER bNewRecord FOR ub.trn-doc.
      DO TRANSACTION ON STOP  UNDO, RETURN "ADM-ERROR":U
                     ON ERROR UNDO, RETURN "ADM-ERROR":U :
        RUN dispatch ('assign-record':U).
        IF  RETURN-VALUE = "ADM-ERROR":U THEN
            RETURN "ADM-ERROR":U.
      END.
      RUN dispatch ('end-update':U).
      FIND FIRST bNewRecord NO-LOCK NO-ERROR.
      IF NOT ERROR-STATUS:ERROR AND ROWID(bNewRecord) = ROWID (ub.trn-doc) THEN
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
               RUN new-first-record IN hRecordSrc (INPUT ROWID (ub.trn-doc)).
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
      AVAILABLE(ub.trn-doc) THEN
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
    IF LOOKUP("ub.trn-doc":U, RETURN-VALUE, " ":U) NE 0 THEN
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
           DBTYPE(LDBNAME(BUFFER ub.trn-doc)) EQ "PROGRESS":U)
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
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
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
  IF key-name eq ? THEN tbl-list = "ub.trn-doc":U.
      RUN send-records IN record-source-hdl
          (INPUT tbl-list, OUTPUT rowid-list) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN RETURN.
  IF key-name ne ?
  THEN DO:
    RUN dispatch ('find-using-key':U).
    IF RETURN-VALUE eq "ADM-ERROR":U THEN RETURN RETURN-VALUE.
  END.
  ELSE
  DO:
    row-avail-cntr = row-avail-cntr + 1.
    row-avail-rowid = TO-ROWID(ENTRY(row-avail-cntr,rowid-list)).
    IF row-avail-rowid NE ROWID(ub.trn-doc) THEN different-row = yes.
    IF row-avail-rowid ne ? THEN DO:
          IF adm-row-avail-state NE yes THEN DO:
             RUN new-state ('record-available':U).
             RUN set-attribute-list ('Query-Position = record-available':U).
             adm-row-avail-state = yes.
          END.
       DO:
         IF row-avail-enabled AND
            (adm-initial-lock = "SHARE-LOCK":U OR
             adm-initial-lock = "EXCLUSIVE-LOCK":U) THEN
         DO:
           IF adm-initial-lock = "SHARE-LOCK":U
           THEN FIND ub.trn-doc WHERE ROWID(ub.trn-doc) = row-avail-rowid SHARE-LOCK NO-ERROR.
           ELSE DO TRANSACTION:
             FIND ub.trn-doc WHERE ROWID(ub.trn-doc) = row-avail-rowid EXCLUSIVE-LOCK NO-ERROR.
           END.
         END.
         ELSE FIND ub.trn-doc WHERE ROWID(ub.trn-doc) = row-avail-rowid  NO-LOCK NO-ERROR.
         IF ERROR-STATUS:ERROR THEN DO:
           RUN dispatch ('show-errors':U).
           RETURN "ADM-ERROR":U.
         END.
       END.
    END.
    ELSE DO:
         IF AVAILABLE ub.trn-doc THEN RELEASE ub.trn-doc.
              IF adm-row-avail-state NE no THEN
              DO:
                RUN new-state ('no-record-available':U).
                RUN set-attribute-list
                  ('Query-Position = no-record-available':U).
                adm-row-avail-state = no.
              END.
     END.
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
  DEFINE INPUT PARAMETER p-tbl-list AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-rowid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
  DEFINE VARIABLE link-handle  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE rowid-string AS CHARACTER NO-UNDO.
  DO i = 1 TO NUM-ENTRIES(p-tbl-list):
      IF i > 1 THEN p-rowid-list = p-rowid-list + ",":U.
      CASE ENTRY(i, p-tbl-list):
    WHEN "ub.trn-doc":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE ub.trn-doc THEN STRING(ROWID(ub.trn-doc))
        ELSE "?":U.
        OTHERWISE
        DO:
            RUN get-link-handle IN adm-broker-hdl (INPUT THIS-PROCEDURE,
                INPUT "RECORD-SOURCE":U, OUTPUT link-handle) NO-ERROR.
            IF link-handle NE "":U THEN
            DO:
                IF NUM-ENTRIES(link-handle) > 1 THEN
                    MESSAGE "send-records in ":U THIS-PROCEDURE:FILE-NAME
                            "encountered more than one RECORD-SOURCE.":U SKIP
                            "The first will be used.":U
                            VIEW-AS ALERT-BOX ERROR.
                RUN send-records IN WIDGET-HANDLE(ENTRY(1,link-handle))
                    (INPUT ENTRY(i, p-tbl-list), OUTPUT rowid-string).
                p-rowid-list = p-rowid-list + rowid-string.
            END.
            ELSE
            DO:
                MESSAGE "Requested table":U ENTRY(i, p-tbl-list)
                        "does not match tables in send-records":U
                        "in procedure":U THIS-PROCEDURE:FILE-NAME ".":U SKIP
                        "Check that objects are linked properly and that":U
                        "database qualification is consistent.":U
                    VIEW-AS ALERT-BOX ERROR.
                RETURN ERROR.
            END.
        END.
        END CASE.
    END.
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
