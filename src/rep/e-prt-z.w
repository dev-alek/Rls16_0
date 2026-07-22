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

Состояние запаса (с учетом признаков)

Автор: Чернова Светлана Александровна
Дата создания: 06/08/01
Author: Svetlana Chernova
Creation date: 06/08/01


*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запасы по признакам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ gbl/cur-time.i }
{ rep/rep-bt.i   }


DEFINE TEMP-TABLE tt-season NO-UNDO LIKE ub.season.

&scop run-param  (input v-cntxt-obj-code ,~
  input v-cntxt-obj-type ,~
  input base-type ,~
  input base-code ,~
  input Classify,~
  input zero,~
  input zero-ost,~
  input Itog , ~
  input tog-obj , ~
  input table tt-season , ~
  input v-prizn  ) .

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable State-source    as  WIDGET-HANDLE   no-undo.
define variable v-today         as date             no-undo.
define variable v-time          as integer          no-undo.
define variable v-prizn         as character        no-undo init "".

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
&Scoped-Define ENABLED-OBJECTS RECT-12 Classify Itog Zero-ost Zero tog-obj ~
rs-prizn txt-prizn 
&Scoped-Define DISPLAYED-OBJECTS Classify Itog Zero-ost Zero tog-obj ~
rs-prizn txt-prizn 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE txt-prizn AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 38 BY 3.81 NO-UNDO.

DEFINE VARIABLE Classify AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Без классификации", 1,
"По производителю", 2,
"По группам товаров", 3,
"По НДС из карточки товара", 4
     SIZE 28.6 BY 3.71 NO-UNDO.

DEFINE VARIABLE rs-prizn AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все признаки", 1,
"Выборочно", 2
     SIZE 24 BY 1.91 NO-UNDO.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 77.8 BY 18.67.

DEFINE VARIABLE Itog AS LOGICAL INITIAL no 
     LABEL "Только итоги" 
     VIEW-AS TOGGLE-BOX
     SIZE 28.8 BY .81 NO-UNDO.

DEFINE VARIABLE tog-obj AS LOGICAL INITIAL yes 
     LABEL "Раздельно по объектам" 
     VIEW-AS TOGGLE-BOX
     SIZE 28.8 BY .81 NO-UNDO.

DEFINE VARIABLE Zero AS LOGICAL INITIAL no 
     LABEL "Нулевые количества по признакам" 
     VIEW-AS TOGGLE-BOX
     SIZE 34.6 BY .81 NO-UNDO.

DEFINE VARIABLE Zero-ost AS LOGICAL INITIAL no 
     LABEL "Нулевые остатки" 
     VIEW-AS TOGGLE-BOX
     SIZE 34.6 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify AT ROW 2.38 COL 3 NO-LABEL
     Itog AT ROW 7.76 COL 3
     Zero-ost AT ROW 8.62 COL 3 WIDGET-ID 2
     Zero AT ROW 9.62 COL 3
     tog-obj AT ROW 10.62 COL 3
     rs-prizn AT ROW 13.48 COL 3 NO-LABEL WIDGET-ID 4
     txt-prizn AT ROW 15.52 COL 3 NO-LABEL WIDGET-ID 12
     "Классификация:":C28 VIEW-AS TEXT
          SIZE 28.8 BY .76 AT ROW 1.43 COL 3
          FGCOLOR 4 
     "Показать:":C28 VIEW-AS TEXT
          SIZE 28.8 BY .76 AT ROW 6.81 COL 3
          FGCOLOR 4 
     "Признаки:":C28 VIEW-AS TEXT
          SIZE 28.8 BY .76 AT ROW 12.52 COL 3 WIDGET-ID 8
          FGCOLOR 4 
     RECT-12 AT ROW 1.14 COL 1
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
         HEIGHT             = 18.91
         WIDTH              = 77.8.
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
       txt-prizn:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME rs-prizn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-prizn s-object
ON MOUSE-SELECT-DBLCLICK OF rs-prizn IN FRAME F-Main
    do:
apply "VALUE-CHANGED" to rs-prizn in frame F-Main.
END.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tog-obj s-object

ON VALUE-CHANGED OF tog-obj IN FRAME F-Main /* Раздельно по объектам */
DO:
  ASSIGN tog-obj.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-prizn s-object
ON VALUE-CHANGED OF rs-prizn IN FRAME F-Main
DO:
    define variable prizn-cur as integer no-undo init 0.
    assign rs-prizn.
    case rs-prizn:
        when 1 then do:
            v-prizn = "".
            txt-prizn:screen-value = "Выбраны признаки: все.".
        end.
        when 2 then do:
            run rep/e-prt-z-d.p (input my-handle, input-output v-prizn).
            if v-prizn = "" then do:
                rs-prizn = 1.
                rs-prizn:screen-value = "1".
                txt-prizn:screen-value = "Выбраны признаки: все.".
            end.
            else do:
                v-prizn = right-trim(v-prizn,",").
                txt-prizn:screen-value = "Выбраны признаки: ".
                do while prizn-cur < num-entries(v-prizn,","):
                    prizn-cur = prizn-cur + 1.
                    for first gds-prt where gds-prt.node-code = integer(entry(prizn-cur, v-prizn, ",")) no-lock:
                        txt-prizn:screen-value = txt-prizn:screen-value + gds-prt.f-name + ", ".
                    end.
                end.
                txt-prizn:screen-value = right-trim(txt-prizn:screen-value, ", ").
            end.
        end.
    end case.
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
  DISPLAY Classify Itog Zero-ost Zero tog-obj rs-prizn txt-prizn 
      WITH FRAME F-Main.
  ENABLE RECT-12 Classify Itog Zero-ost Zero tog-obj rs-prizn txt-prizn 
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
------------------------------------------------------------------------------*/
define buffer tt-goods for goods .
define variable v-col-rec  as integer init 0 no-undo .

if x-selectgood = {&g-grp} then do:
v-col-rec = 0.
for each gds-list : delete gds-list . end.
    for each tmp#grp :
      for each tt-goods no-lock where tt-goods.grp-name begins tmp#grp.grp-name :
        create gds-list.
        buffer-copy tt-goods to gds-list.
        v-col-rec = 1 + v-col-rec  .
      end.
    end.
  if v-col-rec = 0 then do:
  message "Не выбрана группа товаров !!" view-as alert-box information .
  return  .
  end.
end.

if x-selectgood = {&g-prod} then do:
v-col-rec = 0.
for each gds-list : delete gds-list . end.
    for each g#cli :
      for each tt-goods no-lock where tt-goods.prod-code = g#cli.obj-code and
                                      tt-goods.prod-type = g#cli.obj-type
       :
        v-col-rec = 1 + v-col-rec  .
        create gds-list.
        buffer-copy tt-goods to gds-list.
      end.
    end.
  if v-col-rec = 0 then do:
  message "Не выбраны производители !!" view-as alert-box information .
  return  .
  end.


end.

run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
if tog-obj = true then do:
If x-date-alone <> v-today Then do:
      if x-SelectGood = 1 Then DO:
          If x-SET_val_TYPE = 1 /* р_у_б */
            then DO :
                run rep/r-prt-z5.p
                   {&run-param}
                End.
            Else do:
                run rep/r-prt-z6.p
                    {&run-param}
                End.
      End.
      Else DO:
          If x-SET_val_TYPE = 1 /* р_у_б */
            then do:
                run rep/r-prt-z7.p
                    {&run-param}
                End.
            Else do:
                run rep/r-prt-z8.p
                    {&run-param}
                End.
      End.

End.
Else do:
      if x-SelectGood = 1 Then DO:
          If x-SET_val_TYPE = 1 /* р_у_б */
            then DO :
                run rep/r-prt-z1.p
                    {&run-param}
                End.
            Else do:
                run rep/r-prt-z2.p
                    {&run-param}
                End.
      End.
      Else DO:
          If x-SET_val_TYPE = 1 /* р_у_б */
            then do:
                run rep/r-prt-z3.p
                    {&run-param}
                End.
            Else do:
                run rep/r-prt-z4.p
                    {&run-param}
                End.
      End.
End.
End.
else do: /* раздельно */
    If x-date-alone <> v-today Then do:
          if x-SelectGood = 1 Then DO:
              If x-SET_val_TYPE = 1 /* р_у_б */
                then DO :
                    run rep/r-prttz5.p
                      {&run-param}
                    End.
                Else do:
                    run rep/r-prttz6.p
                        {&run-param}
                    End.
          End.
          Else DO:
              If x-SET_val_TYPE = 1 /* р_у_б */
                then do:
                    run rep/r-prttz7.p
                        {&run-param}
                    End.
                Else do:
                    run rep/r-prttz8.p
                        {&run-param}
                    End.
          End.

    End.
    Else do:
          if x-SelectGood = 1 Then DO:
              If x-SET_val_TYPE = 1 /* р_у_б */
                then DO :
                    run rep/r-prttz1.p
                        {&run-param}
                    End.
                Else do:
                    run rep/r-prttz2.p
                        {&run-param}
                    End.
          End.
          Else DO:
              If x-SET_val_TYPE = 1 /* р_у_б */
                then do:
                    run rep/r-prttz3.p
                        {&run-param}
                    End.
                Else do:
                    run rep/r-prttz4.p
                        {&run-param}
                    End.
          End.
    End.

end.
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
 Classify itog zero zero-ost tog-obj .

Sheetf.Excel-Column-Lable =
"N п\п,
Код,
Артикул,
Название товара ,
Признак товара,
Количество,
Учетные цена с НДС,
Сумма в уч.ценах,
Продажная цена,
Суммы в продажных ценах,
% наценки,
Свободное количество,
Ожидаемое количество,
Резерв количество,
Сумма в учетных ценах,
Сумма в ценах докум.,
Учетная цена резерва," .

Sheetf.ColFormat = "2=@;3=@;4=@;5=@"  .
Sheetf.make-correct = fill ("true ," , 17) .

Sheetf.Sizes = "6,16,9,60,20," + fill ("15,", 12)  .
 run cur-time in this-procedure ( output v-today
                                , output v-time
                                ).
 if x-date-alone  <> v-today then
     Sheetf.rights-column =
     "true  ,true ,true ,true ,true ,true ,true ,true, true ,true ,true, false ,true ,false ,false ,false ,false ," .
     else
      Sheetf.rights-column  =  fill ("true ," , 17) .

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

