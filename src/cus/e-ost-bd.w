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

Отчет Остатки по УБД (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 12/11/08
Author: Svetlana Chernova
Creation date: 12/11/08

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Остатки по УБД (закладка № 2)".
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
define variable g#userid as character no-undo .

/*def input parameter Itog as logical init FALSE no-undo .*/

{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }


DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-5 RECT-7 TOGGLE-1 RADIO-SET-1 ~
RADIO-SET-2
&Scoped-Define DISPLAYED-OBJECTS TOGGLE-1 FILL-IN-3 TOGGLE-2 RADIO-SET-1 ~
RADIO-SET-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE FILL-IN-3 AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5.25 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет", 1,
"Выборочно", 2
     SIZE 23.88 BY 1.96 NO-UNDO.

DEFINE VARIABLE RADIO-SET-2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет", 1,
"Выборочно", 2
     SIZE 23.88 BY 1.96 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 49 BY 4.42.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 49 BY 4.42.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.38 BY 5.21.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 17.38 BY .83 NO-UNDO.

DEFINE VARIABLE TOGGLE-2 AS LOGICAL INITIAL no
     LABEL "по группам с уровня"
     VIEW-AS TOGGLE-BOX
     SIZE 23.63 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     TOGGLE-1 AT ROW 3.63 COL 3.75
     FILL-IN-3 AT ROW 4.54 COL 26.5 COLON-ALIGNED NO-LABEL
     TOGGLE-2 AT ROW 4.71 COL 3.63
     RADIO-SET-1 AT ROW 9.21 COL 5.25 NO-LABEL
     RADIO-SET-2 AT ROW 14.08 COL 5.25 NO-LABEL
     "Объекты, показываемые отдельно от всех БД:" VIEW-AS TEXT
          SIZE 44.63 BY 1.17 AT ROW 12.46 COL 3.75
          FGCOLOR 4
     "Просмотр :" VIEW-AS TEXT
          SIZE 26.88 BY 1 AT ROW 1.83 COL 3.63
          FGCOLOR 4
     "Объекты, показываемые отдельно от своей БД:" VIEW-AS TEXT
          SIZE 44.63 BY 1.17 AT ROW 7.58 COL 3.38
          FGCOLOR 4
     RECT-6 AT ROW 12 COL 2
     RECT-5 AT ROW 7.13 COL 2
     RECT-7 AT ROW 1.21 COL 2.38
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

/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX TOGGLE-2 IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 s-object
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME F-Main
DO:
  assign RADIO-SET-1 .
  assign Obj1-list = "" .
  if RADIO-SET-1 = 2 then do:
    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      my-handle
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true then do:
      assign RADIO-SET-1 = 1 .
      display RADIO-SET-1 with frame {&FRAME-NAME} .
    end.
    else do:
      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
      for each buf_userobjs_temp-user-obj :
        if Obj1-list = "" then
          assign  Obj1-list = Obj1-list + buf_userobjs_temp-user-obj.obj-type + "," + string(buf_userobjs_temp-user-obj.obj-code) .
        else
          assign  Obj1-list = Obj1-list + "," + buf_userobjs_temp-user-obj.obj-type + "," + string(buf_userobjs_temp-user-obj.obj-code) .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-2 s-object
ON VALUE-CHANGED OF RADIO-SET-2 IN FRAME F-Main
DO:
  assign RADIO-SET-2 .
  assign Obj2-list = "" .
  if RADIO-SET-2 = 2 then do:
    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      my-handle
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true then do:
      assign RADIO-SET-2 = 1 .
      display RADIO-SET-2 with frame {&FRAME-NAME} .
    end.
    else do:
      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
      for each buf_userobjs_temp-user-obj :
        if Obj2-list = "" then
          assign  Obj2-list = Obj2-list + buf_userobjs_temp-user-obj.obj-type + "," + string(buf_userobjs_temp-user-obj.obj-code) .
        else
          assign  Obj2-list = Obj2-list + "," + buf_userobjs_temp-user-obj.obj-type + "," + string(buf_userobjs_temp-user-obj.obj-code) .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOGGLE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOGGLE-1 s-object
ON VALUE-CHANGED OF TOGGLE-1 IN FRAME F-Main /* Только итоги */
DO:
  assign TOGGLE-1 .
  if TOGGLE-1 = yes then ENABLE  TOGGLE-2 FILL-IN-3 WITH FRAME F-Main.
  else                   DISABLE TOGGLE-2 FILL-IN-3 WITH FRAME F-Main.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
{ gbl/getcntxt.i get }
/* If testing in the UIB, initialize the SmartObject. */
    run get-userid  in parParentProc ( output g#userid ).

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

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
define variable lavel as integer no-undo .

  if TOGGLE-2 = yes then assign lavel = FILL-IN-3 .
  else                   assign lavel = -1 .

  run cus/r-ost-bd.p (RADIO-SET-1, Obj1-list, RADIO-SET-2, Obj2-list, TOGGLE-1, lavel ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

  Assign frame {&frame-name} RADIO-SET-1 RADIO-SET-2 TOGGLE-1 TOGGLE-2 FILL-IN-3 .

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
    str1 = "Остатки по УБД на " + String(x-date-start,"99/99/9999")
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