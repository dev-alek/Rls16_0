&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE TEMP-TABLE tt-clients-iv NO-UNDO LIKE ub.clients
       field is-selected as logical

       index pi is primary unique obj-type obj-code
       index is-sel is-selected
       .
DEFINE BUFFER X_db FOR ub.db.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран Настройки для экспорта

Автор: Хныкин Павел Андреевич
Дата создания: 09/19/08
Author: Pavel Khnykin
Creation date: 09/19/08

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE       NO-UNDO.
DEFINE INPUT PARAMETER p-mode        AS CHARACTER           NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type  LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code  LIKE ub.shop.obj-code    NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран Настройки для экспорта".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/clntattr.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/color.i    }

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.

define variable v-tth           as handle   no-undo .
define variable v-to-create     as logical  no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-tt-clients-iv

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-clients-iv

/* Definitions for BROWSE br-tt-clients-iv                              */
&Scoped-define FIELDS-IN-QUERY-br-tt-clients-iv ~
mark-selected(buffer tt-clients-iv) FORMAT "X(1)":U tt-clients-iv.obj-type ~
tt-clients-iv.obj-code tt-clients-iv.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tt-clients-iv
&Scoped-define QUERY-STRING-br-tt-clients-iv FOR EACH tt-clients-iv NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-tt-clients-iv OPEN QUERY br-tt-clients-iv FOR EACH tt-clients-iv NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-tt-clients-iv tt-clients-iv
&Scoped-define FIRST-TABLE-IN-QUERY-br-tt-clients-iv tt-clients-iv


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-tt-clients-iv}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help tg-bgeclall tg-bgedcard ~
tg-bgedict cb-bgeshift cb-bgefmt cb-bgeflold fi-bgeflnm b-mark b-add b-del ~
br-tt-clients-iv
&Scoped-Define DISPLAYED-OBJECTS tg-bgeclall tg-bgedcard tg-bgedict ~
cb-bgeshift cb-bgefmt cb-bgeflold fi-bgeflnm

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-selected Dialog-Frame
FUNCTION mark-selected RETURNS CHARACTER
( buffer buf_tt-clients-iv for tt-clients-iv)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-bgeflold AS CHARACTER FORMAT "X(256)":U
     LABEL "Варианты создания файла выгрузки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "old","var","new","firm","oracle"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE cb-bgefmt AS CHARACTER FORMAT "X(256)":U
     LABEL "Форматы выгрузки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "xml","dbf","analythic"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE cb-bgeshift AS CHARACTER FORMAT "X(256)":U
     LABEL "Способ выгрузки сменных объектов"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "no-distinct","distinct"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE fi-bgeflnm AS CHARACTER FORMAT "X(256)":U
     LABEL "Список шаблонов"
     VIEW-AS FILL-IN
     SIZE 46.5 BY 1 NO-UNDO.

DEFINE VARIABLE tg-bgeclall AS LOGICAL INITIAL no
     LABEL "Экспорт всех объектов"
     VIEW-AS TOGGLE-BOX
     SIZE 50 BY .83 NO-UNDO.

DEFINE VARIABLE tg-bgedcard AS LOGICAL INITIAL no
     LABEL "Удалять нули в начале номеров дисконтных карт"
     VIEW-AS TOGGLE-BOX
     SIZE 61.5 BY .83 NO-UNDO.

DEFINE VARIABLE tg-bgedict AS LOGICAL INITIAL no
     LABEL "Экспорт видов оплат, типов кас. платежей и дисконтных карт"
     VIEW-AS TOGGLE-BOX
     SIZE 61.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-tt-clients-iv FOR
      tt-clients-iv SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-tt-clients-iv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tt-clients-iv Dialog-Frame _STRUCTURED
  QUERY br-tt-clients-iv NO-LOCK DISPLAY
      mark-selected(buffer tt-clients-iv) FORMAT "X(1)":U WIDTH 1
      tt-clients-iv.obj-type FORMAT "X(3)":U
      tt-clients-iv.obj-code FORMAT ">>>>>>>>9":U
      tt-clients-iv.obj-name FORMAT "X(40)":U WIDTH 48.75
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 64.5 BY 10
         TITLE "Контрагенты для которых внешний приход экспортируется как внутренний" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 6
     B-Help AT ROW 1 COL 54.88 WIDGET-ID 4
     tg-bgeclall AT ROW 3 COL 2 WIDGET-ID 8
     tg-bgedcard AT ROW 4 COL 2 WIDGET-ID 10
     tg-bgedict AT ROW 5 COL 2 WIDGET-ID 12
     cb-bgeshift AT ROW 6 COL 33 COLON-ALIGNED WIDGET-ID 20
     cb-bgefmt AT ROW 7 COL 33 COLON-ALIGNED WIDGET-ID 18
     cb-bgeflold AT ROW 8 COL 33 COLON-ALIGNED WIDGET-ID 16
     fi-bgeflnm AT ROW 9 COL 16.5 COLON-ALIGNED WIDGET-ID 14
     b-mark AT ROW 10.5 COL 1 WIDGET-ID 26
     b-add AT ROW 10.5 COL 4 WIDGET-ID 22
     b-del AT ROW 10.5 COL 14 WIDGET-ID 24
     br-tt-clients-iv AT ROW 11.5 COL 1 WIDGET-ID 200
     SPACE(0.00) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Настройки экспорта" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: tt-clients-iv T "?" NO-UNDO ub clients
      ADDITIONAL-FIELDS:
          field is-selected as logical

          index pi is primary unique obj-type obj-code
          index is-sel is-selected

      END-FIELDS.
      TABLE: X_db B "?" ? ub db
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-tt-clients-iv b-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tt-clients-iv
/* Query rebuild information for BROWSE br-tt-clients-iv
     _TblList          = "Temp-Tables.tt-clients-iv"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-selected(buffer tt-clients-iv) FORMAT ""X(1)"":U" ? ? ? ? ? ? ? ? ? no ? no no "1" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.tt-clients-iv.obj-type
     _FldNameList[3]   = Temp-Tables.tt-clients-iv.obj-code
     _FldNameList[4]   > Temp-Tables.tt-clients-iv.obj-name
"tt-clients-iv.obj-name" ? ? "character" ? ? ? ? ? ? no ? no no "48.75" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-tt-clients-iv */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Настройки экспорта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add in this-procedure no-error .
  if error-status :error = yes
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  run proc-b-del in this-procedure no-error .
  if error-status :error = yes
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  run proc-b-mark in this-procedure no-error .
  if error-status :error = yes
  then do:
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-bgeflold
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-bgeflold Dialog-Frame
ON VALUE-CHANGED OF cb-bgeflold IN FRAME Dialog-Frame /* Варианты создания файла выгрузки */
DO:
  run check-bgeflold in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-bgefmt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-bgefmt Dialog-Frame
ON VALUE-CHANGED OF cb-bgefmt IN FRAME Dialog-Frame /* Форматы выгрузки */
DO:
  run check-bgefmt in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-bgeshift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-bgeshift Dialog-Frame
ON VALUE-CHANGED OF cb-bgeshift IN FRAME Dialog-Frame /* Способ выгрузки сменных объектов */
DO:
  run check-bgeshift in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-bgeflnm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-bgeflnm Dialog-Frame
ON LEAVE OF fi-bgeflnm IN FRAME Dialog-Frame /* Список шаблонов */
DO:
  run check-bgeflnm in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tt-clients-iv
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
  if  p-mode <> {&lookup} and
      p-mode <> {&update}
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      view-as alert-box error.
      undo, return error.
  end.

  if p-obj-type <> {&db} and
     p-obj-type <> '':U
  then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      view-as alert-box error.
      undo, return error.
  end.

  if p-obj-type = {&db} then do:
    find first X_db no-lock where X_db.db-num = p-obj-code no-error.
    if not available X_db then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        view-as alert-box error.
        undo, return error.
    end.
  end.

  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.

  if p-obj-type = {&db} then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    and X_db.db-num <> v-cntxt-db-num
    then do:
        MESSAGE
        "Нельзя менять параметры в чужой УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.

  if p-mode = {&update} then do:
    find first locked_thbj-attr exclusive-lock
      where locked_thbj-attr.obj-type = p-obj-type
        and locked_thbj-attr.obj-code = p-obj-code
        and locked_thbj-attr.upper-prop-code = {&attr-bge-export}
        and locked_thbj-attr.prop-code = "":u
    no-wait no-error.
    if locked locked_thbj-attr then do:
      message
        vss-workfile vss-revision vss-description skip
          "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_thbj-attr no-lock
    where locked_thbj-attr.obj-type = p-obj-type
      and locked_thbj-attr.obj-code = p-obj-code
      and locked_thbj-attr.upper-prop-code = {&attr-bge-export}
      and locked_thbj-attr.prop-code = '':u
    no-error.
  end.
  if not available locked_thbj-attr then do:
    assign
      v-to-create  = yes
    .
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.
  end.

  assign
    v-tth = buffer thbjattr_thbj-attr:table-handle
  .

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  run my-enable in this-procedure .

/*  RUN enable_UI.*/
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-bgeflnm Dialog-Frame
PROCEDURE check-bgeflnm :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-bgeflold Dialog-Frame
PROCEDURE check-bgeflold :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  assign frame {&frame-name}
    cb-bgeflold
  .
  if cb-bgeflold = "var":u
  then do:
    enable
      fi-bgeflnm
    with frame {&frame-name}.
  end.
  else do:
    disable
      fi-bgeflnm
    with frame {&frame-name}.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-bgefmt Dialog-Frame
PROCEDURE check-bgefmt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  assign frame {&frame-name}
    cb-bgefmt
  .
  if cb-bgefmt = "xml":u
  then do:
    enable
      cb-bgeflold
      fi-bgeflnm when cb-bgeflold = "var":u
    with frame {&frame-name}.
  end.
  else do:
    disable
      cb-bgeflold
      fi-bgeflnm
    with frame {&frame-name}.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-bgeshift Dialog-Frame
PROCEDURE check-bgeshift :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

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
  DISPLAY tg-bgeclall tg-bgedcard tg-bgedict cb-bgeshift cb-bgefmt cb-bgeflold
          fi-bgeflnm
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tg-bgeclall tg-bgedcard tg-bgedict cb-bgeshift
         cb-bgefmt cb-bgeflold fi-bgeflnm b-mark b-add b-del br-tt-clients-iv
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame
PROCEDURE fill-widgets :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients       for ub.clients.
define buffer buf_tt-clients-iv for tt-clients-iv.

define variable v-param-type      as character  no-undo .
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-entry           as character  no-undo .
define variable v-str             as character  no-undo .
define variable v-bgecliiv        as character  no-undo .
define variable v-obj-type        as character  no-undo .
define variable v-obj-code        as integer    no-undo .
define variable v-i               as integer    no-undo .

do
on error undo, return error return-value
:
  empty temp-table thbjattr_thbj-attr.
  empty temp-table temp-thbj-attr.
  empty temp-table buf_tt-clients-iv.

  run adm/shattri.p (
                input "init":U
              , input p-obj-type
              , input p-obj-code
              , input {&attr-bge-export}
              , input "":U
              , output v-value-character
              , output v-value-date
              , output v-value-decimal
              , output v-value-integer
              , output v-value-logical
              , output v-param-type
              , INPUT-OUTPUT table-handle v-tth
              ) no-error .
  if error-status:error
  and not available locked_thbj-attr then do:
    message
    "Не удалось получить начальные значения настроек" skip
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo, return error .
  end.

  for each thbjattr_thbj-attr:
    assign
      v-entry = thbjattr_thbj-attr.prop-code
    .
    case v-entry:
      when {&attr-bge-export_bgeclall} then do:
        assign
          tg-bgeclall = thbjattr_thbj-attr.property-value-logical
          tg-bgeclall :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-bge-export_bgedcard} then do:
        assign
          tg-bgedcard = thbjattr_thbj-attr.property-value-logical
          tg-bgedcard :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-bge-export_bgedict} then do:
        assign
          tg-bgedict = thbjattr_thbj-attr.property-value-logical
          tg-bgedict :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-bge-export_bgeflnm} then do:
        assign
          fi-bgeflnm = thbjattr_thbj-attr.property-value-character
          fi-bgeflnm :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-bge-export_bgeflold} then do:
        assign
          cb-bgeflold = thbjattr_thbj-attr.property-value-character
          cb-bgeflold :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-bge-export_bgefmt} then do:
        assign
          cb-bgefmt = thbjattr_thbj-attr.property-value-character
          cb-bgefmt :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-bge-export_bgeshift} then do:
        assign
          cb-bgeshift = thbjattr_thbj-attr.property-value-character
          cb-bgeshift :private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
        .
      end.
      when {&attr-bge-export_bgecliiv} then do:
        assign
          v-bgecliiv = thbjattr_thbj-attr.property-value-character
        .
      end.
    end case.
    create temp-thbj-attr.
    buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
  end.
  _cli-cycle:
  do v-i = 1 to num-entries(v-bgecliiv,';')
  :
    assign
      v-str = entry( v-i , v-bgecliiv ,';')
    .
    if num-entries(v-str) = 2
    then do:
      assign
        v-obj-type = entry(1, v-str)
      .
      assign
        v-obj-code = integer( entry(2, v-str) )
      no-error .
      if error-status :error = yes
      then do:
        next _cli-cycle.
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = v-obj-type
          and buf_clients.obj-code = v-obj-code
      no-error.
      if available buf_clients
      then do:
        find first buf_tt-clients-iv no-lock
          where buf_tt-clients-iv.obj-type = buf_clients.obj-type
            and buf_tt-clients-iv.obj-code = buf_clients.obj-code
        no-error .
        if not available buf_tt-clients-iv
        then do:
          create buf_tt-clients-iv.
          buffer-copy buf_clients to buf_tt-clients-iv.
          release buf_tt-clients-iv.
        end.
      end.
    end. /* if num-entries(v-str) = 2 */
  end. /* _cli-cycle: */
  run open-br in this-procedure .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if p-mode = {&lookup}
  then do:
    assign
      fi-bgeflnm  :fgcolor in frame {&frame-name} = BROWN_COLOR
      b-exit :hidden  = yes
      b-quit :label   = "&Выход":U
    .
  end.

  display
    tg-bgeclall
    tg-bgedcard
    tg-bgedict
    fi-bgeflnm
    cb-bgeflold
    cb-bgefmt
    cb-bgeshift
  with frame {&frame-name}.
  enable
    b-exit      when p-mode = {&update}
    b-quit
    b-help
    b-mark      when p-mode = {&update}
    b-add       when p-mode = {&update}
    b-del       when p-mode = {&update}
    br-tt-clients-iv
    tg-bgeclall when p-mode = {&update}
    tg-bgedcard when p-mode = {&update}
    tg-bgedict  when p-mode = {&update}
    fi-bgeflnm  when p-mode = {&update}
    cb-bgeflold when p-mode = {&update}
    cb-bgefmt   when p-mode = {&update}
    cb-bgeshift when p-mode = {&update}
  with frame {&frame-name}.

  view frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-br Dialog-Frame
PROCEDURE open-br :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  {&OPEN-QUERY-br-tt-clients-iv}
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_clients       for ub.clients.
  define buffer buf_tt-clients-iv for tt-clients-iv.

  define variable v-rid-list  as character no-undo .
  define variable v-i         as integer   no-undo .
do
on error undo, return error return-value
:
  run ref/cli-all.w ( input parparentproc
                    , input "b-sel,b-mark"
                    , input {&all}
                    , input {&all}
                    , input {&current}
                    , input ?
                    , input ",,,,,,NO,,"
                    , input ""
                    , output v-rid-list
                    ) no-error.
  if error-status :error = yes
  then do:
    message
      "Ошибка при выборе контрагентов" skip
      return-value skip
      trim(error-status :get-message(1)) skip
      trim(error-status :get-message(2)) skip
    view-as alert-box information.
  end.
  do v-i = 1 to num-entries(v-rid-list)
  :
    find first buf_clients no-lock
      where recid(buf_clients) = integer(entry(v-i,v-rid-list))
    no-error .
    if available buf_clients
    then do:
      find first buf_tt-clients-iv no-lock
        where buf_tt-clients-iv.obj-type = buf_clients.obj-type
          and buf_tt-clients-iv.obj-code = buf_clients.obj-code
      no-error .
      if not available buf_tt-clients-iv
      then do:
        create buf_tt-clients-iv.
        buffer-copy buf_clients to buf_tt-clients-iv.
      end.
    end.
  end.
  run open-br in this-procedure .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_tt-clients-iv for tt-clients-iv.

  define variable v-log   as logical   no-undo .
do
on error undo, return error return-value
:
  find first buf_tt-clients-iv no-lock
    where buf_tt-clients-iv.is-selected = yes
  no-error .
  if available buf_tt-clients-iv
  then do:
    message
      "Удалить выделенные?"
    view-as alert-box question buttons yes-no update v-log.
    if v-log <> yes then return.
    for each buf_tt-clients-iv
      where buf_tt-clients-iv.is-selected = yes
    :
      delete buf_tt-clients-iv.
    end.
  end.
  else do:
    if available tt-clients-iv
    then do:
      message
        tt-clients-iv.obj-name skip
        "Удалить?"
      view-as alert-box question buttons yes-no update v-log.
      if v-log <> yes then return.
      delete tt-clients-iv.
    end.
  end.
  run open-br in this-procedure.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame
PROCEDURE proc-b-mark :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  if available tt-clients-iv
  then do:
    assign
      tt-clients-iv.is-selected = not tt-clients-iv.is-selected
    .
     br-tt-clients-iv:refresh() in frame {&frame-name}.
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      br-tt-clients-iv:select-next-row ().
      apply "VALUE-CHANGED" to br-tt-clients-iv in frame {&frame-name}.
    end.
  end.
end.
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
define buffer buf_tt-clients-iv for tt-clients-iv.

define variable v-value-character as character      no-undo .
define variable v-value-date      as date           no-undo .
define variable v-value-decimal   as decimal        no-undo .
define variable v-value-integer   as integer        no-undo .
define variable v-value-logical   as logical        no-undo .
define variable v-sale-add        as character      no-undo .
define variable v-param-type      as character      no-undo .
define variable wh                as widget-handle  no-undo .
define variable fh                as widget-handle  no-undo .
define variable v-same            as logical        no-undo .
define variable v-bgecliiv        as character      no-undo .
do
on error undo, return error return-value
:
  if p-mode = {&lookup} then return error.

  assign
  frame {&frame-name}
    tg-bgeclall
    tg-bgedcard
    tg-bgedict
    fi-bgeflnm
    cb-bgeflold
    cb-bgefmt
    cb-bgeshift
    fh = frame {&frame-name}:first-child
    wh = fh:first-child
  .

  for each buf_tt-clients-iv
  :
    assign
      v-bgecliiv = v-bgecliiv + substitute( "&1,&2;"
                                          , buf_tt-clients-iv.obj-type
                                          , buf_tt-clients-iv.obj-code
                                          )
    .
  end.

  assign
    v-bgecliiv = trim(v-bgecliiv , ',')
  .

  do while valid-handle(wh):
    if wh:private-data begins "recid="
    then do:
      find first thbjattr_thbj-attr
        where recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '='))
      .
      assign
      buffer
        thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value
      .
    end.
    wh = wh:next-sibling.
  end.

  find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-bge-export_bgecliiv}.
  assign
    thbjattr_thbj-attr.property-value-character = v-bgecliiv
  .
  release thbjattr_thbj-attr.

  assign
    v-same = yes
  .

  for each thbjattr_thbj-attr,
      first temp-thbj-attr
        where temp-thbj-attr.obj-type         = thbjattr_thbj-attr.obj-type
          and temp-thbj-attr.obj-code         = thbjattr_thbj-attr.obj-code
          and temp-thbj-attr.upper-prop-code  = thbjattr_thbj-attr.upper-prop-code
          and temp-thbj-attr.prop-code        = thbjattr_thbj-attr.prop-code
  :
    buffer-compare thbjattr_thbj-attr to temp-thbj-attr save result in v-same.
    if not v-same then leave.
  end.

  if v-same  and not v-to-create then return.
  /*проверим корректность*/
  run adm/shattri.p ( input "check":U
                    , input p-obj-type
                    , input p-obj-code
                    , input {&attr-bge-export}
                    , INPUT '':U
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-value-integer
                    , output v-value-logical
                    , output v-param-type
                    , input-output table-handle v-tth
                    ) no-error .

  if error-status :error then do:
    message
      "Некорректное значение ПАРАМЕТРОВ"  skip
      error-status:get-message(1)         skip
      return-value
    view-as alert-box error .
    undo, return error .
  end.


  do transaction
  on error undo, return error return-value
  :
    run thbjattr_set-section in this-procedure ( input p-obj-type
                                               , input p-obj-code
                                               , input {&attr-bge-export}
                                               , input table thbjattr_thbj-attr
                                               ) no-error.
    if error-status:error then do:
      message
        error-status:get-message(1)  skip
        return-value
      view-as alert-box.
      undo, return error.
    end.
  end.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-selected Dialog-Frame
FUNCTION mark-selected RETURNS CHARACTER
( buffer buf_tt-clients-iv for tt-clients-iv) :

  return (if buf_tt-clients-iv.is-selected then '*' else '').
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME