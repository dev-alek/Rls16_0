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

Оборотная ведомость детализированная (закладка № 2)

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость детализированная (закладка № 2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable State-source as WIDGET-HANDLE.
define variable print-o      as char init ""  no-undo .
define variable prod-zen     as logical init no  no-undo .
define variable AltObj-list  as character no-undo .

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ trg/factord.i  }
{ rep/rep-bt.i }
{ gbl/userobjs.i }

/*{ rep/r-sym.i }*/

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
&Scoped-Define ENABLED-OBJECTS RECT-7 RECT-5 RECT-8 RECT-6 SortType Tog-obj ~
Classify RADIO-Nomenkl ShowZero-2 RADIO-SET-1 RADIO-AltObj B-columns ~
TOGGLE-1 FILL-IN-31 FILL-IN-30 FILL-IN-33 FILL-IN-32 no-nds
&Scoped-Define DISPLAYED-OBJECTS SortType Tog-obj Classify RADIO-Nomenkl ~
ShowZero-2 RADIO-SET-1 RADIO-AltObj ShowZero SumsOnly no-nds TOGGLE-1 ~
FILL-IN-31 FILL-IN-30 FILL-IN-33 FILL-IN-32

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-columns
     LABEL "Выбор колонок для печати"
     SIZE 26.38 BY 1 TOOLTIP "Выбор колонок для печати".

DEFINE VARIABLE FILL-IN-30 AS CHARACTER FORMAT "X(30)":U INITIAL "Альтернативные объекты :"
      VIEW-AS TEXT
     SIZE 26.63 BY .92
     FGCOLOR 4 .

DEFINE VARIABLE FILL-IN-31 AS CHARACTER FORMAT "X(56)":U INITIAL "Номенклатура :"
      VIEW-AS TEXT
     SIZE 23.88 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-32 AS CHARACTER FORMAT "X(30)":U INITIAL "Наименование товара :"
      VIEW-AS TEXT
     SIZE 22.5 BY .92
     FGCOLOR 4 .

DEFINE VARIABLE FILL-IN-33 AS CHARACTER FORMAT "X(30)":U INITIAL "Показать :"
      VIEW-AS TEXT
     SIZE 12.75 BY .92
     FGCOLOR 4 .

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
     size 46.88 by 6.29 NO-UNDO.

DEFINE VARIABLE RADIO-AltObj AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет", 1,
"Все", 2,
"Выборочно", 3
     SIZE 19.13 BY 3.63 NO-UNDO.

DEFINE VARIABLE RADIO-Nomenkl AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вся", 1,
"Текущая", 2,
"Удаленная", 3
     SIZE 19.13 BY 3.63 NO-UNDO.

DEFINE VARIABLE RADIO-SET-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "русское", 1,
"английское", 2,
"2 наименования", 3
     SIZE 20.25 BY 3.67 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-article":U
     size 14 by 2.17 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.13 BY 9.33.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27.38 BY 3.96.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27.38 BY 5.13.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.25 BY 7.25.

DEFINE VARIABLE no-nds AS LOGICAL INITIAL no
     LABEL "Учет. цены без НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 21.75 BY .83 NO-UNDO.

DEFINE VARIABLE ShowZero AS LOGICAL INITIAL no
     LABEL "Нулевые остатки":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.

DEFINE VARIABLE ShowZero-2 AS LOGICAL INITIAL no
     LABEL "Нулевые обороты":L
     VIEW-AS TOGGLE-BOX
     size 19 by 0.83 NO-UNDO.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY .83 NO-UNDO.

DEFINE VARIABLE Tog-lavel AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     size 11.38 by 1 NO-UNDO.

DEFINE VARIABLE Tog-obj AS LOGICAL INITIAL yes
     LABEL "Раздельно по объектам":L
     VIEW-AS TOGGLE-BOX
     size 47.13 by 1 NO-UNDO.

DEFINE VARIABLE Tog-tree AS LOGICAL INITIAL no
     LABEL "дерево":L
     VIEW-AS TOGGLE-BOX
     size 9.13 by 1 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no
     LABEL "Экспорт в текст. файл с разделителем <TAB>"
     VIEW-AS TOGGLE-BOX
     SIZE 45.5 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SortType at row 2.5 col 51.88 NO-LABEL
     Tog-obj at row 2.54 col 2.13
     Classify at row 3.79 col 2.13 NO-LABEL
     Tog-lavel at row 6 col 21.38
     var-lavel AT ROW 6 COL 31 COLON-ALIGNED NO-LABEL
     Tog-tree at row 6 col 39.13
     RADIO-Nomenkl AT ROW 6.54 COL 52 NO-LABEL
     ShowZero-2 at row 12 col 32
     RADIO-SET-1 AT ROW 12.21 COL 55.38 NO-LABEL
     RADIO-AltObj AT ROW 12.25 COL 3.88 NO-LABEL
     ShowZero at row 13 col 32
     SumsOnly AT ROW 14 COL 32
     no-nds AT ROW 15 COL 32
     B-columns AT ROW 16.5 COL 3
     TOGGLE-1 AT ROW 16.63 COL 31.63
     FILL-IN-31 AT ROW 5.54 COL 51.63 NO-LABEL
     FILL-IN-30 AT ROW 10.88 COL 4 NO-LABEL
     FILL-IN-33 AT ROW 10.88 COL 32.38 NO-LABEL
     FILL-IN-32 AT ROW 10.92 COL 53.5 NO-LABEL
     "Сортировка :" VIEW-AS TEXT
          size 13.63 by 0.75 at row 1.46 col 51.5
          FGCOLOR 4
     "Классификация :":C47 VIEW-AS TEXT
          size 46.25 by 0.75 at row 1.42 col 2.5
          FGCOLOR 4
     RECT-7 AT ROW 5.38 COL 50.5
     RECT-5 AT ROW 1.21 COL 1.75
     RECT-8 AT ROW 10.63 COL 1.75
     RECT-6 AT ROW 1.21 COL 50.38
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
         HEIGHT             = 16.92
         WIDTH              = 77.25.
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
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-30 IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-31 IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-32 IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-33 IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX no-nds IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX ShowZero IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX Tog-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX Tog-tree IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN var-lavel IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
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

&Scoped-define SELF-NAME B-columns
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-columns s-object
ON CHOOSE OF B-columns IN FRAME F-Main /* Выбор колонок для печати */
DO:
  /* Процедура задания колонок в отчете */
  run rep/askfld1.w ( input 0, input-output prod-zen, output print-o ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
            display  TOG-lavel  var-Lavel tog-tree with frame {&FRAME-NAME} .
            disable  TOG-lavel  var-Lavel tog-tree with frame {&FRAME-NAME} .
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-AltObj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-AltObj s-object
ON VALUE-CHANGED OF RADIO-AltObj IN FRAME F-Main
DO:
  assign RADIO-AltObj .
  assign AltObj-list = "" .
  if RADIO-AltObj = 3 then do:
    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      my-handle
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true then do:
      assign RADIO-AltObj = 1 .
      display RADIO-AltObj with frame {&FRAME-NAME} .
    end.
    else do:
      define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
      for each buf_userobjs_temp-user-obj :
        if AltObj-list = "" then
          assign  AltObj-list = AltObj-list + buf_userobjs_temp-user-obj.obj-type + "," + string(buf_userobjs_temp-user-obj.obj-code) .
        else
          assign  AltObj-list = AltObj-list + "," + buf_userobjs_temp-user-obj.obj-type + "," + string(buf_userobjs_temp-user-obj.obj-code) .
      end.
    end.
  end.
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
     display ShowZero with frame {&frame-name} .
     disable ShowZero with frame {&frame-name} .
  end.
  else enable ShowZero with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-lavel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-lavel s-object
ON VALUE-CHANGED OF Tog-lavel IN FRAME F-Main /* с уровня */
DO:
  if tog-lavel:screen-value = string(TRUE)
        Then do:
            display  var-Lavel tog-tree with frame {&FRAME-NAME} .
            enable   var-Lavel tog-tree with frame {&FRAME-NAME} .
        end.
         Else do:
            assign tog-tree = no .
            display    var-Lavel tog-tree with frame {&FRAME-NAME} .
            disable    var-Lavel tog-tree with frame {&FRAME-NAME} .
        end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-tree
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-tree s-object
ON VALUE-CHANGED OF Tog-tree IN FRAME F-Main /* дерево */
DO:
  if tog-tree:screen-value=string(TRUE)
        Then do:
            SumsOnly = true.
            display    SumsOnly with frame {&FRAME-NAME} .
            disable    SumsOnly with frame {&FRAME-NAME} .
        end.
         Else do:

            display  SumsOnly  with frame {&FRAME-NAME} .
            enable   SumsOnly  with frame {&FRAME-NAME} .

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
define variable l-ind as integer no-undo .
define variable glog as logical no-undo .
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  Tog-obj:screen-value in frame {&frame-name} = string(True).
  var-lavel:screen-value in frame {&frame-name} = '1'.
  repeat l-ind = 1 to 96 :  use-column[ l-ind ] =  false . End.

 find first ubflt.usr-flt share-lock
   where ubflt.usr-flt.user-name  = v-cntxt-userid
     and ubflt.usr-flt.call-point = "e-obort1":U
   no-error .
 if not avail ubflt.usr-flt then run rep/askfld1.w ( input 0, input-output prod-zen, output print-o ).
 else do:
   repeat l-ind = 1 to num-entries(ubflt.usr-flt.list_) :
     if index ( entry(l-ind,ubflt.usr-flt.list_),"=") = 0 THEN DO :
       if int(entry(l-ind,ubflt.usr-flt.list_)) > 0 and int(entry(l-ind,ubflt.usr-flt.list_)) <= 88  then use-column[int(entry(l-ind,ubflt.usr-flt.list_)) ] =  true  .
     End.
     Else DO :
       if entry(1,entry(l-ind,ubflt.usr-flt.list_),"=")  = "print-o":U then  print-o = entry(2,entry(l-ind,ubflt.usr-flt.list_),"=") no-error .
       Else DO :
         if entry(1,entry(l-ind,ubflt.usr-flt.list_),"=")  = "prod-zen":U then do:
           if lookup(entry(2,entry(l-ind,ubflt.usr-flt.list_),"="),"yes,true") = 0 then prod-zen = no .
           else prod-zen = yes .
         end.
         if error-status :error then DO:
           run rep/askfld1.w ( input 0, input-output prod-zen, output print-o ).
           return no-apply.
         End.
       End.
     End.
   End.
   run get-gds-engl   in my-handle ( output g#gds-engl ) .
   if g#gds-engl then assign RADIO-SET-1 = 2 .
 End.
 display FILL-IN-30 FILL-IN-31 FILL-IN-32 FILL-IN-33 RADIO-SET-1 with frame {&FRAME-NAME} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
  define variable sz-qnty      as integer initial 3  no-undo .
  define variable v-fact-order-start   as decimal   no-undo .
  define variable v-fact-order-end     as decimal   no-undo .
  define variable sys-key as char no-undo.                  /* для чтения параметра конфигурации */
  define variable par-type as char no-undo.                  /* тип параметра конфигурации */
  { gbl/currsysk.i
    sys-key
    no-error
  }
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "sys-key"
    view-as alert-box error
  .
  if sys-key = "BDC" then assign sz-qnty = 0 .

if x-date-end < today then do:
  if use-column[89] or use-column[90] or use-column[91] or use-column[92] or use-column[93] or use-column[94] or use-column[95] or use-column[96] then do:
    message "Данные по резервам можно корректно рассчитать только на текущую дату!" view-as alert-box.
    assign
      use-column[89] = no
      use-column[90] = no
      use-column[91] = no
      use-column[92] = no
      use-column[93] = no
      use-column[94] = no
      use-column[95] = no
      use-column[96] = no
    .
  end.
end.
run rep/r-obort1.p  (
   input ShowZero       ,
   input ShowZero-2     ,
   input RADIO-Nomenkl  ,
   input Tog-obj        ,
   input Classify       ,
   input RADIO-AltObj   ,
   input AltObj-list    ,
   input SortType       ,
   input prod-zen       ,
   input print-o        ,
   input SumsOnly       ,
   input tog-lavel      ,
   input var-lavel      ,
   input tog-tree       ,
   input RADIO-SET-1    ,
   input no-nds         ,
   input TOGGLE-1       ,
   input sz-qnty        ,
   input sys-key
  ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
Assign frame {&frame-name} SumsOnly ShowZero tog-obj Classify SortType RADIO-SET-1  TOGGLE-1
              ShowZero-2 tog-lavel var-lavel tog-tree RADIO-Nomenkl RADIO-AltObj no-nds .

/*строки в которых содержатся выбранные объекты */
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''
 str4  = ""
.
For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ','
/* str4    = str4 + " " + obj-list.obj-name + " (" + obj-list.obj-type + '#' + string(obj-list.obj-code)  + "), "*/
 str4   = STR-obj
.
End.
assign ReportNAme = "Оборотная ведомость детализированная: " + (If X-TOG-Shift Then
                "Cмены с "  + string(X-Shift-Start)   + " по "  + string(X-Shift-End)  Else "" ) +
                " за период с  " + string(X-Date-Start,"99/99/9999") + "г." + "  по " + string(X-Date-End,"99/99/9999") + "г."
 .
{ rep/claslabl.i }
ReportHeader = "Классификация : " + t-Class.
ReportHeader = ReportHeader + (if tog-lavel  then "    Итоги с уровня  "  + String(var-lavel)  else " "    ).
ReportHeader = ReportHeader  + chr(10).

ReportHeader = ReportHeader  + "Выбор цен: " + (if x-SET_val_TYPE = 1 then "{&abbr_rublevye}" else "валютные" ) + chr(10).

 assign
   str3 = ""
   str1 = "Показать : " +
         (if SumsOnly     then " только итоги, "             else " " ) +
         (if no-nds       then " учет. цены без НДС, "         else " " ) +
         (if tog-tree     then " группировка в виде дерева, "   else " " ) +
         (if Tog-obj      then " раздельно по объектам, "  else " " ) +
         (if ShowZero     then " показывать нулевые остатки, "  else " не показывать нулевые остатки, " ) +
         (if ShowZero-2   then " показывать нулевые обороты "  else " не показывать нулевые обороты " ).
 .
 ReportHeader = ReportHeader + "Сортировка " + t-Sort  + chr(10) + str1 + chr(10) .
 case RADIO-Nomenkl :
   when 1 then str2 =  "Номенклатура : Вся".
   when 2 then str2 =  "Номенклатура : Текущая" .
   when 3 then str2 =  "Номенклатура : Удаленная" .
 end case .
 ReportHeader = ReportHeader + str2 +  chr(10).

 if RADIO-AltObj > 1 then do:
   if RADIO-AltObj = 2 then ReportHeader = ReportHeader + "Альтернативные объекты : Все " .
   else do:
     define buffer buf_clients  for ub.clients .
     define variable ii as integer   no-undo .
     define variable p-num as integer   no-undo .
     assign str3 =  "Альтернативные объекты: " .
     assign p-num = num-entries( AltObj-list ) .
     do ii = 1 to p-num by 2 :
       find first buf_clients no-lock
         where buf_clients.obj-type = entry( ii, AltObj-list )
           and buf_clients.obj-code = integer( entry( ii + 1 , AltObj-list ))
       .
       str3 = str3 + buf_clients.obj-name + " (" + buf_clients.obj-type + '#' + string(buf_clients.obj-code) + ")"  + ", " .
     end.
   end.
 end.

if tog-tree and (use-column [1] = false OR use-column [2] = false  ) then  do:
   message "Для получения отчета с группировкой по дереву должны быть выбраны колонки  Код и Артикул !" view-as alert-box .
return error.
end.

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
    when "link-changed":U then  DO:
         Run my-var.
         End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME