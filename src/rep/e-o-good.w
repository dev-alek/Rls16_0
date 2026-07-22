&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость по одному товару (закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Created: 10/11/00
*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Оборотная ведомость по одному товару (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
define variable lns-cnt as integer   no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-9 COMBO-node TOG-inv
&Scoped-Define DISPLAYED-OBJECTS COMBO-node TOG-inv

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE COMBO-node AS CHARACTER FORMAT "X(40)":U INITIAL "касса"
     LABEL "Типы документов"
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEMS "касса"
     SIZE 40.75 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.75 BY 16.08.

DEFINE VARIABLE TOG-inv AS LOGICAL INITIAL no
     LABEL "С момента последней инвентаризации"
     VIEW-AS TOGGLE-BOX
     SIZE 57.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     COMBO-node AT ROW 1.71 COL 6
     TOG-inv AT ROW 3.38 COL 6.38
     RECT-9 AT ROW 1.38 COL 1.75
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
         HEIGHT             = 16.71
         WIDTH              = 68.63.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     =
                "DLGCLOSE".

/* SETTINGS FOR COMBO-BOX COMBO-node IN FRAME F-Main
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GOTO-first-page s-object
PROCEDURE GOTO-first-page :
/*message " Для этого отчета надо выбрать только один товар ! вернитесь на закладку <Параметры> и выберите 1 товар ".*/
   { rep/get-link.i 'State':U}
   run Select1 IN State-source.

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

    Combo-node:list-items In frame {&frame-name} = Combo-node:list-items + ',' + {&all}      .
    Combo-node:list-items In frame {&frame-name} = Combo-node:list-items + ',' + {&TDEDT_Ras_Vnesh_Kass-full}      .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Vozvrat_Vnesh_Kass-full}  .

    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Pri_Vnesh-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Pri_Perem-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Vozvrat_Vnesh-full}       .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Vozvrat_Perem-full}       .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Pri_Prvo-full}            .

    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Vnesh-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Vnesh_VP-full}        .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Spi_Vnesh-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Perem-full}           .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Ras_Prvo-full}            .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Spi_Prvo-full}            .

    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Inv-full}                 .
    Combo-node:list-items = Combo-node:list-items + ',' + {&TDEDT_Overturn-full}            .

    Combo-node:list-items = Combo-node:list-items + ',' +  {&TDEDT_Corr_Acc_Price-full}         .
    Combo-node:list-items = Combo-node:list-items + ',' +  {&TDEDT_Chg_Purch_Code-full}         .
    Combo-node:list-items = Combo-node:list-items + ',' +  {&TDEDT_Peresort-full}         .

    Combo-node:screen-value in frame {&frame-name} = {&all}.

    display Combo-node  with frame {&FRAME-NAME} .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета
------------------------------------------------------------------------------*/
 run rep/r-o-good.p
  ( input v-cntxt-obj-code ,
    input v-cntxt-obj-type ,
    input base-type  ,
    input base-code  ,
    input COMBO-node ,
    input tog-inv,
    input "no-classify":U,
    input "sort-article":U ,
    input "" ).



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки ???
------------------------------------------------------------------------------*/
assign frame {&frame-name} COMBO-node tog-inv .

/*строки в которых содержатся выбранные объекты */
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.


ReportNAme = "О Т Ч Е Т   О   С О С Т О Я Н И И   З А П А С А   И   П Р О Д А Ж А Х   ( по одному товару)".
ReportHeader = " Тип документов : " + COMBO-node + chr(10) + " Остатки на начало, конец периода и оборот указаны по всем типам документов".
if tog-inv then
ReportHeader = ReportHeader  + chr(10) + " с момента последней инвентаризации ".

            Case COMBO-node:
                when  {&TDEDT_Pri_Vnesh-full}             then   COMBO-node = {&TDEDT_Pri_Vnesh}          .
                when  {&TDEDT_Ras_Vnesh-full}             then   COMBO-node = {&TDEDT_Ras_Vnesh}          .
                when  {&TDEDT_Ras_Vnesh_VP-full}          then   COMBO-node = {&TDEDT_RAS_Vnesh_VP}       .
                when  {&TDEDT_Ras_Vnesh_Kass-full}        then   COMBO-node = {&TDEDT_Ras_Vnesh_Kass}     .
                when  {&TDEDT_Vozvrat_Vnesh-full}         then   COMBO-node = {&TDEDT_Vozvrat_Vnesh}      .
                when  {&TDEDT_Vozvrat_Vnesh_Kass-full}    then   COMBO-node = {&TDEDT_Vozvrat_Vnesh_Kass} .
                when  {&TDEDT_Spi_Vnesh-full}             then   COMBO-node = {&TDEDT_Spi_Vnesh}          .
                when  {&TDEDT_Inv-full}                   then   COMBO-node = {&TDEDT_Inv}                .
                when  {&TDEDT_Pri_Perem-full}             then   COMBO-node = {&TDEDT_Pri_Perem}          .
                when  {&TDEDT_Ras_Perem-full}             then   COMBO-node = {&TDEDT_Ras_Perem}          .
                when  {&TDEDT_Vozvrat_Perem-full}         then   COMBO-node = {&TDEDT_Vozvrat_Perem}       .
                when  {&TDEDT_Ras_Prvo-full}              then   COMBO-node = {&TDEDT_Ras_Prvo}            .
                when  {&TDEDT_Spi_Prvo-full}              then   COMBO-node = {&TDEDT_Spi_Prvo}            .
                when  {&TDEDT_Pri_Prvo-full}              then   COMBO-node = {&TDEDT_Pri_Prvo}            .
                when  {&TDEDT_Peresort-full}              then   COMBO-node = {&TDEDT_Peresort}            .
                when  {&TDEDT_Overturn-full}              then   COMBO-node = {&TDEDT_Overturn}            .
                when  'касса'                             then   COMBO-node = {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}.
                 when  {&all}                             then   COMBO-node = {&all}.
            End case.

if lns-cnt > 1  then DO:
lns-cnt= 0.
For each gds-list no-lock:
   lns-cnt = lns-cnt + 1.
End.
End.
If NOT can-find (first gds-list) OR
  lns-cnt > 1  then DO:
    run goto-first-page in this-procedure.
    Return error 'First-page':U.
End.
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
    When 'link-changed':U then do:
         if lns-cnt > 1 and NOT Link# Then do:
            message " Для этого отчета надо выбрать только один товар ! вернитесь на закладку <Параметры> и выберите 1 товар ".
            run goto-first-page in this-procedure.
         end.
    End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME