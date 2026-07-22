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

Подстановка поля clients.city в goods.alpha1

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/08/05
Author: Bakhtadze Natalya
Creation date: 09/08/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Подстановка поля clients.city в goods.alpha1" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }

define variable glog as logical no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.clients ub.firm ub.person

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 ub.clients.obj-type ub.clients.obj-code ~
ub.clients.obj-name ub.firm.city
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH ub.clients ~
      WHERE ub.clients.is-prod = TRUE ~
 AND ub.clients.obj-type = {&cmp} NO-LOCK, ~
      EACH ub.firm WHERE  ub.firm.firm-code = ub.clients.obj-code ~
      AND ub.firm.city <> "" NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 ub.clients ub.firm
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 ub.clients


/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 ub.clients.obj-type ub.clients.obj-code ~
ub.clients.obj-name ub.person.city
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-2
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH ub.clients ~
      WHERE ub.clients.is-prod = TRUE ~
 AND ub.clients.obj-type = {&prs} NO-LOCK, ~
      EACH ub.person WHERE ub.person.psn-code = ub.clients.obj-code ~
      AND ub.person.city <> "" NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 ub.clients ub.person
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 ub.clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-sel B-Help RS-client-type BROWSE-1 ~
BROWSE-2
&Scoped-Define DISPLAYED-OBJECTS RS-client-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel
     LABEL "Обновить товары производителя"
     SIZE 30 BY 1.

DEFINE VARIABLE RS-client-type AS CHARACTER INITIAL {&cmp}
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Организация", {&cmp},
"Физическое лицо", {&prs}
     SIZE 19.13 BY 2.04 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      ub.clients,
      ub.firm SCROLLING.

DEFINE QUERY BROWSE-2 FOR
      ub.clients,
      ub.person SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _STRUCTURED
  QUERY BROWSE-1 NO-LOCK DISPLAY
      ub.clients.obj-type
      ub.clients.obj-code
      ub.clients.obj-name
      ub.firm.city
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10.25.

DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      clients.obj-type
      clients.obj-code
      clients.obj-name
      person.city
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 71
     RS-client-type AT ROW 3.29 COL 2.25 NO-LABEL
     BROWSE-1 AT ROW 6.33 COL 1.5
     BROWSE-2 AT ROW 6.33 COL 1.5
     "Тип производителя" VIEW-AS TEXT
          SIZE 17.75 BY .75 AT ROW 2.38 COL 2.5
          FGCOLOR 4
     SPACE(80.12) SKIP(13.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Подстановка поля clients.city в goods.alpha1"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 RS-client-type Dialog-Frame */
/* BROWSE-TAB BROWSE-2 BROWSE-1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-2:HIDDEN  IN FRAME Dialog-Frame            = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _TblList          = "ub.clients,ub.firm WHERE ub.clients ..."
     _Options          = "NO-LOCK"
     _Where[1]         = "clients.is-prod = TRUE
 AND clients.obj-type = "{&cmp}"
     _JoinCode[2]      = " firm.firm-code = clients.obj-code"
     _Where[2]         = "firm.city <> """""
     _FldNameList[1]   = ub.clients.obj-type
     _FldNameList[2]   = ub.clients.obj-code
     _FldNameList[3]   = ub.clients.obj-name
     _FldNameList[4]   = ub.firm.city
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "ub.clients,ub.person WHERE ub.clients ..."
     _Options          = "NO-LOCK"
     _Where[1]         = "clients.is-prod = TRUE
 AND clients.obj-type = "{&prs}"
     _JoinCode[2]      = "person.psn-code = clients.obj-code"
     _Where[2]         = "person.city <> """""
     _FldNameList[1]   = ub.clients.obj-type
     _FldNameList[2]   = ub.clients.obj-code
     _FldNameList[3]   = ub.clients.obj-name
     _FldNameList[4]   = ub.person.city
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Подстановка поля clients.city в goods.alpha1 */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Обновить товары производителя */
DO:
 define variable v-rid-list as character no-undo.
 define variable choice as integer no-undo.
 define variable num-rec as integer no-undo.
 define variable num-rec-ok as integer no-undo.
 def buffer b-goods for ub.goods.
 if not avail ub.clients then return no-apply.
 message "Выберите страну, которую выхотите подставить во все товары данного поставщика"
 view-as alert-box.
 run ref/countris.w ( input parparentproc
               , input "b-sel"
               , input-output v-rid-list ).
 if v-rid-list = '' then do:
        return no-apply.
 end.
 FIND FIRST ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
 run gbl/d-askw.w (input "УТИЛИТА",
              input ("Подстановка страны << " + ub.country.short-name +
                     ">>  во все товары производителя " +
                     ub.clients.obj-type + string(ub.clients.obj-code) + " " + ub.clients.obj-name),
              input "|",
              input "Подставить|Отказ",
              input "|",
              input 1,
              input 2,
              output choice).
 if choice = 2 then return no-apply.
 FOR EACH ub.goods NO-LOCK WHERE
          ub.goods.prod-type = ub.clients.obj-type AND
          ub.goods.prod-code = ub.clients.obj-code :
    num-rec = num-rec + 1.
    FIND FIRST b-goods where recid(b-goods) = recid(ub.goods) NO-ERROR.
    IF AVAIL b-goods then
    DO TRANSACTION:
    assign
    b-goods.alpha1 = ub.country.alpha1 no-error.
    END.
    IF error-status:error then do:
        run waitfram-hide in this-procedure .
        message "Не удалось изменить товар " ub.goods.artic "Поставщик" ub.goods.prod-type ub.goods.prod-code
        "Продолжить изменение товаров производителя"
        view-as alert-box ERROR buttons YES-NO update glog.
        if not glog then do:
            IF num-rec > num-rec-ok then
            message "Из выбранных " num-rec "товаров удалось отредактировать " num-rec-ok.
            return.
        end.
    end.
    else num-rec-ok = num-rec-ok + 1.
    if num-rec modulo 10 = 0 then do:
        run waitfram-show in this-procedure
          (input "Обработано " + string(num-rec) + " из них удачно " + string(num-rec-ok)
          ).
    end.
 end.
 run waitfram-hide in this-procedure .
 IF num-rec > num-rec-ok then
 message "Из выбранных " num-rec
        "товаров удалось отредактировать " num-rec-ok.
 else
 message "Пакетное изменение страны производителя для товаров производителя "
         ub.clients.obj-type ub.clients.obj-code ub.clients.obj-name
         " прошло успешно".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-client-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-client-type Dialog-Frame
ON VALUE-CHANGED OF RS-client-type IN FRAME Dialog-Frame
DO:
  assign RS-client-type.
  CASE RS-client-type:
    WHEN {&cmp} then do:
      HIDE browse-2 IN FRAME {&frame-name}.
      DISPLAY BROWSE-1 WITH FRAME {&frame-name}.
    END.
    WHEN {&prs} then do:
      HIDE browse-1 IN FRAME {&frame-name}.
      DISPLAY BROWSE-2 WITH FRAME {&frame-name}.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/curdbnum.i v-curr-db-num }
   FIND ub.db WHERE ub.db.db-num = v-curr-db-num NO-LOCK .
   IF NOT ub.db.add-goods then do:
        message "В данной БД не разрешено изменять товары!" view-as alert-box ERROR.
        return.
   end.
  RUN enable_UI.
  APPLY "VALUE-CHANGED" to RS-client-type.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY RS-client-type
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-sel B-Help RS-client-type BROWSE-1 BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME