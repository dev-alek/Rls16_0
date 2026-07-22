&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-cash-desk NO-UNDO LIKE ub.cash-desk.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запуск рассылки на кассы IBM-XML файла параметров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/26/09
Author: Bakhtadze Natalya
Creation date: 06/26/09

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление кассами IBM-XML".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ cmp/mrk-strf.i }
{ gbl/fileslsh.i }
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
&SCOPED-DEFINE cd-type-code tt-cash-desk.pos-type

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-cash-desk

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-cash-desk

/* Definitions for BROWSE BR-cash-desk                                  */
&Scoped-define FIELDS-IN-QUERY-BR-cash-desk mark-string( recid(tt-cash-desk), v-rid-list ) tt-cash-desk.db-num tt-cash-desk.obj-code tt-cash-desk.cash-num tt-cash-desk.cash-on tt-cash-desk.version string(if tt-cash-desk.is-del then {&deleted-status} else {&current-status}) (if num-entries(tt-cash-desk.addr-path, {&delim-par}) > 1 then (entry(1, tt-cash-desk.addr-path, {&delim-par}) + ":\\":U + entry(2, tt-cash-desk.addr-path, {&delim-par})) else tt-cash-desk.addr-path) tt-cash-desk.cash-os   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-desk   
&Scoped-define SELF-NAME BR-cash-desk
&Scoped-define QUERY-STRING-BR-cash-desk FOR EACH tt-cash-desk NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-cash-desk OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-desk NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-cash-desk tt-cash-desk
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-desk tt-cash-desk


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-cash-desk}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help f-path b-file f-path2 ~
rs-action b-mark B-add B-add-object B-add-db B-add-all B-del B-del-obj ~
B-del-db B-del-all BR-cash-desk
&Scoped-Define DISPLAYED-OBJECTS f-path f-path2 rs-action

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add 
     LABEL "+&Добавить" 
     SIZE 10 BY 1 TOOLTIP "Добавить в список кассы выборочно".

DEFINE BUTTON B-add-all 
     LABEL "+&Все" 
     SIZE 10 BY 1 TOOLTIP "Добавить в списко все кассы".

DEFINE BUTTON B-add-db 
     LABEL "+&БД" 
     SIZE 10 BY 1 TOOLTIP "Добавить в список кассы по выбранной БД".

DEFINE BUTTON B-add-object 
     LABEL "+&Объект" 
     SIZE 10 BY 1 TOOLTIP "Добавить в список кассы по выбранному объекту".

DEFINE BUTTON B-del 
     LABEL "-&Удалить" 
     SIZE 10 BY 1 TOOLTIP "Удалить из списка выбранные кассы".

DEFINE BUTTON B-del-all 
     LABEL "-Все" 
     SIZE 10 BY 1 TOOLTIP "Удалить из списка все кассы".

DEFINE BUTTON B-del-db 
     LABEL "-БД" 
     SIZE 10 BY 1 TOOLTIP "Удалить из списка кассы по выбранной БД".

DEFINE BUTTON B-del-obj 
     LABEL "-Объект" 
     SIZE 10 BY 1 TOOLTIP "Удалить из списка кассы по выбранному объекту".

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-file 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "&Добавить" 
     SIZE 4 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-path AS CHARACTER FORMAT "X(256)":U 
     LABEL "Файл" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 77 BY 1 TOOLTIP "Абс. путь, относ. путь или настройка ini-файла (секция,параметр)"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-path2 AS CHARACTER FORMAT "X(256)":U
     LABEL "UNC"
     VIEW-AS FILL-IN NATIVE
     SIZE 77 BY 1 TOOLTIP "Абс. путь, относ. путь или настройка ini-файла (секция,параметр)"
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE rs-action AS CHARACTER INITIAL "config" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Параметры (отправка/получение)", "config",
"Команда", "control"
     SIZE 59 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-desk FOR 
      tt-cash-desk SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-desk Dialog-Frame _FREEFORM
  QUERY BR-cash-desk NO-LOCK DISPLAY
      mark-string( recid(tt-cash-desk), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      tt-cash-desk.db-num FORMAT ">>>>9":U
      tt-cash-desk.obj-code COLUMN-LABEL "Магазин" FORMAT "99999":U
            WIDTH 8
      tt-cash-desk.cash-num FORMAT ">>>9":U
      tt-cash-desk.cash-on COLUMN-LABEL "Вкл" FORMAT "+/":U
      tt-cash-desk.version FORMAT "X(7)":U
      string(if tt-cash-desk.is-del then {&deleted-status} else {&current-status}) COLUMN-LABEL "Статус" FORMAT "X(8)":U
      (if num-entries(tt-cash-desk.addr-path, {&delim-par}) > 1
then (entry(1, tt-cash-desk.addr-path, {&delim-par}) + ":\\":U +
entry(2, tt-cash-desk.addr-path, {&delim-par}))
else tt-cash-desk.addr-path) COLUMN-LABEL "Адрес" FORMAT "X(35)":U
      tt-cash-desk.cash-os FORMAT "X(20)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     f-path AT ROW 2 COL 6.5 COLON-ALIGNED WIDGET-ID 6
     b-file AT ROW 2 COL 86 WIDGET-ID 4
     f-path2 AT ROW 3 COL 6.5 COLON-ALIGNED WIDGET-ID 30
     rs-action AT ROW 4 COL 9 NO-LABEL WIDGET-ID 26
     b-mark AT ROW 5 COL 1 WIDGET-ID 24
     B-add AT ROW 5 COL 4 WIDGET-ID 16
     B-add-object AT ROW 5 COL 14 WIDGET-ID 14
     B-add-db AT ROW 5 COL 24 WIDGET-ID 12
     B-add-all AT ROW 5 COL 34 WIDGET-ID 10
     B-del AT ROW 5 COL 44 WIDGET-ID 22
     B-del-obj AT ROW 5 COL 54 WIDGET-ID 20
     B-del-db AT ROW 5 COL 64 WIDGET-ID 18
     B-del-all AT ROW 5 COL 74 WIDGET-ID 8
     BR-cash-desk AT ROW 6 COL 1 WIDGET-ID 100
     SPACE(0.70) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Управление кассами  IBM-XML"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-cash-desk T "?" NO-UNDO ub cash-desk
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-cash-desk B-del-all Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       f-path:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-path2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-desk
/* Query rebuild information for BROWSE BR-cash-desk
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-cash-desk NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-cash-desk */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Управление кассами  IBM-XML */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* +Добавить */
DO:
  run proc-b-add IN THIS-PROCEDURE ( INPUT "") NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-all Dialog-Frame
ON CHOOSE OF B-add-all IN FRAME Dialog-Frame /* +Все */
DO:
  run proc-b-add IN THIS-PROCEDURE ( INPUT {&all}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-db Dialog-Frame
ON CHOOSE OF B-add-db IN FRAME Dialog-Frame /* +БД */
DO:
  run proc-b-add IN THIS-PROCEDURE ( INPUT "db" ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-object Dialog-Frame
ON CHOOSE OF B-add-object IN FRAME Dialog-Frame /* +Объект */
DO:
  run proc-b-add IN THIS-PROCEDURE ( INPUT {&g___object}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* -Удалить */
DO:
  run proc-b-del IN THIS-PROCEDURE ( INPUT "") NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-all Dialog-Frame
ON CHOOSE OF B-del-all IN FRAME Dialog-Frame /* -Все */
DO:
  run proc-b-del IN THIS-PROCEDURE ( INPUT {&ALL} ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-db Dialog-Frame
ON CHOOSE OF B-del-db IN FRAME Dialog-Frame /* -БД */
DO:
  run proc-b-del IN THIS-PROCEDURE ( INPUT "db" ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-obj Dialog-Frame
ON CHOOSE OF B-del-obj IN FRAME Dialog-Frame /* -Объект */
DO:
  run proc-b-del IN THIS-PROCEDURE ( INPUT {&g___Object}) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  ASSIGN
  f-path
  rs-action    .
  if f-path = '' then do:
    message
    substitute("Не задан файл &1", f-path)
    view-as alert-box error .
    undo, return no-apply.
  end.
  if not can-find( first tt-cash-desk) then do:
    message
    substitute("Не задан список касс")
    view-as alert-box error .
    undo, return no-apply.
  end.
  MESSAGE
  SUBSTITUTE("Отослать на выбранные кассы файл &1&2Вы уверены?&2" +
             "(Для УБД отсылка будет проведена при приеме пакета СПН)"
             , f-path
             , {&NEW-LINE})
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog THEN RETURN NO-APPLY.
  /*список кассы передается через callback*/
  run str/diallog.w (
            INPUT parparentproc
          , INPUT this-procedure:HANDLE
          , INPUT 'utl/sendxprr.p':U
          , INPUT f-path + {&delim-par} + rs-action
          , INPUT no /*p-auto-go*/
          , input 'Прервать'
          , INPUT 'Пересылка файлов на кассы IBM-XML') no-error .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-file Dialog-Frame
ON CHOOSE OF b-file IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-file IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if not available tt-cash-desk then return no-apply.
  { gbl/markstrn.i tt-cash-desk v-rid-list }
  glog = br-cash-desk  :refresh( ) in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          glog = br-cash-desk:select-next-row () in frame {&frame-name}.
          apply "value-changed" to br-cash-desk in frame {&frame-name}.
  end.
  apply "entry" to br-cash-desk in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-desk
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
{ gbl/getcntxt.i get }
  RUN Myenable IN THIS-PROCEDURE .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_get-cash-desk-list Dialog-Frame 
PROCEDURE cb_get-cash-desk-list :
DEFINE INPUT PARAMETER p-callback-handle AS HANDLE NO-UNDO.
DEFINE BUFFER buf_tt-cash-desk FOR tt-cash-desk.
FOR EACH buf_tt-cash-desk:
  RUN cb_set-cash-desk-list IN p-callback-handle

      ( INPUT buf_tt-cash-desk.db-num
        ,INPUT buf_tt-cash-desk.obj-code
        ,INPUT buf_tt-cash-desk.pos-type
        ,INPUT buf_tt-cash-desk.cash-num
        ,INPUT buf_tt-cash-desk.VERSION ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      UNDO, RETURN ERROR substitute("Ошибка при задании списка касс:&1&2&1&3"
                                    , {&NEW-LINE}
                                    , ERROR-STATUS:GET-MESSAGE(1)
                                    , RETURN-VALUE).
  END.

END.

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
  DISPLAY f-path f-path2 rs-action
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-path b-file f-path2 rs-action b-mark B-add
         B-add-object B-add-db B-add-all B-del B-del-obj B-del-db B-del-all
         BR-cash-desk
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DISPLAY f-path
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
b-file
b-mark
B-add
B-add-object
B-add-db
B-add-all
B-del
B-del-obj
B-del-db
B-del-all
f-path
rs-action
BR-cash-desk
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&PEN-BROWSERS-IN-QUERY-Dialog-Frame}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-cd Dialog-Frame 
PROCEDURE proc-add-cd :
DEFINE parameter BUFFER buf_cash-desk FOR ub.cash-desk.
DEFINE BUFFER buf_tt-cash-desk FOR tt-cash-desk.
FIND FIRST buf_tt-cash-desk NO-LOCK WHERE
         buf_tt-cash-desk.db-num = buf_cash-desk.db-num
    AND  buf_tt-cash-desk.obj-code = buf_cash-desk.obj-code
    AND  buf_tt-cash-desk.pos-type = buf_cash-desk.pos-type
    AND  buf_tt-cash-desk.cash-num = buf_cash-desk.cash-num NO-ERROR.
IF NOT available buf_tt-cash-desk THEN DO:
  if v-cntxt-db-num = 0
  or buf_cash-desk.db-num = v-cntxt-db-num then do:
    CREATE buf_tt-cash-desk.
    BUFFER-COPY buf_cash-desk TO buf_tt-cash-desk.
    RELEASE buf_tt-cash-desk.
  end.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid AS RECID NO-UNDO.
DEFINE VARIABLE v-loc-rid-list AS character NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
define variable v-other-pos-type as logical no-undo .
define variable v-obj-db-num as integer no-undo .
DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER buf_shop FOR ub.shop.
CASE p-option:
  WHEN {&ALL} THEN DO:
     FOR EACH buf_cash-desk NO-LOCK WHERE
             buf_cash-desk.pos-type = {&cd-type-ibm-xml}:
        IF  buf_cash-desk.is-del = yes THEN NEXT.
       RUN proc-add-cd IN THIS-PROCEDURE ( BUFFER buf_Cash-desk).
     END.
  END.
  WHEN "db" THEN DO:
    run adm/dbs.w (
               input ? /*parparentproc*/
              ,input {&lookup}
              ,output v-rid) NO-ERROR.
    IF v-rid <> ?  THEN DO:
        find FIRST buf_db NO-LOCK WHERE recid (buf_db) = v-rid .
       FOR EACH buf_cash-desk NO-LOCK WHERE
               buf_cash-desk.pos-type = {&cd-type-ibm-xml}
           AND buf_cash-desk.is-del = NO
           AND buf_cash-desk.db-num = buf_db.db-num:
          RUN proc-add-cd IN THIS-PROCEDURE ( BUFFER buf_Cash-desk).

       END. /*FOR EACH buf_cash-desk*/
    END. /*IF v-rid <> ?  THEN DO:*/

  END. /*when "db"*/
  WHEN {&g___object} THEN DO:
   run adm/shops.w ( input parparentproc
                       ,input "b-sel,b-mark"
                       ,input-output v-loc-rid-list
                       ,no ) NO-ERROR.

   if v-loc-rid-list <> "":U then DO:
     do v-ii = 1 to num-entries(v-loc-rid-list):
     find first buf_shop no-lock where
          recid(buf_shop) = integer(entry(v-ii, v-loc-rid-list) ).
     { gbl/objdbnum.i {&shop} buf_shop.obj-code v-obj-db-num }
    FOR EACH buf_cash-desk NO-LOCK WHERE
        buf_cash-desk.pos-type = {&cd-type-ibm-xml}
    AND buf_cash-desk.is-del = NO
    AND buf_cash-desk.db-num = v-obj-db-num
    AND buf_Cash-desk.obj-code = buf_shop.obj-code:
      RUN proc-add-cd IN THIS-PROCEDURE ( BUFFER buf_Cash-desk).

     END. /*FOR EACH buf_cash-desk NO-LOCK WHERE*/
     end.
    END. /*if v-loc-rid-list <> "":U then DO:*/
  END.
  WHEN '' THEN DO:
    run ref/cashlist.w (input parparentproc
                  ,INPUT "b-sel,b-mark"
                  ,INPUT (if v-cntxt-db-num = 0 then {&all} else "db")
                  ,INPUT v-cntxt-db-num
                  ,INPUT v-cntxt-host-code-obj
                  ,INPUT v-cntxt-obj-type
                  ,INPUT v-cntxt-obj-code
                  ,INPUT ?
                  ,OUTPUT v-loc-rid-list) NO-ERROR.
    IF v-loc-rid-list <> '':U THEN DO:
      DO v-ii = 1 TO NUM-ENTRIES(v-loc-rid-list):
        FIND FIRST buf_Cash-desk NO-LOCK WHERE
                RECID(buf_cash-desk) = INTEGER(ENTRY(v-ii, v-loc-rid-list)) NO-ERROR.
        IF AVAILABLE buf_Cash-desk THEN DO:
          if buf_cash-desk.pos-type = {&cd-type-ibm-xml} then do:
            RUN proc-add-cd IN THIS-PROCEDURE ( BUFFER buf_Cash-desk).
          end.
          else do:
            v-other-pos-type = yes.
          end.
        END. /*IF AVAILABLE buf_Cash-desk THEN DO:*/
      END. /*DO v-ii = 1 TO NUM-ENTRIES(v-loc-rid-list):*/
      if v-other-pos-type = yes then do:
        message
        substitute("Добавлены только кассы типа &1", {&cd-type-ibm-xml})
        view-as alert-box warning.
      end.
    END. /*IF v-loc-rid-list <> '':U THEN DO:*/
  END. /*when ''*/
END CASE.
{&OPEN-QUERY-BR-cash-desk}
APPLY "ENTRY" to br-cash-desk in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid AS RECID NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
DEFINE VARIABLE v-local-rid-list AS character NO-UNDO.
DEFINE VARIABLE v-local2-rid-list AS character NO-UNDO.
define variable v-entry-ii as integer no-undo .
define variable v-obj-db-num as integer no-undo .
DEFINE BUFFER buf_tt-cash-desk FOR tt-cash-desk.
DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER buf_shop FOR ub.shop.
CASE p-option:
  WHEN {&ALL} THEN DO:
    FOR EACH buf_tt-cash-desk :
        DELETE buf_tt-cash-desk.
    END.
    v-rid-list = ''.
  END.
  WHEN "db" THEN DO:
    run adm/dbs.w (
               input ? /*parparentproc*/
              ,input {&lookup}
              ,output v-rid) NO-ERROR.
    IF v-rid <> ?  THEN DO:
       find FIRST buf_db NO-LOCK WHERE recid (buf_db) = v-rid .
       FOR EACH buf_tt-cash-desk NO-LOCK WHERE
               buf_tt-cash-desk.pos-type = {&cd-type-ibm-xml}
            AND buf_tt-cash-desk.db-num = buf_db.db-num:
        v-local-rid-list = v-rid-list.
        v-entry-ii = lookup(string(recid(buf_tt-cash-desk)), v-local-rid-list).
        if v-entry-ii > 0 then do:
          entry(v-entry-ii,  v-local-rid-list) = ''.
          v-local-rid-list = REPLACE(v-local-rid-list, {&comma-char} + {&comma-char}, {&comma-char}).
          v-local-rid-list = TRIM(v-local-rid-list, {&comma-char}).
        end.
        v-rid-list = v-local-rid-list.
        DELETE buf_tt-cash-desk.
      END. /*FOR EACH buf_tt-cash-desk NO-LOCK WHERE*/
    END. /*IF v-rid <> ?  THEN DO:*/
  END. /*when "db"*/
  WHEN {&g___object} THEN DO:
    run adm/shops.w ( input parparentproc
                       ,input "b-sel,b-mark"
                       ,input-output v-local2-rid-list
                       ,no ) NO-ERROR.
    if v-local2-rid-list <> "":U then DO:
      do v-ii = 1 to num-entries(v-local2-rid-list):
      find first buf_shop no-lock where
          recid(buf_shop) = integer(entry(v-ii, v-local2-rid-list)) .
     { gbl/objdbnum.i {&shop} buf_shop.obj-code v-obj-db-num }
      FOR EACH buf_tt-cash-desk NO-LOCK WHERE
          buf_tt-cash-desk.pos-type = {&cd-type-ibm-xml}
      AND buf_tt-cash-desk.db-num = v-obj-db-num
      AND buf_tt-Cash-desk.obj-code = buf_shop.obj-code:
        v-local-rid-list = v-rid-list.
        v-entry-ii = lookup(string(recid(buf_tt-cash-desk)), v-local-rid-list).
        if v-entry-ii > 0 then do:
          entry(v-entry-ii,  v-local-rid-list) = ''.
          v-local-rid-list = REPLACE(v-local-rid-list, {&comma-char} + {&comma-char}, {&comma-char}).
          v-local-rid-list = TRIM(v-local-rid-list, {&comma-char}).
        end.
        v-rid-list = v-local-rid-list.
        DELETE buf_tt-cash-desk.
      END. /*FOR EACH buf_tt-cash-desk NO-LOCK WHERE*/
      end.
    END. /*if v-local-rid-list <> "":U then DO:*/
  END. /*when {&g___object}*/
  WHEN '' THEN DO:
    IF v-rid-list <> '':U THEN DO:
      v-local-rid-list = v-rid-list.
      DO v-ii = 1 TO NUM-ENTRIES(v-rid-list):
        FIND FIRST buf_tt-Cash-desk NO-LOCK WHERE
                RECID(buf_tt-cash-desk) = INTEGER(ENTRY(v-ii, v-rid-list)) NO-ERROR.
        IF AVAILABLE buf_tt-Cash-desk THEN DO:
          ENTRY( LOOKUP(string(recid(buf_tt-cash-desk)), v-local-rid-list) , v-local-rid-list) = ''.
          v-local-rid-list = REPLACE(v-local-rid-list, {&comma-char} + {&comma-char}, {&comma-char}).
          v-local-rid-list = TRIM(v-local-rid-list, {&comma-char}).
          DELETE buf_tt-cash-desk.
        END. /*IF AVAILABLE buf_tt-Cash-desk THEN DO:*/
      END. /*DO v-ii = 1 TO NUM-ENTRIES(v-rid-list):*/
      v-rid-list = v-local-rid-list.
    END. /*IF v-rid-list <> '':U THEN DO:*/
    else do:
      FIND FIRST buf_tt-Cash-desk NO-LOCK WHERE
              RECID(buf_tt-cash-desk) = recid(tt-cash-desk) NO-ERROR.
      IF AVAILABLE buf_tt-Cash-desk THEN DO:
        DELETE buf_tt-cash-desk.
      END. /*IF AVAILABLE buf_tt-Cash-desk THEN DO:*/
    end.
  END. /*WHEN ''*/
END CASE.
{&OPEN-QUERY-BR-cash-desk}
APPLY "ENTRY" to br-cash-desk in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-file Dialog-Frame 
PROCEDURE proc-b-file :
define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
DEFINE VARIABLE ii AS INTEGER NO-UNDO.

run gbl/dm-file.p ( INPUT (
                  "|" + " XML файлы (*.xml) " + "|" + "*.xml"
                + "|" + " Все файлы (*.*) "  + "|" +  "*.*")
                ,INPUT "."
                ,INPUT "Выберите один или несколько файлов"
                ,input frame {&frame-name}:hwnd
                ,OUTPUT v_os-file
                ,OUTPUT ll_commit
                            ).

IF ll_commit <> YES THEN do:
   RETURN error.
end.
_ii:
DO ii = 1 TO NUM-ENTRIES (v_os-file, "|"):
    run gbl/filename.p (
                     input  entry(ii, v_os-file, '|')
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
    if error-status:error  = ? then do:
      message
      substitute("Ошибка при поиске файла файла &1&2" +
                 "возможно файл уже удален"
                 , v-full-path
                 , {&new-line})
     view-as alert-box error .
     next _ii.
    end.
    assign
    f-path = prepare-path(v-full-path).
    DISPLAY
    f-path
    WITH FRAME {&FRAME-NAME}.
    f-path2 = prepare-path2(v-full-path).
    define variable v-unc as character no-undo .
    run gbl/get-unc.p ( input f-path2, output v-unc) no-error.
    if not error-status :error then do:
      assign
      f-path2 = v-unc.
    end.
    DISPLAY
    f-path2
    WITH FRAME {&FRAME-NAME}.

END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

