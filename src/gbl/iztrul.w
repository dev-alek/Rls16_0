&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME wind1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS wind1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Правила работы ИЖТ

Автор: Чернова Светлана Александровна
Дата создания: 10/20/09
Author: Svetlana Chernova
Creation date: 10/20/09

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Правила работы ИЖТ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ cmp/library.i  }

/*------------------------------------------------------------------------*/
/*           This .W file was created with the Progress AppBuilder.       */
/*------------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter  parparentproc as handle no-undo .

/* Local Variable Definitions ---                                       */


define temp-table tt-izt no-undo
    field nn              as INTEGER
    field izt-event-name  as character
    field izt-event-code  as character
    FIELD izd-new         AS LOGICAL
    FIELD izd-com         AS LOGICAL
    FIELD izd-del         AS LOGICAL
    FIELD izd-spec        AS LOGICAL
    FIELD izd-empty       AS LOGICAL
index pi nn
index by1 izt-event-name
index by2 izt-event-code

.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME wind1
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-izt

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt-izt.izt-event-name tt-izt.izd-new tt-izt.izd-com tt-izt.izd-del tt-izt.izd-spec tt-izt.izd-empty
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 tt-izt.izd-new   tt-izt.izd-com   tt-izt.izd-del   tt-izt.izd-spec   tt-izt.izd-empty
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 tt-izt
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 tt-izt
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH tt-izt
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH tt-izt.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-izt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-izt


/* Definitions for DIALOG-BOX wind1                                     */
&Scoped-define OPEN-BROWSERS-IN-QUERY-wind1 ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-def B-Help RECT-1 BROWSE-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-def
     LABEL "По умолчанию"
     SIZE 17 BY 1 TOOLTIP "Вернуть расстановку по умолчанию"
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "В&вод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 5 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 0
     SIZE 97 BY 1
     BGCOLOR 3 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
tt-izt.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 wind1 _FREEFORM
  QUERY BROWSE-2 DISPLAY
      tt-izt.izt-event-name    FORMAT "X(56)" COLUMN-LABEL "Событие"
tt-izt.izd-new          COLUMN-LABEL "Новый" VIEW-AS TOGGLE-BOX
tt-izt.izd-com          COLUMN-LABEL "Основная" VIEW-AS TOGGLE-BOX
tt-izt.izd-del          COLUMN-LABEL "На вывод" VIEW-AS TOGGLE-BOX
tt-izt.izd-spec         COLUMN-LABEL "Нештатный" VIEW-AS TOGGLE-BOX
tt-izt.izd-empty        COLUMN-LABEL "Пусто"  VIEW-AS TOGGLE-BOX
    ENABLE
    tt-izt.izd-new
    tt-izt.izd-com
    tt-izt.izd-del
    tt-izt.izd-spec
    tt-izt.izd-empty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 19 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME wind1
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-def AT ROW 1 COL 21 WIDGET-ID 6
     B-Help AT ROW 1 COL 93.5
     BROWSE-2 AT ROW 3 COL 1.5 WIDGET-ID 200
     "Действия с товаром разрешены" VIEW-AS TEXT
          SIZE 29 BY .67 AT ROW 2.21 COL 36.63 WIDGET-ID 2
          BGCOLOR 3 FGCOLOR 15
     RECT-1 AT ROW 2 COL 1.5 WIDGET-ID 4
     SPACE(0.37) SKIP(19.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Правила работы ИЖТ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX wind1
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 RECT-1 wind1 */
ASSIGN
       FRAME wind1:SCROLLABLE       = FALSE
       FRAME wind1:HIDDEN           = TRUE.

ASSIGN
       BROWSE-2:NUM-LOCKED-COLUMNS IN FRAME wind1     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-izt.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BROWSE-2 FOR
tt-izt.
     _END_FREEFORM_DEFINE
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME wind1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wind1 wind1
ON WINDOW-CLOSE OF FRAME wind1 /* Правила работы ИЖТ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-def
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-def wind1
ON CHOOSE OF B-def IN FRAME wind1 /* По умолчанию */
DO:
  RUN def-proc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit wind1
ON CHOOSE OF B-exit IN FRAME wind1 /* Ввод */
DO:
  RUN save-proc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help wind1
ON CHOOSE OF B-Help IN FRAME wind1 /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 wind1
ON ITERATION-CHANGED OF BROWSE-2 IN FRAME wind1
DO:
 run rrr .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 wind1
ON ROW-DISPLAY OF BROWSE-2 IN FRAME wind1
DO:

  if tt-izt.izt-event-code = {&izt-event-scu-grp-matr}    or
     tt-izt.izt-event-code = {&izt-event-scu-grp-specif}  then do:
      tt-izt.izd-new        :bgcolor in browse {&browse-name}   = 8  .
      tt-izt.izd-com        :bgcolor in browse {&browse-name}   = 8  .
      tt-izt.izd-del        :bgcolor in browse {&browse-name}   = 8  .
      tt-izt.izd-spec       :bgcolor in browse {&browse-name}   = 8  .
      tt-izt.izd-empty      :bgcolor in browse {&browse-name}   = 8  .
  end.
  else do:
      tt-izt.izd-new        :bgcolor in browse {&browse-name}   = ?  .
      tt-izt.izd-com        :bgcolor in browse {&browse-name}   = ?   .
      tt-izt.izd-del        :bgcolor in browse {&browse-name}   = ?   .
      tt-izt.izd-spec       :bgcolor in browse {&browse-name}   = ?   .
      tt-izt.izd-empty      :bgcolor in browse {&browse-name}   = ?   .
  end.
  if tt-izt.izt-event-code = {&izt-event-delete-matr-rest}  or
     tt-izt.izt-event-code = {&izt-event-delete-matr-norest} then do:
      tt-izt.izd-new        :bgcolor in browse {&browse-name}   = 8  .
      tt-izt.izd-com        :bgcolor in browse {&browse-name}   = 8  .
      tt-izt.izd-spec       :bgcolor in browse {&browse-name}   = 8  .
      tt-izt.izd-empty      :bgcolor in browse {&browse-name}   = 8  .
  end.
  else do:
      tt-izt.izd-new        :bgcolor in browse {&browse-name}   = ?  .
      tt-izt.izd-com        :bgcolor in browse {&browse-name}   = ?   .
      tt-izt.izd-spec       :bgcolor in browse {&browse-name}   = ?   .
      tt-izt.izd-empty      :bgcolor in browse {&browse-name}   = ?   .
  end.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 wind1
ON ROW-ENTRY OF BROWSE-2 IN FRAME wind1
DO:
run rrr .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 wind1
ON VALUE-CHANGED OF BROWSE-2 IN FRAME wind1
DO:
         run rrr .


  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK wind1


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
  RUN init-tt.
  RUN enable_UI.
  if g#db-num > 0 then do:
      hide B-exit B-def in frame {&frame-name} .
      b-quit:label = "Выход" .
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE def-proc wind1
PROCEDURE def-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

find first ub.thbj-attr exclusive-lock where
              ub.thbj-attr.obj-code                     =  0   and
              ub.thbj-attr.obj-type                     =  ""  and
              ub.thbj-attr.prop-code                    = {&attr-izt-rul}  and
              ub.thbj-attr.prop-value-type              = {&ABL-datatype-character}  and
              ub.thbj-attr.upper-prop-code              = {&attr-izt-rul}
              no-error  .
if available ub.thbj-attr then do:
   delete ub.thbj-attr.
end.
  run gbl/clearlib.p .
  run init-tt .
  run enable_ui .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI wind1  _DEFAULT-DISABLE
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
  HIDE FRAME wind1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI wind1  _DEFAULT-ENABLE
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
  ENABLE B-exit B-quit B-def B-Help RECT-1 BROWSE-2
      WITH FRAME wind1.
  VIEW FRAME wind1.
  {&OPEN-BROWSERS-IN-QUERY-wind1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt wind1
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-nn  as integer   no-undo .
define variable i as integer   no-undo .
empty temp-table tt-izt .

v-nn = num-entries ({&izt-event-types}) .
do i = 1 to v-nn :
  CREATE tt-izt.
  ASSIGN
    tt-izt.nn              =  i
    tt-izt.izt-event-name  = entry( i, {&izt-event-types-full})
    tt-izt.izt-event-code  = entry( i, {&izt-event-types} )
  .
  { gbl/iztrul.i
    tt-izt.izt-event-code
    tt-izt.izd-new
    tt-izt.izd-com
    tt-izt.izd-del
    tt-izt.izd-spec
    tt-izt.izd-empty
    no-error }
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
    .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc wind1
PROCEDURE save-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-str as character no-undo .
v-str = "".
    for each tt-izt by tt-izt.nn :
      v-str = v-str + tt-izt.izt-event-code  + "," +
              string (tt-izt.izd-new) + "," +
              string (tt-izt.izd-com) + "," +
              string (tt-izt.izd-del) + "," +
              string (tt-izt.izd-spec) + "," +
              string (tt-izt.izd-empty)  + ";" .
    end.
v-str = trim(v-str, ";") .
empty temp-table thbjattr_thbj-attr.
create thbjattr_thbj-attr.
assign
thbjattr_thbj-attr.obj-code                     =  0
thbjattr_thbj-attr.obj-type                     =  ""
thbjattr_thbj-attr.prop-code                    = {&attr-izt-rul}
thbjattr_thbj-attr.prop-value-type              = {&ABL-datatype-character}
thbjattr_thbj-attr.property-value-character     = v-str
thbjattr_thbj-attr.upper-prop-code              = {&attr-izt-rul}
.

  run thbjattr_set-section in this-procedure (
        input ""
      , input 0
      , input {&attr-izt-rul}
      , input table thbjattr_thbj-attr
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    "Вернулась из thbjattr_set-section"
    view-as alert-box.
    undo, return error.
  end.

 run gbl/clearlib.p .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rrr W-Win
PROCEDURE rrr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
    if tt-izt.izt-event-code = {&izt-event-scu-grp-matr}    or
     tt-izt.izt-event-code = {&izt-event-scu-grp-specif}  then do:
      tt-izt.izd-new        :read-only in browse {&browse-name}   = true  .
      tt-izt.izd-com        :read-only in browse {&browse-name}   = true  .
      tt-izt.izd-del        :read-only in browse {&browse-name}   = true  .
      tt-izt.izd-spec       :read-only in browse {&browse-name}   = true  .
      tt-izt.izd-empty      :read-only in browse {&browse-name}   = true  .
  end.
  else do:
        if tt-izt.izt-event-code = {&izt-event-delete-matr-rest}  or
          tt-izt.izt-event-code = {&izt-event-delete-matr-norest} then do:
            tt-izt.izd-new        :read-only in browse {&browse-name}   = true  .
            tt-izt.izd-com        :read-only in browse {&browse-name}   = true  .
            tt-izt.izd-del        :read-only in browse {&browse-name}   = false   .
            tt-izt.izd-spec       :read-only in browse {&browse-name}   = true  .
            tt-izt.izd-empty      :read-only in browse {&browse-name}   = true  .
        end.
        else do:
            tt-izt.izd-new        :read-only in browse {&browse-name}   = false  .
            tt-izt.izd-com        :read-only in browse {&browse-name}   = false   .
            tt-izt.izd-spec       :read-only in browse {&browse-name}   = false   .
            tt-izt.izd-empty      :read-only in browse {&browse-name}   = false   .
            tt-izt.izd-del        :read-only in browse {&browse-name}   = false   .
        end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
