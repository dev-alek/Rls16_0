CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Форма ввода часов для почасовых отчетов" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
DEFINE  SHARED VARIABLE loc#log as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE loc#db-num as integer NO-UNDO.
DEFINE  SHARED VARIABLE loc#host-code as integer NO-UNDO.
DEFINE  SHARED VARIABLE loc#store-code as integer NO-UNDO.
DEFINE  SHARED VARIABLE vH-0 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-1 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-2 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-3 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-4 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-5 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-6 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-7 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-8 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-9 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-10 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-11 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-12 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-13 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-14 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-15 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-16 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-17 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-18 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-19 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-20 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-21 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-22 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vH-23 as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE vXL    as LOGICAL NO-UNDO.
DEFINE  SHARED VARIABLE WH-start as CHARACTER NO-UNDO.
DEFINE  SHARED VARIABLE WH-end  as CHARACTER NO-UNDO.
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
define variable kk     as integer NO-UNDO.
define variable State-source as WIDGET-HANDLE.
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46 BY 9.58.
DEFINE VARIABLE H-0 AS LOGICAL INITIAL no
     LABEL "00:00-00:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-1 AS LOGICAL INITIAL no
     LABEL "01:00-01:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-10 AS LOGICAL INITIAL no
     LABEL "10:00-10:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-11 AS LOGICAL INITIAL no
     LABEL "11:00-11:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-12 AS LOGICAL INITIAL no
     LABEL "12:00-12:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-13 AS LOGICAL INITIAL no
     LABEL "13:00-13:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-14 AS LOGICAL INITIAL no
     LABEL "14:00-14:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-15 AS LOGICAL INITIAL no
     LABEL "15:00-15:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-16 AS LOGICAL INITIAL no
     LABEL "16:00-16:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-17 AS LOGICAL INITIAL no
     LABEL "17:00-17:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-18 AS LOGICAL INITIAL no
     LABEL "18:00-18:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-19 AS LOGICAL INITIAL no
     LABEL "19:00-19:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-2 AS LOGICAL INITIAL no
     LABEL "02:00-02:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-20 AS LOGICAL INITIAL no
     LABEL "20:00-20:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-21 AS LOGICAL INITIAL no
     LABEL "21:00-21:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-22 AS LOGICAL INITIAL no
     LABEL "22:00-22:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-23 AS LOGICAL INITIAL no
     LABEL "23:00-23:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-3 AS LOGICAL INITIAL no
     LABEL "03:00-03:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-4 AS LOGICAL INITIAL no
     LABEL "04:00-04:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-5 AS LOGICAL INITIAL no
     LABEL "05:00-05:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-6 AS LOGICAL INITIAL no
     LABEL "06:00-06:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-7 AS LOGICAL INITIAL no
     LABEL "07:00-07:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-8 AS LOGICAL INITIAL no
     LABEL "08:00-08:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE H-9 AS LOGICAL INITIAL no
     LABEL "09:00-09:59"
     VIEW-AS TOGGLE-BOX
     SIZE 10.25 BY 1
     FONT 4 NO-UNDO.
DEFINE VARIABLE XL AS LOGICAL INITIAL no
     LABEL "Вывод с разделителем (для импорта в EXCEL)"
     VIEW-AS TOGGLE-BOX
     SIZE 44 BY .96 NO-UNDO.
DEFINE FRAME F-Main
     H-0 AT ROW 3.04 COL 3
     H-1 AT ROW 3.04 COL 13.75
     H-2 AT ROW 3.04 COL 25
     H-3 AT ROW 3.04 COL 36.75
     H-4 AT ROW 4.33 COL 3
     H-5 AT ROW 4.33 COL 13.75
     H-6 AT ROW 4.33 COL 25
     H-7 AT ROW 4.33 COL 36.75
     H-8 AT ROW 5.71 COL 3
     H-9 AT ROW 5.71 COL 13.75
     H-10 AT ROW 5.71 COL 25
     H-11 AT ROW 5.71 COL 36.75
     H-12 AT ROW 7.04 COL 3
     H-13 AT ROW 7.04 COL 13.75
     H-14 AT ROW 7.04 COL 25
     H-15 AT ROW 7.04 COL 36.75
     H-16 AT ROW 8.33 COL 3
     H-17 AT ROW 8.33 COL 13.75
     H-18 AT ROW 8.33 COL 25
     H-19 AT ROW 8.33 COL 36.75
     H-20 AT ROW 9.42 COL 3
     H-21 AT ROW 9.42 COL 13.75
     H-22 AT ROW 9.42 COL 25
     H-23 AT ROW 9.42 COL 36.75
     XL AT ROW 11.21 COL 4.63
     "Показать следующие часы работы магазина:" VIEW-AS TEXT
          SIZE 40 BY 1 AT ROW 1.71 COL 5.13
          FGCOLOR 4
     RECT-10 AT ROW 1.38 COL 1.88
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
    DISABLE RECT-10 H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9 H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19 H-20 H-21 H-22 H-23 XL WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/viewerd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-10 H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9 H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19 H-20 H-21 H-22 H-23 XL WITH FRAME F-Main.
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
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
RUN notify IN THIS-PROCEDURE ('row-available':U).
END PROCEDURE.
PROCEDURE Assign-Frame :
ASSIGN frame F-Main
H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9 H-10
H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
H-20 H-21 H-22 H-23 XL
.
ASSIGN
vH-0 = H-0
vH-1 = H-1
vH-2 = H-2
vH-3 = H-3
vH-4 = H-4
vH-5 = H-5
vH-6 = H-6
vH-7 = H-7
vH-8 = H-8
vH-9 = H-9
vH-10 = H-10
vH-11 = H-11
vH-12 = H-12
vH-13 = H-13
vH-14 = H-14
vH-15 = H-15
vH-16 = H-16
vH-17 = H-17
vH-18 = H-18
vH-19 = H-19
vH-20 = H-20
vH-21 = H-21
vH-22 = H-22
vH-23 = H-23
vXL   = XL
.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE Display_ :
ASSIGN XL = vXL.
DISPLAY XL WITH FRAME F-Main.
END PROCEDURE.
PROCEDURE ini-from-selobj :
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
WH-Start = "24"
WH-End = "0"
.
_hours:
for each obj-list No-LOCK:
    FIND FIRST ub.SHop NO-LOCK WHERE ub.shop.obj-code = obj-list.obj-code No-ERROR.
    if not avail ub.shop then NEXT.
    if ub.shop.work-hours = "" then do:
        message "Не определены часы работы" skip
                        "магазина с кодом " ub.shop.obj-code
        view-as alert-box ERROR .
   end.
   else do:
      if entry( 1, entry( 1, ub.shop.work-hours ), "." ) = entry( 1, entry( 2, ub.shop.work-hours ), "." )
      then do:
          assign
          WH-Start = "0"
          WH-End = "0"
          .
          LEAVE _hours.
      end.
      else
      assign
      WH-Start = string(MIN(integer(entry( 1, entry( 1, ub.shop.work-hours ), "." ) ), integer(WH-start)))
      WH-End = string(MAX(integer(entry( 1, entry( 2, ub.shop.work-hours ), "." ) ), integer(WH-end)))
      .
   end.
END.
if WH-Start = "24" AND WH-End = "0"
then do:
    message "Не определены часы работы" skip
                    "ни одного из магазинов"
                    "данной базы."
    view-as alert-box ERROR .
    DISABLE
    H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9
    H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
    H-20 H-21 H-22 H-23
    WITH FRAME F-Main.
end.
else do:
   if WH-Start = "0" AND WH-End = "0" then  do:
        assign
        H-0 = TRUE
        H-1 = TRUE
        H-2 = TRUE
        H-3 = TRUE
        H-4 = TRUE
        H-5 = TRUE
        H-6 = TRUE
        H-7 = TRUE
        H-8 = TRUE
        H-9 = TRUE
        H-10 = TRUE
        H-11 = TRUE
        H-12 = TRUE
        H-13 = TRUE
        H-14 = TRUE
        H-15 = TRUE
        H-16 = TRUE
        H-17 = TRUE
        H-18 = TRUE
        H-19 = TRUE
        H-20 = TRUE
        H-21 = TRUE
        H-22 = TRUE
        H-23 = TRUE
        .
        DISPLAY
        H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9
        H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
        H-20 H-21 H-22 H-23
        WITH FRAME F-Main.
    end.
    else do:
        assign
        H-0 = FALSE
        H-1 = FALSE
        H-2 = FALSE
        H-3 = FALSE
        H-4 = FALSE
        H-5 = FALSE
        H-6 = FALSE
        H-7 = FALSE
        H-8 = FALSE
        H-9 = FALSE
        H-10 = FALSE
        H-11 = FALSE
        H-12 = FALSE
        H-13 = FALSE
        H-14 = FALSE
        H-15 = FALSE
        H-16 = FALSE
        H-17 = FALSE
        H-18 = FALSE
        H-19 = FALSE
        H-20 = FALSE
        H-21 = FALSE
        H-22 = FALSE
        H-23 = FALSE
        .
        DISPLAY
        H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9
        H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
        H-20 H-21 H-22 H-23
        WITH FRAME F-Main.
        DO kk = integer( WH-Start ) TO ( integer( WH-End ) - 1 ) :
            CASE kk :
                when 0 then do:
                    H-0 = TRUE .
                end.
                when 1 then do:
                    H-1 = TRUE .
                end.
                when 2 then do:
                    H-2 = TRUE .
                end.
                when 3 then do:
                    H-3 = TRUE .
               end.
               when 4 then do:
                    H-4 = TRUE .
               end.
               when 5 then do:
                    H-5 = TRUE .
               end.
               when 6 then do:
                    H-6 = TRUE .
               end.
               when 7 then do:
                    H-7 = TRUE .
               end.
               when 8 then do:
                    H-8 = TRUE .
               end.
               when 9 then do:
                    H-9 = TRUE .
               end.
               when 10 then do:
                    H-10 = TRUE .
               end.
               when 11 then do:
                    H-11 = TRUE .
               end.
               when 12 then do:
                    H-12 = TRUE .
               end.
               when 13 then do:
                    H-13 = TRUE .
               end.
               when 14 then do:
                    H-14 = TRUE .
               end.
               when 15 then do:
                    H-15 = TRUE .
               end.
               when 16 then do:
                    H-16 = TRUE .
               end.
               when 17 then do:
                    H-17 = TRUE .
               end.
               when 18 then do:
                    H-18 = TRUE .
               end.
               when 19 then do:
                    H-19 = TRUE .
               end.
               when 20 then do:
                    H-20 = TRUE .
               end.
               when 21 then do:
                    H-21 = TRUE .
               end.
               when 22 then do:
                    H-22 = TRUE .
               end.
               when 23 then do:
                    H-23 = TRUE .
               end.
            END CASE .
        END .
        DISPLAY
        H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9
        H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
        H-20 H-21 H-22 H-23
        WITH FRAME F-Main.
    end.
end.
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
