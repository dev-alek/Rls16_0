&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE temp-dis-rule NO-UNDO LIKE ub.dis-rule
       field old-des as character.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура копирования скидок по списку


Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-list-mode as character no-undo .
/*template rule-num {&g___object}*/
define input parameter p-rule-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура копирования скидок типа 22 в тип 8".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ gbl/userobjs.i }
{ gbl/disrules.i "work" }
{ ref/disgdsru.i }
DEFINE VARIABLE v-templ-rl-root AS INTEGER NO-UNDO.

define temp-table tt-dis-rule no-undo like ub.dis-rule.
define temp-table tt0-term_dis-rule no-undo like ub.dis-rule.
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-term-value-type   like ub.dis-rule.value-type        no-undo .
define variable  v-output-display as logical   no-undo . /* виден в броусе */
define variable  v-global         as integer no-undo .
define variable  v-host           as integer no-undo .
define variable  v-object         as integer no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other          as character no-undo . /* еще чего - нибудь */

define variable level as integer no-undo .
define variable v-start-level as integer   no-undo .
DEFINE VARIABLE lookup-option AS CHARACTER NO-UNDO.

define buffer loc_dis-rule for ub.dis-rule.
define buffer loc_clients for ub.clients.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dis-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-dis-rule temp-clients

/* Definitions for BROWSE BR-dis-rule                                   */
&Scoped-define FIELDS-IN-QUERY-BR-dis-rule temp-dis-rule.des ~
temp-dis-rule.rule-num temp-dis-rule.templ-rl-root temp-dis-rule.obj-type ~
temp-dis-rule.obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-rule temp-dis-rule.des
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-dis-rule temp-dis-rule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-dis-rule temp-dis-rule
&Scoped-define QUERY-STRING-BR-dis-rule FOR EACH temp-dis-rule NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-dis-rule OPEN QUERY BR-dis-rule FOR EACH temp-dis-rule NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-dis-rule temp-dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-rule temp-dis-rule


/* Definitions for BROWSE BR-objects                                    */
&Scoped-define FIELDS-IN-QUERY-BR-objects temp-clients.obj-type ~
temp-clients.obj-code temp-clients.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-objects
&Scoped-define QUERY-STRING-BR-objects FOR EACH temp-clients NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-objects OPEN QUERY BR-objects FOR EACH temp-clients NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-objects temp-clients
&Scoped-define FIRST-TABLE-IN-QUERY-BR-objects temp-clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-dis-rule}~
    ~{&OPEN-QUERY-BR-objects}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit T-dis-gds-rule B-Help cb-pos-type ~
B-dis-rule-add B-dis-rule-del b-lkp B-run BR-dis-rule B-objects-add ~
B-objects-delete BR-objects
&Scoped-Define DISPLAYED-OBJECTS T-dis-gds-rule cb-pos-type f-old-des

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-dis-rule-add
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-dis-rule-del
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-objects-add
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-objects-delete
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-run
     LABEL "&КОПИРОВАТЬ"
     SIZE 30 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cb-pos-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Место примен."
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-old-des AS CHARACTER FORMAT "X(256)":U
     LABEL "Ориг.опис-е"
     VIEW-AS FILL-IN NATIVE
     SIZE 85 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-dis-gds-rule AS LOGICAL INITIAL no
     LABEL "Копировать привязку скидки на товар"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dis-rule FOR
      temp-dis-rule SCROLLING.

DEFINE QUERY BR-objects FOR
      temp-clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-rule Dialog-Frame _STRUCTURED
  QUERY BR-dis-rule NO-LOCK DISPLAY
      temp-dis-rule.des FORMAT "X(255)":U WIDTH 60
      temp-dis-rule.rule-num FORMAT ">>>>>>>>9":U
      temp-dis-rule.templ-rl-root FORMAT ">,>>>,>>9":U
      temp-dis-rule.obj-type FORMAT "X(3)":U
      temp-dis-rule.obj-code FORMAT ">>>>>>>>9":U
  ENABLE
      temp-dis-rule.des
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.77
         TITLE "Правила скидок, с которых копируем (ОПИСАНИЯ МОЖНО ПОМЕНЯТЬ!!!)" FIT-LAST-COLUMN.

DEFINE BROWSE BR-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-objects Dialog-Frame _STRUCTURED
  QUERY BR-objects NO-LOCK DISPLAY
      temp-clients.obj-type FORMAT "X(3)":U
      temp-clients.obj-code COLUMN-LABEL "Код" FORMAT ">>>>>>>>9":U
      temp-clients.obj-name COLUMN-LABEL "Название" FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9
         TITLE "Объекты, на которые копируем" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     T-dis-gds-rule AT ROW 1 COL 24 WIDGET-ID 6
     B-Help AT ROW 1 COL 95
     cb-pos-type AT ROW 2.07 COL 76 COLON-ALIGNED WIDGET-ID 18
     B-dis-rule-add AT ROW 3 COL 1 WIDGET-ID 2
     B-dis-rule-del AT ROW 3 COL 11 WIDGET-ID 8
     b-lkp AT ROW 3 COL 21 WIDGET-ID 22
     B-run AT ROW 3 COL 31 WIDGET-ID 14
     BR-dis-rule AT ROW 4 COL 1 WIDGET-ID 100
     f-old-des AT ROW 12 COL 1 WIDGET-ID 20
     B-objects-add AT ROW 13 COL 1 WIDGET-ID 4
     B-objects-delete AT ROW 13 COL 11 WIDGET-ID 10
     BR-objects AT ROW 14 COL 1 WIDGET-ID 200
     SPACE(0.69) SKIP(0.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Копирование скидок".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-clients T "?" NO-UNDO ub clients
      TABLE: temp-dis-rule T "?" NO-UNDO ub dis-rule
      ADDITIONAL-FIELDS:
          field old-des as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-dis-rule B-run Dialog-Frame */
/* BROWSE-TAB BR-objects B-objects-delete Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-old-des IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-rule
/* Query rebuild information for BROWSE BR-dis-rule
     _TblList          = "Temp-Tables.temp-dis-rule"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > Temp-Tables.temp-dis-rule.des
"temp-dis-rule.des" ? ? "character" ? ? ? ? ? ? yes ? no no "60" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.temp-dis-rule.rule-num
     _FldNameList[3]   = Temp-Tables.temp-dis-rule.templ-rl-root
     _FldNameList[4]   = Temp-Tables.temp-dis-rule.obj-type
     _FldNameList[5]   = Temp-Tables.temp-dis-rule.obj-code
     _Query            is OPENED
*/  /* BROWSE BR-dis-rule */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-objects
/* Query rebuild information for BROWSE BR-objects
     _TblList          = "Temp-Tables.temp-clients"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   = Temp-Tables.temp-clients.obj-type
     _FldNameList[2]   > Temp-Tables.temp-clients.obj-code
"temp-clients.obj-code" "Код" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.temp-clients.obj-name
"temp-clients.obj-name" "Название" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-objects */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Копирование скидок */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-rule-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-rule-add Dialog-Frame
ON CHOOSE OF B-dis-rule-add IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN proc-b-dis-rule-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-rule-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-rule-del Dialog-Frame
ON CHOOSE OF B-dis-rule-del IN FRAME Dialog-Frame /* Удалить */
DO:


  RUN proc-b-dis-rule-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF NOT AVAILABLE temp-dis-rule THEN DO:
    BELL.
    RETURN NO-APPLY.
  END.
  run ref/show-dr.p ( input parparentproc
                    ,INPUT temp-dis-rule.rule-num) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-objects-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-objects-add Dialog-Frame
ON CHOOSE OF B-objects-add IN FRAME Dialog-Frame /* Добавить */
DO:
    RUN proc-b-objects-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-objects-delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-objects-delete Dialog-Frame
ON CHOOSE OF B-objects-delete IN FRAME Dialog-Frame /* Удалить */
DO:
    RUN proc-b-objects-delete IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-run
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-run Dialog-Frame
ON CHOOSE OF B-run IN FRAME Dialog-Frame /* КОПИРОВАТЬ */
DO:
    ASSIGN
    t-dis-gds-rule
    cb-pos-type
    .
    if lookup(cb-pos-type, {&cd-type-codes}) = 0
    then do:
      message
      "Не заполнено место применения скидок"
      view-as alert-box error .
      undo, return no-apply.
    end.
    RUN proc-b-run IN THIS-PROCEDURE NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dis-rule
&Scoped-define SELF-NAME BR-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dis-rule Dialog-Frame
ON VALUE-CHANGED OF BR-dis-rule IN FRAME Dialog-Frame /* Правила скидок, с которых копируем (ОПИСАНИЯ МОЖНО ПОМЕНЯТЬ!!!) */
DO:
  IF AVAILABLE temp-dis-rule THEN DO:
      DISPLAY
      temp-dis-rule.old-des @ f-old-des
      WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      DISPLAY
      '' @ f-old-des
      WITH FRAME {&FRAME-NAME}.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

ON leave OF temp-dis-rule.des IN BROWSE br-dis-rule
DO:
   IF AVAILABLE temp-dis-rule  THEN DO:
       DEFINE BUFFER buf_temp-dis-rule FOR temp-dis-rule.
       FIND FIRST buf_temp-dis-rule WHERE
                RECID(buf_temp-dis-rule) = RECID(temp-dis-rule).
       ASSIGN
       buf_temp-dis-rule.des = temp-dis-rule.des:SCREEN-VALUE IN BROWSE br-dis-rule.
       {&OPEN-QUERY-br-dis-rule}
       REPOSITION br-dis-rule TO RECID RECID(buf_temp-dis-rule).
       APPLY "entry" to BROWSE br-dis-rule.

   END.
END.
{ gbl/hot-key.i b-lkp }
&scop b-dis-rule-add ~{&b-add~}
{ gbl/hot-key.i b-dis-rule-add  }
&scop b-dis-rule-del ~{&b-del~}
{ gbl/hot-key.i b-dis-rule-del  }


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    v-start-level = 2
  .

  assign
    level = v-start-level
  .
  repeat while program-name(level) <> ?:
    if program-name(level) = this-procedure:file-name then do:
      message
      "Вы уже находитесь в режиме копирования скидок"
      view-as alert-box error .
      undo, return error .
    end.
    assign
    level = level + 1
    .
  end.
  { gbl/getcntxt.i GET }
  if lookup(p-list-mode, "template" + {&comma-char} +
                          "rule-num" + {&comma-char} +
                          {&g___object}) = 0 then do:
    message
    substitute("Неверное значение параметра вызова p-list-mode = &1", p-list-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  case p-list-mode:
     when "template" then do:
       v-templ-rl-root = p-rule-num.
     end.
     when "rule-num" then do:
       find first loc_dis-rule no-lock where
                  loc_dis-rule.rule-num = p-rule-num no-error.
       if not available loc_dis-rule then do:
          message
          substitute("Неверное значение параметра вызова p-rule-num = &1", p-rule-num)
          view-as alert-box error .
          undo main-block, return error .
       end.
      if loc_dis-rule.sts <> integer({&used-status-int}) then do:
        &scop used-status-code string(loc_dis-rule.sts)
        message
        substitute("Правило &1 находится в статусе &2, поэтому не может быть скопировано на другие объекты!"
                  , loc_dis-rule.rule-num
                  , {&used-status-int-name})
        view-as alert-box error .
        undo main-block, return error .
      end.

       create temp-dis-rule.
       buffer-copy loc_dis-rule to temp-dis-rule
       assign
       temp-dis-rule.old-des = loc_dis-rule.des
       .
       release temp-dis-rule.
     end.
     when {&g___object} then do:
       find first loc_clients no-lock where
                  loc_clients.obj-type = p-obj-type
               and loc_clients.obj-code = p-obj-code no-error.
       if not available loc_clients then do:
          message
          substitute("Неверное значение параметра вызова p-obj-type = &1 и/или p-obj-code = &2", p-obj-type, p-obj-code)
          view-as alert-box error .
          undo main-block, return error .
       end.
     end.
  end case.

  RUN Myenable.
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
  DISPLAY T-dis-gds-rule cb-pos-type f-old-des
      WITH FRAME Dialog-Frame.
  ENABLE b-quit T-dis-gds-rule B-Help cb-pos-type B-dis-rule-add
         B-dis-rule-del b-lkp B-run BR-dis-rule B-objects-add
         B-objects-delete BR-objects
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
define variable v-jj as integer no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
DO v-ii = 1 TO NUM-ENTRIES({&cd-type-codes-discnt}):
  if p-list-mode = "template" then do:
    find first buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.templ-rl-root =  p-rule-num
          and buf_dis-cfg-rule.pos-type =  ENTRY(v-ii, {&cd-type-codes-discnt})
              no-error.
    if not available buf_dis-cfg-rule then next.
  end.
  if p-list-mode = "rule-num" then do:
    find first temp-dis-rule.
    find first buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.templ-rl-root = temp-dis-rule.templ-rl-root
          and buf_dis-cfg-rule.pos-type =  ENTRY(v-ii, {&cd-type-codes-discnt})
              no-error.
    if not available buf_dis-cfg-rule then next.
  end.
  v-jj = v-jj + 1.
  ASSIGN
  v-list-items = v-list-items + (IF v-jj > 1 THEN  {&comma-char} ELSE "":U) +
                  ENTRY(v-ii, {&cd-type-codes-full}) + {&comma-char} +
                  ENTRY(v-ii, {&cd-type-codes}).
END.
assign
cb-pos-type:list-item-pairs in frame {&frame-name} = v-list-items
temp-dis-rule.des:RESIZABLE IN BROWSE br-dis-rule = YES
.
DISPLAY
T-dis-gds-rule
WITH FRAME {&FRAME-NAME}.
ENABLE
b-quit
T-dis-gds-rule
B-run
B-Help
B-dis-rule-add
B-dis-rule-del
cb-pos-type
BR-dis-rule
B-objects-add
B-objects-delete
b-lkp
BR-objects
WITH FRAME {&FRAME-NAME}.
case p-list-mode:
  when {&g___object} then do:
    assign
    frame {&frame-name}:title = substitute("Копирование скидок, действующих на &1&2 на другие объекты по списку"
                                           , p-obj-type
                                           , p-obj-code).
  end.
  when "rule-num" then do:
    assign
    frame {&frame-name}:title = substitute("Копирование скидки &1 на другие объекты по списку"
                                           , p-rule-num
                                           ).
  end.
  when "template" then do:
    assign
    frame {&frame-name}:title = substitute("Копирование скидок  по шаблону &1 на другие объекты по списку"
                                           , p-rule-num
                                           ).
  end.
end case.
VIEW FRAME {&FRAME-NAME}.
if p-list-mode = "template" then do:
  find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root =  p-rule-num
        and buf_dis-cfg-rule.table-name =  {&table_dis-gds-rule}
            no-error.
  if not available buf_dis-cfg-rule then do:
    hide
    t-dis-gds-rule
    in frame {&frame-name} .

  end.
end.
if p-list-mode = "rule-num" then do:
  find first temp-dis-rule.
  find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = temp-dis-rule.templ-rl-root
         and buf_dis-cfg-rule.table-name =  {&table_dis-gds-rule}
            no-error.
  if not available buf_dis-cfg-rule then do:
    hide
    t-dis-gds-rule
    in frame {&frame-name} .
  end.
end.


{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "ENTRY" TO br-dis-rule.
APPLY "value-changed" TO br-dis-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-dis-rule-add Dialog-Frame
PROCEDURE proc-b-dis-rule-add :
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rid-list as character NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-host-code as integer no-undo .
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
DEFINE BUFFER buf_temp-dis-rule FOR temp-dis-rule.
if p-list-mode = {&g___Object} then do:
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  run ref/dis-ruls.w (
                input parparentproc
              , input v-host-code
              , input p-obj-type
              , input p-obj-code
              , input "b-sel,b-mark":U
              , input {&g___object}
              , input 0       /*p-upper-rule-num*/
              , input -1 /*p-time-templ-rl-root*/
              , input 0 /*p-r-b-code*/
              , input-output v-sts
              , input-output v-rid-list ) no-error .
end.
if p-list-mode = "template" then do:
  run ref/dis-ruls.w (
              input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code
              ,input "b-sel,b-mark":U
              ,input "upper-rule-num":U
              ,input v-templ-rl-root
              ,input -1 /*p-time-templ-rl-root*/
              ,input 0 /*r-b-code*/
              ,input-output v-sts
              ,input-output v-rid-list ) no-error .
end.
IF ERROR-STATUS:ERROR OR v-rid-list = '' THEN UNDO, RETURN ERROR.
_do:
DO v-ii = 1 TO NUM-ENTRIES(v-rid-list):
   FIND FIRST buf_dis-rule NO-LOCK WHERE
            RECID(buf_dis-rule) = INTEGER(ENTRY(v-ii, v-rid-list)) NO-ERROR.
   IF AVAILABLE buf_dis-rule THEN DO:
     if not (buf_dis-rule.obj-type = {&stock}
             or
             buf_dis-rule.obj-type = {&shop}) then do:
       message
       substitute("Правило &1 не привязано к объекту, поэтому не может быть скопировано на другие объекты!", buf_dis-rule.rule-num)
       view-as alert-box error .
       next _do.
     end.
    if buf_dis-rule.sts <> integer({&used-status-int}) then do:
       &scop used-status-code string(buf_dis-rule.sts)
       message
       substitute("Правило &1 находится в статусе &2, поэтому не может быть скопировано на другие объекты!"
                , buf_dis-rule.rule-num
                , {&used-status-int-name})
       view-as alert-box error .
       next _do.
     end.
     FIND FIRST buf_temp-dis-rule NO-LOCK WHERE
                  buf_temp-dis-rule.rule-num = buf_dis-rule.rule-num NO-ERROR.
      IF NOT AVAILABLE buf_temp-dis-rule THEN DO:
          CREATE buf_temp-dis-rule.
          BUFFER-COPY buf_dis-rule TO buf_temp-dis-rule
          ASSIGN
          buf_temp-dis-rule.old-des = buf_dis-rule.des
              .
    END.
  END.
END.
{&OPEN-QUERY-br-dis-rule}
APPLY "ENTRY" TO br-dis-rule IN FRAME {&FRAME-NAME}.
APPLY "value-changed" TO br-dis-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-dis-rule-del Dialog-Frame
PROCEDURE proc-b-dis-rule-del :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_temp-dis-rule FOR temp-dis-rule.
IF NOT AVAILABLE temp-dis-rule THEN RETURN .
MESSAGE
"Вы действительно хотите удалить правило скидки из списка??"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN UNDO, RETURN.
FIND FIRST buf_temp-dis-rule WHERE
           recid(buf_temp-dis-rule) = RECID(temp-dis-rule) .
DELETE buf_temp-dis-rule.
{&OPEN-QUERY-br-dis-rule}
APPLY "ENTRY" TO br-dis-rule IN FRAME {&FRAME-NAME}.
APPLY "value-changed" TO br-dis-rule.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-objects-add Dialog-Frame
PROCEDURE proc-b-objects-add :
DEFINE VARIABLE v-rid-list as character NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-user-select as logical   no-undo .
DEFINE BUFFER buf_temp-clients FOR temp-clients.
define buffer buf_clients for ub.clients.
{ gbl/uobjclr.i  }

for each buf_temp-clients:
{ gbl/uobjapnd.i
  buf_temp-clients.obj-type
  buf_temp-clients.obj-code
}
end.
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
    "Объекты не выбраны"
    view-as alert-box information .
  return NO-APPLY .
end.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

for each buf_userobjs_temp-user-obj
on error undo, return no-apply
:
  find first buf_temp-clients  where
             buf_temp-clients.obj-type = buf_userobjs_temp-user-obj.obj-type
         and buf_temp-clients.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.
  if not available buf_temp-clients then do:
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
           and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code .
    create buf_temp-clients.
    buffer-copy buf_clients to buf_temp-clients.

  end.
end.

{&OPEN-QUERY-br-objects}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-objects-delete Dialog-Frame
PROCEDURE proc-b-objects-delete :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_temp-clients FOR temp-clients.
IF NOT AVAILABLE temp-clients THEN RETURN .
MESSAGE
"Вы действительно хотите удалить объект из списка??"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN UNDO, RETURN.
FIND FIRST buf_temp-clients WHERE
           recid(buf_temp-clients) = RECID(temp-clients) .
DELETE buf_temp-clients.
{&OPEN-QUERY-br-objects}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-run Dialog-Frame
PROCEDURE proc-b-run :
DEFINE VARIABLE v-parameter AS CHARACTER NO-UNDO.
define  BUFFER buf_temp-dis-rule FOR temp-dis-rule.
define  BUFFER buf_temp-clients FOR temp-clients.
FIND FIRST buf_temp-dis-rule NO-ERROR.
IF NOT AVAILABLE buf_temp-dis-rule THEN DO:
  MESSAGE
  "Не выбрано ни одного правила скидки-оригинала для копирования"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN.

END.
FIND FIRST buf_temp-clients NO-ERROR.
IF NOT AVAILABLE buf_temp-clients THEN DO:
  MESSAGE
  "Не выбрано ни одного объекта-назначения для копирования"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN.
END.
ASSIGN
v-parameter = STRING(t-dis-gds-rule) + {&delim-par} +
              cb-pos-type
              .
run str/diallog.w ( input parparentproc
            , input this-procedure
            , input ('proc-copy':U + {&delim-par} +
                    "1" + {&delim-par} +
                    "0" + {&delim-par} +
                    "1" + {&delim-par} +
                    "1" + {&delim-par} +
                    "yes")
            , input v-parameter
            , input NO /*p-auto-go*/
            , input 'Прервать'
            , input 'Копирование скидок') no-error .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy Dialog-Frame
PROCEDURE proc-copy :
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.


DEFINE VARIABLE V-DIS-GDS-RULE   AS LOGICAL   NO-UNDO.
define variable v-cd-type        as character no-undo .
define variable LOG-FILE-NAME    as character no-undo .
define variable v-dr-ii          as integer   no-undo .
define variable v-dr-ii-ok       as integer   no-undo .
define variable v-dgr-ii         as integer   no-undo .
define variable v-dgr-ii-ok      as integer   no-undo .
define variable v-loc-dgr-ii     as integer   no-undo .
define variable v-loc-dgr-ii-ok  as integer   no-undo .
define variable v-rule-num-count as integer   no-undo .
define variable v-rule-num       as integer   no-undo .
define variable v-upper-rule-num as integer   no-undo .
define variable v-err-cnt        as integer   no-undo init 0 .

define variable v-recid as recid     no-undo .
define variable glog    as logical   no-undo .
define variable dflt-cd as character no-undo .

define variable v-add-upd as logical no-undo .
define variable v-do-it   as logical no-undo init yes .

define buffer buf_temp-dis-rule for temp-dis-rule .
define buffer buf_temp-clients  for temp-clients .
define buffer term_dis-rule     for ub.dis-rule .
define buffer trg_dis-rule      for ub.dis-rule .
define buffer src_dis-rule      for ub.dis-rule .
define buffer src_dis-gds-rule  for ub.dis-gds-rule .
define buffer buf_dis-cfg-rule  for ub.dis-cfg-rule .
define buffer buf_dis-rule      for ub.dis-rule .
define buffer buf_tt0           for tt0-term_dis-rule .

define buffer src_dis-gds-rule-attr for ub.dis-gds-rule-attr .
define buffer trg_dis-gds-rule-attr for ub.dis-gds-rule-attr .

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-message-laud  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

if num-entries(p-parameter, {&delim-par}) <> 2
then do:
  MESSAGE substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 2"
                             , num-entries(p-parameter, {&delim-par}))
  VIEW-AS ALERT-BOX ERROR
  .
  RETURN error.
end.
ASSIGN
V-DIS-GDS-RULE = LOGICAL(ENTRY(1, P-PARAMETER, {&delim-par} ))
v-cd-type = entry(2, p-parameter, {&delim-par} )
.
LOG-file-name = substitute("&1.txt", entry(1, this-procedure:file-name, ".")).
log-file-name = entry( num-entries(log-file-name, {&slash-char}), log-file-name, {&slash-char}).

for each tt0-term_dis-rule:
  delete tt0-term_dis-rule.
end.
for each tt-dis-rule:
  delete tt-dis-rule.
end.

create tt0-term_dis-rule.
_temp-dis-rule:
for each buf_temp-dis-rule:
  if buf_temp-dis-rule.sts <> integer({&used-status-int}) then do:
     &scop used-status-code string(buf_temp-dis-rule.sts)
     &scop my-message  substitute("Нельзя копировать правило в статусе &1", ~{&used-status-int-name~})
     {&display-message}.
     assign
       v-dr-ii = v-dr-ii + 1
       v-err-cnt = v-err-cnt + 1 .
  end.
  /*
  if buf_temp-dis-rule.obj-type = ''
  or not (buf_temp-dis-rule.obj-type = {&shop}
          or
          buf_temp-dis-rule.obj-type = {&stock}) then do:
     &scop my-message  substitute("Нельзя копировать правило, которое действует &1" ~
                               , get-region( buf_temp-dis-rule.host-code,  buf_temp-dis-rule.obj-type, buf_temp-dis-rule.obj-code))
     {&display-message}.
     assign
       v-dr-ii = v-dr-ii + 1
       v-err-cnt = v-err-cnt + 1 .
   end.
  */
  run disrules-fill-properties in this-procedure ( input buf_temp-dis-rule.templ-rl-root).
  FIND FIRST buf_dis-cfg-rule NO-LOCK where
            buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
        and buf_dis-cfg-rule.templ-rl-root = buf_temp-dis-rule.templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = buf_temp-dis-rule.time-templ-rl-root
        and buf_dis-cfg-rule.pos-type = v-cd-type
        no-error
         .
  _temp-clients:
  for each buf_temp-clients :
    if not (v-cd-type = {&cd-type-bo} or v-cd-type = {&cd-type-no-cd}) and
       not buf_temp-clients.obj-type = {&cmp}
    then do:
      if buf_temp-clients.obj-type = {&stock} then do:
        &scop my-message substitute("Нельзя скопировать правила скидки на объект &1&2"  ~
                                    , buf_temp-clients.obj-type ~
                                    , buf_temp-clients.obj-code ~
                                    )
        {&display-message}.
        assign
          v-dr-ii = v-dr-ii + 1
          v-err-cnt = v-err-cnt + 1 .
        next _temp-clients.
      end.
      dflt-cd = ''.
      { gbl/dflt-cd.i buf_temp-clients.obj-type buf_temp-clients.obj-code dflt-cd }
      if dflt-cd <> v-cd-type then do:
        &scop my-message substitute("Нельзя скопировать правила скидки на объект &1&2&3" + ~
                                    "На нем работает POS типа &4" ~
                                    , buf_temp-clients.obj-type ~
                                    , buf_temp-clients.obj-code ~
                                    , ~{&new-line~} ~
                                    , dflt-cd)
        {&display-message}.
        assign
          v-dr-ii = v-dr-ii + 1
          v-err-cnt = v-err-cnt + 1 .
        next _temp-clients.
      end.
    end.
    for each tt-dis-rule:
      delete tt-dis-rule.
    end.

    create tt-dis-rule.
    assign
    tt-dis-rule.des = buf_temp-dis-rule.des
    tt-dis-rule.host-code          = ( if buf_temp-clients.host-code = ? then buf_temp-clients.obj-code  else buf_temp-clients.host-code ) /*buf_temp-dis-rule.host-code*/
    tt-dis-rule.obj-type           = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.obj-type else buf_temp-clients.obj-type )
    tt-dis-rule.obj-code           = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.obj-code else buf_temp-clients.obj-code )
    tt-dis-rule.discnt-type        = buf_temp-dis-rule.discnt-type
    tt-dis-rule.discnt-value       = buf_temp-dis-rule.discnt-value
    tt-dis-rule.time-rule-num      = buf_temp-dis-rule.time-rule-num
    tt-dis-rule.time-templ-rl-root = buf_temp-dis-rule.time-templ-rl-root
    tt-dis-rule.tot-sum            = buf_temp-dis-rule.tot-sum
    tt-dis-rule.sts                = buf_temp-dis-rule.sts
    tt-dis-rule.doc-qnty           = buf_temp-dis-rule.doc-qnty
    .
    /*Здесь ищем тип правила привязанного к указанному объекту*/
    find first buf_dis-rule no-lock where
              /*buf_dis-rule.des = tt-dis-rule.des*/
              buf_dis-rule.discnt-type        = tt-dis-rule.discnt-type
          and buf_dis-rule.discnt-value       = tt-dis-rule.discnt-value
          and buf_dis-rule.time-rule-num      = tt-dis-rule.time-rule-num
          and buf_dis-rule.time-templ-rl-root = tt-dis-rule.time-templ-rl-root
          and buf_dis-rule.tot-sum            = tt-dis-rule.tot-sum
          and buf_dis-rule.sts                = tt-dis-rule.sts
          and buf_dis-rule.doc-qnty           = tt-dis-rule.doc-qnty

          and buf_dis-rule.host-code = tt-dis-rule.host-code
          and buf_dis-rule.obj-type = tt-dis-rule.obj-type
          and buf_dis-rule.obj-code = tt-dis-rule.obj-code
          and buf_dis-rule.templ-rl-root = buf_temp-dis-rule.templ-rl-root
          and buf_dis-rule.root = yes no-error.
    if available buf_dis-rule then do:
      /*message
      substitute("Найдено правило скидки &1&2 на &3&4 c типом &5&2" +
                 "все равно копировать??"
                 , buf_dis-rule.des
                 , {&new-line}
                 , buf_dis-rule.obj-type
                 , buf_dis-rule.obj-code
                 , buf_dis-rule.templ-rl-root)
      view-as alert-box question buttons yes-no update glog.
      if not glog then next _temp-clients.*/
      assign
        v-add-upd = false
        v-upper-rule-num = buf_dis-rule.rule-num
        v-recid = recid(buf_dis-rule)
      .
    end.
    else do:
      v-add-upd = true .
    end.
    buffer-copy buf_temp-dis-rule
    except des
    host-code
    obj-type
    obj-code
    to tt-dis-rule .
    for each tt0-term_dis-rule:
        delete tt0-term_dis-rule .
    end.
    v-rule-num-count = 0 .
    /*Тут список конкретных правил для данного объекта*/
    for each term_dis-rule no-lock
    where term_dis-rule.upper-rule-num = buf_temp-dis-rule.rule-num :
        v-rule-num-count = v-rule-num-count + 1.
        create tt0-term_dis-rule.
        buffer-copy term_dis-rule
        except host-code obj-type obj-code
        rule-num upper-rule-num rl-root
        to tt0-term_dis-rule
        assign
        tt0-term_dis-rule.host-code      = buf_temp-clients.host-code
        tt0-term_dis-rule.obj-type       = buf_temp-clients.obj-type
        tt0-term_dis-rule.obj-code       = buf_temp-clients.obj-code
        tt0-term_dis-rule.rule-num       = v-rule-num-count
        tt0-term_dis-rule.upper-rule-num = (if v-add-upd then buf_temp-dis-rule.templ-rl-root else v-upper-rule-num)
        tt0-term_dis-rule.rl-root        = buf_temp-dis-rule.templ-rl-root
        .
        release tt0-term_dis-rule.
    end.
    if not v-add-upd then do:
      find first tt0-term_dis-rule no-lock no-error .
      find first buf_dis-rule no-lock where
              buf_dis-rule.host-code      = tt0-term_dis-rule.host-code
          and buf_dis-rule.obj-type       = tt0-term_dis-rule.obj-type
          and buf_dis-rule.obj-code       = tt0-term_dis-rule.obj-code
          and buf_dis-rule.templ-rl-root  = tt0-term_dis-rule.templ-rl-root
          and buf_dis-rule.root           = false
          and buf_dis-rule.upper-rule-num = tt0-term_dis-rule.upper-rule-num
      no-error.
      if avail buf_dis-rule then do:
          assign
            tt0-term_dis-rule.rule-num = buf_dis-rule.rule-num
          .
      end.

      else do:
         /*если не найдено, то надо сделать буфферкопи из tt0, расчитать и присвоить rule-num*/
         run gen-b-code in this-procedure ( input {&gbl-dr-code}, output v-rule-num) no-error .
         if error-status:error then do:
              &scop my-message substitute("Не удалось скопировать правило скидки &1 (gen-b-code) на &2&3&4&5&4&6" ~
                                            , buf_temp-dis-rule.rule-num ~
                                            , buf_temp-clients.obj-type ~
                                            , buf_temp-clients.obj-code  ~
                                            , ~{&new-line~} ~
                                            , error-status:get-message(1)  ~
                                            , return-value )
              {&display-message}.
              assign
                v-dr-ii = v-dr-ii + 1
                v-err-cnt = v-err-cnt + 1 .
              next _temp-clients.
         end.
         find first buf_tt0 no-lock no-error.
         if avail buf_tt0 then do:
             create buf_dis-rule.
             buffer-copy buf_tt0
             except rule-num
             to buf_dis-rule
             assign
             buf_dis-rule.rule-num = v-rule-num
             buf_tt0.rule-num = v-rule-num
             .
         end.
         else do:
            /*Правило нашли, но подправил нет, значит не копируем, а сразу привязываем товар.*/
            v-do-it = false .
            /*return error.*/
         end.
      end.

    end.
    /*номер правила для временнЫх скидок*/
    find first buf_tt0 no-lock no-error.
    if avail buf_tt0 and buf_tt0.time-templ-rl-root > 0 then do:
      assign
        tt-dis-rule.time-rule-num = buf_tt0.time-rule-num
      .
    end.

    v-dr-ii = v-dr-ii + 1.

    if v-do-it then do:
        run ref/dis-rul1.p (
        input (if v-add-upd then ? else v-upper-rule-num)
        ,input v-cd-type
        ,input buf_temp-dis-rule.templ-rl-root
        ,input buf_temp-dis-rule.templ-rl-root
        ,input buf_temp-dis-rule.des
        ,input tt-dis-rule.dis-kat
        ,input tt-dis-rule.discnt-type
        ,input tt-dis-rule.doc-qnty
        ,input tt-dis-rule.tot-sum
        ,input tt-dis-rule.charkey_one
        ,input tt-dis-rule.charkey_two
        ,input tt-dis-rule.charkey_three
        ,input tt-dis-rule.deckey_one
        ,input tt-dis-rule.deckey_two
        ,input tt-dis-rule.deckey_three
        ,input tt-dis-rule.key#_one
        ,input tt-dis-rule.key#_two
        ,input tt-dis-rule.key#_three
        ,input tt-dis-rule.subject-type
        ,input tt-dis-rule.time-templ-rl-root
        ,input (if tt-dis-rule.time-templ-rl-root = 0 then 0 else tt-dis-rule.time-rule-num)
        ,input tt-dis-rule.upper-rule-num
        ,input tt-dis-rule.value-type
        ,input tt-dis-rule.host-code
        ,INPUT tt-dis-rule.obj-type
        ,INPUT tt-dis-rule.obj-code
        ,INPUT tt-dis-rule.discnt-value
        ,input table tt0-term_dis-rule
        ,input-output v-recid
        ,input (if v-add-upd then {&add-def} else {&update})
        ,input yes /*p-silent */
        ) NO-ERROR.
        if error-status:error then do:
          &scop my-message substitute("Не удалось скопировать правило скидки &1 на &2&3&4&5&4&6" ~
                                        , buf_temp-dis-rule.rule-num ~
                                        , buf_temp-clients.obj-type ~
                                        , buf_temp-clients.obj-code  ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1)  ~
                                        , return-value )
          {&display-message}.
          assign
            v-dr-ii = v-dr-ii + 1
            v-err-cnt = v-err-cnt + 1
          .
          next _temp-clients.
        end.
    end.

    assign
      v-do-it = true
      v-dr-ii-ok = v-dr-ii-ok + 1
    .
    if v-dis-gds-rule then do:
        assign
          v-loc-dgr-ii = 0
          v-loc-dgr-ii-ok = 0
        .
        find first trg_dis-rule no-lock
        where recid(trg_dis-rule) = v-recid no-error.
        if available buf_dis-cfg-rule then do:
            for each src_dis-gds-rule no-lock
            where src_dis-gds-rule.obj-type = ( if buf_temp-clients.host-code = ? then {&cmp}                      else buf_temp-dis-rule.obj-type )
              and src_dis-gds-rule.obj-code = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.host-code else buf_temp-dis-rule.obj-code )
              and src_dis-gds-rule.rule-num = buf_temp-dis-rule.rule-num
              and src_dis-gds-rule.pos-type = v-cd-type :
                assign
                  v-dgr-ii = v-dgr-ii + 1
                  v-loc-dgr-ii = v-loc-dgr-ii + 1
                .
                /*для фирменных правил*/
                if buf_temp-clients.host-code = ? then do:
                    run cmp-disgdsru-write in this-procedure (
                                                         input src_dis-gds-rule.gds-code
                                                        ,input {&cmp}
                                                        ,input trg_dis-rule.host-code
                                                        ,input v-cd-type
                                                        ,input trg_dis-rule.templ-rl-root
                                                        ,input src_dis-gds-rule.time-templ-rl-root
                                                        ,input buf_dis-cfg-rule.discnt-role
                                                        ,input trg_dis-rule.rule-num
                                                        ,input src_dis-gds-rule.nonunique
                                                       )  no-error.
                end.
                else do: /*для объектов*/
                run disgdsru-write in this-procedure ( input buf_temp-clients.obj-type
                                                      ,input buf_temp-clients.obj-code
                                                      ,input src_dis-gds-rule.gds-code
                                                      ,input v-cd-type
                                                      ,input buf_dis-cfg-rule.discnt-role
                                                      ,input trg_dis-rule.templ-rl-root
                                                      ,input src_dis-gds-rule.time-templ-rl-root /*,input trg_dis-rule.time-templ-rl-root*/
                                                      ,input trg_dis-rule.rule-num
                                                      ,input src_dis-gds-rule.nonunique          /*,input buf_dis-cfg-rule.nonunique*/
                )  no-error.
                end.
                if error-status :error then do:
                    &scop my-message substitute("Не удалось привязать правило скидки &1 к товару с кодом &2 на &3&4&5&6&5&7" ~
                        , trg_dis-rule.rule-num ~
                        , src_dis-gds-rule.gds-code ~
                        , buf_temp-clients.obj-type ~
                        , buf_temp-clients.obj-code  ~
                        , ~{&new-line~} ~
                        , error-status:get-message(1)  ~
                        , return-value )

                    {&display-message} .
                    assign
                      v-dr-ii = v-dr-ii + 1
                      v-err-cnt = v-err-cnt + 1
                    .
                end.
                else do:
                    /*Для бонусов*/
                    if buf_dis-cfg-rule.discnt-role = 'bonus-qnty' and
                       buf_dis-cfg-rule.nonunique   = 'bar-code.b-code'
                    then do:
                        for each src_dis-gds-rule-attr no-lock
                        where src_dis-gds-rule-attr.gds-code    = src_dis-gds-rule.gds-code
                          and src_dis-gds-rule-attr.obj-type    = src_dis-gds-rule.obj-type       /*parobj-type*/
                          and src_dis-gds-rule-attr.obj-code    = src_dis-gds-rule.obj-code       /*parobj-code*/
                          and src_dis-gds-rule-attr.pos-type    = v-cd-type
                          and src_dis-gds-rule-attr.discnt-role = buf_dis-cfg-rule.discnt-role
                          and src_dis-gds-rule-attr.nonunique   = src_dis-gds-rule.nonunique
                        :
                            find first trg_dis-gds-rule-attr exclusive-lock
                            where trg_dis-gds-rule-attr.gds-code    = src_dis-gds-rule.gds-code
                              and trg_dis-gds-rule-attr.obj-type    = ( if buf_temp-clients.host-code = ? then {&cmp}                 else buf_temp-clients.obj-type )
                              and trg_dis-gds-rule-attr.obj-code    = ( if buf_temp-clients.host-code = ? then trg_dis-rule.host-code else buf_temp-clients.obj-code )
                              and trg_dis-gds-rule-attr.pos-type    = v-cd-type
                              and trg_dis-gds-rule-attr.discnt-role = buf_dis-cfg-rule.discnt-role
                              and trg_dis-gds-rule-attr.nonunique   = src_dis-gds-rule.nonunique
                              and trg_dis-gds-rule-attr.attr-value  = src_dis-gds-rule-attr.attr-value
                            no-error.
                            if not avail trg_dis-gds-rule-attr then do:
                                create trg_dis-gds-rule-attr .
                                buffer-copy src_dis-gds-rule-attr
                                except obj-type obj-code
                                to trg_dis-gds-rule-attr
                                assign
                                  trg_dis-gds-rule-attr.obj-type = ( if buf_temp-clients.host-code = ? then {&cmp}                 else buf_temp-clients.obj-type )
                                  trg_dis-gds-rule-attr.obj-code = ( if buf_temp-clients.host-code = ? then trg_dis-rule.host-code else buf_temp-clients.obj-code )
                                .
                            end.
                        end. /*for each src_dis-gds-rule-attr*/
                    end.
                    assign
                      v-dgr-ii-ok = v-dgr-ii-ok + 1
                      v-loc-dgr-ii-ok = v-loc-dgr-ii-ok + 1
                    .
                end.
            end. /*for each src_dis-gds-rule no-lock where*/
        end.
    end. /*if v-dis-gds-rule then do:*/

    if v-dis-gds-rule then do:
      &scop my-count-message substitute("Пр. скидок: OK &1 из &2, привязки: OK &3 из &4", v-dr-ii-ok, v-dr-ii, v-dgr-ii-ok, v-dgr-ii)
      {&display-count-message} .
    end.
    else do:
      &scop my-count-message substitute("Пр. скидок: OK &1 из &2", v-dr-ii-ok, v-dr-ii)
      {&display-count-message} .
    end.
  end. /*for each buf_temp-clients where*/
  if v-dis-gds-rule  then do:
    &scop my-message substitute("привязки Правила &1: OK &2 из &3", buf_temp-dis-rule.rule-num, v-loc-dgr-ii, v-loc-dgr-ii-ok)
    {&display-message}.
  end.
  end. /*for each buf_temp-dis-rule:*/
if v-dis-gds-rule then do:
  &scop my-message substitute("Пр. скидок: OK &1 из &2, привязки: OK &3 из &4", v-dr-ii-ok, v-dr-ii, v-dgr-ii-ok, v-dgr-ii)
  {&display-message}.
end.
else do:
  &scop my-message substitute("Пр. скидок: OK &1 из &2", v-dr-ii-ok, v-dr-ii)
  {&display-message}.
end.
&scop my-message substitute("Копирование закончено")
{&display-message}.
{&display-count-message}.

/*Если в процессе были ошибки, то возвращаем ошибку, чтобы просмотрели лог файл.*/
if v-err-cnt > 0 then do:
    return error.
end.
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME