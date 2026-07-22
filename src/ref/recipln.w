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

Редактирование товара рецепта

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-mode              as character   - {&recipe-reference} - вызов из справочника рецептов, другое - из документа производства
    p-recipe-type       as character   - тип рецепта
    p-recipe-string     as character   - строка для отображения названия рецепта
    p-goods-string      as character   - строка для отображения названия товара
    p-is-pieces         as logical     - yes для штучного товара
    p-is-waste          as logical     - yes, если это отходы
    p-netto             as decimal     - количество нетто
    p-coef-value        as decimal     - сезонный коэффициент (не пересчитывается)
    p-coeff-waste       as decimal     - коэффициент отходов
    p-brutto            as decimal     - количество брутто
    p-calc-method       as integer     - метод расчета
Output:
    p-out-is-waste      as logical     - yes, если это отходы
    p-out-netto         as decimal     - количество нетто
    p-out-coeff-waste   as decimal     - коэффициент отходов
    p-out-brutto        as decimal     - количество брутто
    p-out-calc-method   as integer     - метод расчета
    p-success           as logical     - yes если изменения надо принять
*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mode               as character        no-undo.
define input parameter p-recipe-type        as character        no-undo.
define input parameter p-recipe-string      as character        no-undo.
define input parameter p-goods-string       as character        no-undo.
define input parameter p-is-pieces          as logical          no-undo.
define input parameter p-is-waste           as logical          no-undo.
define input parameter p-netto              as decimal          no-undo.
define input parameter p-coeff-value        as decimal          no-undo.
define input parameter p-coeff-waste        as decimal          no-undo.
define input parameter p-brutto             as decimal          no-undo.
define input parameter p-calc-method        as integer          no-undo.
define output parameter p-out-is-waste      as logical          no-undo.
define output parameter p-out-netto         as decimal          no-undo.
define output parameter p-out-coeff-waste   as decimal          no-undo.
define output parameter p-out-brutto        as decimal          no-undo.
define output parameter p-out-calc-method   as integer          no-undo.
define output parameter p-success           as logical          no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование товара рецепта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/fbrlib.i   }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help tb-is-waste ~
rs-calc-method
&Scoped-Define DISPLAYED-OBJECTS fi-recipe-code fi-goods tb-is-waste ~
fi-coeff-value rs-calc-method fi-netto fi-coeff-waste fi-brutto

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-brutto AS DECIMAL FORMAT ">,>>>,>>9.999":U INITIAL 0
     LABEL "Брутто"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-coeff-value AS DECIMAL FORMAT ">>9.999":U INITIAL 0
     LABEL "ПроцСез"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-coeff-waste AS DECIMAL FORMAT ">>9.999":U INITIAL 0
     LABEL "ПроцПот"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-goods AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 53.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-netto AS DECIMAL FORMAT ">,>>>,>>9.999":U INITIAL 0
     LABEL "Нетто"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE fi-recipe-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Рецепт"
     VIEW-AS FILL-IN
     SIZE 53.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-calc-method AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
"Нетто   через Брутто и ПроцПот", 1,
"ПроцПот через Брутто и Нетто", 2,
"Брутто  через Нетто  и ПроцПот", 3
     SIZE 36.5 BY 4.5 NO-UNDO.

