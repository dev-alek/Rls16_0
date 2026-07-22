&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Редактирование сроков годности партий товара

Автор: Чернова Светлана Александровна
Дата создания: 03/21/08
Author: Svetlana Chernova
Creation date: 03/21/08


После открытия в UIB необходимо заменить определение
DEFINE QUERY BROWSE-1 FOR
      temp-last-date SCROLLING.

на

DEFINE NEW SHARED BUFFER query_temp-last-date FOR temp-last-date .
DEFINE NEW SHARED  QUERY BROWSE-1 FOR
      query_temp-last-date SCROLLING.


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-select    as character no-undo .
define input  parameter p-last-date as date      no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование сроков годности партий товара".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i  }
{ gbl/temphost.i }
{ trg/partslib.i }
{ gbl/waitfram.i }
{ gbl/sel-date.i }
{ gbl/cur-time.i }
{ gbl/color.i    }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }

define temp-table temp-sel-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .


&scop define-temp-last-date define ~{&new~} shared temp-table temp-last-date no-undo ~
  field gds-code      like ub.goods.gds-code ~
  field artic         like ub.goods.artic ~
  field prod-type     like ub.goods.prod-type ~
  field prod-code     like ub.goods.prod-code ~
  field part-code     like ub.parts.part-code ~
  field obj-type      as character ~
  field obj-code      as integer ~
  field gds-name      like ub.goods.gds-name ~
  field fact-qnty     like ub.parts.fact-qnty ~
  field fact-date     as date label "Дата ПН" format "99/99/9999":u ~
  field in-code       like ub.trn-doc.doc-code label "Номер ПН" column-label "Номер ПН" ~
  field last-date     as date column-label " Годен до !  старый  " format "99/99/9999":u ~
  field new-last-date as date column-label " Годен до !  новый   "  format "99/99/9999":u ~
  field obj-full      as character label "Объект"        format "x(9)":u ~
  field prod-full     as character label "Производитель" format "x(13)":u ~
  field price-base    like ub.parts.price-base ~
  field price-rubl    like ub.parts.price-rubl ~
  field supp-type     like ub.parts.supp-type ~
  field supp-code     like ub.parts.supp-code ~
  field supp-full     as character label "Поставщик" format "x(13)":u ~
  field is-supp       like ub.parts.is-supp column-label "П" format "+/-" ~
  field cst-code      like ub.parts.cst-code format "x(31)":u ~
  index xpk is primary unique gds-code in-code part-code obj-type obj-code ~
  .

&scop new new
{&define-temp-last-date}

define variable filter-point as character no-undo init "d-parlas" .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-last-date

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 query_temp-last-date.gds-code query_temp-last-date.artic query_temp-last-date.gds-name query_temp-last-date.fact-qnty query_temp-last-date.fact-date query_temp-last-date.in-code query_temp-last-date.last-date query_temp-last-date.new-last-date query_temp-last-date.obj-full query_temp-last-date.part-code query_temp-last-date.prod-full query_temp-last-date.price-base query_temp-last-date.price-rubl query_temp-last-date.supp-full query_temp-last-date.is-supp query_temp-last-date.cst-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1 query_temp-last-date.new-last-date
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1~
 ~{&FP1}new-last-date ~{&FP2}new-last-date ~{&FP3}
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-1 query_temp-last-date
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-1 query_temp-last-date
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 /* OPEN QUERY {&SELF-NAME} FOR EACH temp-last-date . */ run my-open-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp-last-date
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp-last-date


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-flt b-exit b-quit b-restore ~
b-clear-last-date b-set-last-date b-set-from-old b-set-from-income b-sch ~
b-help RS-filter BROWSE-1 FILL-IN-4
&Scoped-Define DISPLAYED-OBJECTS RS-filter FILL-IN-4

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-clear-last-date
     LABEL "О&чистить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 12 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit
     LABEL "&Отмена"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-restore
     LABEL "Восс&тановить"
     SIZE 14 BY 1.

DEFINE BUTTON b-set-from-income
     LABEL "От при&хода"
     SIZE 12 BY 1.

DEFINE BUTTON b-set-from-old
     LABEL "От ста&рого"
     SIZE 12 BY 1.

DEFINE BUTTON b-set-last-date
     LABEL "&Годен до"
     SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Фильтр:"
      VIEW-AS TEXT
     SIZE 7.75 BY .67 NO-UNDO.

DEFINE VARIABLE RS-filter AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Отредактированные", 2,
"Неизменённые", 3
     SIZE 46.25 BY .92
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE rect-flt
     EDGE-PIXELS 0
     SIZE 0.1 BY 0.1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED BUFFER query_temp-last-date FOR temp-last-date .
DEFINE NEW SHARED  QUERY BROWSE-1 FOR
      query_temp-last-date SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      query_temp-last-date.gds-code
      query_temp-last-date.artic
      query_temp-last-date.gds-name
      query_temp-last-date.fact-qnty
      query_temp-last-date.fact-date
      query_temp-last-date.in-code
      query_temp-last-date.last-date
      query_temp-last-date.new-last-date
      query_temp-last-date.obj-full
      query_temp-last-date.part-code
      query_temp-last-date.prod-full
      query_temp-last-date.price-base
      query_temp-last-date.price-rubl
      query_temp-last-date.supp-full
      query_temp-last-date.is-supp
      query_temp-last-date.cst-code
enable
      query_temp-last-date.new-last-date
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.63 BY 20.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 9
     b-restore AT ROW 1 COL 17
     b-clear-last-date AT ROW 1 COL 31
     b-set-last-date AT ROW 1 COL 41
     b-set-from-old AT ROW 1 COL 51
     b-set-from-income AT ROW 1 COL 63
     b-sch AT ROW 1 COL 75
     b-help AT ROW 1 COL 89.5
     RS-filter AT ROW 2.46 COL 13 NO-LABEL
     BROWSE-1 AT ROW 3.75 COL 1
     FILL-IN-4 AT ROW 2.54 COL 1.25 COLON-ALIGNED NO-LABEL
     rect-flt AT ROW 1.04 COL 75.13
     SPACE(12.62) SKIP(21.42)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Редактирование сроков годности партий товара"
         CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB BROWSE-1 RS-filter Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH temp-last-date . */
run my-open-query in this-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Редактирование сроков годности партий товара */
DO:
  { gbl/stdbtn.i b-exit }

  define buffer buf_temp-last-date for temp-last-date .

  find first buf_temp-last-date
    where buf_temp-last-date.new-last-date <> buf_temp-last-date.last-date
    no-error .
  if available buf_temp-last-date
  then do:
    run save-data in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при сохранении данных" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Редактирование сроков годности партий товара */
DO:
  { gbl/stdbtn.i b-quit }

  define buffer buf_temp-last-date for temp-last-date .

  define variable v-ok as logical   no-undo .

  find first buf_temp-last-date
    where buf_temp-last-date.new-last-date <> buf_temp-last-date.last-date
    no-error .
  if available buf_temp-last-date
  then do:
    assign
      v-ok = true
    .

    message
      "Срок годности был изменён для некоторых партий." skip
      "Сохранить данные?"
      view-as alert-box question buttons yes-no-cancel update v-ok .

    if v-ok = true
    then do:
      run save-data in this-procedure
        no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при сохранении данных" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
    end.

    if v-ok = ?
    then do:
      return no-apply .
    end.
  end.


  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clear-last-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clear-last-date Dialog-Frame
ON CHOOSE OF b-clear-last-date IN FRAME Dialog-Frame /* Очистить */
DO:
  { gbl/stdbtn.i }

  define variable v-last-date as date      no-undo .
  define variable v-ok        as logical   no-undo .

  define buffer buf_temp-last-date for temp-last-date .

  find first buf_temp-last-date
    no-error .
  if available buf_temp-last-date
  then do:
    message
      "Очистить 'Годен до'." skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok = true
    then do:
      run last-date-set-date in this-procedure
        (input  ? /* p-last-date */
        ) .
    end.
  end.
  else do:
    message
      "Не выбрано ни одной партии" skip
      view-as alert-box information .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  { gbl/stdbtn.i }



  run init-flt in this-procedure .
  run gbl/filter.w
    (input  parparentproc /* parparentproc */
    ,input  filter-point  /* c-point       */
    ,input  tbl           /* tbl           */
    ,input  join-tbl      /* buf           */
    ,input  fld           /* fld           */
    ,input  lab           /* lab           */
    ,input  spr           /* spr           */
    ,input  dim           /* dim           */
    ).
  run my-open-query .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }

  apply 'window-close':u to frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-restore
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-restore Dialog-Frame
ON CHOOSE OF b-restore IN FRAME Dialog-Frame /* Восстановить */
DO:
  { gbl/stdbtn.i }

  define variable v-ok as logical   no-undo .

  define buffer buf_temp-last-date for temp-last-date .

  find first buf_temp-last-date
    where buf_temp-last-date.new-last-date <> buf_temp-last-date.last-date
    no-error .
  if available buf_temp-last-date
  then do:
    message
      "Восстановить первоначальное значение сроков годности." skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .

    if v-ok = true
    then do:
      run last-date-restore in this-procedure .
    end.
  end.
  else do:
    message
      "Отсутствуют партии с отредактированным значением срока годности" skip
      view-as alert-box information .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-set-from-income
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-set-from-income Dialog-Frame
ON CHOOSE OF b-set-from-income IN FRAME Dialog-Frame /* От прихода */
DO:
  { gbl/stdbtn.i }

  define variable v-date-offset      as integer   no-undo .
  define variable v-date-offset-char as character no-undo .

  define buffer buf_temp-last-date for temp-last-date .

  find first buf_temp-last-date
    no-error .
  if available buf_temp-last-date
  then do:
    run gbl/d-prompt.w
      (input 'title=':u + "Задание срока годности от прихода" + '\':u
      + 'text1=':u + "На сколько дней 'Годен до'" + '\':u
      + 'text2=':u + "отличается от даты прихода" + '\':u
      + 'format=->>>,>>>,>>9\'
      + 'type=int\'
      ,input-output v-date-offset-char
      ).
    if return-value = "false":u then do:
      return . /* --->>>--- */
    end.

    assign
      v-date-offset = integer(v-date-offset-char)
    .

    define variable v-ok as logical   no-undo .
    message
      "Задать срок годности от даты прихода." skip
      "Пример:" skip
      "  для партии с датой прихода" string(buf_temp-last-date.fact-date, '99/99/9999':u) skip
      "  будет установлена дата 'Годен до'" string(buf_temp-last-date.fact-date + v-date-offset, '99/99/9999':u) skip
      "" skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .

    if v-ok = true
    then do:
      run last-date-set-from-income in this-procedure
        (input  v-date-offset /* p-date-offset */
        ) .
    end.
  end.
  else do:
    message
      "Не выбрано ни одной партии" skip
      view-as alert-box information .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-set-from-old
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-set-from-old Dialog-Frame
ON CHOOSE OF b-set-from-old IN FRAME Dialog-Frame /* От старого */
DO:
  { gbl/stdbtn.i }

  define variable v-date-offset      as integer   no-undo .
  define variable v-date-offset-char as character no-undo .

  define buffer buf_temp-last-date for temp-last-date .

  find first buf_temp-last-date
    where buf_temp-last-date.last-date <> ?
    no-error .
  if available buf_temp-last-date
  then do:
    run gbl/d-prompt.w
      (input 'title=':u + "Задание срока годности от старого" + '\':u
      + 'text1=':u + "На сколько дней изменить срок годности" + '\':u
      + 'format=->>>,>>>,>>9\'
      + 'type=int\'
      ,input-output v-date-offset-char
      ).
    if return-value = "false":u then do:
      return . /* --->>>--- */
    end.

    assign
      v-date-offset = integer(v-date-offset-char)
    .

    define variable v-ok as logical   no-undo .
    message
      "Задать новый 'Годен до' от старого" skip
      "Пример:" skip
      "  для партии с датой прихода" string(buf_temp-last-date.last-date, '99/99/9999':u) skip
      "  будет установлена дата 'Годен до'" string(buf_temp-last-date.last-date + v-date-offset, '99/99/9999':u) skip
      "" skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .

    run last-date-set-from-old in this-procedure
      (input  v-date-offset /* p-date-offset */
      ) .
  end.
  else do:
    message
      "Отсутствуют партии с заданным сроком годности" skip
      view-as alert-box information .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-set-last-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-set-last-date Dialog-Frame
ON CHOOSE OF b-set-last-date IN FRAME Dialog-Frame /* Годен до */
DO:
  { gbl/stdbtn.i }

  define variable v-last-date as date      no-undo .
  define variable v-ok        as logical   no-undo .

  define buffer buf_temp-last-date for temp-last-date .

  find first buf_temp-last-date
    no-error .
  if available buf_temp-last-date
  then do:
    run gbl/d-inpday.w
      (
       input ?                                 /* h-callback    */
      ,input "Выбор даты"                      /* p-title       */
      ,input "Годен до &1 (для партии товара)" /* p-description */
      ,input ""                                /* p-mode        */
      ,input-output v-last-date                /* p-date        */
      ,output v-ok                             /* p-ok          */
      ).
    if v-ok = true
    then do:
      run last-date-set-date in this-procedure
        (input  v-last-date /* p-last-date */
        ) .
    end.
  end.
  else do:
    message
      "Не выбрано ни одной партии" skip
      view-as alert-box information .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  if available query_temp-last-date
  then do:
    run sel-date in this-procedure
      (input query_temp-last-date.new-last-date :handle in browse {&browse-name}
      ,input "Годен до &1 (для партии товара)"
      ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  if available query_temp-last-date
  then do:
    if query_temp-last-date.new-last-date <> query_temp-last-date.last-date
    then do:
      assign
        query_temp-last-date.new-last-date :fgcolor in browse {&browse-name} = BROWN_COLOR
      .
    end.
    else do:
      assign
        query_temp-last-date.new-last-date :fgcolor in browse {&browse-name} = BLACK_COLOR
      .
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON ROW-LEAVE OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  if available query_temp-last-date
  then do:
    assign
      browse {&browse-name} query_temp-last-date.new-last-date
    .

    if query_temp-last-date.new-last-date <> query_temp-last-date.last-date
    then do:
      assign
        query_temp-last-date.new-last-date :fgcolor in browse {&browse-name} = BROWN_COLOR
      .
    end.
    else do:
      assign
        query_temp-last-date.new-last-date :fgcolor in browse {&browse-name} = BLACK_COLOR
      .
    end.

    display
      query_temp-last-date.new-last-date with browse {&browse-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-filter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-filter Dialog-Frame
ON VALUE-CHANGED OF RS-filter IN FRAME Dialog-Frame
DO:
  { gbl/stdbtn.i }

  assign
    rs-filter
    .

  run my-open-query in this-procedure .
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

{ gbl/ed_date.i "query_temp-last-date.new-last-date" "in browse {&browse-name}" "disable_menu" }

assign
  rs-filter = 1
.

{ gbl/getcntxt.i get }
run make-temp-table in this-procedure .

define variable v-record-exist as logical   no-undo .
run check-record-exist in this-procedure
  (output v-record-exist /* p-record-exist */
  ) .
if v-record-exist <> true
then do:
  message
    "Отсутствуют партии с заданными параметрами" skip
    view-as alert-box information .
  return .
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-record-exist Dialog-Frame
PROCEDURE check-record-exist :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-record-exist as logical   no-undo .

  define buffer buf_temp-last-date for temp-last-date .

  do
  on error undo, return error return-value
  :
    find first buf_temp-last-date
      no-error .
    if available buf_temp-last-date
    then do:
      assign
        p-record-exist = true
      .
    end.
    else do:
      assign
        p-record-exist = false
      .
    end.

  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-temp-sel-obj Dialog-Frame
PROCEDURE create-temp-sel-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_temp-sel-obj for temp-sel-obj .

  do
  on error undo, return error return-value
  :
    define variable v-obj-active as logical   no-undo .

    { gbl/objat.i
      p-obj-type
      p-obj-code
      "'active=request'"
      v-obj-active
    }

    if v-obj-active
    then do:
      /* только для активных объектов */
      find first buf_temp-sel-obj
        where buf_temp-sel-obj.obj-type = p-obj-type
          and buf_temp-sel-obj.obj-code = p-obj-code
        no-error .
      if not available buf_temp-sel-obj
      then do:
        create buf_temp-sel-obj .
        assign
          buf_temp-sel-obj.obj-type = p-obj-type
          buf_temp-sel-obj.obj-code = p-obj-code
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  DISPLAY RS-filter FILL-IN-4
      WITH FRAME Dialog-Frame.
  ENABLE rect-flt b-exit b-quit b-restore b-clear-last-date b-set-last-date
         b-set-from-old b-set-from-income b-sch b-help RS-filter BROWSE-1
         FILL-IN-4
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-flt Dialog-Frame
PROCEDURE init-flt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  assign
    tbl = "query_temp-last-date"
    join-tbl = ""
  .

  run fltfield-clear in this-procedure(
  output fld, output lab, output spr, output dim)  .

  run fltfield-add in this-procedure('in-code', 'Номер ПН', 'function_character',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('query_temp-last-date.obj-type{&delim-flt}query_temp-last-date.obj-code', 'Объект', 'function_cli_character{&delim-flt}integer_Объект{&delim-flt}Объект',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('query_temp-last-date.supp-type{&delim-flt}query_temp-last-date.supp-code', 'Поставщик', 'function_cli_character{&delim-flt}integer_Поставщик{&delim-flt}Поставщик',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('query_temp-last-date.artic{&delim-flt}query_temp-last-date.prod-type{&delim-flt}query_temp-last-date.prod-code', 'Артикул', 'function_gds_character{&delim-flt}character{&delim-flt}integer_Артикул{&delim-flt}Производитель{&delim-flt}Производитель',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('part-code', 'Код партии', 'function_character',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('fact-qnty', 'Факт.кол.', 'function_decimal',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('fact-date', 'Дата ПН', 'function_date',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('last-date', 'Старый Годен до', 'function_date',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('new-last-date', 'Новый Годен до', 'function_date',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('price-base', 'Цена (вал)', 'function_decimal',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('price-rubl', 'Цена ({&abbr_rub})', 'function_decimal',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('is-supp', 'Поставка', 'function_logical',
  input-output fld, input-output lab, input-output spr, input-output dim)  .
  run fltfield-add in this-procedure('cst-code', 'ГТД', 'function_character',
  input-output fld, input-output lab, input-output spr, input-output dim)  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE last-date-restore Dialog-Frame
PROCEDURE last-date-restore :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    get first {&browse-name} .

    repeat while available query_temp-last-date
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Восстановление первоначального срока годности &1", v-ind)
          ) .
      end.
      assign
        query_temp-last-date.new-last-date = query_temp-last-date.last-date
      .

      get next {&browse-name} .
    end.

    run waitfram-hide in this-procedure .

    run my-open-query in this-procedure .

  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE last-date-set-date Dialog-Frame
PROCEDURE last-date-set-date :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-new-last-date as date      no-undo .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    get first {&browse-name} .

    repeat while available query_temp-last-date
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Задание нового 'Годен до' &1", v-ind)
          ) .
      end.

      assign
        query_temp-last-date.new-last-date = p-new-last-date
      .

      get next {&browse-name} .
    end.

    run waitfram-hide in this-procedure .

    run my-open-query in this-procedure .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE last-date-set-from-income Dialog-Frame
PROCEDURE last-date-set-from-income :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-date-offset as integer   no-undo .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    get first {&browse-name} .

    repeat while available query_temp-last-date
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Задание нового 'Годен до' от старого &1", v-ind)
          ) .
      end.

      assign
        query_temp-last-date.new-last-date = query_temp-last-date.fact-date + p-date-offset
      .

      get next {&browse-name} .
    end.

    run waitfram-hide in this-procedure .

    run my-open-query in this-procedure .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE last-date-set-from-old Dialog-Frame
PROCEDURE last-date-set-from-old :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-date-offset as integer   no-undo .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    get first {&browse-name} .

    repeat while available query_temp-last-date
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Задание нового 'Годен до' от старого &1", v-ind)
          ) .
      end.

      if query_temp-last-date.last-date <> ?
      then do:
        assign
          query_temp-last-date.new-last-date = query_temp-last-date.last-date + p-date-offset
        .
      end.

      get next {&browse-name} .
    end.

    run waitfram-hide in this-procedure .

    run my-open-query in this-procedure .

  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-temp-table Dialog-Frame
PROCEDURE make-temp-table :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

/*  define buffer  for .*/
/*  define buffer  for .*/

  define buffer buf_goods        for ub.goods .

  define buffer buf_temp-obj     for temp-obj .
  define buffer buf_obj-list     for obj-list .
  define buffer buf_g#cli        for g#cli .
  define buffer buf_tmp#grp      for tmp#grp .
  define buffer buf_gds-list     for gds-list .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure
      (input "Поиск партий с заданными параметрами"
      ) .

    case x-SelectObject :
      when {&obj-firm}
      then do:
        /* все объекты по фирме */
        run init-temphost in this-procedure .

        define variable v-host-code as integer   no-undo .

        { gbl/hostcode.i
          p-obj-type
          p-obj-code
          v-host-code
        }

        for each buf_temp-obj
          where buf_temp-obj.host-code = v-host-code
        :
          run create-temp-sel-obj in this-procedure
            (input  buf_temp-obj.obj-type /* p-obj-type */
            ,input  buf_temp-obj.obj-code /* p-obj-code */
            ) .
        end.
      end.
      when {&obj-currency}
      then do:
        /* текущий объект */
        run create-temp-sel-obj in this-procedure
          (input  p-obj-type /* p-obj-type */
          ,input  p-obj-code /* p-obj-code */
          ) .
      end.
      when {&obj-choice}
      then do:
        /* объекты по списку */
        for each buf_obj-list
        :
          run create-temp-sel-obj in this-procedure
            (input  buf_obj-list.obj-type /* p-obj-type */
            ,input  buf_obj-list.obj-code /* p-obj-code */
            ) .
        end.
      end.
      when {&all}
      then do:
        define buffer buf_db      for ub.db .
        define buffer buf_clients for ub.clients .

        /* все объекты */
        for each buf_db no-lock
        ,each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
        :
          run create-temp-sel-obj in this-procedure
            (input  buf_clients.obj-type /* p-obj-type */
            ,input  buf_clients.obj-code /* p-obj-code */
            ) .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение переменной x-SelectObject" skip
          "x-SelectObject" x-SelectObject skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    case x-SelectGood
    :
      when {&g-all}
      then do:
        /* все товары */
        for each buf_goods no-lock
        :
          assign
            v-ind = v-ind + 1
          .
          if v-ind modulo 10 = 0
          then do:
            run waitfram-show in this-procedure
              (input substitute("Анализ товаров. Обработано &1", v-ind)
              ) .
          end.

          run select-parts in this-procedure
            (input  buf_goods.artic     /* p-artic     */
            ,input  buf_goods.prod-type /* p-prod-type */
            ,input  buf_goods.prod-code /* p-prod-code */
            ) .
        end.
      end.
      when {&g-grp}
      then do:
        /* товары по группе */
        for each buf_tmp#grp
        ,each buf_goods no-lock
          where buf_goods.grp-name begins buf_tmp#grp.grp-name
        :
          assign
            v-ind = v-ind + 1
          .
          if v-ind modulo 10 = 0
          then do:
            run waitfram-show in this-procedure
              (input substitute("Анализ товаров. Обработано &1", v-ind)
              ) .
          end.

          run select-parts in this-procedure
            (input  buf_goods.artic     /* p-artic     */
            ,input  buf_goods.prod-type /* p-prod-type */
            ,input  buf_goods.prod-code /* p-prod-code */
            ) .
        end.
      end.
      when {&g-prod}
      then do:
        /* товары по производителю */
        for each buf_g#cli
        ,each buf_goods no-lock
          where buf_goods.prod-type = buf_g#cli.obj-type
            and buf_goods.prod-code = buf_g#cli.obj-code
        :
          assign
            v-ind = v-ind + 1
          .
          if v-ind modulo 10 = 0
          then do:
            run waitfram-show in this-procedure
              (input substitute("Анализ товаров. Обработано &1", v-ind)
              ) .
          end.

          run select-parts in this-procedure
            (input  buf_goods.artic     /* p-artic     */
            ,input  buf_goods.prod-type /* p-prod-type */
            ,input  buf_goods.prod-code /* p-prod-code */
            ) .
        end.
      end.
      when {&g-choice} or
      when {&g-one}    or
      when {&g-grp-prod}
      then do:
        /* выборочно */
        /* один */
        /* товары по группе производителю */
        for each buf_gds-list no-lock
        :
          assign
            v-ind = v-ind + 1
          .
          if v-ind modulo 10 = 0
          then do:
            run waitfram-show in this-procedure
              (input substitute("Анализ товаров. Обработано &1", v-ind)
              ) .
          end.

          run select-parts in this-procedure
            (input  buf_gds-list.artic     /* p-artic     */
            ,input  buf_gds-list.prod-type /* p-prod-type */
            ,input  buf_gds-list.prod-code /* p-prod-code */
            ) .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение переменной x-SelectGood" skip
          "x-SelectGood" x-SelectGood skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    run waitfram-hide in this-procedure .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-open-query Dialog-Frame
PROCEDURE my-open-query :



define variable v-flt-open-query-def as character no-undo .


&scop flt-open-open-query open query browse-1 for each query_temp-last-date

&scop flt-open-dyn_open-query  for each query_temp-last-date

&scop flt-open-query-handle query browse-1:handle

&scop flt-open-find-buffer-name query_temp-last-date

&scop flt-open-query-was-opened  v-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-debug-file


&scop flt-open-table-name parts


&scop flt-open-waitfram true

  define variable sort-column-phrase as character no-undo .
  define variable v-query-was-opened as logical   no-undo .

  assign
    sort-column-phrase = ""
  .

  do
  on error undo, return error return-value
  :
    case rs-filter :
      when 1
      then do:
/*        open query {&browse-name} for each query_temp-last-date .*/
        { gbl/fltopend.i
          &where-cond = "true"
          &where-cond = " 'true' "
          &use-ind = " "
          &by = " "
        }
      end.
      when 2
      then do:
        open query {&browse-name} for each query_temp-last-date
          where query_temp-last-date.new-last-date <> query_temp-last-date.last-date
          .
      end.
      when 3
      then do:
        open query {&browse-name} for each query_temp-last-date
          where query_temp-last-date.new-last-date = query_temp-last-date.last-date
          .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение переменной rs-filter" skip
          "rs-filter" rs-filter skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    apply 'entry':u to query_temp-last-date.new-last-date in browse {&browse-name} .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-data Dialog-Frame
PROCEDURE save-data :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp-last-date for temp-last-date .

  define variable v-gds-code as integer   no-undo .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    for each buf_temp-last-date
      where buf_temp-last-date.new-last-date <> buf_temp-last-date.last-date
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (substitute("Сохранение нового срока годности &1", v-ind)
          ) .
      end.


      { gbl/gds-code.i
        buf_temp-last-date.artic
        buf_temp-last-date.prod-type
        buf_temp-last-date.prod-code
        v-gds-code
      }

      run trg/partolas.p
        (input  buf_temp-last-date.obj-type      /* p-obj-type  */
        ,input  buf_temp-last-date.obj-code      /* p-obj-code  */
        ,input  buf_temp-last-date.in-code       /* p-in-code   */
        ,input  v-gds-code                       /* p-gds-code  */
        ,input  buf_temp-last-date.part-code     /* p-part-code */
        ,input  buf_temp-last-date.new-last-date /* p-last-date */
        ) .

      define variable v-send-news    as logical   no-undo .
      define variable v-send-db-list as character no-undo .
      define variable v-cmd          as character no-undo .

      assign
        v-send-news = false
      .

      if v-cntxt-db-num <> 0
      then do:
        assign
          v-send-news = true
          v-send-db-list = "0":u
        .
      end.
      else do:
        define buffer buf_clients for ub.clients .
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_temp-last-date.obj-type
            and buf_clients.obj-code = buf_temp-last-date.obj-code
          .
        if buf_clients.db-num <> 0
        then do:
          assign
            v-send-news = true
            v-send-db-list = string(buf_clients.db-num)
          .
        end.
      end.
      define variable conf-par as character no-undo.
      define variable mode-erprn as logical no-undo.
      define variable par-type as character no-undo.
        { gbl/conf-rd.i
        "'is-erpRN'"
        0
        "''"
        0
        "''"
        "''"
        "''"
        NO
        conf-par
        par-type
        no-error
        }
        IF not error-status:error and conf-par = "yes":U then v-send-news = false.

      /* отправляем команду об изменении */
      if v-send-news = true
      then do:
        assign
          v-cmd = "command":U + {&delim-nws}
                + "parts":U + {&delim-nws}
                + "last-date":U + {&delim-nws}
                + buf_temp-last-date.obj-type + {&delim-nws}
                + string(buf_temp-last-date.obj-code) + {&delim-nws}
                + buf_temp-last-date.in-code + {&delim-nws}
                + string(v-gds-code) + {&delim-nws}
                + buf_temp-last-date.part-code + {&delim-nws}
                + substitute('&1', string(buf_temp-last-date.new-last-date, '99/99/9999':u) )
        .
        run nws/cr-route.p
          (input  {&send-cmd}
          ,input  v-cmd
          ,input  ?
          ,input  v-send-db-list
          ).
      end.

      output stream PrnLibStream to value("partolas.txt":u) append .
      put stream PrnLibStream unformatted
        cur-time-string()
        " obj-type "
        buf_temp-last-date.obj-type
        " obj-code "
        buf_temp-last-date.obj-code
        " in-code "
        buf_temp-last-date.in-code
        " gds-code "
        v-gds-code
        " part-code "
        buf_temp-last-date.part-code
        " new-last-date "
        string(buf_temp-last-date.new-last-date, '99/99/9999':u)
        " old-last-date "
        string(buf_temp-last-date.last-date, '99/99/9999':u)
        {&new-line}
        .
      output stream PrnLibStream close .
    end.

    run waitfram-hide in this-procedure .

    if v-ind <> 0
    then do:
      message
        "Изменение даты 'Годен до' завершено" skip
        "Изменено партий" v-ind skip
        view-as alert-box information .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-parts Dialog-Frame
PROCEDURE select-parts :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .

  define variable vss-description as character no-undo init "select-parts-01: выбор партий по указанным условиям".

  define buffer buf_parts for ub.parts .
  define buffer buf_goods for ub.goods .

  define buffer buf_temp-sel-obj   for temp-sel-obj .
  define buffer buf_temp-parts     for temp-parts .
  define buffer buf_temp-last-date for temp-last-date .


  do
  on error undo, return error return-value
  :

    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    for each buf_temp-sel-obj
    :

      run partslib-init-temp-parts in this-procedure
        (input  buf_temp-sel-obj.obj-type
        ,input  buf_temp-sel-obj.obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ) .


      for each buf_temp-parts
      :
        define variable v-copy-part as logical   no-undo .

        assign
          v-copy-part = false
        .

        case p-select
        :
          when "not-defined"
          then do:
            if buf_temp-parts.last-date = ?
            then do:
              assign
                v-copy-part = true
              .
            end.
          end.
          when "less-then"
          then do:
            if  buf_temp-parts.last-date <> ?
            and buf_temp-parts.last-date < p-last-date
            then do:
              assign
                v-copy-part = true
              .
            end.
          end.
          when "all"
          then do:
            assign
              v-copy-part = true
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Внутренняя ошибка" skip
              "Неизвестное значение переменной p-select" skip
              "p-select" p-select skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .

        if v-copy-part = true
        then do:
          create buf_temp-last-date .
          assign
            buf_temp-last-date.gds-code      = buf_goods.gds-code
            buf_temp-last-date.artic         = buf_temp-parts.artic
            buf_temp-last-date.prod-type     = buf_temp-parts.prod-type
            buf_temp-last-date.prod-code     = buf_temp-parts.prod-code
            buf_temp-last-date.part-code     = buf_temp-parts.part-code
            buf_temp-last-date.obj-type      = buf_temp-parts.obj-type
            buf_temp-last-date.obj-code      = buf_temp-parts.obj-code
            buf_temp-last-date.gds-name      = buf_goods.gds-name
            buf_temp-last-date.fact-qnty     = buf_temp-parts.fact-qnty
            buf_temp-last-date.fact-date     = buf_temp-parts.fact-date
            buf_temp-last-date.in-code       = buf_temp-parts.in-code
            buf_temp-last-date.last-date     = buf_temp-parts.last-date
            buf_temp-last-date.new-last-date = buf_temp-parts.last-date
            buf_temp-last-date.obj-full      = substitute("&1 &2"
                                              ,buf_temp-parts.obj-type
                                              ,buf_temp-parts.obj-code
                                              )
            buf_temp-last-date.prod-full     = substitute("&1 &2"
                                              ,buf_temp-parts.prod-type
                                              ,buf_temp-parts.prod-code
                                              )
            buf_temp-last-date.price-base    = buf_temp-parts.price-base
            buf_temp-last-date.price-rubl    = buf_temp-parts.price-rubl
            buf_temp-last-date.supp-type     = buf_temp-parts.supp-type
            buf_temp-last-date.supp-code     = buf_temp-parts.supp-code
            buf_temp-last-date.supp-full     = substitute("&1 &2"
                                              ,buf_temp-parts.supp-type
                                              ,buf_temp-parts.supp-code
                                              )
            buf_temp-last-date.is-supp       = buf_temp-parts.is-supp
            buf_temp-last-date.cst-code      = buf_temp-parts.cst-code
          .
        end.
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-filter-name as character no-undo .

  define variable v-title as character no-undo .

  assign
    v-title = "Редактирование сроков годности партий товара"
  .

  do with frame {&frame-name}:
    if p-filter-name > ""
    then do:
      assign
        frame {&frame-name}:title
          = v-title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        rect-flt :BGCOLOR = RED_COLOR
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        frame {&frame-name}:title
          = v-title
      .
      assign
        rect-flt :BGCOLOR = GREY_COLOR
        b-sch :TOOLTIP = ""
      .
    end.
  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME