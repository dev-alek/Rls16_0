&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME    d-units
&Scoped-define FRAME-NAME     d-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-units
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник единиц измерения.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

Created: 10/21/94 - 11:41 pm

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter as-ref as log no-undo.
define output parameter units-rid as recid init ? no-undo.

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник единиц измерения" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */

define variable ri as recid no-undo.
define variable glog as logical no-undo .
define variable mKKT as integer no-undo.
define variable mText as character no-undo.

&scop unit-type-code units.type

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* ********************  Preprocessor Definitions  ******************** */

/* Name of first Frame and/or Browse (alphabetically)                   */
&Scoped-define FRAME-NAME  d-units
&Scoped-define BROWSE-NAME br-units

/* Custom List Definitions                                              */
&Scoped-define LIST-1
&Scoped-define LIST-2
&Scoped-define LIST-3

/* Definitions for BROWSE br-units                                      */
&Scoped-define FIELDS-IN-QUERY-br-units ub.units.unit-name ~
ub.units.long-name ub.units.OKEI~
(IF (ub.units.type = "" ) THEN ("") ELSE ({&unit-type-name} + {&unit-type-name-toplivo})) ~
mKKT mText
&Scoped-define OPEN-QUERY-br-units OPEN QUERY br-units FOR EACH ub.units NO-LOCK.
&Scoped-define FIRST-TABLE-IN-QUERY-br-units ub.units
&Scoped-define TABLES-IN-QUERY-br-units ub.units

/* Definitions for DIALOG-BOX d-units                                   */
&Scoped-define FIELDS-IN-QUERY-d-units
&Scoped-define ENABLED-FIELDS-IN-QUERY-d-units
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-units ~
    ~{&OPEN-QUERY-br-units}

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add-unit
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-change
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-select
     LABEL "Вы&брать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помощь"
     SIZE 10 BY 1 TOOLTIP "Помощь".

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.


/* Query definitions                                                    */
DEFINE QUERY br-units FOR ub.units SCROLLING.

/* Browse definitions                                                   */
DEFINE BROWSE br-units QUERY br-units NO-LOCK DISPLAY
      ub.units.unit-name
      ub.units.long-name FORMAT "X(30)"
      (IF (ub.units.type = "" ) THEN ("") ELSE ({&unit-type-name} + {&unit-type-name-toplivo})) COLUMN-LABEL "Описание типа" FORMAT "x(30)"
      ub.units.type FORMAT "X(12)"
      ub.units.OKEI COLUMn-LABEL "Код!ОКЕИ" format "9999"
      mKKT COLUMN-LABEL "Код!ККТ" FORMAT ">>>>9"
      mText COLUMN-LABEL "Текст!в чеке ККТ" FORMAT "X(10)"
    WITH SEPARATORS
          &IF '{&WINDOW-SYSTEM}' = 'TTY':U &THEN SIZE 69 BY 13
          &ELSE size 86.25 by 12.58 &ENDIF
         .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-units
     br-units at row 2.5 col 3
     b-exit at row 1 col 1
     b-select at row 1 col 11
     b-add-unit at row 1 col 21
     b-change at row 1 col 31
     B-hist AT ROW 1 COL 41
     b-help at row 1 col 61
    WITH VIEW-AS DIALOG-BOX
         SIDE-LABELS THREE-D
         SCROLLABLE size 91.88 by 16.25
         TITLE "ЕДИНИЦЫ  ИЗМЕРЕНИЯ":L.




/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-units
   UNDERLINE                                                            */
ASSIGN
       FRAME d-units:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-add-unit IN FRAME d-units
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-select IN FRAME d-units
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-help IN FRAME d-units
   NO-DISPLAY                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-units
/* Query rebuild information for BROWSE br-units
     _TblList          = "ub.units"
     _Options          = "NO-LOCK"
     _OrdList          = ""
     _FldNameList[1]   = ub.units.unit-name
     _FldNameList[2]   = ub.units.long-name
     _FldFormatList[2] = "X(30)"
     _FldNameList[3]   = "(IF (ub.units.type = """" ) THEN ("""") ELSE ({&unit-type-name}))"
     _FldLabelList[3]  = "Тип"
     _FldFormatList[3] = "x(30)"
     _FldNameList[4]   > "_<CALC>"
"mKKT" "Calc" ">>>>>" ? ? ? ? ? ? ? no ? no no "15" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"mText" "Calc" "x(12)" ? ? ? ? ? ? ? no ? no no "20" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-units */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */
&Scoped-define BROWSE-NAME br-units
&Scoped-define SELF-NAME br-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-units d-units
ON ROW-DISPLAY OF br-units IN FRAME d-units
DO:
   define buffer code for code.
   assign
      mKKT  = 255
      mText = "-".
   find first code where
              code.parent = "okei-kkt"
          and int(code.code)  = units.OKEI
          and code.status_ = 0 
   no-lock no-error.
   if avail code then
      assign
         mKKT  = integer(code.CodeName)
         mText = code.misc1
         mKKT:bgcolor  in browse br-units = 10
         mText:bgcolor in browse br-units = 10
         .
   else
      assign
         mKKT:bgcolor  in browse br-units = 14
         mText:bgcolor in browse br-units = 14
        .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-add-unit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-unit d-units
ON CHOOSE OF b-add-unit IN FRAME d-units /* Добавить */
DO:
{ gbl/chk-actg.i
ibs.th.gbl.gbl-var:g#db-num  
ibs.th.gbl.gbl-var:g#userid  
{&action-head-code-main}
'actn_unit_update':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply .
ri = ?.
run ref/unitsi.w (
                input parparentproc
              , input {&add-def}
              , "":U
              , input-output ri).
if ri <> ? then  do:
    OPEN QUERY br-units FOR EACH ub.units NO-LOCK.
    reposition br-units to recid ri.
    apply "ENTRY" to br-units.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-change
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-change d-units
ON CHOOSE OF b-change IN FRAME d-units /* Изменить */
DO:
{ gbl/chk-actg.i
ibs.th.gbl.gbl-var:g#db-num  
ibs.th.gbl.gbl-var:g#userid  
{&action-head-code-main}
'actn_unit_update':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then  return no-apply .
if available ub.units then  do:
  ri = recid( units ) .
  run ref/unitsi.w (
                input parparentproc
              , input {&update}
              , units.unit-name
              , input-output ri ).
  OPEN QUERY br-units FOR EACH ub.units NO-LOCK.
  reposition br-units to recid ri.
  apply "ENTRY" to br-units.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist d-units
ON CHOOSE OF B-hist IN FRAME d-units /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-undo.
    IF AVAILABLE ub.units THEN DO:
      run ref/c-units.w (
                     INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'one':U
                    ,INPUT units.unit-name
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b-select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-select d-units
ON CHOOSE OF b-select IN FRAME d-units /* Выбрать */
DO:
    if available ub.units then
        do:
            units-rid = recid( units).
            apply  "GO" to FRAME {&FRAME-NAME}.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-units
&Scoped-define SELF-NAME br-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-units d-units
ON DEFAULT-ACTION OF br-units IN FRAME d-units
DO:
    if as-ref then
        do:
                apply "CHOOSE":U to b-select.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-units d-units
ON RETURN OF br-units IN FRAME d-units
DO:
    if as-ref then
        do:
                apply "CHOOSE":U to b-select.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-units


/* ***************************  Main Block  *************************** */

/* Restore the current-window if it is an icon.                         */
/* Otherwise the dialog box will be hidden                              */
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
 { gbl/getcntxt.i get }
  RUN enable_UI.

  if available units then
      glog = br-units:select-focused-row( ).

do  on endkey undo, leave  on error undo, leave:
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-units _DEFAULT-DISABLE
PROCEDURE disable_UI :
/* --------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
   -------------------------------------------------------------------- */
  /* Hide all frames. */
  HIDE FRAME d-units.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-units
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
    b-select:visible   IN FRAME {&frame-name} = as-ref .
    b-add-unit:visible IN FRAME {&frame-name} = ( not as-ref ) AND ibs.th.gbl.gbl-var:g#db-num = 0 .
    b-change:visible   In FRAME {&frame-name} = b-add-unit:visible IN FRAME {&frame-name} .
    ENABLE  br-units b-exit
                    b-select    WHEN b-select:visible
                    b-help     WHEN b-help:visible
                    b-add-unit WHEN b-add-unit:visible
                    b-change WHEN b-change:visible
                    b-hist
        WITH FRAME d-units.
    {&OPEN-BROWSERS-IN-QUERY-d-units}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE BROWSE-NAME
&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME