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

Оборотная ведомость движению товару (закладка № 2)

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
def var vss-description as character no-undo init "Оборотная ведомость  движению товаров (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.

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
&Scoped-Define ENABLED-OBJECTS RECT-10 RECT-11 RECT-9 Classify SortType ~
COMBO-node TOG-inv TOG-tow 
&Scoped-Define DISPLAYED-OBJECTS Classify SortType COMBO-node TOG-inv ~
SumsOnly TOG-tow 

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
     DROP-DOWN-LIST
     SIZE 40.75 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Сортировка:" 
      VIEW-AS TEXT 
     SIZE 11.88 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U,
"Производители/Группы товаров", "prod/grp-goods":U,
"Группы товаров/Производители", "grp-goods/prod":U,
"Ставка НДС", "vat-ps":U,
"Проба(Сорт)", "sort":U
     SIZE 31.88 BY 6.04 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "по коду", "sort-code":U,
"по артикулу", "sort-article":U
     SIZE 14 BY 1.96 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 48 BY 7.96.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 18.38 BY 7.96.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 67.75 BY 8.17.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no 
     LABEL "Только итоги" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-inv AS LOGICAL INITIAL no 
     LABEL "С момента последней инвентаризации" 
     VIEW-AS TOGGLE-BOX
     SIZE 37.13 BY .83 NO-UNDO.

DEFINE VARIABLE TOG-tow AS LOGICAL INITIAL yes 
     LABEL "В двух ед.изм." 
     VIEW-AS TOGGLE-BOX
     SIZE 17.5 BY .83
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify AT ROW 2.63 COL 2.88 NO-LABEL
     SortType AT ROW 2.63 COL 52.63 NO-LABEL
     COMBO-node AT ROW 9.58 COL 2.63
     TOG-inv AT ROW 10.75 COL 2.88
     SumsOnly AT ROW 11.79 COL 2.88
     TOG-tow AT ROW 12.83 COL 2.88
     FILL-IN-1 AT ROW 1.46 COL 51.75 COLON-ALIGNED NO-LABEL
     "Классификация :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 1.67 COL 10.13
          FGCOLOR 4 
     RECT-10 AT ROW 1.21 COL 2.25
     RECT-11 AT ROW 1.25 COL 50.88
     RECT-9 AT ROW 9.29 COL 1.75
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
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     = 
                "DLGCLOSE".

/* SETTINGS FOR COMBO-BOX COMBO-node IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       FILL-IN-1:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN 
       SortType:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
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

&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify s-object
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
   Assign Classify.
    if Classify  Begins "prod":U OR
       Classify  Begins "grp-goods":U OR
       Classify  Begins "vat-ps":U
        then
        enable SumsOnly with frame {&FRAME-NAME} .

   if Classify = "no-classify":U
      Then do:
            SumsOnly = FALSE .
            display SumsOnly with frame {&FRAME-NAME} .
            disable SumsOnly with frame {&FRAME-NAME} .
        end.

/*   if Classify = "grp-goods":U
         Then do:
            display TOG-lavel   with frame {&FRAME-NAME} .
            enable  TOG-lavel   with frame {&FRAME-NAME} .
        end.
         Else do:
            display  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
        end.
        */
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

    Combo-node:screen-value in frame {&frame-name} = {&all}.
    tog-tow:screen-value in frame {&frame-name} = "yes".

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
        input tog-inv  ,
        input classify ,
        input SortType ,
        input "all," + string(SumsOnly,"yes/no") + "," + string(tog-tow,"yes/no") ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки ???
------------------------------------------------------------------------------*/
assign frame {&frame-name} COMBO-node tog-inv Classify /* SortType  */ SumsOnly tog-tow .
/*строки в которых содержатся выбранные объекты */
ReportNAme = "О Б О Р О Т Н А Я    В Е Д О М О С Т Ь    Д В И Ж Е Н И Я    Т О В А Р О В".
 { rep/claslabl.i }
ReportHeader = "Классификация : " + t-class + chr(10) .
ReportHeader = ReportHeader  + chr(10) + " Тип документов : " + COMBO-node + chr(10) + " Остатки на начало, конец периода и оборот указаны по всем типам документов".
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
                when  {&TDEDT_Overturn-full}              then   COMBO-node = {&TDEDT_Overturn}            .
                when  'касса'                             then   COMBO-node = {&TDEDT_Vozvrat_Vnesh_Kass} + ',' + {&TDEDT_Ras_Vnesh_Kass}.
                 when  {&all}                             then   COMBO-node = {&all}.
            End case.
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


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

