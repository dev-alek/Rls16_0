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

Интерфейс плана-меню или счет-заказа.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-mode       as character -  режим работы:
                                    {&add-def} - добавление

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-list-procedure as handle           no-undo.
define input parameter p-mode           as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-userid         as character        no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Интерфейс плана-меню или счет-заказа.":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/library.i  }
{ str/fbrpln.i   }
{ gbl/cur-time.i }
{ str/fbrhist.i  }
{ str/trdcalib.i }
{ str/fbrattr.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

    define variable v-fbr-pln-history-level     as integer      no-undo.
    define variable v-fbr-pln-hst-upper-code    as integer      no-undo.
    define variable v-fbr-pln-fbroperator-code  as integer      no-undo.
    define variable gds-rec                     as recid        no-undo.

    define buffer buf_init_fbr-pln       for fbr-pln.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-table

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES fbr-pln-line goods

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table fbr-pln-line.artic ~
fbr-pln-line.gds-code goods.gds-name fbr-pln-line.recipe-code ~
fbr-pln-line.fact-qnty fbr-pln-line.fbr-obj-type fbr-pln-line.fbr-obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define QUERY-STRING-br-table FOR EACH fbr-pln-line ~
      WHERE fbr-pln-line.doc-code = p-doc-code NO-LOCK, ~
      EACH goods WHERE goods.gds-code = fbr-pln-line.gds-code NO-LOCK ~
    BY fbr-pln-line.line-num
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH fbr-pln-line ~
      WHERE fbr-pln-line.doc-code = p-doc-code NO-LOCK, ~
      EACH goods WHERE goods.gds-code = fbr-pln-line.gds-code NO-LOCK ~
    BY fbr-pln-line.line-num.
&Scoped-define TABLES-IN-QUERY-br-table fbr-pln-line goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-table fbr-pln-line
&Scoped-define SECOND-TABLE-IN-QUERY-br-table goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit bt-fbr-docs b-help bt-billord b-wrkr ~
br-table b-add b-lkp b-chg b-del
&Scoped-Define DISPLAYED-OBJECTS fi-object fi-date fi-fact-date fi-customer ~
fi-wrkr fi-guest-amount

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON bt-billord
     LABEL "Заказ"
     SIZE 10 BY 1.

DEFINE BUTTON bt-fbr-docs
     LABEL "Произв"
     SIZE 10 BY 1.

DEFINE BUTTON bt-next
     LABEL ">>"
     SIZE 4 BY 1.

DEFINE BUTTON bt-prev
     LABEL "<<"
     SIZE 4 BY 1.

DEFINE VARIABLE fi-customer AS CHARACTER FORMAT "X(256)":U
     LABEL "Заказчик"
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE fi-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fact-date AS DATE FORMAT "99/99/9999":U
     LABEL "Факт"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-guest-amount AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Кол. гостей"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE fi-object AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-wrkr AS CHARACTER FORMAT "X(256)":U
     LABEL "Исполнитель"
     VIEW-AS FILL-IN
     SIZE 35 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      fbr-pln-line,
      goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      fbr-pln-line.artic FORMAT "X(16)":U
      fbr-pln-line.gds-code FORMAT "999999999":U
      goods.gds-name FORMAT "X(35)":U
      fbr-pln-line.recipe-code COLUMN-LABEL "Рецепт" FORMAT "X(8)":U
      fbr-pln-line.fact-qnty FORMAT "->>,>>>,>>9.<<<":U
      fbr-pln-line.fbr-obj-type COLUMN-LABEL "Тип" FORMAT "X(3)":U
      fbr-pln-line.fbr-obj-code COLUMN-LABEL "Код" FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 15.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.5
     bt-prev AT ROW 1 COL 11.5
     bt-next AT ROW 1 COL 15.5
     bt-fbr-docs AT ROW 1 COL 19.5
     b-help AT ROW 1.21 COL 88.63
     fi-object AT ROW 2.58 COL 12.88 COLON-ALIGNED
     bt-billord AT ROW 2.58 COL 69
     fi-date AT ROW 3.71 COL 12.88 COLON-ALIGNED
     fi-fact-date AT ROW 3.71 COL 33.75 COLON-ALIGNED
     fi-customer AT ROW 3.71 COL 67 COLON-ALIGNED
     fi-wrkr AT ROW 4.79 COL 12.88 COLON-ALIGNED
     fi-guest-amount AT ROW 4.79 COL 67 COLON-ALIGNED
     b-wrkr AT ROW 4.83 COL 50.5
     br-table AT ROW 6.38 COL 1.63
     b-add AT ROW 22.21 COL 2.38
     b-lkp AT ROW 22.21 COL 12.38
     b-chg AT ROW 22.21 COL 22.38
     b-del AT ROW 22.21 COL 32.38
     SPACE(56.59) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ план-меню".


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
/* BROWSE-TAB br-table b-wrkr Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON bt-next IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-prev IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-customer IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-fact-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-guest-amount IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-wrkr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "ub.fbr-pln-line,ub.goods WHERE ub.fbr-pln-line ..."
     _Options          = "NO-LOCK"
     _OrdList          = "ub.fbr-pln-line.line-num|yes"
     _Where[1]         = "fbr-pln-line.doc-code = p-doc-code"
     _JoinCode[2]      = "goods.gds-code = fbr-pln-line.gds-code"
     _FldNameList[1]   = ub.fbr-pln-line.artic
     _FldNameList[2]   = ub.fbr-pln-line.gds-code
     _FldNameList[3]   > ub.goods.gds-name
"goods.gds-name" ? "X(35)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > ub.fbr-pln-line.recipe-code
"fbr-pln-line.recipe-code" "Рецепт" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   = ub.fbr-pln-line.fact-qnty
     _FldNameList[6]   > ub.fbr-pln-line.fbr-obj-type
"fbr-pln-line.fbr-obj-type" "Тип" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[7]   > ub.fbr-pln-line.fbr-obj-code
"fbr-pln-line.fbr-obj-code" "Код" ">>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Документ план-меню */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
    run add-doc in this-procedure (
          input p-doc-code
        , output p-doc-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка добавления в план-меню или счет-заказ."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-cancel            as logical      no-undo.
    define variable v-cancel-cycle      as logical      no-undo.

    if available fbr-pln-line
    then do:
        assign
            v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-table" )
        .
        run change-doc in this-procedure (
              input fbr-pln-line.doc-code
            , input fbr-pln-line.gds-code
            , input fbr-pln-line.recipe-code
            , input fbr-pln-line.fbr-obj-type
            , input fbr-pln-line.fbr-obj-code
            , input fbr-pln-line.fact-qnty
            , output v-cancel
            , output v-cancel-cycle
        ).
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
        br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
        reposition br-table to row v-repositioned-row.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
    define variable v-deleted    as logical        no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.

    if available fbr-pln-line
    then do:
        assign
            v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-table" )
        .
        run delete-doc in this-procedure (
              input fbr-pln-line.doc-code
            , input fbr-pln-line.gds-code
            , input fbr-pln-line.recipe-code
            , output v-deleted
        ).
        if v-deleted = yes
        then do:
            {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
            br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
            reposition br-table to row v-repositioned-row.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    define variable v-have-error     as logical        no-undo.
    define variable v-error-text     as character      no-undo.

    assign
        fi-customer
        fi-guest-amount
    .
    run check-fbr-pln in this-procedure (
          output v-have-error
        , output v-error-text
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка проверки введенных данных."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-have-error
    then do:
        message
            "Ошибка введенных данных документа."
            skip(1)
            skip v-error-text
            skip(1)
            "Исправьте неверные данные."
        view-as alert-box error.
        undo, return no-apply .
    end.
    if p-mode = {&update}
    or p-mode = {&add-def}
    then do:
        run assign-data-for-exit in this-procedure (
              input fi-customer
            , input fi-guest-amount
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка записи введенных данных."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
    apply "GO" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
or mouse-select-dblclick of br-table in frame dialog-frame
DO:
    if available fbr-pln-line
    then do:
        run view-doc in this-procedure (
              input fbr-pln-line.doc-code
            , input fbr-pln-line.gds-code
            , input fbr-pln-line.recipe-code
            , input fbr-pln-line.fbr-obj-type
            , input fbr-pln-line.fbr-obj-code
            , input fbr-pln-line.fact-qnty
        ).
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-wrkr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-wrkr Dialog-Frame
ON CHOOSE OF b-wrkr IN FRAME Dialog-Frame
DO:
    { gbl/stdbtn.i }
    /* установка режима справочника */
    run select-fbroperator in this-procedure (
        output fi-wrkr
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора оператора документа план-меню."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    display
        fi-wrkr
    with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-billord
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-billord Dialog-Frame
ON CHOOSE OF bt-billord IN FRAME Dialog-Frame /* Заказ */
DO:
{ gbl/stdbtn.i }
    if fi-customer :sensitive = yes
    and fi-customer :screen-value = ""
    and fi-guest-amount :screen-value = "0"
    then do:
        assign
            fi-customer     :sensitive     = no
            fi-guest-amount :sensitive = no
        .
    end.
    else do:
        assign
            fi-customer     :sensitive     = yes
            fi-guest-amount :sensitive = yes
        .
        apply "entry" to fi-customer.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-fbr-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-fbr-docs Dialog-Frame
ON CHOOSE OF bt-fbr-docs IN FRAME Dialog-Frame /* Произв */
DO:
    run str/fbrplndf.w (
          input parparentproc
        , input p-doc-code
        , input p-obj-type
        , input p-obj-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка списка документов производства."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-next Dialog-Frame
ON CHOOSE OF bt-next IN FRAME Dialog-Frame /* >> */
DO:
    run go-to-doc in this-procedure (
        input 'next':U
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка перехода к следующей записи."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-prev Dialog-Frame
ON CHOOSE OF bt-prev IN FRAME Dialog-Frame /* << */
DO:
    run go-to-doc in this-procedure (
        input 'prev':U
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка перехода к предыдущей записи."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }
{ gbl/f2.i br-table " " " " parparentproc  }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    run init-fields in this-procedure.
    RUN enable_UI.
    run ui-disable-all in this-procedure.
    run ui-enable in this-procedure.
    apply "entry" to br-table.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-doc Dialog-Frame
PROCEDURE add-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define output parameter p-out-doc-code  as character    no-undo.

    define variable v-artic             as character      no-undo.
    define variable v-goods-recid-list  as character      no-undo.
    define variable v-counter           as integer        no-undo.
    define variable v-goods-recid       as recid          no-undo.
    define variable v-recipe-recid-list as character      no-undo.
    define variable v-recipe-code       as character      no-undo.
    define variable v-qnty              as decimal        no-undo.
    define variable v-host-code         as integer        no-undo.
    define variable v-yesno             as logical        no-undo.
    define variable v-add-goods         as logical        no-undo.
    define variable v-cancel            as logical        no-undo.
    define variable v-cancel-cycle      as logical        no-undo.
    define variable v-upper-code        as integer      no-undo.

    define buffer buf_goods         for goods.
    define buffer buf_recipe        for recipe.
    define buffer buf_fbr-gds-obj   for fbr-gds-obj.
    define buffer buf_fbr-pln-line  for fbr-pln-line.

    { gbl/hostcode.i
        p-obj-type
        p-obj-code
        v-host-code
    }
    if p-doc-code = ""
    then do:
        run fbrpln-create-doc in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input {&plnmenu}
            , input ( v-cntxt-db-num <> 0 )
            , input v-cntxt-userid
            , output p-doc-code
        ).
        find first buf_init_fbr-pln no-lock
             where buf_init_fbr-pln.doc-code = p-doc-code
        .
        assign
            frame {&frame-name} :title = substitute( "Документ план-меню N &1 от &2", buf_init_fbr-pln.doc-code, buf_init_fbr-pln.doc-date )
        .
        run fbrhist-write in p-list-procedure (
              input v-cntxt-userid
            , input buf_init_fbr-pln.obj-type
            , input buf_init_fbr-pln.obj-code
            , input {&fbrhist-type-create-doc}
            , input 1
            , input "add-doc"
            , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
            , input p-doc-code
            , input {&plnmenu}
            , input {&g___new}
            , input no
            , input ""
            , input ""
            , input 0
            , input ""
            , input 0
            , input ""
            , input no
        ).
    end.        /* if p-doc-code = "" */
    assign
        p-out-doc-code = p-doc-code
    .
    run str/chs-gds.w (
          input parparentproc
        , input p-obj-type
        , input p-obj-code
        , input '':U
        , input '':U
        , input "План-меню: " + string( p-doc-code )
        , input {&g___object}       /* режим вызова справочника */
        , input ?
        , input ?
        , input ?
        , input ?
        , input-output v-artic
        , output v-goods-recid-list
    ) .
    run fbrhist-write in p-list-procedure (
          input v-cntxt-userid
        , input buf_init_fbr-pln.obj-type
        , input buf_init_fbr-pln.obj-code
        , input {&fbrhist-type-add-goods}
        , input 3
        , input "add-doc"
        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
        , input p-doc-code
        , input {&plnmenu}
        , input {&g___new}
        , input no
        , input ""
        , input ""
        , input 0
        , input ""
        , input 0
        , input substitute( "Выбрано &1 товаров для добавления в план-меню.", num-entries( v-goods-recid-list ) )
        , input no
    ).
    if v-goods-recid-list <> ''
    then do:
        assign
            v-counter   = 1
        .
        cycle-by-goods:
        do
        while v-counter <= num-entries ( v-goods-recid-list )
        :
            assign
                v-goods-recid   = integer( entry ( v-counter, v-goods-recid-list ) )
                v-counter       = v-counter + 1
            .
            find first buf_goods no-lock
                 where recid( buf_goods ) = v-goods-recid
            .
            find first buf_fbr-pln-line no-lock
                 where buf_fbr-pln-line.doc-code    = p-doc-code
                   and buf_fbr-pln-line.artic       = buf_goods.artic
                   and buf_fbr-pln-line.prod-type   = buf_goods.prod-type
                   and buf_fbr-pln-line.prod-code   = buf_goods.prod-code
            no-error.
            if available buf_fbr-pln-line
            then do:
                message
                    skip "Товар уже включен в план-меню."
                    skip "Товар: " buf_goods.artic buf_goods.gds-name
                view-as alert-box error.
                next cycle-by-goods.
            end.        /* if available buf_fbr-pln-line */
            transaction-block:
            do transaction
            on error undo, return error
            :
                find first buf_recipe no-lock
                     where buf_recipe.obj-type  = p-obj-type
                       and buf_recipe.obj-code  = p-obj-code
                       and buf_recipe.artic     = buf_goods.artic
                       and buf_recipe.prod-type = buf_goods.prod-type
                       and buf_recipe.prod-code = buf_goods.prod-code
                no-error.
                if not available buf_recipe
                then do:
                    find first buf_recipe no-lock
                         where buf_recipe.obj-type  = ""
                           and buf_recipe.obj-code  = 0
                           and buf_recipe.artic     = buf_goods.artic
                           and buf_recipe.prod-type = buf_goods.prod-type
                           and buf_recipe.prod-code = buf_goods.prod-code
                    no-error.
                end.
                if available buf_recipe
                then do:        /* У товара есть рецепты - надо указать, по какому рецепту. */
                    find first buf_fbr-gds-obj no-lock
                         where buf_fbr-gds-obj.obj-type = p-obj-type
                           and buf_fbr-gds-obj.obj-code = p-obj-code
                           and buf_fbr-gds-obj.gds-code = buf_goods.gds-code
                    no-error.
                    if not available buf_fbr-gds-obj
                    or ( buf_fbr-gds-obj.fbr-obj-type = ""
                       and buf_fbr-gds-obj.fbr-obj-code = 0 )
                    then do:
                        message
                            skip "Не задан объект для производства товара с рецептом."
                            skip "Товар: " buf_goods.artic buf_goods.gds-name
                            skip(1)
                            skip "Товар не может быть включен в план-меню."
                            skip(1)
                            skip "Необходимо определить атрибуты товара для ресторана."
                        view-as alert-box error.
                        run fbrhist-write in p-list-procedure (
                              input v-cntxt-userid
                            , input buf_init_fbr-pln.obj-type
                            , input buf_init_fbr-pln.obj-code
                            , input {&fbrhist-type-read-ref}
                            , input 2
                            , input "add-doc"
                            , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                            , input p-doc-code
                            , input {&plnmenu}
                            , input {&g___new}
                            , input no
                            , input ""
                            , input ""
                            , input buf_goods.gds-code
                            , input ""
                            , input 0
                            , input "Не задан объект для производства товара с рецептом (атрибут товара на ресторане)."
                            , input yes
                        ).
                        undo transaction-block, next cycle-by-goods.
                    end.
                    assign
                        v-add-goods = no
                    .
                    do while v-add-goods = no
                    :
                        run ref/rcp-all.w (
                              input parparentproc
                            , input "b-add,b-sel"
                            , input {&all}
                            , input recid( buf_goods )
                            , input p-obj-type
                            , input p-obj-code
                            , output v-recipe-recid-list
                        ) no-error.
                        if error-status :error
                        or v-recipe-recid-list = ""
                        then do:
                            message
                                "Отменить добавление товара?"
                                skip(1)
                                skip "Товар:" buf_goods.artic buf_goods.gds-name
                                skip(1)
                                skip "Yes - отменить добавление текущего товара"
                                skip "No  - отменить добавление всех товаров списка"
                                skip "Cancel - вернуться к выбору рецепта"
                            view-as alert-box question
                            buttons yes-no-cancel
                            title "Отмена"
                            update v-yesno
                            .
                            case v-yesno
                            :
                                when yes
                                then do:
                                    run fbrhist-write in p-list-procedure (
                                          input v-cntxt-userid
                                        , input buf_init_fbr-pln.obj-type
                                        , input buf_init_fbr-pln.obj-code
                                        , input {&fbrhist-type-user-select}
                                        , input 2
                                        , input "add-doc"
                                        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                                        , input p-doc-code
                                        , input {&plnmenu}
                                        , input {&g___new}
                                        , input no
                                        , input ""
                                        , input ""
                                        , input buf_goods.gds-code
                                        , input ""
                                        , input 0
                                        , input "Отменено добавление товара списка."
                                        , input no
                                    ).
                                    undo transaction-block, next cycle-by-goods.
                                end.        /* when yes */
                                when no
                                then do:
                                    run fbrhist-write in p-list-procedure (
                                          input v-cntxt-userid
                                        , input buf_init_fbr-pln.obj-type
                                        , input buf_init_fbr-pln.obj-code
                                        , input {&fbrhist-type-user-select}
                                        , input 2
                                        , input "add-doc"
                                        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                                        , input p-doc-code
                                        , input {&plnmenu}
                                        , input {&g___new}
                                        , input no
                                        , input ""
                                        , input ""
                                        , input buf_goods.gds-code
                                        , input ""
                                        , input 0
                                        , input "Отменено добавление всех товаров, выбранных в списке."
                                        , input no
                                    ).
                                    undo transaction-block, leave cycle-by-goods.
                                end.        /* when no */
                            end case.       /* case v-yesno */
                        end.
                        else do:
                            assign
                                v-add-goods = yes
                            .
                        end.
                    end.        /* do while v-add-goods = no */
                    find first buf_recipe no-lock
                         where recid( buf_recipe ) = integer( entry( 1, v-recipe-recid-list ) )
                    .
                    run fbrpln-create-line in this-procedure (
                          input p-doc-code
                        , input buf_goods.gds-code
                        , input buf_recipe.recipe-code
                        , input buf_fbr-gds-obj.fbr-obj-type
                        , input buf_fbr-gds-obj.fbr-obj-code
                        , input no
                        , input v-qnty
                    ).
                    run fbrhist-write in p-list-procedure (
                          input v-cntxt-userid
                        , input buf_init_fbr-pln.obj-type
                        , input buf_init_fbr-pln.obj-code
                        , input {&fbrhist-type-create-line}
                        , input 2
                        , input "add-doc"
                        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                        , input p-doc-code
                        , input {&plnmenu}
                        , input {&g___new}
                        , input no
                        , input buf_recipe.recipe-code
                        , input buf_recipe.recipe-type
                        , input buf_goods.gds-code
                        , input ""
                        , input v-qnty
                        , input ""
                        , input no
                    ).
                    run change-doc in this-procedure (
                          input p-doc-code
                        , input buf_goods.gds-code
                        , input buf_recipe.recipe-code
                        , input ""
                        , input 0
                        , input 0
                        , output v-cancel
                        , output v-cancel-cycle
                    ).
                    if v-cancel-cycle = yes
                    then do:
                        undo transaction-block, leave cycle-by-goods.
                    end.
                    if v-cancel = yes
                    then do:
                        undo transaction-block, next cycle-by-goods.
                    end.
                end.        /* if available buf_recipe */
                else do:        /* У товара рецептов нет - просто добавить его в документ. */
                    run fbrpln-create-line in this-procedure (
                          input p-doc-code
                        , input buf_goods.gds-code
                        , input ""                   /* recipe-code */
                        , input ""
                        , input 0
                        , input no
                        , input v-qnty
                    ).
                    run fbrhist-write in p-list-procedure (
                          input v-cntxt-userid
                        , input buf_init_fbr-pln.obj-type
                        , input buf_init_fbr-pln.obj-code
                        , input {&fbrhist-type-create-line}
                        , input 2
                        , input "add-doc"
                        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                        , input p-doc-code
                        , input {&plnmenu}
                        , input {&g___new}
                        , input no
                        , input ""
                        , input ""
                        , input buf_goods.gds-code
                        , input ""
                        , input v-qnty
                        , input ""
                        , input no
                    ).
                    run change-doc in this-procedure (
                          input p-doc-code
                        , input buf_goods.gds-code
                        , input ""
                        , input ""
                        , input 0
                        , input 0
                        , output v-cancel
                        , output v-cancel-cycle
                    ).
                    if v-cancel-cycle = yes
                    then do:
                        undo transaction-block, leave cycle-by-goods.
                    end.
                    if v-cancel = yes
                    then do:
                        undo transaction-block, next cycle-by-goods.
                    end.
                end.        /* NOT ( if available buf_recipe ) */
            end.        /* do transaction */
        end.        /* do while v-counter <= num-entries ( v-goods-recid-list ) */
    end.        /* if v-goods-recid-list <> '' */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-data-for-exit Dialog-Frame
PROCEDURE assign-data-for-exit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-customer       as character    no-undo.
define input parameter p-guest-amount   as integer      no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
do
for buf_fbr-pln
on error undo, return error
:
    find first buf_fbr-pln exclusive-lock
         where buf_fbr-pln.doc-code = p-doc-code
    no-error.
    if available buf_fbr-pln
    then do:
        assign
            buf_fbr-pln.customer     = p-customer
            buf_fbr-pln.guest-amount = p-guest-amount
        .
        run fbrattr-write in this-procedure (
              input {&fbrattr-type-fbr-pln}
            , input p-doc-code
            , input {&trdcattr-fbroperator}
            , input string( v-fbr-pln-fbroperator-code )
        ) no-error.
        run str/fbrattrw.p (
              input p-doc-code
            , input {&trdcattr-fbroperator}
            , input string( v-fbr-pln-fbroperator-code )
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Не удалось записать оператора производства."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box warning.
        end.
    end.
end.
END PROCEDURE. /* assign-data-for-exit */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-doc Dialog-Frame
PROCEDURE change-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-fact-qnty      as decimal      no-undo.
define output parameter p-cancel        as logical      no-undo.
define output parameter p-cancel-cycle  as logical      no-undo.

    define variable v-new-obj-type      as character    no-undo.
    define variable v-new-obj-code      as integer      no-undo.
    define variable v-new-recipe-code   as character    no-undo.
    define variable v-new-fact-qnty     as decimal      no-undo.
    define variable v-log-string        as character    no-undo.
    define variable v-upper-code        as integer      no-undo.

    define buffer buf_fbr-pln-line      for fbr-pln-line.

    run str/fbrplnd.w (
          input parparentproc
        , input {&update}
        , input p-doc-code
        , input p-gds-code
        , input p-recipe-code
        , input p-obj-type
        , input p-obj-code
        , input p-fact-qnty
        , output v-new-recipe-code
        , output v-new-obj-type
        , output v-new-obj-code
        , output v-new-fact-qnty
        , output p-cancel
        , output p-cancel-cycle
    ).
    if p-cancel = no
    and ( v-new-recipe-code <> p-recipe-code
         or v-new-obj-type  <> p-obj-type
         or v-new-obj-code  <> p-obj-code
         or v-new-fact-qnty <> p-fact-qnty
        )
    then do:
        assign
            v-log-string = substitute( "Изменения в строке: &1 &2 &3"
                , ( if v-new-recipe-code <> p-recipe-code then substitute( "Рецепт:&1|&2", p-recipe-code, v-new-recipe-code ) else "" )
                , ( if v-new-obj-type <> p-obj-type or v-new-obj-code <> p-obj-code then substitute( "Объект:&1&2|&3&4", p-obj-type, p-obj-code, v-new-obj-type, v-new-obj-code ) else "" )
                , ( if v-new-fact-qnty <> p-fact-qnty then substitute( "Количество:&1|&2", p-fact-qnty, v-new-fact-qnty ) else "" ) )
        .
        do transaction
        on error undo, return error
        :
            find first buf_fbr-pln-line exclusive-lock
                 where buf_fbr-pln-line.doc-code    = p-doc-code
                   and buf_fbr-pln-line.gds-code    = p-gds-code
                   and buf_fbr-pln-line.recipe-code = p-recipe-code
            .
            assign
                buf_fbr-pln-line.recipe-code    = v-new-recipe-code
                buf_fbr-pln-line.fbr-obj-type   = v-new-obj-type
                buf_fbr-pln-line.fbr-obj-code   = v-new-obj-code
                buf_fbr-pln-line.fact-qnty      = v-new-fact-qnty
            .
        end.        /* do transaction */
        run fbrhist-write in p-list-procedure (
              input v-cntxt-userid
            , input buf_fbr-pln-line.obj-type
            , input buf_fbr-pln-line.obj-code
            , input {&fbrhist-type-change-doc-line}
            , input 2
            , input "change-doc"
            , input substitute( "doc-code:&1,gds-code:&2,recipe-code:&3,obj-type:&4,obj-code:&5,fact-qnty:&6"
                                , p-doc-code
                                , p-gds-code
                                , p-recipe-code
                                , p-obj-type
                                , p-obj-code
                                , p-fact-qnty )
            , input p-doc-code
            , input {&plnmenu}
            , input ""
            , input no
            , input v-new-recipe-code
            , input ""
            , input buf_fbr-pln-line.gds-code
            , input ""
            , input v-new-fact-qnty
            , input v-log-string
            , input no
        ).
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-fbr-pln Dialog-Frame
PROCEDURE check-fbr-pln :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-bad-data      as logical      no-undo.
define output parameter p-error-text    as character    no-undo.

    define variable v-hst-upper-code    as integer      no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-pln-line  for fbr-pln-line.

do
for buf_fbr-pln
  , buf_fbr-pln-line
on error undo, return error
:
    find first buf_fbr-pln-line no-lock
         where buf_fbr-pln-line.doc-code = p-doc-code
    no-error.
    if not available buf_fbr-pln-line
    then do:
        assign
            p-bad-data   = no
        .
        do transaction
        on error undo, return error
        :
            find first buf_fbr-pln exclusive-lock
                 where buf_fbr-pln.doc-code = p-doc-code
            no-error.
            if available buf_fbr-pln
            then do:
                message
                    "В документе нет ни одной строки."
                    skip(1)
                    skip "Поэтому документ удаляется."
                view-as alert-box information.
                delete buf_fbr-pln.
                run fbrhist-write in p-list-procedure (
                      input v-cntxt-userid
                    , input p-obj-type
                    , input p-obj-code
                    , input {&fbrhist-type-delete-doc}
                    , input 1
                    , input "check-fbr-pln"
                    , input ""
                    , input p-doc-code
                    , input {&plnmenu}
                    , input ""
                    , input no
                    , input ""
                    , input ""
                    , input 0
                    , input ""
                    , input 0
                    , input "Удаление пустого документа"
                    , input no
                ).
            end.
        end.        /* do transaction */
    end.
end.
END PROCEDURE. /* check-fbr-pln */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-doc Dialog-Frame
PROCEDURE delete-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-recipe-code    as character    no-undo.
define output parameter p-deleted       as logical      no-undo.

    define variable v-yesno         as logical      no-undo.
    define variable v-upper-code    as integer      no-undo.

    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_goods         for goods.

    find first buf_fbr-pln-line exclusive-lock
         where buf_fbr-pln-line.doc-code    = p-doc-code
           and buf_fbr-pln-line.gds-code    = p-gds-code
           and buf_fbr-pln-line.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    message
             "Товар строки: " {&tabulation} buf_goods.artic buf_goods.gds-name
        skip "Рецепт: " {&tabulation} {&tabulation} buf_fbr-pln-line.recipe-code
        skip(1)
        skip "Удалить строку документа?"
    view-as alert-box question
    buttons yes-no
    title "Удаление строки документа"
    update v-yesno
    .
    if v-yesno = yes
    then do:
        delete buf_fbr-pln-line.
        assign
            p-deleted = yes
        .
        run fbrhist-write in p-list-procedure (
              input v-cntxt-userid
            , input p-obj-type
            , input p-obj-code
            , input {&fbrhist-type-delete-doc-line}
            , input 2
            , input "delete-doc"
            , input substitute( "doc-code:&1,gds-code:&2,recipe-code:&3"
                                , p-doc-code
                                , p-gds-code
                                , p-recipe-code   )
            , input p-doc-code
            , input {&plnmenu}
            , input ""
            , input no
            , input p-recipe-code
            , input ""
            , input p-gds-code
            , input ""
            , input 0
            , input ""
            , input no
        ).
    end.
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
  DISPLAY fi-object fi-date fi-fact-date fi-customer fi-wrkr fi-guest-amount
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-fbr-docs b-help bt-billord b-wrkr br-table b-add b-lkp b-chg
         b-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE go-to-doc Dialog-Frame
PROCEDURE go-to-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-direction as character  no-undo.
do
on error undo, return error
:
    run local-open-query in p-list-procedure.
    run reposition-to-recid in p-list-procedure (
        input recid( buf_init_fbr-pln )
    ).
    run reposition-query in p-list-procedure (
          input p-direction
        , output p-doc-code
    ).
    if p-doc-code = 'first':U
    then do:
        message
            "Это первый документ списка"
        view-as alert-box information.
    end.
    if p-doc-code = 'last':U
    then do:
        message
            "Это последний документ списка"
        view-as alert-box information.
    end.
    if p-doc-code <> ""
    and p-doc-code <> 'first':U
    and p-doc-code <> 'last':U
    then do:
        run local-open-query in this-procedure.
        run init-fields in this-procedure.
        run ui-disable-all in this-procedure.
        run ui-enable in this-procedure.
    end.
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
    { gbl/getcntxt.i get }
    case p-mode
    :
        when {&add-def}
        then do:
            define variable v-obj-date    as date        no-undo.
            define variable v-userid      as character      no-undo.
            { gbl/curobjdt.i
                p-obj-type
                p-obj-code
                fi-date
            }
            assign
                fi-object       = substitute( "&1 &2", p-obj-type, p-obj-code )
                p-doc-code      = ""
            .
        end.        /* when {&add-def} */
        when {&update}
        or when {&lookup}
        then do:

            define variable v-fbroperator-string    as character    no-undo.

            if p-mode = {&update}
            then do:
                run lock-fbr-pln in this-procedure (
                      input p-doc-code
                    , buffer buf_init_fbr-pln
                ).
            end.        /* if p-mode = {&update} */
            else do:
                find first buf_init_fbr-pln no-lock
                     where buf_init_fbr-pln.doc-code = p-doc-code
                .
            end.        /* NOT ( if p-mode = {&update} ) */
            assign
                fi-object       = substitute( "&1 &2", buf_init_fbr-pln.obj-type, buf_init_fbr-pln.obj-code )
                fi-date         = buf_init_fbr-pln.doc-date
                fi-fact-date    = buf_init_fbr-pln.fact-date
                fi-customer     = buf_init_fbr-pln.customer
                fi-guest-amount = buf_init_fbr-pln.guest-amount
            .
            run fbrattr-value in this-procedure (
                  input {&fbrattr-type-fbr-pln}
                , input buf_init_fbr-pln.doc-code
                , input {&trdcattr-fbroperator}
                , output v-fbroperator-string
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка определения оператора план-меню."
                    skip(1)
                    skip "Выберите ответственного за операции план-меню."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box warning.
                assign
                    v-fbr-pln-fbroperator-code = 0
                .
            end.
            assign
                v-fbr-pln-fbroperator-code = integer( v-fbroperator-string )
            no-error.
            if error-status :error
            then do:
                assign
                    v-fbr-pln-fbroperator-code = 0
                .
            end.
            else do:
                define buffer buf_clients       for clients.

                find first buf_clients no-lock
                     where buf_clients.obj-type = {&prs}
                       and buf_clients.obj-code = v-fbr-pln-fbroperator-code
                no-error.
                if not available buf_clients
                then do:
                    assign
                        v-fbr-pln-fbroperator-code = 0
                    .
                end.
                else do:
                    assign
                        fi-wrkr = buf_clients.obj-name
                    .
                end.
            end.
        end.        /* when {&update} */
        otherwise do:
            message
                     vss-workfile vss-revision vss-description
                skip "Неизвестный режим для документа."
                skip "Код документа:" p-doc-code
                skip "Режим просмотра/редактирования:" p-mode
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.        /* otherwise */
    end case.       /* case p-mode */
    if available buf_init_fbr-pln
    then do:
        assign
            frame {&frame-name} :title = substitute( "Документ план-меню N &1 от &2", buf_init_fbr-pln.doc-code, buf_init_fbr-pln.doc-date )
        .
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
end.
END PROCEDURE. /* local-open-query */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock-fbr-pln Dialog-Frame
PROCEDURE lock-fbr-pln :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code   as character    no-undo.
define parameter buffer buf_fbr-pln        for fbr-pln.

do transaction
on error undo, return error
:
    find first buf_fbr-pln exclusive-lock
         where buf_fbr-pln.doc-code = p-doc-code
    no-wait
    no-error.
    if not available buf_fbr-pln
    then do:
        if locked buf_fbr-pln
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Запись документа захвачена другим процессом."
                skip
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
        end.
        else do:
            message
                vss-workfile vss-revision vss-description
                skip "Внутренняя ошибка при блокировании ресурса"
                skip "Отсутствует запись о блокировке ресурса"
            view-as alert-box error.
        end.
        undo, return error .
    end.        /* if not available buf_fbr-pln  */
end.
END PROCEDURE. /* lock-fbr-pln */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-fbroperator Dialog-Frame
PROCEDURE select-fbroperator :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-obj-fbroperator   as character        no-undo.

    define variable v-fbroperator       as integer      no-undo.
    define variable v-clients-recid-int as integer      no-undo.
    define variable v-clients-recid     as recid        no-undo.
    define variable v-recid-list        as character    no-undo.

    define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
    if v-fbr-pln-fbroperator-code <> 0
    then do:
        find first buf_clients no-lock
             where buf_clients.obj-type = {&prs}
               and buf_clients.obj-code = v-fbr-pln-fbroperator-code
        no-error.
        if available buf_clients
        then do:
            assign
                v-clients-recid = recid( buf_clients )
            .
        end.
    end.
    run ref/cli-all.w (
          input parparentproc
        , input "b-sel":U
        , input {&prs}
        , input {&all}
        , input {&current}
        , input v-clients-recid
        , input ",,,,,,NO,,":U
        , input "":U
        , output v-recid-list
    ).
    assign
        v-clients-recid-int = integer( v-recid-list )
    no-error.
    if error-status :error
    then do:
        assign
            v-fbr-pln-fbroperator-code = 0
            p-obj-fbroperator          = "":U
        .
    end.
    else do:
        find first buf_clients no-lock
             where recid( buf_clients ) = v-clients-recid-int
        no-error.
        if not available buf_clients
        then do:
            assign
                v-fbr-pln-fbroperator-code = 0
                p-obj-fbroperator          = "":U
            .
        end.
        else do:
            assign
                v-fbr-pln-fbroperator-code = buf_clients.obj-code
                p-obj-fbroperator          = buf_clients.obj-name
            .
        end.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-disable-all Dialog-Frame
PROCEDURE ui-disable-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-enable Dialog-Frame
PROCEDURE ui-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-current-db-num    as integer        no-undo.

    define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
    { gbl/curdbnum.i
        v-current-db-num
    }
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    case p-mode
    :
        when {&add-def}
        then do:
            if v-current-db-num = buf_clients.db-num
            then do:        /* Работаем на объекте текущей БД, редактирование разрешено. */
                enable
                    b-add
                    b-lkp
                    b-chg
                    b-del
                    b-wrkr
                    bt-billord
                with frame {&frame-name}.
            end.        /* if v-current-db-num = buf_clients.db-num */
        end.        /* when {&add-def} */
        when {&update}
        then do:
            if v-current-db-num = buf_clients.db-num
            then do:        /* Работаем на объекте текущей БД, редактирование разрешено. */
                enable
                    b-add
                    b-lkp
                    b-chg
                    b-del
                    b-wrkr
                    bt-billord
                with frame {&frame-name}.
                if fi-customer <> ""
                or fi-guest-amount <> 0
                then do:
                    assign
                        fi-customer     :sensitive = yes
                        fi-guest-amount :sensitive = yes
                    .
                end.
            end.        /* if v-current-db-num = buf_clients.db-num */
        end.        /* when {&update} */
        when {&lookup}
        then do:
            find first buf_init_fbr-pln no-lock
                 where buf_init_fbr-pln.doc-code = p-doc-code
            no-error.
            if available buf_init_fbr-pln
            then do:
                disable
                    b-add
                    b-chg
                    b-del
                    b-wrkr
                    bt-billord
                with frame {&frame-name}.
                enable
                    bt-prev
                    bt-next
                with frame {&frame-name}.
                assign
                    fi-object       = substitute( "&1 &2", buf_init_fbr-pln.obj-type, buf_init_fbr-pln.obj-code )
                    fi-date         = buf_init_fbr-pln.doc-date
                    fi-fact-date    = buf_init_fbr-pln.fact-date
                    fi-customer     = buf_init_fbr-pln.customer
                    fi-guest-amount = buf_init_fbr-pln.guest-amount
                .
                display
                    fi-object
                    fi-date
                    fi-fact-date
                    fi-customer
                    fi-guest-amount
                with frame {&frame-name}.
            end.        /* if available buf_init_fbr-pln */
            else do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Не удалось найти запись документа."
                    skip(1)
                    skip "Номер документа:" p-doc-code
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.        /* NOT ( if available buf_init_fbr-pln ) */
        end.        /* when {&lookup} */
        otherwise do:
            message
                     vss-workfile vss-revision vss-description
                skip "Неизвестный режим для документа."
                skip "Код документа:" p-doc-code
                skip "Режим просмотра/редактирования:" p-mode
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.        /* otherwise */
    end case.       /* case p-mode */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-doc Dialog-Frame
PROCEDURE view-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-fact-qnty      as decimal      no-undo.

    define variable v-new-recipe-code   as character      no-undo.
    define variable v-new-obj-type      as character      no-undo.
    define variable v-new-obj-code      as integer        no-undo.
    define variable v-new-fact-qnty     as decimal        no-undo.
    define variable v-cancel            as logical        no-undo.
    define variable v-cancel-cycle      as logical        no-undo.

    run str/fbrplnd.w (
          input parparentproc
        , input {&lookup}
        , input p-doc-code
        , input p-gds-code
        , input p-recipe-code
        , input p-obj-type
        , input p-obj-code
        , input p-fact-qnty
        , output v-new-recipe-code
        , output v-new-obj-type
        , output v-new-obj-code
        , output v-new-fact-qnty
        , output v-cancel
        , output v-cancel-cycle
    ).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
