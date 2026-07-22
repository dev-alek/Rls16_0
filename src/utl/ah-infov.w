&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отображение информации о состоянии складских архивов

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор: Перваков Михаил Сергеевич
Дата создания: 11/16/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отображение информации о состоянии складских архивов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ utl/ah-info.i  }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }
{ gbl/color.i    }
{ cmp/showinf.i  }

define variable v-object       as character no-undo format "x(9)"  label "Объект" .
define variable v-archive-type as character no-undo format "x(21)" label "Архив"  .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define variable v-filter-db as logical   no-undo .
define variable v-all-db    as character no-undo initial "Все" .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-obj-arh

/* Definitions for BROWSE BR-obj                                        */
&Scoped-define FIELDS-IN-QUERY-BR-obj temp-obj-arh.db-num (temp-obj-arh.obj-type + ' ' + string(temp-obj-arh.obj-code)) @ v-object temp-obj-arh.obj-deleted archive-type-name(temp-obj-arh.archive-type) @ v-archive-type temp-obj-arh.archive-detail-date temp-obj-arh.archive-start-date temp-obj-arh.archive-recalc-date temp-obj-arh.archive-calc temp-obj-arh.archive-del temp-obj-arh.archive-disable temp-obj-arh.archive-rest temp-obj-arh.archive-bpexist temp-obj-arh.archive-execuser temp-obj-arh.archive-execsysdate temp-obj-arh.archive-execsystime
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-obj
&Scoped-define SELF-NAME BR-obj
&Scoped-define QUERY-STRING-BR-obj FOR EACH temp-obj-arh NO-LOCK
&Scoped-define OPEN-QUERY-BR-obj OPEN QUERY {&SELF-NAME} FOR EACH temp-obj-arh NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-obj temp-obj-arh
&Scoped-define FIRST-TABLE-IN-QUERY-BR-obj temp-obj-arh


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-hist b-refresh b-print b-excel ~
b-calc b-calc-all B-Help RECT-1 RECT-2 RECT-3 rs-archive-type ~
rs-bad-archive rs-process rs-batch-process rs-deleted cb-db fi-search ~
BR-obj fi-date-time fi-description-1 fi-description-2 fi-description-3 ~
fi-description-4 fi-description-5 fi-description-6 fi-search-description ~
fi-obj-name fi-label-1 fi-label-2 fi-label-3 fi-description ~
fi-calc-execuser fi-rest-execuser fi-detail-date fi-start-date
&Scoped-Define DISPLAYED-OBJECTS rs-archive-type rs-bad-archive rs-process ~
rs-batch-process rs-deleted cb-db fi-search fi-date-time fi-description-1 ~
fi-description-2 fi-description-3 fi-description-4 fi-description-5 ~
fi-description-6 fi-search-description fi-obj-name fi-label-1 fi-label-2 ~
fi-label-3 fi-description fi-calc-execuser fi-rest-execuser fi-detail-date ~
fi-calc-execsysdate fi-rest-execsysdate fi-start-date fi-calc-execsystime ~
fi-rest-execsystime

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD archive-type-name Dialog-Frame
FUNCTION archive-type-name RETURNS CHARACTER
  ( input p-archive-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD history-description Dialog-Frame
FUNCTION history-description RETURNS CHARACTER
  ( input p-history-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc
     LABEL "Рассчитать"
     SIZE 12 BY 1.

DEFINE BUTTON b-calc-all
     LABEL "Рассчитать Все"
     SIZE 16 BY 1.

DEFINE BUTTON b-excel
     LABEL "E&xcel"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "&История"
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-refresh
     LABEL "Об&новить"
     SIZE 10 BY 1.

DEFINE VARIABLE cb-db AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE fi-calc-execsysdate AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Дата начала проходящего сейчас расчёта архива"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-calc-execsystime AS CHARACTER FORMAT "X(5)":U
     LABEL "Время"
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Время начала проходящего сейчас расчёта архива"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-calc-execuser AS CHARACTER FORMAT "X(8)":U
     LABEL "Польз."
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Пользователь, рассчитывающий архив в данный момент"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-date-time AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 81.88 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(40)":U
      VIEW-AS TEXT
     SIZE 46.38 BY .67
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE fi-description-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип архива:"
      VIEW-AS TEXT
     SIZE 19.13 BY .67 NO-UNDO.

DEFINE VARIABLE fi-description-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус архива:"
      VIEW-AS TEXT
     SIZE 18.75 BY .67 NO-UNDO.

DEFINE VARIABLE fi-description-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Текущее состояние:"
      VIEW-AS TEXT
     SIZE 18.75 BY .67 NO-UNDO.

DEFINE VARIABLE fi-description-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Задания на расчёт:"
      VIEW-AS TEXT
     SIZE 18.75 BY .67 NO-UNDO.

DEFINE VARIABLE fi-description-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус объекта:"
      VIEW-AS TEXT
     SIZE 15.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-description-6 AS CHARACTER FORMAT "X(256)":U INITIAL "БД:"
      VIEW-AS TEXT
     SIZE 15.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-detail-date AS DATE FORMAT "99/99/9999":U
     LABEL "Начало подробного"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-label-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус архива"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-label-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Расчёт"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-label-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Удал./Вост."
      VIEW-AS TEXT
     SIZE 15 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE fi-obj-name AS CHARACTER FORMAT "X(80)":U
      VIEW-AS TEXT
     SIZE 74.75 BY .67 TOOLTIP "Полное название объекта"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-rest-execsysdate AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Дата начала проходящего сейчас расчёта архива"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-rest-execsystime AS CHARACTER FORMAT "X(5)":U
     LABEL "Время"
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Время начала проходящего сейчас расчёта архива"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-rest-execuser AS CHARACTER FORMAT "X(8)":U
     LABEL "Польз."
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Пользователь, рассчитывающий архив в данный момент"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-search AS DECIMAL FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-search-description AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по номеру объекта:"
      VIEW-AS TEXT
     SIZE 25.13 BY .67 NO-UNDO.

DEFINE VARIABLE fi-start-date AS DATE FORMAT "99/99/9999":U
     LABEL "Начало сжатого"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-archive-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Все", 1,
"По &товарам", 2,
"По &поставщикам", 3,
"По типам приоб&ретения", 4
     SIZE 61.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-bad-archive AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Все", 1,
"Не рассчитанные", 2,
"Рассчитанные", 3,
"Отключенные", 4
     SIZE 78 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-batch-process AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Все", 1,
"С заданиями", 2,
"Без заданий", 3
     SIZE 59 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-deleted AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Текущие&+", 1,
"Все&!", 2,
"Удалённые&-", 3
     SIZE 59 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-process AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Все", 1,
"Не рассчитываются", 2,
"Рассчитываются", 3
     SIZE 59 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 49 BY 3.75.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.13 BY 3.75.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.13 BY 3.75.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-obj FOR
      temp-obj-arh SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-obj Dialog-Frame _FREEFORM
  QUERY BR-obj DISPLAY
      temp-obj-arh.db-num format ">>>>9"
      (temp-obj-arh.obj-type + ' ' + string(temp-obj-arh.obj-code)) @ v-object
      temp-obj-arh.obj-deleted
      archive-type-name(temp-obj-arh.archive-type) @ v-archive-type
      temp-obj-arh.archive-detail-date
      temp-obj-arh.archive-start-date
      temp-obj-arh.archive-recalc-date
      temp-obj-arh.archive-calc    format "*/ " column-label "Оборот"
      temp-obj-arh.archive-del     format "*/ " column-label "Остат"
      temp-obj-arh.archive-disable format "*/ " column-label "Запрщ"
      temp-obj-arh.archive-rest    format "*/ " column-label "Восст"
      temp-obj-arh.archive-bpexist format "*/ " column-label "Задания"
      temp-obj-arh.archive-execuser
      temp-obj-arh.archive-execsysdate
      temp-obj-arh.archive-execsystime
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.63 BY 10.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-hist AT ROW 1 COL 11
     b-refresh AT ROW 1 COL 21
     b-print AT ROW 1 COL 31
     b-excel AT ROW 1 COL 41
     b-calc AT ROW 1 COL 51
     b-calc-all AT ROW 1 COL 63
     B-Help AT ROW 1 COL 79
     rs-archive-type AT ROW 2.92 COL 21.13 NO-LABEL
     rs-bad-archive AT ROW 3.71 COL 21.13 NO-LABEL
     rs-process AT ROW 4.5 COL 21.13 NO-LABEL
     rs-batch-process AT ROW 5.33 COL 21.13 NO-LABEL
     rs-deleted AT ROW 6.13 COL 21.13 NO-LABEL
     cb-db AT ROW 6.92 COL 19.13 COLON-ALIGNED NO-LABEL
     fi-search AT ROW 6.92 COL 73.5 COLON-ALIGNED NO-LABEL
     BR-obj AT ROW 8.04 COL 1.25
     fi-date-time AT ROW 2.04 COL 1 NO-LABEL
     fi-description-1 AT ROW 2.92 COL 1 NO-LABEL
     fi-description-2 AT ROW 3.71 COL 1 NO-LABEL
     fi-description-3 AT ROW 4.5 COL 1 NO-LABEL
     fi-description-4 AT ROW 5.33 COL 1 NO-LABEL
     fi-description-5 AT ROW 6.13 COL 1 NO-LABEL
     fi-description-6 AT ROW 7.13 COL 1 NO-LABEL
     fi-search-description AT ROW 7.13 COL 47.75 COLON-ALIGNED NO-LABEL
     fi-obj-name AT ROW 18.85 COL 1 NO-LABEL
     fi-label-1 AT ROW 19.42 COL 7.88 COLON-ALIGNED NO-LABEL
     fi-label-2 AT ROW 19.5 COL 55.5 COLON-ALIGNED NO-LABEL
     fi-label-3 AT ROW 19.5 COL 79 COLON-ALIGNED NO-LABEL
     fi-description AT ROW 20.21 COL 2.63 NO-LABEL
     fi-calc-execuser AT ROW 20.5 COL 59.5 COLON-ALIGNED
     fi-rest-execuser AT ROW 20.5 COL 84.5 COLON-ALIGNED
     fi-detail-date AT ROW 21.25 COL 6.5
     fi-calc-execsysdate AT ROW 21.38 COL 59.5 COLON-ALIGNED
     fi-rest-execsysdate AT ROW 21.38 COL 84.5 COLON-ALIGNED
     fi-start-date AT ROW 22.25 COL 9.5
     fi-calc-execsystime AT ROW 22.46 COL 59.5 COLON-ALIGNED
     fi-rest-execsystime AT ROW 22.46 COL 84.5 COLON-ALIGNED
     RECT-1 AT ROW 19.75 COL 1
     RECT-2 AT ROW 19.75 COL 76.5
     RECT-3 AT ROW 19.75 COL 51
     SPACE(25.75) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Складские архивы на объектах"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-obj fi-search Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BR-obj:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 4.

/* SETTINGS FOR FILL-IN fi-calc-execsysdate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-calc-execsystime IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-date-time IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-3 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-4 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-5 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-6 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-detail-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-obj-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-rest-execsysdate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-rest-execsystime IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-start-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-obj
/* Query rebuild information for BROWSE BR-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-obj-arh NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-obj */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Складские архивы на объектах */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Рассчитать */
DO:
  { gbl/stdbtn.i }

  run calc-archive in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc-all Dialog-Frame
ON CHOOSE OF b-calc-all IN FRAME Dialog-Frame /* Рассчитать Все */
DO:
  { gbl/stdbtn.i }

  define variable v-ok as logical   no-undo .

  if available temp-obj-arh
  then do:

    message
      "Рассчитать архив для всех показанных объектов" skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.

    run calc-all-temp-obj-arh in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        "Ошибка при расчете архива" skip
        "Объект" temp-obj-arh.obj-type temp-obj-arh.obj-code skip
        "Складской архив" archive-type-name(temp-obj-arh.archive-type) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply .
    end.
    else do:
      message
        "Рассчет архивов закончен" skip
        view-as alert-box information .
    end.
  end.

  run openbr in this-procedure
    (input true /* p-refresh-query */
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-excel Dialog-Frame
ON CHOOSE OF b-excel IN FRAME Dialog-Frame /* Excel */
DO:
  { gbl/stdbtn.i }

  run print-all-to-excel in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
  { gbl/stdbtn.i }

  run display-history in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
  { gbl/stdbtn.i }

  run print-temp-obj-arh in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh Dialog-Frame
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  { gbl/stdbtn.i }

  run openbr in this-procedure
    (input true /* p-refresh-query */
    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-obj
&Scoped-define SELF-NAME BR-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-obj Dialog-Frame
ON DEFAULT-ACTION OF BR-obj IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  run display-history in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-obj Dialog-Frame
ON VALUE-CHANGED OF BR-obj IN FRAME Dialog-Frame
DO:
  run proc-display-fields in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-db Dialog-Frame
ON VALUE-CHANGED OF cb-db IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    cb-db
    .

  run openbr in this-procedure
    (input false
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-search
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-search Dialog-Frame
ON RETURN OF fi-search IN FRAME Dialog-Frame
DO:
  define variable v-curr-rowid as rowid     no-undo .

  if available temp-obj-arh
  then do:
    assign
      v-curr-rowid = rowid(temp-obj-arh)
    .

    if fi-search <> input frame {&frame-name} fi-search
    then do:
      assign
        fi-search
        .
      run ah-infov_get-first in this-procedure .

      if available temp-obj-arh
      and temp-obj-arh.obj-code = fi-search
      then do:
        assign
          v-curr-rowid = rowid(temp-obj-arh)
        .
        reposition {&browse-name} to rowid v-curr-rowid no-error .
        if error-status :error
        then do:
          reposition {&browse-name} to row 1 .
        end.
        return no-apply .
      end.
    end.

    define variable v-get-first-count as integer   no-undo .
    assign
      v-get-first-count = 0
    .

    do while true
    :
      run ah-infov_get-next in this-procedure .

      if available temp-obj-arh
      then do:
        if temp-obj-arh.obj-code = fi-search
        then do:
          assign
            v-curr-rowid = rowid(temp-obj-arh)
          .
          reposition {&browse-name} to rowid v-curr-rowid no-error .
          if error-status :error
          then do:
            reposition {&browse-name} to row 1 .
          end.
          return no-apply .
        end.
      end.
      else do:
        if v-get-first-count = 0
        then do:
          run ah-infov_get-first in this-procedure .
          assign
            v-get-first-count = v-get-first-count + 1
          .
        end.
        else do:
          leave .
        end.
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-archive-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-archive-type Dialog-Frame
ON VALUE-CHANGED OF rs-archive-type IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    rs-archive-type
    .

  run openbr in this-procedure
    (input false
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-bad-archive
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-bad-archive Dialog-Frame
ON VALUE-CHANGED OF rs-bad-archive IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    rs-bad-archive
    .

  run openbr in this-procedure
    (input false
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-batch-process
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-batch-process Dialog-Frame
ON VALUE-CHANGED OF rs-batch-process IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    rs-batch-process
    .

  run openbr in this-procedure
    (input false
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-deleted
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-deleted Dialog-Frame
ON VALUE-CHANGED OF rs-deleted IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    rs-deleted
    .

  run openbr in this-procedure
    (input false
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-process
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-process Dialog-Frame
ON VALUE-CHANGED OF rs-process IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    rs-process
    .

  run openbr in this-procedure
    (input false
    ) .
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

{ gbl/mv-clmn.i
  &ext-col = 26
  &frame-name = "{&frame-name}"
  &browse-name = "br-obj"
  &start-column = "4"
}

{ gbl/brwrepos.i
  &line-num=5
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  define variable v-ok as logical   no-undo .

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_archive_lookup':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
  if v-ok <> true then do:
    undo, return error .
  end.

  RUN enable_UI in this-procedure .

  run setup-initial-values in this-procedure .

  Run OpenBr in this-procedure
    (input true /* p-refresh-query */
    ).

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_archive-type-name-proc Dialog-Frame
PROCEDURE ah-infov_archive-type-name-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-type-name as character no-undo .

  case p-archive-type
  :
    when {&btpr-type-arh}
    then do:
      assign
        p-archive-type-name = "по товарам"
      .
    end.
    when {&btpr-type-ahsp}
    then do:
      assign
        p-archive-type-name = "по поставщикам"
      .
    end.
    when {&btpr-type-aht}
    then do:
      assign
        p-archive-type-name = "по типам приобретения"
      .
    end.
    otherwise do:
      assign
        p-archive-type-name = p-archive-type
      .
    end.
  end case .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_get-current Dialog-Frame
PROCEDURE ah-infov_get-current :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define output parameter p-available                as logical   no-undo .
  define output parameter p-db-num                   as integer   no-undo .
  define output parameter p-obj-type                 as character no-undo .
  define output parameter p-obj-code                 as integer   no-undo .
  define output parameter p-archive-type             as character no-undo .
  define output parameter p-obj-deleted              as logical   no-undo .
  define output parameter p-archive-calc             as logical   no-undo .
  define output parameter p-archive-del              as logical   no-undo .
  define output parameter p-archive-disable          as logical   no-undo .
  define output parameter p-archive-rest             as logical   no-undo .
  define output parameter p-archive-bpexist          as logical   no-undo .
  define output parameter p-archive-detail-date      as date      no-undo .
  define output parameter p-archive-start-date       as date      no-undo .
  define output parameter p-archive-recalc-date      as date      no-undo .
  define output parameter p-archive-lock-prc         as logical   no-undo .
  define output parameter p-archive-execuser         as character no-undo .
  define output parameter p-archive-execsysdate      as date      no-undo .
  define output parameter p-archive-execsystime      as character no-undo .
  define output parameter p-archive-rest-lock-prc    as logical   no-undo .
  define output parameter p-archive-rest-execuser    as character no-undo .
  define output parameter p-archive-rest-execsysdate as date      no-undo .
  define output parameter p-archive-rest-execsystime as character no-undo .

  if available temp-obj-arh
  then do:
    assign
      p-available                = true
      p-db-num                   = temp-obj-arh.db-num
      p-obj-type                 = temp-obj-arh.obj-type
      p-obj-code                 = temp-obj-arh.obj-code
      p-archive-type             = temp-obj-arh.archive-type
      p-archive-calc             = temp-obj-arh.archive-calc
      p-archive-del              = temp-obj-arh.archive-del
      p-archive-disable          = temp-obj-arh.archive-disable
      p-archive-rest             = temp-obj-arh.archive-rest
      p-archive-bpexist          = temp-obj-arh.archive-bpexist
      p-archive-detail-date      = temp-obj-arh.archive-detail-date
      p-archive-start-date       = temp-obj-arh.archive-start-date
      p-archive-recalc-date      = temp-obj-arh.archive-recalc-date
      p-archive-lock-prc         = temp-obj-arh.archive-lock-prc
      p-archive-execuser         = temp-obj-arh.archive-execuser
      p-archive-execsysdate      = temp-obj-arh.archive-execsysdate
      p-archive-execsystime      = temp-obj-arh.archive-execsystime
      p-archive-rest-lock-prc    = temp-obj-arh.archive-rest-lock-prc
      p-archive-rest-execuser    = temp-obj-arh.archive-rest-execuser
      p-archive-rest-execsysdate = temp-obj-arh.archive-rest-execsysdate
      p-archive-rest-execsystime = temp-obj-arh.archive-rest-execsystime
    .
  end.
  else do:
    assign
      p-available = false
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_get-description Dialog-Frame
PROCEDURE ah-infov_get-description :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-archive-description as character no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      assign
        p-archive-description = fi-date-time :screen-value
      .
    end. /* do with frame */
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_get-first Dialog-Frame
PROCEDURE ah-infov_get-first :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  apply "home":u to browse {&browse-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_get-last Dialog-Frame
PROCEDURE ah-infov_get-last :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  apply "end":u to browse {&browse-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_get-next Dialog-Frame
PROCEDURE ah-infov_get-next :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  get next {&browse-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_get-prev Dialog-Frame
PROCEDURE ah-infov_get-prev :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  get prev {&browse-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_history-description Dialog-Frame
PROCEDURE ah-infov_history-description :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-history-type        as character no-undo .
  define output parameter p-history-description as character no-undo .

  do
  on error undo, return error return-value
  :
    case p-history-type
    :
      when {&archive-history-calc-start}
      then do:
        assign
          p-history-description = "расчёт-начало"
        .
      end.
      when {&archive-history-calc-stop}
      then do:
        assign
          p-history-description = "расчёт-окончание"
        .
      end.
      when {&archive-history-set-calc}
      then do:
        assign
          p-history-description = "пометить-нерассчитанные"
        .
      end.
      when {&archive-history-set-del}
      then do:
        assign
          p-history-description = "пометить-удалённые"
        .
      end.
      when {&archive-history-set-disable}
      then do:
        assign
          p-history-description = "пометить-запретить"
        .
      end.
      when {&archive-history-clear-disable}
      then do:
        assign
          p-history-description = "пометить-разрешить"
        .
      end.
      when {&archive-history-set-recalc}
      then do:
        assign
          p-history-description = "пометить-перерассчитать"
        .
      end.
      when {&archive-history-init-start}
      then do:
        assign
          p-history-description = "инициализация-начало"
        .
      end.
      when {&archive-history-init-stop}
      then do:
        assign
          p-history-description = "инициализация-окончание"
        .
      end.
      when {&archive-history-delall-start}
      then do:
        assign
          p-history-description = "удаление-начало"
        .
      end.
      when {&archive-history-delall-stop}
      then do:
        assign
          p-history-description = "удаление-окончание"
        .
      end.
      when {&archive-history-deldet-start}
      then do:
        assign
          p-history-description = "сжатие-начало"
        .
      end.
      when {&archive-history-deldet-stop}
      then do:
        assign
          p-history-description = "сжатие-окончание"
        .
      end.
      when {&archive-history-rstfil-start}
      then do:
        assign
          p-history-description = "восстановление-начало"
        .
      end.
      when {&archive-history-rstfil-stop}
      then do:
        assign
          p-history-description = "восстановление-окончание"
        .
      end.
      when {&archive-history-rstdoc-start}
      then do:
        assign
          p-history-description = "расчет-назад-начало"
        .
      end.
      when {&archive-history-rstdoc-stop}
      then do:
        assign
          p-history-description = "расчет-назад-окончание"
        .
      end.
      when {&archive-history-ren-gds-code}
      then do:
        assign
          p-history-description = "код-товара-переименование"
        .
      end.
      otherwise do:
        assign
          p-history-description = p-history-type
        .
      end.
    end case .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_is-available Dialog-Frame
PROCEDURE ah-infov_is-available :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-temp-obj-arh-available as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-temp-obj-arh-available = available temp-obj-arh
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ah-infov_reposition-to-current Dialog-Frame
PROCEDURE ah-infov_reposition-to-current :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-curr-rowid as rowid     no-undo .

  do
  on error undo, return error return-value
  :
    if available temp-obj-arh
    then do:
      assign
        v-curr-rowid = rowid(temp-obj-arh)
      .
      reposition {&browse-name} to rowid v-curr-rowid no-error .
      if error-status :error
      then do:
        reposition {&browse-name} to row 1 .
      end.
    end.
    else do:
      reposition {&browse-name} to row 1 .
    end.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-all-temp-obj-arh Dialog-Frame
PROCEDURE calc-all-temp-obj-arh :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_temp-obj-arh for temp-obj-arh .

  do
  on error undo, return error return-value
  :
    define variable v-curr-rowid as rowid no-undo .
    assign
      v-curr-rowid = rowid(temp-obj-arh)
    .

    run ah-infov_get-first in this-procedure .

    do while true
    :
      define variable v-available                as logical   no-undo .
      define variable v-db-num                   as integer   no-undo .
      define variable v-obj-type                 as character no-undo .
      define variable v-obj-code                 as integer   no-undo .
      define variable v-archive-type             as character no-undo .
      define variable v-deleted                  as logical   no-undo .
      define variable v-archive-calc             as logical   no-undo .
      define variable v-archive-del              as logical   no-undo .
      define variable v-archive-disable          as logical   no-undo .
      define variable v-archive-rest             as logical   no-undo .
      define variable v-archive-bpexist          as logical   no-undo .
      define variable v-archive-detail-date      as date      no-undo .
      define variable v-archive-start-date       as date      no-undo .
      define variable v-archive-lock-prc         as logical   no-undo .
      define variable v-archive-execuser         as character no-undo .
      define variable v-archive-execsysdate      as date      no-undo .
      define variable v-archive-execsystime      as character no-undo .
      define variable v-archive-rest-lock-prc    as logical   no-undo .
      define variable v-archive-rest-execuser    as character no-undo .
      define variable v-archive-rest-execsysdate as date      no-undo .
      define variable v-archive-rest-execsystime as character no-undo .
      define variable v-archive-date-recalc      as date      no-undo .

      run ah-infov_get-current in this-procedure
        (output v-available                /* p-available                */
        ,output v-db-num                   /* p-db-num                   */
        ,output v-obj-type                 /* p-obj-type                 */
        ,output v-obj-code                 /* p-obj-code                 */
        ,output v-archive-type             /* p-archive-type             */
        ,output v-deleted                  /* p-obj-deleted              */
        ,output v-archive-calc             /* p-archive-calc             */
        ,output v-archive-del              /* p-archive-del              */
        ,output v-archive-disable          /* p-archive-disable          */
        ,output v-archive-rest             /* p-archive-rest             */
        ,output v-archive-bpexist          /* p-archive-bpexist          */
        ,output v-archive-detail-date      /* p-archive-detail-date      */
        ,output v-archive-start-date       /* p-archive-start-date       */
        ,output v-archive-date-recalc      /* p-archive-recalc-date      */
        ,output v-archive-lock-prc         /* p-archive-lock-prc         */
        ,output v-archive-execuser         /* p-archive-execuser         */
        ,output v-archive-execsysdate      /* p-archive-execsysdate      */
        ,output v-archive-execsystime      /* p-archive-execsystime      */
        ,output v-archive-rest-lock-prc    /* p-archive-rest-lock-prc    */
        ,output v-archive-rest-execuser    /* p-archive-rest-execuser    */
        ,output v-archive-rest-execsysdate /* p-archive-rest-execsysdate */
        ,output v-archive-rest-execsystime /* p-archive-rest-execsystime */
        ) .
      if v-available <> true
      then do:
        leave .
      end.

      run calc-temp-obj-arh in this-procedure
        (input  v-obj-type     /* p-obj-type     */
        ,input  v-obj-code     /* p-obj-code     */
        ,input  v-archive-type /* p-archive-type */
        ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.

      run ah-infov_get-next in this-procedure .
    end.

    reposition {&browse-name} to rowid v-curr-rowid no-error .
    if error-status :error
    then do:
      reposition {&browse-name} to row 1 .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-archive Dialog-Frame
PROCEDURE calc-archive :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  if available temp-obj-arh
  then do:
    define variable v-ok as logical   no-undo .
    message
      "Объект" temp-obj-arh.obj-type temp-obj-arh.obj-code skip
      "Рассчитать складской архив" archive-type-name(temp-obj-arh.archive-type) skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return .
    end.

    run calc-temp-obj-arh in this-procedure
      (input  temp-obj-arh.obj-type     /* p-obj-type     */
      ,input  temp-obj-arh.obj-code     /* p-obj-code     */
      ,input  temp-obj-arh.archive-type /* p-archive-type */
      ) no-error .
    if error-status :error
    then do:
      message
        "Объект" temp-obj-arh.obj-type temp-obj-arh.obj-code skip
        "Складской архив" archive-type-name(temp-obj-arh.archive-type) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    else do:
      message
        "Объект" temp-obj-arh.obj-type temp-obj-arh.obj-code skip
        "Рассчет складского архива" archive-type-name(temp-obj-arh.archive-type) "закончен" skip
        view-as alert-box information .
    end.
  end.

  run openbr in this-procedure
    (input true /* p-refresh-query */
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-temp-obj-arh Dialog-Frame
PROCEDURE calc-temp-obj-arh :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define input  parameter p-archive-type as character no-undo .

  do
  on error undo, return error return-value
  :
    case p-archive-type
    :
      when {&btpr-type-arh}
      then do:
        run trg/bt_arh.p
          (input p-obj-type     /* p-obj-type          */
          ,input p-obj-code     /* p-obj-code          */
          ,input ?              /* p-last-date         */
          ,input true           /* p-check-act         */
          ,input v-cntxt-db-num /* p-check-act-db-num  */
          ,input v-cntxt-userid /* p-check-act-user-id */
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
      end.
      when {&btpr-type-ahsp}
      then do:
        run trg/bt_ahsp.p
          (input p-obj-type     /* p-obj-type          */
          ,input p-obj-code     /* p-obj-code          */
          ,input ?              /* p-last-date         */
          ,input true           /* p-check-act         */
          ,input v-cntxt-db-num /* p-check-act-db-num  */
          ,input v-cntxt-userid /* p-check-act-user-id */
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
      end.
      when {&btpr-type-aht}
      then do:
        run trg/bt_aht.p
          (input p-obj-type     /* p-obj-type          */
          ,input p-obj-code     /* p-obj-code          */
          ,input ?              /* p-last-date         */
          ,input true           /* p-check-act         */
          ,input v-cntxt-db-num /* p-check-act-db-num  */
          ,input v-cntxt-userid /* p-check-act-user-id */
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
      end.
    end case .
  end.

END PROCEDURE.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-history Dialog-Frame
PROCEDURE display-history :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-curr-rowid as rowid     no-undo .

  if available temp-obj-arh
  then do:
    run utl/histarhv.w
      (input this-procedure :handle /* p-ah-infov-handle */
      ) .

    if available temp-obj-arh
    then do:
      assign
        v-curr-rowid = rowid(temp-obj-arh)
      .
      reposition {&browse-name} to rowid v-curr-rowid no-error .
      if error-status :error
      then do:
        reposition {&browse-name} to row 1 .
      end.
    end.
    else do:
      reposition {&browse-name} to row 1 .
    end.
  end.

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
  DISPLAY rs-archive-type rs-bad-archive rs-process rs-batch-process rs-deleted
          cb-db fi-search fi-date-time fi-description-1 fi-description-2
          fi-description-3 fi-description-4 fi-description-5 fi-description-6
          fi-search-description fi-obj-name fi-label-1 fi-label-2 fi-label-3
          fi-description fi-calc-execuser fi-rest-execuser fi-detail-date
          fi-calc-execsysdate fi-rest-execsysdate fi-start-date
          fi-calc-execsystime fi-rest-execsystime
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-hist b-refresh b-print b-excel b-calc b-calc-all B-Help
         RECT-1 RECT-2 RECT-3 rs-archive-type rs-bad-archive rs-process
         rs-batch-process rs-deleted cb-db fi-search BR-obj fi-date-time
         fi-description-1 fi-description-2 fi-description-3 fi-description-4
         fi-description-5 fi-description-6 fi-search-description fi-obj-name
         fi-label-1 fi-label-2 fi-label-3 fi-description fi-calc-execuser
         fi-rest-execuser fi-detail-date fi-start-date
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define input  parameter p-refresh-query as logical   no-undo .

  define variable v-cur-obj-type     as character no-undo .
  define variable v-cur-obj-code     as integer   no-undo .
  define variable v-cur-archive-type as character no-undo .

  do
  on error undo, return error return-value
  :
    if available temp-obj-arh
    then do:
      assign
        v-cur-obj-type     = temp-obj-arh.obj-type
        v-cur-obj-code     = temp-obj-arh.obj-code
        v-cur-archive-type = temp-obj-arh.archive-type
      .
    end.

    if p-refresh-query = true
    then do:
      do with frame {&frame-name}:
        assign
          fi-date-time :screen-value = "*** запрос информации ***"
        .
      end. /* do with frame */

      run cur-time in this-procedure
        (output v-today
        ,output v-time
        ).

      run utl/ah-info.p
        (output table temp-obj-arh
        ).
      assign
        frame {&frame-name} :title = "Архивы на объектах: Состояние на " + string( v-today, "99/99/9999" ) + {&space-char} + string( v-time, "HH:MM:SS" ).
      .

      do with frame {&frame-name}:
        assign
          fi-date-time :screen-value = "Состояние на" + {&space-char} + string( v-today, "99/99/9999" ) + {&space-char} + string( v-time, "HH:MM:SS" )
        .
      end. /* do with frame */
    end.

    open query br-obj for each temp-obj-arh no-lock
      where ( rs-archive-type = 1
              or
              ( rs-archive-type = 2
                and
                temp-obj-arh.archive-type = {&btpr-type-arh}
              )
              or
              ( rs-archive-type = 3
                and
                temp-obj-arh.archive-type = {&btpr-type-ahsp}
              )
              or
              ( rs-archive-type = 4
                and
                temp-obj-arh.archive-type = {&btpr-type-aht}
              )
            )
        and ( rs-bad-archive = 1
              or
              ( rs-bad-archive = 2
                and
                ( temp-obj-arh.archive-calc = true
                  or
                  temp-obj-arh.archive-del  = true
                  or
                  temp-obj-arh.archive-rest = true
                )
                and
                temp-obj-arh.archive-disable <> true
              )
              or
              ( rs-bad-archive = 3
                and
                ( temp-obj-arh.archive-calc <> true
                  and
                  temp-obj-arh.archive-del  <> true
                  and
                  temp-obj-arh.archive-rest <> true
                )
              )
              or
              ( rs-bad-archive = 4
                and
                ( temp-obj-arh.archive-calc = true
                  or
                  temp-obj-arh.archive-del  = true
                  or
                  temp-obj-arh.archive-rest = true
                )
                and
                temp-obj-arh.archive-disable = true
              )
            )
        and ( rs-batch-process = 1
              or
              ( rs-batch-process = 2
                and
                ( temp-obj-arh.archive-bpexist = true
                  or
                  temp-obj-arh.archive-recalc-date <> ?
                )
              )
              or
              ( rs-batch-process = 3
                and
                ( temp-obj-arh.archive-bpexist = false
                  and
                  temp-obj-arh.archive-recalc-date = ?
                )
              )
            )
        and ( ( rs-deleted = 1
                and
                temp-obj-arh.obj-deleted <> true
              )
              or
              rs-deleted = 2
              or
              ( rs-deleted = 3
                and
                temp-obj-arh.obj-deleted = true
              )
            )
        and ( rs-process = 1
              or
              ( rs-process = 2
                and
                temp-obj-arh.archive-lock-prc <> true
              )
              or
              ( rs-process = 3
                and
                temp-obj-arh.archive-lock-prc = true
              )
            )
        and ( v-filter-db <> true
              or
              ( v-filter-db = true
                and
                ( cb-db = v-all-db
                  or
                  ( cb-db <> v-all-db
                    and
                    temp-obj-arh.db-num = integer(cb-db)
                  )
                )
              )
            )
      by temp-obj-arh.db-num
      by temp-obj-arh.obj-type
      by temp-obj-arh.obj-code
      by temp-obj-arh.sort-code
      .

    define buffer buf_temp-obj-arh for temp-obj-arh .

    find first buf_temp-obj-arh
      where buf_temp-obj-arh.obj-type     = v-cur-obj-type
        and buf_temp-obj-arh.obj-code     = v-cur-obj-code
        and buf_temp-obj-arh.archive-type = v-cur-archive-type
      no-error .
    if available buf_temp-obj-arh
    then do:
      reposition br-obj to recid recid(buf_temp-obj-arh) no-error .
      if error-status :error
      then do:
        reposition br-obj to row 1 .
      end.
    end.

    run proc-display-fields in this-procedure .

    APPLY "ENTRY" TO BR-obj.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-all-to-excel Dialog-Frame
PROCEDURE print-all-to-excel :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-curr-rowid as rowid no-undo .
  assign
    v-curr-rowid = rowid(temp-obj-arh)
  .

  run utl/ahinfxls.p
    (input this-procedure :handle /* p-ah-infov-handle */
    ) .

  reposition {&browse-name} to rowid v-curr-rowid no-error .
  if error-status :error
  then do:
    reposition {&browse-name} to row 1 .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-temp-obj-arh Dialog-Frame
PROCEDURE print-temp-obj-arh :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-curr-rowid as rowid no-undo .
  assign
    v-curr-rowid = rowid(temp-obj-arh)
  .

  if available temp-obj-arh
  then do:
    run utl/ahinfprn.p
      (input parparentproc
      ,input this-procedure :handle /* p-ah-infov-handle */
      ) .
  end.

  reposition {&browse-name} to rowid v-curr-rowid no-error .
  if error-status :error
  then do:
    reposition {&browse-name} to row 1 .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Proc-display-fields Dialog-Frame
PROCEDURE Proc-display-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define buffer buf_clients for ub.clients .

  if available temp-obj-arh
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = temp-obj-arh.obj-type
        and buf_clients.obj-code = temp-obj-arh.obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        fi-obj-name = substitute("&1 &2  &3  &4"
                     ,temp-obj-arh.obj-type
                     ,temp-obj-arh.obj-code
                     ,buf_clients.obj-name
                     ,archive-type-name(temp-obj-arh.archive-type)
                     )
      .
    end.
    else do:
      assign
        fi-obj-name = substitute("&1 &2  &3  &4"
                     ,temp-obj-arh.obj-type
                     ,temp-obj-arh.obj-code
                     ,""
                     ,archive-type-name(temp-obj-arh.archive-type)
                     )
      .
    end.

    do with frame {&frame-name}:
      assign
        fi-description             = ""
        fi-detail-date      = ?
        fi-start-date       = ?
        fi-calc-execuser         = ""
        fi-calc-execsysdate      = ?
        fi-calc-execsystime      = ""
        fi-rest-execuser    = ""
        fi-rest-execsysdate = ?
        fi-rest-execsystime = ""
      .

      assign
        fi-description   = (if temp-obj-arh.archive-disable = true
                            then "Расчет архива отключен"
                            else (if temp-obj-arh.archive-del = true
                                  then (if temp-obj-arh.archive-lock-prc = true
                                        then "Расчёт начальных остатков"
                                        else "Не рассчитаны начальные остатки"
                                       )
                                  else (if temp-obj-arh.archive-calc = true
                                        then (if temp-obj-arh.archive-lock-prc = true
                                              then "Расчёт оборотов"
                                              else "Не рассчитаны обороты"
                                              )
                                        else (if temp-obj-arh.archive-rest = true
                                              then (if temp-obj-arh.archive-lock-prc = true
                                                    then "Удаление/восстановление"
                                                    else "Сбой удаления восстановления"
                                                    )
                                              else (if temp-obj-arh.archive-recalc-date <> ?
                                                    then (if temp-obj-arh.archive-calc = true
                                                          then substitute("Перерасчет с даты &1"
                                                                         ,string(temp-obj-arh.archive-recalc-date, '99/99/9999':u)
                                                                         )
                                                          else substitute("Требуется перерасчет с даты &1"
                                                                         ,string(temp-obj-arh.archive-recalc-date, '99/99/9999':u)
                                                                         )
                                                         )
                                                    else (if temp-obj-arh.archive-bpexist = true
                                                          then (if temp-obj-arh.archive-calc = true
                                                                then "Обработка заданий на расчет архива"
                                                                else "Имеются задания на расчет архива"
                                                              )
                                                          else ""
                                                         )
                                                   )
                                             )
                                       )
                                 )
                           )
        fi-detail-date   = temp-obj-arh.archive-detail-date
        fi-start-date    = temp-obj-arh.archive-start-date
      .

      if temp-obj-arh.archive-lock-prc = true
      then do:
        assign
          fi-calc-execuser    = temp-obj-arh.archive-execuser
          fi-calc-execsysdate = temp-obj-arh.archive-execsysdate
          fi-calc-execsystime = temp-obj-arh.archive-execsystime
        .
      end.
      if temp-obj-arh.archive-rest-lock-prc = true
      then do:
        assign
          fi-rest-execuser    = temp-obj-arh.archive-rest-execuser
          fi-rest-execsysdate = temp-obj-arh.archive-rest-execsysdate
          fi-rest-execsystime = temp-obj-arh.archive-rest-execsystime
        .
      end.
    end. /* do with frame */

    display
      fi-obj-name
      fi-description
      fi-detail-date
      fi-start-date
      fi-calc-execuser
      fi-calc-execsysdate
      fi-calc-execsystime
      fi-rest-execuser
      fi-rest-execsysdate
      fi-rest-execsystime
      with frame {&frame-name}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-initial-values Dialog-Frame
PROCEDURE setup-initial-values :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db       for ub.db .

  do with frame {&frame-name}:
    assign
      rs-archive-type  = 1
      rs-bad-archive   = 1
      rs-batch-process = 1
      rs-deleted       = 1
      rs-process       = 1
    .

    display
      rs-archive-type
      rs-bad-archive
      rs-batch-process
      rs-deleted
      rs-process
      with frame {&frame-name} .

    find buf_sys-ctrl .
    if buf_sys-ctrl.db-num = 0
    then do:
      assign
        v-filter-db = true
      .
    end.
    else do:
      assign
        v-filter-db = false
      .
    end.

    if v-filter-db = true
    then do:
      define variable v-db-list as character no-undo .

      assign
        v-db-list = v-all-db
      .

      for each buf_db no-lock
        by buf_db.db-num
      on error undo, return error return-value
      :
        assign
          v-db-list = v-db-list
                    + (if v-db-list <> '':u then ',':u else '':u)
                    + string(buf_db.db-num)
        .
      end.

      assign
        cb-db :list-items = v-db-list
      .

      assign
        cb-db = v-all-db
      .

      display
        cb-db
        with frame {&frame-name} .
      enable
        cb-db
        with frame {&frame-name} .
    end.
    else do:
      disable
        cb-db
        with frame {&frame-name} .
    end.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION archive-type-name Dialog-Frame
FUNCTION archive-type-name RETURNS CHARACTER
  ( input p-archive-type as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-archive-type-name as character no-undo .

  run ah-infov_archive-type-name-proc in this-procedure
    (input  p-archive-type
    ,output v-archive-type-name
    ) .
  return v-archive-type-name .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION history-description Dialog-Frame
FUNCTION history-description RETURNS CHARACTER
  ( input p-history-type as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  define variable v-history-description as character no-undo .

  run ah-infov_history-description in this-procedure
    (input  p-history-type
    ,output v-history-description
    ) .

  return v-history-description .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME