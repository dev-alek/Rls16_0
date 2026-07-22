&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Настройка порядка колонок для АВТОЗАКАЗА (расчет потребности)

Автор: Комаров Иван Сергеевич
Дата создания: 07/23/10
Author: Ivan Komarov
Creation date: 07/23/10

Автор1: Чернова Светлана Александровна
Дата создания1: 12/17/07

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройка порядка колонок для АВТОЗАКАЗА (расчет потребности)".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/usr-flt.i  }
{ cmp/showinf.i  }

/*------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
&scop line-num 10

define temp-table tt-table no-undo
    FIELD id AS INTEGER
    FIELD name-col AS CHARACTER format "x(256)"
    FIELD new-id AS INTEGER
    INDEX p1 IS PRIMARY new-id
    INDEX p2 id
    .

define temp-table tt-old no-undo
    FIELD id AS INTEGER
    FIELD new-id AS INTEGER
    INDEX p1 IS PRIMARY id
    .

define variable v-recid as recid no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-table

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 tt-table.name-col
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt-table
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH tt-table .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-table
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-table


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-Help BROWSE-1 B-up B-down

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-down
     LABEL "B-down"
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     SIZE 6.38 BY 1.13.

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     SIZE 6.38 BY 1.13.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
tt-table.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      tt-table.name-col format "x(100)" column-label "Название колонки"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 72 BY 18.75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 71.5
     BROWSE-1 AT ROW 2.75 COL 2
     B-up AT ROW 2.75 COL 75
     B-down AT ROW 4.25 COL 75
     SPACE(0.24) SKIP(16.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Изменение порядка колонок в режиме РАСЧЕТ потребности товара"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel.


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
                                                                        */
/* BROWSE-TAB BROWSE-1 B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-table .
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BROWSE-1 FOR
tt-table.
     _END_FREEFORM_DEFINE
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Изменение порядка колонок в режиме РАСЧЕТ потребности товара */
DO:
  RUN save-proc NO-ERROR.
  if error-status :error then
     return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Изменение порядка колонок в режиме РАСЧЕТ потребности товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-down Dialog-Frame
ON CHOOSE OF B-down IN FRAME Dialog-Frame /* B-down */
DO:

  IF AVAILABLE tt-table THEN DO:
      v-recid = recid(tt-table) .
      tt-table.new-id = tt-table.new-id + 1 .
      if tt-table.new-id > 34 then tt-table.new-id = 34. /*число столбцов*/
      {&OPEN-QUERY-{&BROWSE-NAME}}
      reposition {&BROWSE-NAME} to recid v-recid no-error .
      {&browse-name} :SET-REPOSITIONED-ROW({&line-num}, "CONDITIONAL") .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-up Dialog-Frame
ON CHOOSE OF B-up IN FRAME Dialog-Frame /* B-up */
DO:
  IF AVAILABLE tt-table THEN DO:
    v-recid = recid(tt-table) .
    tt-table.new-id = tt-table.new-id - 1 .
    if tt-table.new-id < 0 then tt-table.new-id = 1.
    {&OPEN-QUERY-{&BROWSE-NAME}}
    reposition {&BROWSE-NAME} to recid v-recid no-error .
    {&browse-name} :SET-REPOSITIONED-ROW({&line-num}, "CONDITIONAL") .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
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
    RUN make_tt  .
    RUN enable_UI.
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
  ENABLE B-OK B-Cancel B-Help BROWSE-1 B-up B-down
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make_tt Dialog-Frame
PROCEDURE make_tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  create tt-table.
  assign
    tt-table.id       = 1
    tt-table.name-col = 'Код товара'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 2
    tt-table.name-col = 'Артикул'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 3
    tt-table.name-col = 'Название товара'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 4
    tt-table.name-col = 'Группа'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 5
    tt-table.name-col = 'Ед.Изм.'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 6
    tt-table.name-col = 'Код производителя'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 7
    tt-table.name-col = 'Название производителя'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 8
    tt-table.name-col = 'Артикул контрагента'
    tt-table.new-id = tt-table.id
  .

  create tt-table.
  assign
    tt-table.id       = 9
    tt-table.name-col = 'ЕдИзм Контрагента'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 10
    tt-table.name-col = 'Срок хранения'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 11
    tt-table.name-col = 'Коэффициент пересчета Ед.Изм.'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 12
    tt-table.name-col = 'Кол-во в упаковке'
    tt-table.new-id = tt-table.id
  .

  create tt-table.
  assign
    tt-table.id       = 13
    tt-table.name-col = 'Темп продаж'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 14
    tt-table.name-col = 'Расход'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 15
    tt-table.name-col = 'Дней без продаж и остатков'
    tt-table.new-id = tt-table.id
  .

  create tt-table.
  assign
    tt-table.id       = 16
    tt-table.name-col = 'Дней в продаже'
    tt-table.new-id = tt-table.id
  .

  create tt-table.
  assign
    tt-table.id       = 17
    tt-table.name-col = 'Остаток'
    tt-table.new-id = tt-table.id
  .

  create tt-table.
  assign
    tt-table.id       = 18
    tt-table.name-col = 'Приход'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 19
    tt-table.name-col = 'MIN остаток'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 20
    tt-table.name-col = 'Уровень постоянного присутствия'
    tt-table.new-id = tt-table.id
  .

  create tt-table.
  assign
    tt-table.id       = 21
    tt-table.name-col = 'MIN заказ'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 22
    tt-table.name-col = 'Код объекта'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 23
    tt-table.name-col = 'Разрешены отрицательные остатки'
    tt-table.new-id = tt-table.id
  .

  create tt-table.
  assign
    tt-table.id       = 24
    tt-table.name-col = 'В пути'
    tt-table.new-id = tt-table.id
  .

  create tt-table.
  assign
    tt-table.id       = 25
    tt-table.name-col = 'Заказ кол-во'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 26
    tt-table.name-col = 'Поставщики'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 27
    tt-table.name-col = 'Цены поставщиков'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 28
    tt-table.name-col = 'Тип Поставщика'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 29
    tt-table.name-col = 'Код Поставщика'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 30
    tt-table.name-col = 'Артикул Поставщика'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 31
    tt-table.name-col = 'Выбор Поставщика'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 32
    tt-table.name-col = 'Название Объекта'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 33
    tt-table.name-col = 'Расчет кол-во'
    tt-table.new-id = tt-table.id
  .
  create tt-table.
  assign
    tt-table.id       = 34
    tt-table.name-col = 'Штрихкод производителя'
    tt-table.new-id = tt-table.id
  .
run uf-get in this-procedure (
     input  {&uf-seqeallo}
    ,input  'adm'
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.

if v-uf-List_ <> "" then do:
define variable iv as integer   no-undo .
define variable i-kol as integer   no-undo .
define variable st as character no-undo .

i-kol = num-entries (v-uf-List_, {&delim-par}) .
repeat Iv = 1 to i-kol :
   st = entry(Iv,v-uf-List_, {&delim-par}).
   create tt-old.
   assign
     tt-old.id = integer(entry(1, st))
     tt-old.new-id = integer(entry(2, st))
   .
end.
for each tt-table :
    find first tt-old where
               tt-old.id = tt-table.id no-error.
     if available tt-old then do:
      tt-table.new-id = tt-old.new-id .
     end.
end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-str as character no-undo .
define variable v-i   as integer   no-undo .

v-str = '' .
v-i = 0 .
for each tt-table break by new-id :
    v-i = v-i + 1 .
    v-str = v-str + string(tt-table.id) + ',' + string(v-i) + {&delim-par} .
end.
v-str = trim(v-str,{&delim-par}) .



run uf-set in this-procedure(
    input  {&uf-seqeallo}
    ,input 'adm'
    ,input v-str
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
