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

Отчет по бонусам (закладка № 2)

Автор: Шальнев Иван Сергеевич
Дата создания: 23/07/10
Author: Shalnev ivan
Creation date: 23/07/10


*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по бонусам (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/operlist.i  }
define variable v-nn as integer   no-undo .
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
define buffer cli-post for ub.clients .
define buffer cont for ub.contract .
define New SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clieobj-codents.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.
define variable post-grp_recids as character no-undo .
define variable old-post-list   as character no-undo.
define variable ii              as integer no-undo .
define variable NamePost  as character format "X(256)":U.
define variable cont-code as integer format "9999999":U.

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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-5 RECT-8 RECT-7 BUTTON-post ~
cod-post Postname SortType BUTTON-cont cont-num  Classify Cli-art
&Scoped-Define DISPLAYED-OBJECTS cod-post Postname SortType cont-num ~
 Classify Cli-art

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-cont
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-cont"
     SIZE 3 BY .86 TOOLTIP "Выбор договора".

DEFINE BUTTON BUTTON-post
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button post"
     SIZE 3 BY .86 TOOLTIP "Выбор поставщика".

DEFINE VARIABLE cod-post AS INTEGER FORMAT ">>>>>>>>9":U
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE cont-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 27 BY 1 NO-UNDO.

DEFINE VARIABLE Postname AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U,
"Производители/Группы товаров", "prod/grp-goods":U,
"Группы товаров/Производители", "grp-goods/prod":U
     SIZE 38.2 BY 4.62 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-article":U,
"по наимен.", "sort-name":U
     SIZE 14 BY 2.19 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.8 BY 6.95.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 22.8 BY 4.43.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.6 BY 3.43.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45.8 BY 5.91.

DEFINE VARIABLE Cli-art AS LOGICAL INITIAL no
     LABEL "артикул поставщика":L
     VIEW-AS TOGGLE-BOX
     SIZE 21.2 BY .81 NO-UNDO.



/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     BUTTON-post AT ROW 1.95 COL 3 WIDGET-ID 4
     cod-post AT ROW 1.95 COL 7 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     Postname AT ROW 1.95 COL 19 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     SortType AT ROW 2.52 COL 51.8 NO-LABEL
     BUTTON-cont AT ROW 3.38 COL 3 WIDGET-ID 2
     cont-num AT ROW 3.38 COL 7 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     Classify AT ROW 6.81 COL 2.8 NO-LABEL
     Cli-art AT ROW 16.57 COL 49.2
     "Сортировка :" VIEW-AS TEXT
          SIZE 13.6 BY .76 AT ROW 1.29 COL 52.8
          FGCOLOR 4
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .76 AT ROW 4.81 COL 7.2
          FGCOLOR 4
     "Выбор поставщика и договора:" VIEW-AS TEXT
          SIZE 32.8 BY .67 AT ROW 1.24 COL 7.2
          FGCOLOR 4
     RECT-6 AT ROW 1.05 COL 48.2
     RECT-5 AT ROW 4.62 COL 1.8
     RECT-8 AT ROW 11.62 COL 1.8
     RECT-7 AT ROW 1.05 COL 1.8 WIDGET-ID 6
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
         HEIGHT             = 16.76
         WIDTH              = 70.4.
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

ASSIGN
       Cli-art:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       cod-post:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN
       Postname:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN
       cont-num:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME BUTTON-cont
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-cont s-object
ON CHOOSE OF BUTTON-cont IN FRAME F-Main /*выбор договора */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
if Postname:screen-value = "" then do:
 message "Выберите поставщика " view-as alert-box.
 return no-apply.
end.
  run str/cont-all.w
    (input   my-handle
    ,input   v-cntxt-host-code-obj
    ,input   "b-sel"
    ,input   {&company}
    ,input   g#post.obj-type
    ,input   g#post.obj-code
    ,input   ?
    ,input   ?
    ,input   "current"
    ,input   "all"
    ,input-output v-rid-list )
    .
if  v-rid-list = '' and
    cont-num:screen-value = '' then do:
  message "Договор не выбран" view-as alert-box.
end.
else do:
  if  v-rid-list = '' then do:
  end.
  else do:
  assign cont-num:screen-value = '' .
  FIND FIRST cont WHERE recid( cont ) = int( v-rid-list ) NO-LOCK.
  cont-num:screen-value = string( cont.contract-prn-code ).
  cont-code = cont.contract-code.
  end.
end.
  {&apply-entry}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-post
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-post s-object
ON CHOOSE OF BUTTON-post IN FRAME F-Main /* выбор поставщика */
DO:
if available  g#post then delete g#post.
Postname:screen-value = ''.
cod-post:screen-value = ''.
cont-num:screen-value = ''.
  run ref/cli-all.w
    (input   my-handle
    ,input   "b-sel"
    ,input   {&pro}
    ,input   {&all}
    ,input   {&current}
    ,input   ?
    ,input   ",,,,,,NO,,"
    ,input   ?
    ,output post-grp_recids ) .
if post-grp_recids = "" and
   Postname:screen-value = "" then do:
  message "Поставщик не выбран" view-as alert-box.
end.
else do:
  if post-grp_recids = "" then do:
  end.
  else do:
    Assign  Postname:screen-value = ''.
        FIND FIRST cli-post WHERE recid( cli-post ) = int( post-grp_recids ) NO-LOCK.
        create g#post.
        assign
        g#post.obj-type = cli-post.obj-type
        g#post.obj-code = cli-post.obj-code
        g#post.obj-name = cli-post.obj-name
        Postname:screen-value = Postname:screen-value + cli-post.obj-name
        cod-post:screen-value = string( cli-post.obj-code )
        NamePost = Postname:screen-value
        .
  end.
end.
END.

/* _UIB-CODE-BLOCK-END*/
&ANALYZE-RESUME


&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
Assign Classify.
if Classify = "grp-goods":U
Then do:
end.
Else do:
end.
if Classify = "post":U
Then do:
end.
Else do:
end.

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
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/

 run rep/r-bonus.p
    ( input v-cntxt-obj-code      ,
      input v-cntxt-obj-type      ,
      input base-type             ,
      input base-code             ,
      input Cli-art               ,
      input NamePost              ,
      input Classify              ,
      input SortType              ,
      input cont-code
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

assign frame {&frame-name}
Cli-art  /*PostName*/  /*RADPost*/  Classify  SortType.
ReportNAme = "Отчет по бонусам".
{ rep/claslabl.i }
ReportHeader = "Поставщик: " + NamePost + {&new-line}.

ReportHeader = ReportHeader + "Классификация : " + t-Class.

ReportHeader = ReportHeader  + {&new-line}.

ReportHeader = ReportHeader + "Сортировка " + t-Sort + {&new-line}.

ReportHeader = ReportHeader  + {&new-line}.

ReportHeader = ReportHeader + "Отчет сформирован : " + string(today) + {&new-line}.
ReportHeader = ReportHeader  + {&new-line}.
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