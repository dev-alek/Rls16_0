&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор контрагента для документа пересортица

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/10/06


*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор контрагента для документа пересортица".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ str/vrclvmd.i  }
/* Parameters Definitions ---                                           */
define input  parameter parparentproc         as handle               no-undo.
define input  parameter parobj-type           as character            no-undo.
define input  parameter parobj-code           as integer              no-undo.
define output parameter parno-change-cli-cntr as logical              no-undo.
define output parameter parcli-type           as character            no-undo.
define output parameter parcli-code           as integer              no-undo.
define output parameter parcontract-code      as integer              no-undo.
define output parameter parset-cli-contr      as logical   initial no no-undo.

/* Local Variable Definitions ---                                       */
define variable varwithout-obj-host-code like ub.sysconf.host-code      no-undo.
define variable varobj-type              like ub.clients.obj-type       no-undo.
define variable varobj-code              like ub.clients.obj-code       no-undo.
define variable varhost-code             like ub.clients.obj-code       no-undo.
define variable varcontract-code         like ub.contract.contract-code no-undo.
define variable varneed-contract         as logical   no-undo .
define variable varneed-contract-type    as   character                 no-undo.
define variable v-err as logical   no-undo .

define buffer bf-host_clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help b-choose
&Scoped-Define DISPLAYED-OBJECTS b-choose

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-contract
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE VARIABLE varcli-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "&Поставщик"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 44.13 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE varcontract-prn-code AS CHARACTER FORMAT "X(256)":U INITIAL "БЕЗ ДОГОВОРА"
     LABEL "&Договор"
     VIEW-AS FILL-IN
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE b-choose AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По тем же контрагентам и договорам", 1,
"Выбор контрагента и договора", 2
     SIZE 38 BY 3 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11.5
     b-help AT ROW 1 COL 22
     b-choose AT ROW 2.75 COL 1.5 NO-LABEL
     varcli-code AT ROW 6 COL 11 COLON-ALIGNED
     varcli-type AT ROW 6 COL 21.5 COLON-ALIGNED NO-LABEL
     r-cli AT ROW 6 COL 28
     varcli-name AT ROW 7.25 COL 11 COLON-ALIGNED NO-LABEL
     varcontract-prn-code AT ROW 8.75 COL 11 COLON-ALIGNED
     r-contract AT ROW 8.75 COL 31
     SPACE(23.37) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор контрагента"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON r-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       r-cli:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON r-contract IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       r-contract:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcli-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcli-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcli-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcli-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcli-type IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcli-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcontract-prn-code IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcontract-prn-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Выбор контрагента */
DO:
    define buffer bf_clients  for ub.clients.
    define buffer bf_contract for ub.contract.
    if b-choose = 1 then do:
      assign
        parcli-type           = "":u
        parcli-code           = 0
        parcontract-code      = 0
        parno-change-cli-cntr = yes
        parset-cli-contr      = yes.
    end.
    else do:
      if varcli-code = ?  or
         varcli-code = 0  then do:
        message "Не указан контрагент." view-as alert-box.
        apply "entry" to varcli-code in frame {&frame-name}.
        return no-apply.
      end.
      if varcli-type = ?  or
         varcli-type = "" then do:
          message "Не указан контрагент." view-as alert-box.
          apply "entry" to varcli-type in frame {&frame-name}.
          return no-apply.
      end.
      find first bf_clients where bf_clients.obj-type = varcli-type and
                                  bf_clients.obj-code = varcli-code no-lock no-error.
      if not available bf_clients then do:
        message "Не найден контрагент " bf_clients.obj-type " " bf_clients.obj-code " ." view-as alert-box.
        apply "entry" to varcli-type in frame {&frame-name}.
        return no-apply.
      end.
      if bf_clients.obj-type = {&shop}  or
         bf_clients.obj-type = {&stock} then do:
        message "Контрагент не может иметь тип: " {&shop} " или " {&stock} " ." view-as alert-box.
        return no-apply.
      end.
      if varneed-contract = yes and
         not (bf_clients.obj-type = {&cmp} and bf_clients.obj-code = varhost-code) then do:
        if varcontract-code = 0 then do:
          message "В системе запрещено создание складских документов без договоров." skip
                  "По контрагенту " bf_clients.obj-code " " bf_clients.obj-type " " bf_clients.obj-name " не выбран договор для текущей фирмы."
          view-as alert-box.
          return no-apply.
        end.
      end.
      if varcontract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = varhost-code     and
                                     bf_contract.contract-code = varcontract-code no-lock no-error.
        if not available bf_contract then do:
          message "Не наден договор номер " varcontract-prn-code " внутренний номер " varcontract-code " по фирме " varhost-code " ." view-as alert-box.
          return no-apply.
        end.
        if bf_contract.cli-type = bf_clients.obj-type and
           bf_contract.cli-code = bf_clients.obj-code then do:
          assign
            parcontract-code     = bf_contract.contract-code.
        end.
        else do:
          message "Выбранный договор " bf_contract.contract-prn-code " с внутренним номером " bf_contract.contract-code " ." skip
                  "Принадлежит контрагенту: " bf_contract.cli-code " " bf_contract.cli-type " ." skip
                  "Вы выбрали контрагента: " bf_clients.obj-code "  " bf_clients.obj-type " ."
          view-as alert-box.
          return no-apply.
        end.
      end.
      assign
        parcli-type = bf_clients.obj-type
        parcli-code = bf_clients.obj-code.
      assign
        parno-change-cli-cntr = no
        parset-cli-contr      = yes.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор контрагента */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose Dialog-Frame
ON VALUE-CHANGED OF b-choose IN FRAME Dialog-Frame
DO:
  assign frame {&frame-name}
    b-choose.
  if b-choose = 1 then do:
    assign
      varcli-type          = ""
      varcli-code          = 0
      varcontract-code     = 0
      varcontract-prn-code = "БЕЗ ДОГОВОРА".
    hide varcli-type varcli-code r-cli r-contract varcontract-prn-code in frame {&frame-name}.
  end.
  else do:
    assign
      varcli-type          = {&cmp}
      varcli-code          = varhost-code
      varcontract-code     = 0
      varcontract-prn-code = "БЕЗ ДОГОВОРА".
    view varcli-type varcli-code r-cli r-contract varcontract-prn-code in frame {&frame-name}.
    enable varcli-type varcli-code r-cli r-contract with frame {&frame-name}.
    display varcli-type varcli-code varcontract-prn-code with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE varrec-list AS CHARACTER NO-UNDO.
  define variable varrid-list as character no-undo.
  DEFINE VARIABLE varrecid    AS RECID     NO-UNDO.
  DEFINE BUFFER bf_clients  FOR ub.clients.
  DEFINE BUFFER bf_contract FOR ub.contract.
  if transaction = yes then do:
    message "Критическая ошибка." skip
            "Вы находитесь в транзакции." skip
            "Работа со справочником клиентов невозможна."
    view-as alert-box error.
    return no-apply.
  end.
  run ref/cli-all.w (parparentproc
                , "b-sel,b-add"
                , {&ALL}
                , ?
                , ?
                , ?
                , ?
                , ?
                , output varrec-list) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-APPLY.
  END.
  IF varrec-list <> "" THEN DO:
    ASSIGN
      varrecid = integer(ENTRY(1, varrec-list)).
    FIND FIRST bf_clients WHERE RECID(bf_clients) = varrecid NO-LOCK.
    IF bf_clients.obj-type = {&shop}  OR
       bf_clients.obj-type = {&stock} THEN DO:
       MESSAGE "Склад или магазин не может быть контрагентом в данном документе."
       VIEW-AS ALERT-BOX.
       RETURN NO-APPLY.
    END.
    IF bf_clients.obj-type = {&cmp}       AND
       bf_clients.obj-code = varhost-code THEN DO:
       ASSIGN
         varcontract-code     = 0
         varcontract-prn-code = "БЕЗ ДОГОВОРА"
       .
    END.
    ELSE DO:
      FIND FIRST bf_contract WHERE bf_contract.host-code = varhost-code        AND
                                   bf_contract.cli-type  = bf_clients.obj-type AND
                                   bf_contract.cli-code  = bf_clients.obj-code AND
                                   bf_contract.status_   = {&current-contr}    NO-LOCK NO-ERROR.
      IF NOT AVAILABLE bf_contract THEN DO:
        IF varneed-contract = yes THEN DO:
          MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
                  "По контрагенту " bf_clients.obj-code " " bf_clients.obj-type " " bf_clients.obj-name " нет ни одного открытого договора для текущей фирмы."
          VIEW-AS ALERT-BOX.
          RETURN NO-APPLY.
        END.
      END.
      ELSE DO:
        run str/cont-all.w (input parparentproc,
                        input varhost-code,
                        input "b-sel",
                        input {&company} ,
                        input bf_clients.obj-type,
                        input bf_clients.obj-code,
                        input ?,
                        input ?,
                        input "current":u,
                        input {&income},
                        input-output varrid-list ) no-error.
        if error-status:error then do:
          message "Ошибка при вызове справочника договоров." skip
                  return-value                skip
          view-as alert-box error.
          return no-apply.
        end.
        IF varrid-list <> "" THEN DO:
          assign
            varrecid = integer(entry(1, varrid-list)).
          find first bf_contract where recid(bf_contract) = varrecid no-lock.
          if bf_contract.cli-type = bf_clients.obj-type and
             bf_contract.cli-code = bf_clients.obj-code  then do:
            assign
              varcontract-code     = bf_contract.contract-code
              varcontract-prn-code = bf_contract.contract-prn-code.
          end.
          ELSE DO:
            MESSAGE "Выбранный договор " bf_contract.contract-prn-code " с внутренним номером " bf_contract.contract-code " ." SKIP
                    "Принадлежит контрагенту: " bf_contract.cli-code " " bf_contract.cli-type " ." SKIP
                    "Вы выбрали контрагента: " bf_clients.obj-code "  " bf_clients.obj-type " ."
            VIEW-AS ALERT-BOX.
            RETURN NO-APPLY.
          END.
        END.
        ELSE DO:
          IF varneed-contract = yes THEN DO:
            MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
                    "По контрагенту " bf_clients.obj-code " " bf_clients.obj-type " " bf_clients.obj-name " не выбран договор для текущей фирмы."
            VIEW-AS ALERT-BOX.
            RETURN NO-APPLY.
          END.
        END.
      END.
    END.
    ASSIGN
      varcli-type = bf_clients.obj-type
      varcli-code = bf_clients.obj-code
      varcli-name = bf_clients.obj-name.
    DISPLAY varcli-type varcli-code varcli-name varcontract-prn-code WITH FRAME {&FRAME-NAME}.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-contract Dialog-Frame
ON CHOOSE OF r-contract IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER bf_contract FOR ub.contract.
  DEFINE VARIABLE varrid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varrecid    AS RECID     NO-UNDO.
  IF varcli-type <> ?    AND
     varcli-type <> "":u AND
     varcli-code <> 0    AND
     varcli-code <> ?    THEN DO:
    IF NOT (varcli-type = {&cmp}       AND
      INPUT FRAME {&frame-name} varcli-code  = varhost-code) THEN DO:
      run str/cont-all.w (input parparentproc,
                      input varhost-code,
                      input "b-sel",
                      input {&company} ,
                      input varcli-type,
                      input varcli-code,
                      input ?,
                      input ?,
                      input "current":u,
                      input {&income},
                      input-output varrid-list ) no-error.
      if error-status:error then do:
        message "Ошибка при вызове справочника договоров." skip
                return-value                skip
        view-as alert-box error.
        return NO-APPLY.
      end.
      IF varrid-list <> "" THEN DO:
        assign
          varrecid = integer(entry(1, varrid-list)).
        find first bf_contract where recid(bf_contract) = varrecid NO-LOCK.
        if bf_contract.cli-type = varcli-type AND
           bf_contract.cli-code = varcli-code then do:
          assign
            varcontract-code     = bf_contract.contract-code
            varcontract-prn-code = bf_contract.contract-prn-code.
          DISPLAY varcontract-prn-code WITH FRAME {&FRAME-NAME}.
        end.
        ELSE DO:
          MESSAGE "Выбранный договор " bf_contract.contract-prn-code " с внутренним номером " bf_contract.contract-code " ." SKIP
                  "Принадлежит контрагенту: " bf_contract.cli-code " " bf_contract.cli-type " ." SKIP
                  "Вы выбрали контрагента: " varcli-code "  " varcli-type " ."
          VIEW-AS ALERT-BOX.
          RETURN NO-APPLY.
        END.
      END.
      ELSE DO:
        IF varneed-contract = yes THEN DO:
          MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
                  "По контрагенту " varcli-code " " varcli-type " нет ни одного открытого договора для текущей фирмы."
          VIEW-AS ALERT-BOX.
          RETURN NO-APPLY.
        END.
        ASSIGN
          varcontract-code = 0
          varcontract-prn-code = "БЕЗ ДОГОВОРА".
      END.
    END.
    ELSE DO:
      ASSIGN
        varcontract-code = 0
        varcontract-prn-code = "БЕЗ ДОГОВОРА".
    END.
    DISPLAY varcontract-prn-code WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
    MESSAGE "Выбрать договор можно только после указания контрагента." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcli-code Dialog-Frame
ON LEAVE OF varcli-code IN FRAME Dialog-Frame /* Поставщик */
DO:
  ASSIGN FRAME {&FRAME-NAME}
    varcli-code.
  APPLY "entry" TO varcli-type IN FRAME {&FRAME-NAME}.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcli-type Dialog-Frame
ON LEAVE OF varcli-type IN FRAME Dialog-Frame
DO:
 RUN find-cli IN THIS-PROCEDURE NO-ERROR.
 IF ERROR-STATUS:ERROR THEN DO:
   RETURN NO-APPLY.
 END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  FIND FIRST bf-host_clients WHERE bf-host_clients.obj-type = parobj-type AND
                                   bf-host_clients.obj-code = parobj-code NO-LOCK.
  ASSIGN
    varhost-code = bf-host_clients.host-code
    .
define variable varcontract       as character no-undo .
define variable varcontract-type  as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date      like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal   like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical   like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer   like ub.thbj-attr.property-value-integer no-undo .
define variable v-mastc           as logical   no-undo init false .
    run adm/shattri.p (
      input "get":U
      ,input parobj-type
      ,input parobj-code
      ,input {&attr-contr-in}
      ,input "contr-in-income"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output varneed-contract
      ,output varneed-contract-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "adm/shattri.p"
        view-as alert-box error
      .

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY b-choose
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help b-choose
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-cli Dialog-Frame
PROCEDURE find-cli :
DEFINE BUFFER bf_clients  FOR ub.clients.
  DEFINE BUFFER bf_contract FOR ub.contract.
  DEFINE VARIABLE varrid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varrec-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE varrecid    AS RECID     NO-UNDO.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = INPUT FRAME {&frame-name} varcli-type AND
                              bf_clients.obj-code = varcli-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf_clients THEN DO:
    MESSAGE "Нет контрагента " varcli-code " " INPUT FRAME {&frame-name} varcli-type " ."
    VIEW-AS ALERT-BOX.
    run ref/cli-all.w (parparentproc
                  , "b-sel,b-add"
                  , {&ALL}
                  , ?
                  , ?
                  , ?
                  , ?
                  , ?
                  , output varrec-list) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
    END.
    IF varrec-list <> "" THEN DO:
      ASSIGN
        varrecid = integer(ENTRY(1, varrec-list)).
      FIND FIRST bf_clients WHERE recid(bf_clients) = varrecid NO-LOCK.
      ASSIGN
        varcli-code = bf_clients.obj-code.
      DISPLAY varcli-code bf_clients.obj-type @ varcli-type WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
      RETURN NO-APPLY.
    END.
  END.
  IF varneed-contract = yes THEN DO:
    FIND FIRST bf_contract WHERE bf_contract.host-code = varhost-code     AND
                                 bf_contract.cli-type  = INPUT FRAME {&frame-name} varcli-type      AND
                                 bf_contract.cli-code  = varcli-code      AND
                                 bf_contract.status_   = {&current-contr} NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_contract THEN DO:
      MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
              "По контрагенту " bf_clients.obj-code " " INPUT FRAME {&frame-name} varcli-type " нет ни одного открытого договора для текущей фирмы."
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    ELSE DO:
      run str/cont-all.w (input parparentproc,
                      input varhost-code,
                      input "b-sel",
                      input {&company} ,
                      input INPUT FRAME {&frame-name} varcli-type,
                      input varcli-code,
                      input ?,
                      input ?,
                      input "current":u,
                      input {&income},
                      input-output varrid-list ) no-error.
      if error-status:error then do:
        message "Ошибка при вызове справочника договоров." skip
                return-value                skip
        view-as alert-box error.
        return NO-APPLY.
      end.
      IF varrid-list <> "" THEN DO:
        assign
          varrecid = integer(entry(1, varrid-list)).
        find first bf_contract where recid(bf_contract) = varrecid NO-LOCK.
        if bf_contract.cli-type = INPUT FRAME {&frame-name} varcli-type AND
           bf_contract.cli-code = varcli-code then do:
          assign
            varcontract-code     = bf_contract.contract-code
            varcontract-prn-code = bf_contract.contract-prn-code.
          DISPLAY varcontract-prn-code WITH FRAME {&FRAME-NAME}.
        end.
        ELSE DO:
          MESSAGE "Выбранный договор " bf_contract.contract-prn-code " с внутренним номером " bf_contract.contract-code " ." SKIP
                  "Принадлежит контрагенту: " bf_contract.cli-code " " bf_contract.cli-type " ." SKIP
                  "Вы выбрали контрагента: " varcli-code "  " INPUT FRAME {&frame-name} varcli-type " ."
          VIEW-AS ALERT-BOX.
          RETURN NO-APPLY.
        END.
      END.
      ELSE DO:
        MESSAGE "В системе запрещено создание складских документов без договоров." SKIP
                "По контрагенту " bf_clients.obj-code " " INPUT FRAME {&frame-name} varcli-type " не выбран договор по текущей фирмы."
        VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
      END.
    END.
  END.

  run ver-clients  (bf_clients.obj-type , bf_clients.obj-code , output v-err) .
  if  v-err then return NO-APPLY.

  ASSIGN FRAME {&FRAME-NAME} varcli-type.
  FIND FIRST bf_clients WHERE bf_clients.obj-type = varcli-type AND
                              bf_clients.obj-code = varcli-code NO-LOCK NO-ERROR.
  ASSIGN FRAME {&FRAME-NAME}
    varcli-name.
  DISPLAY varcli-name WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME