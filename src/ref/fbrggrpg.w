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

Привязка товаров к группе блюд.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-store-type as character    no-undo.
define input parameter p-store-code as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-cancel    as logical      no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Привязка товаров к группе блюд.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ ref/fbrglib.i  }
{ cmp/gds-list.i gds-list DEF }
{ gbl/waitfram.i }


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
&Scoped-define INTERNAL-TABLES ub.fbr-gds-obj ub.goods

/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table ub.goods.gds-code ub.goods.artic ~
goods.prod-type +  STRING (goods.prod-code) ub.goods.gds-name ~
ub.goods.unit-base ub.goods.grp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define QUERY-STRING-br-table FOR EACH ub.fbr-gds-obj ~
      WHERE fbr-gds-obj.obj-type = p-store-type ~
 AND fbr-gds-obj.obj-code = p-store-code ~
 AND fbr-gds-obj.fbr-grp-code = p-node-code NO-LOCK, ~
      EACH ub.goods OF ub.fbr-gds-obj NO-LOCK
&Scoped-define OPEN-QUERY-br-table OPEN QUERY br-table FOR EACH ub.fbr-gds-obj ~
      WHERE fbr-gds-obj.obj-type = p-store-type ~
 AND fbr-gds-obj.obj-code = p-store-code ~
 AND fbr-gds-obj.fbr-grp-code = p-node-code NO-LOCK, ~
      EACH ub.goods OF ub.fbr-gds-obj NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-table ub.fbr-gds-obj ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-table ub.fbr-gds-obj
&Scoped-define SECOND-TABLE-IN-QUERY-br-table ub.goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-del b-help br-table

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

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 3 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-table FOR
      ub.fbr-gds-obj,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _STRUCTURED
  QUERY br-table NO-LOCK DISPLAY
      ub.goods.gds-code FORMAT "999999999":U
      ub.goods.artic FORMAT "X(16)":U
      goods.prod-type +  STRING (goods.prod-code) COLUMN-LABEL "Производитель" FORMAT "X(15)":U
      ub.goods.gds-name FORMAT "X(48)":U
      ub.goods.unit-base FORMAT "X(3)":U
      ub.goods.grp-name COLUMN-LABEL "Группа" FORMAT "X(40)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 17.7.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 11
     b-del AT ROW 1 COL 21
     b-help AT ROW 1 COL 95
     br-table AT ROW 2 COL 1
     SPACE(0.09) SKIP(0.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары для группы блюд"
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
/* BROWSE-TAB br-table b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _TblList          = "ub.fbr-gds-obj,ub.goods OF ub.fbr-gds-obj"
     _Options          = "NO-LOCK"
     _Where[1]         = "fbr-gds-obj.obj-type = p-store-type
 AND fbr-gds-obj.obj-code = p-store-code
 AND fbr-gds-obj.fbr-grp-code = p-node-code"
     _FldNameList[1]   = ub.goods.gds-code
     _FldNameList[2]   = ub.goods.artic
     _FldNameList[3]   > "_<CALC>"
"goods.prod-type +  STRING (goods.prod-code)" "Производитель" "X(15)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   = ub.goods.gds-name
     _FldNameList[5]   = ub.goods.unit-base
     _FldNameList[6]   > ub.goods.grp-name
"goods.grp-name" "Группа" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары для группы блюд */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
    run add-goods in this-procedure (
        input p-node-code
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка добавления товаров в группу блюд."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
    if available ub.fbr-gds-obj
    then do:
        run unattach-goods in this-procedure (
              input fbr-gds-obj.obj-type
            , input fbr-gds-obj.obj-code
            , input fbr-gds-obj.gds-code
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка удаления записи."
                skip return-value
                skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
    end.        /* if available fbr-gds-obj */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    assign
        p-cancel = no
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


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

   define variable v-root-code    as integer     no-undo.

    run fbrglib-get-root-code in this-procedure ( output v-root-code ) no-error.
    if error-status :error
    then do:
        undo, return error "Не найден корневой узел." + {&new-line} + return-value.
    end.
    if p-node-code = v-root-code
    then do:
        message
            skip "Товары не могут принадлежать корневому узлу дерева."
        view-as alert-box error.
        assign
            p-cancel = yes
        .
        undo, return .
    end.
    RUN enable_UI.
    define variable v-current-db-num    as integer        no-undo.
    define buffer buf_clients       for ub.clients.
    { gbl/curdbnum.i
        v-current-db-num
    }
    find first buf_clients no-lock
         where buf_clients.obj-type = p-store-type
           and buf_clients.obj-code = p-store-code
    .
    if v-current-db-num <> buf_clients.db-num
    then do:
        disable
            b-add
            b-del
        with frame {&frame-name} .
    end.
    apply "entry" to br-table.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-goods Dialog-Frame
PROCEDURE add-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-node-code   as integer      no-undo.

    define variable v-artic                 as character    no-undo.
    define variable v-goods-recid-list      as character    no-undo.
    define variable v-counter               as integer      no-undo.
    define variable v-goods-recid           as recid        no-undo.
    define variable v-fbr-gds-obj-recid     as recid        no-undo.

    define buffer buf_goods         for ub.goods.
    define buffer buf_fbr-gds-obj   for ub.fbr-gds-obj.

    run str/chs-gds.w (
          input parparentproc
        , input p-store-type
        , input p-store-code
        , input '':U /*p-list-mode*/
        , input '':U /*p-stat*/
        , input "Группа блюд: " + string( p-node-code )
        , input {&g___object}            /* режим вызова справочника */
        , input ?
        , input ?
        , input ?
        , input ?
        , input-output v-artic
        , output v-goods-recid-list
    ) .
    if v-goods-recid-list <> ''
    then do:
        IF v-goods-recid-list <> "cb_create_gds-list_from-chs-gds" THEN DO:

          do while v-counter <= num-entries ( v-goods-recid-list )
          :
              assign
                  v-goods-recid   = integer( entry ( v-counter, v-goods-recid-list ) )
                  v-counter       = v-counter + 1
              .
              find first buf_goods no-lock
                  where recid( buf_goods ) = v-goods-recid
              .
              RUN cb_create_gds-list_from-chs-gds IN THIS-PROCEDURE ( INPUT (buffer buf_goods:handle)).
          END.
       end.
       v-counter = 0.
        FOR EACH gds-list NO-LOCK:

          if v-counter modulo 10 = 0 then do:
            run waitfram-show in this-procedure ( input substitute("Обработано &1 ", v-counter)).
          end.
          v-counter = v-counter + 1.
          find first buf_fbr-gds-obj exclusive-lock
                 where buf_fbr-gds-obj.obj-type = p-store-type
                   and buf_fbr-gds-obj.obj-code = p-store-code
                   and buf_fbr-gds-obj.gds-code = gds-list.gds-code
            no-error.
            if not available buf_fbr-gds-obj
            then do:        /* Создать buf_fbr-gds-obj */
                run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input {&add-def}          /* par-mode          */
                    , input no
                    , input gds-list.gds-code   /* p-gds-code        */
                    , input p-store-type        /* p-obj-type        */
                    , input p-store-code        /* p-obj-code        */
                    , input p-node-code         /* p-fbr-grp-code    */
                    , input ""                  /* p-fbr-obj-type    */
                    , input 0                   /* p-fbr-obj-code    */
                    , input no                  /* p-is-cd           */
                    , input no                  /* p-is-menu         */
                    , input no                  /* p-is-modificator  */
                    , input no                  /* p-is-null-price   */
                    , input no                  /* p-is-season       */
                    , input no                  /* p-is-semi-finished*/
               ) no-error.
               if error-status :error
               then do:
                  run waitfram-hide in this-procedure .
                   message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка при создании записи товара производства на объекте."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                   view-as alert-box error.
                   undo, return error .
               end.
            end.        /* if not available buf_fbr-gds-obj  */
            else do:
                assign
                    v-fbr-gds-obj-recid = recid( buf_fbr-gds-obj )
                .
                run ref/fgdsobj1.p (
                      input-output v-fbr-gds-obj-recid
                    , input {&update}                           /* par-mode          */
                    , input no
                    , input buf_fbr-gds-obj.gds-code            /* p-gds-code        */
                    , input buf_fbr-gds-obj.obj-type            /* p-obj-type        */
                    , input buf_fbr-gds-obj.obj-code            /* p-obj-code        */
                    , input p-node-code                         /* p-fbr-grp-code    */
                    , input buf_fbr-gds-obj.fbr-obj-type        /* p-fbr-obj-type    */
                    , input buf_fbr-gds-obj.fbr-obj-code        /* p-fbr-obj-code    */
                    , input buf_fbr-gds-obj.is-cd               /* p-is-cd           */
                    , input buf_fbr-gds-obj.is-menu             /* p-is-menu         */
                    , input buf_fbr-gds-obj.is-modificator      /* p-is-modificator  */
                    , input buf_fbr-gds-obj.is-null-price       /* p-is-null-price   */
                    , input buf_fbr-gds-obj.is-season           /* p-is-season       */
                    , input buf_fbr-gds-obj.is-semi-finished    /* p-is-semi-finished*/
               ) no-error.
               if error-status :error
               then do:
                  run waitfram-hide in this-procedure .
                   message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка при изменении записи товара производства на объекте."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                   view-as alert-box error.
                   undo, return error .
               end.
            end.        /* NOT ( if not available buf_fbr-gds-obj  ) */
          delete gds-list.
        end. /*for each gds-list*/
      run waitfram-hide in this-procedure .
    end.        /* if v-goods-recid-list <> '' */
end.
END PROCEDURE. /* add-goods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_create-gds-list Dialog-Frame
PROCEDURE cb_create_gds-list_from-chs-gds :
DEFINE INPUT PARAMETER p-bh AS handle NO-UNDO.
if p-bh:available = no then return .
FIND FIRST gds-list NO-LOCK WHERE
          gds-list.gds-code = p-bh::gds-code NO-ERROR.
IF NOT AVAILABLE gds-list THEN DO:
   CREATE gds-list.
   buffer gds-list:handle:buffer-copy(p-bh).
   release gds-list.
END.

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
  ENABLE b-exit b-add b-del b-help br-table
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE unattach-goods Dialog-Frame
PROCEDURE unattach-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-gds-code   as integer      no-undo.

    define buffer buf_fbr-gds-obj       for ub.fbr-gds-obj.

    find first buf_fbr-gds-obj exclusive-lock
         where buf_fbr-gds-obj.obj-type = p-obj-type
           and buf_fbr-gds-obj.obj-code = p-obj-code
           and buf_fbr-gds-obj.gds-code = p-gds-code
    .
    assign
        buf_fbr-gds-obj.fbr-grp-code = 0
    .
end.
END PROCEDURE. /* unattach-goods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME