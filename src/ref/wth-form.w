&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-wealth NO-UNDO LIKE ub.wealth.
DEFINE TEMP-TABLE tt-wth-gds NO-UNDO LIKE ub.wth-gds.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка материальной ценности

Автор: Гридчина Полина Дмитриевна
Дата создания: 04/10/06
Author: Polina Gridchina
Creation date: 04/10/06

*/
/* В данном диалоге не реализована возможность привязки нескольких товаров к МЦ. Изменение и удаление даже одной записи
закрыто в силу, того что тогда необходима доработка интерфейса для работы с удаленными связями.
На данном этапе можно единажды привязать один товар.
*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter pwth-code as integer no-undo.
define input parameter par-mode as character no-undo.
define output PARAMETER p-rec as recid no-undo.



/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка материальной ценности ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/library.i }

DEF TEMP-TABLE tt-gds NO-UNDO
    FIELD gds-code LIKE ub.goods.gds-code.
DEF BUFFER LOCKED_wealth FOR ub.wealth.
DEF BUFFER LOCKED_wth-gds FOR ub.wth-gds.

define variable ser-wth  as logical   no-undo. /* для чтения параметра конфигурации */
define variable conf-par as character no-undo.
define variable par-type as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-wth-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-wth-gds goods tt-wealth

/* Definitions for BROWSE BR-wth-gds                                    */
&Scoped-define FIELDS-IN-QUERY-BR-wth-gds goods.artic goods.prod-type ~
goods.prod-code goods.gds-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-wth-gds
&Scoped-define QUERY-STRING-BR-wth-gds FOR EACH tt-wth-gds ~
      WHERE tt-wth-gds.stts = 0 NO-LOCK, ~
      EACH ub.goods WHERE TRUE /* Join to wealth incomplete */ ~
      AND ub.goods.gds-code = tt-wth-gds.gds-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-wth-gds OPEN QUERY BR-wth-gds FOR EACH tt-wth-gds ~
      WHERE tt-wth-gds.stts = 0 NO-LOCK, ~
      EACH ub.goods WHERE TRUE /* Join to wealth incomplete */ ~
      AND ub.goods.gds-code = tt-wth-gds.gds-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-wth-gds tt-wth-gds goods
&Scoped-define FIRST-TABLE-IN-QUERY-BR-wth-gds tt-wth-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BR-wth-gds goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-wealth.wth-name ~
tt-wealth.is-money tt-wealth.curr-code tt-wealth.unit-base ~
tt-wealth.get-qnty-method tt-wealth.is-ser tt-wealth.PS tt-wealth.wth-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-wealth.wth-name ~
tt-wealth.is-money tt-wealth.curr-code tt-wealth.unit-base ~
tt-wealth.get-qnty-method tt-wealth.PS tt-wealth.wth-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-wealth
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-wealth
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-wth-gds}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-wealth SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-wealth SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-wealth
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-wealth


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-wealth.wth-name tt-wealth.is-money ~
tt-wealth.curr-code tt-wealth.unit-base tt-wealth.get-qnty-method ~
tt-wealth.PS tt-wealth.wth-code
&Scoped-define ENABLED-TABLES tt-wealth
&Scoped-define FIRST-ENABLED-TABLE tt-wealth
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-hist B-Help B-unit B-curr ~
FILL-IN-1 b-del fcurr-abbr
&Scoped-Define DISPLAYED-FIELDS tt-wealth.wth-name tt-wealth.is-money ~
tt-wealth.curr-code tt-wealth.unit-base tt-wealth.get-qnty-method ~
tt-wealth.is-ser tt-wealth.PS tt-wealth.wth-code
&Scoped-define DISPLAYED-TABLES tt-wealth
&Scoped-define FIRST-DISPLAYED-TABLE tt-wealth
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1 fcurr-abbr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,btn-gds,List-6                           */
&Scoped-define btn-gds BR-wth-gds b-add b-chg b-del

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-curr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .

DEFINE BUTTON b-del
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-unit
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE fcurr-abbr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.88 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Опред. кол-ва"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-wth-gds FOR
      tt-wth-gds,
      ub.goods SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-wealth SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-wth-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-wth-gds Dialog-Frame _STRUCTURED
  QUERY BR-wth-gds NO-LOCK DISPLAY
      ub.goods.artic FORMAT "X(16)":U WIDTH 12
      ub.goods.prod-type FORMAT "X(3)":U
      ub.goods.prod-code FORMAT ">>>>>>>>9":U
      ub.goods.gds-name FORMAT "X(30)":U WIDTH 36.25
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 68.5 BY 3.25 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-wealth.wth-name AT ROW 2.42 COL 1.88
          LABEL "Название" FORMAT "X(40)"
          VIEW-AS FILL-IN
          SIZE 41.38 BY 1
     tt-wealth.is-money AT ROW 2.42 COL 55.25
          LABEL "Деньги или денежный эквивалент"
          VIEW-AS TOGGLE-BOX
          SIZE 33.13 BY 1
     tt-wealth.curr-code AT ROW 3.75 COL 10 COLON-ALIGNED
          LABEL "Валюта" FORMAT ">>9"
          VIEW-AS FILL-IN
          SIZE 5.13 BY .96
     tt-wealth.unit-base AT ROW 3.75 COL 42.75 COLON-ALIGNED
          LABEL "Ед.изм"
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
     B-unit AT ROW 3.79 COL 51.13
     B-curr AT ROW 3.83 COL 17.75
     FILL-IN-1 AT ROW 5 COL 1.5 NO-LABEL WIDGET-ID 16
     tt-wealth.get-qnty-method AT ROW 5 COL 19 NO-LABEL WIDGET-ID 12
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
          SIZE 72.5 BY 3.5 TOOLTIP "Как определить кол-во МЦ по ее сумме и пр."
     tt-wealth.is-ser AT ROW 8.75 COL 10 COLON-ALIGNED WIDGET-ID 10
          LABEL "Серийная" FORMAT "9"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Нет",0,
                     "Да",1
          DROP-DOWN-LIST
          SIZE 7 BY 1
     BR-wth-gds AT ROW 8.75 COL 22.5 WIDGET-ID 100
     b-add AT ROW 12 COL 22.5 WIDGET-ID 4
     b-chg AT ROW 12 COL 32.5 WIDGET-ID 8
     b-del AT ROW 12 COL 42.5 WIDGET-ID 6
     tt-wealth.PS AT ROW 13 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 97.63 BY 1.71
     tt-wealth.wth-code AT ROW 1.08 COL 28.5 COLON-ALIGNED NO-LABEL FORMAT "999999999"
           VIEW-AS TEXT
          SIZE 13 BY 1
          FGCOLOR 4
     fcurr-abbr AT ROW 3.92 COL 20.63 COLON-ALIGNED NO-LABEL
     "Код" VIEW-AS TEXT
          SIZE 6.13 BY 1.08 AT ROW 1 COL 22.88
     SPACE(69.98) SKIP(12.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Материальная ценность"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-wealth T "?" NO-UNDO ub wealth
      TABLE: tt-wth-gds T "?" NO-UNDO ub wth-gds
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-wth-gds is-ser Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-add IN FRAME Dialog-Frame
   NO-ENABLE 5                                                          */
ASSIGN
       b-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-chg IN FRAME Dialog-Frame
   NO-ENABLE 5                                                          */
ASSIGN
       b-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON b-del IN FRAME Dialog-Frame
   5                                                                    */
ASSIGN
       b-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BROWSE BR-wth-gds IN FRAME Dialog-Frame
   NO-ENABLE 5                                                          */
ASSIGN
       BR-wth-gds:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

/* SETTINGS FOR FILL-IN tt-wealth.curr-code IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX tt-wealth.is-money IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-wealth.is-ser IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
ASSIGN
       tt-wealth.is-ser:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-wealth.unit-base IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-wealth.wth-code IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-wealth.wth-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-wth-gds
/* Query rebuild information for BROWSE BR-wth-gds
     _TblList          = "Temp-Tables.tt-wth-gds,ub.goods WHERE ub.wealth ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ","
     _Where[1]         = "Temp-Tables.tt-wth-gds.stts = 0"
     _Where[2]         = "goods.gds-code = tt-wth-gds.gds-code"
     _FldNameList[1]   > ub.goods.artic
"goods.artic" ? ? "character" ? ? ? ? ? ? no ? no no "12" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = ub.goods.prod-type
     _FldNameList[3]   = ub.goods.prod-code
     _FldNameList[4]   > ub.goods.gds-name
"goods.gds-name" ? "X(30)" "character" ? ? ? ? ? ? no ? no no "36.25" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-wth-gds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-wealth"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Материальная ценность */
DO:
  run proc-save in this-procedure no-error .
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Материальная ценность */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
    EMPTY TEMP-TABLE tt-gds.
    run str/sel-gds.w (parparentproc, INPUT-OUTPUT table tt-gds ).
    for each tt-gds:
      create tt-wth-gds  .
      assign tt-wth-gds.gds-code = tt-gds.gds-code.
    end.

    {&OPEN-QUERY-{&BROWSE-NAME}}
    run GdsEnable.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
    IF NOT AVAILABLE tt-wth-gds THEN DO:
        MESSAGE 'Неправильно выбрана строка'
            VIEW-AS ALERT-BOX.
        RETURN NO-APPLY.
    END.
    EMPTY TEMP-TABLE tt-gds.  /* Заполнение таблицы - параметра */
    CREATE tt-gds.
    tt-gds.gds-code = tt-wth-gds.gds-code.
    RELEASE tt-gds.
    /* Вызов диалога выбора товара */
    run str/sel-gds.w (parparentproc, INPUT-OUTPUT table tt-gds ).
    for FIRST tt-gds:
      assign tt-wth-gds.gds-code = tt-gds.gds-code.
    end.
    {&OPEN-QUERY-{&BROWSE-NAME}}
    run GdsEnable.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-curr Dialog-Frame
ON CHOOSE OF B-curr IN FRAME Dialog-Frame
DO:
define variable rr as recid no-undo.
    rr = ? .
    run ref/currency.w (input parparentproc, "b-sel", input-output rr ).
    if rr <> ? then do:
        FIND FIRST ub.currency WHERE
             recid( ub.currency ) = rr NO-LOCK .
        DISPLAY
        ub.currency.curr-code @ tt-wealth.curr-code
        ub.currency.curr-abbr @ fcurr-abbr
        with frame {&frame-name} .
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:

define variable del-rec as recid no-undo.
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
define buffer buf_wealth for ub.wealth.
if not available tt-wth-gds then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.

rep-rec = recid (tt-wth-gds).
glog = no.

FIND FIRST tt-wth-gds WHERE recid (tt-wth-gds) = rep-rec.
if tt-wth-gds.stts <> 0 then do:
    glog = no.
    message
    SUBSTITUTE('Товар с кодом &1 уже удален.~nВосстановить?',tt-wth-gds.gds-code)
    view-as alert-box question buttons Yes-No update glog.
    if not glog then do:
      apply "entry" to br-wth-gds in frame {&frame-name}.
      return no-apply.
    end.
    assign
    tt-wth-gds.stts = 0
    .
    {&BROWSE-NAME}:REFRESH() NO-ERROR.


end.
else do:
      glog = no.
      MESSAGE SUBSTITUTE('Удалить товар с кодом &1 из списка~nВы уверены?',tt-wth-gds.gds-code)
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
        return no-apply.
      end.
      delete   tt-wth-gds.
    {&OPEN-QUERY-{&BROWSE-NAME}}
    run GdsEnable.
/*     run OpenBr. */
 end.
 apply "entry" to {&BROWSE-NAME} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .


  run ref/cwthhist.w (
                   input        parparentproc
                 , input        ?
                 , input        '':U    /* p-curr-obj-type  */
                 , input        0    /* p-curr-obj-code  */
                 , input        "":U          /* bttns */
                 , input        "subject":U       /* p-mode */
                 , input        tt-wealth.wth-code /*p-wth-code*/
                 , INPUT        0             /*p-par-code*/
                 , input        ?             /* p-host-code */
                 , input        ?             /* p-obj-type*/
                 , input        ?             /* p-obj-code*/
                 , input        ?             /* p-corr-user-db-num */
                 , input        "":U          /* p-corr-user-name */
                 , input        {&table_wealth}  /* p-subject */
                 , input        v-cntxt-db-num      /* p-db-num */
                 , input ?
                 , input ?
                 , input-output v-rid-list
                 ) no-error .
if error-status:error then do:
  message return-value skip
          error-status:get-message(1)
  view-as alert-box.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-unit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-unit Dialog-Frame
ON CHOOSE OF B-unit IN FRAME Dialog-Frame
DO:
    run ch-units.
    apply "entry" to tt-wealth.unit-base in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wealth.curr-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wealth.curr-code Dialog-Frame
ON LEAVE OF tt-wealth.curr-code IN FRAME Dialog-Frame /* Валюта */
DO:
  assign
  tt-wealth.curr-code.
  if tt-wealth.is-money = yes and tt-wealth.curr-code = ? then do:
    message "Для материальных ценностей - денежных средств или имеющих денежный эквивалент" skip
            "необходимо ввести код валюты"
    view-as alert-box ERROR.
    return no-apply.
  end.
  if tt-wealth.curr-code <> ? then do:
    FIND FIRST ub.currency WHERE
               ub.currency.curr-code = tt-wealth.curr-code NO-LOCK .
    if not avail ub.currency then do:
        message "Не найдена валюта с кодом " tt-wealth.curr-code skip
        view-as alert-box ERROR.
        return no-apply.
    end.
    DISPLAY
    ub.currency.curr-code @ tt-wealth.curr-code
    ub.currency.curr-abbr @ fcurr-abbr
    with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wealth.is-money
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wealth.is-money Dialog-Frame
ON VALUE-CHANGED OF tt-wealth.is-money IN FRAME Dialog-Frame /* Деньги или денежный эквивалент */
DO:
  assign
  tt-wealth.is-money.
  if tt-wealth.is-money = yes then do:
    ENABLE
    tt-wealth.curr-code
    b-curr
    with frame {&frame-name}.
    DISABLE
    tt-wealth.unit-base
    b-unit
    tt-wealth.is-ser
    with frame {&frame-name}.
  end.
  else do:
    display
    ? @ tt-wealth.curr-code
    "" @ fcurr-abbr
    with frame {&frame-name}.
    DISABLE
    tt-wealth.curr-code
    b-curr
    with frame {&frame-name}.
    ENABLE
    tt-wealth.unit-base
    b-unit
    tt-wealth.is-ser WHEN ser-wth
    with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wealth.is-ser
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wealth.is-ser Dialog-Frame
ON VALUE-CHANGED OF tt-wealth.is-ser IN FRAME Dialog-Frame /* Серийная */
DO:
  ASSIGN tt-wealth.is-ser.
  IF tt-wealth.is-ser = 1 THEN DO:
/*    ENABLE {&btn-gds} WITH FRAME Dialog-Frame.*/
    DISABLE tt-wealth.is-money
            tt-wealth.curr-code
            b-curr
   /*         B-unit
            tt-wealth.unit-base */
    WITH FRAME {&FRAME-NAME}.
  END.
  ELSE IF tt-wealth.is-ser = 0 THEN DO:
/*    DISABLE {&btn-gds} WITH FRAME Dialog-Frame.*/
    ENABLE tt-wealth.is-money tt-wealth.curr-code b-curr WITH FRAME {&FRAME-NAME}.
    APPLY "VALUE-CHANGED":U TO tt-wealth.is-money.
  END.
  run gdsEnable.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-wealth.unit-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-wealth.unit-base Dialog-Frame
ON LEAVE OF tt-wealth.unit-base IN FRAME Dialog-Frame /* Ед.изм */
DO:
    if not can-FIND( ub.units where ub.units.unit-name = input frame {&frame-name} tt-wealth.unit-base )
     then do:
     tt-wealth.unit-base = "?".
     DISPLAY tt-wealth.unit-base WITH FRAME {&Frame-name}.
     run ch-units.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-wth-gds
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
 IF lookup(par-mode, {&add-def} + {&comma-char} +
                      {&UPDATE} + {&comma-char} +
                      {&LOOKUP}) = 0 THEN DO:
    MESSAGE
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.
/* Определение конфигурационного параметра доступности подсиситемы серийных МЦ */
    { gbl/conf-rd.i
    "'ser-wth'"
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
    IF not error-status:error then
    assign
    ser-wth = (conf-par = "yes":U).
/*   { gbl/getcntxt.i get } */
  RUN Myenable no-error.
  if error-status:error then return error.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-units Dialog-Frame
PROCEDURE ch-units :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ref-rec as recid no-undo .
   run ref/units.w ( input parparentproc, input yes, output ref-rec ).
    if ref-rec = ? then do:
            apply "entry" to b-unit in frame {&frame-name}.
            return no-apply.
    end.
    FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
    DISPLAY ub.units.unit-name @ tt-wealth.unit-base with frame {&frame-name}.

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY FILL-IN-1 fcurr-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wealth THEN
    DISPLAY tt-wealth.wth-name tt-wealth.is-money tt-wealth.curr-code
          tt-wealth.unit-base tt-wealth.get-qnty-method tt-wealth.is-ser
          tt-wealth.PS tt-wealth.wth-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-hist B-Help tt-wealth.wth-name tt-wealth.is-money
         tt-wealth.curr-code tt-wealth.unit-base B-unit B-curr FILL-IN-1
         tt-wealth.get-qnty-method b-del tt-wealth.PS tt-wealth.wth-code
         fcurr-abbr
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GdsEnable Dialog-Frame
PROCEDURE GdsEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF ser-wth and tt-wealth.is-ser:SCREEN-VALUE IN FRAME {&FRAME-NAME} = '1' AND CAN-FIND(FIRST tt-wth-gds NO-LOCK where tt-wth-gds.stts = 0) THEN DO WITH FRAME {&FRAME-NAME}:
    DISABLE b-add .
    if par-mode = {&add-def} then ENABLE b-chg b-del BR-wth-gds.
    else disable b-chg b-del BR-wth-gds.
END.
ELSE IF ser-wth and tt-wealth.is-ser:SCREEN-VALUE = '1'  THEN DO WITH FRAME {&FRAME-NAME}:
    ENABLE b-add.
    DISABLE b-chg b-del WITH FRAME {&FRAME-NAME}.
END.
ELSE DISABLE {&btn-gds} WITH FRAME Dialog-Frame.
apply 'entry':U to   {&BROWSE-NAME} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-list-items as character no-undo.
define variable v-ii as integer no-undo.
  if par-mode = {&update} or par-mode = {&lookup} then do:
    IF par-mode = {&update} THEN FIND FIRST locked_wealth Exclusive-lock where
                locked_wealth.wth-code = pwth-code NO-ERROR.
    ELSE FIND FIRST locked_wealth NO-LOCK where
                locked_wealth.wth-code = pwth-code NO-ERROR.
    if not avail locked_wealth then do:
        message vss-workfile vss-revision vss-description skip
        "Не найдена материальная ценность с кодом " pwth-code
        view-as alert-box error.
        return error.
    end.
    if locked_wealth.curr-code <> ? then do:
        FIND FIRST ub.currency No-LOCK WHERE
                    ub.currency.curr-code = locked_wealth.curr-code NO-ERROR.
        if not avail ub.currency then do:
           message vss-workfile vss-revision vss-description skip
           "Не найдена валюта с кодом " locked_wealth.curr-code
           "для материальной ценности с кодом " pwth-code
            view-as alert-box error.
            return error.
        end.
    end.
    else if locked_wealth.is-ser = 0 then do:
        FIND FIRST ub.units NO-LOCK WHERE
                   ub.units.unit-name = locked_wealth.unit-base No-ERROR.
        if not avail ub.units then do:
           message vss-workfile vss-revision vss-description skip
           "Не найдена единица измерения " locked_wealth.unit-base
           "для материальной ценности с кодом " pwth-code
            view-as alert-box error.
           /* return error.  */
        end.
    end.
    FOR EACH ub.wth-gds NO-LOCK WHERE ub.wth-gds.wth-code = Locked_wealth.wth-code:
        CREATE tt-wth-gds.
        BUFFER-COPY wth-gds TO tt-wth-gds.
    END.
    IF LOCKED_wealth.is-ser = 1 THEN DO:
        FIND FIRST LOCKED_wth-gds WHERE LOCKED_wth-gds.wth-code = LOCKED_wealth.wth-code EXCLUSIVE-LOCK NO-ERROR.
        if not avail locked_wth-gds then do:
        message vss-workfile vss-revision vss-description skip
        substitute("Не найдена связь МЦ (&1) с товарами",LOCKED_wealth.wth-code )
        view-as alert-box error.
        return error.
    end.
    END.
    CREATE tt-wealth.
    BUFFER-COPY LOCKED_wealth TO tt-wealth.
  end.
IF par-mode = {&add-def} THEN do:
    CREATE tt-wealth.
    tt-wealth.curr-code = ?.
END.
do v-ii = 1 to num-entries({&wth-qnty-methods}):
  v-list-items = v-list-items + (if v-ii = 1 then '' else {&comma-char}) +
                  entry(v-ii, {&wth-qnty-methods-full}) + {&comma-char} +
                  entry(v-ii, {&wth-qnty-methods}).
end.
assign
tt-wealth.get-qnty-method:radio-buttons in frame {&frame-name} = v-list-items
.
if par-mode = {&add-def} then do:
  assign
  tt-wealth.get-qnty-method = {&wth-qnty-sum}.
end.
/*ser-wth = yes.*/
DISPLAY
tt-wealth.wth-code
tt-wealth.wth-name
tt-wealth.curr-code
tt-wealth.is-money
tt-wealth.PS
tt-wealth.is-ser
tt-wealth.unit-base WHEN (NOT tt-wealth.is-money /*AND tt-wealth.is-ser = 0*/)
tt-wealth.get-qnty-method
(if avail currency then currency.curr-abbr else "" ) @ fcurr-abbr
WITH FRAME {&frame-name}
  .

if not ser-wth then hide tt-wealth.is-ser {&btn-gds} BR-wth-gds in frame   {&frame-name}.
else view tt-wealth.is-ser {&btn-gds} BR-wth-gds in frame   {&frame-name}.


frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} + par-mode.

if par-mode = {&lookup} then
enable b-quit  b-help b-hist WITH FRAME {&frame-name} .
else do:

  ENABLE
  B-exit
  b-quit
  B-Help
  tt-wealth.is-money when par-mode = {&add-def}
  b-unit when (par-mode = {&add-def} OR (NOT tt-wealth.is-money /*AND tt-wealth.is-ser = 0*/))
  tt-wealth.unit-base when (par-mode = {&add-def} OR (NOT tt-wealth.is-money /*AND tt-wealth.is-ser = 0*/))
  tt-wealth.wth-name
  tt-wealth.ps
  b-hist WHEN par-mode <> {&add-def}
  tt-wealth.is-ser WHEN (par-mode = {&add-def} AND ser-wth)
  tt-wealth.get-qnty-method when par-mode <> {&lookup}
  WITH FRAME {&frame-name}.
  /*   if par-mode = {&update} or par-mode = {&lookup} then do: */
/*  APPLY "VALUE-CHANGED":U TO tt-wealth.is-ser.*/
end.
VIEW FRAME Dialog-Frame.

  {&OPEN-QUERY-{&BROWSE-NAME}}
  APPLY "entry":U to tt-wealth.wth-name.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEF VAR wg-rec AS RECID NO-UNDO.
IF par-mode = {&LOOKUP} THEN UNDO, RETURN ERROR.
ASSIGN FRAME {&frame-name}
tt-wealth.curr-code
tt-wealth.is-money
tt-wealth.is-ser
tt-wealth.unit-base
tt-wealth.wth-name
fcurr-abbr
tt-wealth.get-qnty-method
.
IF tt-wealth.is-ser = 1 AND NOT CAN-FIND(FIRST tt-wth-gds NO-LOCK where tt-wth-gds.stts = 0) THEN DO:
    MESSAGE 'Для серийной МЦ должен быть указан товар!' VIEW-AS ALERT-BOX ERROR.
    APPLY 'entry':U TO b-add.
    RETURN NO-APPLY.
END.
save-block: do transaction  on error undo save-block, return error
on stop undo  save-block, return error
on endkey undo save-block, return error :
  if available locked_wealth then v-rec = recid(locked_wealth).
  run ref/wealth.p ( INPUT par-mode
                      ,INPUT NO /*p-silent*/
                      ,INPUT-OUTPUT v-rec
                      ,INPUT tt-wealth.wth-code
                      ,INPUT tt-wealth.is-money
                      ,INPUT tt-wealth.is-ser
                      ,INPUT (if tt-wealth.is-money
                              then fcurr-abbr
                              else tt-wealth.unit-base )
                      ,INPUT tt-wealth.curr-code
                      ,INPUT tt-wealth.wth-name
                      ,INPUT tt-wealth.get-qnty-method
                      ,INPUT tt-wealth.ps ) NO-ERROR.
  if error-status:error then do:
  { gbl/reterhnd.i error }
    undo save-block, return error.
  end.
  p-rec = v-rec.

  IF tt-wealth.is-ser = 0 THEN LEAVE. /* если не серийная МЦ выходим из блока*/
  if par-mode = {&add-def} then find first locked_wealth where recid(locked_wealth) = v-rec exclusive-lock.

  /*Синхронизация связей МЦ с товарами */
    FIND FIRST tt-wth-gds.
    IF AVAILABLE locked_wth-gds AND LOCKED_wth-gds.gds-code <> tt-wth-gds.gds-code THEN do: /*если запись связи с товарами изменилась, то старую записб переводим в статус удаленная и создаем новую*/
        wg-rec = RECID(locked_wth-gds).
        run ref/wth-gds.p ( INPUT par-mode
                          ,INPUT YES /*p-silent*/
                          ,INPUT-OUTPUT wg-rec
                          ,INPUT locked_wealth.wth-code
                          ,INPUT tt-wth-gds.gds-code
                          ,INPUT 1 )  NO-ERROR.
        if error-status:error then do:
         MESSAGE error-status:get-message(1) SKIP RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
         undo, return error.
        end.
        wg-rec = ?.
        run ref/wth-gds.p ( INPUT par-mode
                          ,INPUT YES /*p-silent*/
                          ,INPUT-OUTPUT wg-rec
                          ,INPUT locked_wealth.wth-code
                          ,INPUT tt-wth-gds.gds-code
                          ,INPUT 0 )  NO-ERROR.
        if error-status:error then do:
         MESSAGE error-status:get-message(1) SKIP RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
         undo, return error.
        end.
    END.
    IF NOT AVAILABLE LOCKED_wth-gds THEN DO:
        run ref/wth-gds.p ( INPUT par-mode
                          ,INPUT NO /*p-silent*/
                          ,INPUT-OUTPUT wg-rec
                          ,INPUT locked_wealth.wth-code
                          ,INPUT tt-wth-gds.gds-code
                          ,INPUT tt-wth-gds.stts ) NO-ERROR.
      if error-status:error then do:
        undo, return error.
      end.
    END.



/*   IF par-mode = {&UPDATE} THEN FOR EACH wth-gds EXCLUSIVE-LOCK WHERE wth-gds.wth-code = tt-wealth.wth-code ON ERROR UNDO save-block, RETURN ERROR RETURN-VALUE: */
/*       FIND FIRST tt-wth-gds WHERE tt-wth-gds.gds-code = wth-gds.gds-code EXCLUSIVE-LOCK NO-ERROR.                                                               */
/*       IF NOT AVAILABLE tt-wth-gds THEN DELETE wth-gds.                                                                                                          */
/*       ELSE DO:                                                                                                                                                  */
/*           BUFFER-COPY tt-wth-gds EXCEPT wth-code TO wth-gds.                                                                                                    */
/*           DELETE tt-wth-gds.                                                                                                                                    */
/*       END.                                                                                                                                                      */
/*   END.                                                                                                                                                          */
/*   FOR EACH tt-wth-gds ON ERROR UNDO save-block, RETURN ERROR RETURN-VALUE:                                                                                      */
/*       CREATE wth-gds.                                                                                                                                           */
/*       BUFFER-COPY tt-wth-gds TO wth-gds                                                                                                                         */
/*       ASSIGN wth-gds.wth-code = tt-wealth.wth-code.                                                                                                             */
/*   END.                                                                                                                                                          */
end. /* save-block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME