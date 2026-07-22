&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-tnved-item NO-UNDO
       field mark as character
       field tnved-code as integer
       field tnved-item-code as character
       field tnved-item-name as character
       field whole-send-news as integer
       field parent-code as character
       field tnved-code-list as character
       field disp-order as integer
       field disp-order-str as character
       field typp-code as character
       field typp-name as character
       field prod-code as character
       field kind-code as character
       index pi is primary unique tnved-code tnved-item-code
       index i1 tnved-item-code whole-send-news.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник типов продукции

  Author: 
    Автор: Молотков Сергей Михайлович
    Дата создания: 24/04/18
    Author: Molotkov Sergey
    Creation date: 24/04/18

Для просмотра справочника в группу меню по работе с Меркурием добавить пункт "Справочник типов продукции".
Для работы со справочником реализовать интерфейс выбора.
В интерфейсе отражены типы и подтипы. Выбирается только подтип.
В интерфейсе просмотра сделать кнопку Импорт, по которой справочник из файла загрузится в БД.
Уже есть текстовый файл, в котором задаются коды ТНВЭД. Надо в него добавить еще GUID записей. 

@NOTE  об экранной таблице
       DEFINE TEMP-TABLE tt-tnved-item NO-UNDO LIKE tnved-item
  если определить экранную таблицу через like то штатными средствами не отображаются дополнительные поля;
  если дополнительные поля прописать руками - AppBuilder умирает при попытке найти их в _Fields.
@NOTE  в UIB всё равно не открывается.
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-selected-uuid as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision               as character no-undo init "$Revision$":U .
define variable vss-author                 as character no-undo init "$Author$":U .
define variable vss-date                   as character no-undo init "$Date$":U .
define variable vss-workfile               as character no-undo init "$Workfile$":U .
define variable vss-archive                as character no-undo init "$Archive$":U .
define variable vss-description            as character no-undo init "Справочник типов продукции".

define temp-table tt-imp
 /* 01 */ field fl01       as character /* Группа и строка из 646 приказа (не используем) */
 /* 02 */ field typp-name  as character /* Тип продукции */
 /* 03 */ field typp-code  as character /* ID типа продукции */

 /* 04 */ field prod-name  as character /* Продукция */
 /* 05 */ field prod-tnved as character /* ТН ВЭД Продукции */
 /* 06 */ field prod-code  as character /* Guid продукции */

 /* 07 */ field kind-name  as character /* Вид продукции */
 /* 08 */ field kind-tnved as character /* ТН ВЭД Вида продукции */
 /* 09 */ field kind-code  as character /* Guid вида продукции */
.

define stream f-imp .
define temp-table tt-tnved-item-imp      no-undo like ub.tnved-item .
define temp-table tt-tnved-item-attr-imp no-undo like ub.tnved-item-attr .
&scoped-define tnved-typp-level  1
&scoped-define tnved-prod-level  2
&scoped-define tnved-kind-level  3

&scoped-define tnved-attr-parentcode  "parent-code"
&scoped-define tnved-attr-tnvedcode   "tnved-code"
&scoped-define tnved-attr-disporder   "order-str"

{ cmp/str-glbl.i }
{ gbl/waitfram.i }
/* &scoped-define SORTBY-PHRASE by tt-tnved-item.disp-order */
/* &scoped-define SORTBY-PHRASE by tt-tnved-item.typp-code by tt-tnved-item.prod-code by tt-tnved-item.kind-code */
 &scoped-define SORTBY-PHRASE by tt-tnved-item.disp-order-str

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tnved-item

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt-tnved-item.mark ~
tt-tnved-item.tnved-item-name ~
tt-tnved-item.tnved-code-list tt-tnved-item.typp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH tt-tnved-item NO-LOCK ~
    ~{&SORTBY-PHRASE} INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH tt-tnved-item NO-LOCK ~
    ~{&SORTBY-PHRASE} INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-tnved-item
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-tnved-item


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_mark b-sel ~
btn_import btn_search BROWSE-2 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON btn_import 
     LABEL "Импорт" 
     SIZE 10 BY 1.

DEFINE BUTTON Btn_mark 
     LABEL "*" 
     SIZE 3 BY 1.

DEFINE BUTTON btn_search 
     LABEL "Поиск" 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1.

DEFINE VARIABLE fi-search AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 30 BY 1
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR 
      tt-tnved-item SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      tt-tnved-item.mark format "x(1)" no-label
      tt-tnved-item.tnved-item-name format "x(80)" column-label "Наименование продукции и вида продукции"
      tt-tnved-item.tnved-code-list format "x(19)" column-label "Коды ТН ВЭД"
      tt-tnved-item.typp-name format "x(20)" column-label "Тип продукции"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 130 BY 20 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     Btn_mark AT ROW 1 COL 12
     b-sel AT ROW 1 COL 16
     btn_import AT ROW 1 COL 27
     btn_search AT ROW 1 COL 38
     fi-search AT ROW 1 COL 49 NO-LABEL
     BROWSE-2 AT ROW 2.91 COL 2 WIDGET-ID 200
     SPACE(1.24) SKIP(2.93)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Справочник типов продукции"
         CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: tt-tnved-item T "?" NO-UNDO
      ADDITIONAL-FIELDS:
          field mark as character
          field tnved-code as integer
          field tnved-item-code as character
          field tnved-item-name as character
          field whole-send-news as integer
          field parent-code as character
          field tnved-code-list as character
          field disp-order as integer
          field disp-order-str as character
          field typp-code as character
          field typp-name as character
          field prod-code as character
          field kind-code as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-2 btn_import Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BROWSE-2:NUM-LOCKED-COLUMNS         = 1
       BROWSE-2:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "Temp-Tables.tt-tnved-item"
     _Options          = "NO-LOCK INDEXED-REPOSITION SORTBY-PHRASE"
     _FldNameList[1]   = Temp-Tables.tt-tnved-item.mark
     _FldNameList[2]   = Temp-Tables.tt-tnved-item.tnved-item-name
     _FldNameList[3]   = Temp-Tables.tt-tnved-item.tnved-code-list
     _FldNameList[4]   = Temp-Tables.tt-tnved-item.typp-name
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON window-close OF FRAME Dialog-Frame /* Справочник типов продукции */
do:
    apply "END-ERROR":U to self.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
/* формат возвращаемого значения: "typp_code, typp_name, prod_guid, kind_guid",
   чтобы вызывающая программа могла сразу отобразить информацию по выбранному коду kind_guid */
define buffer buf_tt-tnved-typp-name for tt-tnved-item .

  p-selected-uuid = "" .
  for each tt-tnved-item
     where tt-tnved-item.mark = "*"
    while length(p-selected-uuid) < 15000
  :
/*    p-selected-uuid = p-selected-uuid + "," + tt-tnved-item.tnved-item-code .*/
    find first buf_tt-tnved-typp-name where buf_tt-tnved-typp-name.tnved-item-code = tt-tnved-item.parent-code no-error .
    if available buf_tt-tnved-typp-name then
      p-selected-uuid = substitute("&1,&2,&3,&4"
      , buf_tt-tnved-typp-name.typp-code
      , buf_tt-tnved-typp-name.typp-name
      , tt-tnved-item.parent-code
      , tt-tnved-item.tnved-item-code
    ) . else
      p-selected-uuid = substitute(",,&1,&2"
      , tt-tnved-item.parent-code
      , tt-tnved-item.tnved-item-code
    ) .
    
    leave .
  end .
/*  p-selected-uuid = substring(p-selected-uuid, 2) .*/
  apply "GO" to FRAME Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
/*
  p-rid-list = v-rid-list.
*/
END.


&Scoped-define SELF-NAME btn_import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_import Dialog-Frame
ON CHOOSE OF btn_import IN FRAME Dialog-Frame /* Импорт */
DO:
define variable v-imp-fname as character no-undo .
define variable v-ok        as logical no-undo .
  /* 25/V-2018 - после нажатия кнопки "Импорт" реализовать окно выбора файла в формате .csv */

  system-dialog get-file v-imp-fname
    filters "Файлы импорта справочника (*.csv)" "*.csv",
            "Все файлы (*.*)" "*.*"
    title "Выберите файл для импорта справочника"
    update v-ok
  .
  if v-ok then do:
    /* v-imp-fname = "Обновленный_справочник_646_17.10.12.csv" . */
    run import-file in this-procedure (v-imp-fname) .
    run load-tt-tnved in this-procedure.    
    run refresh-view.
  end .
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_mark Dialog-Frame
ON choose OF Btn_mark IN FRAME Dialog-Frame /* * */
do:
  /* '*' - mark/unmark current row,
     '+; - mark all rows
     16/V-2018 - для выбора доступны только записи самого нижнего уровня - "вид" (kind)
  */
  define variable varlog as logical no-undo .

  if available tt-tnved-item then do :
    if tt-tnved-item.mark = "*" then tt-tnved-item.mark = "" .
                                else tt-tnved-item.mark = "*" .
    if can-find (first tt-tnved-item where tt-tnved-item.mark > "") then do: 
      ENABLE b-sel WITH FRAME Dialog-Frame.
    end .
    else do:
      DISABLE b-sel WITH FRAME Dialog-Frame.
    end.
    
    varlog = {&browse-name}:refresh () .
    varlog = {&browse-name}:select-next-row () .
    apply "entry" to {&browse-name} in frame {&frame-name}.
  end .

end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_search Dialog-Frame
ON CHOOSE OF btn_search IN FRAME Dialog-Frame /* Поиск */
DO:
    run find-in-browse in this-procedure (
        input fi-search :screen-value
    ) no-error.
    if error-status :error then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка поиска."
          skip return-value
          skip error-status :get-message(1)
          skip error-status :get-message(2)
          skip error-status :get-message(3)
          skip error-status :get-message(4)
          skip error-status :get-message(5)
        view-as alert-box error.
        undo, return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dialog-Frame
ON RETURN OF fi-search IN FRAME Dialog-Frame
DO:
    /* Ничего не делать, если строка поиска пуста. */
    if fi-search :screen-value > "" then apply "choose" to btn_search in frame Dialog-Frame .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-2 IN FRAME Dialog-Frame
DO:
  /* 16/V-2018 - для выбора доступны только записи самого нижнего уровня - "вид" (kind) */
  define variable v-is-active as logical no-undo .
  if p-mode = {&lookup} then do :
    v-is-active = false .
    if available tt-tnved-item then do:
      v-is-active = (tt-tnved-item.kind-code > "") .
    end .
    Btn_mark:SENSITIVE = v-is-active .
  end .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
  then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
    
  run enable_UI.
  case p-mode:
    when {&lookup} then do:
      DISABLE btn_import WITH FRAME Dialog-Frame.
    end .
    when {&update} then do:
      DISABLE Btn_mark b-sel WITH FRAME Dialog-Frame.
    end .
  end case .
  
  run load-tt-tnved in this-procedure.
  if p-selected-uuid > "" then do:
    define variable v-selected-uuid as character no-undo .
    v-selected-uuid = entry(1, p-selected-uuid) .
    find first tt-tnved-item where tt-tnved-item.tnved-item-code = v-selected-uuid no-error.
    if available tt-tnved-item then tt-tnved-item.mark = "*" .
    else do:
      DISABLE b-sel WITH FRAME Dialog-Frame.
    end .
  end .
  else do:
    DISABLE b-sel WITH FRAME Dialog-Frame.
  end .
  
  run refresh-view.
  wait-for go of frame {&FRAME-NAME}.
  
end.
run disable_UI.

return p-selected-uuid .
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
  ENABLE Btn_Cancel Btn_mark b-sel btn_import btn_search fi-search BROWSE-2 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-arr-typp Dialog-Frame 
PROCEDURE load-arr-typp private :
define output parameter p-typp-names as character extent .
define buffer buf_typp_tnved-item        for ub.tnved-item .
define query q1 for buf_typp_tnved-item .
define variable v-size as integer no-undo .
define variable v-ind  as integer no-undo .

  extent(p-typp-names) = ? .
  if can-find (first tnved-item where tnved-item.whole-send-news = 1) then do:
    open query q1 preselect each buf_typp_tnved-item no-lock
                           where buf_typp_tnved-item.whole-send-news = 1
                              by integer(buf_typp_tnved-item.tnved-item-code) .
    get last q1.
    v-size = integer(buf_typp_tnved-item.tnved-item-code).
    extent(p-typp-names) = v-size.
    v-ind = v-size .
    do while available buf_typp_tnved-item :
      v-ind = integer(buf_typp_tnved-item.tnved-item-code) .
      p-typp-names[v-ind] = buf_typp_tnved-item.tnved-item-name .
      get prev q1.
    end .
    close query q1.
  end.
  else do:
    extent(p-typp-names) = 1.
    p-typp-names[1] = "" .
  end.
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-tt-tnved Dialog-Frame 
PROCEDURE load-tt-tnved :
/*------------------------------------------------------------------------------
 Purpose:  загрузка типов продукции из таблиц БД tnved-item и tnved-item-attr
 Notes:    Отображать линейно
   - строки с whole-send-news = 2 – тип
   - строки с whole-send-news = 3 подтип - отображать со сдвигом
   - строки с whole-send-news = 1 вид продукции - не отображать.
   Сам вид продукции отображать последним столбцом во всех строчках.
------------------------------------------------------------------------------*/
define variable v-num-order as integer no-undo .
&scoped-define tnved-prod-level-str  '{&tnved-prod-level}'
&scoped-define tnved-kind-level-str  '{&tnved-kind-level}'
define buffer buf{&tnved-prod-level}_tnved-item        for ub.tnved-item .
define buffer buf{&tnved-prod-level}_tnved-item-attr-a for ub.tnved-item-attr .
define buffer buf{&tnved-prod-level}_tnved-item-attr-b for ub.tnved-item-attr .
define buffer buf{&tnved-prod-level}_tnved-item-attr-c for ub.tnved-item-attr .
&scoped-define buf-p  buf{&tnved-prod-level}_tnved-item
&scoped-define buf-pa buf{&tnved-prod-level}_tnved-item-attr-a
&scoped-define buf-pb buf{&tnved-prod-level}_tnved-item-attr-b
&scoped-define buf-pc buf{&tnved-prod-level}_tnved-item-attr-c
define variable v-wait-msg   as character no-undo .
define variable v-ln-prev    as integer no-undo .
define variable v-tm-prev    as integer no-undo .
define variable v-tm-curr    as integer no-undo .
define variable v-lines      as integer no-undo .
define variable v-typp-names as character extent .
define variable v-name-ind   as integer no-undo .
define variable v-item-level as integer no-undo .

  assign
    v-wait-msg = "Чтение справочника типов продукции. Строк прочитано: &1"
    v-num-order = 0
    v-lines    = 0
    v-ln-prev  = v-num-order + 100
    v-tm-prev  = time + 1
  .
  run waitfram-show in this-procedure ("Чтение справочника типов продукции.") .

  empty temp-table tt-tnved-item .
  run load-arr-typp in this-procedure (output v-typp-names) .
  /*
  for each {&buf-p} no-lock
     where {&buf-p}.tnved-code = 0
       and {&buf-p}.whole-send-news > 1,
     first {&buf-pa} no-lock
     where {&buf-pa}.tnved-code      = {&buf-p}.tnved-code
       and {&buf-pa}.tnved-item-code = {&buf-p}.tnved-item-code
       and {&buf-pa}.attr-code       = {&tnved-attr-parentcode},
     first {&buf-pb} no-lock
     where {&buf-pb}.tnved-code      = {&buf-p}.tnved-code
       and {&buf-pb}.tnved-item-code = {&buf-p}.tnved-item-code
       and {&buf-pb}.attr-code       = {&tnved-attr-tnvedcode},
     first {&buf-pc} no-lock
     where {&buf-pc}.tnved-code      = {&buf-p}.tnved-code
       and {&buf-pc}.tnved-item-code = {&buf-p}.tnved-item-code
       and {&buf-pc}.attr-code       = {&tnved-attr-disporder}
    :
    */
    /*
        by {&buf-pa}.attr-value
        by {&buf-p}.tnved-item-code 
    */
  for each {&buf-pa} no-lock
     where {&buf-pa}.tnved-code = 0
  break by {&buf-pa}.tnved-code
        by {&buf-pa}.tnved-item-code :
    
    v-lines = v-lines + 1 .
    if v-lines > v-ln-prev then do:
      v-ln-prev = v-lines + 100.
      v-tm-curr = time.
      if v-tm-prev < v-tm-curr then do:
        v-tm-prev  = v-tm-curr + 1 .
        run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
      end .
    end.
    
    if first-of ({&buf-pa}.tnved-item-code) then do :
      find first {&buf-p} no-lock
           where {&buf-p}.tnved-code      = {&buf-pa}.tnved-code 
             and {&buf-p}.tnved-item-code = {&buf-pa}.tnved-item-code
             and {&buf-p}.whole-send-news > {&tnved-typp-level} no-error .
      if available {&buf-p} then do:
        create tt-tnved-item .
        assign
          tt-tnved-item.mark            = ""
          tt-tnved-item.disp-order      = 0
          tt-tnved-item.tnved-code      = {&buf-p}.tnved-code
          tt-tnved-item.tnved-item-code = {&buf-p}.tnved-item-code
          tt-tnved-item.whole-send-news = {&buf-p}.whole-send-news
          tt-tnved-item.tnved-item-name =
            if {&buf-p}.whole-send-news = {&tnved-prod-level}
                                   then                      {&buf-p}.tnved-item-name
                                   else substitute("    &1", {&buf-p}.tnved-item-name)
          v-item-level = {&buf-p}.whole-send-news
        .
      end .
      else v-item-level = {&tnved-typp-level} .
    end . /* end_of first-of tnved-item-code */
    
    if v-item-level > {&tnved-typp-level} then do:
      case {&buf-pa}.attr-code :
        when {&tnved-attr-parentcode} then do:
          /* для вида его родитель продукт, для продукта - тип */
          tt-tnved-item.parent-code = {&buf-pa}.attr-value .
          case v-item-level :
            when {&tnved-prod-level} then do: /* 2 */
              assign
                tt-tnved-item.typp-code       = tt-tnved-item.parent-code
                tt-tnved-item.prod-code       = tt-tnved-item.tnved-item-code
                tt-tnved-item.kind-code       = ""
              . 
              v-name-ind = integer(tt-tnved-item.parent-code) no-error.
              tt-tnved-item.typp-name = if v-name-ind > 0 then v-typp-names[v-name-ind] else "" .
            end .
            when {&tnved-kind-level} then do: /* 3 */
              assign
                tt-tnved-item.typp-code       = ""
                tt-tnved-item.prod-code       = tt-tnved-item.parent-code
                tt-tnved-item.kind-code       = tt-tnved-item.tnved-item-code
              .
            end . 
            otherwise . /* 1 */
          end case .
        end .
        when {&tnved-attr-tnvedcode} then tt-tnved-item.tnved-code-list = {&buf-pa}.attr-value .
        when {&tnved-attr-disporder} then tt-tnved-item.disp-order-str  = {&buf-pa}.attr-value .
        otherwise . /* unknown */
      end case.
    end . /* end_of available_buf-p */
    
  end . /* end_of for_each &buf-pa */

  extent(v-typp-names) = ?.
  run waitfram-hide in this-procedure.

&undefine buf-pc
&undefine buf-pb
&undefine buf-pa
&undefine buf-p
&undefine tnved-kind-level-str
&undefine tnved-prod-level-str

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-in-browse Dialog-Frame 
PROCEDURE find-in-browse :
define input parameter p-search-str as character no-undo . /* строка для поиска по наименованию */
define variable v-search-str  as character no-undo .
define variable v-is-found    as logical no-undo .
define variable v-focused-row as integer no-undo .
/* буффер для поиска по наименованию */
define buffer buf_tt-tnved-item for tt-tnved-item .
define query q_brw-2 for buf_tt-tnved-item .

  if not available tt-tnved-item then return . /* пустой список */

  assign
    v-is-found   = false
    v-search-str = substitute("*&1*", p-search-str)
    v-focused-row = {&BROWSE-NAME} :focused-row in frame {&FRAME-NAME}
  .
  open query q_brw-2
    FOR EACH buf_tt-tnved-item
       where buf_tt-tnved-item.tnved-item-name matches v-search-str
          by buf_tt-tnved-item.disp-order-str .
  /* сначала ищем от текущей строки на экране */
  repeat :
    get next q_brw-2 .
    if not available buf_tt-tnved-item then leave .
    if buf_tt-tnved-item.disp-order-str > tt-tnved-item.disp-order-str then do:
      {&BROWSE-NAME} :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
      reposition {&BROWSE-NAME} to rowid rowid ( buf_tt-tnved-item ).
      v-is-found = true .
      leave .
    end .
  end .
  /* если ниже текущей строки не найдено - ищем с начала списка */
  if not v-is-found then do :
    get first q_brw-2 .
    if available buf_tt-tnved-item then do:
      {&BROWSE-NAME} :set-repositioned-row(v-focused-row, "ALWAYS") in frame {&FRAME-NAME}.
      reposition {&BROWSE-NAME} to rowid rowid ( buf_tt-tnved-item ).
      v-is-found = true .
    end .
  end .
  close query q_brw-2 .
  if not v-is-found then do:
    message substitute("Запись не найдена.") view-as alert-box .
  end .  

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-row-disp Dialog-Frame 
PROCEDURE proc-row-disp :
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-view Dialog-Frame 
PROCEDURE refresh-view :
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-browse Dialog-Frame 
PROCEDURE reopen-browse :
  run refresh-view.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-file Dialog-Frame 
PROCEDURE import-file :
define input parameter p-imp-file-name as character no-undo .
define buffer buf{&tnved-typp-level}_tnved-item      for tt-tnved-item-imp .
define buffer buf{&tnved-typp-level}_tnved-item-attr for tt-tnved-item-attr-imp .
define buffer buf{&tnved-prod-level}_tnved-item      for tt-tnved-item-imp .
define buffer buf{&tnved-prod-level}_tnved-item-attr for tt-tnved-item-attr-imp .
define buffer buf{&tnved-kind-level}_tnved-item      for tt-tnved-item-imp .
define buffer buf{&tnved-kind-level}_tnved-item-attr for tt-tnved-item-attr-imp .
&scoped-define buf-imp-t  buf{&tnved-typp-level}_tnved-item
&scoped-define buf-imp-ta buf{&tnved-typp-level}_tnved-item-attr
&scoped-define buf-imp-p  buf{&tnved-prod-level}_tnved-item
&scoped-define buf-imp-pa buf{&tnved-prod-level}_tnved-item-attr
&scoped-define buf-imp-k  buf{&tnved-kind-level}_tnved-item
&scoped-define buf-imp-ka buf{&tnved-kind-level}_tnved-item-attr
define variable v-imp-row   as character no-undo .
define variable v-str-typp-code as character no-undo .
define variable v-str-prod-code as character no-undo .
define variable v-str-kind-code as character no-undo .
define variable v-srt-prod-code as character no-undo .
define variable v-srt-kind-code as character no-undo .
define variable v-wait-msg   as character no-undo .
define variable v-lines      as integer no-undo .
define variable v-ln-prev    as integer no-undo .
define variable v-tm-prev    as integer no-undo .
define variable v-tm-curr    as integer no-undo .

  empty temp-table tt-tnved-item-imp  .
  empty temp-table tt-tnved-item-attr-imp .
  
  do transaction on error undo, return error string(os-error):
    input stream f-imp from value(p-imp-file-name) .
  end .

  assign
    v-wait-msg = "Импорт справочника типов продукции. Строк прочитано: &1"
    v-lines    = 0
    v-ln-prev  = v-lines + 100
    v-tm-prev  = time + 1
  .
  run waitfram-show in this-procedure ("Импорт справочника типов продукции.") .
  /* первую строку с заголовками столбцов отбрасываем */
  import stream f-imp unformatted v-imp-row .
  repeat on endkey undo, leave
         on error undo, leave :

    v-lines = v-lines + 1 .
    if v-lines > v-ln-prev then do:
      v-ln-prev = v-lines + 100.
      v-tm-curr = time.
      if v-tm-prev < v-tm-curr then do:
        v-tm-prev  = v-tm-curr + 1 .
        run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
      end .
    end.

    /* внутри файла есть текстовые поля, содержащие ';',
       поэтому для распарсивания строки используем встроенные возможности Progress */
    empty temp-table tt-imp .
    create tt-imp .
    import stream f-imp DELIMITER ';' tt-imp .
    /* В доп.атрибуты пишем:
       - код ТН ВЭД продукции        = "tnved-code"
       - ссылку на вышестоящий узел  = "parent-code"
       - очерёдность отображения в списке = "order-str"
    */
    v-str-typp-code = trim(tt-imp.typp-code) .
    if not can-find (first {&buf-imp-t} where {&buf-imp-t}.tnved-item-code = v-str-typp-code
                                          and {&buf-imp-t}.whole-send-news = {&tnved-typp-level}) then do:
      create {&buf-imp-t} .
      assign
        {&buf-imp-t}.tnved-code      = 0
        {&buf-imp-t}.whole-send-news = {&tnved-typp-level}
        {&buf-imp-t}.tnved-item-code = v-str-typp-code
        {&buf-imp-t}.tnved-item-name = trim(tt-imp.typp-name)
      .
      /* buf-imp-ta не заполняем:
         - родитель совпадает с tnved-code,
         - вместо самого tnved-code у нас столбец 01, который мы игнорируем
         - очерёдность не используется, т.к. записи этого уровня не отображаются в списке */
    end .
    
    v-str-prod-code = trim(tt-imp.prod-code) .
    if not can-find (first {&buf-imp-p} where {&buf-imp-p}.tnved-item-code = v-str-prod-code
                                          and {&buf-imp-p}.whole-send-news = {&tnved-prod-level}) then do:
      v-srt-prod-code = string(v-lines, "999999999") .
      create {&buf-imp-p} .
      assign
        {&buf-imp-p}.tnved-code      = 0
        {&buf-imp-p}.whole-send-news = {&tnved-prod-level}
        {&buf-imp-p}.tnved-item-code = v-str-prod-code
        {&buf-imp-p}.tnved-item-name = trim(tt-imp.prod-name)
      .
      create {&buf-imp-pa} .
      assign
        {&buf-imp-pa}.tnved-code      = {&buf-imp-p}.tnved-code
        {&buf-imp-pa}.tnved-item-code = {&buf-imp-p}.tnved-item-code
        {&buf-imp-pa}.attr-code       = {&tnved-attr-tnvedcode}
        {&buf-imp-pa}.attr-value      = trim(tt-imp.prod-tnved)
      .
      create {&buf-imp-pa} .
      assign
        {&buf-imp-pa}.tnved-code      = {&buf-imp-p}.tnved-code
        {&buf-imp-pa}.tnved-item-code = {&buf-imp-p}.tnved-item-code
        {&buf-imp-pa}.attr-code       = {&tnved-attr-parentcode}
        {&buf-imp-pa}.attr-value      = v-str-typp-code
      .
      create {&buf-imp-pa} .
      assign
        {&buf-imp-pa}.tnved-code      = {&buf-imp-p}.tnved-code
        {&buf-imp-pa}.tnved-item-code = {&buf-imp-p}.tnved-item-code
        {&buf-imp-pa}.attr-code       = {&tnved-attr-disporder}
        {&buf-imp-pa}.attr-value      = substitute("&1,&2,&3", v-str-typp-code, v-srt-prod-code, "")
      .
    end .
    
    v-str-kind-code = trim(tt-imp.kind-code) .
    /* 25/IV-2018 в видах продукции встречаются строки с совпадающим guid вида продукции: 
сухая молочная сыворотка (не более 1,5 мас.%) 4041  2976e599-35c8-4e24-bbf0-4242cf2282fa
сухая молочная сыворотка (не более 1,5 мас.%) 404   2976e599-35c8-4e24-bbf0-4242cf2282fa
                  первую строку импортируем, последующие - игнорируем
    */
    if not can-find (first {&buf-imp-k} where {&buf-imp-k}.tnved-item-code = v-str-kind-code
                                          and {&buf-imp-k}.whole-send-news = {&tnved-kind-level}) then do:
      v-srt-kind-code = string(v-lines, "999999999") .
      create {&buf-imp-k} .
      assign
        {&buf-imp-k}.tnved-code      = 0
        {&buf-imp-k}.whole-send-news = {&tnved-kind-level}
        {&buf-imp-k}.tnved-item-code = v-str-kind-code
        {&buf-imp-k}.tnved-item-name = trim(tt-imp.kind-name)
      .
      create {&buf-imp-ka} .
      assign
        {&buf-imp-ka}.tnved-code      = {&buf-imp-k}.tnved-code
        {&buf-imp-ka}.tnved-item-code = {&buf-imp-k}.tnved-item-code
        {&buf-imp-ka}.attr-code       = {&tnved-attr-tnvedcode}
        {&buf-imp-ka}.attr-value      = trim(tt-imp.kind-tnved)
      .
      create {&buf-imp-ka} .
      assign
        {&buf-imp-ka}.tnved-code      = {&buf-imp-k}.tnved-code
        {&buf-imp-ka}.tnved-item-code = {&buf-imp-k}.tnved-item-code
        {&buf-imp-ka}.attr-code       = {&tnved-attr-parentcode}
        {&buf-imp-ka}.attr-value      = v-str-prod-code
      .
      create {&buf-imp-ka} .
      assign
        {&buf-imp-ka}.tnved-code      = {&buf-imp-k}.tnved-code
        {&buf-imp-ka}.tnved-item-code = {&buf-imp-k}.tnved-item-code
        {&buf-imp-ka}.attr-code       = {&tnved-attr-disporder}
        {&buf-imp-ka}.attr-value      = substitute("&1,&2,&3", v-str-typp-code, v-srt-prod-code, v-srt-kind-code)
      .
    end .
  end. /* end_of repeat_import */
  input stream f-imp close .
  
  assign
    v-wait-msg = "Импорт справочника типов продукции. Строк записано: &1"
    v-lines    = 0
    v-ln-prev  = v-lines + 100
  .
  run waitfram-show in this-procedure ("Импорт справочника типов продукции. Удаление строк.") .

  /* сохранить временные таблицы в БД */
  define buffer buf_tnved-item      for ub.tnved-item .
  define buffer buf_tnved-item-attr for ub.tnved-item-attr .
  define buffer buf_tt-tnved-item-imp      for tt-tnved-item-imp .  
  define buffer buf_tt-tnved-item-attr-imp for tt-tnved-item-attr-imp .  
  /* разделяем на транзакции, т.к. иначе переполняется -L параметр */
  do transaction on error undo, leave:
    for each buf_tnved-item-attr exclusive-lock : delete buf_tnved-item-attr . end .
    for each buf_tnved-item      exclusive-lock : delete buf_tnved-item .      end .
  end .
  for each buf_tt-tnved-item-imp :
    v-lines = v-lines + 1 .
    if v-lines > v-ln-prev then do:
      v-ln-prev = v-lines + 100.
      v-tm-curr = time.
      if v-tm-prev < v-tm-curr then do:
        v-tm-prev  = v-tm-curr + 1 .
        run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
      end .
    end.
    do transaction on error undo, leave:
      create buf_tnved-item .
      buffer-copy buf_tt-tnved-item-imp to buf_tnved-item .
    end .
  end .
  for each buf_tt-tnved-item-attr-imp :
    v-lines = v-lines + 1 .
    if v-lines > v-ln-prev then do:
      v-ln-prev = v-lines + 100.
      v-tm-curr = time.
      if v-tm-prev < v-tm-curr then do:
        v-tm-prev  = v-tm-curr + 1 .
        run waitfram-show in this-procedure (substitute(v-wait-msg, v-lines)) .
      end .
    end.
    do transaction on error undo, leave:
      create buf_tnved-item-attr .
      buffer-copy buf_tt-tnved-item-attr-imp to buf_tnved-item-attr .
    end .
  end .
  
  define variable vMsg as character no-undo .
  /* @NOTE не поддерживаетсяProgress v.10.1b
  catch exAppErrors as class Progress.Lang.AppError :
    vMsg = exAppErrors:ReturnValue .
    if vMsg > "" then . else do :
      vMsg = exAppErrors:GetMessage(1) .
      if vMsg > "" then . else vMsg = "AppError при импорте" .
    end .
    message "AppError" skip(1) vMsg view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    vMsg = exProErrors:GetMessage(1) . 
    if vMsg > "" then . else vMsg = "ProError в фирмах" .
    message "ProError" skip(1) vMsg view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    vMsg = "Unexpected error в фирмах" .
    message "LangError" skip(1) vMsg view-as alert-box.
  end catch .
  finally :
    run waitfram-hide in this-procedure.
    message "Finally" view-as alert-box.
  end finally .
  */
  run waitfram-hide in this-procedure.
    
&undefine buf-imp-t
&undefine buf-imp-ta
&undefine buf-imp-p
&undefine buf-imp-pa
&undefine buf-imp-k
&undefine buf-imp-ka
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
