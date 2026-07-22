&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Генерация df-файла таблиц истории

Автор: Ростовцев Александр
Дата создания: 29/04/2025
Author: Rostovtsev Aleksandr
Creation date: 29/04/2025

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using ibs.th.adm.upd.*.

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
/* Parameters Definitions ---                                           */
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Процедура просмотра объектов зарегистрированых в ObjSRV".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ gbl/objsrv.i }

define variable analisDfObj as class analisdf no-undo.

analisDfObj = new analisdf ().

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 fAttrTriggers bExit bCreate ~
bHelpHead fTableForHead fHeadTable fHeadSequence fTriggerFile bHelpHist ~
fTables fTriggerHist bHelpAttr fAttrTables fTriggerAttr fCrHistAttr ~
fTriggerAttrHist textHeadHist textHistory textAttr 
&Scoped-Define DISPLAYED-OBJECTS fTableForHead fHeadTable fHeadSequence ~
fTriggerFile fTables fTriggerHist fAttrTables fTriggerAttr fCrHistAttr ~
fTriggerAttrHist textHeadHist textHistory textAttr 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 fTableForHead fHeadTable fHeadSequence fTriggerFile ~
fTables fTriggerHist fAttrTables fTriggerAttr fCrHistAttr fTriggerAttrHist 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bCreate 
     LABEL "Создать" 
     SIZE 15 BY 1.14.

DEFINE BUTTON bExit 
     LABEL "Выход" 
     SIZE 15 BY 1.14.

DEFINE BUTTON bHelpAttr 
     IMAGE-UP FILE "cmp/b-help.bmp":U
     IMAGE-DOWN FILE "cmp/b-help.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-help.bmp":U
     LABEL "" 
     SIZE 3.8 BY 1.

DEFINE BUTTON bHelpHead 
     IMAGE-UP FILE "cmp/b-help.bmp":U
     IMAGE-DOWN FILE "cmp/b-help.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-help.bmp":U
     LABEL "" 
     SIZE 3.8 BY 1.

DEFINE BUTTON bHelpHist 
     IMAGE-UP FILE "cmp/b-help.bmp":U
     IMAGE-DOWN FILE "cmp/b-help.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-help.bmp":U
     LABEL "" 
     SIZE 3.8 BY 1.

DEFINE VARIABLE fAttrTables AS CHARACTER FORMAT "X(256)":U 
     LABEL "Список таблиц" 
     VIEW-AS FILL-IN 
     SIZE 87 BY 1 TOOLTIP "Список таблиц через ~",~", по которым генерировать таблицы атибутов" NO-UNDO.

DEFINE VARIABLE fHeadSequence AS CHARACTER FORMAT "X(20)":U 
     LABEL "Head-последовательность" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 TOOLTIP "Имя последовательности для головной таблицы" NO-UNDO.

DEFINE VARIABLE fHeadTable AS CHARACTER FORMAT "X(20)":U 
     LABEL "Head-таблица" 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 TOOLTIP "Имя головной таблицы" NO-UNDO.

DEFINE VARIABLE fTableForHead AS CHARACTER FORMAT "X(20)":U 
     LABEL "из таблицы" 
     VIEW-AS FILL-IN 
     SIZE 30 BY 1 TOOLTIP "по какой таблице генерируется головная таблица" NO-UNDO.

DEFINE VARIABLE fTables AS CHARACTER FORMAT "X(256)":U 
     LABEL "Список таблиц" 
     VIEW-AS FILL-IN 
     SIZE 87 BY 1 TOOLTIP "Список таблиц через ~",~", по которым генерировать таблицы истории" NO-UNDO.

DEFINE VARIABLE fTriggerAttr AS CHARACTER FORMAT "X(20)":U 
     LABEL "Триггер-файлы" 
     VIEW-AS FILL-IN 
     SIZE 87 BY 1 TOOLTIP "Имя триггер-файлов для таблиц атрибутов" NO-UNDO.

DEFINE VARIABLE fTriggerAttrHist AS CHARACTER FORMAT "X(20)":U 
     LABEL "Триггеры истории" 
     VIEW-AS FILL-IN 
     SIZE 87 BY 1 TOOLTIP "Имя триггер-файлов для таблиц истории по атрибутам" NO-UNDO.

DEFINE VARIABLE fTriggerFile AS CHARACTER FORMAT "X(7)":U 
     LABEL "Триггер-файл" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 TOOLTIP "Имя триггер-файла для головной таблицы" NO-UNDO.

DEFINE VARIABLE fTriggerHist AS CHARACTER FORMAT "X(20)":U 
     LABEL "Триггер-файлы" 
     VIEW-AS FILL-IN 
     SIZE 87 BY 1 TOOLTIP "Имя триггер-файлов для таблицы истории" NO-UNDO.

DEFINE VARIABLE textAttr AS CHARACTER FORMAT "X(50)":U INITIAL "Таблицы атрибутов" 
      VIEW-AS TEXT 
     SIZE 19 BY .62 NO-UNDO.

DEFINE VARIABLE textHeadHist AS CHARACTER FORMAT "X(50)":U INITIAL "Для головной таблицы истории" 
      VIEW-AS TEXT 
     SIZE 28.8 BY .62 NO-UNDO.

DEFINE VARIABLE textHistory AS CHARACTER FORMAT "X(50)":U INITIAL " Основные таблицы истории" 
      VIEW-AS TEXT 
     SIZE 26 BY .95 NO-UNDO.

DEFINE RECTANGLE fAttrTriggers
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 109 BY 6.86.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 109 BY 4.05.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 109 BY 5.24.

DEFINE VARIABLE fCrHistAttr AS LOGICAL INITIAL no 
     LABEL "создать таблицы истории по атрибутам" 
     VIEW-AS TOGGLE-BOX
     SIZE 48 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     bExit AT ROW 1.48 COL 6 WIDGET-ID 14
     bCreate AT ROW 1.48 COL 27 WIDGET-ID 16
     bHelpHead AT ROW 2.71 COL 35 WIDGET-ID 42
     fTableForHead AT ROW 4.1 COL 66.2 WIDGET-ID 6
     fHeadTable AT ROW 4.14 COL 9 WIDGET-ID 4
     fHeadSequence AT ROW 5.57 COL 9 WIDGET-ID 8
     fTriggerFile AT ROW 7 COL 22 WIDGET-ID 10
     bHelpHist AT ROW 8.71 COL 31 WIDGET-ID 44
     fTables AT ROW 10.19 COL 6.6 WIDGET-ID 2
     fTriggerHist AT ROW 11.52 COL 6.6 WIDGET-ID 32
     bHelpAttr AT ROW 13.67 COL 25 WIDGET-ID 46
     fAttrTables AT ROW 15.05 COL 6.6 WIDGET-ID 30
     fTriggerAttr AT ROW 16.48 COL 6.6 WIDGET-ID 34
     fCrHistAttr AT ROW 17.91 COL 23 WIDGET-ID 48
     fTriggerAttrHist AT ROW 19.1 COL 3.2 WIDGET-ID 52
     textHeadHist AT ROW 2.91 COL 4.2 COLON-ALIGNED NO-LABEL WIDGET-ID 40
     textHistory AT ROW 8.71 COL 3.4 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     textAttr AT ROW 13.86 COL 4.2 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     RECT-1 AT ROW 9.19 COL 3 WIDGET-ID 18
     RECT-2 AT ROW 3.19 COL 3 WIDGET-ID 20
     fAttrTriggers AT ROW 14.14 COL 3 WIDGET-ID 26
     SPACE(0.99) SKIP(0.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Генерация df-файла таблиц истории" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fAttrTables IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR TOGGLE-BOX fCrHistAttr IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN fHeadSequence IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN fHeadTable IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN fTableForHead IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN fTables IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN fTriggerAttr IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN fTriggerAttrHist IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       fTriggerAttrHist:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN fTriggerFile IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN fTriggerHist IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Генерация df-файла таблиц истории */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bCreate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bCreate Dialog-Frame
ON CHOOSE OF bCreate IN FRAME Dialog-Frame /* Создать */
DO:
define variable vFileErr as character no-undo.
define variable vMsg     as character no-undo.


vFileErr              = substitute("&1&2.err",session:temp-directory,"history").
analisDfObj:fileDF    = substitute("&1&2.df",session:temp-directory,"history").
analisDfObj:noMessage = true.

if search(analisDfObj:fileDF) <> ? then
  os-delete value(analisDfObj:fileDF).
  
  assign {&list-1}.

do transaction:  
  output to value(vFileErr).

  run genAttrTablesDF in this-procedure.
   
  if fHeadTable <> "" then
  do:
    run genHeadTableDF in this-procedure.
  end.
  
  run genHistTablesDF in this-procedure.

  catch exProErrors as class Progress.Lang.ProError :
    vMsg = exProErrors:GetMessage(1) + "~nСмотрите лог " + vFileErr + ".". 
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    vMsg = "Неизвестная ошибка~nСмотрите лог " + vFileErr + "." .
  end catch .
  finally :
    if vMsg <> "" then
      message vMsg view-as alert-box error.
    output close.
  end finally .  
end.

if search(analisDfObj:fileDF) <> ? then
do:
  file-info:file-name = analisDfObj:fileDF.
  if file-info:file-size <> 0 then do:
    output to value(analisDfObj:fileDF) append.
    put unformatted "." skip "PSC" skip "cpstream=1251" skip "." skip .
    output close.
    message "Создан DF-файл" analisDfObj:fileDF view-as alert-box. 
  end.
  else do:
    os-delete value(analisDfObj:fileDF).
    message "DF-файл не создан~nСмотрите лог " + vFileErr + "." view-as alert-box error. 
  end.
end.
else 
  message "DF-файл не создан~nСмотрите лог " + vFileErr + "." view-as alert-box error. 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bExit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bExit Dialog-Frame
ON CHOOSE OF bExit IN FRAME Dialog-Frame /* Выход */
DO:
  APPLY "END-ERROR":U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bHelpAttr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bHelpAttr Dialog-Frame
ON CHOOSE OF bHelpAttr IN FRAME Dialog-Frame
DO:
  message 
    "Заполняется для создания структуры таблиц атрибутов из списка." skip
    "~"Список таблиц~" - список таблиц через ~",~", для которых генерируется структура таблиц атрибутов" skip
    "~"Триггер-файлы~" - список имен файлов триггера через ~",~" для каждой таблицы из списка. ~
Будут сгенерированы файлы-триггеры с соответствующим именем на WRITE и DELETE и расширением p для каждой таблицы списка. ~
Для WRITE в конце имени добавится ~"w~", для DELETE - ~"d~".~
Если поле не заполнено, то триггеры сгенерированы не будут для всех таблиц списка. ~
Если для какой-то таблицы из списка не нужны триггеры, то эту позицию оставляем не заполненной." skip
  view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bHelpHead
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bHelpHead Dialog-Frame
ON CHOOSE OF bHelpHead IN FRAME Dialog-Frame
DO:
  message 
    "Заполняется для создания структуры головной таблицы истории. Необязательный" skip
    "~"Head-таблица~" - имя головной таблицы истории" skip
    "~"из таблицы~" - имя таблицы, по которой создается головная таблица истории" skip
    "~"Head-последовательность~" - имя последовательности chip-num для головной таблицы" skip
    "~"Триггер-файл~" - имя файла триггера, для головной таблицы (max 7 знаков, необязательный).~
Будут сгенерированы файлы-триггеры с таким именем на WRITE и DELETE и расширением p. ~
Для WRITE в конце имени добавится ~"w~", для DELETE - ~"d~"." skip
  view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bHelpHist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bHelpHist Dialog-Frame
ON CHOOSE OF bHelpHist IN FRAME Dialog-Frame
DO:
  message 
    "Заполняется для создания структуры таблицы истории из списка." skip
    "~"Список таблиц~" - список таблиц через ~",~", для которых генерируется структура таблиц истории" skip
    "~"Триггер-файлы~" - список имен файлов триггера через ~",~" для каждой таблицы из списка. ~
Будут сгенерированы файлы-триггеры с соответствующим именем на WRITE и DELETE и расширением p для каждой таблицы списка. ~
Для WRITE в конце имени добавится ~"w~", для DELETE - ~"d~".~
Если поле не заполнено, то триггеры сгенерированы не будут для всех таблиц списка. ~
Если для какой-то таблицы из списка не нужны триггеры, то эту позицию оставляем не заполненной." skip
  view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fCrHistAttr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fCrHistAttr Dialog-Frame
ON VALUE-CHANGED OF fCrHistAttr IN FRAME Dialog-Frame /* создать таблицы истории по атрибутам */
DO:
do with frame {&frame-name}:
  assign {&self-name}.
  if {&self-name} then
    view fTriggerAttrHist.
  else
    hide fTriggerAttrHist.
end.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
/*
  assign
    fHeadTable    = "c-order-head"
    fTableForHead = "order-doc"
    fHeadSequence = "s-c-order-chip-num"
    fTriggerFile  = "cordh"
    fTables       = "order-doc,order-line"  
    fTriggerHist  = "cordd,cordl"  
    fAttrTables   = "order-doc,order-line"  
    fTriggerAttr  = "orddatt,ordlatt"  
    fTriggerAttrHist  = "cordda,cordla"  
  .
*/
  RUN enable_UI.
  hide fTriggerAttrHist.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY fTableForHead fHeadTable fHeadSequence fTriggerFile fTables 
          fTriggerHist fAttrTables fTriggerAttr fCrHistAttr fTriggerAttrHist 
          textHeadHist textHistory textAttr 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 fAttrTriggers bExit bCreate bHelpHead fTableForHead 
         fHeadTable fHeadSequence fTriggerFile bHelpHist fTables fTriggerHist 
         bHelpAttr fAttrTables fTriggerAttr fCrHistAttr fTriggerAttrHist 
         textHeadHist textHistory textAttr 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE genAttrTablesDF Dialog-Frame 
PROCEDURE genAttrTablesDF :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define variable vCount       as integer   no-undo.
  define variable vTable       as character no-undo.
  define variable vTrigger     as character no-undo.
  define variable vTriggerHist as character no-undo.

  define buffer bFile for ub._file.

do with frame {&frame-name}:
  if fAttrTables <> "" and fTriggerAttr <> "" and
     num-entries(fAttrTables) <> num-entries(fTriggerAttr ) then
  do:
    message "Ошибка в секции ~"" trim(textAttr) "~"." skip
            substitute("Количество имен таблиц в поле ~"&1~" должно совпадать с количеством имен файлов в поле ~"&2~".",fAttrTables:label,fTriggerAttr :label) skip
            "Структуры для таблиц атрибутов не будут сгененрирована."
            view-as alert-box.
    return.
  end.

  if fAttrTables <> "" and fCrHistAttr and fTriggerAttrHist <> "" and
     num-entries(fAttrTables) <> num-entries(fTriggerAttrHist) then
  do:
    message "Ошибка в секции ~"" trim(textAttr) "~"." skip
            substitute("Количество имен таблиц в поле ~"&1~" должно совпадать с количеством имен файлов в поле ~"&2~".",
                       fAttrTables:label,fTriggerAttrHist:label) skip
            "Структуры для таблиц атрибутов не будут сгененрирована."
            view-as alert-box.
    return.
  end.
    
  do vCount = 1 to num-entries(fAttrTables):
    assign
      vTable       = entry(vCount,fAttrTables)
      vTrigger     = if fTriggerAttr <> "" then entry(vCount,fTriggerAttr) else ""
      vTriggerHist = if fCrHistAttr and fTriggerAttrHist <> "" then entry(vCount,fTriggerAttrHist) else ""
    .
    
    find first bFile where bFile._file-name = vTable no-lock no-error.
    if avail bFile then
    do:
      analisDfObj:crTableAttr(vTable, vTrigger, fCrHistAttr, vTriggerHist ).
    end.
    else
    do:
      message 
        substitute("Таблица &1 не найдена в БД.~nСтруктура таблицы атрибутов для нее не сгененрирована.", vTable)
        view-as alert-box.
    end.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE genHeadTableDF Dialog-Frame 
PROCEDURE genHeadTableDF :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

  define buffer bFile for ub._file.
  
  if fTableForHead <> "" then
  do:
    find first bFile where bFile._file-name = fTableForHead no-lock no-error.
    if avail bFile then
    do:
      analisDfObj:crTableHeadHist(fTableForHead, fHeadTable, fHeadSequence, fTriggerFile) no-error.
      if error-status:error then do:
        message 
          "Ошибка при генерации Головной таблицы истории." skip
          error-status:get-message(1) skip
          "Структура Головной таблица истории не сгенерирована."
          view-as alert-box.
      end.
    end.
    else
    do:
      message 
        substitute("Таблица &1 не найдена в БД.~nСтруктура головной таблицы истории для нее не сгененрирована.", fTableForHead )
        view-as alert-box.
    end.    
  end.
  else 
  do:
    message 
      "Ошибка в секции ~"" trim(textHeadHist) "~"." skip
      "Не заполнено поле ~"из таблицы~", для которой табицы должна быть создана головная таблица истории" skip
      "Структура Головной таблица истории не сгенерирована."
      view-as alert-box.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE genHistTablesDF Dialog-Frame 
PROCEDURE genHistTablesDF :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DO WITH FRAME {&frame-name}:
  define variable vCount    as integer   no-undo.
  define variable vTable    as character no-undo.
  define variable vTrigger  as character no-undo.

  define buffer bFile for ub._file.
  
  if fTables <> "" and fTriggerHist <> "" and
     num-entries(fTables) <> num-entries(fTriggerHist) then
  do:
    message "Ошибка в секции ~"" trim(textHistory) "~"." skip
            substitute("Количество имен таблиц в поле ~"&1~" должно совпадать с количеством имен файлов в поле ~"&2~".",fTables:label,fTriggerHist:label) skip
            "Структура для таблиц истории не будут сгененрирована."
            view-as alert-box.
    return.
  end.
  
  do vCount = 1 to num-entries(fTables):
    assign
      vTable    = entry(vCount,fTables)
      vTrigger  = entry(vCount,fTriggerHist)
    no-error.
    
    find first bFile where bFile._file-name = vTable no-lock no-error.
    if avail bFile then
    do:
      analisDfObj:crTableHist(vTable, if fHeadTable <> "" then no else yes, vTrigger).
    end.
    else
    do:
      message 
        substitute("Таблица &1 не найдена в БД.~nСтруктура таблицы истории для нее не будет сгенерирована.", vTable)
        view-as alert-box.
    end.
  end.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

