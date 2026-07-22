&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_fin-bank FOR fin-bank.
DEFINE TEMP-TABLE tt-fin-bank NO-UNDO LIKE fin-bank.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка редактирования банка

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
/*может быть {&add-def} {&update} {&lookup}*/

define input parameter p-host-code like ub.fin-bank.host-code no-undo.
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo.

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
define variable v-tab-order as character no-undo .

define buffer X_curr_sysconf for ub.sysconf.
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }

&scop tab-order   "B-exit,b-quit,b-print,b-hist,b-help,code-bank,bik,inn,kpp,cor-acc,rkc,bank-name,short-name,licenz," +  ~
                  "otdel,addres,addres1,phone,fax,e-mail,OKATO,OKONX,OKPO,PS" ~

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-fin-bank

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-fin-bank.host-code ~
tt-fin-bank.code-bank tt-fin-bank.bik tt-fin-bank.inn tt-fin-bank.kpp ~
tt-fin-bank.cor-acc tt-fin-bank.rkc tt-fin-bank.bank-name ~
tt-fin-bank.short-name tt-fin-bank.licenz tt-fin-bank.bank-city ~
tt-fin-bank.addres tt-fin-bank.addres1 tt-fin-bank.phone tt-fin-bank.fax ~
tt-fin-bank.e-mail tt-fin-bank.cl-bank tt-fin-bank.okato tt-fin-bank.okonx ~
tt-fin-bank.okpo tt-fin-bank.PS 
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-fin-bank.bik ~
tt-fin-bank.inn tt-fin-bank.kpp tt-fin-bank.cor-acc tt-fin-bank.rkc ~
tt-fin-bank.bank-name tt-fin-bank.short-name tt-fin-bank.licenz ~
tt-fin-bank.bank-city tt-fin-bank.addres tt-fin-bank.addres1 ~
tt-fin-bank.phone tt-fin-bank.fax tt-fin-bank.e-mail tt-fin-bank.cl-bank ~
tt-fin-bank.okato tt-fin-bank.okonx tt-fin-bank.okpo tt-fin-bank.PS 
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-fin-bank
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-fin-bank
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-fin-bank WHERE TRUE /* Join to tt-fin-bank incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-fin-bank WHERE TRUE /* Join to tt-fin-bank incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-fin-bank
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-fin-bank


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-fin-bank.bik tt-fin-bank.inn ~
tt-fin-bank.kpp tt-fin-bank.cor-acc tt-fin-bank.rkc tt-fin-bank.bank-name ~
tt-fin-bank.short-name tt-fin-bank.licenz tt-fin-bank.bank-city ~
tt-fin-bank.addres tt-fin-bank.addres1 tt-fin-bank.phone tt-fin-bank.fax ~
tt-fin-bank.e-mail tt-fin-bank.cl-bank tt-fin-bank.okato tt-fin-bank.okonx ~
tt-fin-bank.okpo tt-fin-bank.PS 
&Scoped-define ENABLED-TABLES tt-fin-bank
&Scoped-define FIRST-ENABLED-TABLE tt-fin-bank
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-print B-hist B-Help 
&Scoped-Define DISPLAYED-FIELDS tt-fin-bank.host-code tt-fin-bank.code-bank ~
tt-fin-bank.bik tt-fin-bank.inn tt-fin-bank.kpp tt-fin-bank.cor-acc ~
tt-fin-bank.rkc tt-fin-bank.bank-name tt-fin-bank.short-name ~
tt-fin-bank.licenz tt-fin-bank.bank-city tt-fin-bank.addres ~
tt-fin-bank.addres1 tt-fin-bank.phone tt-fin-bank.fax tt-fin-bank.e-mail ~
tt-fin-bank.cl-bank tt-fin-bank.okato tt-fin-bank.okonx tt-fin-bank.okpo ~
tt-fin-bank.PS 
&Scoped-define DISPLAYED-TABLES tt-fin-bank
&Scoped-define FIRST-DISPLAYED-TABLE tt-fin-bank
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

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 10 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 10 BY 1.

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
      tt-fin-bank SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-print AT ROW 1 COL 41
     B-hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 71
     tt-fin-bank.host-code AT ROW 2.5 COL 13 COLON-ALIGNED
          LABEL "Фирма" format 9999999999
          VIEW-AS FILL-IN 
          SIZE 12.5 BY 1
     f-host-name AT ROW 2.5 COL 26.38 COLON-ALIGNED NO-LABEL
     tt-fin-bank.code-bank AT ROW 2.5 COL 78.5 COLON-ALIGNED
          LABEL "Код банка"
          VIEW-AS FILL-IN 
          SIZE 8 BY 1
     tt-fin-bank.bik AT ROW 3.75 COL 13 COLON-ALIGNED
          LABEL "БИК"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     tt-fin-bank.inn AT ROW 3.75 COL 32 COLON-ALIGNED
          LABEL "INN"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     tt-fin-bank.kpp AT ROW 3.75 COL 62.13 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     tt-fin-bank.cor-acc AT ROW 5.33 COL 13.13 COLON-ALIGNED
          LABEL "№ Корсчета"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     tt-fin-bank.rkc AT ROW 5.38 COL 41 COLON-ALIGNED
          LABEL "РКЦ"
          VIEW-AS FILL-IN 
          SIZE 55 BY 1
     tt-fin-bank.bank-name AT ROW 6.75 COL 13 COLON-ALIGNED
          LABEL "Наим. банка"
          VIEW-AS FILL-IN 
          SIZE 84 BY 1
     tt-fin-bank.short-name AT ROW 8 COL 13 COLON-ALIGNED
          LABEL "Кратк. назв."
          VIEW-AS FILL-IN 
          SIZE 84 BY 1
     tt-fin-bank.licenz AT ROW 9.25 COL 13 COLON-ALIGNED
          LABEL "Лицензия"
          VIEW-AS FILL-IN 
          SIZE 50 BY 1
     tt-fin-bank.otdel AT ROW 10.5 COL 13 COLON-ALIGNED
          LABEL "Отделение"
          VIEW-AS FILL-IN 
          SIZE 62.88 BY 1
     tt-fin-bank.bank-city AT ROW 11.58 COL 13 COLON-ALIGNED
          LABEL "Город"
          VIEW-AS FILL-IN 
          SIZE 13 BY 1
     tt-fin-bank.addres AT ROW 12.75 COL 13 COLON-ALIGNED
          LABEL "Адрес юрид."
          VIEW-AS FILL-IN 
          SIZE 78 BY 1
     tt-fin-bank.addres1 AT ROW 14 COL 13 COLON-ALIGNED
          LABEL "Адрес почт."
          VIEW-AS FILL-IN 
          SIZE 78 BY 1
     tt-fin-bank.phone AT ROW 15.25 COL 13 COLON-ALIGNED
          LABEL "Телефон"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     tt-fin-bank.fax AT ROW 15.25 COL 55.63 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN 
          SIZE 22 BY 1
     tt-fin-bank.e-mail AT ROW 16.5 COL 13 COLON-ALIGNED
          LABEL "E-mail"
          VIEW-AS FILL-IN 
          SIZE 34 BY 1
     tt-fin-bank.cl-bank AT ROW 16.5 COL 61 COLON-ALIGNED
          LABEL "Клиент-Банк" FORMAT "X(25)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 35.5 BY 1
     tt-fin-bank.okato AT ROW 17.75 COL 13 COLON-ALIGNED
          LABEL "ОКАТО"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     tt-fin-bank.okonx AT ROW 17.75 COL 36 COLON-ALIGNED
          LABEL "OKNH"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     tt-fin-bank.okpo AT ROW 17.75 COL 55.75 COLON-ALIGNED
          LABEL "ОКПО" FORMAT "X(10)"
          VIEW-AS FILL-IN 
          SIZE 12 BY 1
     tt-fin-bank.PS AT ROW 19 COL 15 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 63.5 BY 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "Примечания" VIEW-AS TEXT
          SIZE 10.63 BY 1 AT ROW 19.75 COL 2.5
     SPACE(85.87) SKIP(2.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Банк"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_fin-bank B "?" ? ub fin-bank
      TABLE: tt-fin-bank T "?" NO-UNDO ub fin-bank
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-fin-bank.addres IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.addres1 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.bank-city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.bank-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.bik IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-fin-bank.cl-bank IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-bank.code-bank IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-bank.cor-acc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.e-mail IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-host-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.fax IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.host-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-bank.inn IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.kpp IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.licenz IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.okato IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.okonx IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.okpo IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-bank.otdel IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE EXP-LABEL                                       */
ASSIGN 
       tt-fin-bank.otdel:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-fin-bank.phone IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.rkc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-bank.short-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-fin-bank WHERE Temp-Tables.tt-fin-bank ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Банк */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
  run proc-save in this-procedure(yes) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo.
{ gbl/stdbtn.i }
    run ref/fincbnks.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input "":U /*bttns*/
                ,input "one":U
                ,input locked_fin-bank.host-code
                ,input locked_fin-bank.code-bank
                ,input-output v-rid-list
                              )

 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-log as logical no-undo .
define variable v-cmp as character no-undo .
{ gbl/stdbtn.i }
run proc-save in this-procedure (no) no-error.
buffer-compare tt-fin-bank to locked_fin-bank
case-sensitive
save result in v-cmp .
if v-cmp <> "":U then do:
  message
  "Вы изменили запись БАНК, но не сохранили ее" skip
  "сохранить перед печатью?"
  view-as alert-box QUESTION buttons YES-NO update v-log.
end.
run proc-save in this-procedure (v-log) no-error.
    run ref/finbankp.p (
                 INPUT parParentProc
                 ,input locked_fin-bank.host-code
                 ,input locked_fin-bank.code-bank
              ) no-error.
if error-status:error then do:
  return no-apply.
end.


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

{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> {&add-def}
 and p-mode <> {&update}
 and p-mode <> {&lookup}
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 { gbl/curdbnum.i v-db-num }
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code.
find first X_sysconf no-lock where
                X_sysconf.host-code = p-host-code.
 if p-mode <> {&lookup} then do:
    if X_curr_sysconf.host-code <> p-host-code
    or v-db-num <> X_sysconf.firm-db-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode и/или p-host-code и/или p-curr-host-code" p-mode p-host-code  p-curr-host-code
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-fin-bank:
        delete tt-fin-bank.
    end.
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_fin-bank EXclusive-lock where
                   recid(locked_fin-bank) = p-doc-rec no-wait no-error.
      if locked locked_fin-bank then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись БАНК занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_fin-bank no-lock where
                       recid(locked_fin-bank) = p-doc-rec no-error .
      if not avail locked_fin-bank then do:
        find first locked_fin-bank where
                  locKed_fin-bank.host-code = p-host-code
               AND locKed_fin-bank.code-bank = p-code-bank no-error .
      end.
    end.
    if not available locked_fin-bank then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись БАНК"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-fin-bank.
    buffer-copy locked_fin-bank to tt-fin-bank.

   end.
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
  IF AVAILABLE tt-fin-bank THEN 
    DISPLAY tt-fin-bank.host-code tt-fin-bank.code-bank tt-fin-bank.bik 
          tt-fin-bank.inn tt-fin-bank.kpp tt-fin-bank.cor-acc tt-fin-bank.rkc 
          tt-fin-bank.bank-name tt-fin-bank.short-name tt-fin-bank.licenz 
          tt-fin-bank.bank-city tt-fin-bank.addres tt-fin-bank.addres1 
          tt-fin-bank.phone tt-fin-bank.fax tt-fin-bank.e-mail 
          tt-fin-bank.cl-bank tt-fin-bank.okato tt-fin-bank.okonx 
          tt-fin-bank.okpo tt-fin-bank.PS 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-print B-hist B-Help tt-fin-bank.bik tt-fin-bank.inn 
         tt-fin-bank.kpp tt-fin-bank.cor-acc tt-fin-bank.rkc 
         tt-fin-bank.bank-name tt-fin-bank.short-name tt-fin-bank.licenz 
         tt-fin-bank.bank-city tt-fin-bank.addres tt-fin-bank.addres1 
         tt-fin-bank.phone tt-fin-bank.fax tt-fin-bank.e-mail 
         tt-fin-bank.cl-bank tt-fin-bank.okato tt-fin-bank.okonx 
         tt-fin-bank.okpo tt-fin-bank.PS 
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
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
assign
v-list-items = "нет системы КЛИЕНТ-БАНК" + {&comma-char} + '':U.

DO v-ii = 1 TO NUM-ENTRIES({&cl-bank-codes}):
    ASSIGN
    v-list-items = v-list-items + {&comma-char} +
                   ENTRY(v-ii, {&cl-bank-codes-full}) + {&comma-char} +
                   ENTRY(v-ii, {&cl-bank-codes}).
END.

assign
tt-fin-bank.okonx:label in frame {&frame-name} = "{&abbr_okonh_allshift}"
tt-fin-bank.inn:label  in frame {&frame-name}  = "{&abbr_inn_allshift}"
tt-fin-bank.kpp:label  in frame {&frame-name}  = "{&abbr_kpp_allshift}"
tt-fin-bank.cl-bank:list-item-pairs in frame {&frame-name} = v-list-items
.

find first X_clients no-lock where
            X_clients.obj-type = {&cmp}
        AND X_clients.obj-code = p-host-code.
  DISPLAY
  X_clients.obj-name @  f-host-name
   WITH FRAME Dialog-Frame.
case p-mode:
  when {&add-def} then do:
    DISPLAY
    p-host-code @ tt-fin-bank.host-code
    ? @ tt-fin-bank.code-bank
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    DISPLAY
    tt-fin-bank.bank-city
    tt-fin-bank.host-code
    tt-fin-bank.code-bank
    tt-fin-bank.addres
    tt-fin-bank.addres1
    tt-fin-bank.bank-name
    tt-fin-bank.bik
    tt-fin-bank.cor-acc
    tt-fin-bank.e-mail
    tt-fin-bank.fax
    tt-fin-bank.inn
    tt-fin-bank.kpp
    tt-fin-bank.licenz
    tt-fin-bank.okato
    tt-fin-bank.okonx
    tt-fin-bank.okpo
    tt-fin-bank.phone
    tt-fin-bank.PS
    tt-fin-bank.rkc
    tt-fin-bank.short-name
    tt-fin-bank.cl-bank
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = {&lookup} then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame {&frame-name}.
end.
ENABLE
b-quit
B-exit when p-mode <> {&lookup}
b-print when p-mode <> {&add-def}
b-hist when p-mode <> {&add-def}
B-Help
tt-fin-bank.bank-name when p-mode <> {&lookup}
tt-fin-bank.bik when p-mode <> {&lookup}
tt-fin-bank.addres when p-mode <> {&lookup}
tt-fin-bank.addres1 when p-mode <> {&lookup}
tt-fin-bank.cor-acc when p-mode <> {&lookup}
tt-fin-bank.rkc     when p-mode <> {&lookup}
tt-fin-bank.e-mail when p-mode <> {&lookup}
tt-fin-bank.fax    when p-mode <> {&lookup}
tt-fin-bank.inn    when p-mode <> {&lookup}
tt-fin-bank.kpp    when p-mode <> {&lookup}
tt-fin-bank.licenz when p-mode <> {&lookup}
tt-fin-bank.okato when p-mode <> {&lookup}
tt-fin-bank.okonx when p-mode <> {&lookup}
tt-fin-bank.okpo  when p-mode <> {&lookup}
tt-fin-bank.phone  when p-mode <> {&lookup}
tt-fin-bank.short-name when p-mode <> {&lookup}
tt-fin-bank.bank-city when p-mode <> {&lookup}
tt-fin-bank.PS when p-mode <> {&lookup}
tt-fin-bank.cl-bank when p-mode <> {&lookup}
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-save as logical no-undo .
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-fin-bank then do:
    create tt-fin-bank.
end.
assign
tt-fin-bank.addres frame {&frame-name}
tt-fin-bank.bank-city
tt-fin-bank.addres1
tt-fin-bank.bank-name
tt-fin-bank.bik
tt-fin-bank.cor-acc
tt-fin-bank.e-mail
tt-fin-bank.fax
tt-fin-bank.inn
tt-fin-bank.kpp
tt-fin-bank.licenz
tt-fin-bank.okato
tt-fin-bank.okonx
tt-fin-bank.okpo
tt-fin-bank.phone
tt-fin-bank.PS
tt-fin-bank.rkc
tt-fin-bank.short-name
tt-fin-bank.cl-bank
.
if not p-save then return .
run ref/finbank1.p (
input-output p-doc-rec
,input p-mode
,input no
,input "bik" /*p-verify*/
,input "":U
,input p-host-code
,input p-code-bank
,input tt-fin-bank.addres
,input tt-fin-bank.bank-city
,input tt-fin-bank.addres1
,input tt-fin-bank.bank-name
,input tt-fin-bank.bik
,input tt-fin-bank.cor-acc
,input tt-fin-bank.e-mail
,input tt-fin-bank.fax
,input tt-fin-bank.inn
,input tt-fin-bank.kpp
,input tt-fin-bank.licenz
,input tt-fin-bank.okato
,input tt-fin-bank.okonx
,input tt-fin-bank.okpo
,input tt-fin-bank.otdel
,input tt-fin-bank.phone
,input tt-fin-bank.PS
,input tt-fin-bank.rkc
,input tt-fin-bank.short-name
,input tt-fin-bank.cl-bank
)
no-error.

if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

