&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сравнительный отчет по ценам товара на объектах (закладка № 2)

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сравнительный отчет по ценам товара на объектах (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
define variable rserv as char init "all" no-undo .
define variable print-o as char init "" no-undo .

define variable Obj1-list  as character no-undo .
define variable Obj2-list  as character no-undo .

/*def input parameter Itog as logical init FALSE no-undo .*/

{ cmp/r-page1.i }
{ cmp/str-glbl.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 RECT-8 COMBO-Firm SortType sort-grp
&Scoped-Define DISPLAYED-OBJECTS COMBO-Firm SortType sort-grp

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE COMBO-Firm AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEMS "?"
     DROP-DOWN-LIST
     SIZE 69.5 BY 1 NO-UNDO.

DEFINE VARIABLE SortType AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", 1,
"по артикулу", 2,
"по наименованию", 3
     SIZE 23.38 BY 3.75 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 73.25 BY 16.04.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 28.25 BY 7.67.

DEFINE VARIABLE sort-grp AS LOGICAL INITIAL no
     LABEL "по группам"
     VIEW-AS TOGGLE-BOX
     SIZE 19.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     COMBO-Firm AT ROW 3.13 COL 2.13 COLON-ALIGNED NO-LABEL
     SortType AT ROW 7.88 COL 5.88 NO-LABEL
     sort-grp AT ROW 12.29 COL 6
     "Сортировка :" VIEW-AS TEXT
          SIZE 24.25 BY 1 AT ROW 6.58 COL 5.38
          FGCOLOR 4
     "Фирмы - посредники :" VIEW-AS TEXT
          SIZE 39.75 BY 1 AT ROW 1.83 COL 3.63
          FGCOLOR 4
     RECT-7 AT ROW 1.21 COL 2.38
     RECT-8 AT ROW 5.75 COL 3.63
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.88
         WIDTH              = 76.13.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF
define variable temp-string as character no-undo .
define variable str as character no-undo .
temp-string = "".

for each ub.sysconf where ub.sysconf.avrg-price = yes no-lock :
 find first ub.clients where ub.clients.obj-code = ub.sysconf.host-code and ub.clients.obj-type = {&cmp} no-error .
 IF temp-string = "" THEN do:
   assign
     temp-string = string(ub.sysconf.host-code,">>>>9") + " " + ub.clients.obj-name
     str = temp-string
   .
 end.
 ELSE temp-string = temp-string + "," + string(ub.sysconf.host-code,">>>>9") + " " + ub.clients.obj-name.
END.

ASSIGN COMBO-Firm:LIST-ITEMS IN FRAME {&frame-name} = temp-string.
ASSIGN COMBO-Firm:SCREEN-VALUE = str.

ENABLE COMBO-Firm WITH FRAME {&frame-name}.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
define variable h-code as integer   no-undo .
  h-code = int(substr(str3,1,6)) .
  run cus/r-z-posr.p ( h-code, SortType, sort-grp) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

  Assign frame {&frame-name}  COMBO-Firm SortType sort-grp.

  /*строки в которых содержатся выбранные объекты */
  Assign
    STR-obj-type = ''
    STR-obj-code = ''
    STR-obj-name = ''
    STR-obj      = ''
  .

  For each obj-list no-lock:
    Assign
      STR-obj-type = STR-obj-type + obj-list.obj-type + ','
      STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
      STR-obj-name = STR-obj-name + obj-list.obj-name + ','
      STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ','
    .
  End.
  assign
/*    str1 = "Сравнительный отчет по ценам товара на объектах на " + String(TODAY,"99/99/9999")*/
    str2 = "Фирма-посредник: " + COMBO-Firm:screen-value
    str3 = COMBO-Firm:screen-value
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
    when "link-changed":U then  DO:
         Run my-var.
         End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
