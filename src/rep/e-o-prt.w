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

Оборотная ведомость с учетом признаков

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Created: 02/08/01
*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Оборотная ведомость с учетом признаков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/cur-time.i }
{ rep/gn-extp.i  }


&scop run-param  (input v-cntxt-obj-code ,~
  input v-cntxt-obj-type ,~
  input base-type ,~
  input base-code ,~
  input Classify,~
  input Itog, input tog-zero) .

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source    as  WIDGET-HANDLE  no-undo.
define variable v-today         as date            no-undo.
define variable v-time          as integer         no-undo.


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
&Scoped-Define ENABLED-OBJECTS RECT-12 RECT-10 Classify ie ee ep es re rs ~
Itog we tog-zero vt iv ev rv em wm im ot
&Scoped-Define DISPLAYED-OBJECTS Classify ie ee ep es re rs Itog we ~
tog-zero vt ShowZero-3 iv ev rv em wm im ot

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE Classify AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", 1,
"По производителю", 2,
"По группам товаров", 3,
"По НДС из карточки товара", 4
     SIZE 28.63 BY 3.71 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.63 BY 16.83.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46.5 BY 16.83.

DEFINE VARIABLE ee AS LOGICAL INITIAL yes
     LABEL "расход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE em AS LOGICAL INITIAL yes
     LABEL "расход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ep AS LOGICAL INITIAL yes
     LABEL "возврат поставщику"
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE es AS LOGICAL INITIAL yes
     LABEL "касса продажа":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ev AS LOGICAL INITIAL yes
     LABEL "расход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ie AS LOGICAL INITIAL yes
     LABEL "приход внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE im AS LOGICAL INITIAL yes
     LABEL "приход произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE Itog AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE iv AS LOGICAL INITIAL yes
     LABEL "приход перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ot AS LOGICAL INITIAL no
     LABEL "переоценка":L27
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE re AS LOGICAL INITIAL yes
     LABEL "возврат внешний":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE rs AS LOGICAL INITIAL yes
     LABEL "касса возврат":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE rv AS LOGICAL INITIAL yes
     LABEL "возврат перемещение":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE ShowZero-3 AS LOGICAL INITIAL no
     LABEL "Все товары"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY .83 NO-UNDO.

DEFINE VARIABLE tog-zero AS LOGICAL INITIAL no
     LABEL "Нулевые обороты"
     VIEW-AS TOGGLE-BOX
     SIZE 28.88 BY .83 NO-UNDO.

DEFINE VARIABLE vt AS LOGICAL INITIAL yes
     LABEL "инвентаризация":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE we AS LOGICAL INITIAL yes
     LABEL "списание":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.

DEFINE VARIABLE wm AS LOGICAL INITIAL yes
     LABEL "списан. произв.":L
     VIEW-AS TOGGLE-BOX
     SIZE 27.63 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify AT ROW 2.38 COL 3 NO-LABEL
     ie AT ROW 2.46 COL 49.63
     ee AT ROW 3.42 COL 49.63
     ep AT ROW 4.33 COL 49.63
     es AT ROW 5.25 COL 49.63
     re AT ROW 6.21 COL 49.63
     rs AT ROW 7.08 COL 49.63
     Itog AT ROW 7.75 COL 3
     we AT ROW 8 COL 49.63
     tog-zero AT ROW 8.67 COL 3
     vt AT ROW 8.79 COL 49.63
     ShowZero-3 AT ROW 9.5 COL 3
     iv AT ROW 9.79 COL 49.63
     ev AT ROW 10.75 COL 49.63
     rv AT ROW 11.71 COL 49.63
     em AT ROW 12.63 COL 49.63
     wm AT ROW 13.58 COL 49.63
     im AT ROW 14.5 COL 49.63
     ot AT ROW 15.42 COL 49.63
     "Оборот (выборочно):":C27 VIEW-AS TEXT
          SIZE 27.63 BY .75 AT ROW 1.5 COL 49.75
          FGCOLOR 4
     "Классификация:":C28 VIEW-AS TEXT
          SIZE 28.75 BY .75 AT ROW 1.42 COL 3
          FGCOLOR 4
     "Показать:":C28 VIEW-AS TEXT
          SIZE 28.75 BY .75 AT ROW 6.79 COL 3
          FGCOLOR 4
     RECT-12 AT ROW 1.13 COL 1
     RECT-10 AT ROW 1.13 COL 47.63
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
         HEIGHT             = 17.25
         WIDTH              = 77.88.
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

/* SETTINGS FOR TOGGLE-BOX ShowZero-3 IN FRAME F-Main
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

&Scoped-define SELF-NAME tog-zero
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-zero s-object
ON VALUE-CHANGED OF tog-zero IN FRAME F-Main /* Нулевые обороты */
DO:
   run p-val in this-procedure.
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
  DISPLAY Classify ie ee ep es re rs Itog we tog-zero vt ShowZero-3 iv ev rv em
          wm im ot
      WITH FRAME F-Main.
  ENABLE RECT-12 RECT-10 Classify ie ee ep es re rs Itog we tog-zero vt iv ev
         rv em wm im ot
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
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


run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
/* message x-date-end v-today . */
if x-date-end <> v-today then do:
  tog-zero = false.
  disable  tog-zero with frame {&frame-name}.
  display  tog-zero with frame {&frame-name}.

end.
else do:
  enable  tog-zero with frame {&frame-name}.
  display  tog-zero with frame {&frame-name}.
end.
 run p-val in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
fOR EACH tdedt SHARE-LOCK: DELETE tdedt. eND.
IF ie then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Vnesh}    01 }                   END.
IF ee then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh}    02 }                   END.
IF ep then  do:  { rep/r-mtdedt.i {&TDEDT_RAS_Vnesh_VP}  03}                   END.
IF es then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Vnesh_Kass} 04 }                 END.
IF re then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh} 05 }                  END.
IF rs then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh_Kass} 06 }             END.
IF we then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Vnesh} 07 }                      END.
IF vt then  do:  { rep/r-mtdedt.i {&TDEDT_Inv} 08 }                            END.
IF iv then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Perem} 09 }                      END.
IF ev then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Perem} 10 }                      END.
IF rv then  do:  { rep/r-mtdedt.i {&TDEDT_Vozvrat_Perem} 11 }                  END.
IF em then  do:  { rep/r-mtdedt.i {&TDEDT_Ras_Prvo} 12 }                       END.
IF wm then  do:  { rep/r-mtdedt.i {&TDEDT_Spi_Prvo} 13 }                       END.
IF im then  do:  { rep/r-mtdedt.i {&TDEDT_Pri_Prvo} 14 }                       END.
IF ot then  do:  { rep/r-mtdedt.i {&TDEDT_Overturn} 15 }                       END.
IF vt then  do:  { rep/r-mtdedt.i {&TDEDT_Corr_Acc_Price} 16 }                END.

run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).

      if x-SelectGood = 1 Then DO:
          If x-SET_val_TYPE = 1 /* р_у_б */
            then DO :
                run rep/r-o-prt5.p
                    {&run-param}
                End.
            Else do:
                run rep/r-o-prt6.p
                    {&run-param}
                End.
      End.
      Else DO:
          If x-SET_val_TYPE = 1 /* р_у_б */
            then do:
                run rep/r-o-prt7.p
                    {&run-param}
                End.
            Else do:
                run rep/r-o-prt8.p
                   {&run-param}
                End.
      End.

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
 ie
 ee
 ep
 es
 re
 rs
 we
 vt

 iv
 ev
 rv
 em
 wm
 im
 ot
 Classify itog tog-zero ShowZero-3.

v-show-all-goods  = ShowZero-3 .
run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
if tog-zero = true and x-date-end <> v-today then do:
  tog-zero = false.
  disable  tog-zero with frame {&frame-name}.
  display  tog-zero with frame {&frame-name}.
end.
else do:
  /* enable  tog-zero with frame {&frame-name}. */
  display  tog-zero with frame {&frame-name}.
end.
run p-val in this-procedure.


ReportHeader =  "Оборот (выборочно) по типам документов : "  + chr(10).
ReportHeader = (ReportHeader) + IF  ie THen      String(ie:label) + ","  else "" .
ReportHeader = (ReportHeader) + IF  ee then      String(ee:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  ep then      String(ep:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  es THen      String(es:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  re then      String(re:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  rs then      String(rs:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  we THen      String(we:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  vt then      String(vt:label) + " с учетом корр.уч.цены,"  else "".

ReportHeader = (ReportHeader) + IF  iv then      String(iv:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  ev THen      String(ev:label) + ","  else "".
ReportHeader = (ReportHeader) + chr(10).
ReportHeader = (ReportHeader) + IF  rv then      String(rv:label) + ","  else "".
ReportHeader = (ReportHeader) + IF  em then      String(em:label) + ","  else "" .
ReportHeader = (ReportHeader) + IF  wm THen      wm:label + ","  else "" .
ReportHeader = (ReportHeader) + IF  im then      im:label + ","  else "".
ReportHeader = (ReportHeader) + IF  ot then      ot:label        else "" .

if tog-zero then ReportHeader = (ReportHeader) +  chr(10) + 'с нулевыми оборотами '.
if ShowZero-3 then ReportHeader = (ReportHeader) +  chr(10) + 'все выбранные товары '.


Sheetf.Excel-Column-Lable =
     "N п\п,Код,Артикул,Название товара ,Оборот выборочно,,,,,Весь оборот за период,,,Остатки,,," + {&new-line} +
    ",,,,Количество,Сумма в учетных ценах,Сумма в ценах документа,В том числе скидки,Сумма в продажных ценах," +
   "Количество,Сумма в учетных ценах,Сумма в продажных ценах,Количество,Сумма в учетных ценах,Сумма в продажных ценах," .
Sheetf.Sizes = "6,10,16,25,12,13,13,10,13,12,13,13,12,13,13,".
Sheetf.ColFOrmat = "3=@;4=@"  .
 make-correct = Fill("true,", 15).
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

  /*
    tog-zero = false .
    disable  tog-zero with frame {&frame-name}.
 */

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p-val W-Win
PROCEDURE p-val :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  ASSIGN frame {&frame-name} tog-zero.
  IF tog-zero THEN DO:
     enable ShowZero-3 with  frame {&frame-name} .
     display ShowZero-3 with  frame {&frame-name} .
  END.
  ELSE DO:
     ShowZero-3 = false .
     disable ShowZero-3 with  frame {&frame-name} .
     hide ShowZero-3 in frame {&frame-name} .
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME