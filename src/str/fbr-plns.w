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

Список План-меню или Счет-заказов

Автор: Белоусов Илья Александрович
Дата создания: 09/09/05
Author: Ilia Belousov
Creation date: 09/09/05

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle  no-undo.
define input parameter p-status       as character      no-undo.
define input parameter p-store-type   as character      no-undo.
define input parameter p-store-code   as integer        no-undo.
define input parameter p-userid       as character      no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список План-меню или Счет-заказов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ str/doc-code.i }
{ trg/partslib.i }
{ str/writelog.i def "'fbrpln.log'" no-create }
{ str/temp_upd.i }
{ gbl/objsrv.i   }
{ str/fbrpln.i   }
{ str/fbrlib.i   }
{ str/fbrrest.i  }
{ str/fbradd.i   }
{ str/fbrhist.i main }
{ cmp/showinf.i  }

define variable v-fbr-plns-history-level    as integer      no-undo.
define variable v-fbr-plns-hst-upper-code   as integer      no-undo.

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
&Scoped-define INTERNAL-TABLES buf_init_fbr-pln

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table buf_init_fbr-pln.status_ buf_init_fbr-pln.doc-code substring( string( buf_init_fbr-pln.doc-date ), 1, 5 ) buf_init_fbr-pln.fact-date buf_init_fbr-pln.obj-type + string( buf_init_fbr-pln.obj-code ) buf_init_fbr-pln.creid buf_init_fbr-pln.customer
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define SELF-NAME br-table
&Scoped-define OPEN-QUERY-br-table /* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_fbr-pln no-lock . */ run local-open-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-br-table buf_init_fbr-pln
&Scoped-define FIRST-TABLE-IN-QUERY-br-table buf_init_fbr-pln


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-add b-lkp b-chg b-del ~
b-close b-open b-history b-print br-table EDITOR-1
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1

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

DEFINE BUTTON b-close
     LABEL "&Закрыть"
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

DEFINE BUTTON b-history
     LABEL "И&стория"
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-open
     LABEL "&Открыть"
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-sel
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON b-select
     LABEL "В&ыбор"
     SIZE 10 BY 1.

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 96.88 BY 2.21 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      buf_init_fbr-pln SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      buf_init_fbr-pln.status_
      buf_init_fbr-pln.doc-code
      substring( string( buf_init_fbr-pln.doc-date ), 1, 5 ) COLUMN-LABEL "Дата" FORMAT "X(5)"
      buf_init_fbr-pln.fact-date
      buf_init_fbr-pln.obj-type + string( buf_init_fbr-pln.obj-code ) COLUMN-LABEL "Объект" FORMAT "X(8)"
      buf_init_fbr-pln.creid COLUMN-LABEL "Оператор" FORMAT "X(15)"
      buf_init_fbr-pln.customer COLUMN-LABEL "Заказчик" FORMAT "X(33)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 17.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 1.63
     b-sel AT ROW 1.17 COL 11.63
     b-select AT ROW 1.17 COL 14.63
     b-help AT ROW 1.17 COL 88.63
     b-add AT ROW 2.5 COL 1.63
     b-lkp AT ROW 2.5 COL 11.63
     b-chg AT ROW 2.5 COL 21.63
     b-del AT ROW 2.5 COL 31.63
     b-close AT ROW 2.5 COL 41.63
     b-open AT ROW 2.5 COL 51.63
     b-history AT ROW 2.5 COL 78.63
     b-print AT ROW 2.5 COL 88.63
     br-table AT ROW 3.67 COL 1.63
     EDITOR-1 AT ROW 21.17 COL 1.63 NO-LABEL
     SPACE(0.46) SKIP(0.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список План-меню".


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
/* BROWSE-TAB br-table b-print Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-select IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH buf_init_fbr-pln no-lock . */
run local-open-query in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "buf_init_fbr-pln.obj-type = ""p-o""
 AND buf_init_fbr-pln.obj-code = 1"
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список План-меню */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
    define variable v-have-rights    as logical        no-undo.
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_res-pln-menu_update':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
    }
    if v-have-rights = yes
    then do:
        run add-doc in this-procedure.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
    define variable v-have-rights    as logical        no-undo.
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_res-pln-menu_update':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
    }
    if v-have-rights = no
    then do:
        undo, return no-apply.
    end.
    if buf_init_fbr-pln.status_ <> {&g___new}
    then do:
        message
            "Невозможно изменить закрытый документ."
            skip(1)
            "Статус документа:" buf_init_fbr-pln.status_
        view-as alert-box error.
        undo, return no-apply.
    end.
    if v-have-rights = yes
    and available buf_init_fbr-pln
    then do:
        run fbrhist-init in this-procedure.
        run fbrhist-write in this-procedure (
              input v-cntxt-userid
            , input p-store-type
            , input p-store-code
            , input {&fbrhist-type-change-doc}
            , input 1
            , input "change-doc"
            , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
            , input buf_init_fbr-pln.doc-code
            , input {&plnmenu}
            , input {&g___new}
            , input no
            , input ""
            , input ""
            , input 0
            , input ""
            , input 0
            , input substitute( "Изменение документа план-меню &1", buf_init_fbr-pln.doc-code )
            , input no
        ).
        run fbrhist-set-upper-code in this-procedure.
        run change-doc in this-procedure (
            input buf_init_fbr-pln.doc-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка изменения документа план-меню."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            run fbrhist-write in this-procedure (
                  input v-cntxt-userid
                , input p-store-type
                , input p-store-code
                , input {&fbrhist-type-change-doc}
                , input 1
                , input "change-doc"
                , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                , input buf_init_fbr-pln.doc-code
                , input {&plnmenu}
                , input {&g___new}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "Ошибка изменения документа план-меню &1. &2. &3."
                                    , buf_init_fbr-pln.doc-code
                                    , return-value
                                    , trim(error-status :get-message(1))
                                  )
                , input yes
            ).
            run fbrhist-table-to-base in this-procedure.
            undo, return no-apply .
        end.
        else do:
            run fbrhist-write in this-procedure (
                  input v-cntxt-userid
                , input p-store-type
                , input p-store-code
                , input {&fbrhist-type-change-doc}
                , input 1
                , input "change-doc"
                , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                , input buf_init_fbr-pln.doc-code
                , input {&plnmenu}
                , input {&g___new}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "Изменен документ план-меню &1"
                                    , buf_init_fbr-pln.doc-code
                                  )
                , input no
            ).
            run fbrhist-table-to-base in this-procedure.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Закрыть */
DO:
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-yesno             as logical  no-undo.
    define variable v-have-rights    as logical        no-undo.
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_res-pln-menu_update':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
    }
    if v-have-rights = yes
    and available buf_init_fbr-pln
    then do:
        if buf_init_fbr-pln.status_ = {&fact}
        then do:
            message
                "Документ уже закрыт."
            view-as alert-box error
            title "Закрытие документа".
            undo, return no-apply.
        end.
        assign
            v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-table" )
        .
        if buf_init_fbr-pln.status_ = {&g___new}
        then do:
            message
                     "При закрытии документа план-меню до статуса разрешен"
                skip "будут созданы необходимые документы производства"
                skip "и запросы для перемещения товаров со складов."
                skip (1)
                skip "Закрыть документ?"
            view-as alert-box question
            buttons yes-no
            title "Закрытие документа план-меню"
            update v-yesno
            .
            if v-yesno = yes
            then do:
                run fbrhist-init in this-procedure.
                run fbrhist-write in this-procedure (
                      input v-cntxt-userid
                    , input p-store-type
                    , input p-store-code
                    , input {&fbrhist-type-close-doc}
                    , input 1
                    , input "close-to-permitted"
                    , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                    , input buf_init_fbr-pln.doc-code
                    , input {&plnmenu}
                    , input {&g___new}
                    , input no
                    , input ""
                    , input ""
                    , input 0
                    , input ""
                    , input 0
                    , input substitute( "Закрытие документа план-меню &1 до статуса разр", buf_init_fbr-pln.doc-code )
                    , input no
                ).
                run fbrhist-set-upper-code in this-procedure.
                run close-to-permitted in this-procedure (
                    input buf_init_fbr-pln.doc-code
                ) no-error.
                if error-status :error
                then do:
                    message
                             vss-workfile vss-revision vss-description
                        skip "Ошибка закрытия документа до статуса разр."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    run fbrhist-write in this-procedure (
                          input v-cntxt-userid
                        , input p-store-type
                        , input p-store-code
                        , input {&fbrhist-type-close-doc}
                        , input 1
                        , input "close-to-permitted"
                        , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                        , input buf_init_fbr-pln.doc-code
                        , input {&plnmenu}
                        , input {&g___new}
                        , input no
                        , input ""
                        , input ""
                        , input 0
                        , input ""
                        , input 0
                        , input substitute( "Ошибка закрытия документа план-меню &1 до статуса разр. &2. &3"
                                            , buf_init_fbr-pln.doc-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                          )
                        , input no
                    ).
                    run fbrhist-table-to-base in this-procedure.
                    undo, return no-apply .
                end.
                else do:
                    run fbrhist-write in this-procedure (
                          input v-cntxt-userid
                        , input p-store-type
                        , input p-store-code
                        , input {&fbrhist-type-close-doc}
                        , input 1
                        , input "close-to-permitted"
                        , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                        , input buf_init_fbr-pln.doc-code
                        , input {&plnmenu}
                        , input {&g___new}
                        , input no
                        , input ""
                        , input ""
                        , input 0
                        , input ""
                        , input 0
                        , input substitute( "Документ план-меню &1 закрыт до статуса разр.", buf_init_fbr-pln.doc-code )
                        , input no
                    ).
                    run fbrhist-table-to-base in this-procedure.
                end.
            end.        /* if v-yesno = yes  */
            else do:
                undo, return no-apply.
            end.        /* NOT ( if v-yesno = yes  ) */
        end.
        else do:
            message
                     "При закрытии документа план-меню до статуса факт"
                skip "будут заново созданы необходимые документы производства"
                skip "и документы перемещения блюд на объект ресторан."
                skip (1)
                skip "Отмена операции невозможна."
                skip (1)
                skip "Закрыть документ?"
            view-as alert-box question
            buttons yes-no
            title "Закрытие документа план-меню"
            update v-yesno
            .
            if v-yesno = yes
            then do:
                run fbrhist-init in this-procedure.
                run fbrhist-write in this-procedure (
                      input v-cntxt-userid
                    , input p-store-type
                    , input p-store-code
                    , input {&fbrhist-type-close-fact}
                    , input 1
                    , input "close-to-fact"
                    , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                    , input buf_init_fbr-pln.doc-code
                    , input {&plnmenu}
                    , input {&permitted}
                    , input no
                    , input ""
                    , input ""
                    , input 0
                    , input ""
                    , input 0
                    , input substitute( "Закрытие документа план-меню &1 до статуса факт.",  buf_init_fbr-pln.doc-code )
                    , input no
                ).
                run fbrhist-set-upper-code in this-procedure.
                run close-to-fact in this-procedure (
                    input buf_init_fbr-pln.doc-code
                ) no-error.
                if error-status :error
                then do:
                    message
                             vss-workfile vss-revision vss-description
                        skip "Ошибка закрытия документа до статуса факт."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    run fbrhist-write in this-procedure (
                          input v-cntxt-userid
                        , input p-store-type
                        , input p-store-code
                        , input {&fbrhist-type-close-fact}
                        , input 1
                        , input "close-to-fact"
                        , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                        , input buf_init_fbr-pln.doc-code
                        , input {&plnmenu}
                        , input {&permitted}
                        , input no
                        , input ""
                        , input ""
                        , input 0
                        , input ""
                        , input 0
                        , input substitute( "Ошибка закрытия документа &1 до статуса факт. &2. &3."
                                            , buf_init_fbr-pln.doc-code
                                            , return-value
                                            , trim(error-status :get-message(1))
                                          )
                        , input yes
                    ).
                    run fbrhist-table-to-base in this-procedure.
                    undo, return no-apply .
                end.        /* if error-status :error  */
                else do:
                    run fbrhist-write in this-procedure (
                          input v-cntxt-userid
                        , input p-store-type
                        , input p-store-code
                        , input {&fbrhist-type-close-fact}
                        , input 1
                        , input "close-to-fact"
                        , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                        , input buf_init_fbr-pln.doc-code
                        , input {&plnmenu}
                        , input {&permitted}
                        , input no
                        , input ""
                        , input ""
                        , input 0
                        , input ""
                        , input 0
                        , input substitute( "Документ план-меню &1 закрыт до статуса факт.",  buf_init_fbr-pln.doc-code )
                        , input no
                    ).
                    run fbrhist-table-to-base in this-procedure.
                end.        /* NOT ( if error-status :error  ) */
            end.        /* if v-yesno = yes  */
            else do:
                undo, return no-apply.
            end.        /* NOT ( if v-yesno = yes  ) */
        end.
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
    define variable v-doc-code          as character    no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-can-delete        as logical  no-undo.

    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_res-pln-menu_update':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-can-delete
    }
    if v-can-delete = no
    then do:
        undo, return no-apply.
    end.
    if buf_init_fbr-pln.status_ <> {&g___new}
    then do:
        message
            "Невозможно удалить закрытый документ."
            skip(1)
            "Статус документа:" buf_init_fbr-pln.status_
        view-as alert-box error.
        undo, return no-apply.
    end.
    if v-can-delete = yes
    and available buf_init_fbr-pln
    and buf_init_fbr-pln.status_ = {&g___new}
    then do:
        assign
            v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-table" )
        .
        assign
            v-doc-code         = buf_init_fbr-pln.doc-code
        .
        run fbrhist-init in this-procedure.
        run fbrhist-write in this-procedure (
              input v-cntxt-userid
            , input p-store-type
            , input p-store-code
            , input {&fbrhist-type-delete-doc}
            , input 1
            , input "del-doc"
            , input substitute( "doc-code:&1", v-doc-code )
            , input v-doc-code
            , input {&plnmenu}
            , input {&g___new}
            , input no
            , input ""
            , input ""
            , input 0
            , input ""
            , input 0
            , input substitute( "Удаление документа план-меню &1", v-doc-code )
            , input no
        ).
        run fbrhist-set-upper-code in this-procedure.
        run delete-doc in this-procedure (
            input v-doc-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка удаления документа план-меню."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            run fbrhist-write in this-procedure (
                  input v-cntxt-userid
                , input p-store-type
                , input p-store-code
                , input {&fbrhist-type-delete-doc}
                , input 1
                , input "del-doc"
                , input substitute( "doc-code:&1", v-doc-code )
                , input v-doc-code
                , input {&plnmenu}
                , input {&g___new}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "Ошибка удаления документа план-меню &1. &2. &3."
                                    , v-doc-code
                                    , return-value
                                    , trim(error-status :get-message(1))
                                  )
                , input yes
            ).
            run fbrhist-table-to-base in this-procedure.
            undo, return no-apply.
        end.        /* if error-status :error */
        else do:
            run fbrhist-write in this-procedure (
                  input v-cntxt-userid
                , input p-store-type
                , input p-store-code
                , input {&fbrhist-type-delete-doc}
                , input 1
                , input "del-doc"
                , input substitute( "doc-code:&1", v-doc-code )
                , input v-doc-code
                , input {&plnmenu}
                , input {&g___new}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "Документ план-меню &1 удален.", v-doc-code )
                , input no
            ).
            run fbrhist-table-to-base in this-procedure.
        end.        /* NOT ( if error-status :error ) */
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
        if v-focused-row > 1
        then do:
            br-table :set-repositioned-row( v-focused-row - 1, "ALWAYS" ) in frame {&FRAME-NAME} .
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
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
    run str/fbrhist.w (
        input buf_init_fbr-pln.doc-code
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка просмотра истории."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
or mouse-select-dblclick of br-table in frame dialog-frame
DO:
    define variable v-have-rights    as logical        no-undo.
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_res-pln-menu_lookup':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
    }
    if v-have-rights = yes
    and available buf_init_fbr-pln
    then do:
        run view-doc in this-procedure (
            input buf_init_fbr-pln.doc-code
        ).
    end.        /* if available buf_init_fbr-pln */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-open Dialog-Frame
