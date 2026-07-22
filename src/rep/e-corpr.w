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

Объединенные документы возврата поставщику и прихода для смены типа приобретени  (закладка № 2)

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Объединенные документы возврата поставщику и прихода для смены типа приобретени  (закладка № 2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEF BUFFER supplier FOR ub.clients.

/*def input parameter Itog as logical init FALSE no-undo .*/

  { cmp/str-glbl.i }
{ cmp/r-page1.i }
  { cmp/showinf.i }

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
&Scoped-Define ENABLED-OBJECTS RECT-8 RECT-5 RECT-6 RECT-7 r-cli ~
FILL-cli-code COMBO-cli-type FILL-num sort-name RADIO-SET-1 sort-gr
&Scoped-Define DISPLAYED-OBJECTS FILL-cli-code COMBO-cli-type FILL-cli-name ~
FILL-num sort-name RADIO-SET-1 sort-gr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3.5 BY 1.08.

DEFINE VARIABLE COMBO-cli-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "орг","чел","скл","маг"
     DROP-DOWN-LIST
     SIZE 7.63 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-cli-code AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "&Поставщик"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-cli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35.13 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-num AS CHARACTER FORMAT "X(256)":U
     LABEL "Номер &документа"
     VIEW-AS FILL-IN
     SIZE 26.38 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Возврат поставщику ТОРГ-12", 1,
"Приход ТОРГ-12", 2,
"Приход Счет-фактура", 3
     SIZE 32.13 BY 3.5 NO-UNDO.

DEFINE VARIABLE sort-name AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по наименованию", 1,
"по коду", 2,
"по артикулу", 3
     SIZE 32.13 BY 3.5 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.88 BY 6.25.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.88 BY 6.21.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.75 BY 4.13.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.88 BY 3.17.

DEFINE VARIABLE sort-gr AS LOGICAL INITIAL no
     LABEL "По группам"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     r-cli AT ROW 1.75 COL 4
     FILL-cli-code AT ROW 1.79 COL 17.13 COLON-ALIGNED
     COMBO-cli-type AT ROW 1.79 COL 29.88 COLON-ALIGNED NO-LABEL
     FILL-cli-name AT ROW 1.79 COL 38.63 COLON-ALIGNED NO-LABEL
     FILL-num AT ROW 3.5 COL 19.38 COLON-ALIGNED
     sort-name AT ROW 7.79 COL 41.63 NO-LABEL
     RADIO-SET-1 AT ROW 7.88 COL 4.88 NO-LABEL
     sort-gr AT ROW 14.17 COL 5.25
     "Сортировка :" VIEW-AS TEXT
          SIZE 19.13 BY 1.17 AT ROW 6.08 COL 41.75
          FGCOLOR 4
     "Печать документа:" VIEW-AS TEXT
          SIZE 33 BY 1.17 AT ROW 6.13 COL 4.25
          FGCOLOR 4
     "Классификация :" VIEW-AS TEXT
          SIZE 22.63 BY 1.17 AT ROW 12.67 COL 4.5
          FGCOLOR 4
     RECT-8 AT ROW 12.17 COL 1.88
     RECT-5 AT ROW 5.63 COL 2
     RECT-6 AT ROW 5.63 COL 40.13
     RECT-7 AT ROW 1 COL 1.88
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

/* SETTINGS FOR FILL-IN FILL-cli-name IN FRAME F-Main
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

&Scoped-define SELF-NAME COMBO-cli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL COMBO-cli-type s-object
ON LEAVE OF COMBO-cli-type IN FRAME F-Main
DO:
  ASSIGN COMBO-cli-type.
  FIND supplier NO-LOCK WHERE supplier.obj-type = COMBO-cli-type AND supplier.obj-code = FILL-cli-code NO-ERROR.
  ASSIGN FILL-cli-name = ( IF AVAIL supplier THEN supplier.obj-name ELSE "":U ).
  DISP   FILL-cli-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL COMBO-cli-type s-object
ON VALUE-CHANGED OF COMBO-cli-type IN FRAME F-Main
DO:
  ASSIGN COMBO-cli-type.
  FIND supplier NO-LOCK WHERE supplier.obj-type = COMBO-cli-type AND supplier.obj-code = FILL-cli-code NO-ERROR.
  ASSIGN FILL-cli-name = ( IF AVAIL supplier THEN supplier.obj-name ELSE "":U ).
  DISP   FILL-cli-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FILL-cli-code s-object
ON LEAVE OF FILL-cli-code IN FRAME F-Main /* Поставщик */
DO:
  ASSIGN FILL-cli-code.
  FIND supplier NO-LOCK WHERE supplier.obj-type = COMBO-cli-type AND supplier.obj-code = FILL-cli-code NO-ERROR.
  ASSIGN FILL-cli-name = ( IF AVAIL supplier THEN supplier.obj-name ELSE "":U ).
  DISP   FILL-cli-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli s-object
ON CHOOSE OF r-cli IN FRAME F-Main /* r-cli */
DO:
  DEF VAR v_rid-list AS CHAR NO-UNDO.

  run ref/cli-all.w (parParentProc
                 , INPUT "b-sel"
                 , {&pro}
                 , {&all}
                 , {&current}
                 , ( IF AVAIL supplier THEN RECID( supplier ) ELSE ? )
                 , ",,,,,,NO,,"
                 ,?
  , OUTPUT v_rid-list ).
  FIND supplier NO-LOCK WHERE RECID( supplier ) = INT( v_rid-list ) NO-ERROR.
  IF AVAIL supplier THEN DO:
    ASSIGN FILL-cli-code  = supplier.obj-code
           COMBO-cli-type = supplier.obj-type
           FILL-cli-name  = supplier.obj-name.
  END.              ELSE DO:
    ASSIGN FILL-cli-name  = "":U
           FILL-cli-code  = 0
           COMBO-cli-type = {&cmp}.
  END.
  DISP COMBO-cli-type FILL-cli-code FILL-cli-name WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

ASSIGN COMBO-cli-type = {&cmp}.
DISP   COMBO-cli-type WITH FRAME {&FRAME-NAME}.

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
find first supplier no-lock where supplier.obj-code = FILL-cli-code and supplier.obj-type = COMBO-cli-type no-error.
  if avail supplier then do:
    case RADIO-SET-1 :
      when 1 then run rep/r-corpr1.p ( my-handle, COMBO-cli-type, FILL-cli-code, FILL-num, sort-name, sort-gr, yes ) .
      when 2 then run rep/r-corpr1.p ( my-handle, COMBO-cli-type, FILL-cli-code, FILL-num, sort-name, sort-gr, no ) .
      when 3 then run rep/r-corpr2.p ( COMBO-cli-type, FILL-cli-code, FILL-num, sort-name, sort-gr, ? ) .
    end.
  end.
  else  message  "Поставщик не выбран!" view-as alert-box.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

  Assign frame {&frame-name} COMBO-cli-type FILL-cli-code FILL-num RADIO-SET-1 sort-name sort-gr .

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