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

Оборотная ведомость по покупателям (по товарам)

Автор: Комаров Иван Сергеевич
Дата создания: 11/26/09
Author: Ivan Komarov
Creation date: 11/26/09

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость по покупателям (закладка № 2)".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ cmp/operlist.i  }
{ rep/rep-bt.i    }
{ gbl/twowin.i   }
{ gbl/usr-flt.i }
/* { rep/varfpage.i p-customer }
  { rep/rvarpage.i }*/

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable v-nn as integer   no-undo .
define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .
def buffer cli-post for clients .

define variable v-curr-r-b               as character no-undo .
define variable v-print-rubl             as logical   no-undo .

  def var p-customer as int.
  def var v-res as char.

  def new  SHARED temp-table g#post NO-UNDO
     field obj-type like ub.clients.obj-type
     field obj-code like ub.clients.obj-code
     field obj-name like ub.clients.obj-name
     INDEX pi IS UNIQUE PRIMARY obj-type obj-code.

def New SHARED temp-table g#post-f NO-UNDO
     field obj-type like ub.clients.obj-type
     field obj-code like ub.clients.obj-code
     field obj-name like ub.clients.obj-name
     field grp-code like ub.clients.grp-code
     field grp-name like ub.clients.grp-name
     field lvl-num like  ub.cli-grp.lvl-num
     INDEX pi IS UNIQUE PRIMARY obj-type obj-code
     INDEX p1  obj-name
    .
define variable  post-grp_recids as character no-undo .
define variable ii as integer no-undo .
DEFINE VARIABLE v-detdoctip AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-detgoods AS LOGICAL NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-11 RECT-12 DetGoods Detdoctip
&Scoped-Define DISPLAYED-OBJECTS DetGoods Detdoctip

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 42.5 BY 2.75.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 42.5 BY 2.25.

DEFINE VARIABLE Detdoctip AS LOGICAL INITIAL no
     LABEL "Детализация по типам документов":L
     VIEW-AS TOGGLE-BOX
     SIZE 34.5 BY .83 TOOLTIP "Выводит разделение по типу документа" NO-UNDO.

DEFINE VARIABLE Detgoods AS LOGICAL INITIAL no
     LABEL "Детализация по товарам":L
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 TOOLTIP "Выводит детализацию по товарам" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Detgoods AT ROW 2.25 COL 6 WIDGET-ID 6
     Detdoctip AT ROW 4.75 COL 6 WIDGET-ID 8
     RECT-11 AT ROW 1 COL 4 WIDGET-ID 10
     RECT-12 AT ROW 4 COL 4 WIDGET-ID 12
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
         HEIGHT             = 16.75
         WIDTH              = 75.
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
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
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





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Detdoctip
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Detdoctip s-object
ON VALUE-CHANGED OF Detdoctip IN FRAME F-Main /* Детализация по типам документов */
DO:
  assign DetDocTip.

assign
  v-detdoctip = detdoctip
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Detgoods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Detgoods s-object
ON VALUE-CHANGED OF Detgoods IN FRAME F-Main /* Детализация по товарам */
DO:
  assign Detgoods.

 assign
  v-detgoods = DetGoods
.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
run rep/r-obcntr.p
    ( input v-cntxt-obj-code    ,
      input v-cntxt-obj-type    ,
      input base-type           ,
      input base-code           ,
      input v-DetGoods          ,
      input v-Detdoctip         ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} DetGoods Detdoctip
.

ReportNAme = "Оборотная ведомость по покупателям (по товарам) " .
assign
sheetf.Excel-Column-Lable = "Код,Артикул,Наименование" +
(if v-detdoctip then (",Расход Количество,Расход Сумма,Возврат Количество,Возврат Сумма")  else "") + ",Итого количество,Итого обороты"
sheetf.Sizes  = "9,16,40" + (if v-detdoctip then ",12,12,12,12" else "") + ",12,12"
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME