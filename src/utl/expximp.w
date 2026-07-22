&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт-импорт локальных таблиц УБД из старой версии TH - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/24/05
Author: Bakhtadze Natalya
Creation date: 09/24/05


*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---
         */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-from-version as character no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Экспорт-импорт локальных таблиц УБД из старой версии TH - запуск" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/thth150.i }
{ cmp/thth14.i }


define variable v_os-dir   AS CHAR NO-UNDO INIT "".
define variable v_os-dir-type   AS CHAR NO-UNDO INIT "".
define variable v_can-write as logical no-undo.

{ gbl/waitfram.i }
{ cmp/operfile.i }
{ utl/imp-expd.i }
{ gbl/key-rec.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-import B-Help RECT-groups B-dir ~
T-pbc T-glb T-scl T-cdk T-usr T-flt T-pet B-obj dir-name F-pbc F-scl F-cdk ~
F-usr F-flt F-pet
&Scoped-Define DISPLAYED-OBJECTS T-pbc T-glb T-scl T-cdk T-usr T-flt T-pet ~
f-old-host-code f-new-host-code Rs-old-obj-type Rs-new-obj-type ~
f-old-obj-code f-new-obj-code dir-name F-pbc F-scl F-cdk F-usr F-flt F-pet

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-import
     LABEL "&Импорт"
     SIZE 10 BY 1.

DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 2.5 BY 1.

DEFINE VARIABLE dir-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.6 BY 1 NO-UNDO.

DEFINE VARIABLE F-cdk AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-cdrg AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-flt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-gen AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE f-new-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Новый код фирмы"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-new-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Новый код объекта"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-old-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Старый код фирмы"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-old-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Старый код объекта"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE F-pbc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-pet AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-rht AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-scl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-seq AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-thb AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE F-usr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.

DEFINE VARIABLE Rs-new-obj-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 12.5 BY .8 NO-UNDO.

DEFINE VARIABLE Rs-old-obj-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 12.5 BY .8 NO-UNDO.

DEFINE RECTANGLE RECT-groups
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 86.8 BY 13.67.

DEFINE VARIABLE T-cdk AS LOGICAL INITIAL yes
     LABEL "Кассы"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-cdrg AS LOGICAL INITIAL no
     LABEL "Диапазоны весовых кодов"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .8 NO-UNDO.

DEFINE VARIABLE T-flt AS LOGICAL INITIAL yes
     LABEL "Фильтры"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-gen AS LOGICAL INITIAL yes
     LABEL "Настройки"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-glb AS LOGICAL INITIAL no
     LABEL "Глобальные коды"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1.07 NO-UNDO.

DEFINE VARIABLE T-pbc AS LOGICAL INITIAL yes
     LABEL "Вес,взвеш и топ.коды"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-pet AS LOGICAL INITIAL yes
     LABEL "Конфиг АЗК"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-rht AS LOGICAL INITIAL no
     LABEL "Права"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-scl AS LOGICAL INITIAL yes
     LABEL "Весы"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-seq AS LOGICAL INITIAL no
     LABEL "Счетчики"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-thb AS LOGICAL INITIAL no
     LABEL "Параметры"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.

DEFINE VARIABLE T-usr AS LOGICAL INITIAL yes
     LABEL "Пользователи"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     B-export AT ROW 1 COL 21
     B-import AT ROW 1 COL 31
     B-Help AT ROW 1 COL 82
     B-dir AT ROW 2 COL 81.3
     T-rht AT ROW 5 COL 3
     T-gen AT ROW 6 COL 3
     T-thb AT ROW 7 COL 3 WIDGET-ID 30
     T-cdrg AT ROW 8 COL 3 WIDGET-ID 22
     T-pbc AT ROW 9 COL 3
     T-glb AT ROW 9 COL 64.5 WIDGET-ID 2
     T-scl AT ROW 10 COL 3
     T-cdk AT ROW 11 COL 3 WIDGET-ID 26
     T-seq AT ROW 12 COL 3
     T-usr AT ROW 13 COL 3
     T-flt AT ROW 14 COL 3
     T-pet AT ROW 15 COL 3 WIDGET-ID 34
     B-obj AT ROW 17.27 COL 1 WIDGET-ID 38
     f-old-host-code AT ROW 17.27 COL 19.5 COLON-ALIGNED WIDGET-ID 4
     f-new-host-code AT ROW 17.27 COL 49 COLON-ALIGNED WIDGET-ID 6
     Rs-old-obj-type AT ROW 18.33 COL 21 NO-LABEL WIDGET-ID 16
     Rs-new-obj-type AT ROW 18.33 COL 51 NO-LABEL WIDGET-ID 18
     f-old-obj-code AT ROW 19.27 COL 19.5 COLON-ALIGNED WIDGET-ID 8
     f-new-obj-code AT ROW 19.27 COL 49 COLON-ALIGNED WIDGET-ID 10
     dir-name AT ROW 2 COL 28.6 COLON-ALIGNED NO-LABEL
     F-rht AT ROW 5 COL 30.5 COLON-ALIGNED NO-LABEL
     F-gen AT ROW 6 COL 30.5 COLON-ALIGNED NO-LABEL
     F-thb AT ROW 7 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     F-cdrg AT ROW 8 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     F-pbc AT ROW 9 COL 30.5 COLON-ALIGNED NO-LABEL
     F-scl AT ROW 10 COL 30.5 COLON-ALIGNED NO-LABEL
     F-cdk AT ROW 11 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     F-seq AT ROW 12 COL 30.5 COLON-ALIGNED NO-LABEL
     F-usr AT ROW 13 COL 30.5 COLON-ALIGNED NO-LABEL
     F-flt AT ROW 14 COL 30.5 COLON-ALIGNED NO-LABEL
     F-pet AT ROW 15 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     "Группы данных" VIEW-AS TEXT
          SIZE 20.1 BY .8 AT ROW 4 COL 3.4
          FGCOLOR 4
     "Название файла экспорта-импорта" VIEW-AS TEXT
          SIZE 33.5 BY .8 AT ROW 4 COL 33.1
          FGCOLOR 4
     "ПРИ ИМПОРТЕ" VIEW-AS TEXT
          SIZE 22 BY 1.07 AT ROW 17.27 COL 65.5 WIDGET-ID 20
          FGCOLOR 4
     "Директория экспорта/импорта" VIEW-AS TEXT
          SIZE 27.9 BY 1 AT ROW 2 COL 2
          FGCOLOR 4
     RECT-groups AT ROW 3.4 COL 1.8
     SPACE(0.39) SKIP(3.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт-импорт локальных таблиц для РАСТЯНУТОГО upgrade"
         DEFAULT-BUTTON B-exit.


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-export IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-export:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-cdrg IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-cdrg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-gen IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-gen:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-new-host-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-new-obj-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-old-host-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-old-obj-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-rht IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-rht:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-seq IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-seq:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN F-thb IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       F-thb:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR RADIO-SET Rs-new-obj-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET Rs-old-obj-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-cdrg IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-cdrg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-gen IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-gen:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-rht IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-rht:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-seq IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-seq:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX T-thb IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-thb:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Экспорт-импорт локальных таблиц для РАСТЯНУТОГО upgrade */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dir Dialog-Frame
ON CHOOSE OF B-dir IN FRAME Dialog-Frame
DO:



    run gbl/dir-sel.p (output v_os-dir,
                output v_os-dir-type,
                output v_can-write) no-error.
    if error-status:error then return no-apply.
    dir-name = v_os-dir.
    display
    dir-name
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-export Dialog-Frame
ON CHOOSE OF B-export IN FRAME Dialog-Frame /* Экспорт */
DO:
  if NOT v_can-write then do:
    message "Данная директория доступна только для чтения"
    view-as alert-box ERROR.
    return no-apply.
  end.
  run waitfram-show in this-procedure ( input "Ждите..." ).
  run proc-b-ie in this-procedure ( input "export":U).
  run waitfram-hide in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-import Dialog-Frame
ON CHOOSE OF B-import IN FRAME Dialog-Frame /* Импорт */
DO:
 DEFINE buffer buf_sysconf FOR ub.sysconf.
 DEFINE BUFFER buf_clients FOR ub.clients.
 ASSIGN
 f-old-host-code
 f-new-host-code
 rs-old-obj-type
 rs-new-obj-type
 f-old-obj-code
 f-new-obj-code
 .
 FIND FIRST buf_sysconf NO-LOCK WHERE
            buf_sysconf.host-code = f-new-host-code NO-ERROR.
 IF NOT AVAILABLE buf_sysconf THEN DO:
   MESSAGE
   substitute("Не найдена фирма с кодом (НОВОЙ) фирмы &1"
              , f-new-host-code)
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN NO-APPLY.
 END.
 FIND FIRST buf_clients NO-LOCK WHERE
             buf_clients.obj-type = rs-new-obj-type
        AND  buf_clients.obj-code = f-new-obj-code
     NO-ERROR.
  IF NOT AVAILABLE buf_clients THEN DO:
    MESSAGE
    substitute("Не найден объект с кодом/типом (НОВЫМ) &1&2"
               , rs-new-obj-type
               , f-new-obj-code)
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN NO-APPLY.
 END.
if buf_clients.host-code <> buf_sysconf.host-code then do:
    MESSAGE
    substitute("Объект с кодом/типом (НОВЫМ) &1&2 НЕ принадлежит фирме &3"
               , rs-new-obj-type
               , f-new-obj-code
               , f-new-host-code
               )
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN NO-APPLY.
end.
IF f-old-host-code = 0  THEN DO:
   MESSAGE
   "Не заполнен СТАРЫЙ код фирмы"
   VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN NO-APPLY.
END.
IF f-old-obj-code = 0  THEN DO:
    MESSAGE
    "Не заполнен СТАРЫЙ код объекта"
    VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN NO-APPLY.

END.

  if sys-ctrl.db-num <> 0
    and T-cdrg <> no
  then do:
    MESSAGE
    "Импортировать ДИАПАЗОНЫ ВЕСОВЫХ КОДОВ можно только в ГБД"
    VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN NO-APPLY.
  end.


  run waitfram-show in this-procedure ( input "Ждите..." ).
  run proc-b-ie in this-procedure ( input "import":U).
  run waitfram-hide in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Btn 1 */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-rowid AS rowid NO-UNDO.
  DEFINE VARIABLE v-tbl-name AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
  DEFINE BUFFER buf_clients FOR ub.clients.
  run utl/thth-cli.w ( input parparentproc
                      ,input "b-sel"
                      ,input {&g___object} /*p-list-mode*/
                      ,input-output v-rid-list) no-error.
  IF v-rid-list <> '' THEN DO:
      FIND FIRST buf_ext-classif NO-LOCK WHERE
            RECID(buf_ext-classif) = INTEGER(v-rid-list) NO-ERROR.
      IF buf_ext-classif.uniq-key-rec = '' THEN DO:
         MESSAGE
         "Еще не установлено соответствие для этого объекта"
         VIEW-AS ALERT-BOX ERROR.
         RETURN NO-APPLY.
      END.
      ASSIGN
      f-old-host-code = buf_ext-classif.key#_two
      rs-old-obj-type = buf_ext-classif.charkey_one
      f-old-obj-code = buf_ext-classif.key#_one
      .
        RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                      ,input ?
                                      ,INPUT "ub"
                                      ,INPUT ? /*p-bh-handle*/
                                      ,INPUT NO-LOCK
                                      ,OUTPUT v-rowid
                                      ,OUTPUT v-tbl-name) no-error.
     FIND FIRST buf_clients NO-LOCK WHERE
                ROWID(buf_clients) = v-rowid.
     ASSIGN
     f-new-host-code = buf_clients.host-code
     rs-new-obj-type = buf_clients.obj-type
     f-new-obj-code = buf_clients.obj-code
     .
     DISPLAY
     f-old-host-code
     rs-old-obj-type
     f-old-obj-code
     f-new-host-code
     rs-new-obj-type
     f-new-obj-code
     WITH FRAME {&FRAME-NAME}.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-usr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-usr Dialog-Frame
ON VALUE-CHANGED OF T-usr IN FRAME Dialog-Frame /* Пользователи */
DO:
  ASSIGN
  t-usr.
  /*
  CASE t-usr:
      WHEN NO THEN DO:
         ASSIGN
         t-rht = NO.
         DISPLAY
         t-rht
         WITH FRAME {&FRAME-NAME}.
      END.
      WHEN YES  THEN DO:
         ASSIGN
            t-rht = YES.
            DISPLAY
            t-rht
            WITH FRAME {&FRAME-NAME}.
      END.
  END CASE.
  */
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
    file-info:file-name = ".".
    assign
    dir-name = file-info:full-pathname
    v_os-dir-type = file-info :file-type
    v_can-write = (index(v_os-dir-type, "W") > 0)
   .
  FIND FIRST sys-ctrl No-LOCK.
  FIND FIRST db no-LOCK where
             db.db-num = sys-ctrl.db-num.

  assign
    f-rht  = corr-file-name(db.db-key) + ".":U +   "rht"
    F-flt  = corr-file-name(db.db-key) + ".":U +   "flt"
    F-thb  = corr-file-name(db.db-key) + ".":U +   "thb"
    F-pbc  = corr-file-name(db.db-key) + ".":U +   "pbc"
    F-scl  = corr-file-name(db.db-key) + ".":U +   "scl"
    F-usr  = corr-file-name(db.db-key) + ".":U +   "usr"
    F-gen  = corr-file-name(db.db-key) + ".":U +   "gen"
    F-seq  = corr-file-name(db.db-key) + ".":U +   "seq"
    F-cdrg = corr-file-name(db.db-key) + ".":U +   "cdr"
    F-cdk  = corr-file-name(db.db-key) + ".":U +   "cdk"
    F-pet  = corr-file-name(db.db-key) + ".":U +   "pet"
    .

  rs-old-obj-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
      {&shop} + {&comma-char} + {&shop} + {&comma-char} +
      {&stock} + {&comma-char} + {&stock}
      .
  rs-new-obj-type:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
      {&shop} + {&comma-char} + {&shop} + {&comma-char} +
{&stock} + {&comma-char} + {&stock} .
  rs-old-obj-type = {&shop}.
  rs-new-obj-type = {&shop}.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-iefile Dialog-Frame
PROCEDURE check-iefile :
/*------------------------------------------------------------------------------
  Purpose:  проверка наличия файлов в выбранной директории
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-dir-name as character no-undo.
DEFINE INPUT PARAMETER p-file-extension as character no-undo.
DEFINE INPUT PARAMETER p-mode as character no-undo.
define output parameter p-ok as logical no-undo.
define variable full_name as character no-undo.
FIND FIRST sys-ctrl No-LOCK.
FIND FIRST db no-LOCK where
            db.db-num = sys-ctrl.db-num.
if not avail db then do:
    message "Отсутствует информация в таблице db"
    view-as alert-box ERROR.
    return error.
end.
full_name = dir-name + "\":U + corr-file-name(db.db-key) + "." + p-file-extension.
if p-mode = "import":U then do:
    if search(full_name) = ? then do:
    message "Не найден файл данных" full_name  skip
                        "для импорта"
        view-as alert-box ERROR.
        p-ok = no.
        return.
    end.
    p-ok = yes.
    return.
end.
if p-mode = "export":U then do:
    if search(full_name) <> ? then do:
    message "Уже имеется в выбранной директории файл с именем" full_name  skip
            "совпадающим с именем одного из файлов экспорта" skip
            "Перезаписывать?"
    view-as alert-box QUESTION buttons YES-NO update p-ok.
    return.
  end.
  p-ok = yes.
  return.
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
  DISPLAY T-pbc T-glb T-scl T-cdk T-usr T-flt T-pet f-old-host-code
          f-new-host-code Rs-old-obj-type Rs-new-obj-type f-old-obj-code
          f-new-obj-code dir-name F-pbc F-scl F-cdk F-usr F-flt F-pet
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-import B-Help RECT-groups B-dir T-pbc T-glb T-scl T-cdk T-usr
         T-flt T-pet B-obj dir-name F-pbc F-scl F-cdk F-usr F-flt F-pet
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-ie Dialog-Frame
PROCEDURE proc-b-ie :
/*------------------------------------------------------------------------------
  Purpose:     проверка наличия файлов в выбранной директории и запуск процедур имп-эксп
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-mode as character no-undo.
 /*надо проверить наличие файлов в данной директории*/
 define variable ii as integer no-undo.
 define variable loc#log as logical no-undo.
 define variable file-extensions as char format "X(3)" no-undo init {&ie-data-groups}.
 define variable t-vals as logical no-undo extent 11.
 define variable v-proc-name as character no-undo .
 define variable v-proc-title as character no-undo .
 define variable v-param as character no-undo .
 define variable v-choice as integer no-undo .
 define variable glog as logical no-undo .
 assign
 dir-name
 frame {&frame-name}
 T-flt
 t-pbc
 T-scl
 T-usr
 T-seq  = no
 t-glb
 t-cdk
 t-thb
 t-pet
 .
 if (t-cdk
 or t-pet
 or t-thb)
 and p-mode = "export"  then do:
   message
   "Данные о кассах и/или конфигурации АЗК и/или ПАРАМЕТРАХ доступны только для ИМПОРТА"
   view-as alert-box error .
   run waitfram-hide in this-procedure .
   undo, return error .
 end.
 assign
 t-vals[{&ie-gen}]  = no
 t-vals[{&ie-flt}]  = t-flt
 t-vals[{&ie-rht}]  = no
 t-vals[{&ie-pbc}]  = t-pbc
 t-vals[{&ie-scl}]  = t-scl
 t-vals[{&ie-usr}]  = t-usr
 t-vals[{&ie-seq}]  = t-seq
 t-vals[{&ie-cdrg}] = no
 t-vals[{&ie-cdk}]  = t-cdk
 t-vals[{&ie-thb}]  = t-thb
 t-vals[{&ie-pet}]  = t-pet
 .

 if dir-name = "" then do:
    message "Не задана директория для файлов экспорта/импорат"
    view-as alert-box ERROR.
    return error.
 end.
 DO ii = 1 to num-entries(file-extensions):
    if t-vals[ii] then do:
        run check-iefile in this-procedure (
                                           input dir-name
                                           ,input entry(ii, file-extensions)
                                           ,input p-mode
                                           ,output loc#log).
        if not loc#log then  return no-apply.
    end.
  end.
  assign
  v-param = string(T-vals[{&ie-rht}])  + {&delim-par} +
            string(T-vals[{&ie-gen}])  + {&delim-par} +
            string(T-vals[{&ie-flt}])  + {&delim-par} +
            string(T-vals[{&ie-pbc}])  + {&delim-par} +
            string(T-vals[{&ie-scl}])  + {&delim-par} +
            string(T-vals[{&ie-usr}])  + {&delim-par} +
            string(T-vals[{&ie-seq}])  + {&delim-par} +
            string(T-vals[{&ie-cdrg}]) + {&delim-par} +
            string(T-vals[{&ie-cdk}]) + {&delim-par} +
            string(T-vals[{&ie-thb}]) + {&delim-par} +
            (if p-mode = "import"
            then (string(T-vals[{&ie-pet}]) + {&delim-par})
            else '') +
            corr-file-name(db.db-key)  + {&delim-par} +
            dir-name                   + {&delim-par} +
            string(T-glb)

            .
  if p-mode = "export":U then do:
    assign
    v-proc-name = "utl/impxexpe.p"
    v-proc-title = "Экспорт локальных таблиц БД"
    .
  end.
  else do:
    MESSAGE
    "ПРОВЕРЬТЕ ЕЩЕ РАЗ ЗНАЧЕНИЯ СТАРЫХ И НОВЫХ КОДОВ ФИРМ И ОБЪЕКТОВ!" SKIP
    "ПРОДОЛЖИТЬ?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF NOT glog  THEN RETURN.
    assign
    v-param = v-param + {&delim-par} +
            replace(p-from-version, "v", "") + {&delim-par} +
            STRING(f-old-host-code) + {&delim-par} +
            STRING(f-new-host-code) + {&delim-par} +
            rs-old-obj-type + {&delim-par} +
            rs-new-obj-type + {&delim-par} +
            STRING(f-old-obj-code) + {&delim-par} +
            STRING(f-new-obj-code) + {&delim-par} +
            p-from-version
    v-proc-name = "utl/impxexpi.p"
    v-proc-title = "Импорт локальных таблиц БД"
    .
  end.
  run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input v-proc-name
        , input v-param
        , input no /*p-auto-go*/
        , input "":U
        , input v-proc-title
    ) no-error.
  if error-status:error then do:
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box error.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
