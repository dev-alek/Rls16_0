&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_stop-list FOR ub.stop-list.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список стоплистов по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/12/07
Author: Bakhtadze Natalya
Creation date: 07/12/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список стоплистов по ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i DEF }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable filter-label as character no-undo .
define variable filter-label0 as character no-undo init "Список Стоплистов" .
define variable filter-point as character no-undo .
define variable filter-point0 as character no-undo init "stop-ls" .
DEFINE VARIABLE sort-column-name as character no-undo .
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE chg-option AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-stop-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_stop-list

/* Definitions for BROWSE BR-stop-list                                  */
&Scoped-define FIELDS-IN-QUERY-BR-stop-list mark-string(recid(X_stop-list), v-rid-list) X_stop-list.stop-list-code X_stop-list.doc-date X_stop-list.fact-date X_stop-list.sys-time X_stop-list.status_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-stop-list
&Scoped-define SELF-NAME BR-stop-list
&Scoped-define QUERY-STRING-BR-stop-list FOR EACH X_stop-list NO-LOCK WHERE        X_stop-list.classif-type = {&TABLE_dis-card}      INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-stop-list OPEN QUERY {&SELF-NAME} FOR EACH X_stop-list NO-LOCK WHERE        X_stop-list.classif-type = {&TABLE_dis-card}      INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-stop-list X_stop-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-stop-list X_stop-list


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-stop-list}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-add b-chg b-del b-lkp ~
b-history b-sch B-Help b-close b-cd BR-stop-list mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-add
       MENU-ITEM m_import       LABEL "Импорт (формат СИБНЕФТЬ)"
       MENU-ITEM m_manual       LABEL "Вручную"
       MENU-ITEM m_copy         LABEL "Копия"         .

DEFINE MENU PMENU-b-chg
       MENU-ITEM m_import-chg   LABEL "Импорт (формат СИБНЕФТЬ)"
       MENU-ITEM m_manual-chg   LABEL "Вручную"       .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cd
     LABEL "На кассу"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-close
     LABEL "Закрыть"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-history
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-stop-list FOR X_stop-list SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-stop-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-stop-list Dialog-Frame _FREEFORM
  QUERY BR-stop-list NO-LOCK DISPLAY
      mark-string(recid(X_stop-list), v-rid-list) COLUMN-LABEL "*" FORMAT "X(2)"
X_stop-list.stop-list-code COLUMN-LABEL "№ стоплиста" FORMAT "X(9)"
X_stop-list.doc-date  COLUMN-LABEL "Дата стоплиста" FORMAT "99/99/9999"
X_stop-list.fact-date COLUMN-LABEL "Факт.Дата" FORMAT "99/99/9999"
X_stop-list.sys-time COLUMN-LABEL "Факт.время" FORMAT "X(10)"
X_stop-list.status_ COLUMN-LABEL "Статус" FORMAT "X(10)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.88 BY 19 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-add AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-lkp AT ROW 1 COL 61
     b-history AT ROW 1 COL 89 WIDGET-ID 2
     b-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     b-close AT ROW 2 COL 31
     b-cd AT ROW 2 COL 61
     BR-stop-list AT ROW 3 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     SPACE(79.40) SKIP(20.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Стоплисты по ДК"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_stop-list B "?" ? ub stop-list
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-stop-list b-cd Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.

ASSIGN
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU PMENU-b-chg:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-stop-list
/* Query rebuild information for BROWSE BR-stop-list
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_stop-list NO-LOCK WHERE
       X_stop-list.classif-type = {&TABLE_dis-card}
     INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-stop-list FOR X_stop-list SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-stop-list */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Стоплисты по ДК */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Стоплисты по ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
 IF add-option = '':U THEN DO:
    run gbl/pop-up.p ( input self:handle
                     , input no) no-error.
    if error-status:error or add-option = "":U then return no-apply.
  END.
  run proc-b-add IN THIS-PROCEDURE ( add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      add-option = "":U.
      RETURN NO-APPLY.
  END.
  add-option = "":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cd Dialog-Frame
ON CHOOSE OF b-cd IN FRAME Dialog-Frame /* На кассу */
DO:
  IF NOT AVAILABLE X_stop-list THEN RETURN NO-APPLY.
  run proc-b-cd IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  IF chg-option = '':U THEN DO:
    run gbl/pop-up.p ( input self:handle
                     , input no) no-error.
    if error-status:error or chg-option = "":U then return no-apply.
  END.
  RUN proc-b-chg IN THIS-PROCEDURE ( input chg-option) no-error.
  IF ERROR-STATUS:ERROR THEN DO:
     chg-option = '':U.
     RETURN NO-APPLY.
  END.
  chg-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Закрыть */
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
  DEFINE VARIABLE glog AS LOGICAL no-undo.
  IF NOT AVAILABLE X_stop-list THEN RETURN NO-APPLY.
define variable v-ok as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_stop-list_fact':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok <> true
then do:
  undo, return no-apply .
end.

  MESSAGE
  SUBSTITUTE("Вы действительно хотите закрыть стоплист &1?"
               , X_stop-list.stop-list-code)
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.

  IF NOT glog THEN RETURN NO-APPLY.
  v-rec = RECID(X_stop-list).
  run ref/stop-l2.p (
                  input parparentproc
                 ,INPUT RECID(X_stop-list)
                 ,INPUT NO /*p-silent*/
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run proc-b-cd in this-procedure  .
  run Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
  REPOSITION br-stop-list TO RECID v-rec NO-ERROR.
  APPLY "ENtRY" TO br-stop-list.
  APPLY "value-changed" TO br-stop-list.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  DEFINE VARIABLE glog AS LOGICAL no-undo.
  IF NOT AVAILABLE X_stop-list THEN RETURN NO-APPLY.
define variable v-ok as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_stop-list_preparation':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok <> true
then do:
  undo, return no-apply .
end.


  MESSAGE
  SUBSTITUTE("Вы действительно хотите удалить стоплист &1?"
           , X_stop-list.stop-list-code)
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog THEN RETURN NO-APPLY.
  run ref/stop-l3.p ( INPUT RECID(X_stop-list)
                 ,INPUT NO /*p-silent*/
                 ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
  APPLY "ENtRY" TO br-stop-list.
  APPLY "value-changed" TO br-stop-list.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
IF NOT AVAILABLE X_stop-list THEN RETURN NO-APPLY.
  run ref/cstop-ls.w ( INPUT parparentproc
                      ,INPUT '':U
                      ,INPUT "one"
                      ,INPUT X_stop-list.stop-list-code
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available X_stop-list then do:
    { gbl/markstrn.i X_stop-list v-rid-list }
    loc#log = br-stop-list:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-stop-list:select-next-row ().
        apply "VALUE-CHANGED" to br-stop-list in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-stop-list in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_stop-list ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_stop-list ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_copy Dialog-Frame
ON CHOOSE OF MENU-ITEM m_copy /* Копия */
DO:
  ASSIGN
  ADD-OPTION = "copy":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_import Dialog-Frame
ON CHOOSE OF MENU-ITEM m_import /* Импорт (формат СИБНЕФТЬ) */
DO:
  ASSIGN
  ADD-OPTION = "import":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_import-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_import-chg Dialog-Frame
ON CHOOSE OF MENU-ITEM m_import-chg /* Импорт (формат СИБНЕФТЬ) */
DO:
      ASSIGN
    chg-OPTION = "import":U.
    RUN proc-b-chg IN THIS-PROCEDURE  ( chg-option) NO-ERROR.
    IF error-status:ERROR THEN DO:
      chg-option = '':U.
      RETURN NO-APPLY.
    END.
    chg-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_manual
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_manual Dialog-Frame
ON CHOOSE OF MENU-ITEM m_manual /* Вручную */
DO:
    ASSIGN
  ADD-OPTION = "manual":U.
  RUN proc-b-add IN THIS-PROCEDURE  ( add-option) NO-ERROR.
  IF error-status:ERROR THEN DO:
    add-option = '':U.
    RETURN NO-APPLY.
  END.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_manual-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_manual-chg Dialog-Frame
ON CHOOSE OF MENU-ITEM m_manual-chg /* Вручную */
DO:
    ASSIGN
      chg-OPTION = "manual":U.
      RUN proc-b-chg IN THIS-PROCEDURE  ( chg-option) NO-ERROR.
      IF error-status:ERROR THEN DO:
        chg-option = '':U.
        RETURN NO-APPLY.
      END.
      chg-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-stop-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ gbl/brwrepos.i
  &line-num=5
}
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
/*{ gbl/hot-key.i b-print }*/
{ gbl/hot-key.i b-history }
{ gbl/setfltnm.i }
{ gbl/brwrefre.i " v-doc-rec = ?. if available X_stop-list then v-doc-rec = recid(X_stop-list). ~
               run openbr in this-procedure ( input yes, input no, input '':U) no-error. ~
               REPOSITION br-stop-list to recid v-doc-rec No-ERROR." }



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  ASSIGN
  v-rid-list = p-rid-list.
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  IF v-rid-list <> '':U THEN DO:
    REPOSITION br-stop-list to RECID INTEGER(entry(1, v-rid-list)) NO-ERROR.
    APPLY "entry" to br-stop-list.
    APPLY "value-changed" TO br-stop-list.
  END.
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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-chg b-del b-lkp b-history b-sch B-Help
         b-close b-cd BR-stop-list mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
b-add:MENU-MOUSE  IN FRAME {&FRAME-NAME} = 1
b-chg:MENU-MOUSE  IN FRAME {&FRAME-NAME} = 1
.
ENABLE
b-quit
B-mark  when lookup("b-mark", bttns) > 0
B-sel when lookup("b-sel", bttns) > 0
b-add when lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0 AND NOT TRANSACTION
b-chg when lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0 AND NOT TRANSACTION
b-del when lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0 AND NOT TRANSACTION
b-close when lookup("b-add", bttns) > 0 AND v-cntxt-db-num = 0 AND NOT TRANSACTION
b-cd
b-lkp
b-history
b-sch
B-Help
BR-stop-list
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
run openbr in this-procedure ( input yes, input no, input '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-stop-list FOR EACH X_stop-list

&scop flt-open-dyn_open-query FOR EACH X_stop-list

&scop flt-open-query-handle QUERY br-stop-list:handle

&scop flt-open-query p-open-query

&scop flt-open-find-next p-find-next

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-buffer-name X_stop-list

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-waitfram yes

&scop flt-open-table-name X_stop-list

&scop flt-open-search-option no-lock

 CASE p-list-mode:
   WHEN {&ALL} THEN DO:
    ASSIGN
    FRAME {&frame-name}:TITLE = substitute("СТОПЛИСТЫ ПО ДК")
      filter-label = filter-label0
      filter-point = filter-point0
      .
      if sort-column-name = '':u then do:
        { gbl/fltopend.i
          &where-cond = " X_stop-list.classif-type = ~{&table_dis-card~} ~
                          "
          &dyn_where-cond = " substitute('X_stop-list.classif-type = &1&2&1', ~{&double-quote~}, ~{&table_dis-card~})  "

          &use-ind = "  "
          &by = " by X_stop-list.stop-list-code descending"
        }
      end.
   END.
 END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-stop-list to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-stop-list:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-stop-list in frame {&frame-name}.
APPLY "ENTRY" TO br-stop-list.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-add-option AS CHARACTER NO-UNDO.
define variable v-stop-list-code as character no-undo .
define variable v-ok as logical no-undo .
DEFINE variable v-loc-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_stop-list FOR ub.stop-list.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_stop-list_preparation':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok <> true
then do:
  undo, return no-apply .
end.


CASE p-add-option:
  WHEN "import" THEN DO:
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input "ref/impstpl.w":U
        , input ({&add-def} + {&delim-par} + '':U) /*parameter*/
        , input no /*p-auto-go*/
        , input "&Стоп"
        , input substitute("Импорт стоплистов по ДК")
    ) no-error.
  END.
  WHEN  "manual" THEN DO:
    run ref/stop-l1.p ( input no /*p-silent*/
                    ,output v-stop-list-code) NO-ERROR.
  END.
  WHEN "copy" THEN DO:
    message
    substitute("Выберите стоплист-оригинал для копирования&1" +
              "(полученный новый стоплист будет дополнен НОВЫМИ картами для тех клиентов-держателей,&1" +
              "чьи карты были в стоплисте-оригинале в статусе &2 или &3"
              , {&new-line}
              , {&stop-client-full}
              , {&stop-card-and-client-full})
    view-as alert-box .
    run ref/stop-ls.w ( input parparentproc
                    ,input "b-sel"
                    ,input {&all}
                    ,input-output v-loc-rid-list) no-error.
    if v-loc-rid-list = "":U then undo, return error .
    run waitfram-show in this-procedure ( "Ждите..." ).
    find first buf_stop-list no-lock where
              recid(buf_stop-list) = integer(v-loc-rid-list).
    run ref/stop-l4.p ( input no /*p-silent*/
                  ,input buf_stop-list.stop-list-code
                  ,output v-stop-list-code) NO-ERROR.
    run waitfram-hide in this-procedure .
  END.
END CASE.
RUN openbr IN THIS-PROCEDURE  ( INPUT YES, INPUT NO, INPUT '':U) NO-ERROR.
APPLY "ENTRY" TO br-stop-list IN FRAME {&FRAME-NAME}.
APPLY "VALUE-CHANGED" TO br-stop-list.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-cd Dialog-Frame
PROCEDURE proc-b-cd :
run str/diallog.w (
                  input parparentproc
                  ,input this-procedure
                  ,input 'str/snd-stpl.p':U
                  ,input X_stop-list.stop-list-code
                  ,input yes /*p-auto-go*/
                  ,input '':U
                  ,input 'Отправка информации по стоплистам на кассы текущей БД') no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-chg-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rec AS RECID  NO-UNDO.
DEFINE VARIABLE v-loc-rid-list AS character  NO-UNDO.
IF NOT AVAILABLE X_stop-list THEN RETURN NO-APPLY.
define variable v-ok as logical no-undo .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_stop-list_preparation':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-ok
}
if v-ok <> true
then do:
  undo, return no-apply .
end.


v-rec = recid(X_stop-list).
CASE p-chg-option:
  WHEN "import" THEN DO:
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input "ref/impstpl.w":U
        , input ({&update} + {&delim-par} + X_stop-list.stop-list-code) /*parameter*/
        , input no /*p-auto-go*/
        , input "&Стоп"
        , input substitute("Импорт стоплистов по ДК")
    ) no-error.
  END.
  WHEN "manual" THEN DO:
    run ref/stop-lls.w ( INPUT parparentproc
                      ,INPUT "b-add":U /*btnns*/
                      ,INPUT {&update}
                      ,INPUT X_stop-list.stop-list-code
                      ,input '':U /*p-d-card*/
                      ,INPUT-OUTPUT v-loc-rid-list ) NO-ERROR.
  END.
END CASE.
IF NOT ERROR-STATUS:ERROR THEN DO:
  RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, input '':U).
  REPOSITION br-stop-list to RECID v-rec NO-ERROR.
  APPLY "ENTRY" TO BROWSE br-stop-list.
  APPLY "value-changed" TO BROWSE br-stop-list.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
IF NOT AVAILABLE X_stop-list THEN RETURN ERROR.
run ref/stop-lls.w ( INPUT parparentproc
                ,INPUT "":U /*btnns*/
                ,INPUT {&LOOKUP}
                ,INPUT X_stop-list.stop-list-code
                ,input '':U /*p-d-card*/
                ,INPUT-OUTPUT v-loc-rid-list ) NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_stop-list then recid(X_stop-list) else ?)
.
assign
tbl = 'stop-list'
join-tbl = 'X_stop-list'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('doc-date', 'Дата стоплиста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-date', 'Факт.Дата стоплиста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('stop-list-code', 'N стоплиста', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + {&delim-par} + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    RUN OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-stop-list to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-stop-list in frame {&frame-name} .
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