DEFINE VARIABLE tb-is-waste AS LOGICAL INITIAL no
     LABEL "Отходы"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-cancel AT ROW 1.17 COL 12
     b-help AT ROW 1.21 COL 56.88
     fi-recipe-code AT ROW 2.5 COL 11.38 COLON-ALIGNED
     fi-goods AT ROW 3.71 COL 11.38 COLON-ALIGNED
     tb-is-waste AT ROW 5 COL 13.5
     fi-coeff-value AT ROW 6.5 COL 11.5 COLON-ALIGNED
     rs-calc-method AT ROW 7.75 COL 29 NO-LABEL
     fi-netto AT ROW 8 COL 11.5 COLON-ALIGNED
     fi-coeff-waste AT ROW 9.5 COL 11.5 COLON-ALIGNED
     fi-brutto AT ROW 11 COL 11.5 COLON-ALIGNED
     SPACE(40.87) SKIP(1.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товар рецепта".


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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-brutto IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-coeff-value IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-coeff-waste IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-goods IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-netto IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-recipe-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товар рецепта */
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
        p-success = no
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
    define variable v-error-message     as character      no-undo.
    define variable v-not-good          as logical        no-undo.
    assign
        tb-is-waste
        rs-calc-method
    .
    if p-recipe-type <> {&manufacturing}
    then do:
        assign
            fi-brutto
        .
        assign
            p-out-netto         = fi-brutto
            p-out-brutto        = fi-brutto
            p-out-coeff-waste   = 0
            p-out-calc-method   = 1
        .
    end.        /* if p-recipe-type <> {&manufacturing} */
    else do:
        case rs-calc-method
        :
            when 1
            then do:
                assign
                    fi-coeff-waste
                    fi-brutto
                .
            end.        /* when 1 */
            when 2
            then do:
                assign
                    fi-netto
                    fi-brutto
                .
            end.        /* when 2 */
            when 3
            then do:
                assign
                    fi-netto
                    fi-coeff-waste
                .
            end.        /* when 3 */
        end case.       /* case rs-calc-method */
        assign
            p-out-netto         = fi-netto
            p-out-coeff-waste   = fi-coeff-waste
            p-out-brutto        = fi-brutto
            p-out-calc-method   = rs-calc-method
        .
    end.        /* NOT ( if p-recipe-type <> {&manufacturing} ) */
    assign
        p-out-is-waste      = ( if p-is-pieces = yes then no else tb-is-waste     )
    .
    run check-fields in this-procedure (
          input p-out-is-waste
        , input p-out-netto
        , input p-out-coeff-waste
        , input p-out-brutto
        , input p-out-calc-method
        , output v-error-message
        , output v-not-good
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
    if v-not-good = yes
    then do:
        message
            v-error-message
            skip (1)
            skip "Исправьте данные или отмените изменение ингредиента."
        view-as alert-box error
        title "Проверка введенных данных".
        undo, return no-apply .
    end.
    assign
        p-success        = yes
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-netto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-netto Dialog-Frame
ON LEAVE OF fi-netto IN FRAME Dialog-Frame /* Нетто */
OR LEAVE OF fi-coeff-waste IN FRAME Dialog-Frame /* КоэфОтх */
OR LEAVE OF fi-brutto IN FRAME Dialog-Frame /* Брутто */
DO:
{ gbl/stdbtn.i }
    if p-recipe-type <> {&manufacturing}
    then do:
        /* ничего не пересчитывать */
    end.
    else do:
        if decimal( fi-coeff-waste :screen-value ) < 0
        or decimal( fi-coeff-waste :screen-value ) >= 100
        then do:
            message
                "Значение процента потерь"
                skip "должно быть больше или равно 0"
                skip "и строго меньше 100."
                skip(1)
                skip "Исправьте значение процента"
                skip "или отмените операцию."
            view-as alert-box error
            title "Неверное значение процента потерь".
            undo, return no-apply.
        end.
        run calc-qnty in this-procedure
        no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка расчета количеств"
                skip "в рецепте документа производства."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-netto Dialog-Frame
ON RETURN OF fi-netto IN FRAME Dialog-Frame /* Нетто */
DO:
{ gbl/stdbtn.i }
/*    if p-mode = {&recipe-reference}*/
/*    then do:*/
/*        apply "entry" to b-exit.*/
/*        return no-apply.*/
/*    end.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-calc-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-calc-method Dialog-Frame
ON VALUE-CHANGED OF rs-calc-method IN FRAME Dialog-Frame
DO:
{ gbl/stdbtn.i }
    run manage-qnty-fields in this-procedure
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при выборе метода расчета"
            skip "в рецепте документа производства."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run calc-qnty in this-procedure
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка расчета количеств"
            skip "в рецепте документа производства."
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

    run init-fields in this-procedure.
    RUN enable_UI.
    run hide-if-not-manufacturing in this-procedure .
    run manage-qnty-fields in this-procedure.
    if p-is-pieces
    then do:
        disable
            tb-is-waste
        with frame {&frame-name} .
    end.
/*    if p-mode = {&recipe-reference}*/
/*    then do:*/
/*        apply "entry" to fi-netto.*/
/*    end.*/
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-qnty Dialog-Frame
PROCEDURE calc-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-coeff-value    as decimal      no-undo.

do with frame {&frame-name}
on error undo, return error
:
    assign
        fi-netto
        fi-brutto
        fi-coeff-waste
        rs-calc-method
    .
    if p-mode = {&recipe-reference}
    then do:        /* Брутто в справочнике рецептов считается без учета сезонного коэффициента */
        assign
            v-coeff-value = 0
        .
    end.
    else do:
        assign
            v-coeff-value = p-coeff-value
        .
    end.
    assign
        rs-calc-method
    .
    run fbrlib-calc-brutto in this-procedure (
          input p-recipe-type
        , input fi-netto
        , input v-coeff-value
        , input fi-coeff-waste
        , input fi-brutto
        , input rs-calc-method
        , output fi-netto
        , output fi-coeff-waste
        , output fi-brutto
        , output rs-calc-method
    ).
    display
        fi-netto
        fi-coeff-waste
        fi-brutto
        rs-calc-method
    .
end.
END PROCEDURE. /* calc-qnty */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-fields Dialog-Frame
PROCEDURE check-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-waste           as logical      no-undo.
define input parameter p-netto              as decimal      no-undo.
define input parameter p-coeff-waste        as decimal      no-undo.
define input parameter p-brutto             as decimal      no-undo.
define input parameter p-calc-method        as integer      no-undo.
define output parameter p-error-message     as character    no-undo.
define output parameter p-not-good          as logical      no-undo.

    define variable v-coeff-value    as decimal      no-undo.
do
on error undo, return error
:
    if p-is-pieces = yes
    and p-is-waste = yes
    then do:
        assign
            p-not-good      = yes
            p-error-message = ( if p-error-message = "" then "" else p-error-message + {&new-line} )
                                + "Штучный товар не может быть отходом."
        .
    end.
    if p-mode = {&recipe-reference}
    then do:        /* Брутто в справочнике рецептов считается без учета сезонного коэффициента */
        assign
            v-coeff-value = 0
        .
    end.
    else do:
        assign
            v-coeff-value = p-coeff-value
        .
    end.
    run fbrlib-check-brutto in this-procedure (
          input p-recipe-type
        , input p-netto
        , input v-coeff-value
        , input p-coeff-waste
        , input p-brutto
        , input p-calc-method
        , output p-error-message
        , output p-not-good
    ).
end.
END PROCEDURE. /* check-fields */

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
  DISPLAY fi-recipe-code fi-goods tb-is-waste fi-coeff-value rs-calc-method
          fi-netto fi-coeff-waste fi-brutto
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help tb-is-waste rs-calc-method
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
    define variable v-coeff-value    as decimal      no-undo.
    define variable v-coeff-waste    as decimal      no-undo.
    define variable v-calc-method    as integer      no-undo.
    assign
        fi-recipe-code  = p-recipe-string
        fi-goods        = p-goods-string
        tb-is-waste     = p-is-waste
    .
    if p-recipe-type = {&manufacturing}
    then do:
        assign
            fi-coeff-value  = p-coeff-value
            rs-calc-method  = p-calc-method
        .
        if p-mode = {&recipe-reference}
        then do:        /* Брутто в справочнике рецептов считается без учета сезонного коэффициента */
            assign
                v-coeff-value = 0
            .
        end.
        else do:
            assign
                v-coeff-value = p-coeff-value
            .
        end.
        run fbrlib-calc-brutto in this-procedure (
              input p-recipe-type
            , input p-netto
            , input v-coeff-value
            , input p-coeff-waste
            , input p-brutto
            , input rs-calc-method
            , output fi-netto
            , output fi-coeff-waste
            , output fi-brutto
            , output rs-calc-method
        ).
    end.
    else do:
        assign
            fi-coeff-value  = 0
            fi-coeff-waste  = 0
            rs-calc-method  = 1
            fi-netto        = p-brutto
            fi-brutto       = p-brutto
        .
    end.
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-qnty-fields Dialog-Frame
PROCEDURE manage-qnty-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do with frame {&frame-name}
on error undo, return error
:
    if p-recipe-type <> {&manufacturing}
    then do:
        enable
            fi-brutto
        .
        apply "entry" to fi-brutto.
        undo, return .
    end.
    assign
        rs-calc-method
    .
    case rs-calc-method
    :
        when 1
        then do:
            disable
                fi-netto
            .
            enable
                fi-coeff-waste
                fi-brutto
            .
        end.        /* when 1 */
        when 2
        then do:
            disable
                fi-coeff-waste
            .
            enable
                fi-netto
                fi-brutto
            .
        end.        /* when 2 */
        when 3
        then do:
            disable
                fi-brutto
            .
            enable
                fi-netto
                fi-coeff-waste
            .
        end.        /* when 3 */
    end case.       /* case fi-calc-method */
end.
END PROCEDURE. /* manage-qnty-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-if-not-manufacturing {&FRAME-NAME}
PROCEDURE hide-if-not-manufacturing :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do with frame {&frame-name}
on error undo, return error
:
    if p-recipe-type <> {&manufacturing}
    then do:
        hide
            fi-netto
            fi-coeff-value
            fi-coeff-waste
            rs-calc-method
        .
    end.
end.
END PROCEDURE. /* hide-if-not-manufacturing */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME