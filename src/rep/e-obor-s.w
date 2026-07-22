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

Оборотная ведомость сводная (закладка № 2)

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
def var vss-description as character no-undo init "Оборотная ведомость сводная (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/rep-bt.i  }
{ rep/par-actu.i }
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.

define variable glog as logical no-undo .
&scop run-param   ( input t-txt      , input v-cntxt-obj-code , ~
                    input v-cntxt-obj-type , input buf_currency.curr-abbr  , input v-base-code  , input Classify , input SortType ,~
                    input SumsOnly   , input ShowZero   , input ShowZero-2 , input tog-obj  , input tog-lavel,~
                    input var-lavel  , input vat-cost   , input vat-crsa   , input vat-sale   ) .


define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_currency for ub.currency.
{ gbl/basecode.i v-cntxt-host-code-obj v-base-code }
find first buf_currency no-lock where
           buf_currency.curr-code = v-base-code.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-8 RECT-9 RECT-5 SortType Tog-obj ~
Classify ShowZero-2 VAT-Cost VAT-CRSA ShowZero VAT-sale T-txt
&Scoped-Define DISPLAYED-OBJECTS SortType Tog-obj Classify ShowZero-2 ~
VAT-Cost VAT-CRSA ShowZero VAT-sale SumsOnly T-txt ShowZero-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-6 VAT-Cost VAT-CRSA VAT-sale

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE var-lavel AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Производители", "prod":U,
"Группы товаров", "grp-goods":U,
"Производители/Группы товаров", "prod/grp-goods":U,
"Группы товаров/Производители", "grp-goods/prod":U,
"Ставка НДС", "vat-ps":U
     SIZE 47.13 BY 6.29 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-artic":U,
"по наименованию", "sort-name":U
     SIZE 19 BY 2.54 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.88 BY 9.54.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 26 BY 9.54.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 75.75 BY 7.08.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 75.75 BY 16.67.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE ShowZero-2 AS LOGICAL INITIAL no
     LABEL "Нулевые обороты":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE ShowZero-3 AS LOGICAL INITIAL no
     LABEL "Все товары":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги":L
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE T-txt AS LOGICAL INITIAL no
     LABEL "Подготовить текстовый файл с разделителем <TAB>"
     VIEW-AS TOGGLE-BOX
     SIZE 49.88 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.63 BY 1 NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     SIZE 47.25 BY 1 NO-UNDO.

DEFINE VARIABLE VAT-Cost AS LOGICAL INITIAL no
     LABEL "НДС в учетных ценах":L
     VIEW-AS TOGGLE-BOX
     SIZE 25.63 BY .83 NO-UNDO.

DEFINE VARIABLE VAT-CRSA AS LOGICAL INITIAL no
     LABEL "НДС в продажных ценах":L
     VIEW-AS TOGGLE-BOX
     SIZE 25.63 BY .83 NO-UNDO.

DEFINE VARIABLE VAT-sale AS LOGICAL INITIAL no
     LABEL "НДС в ценах документа":L
     VIEW-AS TOGGLE-BOX
     SIZE 25.63 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SortType AT ROW 2.5 COL 51.88 NO-LABEL
     Tog-obj AT ROW 2.54 COL 2.13
     Classify AT ROW 3.79 COL 2.13 NO-LABEL
     Tog-lavel AT ROW 5.96 COL 21.38
     var-lavel AT ROW 6 COL 32.63 COLON-ALIGNED NO-LABEL
     ShowZero-2 AT ROW 12.04 COL 2.38
     VAT-Cost AT ROW 12.04 COL 22.5
     VAT-CRSA AT ROW 12.92 COL 22.5
     ShowZero AT ROW 13 COL 2.5
     VAT-sale AT ROW 13.83 COL 22.5
     SumsOnly AT ROW 14 COL 2.5
     T-txt AT ROW 15 COL 2.38
     ShowZero-3 AT ROW 16 COL 2.5
     "Показать :" VIEW-AS TEXT
          SIZE 46.13 BY .75 AT ROW 11 COL 2.38
          FGCOLOR 4
     "Классификация :" VIEW-AS TEXT
          SIZE 47 BY .75 AT ROW 1.46 COL 2.38
          FGCOLOR 4
     "Сортировка товара :" VIEW-AS TEXT
          SIZE 24.25 BY .67 AT ROW 1.42 COL 51.63
          FGCOLOR 4
     RECT-6 AT ROW 1 COL 50.75
     RECT-8 AT ROW 10.58 COL 1
     RECT-9 AT ROW 1 COL 1
     RECT-5 AT ROW 1 COL 1
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
         WIDTH              = 75.88.
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
/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX Tog-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN var-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX VAT-Cost IN FRAME F-Main
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX VAT-CRSA IN FRAME F-Main
   6                                                                    */
/* SETTINGS FOR TOGGLE-BOX VAT-sale IN FRAME F-Main
   6                                                                    */
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

   if Classify = "grp-goods":U
         Then do:
            display TOG-lavel   with frame {&FRAME-NAME} .
            enable  TOG-lavel   with frame {&FRAME-NAME} .
        end.
         Else do:
            display  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel with frame {&FRAME-NAME} .
        end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ShowZero
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ShowZero s-object
ON VALUE-CHANGED OF ShowZero IN FRAME F-Main /* Нулевые остатки */
DO:
   assign ShowZero.
  if ShowZero = no then do:

     ShowZero-3 = no .
     display ShowZero-3 with frame {&frame-name} .
     disable ShowZero-3 with frame {&frame-name} .
  end.
  else enable ShowZero-3 with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ShowZero-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ShowZero-2 s-object
ON VALUE-CHANGED OF ShowZero-2 IN FRAME F-Main /* Нулевые обороты */
DO:
    assign ShowZero-2.
  if ShowZero-2 = no then do:
     ShowZero = no .
     ShowZero-3 = no .
     display ShowZero ShowZero-3 with frame {&frame-name} .
     disable ShowZero ShowZero-3 with frame {&frame-name} .
  end.
  else enable ShowZero with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-lavel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-lavel s-object
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main /* с уровня */
DO:
    Assign tog-lavel.
  if tog-lavel =TRUE
        Then do:
            display  var-Lavel  with frame {&FRAME-NAME} .
            enable   var-Lavel  with frame {&FRAME-NAME} .
        end.
         Else do:
            display    var-Lavel with frame {&FRAME-NAME} .
            disable    var-Lavel with frame {&FRAME-NAME} .
        end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object

{ gbl/getcntxt.i get " " my-handle }
{ rep/par-actu.i proc }
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
   Tog-obj:screen-value in frame {&frame-name} = 'yes':U.
   var-lavel:screen-value in frame {&frame-name} = '1'.

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
    glog
  }
 if not glog then
    disable vat-Cost with frame {&frame-name}.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-crsa':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    glog
  }
 if not glog then
    disable vat-crsa with frame {&frame-name}.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reports_lookup-sale':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    false
    glog
  }
 if not glog then
    disable vat-sale with frame {&frame-name}.




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :

case SortType :
  when "sort-artic" then do:
    run proc-r in this-procedure .
  end.
  when "sort-code" then do:
    run proc-c in this-procedure .
  end.
  when "sort-name" then do:
    run proc-n in this-procedure .
  end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} SumsOnly ShowZero tog-obj ShowZero-2
tog-lavel var-lavel Classify T-txt
 SortType
   {&List-6}
   ShowZero-3 .
v-show-all-goods  = ShowZero-3 .

if x-SelectObject = {&obj-currency} and tog-obj = false then tog-obj = true .

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


ReportNAme = "О Т Ч Е Т   О   С О С Т О Я Н И И   З А П А С А   И   П Р О Д А Ж А Х   ( сводная оборотная ведомость )".
{ rep/claslabl.i }
ReportHeader = "Классификация : " + t-Class.
ReportHeader = ReportHeader +
               (if tog-lavel  then "    Итоги с уровня  "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader  + chr(10).

ReportHeader = ReportHeader +
               "Сортировка " + t-Sort + chr(10) +
               "Показать : " +
               (if SumsOnly     then "Только итоги, "  else " "            ) +
               (if Show-Cost     then "Суммы в учетных ценах, "  else " "   ) +
               (if Show-Crsa     then "Суммы в продажных ценах, "  else " " ) +
               (if Show-Sale     then "Суммы в продажных ценах документа , "  else " " ) +
               (if vat-Cost     then "НДС в учетных ценах, "  else " "   ) +
               (if vat-Crsa     then "НДС в продажных ценах, "  else " " ) +
               (if vat-Sale     then "НДС в продажных ценах документа , "  else " " ) +
               (if ShowZero-3     then " Показывать все выбранные товары "  else " " ) +
               (if ShowZero-2    then "Показывать нулевые обороты "  else "Не показывать нулевые обороты" )  +
               (if ShowZero     then "Показывать нулевые остатки "  else "Не показывать нулевые остатки" ) .

Sheetf.Excel-Column-Lable = "Код,Артикул,Название товара ,Ед.изм,т/у,Скидка,Остаток на  начало,,,,,,,Приход,,,,,,,Расход,,,,,,,Касса,,,,,,,Инвентаризация,,,,,,,Переоценка,,,,,,,Остаток на конец,,,,,,,, "  + chr(10).
Sheetf.Excel-Column-Lable = Excel-Column-Lable + ",,,,,, " +
      Fill ( "кол-во ,учет.сумма ,прод.сумма ,в ценах док-та ,учет.НДС,прод.НДС,НДС в ценах док-та ," , 7) .
Sheetf.Sizes = "10,16,60,7,3,13," + Fill("13,", 49) .
Sheetf.make-correct = fill("false,", 55) .
Sheetf.ColFOrmat = "2=@;3=@"  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE report-to-ach s-object
PROCEDURE report-to-ach :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR param-to-export .

  for each  param-to-export : delete  param-to-export. end.
{ rep/par-std.i }


{ rep/par-actu.i run-proc
 "'classify '                           "
 "''                             "
 "'character'                      "
 "string(classify)            "
 "'классификация' "
}

{ rep/par-actu.i run-proc
 "'sorttype '                           "
 "''                             "
 "'character'                      "
 "string(sorttype )            "
 "'тип сортировки'"
}

{ rep/par-actu.i run-proc
 "'sumsonly'                           "
 "''                             "
 "'logical'                      "
 "string(sumsonly,'yes/no')            "
 "sumsonly:label in frame {&frame-name}"
}

{ rep/par-actu.i run-proc
 "'showzero'                           "
 "''                             "
 "'logical'                      "
 "string(showzero,'yes/no')            "
 "showzero:label in frame {&frame-name}"
}

{ rep/par-actu.i run-proc
 "'showzero-2'                           "
 "''                             "
 "'logical'                      "
 "string(showzero-2,'yes/no')            "
 "showzero-2:label in frame {&frame-name}"
}

{ rep/par-actu.i run-proc
 "'tog-obj'                           "
 "''                             "
 "'logical'                      "
 "string(tog-obj,'yes/no')            "
 "tog-obj:label in frame {&frame-name}"
}

{ rep/par-actu.i run-proc
 "'tog-lavel'                           "
 "''                             "
 "'logical'                      "
 "string(tog-lavel,'yes/no')            "
 "tog-lavel:label in frame {&frame-name}"
}

{ rep/par-actu.i run-proc
 "'var-lavel'                           "
 "''                             "
 "'logical'                      "
 "string(var-lavel)            "
 "'номер уровеня'"
}

{ rep/par-actu.i run-proc
 "'vat-cost'                           "
 "''                             "
 "'logical'                      "
 "string(vat-cost,'yes/no')            "
 "vat-cost:label in frame {&frame-name}"
}

{ rep/par-actu.i run-proc
 "'vat-crsa'                           "
 "''                             "
 "'logical'                      "
 "string(vat-crsa,'yes/no')            "
 "vat-crsa:label in frame {&frame-name}"
}

{ rep/par-actu.i run-proc
 "'vat-sale '                           "
 "''                             "
 "'logical'                      "
 "string(vat-sale ,'yes/no')            "
 "vat-sale :label in frame {&frame-name}"
}

find first param-to-export where param-to-export.param-code =  "set-pay-type" and
                                 param-to-export.param-sub-code = "" no-error .
if available param-to-export then do:   delete param-to-export . end.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-r W-Win
PROCEDURE proc-r :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/r-obr-1y.p
           {&run-param}
      else
        run rep/r-obr-1n.p
            {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/r-obr-3y.p
            {&run-param}
      else
        run rep/r-obr-3n.p
            {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/r-obr-2y.p
           {&run-param}
      else
        run rep/r-obr-2n.p
            {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/r-obr-4y.p
            {&run-param}
      else
        run rep/r-obr-4n.p
            {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/r-obr-5y.p
            {&run-param}
      else
        run rep/r-obr-5n.p
            {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/r-obr-6y.p
            {&run-param}
      else
        run rep/r-obr-6n.p
           {&run-param}
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-c W-Win
PROCEDURE proc-c :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/r-obc-1y.p
           {&run-param}
      else
        run rep/r-obc-1n.p
            {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/r-obc-3y.p
            {&run-param}
      else
        run rep/r-obc-3n.p
            {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/r-obc-2y.p
           {&run-param}
      else
        run rep/r-obc-2n.p
            {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/r-obc-4y.p
            {&run-param}
      else
        run rep/r-obc-4n.p
            {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/r-obc-5y.p
            {&run-param}
      else
        run rep/r-obc-5n.p
            {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/r-obc-6y.p
            {&run-param}
      else
        run rep/r-obc-6n.p
           {&run-param}
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-n W-Win
PROCEDURE proc-n :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 case Classify :
  when "no-classify" then do:
     if tog-obj = true then
        run rep/r-obn-1y.p
           {&run-param}
      else
        run rep/r-obn-1n.p
            {&run-param}
  end.

  when "prod" then do:
     if tog-obj = true then
        run rep/r-obn-3y.p
            {&run-param}
      else
        run rep/r-obn-3n.p
            {&run-param}
  end.
  when "grp-goods" then do:
     if tog-obj = true then
        run rep/r-obn-2y.p
           {&run-param}
      else
        run rep/r-obn-2n.p
            {&run-param}
  end.
  when "prod/grp-goods" then do:
     if tog-obj = true then
        run rep/r-obn-4y.p
            {&run-param}
      else
        run rep/r-obn-4n.p
            {&run-param}
  end.
  when "grp-goods/prod" then do:
     if tog-obj = true then
        run rep/r-obn-5y.p
            {&run-param}
      else
        run rep/r-obn-5n.p
            {&run-param}
  end.
  when "vat-ps" then do:
     if tog-obj = true then
        run rep/r-obn-6y.p
            {&run-param}
      else
        run rep/r-obn-6n.p
           {&run-param}
  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME