&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE x_thbj-attr NO-UNDO LIKE ub.thbj-attr
       field ind1 as char
       field p1 as char
       field d1 as char
       index pi ind1
       .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр Параметров по всем объектам для thbjattr

Автор: Чернова Светлана Александровна
Дата создания: 07/02/08
Author: Svetlana Chernova
Creation date: 07/02/08

*/
define input  parameter p-upper-code as character no-undo .
define input  parameter p-code       as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр Параметров по всем объектам для thbjattr".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }

/*------------------------------------------------------------------------

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
define variable v-host-code as integer   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x_thbj-attr

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 X_thbj-attr.p1 X_thbj-attr.obj-type X_thbj-attr.obj-code X_thbj-attr.d1
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH x_thbj-attr  NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY {&SELF-NAME} FOR EACH x_thbj-attr  NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 x_thbj-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 x_thbj-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Help v-info BROWSE-2
&Scoped-Define DISPLAYED-OBJECTS v-info

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-info AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 62.38 BY 3.33 TOOLTIP "Справочная информация о параметре" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      x_thbj-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _FREEFORM
  QUERY BROWSE-2 NO-LOCK DISPLAY
      X_thbj-attr.p1 FORMAT "X(9)":U COLUMN-LABEL "Уровень"
      X_thbj-attr.obj-type FORMAT "X(3)":U
      X_thbj-attr.obj-code FORMAT ">>>>>>>>>":U COLUMN-LABEL "Код"
      X_thbj-attr.d1  COLUMN-LABEL "Значение" FORMAT "x(100)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 65.5 BY 12.25 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Help AT ROW 1 COL 65
     v-info AT ROW 2 COL 1.88 NO-LABEL WIDGET-ID 6
     BROWSE-2 AT ROW 5.5 COL 1.75 WIDGET-ID 200
     SPACE(1.12) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: x_thbj-attr T "?" NO-UNDO ub thbj-attr
      ADDITIONAL-FIELDS:
          field ind1 as char
          field p1 as char
          field d1 as char
          index pi ind1

      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 v-info Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       v-info:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x_thbj-attr  NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Help */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
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


run thbjattr_tooltip in this-procedure (
   input  p-upper-code
  ,input  p-code
  ,output v-tooltip
  ,output v-label
  ,output v-tooltip-code
  ) no-error .

 frame {&frame-name}:title = entry( 2 ,v-label, ":" ) no-error .
 if error-status :error then frame {&frame-name}:title = v-label .

 v-info =  REPLACE ( v-tooltip-code , "`" , "," ) .
 display v-info with frame {&frame-name} .

  run init-tt in this-procedure .
  run enable_ui in this-procedure .
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
  DISPLAY v-info
      WITH FRAME Dialog-Frame.
  ENABLE B-Help v-info BROWSE-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame
PROCEDURE init-tt :

define buffer buf_thbj-attr for ub.thbj-attr .
empty TEMP-TABLE  x_thbj-attr .


for each buf_thbj-attr no-lock where
         buf_thbj-attr.upper-prop-code = p-upper-code and
         buf_thbj-attr.prop-code       = p-code and
         buf_thbj-attr.prop-code <> "" Break by buf_thbj-attr.obj-type by buf_thbj-attr.obj-code :
   find first x_thbj-attr where
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type and
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code no-error .

        if not available x_thbj-attr then do:
          create  x_thbj-attr.
          assign
              x_thbj-attr.obj-type = buf_thbj-attr.obj-type
              x_thbj-attr.obj-code = buf_thbj-attr.obj-code
          .
        end.

       if buf_thbj-attr.obj-type  = "" then
        assign
          x_thbj-attr.p1 = "глобально"
          x_thbj-attr.ind1 =  "0" + string( 0,"999999999") + "   " + string( 0 ,"999999999" )
        .
       if buf_thbj-attr.obj-type  = {&cmp} then
        assign
          x_thbj-attr.p1 = "фирма"
          x_thbj-attr.ind1 =  "0" + string(buf_thbj-attr.obj-code,"999999999") + "   " + string( 0 ,"999999999" )
        .
       if buf_thbj-attr.obj-type  <> {&cmp} and buf_thbj-attr.obj-type  <> ""
       and buf_thbj-attr.obj-type <> {&db}
       then do:
        assign
          x_thbj-attr.p1 = " объект"
        .
        { gbl/hostcode.i
          buf_thbj-attr.obj-type
          buf_thbj-attr.obj-code
          v-host-code
          }
         x_thbj-attr.ind1 =  "0" + string(v-host-code,"999999999") + buf_thbj-attr.obj-type + string(buf_thbj-attr.obj-code ,"999999999" ).
       end.
       if buf_thbj-attr.obj-type = {&db} then do:
        assign
          x_thbj-attr.p1 = " БД"
          x_thbj-attr.ind1 = "0" + string( buf_thbj-attr.obj-code,":999999999") + "   " + string( 0 ,"999999999" ).
       end.
       case buf_thbj-attr.prop-value-type :
       when {&ABL-datatype-character} then do:
            if      buf_thbj-attr.upper-prop-code eq "gismt"
            and (   buf_thbj-attr.prop-code eq "oflinepswd"
                 or buf_thbj-attr.prop-code eq "proxypswd"
                 or buf_thbj-attr.prop-code eq "MaxApiToken")
            then
               x_thbj-attr.d1 = fill("*",length (buf_thbj-attr.property-value-character)).
             else
                x_thbj-attr.d1 = buf_thbj-attr.property-value-character.
       end.
       when {&ABL-datatype-integer} then
            assign
             x_thbj-attr.d1 = string(buf_thbj-attr.property-value-integer)
            .
       when {&ABL-datatype-decimal} then
            assign
             x_thbj-attr.d1 = string(buf_thbj-attr.property-value-decimal)
            .
       when {&ABL-datatype-logical} then
            assign
             x_thbj-attr.d1 = string(buf_thbj-attr.property-value-logical,"да/нет")
            .

       when {&ABL-datatype-date} then do:
            assign
             x_thbj-attr.d1 = string(buf_thbj-attr.property-value-date, "99/99/9999" )
            .
            if  x_thbj-attr.d1 = ? then x_thbj-attr.d1 = "" .
            end.

       end case.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME