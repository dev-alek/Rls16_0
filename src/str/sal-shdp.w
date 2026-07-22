&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-schedule-attr NO-UNDO LIKE ub.schedule-attr.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор параметров для автоматическиго обработки документов продаж по расписанию.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/05
Author: Bakhtadze Natalya
Creation date: 03/22/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle   no-undo.
define input  parameter p-cre-db-num  as integer   no-undo .
define input  parameter p-task-type   as character no-undo .
define input  parameter p-task-num    as integer   no-undo .
define output parameter p-cancel      as logical      no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для автоматическиго обработки документов продаж по расписанию.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ ref/shd-attr.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define variable v-obj-list              as character    no-undo.
define variable v-host-code             as integer      no-undo.
define variable v-host-name             as character    no-undo.
dEFINE variable v-param-type            as character    no-undo.
define variable filter-point0 as character no-undo init "Обработка продаж" .
define variable filter-point as character no-undo init "Обработка продаж" .
DEFINE VARIABLE kl AS INTEGER INITIAL 0.
define variable MethodReturn AS LOGICAL.
define variable id as recid no-undo .
define variable IDENT AS RECID no-undo .

define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.

DEFINE TEMP-TABLE temp-inkas NO-UNDO
    FIELD inkas-code LIKE ub.inkas.inkas-code
    FIELD shift-date LIKE ub.inkas.shift-date
    FIELD shift-num  LIKE ub.inkas.shift-num
    FIELD num-flt    AS INTEGER
    INDEX pi IS PRIMARY UNIQUE inkas-code
.

&SCOPED-DEFINE step-labels "Создавать продажи по шаблонам,~
                            Закачивать чеки в продажу,~
                            Резервировать товары продажи,~
                            Закрывать документ продажи на факт,~
                            Удалять пустые (без чеков) продажи"
&SCOPED-DEFINE step-values "0,100,200,300,400"

&SCOPED-DEFINE min-finalize-study 100
&SCOPED-DEFINE max-finalize-study 200

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-template

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-schedule-attr

/* Definitions for BROWSE br-template                                   */
&Scoped-define FIELDS-IN-QUERY-br-template ~
entry(2, temp-schedule-attr.attr-code, {&delim-par}) ~
entry(3, temp-schedule-attr.attr-value, {&delim-par})
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-template
&Scoped-define QUERY-STRING-br-template FOR EACH temp-schedule-attr ~
      WHERE temp-schedule-attr.cre-db-num = p-cre-db-num ~
 AND temp-schedule-attr.task-type = p-task-type ~
 AND temp-schedule-attr.task-num = p-task-num ~
 AND temp-schedule-attr.attr-code BEGINS ({&attr-schedule-date-list-h} + {&delim-par}) NO-LOCK
&Scoped-define OPEN-QUERY-br-template OPEN QUERY br-template FOR EACH temp-schedule-attr ~
      WHERE temp-schedule-attr.cre-db-num = p-cre-db-num ~
 AND temp-schedule-attr.task-type = p-task-type ~
 AND temp-schedule-attr.task-num = p-task-num ~
 AND temp-schedule-attr.attr-code BEGINS ({&attr-schedule-date-list-h} + {&delim-par}) NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-template temp-schedule-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-template temp-schedule-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-template}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help rct-obj RECT-6 rs-1 ~
bt-sel-obj rs-start rs-end T-finalize-100 T-finalize-200 btn-add btn-del ~
btn-update-main btn-update br-template ED-FILTER
&Scoped-Define DISPLAYED-OBJECTS rs-1 ed-object rs-start rs-end ~
T-finalize-100 T-finalize-200 F-shift-date F-shift-name F-shift-num ~
ED-FILTER

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD octal-to-char Dialog-Frame
FUNCTION octal-to-char RETURNS CHARACTER
( p-string as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON bt-sel-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON btn-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить новый фильтр".

DEFINE BUTTON btn-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить ранее существующий фильтр".

DEFINE BUTTON btn-update
     LABEL "&Фильтр по чекам":L
     SIZE 20 BY 1 TOOLTIP "Изменить установки фильтра по чекам".

DEFINE BUTTON btn-update-main
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить установки шаблона".

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ED-FILTER AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 39 BY 3.83 NO-UNDO.

DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 40.75 BY 3.38
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE F-shift-date AS CHARACTER FORMAT "X(20)":U
     LABEL "Дата смены(учета)"
     VIEW-AS FILL-IN
     SIZE 21 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-shift-name AS CHARACTER FORMAT "X(2)":U
     LABEL "№ смены (может игнор.)"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-shift-num AS CHARACTER FORMAT "X(2)":U
     LABEL "Порядок смен(может игнор.)"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все объекты БД", 1,
"все объекты БД по фирме", 2,
"объекты выборочно", 3
     SIZE 28 BY 3.25 NO-UNDO.

DEFINE VARIABLE rs-end AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "0", 0,
"100", 100,
"200", 200,
"300", 300,
"400", 400
     SIZE 38 BY 5.5 NO-UNDO.

DEFINE VARIABLE rs-start AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "0", 0,
"100", 100,
"200", 200,
"300", 300,
"400", 400
     SIZE 38 BY 5.5 NO-UNDO.

DEFINE RECTANGLE rct-obj
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.25.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 7.

DEFINE VARIABLE T-finalize-100 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 NO-UNDO.

DEFINE VARIABLE T-finalize-200 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .75 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-template FOR
      temp-schedule-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-template
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-template Dialog-Frame _STRUCTURED
  QUERY br-template NO-LOCK DISPLAY
      entry(2, temp-schedule-attr.attr-code, {&delim-par}) COLUMN-LABEL "№" FORMAT "X(2)":U
      entry(3, temp-schedule-attr.attr-value, {&delim-par}) COLUMN-LABEL "Название шаблона" FORMAT "X(50)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56 BY 6.25
         TITLE "Список шаблонов" ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 71
     rs-1 AT ROW 3 COL 3.5 NO-LABEL
     ed-object AT ROW 3 COL 38 NO-LABEL
     bt-sel-obj AT ROW 5.25 COL 33
     rs-start AT ROW 7.75 COL 3 NO-LABEL
     rs-end AT ROW 7.75 COL 42 NO-LABEL
     T-finalize-100 AT ROW 9.25 COL 81.5
     T-finalize-200 AT ROW 10.25 COL 81.5
     F-shift-date AT ROW 13.25 COL 75.5 COLON-ALIGNED
     btn-add AT ROW 13.75 COL 2
     btn-del AT ROW 13.75 COL 12
     btn-update-main AT ROW 13.75 COL 22
     btn-update AT ROW 13.75 COL 32
     F-shift-name AT ROW 14.5 COL 89 COLON-ALIGNED
     br-template AT ROW 15 COL 1.5
     F-shift-num AT ROW 15.5 COL 89 COLON-ALIGNED
     ED-FILTER AT ROW 17.5 COL 59 NO-LABEL
     "Начальная стадия обработки" VIEW-AS TEXT
          SIZE 37 BY 1 AT ROW 6.75 COL 3
          FGCOLOR 4
     "Дополнительный фильтр по чекам" VIEW-AS TEXT
          SIZE 39 BY .67 AT ROW 16.75 COL 59
          BGCOLOR 1 FGCOLOR 15
     "Пометить как заверш." VIEW-AS TEXT
          SIZE 20.5 BY 1 AT ROW 6.75 COL 78.5
          FGCOLOR 4
     "Конечная стадия обработки" VIEW-AS TEXT
          SIZE 33 BY 1 AT ROW 6.75 COL 41.5
          FGCOLOR 4
     rct-obj AT ROW 2.25 COL 2
     RECT-6 AT ROW 6.5 COL 2
     SPACE(0.00) SKIP(7.83)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры обработки документов продаж по расписанию"
         CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-schedule-attr T "?" NO-UNDO ub schedule-attr
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-template F-shift-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON btn-add IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-del IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-update IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON btn-update-main IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       ED-FILTER:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-shift-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-shift-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-shift-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-template
/* Query rebuild information for BROWSE br-template
     _TblList          = "Temp-Tables.temp-schedule-attr"
     _Options          = "NO-LOCK"
     _Where[1]         = "Temp-Tables.temp-schedule-attr.cre-db-num = p-cre-db-num
 AND Temp-Tables.temp-schedule-attr.task-type = p-task-type
 AND Temp-Tables.temp-schedule-attr.task-num = p-task-num
 AND Temp-Tables.temp-schedule-attr.attr-code BEGINS ({&attr-schedule-date-list-h} + {&delim-par})"
     _FldNameList[1]   > "_<CALC>"
"entry(2, temp-schedule-attr.attr-code, {&delim-par})" "№" "X(2)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[2]   > "_<CALC>"
"entry(3, temp-schedule-attr.attr-value, {&delim-par})" "Название шаблона" "X(50)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-template */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры обработки документов продаж по расписанию */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-template
&Scoped-define SELF-NAME br-template
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-template Dialog-Frame
ON VALUE-CHANGED OF br-template IN FRAME Dialog-Frame /* Список шаблонов */
DO:
  assign
  f-shift-DATE:screen-value = ""
  f-shift-num:screen-value = ""
  f-shift-name:screen-value = ""
  ED-FILTER:screen-value = ""
  .
  IF AVAILABLE(temp-schedule-attr) THEN DO:
    RUN proc-value-changed IN THIS-PROCEDURE NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-exclude-obj-list     as character     no-undo.
    assign
        rs-1 :screen-value  = "3"
    .

    { gbl/uobjclr.i  }

    for each temp_obj-list:

    { gbl/uobjapnd.i
      temp_obj-list.obj-type
      temp_obj-list.obj-code
    }
    end.

    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true
    then do:
      message
        "Объект не выбран"
        view-as alert-box information .
      return NO-APPLY .
    end.


    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    define variable v-skip-store as integer   no-undo .
    assign
      v-skip-store = 0
    .
    for each temp_obj-list :
      delete temp_obj-list.
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      if buf_userobjs_temp-user-obj.obj-type = {&stock}
      then do:
        assign
          v-skip-store = v-skip-store + 1
        .
      end.
      find first temp_obj-list no-lock where
                temp_obj-list.obj-type  = buf_userobjs_temp-user-obj.obj-type
            and temp_obj-list.obj-code  = buf_userobjs_temp-user-obj.obj-code no-error .
      if not available temp_obj-list then do:
        create temp_obj-list.
        assign
          temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
          temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
        .
        release temp_obj-list.
      end.
    end.

    if v-skip-store <> 0
    then do:
      message
        substitute("Среди выбранных были объекты типа &1", {&stock}) skip
        "Они были исключены из списка" skip
        substitute("Всего было исключено &1 объектов", v-skip-store) skip
        view-as alert-box information .
    end.

    run select-objects-only-this-db in this-procedure
      (output v-obj-list
      ,output v-exclude-obj-list
      ).
    if v-exclude-obj-list <> ""
    then do:
        message
            "Из списка выбранных объектов исключены"
            skip "объекты, не принадлежащие БД, указанной в расписании:"
            skip(1)
            skip v-exclude-obj-list
        view-as alert-box information.
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-add Dialog-Frame
ON CHOOSE OF btn-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define buffer buf_temp-schedule-attr for temp-schedule-attr.
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "VALUE-CHANGED" TO br-template.
  apply "entry" to br-template.
  APPLY "CHOOSE" TO btn-update-main.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-del Dialog-Frame
ON CHOOSE OF btn-del IN FRAME Dialog-Frame /* Удалить */
do:

IF NOT available temp-schedule-attr THEN RETURN NO-APPLY.
RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-update Dialog-Frame
ON CHOOSE OF btn-update IN FRAME Dialog-Frame /* Фильтр по чекам */
DO:
 IF NOT AVAILABLE temp-schedule-attr THEN RETURN NO-APPLY.

 RUN proc-filter IN THIS-PROCEDURE NO-ERROR.
 IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn-update-main
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn-update-main Dialog-Frame
ON CHOOSE OF btn-update-main IN FRAME Dialog-Frame /* Изменить */
DO:
DEFINE VARIABLE v-name AS CHARACTER NO-UNDO.
define variable v-str as character no-undo .
define variable v-str-rus as character no-undo .
define variable v-str-int as character no-undo .
define variable v-str-rus-int as character no-undo .
define variable v-str-int-shift-name as character no-undo .
define variable v-str-rus-int-shift-name as character no-undo .
define variable v-flt-rec as recid no-undo .
IF NOT AVAILABLE temp-schedule-attr THEN RETURN NO-APPLY.
ASSIGN
v-flt-rec = recid(temp-schedule-attr)
v-name = ENTRY(3, temp-schedule-attr.attr-VALUE, {&delim-par})
v-str = entry(1, ENTRY(1, temp-schedule-attr.attr-VALUE, {&delim-par}))
v-str-rus = entry(1, ENTRY(2, temp-schedule-attr.attr-VALUE, {&delim-par}))
v-str-int = entry(2, ENTRY(1, temp-schedule-attr.attr-VALUE, {&delim-par}))
v-str-rus-int = entry(2, ENTRY(2, temp-schedule-attr.attr-VALUE, {&delim-par}))
.
if num-entries(ENTRY(1, temp-schedule-attr.attr-VALUE, {&delim-par})) > 2 then
assign
v-str-int-shift-name = entry(3, ENTRY(1, temp-schedule-attr.attr-VALUE, {&delim-par}))
v-str-rus-int-shift-name = entry(3, ENTRY(2, temp-schedule-attr.attr-VALUE, {&delim-par}))
.

  run str/asltmpl0.w ( parparentproc
                 ,INPUT-OUTPUT v-name
                 ,INPUT-OUTPUT v-str
                 ,INPUT-OUTPUT v-str-rus
                 ,INPUT-OUTPUT v-str-int
                 ,INPUT-OUTPUT v-str-rus-int
                 ,INPUT-OUTPUT v-str-rus-int-shift-name
                 ,INPUT-OUTPUT v-str-rus-int-shift-name
                 ) No-error.
  IF NOT ERROR-STATUS:error
  and v-name > ''
  THEN DO:
   RUN temp-schedule-attr-write  IN THIS-PROCEDURE(
                                             input p-cre-db-num
                                            ,input p-task-type
                                            ,input p-task-num
                                            ,input temp-schedule-attr.attr-code
                                            ,input (v-str + {&comma-char} +
                                                    v-str-int + {&comma-char} +
                                                    v-str-int-shift-name +
                                                    {&delim-par} +
                                                   v-str-rus + {&comma-char} +
                                                   v-str-rus-int + {&comma-char} +
                                                   v-str-rus-int-shift-name +
                                                    {&delim-par} + v-name)).

     {&OPEN-QUERY-br-template}
      reposition br-template to recid v-flt-rec no-error.
     APPLY "VALUE-CHANGED" TO br-template.
     apply "entry" to br-template.
 END.
 if v-name = '' then do:
   apply "CHOOSE" to btn-del.
 end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-cancel = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    define variable v-obj-list as character     no-undo.
    define variable v-deleted as logical     no-undo.
    DEFINE BUFFER buf_schedule-attr FOR ub.schedule-attr.
    DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
    ASSIGN
        rs-1
        rs-start
        rs-end
        t-finalize-100
        t-finalize-200
    .
    case rs-1
    :
    when 1
    then do:
        assign
            v-obj-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-obj-list = ""
        .
    end.
    when 3
    then do:
        assign
            v-obj-list = ""
        .
        for each temp_obj-list
        :
            assign
                v-obj-list = v-obj-list
                        + ( if v-obj-list = "" then "" else "," ) + temp_obj-list.obj-type
                        + "," + string( temp_obj-list.obj-code )
            .
        end.
    end.
    end case.
    find first temp_obj-list no-error.
    if not available temp_obj-list
    and rs-1 = 3
    then do:
        message
            "Не выбраны объекты для обработкаи документов продаж."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    run attach-attr-to-schedule-line in this-procedure (
          input rs-1
        , input v-obj-list
        , INPUT rs-start
        , INPUT rs-end
        , INPUT t-finalize-100
        , INPUT t-finalize-200
    ).
     if rs-start = 0 then do:
      find first buf_temp-schedule-attr NO-LOCK WHERE
                buf_temp-schedule-attr.cre-db-num = p-cre-db-num
             AND buf_temp-schedule-attr.task-type = p-task-type
             AND buf_temp-schedule-attr.task-num = p-task-num
             AND buf_temp-schedule-attr.attr-code BEGINS ({&attr-schedule-date-list-h} + {&delim-par})  no-error.
        if not available buf_temp-schedule-attr then do:
          message
          "Не определено ни одного шаблона для создания документов продаж" skip
          "Расписание не может быть сохранено"
          view-as alert-box .
          return no-apply.
        end.
        RUN save-table IN THIS-PROCEDURE.
      end.
      else DO:
       RUN save-table IN THIS-PROCEDURE.
       /*может не стоит удалять пока???????*/
       /*
       FOR EACH buf_schedule-attr NO-LOCK WHERE
                buf_schedule-attr.task-type = p-task-type
             AND buf_schedule-attr.cre-db-num = p-cre-db-num
             AND buf_schedule-attr.task-num = p-task-num
             AND buf_schedule-attr.attr-code BEGINS ({&attr-schedule-date-list-h} + {&delim-par}) :
         RUN schedule-attr-delete IN THIS-PROCEDURE (
                                                      input p-cre-db-num
                                                      ,input p-task-type
                                                      ,input p-task-num
                                                      ,input ({&attr-schedule-filter-h} + {&delim-par} + string(integer(entry(2, buf_schedule-attr.attr-code, {&delim-par}))))
                                                      ,output v-deleted       ) NO-ERROR.
         message 11
         ERROR-STATUS:ERROR  v-deleted
         view-as alert-box .
         IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

         RUN schedule-attr-delete IN THIS-PROCEDURE (
                                                            input p-cre-db-num
                                                            ,input p-task-type
                                                            ,input p-task-num
                                                            ,input buf_schedule-attr.attr-code
                                                            ,output v-deleted       ) NO-ERROR.
         IF ERROR-STATUS:ERROR OR NOT v-deleted THEN RETURN NO-APPLY.
      END.
      */
    END.
    APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-1 Dialog-Frame
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
DO:
    assign
        rs-1
    .
    run object-select in this-procedure (
        input rs-1
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-end Dialog-Frame
ON VALUE-CHANGED OF rs-end IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE ii AS INTEGER NO-UNDO.
  DEFINE VARIABLE v-label AS character NO-UNDO.
  DEFINE VARIABLE v-value AS integer NO-UNDO.
  ASSIGN
  rs-end.
  IF NOT (rs-start <= 100 AND rs-end >= 100) THEN DO:
   ASSIGN
   t-finalize-100 = NO
   .
   DISPLAY
   t-finalize-100
   WITH FRAME {&FRAME-NAME}.
   DISPLAY
   t-finalize-100
   WITH FRAME {&FRAME-NAME}.
  END.
  IF NOT (rs-start <= 200 AND rs-end >= 200) THEN DO:
   ASSIGN
   t-finalize-200 = NO
   .
   DISPLAY
   t-finalize-200
   WITH FRAME {&FRAME-NAME}.
   DISPLAY
   t-finalize-200
   WITH FRAME {&FRAME-NAME}.
  END.


_ii:
DO ii = 1 TO NUM-ENTRIES({&step-values}):
   ASSIGN
   v-label = trim(ENTRY(ii, {&step-labels}))
   v-value = integer(ENTRY(ii, {&step-values}))
   .
   IF v-value < rs-start THEN DO:
      NEXT _ii.
   END.
   IF v-value > rs-end THEN DO:
       leave _ii.
   END.
   /*IF v-value > rs-end THEN DO:*/
   IF v-value >= rs-start
   AND v-value <= rs-end  THEN DO:
       CASE v-value:
           WHEN 100 THEN DO:
               ENABLE
               t-finalize-100
               WITH FRAME {&FRAME-NAME}.
           END.
              WHEN 200 THEN DO:
               ENABLE
               t-finalize-200
               WITH FRAME {&FRAME-NAME}.
           END.
       END CASE.
   END.
END. /*DO ii = 1 */



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-start Dialog-Frame
ON VALUE-CHANGED OF rs-start IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-start.
  RUN proc-start IN THIS-PROCEDURE (rs-start) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-finalize-100
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-finalize-100 Dialog-Frame
ON VALUE-CHANGED OF T-finalize-100 IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-finalize-100.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-finalize-200
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-finalize-200 Dialog-Frame
ON VALUE-CHANGED OF T-finalize-200 IN FRAME Dialog-Frame
DO:
    ASSIGN
  t-finalize-200.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
    assign
    frame {&frame-name} :title = frame {&frame-name} :title +
                        substitute(". &1: Задача номер &2"
                        , p-task-type
                        , p-task-num )
    .
    { gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-host-code no-error }
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении кода фирмы текущего объекта"
          skip "Тип объекта:" v-cntxt-obj-type
          skip "Код объекта:" v-cntxt-obj-code
          skip "Обработка документов продаж невозможна"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error.
    end.
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-host-code
          skip "Имя фирмы будет отображаться как '" + {&cmp} + string( v-host-code ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box warning.
        assign
            v-host-name = {&cmp} + string( v-host-code )
        .
    end.
    run init-param-values in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , output v-obj-list
        , output rs-1
        , OUTPUT rs-start
        , OUTPUT rs-end
        , OUTPUT t-finalize-100
        , OUTPUT t-finalize-200
    ).
    RUN fill-table IN THIS-PROCEDURE.
    run MYenable.
    run object-select in this-procedure (
        input rs-1
    ).
    run init-fields in this-procedure .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line Dialog-Frame
PROCEDURE attach-attr-to-schedule-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define input parameter p-rs-1               as integer      no-undo.
    define input parameter p-object-list        as character    no-undo.
    define input parameter p-rs-start           as integer      no-undo.
    define input parameter p-rs-end             as integer      no-undo.
    define input parameter p-finalize-100       as logical      no-undo.
    define input parameter p-finalize-200       as logical      no-undo.

    define variable v-attr-value as character     no-undo.

    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.
    find first buf_schedule no-lock
         where buf_schedule.cre-db-num = p-cre-db-num
           and buf_schedule.task-type  = p-task-type
           and buf_schedule.task-num   = p-task-num
    no-error.
    if not available buf_schedule
    and (  p-task-type   <> {&btpr-type-autosale}
        or p-task-num    <> -1 )
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не найдена строка расписания."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-attr-value = string( p-rs-1 )
                       + "," + string( v-cntxt-host-code-obj )
                       + "," + string( p-rs-start )
                       + "," + string( p-rs-end )
                       + "," + string( p-finalize-100 )
                       + "," + string( p-finalize-200 )
    .
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , input v-attr-value
    ).
    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-obj-list-h}
        , input p-object-list
    ).
    for each buf_schedule-attr
    on error undo, return error
    :
        if buf_schedule-attr.task-type  <> {&btpr-type-autosale}
        or buf_schedule-attr.cre-db-num <> p-cre-db-num
        or buf_schedule-attr.task-num   <> -1
        or (
                buf_schedule-attr.attr-code <> {&attr-schedule-param-list-h}
            and buf_schedule-attr.attr-code <> {&attr-schedule-obj-list-h}
            and buf_schedule-attr.attr-code <> {&attr-schedule-date-list-h}
            and buf_schedule-attr.attr-code <> {&attr-schedule-filter-h}
)
        then do:
            find first buf_schedule
                 where buf_schedule.cre-db-num = buf_schedule-attr.cre-db-num
                   and buf_schedule.task-type  = buf_schedule-attr.task-type
                   and buf_schedule.task-num   = buf_schedule-attr.task-num
            no-error.
            if not available buf_schedule
            then do:
                delete buf_schedule-attr.
            end.
        end.
    end.        /* for each buf_schedule-attr */
end.
END PROCEDURE. /* attach-attr-to-schedule-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY rs-1 ed-object rs-start rs-end T-finalize-100 T-finalize-200
          F-shift-date F-shift-name F-shift-num ED-FILTER
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help rct-obj RECT-6 rs-1 bt-sel-obj rs-start
         rs-end T-finalize-100 T-finalize-200 btn-add btn-del btn-update-main
         btn-update br-template ED-FILTER
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE extract-parameter Dialog-Frame
PROCEDURE extract-parameter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:

end.
END PROCEDURE. /* extract-parameter */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_schedule-attr FOR ub.schedule-attr.
DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
FOR EACH buf_temp-schedule-attr:
    DELETE buf_temp-schedule-attr.
END.
FOR EACH buf_schedule-attr WHERE
        buf_schedule-attr.cre-db-num = p-cre-db-num
    AND buf_schedule-attr.task-type = p-task-type
    AND buf_schedule-attr.task-num = p-task-num:
  IF buf_schedule-attr.attr-code BEGINS ({&attr-schedule-date-list-h} + {&delim-par})
  or buf_schedule-attr.attr-code BEGINS ({&attr-schedule-filter-h}  + {&delim-par}) THEN DO:
    CREATE buf_temp-schedule-attr.
    BUFFER-COPY buf_schedule-attr
    TO
    buf_temp-schedule-attr.
  END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE filter-get Dialog-Frame
PROCEDURE filter-get :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-where-ysl AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-where-ysl-rus AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-where-phrase AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-where-phrase-rus AS CHARACTER NO-UNDO.
define variable  ind as integer no-undo.
define variable  v-new-where-phrase as character no-undo .
define variable  v-sub-phrase as character no-undo .

assign
p-where-phrase     = ""
p-where-phrase-rus = ""
.

if num-entries(p-where-ysl) > 0 then do:
  assign
  p-where-phrase = p-where-phrase
                  + ' and ('
  .

  do ind = 1 to num-entries(p-where-ysl):
    assign
    p-where-phrase = p-where-phrase
                  + " " + (if ind = 1 then left-trim(left-trim(entry(ind, p-where-ysl)), 'and':U)
                           else entry(ind, p-where-ysl))
    .
  end.
  assign
  p-where-phrase = p-where-phrase
                  + ')'
  .
end.

if num-entries(p-where-phrase, "{&delim-flt-tilda}") > 1 then do:
  assign
  v-new-where-phrase = entry(1, p-where-phrase, "{&delim-flt-tilda}")
  .
  do ind = 2 to num-entries(p-where-phrase, "{&delim-flt-tilda}")
  :
    assign
    v-sub-phrase = entry(ind, p-where-phrase, "{&delim-flt-tilda}")
    .
    if octal-to-char(substring(v-sub-phrase, 1, 3)) <> ? then do:
      assign
      v-new-where-phrase = v-new-where-phrase
                          + octal-to-char(substring(v-sub-phrase, 1, 3))
                          + substring(v-sub-phrase, 4)
      .
    end.
    else do:
      assign
      v-new-where-phrase = v-new-where-phrase
                          + "{&delim-flt-tilda}"
                          + v-sub-phrase
      .
    end.
  end. /*do ind = 2*/
  assign
  p-where-phrase = v-new-where-phrase
  .
end. /*f num-entries(p-where-phrase, "{&delim-flt-tilda}") > 1 then do:*/
assign
p-where-phrase-rus = p-where-ysl-rus
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name Dialog-Frame
PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.

define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-host-code
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else do:
        assign
            p-host-name = buf_clients.obj-name
        .
    end.
end.
END PROCEDURE. /* get-host-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define variable v-oper-num     as integer           no-undo.
    run manage-options          in this-procedure.
/*    assign*/
/*        rs-1 :screen-value in frame dialog-frame = "2"*/
/*        ed-object :screen-value in frame Dialog-frame = {&cmp} + string( v-host-code ) + " " + v-host-name*/
/*    .*/
/*    assign*/
/*        rs-1*/
/*    .*/
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame
PROCEDURE init-param-values :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-cre-db-num             as integer      no-undo .
define input parameter p-task-type              as character    no-undo.
define input parameter p-task-num               as integer      no-undo.
define output parameter p-obj-list              as character    no-undo.
define output parameter p-rs-1                  as integer      no-undo.
define output parameter p-rs-start              as integer      no-undo.
define output parameter p-rs-end                as integer      no-undo.
define output parameter p-finalize-100          as LOGICAL      no-undo.
define output parameter p-finalize-200          as LOGICAL      no-undo.

    define variable v-counter       as integer       no-undo.
    define variable v-param-list    as character     no-undo.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-obj-list-h}
        , output p-obj-list
        , output v-param-type
    ) .
    for each temp_obj-list
    :
        delete temp_obj-list.
    end.
    do v-counter = 1 to num-entries( p-obj-list ) / 2
    :
        create temp_obj-list.
        assign
            temp_obj-list.obj-type = entry( 2 * v-counter - 1,  p-obj-list )
            temp_obj-list.obj-code = integer( entry( 2 * v-counter,      p-obj-list ) )
        .
    end.
    run schedule-attr-value in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , output v-param-list
        , output v-param-type
    ) .
    if v-param-list = ""
    then do:
        assign
            p-rs-1                  = 1
            p-rs-start             = 0
            p-rs-end               = 300
            t-finalize-100         = NO
            t-finalize-200         = NO
        .
    end.
    else do:
        assign
            p-rs-1 = integer( entry( 1, v-param-list ) )
            p-rs-start = integer( entry( 3, v-param-list ) )
            p-rs-end = integer( entry( 4, v-param-list ) )
            p-finalize-100 = LOGICAL (entry( 5, v-param-list ) )
            p-finalize-200 = LOGICAL (entry( 6, v-param-list ) )
        .


    end.
end.
END PROCEDURE. /* init-param-values */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-options Dialog-Frame
PROCEDURE manage-options :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
assign
    rct-obj             :visible in frame {&frame-name} = yes
    rs-1                :visible in frame {&frame-name} = yes
    bt-sel-obj          :visible in frame {&frame-name} = yes
    ed-object           :visible in frame {&frame-name} = yes
.
run object-select in this-procedure (
    input rs-1
).

end.
END PROCEDURE. /* manage-options */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
dEFINE variable ii                      as INTEGER       no-undo.
DO ii =  1 TO NUM-ENTRIES({&step-values}):
    ASSIGN
    rs-start:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
    (IF ii = 1
    THEN (trim(ENTRY(ii, {&step-labels})) + {&comma-char} + ENTRY(ii, {&step-values}))
    ELSE (rs-start:RADIO-BUTTONS IN FRAME {&FRAME-NAME} + {&comma-char} +
         (trim(ENTRY(ii, {&step-labels})) + {&comma-char} + ENTRY(ii, {&step-values}))
         )
    ).

END.
ASSIGN
rs-end:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = rs-start:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
.
ASSIGN
filter-point = filter-point + {&space-char} + STRING(p-task-num)
.
DISPLAY
rs-1
ed-object
rs-start
rs-end
t-finalize-100
t-finalize-200
WITH FRAME Dialog-Frame.
ENABLE
rct-obj
RECT-6
Btn_OK
Btn_Cancel
b-help
rs-1
bt-sel-obj
rs-start
rs-end
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
APPLY "VALUE-CHANGED" TO rs-start IN FRAME {&FRAME-NAME}.
{&OPEN-QUERY-br-template}
APPLY "VALUE-CHANGED" TO br-template IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE object-select Dialog-Frame
PROCEDURE object-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-rs-1   as integer      no-undo.
case p-rs-1
:
    when 1
    then do:
        assign
            ed-object :screen-value in frame Dialog-frame = "Все объекты БД"
        .
    end.
    when 2
    then do:
        assign
            ed-object :screen-value = v-host-name
        .
    end.
    when 3
    then do:
        assign
            ed-object :screen-value = ""
        .
        for each temp_obj-list
        :
            assign
                ed-object :screen-value = ed-object :screen-value
                    + ( if ed-object :screen-value = "" then "" else ", " )
                    + temp_obj-list.obj-type + string( temp_obj-list.obj-code )
            .
        end.
    end.
end case.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-flt-rec as recid  no-undo .
DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
FIND LAST buf_temp-schedule-attr NO-LOCK WHERE
        buf_temp-schedule-attr.cre-db-num = p-cre-db-num
    AND buf_temp-schedule-attr.task-type = p-task-type
    AND buf_temp-schedule-attr.task-num = p-task-num
    AND buf_temp-schedule-attr.attr-code BEGINS ({&attr-schedule-date-list-h} + {&delim-par}) NO-ERROR.
  IF NOT AVAILABLE buf_temp-schedule-attr THEN Kl = 1.
  ELSE kl = integer(ENTRY(2, buf_temp-schedule-attr.attr-code, {&delim-par})) + 1.
  RUN temp-schedule-attr-write  IN THIS-PROCEDURE(
                                             input p-cre-db-num
                                            ,input p-task-type
                                            ,input p-task-num
                                            ,input ({&attr-schedule-date-list-h} + {&delim-par} + STRING(kl))
                                            ,input ("(TODAY - 1),0" + {&delim-par} +
                                                   "(TODAY - 1),0" + {&delim-par})
                                            ).
  FIND first buf_temp-schedule-attr NO-LOCK WHERE
          buf_temp-schedule-attr.cre-db-num = p-cre-db-num
      AND buf_temp-schedule-attr.task-type = p-task-type
      AND buf_temp-schedule-attr.task-num = p-task-num
      AND buf_temp-schedule-attr.attr-code = ({&attr-schedule-date-list-h} + {&delim-par} + STRING(kl)) .

  v-flt-rec = RECID(buf_temp-schedule-attr).

  {&OPEN-QUERY-br-template}
  REPOSITION br-template TO RECID v-flt-rec no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-deleted AS LOGICAL NO-UNDO.
define variable v-flt-rec as recid no-undo .
do on stop  undo, return:
 f-shift-DATE = "".
 f-shift-name = "".
 f-shift-num = "".
 ED-FILTER = "".

 v-flt-rec = recid(temp-schedule-attr).

 kl = INTEGER(ENTRY(2, temp-schedule-attr.attr-code, {&delim-par})).

 RUN temp-schedule-attr-delete IN THIS-PROCEDURE (
                                                 input p-cre-db-num
                                                ,input p-task-type
                                                ,input p-task-num
                                                ,input {&attr-schedule-date-list-h} + {&delim-par} + string(Kl)
                                                ,output v-deleted       ) NO-ERROR.

 IF ERROR-STATUS:ERROR or NOT v-deleted THEN UNDO, RETURN error.

 RUN temp-schedule-attr-delete IN THIS-PROCEDURE (
                                                 input p-cre-db-num
                                                ,input p-task-type
                                                ,input p-task-num
                                                ,input {&attr-schedule-filter-h} + {&delim-par} + string(Kl)
                                                ,output v-deleted       ) NO-ERROR.


IF ERROR-STATUS:ERROR THEN UNDO, RETURN error.

 {&OPEN-QUERY-br-template}
 REPOSITION br-template TO RECID v-flt-rec no-error.
 APPLY "VALUE-CHANGED" TO br-template IN FRAME {&FRAME-NAME}.
 apply "entry" to br-template.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-template Dialog-Frame
PROCEDURE proc-b-template :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'chk-doc'
  join-tbl = 'X_chk-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-type', 'Тип чека', 'receipt-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Т или у', 'gds-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Дата смены(учета)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-filter Dialog-Frame
PROCEDURE proc-filter :
define variable v-rid as recid no-undo .
define variable v-naim like ubflt.filter.naim no-undo .
define variable v-where-ysl as character no-undo .
define variable v-where-ysl-rus as character no-undo .
define variable where-phrase as character no-undo .
define variable where-phrase-rus as character no-undo .
define variable v-fields-sort as character no-undo .
define variable v-fields-sort-rus as character no-undo .
define variable p-lst-cend        as character no-undo .
define variable v-doc-rec        as  recid no-undo .

define buffer buf_temp-schedule-attr for temp-schedule-attr.

FIND FIRST buf_temp-schedule-attr NO-LOCK WHERE
          buf_temp-schedule-attr.cre-db-num = p-cre-db-num
    AND   buf_temp-schedule-attr.task-type  = p-task-type
    and   buf_temp-schedule-attr.task-num = p-task-num
    and buf_temp-schedule-attr.attr-code = {&attr-schedule-filter-h} + {&delim-par} +
                                      string(integer(entry(2, temp-schedule-attr.attr-code, {&delim-par})))   no-error.
if available buf_temp-schedule-attr then do:
  assign
  v-where-ysl = entry(1, buf_temp-schedule-attr.attr-value, {&delim-par})
  v-where-ysl-rus = entry(2, buf_temp-schedule-attr.attr-value, {&delim-par})
  v-naim          = entry(3, temp-schedule-attr.attr-value, {&delim-par})
  v-doc-rec       = recid(temp-schedule-attr)
  .

end.
else do:
end.
v-naim = entry(3, temp-schedule-attr.attr-value, {&delim-par}).
  Kl = 0.
  run gbl/updf.w  (
                input parparentproc
              , input "Обработка продаж"
              , input-output v-naim
              , input no  /*save-in-filter*/
              , input no  /*enable-sorting*/
              , input no  /*save-to-file*/
              , input no /*enable name-changing*/
              , input Tbl
              , input join-tbl
              , input Fld
              , input Lab
              , input Spr
              , input Dim
              , input-output v-where-ysl
              , input-output v-where-ysl-rus
              , input-output v-fields-sort
              , input-output v-fields-sort-rus
              , input-output p-lst-cend
              , input Kl
              , output v-rID).
  IF v-rid = ? THEN ID = IDENT.
  else do:
      run filter-get in this-procedure (
                                          input  v-where-ysl
                                         ,input  v-where-ysl-rus
                                         ,output where-phrase
                                         ,output where-phrase-rus
                                       ).
    if not available buf_temp-schedule-attr then do:
      create buf_temp-schedule-attr.
      buffer-copy temp-schedule-attr
      except attr-code attr-value
      to buf_temp-schedule-attr
      assign
      buf_temp-schedule-attr.attr-code = {&attr-schedule-filter-h} + {&delim-par} +
                                      string(integer(entry(2, temp-schedule-attr.attr-code, {&delim-par})))
      .
    end.
    assign
      buf_temp-schedule-attr.attr-value = where-phrase + {&delim-par} +
                                     where-phrase-rus
      .

  end.
  RUN MYenable.
  run object-select in this-procedure (
        input rs-1
    ).
  REPOSITION br-template TO RECID v-doc-rec no-error.
  APPLY "VALUE-CHANGED" TO br-template in frame {&frame-name}.
  apply "entry" to br-template.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-start Dialog-Frame
PROCEDURE proc-start :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-start AS INTEGER NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-label AS character NO-UNDO.
DEFINE VARIABLE v-value AS INTEGER NO-UNDO.
DO ii = 1 TO NUM-ENTRIES({&step-values}):
    ASSIGN
    v-label = trim(ENTRY(ii, {&step-labels}))
    v-value = integer(ENTRY(ii, {&step-values}))
    .
   rs-end:enable(v-label) IN FRAME {&FRAME-NAME}.
END.
DO ii = 1 TO NUM-ENTRIES({&step-values}):
    ASSIGN
    v-label = trim(ENTRY(ii, {&step-labels}))
    v-value = integer(ENTRY(ii, {&step-values}))
    .
    IF v-value < p-start  THEN DO:
       rs-end:disable(v-label) IN FRAME {&FRAME-NAME}.
    END.
END.
IF p-start = 0 THEN dO:
    ENABLE
    br-template
    btn-add
    btn-del
    btn-update-main
    btn-update
    WITH FRAME {&FRAME-NAME}.
    RUN proc-b-template IN THIS-PROCEDURE NO-ERROR.
END.
ELSE DO:
   if p-start > 100 then do:
    disable
    t-finalize-100
    with frame {&frame-name} .
   end.
   else do:
    enable
    t-finalize-100
    with frame {&frame-name} .
   end.
   if p-start > 200 then do:
    disable
    t-finalize-200
    with frame {&frame-name} .
   end.
   else do:
    enable
    t-finalize-200
    with frame {&frame-name} .
   end.
   disable
   br-template
   btn-add
   btn-del
   btn-update-main
   btn-update
WITH FRAME {&FRAME-NAME}.


END.
APPLY "VALUE-CHANGED" to rs-end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-changed Dialog-Frame
PROCEDURE proc-value-changed :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE v-str as character no-undo.
DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
Kl = integer(entry(2, temp-schedule-attr.attr-code, {&delim-par})).
assign
  f-shift-date :screen-value IN FRAME {&FRAME-NAME} = ""
  f-shift-num :screen-value IN FRAME {&FRAME-NAME} = ""
  f-shift-name :screen-value IN FRAME {&FRAME-NAME} = ""
  ED-FILTER:screen-value = "".
assign
ED-FILTER.
ASSIGN
f-shift-date = ENTRY(1, (entry(2, temp-schedule-attr.attr-value, {&delim-par})))
f-shift-num = ENTRY(2, (entry(2, temp-schedule-attr.attr-value, {&delim-par}))).
if num-entries(entry(2, temp-schedule-attr.attr-value, {&delim-par})) > 2 then do:
  f-shift-name = ENTRY(3, (entry(2, temp-schedule-attr.attr-value, {&delim-par}))).
end.
FIND FIRST buf_temp-schedule-attr NO-LOCK WHERE
        buf_temp-schedule-attr.cre-db-num = p-cre-db-num
  AND   buf_temp-schedule-attr.task-type = p-task-type
  AND   buf_temp-schedule-attr.task-num = p-task-num
  AND   buf_temp-schedule-attr.attr-code = ({&attr-schedule-filter-h} + {&delim-par} + STRING(kl)) NO-ERROR.
IF AVAILABLE buf_temp-schedule-attr THEN DO:
  ASSIGN
  v-str = entry(2, buf_temp-schedule-attr.attr-value, {&delim-par}).
  DO ii = 1 TO NUM-ENTRIES(v-str):
      MethodReturn = ED-FILTER:insert-string(entry(ii, v-str) + {&new-line}).
      assign ED-FILTER.
  END.
END.
IDENT = RECID(temp-schedule-attr).
DISPLAY
f-shift-date
f-shift-num
f-shift-name
ED-FILTER
WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-table Dialog-Frame
PROCEDURE save-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-deleted AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_temp-schedule-attr FOR temp-schedule-attr.
DEFINE BUFFER buf_schedule-attr FOR ub.schedule-attr.
do ON ERROR UNDO, RETURN ERROR RETURN-VALUE:
FOR EACH buf_temp-schedule-attr :

    RUN  schedule-attr-write  IN THIS-PROCEDURE(
                                                     input buf_temp-schedule-attr.cre-db-num
                                                    ,input buf_temp-schedule-attr.task-type
                                                    ,input buf_temp-schedule-attr.task-num
                                                    ,input buf_temp-schedule-attr.attr-code
                                                    ,input buf_temp-schedule-attr.attr-value).

END.
FOR EACH buf_schedule-attr NO-LOCK where
        buf_schedule-attr.task-type = p-task-type
    and buf_schedule-attr.cre-db-num = p-cre-db-num
    and buf_schedule-attr.task-num = p-task-num:

  IF buf_schedule-attr.attr-code BEGINS ({&attr-schedule-date-list-h} + {&delim-par})
  or buf_schedule-attr.attr-code BEGINS ({&attr-schedule-filter-h}  + {&delim-par}) THEN DO:
    FIND FIRST buf_temp-schedule-attr NO-LOCK WHERE
              buf_temp-schedule-attr.cre-db-num = buf_schedule-attr.cre-db-num
        and   buf_temp-schedule-attr.task-type = buf_schedule-attr.task-type
        and   buf_temp-schedule-attr.task-num = buf_schedule-attr.task-num
         and   buf_temp-schedule-attr.attr-code = buf_schedule-attr.ATTR-code NO-ERROR.
    IF NOT AVAILABLE buf_temp-schedule-attr  THEN DO:
        RUN  schedule-attr-delete  IN THIS-PROCEDURE(
                                                         input buf_schedule-attr.cre-db-num
                                                        ,input buf_schedule-attr.task-type
                                                        ,input buf_schedule-attr.task-num
                                                        ,input buf_schedule-attr.attr-code
                                                        ,output v-deleted).
       IF NOT v-deleted THEN UNDO, RETURN ERROR.
    END.
  end.
END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-objects-only-this-db Dialog-Frame
PROCEDURE select-objects-only-this-db :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-only-this-db-obj-list as character    no-undo.
define output parameter p-exclude-obj-list      as character    no-undo.

  define variable v-db-num                as integer       no-undo.
  define variable v-obj-type              as character     no-undo.
  define variable v-obj-code              as integer       no-undo.

  define buffer buf_clients       for ub.clients.
  define buffer buf_temp_obj-list for temp_obj-list.
  define buffer buf_schedule for ub.schedule.

  assign
      p-only-this-db-obj-list = ""
      p-exclude-obj-list      = ""
  .
  if p-task-num > 0 then do:
    find first buf_schedule no-lock where
              buf_schedule.cre-db-num = p-cre-db-num
          and buf_schedule.task-type = p-task-type
          and buf_schedule.task-num = p-task-num no-error.
    if not available buf_schedule then do:
       undo, return error .
    end.
    assign
    v-db-num = ( if buf_schedule.db-num-char = "*" then -10 else integer( buf_schedule.db-num-char ) )
    .
  end.
  else do:
    v-db-num = v-cntxt-db-num.
  end.
    for each buf_temp_obj-list:
        find first buf_clients no-lock
                where buf_clients.obj-type = buf_temp_obj-list.obj-type
                and buf_clients.obj-code = buf_temp_obj-list.obj-code
        .
        if v-db-num = -10
        or buf_clients.db-num = v-db-num
        then do:
            assign
                p-only-this-db-obj-list = p-only-this-db-obj-list
                                        + ( if p-only-this-db-obj-list <> "" then ", " else "" )
                                        + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
            .
        end.
        else do:
            assign
                p-exclude-obj-list = p-exclude-obj-list
                                        + ( if p-exclude-obj-list <> "" then ", " else "" )
                                        + buf_temp_obj-list.obj-type + string( buf_temp_obj-list.obj-code )
            .
            delete buf_temp_obj-list.
        end.
    end.
end.
END PROCEDURE. /* select-objects-only-this-db */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-schedule-attr-delete Dialog-Frame
PROCEDURE temp-schedule-attr-delete :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-cre-db-num    as integer    no-undo .      /* PI строки расписания */
define input parameter p-task-type     as character  no-undo.
define input parameter p-task-num      as integer    no-undo.
define input parameter p-code          as character  no-undo.      /* код атрибута */
define output parameter p-deleted      as logical    no-undo.

    define buffer buf_temp-schedule-attr for temp-schedule-attr .

    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.

    run schedule-attr-name in this-procedure (
          input p-code            /* p-code           */
        , output v-type           /* p-type           */
        , output v-format         /* p-format         */
        , output v-label          /* p-label          */
        , output v-user-can-edit  /* p-user-can-edit  */
        , output v-output-display /* p-output-display */
        , output v-other          /* p-other          */
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_temp-schedule-attr exclusive-lock
         where buf_temp-schedule-attr.cre-db-num = p-cre-db-num
           and buf_temp-schedule-attr.task-type  = p-task-type
           and buf_temp-schedule-attr.task-num   = p-task-num
           and buf_temp-schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_temp-schedule-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
        delete buf_temp-schedule-attr.
        assign
            p-deleted = yes
        .
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE temp-schedule-attr-write Dialog-Frame
PROCEDURE temp-schedule-attr-write :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-cre-db-num as integer   no-undo .      /* PI строки расписания */
define input parameter p-task-type  as character no-undo.
define input parameter p-task-num   as integer   no-undo.
define input parameter p-code       as character no-undo.      /* код атрибута */
define input parameter p-value      as character no-undo.      /* значение атрибута */

    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.

    define buffer buf_temp-schedule-attr for temp-schedule-attr .

    run schedule-attr-name in this-procedure (
          input  p-code           /* p-code           */
        , output v-type           /* v-type           */
        , output v-format         /* v-format         */
        , output v-label          /* v-label          */
        , output v-user-can-edit  /* v-user-can-edit  */
        , output v-output-display /* v-output-display */
        , output v-other          /* v-other          */
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_temp-schedule-attr exclusive-lock
         where buf_temp-schedule-attr.cre-db-num = p-cre-db-num
           and buf_temp-schedule-attr.task-type  = p-task-type
           and buf_temp-schedule-attr.task-num   = p-task-num
           and buf_temp-schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_temp-schedule-attr
    then do:
        create buf_temp-schedule-attr.
        assign
                buf_temp-schedule-attr.cre-db-num = p-cre-db-num
                buf_temp-schedule-attr.task-type  = p-task-type
                buf_temp-schedule-attr.task-num   = p-task-num
                buf_temp-schedule-attr.attr-code  = p-code
                buf_temp-schedule-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_temp-schedule-attr.attr-value = p-value
        .
    end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION octal-to-char Dialog-Frame
FUNCTION octal-to-char RETURNS CHARACTER
( p-string as character ) :

  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .

  if length(p-string) <> 3 then do:
    return ? .
  end.

  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.

  return chr(v-asc) .
end function .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME