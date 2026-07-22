&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS D-Dialog
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывод информации по бар-кодам

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 04/12/06


*/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter rec-id as recid no-undo.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Информация по бар-кодам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ str/anlz-bc.i  }

/* Parameters Definitions ---                                           */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartDialog

&Scoped-define ADM-CONTAINER DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME D-Dialog

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-goods b-parts b-place RECT-4 ~
RECT-5 RECT-1 RECT-2 varpl-name
&Scoped-Define DISPLAYED-OBJECTS varbar-code varentity vartype-bc varwt ~
varadd-info varb-c-cli varunit-cli-name varunit-cli-long varrate varb-c ~
varunit-base-name varunit-base-long varartic vargds-name varprod-type ~
varprod-code varprod-name varf-name varpart-code varloc1 varloc2 varin-code ~
varloc3 varfact-date varloc4 varTempBarCode varTempGoods varTempAdd ~
varpl-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON b-goods
     LABEL "&Товар"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-parts
     LABEL "&Партия"
     SIZE 10 BY 1.

DEFINE BUTTON b-place
     LABEL "&Место"
     SIZE 10 BY 1.

DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 19.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varb-c AS INTEGER FORMAT ">>>>>>>>>>>>>>9":U INITIAL 0
     LABEL "Основной код"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varb-c-cli AS INTEGER FORMAT ">>>>>>>>>>>>>>9":U INITIAL 0
     LABEL "Собственный код"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varbar-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Исходный код"
     VIEW-AS FILL-IN
     SIZE 52.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varadd-info AS CHARACTER FORMAT "X(256)":U
     LABEL "Доп инф"
     VIEW-AS FILL-IN
     SIZE 64.88 BY 1 NO-UNDO.

DEFINE VARIABLE varentity AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 26.13 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varf-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 83.63 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varfact-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 53.38 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varin-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Накладная"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varloc1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Коорд1"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varloc2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Коорд2"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varloc3 AS CHARACTER FORMAT "X(256)":U
     LABEL "Коорд3"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varloc4 AS CHARACTER FORMAT "X(256)":U
     LABEL "Коорд4"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varpart-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Код"
     VIEW-AS FILL-IN
     SIZE 20.75 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varpl-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 22.88 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varprod-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13.75 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varprod-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 53.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varprod-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 5.75 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varrate AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0
     LABEL "Коэффициент"
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varTempAdd AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 94.88 BY .75
     BGCOLOR 7 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE varTempBarCode AS CHARACTER FORMAT "X(256)":U INITIAL "СОБСТВЕННЫЙ КОД"
      VIEW-AS TEXT
     SIZE 94.88 BY .75
     BGCOLOR 7 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE varTempGoods AS CHARACTER FORMAT "X(256)":U INITIAL "ТОВАР"
      VIEW-AS TEXT
     SIZE 94.88 BY .75
     BGCOLOR 7 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE vartype-bc AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип кода"
     VIEW-AS FILL-IN
     SIZE 65.13 BY 1
     BGCOLOR 15 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varunit-base-long AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varunit-base-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Ед. изм."
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varunit-cli-long AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varunit-cli-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Ед. изм."
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varwt AS DECIMAL FORMAT ">>9.99":U INITIAL ?
     LABEL "Вес"
     VIEW-AS FILL-IN
     SIZE 6.63 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 94.88 BY 4.25.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 94.88 BY 2.08.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 94.88 BY 4.21.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 94.88 BY 3.13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME D-Dialog
     b-exit AT ROW 1.21 COL 2
     b-help AT ROW 1.21 COL 12
     b-goods AT ROW 1.21 COL 22
     b-parts AT ROW 1.21 COL 32
     b-place AT ROW 1.21 COL 42
     varbar-code AT ROW 3.67 COL 14.88 COLON-ALIGNED
     varentity AT ROW 3.67 COL 67.63 COLON-ALIGNED NO-LABEL
     vartype-bc AT ROW 4.88 COL 14.88 COLON-ALIGNED
     varwt AT ROW 4.92 COL 87 COLON-ALIGNED
     varadd-info AT ROW 6.25 COL 15 COLON-ALIGNED
     varb-c-cli AT ROW 8.42 COL 20.25 COLON-ALIGNED
     varunit-cli-name AT ROW 8.42 COL 56.75 COLON-ALIGNED
     varunit-cli-long AT ROW 8.42 COL 62.88 COLON-ALIGNED NO-LABEL
     varrate AT ROW 9.71 COL 56.75 COLON-ALIGNED
     varb-c AT ROW 12.04 COL 20.25 COLON-ALIGNED
     varunit-base-name AT ROW 12.04 COL 56.75 COLON-ALIGNED
     varunit-base-long AT ROW 12.04 COL 62.88 COLON-ALIGNED NO-LABEL
     varartic AT ROW 13.29 COL 20.25 COLON-ALIGNED
     vargds-name AT ROW 13.29 COL 40.5 COLON-ALIGNED NO-LABEL
     varprod-type AT ROW 14.33 COL 20.25 COLON-ALIGNED
     varprod-code AT ROW 14.33 COL 26.38 COLON-ALIGNED NO-LABEL
     varprod-name AT ROW 14.33 COL 40.5 COLON-ALIGNED NO-LABEL
     varf-name AT ROW 17 COL 4.75 NO-LABEL
     varpart-code AT ROW 17 COL 6.5 COLON-ALIGNED
     varloc1 AT ROW 17 COL 32.5 COLON-ALIGNED
     varloc2 AT ROW 17 COL 47.63 COLON-ALIGNED
     varin-code AT ROW 17 COL 52.38 COLON-ALIGNED
     varloc3 AT ROW 17 COL 61.75 COLON-ALIGNED
     varfact-date AT ROW 17 COL 74 COLON-ALIGNED
     varloc4 AT ROW 17 COL 78 COLON-ALIGNED
     varTempBarCode AT ROW 7.54 COL 1.88 NO-LABEL
     varTempGoods AT ROW 11.38 COL 1.88 NO-LABEL
     varTempAdd AT ROW 16.17 COL 1.88 NO-LABEL
     varpl-name AT ROW 17 COL 1.5 COLON-ALIGNED NO-LABEL
     "ИСКОМЫЙ КОД" VIEW-AS TEXT
          SIZE 94.88 BY .75 AT ROW 2.92 COL 1.75
          BGCOLOR 7 FGCOLOR 15
     RECT-4 AT ROW 3.25 COL 1.75
     RECT-5 AT ROW 7.96 COL 1.88
     RECT-1 AT ROW 11.58 COL 1.88
     RECT-2 AT ROW 16.38 COL 1.88
     SPACE(0.23) SKIP(1.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Информация по коду (бар-коду)".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartDialog
   Allow: Basic,Browse,DB-Fields,Query,Smart
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX D-Dialog
                                                                        */
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN varartic IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varb-c IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varb-c-cli IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varbar-code IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varadd-info IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varentity IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varf-name IN FRAME D-Dialog
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varfact-date IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vargds-name IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varin-code IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varloc1 IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varloc2 IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varloc3 IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varloc4 IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varpart-code IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-code IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-name IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-type IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varrate IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varTempAdd IN FRAME D-Dialog
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varTempBarCode IN FRAME D-Dialog
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varTempGoods IN FRAME D-Dialog
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN vartype-bc IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-base-long IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-base-name IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-cli-long IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-cli-name IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varwt IN FRAME D-Dialog
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX D-Dialog
/* Query rebuild information for DIALOG-BOX D-Dialog
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX D-Dialog */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB D-Dialog
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME D-Dialog
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL D-Dialog D-Dialog
ON WINDOW-CLOSE OF FRAME D-Dialog /* Информация по коду (бар-коду) */
DO:
  /* Add Trigger to equate WINDOW-CLOSE to END-ERROR. */
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods D-Dialog
ON CHOOSE OF b-goods IN FRAME D-Dialog /* Товар */
DO:
  find first goods where goods.artic = varartic and
                         goods.prod-type = varprod-type and
                         goods.prod-code = varprod-code no-lock no-error.
  if not available goods then do:
    message "Товар не найден." view-as alert-box.
    return no-apply.
  end.
  run str/showgds.p ( input parparentproc
                     ,input ? /*p-call-handle*/
                     ,input goods.gds-code
                     ,input {&lookup}).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parts D-Dialog
ON CHOOSE OF b-parts IN FRAME D-Dialog /* Партия */
DO:
def var rid-list as char no-undo.
define variable prt-rec as recid no-undo .

find goods where goods.artic     = varartic     and
                goods.prod-type = varprod-type and
                goods.prod-code = varprod-code no-lock no-error.
if not available goods then do:
  message "Товар не найден."
  view-as alert-box error.
  return no-apply.
end.
   run str/parts-l.w
     (input parparentproc
     ,input p-obj-type                /* v-obj-type   */
     ,input p-obj-code                /* v-obj-code   */
     ,input goods.gds-code            /* p-gds-code   */
     ,input ""                        /* p-doc-code   */
     ,input {&lookup}                 /* p-edit-mode  */
     ,input {&parts-l_parts-all}      /* p-r-parts    */
     ,input {&parts-l_object-all}     /* p-one-all    */
     ,input {&parts-l_call-reference} /* p-call-point */
     ,output prt-rec                  /* part-recid   */
     ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-place
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-place D-Dialog
ON CHOOSE OF b-place IN FRAME D-Dialog /* Место */
DO:
def var rid-list as char no-undo.

find place where place.obj-type = p-obj-type and
                 place.obj-code = p-obj-code and
                 place.pl-code  = int (varbar-code) no-lock no-error.
if not available place then do:
  message "Складское место не найдено." view-as alert-box error.
  return no-apply.
end.
run ref/pl-list.w (
                  input parparentproc
                , input "" /*bttns*/
                , input p-obj-type
                , input p-obj-code
                , input {&g___Object} /*p-mode*/
                , input-output rid-list).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK D-Dialog


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

{src/adm/template/dialogmn.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects D-Dialog _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available D-Dialog _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI D-Dialog _DEFAULT-DISABLE
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
  HIDE FRAME D-Dialog.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI D-Dialog _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY varbar-code varentity vartype-bc varwt varadd-info varb-c-cli
          varunit-cli-name varunit-cli-long varrate varb-c varunit-base-name
          varunit-base-long varartic vargds-name varprod-type varprod-code
          varprod-name varf-name varpart-code varloc1 varloc2 varin-code varloc3
          varfact-date varloc4 varTempBarCode varTempGoods varTempAdd varpl-name
      WITH FRAME D-Dialog.
  ENABLE b-exit b-help b-goods b-parts b-place RECT-4 RECT-5 RECT-1 RECT-2
         varpl-name
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
  {&OPEN-BROWSERS-IN-QUERY-D-Dialog}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize D-Dialog
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  find un-bc where recid(un-bc) = rec-id.

  assign
  varbar-code       = un-bc.bar-code
  varentity         = un-bc.entity
  vartype-bc        = un-bc.type-bc
  varrate           = un-bc.rate
  varwt             = un-bc.wt
  varb-c-cli        = un-bc.b-c
  varunit-cli-name  = un-bc.unit-name
  varunit-cli-long  = un-bc.long-name
  varb-c            = un-bc.b-c-base
  varunit-base-name = un-bc.unit-name-base
  varunit-base-long = un-bc.long-name-base
  varartic          = un-bc.artic
  varprod-type      = un-bc.prod-type
  varprod-code      = un-bc.prod-code
  vargds-name       = un-bc.gds-name
  varprod-name      = un-bc.prod-name
  varpl-name        = un-bc.pl-name
  varloc1           = un-bc.loc1
  varloc2           = un-bc.loc2
  varloc3           = un-bc.loc3
  varloc4           = un-bc.loc4
  varf-name         = un-bc.f-name
  varin-code        = un-bc.in-code
  varfact-date      = un-bc.fact-date
  varpart-code      = un-bc.part-code
  varTempAdd        = varentity
  .
  /* определяем дополнительную информацию на основании кода EAN13 */
  if length (varbar-code) = 13 then do:
    run gbl/bcextinf.p
      (input 'EAN13':U
      ,input varbar-code
      ,output varadd-info
      ) .
  end.

  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  /*Складское место*/
  IF varentity <> {&goods}    AND
     varentity <> {&property} AND
     varentity <> {&part}     THEN
     HIDE varrate           in frame {&frame-name}
          varb-c-cli        in frame {&frame-name}
          varunit-cli-name  in frame {&frame-name}
          varunit-cli-long  in frame {&frame-name}
          varb-c            in frame {&frame-name}
          varunit-base-name in frame {&frame-name}
          varunit-base-long in frame {&frame-name}
          varartic          in frame {&frame-name}
          vargds-name       in frame {&frame-name}
          varprod-type      in frame {&frame-name}
          varprod-code      in frame {&frame-name}
          varprod-name      in frame {&frame-name}
          b-goods           in frame {&frame-name}
          RECT-1            in frame {&frame-name}
          RECT-5            in frame {&frame-name}
          varTempBarCode    in frame {&frame-name}
          varTempGoods      in frame {&frame-name}.
  /*просто товар*/
  IF varentity <> {&stock-place}  AND
     varentity <> {&property}     AND
     varentity <> {&part}         THEN
     HIDE
       RECT-2     in frame {&frame-name}
       varTempAdd in frame {&frame-name}.
  /*Если не признак*/
  IF varentity <> {&property} THEN
     HIDE varf-name in frame {&frame-name}.
  /*Если не партия*/
  IF varentity <> {&part}  THEN
     HIDE varfact-date in frame {&frame-name}
          varin-code   in frame {&frame-name}
          varpart-code in frame {&frame-name}
          b-parts      in frame {&frame-name}.
  /*Если не складское место*/
  IF varentity <> {&stock-place} THEN
     HIDE varpl-name in frame {&frame-name}
          varloc1 in frame {&frame-name}
          varloc2 in frame {&frame-name}
          varloc3 in frame {&frame-name}
          varloc4 in frame {&frame-name}
          b-place in frame {&frame-name}.
  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records D-Dialog _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartDialog, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed D-Dialog
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME