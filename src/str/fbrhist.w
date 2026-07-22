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

История производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-doc-code   as character    no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История производства".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/fbrhist.i  }
{ cmp/showinf.i  }

define variable v-fbrhist-sort-type         as integer              no-undo.
define variable v-fbrhist-doc-code          as character            no-undo.
define variable v-fbrhist-date-from         as date                 no-undo.
define variable v-fbrhist-date-to           as date                 no-undo.
define variable v-fbrhist-level             as integer              no-undo.
define variable v-fbrhist-userid            as character            no-undo.
define variable v-fbrhist-cur-recid         as integer              no-undo.
define variable v-fbrhist-focused-row       as integer              no-undo.
define variable v-fbrhist-columns-amount    as integer              no-undo.
define variable v-fbrhist-column-handles    as handle   extent 20   no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES fbr-history

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 fbr-history.hst-code fbr-history.hst-upper-code fbr-history.hst-level fbr-history.sys-date fbr-history.hst-type fbr-history.obj-type fbr-history.obj-code fbr-history.doc-code fbr-history.doc-type fbr-history.status_ fbr-history.recipe-type fbr-history.recipe-code fbr-history.gds-code fbr-history.trn-type fbr-history.qnty fbr-history.PS fbr-history.user-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 /*OPEN QUERY {&SELF-NAME} FOR EACH fbr-history NO-LOCK INDEXED-REPOSITION.*/ run local-open-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 fbr-history
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 fbr-history


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit bt-del bt-sort b-help BROWSE-1 ~
ed-parameters ed-comment
&Scoped-Define DISPLAYED-OBJECTS fi-sort-string ed-parameters ed-comment

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
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

DEFINE BUTTON bt-del
     LABEL "О&чистить"
     SIZE 10 BY 1.

DEFINE BUTTON bt-sort
     LABEL "Группировка"
     SIZE 15 BY 1.

DEFINE VARIABLE ed-comment AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 52 BY 2.75
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE ed-parameters AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 44 BY 2.75
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-sort-string AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      fbr-history SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 NO-LOCK DISPLAY
      fbr-history.hst-code COLUMN-LABEL "КодЗаписи" FORMAT "999999999":U
            WIDTH 10
      fbr-history.hst-upper-code COLUMN-LABEL "КодРод" FORMAT "999999999":U
            WIDTH 10
      fbr-history.hst-level COLUMN-LABEL "Дет" FORMAT "ZZ9":U
      fbr-history.sys-date FORMAT "99/99/9999":U
      fbr-history.hst-type COLUMN-LABEL "Событие" FORMAT "X(8)":U
            WIDTH 9
      fbr-history.obj-type COLUMN-LABEL "Тип" FORMAT "X(3)":U WIDTH 4
      fbr-history.obj-code COLUMN-LABEL "кодОб" FORMAT "99999":U
      fbr-history.doc-code FORMAT "X(14)":U
      fbr-history.doc-type COLUMN-LABEL "ТипДок" FORMAT "X(6)":U
      fbr-history.status_ FORMAT "X(8)":U
      fbr-history.recipe-type COLUMN-LABEL "ТипРец" FORMAT "X(16)":U
      fbr-history.recipe-code COLUMN-LABEL "НомРец" FORMAT "X(8)":U
      fbr-history.gds-code COLUMN-LABEL "КодТов" FORMAT "999999999":U
      fbr-history.trn-type COLUMN-LABEL "Спи" FORMAT "X(3)":U
      fbr-history.qnty FORMAT "->>,>>>,>>9.<<<":U
      fbr-history.PS FORMAT "X(50)":U
      fbr-history.user-name COLUMN-LABEL "Пользователь" FORMAT "X(12)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 17.75 ROW-HEIGHT-CHARS .58 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.25 COL 2
     bt-del AT ROW 1.25 COL 12
     bt-sort AT ROW 1.25 COL 29.5
     fi-sort-string AT ROW 1.25 COL 43 COLON-ALIGNED NO-LABEL
     b-help AT ROW 1.25 COL 88.5
     BROWSE-1 AT ROW 2.5 COL 2
     ed-parameters AT ROW 20.5 COL 2 NO-LABEL
     ed-comment AT ROW 20.5 COL 46.5 NO-LABEL
     SPACE(0.62) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История производства"
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
/* BROWSE-TAB BROWSE-1 b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ed-comment:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       ed-parameters:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fi-sort-string IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
/*OPEN QUERY {&SELF-NAME} FOR EACH fbr-history NO-LOCK INDEXED-REPOSITION.*/
run local-open-query in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* История производства */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    run set-param in this-procedure (
          input v-fbrhist-sort-type
        , input v-fbrhist-doc-code
        , input v-fbrhist-date-from
        , input v-fbrhist-date-to
        , input v-fbrhist-level
        , input v-fbrhist-userid
        , input ( if available fbr-history then integer( recid( fbr-history ) ) else 0 )
        , input browse-1 :focused-row in frame {&FRAME-NAME}
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка записи параметров списка истории производства"
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-1 IN FRAME Dialog-Frame
DO:
    define variable v-counter    as integer      no-undo.
    if available fbr-history
    then do:
        if fbr-history.is-error = yes
        then do:
            do v-counter = 1 to v-fbrhist-columns-amount
            :
                assign
                    v-fbrhist-column-handles [ v-counter ] :fgcolor = 4
                .
            end.
        end.
        else do:
            if fbr-history.hst-type         = {&fbrhist-type-run}
            or fbr-history.hst-type         = {&fbrhist-type-end}
            or fbr-history.hst-upper-code   = 0
            then do:
                do v-counter = 1 to v-fbrhist-columns-amount
                :
                    assign
                        v-fbrhist-column-handles [ v-counter ] :fgcolor = 1
                    .
                end.
            end.
        end.
    end.        /* if available fbr-history */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
    run refresh-editors in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-del Dialog-Frame
ON CHOOSE OF bt-del IN FRAME Dialog-Frame /* Очистить */
DO:
    define variable v-date-to-clear as date         no-undo.
    define variable v-clear-level   as integer      no-undo.
    define variable v-ok            as logical      no-undo.

    run str/fbrhistd.w (
          output v-date-to-clear
        , output v-clear-level
        , output v-ok
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка задания параметров очистки истории."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-ok = yes
    then do:
        message
                 "Очистка истории."
            skip (1)
            skip "Дата, до которой история будет очищена:" v-date-to-clear
            skip "Уровень детализации очистки:" v-clear-level
            skip (1)
            skip "Очистить историю?"
        view-as alert-box information
        buttons yes-no
        title "Очистка истории"
        update v-ok.
        if v-ok = yes
        then do:
            run clear-history in this-procedure (
                  input v-date-to-clear
                , input v-clear-level
            ) no-error.
            if error-status :error
            then do:
                message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при очистке истории."
                    skip return-value
                    skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return no-apply .
            end.
            run local-open-query in this-procedure.
        end.        /* if v-ok = yes */
    end.        /* if v-ok = yes */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sort Dialog-Frame
ON CHOOSE OF bt-sort IN FRAME Dialog-Frame /* Группировка */
DO:
    define variable v-sort-type     as integer      no-undo.
    define variable v-doc-code      as character    no-undo.
    define variable v-date-from     as date         no-undo.
    define variable v-date-to       as date         no-undo.
    define variable v-level         as integer      no-undo.
    define variable v-userid        as character    no-undo.
    define variable v-ok            as logical      no-undo.

    if available fbr-history
    then do:
        assign
            v-sort-type  = v-fbrhist-sort-type
            v-doc-code   = fbr-history.doc-code
            v-date-from  = v-fbrhist-date-from
            v-date-to    = v-fbrhist-date-to
            v-level      = v-fbrhist-level
            v-userid     = fbr-history.user-name
        .
    end.        /* if available fbr-history */
    else do:
        assign
            v-sort-type  = v-fbrhist-sort-type
            v-doc-code   = v-fbrhist-doc-code
            v-date-from  = v-fbrhist-date-from
            v-date-to    = v-fbrhist-date-to
            v-level      = v-fbrhist-level
            v-userid     = v-fbrhist-userid
        .
    end.        /* if not available fbr-history */
    run str/fbrhists.w (
          input v-sort-type
        , input v-doc-code
        , input v-date-from
        , input v-date-to
        , input v-level
        , input v-userid
        , output v-fbrhist-sort-type
        , output v-fbrhist-doc-code
        , output v-fbrhist-date-from
        , output v-fbrhist-date-to
        , output v-fbrhist-level
        , output v-fbrhist-userid
        , output v-ok
    ) no-error.
    if error-status :error
    then do:
        message
                vss-workfile vss-revision vss-description
            skip "Ошибка изменения правил группировки."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-ok = yes
    and ( v-fbrhist-sort-type <> v-sort-type
        or v-fbrhist-doc-code  <> v-doc-code
        or v-fbrhist-date-from <> v-date-from
        or v-fbrhist-date-to   <> v-date-to
        or v-fbrhist-level     <> v-level
        or v-fbrhist-userid    <> v-userid )
    then do:
        run local-open-query in this-procedure.
        run assign-fi-sort-string in this-procedure.
    end.
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
    run get-param in this-procedure.
    RUN enable_UI.
    run fill-column-handles in this-procedure.
    run assign-fi-sort-string in this-procedure.
    if v-fbrhist-cur-recid <> 0
    then do:
        browse-1 :set-repositioned-row( v-fbrhist-focused-row, "ALWAYS" ) in frame {&FRAME-NAME}.
        reposition browse-1 to recid( v-fbrhist-cur-recid ) no-error.
    end.
    run refresh-editors in this-procedure.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-fi-sort-string Dialog-Frame
PROCEDURE assign-fi-sort-string :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    case v-fbrhist-sort-type
    :
        when 1
        then do:
            assign
                fi-sort-string = "Все" + ( if v-fbrhist-level <> 0 then " до уровня " + string( v-fbrhist-level ) else "" )
            .
        end.        /* when 1 */
        when 2
        then do:
            assign
                fi-sort-string = ( if v-fbrhist-doc-code <> "" then "По документу " + v-fbrhist-doc-code else "" )
            .
        end.        /* when 2 */
        when 3
        then do:
            assign
                fi-sort-string = "Даты"
                            + ( if v-fbrhist-date-from <> ? then " с ":U + string( v-fbrhist-date-from, "99.99.99" ) else "" )
                            + ( if v-fbrhist-date-to   <> ? then " по ":U + string( v-fbrhist-date-to, "99.99.99" )  else "" )
                            + ( if v-fbrhist-level <> 0 then " до уровня ":U + string( v-fbrhist-level ) else "" )
            .
        end.        /* when 3 */
        when 4
        then do:
            assign
                fi-sort-string = ( if v-fbrhist-userid   <> "" then "Пользователь " + v-fbrhist-userid else "" )
            .
        end.        /* when 4 */
    end case.       /* case v-fbrhist-sort-type */
    display
        fi-sort-string
    with frame {&frame-name} .
end.
END PROCEDURE. /* assign-fi-sort-string */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear-history Dialog-Frame
PROCEDURE clear-history :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-date-to-clear  as date         no-undo.
define input parameter p-clear-level    as integer      no-undo.

    define buffer buf_fbr-history       for fbr-history.

do
for buf_fbr-history
on error undo, return error
:
    for each buf_fbr-history exclusive-lock
       where buf_fbr-history.sys-date  <= p-date-to-clear
         and buf_fbr-history.hst-level >= p-clear-level
    on error undo, return error
    :
        delete buf_fbr-history.
    end.        /* for each buf_fbr-history */
end.
END PROCEDURE. /* clear-history */

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
  DISPLAY fi-sort-string ed-parameters ed-comment
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-del bt-sort b-help BROWSE-1 ed-parameters ed-comment
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-column-handles Dialog-Frame
PROCEDURE fill-column-handles :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-column-handle as handle   no-undo .
    define variable v-counter       as integer  no-undo.
do
on error undo, return error
:

        assign
            v-counter                               = 1
            v-fbrhist-column-handles [ v-counter ]  = {&browse-name} :first-column in frame {&frame-name}
        .
        do while
        valid-handle( v-fbrhist-column-handles [ v-counter ] :next-column )
        and v-counter < extent( v-fbrhist-column-handles )
        :
            assign
                v-fbrhist-column-handles [ v-counter + 1 ] = v-fbrhist-column-handles [ v-counter ] :next-column
            .
            assign
                v-counter = v-counter + 1
            .
        end.
        assign
            v-fbrhist-columns-amount = v-counter
        .
end.
END PROCEDURE. /* fill-column-handles */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-param Dialog-Frame
PROCEDURE get-param :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-num-entries    as integer      no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.

do
for buf_usr-flt
on error undo, return error
:
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = g#userid
           and buf_usr-flt.call-point = {&fbrhistory}
    no-error.
    if available buf_usr-flt
    then do:
        assign
            v-num-entries = num-entries( buf_usr-flt.List_ )
        .
        if v-num-entries >= 1
        then do:
            assign
                v-fbrhist-sort-type = integer( entry( 1, buf_usr-flt.List_ ) )
            no-error.
            if error-status :error
            then do:
                assign
                    v-fbrhist-sort-type = 1
                .
            end.
            if v-num-entries >= 2
            then do:
                assign
                    v-fbrhist-doc-code = entry( 2, buf_usr-flt.List_ )
                no-error.
                if error-status :error
                then do:
                    assign
                        v-fbrhist-doc-code = "":U
                    .
                end.
                if v-num-entries >= 3
                then do:
                    assign
                        v-fbrhist-date-from = date( entry( 3, buf_usr-flt.List_ ) )
                    no-error.
                    if error-status :error
                    then do:
                        assign
                            v-fbrhist-date-from = ?
                        .
                    end.
                    if v-num-entries >= 4
                    then do:
                        assign
                            v-fbrhist-date-to = date( entry( 4, buf_usr-flt.List_ ) )
                        no-error.
                        if error-status :error
                        then do:
                            assign
                                v-fbrhist-date-to = ?
                            .
                        end.
                        if v-num-entries >= 5
                        then do:
                            assign
                                v-fbrhist-level = integer( entry( 5, buf_usr-flt.List_ ) )
                            no-error.
                            if error-status :error
                            then do:
                                assign
                                    v-fbrhist-level = 1
                                .
                            end.
                            if v-num-entries >= 6
                            then do:
                                assign
                                    v-fbrhist-userid    = entry( 6, buf_usr-flt.List_ )
                                no-error.
                                if error-status :error
                                then do:
                                    assign
                                        v-fbrhist-userid    = "":U
                                    .
                                end.
                                if v-num-entries >= 7
                                then do:
                                    assign
                                        v-fbrhist-cur-recid = integer( entry( 7, buf_usr-flt.List_ ) )
                                    no-error.
                                    if error-status :error
                                    then do:
                                        assign
                                            v-fbrhist-cur-recid = 0
                                        .
                                    end.
                                    if v-num-entries >= 8
                                    then do:
                                        assign
                                            v-fbrhist-focused-row = integer( entry( 8, buf_usr-flt.List_ ) )
                                        no-error.
                                        if error-status :error
                                        then do:
                                            assign
                                                v-fbrhist-focused-row = 0
                                            .
                                        end.
                                    end.        /* if num-entries( buf_usr-flt.List_ ) >= 8 */
                                end.        /* if num-entries( buf_usr-flt.List_ ) >= 7 */
                             end.        /* if num-entries( buf_usr-flt.List_ ) >= 6 */
                        end.        /* if num-entries( buf_usr-flt.List_ ) >= 5 */
                    end.        /* if num-entries( buf_usr-flt.List_ ) >= 4 */
                end.        /* if num-entries( buf_usr-flt.List_ ) >= 3 */
            end.        /* if num-entries( buf_usr-flt.List_ ) >= 2 */
        end.        /* if num-entries( buf_usr-flt.List_ ) >= 1 */
    end.
end.
END PROCEDURE. /* get-param */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query Dialog-Frame
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-hst-level-from    as integer      no-undo.
    define variable v-hst-level-to      as integer      no-undo.
    define variable v-doc-code-from     as character    no-undo.
    define variable v-doc-code-to       as character    no-undo.
    define variable v-userid-from       as character    no-undo.
    define variable v-userid-to         as character    no-undo.
do
on error undo, return error
:
    assign
        v-date-from        = {&fbrhist-min-date}
        v-date-to          = {&fbrhist-max-date}
        v-hst-level-from   = {&fbrhist-min-integer}
        v-hst-level-to     = {&fbrhist-max-integer}
        v-doc-code-from    = {&fbrhist-min-character}
        v-doc-code-to      = {&fbrhist-max-character}
        v-userid-from      = {&fbrhist-min-character}
        v-userid-to        = {&fbrhist-max-character}
    .
    case v-fbrhist-sort-type
    :
        when 1
        then do:
            if v-fbrhist-level <> 0
            then do:
                assign
                    v-hst-level-to = v-fbrhist-level
                .
            end.
        end.        /* when 1 */
        when 2
        then do:
            if v-fbrhist-doc-code <> ""
            then do:
                assign
                    v-doc-code-from = v-fbrhist-doc-code
                    v-doc-code-to   = v-fbrhist-doc-code
                .
            end.
        end.        /* when 2 */
        when 3
        then do:
            if v-fbrhist-date-from <> ?
            then do:
                assign
                    v-date-from = v-fbrhist-date-from
                .
            end.
            if v-fbrhist-date-to <> ?
            then do:
                assign
                    v-date-to = v-fbrhist-date-to
                .
            end.
            if v-fbrhist-level <> 0
            then do:
                assign
                    v-hst-level-to = v-fbrhist-level
                .
            end.
        end.        /* when 3 */
        when 4
        then do:
            if v-fbrhist-userid <> ?
            then do:
                assign
                    v-userid-from = v-fbrhist-userid
                    v-userid-to   = v-fbrhist-userid
                .
            end.
        end.        /* when 4 */
    end case.       /* case v-fbrhist-sort-type */
    if v-fbrhist-sort-type = 2
    then do:

    end.        /* if v-fbrhist-sort-type = 2 */
    else do:
        open query {&BROWSE-NAME}
            for each fbr-history no-lock
               where fbr-history.sys-date  >= v-date-from
                 and fbr-history.sys-date  <= v-date-to
                 and fbr-history.hst-level >= v-hst-level-from
                 and fbr-history.hst-level <= v-hst-level-to
                 and fbr-history.doc-code  >= v-doc-code-from
                 and fbr-history.doc-code  <= v-doc-code-to
                 and fbr-history.user-name >= v-userid-from
                 and fbr-history.user-name <= v-userid-to
            by fbr-history.sys-date descending
            by fbr-history.sys-time-int descending
        indexed-reposition .
    end.        /* NOT ( if v-fbrhist-sort-type = 2 ) */
end.
END PROCEDURE. /* local-open-query */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-editors Dialog-Frame
PROCEDURE refresh-editors :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    assign
        ed-comment      = fbr-history.PS
        ed-parameters   = substitute( "Вызов: &1. Параметры: &2"
                                        , fbr-history.procedure-name
                                        , fbr-history.procedure-parameters
                                      )
    .
    display
        ed-comment
        ed-parameters
    with frame {&frame-name} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-param Dialog-Frame
PROCEDURE set-param :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-fbrhist-sort-type    as integer      no-undo.
define input parameter p-fbrhist-doc-code     as character    no-undo.
define input parameter p-fbrhist-date-from    as date         no-undo.
define input parameter p-fbrhist-date-to      as date         no-undo.
define input parameter p-fbrhist-level        as integer      no-undo.
define input parameter p-fbrhist-userid       as character    no-undo.
define input parameter p-fbrhist-cur-recid    as integer      no-undo.
define input parameter p-fbrhist-focused-row  as integer      no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.

do
for buf_usr-flt
on error undo, return error
:
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = g#userid
           and buf_usr-flt.call-point = {&fbrhistory}
    no-error.
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name  = g#userid
            buf_usr-flt.call-point = {&fbrhistory}
        .
    end.
    assign
        buf_usr-flt.List_ =   string( p-fbrhist-sort-type   )
                    + ",":U + string( p-fbrhist-doc-code    )
                    + ",":U + string( p-fbrhist-date-from, "99/99/9999" )
                    + ",":U + string( p-fbrhist-date-to, "99/99/9999"   )
                    + ",":U + string( p-fbrhist-level       )
                    + ",":U + string( p-fbrhist-userid      )
                    + ",":U + string( p-fbrhist-cur-recid   )
                    + ",":U + string( p-fbrhist-focused-row )

    .
end.
END PROCEDURE. /* set-param */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
