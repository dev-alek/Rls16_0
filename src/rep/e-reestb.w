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

Реестр документов (Товарный отчет)(закладка № 2)

Автор: Чернова Светлана Александровна
Дата создания: 20/10/00
Author: Svetlana Chernova
Creation date: 20/10/00

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реестр документов (Товарный отчет)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i  }
{ rep/rep-bt.i  }
{ rep/gn-extp.i  }
{ rep/par-actu.i }
{ rep/par-actu.i proc }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source as  WIDGET-HANDLE.
define variable g#log as logical   no-undo .

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
&Scoped-Define ENABLED-OBJECTS RECT-14 RECT-15 RECT-16 RECT-12 ie VAT-SLT ~
ee VAT-SLT-s ep CostSum es DispUpFact re Serv rs we NullPer vt iv CalcRest ~
ev rv em wm im ot ap EDITOR-1 pc mp
&Scoped-Define DISPLAYED-OBJECTS ie VAT-SLT ee VAT-SLT-s ep CostSum es ~
DispUpFact re Serv rs we NullPer vt iv CalcRest ev rv em wm im ot ap ~
EDITOR-1 pc mp

/* Custom List Definitions                                              */
/* list-tdedt,List-2,List-3,List-4,List-5,List-6                        */
&Scoped-define list-tdedt ie ee ep es re rs we vt iv ev rv em wm im ot ap ~
pc mp

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Выбрать колонки для печати на закладке Формат можно только для Excel"
     VIEW-AS EDITOR NO-BOX
     SIZE 30 BY 2.5
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 4.83.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.29.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.67.

DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35 BY 1.67.

DEFINE VARIABLE ap AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE CalcRest AS LOGICAL INITIAL yes
     LABEL "Расчет остатков"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE CostSum AS LOGICAL INITIAL no
     LABEL "Учетные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE DispUpFact AS LOGICAL INITIAL no
     LABEL "Наценка"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE ee AS LOGICAL INITIAL yes
     LABEL "расход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE em AS LOGICAL INITIAL yes
     LABEL "расход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE ep AS LOGICAL INITIAL yes
     LABEL "возврат поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE es AS LOGICAL INITIAL yes
     LABEL "касса продажа":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE ev AS LOGICAL INITIAL yes
     LABEL "расход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE ie AS LOGICAL INITIAL yes
     LABEL "приход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE im AS LOGICAL INITIAL yes
     LABEL "приход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE iv AS LOGICAL INITIAL yes
     LABEL "приход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE mp AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 53.5 BY .75 NO-UNDO.

DEFINE VARIABLE NullPer AS LOGICAL INITIAL no
     LABEL "не удалять нулевые переоценки"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE ot AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE pc AS LOGICAL INITIAL yes
     LABEL "переоценка":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE re AS LOGICAL INITIAL yes
     LABEL "возврат внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE rs AS LOGICAL INITIAL yes
     LABEL "касса возврат":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE rv AS LOGICAL INITIAL yes
     LABEL "возврат перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE Serv AS LOGICAL INITIAL no
     LABEL "Реестр только по услугам"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE VAT-SLT AS LOGICAL INITIAL no
     LABEL "НДС и НП детально"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE VAT-SLT-s AS LOGICAL INITIAL no
     LABEL "распределение налогов"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .75 NO-UNDO.

DEFINE VARIABLE vt AS LOGICAL INITIAL yes
     LABEL "инвентаризация":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE we AS LOGICAL INITIAL yes
     LABEL "списание":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.

DEFINE VARIABLE wm AS LOGICAL INITIAL yes
     LABEL "списан. произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     ie AT ROW 1.88 COL 37
     VAT-SLT AT ROW 2.29 COL 2.38
     ee AT ROW 2.92 COL 37
     VAT-SLT-s AT ROW 3.13 COL 2.38
     ep AT ROW 3.83 COL 37
     CostSum AT ROW 3.92 COL 2.38
     es AT ROW 4.75 COL 37
     DispUpFact AT ROW 4.83 COL 2.38
     re AT ROW 5.71 COL 37
     Serv AT ROW 6.17 COL 2.38
     rs AT ROW 6.58 COL 37
     we AT ROW 7.5 COL 37
     NullPer AT ROW 7.88 COL 2.38
     vt AT ROW 8.29 COL 37
     iv AT ROW 9.29 COL 37
     CalcRest AT ROW 9.75 COL 2.38
     ev AT ROW 10.08 COL 37
     rv AT ROW 11.04 COL 37
     em AT ROW 11.88 COL 37
     wm AT ROW 12.71 COL 37
     im AT ROW 13.5 COL 37
     ot AT ROW 14.42 COL 37
     ap AT ROW 15.33 COL 37
     EDITOR-1 AT ROW 15.75 COL 2.5 NO-LABEL WIDGET-ID 2
     pc AT ROW 16.29 COL 37
     mp AT ROW 17.08 COL 37
     "Документы:" VIEW-AS TEXT
          SIZE 11 BY .75 AT ROW 1 COL 44
          FGCOLOR 4
     "Показать:" VIEW-AS TEXT
          SIZE 11 BY .75 AT ROW 1.42 COL 12
          FGCOLOR 4
     RECT-14 AT ROW 6.04 COL 1
     RECT-15 AT ROW 9.33 COL 1
     RECT-16 AT ROW 7.5 COL 1
     RECT-12 AT ROW 1.17 COL 1
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
         HEIGHT             = 17.92
         WIDTH              = 89.88.
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

/* SETTINGS FOR TOGGLE-BOX ap IN FRAME F-Main
   1                                                                    */
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR TOGGLE-BOX ee IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX em IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ep IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX es IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ev IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ie IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX im IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX iv IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX mp IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX ot IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX pc IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX re IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX rs IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX rv IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX vt IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX we IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX wm IN FRAME F-Main
   1                                                                    */
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

&Scoped-define SELF-NAME ap
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ap s-object
ON VALUE-CHANGED OF ap IN FRAME F-Main /* переоценка */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ee
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ee s-object
ON VALUE-CHANGED OF ee IN FRAME F-Main /* расход внешний */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME em
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL em s-object
ON VALUE-CHANGED OF em IN FRAME F-Main /* расход произв. */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ep s-object
ON VALUE-CHANGED OF ep IN FRAME F-Main /* возврат поставщику */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME es
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL es s-object
ON VALUE-CHANGED OF es IN FRAME F-Main /* касса продажа */
DO:
    run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ev s-object
ON VALUE-CHANGED OF ev IN FRAME F-Main /* расход перемещение */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ie
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ie s-object
ON VALUE-CHANGED OF ie IN FRAME F-Main /* приход внешний */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im s-object
ON VALUE-CHANGED OF im IN FRAME F-Main /* приход произв. */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME iv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL iv s-object
ON VALUE-CHANGED OF iv IN FRAME F-Main /* приход перемещение */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME mp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL mp s-object
ON VALUE-CHANGED OF mp IN FRAME F-Main /* переоценка */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ot s-object
ON VALUE-CHANGED OF ot IN FRAME F-Main /* переоценка */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL pc s-object
ON VALUE-CHANGED OF pc IN FRAME F-Main /* переоценка */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME re
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL re s-object
ON VALUE-CHANGED OF re IN FRAME F-Main /* возврат внешний */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs s-object
ON VALUE-CHANGED OF rs IN FRAME F-Main /* касса возврат */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rv s-object
ON VALUE-CHANGED OF rv IN FRAME F-Main /* возврат перемещение */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Serv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Serv s-object
ON VALUE-CHANGED OF Serv IN FRAME F-Main /* Реестр по услугам */
DO:
  assign serv.
  if serv then DO:
       CalcRest = false.
       disable CalcRest with frame {&frame-name}.
       display CalcRest with frame {&frame-name}.
       End.
     Else do:
       enable CalcRest with frame {&frame-name}.
       display CalcRest with frame {&frame-name}.
       End.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME vt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vt s-object
ON VALUE-CHANGED OF vt IN FRAME F-Main /* инвентаризация */
DO:
    run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME we
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL we s-object
ON VALUE-CHANGED OF we IN FRAME F-Main /* списание */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME wm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wm s-object
ON VALUE-CHANGED OF wm IN FRAME F-Main /* списан. произв. */
DO:
  run calc-rest in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  run dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF
define variable  list-com-hand as character no-undo .
list-com-hand = "" .
&scop v-str        list-com-hand = list-com-hand + string(~{&v-tt}:handle) + "," .
&scop v-tt  ie
{&v-str}
&scop v-tt  ee
{&v-str}
&scop v-tt  ep
{&v-str}
&scop v-tt  es
{&v-str}
&scop v-tt  re
{&v-str}
&scop v-tt  rs
{&v-str}
&scop v-tt  we
{&v-str}
&scop v-tt  vt
{&v-str}
&scop v-tt  iv
{&v-str}
&scop v-tt  ev
{&v-str}
&scop v-tt  rv
{&v-str}
&scop v-tt  em
{&v-str}
&scop v-tt  wm
{&v-str}
&scop v-tt  im
{&v-str}
&scop v-tt  ot
{&v-str}
&scop v-tt  ap
{&v-str}
&scop v-tt  pc
{&v-str}
&scop v-tt  mp
{&v-str}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-rest s-object
PROCEDURE calc-rest :
assign FRAME {&FRAME-NAME} {&list-tdedt}    .
if  ie
AND ee
AND  ep
AND  es
AND  re
AND  rs
AND  we
AND  vt
AND  iv
AND  ev
AND  rv
AND  em
AND  wm
AND  im
AND  ot
AND  ap
AND  pc
   then
    do:
        assign CalcRest = yes.
        DISPLAY CalcRest WITH FRAME {&FRAME-NAME}.
        ENABLE CalcRest WITH FRAME {&FRAME-NAME}.
    end.
else
    do:
        assign CalcRest = no.
        DISPLAY CalcRest WITH FRAME {&FRAME-NAME}.
        DISABLE CalcRest WITH FRAME {&FRAME-NAME}.
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object  _DEFAULT-ENABLE
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
  DISPLAY ie VAT-SLT ee VAT-SLT-s ep CostSum es DispUpFact re Serv rs we NullPer
          vt iv CalcRest ev rv em wm im ot ap EDITOR-1 pc mp
      WITH FRAME F-Main.
  ENABLE RECT-14 RECT-15 RECT-16 RECT-12 ie VAT-SLT ee VAT-SLT-s ep CostSum es
         DispUpFact re Serv rs we NullPer vt iv CalcRest ev rv em wm im ot ap
         EDITOR-1 pc mp
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------------------------------------------------------*/


  run dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-cost':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    g#log
  }
   if not  g#log then do :
   CostSum = false .
   DispUpFact = false .
   disable CostSum DispUpFact  with frame {&frame-name} .
   display CostSum  DispUpFact with frame {&frame-name} .
 end.

/* Проставим названия Документов на экране */
define variable lab-handle as handle no-undo .
define variable i as integer no-undo .
define variable v-code as character no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries (list-com-hand) .
do i = 1 to v-nn :
 lab-handle = widget-handle (entry( i , list-com-hand) ) no-error .
 if valid-handle(lab-handle) = true and  error-status :error = false   then do:
    v-code = lab-handle:name.
    lab-handle:label = func-get-name-from-ext-type ( v-code, true  ) .
    end.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
fOR EACH tdedt: DELETE tdedt. eND.
IF ie then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Vnesh}    01 }                      END.
IF ee then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh}    02 }                      END.
IF ep then  do:  { rep/r-mtdedt.i {&TDEDT_RAS_Vnesh_VP}  03}                END.
IF es then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh_Kass} 04 }            END.
IF re then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh} 05 }              END.
IF rs then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh_Kass} 06 }    END.
IF we then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Vnesh} 07 }                      END.
IF vt then  do:
                 { rep/r-mtdedt.i {&TDEDT_Inv} 08 }
                 { rep/r-mtdedt.i {&TDEDT_Peresort} 08 }                                  END.
IF iv then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Perem} 09 }                      END.
IF ev then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Perem} 10 }                      END.
IF rv then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Perem} 11 }              END.
IF em then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Prvo} 12 }                        END.
IF wm then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Prvo} 13 }                        END.
IF im then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Prvo} 14 }                        END.
IF ot then  do:  { rep/r-mtdedt.i {&TDEDT_Overturn} 15 }                        END.
IF ap then  do:  { rep/r-mtdedt.i {&TDEDT_Corr_Acc_Price} 16 }                  END.
IF pc then  do:  { rep/r-mtdedt.i {&TDEDT_Chg_Purch_Code} 17 }                  END.
IF mp then  do:  { rep/r-mtdedt.i {&TDEDT_Corr_Minus_Parts} 18 }                  END.

if serv = true then
  run rep/r-reestb.p
                 (input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type ,
                  input base-code ,
                  input VAT-SLT,
                  input VAT-SLT-s,
                  input CostSum,
                  input DispUpFact  ,
                  input Serv,
                  input ?,
                  input NullPer,
                  input CalcRest) .
 Else  run rep/r-reest2.p
                 (input v-cntxt-obj-code ,
                  input v-cntxt-obj-type ,
                  input base-type ,
                  input base-code ,
                  input VAT-SLT,
                  input VAT-SLT-s,
                  input CostSum,
                  input DispUpFact  ,
                  input Serv,
                  input ?,
                  input NullPer,
                  input CalcRest)
                  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} {&list-tdedt}
 VAT-SLT VAT-SLT-s
 CostSum DispUpFact
 Serv  NullPer CalcRest.
ReportNAme = "Р Е Е С Т Р   Д О К У М Е Н Т О В  ( Т О В А Р Н Ы Й   О Т Ч Е Т )".

ReportHeader = IF VAT-SLT THEN VAT-SLT:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF VAT-SLT-s   THEN VAT-SLT-s:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF CostSum     THEN CostSum:label + chr(10) Else "".
ReportHeader = (ReportHeader) + IF DispUpFact  THEN DispUpFact:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF  Serv       THEN Serv:label + chr(10) Else "" .
ReportHeader = (ReportHeader) + IF  NullPer    THEN NullPer:label + chr(10) Else "без нулевых остатков по переоценке" + chr(10) .
ReportHeader = (ReportHeader) + IF  CalcRest   THEN CalcRest:label + chr(10) Else ""  .
ReportHeader = (ReportHeader) + "документы : "  + chr(10).

ReportHeader = (ReportHeader)               + IF  ie THen      (ie:label) + ","  else " " .
ReportHeader = (ReportHeader)               + IF  ee then      (ee:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ep then      (ep:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  es THen      (es:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  re then      (re:label) + ","  else " ".
ReportHeader = (ReportHeader) +  chr(10).
ReportHeader = (ReportHeader)               + IF  rs then      (rs:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  we THen      (we:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  vt then      (vt:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  iv then      (iv:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ev THen      (ev:label) + ","  else " ".
ReportHeader = (ReportHeader) +  chr(10).
ReportHeader = (ReportHeader)               + IF  rv then      (rv:label) + ","  else " ".
ReportHeader = (ReportHeader)               + IF  em then      (em:label) + ","  else " " .
ReportHeader = (ReportHeader)               + IF  wm THen      wm:label + ","  else " " .
ReportHeader = (ReportHeader)               + IF  im then      im:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ap then      ap:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  pc then      pc:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  mp then      mp:label + ","  else " ".
ReportHeader = (ReportHeader)               + IF  ot then      ot:label        else " " .

 sheetf.Excel-Column-Lable =
           "Дата закрытия"
  + ","  + "№ документа"
  + ","  + "Контрагент"
  + ","  + "Количество"
  + ","  + "Сумма с НДС"
  + ","  + "Сумма без НДС"
  + ","  + "Сумма скидки"
  + ","  + "Сумма авт. переоценки"
  + ","  + "Сумма в продажных ценах"
  + ","  + "Ставка НДС"
  + ","  + "Сумма НДС"
  + ","  + "Ставка НП"
  + ","  + "Сумма налога с продаж" .

 sheetf.Sizes        =  "10,16,30,13,15,15,15,15,15,15,15,15,15" .
 sheetf.make-correct = /* "false,false,false,false,true,true,true,true,true,true,true,true,true" */

 "false,false,false,false,false,false,false,false,false,false,false,false,false"
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE report-to-ach s-object
PROCEDURE report-to-ach :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
 DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR param-to-export .

  for each  param-to-export : delete  param-to-export. end.
 { rep/par-std.i }

{ rep/par-actu.i run-proc
 "'vat-slt'                           "
 "''                                  "
 "'logical'                           "
 "string(vat-slt,'yes/no')            "
 "vat-slt:label in frame {&frame-name}"
 }

{ rep/par-actu.i run-proc
 "'vat-slt-detale'                     "
 "''                                   "
 "'logical'                            "
 "string(vat-slt-s,'yes/no')           "
 "vat-slt-s:label in frame {&frame-name}"

    }
{ rep/par-actu.i run-proc
 "'cost-sum'                                          "
 "''                                                  "
 "'logical'                                           "
 "string(costsum,'yes/no')                            "
 "costsum:label in frame {&frame-name}                "

    }
{ rep/par-actu.i run-proc
 "'discont'                                           "
 "''                                                  "
 "'logical'                                           "
 "string(dispupfact,'yes/no')                         "
 "dispupfact:label in frame {&frame-name}             "

    }
{ rep/par-actu.i run-proc
 "'service'                                           "
 "''                                                  "
 "'logical'                                           "
 "string(serv,'yes/no')                               "
 "serv:label in frame {&frame-name}                   "

    }
{ rep/par-actu.i run-proc
 "'null-pricelist'                                    "
 "''                                                  "
 "'logical'                                           "
 "string(nullper,'yes/no')                            "
 "nullper:label in frame {&frame-name}                "

    }
{ rep/par-actu.i run-proc
 "'calc-rest '                                        "
 "''                                                  "
 "'logical'                                           "
 "string(calcrest ,'yes/no')                          "
 "calcrest :label in frame {&frame-name}              "

    }
{ rep/par-actu.i run-proc
 "'ie'                           "
 "''                             "
 "'logical'                      "
 "string(ie,'yes/no')            "
 "ie:label in frame {&frame-name}"
    }
{ rep/par-actu.i run-proc
 "'ee'                           "
 "''                             "
 "'logical'                      "
 "string(ee,'yes/no')            "
 "ee:label in frame {&frame-name}"

    }
{ rep/par-actu.i run-proc
 "'ep'                           "
 "''                             "
 "'logical'                      "
 "string(ep,'yes/no')            "
 "ep:label in frame {&frame-name}"
    }
{ rep/par-actu.i run-proc
 "'es'                           "
 "''                             "
 "'logical'                      "
 "string(es,'yes/no')            "
 "es:label in frame {&frame-name}"
    }
{ rep/par-actu.i run-proc
 "'re'                           "
 "''                             "
 "'logical'                      "
 "string(re,'yes/no')            "
 "re:label in frame {&frame-name}"

    }
{ rep/par-actu.i run-proc
 "'rs'                           "
 "''                             "
 "'logical'                      "
 "string(rs,'yes/no')            "
 "rs:label in frame {&frame-name}"

    }
{ rep/par-actu.i run-proc
 "'we'                           "
 "''                             "
 "'logical'                      "
 "string(we,'yes/no')            "
 "we:label in frame {&frame-name}"

    }
{ rep/par-actu.i run-proc
 "'vt'                           "
 "''                             "
 "'logical'                      "
 "string(vt,'yes/no')            "
 "vt:label in frame {&frame-name}"


    }
{ rep/par-actu.i run-proc
 "'iv'                           "
 "''                             "
 "'logical'                      "
 "string(iv,'yes/no')            "
 "iv:label in frame {&frame-name}"

    }

{ rep/par-actu.i run-proc
 "'ev'                           "
 "''                             "
 "'logical'                      "
 "string(ev,'yes/no')            "
 "ev:label in frame {&frame-name}"
    }

{ rep/par-actu.i run-proc
 "'rv'                           "
 "''                             "
 "'logical'                      "
 "string(rv,'yes/no')            "
 "rv:label in frame {&frame-name}"

    }
{ rep/par-actu.i run-proc
 "'em'                           "
 "''                             "
 "'logical'                      "
 "string(em,'yes/no')            "
 "em:label in frame {&frame-name}"

    }
{ rep/par-actu.i run-proc
 "'wm'                           "
 "''                             "
 "'logical'                      "
 "string(wm,'yes/no')            "
 "wm:label in frame {&frame-name}"
    }
{ rep/par-actu.i run-proc
 "'im'                           "
 "''                             "
 "'logical'                      "
 "string(im,'yes/no')            "
 "im:label in frame {&frame-name}"
    }


{ rep/par-actu.i run-proc
 "'ot'                           "
 "''                             "
 "'logical'                      "
 "string(ot,'yes/no')            "
 "ot:label in frame {&frame-name}"
}

  end.  /* do */
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