define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ассортиментный минимум по текущему объекту (ЗАКЛАДКА №2)".
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
CREATE WIDGET-POOL.
def var State-source as  WIDGET-HANDLE.
define variable all-gds as logical no-undo initial true.
DEFINE VARIABLE RADIO-gds AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по всем товарам", 1,
"с остатком ниже минимального", 2
     SIZE 37 BY 2.81 NO-UNDO.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 71.4 BY 5.95.
DEFINE FRAME F-Main
     RADIO-gds AT ROW 3.38 COL 3 NO-LABEL
     "Выводить информацию:" VIEW-AS TEXT
          SIZE 25 BY .67 AT ROW 2.19 COL 3
          FGCOLOR 4
     RECT-7 AT ROW 1.48 COL 1
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 .
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\rep\e-amin.w should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.
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
     'SmartViewer~`':U +
     '~`':U +
     'NO ~`':U +
     '~`':U +
     '~`':U +
     '~`':U +
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
    DISABLE RECT-7 RADIO-gds WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-7 RADIO-gds WITH FRAME F-Main.
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
  RUN set-attribute-list ('FIELDS-ENABLED=no,ADM-NEW-RECORD=no':U).
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.
ON VALUE-CHANGED OF RADIO-gds IN FRAME F-Main
DO:
  assign RADIO-gds .
  if RADIO-gds = 1 then all-gds = true.
  else all-gds = false.
END.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE local-apply-layout :
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .
END PROCEDURE.
PROCEDURE local-initialize :
RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
END PROCEDURE.
PROCEDURE my-report :
 run rep/r-amin.p ( all-gds ).
END PROCEDURE.
PROCEDURE my-var :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
  END CASE.
  END PROCEDURE.
