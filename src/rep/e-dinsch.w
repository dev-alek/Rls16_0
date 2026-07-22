/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Динамика финансового движени (закладка № 2)

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет Динамика финансового движени  (закладка № 2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var State-source as  WIDGET-HANDLE.
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/r-page1.i }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
def var cli-list as char no-undo.

ASSIGN parParentProc =  my-handle .

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

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
&Scoped-Define ENABLED-OBJECTS RECT-6 sort-1 sort-2 sort-3 sort-4
&Scoped-Define DISPLAYED-OBJECTS sort-1 sort-2 sort-3 sort-4

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE sort-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень 1"
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEMS "Дата документа","Корреспондирующий счет","Шифр аналитического учета","Шифр целевого назначения"
     DROP-DOWN-LIST
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE sort-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень 2"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "","Дата документа","Корреспондирующий счет","Шифр аналитического учета","Шифр целевого назначения"
     DROP-DOWN-LIST
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE sort-3 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень 3"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "","Дата документа","Корреспондирующий счет","Шифр аналитического учета","Шифр целевого назначения"
     DROP-DOWN-LIST
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE VARIABLE sort-4 AS CHARACTER FORMAT "X(256)":U
     LABEL "Уровень 4"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "","Дата документа","Корреспондирующий счет","Шифр аналитического учета","Шифр целевого назначения"
     DROP-DOWN-LIST
     SIZE 27.63 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.5 BY 8.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     sort-1 AT ROW 3 COL 12.5 COLON-ALIGNED
     sort-2 AT ROW 4.5 COL 12.5 COLON-ALIGNED
     sort-3 AT ROW 6 COL 12.5 COLON-ALIGNED
     sort-4 AT ROW 7.5 COL 12.5 COLON-ALIGNED
     "Сортировка:" VIEW-AS TEXT
          SIZE 13.25 BY 1 AT ROW 1.63 COL 4.13
          FGCOLOR 4
     RECT-6 AT ROW 1.25 COL 2.25
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

  assign sort-1:screen-value = "Дата документа" .
  display sort-1  with frame {&FRAME-NAME} .

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
/*run r-curfin.p (input p-radio-schet, input p-curr-code, input RADIO-sort) .*/
  define variable code-schet as integer   no-undo .
  assign  code-schet = int(fin-schet-recid) .
  if code-schet = 0 then do:
    message "Не выбран счет!" view-as alert-box error .
    return no-apply .
  end.

  define variable num-key as integer initial 1  no-undo .
  define variable str as character no-undo .

  case sort-1 :
    when "Дата документа"            then assign str = "buf_fin-doc.doc-date"      .
    when "Корреспондирующий счет"    then assign str = "buf_fin-doc.cor-acc"  .
    when "Шифр аналитического учета" then assign str = "buf_fin-doc.an-uchet-code" .
    when "Шифр целевого назначения"  then assign str = "buf_fin-doc.cel-nazn-code" .
  end.

  if sort-2 = sort-1 then assign sort-2 = "" .
  case sort-2 :
    when "Дата документа"            then assign str = str + ",buf_fin-doc.doc-date"      num-key = num-key + 1 .
    when "Корреспондирующий счет"    then assign str = str + ",buf_fin-doc.cor-acc"       num-key = num-key + 1 .
    when "Шифр аналитического учета" then assign str = str + ",buf_fin-doc.an-uchet-code" num-key = num-key + 1 .
    when "Шифр целевого назначения"  then assign str = str + ",buf_fin-doc.cel-nazn-code" num-key = num-key + 1 .
  end.

  if sort-3 = sort-2 then assign sort-3 = "" .
  else  if sort-3 = sort-1 then assign sort-3 = "" .
  case sort-3 :
    when "Дата документа"            then assign str = str + ",buf_fin-doc.doc-date"      num-key = num-key + 1 .
    when "Корреспондирующий счет"    then assign str = str + ",buf_fin-doc.cor-acc"       num-key = num-key + 1 .
    when "Шифр аналитического учета" then assign str = str + ",buf_fin-doc.an-uchet-code" num-key = num-key + 1 .
    when "Шифр целевого назначения"  then assign str = str + ",buf_fin-doc.cel-nazn-code" num-key = num-key + 1 .
  end.

  if sort-4 = sort-1 then assign sort-4 = "" .
  else do:
    if sort-4 = sort-2 then assign sort-4 = "" .
    else  if sort-4 = sort-3 then assign sort-4 = "" .
  end.
  case sort-4 :
    when "Дата документа"            then assign str = str + ",buf_fin-doc.doc-date"      num-key = num-key + 1 .
    when "Корреспондирующий счет"    then assign str = str + ",buf_fin-doc.cor-acc"       num-key = num-key + 1 .
    when "Шифр аналитического учета" then assign str = str + ",buf_fin-doc.an-uchet-code" num-key = num-key + 1 .
    when "Шифр целевого назначения"  then assign str = str + ",buf_fin-doc.cel-nazn-code" num-key = num-key + 1 .
  end.

  run rep/r-dinsch.p ( input parParentProc, input v-cntxt-host-code-obj, input code-schet, input num-key, input str, input x-Date-Start, input x-Date-End) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

 assign frame {&frame-name} sort-1 sort-2 sort-3 sort-4 .

/*  find first clients no-lock where clients.obj-type = {&cmp} and clients.obj-code = v-cntxt-host-code-obj .*/
/*  assign*/
/*    ReportNAme = "Состояние финансов на " + string(x-Date-Start,"99/99/9999") + "г.".*/
/*    str1 = "Фирма: " + clients.obj-name .*/
/*  .*/
END PROCEDURE.
{ rep/varfpage.i }

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