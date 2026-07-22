&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-grp NO-UNDO LIKE gds-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

e-Отчет по картам ЛНР. Печать отчёта в процедуре  my-report.

Автор: Соломко Дмитрий Владимирович
Дата создания: 10/02/2014 
Author: Solomko Dmitry
Creation date: 10/02/2014 

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "e-Отчет Детализированный отчет по бонусам и картам ЛНР. Печать отчёта в процедуре my-report.".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i }
{ cmp/operlist.i }
{ rep/e-xldbj.i "NEW SHARED" }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ cmp/dc-list.i dc-list def "new shared" }
{ gbl/getcntxt.i def }
{ rep/lhstprex.i dc-list-hist }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable parparentproc as widget-handle no-undo.
define variable loc-ref-list as character no-undo.
define variable doc-list as character no-undo.
define variable ii as integer no-undo.
/*define variable Report  as class ReportXml no-undo. /* Переменная под класс */                            */
/*define variable xml_tmp as character no-undo. /*путь к временному файлу*/                                 */
/*define variable xslt-path as character no-undo. /*путь к шаблону */                                       */
/*define variable rep-out-unit as class rep-out no-undo. /*экземпляр класса формирования документа отчёта */*/
/*define variable v-total-qnty as decimal no-undo.                                                          */
/*define variable v-total-sum1 as decimal no-undo.                                                          */
/*define variable v-total-sum2 as decimal no-undo.                                                          */
/*define variable v-discount as decimal no-undo.                                                            */
/*define variable gds-str as character no-undo initial "".                                                  */

/*define buffer buf_trn-doc for ub.trn-doc.                                                                 */

/*define temp-table tt-line no-undo*/
/*/*Дата чека*/                    */
/*field chk-date as date           */
/*/*Время*/                        */
/*field chk-time as integer        */
/*/*Номер карты*/                  */
/*field d-card as character        */
/*/*№ кассы*/                      */
/*field pay-desk as integer        */
/*/*Объект*/                       */
/*field obj-name as character      */
/*field obj-type as character      */
/*field obj-code as integer        */
/*/*Товар*/                        */
/*field gds-name as character      */
/*/*Количество*/                   */
/*field eff-doc-qnty as decimal    */
/*/*Сумма без скидки*/             */
/*field object-sum as decimal      */
/*/*Скидка*/                       */
/*field discount as decimal        */
/*/*Сумма со скидкой*/             */
/*field tot-r-b as decimal         */
/*field line-type as character     */
/*field doc-code as character      */
/*field type-line as character     */
/*                                 */
/*index pi as primary doc-code     */
/*.                                */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-3 RECT-4 cb-disType v-rs-klass v-rs-det 
&Scoped-Define DISPLAYED-OBJECTS cb-disType v-rs-klass v-rs-det 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE cb-disType AS CHARACTER FORMAT "X(256)":U INITIAL "1" 
     LABEL "Тип скидки" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "ЛНР","1",
                     "Оплата бонусами","2"
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE v-rs-det AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Товар", "good":U,
"По типам товаров (Топливо\СТ\Услуги)", "goodtype":U
     SIZE 39.4 BY 2.52 NO-UNDO.

DEFINE VARIABLE v-rs-klass AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Объект", "object":U,
"Дата", "date":U,
"Номер карты", "card":U
     SIZE 20 BY 3.81 NO-UNDO.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 42.8 BY 4.52.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 42.8 BY 3.05.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     cb-disType AT ROW 1.29 COL 14.6 COLON-ALIGNED WIDGET-ID 2
     v-rs-klass AT ROW 4.33 COL 3.6 NO-LABEL
     v-rs-det AT ROW 9.33 COL 3.6 NO-LABEL
     " Классификация" VIEW-AS TEXT
          SIZE 15.4 BY .81 AT ROW 3.48 COL 3.6
          FGCOLOR 4 
     " Детализация" VIEW-AS TEXT
          SIZE 13.4 BY .81 AT ROW 8.48 COL 3.6
          FGCOLOR 4 
     RECT-3 AT ROW 3.86 COL 1.2
     RECT-4 AT ROW 8.91 COL 1.2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
   Temp-Tables and Buffers:
      TABLE: tt-grp T "?" NO-UNDO ub gds-grp
   END-TABLES.
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
         HEIGHT             = 11.48
         WIDTH              = 43.8.
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

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */
  parparentproc = my-handle.
  { gbl/getcntxt.i get }

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
define variable v-list as character no-undo.
    define variable v-tmp as character no-undo.
    
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
    cb-disType:screen-value in frame {&frame-name} = '1'.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/******************/

    run rep/r-xldlnr.p(input cb-disType, input v-rs-klass, input v-rs-det).

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
    assign frame {&frame-name}
        cb-disType
        v-rs-klass
        v-rs-det
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
      /* link-changed */
  END CASE.
  END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

