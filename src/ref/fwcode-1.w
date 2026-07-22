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

Справочник Корреспондирующие счета

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 10/07/03 3:57

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter bttns  as char   no-undo .
define input parameter par-mode  as char   no-undo .
define input parameter pardoc-rec as recid no-undo.
define input parameter par-host-code like ub.clients.obj-code no-undo.
define output param rid-list    as  char no-undo . /* список recid'ов выбранных */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " Справочник фин.кодов   ".
{ cmp/vssrevis.i }


/* Local Variable Definitions ---                                       */
define variable g#log as logical no-undo .
define variable doc-rec as recid no-undo .
define variable g#report-num as integer no-undo .

{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }
{ cmp/mrk-strf.i }

&Scoped-Define main-file ub.fin-code-cor-acc
&SCOPED-DEFINE status-code STRING(buf_fin-code.status_ )

define variable t-a as char no-undo.
define variable t-s as char no-undo.
define variable filter-point as character no-undo init "Справочник фин.кодов" .
define variable filter-point0 as character no-undo init "Фин_справочники_" .
define variable sort-column-name as character no-undo .
define variable print-type as character no-undo.
define variable del-type as character no-undo.
define variable deleted as logical no-undo init no.
DEFINE VARIABLE change-type as character init "" no-undo .

define variable  br-handle as handle no-undo.
define variable v-main-firm-db as integer no-undo init -1.
define buffer X_sysconf for ub.sysconf.

define buffer find_code for {&main-file} .
DEFINE BUFFER buf_fin-code FOR {&main-file}.

define variable p-sts as integer no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fin-code

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs mark-string(recid( ub.buf_fin-code), rid-list) buf_fin-code.code-value sel-type(recid( ub.buf_fin-code)) @ t-a buf_fin-code.descr buf_fin-code.fin-code buf_fin-code.host-code {&status-int-name} @ t-s buf_fin-code.level-1 "Уровень1" buf_fin-code.level-2 "Уровень2" buf_fin-code.level-3 "Уровень3"
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs buf_fin-code.code-value
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-docs buf_fin-code
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-docs buf_fin-code
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH buf_fin-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-docs buf_fin-code
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs buf_fin-code


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-mark B-sel B-add B-lkp B-chg B-del ~
B-firm B-copy B-sch B-print B-Help BR-docs rs-sts sch-code p-desc mark-num
&Scoped-Define DISPLAYED-OBJECTS rs-sts sch-code p-desc mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sel-type Dialog-Frame
FUNCTION sel-type RETURNS CHARACTER
  ( input p-rec as recid  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавление записи"
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменение записи"
     BGCOLOR 8 .

DEFINE BUTTON B-copy
     LABEL "Копи&я"
     SIZE 10 BY 1 TOOLTIP "Скопировать в другие фирмы"
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удаление записи"
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-firm
     LABEL "Фирм&а"
     SIZE 10 BY 1 TOOLTIP "Сменить фирму"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-History
     LABEL "Ис&тория"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-import
     LABEL "Импорт"
     SIZE 10 BY 1 TOOLTIP "Импорт из тестового файла"
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр записи".

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить строки справочника"
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1 TOOLTIP "Печать текущего списка"
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 10 BY 1 TOOLTIP "Фильтрация справочника"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1 TOOLTIP "Выбор отмеченных или текущей записи"
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE p-desc AS CHARACTER FORMAT "X(80)":U
     LABEL "по &описанию"
     VIEW-AS FILL-IN
     SIZE 29.25 BY 1 TOOLTIP "Поиск по описанию  Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(12)":U
     LABEL "по &коду"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по коду справочника Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE rs-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 34.5 BY .75 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-docs FOR
      buf_fin-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      mark-string(recid( ub.buf_fin-code), rid-list) COLUMN-LABEL "*" FORMAT "x(1)"
      buf_fin-code.code-value COLUMN-LABEL "Код" FORMAT "x(6)"
      sel-type(recid( ub.buf_fin-code)) @ t-a COLUMN-LABEL "Тип" FORMAT "x(9)"
      buf_fin-code.descr    COLUMN-LABEL "Описание"
      buf_fin-code.fin-code COLUMN-LABEL "Внутр. №"
      buf_fin-code.host-code    COLUMN-LABEL "Фирма" format ">>>>>>>>9"
      {&status-int-name} @ t-s  COLUMN-LABEL "Статус" FORMAT "x(6)"
      buf_fin-code.level-1 COLUMN-LABEL   "Уровень1" format ">>>9"
      buf_fin-code.level-2 COLUMN-LABEL   "Уровень2" format ">>>9"
      buf_fin-code.level-3 COLUMN-LABEL   "Уровень3" format ">>>9"
      enable buf_fin-code.code-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 69.88 BY 12.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11.5
     B-sel AT ROW 1 COL 21
     B-add AT ROW 1 COL 31
     B-lkp AT ROW 1 COL 41
     B-chg AT ROW 1 COL 51
     B-del AT ROW 1 COL 61
     B-History AT ROW 2 COL 1
     B-import AT ROW 2 COL 11
     B-firm AT ROW 2 COL 21
     B-copy AT ROW 2 COL 31
     B-sch AT ROW 2 COL 41
     B-print AT ROW 2 COL 51
     B-Help AT ROW 2 COL 61
     BR-docs AT ROW 3.25 COL 1.25
     rs-sts AT ROW 16.25 COL 35 NO-LABEL
     sch-code AT ROW 17.38 COL 1
     p-desc AT ROW 17.38 COL 23.75
     mark-num AT ROW 1 COL 14.88 NO-LABEL
     " ПОИСК" VIEW-AS TEXT
          SIZE 7.13 BY .71 AT ROW 16.67 COL 1.13
          BGCOLOR 3 FGCOLOR 15
     SPACE(62.98) SKIP(1.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-exit.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-History IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-History:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-import IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-import:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN p-desc IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN sch-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_fin-code NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run add-proc in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-reference_update':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g#log
}
if not g#log then  return .
define variable rr as recid no-undo .

    if available buf_fin-code then do:
        rr = recid( buf_fin-code ).
        run ref/fci-1.w
        ( {&update} , input-output rr , input par-host-code ).
        disp buf_fin-code.code-value
             buf_fin-code.descr
             sel-type(recid( ub.buf_fin-code)) @ t-a
             buf_fin-code.level-1
             buf_fin-code.level-2
             buf_fin-code.level-3
        with browse br-docs.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy Dialog-Frame
ON CHOOSE OF B-copy IN FRAME Dialog-Frame /* Копия */
DO:
run proc-copy in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:

/* Право на удаление */
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-reference_deletion':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g#log
}
if not g#log then  return .
  else do:
      message "Удалить запись в справочнике ?"
      view-as alert-box question
      buttons yes-no
      update g#log.
      if g#log = false then return.
  end.
  find current buf_fin-code  exclusive-lock  no-error .
  if available buf_fin-code then do:
      find first ub.sysconf no-lock where
            ( ub.sysconf.cor-acc-in   = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc1-in  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc-out  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc1-out = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc-in-cash  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc1-in-cash  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc-out-cash  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc1-out-cash  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc-in-payoff  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc1-in-payoff  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc-out-payoff  = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code ) or
            ( ub.sysconf.cor-acc1-out-payoff = buf_fin-code.fin-code    and
              ub.sysconf.host-code = buf_fin-code.host-code )
              no-error .
      if available ub.sysconf
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Нельзя удалять запись! " skip
            "Значение справочника используется в настройке фирмы"  skip
            view-as alert-box error .
          return no-apply.
        end.

    buf_fin-code.status_ = 1.
    run OpenBr in this-procedure (yes, no, '':U).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-firm Dialog-Frame
ON CHOOSE OF B-firm IN FRAME Dialog-Frame /* Фирма */
DO:
define var p-out-host-code like ub.sysconf.host-code no-undo.
define variable v-rid-list as character no-undo .
define buffer buf_sysconf for ub.sysconf.
find first buf_sysconf no-lock where
            buf_sysconf.host-code = par-host-code no-error.
if available buf_sysconf then v-rid-list =string( recid(buf_sysconf) ).

run adm/sconfs.w
             (input parParentProc,
              input "b-sel":U,
              input no,
              input  par-host-code ,
              output p-out-host-code,
              input-output v-rid-list ) no-error
              .
if error-status :error then     message vss-workfile vss-revision vss-description skip
                                        error-status :get-message(1)
                                        skip " из sconfs.w"
                                        view-as alert-box error
                                        .
/* Проверка на то что выбрать можно фирмы текущей БД */
define variable p-ret as logical no-undo .

if p-out-host-code <> ? then do:
run current-db in this-procedure (
    input p-out-host-code,
    input par-host-code,
    output p-ret ) no-error .
if error-status :error then do:
   message vss-workfile vss-revision vss-description skip
           error-status :get-message(1) .
   return .
   end.
if p-ret = no then return.

if p-out-host-code <> ? then
   par-host-code = p-out-host-code .

run OpenBR in this-procedure (yes, no, '':U).
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-import Dialog-Frame
ON CHOOSE OF B-import IN FRAME Dialog-Frame /* Импорт */
DO:
  run buh-import in this-procedure.
END.

ON CHOOSE OF B-History IN FRAME Dialog-Frame /* Экспорт */
DO:
    if available buf_fin-code then do:
       run ref/fincac.w
         (input  parparentproc              ,
          input  buf_fin-code.host-code     ,
          input  buf_fin-code.fin-code
          ).

    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-reference_lookup':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g#log
}
if not g#log then  return .
define variable rr as recid no-undo .
    if available buf_fin-code then do:
        rr = recid( buf_fin-code ).
        run ref/fci-1.w ( {&lookup} , input-output rr , input par-host-code ).
     end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
      if available buf_fin-code then do:
        { gbl/markstrn.i buf_fin-code rid-list }
        g#log = br-docs:refresh() .

        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g#log = br-docs:select-next-row ().
            apply "VALUE-CHANGED" to br-docs in frame {&frame-name}.
        end.

        if num-entries( rid-list ) = 0
        then
            hide mark-num in frame {&frame-name}.
        else do:
            mark-num:screen-value in frame {&frame-name}  = string (num-entries( rid-list )) .
            enable mark-num with frame {&frame-name}.
            end.
    end.
    apply "entry" to br-docs in frame {&frame-name}.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run print-proc in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available buf_fin-code ) AND ( rid-list = "" ) then
    rid-list = string( recid( buf_fin-code ) ) .
    /* message "выбрано" rid-list . */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
   if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
    if b-mark:sensitive in frame {&frame-name} then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame {&frame-name} then
      APPLY "CHOOSE" to b-sel.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
OR MOUSE-SELECT-DBLCLICK OF {&self-name} IN FRAME {&frame-name}
DO:
      if b-sel:sensitive in frame {&frame-name}  = yes then
        apply "choose" to b-sel in frame {&frame-name}.
    else
        apply "choose" to B-lkp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-desc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-desc Dialog-Frame
ON LEAVE OF p-desc IN FRAME Dialog-Frame /* по описанию */
DO:
END.

ON CTRL-J OF p-desc IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc in this-procedure(yes, input frame {&frame-name} p-desc) no-error.
  if error-status:error then return no-apply.

END.

ON RETURN OF p-desc IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-desc in this-procedure(no, input frame {&frame-name} p-desc) no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-sts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-sts Dialog-Frame
ON VALUE-CHANGED OF rs-sts IN FRAME Dialog-Frame
DO:
    ASSIGN
  rs-sts
  p-sts = (IF rs-sts = {&all}  THEN ? ELSE INTEGER(rs-sts))
  .
  run openbr in this-procedure (yes, no, '':u)  no-error.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* по коду */
DO:
  run proc-find-code in this-procedure(no, input frame {&frame-name} sch-code) no-error.
  return no-apply.
END.

ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
  run proc-find-code in this-procedure(yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ ref/crfincd.i  {&main-file} }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/mv-clmn.i
 &ext-col = 9
 &start-column = 2
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
}

{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&main-file}"
  &sort-clmn_1    = "buf_fin-code.code-value"
  &sort-clmn_2    = "buf_fin-code.acc-type"
  &label-clmn_2   =  "'Тип'"
  &sort-clmn_3    = "buf_fin-code.descr"
  &sort-clmn_4    = "buf_fin-code.fin-code"
  &sort-clmn_5    = "buf_fin-code.host-code"
  &sort-clmn_7    = "buf_fin-code.level-1"
  &sort-clmn_8    = "buf_fin-code.level-2"
  &sort-clmn_9    = "buf_fin-code.level-3"
  &open-query     = "run OpenBr(yes, no, '':U)."
  &open-query-otherwise = "run OpenBr(yes, no, '':U)."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "yes" }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  assign
    buf_fin-code.code-value:read-only in browse {&browse-name} = true
  .
/* Нaзвание таблицы */
  define variable p-file-label as character no-undo .

  assign
    p-file-label =  "Корреспондирующие счета"
  .

  define buffer buf_clients for  ub.clients .
  case par-mode:
    when {&all}
    then do:
    end.
    when {&company}
    then do:
      find first buf_clients no-lock
        where buf_clients.obj-code = par-host-code
          and buf_clients.obj-type = {&cmp}
        no-error .
      if not available buf_clients then do:
        message
        substitute("Неверное значение параметра par-host-code=&1", par-host-code)
        view-as alert-box error .
        return error.
      end.
      find first X_sysconf where X_sysconf.host-code = par-host-code .
      v-main-firm-db = X_sysconf.firm-db-num.
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - par-mode=" par-mode
      view-as alert-box ERROR.
      return.
    end.
  end CASE.
    if pardoc-rec <> ? then do:
      FIND FIRST find_code No-LOCK where
                 recid(find_code) = pardoc-rec No-ERROR.
      if not avail find_code then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра вызова pardoc-rec" pardoc-rec
        view-as alert-box error .
        return error.
      end.
      doc-rec = pardoc-rec.
    end.
  run my-enable_ui in this-procedure.
  run openbr in this-procedure (yes, no, '':u).
  hide mark-num  B-import in frame {&frame-name} .
  if pardoc-rec <> ? then
  reposition br-docs to recid doc-rec no-error.
  wait-for go of frame {&frame-name}.
END.
run disable_ui in this-procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-proc Dialog-Frame
PROCEDURE add-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-reference_add-def':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g#log
}
if not g#log then  return .

define variable rr as recid no-undo .
  run ref/fci-1.w ( {&add-def} , input-output rr , input par-host-code ).
  v-doc-rec = rr .
  run openbr in this-procedure (yes, no, '':u).
  REPOSITION br-docs to recid v-doc-rec no-error .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE buh-import Dialog-Frame
PROCEDURE buh-import :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-doc-rec as recid no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-reference_add-def':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g#log
}
if not g#log then  return .

define variable rr as recid no-undo .

  run ref/fi-buhac.p ( input-output rr , input par-host-code ).
  v-doc-rec = rr .
  run openbr in this-procedure (yes, no, '':u).
  REPOSITION br-docs to recid v-doc-rec no-error .


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
  DISPLAY rs-sts sch-code p-desc mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-mark B-sel B-add B-lkp B-chg B-del B-firm B-copy B-sch
         B-print B-Help BR-docs rs-sts sch-code p-desc mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable_UI Dialog-Frame
PROCEDURE my-enable_UI :
ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "Текущие&+" + {&comma-char} +  {&current-status-int} + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Удаленные&-" + {&comma-char} + {&deleted-status-int}
rs-sts = (IF p-sts = ? THEN {&all} ELSE string(p-sts))
.


DISPLAY sch-code p-desc mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit rs-sts
         B-lkp
         B-add       when LOOKUP("b-add":U,  bttns) > 0  and v-cntxt-db-num = v-main-firm-db  and not transaction
         B-chg       when LOOKUP("b-chg":U,  bttns) > 0  and v-cntxt-db-num = v-main-firm-db  and not transaction
         B-copy      when LOOKUP("b-add":U,  bttns) > 0  and v-cntxt-db-num = v-main-firm-db  and not transaction
         B-import    when LOOKUP("b-add":U,  bttns) > 0  and v-cntxt-db-num = v-main-firm-db  and not transaction
         B-firm
         B-History
         B-sch
         B-print
         B-Help
         b-sel        when LOOKUP("b-sel":U,  bttns) > 0
         b-mark       when LOOKUP("b-mark":U, bttns) > 0
         b-del        when LOOKUP("b-del":U,  bttns) > 0 and v-cntxt-db-num = v-main-firm-db  and not transaction
         BR-docs sch-code p-desc mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.

title0 = "Справочник фин.кодов " + caps(p-file-label) + {&space-char}.

IF p-sts <> ? THEN DO:
&SCOPED-DEFINE status-code STRING(p-sts)
    frame {&frame-name}:TITLE = title0 + {&space-char} + {&status-int-name}.

END.


{&SetCursorWait}

define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH buf_fin-code

&scop flt-open-dyn_open-query  FOR EACH buf_fin-code

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name buf_fin-code

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_fin-code

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer buf_fin-code for {&main-file}.

&scop flt-open-debug-file

&scop flt-open-waitfram  true


define variable l-open-query as logical   no-undo .

 IF p-sts <> ? THEN DO:
     CASE par-mode :
         WHEN {&all}        THEN DO:
          filter-point = filter-point0 + par-mode.
          ASSIGN frame {&frame-name}:TITLE = title0 .
          { gbl/fltopend.i
             &where-cond = " buf_fin-code.status_ = p-sts"
             &dyn_where-cond = " substitute (' buf_fin-code.status_ =  &1 ', p-sts ) "
             &use-ind    = "  "
             &by         = "  " }

         END.
         WHEN {&company} THEN DO:
            find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
            if not available buf_clients then return .
            filter-point = filter-point0 + par-mode.
            ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + "  код:" +  string(par-host-code).
           { gbl/fltopend.i
             &where-cond = " buf_fin-code.host-code = par-host-code and buf_fin-code.status_ = p-sts "
             &dyn_where-cond = " substitute (' buf_fin-code.host-code = &2 and  buf_fin-code.status_ =  &1 ', p-sts , par-host-code) "
             &use-ind    = " USE-INDEX val "
             &by         = "  " }
         END.
     END CASE.

 END.
 ELSE DO:
     CASE par-mode :
         WHEN {&all}        THEN DO:
          filter-point = filter-point0 + par-mode.
          ASSIGN frame {&frame-name}:TITLE = title0 .
          { gbl/fltopend.i
             &where-cond = " TRUE "
             &dyn_where-cond = " 'TRUE' "
             &use-ind    = "  "
             &by         = "  " }

         END.
         WHEN {&company} THEN DO:
            find first buf_clients no-lock where buf_clients.obj-code = par-host-code and buf_clients.obj-type = {&cmp} no-error .
            if not available buf_clients then return .
            filter-point = filter-point0 + par-mode.
            ASSIGN frame {&frame-name}:TITLE = title0 + "   ФИРМА: " + buf_clients.obj-name  + "  код:" +  string(par-host-code).
           { gbl/fltopend.i
             &where-cond = " buf_fin-code.host-code = par-host-code "
             &dyn_where-cond = " substitute (' buf_fin-code.host-code = &1 ', par-host-code) "
             &use-ind    = " USE-INDEX val "
             &by         = "  " }
         END.
     END CASE.

 END.


if not p-open-query and doc-rec <> ? then
REPOSITION br-docs to recid doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

apply "entry" to br-docs in frame {&frame-name}.

{&SetCursorno}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-proc Dialog-Frame
PROCEDURE print-proc :
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-reference_print':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g#log
}
if not g#log then  return .

define variable sym1   as char format "X(1)" init ":".
define variable sym2 as char format "X(1)" init ":".
define variable sym3 as char format "X(1)" init ":".
define variable sym4 as char format "X(1)" init ":".

define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable l-type as character no-undo .


DEFINE FRAME Chk-List
        sym1                      column-label "_"                   format "X(1)" space(0)
        buf_fin-code.code-value   column-label "Код_"                format "X(12)"
        sym2                      column-label " "                   format "X(1)"
        l-type                    column-label "Тип"
        sym4                      column-label " "                   format "X(1)"
        buf_fin-code.descr        column-label "Описание_"           format "X(80)"
        sym3                      column-label " "                   format "X(1)"
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER(PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(108)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 108).
    date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(108)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME Chk-List  .
    run waitfram-show in this-procedure("Ждите...").
    run openbr in this-procedure (yes, no, '':u).
     DO WHILE available buf_fin-code :
             Display STREAM PrnLibStream
            sym1
            sym2
            sym3
            sym4
            buf_fin-code.code-value
            buf_fin-code.descr
            sel-type(recid( ub.buf_fin-code)) @ l-type
            with FRAME Chk-List .
            DOWN STREAM PrnLibStream 1 with FRAME CHk-List  .
            GET next br-docs.
      END.
      UNDERLINE  STREAM PrnLibStream
            sym1 sym2 sym3 sym4
            buf_fin-code.code-value buf_fin-code.descr l-type
            with FRAME Chk-List .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure.
    run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = '{&main-file}'
  join-tbl = 'buf_fin-code'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('code-value', 'Код', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('descr', 'Описание', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fin-code', 'Внутр.№', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', 'Код фирмы', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
/*
run fltfield-add in this-procedure('Status_', 'Статус', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
*/
run fltfield-add in this-procedure('level-1', 'Уровень_1', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('level-2', 'Уровень_2', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('level-3', 'Уровень_3', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr in this-procedure (yes, no, '':u).
END. /* Filter-Block */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy Dialog-Frame
PROCEDURE proc-copy :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable p-fin-code as integer no-undo .
define variable p-out-host-code like ub.sysconf.host-code no-undo.
define variable firm-rid-list as char no-undo.
define variable p-ok as logical no-undo .
define buffer buf2_fin-code for {&main-file} .
define variable i as integer no-undo .
define variable J as integer no-undo .
define variable k as integer no-undo .
define variable p-ret as logical no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-reference_export':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g#log
}
if not g#log then  return .

if num-entries(rid-list) = 0 then do:
   message "Не отмечены записи для копирования !!!" .
   return .
end.

define variable v-out-host-code  as integer no-undo .
define variable v-lock-self-host as integer no-undo .
define variable v-curr-host-code as integer no-undo .


v-lock-self-host = par-host-code.
v-lock-self-host = par-host-code.
run adm/sconfs.w
(
 input parParentProc,
 input "b-sel,b-mark" ,
 input no,
 input par-host-code,
 output v-out-host-code,
 input-output firm-rid-list )
 .

 if num-entries(firm-rid-list) = 0 then do:
   message "Не выбрана фирма для копирования !!!" .
   return .
   end.

  message
    "Вы отметили " num-entries(firm-rid-list) " фирмы. " skip
    "Скопировать выбранные значения справочника в эти фирмы ?"
    view-as alert-box question
    buttons yes-no
    update p-ok.

k = 0.
  if p-ok = false then return.
define buffer buf_sysconf for ub.sysconf.
define variable v-nn as integer   no-undo .
define variable v-nnn as integer   no-undo .

v-nn  = num-entries(firm-rid-list) .
v-nnn = num-entries(rid-list) .
  repeat i = 1 to  v-nn :
     for each buf_sysconf no-lock where recid(buf_sysconf) = integer(entry(i,firm-rid-list)) :
        /* список recid справочника */
        repeat j = 1 to v-nnn :
          for each buf2_fin-code where recid(buf2_fin-code) =  integer(entry(j,rid-list)):
          if not can-find ( first buf_fin-code no-lock where
                              buf_fin-code.host-code      = buf_sysconf.host-code and
                              buf_fin-code.code-value     = buf2_fin-code.code-value) then do:

                  /* Проверка на то что выбранная фирма с текущей БД */
                  run current-db in this-procedure (
                      input buf_fin-code.host-code,
                      input par-host-code,
                      output p-ret ) .

                  if p-ret = no then next.

                  run fin-code in this-procedure (input buf_sysconf.host-code , output p-fin-code) .
                  run create-ref-corr-acc in this-procedure (
                      input yes ,
                      input buf_sysconf.host-code,
                      input p-fin-code   ,
                      input buf2_fin-code.code-value ,
                      input buf2_fin-code.descr,
                      input buf2_fin-code.status_,
                      input buf2_fin-code.level-1,
                      input buf2_fin-code.level-2,
                      input buf2_fin-code.level-3,
                      input buf2_fin-code.acc-type
                      ).
                      k = k + 1.
                  end.
          end.
        end.
     end.
  end.
message "Скопировано " k  "записей" view-as alert-box .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
display "" @ p-desc with frame {&frame-name}.
assign
  pardoc-code = {&double-quote} + pardoc-code + {&double-quote} .

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_fin-code.code-value   begins &1 "
      , pardoc-code)
    ).

/* apply "entry":u to sch-code in frame {&frame-name} . */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-desc Dialog-Frame
PROCEDURE proc-find-desc :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code as char no-undo.
display "" @ sch-code with frame {&frame-name}.
assign
  pardoc-code = {&double-quote} + pardoc-code + {&double-quote} .

run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_fin-code.descr   begins &1 "
      , pardoc-code)
    ).
apply "entry":u to p-desc in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sel-type Dialog-Frame
FUNCTION sel-type RETURNS CHARACTER
  (input  p-rec as recid   ) :
  define buffer loc-fin-code for ub.fin-code-cor-acc  .
  find first loc-fin-code no-lock where recid(loc-fin-code) = p-rec no-error .
  if error-status :error then return '' .

  define variable rr as character no-undo .

  &scop fin-acc-code  string(loc-fin-code.acc-type)
  rr = string({&fin-acc-codes-name} ) no-error .
  if error-status :error then return '' .
  RETURN rr.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME