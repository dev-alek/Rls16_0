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

Отчет поставки алкогольной продукции XML (ЗАКЛАДКА №2)

Автор: Хныкин Павел Андреевич
Дата создания: 05/08/08
Author: Pavel Khnykin
Creation date: 05/08/08

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет поставки алкогольной продукции (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i   }
{ gbl/filelist.i  }
{ gbl/getcntxt.i def " " my-handle }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.



define variable loc-ref-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 fi-dir-full-name b-sel-dir tg-zip
&Scoped-Define DISPLAYED-OBJECTS fi-dir-full-name tg-zip

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-sel-dir DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     size 2.5 by 1.08.

DEFINE VARIABLE fi-dir-full-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория вывода"
     VIEW-AS FILL-IN
     SIZE 33.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-7
     edge-chars 0.25 GRAPHIC-EDGE  NO-FILL
     SIZE 71.38 BY 16.25.

DEFINE VARIABLE tg-zip AS LOGICAL INITIAL no
     LABEL "Упаковывать отчет в zip архив"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     fi-dir-full-name AT ROW 3 COL 20 COLON-ALIGNED
     b-sel-dir at row 3 col 56
     tg-zip AT ROW 5 COL 3
     RECT-7 AT ROW 1.25 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.75
         WIDTH              = 73.
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
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       fi-dir-full-name:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME b-sel-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-dir s-object
ON CHOOSE OF b-sel-dir IN FRAME F-Main
DO:

define variable v-dir-name  as character no-undo .
define variable v-dir-type  as character no-undo .
define variable v-can-write as logical   no-undo .

define buffer buf_temp-filelist for temp-filelist .

  do on error undo, return no-apply :

  end.

  run gbl/dir-sel.p ( output v-dir-name
                    , output v-dir-type
                    , output v-can-write
                    ) .
  if v-dir-name = "" or v-dir-name = ? then return no-apply.
  if v-can-write <> yes then do :
    message
      "Выбранная директория не доступна для записи, выберите другую директорию."
    view-as alert-box error.
    return no-apply.
  end.
  run filelist-init in this-procedure ( input v-dir-name
                                      , input yes
                                      , input "xml,zip":U
                                      , input ?
                                      ) .
  find first buf_temp-filelist no-lock no-error .
  if available buf_temp-filelist then do:
    message
      "В директории присутствуют XML или ZIP файлы." skip
      "Для формирования отчета необходимо указать пустую директорию."
    view-as alert-box error.
    return no-apply.
  end.



  assign
    fi-dir-full-name = v-dir-name
  .
  display
    fi-dir-full-name
  with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */

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
  assign
    tg-zip = yes
  .
  display
    tg-zip
  with frame {&frame-name}.
  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
  define buffer buf_usr-flt for ubflt.usr-flt .

  { gbl/getcntxt.i get " " my-handle }

  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  find first buf_usr-flt no-lock
    where buf_usr-flt.user-name  = v-cntxt-userid
      and buf_usr-flt.call-point = "rep/e-alcxml.w":U
  no-error .
  if available buf_usr-flt then do:
    assign
      tg-zip           = logical( entry( 1, buf_usr-flt.list_) )
      fi-dir-full-name = entry( 2 , buf_usr-flt.list_ )
    .
    display
      tg-zip
      fi-dir-full-name
    with frame {&frame-name} .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
  define buffer buf_usr-flt for ubflt.usr-flt .
  define buffer buf_temp-filelist for temp-filelist .

  run filelist-init in this-procedure ( input fi-dir-full-name
                                      , input yes
                                      , input "xml,zip":U
                                      , input ?
                                      ) .
  find first buf_temp-filelist no-lock no-error .
  if available buf_temp-filelist then do:
    message
      "В директории присутствуют XML или ZIP файлы." skip
      "Для формирования отчета необходимо указать пустую директорию."
    view-as alert-box error.
    return .
  end.

  find first buf_usr-flt exclusive-lock
    where buf_usr-flt.user-name  = v-cntxt-userid
      and buf_usr-flt.call-point = "rep/e-alcxml.w":U
  no-error .
  if not available buf_usr-flt then do:
    create buf_usr-flt .
    assign
      buf_usr-flt.user-name  = v-cntxt-userid
      buf_usr-flt.call-point = "rep/e-alcxml.w":U
    .
  end.
  assign
    buf_usr-flt.list_ = substitute( "&1,&2"
                                  , string(tg-zip)
                                  , fi-dir-full-name
                                  )
  .
  run rep/alcxml01.p ( input my-handle
                     , input fi-dir-full-name
                     , input tg-zip
                     ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???

------------------------------------------------------------------------------*/
/*if cb-type > 0 then  assign ReportHeader = {&new-line} + "Форма отчета : " + entry( cb-type , {&alcdcl-region-name} ) + {&new-line} .*/
  define variable v-zip as logical   no-undo .
  do with frame {&frame-name} :
    assign
      tg-zip
      fi-dir-full-name
    .
    assign
      ReportHeader = substitute( "Формирование XML файлов в директории &1 &2 &3"
                              , fi-dir-full-name
                              , ( if tg-zip = yes then "Упаковывать отчет в zip архив" else "" )
                              )
    .
  end.

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
      /* link-changed */
  END CASE.
  END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME