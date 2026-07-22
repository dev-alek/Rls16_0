CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр строк документа".
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
DEFINE QUERY external_tables FOR trn-doc.
RUN set-attribute-list (
    'Keys-Accepted = ,
     Keys-Supplied = "obj-code,doc-code"':U).
RUN set-attribute-list (
    'SortBy-Options = ""':U).
DEFINE QUERY br_table FOR
      doc-line SCROLLING.
DEFINE BROWSE br_table
  QUERY br_table NO-LOCK DISPLAY
      doc-line.artic           COLUMN-LABEL "artic"
      doc-line.prod-type       COLUMN-LABEL "prod-type"
      doc-line.prod-code       COLUMN-LABEL "prod-code"
      doc-line.cli-qnty        COLUMN-LABEL "cli-qnty"
      doc-line.cli-base-rate   COLUMN-LABEL "cli-base-rate"
      doc-line.doc-qnty        COLUMN-LABEL "doc-qnty"
      doc-line.fact-qnty       COLUMN-LABEL "fact-qnty"
      doc-line.price-cli       COLUMN-LABEL "price-cli"
      doc-line.price-base      COLUMN-LABEL "price-base"
      doc-line.price-rubl      COLUMN-LABEL "price-rubl"
      doc-line.VAT-pc          COLUMN-LABEL "VAT-pc"
      doc-line.SLT-pc          COLUMN-LABEL "SLT-pc"
      doc-line.road-tax        COLUMN-LABEL "road-tax"
      doc-line.transport-base  COLUMN-LABEL "transport-base"
      doc-line.transport-rubl  COLUMN-LABEL "transport-rubl"
      doc-line.other-base      COLUMN-LABEL "other-base"
      doc-line.other-rubl      COLUMN-LABEL "other-rubl"
      doc-line.excise          COLUMN-LABEL "excise"
      doc-line.doc-density     COLUMN-LABEL "doc-density"
      doc-line.fact-density    COLUMN-LABEL "fact-density"
      doc-line.doc-code        COLUMN-LABEL "doc-code"
      doc-line.fact-order      COLUMN-LABEL "fact-order"
      doc-line.line-num        COLUMN-LABEL "line-num"
      doc-line.num-place       COLUMN-LABEL "num-place"
      doc-line.obj-code        COLUMN-LABEL "obj-code"
      doc-line.obj-type        COLUMN-LABEL "obj-type"
      doc-line.prt-OK          COLUMN-LABEL "prt-OK"
      doc-line.prt-root        COLUMN-LABEL "prt-root"
      doc-line.status_         COLUMN-LABEL "status_"
      doc-line.temperature     COLUMN-LABEL "temperature"
      doc-line.unit-cli        COLUMN-LABEL "unit-cli"
      doc-line.wt-brutto       COLUMN-LABEL "wt-brutto"
    WITH NO-ASSIGN SEPARATORS SIZE 97.38 BY 6.71.
DEFINE FRAME F-Main
     br_table AT ROW 1 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE adm-sts           AS LOGICAL NO-UNDO.
DEFINE VARIABLE adm-brs-in-update AS LOGICAL NO-UNDO INIT no.
DEFINE VARIABLE adm-brs-initted   AS LOGICAL NO-UNDO INIT no.
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
     'YES~`':U +
     'trn-doc~`':U +
     'doc-line~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Initial-Lock,Hide-on-Init,Disable-on-Init,Key-Name,Layout,Create-On-Add,SortBy-Case~`':U +
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
    DISABLE br_table WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/browserd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN br_table WITH FRAME F-Main.
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
  IF "":U = "":U THEN
    RUN modify-list-attribute IN adm-broker-hdl
      (THIS-PROCEDURE, "REMOVE":U, "SUPPORTED-LINKS":U, "TABLEIO-TARGET":U).
  RUN use-create-on-add(?).
PROCEDURE adm-add-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
       "must have at least one Enabled Table to perform Add.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-assign-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Assign.":U
           VIEW-AS ALERT-BOX ERROR.
   RETURN.
  END PROCEDURE.
PROCEDURE adm-assign-statement :
  RETURN.
END PROCEDURE.
PROCEDURE adm-cancel-record :
   RETURN.
  END PROCEDURE.
PROCEDURE adm-copy-record :
    MESSAGE "Object ":U THIS-PROCEDURE:FILE-NAME
     "must have at least one Enabled Table to perform Copy.":U
       VIEW-AS ALERT-BOX ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-create-record :
   RETURN.
END PROCEDURE.
PROCEDURE adm-current-changed :
  RETURN.
END PROCEDURE.
PROCEDURE adm-delete-record :
 MESSAGE
       "Object ":U THIS-PROCEDURE:FILE-NAME
         "must have at least one Enabled Table to perform Delete.":U
           VIEW-AS ALERT-BOX ERROR.
    RUN dispatch IN THIS-PROCEDURE ('apply-entry':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-disable-fields :
      RUN notify ('disable-fields, GROUP-ASSIGN-TARGET':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-enable-fields :
    RETURN.
END PROCEDURE.
PROCEDURE adm-end-update :
  RETURN.
END PROCEDURE.
PROCEDURE adm-reset-record :
    RETURN.
END PROCEDURE.
PROCEDURE adm-update-record :
    MESSAGE
      "Object ":U THIS-PROCEDURE:FILE-NAME
        "must have at least one Enabled Table to perform Update.":U
          VIEW-AS ALERT-BOX ERROR.
   RETURN.
END PROCEDURE.
PROCEDURE check-modified :
DEFINE INPUT PARAMETER check-state AS CHARACTER NO-UNDO.
DEFINE VARIABLE curr-widget       AS HANDLE      NO-UNDO.
DEFINE VARIABLE container-hdl-str AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i                 AS INTEGER     NO-UNDO.
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
    IF LOOKUP("":U, RETURN-VALUE, " ":U) NE 0 THEN
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
   RETURN.
END PROCEDURE.
PROCEDURE use-initial-lock :
  DEFINE INPUT PARAMETER p-attr-value AS CHARACTER NO-UNDO.
  ASSIGN adm-initial-lock = p-attr-value.
  RETURN.
END PROCEDURE.
PROCEDURE adm-display-fields :
      IF AVAILABLE doc-line THEN
          DISPLAY doc-line.artic doc-line.prod-type doc-line.prod-code doc-line.cli-qnty doc-line.cli-base-rate doc-line.doc-qnty doc-line.fact-qnty doc-line.price-cli doc-line.price-base doc-line.price-rubl doc-line.VAT-pc doc-line.SLT-pc doc-line.road-tax doc-line.transport-base doc-line.transport-rubl doc-line.other-base doc-line.other-rubl doc-line.excise doc-line.doc-density doc-line.fact-density doc-line.doc-code doc-line.fact-order doc-line.line-num doc-line.num-place doc-line.obj-code doc-line.obj-type doc-line.prt-OK doc-line.prt-root doc-line.status_ doc-line.temperature doc-line.unit-cli doc-line.wt-brutto WITH BROWSE br_table
            NO-ERROR.
    RUN check-modified IN THIS-PROCEDURE ('clear':U) NO-ERROR.
    RETURN.
END PROCEDURE.
PROCEDURE adm-open-query :
    IF AVAILABLE(trn-doc) THEN DO:
            RUN dispatch ('open-query-cases':U).
        adm-query-opened = yes.
        IF NUM-RESULTS("br_table":U) = 0 THEN
            RUN new-state ('no-record-available,SELF':U).
        ELSE DO:
            RUN new-state ('record-available,SELF':U).
            RUN new-state ('first-record,SELF':U).
        END.
    END.
    ELSE
    DO:
        CLOSE QUERY br_table.
        RELEASE doc-line NO-ERROR.
        RUN new-state ('no-external-record-available,SELF':U).
    END.
        IF NOT adm-updating-record THEN
            RUN dispatch IN THIS-PROCEDURE ('row-changed':U).
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
    DEFINE VARIABLE table-name                 AS ROWID NO-UNDO.
    RUN get-rowid IN p-requestor-hdl (OUTPUT table-name).
    IF table-name <> ? THEN
        REPOSITION br_table TO ROWID table-name NO-ERROR.
    RUN set-attribute-list ('REPOSITION-PENDING = NO':U).
    RETURN.
END PROCEDURE.
  adm-sts = br_table:SET-REPOSITIONED-ROW
    (br_table:DOWN,"CONDITIONAL":U).
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
PROCEDURE set-size :
  DEFINE INPUT PARAMETER pd_height AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pd_width  AS DECIMAL NO-UNDO.
  DEFINE VARIABLE hBrowse     AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFieldGroup AS HANDLE           NO-UNDO.
  DEFINE VARIABLE hFrame      AS HANDLE           NO-UNDO.
  DEFINE VARIABLE htmpWidget  AS HANDLE           NO-UNDO.
  DEFINE VARIABLE otherWidget AS LOGICAL          NO-UNDO.
  ASSIGN pd_height = MAX(pd_height, 2.0)
         pd_width  = MAX(pd_width, 2.0)
         hBrowse     = br_table:HANDLE IN FRAME F-Main
         hFieldGroup = hBrowse:PARENT
         htmpWidget  = hFieldGroup:FIRST-CHILD
         hFrame      = hFieldGroup:PARENT.
  Search-For-Siblings:
  REPEAT WHILE VALID-HANDLE(htmpWidget):
    IF htmpWidget NE hBrowse THEN DO:
      IF htmpWidget:TYPE NE "BUTTON" OR
         htmpWidget:X    NE 4 OR
         htmpWidget:Y    NE 4 THEN DO:
        RETURN.
      END.
    END.
    htmpWidget = htmpWidget:NEXT-SIBLING.
  END.
  IF pd_width < hBrowse:WIDTH THEN
    ASSIGN hBrowse:WIDTH = pd_width
           hFrame:WIDTH  = pd_width     NO-ERROR.
  ELSE
    ASSIGN hFrame:WIDTH  = pd_width
           hBrowse:WIDTH = pd_width     NO-ERROR.
  IF pd_height < hBrowse:HEIGHT THEN
    ASSIGN hBrowse:HEIGHT = pd_height
           hFrame:HEIGHT  = pd_height     NO-ERROR.
  ELSE
    ASSIGN hFrame:HEIGHT  = pd_height
           hBrowse:HEIGHT = pd_height     NO-ERROR.
END PROCEDURE.
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.
ON ROW-ENTRY OF br_table IN FRAME F-Main
DO:
END.
ON ROW-LEAVE OF br_table IN FRAME F-Main
DO:
DEFINE VARIABLE widget-enter  AS HANDLE NO-UNDO.
DEFINE VARIABLE widget-frame  AS HANDLE NO-UNDO.
DEFINE VARIABLE widget-parent AS HANDLE NO-UNDO.
  widget-enter = last-event:widget-enter.
  IF VALID-HANDLE(widget-enter) THEN widget-parent = widget-enter:PARENT.
  IF VALID-HANDLE(widget-parent) AND widget-parent:TYPE NE "BROWSE":U
    THEN widget-frame = widget-enter:FRAME.
  IF ((NOT VALID-HANDLE(widget-enter)) OR
      (widget-parent:TYPE = "BROWSE":U) OR
      (NOT VALID-HANDLE(widget-frame)) OR
      (NOT CAN-DO(widget-frame:PRIVATE-DATA, "ADM-PANEL":U)))
  THEN DO:
      IF adm-brs-in-update THEN
      DO:
        MESSAGE
        "You must complete or cancel the update before leaving the current row."
            VIEW-AS ALERT-BOX WARNING.
        RETURN NO-APPLY.
      END.
      IF br_table:CURRENT-ROW-MODIFIED  OR
        (adm-new-record AND BROWSE br_table:NUM-SELECTED-ROWS = 1) THEN
      DO:
        IF VALID-HANDLE (widget-parent) AND widget-parent:TYPE NE "BROWSE":U
        THEN DO:
          MESSAGE
          "Current record has been changed. " SKIP
          "Do you wish to save those changes?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE l-save AS LOGICAL.
          IF l-save THEN
          DO:
             RUN dispatch('update-record':U).
             IF RETURN-VALUE = "ADM-ERROR":U THEN
                 RETURN NO-APPLY.
          END.
          ELSE RUN dispatch ('cancel-record':U).
        END.
        ELSE DO:
          RUN dispatch('update-record':U).
          IF RETURN-VALUE = "ADM-ERROR":U THEN
              RETURN NO-APPLY.
        END.
      END.
  END.
END.
ON VALUE-CHANGED OF br_table IN FRAME F-Main
DO:
RUN get-attribute('ADM-NEW-RECORD':U).
IF RETURN-VALUE NE "YES":U THEN
  RUN notify ('row-available':U).
END.
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.
PROCEDURE adm-open-query-cases :
  OPEN QUERY br_table FOR EACH doc-line where doc-line.doc-code = trn-doc.doc-code NO-LOCK     .
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
  IF key-name eq ? THEN tbl-list = "trn-doc":U.
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
    IF row-avail-rowid NE ROWID(trn-doc) THEN different-row = yes.
    IF row-avail-rowid ne ? THEN DO:
       DO:
         IF row-avail-enabled AND
            (adm-initial-lock = "SHARE-LOCK":U OR
             adm-initial-lock = "EXCLUSIVE-LOCK":U) THEN
         DO:
           IF adm-initial-lock = "SHARE-LOCK":U
           THEN FIND trn-doc WHERE ROWID(trn-doc) = row-avail-rowid SHARE-LOCK NO-ERROR.
           ELSE DO TRANSACTION:
             FIND trn-doc WHERE ROWID(trn-doc) = row-avail-rowid EXCLUSIVE-LOCK NO-ERROR.
           END.
         END.
         ELSE FIND trn-doc WHERE ROWID(trn-doc) = row-avail-rowid  NO-LOCK NO-ERROR.
         IF ERROR-STATUS:ERROR THEN DO:
           RUN dispatch ('show-errors':U).
           RETURN "ADM-ERROR":U.
         END.
       END.
    END.
    ELSE DO:
         IF AVAILABLE trn-doc THEN RELEASE trn-doc.
           IF NOT different-row THEN
             RUN dispatch('open-query').
     END.
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
  IF key-name ne ? OR different-row
  THEN RUN dispatch IN THIS-PROCEDURE ('open-query':U).
  ELSE RUN notify IN THIS-PROCEDURE('row-available':U).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE send-key :
  DEFINE INPUT  PARAMETER pc_key-name   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER pc_key-value  AS CHARACTER NO-UNDO INITIAL ?.
  CASE pc_key-name:
    WHEN "obj-code" THEN
      pc_key-value = IF AVAILABLE doc-line THEN STRING(doc-line.obj-code) ELSE ?.
    WHEN "doc-code" THEN
      pc_key-value = IF AVAILABLE doc-line THEN STRING(doc-line.doc-code) ELSE ?.
      WHEN "":U THEN .
      OTHERWISE MESSAGE "Entry ":U pc_key-name
                        " was not found in the send-key cases in ":U
                        THIS-PROCEDURE:FILE-NAME
                      VIEW-AS ALERT-BOX ERROR.
  END CASE.
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
    WHEN "trn-doc":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE trn-doc THEN STRING(ROWID(trn-doc))
        ELSE "?":U.
    WHEN "doc-line":U THEN p-rowid-list = p-rowid-list +
        IF AVAILABLE doc-line THEN STRING(ROWID(doc-line))
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
    WHEN "update-begin":U THEN
    DO:
        adm-brs-in-update = yes.
        RUN dispatch ('enable-fields':U).
        IF RETURN-VALUE = "ADM-ERROR":U THEN
        DO:
          RUN new-state('update-failed,TABLEIO-SOURCE':U).
          RUN new-state('update-complete':U).
        END.
        ELSE DO:
          RUN dispatch ('apply-entry':U).
          RUN new-state('update':U).
        END.
    END.
    WHEN "update":U THEN
      DO:
        DEFINE VARIABLE group-link AS CHARACTER NO-UNDO INIT "":U.
        RUN get-link-handle IN adm-broker-hdl
            (INPUT THIS-PROCEDURE, 'GROUP-ASSIGN-TARGET':U, OUTPUT group-link)
                NO-ERROR.
        IF LOOKUP(STRING(p-issuer-hdl), group-link) EQ 0 THEN
          br_table:SENSITIVE IN FRAME F-Main = no.
      END.
    WHEN "update-complete":U THEN DO:
        br_table:SENSITIVE IN FRAME F-Main = yes.
        adm-brs-in-update = no.
        RUN get-attribute IN p-issuer-hdl ('QUERY-OBJECT':U).
        IF RETURN-VALUE NE "YES":U THEN
        DO:
          IF NUM-RESULTS("br_table":U) NE ? AND
             NUM-RESULTS("br_table":U) NE 0
          THEN DO:
            GET CURRENT br_table.
            RUN dispatch ('row-changed':U).
          END.
        END.
        RUN new-state ('update-complete':U).
    END.
    WHEN "delete-complete":U THEN DO:
       DEFINE VARIABLE sts AS LOGICAL NO-UNDO.
       sts = br_table:DELETE-CURRENT-ROW() IN FRAME F-Main.
       IF NUM-RESULTS("br_table":U) = 0 THEN
         RUN notify('row-available':U).
    END.
    WHEN   'first-record':U        OR
      WHEN 'last-record':U         OR
      WHEN 'only-record':U         OR
      WHEN 'not-first-or-last':U   OR
      WHEN 'no-record-available':U OR
      WHEN 'no-external-record-available':U THEN
        RUN set-attribute-list('Query-Position=':U + p-state).
  END CASE.
END PROCEDURE.
