&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка сертификата

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/27/05
Author: Bakhtadze Natalya
Creation date: 09/27/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter i-mode as char no-undo.
define input-output parameter i-rec as recid no-undo.
define input parameter i-type like ub.clients.obj-type no-undo.
define input parameter i-code like ub.clients.obj-code no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка сертификата".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/gds-list.i gds-list def "new shared" }

/* Local Variable Definitions ---                                       */

def buffer b-sert for ub.sert.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.sert.sert-code ub.sert.first-date ~
ub.sert.last-date ub.sert.sert-org ub.sert.blank-num ub.sert.PS
&Scoped-define ENABLED-TABLES ub.sert
&Scoped-define FIRST-ENABLED-TABLE ub.sert
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-gds b-hist b-help
&Scoped-Define DISPLAYED-FIELDS ub.sert.cli-code ub.sert.cli-type ~
ub.sert.sert-code ub.sert.first-date ub.sert.last-date ub.sert.sert-org ~
ub.sert.blank-num ub.sert.PS
&Scoped-define DISPLAYED-TABLES ub.sert
&Scoped-define FIRST-DISPLAYED-TABLE ub.sert
&Scoped-Define DISPLAYED-OBJECTS v-c-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cli
     LABEL ""
     SIZE 2.5 BY .96.

DEFINE BUTTON b-gds
     LABEL "Товар(ы)"
     SIZE 10 BY 1 TOOLTIP "Выбор одного или нескольких товаров".

DEFINE BUTTON b-help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "История"
     SIZE 10 BY 1 TOOLTIP "История сертификата".

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1 TOOLTIP "Вод сертификата"
     BGCOLOR 8 .

DEFINE VARIABLE v-c-name AS CHARACTER FORMAT "X(30)":U
     VIEW-AS FILL-IN
     SIZE 41.13 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-gds AT ROW 1 COL 31
     b-hist AT ROW 1 COL 41
     b-help AT ROW 1 COL 51
     ub.sert.cli-code AT ROW 4.04 COL 1 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     ub.sert.cli-type AT ROW 4.04 COL 12.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1
     v-c-name AT ROW 4.04 COL 22 COLON-ALIGNED NO-LABEL
     b-cli AT ROW 4.08 COL 21.5
     ub.sert.sert-code AT ROW 5.58 COL 12.5 COLON-ALIGNED FORMAT "X(35)"
          VIEW-AS FILL-IN
          SIZE 37 BY 1 TOOLTIP "Код сертификата"
     ub.sert.first-date AT ROW 6.92 COL 12.63 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "Дата начала действия сертификата"
     ub.sert.last-date AT ROW 6.92 COL 47.25 COLON-ALIGNED
          LABEL "Дата окончания"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "Дата окончания сертификата"
     ub.sert.sert-org AT ROW 8.17 COL 26 COLON-ALIGNED WIDGET-ID 2
          VIEW-AS FILL-IN
          SIZE 37 BY 1
     ub.sert.blank-num AT ROW 9.5 COL 13 COLON-ALIGNED WIDGET-ID 4
          VIEW-AS FILL-IN
          SIZE 21 BY 1
     ub.sert.PS AT ROW 10.79 COL 13 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 50.13 BY 1
     "Поставщик/Производитель:" VIEW-AS TEXT
          SIZE 28.75 BY .92 AT ROW 3.17 COL 1
     SPACE(35.37) SKIP(8.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Добавление/изменение сертификата"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-cli IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-cli:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN ub.sert.cli-code IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN ub.sert.cli-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.sert.last-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN ub.sert.sert-code IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN v-c-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Добавление/изменение сертификата */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds Dialog-Frame
ON CHOOSE OF b-gds IN FRAME Dialog-Frame /* Товар(ы) */
DO:
  def var g-l as log init no no-undo.
  define variable v-host-code like ub.sysconf.host-code no-undo .
  message "Вы хотите задать этот сертификат для товара(ов)?"
    view-as alert-box question buttons Yes-No update g-l.
  if g-l then do:
   { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
   run str/gds-list.w (
                 input parparentproc
                ,input v-host-code
                ,input p-curr-obj-type
                ,input p-curr-obj-code).

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE ub.sert THEN RETURN.
  run ref/c-serts.w (
                INPut parParentProc
               ,INPUT '':U /* bttns  */
               ,INPUT 'onet' /*p-mode*/
               ,INPUT sert.cli-type
               ,INPUT sert.cli-code
               ,INPUT sert.sert-code
               ,INPUT 0
               ,INPUT '':U
               ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
define variable v-ii as integer no-undo .
define variable v-ok  as integer no-undo .
define variable v-err as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

def var p-l as log init no no-undo.
  if can-find(first b-sert where
                    b-sert.cli-type = ub.sert.cli-type and
                    b-sert.cli-code =  ub.sert.cli-code and
                    b-sert.sert-code = input ub.sert.sert-code and
                    recid(b-sert) <> recid(ub.sert) ) then do:
    message "По данному клиенту уже есть сертификат с кодом " input sert.sert-code
            sert.cli-type  sert.cli-code       view-as alert-box error.
    return no-apply.
  end.
  assign
  sert.last-date
  sert.first-date
  sert.ps
  sert.blank-num
  sert.sert-org
  ub.sert.sert-code.
  if sert.last-date = ? then do:
    message "Введите дату окончания сертификата" view-as alert-box error.
    return no-apply.
  end.
  if sert.first-date = ? then do:
    message "Введите дату начала действия сертификата" view-as alert-box error.
    return no-apply.
  end.
  if sert.sert-code = ?
  or sert.sert-code = ''
  then do:
    message "Введите номер сертификата" view-as alert-box error.
    return no-apply.
  end.
  if can-find(first gds-list) or
     can-find (first ub.sert-join where
                     ub.sert-join.cli-type = i-type and
                     ub.sert-join.cli-code = i-code AND
                     ub.sert-join.SERT-code = input ub.sert.sert-code
                     ) then.
  else do:
    if i-mode = {&add-def} then do:
      { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
      run str/gds-list.w (
                    input parparentproc
                    ,input v-host-code
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code).
    end.
    IF NOT CAN-FIND(FIRST GDS-LIST) THEN DO:
      message "Нет ни одного товара для данного сертификата. Будете задавать товар?"
          view-as alert-box question buttons Yes-No update g-log as log.
          if g-log then do:
              enable b-gds with frame {&frame-name}.
              disp b-gds   with frame {&frame-name}.
              return no-apply.
          end.
          else p-l = yes.
    end.
  end.
  if not p-l then run cre-s-j(output v-ii, output v-ok, output v-err).
  message
  substitute("Обработано &1 товаров, создано &2 привязок к сертификату, ошибок &3", v-ii, v-ok, v-err)
  view-as alert-box .
  i-rec = recid(sert).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/ed_date.i ub.sert.first-date }
{ gbl/ed_date.i ub.sert.last-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   find ub.clients where ub.clients.obj-type = i-type and
                                ub.clients.obj-code = i-code no-lock.
   if i-mode = {&add-def} then do:
        disable b-gds with frame {&frame-name}.
        create ub.sert.
        assign
            ub.sert.cli-type = i-type
            ub.sert.cli-code = i-code.
   end.
   else do:
      find ub.sert where recid(ub.sert) = i-rec.
      enable b-gds with frame {&frame-name}.
   end.
   v-c-name = ub.clients.obj-name.
  RUN Myenable.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cre-s-j Dialog-Frame
PROCEDURE cre-s-j :
define buffer gl-goods for ub.goods.
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter v-ii as integer no-undo .
define output parameter v-ok  as integer no-undo .
define output parameter v-err as integer no-undo .
define variable v-b-code like ub.bar-code.b-code no-undo .
  _gds-list:
  for each gds-list :
    assign
    v-ii = v-ii + 1
    .
    find first gl-goods where
              gl-goods.artic     = gds-list.artic     and
              gl-goods.prod-type = gds-list.prod-type and
              gl-goods.prod-code = gds-list.prod-code no-lock.

    FIND ub.gds-prt WHERE
         ub.gds-prt.upper-code = gds-list.prt-root NO-LOCK .
    { gbl/gdsbcode.i gl-goods.gds-code ? v-b-code }
    find first ub.sert-join where
              ub.sert-join.cli-type = i-type and
              ub.sert-join.cli-code = i-code and
              ub.sert-join.sert-code = ub.sert.sert-code and
              ub.sert-join.b-code = v-b-code no-error.
    if not available ub.sert-join then do:
        create ub.sert-join.
        assign
        ub.sert-join.cli-type = i-type
        ub.sert-join.cli-code = i-code
        ub.sert-join.sert-code = ub.sert.sert-code
        ub.sert-join.b-code = v-b-code .
        release ub.sert-join no-error .
    end.
    if error-status:error then do:
      assign
      v-err = v-err + 1
      .
    end.
    else do:
      assign
      v-ok = v-ok + 1
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY v-c-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.sert THEN
    DISPLAY ub.sert.cli-code ub.sert.cli-type ub.sert.sert-code ub.sert.first-date
          ub.sert.last-date ub.sert.sert-org ub.sert.blank-num ub.sert.PS
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-gds b-hist b-help ub.sert.sert-code
         ub.sert.first-date ub.sert.last-date ub.sert.sert-org
         ub.sert.blank-num ub.sert.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DISPLAY
v-c-name
WITH FRAME Dialog-Frame.
IF AVAILABLE ub.sert THEN
 DISPLAY
 ub.sert.cli-code
 ub.sert.cli-type
 ub.sert.sert-code
 ub.sert.first-date
 ub.sert.blank-num
 ub.sert.sert-org
 ub.sert.last-date
 ub.sert.PS
 WITH FRAME {&frame-name}.
  ENABLE
  ub.sert.sert-code when i-mode = {&add-def}
  ub.sert.first-date
  ub.sert.last-date
  ub.sert.blank-num
  ub.sert.sert-org
  ub.sert.PS
  Btn_OK
  Btn_Cancel
  b-gds
  b-help
  b-hist WHEN i-mode <> {&add-def}
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME