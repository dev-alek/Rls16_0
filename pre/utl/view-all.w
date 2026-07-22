define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр документов".
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
CREATE WIDGET-POOL.
DEFINE VARIABLE h_b-dl AS HANDLE NO-UNDO.
DEFINE VARIABLE h_b-dl-2 AS HANDLE NO-UNDO.
DEFINE VARIABLE h_b-gdsdtl AS HANDLE NO-UNDO.
DEFINE VARIABLE h_b-ot-tot AS HANDLE NO-UNDO.
DEFINE VARIABLE h_b-otline AS HANDLE NO-UNDO.
DEFINE VARIABLE h_b-prt AS HANDLE NO-UNDO.
DEFINE VARIABLE h_b-t-doc AS HANDLE NO-UNDO.
DEFINE VARIABLE h_folder AS HANDLE NO-UNDO.
DEFINE VARIABLE h_v-t-doc AS HANDLE NO-UNDO.
DEFINE FRAME D-Dialog
     SPACE(99.01) SKIP(21.72)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Просмотр информации по документам".
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
    DISABLE  WITH FRAME D-Dialog.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN  WITH FRAME D-Dialog.
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
  DEFINE VARIABLE adm-current-page  AS INTEGER NO-UNDO.
  RUN get-attribute IN THIS-PROCEDURE ('Current-Page':U).
  ASSIGN adm-current-page = INTEGER(RETURN-VALUE).
  CASE adm-current-page:
    WHEN 0 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'adm/objects/folder.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'FOLDER-LABELS = ':U + 'документ|строки|архив' + ',
                     FOLDER-TAB-TYPE = 1':U ,
             OUTPUT h_folder ).
       RUN set-position IN h_folder ( 1.00 , 1.13 ) NO-ERROR.
       RUN set-size IN h_folder ( 21.63 , 98.75 ) NO-ERROR.
       RUN add-link IN adm-broker-hdl ( h_folder , 'Page':U , THIS-PROCEDURE ).
    END.
    WHEN 1 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'utl/b-t-doc.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_b-t-doc ).
       RUN set-position IN h_b-t-doc ( 2.13 , 1.63 ) NO-ERROR.
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'utl/v-t-doc.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_v-t-doc ).
       RUN set-position IN h_v-t-doc ( 8.88 , 1.63 ) NO-ERROR.
       RUN add-link IN adm-broker-hdl ( h_b-t-doc , 'Record':U , h_v-t-doc ).
    END.
    WHEN 2 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'utl/b-dl.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_b-dl ).
       RUN set-position IN h_b-dl ( 2.33 , 1.63 ) NO-ERROR.
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'utl/b-gdsdtl.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_b-gdsdtl ).
       RUN set-position IN h_b-gdsdtl ( 9.08 , 1.63 ) NO-ERROR.
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'utl/b-prt.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_b-prt ).
       RUN set-position IN h_b-prt ( 15.88 , 1.63 ) NO-ERROR.
       RUN init-pages IN THIS-PROCEDURE ('1') NO-ERROR.
       RUN add-link IN adm-broker-hdl ( h_b-t-doc , 'Record':U , h_b-dl ).
       RUN add-link IN adm-broker-hdl ( h_b-dl , 'Record':U , h_b-gdsdtl ).
       RUN add-link IN adm-broker-hdl ( h_b-dl , 'Record':U , h_b-prt ).
    END.
    WHEN 3 THEN DO:
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'utl/b-ot-tot.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_b-ot-tot ).
       RUN set-position IN h_b-ot-tot ( 2.33 , 2.75 ) NO-ERROR.
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'utl/b-dl.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_b-dl-2 ).
       RUN set-position IN h_b-dl-2 ( 9.17 , 2.50 ) NO-ERROR.
       RUN init-object IN THIS-PROCEDURE (
             INPUT  'utl/b-otline.w':U ,
             INPUT  FRAME D-Dialog:HANDLE ,
             INPUT  'Layout = ':U ,
             OUTPUT h_b-otline ).
       RUN set-position IN h_b-otline ( 16.00 , 2.50 ) NO-ERROR.
       RUN init-pages IN THIS-PROCEDURE ('1') NO-ERROR.
       RUN add-link IN adm-broker-hdl ( h_b-t-doc , 'Record':U , h_b-ot-tot ).
       RUN add-link IN adm-broker-hdl ( h_b-t-doc , 'Record':U , h_b-dl-2 ).
       RUN add-link IN adm-broker-hdl ( h_b-dl-2 , 'Record':U , h_b-otline ).
    END.
  END CASE.
  IF adm-current-page eq 0
  THEN RUN select-page IN THIS-PROCEDURE ( 1 ).
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
  VIEW FRAME D-Dialog.
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.
