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

Зависшие товары

Автор: Чернова Светлана Александровна
Дата создания: 06/12/00
Author: Svetlana Chernova
Creation date: 06/12/00

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Зависшие товары".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
define variable scale_recid  as  recid    no-undo.
define variable Sort as integer no-undo.
define variable Crit as integer no-undo.
define variable Sc-node  like ub.gds-prt.node-code no-undo.
define variable Sc-upper like ub.gds-prt.upper-code no-undo.
define variable xclassify as character no-undo.

&glob ns-1    "Макс. количество"
&glob ns-2    "Макс. сумма в учетных ценах"
&glob ns-3    "Макс. сумма в прод. ценах"
&glob ns-sort-1    "по коду"
&glob ns-sort-2    "по артикулу"
&glob ns-sort-3    "по названию"
&glob ns-classify-1 "Без классификации"
&glob ns-classify-2 "Производители"
&glob ns-classify-3 "Группы товаров"
&glob ns-classify-4 "Производители/Группы товаров"
&glob ns-classify-5 "Группы товаров/Производители"

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
&Scoped-Define ENABLED-OBJECTS RECT-11 RECT-10 RECT-12 COMBO-crit ~
COMBO-Sort Classify Tog-Scale Sc_Name BSAmount Tog-Sale FILL-IN-1
&Scoped-Define DISPLAYED-OBJECTS COMBO-crit COMBO-Sort Classify Tog-Scale ~
Scale Sc_Name BSAmount Tog-Sale FILL-IN-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE Classify AS CHARACTER FORMAT "X(40)":U
     LABEL "Классификация"
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEMS "1","2"
     DROP-DOWN-LIST
     SIZE 40.75 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE COMBO-crit AS CHARACTER FORMAT "X(40)":U
     LABEL "Процент по критерию"
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEMS "1","2"
     DROP-DOWN-LIST
     SIZE 40.75 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE COMBO-Sort AS CHARACTER FORMAT "X(40)":U
     LABEL "Сортировка"
     VIEW-AS COMBO-BOX INNER-LINES 6
     LIST-ITEMS "1","2"
     DROP-DOWN-LIST
     SIZE 40.75 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Sc_Name AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL
     SIZE 41.25 BY 1.92
     BGCOLOR 8 FONT 4 NO-UNDO.

DEFINE VARIABLE BSAmount AS INTEGER FORMAT ">>9":U INITIAL 10
     LABEL "Сколько показать товаров"
     VIEW-AS FILL-IN
     SIZE 4.88 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Шкалы:"
      VIEW-AS TEXT
     SIZE 7.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Scale AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все", "все",
"Выбор шкалы", "Choice-scala":U
     SIZE 14.88 BY 2.04 NO-UNDO.

DEFINE VARIABLE Tog-Sale AS LOGICAL
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Только по продажам", Yes,
"По всем документам(с перемещениями)", No
     SIZE 63.5 BY 1.25 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.38 BY 4.58.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.38 BY 4.58.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 66.38 BY 4.58.

DEFINE VARIABLE Tog-Scale AS LOGICAL INITIAL no
     LABEL "По признакам"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     COMBO-crit AT ROW 1.71 COL 2.63
     COMBO-Sort AT ROW 3.04 COL 11.63
     Classify AT ROW 4.33 COL 21.5 COLON-ALIGNED
     Tog-Scale AT ROW 7.33 COL 9.88
     Scale AT ROW 8.33 COL 9.75 NO-LABEL
     Sc_Name AT ROW 8.38 COL 26.13 NO-LABEL
     BSAmount AT ROW 11.54 COL 27.5 COLON-ALIGNED
     Tog-Sale AT ROW 13.63 COL 3.5 NO-LABEL WIDGET-ID 2
     FILL-IN-1 AT ROW 6.46 COL 12.13 COLON-ALIGNED NO-LABEL
     RECT-11 AT ROW 1.33 COL 1.38
     RECT-10 AT ROW 6.04 COL 1.38
     RECT-12 AT ROW 10.75 COL 1.38
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

/* SETTINGS FOR COMBO-BOX COMBO-crit IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX COMBO-Sort IN FRAME F-Main
   ALIGN-L                                                              */
ASSIGN
       FILL-IN-1:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR RADIO-SET Scale IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       Scale:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN
       Sc_Name:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN
       Tog-Scale:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME Scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Scale s-object
ON VALUE-CHANGED OF Scale IN FRAME F-Main
DO:
    assign Scale .
    Sc-node = 0.
    Sc-Upper = 0 .
    if Scale = "Choice-scala":U then
    do:
             run ref/gdsprts.w
                 (my-handle, yes, output scale_recid).
             if scale_recid = ? then
             do:
                  Scale:screen-value = {&all} .
                  Sc_Name:screen-value IN FRAME {&FRAME-NAME} = {&all} .
                  Sc-node = 0.
                  Sc-Upper = 0.
             end.
             else
             do:
                  find first ub.gds-prt where recid (ub.gds-prt) = scale_recid.
                  Sc_Name:screen-value IN FRAME {&FRAME-NAME} = ub.gds-prt.node-name.
                  Sc-node = ub.gds-prt.node-code.
                  Sc-Upper = ub.gds-prt.upper-code.
             end.
    end.
    else
             Sc_Name:screen-value IN FRAME {&FRAME-NAME} = {&all} .
 aSSIGN Sc_Name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-Scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-Scale s-object
ON VALUE-CHANGED OF Tog-Scale IN FRAME F-Main /* По признакам */
DO:
Assign Tog-scale.
IF Tog-scale = TRUE then DO:
   Enable Scale with frame {&FRAME-NAME} .

  End.
  Else DO:
   Disable Scale   with frame {&FRAME-NAME} .
   Display Scale  with frame {&FRAME-NAME} .
  End.
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
classify:list-items    in frame {&frame-name} = {&ns-classify-1} + ',' + {&ns-classify-2} + ',' + {&ns-classify-3} .
combo-crit:list-items  in frame {&frame-name} = {&ns-1} + ',' + {&ns-2} + ',' + {&ns-3} .
combo-sort:list-items  in frame {&frame-name} = {&ns-sort-1} + ',' + {&ns-sort-2} + ',' + {&ns-sort-3} .
scale:radio-buttons    in frame {&frame-name} = "все" + ',' + {&all} + ',' + "Выбор шкалы" + ',' +  "choice-scala":u  .


  assign
   combo-crit:screen-value in frame {&frame-name} = {&ns-1}
   combo-sort:screen-value in frame {&frame-name} = {&ns-sort-1}
   classify:screen-value in frame {&frame-name}   = {&ns-classify-1}
   fill-in-1:screen-value in frame {&frame-name}  = "Шкалы:"
   scale:screen-value in frame {&frame-name}      = {&all}
   sc_name :screen-value in frame {&frame-name}   = {&all}
   tog-sale = true.

   enable  combo-crit combo-sort fill-in-1 scale classify tog-sale  with frame {&frame-name} .
   display combo-crit combo-sort fill-in-1 scale  classify tog-sale  with frame {&frame-name} .
   hide bsamount in frame {&frame-name} .

   /* WHITH FRAME {&FRAME-NAME}. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета
------------------------------------------------------------------------------*/
  Case classify :
      when {&ns-classify-1}  then
            run rep/r-nosale.p
            ( input v-cntxt-obj-code ,input v-cntxt-obj-type ,input base-type  ,input base-code  ,input v-cntxt-host-code-obj,input crit ,
              input Sort ,input xClassify,input BSAmount ,input Sc-node, input Sc-upper, input Tog-Scale,input Tog-Sale).

        when {&ns-classify-2}        then
            run rep/r-nosal3.p
            ( input v-cntxt-obj-code ,input v-cntxt-obj-type ,input base-type  ,input base-code  ,input v-cntxt-host-code-obj,input crit ,
              input Sort ,input xClassify,input BSAmount ,input Sc-node, input Sc-upper, input Tog-Scale,input Tog-Sale).

      when {&ns-classify-3}  then
              run rep/r-nosal2.p
              ( input v-cntxt-obj-code ,input v-cntxt-obj-type ,input base-type  ,input base-code  ,input v-cntxt-host-code-obj,input crit ,
                input Sort ,input xClassify,input BSAmount ,input Sc-node, input Sc-upper, input Tog-Scale,input Tog-Sale).
  end case.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки ???
------------------------------------------------------------------------------*/
assign frame {&frame-name}
    BSAmount COMBO-crit COMBO-Sort FILL-IN-1
    Sc_Name Scale Tog-Scale Tog-Sale Classify
.

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
 Sheetf.Excel-Column-Lable =
              "Код             "
      + "," + "Артикул         "
      + "," + "Название товара "
      + "," + "Ед.изм "
      + "," + "Количество "
      + "," + "Сумма в учетных ценах"
      + "," + "Сумма в продажных ценах"
      + "," + " %" .

Sheetf.Sizes =   "10,16,40,6,15,15,15,15,15".
ReportNAme = "<<Зависшие>> товары".
            Case COMBO-crit:
                when {&ns-1}                   then   crit = 1.
                when {&ns-2}                   then   crit = 2.
                when {&ns-3}                   then   crit = 3.
            End case.

            Case COMBO-Sort:
                when {&ns-sort-1}               then   Sort = 1.
                when {&ns-sort-2}               then   Sort = 2.
                when {&ns-sort-3}               then   Sort = 3.
            End case.
            Case classify :
                when {&ns-classify-1}  then xclassify = "no-classify":U .
                when {&ns-classify-2}  then xclassify = "prod":U         .
                when {&ns-classify-3}  then xclassify = "grp-goods":U     .
                when {&ns-classify-4}  then xclassify = "prod/grp-goods":U .
                when {&ns-classify-5}  then xclassify = "grp-goods/prod":U  .
            end case.

ReportHeader = " Критерий отбора : " + COMBO-crit + chr(10) +
               " Сортировка : " + COMBO-Sort + chr(10) +
               " Классификация : " + classify + chr(10)
                .
If  Tog-Scale Then
ReportHeader = ReportHeader + chr(10) + " Шкалы : "  + Sc_Name .

If  Tog-Sale Then
ReportNAme  = 'Товары <<зависшие>> по продажам '.
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
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
