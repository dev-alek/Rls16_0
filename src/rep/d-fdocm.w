&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
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

Список печатных форм для печати финдокументов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/14/10
Author: Bakhtadze Natalya
Creation date: 04/14/10

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

define temp-table temp_fin-doc-code no-undo
field host-code as integer
field fin-doc-code as integer
index pi is primary unique fin-doc-code
.
/* Parameters Definitions ---                                           */

define input parameter parparentproc    as handle           no-undo.
define input parameter p-call-handle     as handle           no-undo.
define input parameter table for temp_fin-doc-code .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список печатных форм для печати документов.".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/showinf.i      }
{ cmp/library.i      }
{ cmp/r-pril.i new   }
{ gbl/color.i        }
{ rep/menufdoc.i def }
{ gbl/getcntxt.i def }

define new shared variable print-graft as logical no-undo .
define new shared variable no-vat      as logical no-undo .
define new shared variable sort-gr     as logical no-undo .
define new shared variable sort-name   as logical no-undo .
define new shared variable CostPrice   as logical no-undo .
define new shared variable PrintScale  as logical no-undo .
define new shared variable PrintParts  as logical no-undo .

define variable v-par-value         as character    no-undo.
define variable v-par-type          as character    no-undo.
define variable in-docprvalue       as character    no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES Tmp#List

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table Tmp#List.last-use Tmp#List.blank-name Tmp#List.type-val   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table   
&Scoped-define SELF-NAME br-table
&Scoped-define OPEN-QUERY-br-table /* OPEN QUERY {&SELF-NAME} FOR EACH Tmp#List no-lock . */ run local-open-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table Tmp#List
&Scoped-define FIRST-TABLE-IN-QUERY-br-table Tmp#List


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-chg b-print-doc b-help i-print ~
br-table fi-default-printer 
&Scoped-Define DISPLAYED-OBJECTS fi-default-printer 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.1.

DEFINE BUTTON b-deselect 
     LABEL "&Снять *" 
     SIZE 10 BY 1.1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход" 
     SIZE 10 BY 1.1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помощ&ь" 
     SIZE 3.6 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print-doc 
     LABEL ".   Пе&чать":L 
     SIZE 11.8 BY 1.1
     BGCOLOR 8 .

DEFINE BUTTON b-sel 
     LABEL "*" 
     SIZE 3 BY 1.1.

DEFINE BUTTON i-print 
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U
     LABEL "" 
     SIZE 4 BY .95.

DEFINE VARIABLE fi-default-printer AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 97 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR 
      Tmp#List SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      Tmp#List.last-use COLUMN-LABEL "*" FORMAT "*/"
    Tmp#List.blank-name COLUMN-LABEL "Название печатной формы":C53 FORMAT "X(255)"
    Tmp#List.type-val       column-label "в ..."    format "X(5)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.8 BY 20.24 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.6
     b-sel AT ROW 1 COL 11.6
     b-deselect AT ROW 1 COL 14.6
     b-chg AT ROW 1 COL 24.8
     b-print-doc AT ROW 1 COL 34.8
     b-help AT ROW 1 COL 96
     i-print AT ROW 1.05 COL 35 WIDGET-ID 2 NO-TAB-STOP 
     br-table AT ROW 2.24 COL 1.6
     fi-default-printer AT ROW 22.76 COL 1.6 NO-LABEL
     SPACE(1.27) SKIP(0.19)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Список печатных форм".


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
/* BROWSE-TAB br-table i-print Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-deselect IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-default-printer IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN 
       fi-default-printer:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH Tmp#List no-lock . */
run local-open-query in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список печатных форм */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable v-options-string            as character    no-undo.
define variable v-options-string-new        as character    no-undo.
define variable v-options-enabled-string    as character    no-undo.

if available tmp#list
then do:
  run menufdoc-create-options-string in this-procedure (
        input tmp#list.id
      , output v-options-string
  ).
  run menufdoc-create-options-enabled-string in this-procedure (
        input tmp#list.id
      , output v-options-enabled-string
  ).
  run rep/d-docmd.w (
        input tmp#list.blank-name
      , input v-options-string
      , input v-options-enabled-string
      , output v-options-string-new
  ) no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description
    skip(1)
    skip "Ошибка изменения параметров печати."
    skip return-value
    skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return no-apply .
  end.
  if v-options-string-new <> v-options-string
  then do:
      run menufdoc-set-options-string in this-procedure (
              input tmp#list.id
            , input v-options-string-new
      ).
    browse {&browse-name} :refresh().
    apply "entry" to {&browse-name} in frame {&frame-name}.
  end.
end.        /* available tmp#list */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-deselect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-deselect Dialog-Frame
ON CHOOSE OF b-deselect IN FRAME Dialog-Frame /* Снять * */
DO:
  for each tmp#list no-lock
  :
    assign
    tmp#list.last-use = no
    .
  end.        /* for each tmp#list */
  browse {&browse-name} :refresh().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  run save-form-parameters in this-procedure no-error.
  if error-status :error
  then do:
      message
      vss-workfile vss-revision vss-description
      skip(1)
      skip "Ошибка при сохранении параметров"
      skip "списка печатных форм."
      skip return-value
      skip trim(error-status :get-message(1))
      view-as alert-box error.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print-doc Dialog-Frame
ON CHOOSE OF b-print-doc IN FRAME Dialog-Frame /* .   Печать */
DO:
define variable v-is-selected   as logical      no-undo.
define buffer buf_temp_tmp#list      for tmp#list.
assign
v-is-selected = no
.
test-selecting:
for each buf_temp_tmp#list
:
  if buf_temp_tmp#list.last-use <> no
  then do:
    assign
    v-is-selected = yes
    .
    leave test-selecting.
  end.
end.
if v-is-selected = no
then do:
  message
  "Не выбрано ни одной формы"
  skip "для печати."
  view-as alert-box information
  title "Печать невозможна"
  .
  undo, return no-apply.
end.
else do:
  run print-docs in this-procedure no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description
    skip(1)
    skip "Ошибка печати документов."
    skip return-value
    skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return no-apply .
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* * */
DO:
  if available tmp#list
  then do:
    assign
    tmp#list.last-use = ( if tmp#list.last-use = yes then no else yes )
    .
    run reposition-browse in this-procedure .
    browse {&browse-name} :refresh().
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON 1 OF br-table IN FRAME Dialog-Frame
DO:
  if available tmp#list
  then do:
    if tmp#list.type-val = "  +":U
    or tmp#list.type-val = "  -":U
    then do:
      assign
      tmp#list.type-val = ( if tmp#list.type-val = "  +":U then "  -":U else "  +":U )
      .
    end.
    {&browse-name} :refresh().
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-table IN FRAME Dialog-Frame
DO:
  if available Tmp#List
  then do:
    run select-or-deselect-item in this-procedure (
        input Tmp#List.id
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка выбора или отмены выбора."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    br-table :refresh().
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON ROW-DISPLAY OF br-table IN FRAME Dialog-Frame
DO:
  if tmp#list.type-val-enabled = no
  then do:
    assign
    Tmp#List.type-val :bgcolor in browse {&browse-name} = GREY_COLOR
    .
  end.
  if lookup("other", tmp#list.filtr) > 0  then do:
    assign
    Tmp#List.last-use          :bgcolor in browse {&browse-name} = yellow_COLOR
    Tmp#List.blank-name        :bgcolor in browse {&browse-name} = yellow_COLOR
    .
  end.
  else do:
    assign
    Tmp#List.last-use          :bgcolor in browse {&browse-name} = ?
    Tmp#List.blank-name        :bgcolor in browse {&browse-name} = ?
    .
  end.
  if Tmp#List.orient-font-num <> 7
  then do:
    assign
    Tmp#List.last-use          :fgcolor in browse {&browse-name} = DARK_GREEN_COLOR
    Tmp#List.blank-name        :fgcolor in browse {&browse-name} = DARK_GREEN_COLOR
    .
  end.        /* if Tmp#List.orient-font-number <> 7 */
  else do:
    if Tmp#List.orient-orientation = 'A4port':U
    or Tmp#List.orient-orientation = 'A3port':U
    then do:
      Tmp#List.last-use          :fgcolor in browse {&browse-name} = BLUE_COLOR.
      Tmp#List.blank-name        :fgcolor in browse {&browse-name} = BLUE_COLOR.
    end.
    else do:
      if Tmp#List.orient-orientation = 'EXCEL':U
      or Tmp#List.orient-orientation = 'self':U
      then do:
        Tmp#List.last-use   :fgcolor in browse {&browse-name} = CYAN_COLOR.
        Tmp#List.blank-name :fgcolor in browse {&browse-name} = CYAN_COLOR.
      end.
      else do:
        Tmp#List.last-use   :fgcolor in browse {&browse-name} = BLACK_COLOR.
        Tmp#List.blank-name :fgcolor in browse {&browse-name} = BLACK_COLOR.
      end.
    end.
  end.        /* NOT ( if Tmp#List.orient-font-number <> 7 ) */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME i-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL i-print Dialog-Frame
ON CHOOSE OF i-print IN FRAME Dialog-Frame
DO:
  APPLY "choose" TO b-print-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/*on ctrl-alt-f3 anywhere*/
/*do:*/
/*    define variable v-str    as character    no-undo.*/
/*    for each tmp#list*/
/*    where tmp#list.last-use = yes*/
/*    :*/
/*        assign*/
/*            v-str = v-str + {&new-line} + tmp#list.blank-name*/
/*        .*/
/*    end.*/
/*    message*/
/*        "X"*/
/*        skip v-str*/
/*    view-as alert-box information.*/
/*end.*/

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  Tmp#List.type-val:label =  "в {&abbr_rub}"  .
  { gbl/getcntxt.i get " " parparentproc }
  run get-quest-print in parparentproc (
      output g#quest-print
  ).
  run get-report-num in parparentproc (
      output g#report-num
  ).
  run init-fields in this-procedure.
  RUN enable_UI.
  run ui-disable-all in this-procedure.
  run ui-enable in this-procedure.
  apply "value-changed" to br-table.
  apply "entry" to br-table.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-menu-items1 Dialog-Frame 
PROCEDURE create-menu-items1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-host-code      as integer          no-undo .
define input parameter p-fin-doc-code   as integer          no-undo.
define input parameter p-doc-type       as character        no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-status_        as character        no-undo.

define variable xtype        as character    no-undo.
define variable xstatus      as character    no-undo.
do
on error undo, return error
:
  if p-doc-type <> {&inventory}
  then do:
    assign
    xtype = p-doc-type
    .
  end.
  else do:
    assign
    xtype = p-ext-doc-type
    .
  end.
  assign
  xstatus             = string( p-status_  )
  .
  assign
  v-menu-doc-host-code = p-host-code
  v-menu-doc-fin-doc-code = p-fin-doc-code
  v-menu-doc-fin-doc-type = xtype
  v-menu-doc-fin-ext-doc-type = p-ext-doc-type
  v-menu-doc-status_      = xstatus
  .
  { rep/loadfdoc.i }
end.
END PROCEDURE. /* create-menu-items1 */


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
  DISPLAY fi-default-printer 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-chg b-print-doc b-help i-print br-table fi-default-printer 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-call-point Dialog-Frame 
PROCEDURE get-call-point :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-tmp#list-id as integer          no-undo.
define output parameter p-call-point as character        no-undo.

define variable v-doc-type        as character    no-undo.
define variable v-doc-status      as character    no-undo.

define buffer buf_temp_form-list        for temp_form-list.
do
for buf_temp_form-list
on error undo, return error
:
  assign
  v-doc-type     = "":U
  v-doc-status   = "":U
  .
  for each buf_temp_form-list
      where buf_temp_form-list.id = Tmp#List.id
  :
    if lookup( buf_temp_form-list.fin-doc-type, v-doc-type ) = 0
    then do:
      assign
      v-doc-type = ( if v-doc-type = "":U then "":U else "_":U ) + buf_temp_form-list.fin-doc-type
      .
    end.
    if lookup( buf_temp_form-list.status_, v-doc-status ) = 0
    then do:
      assign
      v-doc-status = ( if v-doc-status = "":U then "":U else "_":U ) + buf_temp_form-list.status_
            .
    end.
  end.
  assign
  p-call-point = substitute( "&1,&2", v-doc-type, v-doc-status )
  .
end.
END PROCEDURE. /* get-call-point */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-handle-all-docs Dialog-Frame 
PROCEDURE get-handle-all-docs :
/* -----------------------------------------------------------
  Purpose: Возвращает хендл alldocs
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define output parameter p-handle as handle no-undo .
p-handle =  p-call-handle .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-saved-character Dialog-Frame 
PROCEDURE get-saved-character :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-list           as character        no-undo.
define input parameter p-name           as character        no-undo.
define output parameter p-character     as character        no-undo.

define variable v-position    as integer      no-undo.
do
on error undo, return error
:
  assign
  v-position = lookup( p-name, p-list )
  .
  if v-position = 0
  then do:
    assign
    p-character = "":U
        .
  end.
  else do:
    if num-entries( p-list ) > v-position
    then do:
      assign
      p-character = entry( v-position + 1, p-list )
      .
    end.
    else do:
      assign
      p-character = "":U
      .
    end.
  end.
end.
END PROCEDURE. /* get-saved-character */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-saved-logical Dialog-Frame 
PROCEDURE get-saved-logical :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-list       as character        no-undo.
define input parameter p-name       as character        no-undo.
define output parameter p-logical   as character        no-undo.

define variable v-position    as integer      no-undo.
do
on error undo, return error
:
  assign
      v-position = lookup( p-name, p-list )
  .
  if v-position = 0
  then do:
    assign
    p-logical = "  -":U
    .
  end.
  else do:
    if num-entries( p-list ) > v-position
    then do:
      assign
      p-logical = "  ":U + entry( v-position + 1, p-list )
      .
      if trim( p-logical ) = "":U
      then do:
        assign
        p-logical = "  -":U
        .
      end.
    end.
    else do:
      assign
      p-logical = "  -":U
      .
    end.
  end.
end.
END PROCEDURE. /* get-saved-logical */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame 
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable xtype        as character    no-undo.
define variable xstatus      as character    no-undo.

define variable v-temp-char     as character    no-undo.
define variable v-par-type      as character    no-undo.
define variable v-call-point    as character    no-undo.
define variable v-doc-counter   as integer      no-undo.
define variable v-form-title    as character    no-undo.

define buffer buf_fin-doc           for ub.fin-doc.
define buffer buf_usr-flt           for ubflt.usr-flt.
do
for buf_fin-doc
  , buf_usr-flt
with frame {&frame-name}
on error undo, return error
:
  assign
 fi-default-printer = session :printer-name
  .
 { gbl/currsysk.i
      v-menu-doc-sys-key
      no-error
    }
  
  for each temp_fin-doc-code
  on error undo, return error
  :
    assign
    v-doc-counter = v-doc-counter + 1
    .
    find first buf_fin-doc no-lock
          where buf_fin-doc.host-code = temp_fin-doc-code.host-code
           and  buf_fin-doc.fin-doc-code = temp_fin-doc-code.fin-doc-code
    .
    run create-menu-items1 in this-procedure (
          input buf_fin-doc.host-code
        , input buf_fin-doc.fin-doc-code
        , input buf_fin-doc.fin-doc-type
        , input buf_fin-doc.fin-ext-doc-type
        , input buf_fin-doc.status_
      ).
  end.        /* for each temp_fin-doc-code */
  if v-doc-counter = 1
  then do:
    assign
    v-form-title = substitute( "Печать документа   Тип: &1 Статус: &2  Фирма &3 вн. № &4"
        , v-menu-doc-fin-doc-type
        , v-menu-doc-status_
        , v-menu-doc-host-code
        , v-menu-doc-fin-doc-code )
    .
  end.
  else do:
    assign
    v-form-title = substitute( "Печать выбранных документов по списку" )
    .
  end.
  assign
  frame {&frame-name} :title = v-form-title
  .
/*    run test-temp-tables in this-procedure .*/
  /* загрузить значения из ubflt.usr-flt       */
  for each Tmp#List
  :
    run get-call-point in this-procedure (
          input Tmp#List.id
        , output v-call-point
    ).
    find first buf_usr-flt no-lock
          where buf_usr-flt.user-name  = v-cntxt-userid
            and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                        , Tmp#List.blank-name
                                        , Tmp#List.sys-key
                                        , Tmp#List.sys-key-black
                                        , v-call-point )
    no-error.
    if available buf_usr-flt
    then do:
      run get-saved-logical in this-procedure (
            input buf_usr-flt.list_
          , input "type-val":U
          , output Tmp#List.type-val
      ).
      assign
      v-temp-char = "":U
      .
      run get-saved-logical in this-procedure (
            input buf_usr-flt.list_
          , input "selection":U
          , output v-temp-char
      ).
      if v-temp-char = "  +":U
      then do:
        assign
        Tmp#List.last-use = yes
        .
      end.
    end.
    else do:
      assign
      Tmp#List.type-val     = "  -":U
      .
    end.
    if Tmp#List.type-val-enabled = no
    then do:
      assign
      Tmp#List.type-val     = " ":U
      .
    end.

    if v-doc-counter > 1 then do:
      if lookup("no-print-many" ,Tmp#List.filtr )  > 0 then do:
        Tmp#List.view_ = 0.
      end.
    end.
  end.        /* for each Tmp#List */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame 
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/
open query {&browse-name}
for each Tmp#List no-lock
    where Tmp#List.view_ <> 0
by Tmp#List.blank-name
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-docs Dialog-Frame 
PROCEDURE print-docs :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-type          as character    no-undo.
define variable v-status            as character    no-undo.
define variable v-form-amount       as integer      no-undo.
define variable v-user-action       as character    no-undo.
define variable v-printed           as logical      no-undo.

define buffer buf_fin-doc       for ub.fin-doc.
define buffer buf_t_tmp#list    for tmp#list.
define buffer buf_tmp#list      for tmp#list.
do
for buf_fin-doc
  , buf_t_tmp#list
  , buf_tmp#list
with frame {&frame-name}
on error undo, return error
:

if g#quest-print = yes
then do:
  output  to value( string( session:temp-directory + "$" + string( g#report-num ) ) ) .
  output close.
End.
output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
output close.
output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ) .
output close.
for each temp_form-list
by temp_form-list.fin-doc-code
on error undo, return error
:
  for each buf_tmp#list
      where buf_tmp#list.id = temp_form-list.id
  on error undo, return error
   :
    if buf_tmp#list.last-use <> no
    then do:
      find first buf_t_tmp#list no-lock
            where buf_t_tmp#list.id = temp_form-list.id
      .
      assign
      v-form-amount = v-form-amount + 1
      .
      find first buf_fin-doc
            where buf_fin-doc.host-code = temp_form-list.host-code
            and buf_fin-doc.fin-doc-code = temp_form-list.fin-doc-code
      no-lock.
      assign
      v-doc-type = buf_fin-doc.fin-doc-type
      v-status   = string( buf_fin-doc.status_  )
      .
      assign
      PrintRubl   = ( trim( buf_tmp#list.type-val    ) = "+":U )
      .
      case num-entries( buf_tmp#list.proc-param )
      :
        when 0
        then do:
          run value ( buf_tmp#list.proc-name )  (
                input parparentproc
              , input recid( buf_fin-doc )
            ).
        end.
        when 1
        then do:
          run value ( buf_tmp#list.proc-name ) (
                input parparentproc
              , input recid( buf_fin-doc )
              , input buf_tmp#list.proc-param
            ).
        end.
        when 2
        then do:
          run value ( buf_tmp#list.proc-name )  (
                input parparentproc
              , input recid( buf_fin-doc )
              , input entry( 1, buf_tmp#list.proc-param )
              , input entry( 2, buf_tmp#list.proc-param )
            ).
        end.
        when 3
        then do:
          run value ( buf_tmp#list.proc-name )  (
                input parparentproc
              , input recid( buf_fin-doc )
              , input entry( 1, buf_tmp#list.proc-param )
              , input entry( 2, buf_tmp#list.proc-param )
              , input entry( 3, buf_tmp#list.proc-param )
            ).
        end.
        when 4
        then do:
          run value ( buf_tmp#list.proc-name )  (
                  input parparentproc
                , input recid( buf_fin-doc )
                , input entry( 1, buf_tmp#list.proc-param )
                , input entry( 2, buf_tmp#list.proc-param )
                , input entry( 3, buf_tmp#list.proc-param )
                , input entry( 4, buf_tmp#list.proc-param )
            ).
        end.
        when 5
        then do:
            run value ( buf_tmp#list.proc-name )  (
                  input parparentproc
                , input recid( buf_fin-doc )
                , input entry( 1, buf_tmp#list.proc-param )
                , input entry( 2, buf_tmp#list.proc-param )
                , input entry( 3, buf_tmp#list.proc-param )
                , input entry( 4, buf_tmp#list.proc-param )
                , input entry( 5, buf_tmp#list.proc-param )
            ).
          end.
          when 6
          then do:
              run value ( buf_tmp#list.proc-name )  (
                    input parparentproc
                  , input recid( buf_fin-doc )
                  , input entry( 1, buf_tmp#list.proc-param )
                  , input entry( 2, buf_tmp#list.proc-param )
                  , input entry( 3, buf_tmp#list.proc-param )
                  , input entry( 4, buf_tmp#list.proc-param )
                  , input entry( 5, buf_tmp#list.proc-param )
                  , input entry( 6, buf_tmp#list.proc-param )
              ).
          end.
        end case.
      end.
    end.
  end.        /* for each temp_form-list */
  if g#quest-print = yes
  Then do:
    os-delete  value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) )
      .
    os-rename
        value(  string( session:temp-directory ) + "$" + string( g#report-num ) )
        value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) )
    .
    os-delete
          value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
      .
    os-rename
          value(  string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
          value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
      .
    find first buf_tmp#list
          where buf_tmp#list.last-use = yes
    no-error.
    if available buf_tmp#list
    then do:
      if buf_tmp#list.orient-orientation = "runexcelport":U
      or buf_tmp#list.orient-orientation = "runexcellans":U
      then do:
        os-rename
            value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
            value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".tx_" )
        .
      end.
      case buf_tmp#list.orient-orientation
      :
        when "A4port":U
        or when "runexcelport":U
        then do:
          run gbl/prnfilen.w (
                input "":U
              , input 0
              , input string( session :temp-directory )
                          + {&DF_Name}
                          + string( g#report-num )
              , input buf_tmp#list.orient-font-num
              , output v-user-action
              , output v-printed
          ) .
        end.
        when "A4lans":U
        or when "runexcellans":U
        or when "":U
        then do:
          run gbl/prnfilen.w (
                input "":U
              , input 8
              , input string( session :temp-directory )
                          + {&DF_Name}
                          + string( g#report-num )
              , input buf_tmp#list.orient-font-num
              , output v-user-action
              , output v-printed
          ) .
        end.
      end case.
      if buf_tmp#list.orient-orientation = "runexcelport":U
      or buf_tmp#list.orient-orientation = "runexcellans":U
      then do:
        os-rename
            value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".tx_" )
            value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
        .
      end.
    end.
  end.
  else do:
   Message 'Задание распечатано'.
  end.
end.
END PROCEDURE. /* print-docs */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-browse Dialog-Frame 
PROCEDURE reposition-browse :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
  define variable v-focused-row    as integer      no-undo.
  assign
 v-focused-row     = {&browse-name} :focused-row in frame {&FRAME-NAME}.
  .
  get next {&browse-name}.
  if available tmp#list
  then do:
    if v-focused-row >= {&browse-name} :height-chars - 4
    then do:
      {&browse-name} :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    end.
    else do:
      {&browse-name} :set-repositioned-row( v-focused-row + 1, "ALWAYS" ) in frame {&FRAME-NAME}.
    end.
    reposition {&browse-name} to rowid rowid( tmp#list ) no-error.
  end.
  else do:
    get last {&browse-name}.
  end.
end.
END PROCEDURE. /* reposition-browse */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-to-recid Dialog-Frame 
PROCEDURE reposition-to-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-ext-system-recid  as recid        no-undo.
do
on error undo, return error
:
  if p-ext-system-recid <> ?
  then do:
    reposition br-table to recid p-ext-system-recid no-error .
  end.
  do with frame {&frame-name}
  :
    apply "entry":u to browse {&browse-name} .
  end. /* do with frame */

end.
END PROCEDURE. /* reposition-to-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-form-parameters Dialog-Frame 
PROCEDURE save-form-parameters :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-call-point    as character    no-undo.

define buffer buf_tmp#list          for tmp#list.
define buffer buf_usr-flt           for ubflt.usr-flt.
define buffer buf_temp_form-list    for temp_form-list.
do
for buf_tmp#list
  , buf_usr-flt
  , buf_temp_form-list
on error undo, return error
:
  for each buf_tmp#list
  :
    run get-call-point in this-procedure (
          input buf_tmp#list.id
        , output v-call-point
    ).
    find first buf_usr-flt exclusive-lock
          where buf_usr-flt.user-name  = v-cntxt-userid
            and buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                        , buf_tmp#list.blank-name
                                        , buf_tmp#list.sys-key
                                        , buf_tmp#list.sys-key-black
                                        , v-call-point )
    no-error.
    if not available buf_usr-flt
    then do:
      create buf_usr-flt.
      assign
      buf_usr-flt.user-name  = v-cntxt-userid
      buf_usr-flt.call-point = substitute( "&1,&2,&3,&4"
                                  , buf_tmp#list.blank-name
                                  , buf_tmp#list.sys-key
                                  , buf_tmp#list.sys-key-black
                                  , v-call-point )
      .
    end.
    assign
    buf_usr-flt.list_ = substitute( "selection,&1,type-val,&2":U
                            , ( if buf_tmp#list.last-use = yes then "+":U else "-":U )
                            , ( if index( buf_tmp#list.type-val   , "+":U ) <> 0 then "+":U else "-":U )
                            )
    .
  end.
end.
END PROCEDURE. /* save-form-parameters */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-or-deselect-item Dialog-Frame 
PROCEDURE select-or-deselect-item :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-id as integer    no-undo.

define buffer buf_tmp#list for tmp#list.
do
for buf_tmp#list
on error undo, return error
:
  find first buf_tmp#list
        where buf_tmp#list.id = p-id
  .
  if buf_tmp#list.last-use = yes
  then do:
    assign
    buf_tmp#list.last-use = no
    .
  end.
  else do:
    assign
    buf_tmp#list.last-use = yes
    .
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test-temp-tables Dialog-Frame 
PROCEDURE test-temp-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define buffer buf_t_tmp#list      for tmp#list.
do
for buf_t_tmp#list
on error undo, return error
:
  output to "D:\111.txt".
  for each temp_fin-doc-code no-lock
  :
    put unformatted
    skip substitute( "&1", temp_fin-doc-code.fin-doc-code )
    .
  end.
  put unformatted
  skip "================================================================================"
  .
  for each temp_form-list no-lock
  on error undo, return error
  :
    find first buf_t_tmp#list no-lock
          where buf_t_tmp#list.id = temp_form-list.id
    .
    put unformatted
    skip substitute( "&1 &2 &3 &4 &5 &6", temp_form-list.fin-doc-code, temp_form-list.fin-doc-type, temp_form-list.status_, temp_form-list.id, buf_t_tmp#list.blank-name, buf_t_tmp#list.last-use )
    .
  end.        /* for each temp_form-list */
  put unformatted
  skip "================================================================================"
  .
  for each temp_menu-doc_disabled-doc-list no-lock
  on error undo, return error
  :
    put unformatted
    skip substitute( "&1 &2 &3", temp_menu-doc_disabled-doc-list.fin-doc-code, temp_menu-doc_disabled-doc-list.blank-name, temp_menu-doc_disabled-doc-list.reason )
    .
  end.        /* for each temp_menu-doc_disabled-doc-list */
  output close.
end.
END PROCEDURE. /* test-temp-tables */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-disable-all Dialog-Frame 
PROCEDURE ui-disable-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
/*
    disable
        b-add
        b-del
        b-chg
    with frame {&frame-name} .
*/
end.
END PROCEDURE. /* ui-disable-all */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-enable Dialog-Frame 
PROCEDURE ui-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
  enable
  b-sel
  b-deselect
  with frame {&frame-name} .
  Tmp#List.blank-name:width in browse br-table = 53.
  Tmp#List.blank-name:resizable in browse br-table = yes.
end.
END PROCEDURE. /* ui-enable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

