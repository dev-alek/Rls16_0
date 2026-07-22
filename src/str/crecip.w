&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Просмотр истории рецепта.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-mode           as character - режим запроса для таблицы:
                                    1 - задан номер рецепта.
                                        Возможны ограничения или сортировки:
                                            по имени пользователя, затем по дате, затем по времени.
                                    2 - задано имя пользователя.
                                        Возможны ограничения или сортировки:
                                            по номеру рецепта, затем по дате.
                                    3 - задан диапазон дат.
                                        Возможны ограничения или сортировки:
                                            по имени пользователя, затем по времени.
                                    4 - задан код товара.
                                        Возможны ограничения или сортировки:
                                            по дате, затем по времени.

    p-recipe-code    as character   - номер рецепта
    p-userid         as character   - имя пользовател
    p-date-1         as date        - диапазон дат
    p-date-2         as date
    p-gds-code       as integer     - код товара

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mode           as integer          no-undo.
define input parameter p-recipe-code    as character        no-undo.
define input parameter p-userid         as character        no-undo.
define input parameter p-date-1         as date             no-undo.
define input parameter p-date-2         as date             no-undo.
define input parameter p-gds-code       as integer          no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр истории рецепта.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/bufcomp.i  }

define temp-table temp_changes no-undo
    field field-name as character
    field field-label as character
    field value-old as character
    field value-new as character

    index pi is primary unique
            field-name
.

&global-define date-minimum 01/01/0001
&global-define date-maximum 12/31/4999
&global-define character-minimum ""
&global-define character-maximum chr(254)
&global-define integer-minimum -2147483648
&global-define integer-maximum 2147483647

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-changes

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp_bufcomp_field-diff c-recipe-hist

/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp_bufcomp_field-diff.label-new temp_bufcomp_field-diff.value-old temp_bufcomp_field-diff.value-new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp_bufcomp_field-diff
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY br-changes FOR EACH temp_bufcomp_field-diff.
&Scoped-define TABLES-IN-QUERY-BR-changes temp_bufcomp_field-diff
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp_bufcomp_field-diff


/* Definitions for BROWSE br-table                                      */
&Scoped-define FIELDS-IN-QUERY-br-table get-recipe-fields( input 1, input c-recipe-hist.action, input "":U ) c-recipe-hist.recipe-type get-recipe-fields( input 2, input 0, input c-recipe-hist.subject ) c-recipe-hist.corr-user-name c-recipe-hist.corr-date get-recipe-fields( input 3, input c-recipe-hist.corr-time, input "":U ) c-recipe-hist.recipe-code get-recipe-fields( input 4, input c-recipe-hist.gds-code, input "":U ) c-recipe-hist.recipe-chip-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-table
&Scoped-define SELF-NAME br-table
&Scoped-define OPEN-QUERY-br-table /* OPEN QUERY {&SELF-NAME} FOR EACH c-recipe-hist NO-LOCK INDEXED-REPOSITION. */ run open-query in this-procedure.
&Scoped-define TABLES-IN-QUERY-br-table c-recipe-hist
&Scoped-define FIRST-TABLE-IN-QUERY-br-table c-recipe-hist


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-table}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit bt-filter b-help br-table BR-changes

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-recipe-fields Dialog-Frame
FUNCTION get-recipe-fields RETURNS CHARACTER
  ( p-field-id as integer, p-input-integer as integer, p-input-character as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-filter
     LABEL "&Фильтр"
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-changes FOR
      temp_bufcomp_field-diff SCROLLING.

DEFINE QUERY br-table FOR
      c-recipe-hist SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp_bufcomp_field-diff.label-new column-label "Изменилось" format "X(20)"
temp_bufcomp_field-diff.value-old column-label "Было" format "X(36)"
temp_bufcomp_field-diff.value-new column-label "Стало" format "X(36)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 6.

DEFINE BROWSE br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-table Dialog-Frame _FREEFORM
  QUERY br-table NO-LOCK DISPLAY
      get-recipe-fields( input 1, input c-recipe-hist.action, input "":U ) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      c-recipe-hist.recipe-type COLUMN-LABEL "Тип" FORMAT "X(1)":U
      get-recipe-fields( input 2, input 0, input c-recipe-hist.subject ) COLUMN-LABEL "Сост/Ингр" FORMAT "X(10)":U
      c-recipe-hist.corr-user-name COLUMN-LABEL "Пользователь" FORMAT "X(14)":U
      c-recipe-hist.corr-date COLUMN-LABEL "Дата" FORMAT "99/99/9999":U
      get-recipe-fields( input 3, input c-recipe-hist.corr-time, input "":U ) COLUMN-LABEL "Время" FORMAT "X(5)":U
      c-recipe-hist.recipe-code COLUMN-LABEL "Рецепт" FORMAT "X(12)":U
      get-recipe-fields( input 4, input c-recipe-hist.gds-code, input "":U ) COLUMN-LABEL "Товар" FORMAT "X(20)":U
      c-recipe-hist.recipe-chip-num
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.5 BY 14.75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     bt-filter AT ROW 1 COL 11
     b-help AT ROW 1 COL 89.5
     br-table AT ROW 2.5 COL 2
     BR-changes AT ROW 17.5 COL 2
     SPACE(0.37) SKIP(0.12)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История рецепта"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB br-table b-help Dialog-Frame */
/* BROWSE-TAB BR-changes br-table Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY br-changes FOR EACH temp_bufcomp_field-diff.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-table
/* Query rebuild information for BROWSE br-table
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH c-recipe-hist NO-LOCK INDEXED-REPOSITION. */
run open-query in this-procedure.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-table */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История рецепта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
{ gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-table
&Scoped-define SELF-NAME br-table
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-table Dialog-Frame
ON VALUE-CHANGED OF br-table IN FRAME Dialog-Frame
DO:
    if available c-recipe-hist
    then do:
        run calc-changes in this-procedure (
              input c-recipe-hist.corr-user-db-num
            , input c-recipe-hist.chip-num
        ) no-error.
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "Ошибка вычисления изменений по истории."
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
        {&OPEN-QUERY-BR-changes}
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-changes
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/*{ gbl/app_help.i }*/
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  apply "value-changed" to br-table in frame {&frame-name} .
  apply "entry" to b-exit.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-changes Dialog-Frame
PROCEDURE calc-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-c-recipe-hist-db-num     as integer    no-undo.
define input parameter p-c-recipe-hist-chip-num   as integer    no-undo.

    define variable v-old-recipe-handle     as handle     no-undo.
    define variable v-new-recipe-handle     as handle     no-undo.
    define variable v-find-success          as logical      no-undo.

    define buffer buf_temp_bufcomp_field-diff       for temp_bufcomp_field-diff.



    define variable v-field-list    as character    no-undo.

    define buffer buf_old_c-recipe      for c-recipe.
    define buffer buf_old_c-recipe-gds  for c-recipe-gds.
    define buffer buf_c-recipe-hist     for c-recipe-hist.
do
for buf_c-recipe-hist
  , buf_temp_bufcomp_field-diff
on error undo, return error
:
    for each buf_temp_bufcomp_field-diff
    :
        delete buf_temp_bufcomp_field-diff.
    end.
    find first buf_c-recipe-hist no-lock
         where buf_c-recipe-hist.corr-user-db-num   = p-c-recipe-hist-db-num
           and buf_c-recipe-hist.chip-num = p-c-recipe-hist-chip-num
    .
    if buf_c-recipe-hist.action = integer( {&hn-delete} )
/*    or buf_c-recipe-hist.action = integer( {&hn-create} )*/
    then do:

    end.        /* if buf_c-recipe-hist.action = {&hn-create} */
    else do:
/*                create buffer v-recipe-handle for table "recipe":U.*/
        create buffer v-old-recipe-handle for table substitute( "c-&1":U, buf_c-recipe-hist.subject ).
        assign
            v-find-success = v-old-recipe-handle :find-first(
                substitute( "where &1 = '&2' and &3 = &4 use-index pi"
                    , "recipe-code":U
                    , buf_c-recipe-hist.recipe-code
                    , "chip-num":U
                    , buf_c-recipe-hist.recipe-chip-num
                ), no-lock )
        no-error.
        if v-find-success = yes
        then do:
            create buffer v-new-recipe-handle for table substitute( "c-&1":U, buf_c-recipe-hist.subject ).
            assign
                v-find-success = v-new-recipe-handle :find-first(
                    substitute( "where &1 = '&2' and &3 > &4 use-index pi"
                        , "recipe-code":U
                        , buf_c-recipe-hist.recipe-code
                        , "chip-num":U
                        , buf_c-recipe-hist.recipe-chip-num
                    ), no-lock )
            no-error.
            if v-find-success = yes
            then do:
/*                        message*/
/*                            "X"*/
/*                            skip buf_c-recipe-hist.recipe-chip-num*/
/*                            skip v-old-recipe-handle :buffer-field( "chip-num" ) :buffer-value*/
/*                            skip v-new-recipe-handle :buffer-field( "chip-num" ) :buffer-value*/
/*                        view-as alert-box information.*/
                run bufcomp-buffer-compare in this-procedure (
                      input v-old-recipe-handle
                    , input v-new-recipe-handle
                    , input "chip-num,corr-date,corr-time,corr-user-name,v-user-db-num":U
                ).
            end.        /* if v-find-success = yes */
            else do:
                create buffer v-new-recipe-handle for table buf_c-recipe-hist.subject.
                assign
                    v-find-success = v-new-recipe-handle :find-first(
                        substitute( "where &1 = '&2' use-index pi"
                            , "recipe-code":U
                            , buf_c-recipe-hist.recipe-code
                        ), no-lock )
                no-error.
                if v-find-success = yes
                then do:
                    run bufcomp-buffer-compare in this-procedure (
                            input v-old-recipe-handle
                        , input v-new-recipe-handle
                        , input "chip-num,corr-date,corr-time,corr-user-name,v-user-db-num":U
                    ).
                end.
            end.        /* NOT( if v-find-success = yes ) */
            delete object v-old-recipe-handle.
        end.        /* if v-find-success = yes */
        else
        delete object v-old-recipe-handle.
    end.        /* NOT( if buf_c-recipe-hist.action = {&hn-create} ) */
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
  ENABLE b-exit bt-filter b-help br-table BR-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query Dialog-Frame
PROCEDURE open-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-min      as date       no-undo.
    define variable v-date-max      as date       no-undo.
do
on error undo, return error
:

    assign
        v-date-min = ( if p-date-1 = ? then {&date-minimum} else p-date-1 )
        v-date-max = ( if p-date-2 = ? then {&date-maximum} else p-date-2 )
    .
    case p-mode
    :
        when 1
        then do:
            if p-userid = "":U
            then do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.recipe-code  = p-recipe-code
                         and c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.chip-num descending
                indexed-reposition.
            end.
            else do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.recipe-code  = p-recipe-code
                         and c-recipe-hist.corr-user-name  = p-userid
                         and c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.chip-num descending
                indexed-reposition.
            end.
        end.        /* when 1 */
        when 2
        then do:
            if p-recipe-code = "":U
            then do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.corr-user-name  = p-userid
                         and c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.corr-time
                indexed-reposition.
            end.
            else do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.corr-user-name  = p-userid
                         and c-recipe-hist.recipe-code  = p-recipe-code
                         and c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.corr-time
                indexed-reposition.
            end.
        end.        /* when 2 */
        when 3
        then do:
            if p-userid = "":U
            then do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                    by c-recipe-hist.corr-user-name
                    by c-recipe-hist.corr-time
                indexed-reposition.
            end.
            else do:
                open query br-table
                    for each c-recipe-hist no-lock
                       where c-recipe-hist.corr-date       >= v-date-min
                         and c-recipe-hist.corr-date       <= v-date-max
                         and c-recipe-hist.corr-user-name  = p-userid
                    by c-recipe-hist.corr-time
                indexed-reposition.
            end.
        end.        /* when 3 */
        when 4
        then do:
            open query br-table
                for each c-recipe-hist no-lock
                   where c-recipe-hist.gds-code     = p-gds-code
                     and c-recipe-hist.corr-date       >= v-date-min
                     and c-recipe-hist.corr-date       <= v-date-max
                by c-recipe-hist.corr-time
            indexed-reposition.
        end.        /* when 4 */
    end case.       /* case p-mode */
end.
END PROCEDURE. /* open-query */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-recipe-fields Dialog-Frame
FUNCTION get-recipe-fields RETURNS CHARACTER
  ( p-field-id as integer, p-input-integer as integer, p-input-character as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
    case p-field-id
    :
        when 1
        then do:
            case p-input-integer
            :
                when integer( {&hn-create} )
                then do:
                    return {&hn-create-full}.
                end.
                when integer( {&hn-update} )
                then do:
                    return {&hn-update-full}.
                end.
                when integer( {&hn-delete} )
                then do:
                    return {&hn-delete-full}.
                end.
            end case.
        end.
        when 2
        then do:
            case p-input-character
            :
                when {&table_recipe}
                then do:
                    return "Составной".
                end.
                when {&table_recipe-gds}
                then do:
                    return "Ингредиент".
                end.
            end case.
        end.
        when 3
        then do:
            return string( p-input-integer, "HH:MM":U ).
        end.
        when 4
        then do:
            define variable v-artic     as character  no-undo.
            define variable v-prod-type as character  no-undo.
            define variable v-prod-code as integer    no-undo.
            define variable v-gds-name  as character  no-undo.
            /*
            { gbl/gds-cdnm.i
                p-input-integer
                v-gds-name
            }
            */
            { gbl/arptpc.i
                p-input-integer
                v-artic
                v-prod-type
                v-prod-code
            }
            return substitute( "&1 &2", v-artic, v-gds-name ).
        end.
    end case.
    RETURN "".   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
