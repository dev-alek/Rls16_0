&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_c-fin-bank FOR ub.c-fin-bank.
DEFINE TEMP-TABLE tt-c-fin-bank NO-UNDO LIKE ub.c-fin-bank.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_sysconf FOR ub.sysconf.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка просмотра истории банка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/03
Author: Bakhtadze Natalya
Creation date: 10/16/03

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.


define input parameter p-mode as character no-undo.
/*может быть  {&lookup}*/

define input parameter p-host-code like ub.c-fin-bank.host-code no-undo.
define input parameter p-code-bank like ub.c-fin-bank.code-bank no-undo.
define input parameter p-corr-user-db-num like ub.c-fin-bank.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-fin-bank.chip-num  no-undo .

define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования банка".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
define buffer X_curr_sysconf for ub.sysconf.
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-c-fin-bank

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-c-fin-bank.host-code ~
tt-c-fin-bank.code-bank tt-c-fin-bank.bik tt-c-fin-bank.inn ~
tt-c-fin-bank.kpp tt-c-fin-bank.cor-acc tt-c-fin-bank.bank-name ~
tt-c-fin-bank.short-name tt-c-fin-bank.licenz tt-c-fin-bank.otdel ~
tt-c-fin-bank.bank-city tt-c-fin-bank.addres tt-c-fin-bank.addres1 ~
tt-c-fin-bank.phone tt-c-fin-bank.fax tt-c-fin-bank.e-mail ~
tt-c-fin-bank.okato tt-c-fin-bank.okonx tt-c-fin-bank.okpo tt-c-fin-bank.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-c-fin-bank.bik ~
tt-c-fin-bank.inn tt-c-fin-bank.kpp tt-c-fin-bank.cor-acc ~
tt-c-fin-bank.bank-name tt-c-fin-bank.short-name tt-c-fin-bank.licenz ~
tt-c-fin-bank.otdel tt-c-fin-bank.bank-city tt-c-fin-bank.addres ~
tt-c-fin-bank.addres1 tt-c-fin-bank.phone tt-c-fin-bank.fax ~
tt-c-fin-bank.e-mail tt-c-fin-bank.okato tt-c-fin-bank.okonx ~
tt-c-fin-bank.okpo tt-c-fin-bank.PS
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-c-fin-bank
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-c-fin-bank
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-c-fin-bank SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-c-fin-bank SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-c-fin-bank
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-c-fin-bank


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-fin-bank.bik tt-c-fin-bank.inn ~
tt-c-fin-bank.kpp tt-c-fin-bank.cor-acc tt-c-fin-bank.bank-name ~
tt-c-fin-bank.short-name tt-c-fin-bank.licenz tt-c-fin-bank.otdel ~
tt-c-fin-bank.bank-city tt-c-fin-bank.addres tt-c-fin-bank.addres1 ~
tt-c-fin-bank.phone tt-c-fin-bank.fax tt-c-fin-bank.e-mail ~
tt-c-fin-bank.okato tt-c-fin-bank.okonx tt-c-fin-bank.okpo tt-c-fin-bank.PS
&Scoped-define ENABLED-TABLES tt-c-fin-bank
&Scoped-define FIRST-ENABLED-TABLE tt-c-fin-bank
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help
&Scoped-Define DISPLAYED-FIELDS tt-c-fin-bank.host-code ~
tt-c-fin-bank.code-bank tt-c-fin-bank.bik tt-c-fin-bank.inn ~
tt-c-fin-bank.kpp tt-c-fin-bank.cor-acc tt-c-fin-bank.bank-name ~
tt-c-fin-bank.short-name tt-c-fin-bank.licenz tt-c-fin-bank.otdel ~
tt-c-fin-bank.bank-city tt-c-fin-bank.addres tt-c-fin-bank.addres1 ~
tt-c-fin-bank.phone tt-c-fin-bank.fax tt-c-fin-bank.e-mail ~
tt-c-fin-bank.okato tt-c-fin-bank.okonx tt-c-fin-bank.okpo tt-c-fin-bank.PS
&Scoped-define DISPLAYED-TABLES tt-c-fin-bank
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-fin-bank
&Scoped-Define DISPLAYED-OBJECTS f-host-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-host-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-c-fin-bank SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     tt-c-fin-bank.host-code AT ROW 2.5 COL 13 COLON-ALIGNED
          LABEL "Фирма"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     f-host-name AT ROW 2.5 COL 23.5 COLON-ALIGNED NO-LABEL
     tt-c-fin-bank.code-bank AT ROW 2.5 COL 78.5 COLON-ALIGNED
          LABEL "Код банка"
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     tt-c-fin-bank.bik AT ROW 4.25 COL 13 COLON-ALIGNED
          LABEL "БИК"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-c-fin-bank.inn AT ROW 4.25 COL 32 COLON-ALIGNED
          LABEL "INN"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-c-fin-bank.kpp AT ROW 4.25 COL 62.13 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-c-fin-bank.cor-acc AT ROW 5.5 COL 13 COLON-ALIGNED
          LABEL "Корр.счет"
          VIEW-AS FILL-IN
          SIZE 84 BY 1
     tt-c-fin-bank.bank-name AT ROW 6.75 COL 13 COLON-ALIGNED
          LABEL "Наим. банка"
          VIEW-AS FILL-IN
          SIZE 84 BY 1
     tt-c-fin-bank.short-name AT ROW 8 COL 13 COLON-ALIGNED
          LABEL "Кратк. назв."
          VIEW-AS FILL-IN
          SIZE 84 BY 1
     tt-c-fin-bank.licenz AT ROW 9.25 COL 13 COLON-ALIGNED
          LABEL "Лицензия"
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     tt-c-fin-bank.otdel AT ROW 10.5 COL 13 COLON-ALIGNED
          LABEL "Отделение"
          VIEW-AS FILL-IN
          SIZE 62.88 BY 1
     tt-c-fin-bank.bank-city AT ROW 11.75 COL 21.5 COLON-ALIGNED
          LABEL "Город"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-c-fin-bank.addres AT ROW 12.75 COL 13 COLON-ALIGNED
          LABEL "Адрес юрид."
          VIEW-AS FILL-IN
          SIZE 78 BY 1
     tt-c-fin-bank.addres1 AT ROW 14 COL 13 COLON-ALIGNED
          LABEL "Адрес почт."
          VIEW-AS FILL-IN
          SIZE 78 BY 1
     tt-c-fin-bank.phone AT ROW 15.25 COL 13 COLON-ALIGNED
          LABEL "Телефон"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-c-fin-bank.fax AT ROW 15.25 COL 55.63 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-c-fin-bank.e-mail AT ROW 16.5 COL 13 COLON-ALIGNED
          LABEL "E-mail"
          VIEW-AS FILL-IN
          SIZE 34 BY 1
     tt-c-fin-bank.okato AT ROW 17.75 COL 13 COLON-ALIGNED
          LABEL "ОКАТО"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-c-fin-bank.okonx AT ROW 17.75 COL 36 COLON-ALIGNED
          LABEL "OKONX"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-c-fin-bank.okpo AT ROW 17.75 COL 55.75 COLON-ALIGNED
          LABEL "ОКПО" FORMAT "X(10)"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-c-fin-bank.PS AT ROW 19 COL 15 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 63.5 BY 4
     "Примечания" VIEW-AS TEXT
          SIZE 10.63 BY 1 AT ROW 18.63 COL 2.25
     "Адрес юрид.:" VIEW-AS TEXT
          SIZE 12 BY 1 AT ROW 11.75 COL 2
     SPACE(85.00) SKIP(10.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запись истории по Банку"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_c-fin-bank B "?" ? ub c-fin-bank
      TABLE: tt-c-fin-bank T "?" NO-UNDO ub c-fin-bank
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-c-fin-bank.addres IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.addres1 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.bank-city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.bank-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.bik IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.code-bank IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.cor-acc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.e-mail IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-host-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.fax IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.host-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.inn IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.kpp IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.licenz IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.okato IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.okonx IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.okpo IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.otdel IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.phone IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-bank.short-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-c-fin-bank"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Запись истории по Банку */
DO:
  APPLY "END-ERROR":U TO SELF.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 { gbl/curdbnum.i v-db-num }
  for each tt-c-fin-bank:
      delete tt-c-fin-bank.
  end.
  find first locked_c-fin-bank no-lock where
                  recid(locked_c-fin-bank) = p-doc-rec.

  if not available locked_c-fin-bank then do:
  message
  vss-workfile vss-revision vss-description skip
  "Не найдена запись БАНК"
  view-as alert-box error .
  undo, return error.
  end.
  create tt-c-fin-bank.
  buffer-copy locked_c-fin-bank to tt-c-fin-bank.

  RUN MYEnable.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY f-host-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-fin-bank THEN
    DISPLAY tt-c-fin-bank.host-code tt-c-fin-bank.code-bank tt-c-fin-bank.bik
          tt-c-fin-bank.inn tt-c-fin-bank.kpp tt-c-fin-bank.cor-acc
          tt-c-fin-bank.bank-name tt-c-fin-bank.short-name tt-c-fin-bank.licenz
          tt-c-fin-bank.otdel tt-c-fin-bank.bank-city tt-c-fin-bank.addres
          tt-c-fin-bank.addres1 tt-c-fin-bank.phone tt-c-fin-bank.fax
          tt-c-fin-bank.e-mail tt-c-fin-bank.okato tt-c-fin-bank.okonx
          tt-c-fin-bank.okpo tt-c-fin-bank.PS
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help tt-c-fin-bank.bik tt-c-fin-bank.inn
         tt-c-fin-bank.kpp tt-c-fin-bank.cor-acc tt-c-fin-bank.bank-name
         tt-c-fin-bank.short-name tt-c-fin-bank.licenz tt-c-fin-bank.otdel
         tt-c-fin-bank.bank-city tt-c-fin-bank.addres tt-c-fin-bank.addres1
         tt-c-fin-bank.phone tt-c-fin-bank.fax tt-c-fin-bank.e-mail
         tt-c-fin-bank.okato tt-c-fin-bank.okonx tt-c-fin-bank.okpo
         tt-c-fin-bank.PS
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
tt-c-fin-bank.okonx:label in frame {&frame-name} = "{&abbr_okonh_allshift}".
tt-c-fin-bank.inn:label in frame {&frame-name} = "{&abbr_inn_allshift}".
tt-c-fin-bank.kpp:label in frame {&frame-name} = "{&abbr_kpp_allshift}".
find first X_clients no-lock where
            X_clients.obj-type = {&cmp}
        AND X_clients.obj-code = p-host-code.
  DISPLAY
  X_clients.obj-name @  f-host-name
   WITH FRAME Dialog-Frame.
ENABLE
b-quit
B-exit
B-Help
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-c-fin-bank THEN
DISPLAY
tt-c-fin-bank.bank-city
tt-c-fin-bank.host-code
tt-c-fin-bank.code-bank
tt-c-fin-bank.bik
tt-c-fin-bank.inn
tt-c-fin-bank.kpp
tt-c-fin-bank.cor-acc
tt-c-fin-bank.bank-name
tt-c-fin-bank.short-name
tt-c-fin-bank.licenz
tt-c-fin-bank.otdel
tt-c-fin-bank.addres
tt-c-fin-bank.addres1
tt-c-fin-bank.phone
tt-c-fin-bank.fax
tt-c-fin-bank.e-mail
tt-c-fin-bank.okato
tt-c-fin-bank.okonx
tt-c-fin-bank.okpo
tt-c-fin-bank.PS
WITH FRAME {&frame-name} .

if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  .
  hide
  b-exit in frame {&frame-name} .
end.
VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME