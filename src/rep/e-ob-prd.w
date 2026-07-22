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

Обороты по производителям (закладка № 2)

Автор: Демин Алексей Сергеевич
Дата создания: 09/16/05
Author: Alexey Demin
Creation date: 09/16/05

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Обороты по производителям' (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable State-source as WIDGET-HANDLE.
define variable print-o      as integer   no-undo .
define variable MngrCodes    as character no-undo .
define variable org-list     as character no-undo .

{ cmp/str-glbl.i }
{ cmp/r-page1.i }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

  define variable g#userid as character no-undo .
  run get-userid  in parParentProc ( output g#userid ).

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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-5 RECT-7 TOGGLE-1 RADIO-Sort ~
TOGGLE-2 SumsOnly RADIO-boss SelectOrg Classify SortType B-columns ~
FILL-IN-33 FILL-IN-30 FILL-IN-31 FILL-IN-35 FILL-IN-34 FILL-IN-36
&Scoped-Define DISPLAYED-OBJECTS TOGGLE-1 RADIO-Sort TOGGLE-2 SumsOnly ~
RADIO-boss SelectOrg Classify SortType FILL-IN-33 FILL-IN-30 FILL-IN-31 ~
FILL-IN-35 FILL-IN-34 FILL-IN-36

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 RECT-5 TOGGLE-1 TOGGLE-2 SumsOnly RADIO-boss ~
SelectOrg FILL-IN-33 FILL-IN-31 FILL-IN-34 FILL-IN-36
&Scoped-define List-2 RECT-6 Classify SortType

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-columns
     LABEL "Выбор колонок для печати"
     SIZE 26.75 BY 1.5 TOOLTIP "Выбор колонок для печати".

DEFINE VARIABLE FILL-IN-30 AS CHARACTER FORMAT "X(30)":U INITIAL "Сортировка списка контрагентов :"
      VIEW-AS TEXT
     SIZE 33.63 BY .92
     FGCOLOR 4 .

DEFINE VARIABLE FILL-IN-31 AS CHARACTER FORMAT "X(56)":U INITIAL "Менеджеры:"
      VIEW-AS TEXT
     SIZE 13.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-33 AS CHARACTER FORMAT "X(30)":U INITIAL "Показать :"
      VIEW-AS TEXT
     SIZE 12.75 BY .92
     FGCOLOR 4 .

DEFINE VARIABLE FILL-IN-34 AS CHARACTER FORMAT "X(56)":U INITIAL "Контрагенты:"
      VIEW-AS TEXT
     SIZE 13.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-35 AS CHARACTER FORMAT "X(30)":U INITIAL "Упорядочение списка товаров"
      VIEW-AS TEXT
     SIZE 33.63 BY .92
     FGCOLOR 15 .

DEFINE VARIABLE FILL-IN-36 AS CHARACTER FORMAT "X(56)":U INITIAL "Классификация :"
      VIEW-AS TEXT
     SIZE 18.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без классификации", "no-classify":U,
"Группы товаров", "grp-goods":U
     size 21 by 2.42 NO-UNDO.

DEFINE VARIABLE RADIO-boss AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 16.38 BY 2.17 NO-UNDO.

DEFINE VARIABLE RADIO-Sort AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По алфавиту", 1,
"По менеджерам", 2,
"По исполнителям", 3,
"По формам оплаты", 4,
"По группам клиентов", 5
     SIZE 32 BY 6.54 NO-UNDO.

DEFINE VARIABLE SelectOrg AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 16.38 BY 2.17 NO-UNDO.

DEFINE VARIABLE SortType AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "sort-code":U,
"по артикулу", "sort-article":U
     size 20.5 by 2.54 NO-UNDO.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27.75 BY 14.29.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46 BY 7.38.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 46 BY 9.29.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL yes
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .83 NO-UNDO.

DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL yes
     LABEL "Закрытые документы"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY .83 NO-UNDO.

DEFINE VARIABLE TOGGLE-2 AS LOGICAL INITIAL no
     LABEL "Незакрытые документы"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     TOGGLE-1 AT ROW 2.5 COL 3
     RADIO-Sort AT ROW 2.88 COL 36 NO-LABEL
     TOGGLE-2 AT ROW 4 COL 3
     SumsOnly AT ROW 5.5 COL 3
     RADIO-boss AT ROW 8.21 COL 5 NO-LABEL
     SelectOrg AT ROW 12.71 COL 4.25 NO-LABEL
     Classify at row 14.5 col 32.13 NO-LABEL
     SortType at row 14.58 col 55.5 NO-LABEL
     B-columns AT ROW 16.04 COL 2.38
     FILL-IN-33 AT ROW 1.38 COL 7.88 NO-LABEL
     FILL-IN-30 AT ROW 1.71 COL 35.88 NO-LABEL
     FILL-IN-31 AT ROW 7.21 COL 4.63 NO-LABEL
     FILL-IN-35 AT ROW 11.42 COL 37.13 NO-LABEL
     FILL-IN-34 AT ROW 11.58 COL 4.38 NO-LABEL
     FILL-IN-36 AT ROW 13.5 COL 32.13 NO-LABEL
     "Сортировка :" VIEW-AS TEXT
          size 13.63 by 0.75 at row 13.5 col 55.38
          FGCOLOR 4
     RECT-6 AT ROW 10.83 COL 31
     RECT-5 AT ROW 1.21 COL 1.75
     RECT-7 AT ROW 1.21 COL 31
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
         HEIGHT             = 17.96
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

/* SETTINGS FOR RADIO-SET Classify IN FRAME F-Main
   2                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-30 IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-31 IN FRAME F-Main
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-33 IN FRAME F-Main
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-34 IN FRAME F-Main
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-35 IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-36 IN FRAME F-Main
   ALIGN-L 1                                                            */
/* SETTINGS FOR RADIO-SET RADIO-boss IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-5 IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-6 IN FRAME F-Main
   2                                                                    */
/* SETTINGS FOR RADIO-SET SelectOrg IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR RADIO-SET SortType IN FRAME F-Main
   2                                                                    */
/* SETTINGS FOR TOGGLE-BOX SumsOnly IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOGGLE-1 IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOGGLE-2 IN FRAME F-Main
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

&Scoped-define SELF-NAME B-columns
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-columns s-object
ON CHOOSE OF B-columns IN FRAME F-Main /* Выбор колонок для печати */
DO:
  /* Процедура задания колонок в отчете */
  run rep/e-ob-pr1.w  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-boss
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-boss s-object
ON VALUE-CHANGED OF RADIO-boss IN FRAME F-Main
DO: /* Менеджеры --- выборочно */
  define variable ref-list as character no-undo .
  define variable i as integer   no-undo .
  assign RADIO-boss .
  assign
    ref-list = ""
    MngrCodes = ""
  .

  if RADIO-boss = 2 then  do:
    run ref/cli-all.w ( parParentProc
                   , "b-sel,b-mark"
                   , {&prs}
                   , {&all}
                   , {&current}
                   , ?
                   , ",,,,,,NO"
                   ,?
                  , output ref-list ) .
    if ref-list <> "" then do:
      DO i = 1 to num-entries( ref-list ) :
        FIND clients WHERE recid( clients ) = integer( entry( i, ref-list ) ) NO-LOCK .
        MngrCodes = MngrCodes + string( clients.obj-code ) + "," .
      END.
      MngrCodes = right-trim( MngrCodes, "," ) .
    end.
    else do:
      assign
        RADIO-boss = 1
        MngrCodes = ""
      .
      DISPLAY RADIO-boss with frame {&frame-name} .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectOrg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectOrg s-object
ON VALUE-CHANGED OF SelectOrg IN FRAME F-Main
DO:
  assign SelectOrg .

  if SelectOrg = 2 then do:
    assign
      org-list = ""
    .
    run ref/cli-all.w ( parParentProc
                   , "b-sel"
                   , {&all}
                   , {&all}
                   , {&current}
                   , ?
                   ,",,,,,,NO"
                   ,?
                  , output org-list ) .
    if org-list = "" then do:
      SelectOrg = 1 .
      disp SelectOrg with frame {&frame-name}.
    end.
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SumsOnly
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SumsOnly s-object
ON VALUE-CHANGED OF SumsOnly IN FRAME F-Main /* Только итоги */
DO:
  Assign SumsOnly.
  if SumsOnly = no then enable  {&List-2} with frame {&FRAME-NAME} .
  else                  disable {&List-2} with frame {&FRAME-NAME} .
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
def var  l-ind as integer no-undo .
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  repeat l-ind = 1 to 88 :  use-column[ l-ind ] =  false . End.

 find first ubflt.usr-flt share-lock where ubflt.usr-flt.user-name  = g#userid and ubflt.usr-flt.call-point = "e-ob-prd":U no-error .
 if not avail ubflt.usr-flt then run rep/e-ob-pr1.w .
 else do:
   repeat l-ind = 1 to num-entries(ubflt.usr-flt.list_) :
     if index ( entry(l-ind,ubflt.usr-flt.list_),"=") = 0 THEN DO :
       if int(entry(l-ind,ubflt.usr-flt.list_)) > 0 and int(entry(l-ind,ubflt.usr-flt.list_)) <= 28  then use-column[int(entry(l-ind,ubflt.usr-flt.list_)) ] =  true  .
     End.
     Else DO :
       if error-status :error then DO:
         run rep/e-ob-pr1.w .
         return no-apply.
       End.
     End.
   End.
 End.

 assign TOGGLE-1 = yes SumsOnly = yes .
 disable {&List-2} with frame {&FRAME-NAME} .
 display FILL-IN-30 FILL-IN-31  FILL-IN-33  FILL-IN-34  FILL-IN-35 FILL-IN-36 TOGGLE-1 SumsOnly with frame {&FRAME-NAME} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
if TOGGLE-1 = no and TOGGLE-2 = no then do:
    message  "Нет выбранных документов!"  view-as alert-box.
    leave .
  end.

  if SumsOnly = yes then  assign  print-o = 31 .
  else                    assign  print-o = 90 .

  define variable ii as integer   no-undo .
  do ii = 1 to 24:
    if use-column[ii] = TRUE then do:
      if ii = 9 or ii = 14 or ii = 19 or ii = 24 then assign  print-o = print-o + 10 .
      else                                            assign  print-o = print-o + 14 .
    end.
  end.

  run rep/r-ob-prd.p  (
   input RADIO-Sort  ,
   input SelectOrg   ,
   input org-list    ,
   input RADIO-boss  ,
   input MngrCodes   ,
   input Classify    ,
   input SortType    ,
   input TOGGLE-1    ,
   input TOGGLE-2    ,
   input SumsOnly    ,
   input print-o
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
 Assign frame {&frame-name} SumsOnly Classify SortType SelectOrg TOGGLE-1 TOGGLE-2 RADIO-boss RADIO-Sort .

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
   .
 End.

 ReportNAme = "Обороты по производителям с: " + string(x-date-start,"99/99/9999") + "г. по: "  + string(x-date-end, "99/99/9999") + "г.".
 { rep/claslabl.i }

 ReportHeader = "Классификация : " + t-Class + "   Сортировка : "  + t-sort .

 assign str1 = "Показать : " + (if SumsOnly then " только итоги, " else " " ) .
 if TOGGLE-1 = yes then assign str1 = str1 + "закрытые документы, " .
 if TOGGLE-2 = yes then assign str1 = str1 + "незакрытые документы " .

 assign str2 = "Сортировка организаций : " .
 case RADIO-Sort :
   when 1 then assign str2 = str2 + "по алфавиту" .
   when 2 then assign str2 = str2 + "по менеджерам" .
   when 3 then assign str2 = str2 + "по исполнителям" .
   when 4 then assign str2 = str2 + "по формам оплаты" .
   when 5 then assign str2 = str2 + "по группам клиентов" .
 end.

 assign str3 = "Контрагенты : " + (if SelectOrg = 1 then " все, " else org-list ) + "Менеджеры : " + (if RADIO-boss = 1 then " все" else MngrCodes ) .

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