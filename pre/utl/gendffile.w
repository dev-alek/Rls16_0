using ibs.th.adm.upd.*.
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "Процедура просмотра объектов зарегистрированых в ObjSRV".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable analisDfObj as class analisdf no-undo.
analisDfObj = new analisdf ().
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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       fTriggerAttrHist:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF bCreate IN FRAME Dialog-Frame
DO:
define variable vFileErr as character no-undo.
define variable vMsg     as character no-undo.
vFileErr              = substitute("&1&2.err",session:temp-directory,"history").
analisDfObj:fileDF    = substitute("&1&2.df",session:temp-directory,"history").
analisDfObj:noMessage = true.
if search(analisDfObj:fileDF) <> ? then
  os-delete value(analisDfObj:fileDF).
  assign fTableForHead fHeadTable fHeadSequence fTriggerFile fTables fTriggerHist fAttrTables fTriggerAttr fCrHistAttr fTriggerAttrHist.
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
ON CHOOSE OF bExit IN FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U.
END.
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
ON VALUE-CHANGED OF fCrHistAttr IN FRAME Dialog-Frame
DO:
do with frame Dialog-Frame:
  assign fCrHistAttr.
  if fCrHistAttr then
    view fTriggerAttrHist.
  else
    hide fTriggerAttrHist.
end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  hide fTriggerAttrHist.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
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
END PROCEDURE.
PROCEDURE genAttrTablesDF :
  define variable vCount       as integer   no-undo.
  define variable vTable       as character no-undo.
  define variable vTrigger     as character no-undo.
  define variable vTriggerHist as character no-undo.
  define buffer bFile for ub._file.
do with frame Dialog-Frame:
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
PROCEDURE genHeadTableDF :
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
PROCEDURE genHistTablesDF :
DO WITH FRAME Dialog-Frame:
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