ON CHOOSE OF b-open IN FRAME Dialog-Frame /* Открыть */
DO:
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    define variable v-yesno             as logical  no-undo.
    define variable v-have-rights    as logical        no-undo.
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_res-pln-menu_update':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
    }
    if v-have-rights = yes
    and available buf_init_fbr-pln
    then do:
        if buf_init_fbr-pln.status_ = {&fact}
        then do:
            message
                     "Документ закрыт до статуса факт"
                skip(1)
                skip "Невозможно открыть документ"
            view-as alert-box error
            title "Открытие документа план-меню".
            undo, return no-apply.
        end.
        if buf_init_fbr-pln.status_ = {&g___new}
        then do:
            message
                     "Документ в статусе новый"
                skip(1)
                skip "Невозможно открыть документ"
            view-as alert-box error
            title "Открытие документа план-меню".
            undo, return no-apply.
        end.
        assign
            v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
            v-repositioned-row = current-result-row( "br-table" )
        .
        message
                 "При открытии документа план-меню"
            skip "будут удалены ранее созданные документы производства."
            skip (1)
            skip "Открыть документ?"
        view-as alert-box question
        buttons yes-no
        title "Открытие документа план-меню"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            run fbrhist-init in this-procedure.
            run fbrhist-write in this-procedure (
                  input v-cntxt-userid
                , input p-store-type
                , input p-store-code
                , input {&fbrhist-type-open-doc}
                , input 1
                , input "open-doc"
                , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                , input buf_init_fbr-pln.doc-code
                , input {&plnmenu}
                , input {&permitted}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input substitute( "Открытие документа план-меню &1", buf_init_fbr-pln.doc-code )
                , input no
            ).
            run fbrhist-set-upper-code in this-procedure.
            run open-doc in this-procedure (
                input buf_init_fbr-pln.doc-code
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка открытия документа план-меню."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                run fbrhist-write in this-procedure (
                      input v-cntxt-userid
                    , input p-store-type
                    , input p-store-code
                    , input {&fbrhist-type-open-doc}
                    , input 1
                    , input "open-doc"
                    , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                    , input buf_init_fbr-pln.doc-code
                    , input {&plnmenu}
                    , input {&permitted}
                    , input no
                    , input ""
                    , input ""
                    , input 0
                    , input ""
                    , input 0
                    , input substitute( "Ошибка открытия документа план-меню &1. &2. &3."
                                        , buf_init_fbr-pln.doc-code
                                        , return-value
                                        , trim(error-status :get-message(1))
                                      )
                    , input yes
                ).
                run fbrhist-table-to-base in this-procedure.
                undo, return no-apply .
            end.        /* if error-status :error */
            else do:
                run fbrhist-write in this-procedure (
                      input v-cntxt-userid
                    , input p-store-type
                    , input p-store-code
                    , input {&fbrhist-type-open-doc}
                    , input 1
                    , input "open-doc"
                    , input substitute( "doc-code:&1", buf_init_fbr-pln.doc-code )
                    , input buf_init_fbr-pln.doc-code
                    , input {&plnmenu}
                    , input {&permitted}
                    , input no
                    , input ""
                    , input ""
                    , input 0
                    , input ""
                    , input 0
                    , input substitute( "Документ план-меню &1 открыт.", buf_init_fbr-pln.doc-code )
                    , input no
                ).
                run fbrhist-table-to-base in this-procedure.
            end.        /* NOT ( if error-status :error ) */
        end.        /* if v-yesno = yes  */
        else do:
            undo, return no-apply.
        end.        /* NOT ( if v-yesno = yes  ) */
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
        br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
        reposition br-table to row v-repositioned-row.
    end.        /* if available buf_init_fbr-pln */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
    define variable v-have-rights    as logical        no-undo.
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_res-print_print':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        yes
        v-have-rights
    }
    if v-have-rights = yes
    then do:
        run print-doc in this-procedure (
            input recid( buf_init_fbr-pln )
        ).
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
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-open }
{ gbl/hot-key.i b-print }
/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    run fbrhist-read-conf in this-procedure .
    { gbl/getcntxt.i get }
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
    run str/fbr-pln.w (
          input parparentproc
        , input this-procedure
        , input {&add-def}
        , input ""
        , input p-store-type
        , input p-store-code
        , input p-userid
    ).
end.
END PROCEDURE.

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
define input parameter p-doc-code   as character    no-undo.

    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.

    assign
        v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-table" )
    .
    run str/fbr-pln.w (
          input parparentproc
        , input this-procedure
        , input {&update}
        , input p-doc-code
        , input p-store-type
        , input p-store-code
        , input p-userid
    ).
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    reposition br-table to row v-repositioned-row.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE close-to-fact Dialog-Frame
PROCEDURE close-to-fact :
/*------------------------------------------------------------------------------
  Purpose:     Закрытие плана-меню до статуса факт
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code    as character    no-undo.
do
on error undo, return error
:
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.

    assign
        v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-table" )
    .
    run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input "str/fbrplnft.p":U
        , input p-doc-code
        , input no /*p-auto-go*/
        , input "":U
        , input substitute( "Закрытие план-меню до статуса факт. Номер документа план-меню: &1", p-doc-code )
    ) .
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    reposition br-table to row v-repositioned-row.
end.
END PROCEDURE. /* close-to-fact */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE close-to-permitted Dialog-Frame
PROCEDURE close-to-permitted :
/*------------------------------------------------------------------------------
  Purpose:      Закрытие плана-меню до статуса разрешен
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code    as character    no-undo.

    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-yesno             as logical      no-undo.
    define variable v-hst-upper-code    as integer      no-undo.

    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_goods         for goods.
    define buffer buf_fbr-pln       for fbr-pln.
do
for buf_fbr-pln-line
  , buf_goods
  , buf_fbr-pln
on error undo, return error
:
    assign
        v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-table" )
    .
    do transaction
    on error undo, return error
    :
        check-zero-qnty:
        for each buf_fbr-pln-line exclusive-lock
           where buf_fbr-pln-line.doc-code = p-doc-code
        on error undo, return error
        :
            if buf_fbr-pln-line.fact-qnty = 0
            then do:
                find first buf_goods no-lock
                     where buf_goods.gds-code = buf_fbr-pln-line.gds-code
                .
                assign
                    v-yesno = yes
                .
                message
                    "Строка документа содержит товар с нулевым количеством."
                    skip (1)
                    skip "Товар:" buf_fbr-pln-line.artic buf_goods.gds-name
                    skip (1)
                    skip "Вы можете удалить строку товара и продолжить закрытие документа"
                    skip "Или прервать процесс закрытия для редактирования документа."
                    skip (1)
                    skip "OK - удалить строку и продолжить"
                    skip "Cancel  - прервать процедуру закрытия"
                    skip (1)
                    skip "Удалить строку с нулевым количеством?"
                view-as alert-box warning
                buttons ok-cancel
                title "Строка с нулевым количеством"
                update v-yesno.
                if v-yesno = yes
                then do:
                    define variable v-gds-code    as integer      no-undo.
                    assign
                        v-gds-code = buf_fbr-pln-line.gds-code
                    .
                    delete buf_fbr-pln-line.
                    run fbrhist-write in this-procedure (
                          input v-cntxt-userid
                        , input p-store-type
                        , input p-store-code
                        , input {&fbrhist-type-close-doc} + ",":U + {&fbrhist-type-user-select} + ",":U + {&fbrhist-type-delete-doc-line}
                        , input 2
                        , input "close-to-permitted"
                        , input "doc-code:" + p-doc-code
                        , input p-doc-code
                        , input {&plnmenu}
                        , input {&g___new}
                        , input no
                        , input ""
                        , input ""
                        , input v-gds-code
                        , input ""
                        , input 0
                        , input "Удаление строки с нулевым количеством"
                        , input no
                    ).
                    next check-zero-qnty.
                end.
                else do:
                    undo, return error.
                end.
            end.
        end.
    end.        /* do transaction */
    find first buf_fbr-pln-line no-lock
         where buf_fbr-pln-line.doc-code = p-doc-code
    no-error.
    if not available buf_fbr-pln-line
    then do:
        message
            "В документе нет строк."
            skip "Пустой документ будет удален."
            skip(1)
            skip "Номер документа:" p-doc-code
        view-as alert-box information.
        do transaction
        on error undo, return error
        :
            find first buf_fbr-pln exclusive-lock
                 where buf_fbr-pln.doc-code = p-doc-code
            .
            delete buf_fbr-pln.
            run fbrhist-write in this-procedure (
                  input v-cntxt-userid
                , input p-store-type
                , input p-store-code
                , input {&fbrhist-type-close-doc} + ",":U + {&fbrhist-type-delete-doc}
                , input 1
                , input "close-to-permitted"
                , input "doc-code:" + p-doc-code
                , input p-doc-code
                , input {&plnmenu}
                , input {&g___new}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input "Удаление пустого документа"
                , input no
            ).
        end.        /* do transaction */
    end.        /* not available buf_fbr-pln-line */
    else do:
        run str/diallog.w (
              input parparentproc
            , input this-procedure
            , input "str/fbrplnpm.p":U
            , input p-doc-code
            , input no /*p-auto-go*/
            , input "":U
            , input substitute( "Закрытие план-меню до статуса разрешен. Номер документа план-меню: &1", p-doc-code )
        ) no-error.
        if error-status:error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа план-меню до статуса разрешен."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            run fbrhist-write in this-procedure (
                  input v-cntxt-userid
                , input p-store-type
                , input p-store-code
                , input {&fbrhist-type-close-doc} + ",":U + {&fbrhist-type-delete-doc}
                , input 1
                , input "close-to-permitted"
                , input "doc-code:" + p-doc-code
                , input p-doc-code
                , input {&plnmenu}
                , input {&g___new}
                , input no
                , input ""
                , input ""
                , input 0
                , input ""
                , input 0
                , input "Удаление пустого документа"
                , input no
            ).
            undo, return error .
        end.
    end.        /* available buf_fbr-pln-line */
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    reposition br-table to row v-repositioned-row.
end.
END PROCEDURE.

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
define input parameter p-doc-code as character    no-undo.

    define variable v-yesno    as logical        no-undo.

    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-pln-line  for fbr-pln-line.

    assign
        v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-table" )
    .
    find first buf_fbr-pln exclusive-lock
         where buf_fbr-pln.doc-code = p-doc-code
    no-error.
    if available buf_fbr-pln
    then do:
        assign
            v-yesno = no
        .
        message
                 "Удаление документа."
            skip (1)
            skip "Номер документа:" p-doc-code
            skip "Дата документа:" buf_fbr-pln.doc-date
            skip "Удалить документ?"
        view-as alert-box information
        buttons yes-no
        title "Удаление документа"
        update v-yesno.
        if v-yesno = yes
        then do:
            for each buf_fbr-pln-line exclusive-lock
               where buf_fbr-pln-line.doc-code = buf_fbr-pln.doc-code
            on error undo, return error
            :
                delete buf_fbr-pln-line.
            end.        /* for each buf_fbr-pln-line */
            delete buf_fbr-pln.
        end.        /* if v-yesno = yes */
    end.        /* if available buf_fbr-pln */
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    reposition br-table to row v-repositioned-row.
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
  DISPLAY EDITOR-1
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help b-add b-lkp b-chg b-del b-close b-open b-history b-print
         br-table EDITOR-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

    if p-status = '':U
    then do:
        open query {&browse-name}
        for each buf_init_fbr-pln no-lock
           where buf_init_fbr-pln.obj-type = p-store-type
             and buf_init_fbr-pln.obj-code = p-store-code
    /*    use-index objdate*/
        by buf_init_fbr-pln.doc-date descending
        .
    end.        /* if p-status = '':U */
    else do:
        open query {&browse-name}
        for each buf_init_fbr-pln no-lock
           where buf_init_fbr-pln.obj-type = p-store-type
             and buf_init_fbr-pln.obj-code = p-store-code
             and buf_init_fbr-pln.status_  = p-status
    /*    use-index objdate*/
        by buf_init_fbr-pln.doc-date descending
        .
    end.        /* NOT ( if p-status = '':U ) */

 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-doc Dialog-Frame
PROCEDURE open-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code as character    no-undo.
do
on error undo, return error
:
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.

    assign
        v-focused-row      = br-table :focused-row in frame {&FRAME-NAME}.
        v-repositioned-row = current-result-row( "br-table" )
    .
    run str/fbrplnop.p (
        input p-doc-code
    ).
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
    reposition br-table to row v-repositioned-row.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-doc Dialog-Frame
PROCEDURE print-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fbr-pln-recid   as recid    no-undo.

do
on error undo, return error
:

      run rep/fplndprn.w (
          input parparentproc
        , input p-fbr-pln-recid
    ).
end.
END PROCEDURE. /* print-doc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-direction  as character    no-undo.
define output parameter p-doc-code  as character    no-undo.

    define buffer buf_fbr-pln       for fbr-pln.
do
for buf_fbr-pln
on error undo, return error
:
    case p-direction
    :
        when 'prev':U
        then do:
            get prev br-table.
            if available buf_init_fbr-pln
            then do:
                assign
                    p-doc-code = buf_init_fbr-pln.doc-code
                .
            end.
            else do:
                assign
                    p-doc-code = 'first':U
                .
            end.
        end.        /* when 'prev':U */
        when 'next':U
        then do:
            get next br-table.
            if available buf_init_fbr-pln
            then do:
                assign
                    p-doc-code = buf_init_fbr-pln.doc-code
                .
            end.
            else do:
                assign
                    p-doc-code = 'last':U
                .
            end.
        end.        /* when 'next':U */
        when 'first':U
        then do:
            get first br-table.
            if available buf_init_fbr-pln
            then do:
                assign
                    p-doc-code = buf_init_fbr-pln.doc-code
                .
            end.
            else do:
                assign
                    p-doc-code = ""
                .
            end.
        end.        /* when 'first':U */
        when 'last':U
        then do:
            get last br-table.
            if available buf_init_fbr-pln
            then do:
                assign
                    p-doc-code = buf_init_fbr-pln.doc-code
                .
            end.
            else do:
                assign
                    p-doc-code = ""
                .
            end.
        end.        /* when 'last':U */
        otherwise do:
            assign
                p-doc-code = p-direction
            .
        end.        /* otherwise */
    end case.       /* case p-direction */
    if p-doc-code  <> ""
    and p-doc-code <> 'first':U
    and p-doc-code <> 'last':U
    then do:
        find first buf_fbr-pln no-lock
             where buf_fbr-pln.doc-code = p-doc-code
        no-error.
        if available buf_fbr-pln
        then do:
            reposition br-table to recid recid( buf_fbr-pln ) no-error .
        end.
        else do:
            assign
                p-doc-code = ""
            .
        end.
    end.

end.
END PROCEDURE. /* reposition-query */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-to-recid Dialog-Frame
PROCEDURE reposition-to-recid :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fbr-pln-recid  as recid        no-undo.
do
on error undo, return error
:
    if p-fbr-pln-recid <> ?
    then do:
        reposition br-table to recid p-fbr-pln-recid no-error .
    end.
    do with frame {&frame-name}
    :
        apply "entry":u to browse {&browse-name} .
    end. /* do with frame */

end.
END PROCEDURE. /* reposition-to-recid */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ui-disable-all Dialog-Frame
PROCEDURE ui-disable-all :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    disable
        b-add
        b-del
        b-chg
        b-close
        b-open
    with frame {&frame-name} .
end.
END PROCEDURE. /* ui-disable-all */

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
         where buf_clients.obj-type = p-store-type
           and buf_clients.obj-code = p-store-code
    .
    if v-current-db-num = buf_clients.db-num
    then do:        /* Работаем на объекте текущей БД, редактирование разрешено. */
        enable
            b-add
            b-del
            b-chg
            b-close
            b-open
        with frame {&frame-name} .
    end.        /* if v-current-db-num = buf_clients.db-num */
end.
END PROCEDURE. /* ui-enable */

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
define input parameter p-doc-code as character    no-undo.

    run str/fbr-pln.w (
          input parparentproc
        , input this-procedure
        , input {&lookup}
        , input p-doc-code
        , input p-store-type
        , input p-store-code
        , input p-userid
    ).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME