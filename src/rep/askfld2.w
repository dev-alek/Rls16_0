&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор колонок для печати отчета  Отчет по движению товара - сводный (вывод в Excel)

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
def var vss-description as character no-undo init "Поля для отчета бенетона ".
{ cmp/vssrevis.i }
define input-output parameter ParamStr as character no-undo .

{ cmp/str-glbl.i }
{ cmp/r-page1.i }
 { cmp/showinf.i }

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

  define variable g#userid as character no-undo .
  run get-userid  in parParentProc ( output g#userid ).

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-21 B-quit B-exit B-mark B-unmark ~
B-help TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 ~
TOG-6 TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30 ~
FILL-IN-58 FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28 ~
FILL-IN-53 FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50 ~
FILL-IN-56 FILL-IN-29 FILL-IN-57 FILL-IN-49
&Scoped-Define DISPLAYED-OBJECTS TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 ~
TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 ~
TOG-18 FILL-IN-25 FILL-IN-30 FILL-IN-58 FILL-IN-26 FILL-IN-31 FILL-IN-27 ~
FILL-IN-52 FILL-IN-28 FILL-IN-53 FILL-IN-32 FILL-IN-54 FILL-IN-48 ~
FILL-IN-55 FILL-IN-50 FILL-IN-56 FILL-IN-29 FILL-IN-57 FILL-IN-49

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 ~
TOG-5 TOG-14 TOG-6 TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помощь"
     SIZE 10.38 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "Отметить *"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "Ввод"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-unmark
     LABEL "Снять *"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-25 AS CHARACTER FORMAT "X(256)":U INITIAL "Цена поставщика"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-26 AS CHARACTER FORMAT "X(256)":U INITIAL "Розничная базовая цена"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-27 AS CHARACTER FORMAT "X(256)":U INITIAL "Розничная текущая цена"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-28 AS CHARACTER FORMAT "X(256)":U INITIAL "Заказы подробно"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-29 AS CHARACTER FORMAT "X(256)":U INITIAL "Остаток на складе в Италии"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-30 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внутр. (с др. объектов)"
      VIEW-AS TEXT
     SIZE 30.25 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-31 AS CHARACTER FORMAT "X(256)":U INITIAL "Остаток на складе"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-32 AS CHARACTER FORMAT "X(256)":U INITIAL "Заказы итого"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-48 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внешний подробно"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-49 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внутренний (отложка)"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-50 AS CHARACTER FORMAT "X(256)":U INITIAL "Приход внешний итого"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-52 AS CHARACTER FORMAT "X(256)":U INITIAL "Реализация за сезон"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-53 AS CHARACTER FORMAT "X(256)":U INITIAL "Реализация за период итого"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-54 AS CHARACTER FORMAT "X(256)":U INITIAL "Реализация за период подробно"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-55 AS CHARACTER FORMAT "X(256)":U INITIAL "Среднесуточная реализация"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-56 AS CHARACTER FORMAT "X(256)":U INITIAL "Внутр. перемещ. (на др. объект)"
      VIEW-AS TEXT
     SIZE 31.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-57 AS CHARACTER FORMAT "X(256)":U INITIAL "Инвентаризация"
      VIEW-AS TEXT
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-58 AS CHARACTER FORMAT "X(256)":U INITIAL "Нетто-Приход"
      VIEW-AS TEXT
     SIZE 29 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 73.38 BY 11.

DEFINE VARIABLE TOG-1 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-10 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-11 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-12 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-13 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-14 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-15 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-16 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-17 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-18 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-2 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-3 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-4 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-5 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-6 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-7 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-8 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.

DEFINE VARIABLE TOG-9 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 2.25
     B-exit AT ROW 1 COL 14.25
     B-mark AT ROW 1 COL 26.25
     B-unmark AT ROW 1 COL 38.13
     B-help AT ROW 1 COL 50.25
     TOG-1 AT ROW 4.5 COL 33.63
     TOG-10 AT ROW 4.5 COL 70
     TOG-2 AT ROW 5.58 COL 33.63
     TOG-11 AT ROW 5.58 COL 70
     TOG-3 AT ROW 6.71 COL 33.63
     TOG-12 AT ROW 6.71 COL 70
     TOG-4 AT ROW 7.79 COL 33.63
     TOG-13 AT ROW 7.79 COL 70
     TOG-5 AT ROW 8.92 COL 33.63
     TOG-14 AT ROW 8.92 COL 70
     TOG-6 AT ROW 10 COL 33.63
     TOG-15 AT ROW 10 COL 70
     TOG-7 AT ROW 11.08 COL 33.63
     TOG-16 AT ROW 11.08 COL 70
     TOG-8 AT ROW 12.21 COL 33.63
     TOG-17 AT ROW 12.21 COL 70
     TOG-9 AT ROW 13.29 COL 33.63
     TOG-18 AT ROW 13.29 COL 70
     FILL-IN-25 AT ROW 4.5 COL 2.38 NO-LABEL
     FILL-IN-30 AT ROW 4.5 COL 35.75 COLON-ALIGNED NO-LABEL
     FILL-IN-58 AT ROW 5.54 COL 38 NO-LABEL
     FILL-IN-26 AT ROW 5.58 COL 2.38 NO-LABEL
     FILL-IN-31 AT ROW 6.54 COL 36.25 COLON-ALIGNED NO-LABEL
     FILL-IN-27 AT ROW 6.71 COL 2.38 NO-LABEL
     FILL-IN-52 AT ROW 7.67 COL 36.13 COLON-ALIGNED NO-LABEL
     FILL-IN-28 AT ROW 7.79 COL 2.38 NO-LABEL
     FILL-IN-53 AT ROW 8.75 COL 36.5 COLON-ALIGNED NO-LABEL
     FILL-IN-32 AT ROW 8.92 COL 2.38 NO-LABEL
     FILL-IN-54 AT ROW 9.88 COL 36.38 COLON-ALIGNED NO-LABEL
     FILL-IN-48 AT ROW 10 COL 2.38 NO-LABEL
     FILL-IN-55 AT ROW 10.96 COL 36.13 COLON-ALIGNED NO-LABEL
     FILL-IN-50 AT ROW 11.08 COL 2.38 NO-LABEL
     FILL-IN-56 AT ROW 12.04 COL 36.25 COLON-ALIGNED NO-LABEL
     FILL-IN-29 AT ROW 12.21 COL 2.38 NO-LABEL
     FILL-IN-57 AT ROW 13.17 COL 36.13 COLON-ALIGNED NO-LABEL
     FILL-IN-49 AT ROW 13.29 COL 2.38 NO-LABEL
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 2.63 COL 30
          FGCOLOR 4
     RECT-21 AT ROW 3.83 COL 1.88
     "Колонки":C28 VIEW-AS TEXT
          SIZE 25.38 BY .67 AT ROW 2.63 COL 1.88
          FGCOLOR 4
     "Колонки":C28 VIEW-AS TEXT
          SIZE 25.38 BY .67 AT ROW 2.63 COL 39.75
          FGCOLOR 4
     "Показать":C8 VIEW-AS TEXT
          SIZE 8.88 BY .67 AT ROW 2.63 COL 66.88
          FGCOLOR 4
     SPACE(0.61) SKIP(11.65)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор колонок для печати"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-25 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-26 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-27 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-28 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-29 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-32 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-48 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-49 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-50 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-58 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX TOG-1 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-10 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-11 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-12 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-13 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-14 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-15 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-16 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-17 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-18 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-3 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-4 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-5 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-6 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-7 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-8 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX TOG-9 IN FRAME Dialog-Frame
   1                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор колонок для печати */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* Отметить * */
DO:
  Assign
   TOG-1 = true
   TOG-2 = true
   TOG-3 = true
   TOG-4 = true
   TOG-5 = true
   TOG-6 = true
   TOG-7 = true
   TOG-8 = true
   TOG-9 = true
   TOG-10 = true
   TOG-11 = true
   TOG-12 = true
   TOG-13 = true
   TOG-14 = true
   TOG-15 = true
   TOG-16 = true
   TOG-17 = true
   TOG-18 = true
  .
  Display  {&list-1} with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Сохранить */
DO:
  def var l-ind as integer no-undo .
  assign {&list-1}.
/*run eq-frame.*/
  assign ParamStr = "" .
  if TOG-1  = yes then ParamStr = ParamStr + "1," .
  if TOG-2  = yes then ParamStr = ParamStr + "2," .
  if TOG-3  = yes then ParamStr = ParamStr + "3," .
  if TOG-4  = yes then ParamStr = ParamStr + "4," .
  if TOG-5  = yes then ParamStr = ParamStr + "5," .
  if TOG-6  = yes then ParamStr = ParamStr + "6," .
  if TOG-7  = yes then ParamStr = ParamStr + "7," .
  if TOG-8  = yes then ParamStr = ParamStr + "8," .
  if TOG-9  = yes then ParamStr = ParamStr + "9," .
  if TOG-10 = yes then ParamStr = ParamStr + "10," .
  if TOG-11 = yes then ParamStr = ParamStr + "11," .
  if TOG-12 = yes then ParamStr = ParamStr + "12," .
  if TOG-13 = yes then ParamStr = ParamStr + "13," .
  if TOG-14 = yes then ParamStr = ParamStr + "14," .
  if TOG-15 = yes then ParamStr = ParamStr + "15," .
  if TOG-16 = yes then ParamStr = ParamStr + "16," .
  if TOG-17 = yes then ParamStr = ParamStr + "17," .
  if TOG-18 = yes then ParamStr = ParamStr + "18," .

 find first ubflt.usr-flt share-lock where
   ubflt.usr-flt.user-name  = g#userid and
   ubflt.usr-flt.call-point = "e-ben-dt":U
 no-error .
 if NOT avail ubflt.usr-flt then  create ubflt.usr-flt.
 Assign
   ubflt.usr-flt.user-name  = g#userid
   ubflt.usr-flt.call-point = "e-ben-dt":U
   ubflt.usr-flt.list_      = ParamStr
 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unmark Dialog-Frame
ON CHOOSE OF B-unmark IN FRAME Dialog-Frame /* Снять * */
DO:
  Assign
   TOG-1 = false
   TOG-2 = false
   TOG-3 = false
   TOG-4 = false
   TOG-5 = false
   TOG-6 = false
   TOG-7 = false
   TOG-8 = false
   TOG-9 = false
   TOG-10 = false
   TOG-11 = false
   TOG-12 = false
   TOG-13 = false
   TOG-14 = false
   TOG-15 = false
   TOG-16 = false
   TOG-17 = false
   TOG-18 = false
  .
  Display  {&list-1} with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
  def var  ii  as integer no-undo init 0 .

  DO ii = 1 TO NUM-ENTRIES(ParamStr):
    case integer(ENTRY(ii,ParamStr)) :
      when 1  then TOG-1  = yes .
      when 2  then TOG-2  = yes .
      when 3  then TOG-3  = yes .
      when 4  then TOG-4  = yes .
      when 5  then TOG-5  = yes .
      when 6  then TOG-6  = yes .
      when 7  then TOG-7  = yes .
      when 8  then TOG-8  = yes .
      when 9  then TOG-9  = yes .
      when 10 then TOG-10 = yes .
      when 11 then TOG-11 = yes .
      when 12 then TOG-12 = yes .
      when 13 then TOG-13 = yes .
      when 14 then TOG-14 = yes .
      when 15 then TOG-15 = yes .
      when 16 then TOG-16 = yes .
      when 17 then TOG-17 = yes .
      when 18 then TOG-18 = yes .
    end case.
  END.

  Display  {&list-1} with frame {&frame-name}.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
/*  RUN Show-format.*/
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6
          TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30
          FILL-IN-58 FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28
          FILL-IN-53 FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50
          FILL-IN-56 FILL-IN-29 FILL-IN-57 FILL-IN-49
      WITH FRAME Dialog-Frame.
  ENABLE RECT-21 B-quit B-exit B-mark B-unmark B-help TOG-1 TOG-10 TOG-2
         TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7
         TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30 FILL-IN-58
         FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28 FILL-IN-53
         FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50 FILL-IN-56
         FILL-IN-29 FILL-IN-57 FILL-IN-49
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE eq-frame Dialog-Frame _DEFAULT-ENABLE
PROCEDURE eq-frame :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY TOG-1 TOG-10 TOG-2 TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6
          TOG-15 TOG-7 TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30
          FILL-IN-58 FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28
          FILL-IN-53 FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50
          FILL-IN-56 FILL-IN-29 FILL-IN-57 FILL-IN-49
      WITH FRAME Dialog-Frame.
  ENABLE RECT-21 B-quit B-exit B-mark B-unmark B-help TOG-1 TOG-10 TOG-2
         TOG-11 TOG-3 TOG-12 TOG-4 TOG-13 TOG-5 TOG-14 TOG-6 TOG-15 TOG-7
         TOG-16 TOG-8 TOG-17 TOG-9 TOG-18 FILL-IN-25 FILL-IN-30 FILL-IN-58
         FILL-IN-26 FILL-IN-31 FILL-IN-27 FILL-IN-52 FILL-IN-28 FILL-IN-53
         FILL-IN-32 FILL-IN-54 FILL-IN-48 FILL-IN-55 FILL-IN-50 FILL-IN-56
         FILL-IN-29 FILL-IN-57 FILL-IN-49
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME