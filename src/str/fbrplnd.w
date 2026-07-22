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

Просмотр и редактирование строки документа план-меню

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
define input parameter parparentproc        as widget-handle    no-undo.
define input parameter p-mode               as character        no-undo.
define input parameter p-doc-code           as character        no-undo.
define input parameter p-gds-code           as integer          no-undo.
define input parameter p-recipe-code        as character        no-undo.
define input parameter p-fbr-obj-type       as character        no-undo.
define input parameter p-fbr-obj-code       as integer          no-undo.
define input parameter p-fact-qnty          as decimal          no-undo.
define output parameter p-new-recipe-code   as character        no-undo.
define output parameter p-new-fbr-obj-type  as character        no-undo.
define output parameter p-new-fbr-obj-code  as integer          no-undo.
define output parameter p-new-fact-qnty     as decimal          no-undo.
define output parameter p-cancel            as logical          no-undo.
define output parameter p-cancel-cycle      as logical          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр и редактирование строки документа план-меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/chkleave.i }
{ cmp/showinf.i  }

define variable v-fbrplnd-kitchen-selected      as logical init no  no-undo.

define buffer buf_init_recipe    for recipe.
define buffer buf_init_goods     for goods.
define buffer buf_init_fbr-pln   for fbr-pln.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-stop-cycle b-help ~
fi-kitchen-code bt-sel-kitchen bt-sel-recipe fi-fact-qnty
&Scoped-Define DISPLAYED-OBJECTS fi-kitchen-type fi-kitchen-code fi-artic ~
fi-name fi-recipe-code fi-recipe-name fi-fact-qnty

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-stop-cycle
     LABEL "&СтопЦикл"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-sel-kitchen
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-sel-recipe
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE VARIABLE fi-artic AS CHARACTER FORMAT "X(20)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 14.38 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-fact-qnty AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0
     LABEL "Количество"
     VIEW-AS FILL-IN
     SIZE 14.38 BY 1 NO-UNDO.

DEFINE VARIABLE fi-kitchen-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-kitchen-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Кухня"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Наименование"
     VIEW-AS FILL-IN
     SIZE 47.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-recipe-code AS CHARACTER FORMAT "X(20)":U
     LABEL "Рецепт"
     VIEW-AS FILL-IN
     SIZE 14.38 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-recipe-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 29.38 BY 1
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-cancel AT ROW 1.17 COL 12
     b-stop-cycle AT ROW 1.17 COL 22
     b-help AT ROW 1.17 COL 52.38
     fi-kitchen-type AT ROW 2.5 COL 13.5 COLON-ALIGNED
     fi-kitchen-code AT ROW 2.5 COL 18.88 COLON-ALIGNED NO-LABEL
     bt-sel-kitchen AT ROW 2.5 COL 28.25
     fi-artic AT ROW 3.79 COL 13.5 COLON-ALIGNED
     fi-name AT ROW 5.04 COL 1.5
     fi-recipe-code AT ROW 6.29 COL 13.5 COLON-ALIGNED
     bt-sel-recipe AT ROW 6.29 COL 29.88
     fi-recipe-name AT ROW 6.29 COL 31.63 COLON-ALIGNED NO-LABEL
     fi-fact-qnty AT ROW 7.54 COL 13.5 COLON-ALIGNED
     SPACE(33.36) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Строка документа".


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-artic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-kitchen-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-recipe-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-recipe-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Строка документа */
DO:
    /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Строка документа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-cancel   = yes
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
    assign
        fi-fact-qnty
        fi-kitchen-type
        fi-kitchen-code
    .
    if fi-kitchen-type = ""
    or fi-kitchen-code = 0
    then do:
        message
            "Выберите объект, с которого"
            skip "должен будет переместиться товар."
        view-as alert-box error.
        apply "entry":U to fi-kitchen-code in frame {&frame-name} .
        undo, return no-apply.
    end.
    assign
        p-new-fbr-obj-type  = fi-kitchen-type
        p-new-fbr-obj-code  = fi-kitchen-code
        p-new-fact-qnty     = fi-fact-qnty
        p-cancel            = no
        p-cancel-cycle      = no
    .
    if available buf_init_recipe
    then do:
        assign
            fi-recipe-code
        .
        assign
            p-new-recipe-code = fi-recipe-code
        .
    end.
    else do:
        assign
            p-new-recipe-code = ""
        .
    end.
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-stop-cycle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-stop-cycle Dialog-Frame
ON CHOOSE OF b-stop-cycle IN FRAME Dialog-Frame /* СтопЦикл */
DO:
    assign
        p-cancel-cycle   = yes
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-kitchen
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-kitchen Dialog-Frame
ON CHOOSE OF bt-sel-kitchen IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-is-invalid    as logical        no-undo.

    run select-kitchen in this-procedure (
          input fi-kitchen-type
        , input fi-kitchen-code
        , output fi-kitchen-type
        , output fi-kitchen-code
    ).
    display
        fi-kitchen-type
        fi-kitchen-code
    with frame {&frame-name}.
    run check-object in this-procedure (
          input fi-kitchen-type :screen-value
        , input integer( fi-kitchen-code :screen-value )
        , output v-is-invalid
    ).
    if v-is-invalid = yes
    then do:
        message
            "Объект выбран неверно."
            skip(1)
            "Введите код объекта или выберите объект."
        view-as alert-box error.
        apply "entry" to fi-kitchen-code.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-recipe
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-recipe Dialog-Frame
ON CHOOSE OF bt-sel-recipe IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-recipe-recid-list    as character      no-undo.

    define buffer buf_fbr-pln       for fbr-pln.

    find first buf_fbr-pln no-lock
         where buf_fbr-pln.doc-code = p-doc-code
    .
    run ref/rcp-all.w (
          input parparentproc
        , input "b-add,b-sel"
        , input {&all}
        , input recid( buf_init_goods )
        , input buf_fbr-pln.obj-type
        , input buf_fbr-pln.obj-code
        , output v-recipe-recid-list
    ) no-error.
    if error-status :error
    or v-recipe-recid-list = ""
    then do:
        /* Отмена выбора рецепта */
    end.
    else do:
        find first buf_init_recipe no-lock
             where recid( buf_init_recipe ) = integer( entry( 1, v-recipe-recid-list ) )
        .
        assign
            fi-recipe-code  = buf_init_recipe.recipe-code
            fi-recipe-name  = buf_init_recipe.recipe-name
        .
        display
            fi-recipe-code
            fi-recipe-name
        with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-fact-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-fact-qnty Dialog-Frame
ON RETURN OF fi-fact-qnty IN FRAME Dialog-Frame /* Количество */
DO:
    apply "entry" to b-exit.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-kitchen-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-kitchen-code Dialog-Frame
ON LEAVE OF fi-kitchen-code IN FRAME Dialog-Frame
DO:
    define variable v-is-invalid    as logical        no-undo.

    if chkleave (
         input last-event :widget-enter         /* p-widget-enter */
       , input "b-cancel,b-help,b-stop-cycle":u /* p-button-list  */
    )
    then do:
        run check-object in this-procedure (
              input fi-kitchen-type :screen-value
            , input integer( fi-kitchen-code :screen-value )
            , output v-is-invalid
        ).
        if v-is-invalid = yes
        then do:
            message
                "Неверно выбран объект."
                skip "Выберите объект из списка."
            view-as alert-box warning.
            run select-kitchen in this-procedure (
                  input fi-kitchen-type :screen-value
                , input integer( fi-kitchen-code :screen-value )
                , output fi-kitchen-type
                , output fi-kitchen-code
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка выбора объекта."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return no-apply .
            end.
            run check-object in this-procedure (
                  input fi-kitchen-type
                , input fi-kitchen-code
                , output v-is-invalid
            ).
            if v-is-invalid = yes
            then do:
                message
                    "Объект не найден"
                    skip "или не определен тип объекта"
                view-as alert-box error.
                undo, return no-apply.
            end.
            display
                fi-kitchen-type
                fi-kitchen-code
            with frame {&frame-name}.
            return no-apply.
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-kitchen-code Dialog-Frame
ON RETURN OF fi-kitchen-code IN FRAME Dialog-Frame
DO:
    define variable v-is-invalid    as logical      no-undo.
    run get-obj-type in this-procedure (
          input integer( fi-kitchen-code :screen-value )
        , output fi-kitchen-type
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при определении типа объекта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if fi-kitchen-type = ?
    then do:
        run select-kitchen in this-procedure (
              input fi-kitchen-type
            , input fi-kitchen-code
            , output fi-kitchen-type
            , output fi-kitchen-code
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка выбора объекта."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        run check-object in this-procedure (
              input fi-kitchen-type
            , input fi-kitchen-code
            , output v-is-invalid
        ).
        if v-is-invalid = yes
        then do:
            message
                "Объект не найден"
                skip "или не определен тип объекта"
            view-as alert-box error.
            undo, return no-apply.
        end.
        display
            fi-kitchen-type
            fi-kitchen-code
        with frame {&frame-name}.
    end.
    else do:
        display
            fi-kitchen-type
        with frame {&frame-name} .
    end.
    apply "entry":U to fi-fact-qnty in frame {&frame-name} .
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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

    run init-fields in this-procedure no-error.
    if error-status :error
    then do:
        assign
            p-cancel   = yes
        .
        apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
    end.
    RUN enable_UI.
    if p-mode = {&lookup}
    then do:
        apply "entry" to b-exit in frame {&frame-name} .
        disable
            fi-fact-qnty
            bt-sel-recipe
            bt-sel-kitchen
            fi-kitchen-code
        with frame {&frame-name} .
        assign
            fi-fact-qnty :fgcolor = 4
        .
    end.
    else do:
        if not available buf_init_recipe
        then do:
            disable
                bt-sel-recipe
            with frame {&frame-name} .
            apply "entry" to fi-kitchen-code in frame {&frame-name} .
        end.
        else do:
/*            disable*/
/*                bt-sel-kitchen*/
/*                fi-kitchen-code*/
/*            with frame {&frame-name} .*/
            apply "entry" to fi-fact-qnty in frame {&frame-name} .
        end.
    end.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-object Dialog-Frame
PROCEDURE check-object :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define output parameter p-is-invalid    as logical      no-undo.

    define buffer buf_clients       for clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    no-error.
    if not available buf_clients
    or ( buf_clients.obj-type <> {&shop}
        and buf_clients.obj-type <> {&stock} )
    then do:
        assign
            p-is-invalid = yes
        .
    end.
    else do:
        assign
            p-is-invalid = no
        .
    end.
end.
END PROCEDURE. /* check-object */

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
  DISPLAY fi-kitchen-type fi-kitchen-code fi-artic fi-name fi-recipe-code
          fi-recipe-name fi-fact-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-stop-cycle b-help fi-kitchen-code bt-sel-kitchen
         bt-sel-recipe fi-fact-qnty
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-obj-type Dialog-Frame
PROCEDURE get-obj-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-obj-code   as integer      no-undo.
define output parameter p-obj-type  as character    no-undo.

    define buffer buf_shop_clients      for clients.
    define buffer buf_stock_clients     for clients.

    find first buf_shop_clients no-lock
         where buf_shop_clients.obj-type = {&shop}
           and buf_shop_clients.obj-code = p-obj-code
    no-error.
    find first buf_stock_clients no-lock
         where buf_stock_clients.obj-type = {&stock}
           and buf_stock_clients.obj-code = p-obj-code
    no-error.
    if available buf_shop_clients
    then do:
        if available buf_stock_clients
        then do:
            run str/fbrplnds.w (
                  input "Выберите тип объекта:"
                , output p-obj-type
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Ошибка определения типа объекта."
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                assign
                    p-obj-type = ?
                .
                undo, return error .
            end.
        end.        /* if available buf_stock_clients */
        else do:
            assign
                p-obj-type = buf_shop_clients.obj-type
            .
        end.        /* if not available buf_stock_clients */
    end.        /* if available buf_shop_clients */
    else do:
        if available buf_stock_clients
        then do:
            assign
                p-obj-type = buf_stock_clients.obj-type
            .
        end.        /* if available buf_stock_clients */
        else do:
            assign
                p-obj-type = ?
            .
        end.        /* if not available buf_stock_clients */
    end.        /* if not available buf_shop_clients */
end.
END PROCEDURE. /* get-obj-type */

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
    define buffer buf_goods         for goods.
    define buffer buf_recipe        for recipe.
    define buffer buf_fbr-gds-obj   for fbr-gds-obj.

    find first buf_init_fbr-pln no-lock
         where buf_init_fbr-pln.doc-code = p-doc-code
    .
    find first buf_init_goods no-lock
         where buf_init_goods.gds-code = p-gds-code
    .
    find first buf_recipe no-lock
         where buf_recipe.artic     = buf_init_goods.artic
           and buf_recipe.prod-type = buf_init_goods.prod-type
           and buf_recipe.prod-code = buf_init_goods.prod-code
    no-error.
    if available buf_recipe
    and ( buf_recipe.recipe-type = {&manufacturing}
       or buf_recipe.recipe-type = {&alternative} )
    and p-fbr-obj-type = ""
    and p-fbr-obj-code = 0
    then do:
        find first buf_fbr-gds-obj no-lock
             where buf_fbr-gds-obj.obj-type = buf_init_fbr-pln.obj-type
               and buf_fbr-gds-obj.obj-code = buf_init_fbr-pln.obj-code
               and buf_fbr-gds-obj.gds-code = p-gds-code
        no-error.
        if not available buf_fbr-gds-obj
        then do:
            message
                skip "Не задан объект для производства товара с рецептом."
                skip "Товар: " buf_init_goods.artic buf_init_goods.gds-name
                skip(1)
                skip "Товар не может быть включен в план-меню."
                skip(1)
                skip "Необходимо определить атрибуты товара для ресторана."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        else do:
            assign
                p-fbr-obj-type  = buf_fbr-gds-obj.fbr-obj-type
                p-fbr-obj-code  = buf_fbr-gds-obj.fbr-obj-code
            .
        end.
    end.        /* if p-mode = {&add-def} */
    find first buf_init_recipe no-lock
         where buf_init_recipe.recipe-code = p-recipe-code
    no-error.
    assign
        fi-artic        = buf_init_goods.artic
        fi-name         = buf_init_goods.gds-name
        fi-kitchen-type = p-fbr-obj-type
        fi-kitchen-code = p-fbr-obj-code
        fi-fact-qnty    = p-fact-qnty
    .
    if available buf_init_recipe
    then do:
        assign
            fi-recipe-code  = p-recipe-code
            fi-recipe-name  = buf_init_recipe.recipe-name
        .
    end.
    else do:
        assign
            fi-kitchen-type :label in frame {&frame-name} = "Склад"
        .
    end.
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-kitchen Dialog-Frame
PROCEDURE select-kitchen :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-old-obj-type   as character    no-undo.
define input parameter p-old-obj-code   as integer      no-undo.
define output parameter p-new-obj-type   as character    no-undo.
define output parameter p-new-obj-code   as integer      no-undo.

    define variable v-types as character no-undo .
    define variable v-old-cli-recid    as recid      no-undo.
    define variable v-new-cli-recid    as recid      no-undo.

    define buffer buf_clients       for clients.
do
on error undo, return error
:
    assign
        v-types = {&shop}
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-old-obj-type
           and buf_clients.obj-code = p-old-obj-code
    no-error.
    if available buf_clients
    then do:
        assign
            v-old-cli-recid = recid( buf_clients )
        .
    end.
    else do:
        assign
            v-old-cli-recid = ?
        .
    end.
    run ref/cli-all.w (
          input parparentproc
        , input "b-sel"
        , input v-types
        , input ?
        , input ?
        , input v-old-cli-recid
        , input ?
        , input ?
        , output v-new-cli-recid
    ) .
    find first buf_clients no-lock
         where recid( buf_clients ) = v-new-cli-recid
    no-error.
    if available buf_clients
    then do:
        assign
            p-new-obj-type = buf_clients.obj-type
            p-new-obj-code = buf_clients.obj-code
        .
    end.
    else do:
        assign
            p-new-obj-type = ""
            p-new-obj-code = 0
        .
    end.
end.
END PROCEDURE. /* select-kitchen */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME