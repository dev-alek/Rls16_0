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

Выбор параметров для автоматического эксп/имп фин документов в систему клиент-банк

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/18/05
Author: Bakhtadze Natalya
Creation date: 07/18/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input PARAMETER p-curr-host-code LIKE ub.sysconf.host-code NO-UNDO.
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
/*может быть shd или run
для расписания или вызова из АРМ взаиморасчеты
*/
define input  parameter p-cre-db-num as integer   no-undo .
define input  parameter p-task-type  as character no-undo .
define input  parameter p-task-num   as integer   no-undo .

/*при p-mode = 'run'*/
define input parameter p-action         as character    no-undo.
/**/

define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.
define output parameter p-object-list        as character    no-undo.
define output parameter p-doc-type-list      as character    no-undo.
define output parameter p-date-list          as character    no-undo.
define output parameter p-hsch-list          as character    no-undo.
define output parameter p-csch-list          as character    no-undo.



/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для автоматического эксп/имп фин документов в систему клиент-банк.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ ref/shd-attr.i }
{ gbl/getcntxt.i def }
{ bge/clbnkd.i " " }

define variable v-host-list              as character    no-undo.
define variable v-hsch-list              as character    no-undo.
define variable v-csch-list              as character    no-undo.
define variable v-host-name             as character    no-undo.
dEFINE variable v-param-type            as character    no-undo.
define variable v-today                 as date         no-undo.
define variable v-time                  as integer      no-undo.

define variable v-init-doc-type-list    as character    no-undo.
define variable v-doc-type-list         as character    no-undo.

define variable v-ext-fin-doc-type-list as character extent 2 init
[
    "расходное платежное поручение",             {&FDEDT_Expense_Cashless}

]                                                           no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK rct-host rct-host-2 rct-host-3 ~
rct-dates Btn_Cancel RS-action b-help RS-encoding RS-format rs-1 ~
bt-sel-host rs-hsch T-create bt-sel-hsch rs-csch T-create-no-th bt-sel-csch ~
fi-days-amount rs-date fi-days-ago fi-date-from fi-date-to ED-doc-type ~
bt-sel-doc-type fi-format-select fi-encoding-select
&Scoped-Define DISPLAYED-OBJECTS RS-action RS-encoding RS-format ed-host ~
rs-1 rs-hsch ed-hsch T-create rs-csch ed-csch T-create-no-th fi-days-amount ~
rs-date fi-days-ago fi-date-from fi-date-to ED-doc-type fi-format-select ~
fi-encoding-select f-t-create-1 f-t-create-2 f-t-create-3 f-t-create-4 ~
f-t-create-5 fi-dates-title f-doc-type-label

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON bt-sel-csch
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON bt-sel-doc-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON bt-sel-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON bt-sel-hsch
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE ed-csch AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 50 BY 2.77
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE ED-doc-type AS CHARACTER INITIAL "Все"
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 50 BY 2.77 NO-UNDO.

DEFINE VARIABLE ed-host AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 20.3 BY 2.77
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE ed-hsch AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 50 BY 2.77
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-doc-type-label AS CHARACTER FORMAT "X(256)":U INITIAL "Типы документов"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.

DEFINE VARIABLE f-t-create-1 AS CHARACTER FORMAT "X(256)":U INITIAL "отсутствующие"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.

DEFINE VARIABLE f-t-create-2 AS CHARACTER FORMAT "X(256)":U INITIAL "платежи"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.

DEFINE VARIABLE f-t-create-3 AS CHARACTER FORMAT "X(256)":U INITIAL "платежей"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.

DEFINE VARIABLE f-t-create-4 AS CHARACTER FORMAT "X(256)":U INITIAL "создавать"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.

DEFINE VARIABLE f-t-create-5 AS CHARACTER FORMAT "X(256)":U INITIAL "строки выписки"
      VIEW-AS TEXT
     SIZE 15.5 BY .77 NO-UNDO.

DEFINE VARIABLE fi-date-from AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-date-to AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-dates-title AS CHARACTER FORMAT "X(256)":U INITIAL " Выбор диапазона дат"
      VIEW-AS TEXT
     SIZE 21.6 BY .67 NO-UNDO.

DEFINE VARIABLE fi-days-ago AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Дней назад"
     VIEW-AS FILL-IN
     SIZE 5.4 BY 1 NO-UNDO.

DEFINE VARIABLE fi-days-amount AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Количество дней"
     VIEW-AS FILL-IN
     SIZE 5.4 BY 1 NO-UNDO.

DEFINE VARIABLE fi-encoding-select AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор кодировки"
      VIEW-AS TEXT
     SIZE 19.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-format-select AS CHARACTER FORMAT "X(256)":U INITIAL " Выбор формата обмена"
      VIEW-AS TEXT
     SIZE 23.5 BY .67 NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все фирмы", 1,
"выбранная фирма", 2
     SIZE 19 BY 2.27 NO-UNDO.

DEFINE VARIABLE RS-action AS CHARACTER INITIAL "exp"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Экспорт", "exp",
"Импорт", "imp"
     SIZE 39.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-csch AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все счета контраг.", 1,
"счета выборочно", 2
     SIZE 21 BY 2.27 NO-UNDO.

DEFINE VARIABLE rs-date AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "за прошлые дни", 0,
"по текущую", 1,
"интервал", 2
     SIZE 19.4 BY 3.27 NO-UNDO.

DEFINE VARIABLE RS-encoding AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "DOS", "IBM866",
"Windows", "Windows-1251"
     SIZE 16.5 BY 3.5 NO-UNDO.

DEFINE VARIABLE RS-format AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 27.5 BY 3.27 NO-UNDO.

DEFINE VARIABLE rs-hsch AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все счета фирмы", 1,
"счета выборочно", 2
     SIZE 18 BY 2.27 NO-UNDO.

DEFINE RECTANGLE rct-dates
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.5 BY 4.47.

DEFINE RECTANGLE rct-host
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 48.5 BY 3.5.

DEFINE RECTANGLE rct-host-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.5 BY 3.5.

DEFINE RECTANGLE rct-host-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 76.5 BY 3.5.

DEFINE VARIABLE T-create AS LOGICAL INITIAL no
     LABEL "Создавать"
     VIEW-AS TOGGLE-BOX
     SIZE 19.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-create-no-th AS LOGICAL INITIAL no
     LABEL "Для отсутствующих"
     VIEW-AS TOGGLE-BOX
     SIZE 19.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     RS-action AT ROW 1 COL 28.5 NO-LABEL
     b-help AT ROW 1 COL 71
     RS-encoding AT ROW 2.5 COL 31.5 NO-LABEL
     RS-format AT ROW 2.77 COL 2 NO-LABEL
     ed-host AT ROW 2.77 COL 78 NO-LABEL
     rs-1 AT ROW 3 COL 52 NO-LABEL
     bt-sel-host AT ROW 4.27 COL 72.5
     rs-hsch AT ROW 6.5 COL 2.5 NO-LABEL
     ed-hsch AT ROW 6.5 COL 27.5 NO-LABEL
     T-create AT ROW 7.27 COL 79.5
     bt-sel-hsch AT ROW 7.77 COL 23
     rs-csch AT ROW 10.27 COL 3 NO-LABEL
     ed-csch AT ROW 10.27 COL 28 NO-LABEL
     T-create-no-th AT ROW 10.33 COL 79.5
     bt-sel-csch AT ROW 11.5 COL 23.5
     fi-days-amount AT ROW 14.27 COL 41.8 COLON-ALIGNED
     rs-date AT ROW 14.57 COL 3.5 NO-LABEL
     fi-days-ago AT ROW 15.47 COL 41.8 COLON-ALIGNED
     fi-date-from AT ROW 16.7 COL 30.6 COLON-ALIGNED
     fi-date-to AT ROW 16.77 COL 47.4 COLON-ALIGNED
     ED-doc-type AT ROW 18.27 COL 22 NO-LABEL
     bt-sel-doc-type AT ROW 18.77 COL 18.5
     fi-format-select AT ROW 2 COL 2 NO-LABEL
     fi-encoding-select AT ROW 2 COL 30.5 NO-LABEL
     f-t-create-1 AT ROW 8.27 COL 79.5 NO-LABEL
     f-t-create-2 AT ROW 9 COL 79.5 NO-LABEL
     f-t-create-3 AT ROW 11.33 COL 79.5 NO-LABEL
     f-t-create-4 AT ROW 12.07 COL 79.5 NO-LABEL
     f-t-create-5 AT ROW 13 COL 79.5 NO-LABEL
     fi-dates-title AT ROW 13.5 COL 3 NO-LABEL
     f-doc-type-label AT ROW 18.77 COL 2.5 NO-LABEL
     rct-host AT ROW 2.5 COL 50.5
     rct-host-2 AT ROW 6.27 COL 2
     rct-host-3 AT ROW 10 COL 2
     rct-dates AT ROW 13.7 COL 2
     SPACE(20.50) SKIP(3.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры эксп.-имп. фин документов в систему КЛИЕНТ-БАНК"
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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR EDITOR ed-csch IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       ED-doc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR ed-host IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR ed-hsch IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-doc-type-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-t-create-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-t-create-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-t-create-3 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-t-create-4 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-t-create-5 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-dates-title IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-encoding-select IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-format-select IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры эксп.-имп. фин документов в систему КЛИЕНТ-БАНК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-csch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-csch Dialog-Frame
ON CHOOSE OF bt-sel-csch IN FRAME Dialog-Frame /* ... */
DO:
 define variable v-rid-list as character no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
DEFINE VARIABLE v-sch-list AS CHARACTER NO-UNDO.
define buffer buf_temp_obj-list for temp_obj-list.
define variable v-host-code like ub.sysconf.host-code no-undo .

    assign
        rs-csch :screen-value  = "2"
    .
    if p-mode = 'shd':U then do:
      find first buf_temp_obj-list no-error .
      if not available buf_temp_obj-list then do:
        message
        "Не выбрана фирма"
        view-as alert-box error .
        return no-apply.
      end.
      assign
      v-host-code = buf_temp_obj-list.obj-code.
    end.
    else do:
      assign
      v-host-code = p-curr-host-code.
    end.
    run ref/finschts.w (
              INPUT parparentproc
              ,INPUT v-host-code
              ,input "b-sel,b-mark":U
              ,input {&company}
              ,input '':U /*p-cli-type*/
              ,input 0 /*p-cli-code*/
              ,input ? /*p-curr-code*/
              ,input v-host-code
              ,input 0 /* p-code-bank */
              ,input-output v-status_
              ,input-output v-rid-list
) no-error.

    run fill-sch-list in this-procedure ( input v-rid-list, INPUT {&company}, OUTPUT v-sch-list ) no-error .
    if error-status :error
    then do:
        return no-apply.
    end.
    ASSIGN
        ed-csch :screen-value = v-sch-list
        ed-csch
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-doc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-doc-type Dialog-Frame
ON CHOOSE OF bt-sel-doc-type IN FRAME Dialog-Frame /* ... */
DO:

    define variable v-cancel     as logical           no-undo.
    define variable v-oper-num   as integer           no-undo.
    define variable v-doc-type-select as character no-undo .
    assign
    v-doc-type-select = "fin-doc-bank":U
    .
    run bge/bgeseltp.w (
          input v-doc-type-select
        , input v-init-doc-type-list
        , output v-doc-type-list
        , output v-cancel
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора типов операций."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = yes
    then do:
        assign
            v-doc-type-list = v-init-doc-type-list
        .
    end.
    else do:
        assign
            v-init-doc-type-list    = v-doc-type-list
        .
        if v-doc-type-list = ''
        then do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "Все"
                ed-doc-type
            .
        end.
        else do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = ''
                ed-doc-type
            .
            do v-oper-num = 1 to 1
            :
                if lookup( v-ext-fin-doc-type-list [v-oper-num * 2], v-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + v-ext-fin-doc-type-list [v-oper-num * 2 - 1] + {&new-line}
                        ed-doc-type
                    .
                end.
            end.

        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-host Dialog-Frame
ON CHOOSE OF bt-sel-host IN FRAME Dialog-Frame /* ... */
DO:
   define variable v-firm-code like ub.sysconf.host-code no-undo .
   DEFINE VARIABLE v-rec-list AS CHARACTER NO-UNDO.
    assign
        rs-1 :screen-value  = "2"
    .
    define buffer buf_sysconf      for ub.sysconf.
    find first buf_sysconf no-lock
         where buf_sysconf.host-code = p-curr-host-code
    no-error .
    if available buf_sysconf
    then do:
          assign
            v-host-list = string( recid( buf_sysconf ) )
        .
    end.
    run adm/sconfs.w (
          input parparentproc
        , input "b-sel":U
        , input no
        , input p-curr-host-code
        , output v-firm-code
        , input-output v-rec-list
    ) no-error.
    run fill-host-list in this-procedure ( input v-rec-list, OUTPUT v-host-list ) no-error .
    if error-status :error
    then do:
        return no-apply.
    end.
    assign
        ed-host :screen-value = v-host-list
        ed-host
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-hsch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-hsch Dialog-Frame
ON CHOOSE OF bt-sel-hsch IN FRAME Dialog-Frame /* ... */
DO:
 define variable v-rid-list as character no-undo.
define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
DEFINE VARIABLE v-sch-list AS CHARACTER NO-UNDO.
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_temp_obj-list for temp_obj-list.

    assign
        rs-hsch :screen-value  = "2"
    .
    if p-mode = 'shd':U then do:
      find first buf_temp_obj-list no-error .
      if not available buf_temp_obj-list then do:
        message
        "Не выбрана фирма"
        view-as alert-box error .
        return no-apply.
      end.
      assign
      v-host-code = buf_temp_obj-list.obj-code.
    end.
    else do:
      assign
      v-host-code = p-curr-host-code.
    end.

        run ref/finschts.w (
                  INPUT parparentproc
                  ,INPUT v-host-code
                  ,input "b-sel,b-mark":U
                  ,input "company-host":U
                  ,input {&cmp} /*p-cli-type*/
                  ,input v-host-code /*p-cli-code*/
                  ,input ? /*p-curr-code*/
                  ,input v-host-code
                  ,input 0 /* p-code-bank */
                  ,input-output v-status_
                  ,input-output v-rid-list
    ) no-error.



    run fill-sch-list in this-procedure ( input v-rid-list, INPUT "company-host", OUTPUT v-sch-list ) no-error .
    if error-status :error
    then do:
        return no-apply.
    end.
    ASSIGN
        ed-hsch :screen-value = v-sch-list
        ed-hsch
    .
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

    if p-mode = 'shd':U then
    assign
    rs-action
    rs-1
    .

    IF rs-format:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
    rs-format
    .
    IF rs-action = 'exp' THEN DO:
        ASSIGN
        t-create
        rs-encoding
        rs-date
        fi-days-amount
        fi-days-ago
        fi-date-from
        fi-date-to

        rs-hsch
        rs-csch
        .
    END.
    IF rs-action = 'imp' THEN DO:
        ASSIGN
        t-create
        t-create-no-th
        rs-encoding
        rs-hsch
        .

    END.
    case rs-1
    :
    when 1
    then do:
        assign
            v-host-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-host-list = ""
        .
        for each temp_obj-list
        :
            assign
                v-host-list = v-host-list
                        + ( if v-host-list = "" then "" else "," ) + temp_obj-list.obj-type
                        + "," + string( temp_obj-list.obj-code )
            .
        end.
    end.
    end case.
    find first temp_obj-list no-error.
    if not available temp_obj-list
    and rs-1 = 2
    then do:
        message
            "Не выбраны фирмы для эксп/имп финдокументов в КЛИЕНТ-БАНК."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    CASE rs-hsch
    :
    when 1
    then do:
        assign
            v-hsch-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-hsch-list = ""
        .
        for each temp_hfin-schet
        :
            assign
                v-hsch-list = v-hsch-list
                        + ( if v-hsch-list = "" then "" else "," )  +  string(temp_hfin-schet.host-code)
                        + "," + temp_hfin-schet.r-schet
                        + "," + string( temp_hfin-schet.cli-type )
                        + "," + string( temp_hfin-schet.cli-code )
                        + "," + string( temp_hfin-schet.code-bank )
                        + "," + string( temp_hfin-schet.code-schet )

            .
        end.
    end.
    end case.
    find first temp_hfin-schet no-error.
    if not available temp_hfin-schet
    and rs-hsch = 2
    then do:
        message
            "Не выбраны счета СВОЕЙ фирмы для эксп/имп финдокументов в КЛИЕНТ-БАНК."
        view-as alert-box warning.
        undo, return no-apply.
    end.

CASE rs-csch
    :
    when 1
    then do:
        assign
            v-csch-list = ""
        .
    end.
    when 2
    then do:
        assign
            v-csch-list = ""
        .
        for each temp_cfin-schet
        :
            assign
                v-csch-list = v-csch-list
                        + ( if v-csch-list = "" then "" else "," ) +  string(temp_cfin-schet.host-code)
                        + "," + temp_cfin-schet.r-schet
                        + "," + string( temp_cfin-schet.cli-type )
                        + "," + string( temp_cfin-schet.cli-code )
                        + "," + string( temp_cfin-schet.code-bank )
                        + "," + string( temp_cfin-schet.code-schet )
            .
        end.
    end.
    end case.
    find first temp_cfin-schet no-error.
    if not available temp_cfin-schet
    and rs-csch = 2
    then do:
        message
            "Не выбраны счета КОНТРАГЕНТОВ для эксп/имп финдокументов в КЛИЕНТ-БАНК."
        view-as alert-box warning.
        undo, return no-apply.
    end.
    CASE rs-date:
      when 0 then do:
      end.
      when 1
      then do:
         if fi-date-from = ? then do:
           message
           "Неверно задана дата начала"
           view-as alert-box error .
           return no-apply.
         end.
      end.
      when 2 then do:
         if fi-date-from > fi-date-to then do:
           message
           "Неверно задан диапазон дат"
           view-as alert-box error .
           return no-apply.
         end.
      end.
    END CASE.

    /*здесь же пишем в параметры для вызова из АРМ взаиморасчеты*/
    run attach-attr-to-schedule-line in this-procedure (
          INPUT rs-format         /* p-rs-format         */
        , INPUT rs-encoding       /* p-rs-encoding       */
        , input rs-date           /* p-rs-date           */
        , input fi-days-amount    /* p-days-amount       */
        , input fi-days-ago       /* p-days-ago          */
        , input fi-date-from      /* p-date-from         */
        , input fi-date-to        /* p-date-to           */
        , input rs-1              /* p-rs-1              */
        , input v-host-list       /* p-loc-object-list   */
        , input v-doc-type-list   /* p-loc-doc-type-list */
        , INPUT rs-action         /* p-rs-action         */
        , INPUT rs-hsch           /* p-rs-hsch           */
        , INPUT v-hsch-list       /* p-loc-hsch-list     */
        , INPUT rs-csch           /* p-rs-csch           */
        , INPUT v-csch-list       /* p-loc-csch-list     */
        , INPUT t-create          /* p-create            */
        , input t-create-no-th    /* p-create-no-th      */

    ).


    APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-date-from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-date-from Dialog-Frame
ON RETURN OF fi-date-from IN FRAME Dialog-Frame /* Дата с */
DO:
    APPLY "ENTRY" TO fi-date-to IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-date-to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-date-to Dialog-Frame
ON RETURN OF fi-date-to IN FRAME Dialog-Frame /* по */
DO:
    APPLY "ENTRY" TO btn_OK IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
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
    run host-select in this-procedure (
        input rs-1
    ) .
    run manage-rs-1 in this-procedure.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-action
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-action Dialog-Frame
ON VALUE-CHANGED OF RS-action IN FRAME Dialog-Frame
DO:
  if rs-action:sensitive in frame {&frame-name} = yes then
  ASSIGN
  rs-action.
  else do:
    display
    rs-action
    with frame {&frame-name} .
  end.
  RUN manage-options IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-csch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-csch Dialog-Frame
ON VALUE-CHANGED OF rs-csch IN FRAME Dialog-Frame
DO:
    assign
        rs-csch
    .
    run cschet-select in this-procedure (
        input rs-csch
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-date Dialog-Frame
ON VALUE-CHANGED OF rs-date IN FRAME Dialog-Frame
DO:
assign
    rs-date
.
run date-select in this-procedure (
    input rs-date
) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-encoding
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-encoding Dialog-Frame
ON VALUE-CHANGED OF RS-encoding IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-encoding.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-format
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-format Dialog-Frame
ON VALUE-CHANGED OF RS-format IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-format.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-hsch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-hsch Dialog-Frame
ON VALUE-CHANGED OF rs-hsch IN FRAME Dialog-Frame
DO:
    assign
        rs-hsch
    .
    run hschet-select in this-procedure (
        input rs-hsch
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-create
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-create Dialog-Frame
ON VALUE-CHANGED OF T-create IN FRAME Dialog-Frame /* Создавать */
DO:
  ASSIGN
  t-create.
  CASE t-create:
  WHEN YES THEN DO:
    ASSIGN
    t-create-no-th = NO.
    DISPLAY
    t-create-no-th
    WITH FRAME {&FRAME-NAME}.
  END.
  WHEN NO THEN DO:
    ASSIGN
    t-create-no-th = YES.
    DISPLAY
    t-create-no-th
    WITH FRAME {&FRAME-NAME}.
  END.
 END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-create-no-th
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-create-no-th Dialog-Frame
ON VALUE-CHANGED OF T-create-no-th IN FRAME Dialog-Frame /* Для отсутствующих */
DO:
  IF INPUT FRAME {&frame-name} t-create-no-th = YES THEN DO:
     IF t-create = YES THEN DO:
        MESSAGE
        "Включена опция СОЗДАВАТЬ ОТСУТСТВУЮЩИЕ ПЛАТЕЖИ"
        VIEW-AS ALERT-BOX ERROR.
        t-create-no-th = NO.
        DISPLAY t-create-no-th
        WITH FRAME {&FRAME-NAME}.
     END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/ed_date.i fi-date-from }
{ gbl/ed_date.i fi-date-to   }

run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).

{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if p-mode = 'shd':U then do:
      assign
      frame {&frame-name} :title = frame {&frame-name} :title +
                          substitute(". &1: Задача номер &2"
                          , p-task-type
                          , p-task-num )
      .
    end.
    if p-curr-host-code = 0 then do:
      { gbl/getcntxt.i get }
      assign
      p-curr-host-code = v-cntxt-host-code-obj.
    end.
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" p-curr-host-code
          skip "Имя фирмы будет отображаться как '" + {&cmp} + string( p-curr-host-code ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box warning.
        assign
            v-host-name = {&cmp} + string( p-curr-host-code )
        .
    end.
    run init-param-values in this-procedure (
          input p-cre-db-num               /* p-cre-db-num        */
        , input p-task-type                /* p-task-type         */
        , input p-task-num                 /* p-task-num          */
        , output fi-days-amount            /* p-days-amount       */
        , output rs-date                   /* p-rs-date           */
        , output fi-days-ago               /* p-days-ago          */
        , output fi-date-from              /* p-date-from         */
        , output fi-date-to                /* p-date-to           */
        , output v-host-list               /* p-host-list         */
        , output v-init-doc-type-list      /* p-loc-doc-type-list */
        , output rs-format                 /* p-rs-format         */
        , output rs-encoding               /* p-rs-encoding       */
        , OUTPUT rs-1                      /* p-rs-1              */
        , output rs-action                 /* p-rs-action         */
        , OUTPUT rs-hsch                   /* p-rs-hsch           */
        , OUTPUT v-hsch-list               /* p-hfin-schet        */
        , OUTPUT rs-csch                   /* p-rs-csch           */
        , OUTPUT v-csch-list               /* p-cfin-schet        */
        , OUTPUT t-create                  /* p-create            */
        , output t-create-no-th            /* p-create-no-th      */
        ).

    run MYenable.

    run host-select in this-procedure (
        input rs-1
    ).
    run date-select in this-procedure (
        input rs-date
    ).

    RUN init-fields in this-procedure .
    apply "value-changed" to rs-action.
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

    define input  parameter p-rs-format          as character no-undo .
    define input  parameter p-rs-encoding        as character no-undo .
    define input  parameter p-rs-date            as integer   no-undo .
    define input  parameter p-days-amount        as integer   no-undo .
    define input  parameter p-days-ago           as integer   no-undo .
    define input  parameter p-date-from          as date      no-undo .
    define input  parameter p-date-to            as date      no-undo .
    define input  parameter p-rs-1               as integer   no-undo .
    define input  parameter p-loc-object-list    as character no-undo .
    define input  parameter p-loc-doc-type-list  as character no-undo .
    define input  parameter p-rs-action          as character no-undo .
    define input  parameter p-rs-hsch            as integer   no-undo .
    define input  parameter p-loc-hsch-list      as character no-undo .
    define input  parameter p-rs-csch            as integer   no-undo .
    define input  parameter p-loc-csch-list      as character no-undo .
    define input  parameter p-create             as logical   no-undo .
    define input  parameter p-create-no-th       as logical   no-undo .

do
on error undo, return error
:

    define variable v-attr-value as character     no-undo.
    define variable v-date-value as character     no-undo.

    define buffer buf_schedule      for ub.schedule.
    define buffer buf_schedule-attr for ub.schedule-attr.
    assign
        v-attr-value =   p-rs-format
                       + {&comma-char} + p-rs-encoding
                       + {&comma-char} + string( p-rs-1 )
                       + {&comma-char} + string( p-curr-host-code )
                       + {&comma-char} + p-rs-action
                       + {&comma-char} + string(p-rs-hsch)
                       + {&comma-char} + string(p-rs-csch)
                       + {&comma-char} + string(p-create)
                       + {&comma-char} + string(p-create-no-th)
    .

    assign
        v-date-value = string( p-rs-date )
                        + "," + string( p-days-amount )
                        + "," + string( p-days-ago    )
                        + "," + (if p-date-from = ? then {&question-mark} else string(p-date-from))
                        + "," + (if p-date-to = ? then {&question-mark} else string(p-date-to))
    .
    CASE p-mode:
      when 'shd':U then do:

          find first buf_schedule no-lock
               where buf_schedule.cre-db-num = p-cre-db-num
                 and buf_schedule.task-type  = p-task-type
                 and buf_schedule.task-num   = p-task-num
          no-error.
          if not available buf_schedule
          and (  p-task-type   <> {&btpr-type-autocbnk}
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
            , input p-loc-object-list
        ).
        run schedule-attr-write in this-procedure (
              input p-cre-db-num
            , input p-task-type
            , input p-task-num
            , input {&attr-schedule-doc-type-list-h}
            , input p-loc-doc-type-list
        ).

        run schedule-attr-write in this-procedure (
              input p-cre-db-num
            , input p-task-type
            , input p-task-num
            , input {&attr-schedule-filter-h}
            , input p-loc-hsch-list
        ).

        run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-filter-2-h}
        , input p-loc-csch-list
    ).

    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-date-list-h}
        , input v-date-value
    ).


        for each buf_schedule-attr
        on error undo, return error
        :
            if buf_schedule-attr.cre-db-num <> p-cre-db-num
            or buf_schedule-attr.task-type  <> {&btpr-type-autocbnk}
            or buf_schedule-attr.task-num   <> -1
            or (
                    buf_schedule-attr.attr-code <> {&attr-schedule-param-list-h}
                and buf_schedule-attr.attr-code <> {&attr-schedule-obj-list-h}
                and buf_schedule-attr.attr-code <> {&attr-schedule-date-list-h}
                and buf_schedule-attr.attr-code <> {&attr-schedule-doc-type-list-h}
                and buf_schedule-attr.attr-code <> {&attr-schedule-filter-h}
                and buf_schedule-attr.attr-code <> {&attr-schedule-filter-2-h}
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
      when 'run':U then do:
        assign
        p-params = v-attr-value
        p-object-list = p-loc-object-list
        p-doc-type-list = p-loc-doc-type-list
        p-hsch-list = p-loc-hsch-list
        p-csch-list = p-loc-csch-list
        p-date-list = v-date-value
        .
      end.
    END CASE.

end.
END PROCEDURE. /* attach-attr-to-schedule-line */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cschet-select Dialog-Frame
PROCEDURE cschet-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-rs-csch   as integer      no-undo.
case p-rs-csch
:
    when 1
    then do:
        assign
            ed-csch :screen-value in frame Dialog-frame = "Все счета контрагентов"
            ed-csch
        .
    end.
    when 2
    then do:
        assign
            ed-csch :screen-value = ""
            ed-csch
        .
        for each temp_cfin-schet
        :
            assign
                ed-csch:screen-value = ed-csch :screen-value
                    + ( if ed-csch :screen-value = "" then "" else ", " )
                    + SUBSTITUTE("&1 &2&3 &4/&5",
                           temp_cfin-schet.r-schet
                          ,temp_cfin-schet.cli-type
                          ,temp_cfin-schet.cli-code
                          ,temp_cfin-schet.code-bank
                          ,temp_cfin-schet.code-schet).
                ed-csch

            .
        end.
    end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE date-select Dialog-Frame
PROCEDURE date-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-date-select-value as integer      no-undo.
    case p-date-select-value
    :
        when 0
        then do:
            hide
                fi-date-from in frame {&frame-name}
                fi-date-to
            .
            view
                fi-days-ago
                fi-days-amount
            .
            display
            fi-days-ago
            fi-days-amount
            with frame {&frame-name} .

        end.
        when 1
        then do:
            hide
                fi-date-to
                fi-days-ago
                fi-days-amount
            .
            view
                fi-date-from
            .
            display
            fi-date-from
            with frame {&frame-name} .

        end.
        when 2
        then do:
            hide
                fi-days-ago
                fi-days-amount
            .
            view
                fi-date-from
                fi-date-to
            .
            display
            fi-date-from
            fi-date-to
            with frame {&frame-name} .
         end.
    end case.
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
  DISPLAY RS-action RS-encoding RS-format ed-host rs-1 rs-hsch ed-hsch T-create
          rs-csch ed-csch T-create-no-th fi-days-amount rs-date fi-days-ago
          fi-date-from fi-date-to ED-doc-type fi-format-select
          fi-encoding-select f-t-create-1 f-t-create-2 f-t-create-3 f-t-create-4
          f-t-create-5 fi-dates-title f-doc-type-label
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK rct-host rct-host-2 rct-host-3 rct-dates Btn_Cancel RS-action
         b-help RS-encoding RS-format rs-1 bt-sel-host rs-hsch T-create
         bt-sel-hsch rs-csch T-create-no-th bt-sel-csch fi-days-amount rs-date
         fi-days-ago fi-date-from fi-date-to ED-doc-type bt-sel-doc-type
         fi-format-select fi-encoding-select
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-host-list Dialog-Frame
PROCEDURE fill-host-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-recid-list as character no-undo.
define output parameter p-host-list as character no-undo.

define variable v-recid-index as integer no-undo.
define variable v-recid          as recid    no-undo.
define buffer buf_sysconf     for ub.sysconf.

for each temp_obj-list:
    delete temp_obj-list.
end.
cre-obj-list:
do v-recid-index = 1 to num-entries( p-recid-list )
:
    find first buf_sysconf
         where recid( buf_sysconf ) = integer( entry( v-recid-index, p-recid-list) )
    no-error.
    if error-status :error
    then do:
        message
        "Не найдена запись sysconf для " p-recid-list
        skip v-recid-index entry( v-recid-index, p-recid-list)
        view-as alert-box.
        next cre-obj-list.
    end.
    create temp_obj-list.
    assign
        temp_obj-list.obj-type = {&cmp}
        temp_obj-list.obj-code = buf_sysconf.host-code
    .
    ASSIGN
    p-host-list = p-host-list + (IF p-host-list = '':U THEN '':U ELSE {&NEW-LINE}) +
                substitute("&1&2",
                           {&cmp}
                           ,buf_sysconf.host-code).



end.


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-sch-list Dialog-Frame
PROCEDURE fill-sch-list :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-recid-list as character no-undo.
define input parameter p-mode as character no-undo.
define OUTPUT parameter p-schet-list as character no-undo.
define variable v-recid-index as integer no-undo.
define variable v-recid          as recid    no-undo.
define buffer buf_fin-schet     for ub.fin-schet.
CASE p-mode:
    WHEN {&company} THEN DO:
        for each temp_cfin-schet:
            delete temp_cfin-schet.
        end.
    END.
    WHEN "company-host" THEN DO:
        for each temp_hfin-schet:
            delete temp_hfin-schet.
        end.

    END.
END CASE.
cre-schet-list:
do v-recid-index = 1 to num-entries( p-recid-list )
:
    find first buf_fin-schet
         where recid( buf_fin-schet ) = integer( entry( v-recid-index, p-recid-list) )
    no-error.
    if error-status :error
    then do:
        message
        "Не найдена запись fin-schet для " p-recid-list
        skip v-recid-index entry( v-recid-index, p-recid-list)
        view-as alert-box.
        next cre-schet-list.
    end.
    ASSIGN
    p-schet-list = p-schet-list + (IF p-schet-list = '':U THEN '':U ELSE {&NEW-LINE}) +
                   substitute("&1 &2&3 &4/&5",
                              buf_fin-schet.r-schet
                              ,buf_fin-schet.cli-type
                              ,buf_fin-schet.cli-code
                              ,buf_fin-schet.code-bank
                              ,buf_fin-schet.code-schet).




     CASE p-mode:
         WHEN {&company} THEN DO:
             create temp_cfin-schet.
             BUFFER-COPY buf_fin-schet TO temp_cfin-schet.
         END.
         WHEN "company-host":U THEN DO:
             create temp_hfin-schet.
             BUFFER-COPY buf_fin-schet TO temp_hfin-schet.

         END.
     END CASE.


end.
END.
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
           and buf_clients.obj-code = p-curr-host-code
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE host-select Dialog-Frame
PROCEDURE host-select :
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
            ed-host :screen-value in frame Dialog-frame = "Все фирмы"
            ed-host
        .
    end.
    when 2
    then do:
        assign
            ed-host :screen-value = ""
            ed-host
        .
        for each temp_obj-list
        :
            assign
                ed-host :screen-value = ed-host :screen-value
                    + ( if ed-host :screen-value = "" then "" else ", " )
                    + temp_obj-list.obj-type + string( temp_obj-list.obj-code )
                ed-host
            .
        end.
    end.
end case.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hschet-select Dialog-Frame
PROCEDURE hschet-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-rs-hsch   as integer      no-undo.
case p-rs-hsch
:
    when 1
    then do:
        assign
            ed-hsch :screen-value in frame Dialog-frame = "Все счета фирмы"
            ed-hsch
        .
    end.
    when 2
    then do:
        assign
            ed-hsch :screen-value = ""
            ed-hsch
        .
        for each temp_hfin-schet
        :

            assign
                ed-hsch:screen-value = ed-hsch :screen-value
                    + ( if ed-hsch :screen-value = "" then "" else {&NEW-LINE} )
                    + SUBSTITUTE("&1 &2&3 &4/&5",
                               temp_hfin-schet.r-schet
                              ,temp_hfin-schet.cli-type
                              ,temp_hfin-schet.cli-code
                              ,temp_hfin-schet.code-bank
                              ,temp_hfin-schet.code-schet)
               ed-hsch.
        end.
    end.
end case.

end.

END PROCEDURE.

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
    run manage-rs-1  in this-procedure.

    assign
        v-doc-type-list = v-init-doc-type-list
    .
    /*
    if v-init-doc-type-list = ?
    OR v-init-doc-type-list = ''
    then do:
        assign
            ed-doc-type :screen-value in frame Dialog-Frame = ""
        .
        do v-oper-num = 1 to 1
        :
            if lookup( v-ext-fin-doc-type-list [v-oper-num * 2], v-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + v-ext-fin-doc-type-list [v-oper-num * 2 - 1] + {&new-line}
                .
            end.
        end.
    end.
    */
    v-oper-num = 1.
    assign
        ed-doc-type :screen-value in frame Dialog-Frame = /*ed-doc-type :screen-value in frame Dialog-Frame
                                    + */   v-ext-fin-doc-type-list [v-oper-num * 2 - 1] + {&new-line}
    v-doc-type-list = v-ext-fin-doc-type-list [v-oper-num * 2]
    ed-doc-type
    .




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

  define input  parameter p-cre-db-num        as integer   no-undo .
  define input  parameter p-task-type         as character no-undo .
  define input  parameter p-task-num          as integer   no-undo .
  define output parameter p-days-amount       as integer   no-undo .
  define output parameter p-rs-date           as integer   no-undo .
  define output parameter p-days-ago          as integer   no-undo .
  define output parameter p-date-from         as date      no-undo .
  define output parameter p-date-to           as date      no-undo .
  define output parameter p-host-list         as character no-undo .
  define output parameter p-loc-doc-type-list as character no-undo .
  define output parameter p-rs-format         as character no-undo .
  define output parameter p-rs-encoding       as character no-undo .
  define output parameter p-rs-1              as integer   no-undo .
  define output parameter p-rs-action         as character no-undo .
  define output parameter p-rs-hsch           as integer   no-undo .
  define output parameter p-hfin-schet        as character no-undo .
  define output parameter p-rs-csch           as integer   no-undo .
  define output parameter p-cfin-schet        as character no-undo .
  define output parameter p-create            as logical   no-undo .
  define output parameter p-create-no-th      as logical   no-undo .

  do
  on error undo, return error
  :



  define variable v-counter       as integer       no-undo.
  define variable v-param-list    as character     no-undo.
  define variable v-date-list     as character no-undo .

  CASE p-mode:
    when 'shd':U then do:

      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-obj-list-h}
          , output p-host-list
          , output v-param-type
      ) .

      run init-host-list in this-procedure (input p-host-list).
      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-param-list-h}
          , output v-param-list
          , output v-param-type
      ) .
      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-filter-h}
          , output p-hfin-schet
          , output v-param-type
      ) .

      run fill-hfin-schet in this-procedure (input p-hfin-schet).

      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-filter-2-h}
          , output p-cfin-schet
          , output v-param-type
      ) .
      run fill-cfin-schet in this-procedure (input p-cfin-schet).

      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-date-list-h}
          , output v-date-list
          , output v-param-type
      ) .

      run schedule-attr-value in this-procedure (
            input p-cre-db-num
          , input p-task-type
          , input p-task-num
          , input {&attr-schedule-doc-type-list-h}
          , output p-loc-doc-type-list
          , output v-param-type
      ) .

    end.
    when 'run':U then do:
      assign
      v-param-list = STRING({&cl-bank-1s}) + {&comma-char} +
                     'ibm866':U + {&comma-char} +
                     string(2) + {&comma-char} +
                     string(p-curr-host-code) + {&comma-char} +
                     p-action + {&comma-char} +
                     string(1) + {&comma-char} +
                     string(1) + {&comma-char} +
                     string(no) + {&comma-char}
     .
    end.
  END CASE.
    if v-param-list = ""
    or p-mode = 'run':U
    then do:

        assign
        p-rs-format             = {&cl-bank-1s}
        p-rs-encoding           = 'ibm866'
        p-rs-1                  = (if p-mode = 'run' then 2 else 1)
        v-host-list             = (if p-mode = 'run'
                                   then  substitute("&1&2"
                                                  ,{&cmp}
                                                  ,p-curr-host-code)
                                   else '':U)
        p-rs-action             = p-action
        p-rs-hsch               = 1
        p-rs-csch               = 1
        p-create               = NO
        p-create-no-th         = yes
        p-rs-action            = p-action
        .
       if p-mode = 'run':U then do:
          create temp_obj-list.
          assign
          temp_obj-list.obj-type = {&cmp}
          temp_obj-list.obj-code = p-curr-host-code
          .
          release temp_obj-list.
        end.
    end.
    else do:
        assign
        p-rs-encoding = entry( 2, v-param-list)
        p-rs-1 = integer( entry( 3, v-param-list) )
        p-rs-action =  entry( 5, v-param-list )
        p-rs-hsch = integer( entry( 6, v-param-list ) )
        p-rs-csch = integer( entry( 7, v-param-list ) )
        p-create = logical( entry( 8, v-param-list ) )
        p-create-no-th = (if num-entries(v-param-list) > 8
                          and not p-create
                          then logical( entry( 9, v-param-list ) )
                          else no)
        .
    end.
    if v-date-list = ""
    then do:
        define variable v-today as date      no-undo.
        define variable v-time  as integer   no-undo.

        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign
            p-rs-date       = 0
            p-days-amount   = 1
            p-days-ago      = 0
            p-date-from     = v-today - 1
            p-date-to       = v-today - 1
        .
    end.
    else do:

        assign
            p-rs-date       = integer( entry( 1, v-date-list ) )
            p-days-amount   = integer( entry( 2, v-date-list ) )
            p-days-ago      = integer( entry( 3, v-date-list ) )
            p-date-from     = date( entry( 4, v-date-list ) )
            p-date-to       = date( entry( 5, v-date-list ) )
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
    rct-host          :visible in frame {&frame-name} = no
    rct-host-2        :visible in frame {&frame-name} = no
    rct-host-3        :visible in frame {&frame-name} = no
    rs-1              :visible in frame {&frame-name} = no
    bt-sel-host       :visible in frame {&frame-name} = no
    ed-host           :visible in frame {&frame-name} = no
    ed-doc-type       :visible in frame {&frame-name} = no
    bt-sel-doc-type   :visible in frame {&frame-name} = no
    rs-hsch           :visible in frame {&frame-name} = no
    bt-sel-hsch       :visible in frame {&frame-name} = no
    ed-hsch           :visible in frame {&frame-name} = no
    rs-csch           :visible in frame {&frame-name} = no
    bt-sel-csch       :visible in frame {&frame-name} = no
    ed-csch           :visible in frame {&frame-name} = no
    rct-dates           :visible in frame {&frame-name} = no
    fi-dates-title      :visible in frame {&frame-name} = no
    rs-date             :visible in frame {&frame-name} = no
    fi-days-amount      :visible in frame {&frame-name} = no
    fi-days-ago         :visible in frame {&frame-name} = no
    fi-date-from        :visible in frame {&frame-name} = no
    fi-date-to          :visible in frame {&frame-name} = no
    f-doc-type-label    :visible in frame {&frame-name} = no
    t-create            :visible in frame {&frame-name} = no
    f-t-create-1        :visible in frame {&frame-name} = no
    f-t-create-2        :visible in frame {&frame-name} = no
    t-create-no-th      :visible in frame {&frame-name} = no
    f-t-create-3        :visible in frame {&frame-name} = no
    f-t-create-4        :visible in frame {&frame-name} = no
    f-t-create-5        :visible in frame {&frame-name} = no    
.
if rs-action = "exp" then do:
    assign
    rct-host          :visible in frame {&frame-name} = yes
    rct-host-2        :visible in frame {&frame-name} = yes
    rct-host-3        :visible in frame {&frame-name} = yes
    rs-1              :visible in frame {&frame-name} = yes
    bt-sel-host       :visible in frame {&frame-name} = yes
    ed-host           :visible in frame {&frame-name} = yes
    ed-doc-type       :visible in frame {&frame-name} = yes
    bt-sel-doc-type   :visible in frame {&frame-name} = yes
    rs-hsch           :visible in frame {&frame-name} = YES
    ed-hsch           :visible in frame {&frame-name} = YES
    rs-csch           :visible in frame {&frame-name} = YES
    ed-csch           :visible in frame {&frame-name} = YES
    f-doc-type-label  :visible in frame {&frame-name} = YES
    rct-dates           :visible in frame {&frame-name} = yes
    fi-dates-title      :visible in frame {&frame-name} = yes
    rs-date             :visible in frame {&frame-name} = yes
    fi-days-amount      :visible in frame {&frame-name} = yes
    fi-days-ago         :visible in frame {&frame-name} = yes
    fi-date-from        :visible in frame {&frame-name} = yes
    fi-date-to          :visible in frame {&frame-name} = yes
    bt-sel-hsch       :visible in frame {&frame-name} = yes
    bt-sel-csch       :visible in frame {&frame-name} = yes
    .

    run host-select in this-procedure (
    input rs-1
     ).

    run hschet-select in this-procedure (
    input rs-hsch
     ).

    run cschet-select in this-procedure (
    input rs-csch
     ).

    run date-select in this-procedure (
        input rs-date
    ).
    RUN manage-rs-1 IN THIS-PROCEDURE.
    enable
    rs-1 when p-mode = 'shd':U
    bt-sel-host when p-mode = 'shd':U
    ed-host     when p-mode = 'shd':U
    ed-doc-type
    /*bt-sel-doc-type*/
    ed-hsch
    ed-csch
    rs-date
    with frame {&frame-name} .
    DISPLAY
    rs-encoding
    rs-1
    f-doc-type-label
    fi-dates-title
    ed-host     when p-mode = 'shd':U
    ed-doc-type
    ed-hsch
    ed-csch
    rs-date
    with frame {&frame-name} .

end.
if rs-action = "imp" then do:
    ASSIGN
    rct-host          :visible in frame {&frame-name} = yes
    rct-host-2        :visible in frame {&frame-name} = yes
    bt-sel-host       :visible in frame {&frame-name} = yes
    rs-hsch           :visible in frame {&frame-name} = YES
    ed-hsch           :visible in frame {&frame-name} = YES
    rs-1              :visible in frame {&frame-name} = yes
    ed-host           :visible in frame {&frame-name} = yes
    t-create            :visible in frame {&frame-name} = YES
    f-t-create-1        :visible in frame {&frame-name} = YES
    f-t-create-2        :visible in frame {&frame-name} = YES
    t-create-no-th      :visible in frame {&frame-name} = YES
    f-t-create-3        :visible in frame {&frame-name} = YES
    f-t-create-4        :visible in frame {&frame-name} = YES
    f-t-create-5        :visible in frame {&frame-name} = YES
    bt-sel-hsch       :visible in frame {&frame-name} = yes
    .
    run host-select in this-procedure (
    input rs-1
     ).

    run hschet-select in this-procedure (
    input rs-hsch
     ).

    RUN manage-rs-1 IN THIS-PROCEDURE.
    enable
    rs-1 when p-mode = 'shd':U
    bt-sel-host when p-mode = 'shd':U
    ed-host     when p-mode = 'shd':U
    ed-hsch
    t-create
    t-create-no-th
    with frame {&frame-name} .
    if p-mode = 'run' then do:
      display
      rs-1
      with frame {&frame-name} .
    end.
    DISPLAY
    f-t-create-1
    f-t-create-2
    f-t-create-3
    f-t-create-4
    f-t-create-5
    rs-1
    t-create
    t-create-no-th
    ed-host     when p-mode = 'shd':U
    ed-hsch
    rs-encoding
    with frame {&frame-name} .

END.
end.
END PROCEDURE. /* manage-options */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-rs-1 Dialog-Frame
PROCEDURE manage-rs-1 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
 if rs-1 = 1
    then do:
        assign
        rs-hsch = 1
        rs-hsch :sensitive in frame {&frame-name} = NO
        bt-sel-hsch:sensitive in frame {&frame-name} = NO
        .
        display
        rs-hsch
        with frame {&frame-name} .
        run hschet-select in this-procedure (
            input rs-hsch
        ) .

        if rs-action = 'exp' then do:
          assign
          rs-csch = 1
          rs-csch :sensitive in frame {&frame-name} = NO
          bt-sel-csch:sensitive in frame {&frame-name} = NO
          .
          display
          rs-csch
          with frame {&frame-name} .
          run cschet-select in this-procedure (
              input rs-csch
          ) .
        end.
    end.
    else do:
        assign
        rs-hsch :sensitive in frame {&frame-name} = YES
        bt-sel-hsch:sensitive in frame {&frame-name} = YES
        .
        display
        rs-hsch
        with frame {&frame-name} .
        run hschet-select in this-procedure (
            input rs-hsch
        ) .
        if rs-action = 'exp' then do:
          assign
          rs-csch :sensitive in frame {&frame-name} = YES
          bt-sel-csch:sensitive in frame {&frame-name} = YES
          .
          display
          rs-csch
          with frame {&frame-name} .
          run cschet-select in this-procedure (
              input rs-csch
          ) .
        end.
    end.
    DISPLAY
    rs-hsch
    rs-csch when rs-action = 'exp'
    WITH FRAME {&FRAME-NAME}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
dEFINE variable ii                      as INTEGER       no-undo.
dEFINE VARIABLE v-dop AS CHARACTER NO-UNDO.
&SCOPED-DEFINE cl-bank-code ENTRY(ii, ~{&cl-bank-codes~})
DO ii = 1 TO NUM-ENTRIES({&cl-bank-codes}):
    ASSIGN
    v-dop = v-dop + (IF v-dop = '':U THEN '':U ELSE {&comma-char}) +
            {&cl-bank-name} + {&comma-char} + ENTRY(ii, {&cl-bank-codes})  .
END.
rs-format:RADIO-BUTTONS IN FRAME {&frame-name} = v-dop.

if p-mode = 'shd':U then do:
  if rs-action = '':U
  or rs-action = ?
  then rs-action = 'exp'.
  DISPLAY
  rs-action
  fi-format-select
  fi-encoding-select
  WITH FRAME {&frame-name}.
end.
ENABLE
Btn_OK
Btn_Cancel
b-help
rs-action when p-mode = 'shd':U
fi-days-amount
rs-date
fi-days-ago
fi-date-from
fi-date-to
rs-encoding
rs-format

WITH FRAME {&frame-name}.
ASSIGN
rs-format = {&cl-bank-1s}.
DISABLE
rs-format
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME