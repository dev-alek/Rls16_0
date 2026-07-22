CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки СПН (SmartObject)".
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
define stream test.
define variable v-old-exch-dir as character no-undo .
define variable v-old-heap-dir as character no-undo .
DEFINE BUTTON b-save DEFAULT
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel-exch-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.
DEFINE BUTTON b-sel-heap-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.
DEFINE VARIABLE v-exch-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "каталог exch"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.
DEFINE VARIABLE v-heap-dir AS CHARACTER FORMAT "X(256)":U
     LABEL "каталог heap"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.
DEFINE FRAME F-Main
     b-save AT ROW 1.13 COL 1
     b-sel-exch-dir AT ROW 2.5 COL 55
     v-exch-dir AT ROW 2.54 COL 14 COLON-ALIGNED
     b-sel-heap-dir AT ROW 3.67 COL 55
     v-heap-dir AT ROW 3.75 COL 14 COLON-ALIGNED
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 58.25 BY 4.5.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
    ASSIGN adm-object-hdl = FRAME F-Main:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartObject~`':U +
     'FRAME~`':U +
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
    DISABLE b-save b-sel-exch-dir v-exch-dir b-sel-heap-dir v-heap-dir WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN b-save b-sel-exch-dir v-exch-dir b-sel-heap-dir v-heap-dir WITH FRAME F-Main.
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
ON CHOOSE OF b-save IN FRAME F-Main
DO:
  assign
    v-exch-dir
    v-heap-dir
  .
  run check-dir ( input-output v-exch-dir ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message(0) skip
      error-status :get-message(1)
      view-as alert-box error.
    return no-apply.
  end.
  else do:
    if v-exch-dir <> v-old-exch-dir then do:
      put-key-value section "news":U key "nws-exch-dir":U value v-exch-dir  no-error.
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Файл настроек progress доступен только для чтения!" skip
          "Сохранение параметров невозможно."
          view-as alert-box error.
        return no-apply.
      end.
    end.
  end.
  run check-dir ( input-output v-heap-dir ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      return-value skip
      error-status :get-message(0) skip
      error-status :get-message(1)
      view-as alert-box error.
    return no-apply.
  end.
  else do:
    if v-heap-dir <> v-old-heap-dir then do:
      put-key-value section "news":U key "nws-heap-dir":U value v-heap-dir .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Файл настроек progress доступен только для чтения!" skip
          "Сохранение параметров невозможно."
          view-as alert-box error.
        return no-apply.
      end.
    end.
  end.
  message
    "Настройки СПН сохранены"
    view-as alert-box information.
END.
ON CHOOSE OF b-sel-exch-dir IN FRAME F-Main
DO:
  define variable v-dir-name  as character no-undo .
  define variable v-type      as character no-undo .
  define variable v-can-write as logical   no-undo .
  run gbl/dir-sel.p ( output v-dir-name
                 ,output v-type
                 ,output v-can-write
                ).
  if v-can-write then do:
    assign
      v-exch-dir = v-dir-name
    .
    display
      v-exch-dir
      with frame F-Main
    .
  end.
  APPLY "ENTRY" TO v-exch-dir IN FRAME F-Main .
END.
ON CHOOSE OF b-sel-heap-dir IN FRAME F-Main
DO:
  define variable v-dir-name  as character no-undo .
  define variable v-type      as character no-undo .
  define variable v-can-write as logical   no-undo .
  run gbl/dir-sel.p ( output v-dir-name
                 ,output v-type
                 ,output v-can-write
                ).
  if v-can-write then do:
    assign
      v-heap-dir = v-dir-name
    .
    display
      v-heap-dir
      with frame F-Main
    .
  end.
  APPLY "ENTRY" TO v-heap-dir IN FRAME F-Main .
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
get-key-value section "news":U key "nws-exch-dir":U value v-exch-dir .
get-key-value section "news":U key "nws-heap-dir":U value v-heap-dir .
if v-exch-dir = ? then do:
  assign
    v-exch-dir = "":U
  .
end.
if v-heap-dir = ? then do:
  assign
    v-heap-dir = "":U
  .
end.
assign
  v-old-exch-dir = v-exch-dir
  v-old-heap-dir = v-heap-dir
.
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
PROCEDURE check-dir :
define input-output parameter p-dir-name as character no-undo .
do
on error undo, return error
:
  define variable v-log as logical no-undo .
  assign
    file-info:file-name = p-dir-name
  .
  if file-info:file-type <> ?
    and index( file-info:file-type, "D":U ) <> 0
  then do:
    output stream test to "test.tst":U .
    put stream test unformatted "test":U skip.
    output stream test close.
    os-copy "test.tst":U value( p-dir-name ) .
    if os-error <> 0 then do:
      return error string( "Каталог" + chr(32) + p-dir-name + chr(32)
                           + "недоступен для чтения и(или) записи!"
                           + chr(10) + "Сохранение параметров невозможно."
                         ).
    end.
    else do:
      os-delete value( "test.tst":U ) .
      os-delete value( p-dir-name + chr(92) + "test.tst":U ) .
    end.
  end.
  else do:
    message
      "Каталог" p-dir-name "не существует!" skip
      "Cоздать его?"
      view-as alert-box information buttons yes-no update v-log.
    if v-log = false then do:
      return error substitute( "Отказ от создания каталога!" ).
    end.
    else do:
      run gbl/dir-cre.p ( input p-dir-name ) no-error .
      if error-status:error then do:
        return error substitute( "Ошибка при создании каталога &1&2&3", p-dir-name, chr(10), return-value ).
      end.
    end.
  end.
  assign
    file-info:file-name = p-dir-name
  .
  if file-info:file-type <> ? then do:
    assign
      p-dir-name = file-info:full-pathname
    .
  end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-exch-dir v-heap-dir
      WITH FRAME F-Main.
  ENABLE b-save b-sel-exch-dir v-exch-dir b-sel-heap-dir v-heap-dir
      WITH FRAME F-Main.
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.
