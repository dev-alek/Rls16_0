&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Справочник групп прав

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/01/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter       parparentproc      as widget-handle no-undo .
define input  parameter       p-bttns            as character     no-undo .
define input-output parameter p-context          AS character     no-undo .
define OUTPUT parameter       p-action-role-code as integer       no-undo .
define INPUT-OUTPUT parameter p-rid-list         as character     no-undo .
define INPUT  parameter       p-db-num           as integer       no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник групп прав".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/mrk-strf.i }
{ gbl/getcntxt.i def }
{ str/actntw.i   }
{ gbl/onewin.i   }
{ gbl/color.i    }
{gbl/waitfram.i}
{ gbl/prn-lib.i "new shared" }

/* Local Variable Definitions ---                                       */
define stream OutStr-html.
define variable v-current-db-num              as integer   no-undo .
define variable v-can-edit-action-role        as logical   no-undo .
define variable v-current-db-num-screen-value as character no-undo .
define variable v-current-context             as character no-undo .
define variable v-on-gbl                      as logical   no-undo.

define variable v-action-role-context         as character no-undo format "x(8)" column-label "Контекст".
define variable v-action-role-item-state      as character no-undo format "x(3)" column-label "Вкл" .
define variable v-action-role-select          as character no-undo format "x(1)" column-label "*" .
DEFINE VARIABLE g#log                         AS LOGICAL   NO-UNDO.
define variable v-ok                          as logical   no-undo .

define temp-table temp_filter-fields no-undo
    field action-role-code as integer
    field record-on        as logical

    index pi is primary unique
    action-role-code
    .
define temp-table temp_actnrole-user no-undo
    field user-id    as character
    field nik        as character
    field lastName   as character
    field firstName  as character
    field secondName as character

    index pi is primary unique
    user-id
    .
define temp-table temp_filter-fields-item no-undo
    field action-item-code as integer
    field record-on        as logical INIT YES

    index pi is primary unique
    action-item-code
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME browse-action-item

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES action-item temp_filter-fields-item ~
action-group action-role-item action-role temp_filter-fields

/* Definitions for BROWSE browse-action-item                            */
&Scoped-define FIELDS-IN-QUERY-browse-action-item action-group.action-group-name action-item.action-item-name action-item.action-item-id   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browse-action-item   
&Scoped-define SELF-NAME browse-action-item
&Scoped-define OPEN-QUERY-browse-action-item /* OPEN QUERY {&SELF-NAME} FOR EACH action-item, ~
       FIRST temp_filter-fields-item, ~
       FIRST action-group, ~
       first action-role-item. */ RUN refresh-query-action-item .
&Scoped-define TABLES-IN-QUERY-browse-action-item action-item ~
temp_filter-fields-item action-group action-role-item
&Scoped-define FIRST-TABLE-IN-QUERY-browse-action-item action-item
&Scoped-define SECOND-TABLE-IN-QUERY-browse-action-item temp_filter-fields-item
&Scoped-define THIRD-TABLE-IN-QUERY-browse-action-item action-group
&Scoped-define FOURTH-TABLE-IN-QUERY-browse-action-item action-role-item


/* Definitions for BROWSE browse-action-role                            */
&Scoped-define FIELDS-IN-QUERY-browse-action-role mark-string(recid(action-role), p-rid-list) @ v-action-role-select get-action-role-context(BUFFER action-role) @ v-action-role-context action-role.action-role-name action-role.action-role-description   
&Scoped-define ENABLED-FIELDS-IN-QUERY-browse-action-role   
&Scoped-define SELF-NAME browse-action-role
&Scoped-define OPEN-QUERY-browse-action-role /* OPEN QUERY {&SELF-NAME} FOR EACH action-role, ~
       FIRST temp_filter-fields. */ RUN refresh-query-action-role IN THIS-PROCEDURE .
&Scoped-define TABLES-IN-QUERY-browse-action-role action-role ~
temp_filter-fields
&Scoped-define FIRST-TABLE-IN-QUERY-browse-action-role action-role
&Scoped-define SECOND-TABLE-IN-QUERY-browse-action-role temp_filter-fields


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-browse-action-item}~
    ~{&OPEN-QUERY-browse-action-role}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-help rs-scope b-print b-mark ~
b-add b-chg b-del b-toggle b-users b-hist b-filter-role v-filter-role ~
b-filter-item v-filter-item browse-action-role browse-action-item ~
role-editor item-EDITOR 
&Scoped-Define DISPLAYED-OBJECTS rs-scope v-filter-role tb-filter-role ~
v-filter-item tb-filter-item role-editor item-EDITOR 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action-role-context Dialog-Frame 
FUNCTION get-action-role-context RETURNS CHARACTER
    ( BUFFER buf_action-role FOR action-role )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action-role-item-state Dialog-Frame 
FUNCTION get-action-role-item-state RETURNS CHARACTER
    ( BUFFER buf_action-item FOR action-item )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
    LABEL "&Добавить" 
    SIZE 9 BY 1 TOOLTIP "Добавить группу прав".

DEFINE BUTTON b-chg 
    LABEL "&Изменить" 
    SIZE 9 BY 1 TOOLTIP "Изменить группу прав".

DEFINE BUTTON b-del 
    LABEL "&Удалить" 
    SIZE 9 BY 1 TOOLTIP "Удалить группу прав".

DEFINE BUTTON b-filter-item DEFAULT 
    LABEL "&ФПоиск" 
    SIZE 10 BY 1 TOOLTIP "Поиск с фильтром строки во всех текстовых полях"
    BGCOLOR 8 .

DEFINE BUTTON b-filter-role 
    LABEL "Ф&Поиск" 
    SIZE 10 BY 1 TOOLTIP "Поиск с фильтрацией строки во всех текстовых полях формы".

DEFINE BUTTON b-help 
    LABEL "&Помощь" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON b-hist 
    LABEL "Печать" 
    SIZE 3 BY 1.

DEFINE BUTTON b-mark 
    LABEL "&*" 
    SIZE 3 BY 1.

DEFINE BUTTON b-print 
    LABEL "Печать" 
    SIZE 9.63 BY .96.

DEFINE BUTTON b-quit AUTO-END-KEY 
    LABEL "&Выход" 
    SIZE 10 BY 1
    BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO 
    LABEL "Вы&брать" 
    SIZE 10 BY 1.

DEFINE BUTTON b-set-current-db 
    LABEL "Тек" 
    SIZE 5 BY 1 TOOLTIP "Выбрать текущую базу данных".

DEFINE BUTTON b-toggle 
    LABEL "&Права" 
    SIZE 10 BY 1 TOOLTIP "Изменить список прав, привязанных к группе".

DEFINE BUTTON b-users 
    LABEL "&Польз" 
    SIZE 9 BY 1 TOOLTIP "Список пользователей с выбранной группой прав".

DEFINE VARIABLE cb-db          AS CHARACTER FORMAT "X(256)":U 
    LABEL "БД" 
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEMS "Item 1" 
    DROP-DOWN-LIST
    SIZE 12.63 BY 1 NO-UNDO.

DEFINE VARIABLE item-EDITOR    AS CHARACTER 
    VIEW-AS EDITOR SCROLLBAR-VERTICAL
    SIZE 58 BY 1.58 TOOLTIP "описание права"
    FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE role-editor    AS CHARACTER 
    VIEW-AS EDITOR SCROLLBAR-VERTICAL
    SIZE 39.63 BY 1.58 TOOLTIP "Описание группы"
    FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE v-filter-item  AS CHARACTER FORMAT "X(256)":U 
    VIEW-AS FILL-IN 
    SIZE 20.75 BY 1 NO-UNDO.

DEFINE VARIABLE v-filter-role  AS CHARACTER FORMAT "X(40)":U 
    VIEW-AS FILL-IN 
    SIZE 25 BY 1
    FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE rs-scope       AS INTEGER 
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS 
    "Все", 1,
    "Без привязки", 2,
    "Фирма", 3,
    "Объект", 4
    SIZE 40.63 BY .75
    FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE tb-filter-item AS LOGICAL   INITIAL no 
    LABEL "" 
    VIEW-AS TOGGLE-BOX
    SIZE 2.63 BY .79 TOOLTIP "Снятие поиска с фильтром" NO-UNDO.

DEFINE VARIABLE tb-filter-role AS LOGICAL   INITIAL no 
    LABEL "" 
    VIEW-AS TOGGLE-BOX
    SIZE 2.63 BY .79 TOOLTIP "Временно отключить фильтрацию" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY browse-action-item FOR 
    action-item, 
    temp_filter-fields-item, 
    action-group, 
    action-role-item SCROLLING.

DEFINE QUERY browse-action-role FOR 
    action-role, 
    temp_filter-fields SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE browse-action-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browse-action-item Dialog-Frame _FREEFORM
    QUERY browse-action-item DISPLAY
    action-group.action-group-name format "X(14)" column-label "Тема"
    action-item.action-item-name format "X(58)"
    action-item.action-item-id column-label "Идентификатор"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58 BY 16.75.

DEFINE BROWSE browse-action-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS browse-action-role Dialog-Frame _FREEFORM
    QUERY browse-action-role DISPLAY
    mark-string(recid(action-role), p-rid-list) @ v-action-role-select
    get-action-role-context(BUFFER action-role) @ v-action-role-context COLUMN-LABEL "Привязка" format "x(12)"
    action-role.db-num column-label "БД"
    action-role.action-role-name COLUMN-LABEL "Название группы прав"
    action-role.action-role-description
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 39.63 BY 16.75 ROW-HEIGHT-CHARS .53.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-quit AT ROW 1 COL 1
    b-sel AT ROW 1 COL 11 WIDGET-ID 16
    cb-db AT ROW 1 COL 68.63 COLON-ALIGNED WIDGET-ID 2
    b-set-current-db AT ROW 1 COL 83 WIDGET-ID 4
    b-help AT ROW 1 COL 89.63
    rs-scope AT ROW 1.25 COL 23.63 NO-LABEL WIDGET-ID 42
    b-print AT ROW 1.96 COL 90 WIDGET-ID 70
    b-mark AT ROW 2 COL 1 WIDGET-ID 14
    b-add AT ROW 2 COL 4 WIDGET-ID 6
    b-chg AT ROW 2 COL 13 WIDGET-ID 10
    b-del AT ROW 2 COL 22 WIDGET-ID 8
    b-toggle AT ROW 2 COL 31 WIDGET-ID 12
    b-users AT ROW 2 COL 41 WIDGET-ID 48
    b-hist AT ROW 2 COL 87 WIDGET-ID 74
    b-filter-role AT ROW 3 COL 1 WIDGET-ID 24
    v-filter-role AT ROW 3 COL 10 COLON-ALIGNED NO-LABEL WIDGET-ID 28 NO-TAB-STOP 
    tb-filter-role AT ROW 3 COL 38 WIDGET-ID 52
    b-filter-item AT ROW 3 COL 63.63 WIDGET-ID 64 NO-TAB-STOP 
    v-filter-item AT ROW 3 COL 71.75 COLON-ALIGNED NO-LABEL WIDGET-ID 66
    tb-filter-item AT ROW 3 COL 95.63 WIDGET-ID 68
    browse-action-role AT ROW 4.25 COL 1 WIDGET-ID 200
    browse-action-item AT ROW 4.25 COL 41.63 WIDGET-ID 300
    role-editor AT ROW 21.25 COL 1 NO-LABEL WIDGET-ID 20
    item-EDITOR AT ROW 21.25 COL 41.63 NO-LABEL WIDGET-ID 22
    SPACE(0.00) SKIP(0.27)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Группы прав"
    DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit WIDGET-ID 100.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB browse-action-role tb-filter-item Dialog-Frame */
/* BROWSE-TAB browse-action-item browse-action-role Dialog-Frame */
ASSIGN 
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR BUTTON b-set-current-db IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
    b-set-current-db:HIDDEN IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR COMBO-BOX cb-db IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
    cb-db:HIDDEN IN FRAME Dialog-Frame = TRUE.

ASSIGN 
    item-EDITOR:READ-ONLY IN FRAME Dialog-Frame = TRUE.

ASSIGN 
    role-editor:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* SETTINGS FOR TOGGLE-BOX tb-filter-item IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX tb-filter-role IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
    v-filter-item:READ-ONLY IN FRAME Dialog-Frame = TRUE.

ASSIGN 
    v-filter-role:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browse-action-item
/* Query rebuild information for BROWSE browse-action-item
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH action-item, FIRST temp_filter-fields-item, FIRST action-group, first action-role-item. */
RUN refresh-query-action-item .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browse-action-item */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE browse-action-role
/* Query rebuild information for BROWSE browse-action-role
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH action-role, FIRST temp_filter-fields. */
RUN refresh-query-action-role IN THIS-PROCEDURE .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE browse-action-role */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Группы прав */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
    DO:
        DEFINE VARIABLE v-recid AS RECID NO-UNDO.
        /* Права !!! */
        run str/actnrold.w ( INPUT parparentproc
            , INPUT FALSE
            , INPUT-OUTPUT v-recid
            ) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN 
        DO:
            MESSAGE RETURN-VALUE SKIP
                ERROR-STATUS:GET-MESSAGE(1)
                VIEW-AS ALERT-BOX.
            UNDO, RETURN NO-APPLY.
        END.
        run assign-filter-mark-role in this-procedure ( input v-filter-role ) .
        RUN enable_UI.
        RUN post_enable_UI.

        run set-brw-pos in this-procedure ( input v-recid ).
        run refresh-query-action-item in this-procedure .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
    DO:
        DEFINE VARIABLE v-recid AS RECID   NO-UNDO.
        define variable v-ok    as logical no-undo.
        IF AVAILABLE action-role THEN 
        DO:
            ASSIGN
                v-recid = RECID(action-role)
                .
            /* Права !!! */
            run str/actnrold.w ( INPUT parparentproc
                , INPUT TRUE
                , INPUT-OUTPUT v-recid
                ) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN 
            DO:
                MESSAGE RETURN-VALUE SKIP
                    ERROR-STATUS:GET-MESSAGE(1)
                    VIEW-AS ALERT-BOX.
                UNDO, RETURN NO-APPLY.
            END.
            v-ok = browse-action-role:refresh( )  in frame {&frame-name}.
        END.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
    DO:
        IF AVAILABLE action-role THEN 
        DO:
            RUN delete-action-role IN THIS-PROCEDURE.
            run enable_UI IN THIS-PROCEDURE .
            RUN post_enable_UI IN THIS-PROCEDURE.
        END.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-filter-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-filter-item Dialog-Frame
ON CHOOSE OF b-filter-item IN FRAME Dialog-Frame /* ФПоиск */
    DO:
        define variable v-new-filter as character no-undo.
        define variable v-accepted   as logical   no-undo.
        run gbl/twowinf.w (
            input v-filter-item
            , output v-new-filter
            , output v-accepted
            ).
        if v-accepted = yes
            then 
        do:
            assign
                v-filter-item = v-new-filter
                .
            if v-filter-item = "":U
                then 
            do:
                assign
                    tb-filter-item            = no
                    tb-filter-item :sensitive = no
                    .
            end.
            else 
            do:
                assign
                    tb-filter-item            = yes
                    tb-filter-item :sensitive = yes
                    .
            end.
            display
                v-filter-item
                tb-filter-item
                with frame {&frame-name}.
            run assign-filter-mark-item IN THIS-PROCEDURE
                ( input v-filter-item
                ) .
            {&OPEN-QUERY-browse-action-item}
            apply "entry":U to browse-action-role.
            apply "VALUE-CHANGED":U to browse-action-role.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-filter-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-filter-role Dialog-Frame
ON CHOOSE OF b-filter-role IN FRAME Dialog-Frame /* ФПоиск */
    DO:
        define variable v-new-filter as character no-undo.
        define variable v-accepted   as logical   no-undo.
        run gbl/twowinf.w (
            input v-filter-role
            , output v-new-filter
            , output v-accepted
            ).
        if v-accepted = yes
            then 
        do:
            assign
                v-filter-role = v-new-filter
                .
            if v-filter-role = "":U
                then 
            do:
                assign
                    tb-filter-role            = no
                    tb-filter-role :sensitive = no
                    .
            end.
            else 
            do:
                assign
                    tb-filter-role            = yes
                    tb-filter-role :sensitive = yes
                    .
            end.
        end.
        { gbl/working.i }
        run assign-filter-mark-role IN THIS-PROCEDURE
            ( input v-filter-role
            ) .
        run enable_UI IN THIS-PROCEDURE .
        RUN post_enable_UI IN THIS-PROCEDURE.
        apply "VALUE-CHANGED":U to browse-action-role.
        { gbl/stopwork.i }
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* Печать */
    DO:
        define variable rid-list as character no-undo.
        run ref/cactnrole.w (
            INPUT parparentproc
            , INPUT "":U /*bttns*/
            , INPUT "one":U /*parref-mode*/
            , OUTPUT  rid-list
            , INPUT ub.action-role.db-num
            , INPUT ub.action-role.action-head-code
            , INPUT ub.action-role.action-role-code
            , input "":U /*p-subject*/
            ).
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
    DO:
        DEFINE VARIABLE v-log AS LOGICAL NO-UNDO .

        IF NOT AVAILABLE action-role THEN RETURN NO-APPLY.
        { gbl/markstrn.i action-role p-rid-list }
        v-log = browse-action-role:refresh() IN FRAME Dialog-Frame.
        IF last-event:function <> "MOUSE-SELECT-DBLCLICK" THEN 
        DO:
            g#log = browse-action-role:select-next-row ().
            APPLY "ITERATION-CHANGED" TO browse-action-role IN FRAME Dialog-Frame.
        END.
        /* !!!
        IF NUM-ENTRIES (p-rid-list) = 0 THEN DO:
           HIDE mark-num IN FRAME Dialog-Frame.
        END.
        ELSE DO:
           DISPLAY NUM-ENTRIES (p-rid-list) @ mark-num WITH FRAME Dialog-Frame.
        END.
        */
        APPLY "ENTRY" TO browse-action-role IN FRAME Dialog-Frame.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
    DO:
    

        def var v-prn-ff as char no-undo.
        v-prn-ff = session:temp-directory + {&DF_Name} +  "actnrole.html".

        run waitfram-show in this-procedure ( input "Ждите...").
        output stream OutStr-html to value(v-prn-ff) convert target 'UTF-8'/*no-convert*/.
     
        put stream outstr-html unformatted 
            substitute(
              
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px;  
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 5px;
                   ~}
          
              </style>
               </head>
                    <body>
                  <table orientation="landscape" name="Группы прав" fit_to_page="true" > 
                    <thead> 
                   <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                <tr class="set_columns">                       
                <td style="width:250px"></td>
                        
                       <td style="width:250px"></td>
                        <td style="width:250px"></td>
                            
        
                 </tr>
        <tr>
            <td colspan="2" style="front-weight: bold; text-align: center;">Список групп прав</td>
        </tr>
        </thead>

        <tbody>
        <tr>
        <th>Привязка</th>
        <th>Наименование</th>
       
        </tr>'  ). 
        
        get first browse-action-role.     
        do while available action-role:    
            
            for each  action-role-item no-lock
                where action-role-item.db-num           = action-role.db-num
                and action-role-item.action-head-code = action-role.action-head-code
                and action-role-item.action-role-code = action-role.action-role-code:
          
 
                put stream OutStr-html unformatted
                    substitute(
    
                    '<tr style="height: 50px;">
                  <td text_wrap="true"> &1 </td>
                   <td text_wrap="true"> &2 </td> 
                   </tr> ', 
     
                    get-action-role-context(BUFFER action-role),
                    action-role.action-role-name
                    ).  
            end.

            get next browse-action-role. 
        end. 
        put stream OutStr-html unformatted
            substitute('
            </table>'
            ,chr(123), chr(125)).

    
        put stream OutStr-html unformatted
            substitute(
                                            
            '  <table orientation="landscape" name="Списки прав" fit_to_page="true"> 
                    <thead> 
                   <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                <tr class="set_columns">                       
                <td style="width:250px"></td>
                        
                       <td style="width:250px"></td>
                        <td style="width:250px"></td>
                        <td style="width:250px"></td>  
                        <td style="width:250px"></td>              
       
                 </tr>
        <tr>
            <td colspan="4" style="front-weight: bold; text-align: center;">Список прав</td>
        </tr>
        </thead>

        <tbody>
        <tr>
        <th>Привязка</th>
        <th>Название группы прав</th>
        <th>Тема</th>
        <th>Имя права</th>
        </tr>').
   
        get first browse-action-role.     
        do while available action-role:    
            
            for each  action-role-item no-lock
                where action-role-item.db-num           = action-role.db-num
                and action-role-item.action-head-code = action-role.action-head-code
                and action-role-item.action-role-code = action-role.action-role-code
                ,
                FIRST action-item  where action-role-item.action-item-code = action-item.action-item-code
                NO-LOCK
                ,
                FIRST temp_filter-fields-item
                WHERE temp_filter-fields-item.action-item-code = action-item.action-item-code
                and (    temp_filter-fields-item.record-on = YES
                or tb-filter-item = no
                )
                NO-LOCK 
                ,
                FIRST action-group  where action-group.action-head-code  = action-item.action-head-code
                and action-group.action-group-id = action-item.action-group-id no-lock  
                /*       by action-item.action-head-code     */
                /*        by  action-group.action-group-name */
                /*        by  action-item.action-item-context*/
                /*        by  action-item.action-group-id    */
                /*         by action-item.action-item-name  */:
                put stream OutStr-html unformatted
                    substitute(
          
          
                    '<tr style="height: 50px;">
                  <td text_wrap="true"> &1 </td>
                   <td text_wrap="true"> &2 </td>
                   <td text_wrap="true"> &3 </td>
                   <td text_wrap="true"> &4 </td>
                   </tr>
                    
                    ',
     
                    get-action-role-context(BUFFER action-role),
                    action-role.action-role-name,
                    action-group.action-group-name,
                    action-item.action-item-name
                    ).

            end.
    
            get next browse-action-role.
        end.
        run waitfram-hide in this-procedure. 
                  put stream outstr-html unformatted
                    substitute(
       
                    '</tbody>
      </body>
      </html>',chr(123), chr(125)
      
                    ). 
    
        output stream OutStr-html close.  

        run prn-lib-reportviewer-report-name in this-procedure (
            input parParentProc
            ,input v-prn-ff
            ).
     
    end.
  /* new trigger */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
    DO:
        assign
            p-rid-list         = ""
            p-action-role-code = ?
            .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбрать */
    DO:
        define variable v-ind         as integer no-undo .
        define variable v-num-entries as integer no-undo .
        if not avail action-role then return no-apply.
        if p-rid-list = "" then 
        do:
            p-rid-list = string (recid (action-role)).
        end.
        ASSIGN
            p-action-role-code = action-role.action-role-code
            .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-set-current-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-set-current-db Dialog-Frame
ON CHOOSE OF b-set-current-db IN FRAME Dialog-Frame /* Тек */
    DO:

        assign
            v-current-db-num    = v-cntxt-db-num
            cb-db :screen-value = v-current-db-num-screen-value
            .
        run can-edit-action-role
            (input  v-current-db-num
            ,output v-can-edit-action-role
            ) .

        run enable_UI IN THIS-PROCEDURE .
        RUN post_enable_UI IN THIS-PROCEDURE.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-toggle
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-toggle Dialog-Frame
ON CHOOSE OF b-toggle IN FRAME Dialog-Frame /* Права */
    DO:
        IF AVAILABLE action-role THEN 
        DO:
            run change-items in this-procedure
                ( input action-role.action-head-code
                , input action-role.db-num
                , input action-role.action-role-code
                , input action-role.action-role-context
                ) no-error.
            if error-status :error
                then 
            do:
                message
                    vss-workfile vss-revision vss-description
                    skip(1)
                    skip 
                    "Ошибка изменения списка прав"
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
                    view-as alert-box error.
                undo, return no-apply.
            end.
            run refresh-query-action-item in this-procedure .
            APPLY "ENTRY" TO browse-action-item IN FRAME Dialog-Frame.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-users
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-users Dialog-Frame
ON CHOOSE OF b-users IN FRAME Dialog-Frame /* Польз */
    DO:
        if available action-role
            then 
        do:
            run show-users-for-role in this-procedure (
                input action-role.db-num
                , input action-role.action-head-code
                , input action-role.action-role-code
                , input action-role.action-role-name
                ).
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browse-action-item
&Scoped-define SELF-NAME browse-action-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browse-action-item Dialog-Frame
ON VALUE-CHANGED OF browse-action-item IN FRAME Dialog-Frame
    DO:
        if available action-item then 
        do:
            assign
                item-editor = action-item.action-item-description
                .
        end.
        else 
        do:
            assign
                item-editor = "":U
                .
        end.

        display
            item-editor
            with frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browse-action-role
&Scoped-define SELF-NAME browse-action-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browse-action-role Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF browse-action-role IN FRAME Dialog-Frame
    DO:
        if (lookup  ( "b-add" , p-bttns) > 0 ) then 
        do:
            apply "CHOOSE" to b-chg.
        end.
        else 
        do:
            apply "CHOOSE" to b-mark.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL browse-action-role Dialog-Frame
ON VALUE-CHANGED OF browse-action-role IN FRAME Dialog-Frame
    DO:
        run refresh-query-action-item in this-procedure .
        if available action-role then 
        do:
            assign
                role-editor = action-role.action-role-description
                .
            if available action-item then 
            do:
                assign
                    item-editor = action-item.action-item-description
                    .
            end.
            else 
            do:
                assign
                    item-editor = "":U
                    .
            end.

            display
                item-editor
                with frame {&frame-name}.
        end.
        else 
        do:
            assign
                role-editor = "":U
                .
        end.
        display
            role-editor
            with frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-db Dialog-Frame
ON VALUE-CHANGED OF cb-db IN FRAME Dialog-Frame /* БД */
    DO:
        assign
            cb-db
            .
        assign
            v-current-db-num = integer(entry(1, cb-db, ' ':U))
            .
        run can-edit-action-role
            (input  v-current-db-num
            ,output v-can-edit-action-role
            ) .

        run enable_UI IN THIS-PROCEDURE .
        RUN post_enable_UI IN THIS-PROCEDURE.

        apply 'entry':U to browse browse-action-role .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-scope
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-scope Dialog-Frame
ON VALUE-CHANGED OF rs-scope IN FRAME Dialog-Frame
    DO:
        assign
            rs-scope
            .
        assign
            p-context = entry( rs-scope, substitute( "&1,&2,&3,&4",'All', {&cntxt-global}, {&cntxt-firm}, {&cntxt-object} ) )
            .

        run enable_UI IN THIS-PROCEDURE .
        RUN post_enable_UI IN THIS-PROCEDURE.

        apply 'entry':U to browse browse-action-role .

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-filter-item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-filter-item Dialog-Frame
ON VALUE-CHANGED OF tb-filter-item IN FRAME Dialog-Frame
    DO:
        assign
            tb-filter-item
            .
        {&OPEN-QUERY-browse-action-item}
        apply "entry":U to browse-action-item.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tb-filter-role
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tb-filter-role Dialog-Frame
ON VALUE-CHANGED OF tb-filter-role IN FRAME Dialog-Frame
    DO:
        assign
            tb-filter-role
            .
        RUN enable_UI.
        RUN post_enable_UI IN THIS-PROCEDURE.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME browse-action-item
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/getcntxt.i get }

{ gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_actn-lookup':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      false
      v-ok
    }
IF NOT v-ok then 
do:
    message
        "У вас нет прав для просмотра справочника прав"
        view-as alert-box information.
    return.
end.

{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/brwrefre.i
  "run refresh-query-action-role in this-procedure .
   run refresh-query-action-item in this-procedure ."
   }
{ adm/actn-gbl.i
  v-on-gbl
  no-error
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

if p-db-num = 0 then do:
    assign
        v-current-db-num = v-cntxt-db-num
        .
  end.
  else v-current-db-num = p-db-num .
  if v-on-gbl then v-current-db-num = 0.
  
    run can-edit-action-role
        (input  v-current-db-num
        ,output v-can-edit-action-role
        ) .


    run fill-db-num-list in this-procedure .

    run assign-filter-mark-role IN THIS-PROCEDURE ( input v-filter-role ) .

    run init-filter-item  IN THIS-procedure.

    RUN enable_UI.
    RUN post_enable_UI.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-gds-grp Dialog-Frame 
PROCEDURE add-gds-grp :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-gds-list as character        no-undo.

    define buffer buf_action-role-item-gds-grp for ub.action-role-item-gds-grp .

    define variable v-count as integer no-undo.

    do
        on error undo, return error
        :
        FOR EACH  buf_action-role-item-gds-grp
            where buf_action-role-item-gds-grp.db-num           = action-role-item.db-num
            AND buf_action-role-item-gds-grp.action-head-code = action-role-item.action-head-code
            AND buf_action-role-item-gds-grp.action-role-code = action-role-item.action-role-code
            AND buf_action-role-item-gds-grp.action-item-code = action-role-item.action-item-code
            exclusive-lock
            :
            IF LOOKUP(STRING(buf_action-role-item-gds-grp.gds-grp-code), p-Gds-List, {&delim-par}) = 0
                THEN 
            DO:
                DELETE buf_action-role-item-gds-grp.
            END.
        END.

        DO v-count = 1 TO NUM-ENTRIES(p-Gds-List, {&delim-par})
            on error undo, next
            :
            FIND   FIRST buf_action-role-item-gds-grp
                where buf_action-role-item-gds-grp.db-num               = action-role-item.db-num
                AND buf_action-role-item-gds-grp.action-head-code     = action-role-item.action-head-code
                AND buf_action-role-item-gds-grp.action-role-code = action-role-item.action-role-code
                AND buf_action-role-item-gds-grp.action-item-code         = action-role-item.action-item-code
                AND buf_action-role-item-gds-grp.gds-grp-code             = INTEGER(ENTRY(v-count, p-Gds-List, {&delim-par}))
                no-lock
                no-error
                .
            IF NOT AVAILABLE buf_action-role-item-gds-grp THEN 
            DO:
                CREATE buf_action-role-item-gds-grp.
                ASSIGN
                    buf_action-role-item-gds-grp.db-num                = action-role-item.db-num
                    buf_action-role-item-gds-grp.action-head-code      = action-role-item.action-head-code
                    buf_action-role-item-gds-grp.action-role-code      = action-role-item.action-role-code
                    buf_action-role-item-gds-grp.action-item-code      = action-role-item.action-item-code
                    buf_action-role-item-gds-grp.action-role-item-code = action-role-item.action-role-item-code
                    buf_action-role-item-gds-grp.action-item-id        = action-role-item.action-item-id
                    buf_action-role-item-gds-grp.gds-grp-code          = INTEGER(ENTRY(v-count, p-Gds-List, {&delim-par}))
                    .
            END.
        END.

    end.  /* do on error */
END PROCEDURE. /* add-gds-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-goods Dialog-Frame 
PROCEDURE add-goods :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-gds-list as character        no-undo.

    define buffer buf_action-role-item-gds for ub.action-role-item-gds .

    define variable v-count as integer no-undo.

    do
        on error undo, return error
        :
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.db-num           = action-role-item.db-num
            AND buf_action-role-item-gds.action-head-code = action-role-item.action-head-code
            AND buf_action-role-item-gds.action-role-code = action-role-item.action-role-code
            AND buf_action-role-item-gds.action-item-code = action-role-item.action-item-code
            exclusive-lock
            :
            IF LOOKUP(STRING(buf_action-role-item-gds.gds-code), p-Gds-List, {&delim-par}) = 0
                THEN 
            DO:
                DELETE buf_action-role-item-gds.
            END.
        END.

        DO v-count = 1 TO NUM-ENTRIES(p-Gds-List, {&delim-par})
            on error undo, next
            :
            FIND FIRST buf_action-role-item-gds
                where buf_action-role-item-gds.db-num            = action-role-item.db-num
                AND buf_action-role-item-gds.action-head-code = action-role-item.action-head-code
                AND buf_action-role-item-gds.action-role-code = action-role-item.action-role-code
                AND buf_action-role-item-gds.action-item-code = action-role-item.action-item-code
                AND buf_action-role-item-gds.gds-code         = INTEGER(ENTRY(v-count, p-Gds-List, {&delim-par}))
                no-lock
                no-error
                .
            IF NOT AVAILABLE buf_action-role-item-gds THEN 
            DO:
                CREATE buf_action-role-item-gds.
                ASSIGN
                    buf_action-role-item-gds.db-num                = action-role-item.db-num
                    buf_action-role-item-gds.action-head-code      = action-role-item.action-head-code
                    buf_action-role-item-gds.action-role-code      = action-role-item.action-role-code
                    buf_action-role-item-gds.action-item-code      = action-role-item.action-item-code
                    buf_action-role-item-gds.action-role-item-code = action-role-item.action-role-item-code
                    buf_action-role-item-gds.action-item-id        = action-role-item.action-item-id
                    buf_action-role-item-gds.gds-code              = INTEGER(ENTRY(v-count, p-Gds-List, {&delim-par}))
                    .
            END.
        END.

    end.  /* do on error */
END PROCEDURE. /* add-goods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-filter-mark-item Dialog-Frame 
PROCEDURE assign-filter-mark-item :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-name-filter    as character        no-undo.

    define buffer buf_temp_filter-fields-item for temp_filter-fields-item .
    define buffer buf_action-item             for action-item .

    do
        on error undo, return error
        :

        for each buf_action-item no-lock

            :
            find first buf_temp_filter-fields-item
                where buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                no-error.
            if not available buf_temp_filter-fields-item
                then 
            do:
                create buf_temp_filter-fields-item.
                assign
                    buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                    buf_temp_filter-fields-item.record-on        = no
                    .
            end.
            if ( p-name-filter = "":U )
                or index( buf_action-item.action-item-name, p-name-filter ) <> 0
                or index( buf_action-item.action-item-description, p-name-filter ) <> 0
                or index( buf_action-item.action-item-id, p-name-filter ) <> 0
                then 
            do:
                assign
                    buf_temp_filter-fields-item.record-on = yes
                    .
            end.
            else 
            do:
                assign
                    buf_temp_filter-fields-item.record-on = no
                    .
            end.
        end.
    end.  /* do on error */
END PROCEDURE. /* assign-filter-mark-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE assign-filter-mark-role Dialog-Frame 
PROCEDURE assign-filter-mark-role :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-name-filter    as character        no-undo.

    define buffer buf_action-role        for action-role .
    define buffer buf_temp_filter-fields for temp_filter-fields .

    do
        on error undo, return error
        :
        for each buf_action-role no-lock
            where buf_action-role.db-num              = v-current-db-num
            and   buf_action-role.action-head-code    = {&action-head-code-main}

            :
            find first buf_temp_filter-fields
                where buf_temp_filter-fields.action-role-code = buf_action-role.action-role-code
                no-error.
            if not available buf_temp_filter-fields
                then 
            do:
                create buf_temp_filter-fields.
                assign
                    buf_temp_filter-fields.action-role-code = buf_action-role.action-role-code
                    buf_temp_filter-fields.record-on        = no
                    .

            end.
            if ( p-name-filter = "":U )
                OR index(buf_action-role.action-role-name , p-name-filter ) <> 0
                or index(buf_action-role.action-role-description , p-name-filter ) <> 0
                then 
            do:
                assign
                    buf_temp_filter-fields.record-on = yes
                    .
            end.
            else 
            do:
                assign
                    buf_temp_filter-fields.record-on = no
                    .
            end.
        end.
    end.
END PROCEDURE. /* assign-filter-mark-role */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE can-edit-action-role Dialog-Frame 
PROCEDURE can-edit-action-role :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    define input  parameter p-db-num   as integer   no-undo .
    define output parameter p-can-edit as logical   no-undo .

    define buffer buf_db for ub.db .

    do
        on error undo, return error return-value
        :
        find first buf_db no-lock
            where buf_db.db-num = v-current-db-num
            no-error .
        if not available buf_db
            then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Неизвестный номер БД" v-current-db-num skip
                view-as alert-box error .
            undo, return error return-value .
        end.

        assign
            p-can-edit = (v-current-db-num = v-cntxt-db-num
                    or
                    buf_db.db-key = '':U
                   )
            .

    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-items Dialog-Frame 
PROCEDURE change-items :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-action-head-code    as integer          no-undo.
    define input parameter p-db-num              as integer          no-undo.
    define input parameter p-action-role-code    as integer          no-undo.
    define input parameter p-action-role-context as character        no-undo.

    DEFINE VARIABLE v-accepted              AS LOGICAL NO-UNDO.
    define variable v-changed               as logical no-undo.
    define variable v-action-item-code      as integer no-undo.
    define variable v-action-role-item-code as integer no-undo .
    define variable v-count                 as integer no-undo .

    define buffer buf_action-item              for ub.action-item .
    define buffer buf_action-role-item         for ub.action-role-item .
    define buffer buf_action-group             for ub.action-group .
    define buffer buf_action-role-item-gds     for ub.action-role-item-gds .
    define buffer buf_action-role-item-gds-grp for ub.action-role-item-gds-grp .

    do for buf_action-item
        , buf_action-role-item
        on error undo, return error
        :

        run actntw_clear in this-procedure.

        each-item_:
        for each  buf_action-item
            where buf_action-item.action-head-code      = p-action-head-code
            and buf_action-item.action-item-context   = p-action-role-context
            no-lock
            on error undo, return error
            :

            find first buf_action-group no-lock
                where buf_action-group.action-head-code  = buf_action-item.action-head-code
                and buf_action-group.action-group-code = buf_action-item.action-group-code
                OR  buf_action-group.action-head-code  = buf_action-item.action-head-code
                and buf_action-group.action-group-id   = buf_action-item.action-group-id
                no-error
                .
            IF NOT AVAILABLE buf_action-group THEN 
            DO:
                next each-item_.
            END.

            find first buf_action-role-item no-lock
                where buf_action-role-item.db-num           = p-db-num
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = p-action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code
                no-error
                .
            define variable v-list as character no-undo.
            IF available buf_action-role-item
                THEN 
            DO:
                IF ( buf_action-item.action-group-id = "gds":U ) /* !!! str-glbl */
                    THEN 
                DO:
                    assign
                        v-list = "":U
                        .
                    FOR EACH  buf_action-role-item-gds
                        where buf_action-role-item-gds.db-num            = p-db-num
                        AND buf_action-role-item-gds.action-head-code = p-action-head-code
                        AND buf_action-role-item-gds.action-role-code = p-action-role-code
                        AND buf_action-role-item-gds.action-item-code = buf_action-item.action-item-code
                        no-lock
                        :
                        assign
                            v-list = IF v-list = "":U THEN STRING(buf_action-role-item-gds.gds-code)
                                          ELSE v-list + {&delim-par} + STRING(buf_action-role-item-gds.gds-code)
                            .

                    END.
                END.
                IF ( buf_action-item.action-group-id = "gds-grp":U ) /* !!! str-glbl */
                    THEN 
                DO:
                    assign
                        v-list = "":U
                        .
                    FOR EACH  buf_action-role-item-gds-grp
                        where buf_action-role-item-gds-grp.db-num           = p-db-num
                        AND buf_action-role-item-gds-grp.action-head-code = p-action-head-code
                        AND buf_action-role-item-gds-grp.action-role-code = p-action-role-code
                        AND buf_action-role-item-gds-grp.action-item-code = buf_action-item.action-item-code
                        no-lock
                        :
                        assign
                            v-list = IF v-list = "":U THEN STRING(buf_action-role-item-gds-grp.gds-grp-code)
                                          ELSE v-list + {&delim-par} + STRING(buf_action-role-item-gds-grp.gds-grp-code)
                            .

                    END.
                END.
            END.

            run actntw_add-item in this-procedure
                ( input buf_action-item.action-item-code /*SUBSTITUTE("&2{&tabulation}&1", string( buf_action-item.action-item-code  ), buf_action-group.action-group-name)*/
                , input buf_action-group.action-group-name
                , input buf_action-item.action-item-name
                , input SUBSTITUTE('Тема "&2" &1', string( buf_action-item.action-item-description  ), buf_action-group.action-group-name)
                , input ( available buf_action-role-item )
                , INPUT ( buf_action-item.action-group-id = "gds":U ) /* !!! str-glbl */
                , INPUT ( buf_action-item.action-group-id = "gds-grp":U ) OR ( buf_action-item.action-group-id = "gds":U ) /* !!! str-glbl */
                , INPUT v-list
                ) .

        end. /* each  buf_action-item */

        run str/actntw.w
            ( input parparentproc
            , input 1
            , input "Добавление прав в группу"
            , input "":U
            , input "&Тест"
            , input  table temp_actntw_items
            , input  p-action-head-code
            , input  p-action-role-code
            , output table temp_actntw_itemsSelected
            , output v-changed
            , output v-accepted
            ) .
        IF NOT v-accepted
            THEN 
        DO:
            RETURN.
        END.

   { gbl/working.i }
        IF v-changed then 
        do:
            /* проверяем удаление прав */
            for each  buf_action-item
              where buf_action-item.action-head-code      = p-action-head-code
              and buf_action-item.action-item-context   = p-action-role-context
              no-lock
              on error undo, return error
              :
              for each  buf_action-role-item
                  where buf_action-role-item.db-num            = p-db-num
                  and buf_action-role-item.action-head-code = p-action-head-code
                  and buf_action-role-item.action-role-code = p-action-role-code
                  and buf_action-role-item.action-item-code = buf_action-item.action-item-code
                  exclusive-lock
                  on error undo, return error
                  :
                  find first temp_actntw_itemsSelected
                      where temp_actntw_itemsSelected.itmExtKey = string( buf_action-role-item.action-item-code  )
                      no-error.
                  if not available temp_actntw_itemsSelected
                      then 
                  do:
                      delete buf_action-role-item.
                  end.
              end.
            end.

            /* проверяем установку прав */
            for each temp_actntw_itemsSelected
                :
                assign
                    v-action-item-code = integer( temp_actntw_itemsSelected.itmExtKey )
         no-error.
                if error-status :error
                    then 
                do:
                    message
                        vss-workfile vss-revision vss-description
                        skip(1)
                        skip 
                        "Ошибка передачи первичного ключа из двухоконного интерфейса."
                        skip return-value
                        skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                        view-as alert-box error.
                    undo, return error.
                end.
                find first buf_action-role-item
                    where buf_action-role-item.db-num           = p-db-num
                    and buf_action-role-item.action-head-code = p-action-head-code
                    and buf_action-role-item.action-role-code = p-action-role-code
                    and buf_action-role-item.action-item-code = v-action-item-code
                    exclusive-lock
                    no-error
                    .
                if not available buf_action-role-item
                    then 
                do:
                    find first buf_action-item share-lock
                        where buf_action-item.action-head-code = p-action-head-code
                        and buf_action-item.action-item-code = v-action-item-code
                        no-error.
                    if error-status :error
                        then 
                    do:
                        message
                            vss-workfile vss-revision vss-description
                            skip(1)
                            skip 
                            "Ошибка поиска прав в системе."
                            skip return-value
                            skip trim( error-status :get-message( 1 ) )
                            trim( error-status :get-message( 2 ) )
                            trim( error-status :get-message( 3 ) )
                            view-as alert-box error.
                        undo, return error.
                    end.
                    assign
                        v-action-role-item-code = NEXT-VALUE(s-action-role-item)
                        .
                    create buf_action-role-item.
                    assign
                        buf_action-role-item.db-num                = p-db-num
                        buf_action-role-item.action-head-code      = p-action-head-code
                        buf_action-role-item.action-role-code      = p-action-role-code
                        buf_action-role-item.action-item-code      = v-action-item-code
                        buf_action-role-item.action-item-id        = buf_action-item.action-item-id
                        buf_action-role-item.action-role-item-code = v-action-role-item-code
                        .
                end. /* not available buf_action-role-item */
                /* привязка товаров к правам */
                IF temp_actntw_itemsSelected.itmGds
                    THEN 
                DO:
                    FOR EACH  buf_action-role-item-gds
                        where buf_action-role-item-gds.db-num           = buf_action-role-item.db-num
                        AND buf_action-role-item-gds.action-head-code = buf_action-role-item.action-head-code
                        AND buf_action-role-item-gds.action-role-code = buf_action-role-item.action-role-code
                        AND buf_action-role-item-gds.action-item-code = buf_action-role-item.action-item-code
                        exclusive-lock
                        :
                        IF LOOKUP(STRING(buf_action-role-item-gds.gds-code), temp_actntw_itemsSelected.itmGdsList, {&delim-par}) = 0
                            THEN 
                        DO:
                            DELETE buf_action-role-item-gds.
                        END.
                    END.

                    DO v-count = 1 TO NUM-ENTRIES(temp_actntw_itemsSelected.itmGdsList, {&delim-par})
                        on error undo, next
                        :
                        FIND FIRST buf_action-role-item-gds
                            where buf_action-role-item-gds.db-num           = buf_action-role-item.db-num
                            AND buf_action-role-item-gds.action-head-code = buf_action-role-item.action-head-code
                            AND buf_action-role-item-gds.action-role-code = buf_action-role-item.action-role-code
                            AND buf_action-role-item-gds.action-item-code = buf_action-role-item.action-item-code
                            AND buf_action-role-item-gds.gds-code         = INTEGER(ENTRY(v-count, temp_actntw_itemsSelected.itmGdsList, {&delim-par}))
                            no-lock
                            no-error
                            .
                        IF NOT AVAILABLE buf_action-role-item-gds THEN 
                        DO:
                            CREATE buf_action-role-item-gds.
                            ASSIGN
                                buf_action-role-item-gds.db-num                = buf_action-role-item.db-num
                                buf_action-role-item-gds.action-head-code      = buf_action-role-item.action-head-code
                                buf_action-role-item-gds.action-role-code      = buf_action-role-item.action-role-code
                                buf_action-role-item-gds.action-item-code      = buf_action-role-item.action-item-code
                                buf_action-role-item-gds.action-role-item-code = buf_action-role-item.action-role-item-code
                                buf_action-role-item-gds.action-item-id        = buf_action-role-item.action-item-id
                                buf_action-role-item-gds.gds-code              = INTEGER(ENTRY(v-count, temp_actntw_itemsSelected.itmGdsList, {&delim-par}))
                                .
                        END.
                    END.
                END.
                /* привязка групп товаров к правам */
                IF temp_actntw_itemsSelected.itmGrp
                    THEN 
                DO:
                    FOR EACH  buf_action-role-item-gds-grp
                        where buf_action-role-item-gds-grp.db-num           = buf_action-role-item.db-num
                        AND buf_action-role-item-gds-grp.action-head-code = buf_action-role-item.action-head-code
                        AND buf_action-role-item-gds-grp.action-role-code = buf_action-role-item.action-role-code
                        AND buf_action-role-item-gds-grp.action-item-code = buf_action-role-item.action-item-code
                        exclusive-lock
                        :
                        IF LOOKUP(STRING(buf_action-role-item-gds-grp.gds-grp-code), temp_actntw_itemsSelected.itmGrpList, {&delim-par}) = 0
                            THEN 
                        DO:
                            DELETE buf_action-role-item-gds-grp.
                        END.
                    END.

                    DO v-count = 1 TO NUM-ENTRIES(temp_actntw_itemsSelected.itmGrpList, {&delim-par})
                        on error undo, next
                        :
                        FIND FIRST buf_action-role-item-gds-grp
                            where buf_action-role-item-gds-grp.db-num           = buf_action-role-item.db-num
                            AND buf_action-role-item-gds-grp.action-head-code = buf_action-role-item.action-head-code
                            AND buf_action-role-item-gds-grp.action-role-code = buf_action-role-item.action-role-code
                            AND buf_action-role-item-gds-grp.action-item-code = buf_action-role-item.action-item-code
                            AND buf_action-role-item-gds-grp.gds-grp-code         = INTEGER(ENTRY(v-count, temp_actntw_itemsSelected.itmGrpList, {&delim-par}))
                            no-lock
                            no-error
                            .
                        IF NOT AVAILABLE buf_action-role-item-gds-grp THEN 
                        DO:
                            CREATE buf_action-role-item-gds-grp.
                            ASSIGN
                                buf_action-role-item-gds-grp.db-num                = buf_action-role-item.db-num
                                buf_action-role-item-gds-grp.action-head-code      = buf_action-role-item.action-head-code
                                buf_action-role-item-gds-grp.action-role-code      = buf_action-role-item.action-role-code
                                buf_action-role-item-gds-grp.action-item-code      = buf_action-role-item.action-item-code
                                buf_action-role-item-gds-grp.action-role-item-code = buf_action-role-item.action-role-item-code
                                buf_action-role-item-gds-grp.action-item-id        = buf_action-role-item.action-item-id
                                buf_action-role-item-gds-grp.gds-grp-code          = INTEGER(ENTRY(v-count, temp_actntw_itemsSelected.itmGrpList, {&delim-par}))
                                .
                        END.
                    END.
                END.
            end. /* each temp_actntw_itemsSelected */
        end. /* v-changed */
   { gbl/stopwork.i }

    end. /* do on error */
END PROCEDURE. /* change-items */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-action-role Dialog-Frame 
PROCEDURE delete-action-role :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    define buffer buf_user-login-action-role for user-login-action-role.
    define buffer buf_action-role-item       for action-role-item.
    define buffer buf_action-role            for action-role.

    do
        on error undo, return error return-value
        :

        MESSAGE SUBSTITUTE('Удалить группу прав "&1"?', action-role.action-role-name )
            VIEW-AS ALERT-BOX QUESTION
            BUTTONS YES-NO
            UPDATE v-yes AS LOGICAL.
        IF NOT v-yes THEN RETURN ERROR.

        IF NOT CAN-FIND (FIRST buf_action-role-item
            WHERE buf_action-role-item.db-num           = action-role.db-num
            AND buf_action-role-item.action-head-code = action-role.action-head-code
            AND buf_action-role-item.action-role-code = action-role.action-role-code
            no-lock) THEN 
        DO:
            FOR EACH buf_user-login-action-role WHERE buf_user-login-action-role.db-num           = action-role.db-num
                AND buf_user-login-action-role.action-head-code = action-role.action-head-code
                AND buf_user-login-action-role.action-role-code = action-role.action-role-code
                EXCLUSIVE-LOCK
                :
                DELETE buf_user-login-action-role.
            END.
        END.
        else 
        do:
            IF CAN-FIND( FIRST buf_user-login-action-role WHERE buf_user-login-action-role.db-num           = action-role.db-num
                AND buf_user-login-action-role.action-head-code = action-role.action-head-code
                AND buf_user-login-action-role.action-role-code = action-role.action-role-code
                NO-LoCK) THEN 
            DO:
                message
                    "В группе прав присутствуют права и группа выдана пользователям."
                    skip 
                    "Удалить группу нельзя"
                    view-as alert-box information.
                RETURN.
            END.
        end.
        FOR EACH buf_action-role-item WHERE buf_action-role-item.db-num           = action-role.db-num
            AND buf_action-role-item.action-head-code = action-role.action-head-code
            AND buf_action-role-item.action-role-code = action-role.action-role-code
            EXCLUSIVE-LOCK
            :
            DELETE buf_action-role-item.
        END.
        find first buf_action-role
            where recid(buf_action-role) = recid(action-role)
            exclusive-lock
            .
        delete buf_action-role.


    end.

END PROCEDURE. /* delete-action-role */

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
    DISPLAY rs-scope v-filter-role tb-filter-role v-filter-item tb-filter-item 
        role-editor item-EDITOR 
        WITH FRAME Dialog-Frame.
    ENABLE b-quit b-sel b-help rs-scope b-print b-mark b-add b-chg b-del b-toggle 
        b-users b-hist b-filter-role v-filter-role b-filter-item v-filter-item 
        browse-action-role browse-action-item role-editor item-EDITOR 
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-db-num-list Dialog-Frame 
PROCEDURE fill-db-num-list :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    define buffer buf_db for ub.db .

    define variable v-db-num-list as character no-undo .

    do
        on error undo, return error return-value
        :
        assign
            v-db-num-list = '':U
            .

        for each buf_db
            where (v-cntxt-db-num = 0
            or buf_db.db-num = v-cntxt-db-num
            )
            on error undo, return error return-value
            :
            assign
                v-db-num-list = v-db-num-list
                      + (if v-db-num-list <> '':U then ',':U else '':U)
                      + string(buf_db.db-num) + ' ':U + replace(string(buf_db.db-name), ',':U, '':U)
                .

            if buf_db.db-num = v-cntxt-db-num
                then 
            do:
                assign
                    v-current-db-num-screen-value = string(buf_db.db-num) + ' ':U + replace(string(buf_db.db-name), ',':U, '':U)
                    .
            end.
        end.

        do with frame {&frame-name}
            :
            assign
                cb-db :list-items   = v-db-num-list
                cb-db :screen-value = v-current-db-num-screen-value
                .
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-action-item Dialog-Frame 
PROCEDURE local-open-query-action-item :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    do
        with frame {&frame-name}
        on error undo, return error return-value
        :
        if available action-role
            then 
        do:

            IF tb-filter-item
                THEN 
            DO:
                assign
                    v-filter-item :bgcolor = RED_COLOR
                    .
            END.
            ELSE 
            DO:
                assign
                    v-filter-item :bgcolor = GREY_COLOR
                    .
            END.


            open query browse-action-item
                for each action-item
                where action-item.action-head-code = {&action-head-code-main}
                and action-item.action-item-context = action-role.action-role-context
                NO-LOCK
                ,
                FIRST temp_filter-fields-item
                WHERE temp_filter-fields-item.action-item-code = action-item.action-item-code
                and (    temp_filter-fields-item.record-on = YES
                or tb-filter-item = no
                )
                NO-LOCK
                ,
                FIRST action-group
                where action-group.action-head-code  = action-item.action-head-code
                /*          and action-group.action-group-code = action-item.action-group-code */
                and action-group.action-group-id = action-item.action-group-id
                NO-LOCK
                ,
                first action-role-item no-lock
                where action-role-item.db-num           = action-role.db-num
                and action-role-item.action-head-code = action-role.action-head-code
                and action-role-item.action-role-code = action-role.action-role-code
                and action-role-item.action-item-code = action-item.action-item-code
                BY action-item.action-head-code
                by action-group.action-group-name
                BY action-item.action-item-context
                BY action-item.action-group-id
                BY action-item.action-item-name
                indexed-reposition .

        end.
        else 
        do:
            /* задаем такое условие - чтобы на экране не было записей */
            open query browse-action-item
                for each action-item
                where action-item.action-head-code = {&action-head-code-main}
                and action-item.action-item-context = '':U
                no-lock ,
                FIRST temp_filter-fields-item
                WHERE temp_filter-fields-item.action-item-code = action-item.action-item-code
                and temp_filter-fields-item.record-on = YES
                NO-LOCK
                ,
                FIRST action-group
                where action-group.action-head-code  = action-item.action-head-code
                and action-group.action-group-code = action-item.action-group-code
                no-lock,
                first action-role-item no-lock
                where action-role-item.db-num           = action-role.db-num
                and action-role-item.action-head-code = action-role.action-head-code
                and action-role-item.action-role-code = action-role.action-role-code
                and action-role-item.action-item-code = action-item.action-item-code
                indexed-reposition .
        end.

    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query-action-role Dialog-Frame 
PROCEDURE local-open-query-action-role :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/

  define variable v-num-db    as integer      no-undo.

    do
        with frame {&frame-name}
        on error undo, return error return-value
        :

        IF tb-filter-role
            THEN 
        DO:
            assign
                v-filter-role :bgcolor = RED_COLOR
                .
        END.
        ELSE 
        DO:
            assign
                v-filter-role :bgcolor = GREY_COLOR
                .
        END.

        v-num-db = if v-on-gbl then 0
                   else v-current-db-num
        .
        case p-context:
            WHEN {&cntxt-global} OR
            WHEN {&cntxt-firm}   OR
            WHEN {&cntxt-object} THEN 
                DO:
                    open query browse-action-role
                        for each  action-role no-lock
                        where action-role.db-num            = v-num-db
                        and action-role.action-head-code    = {&action-head-code-main}
                        and action-role.action-role-context = p-context
                        , first temp_filter-fields
                        where temp_filter-fields.action-role-code  = action-role.action-role-code
                        and (     temp_filter-fields.record-on     = yes
                        or tb-filter-role = no
                        )
                        by action-role.action-role-name
                        indexed-reposition .
                END.
            OTHERWISE 
            DO:
                open query browse-action-role
                    for each action-role no-lock
                    where action-role.db-num                = v-num-db
                    and action-role.action-head-code        = {&action-head-code-main}
                    , first temp_filter-fields
                    where temp_filter-fields.action-role-code = action-role.action-role-code
                    and (     temp_filter-fields.record-on    = yes
                    or tb-filter-role = no
                    )
                    by action-role.action-role-context
                    by action-role.action-role-name
                    indexed-reposition .
            END.
        END.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post_enable_UI Dialog-Frame 
PROCEDURE post_enable_UI :
    /*------------------------------------------------------------------------------
      Purpose:     ENABLE the User Interface
      Parameters:  <none>
      Notes:       Here we display/view/enable the widgets in the
                   user-interface.  In addition, OPEN all queries
                   associated with each FRAME and BROWSE.
                   These statements here are based on the "Other
                   Settings" section of the widget Property Sheets.
    ------------------------------------------------------------------------------*/
    DISABLE
        b-quit
        b-sel
        b-help
        b-mark
        b-add
        b-chg
        b-del
        rs-scope
        b-toggle
        browse-action-role browse-action-item
        WITH FRAME Dialog-Frame.
    ENABLE
        b-quit
        b-sel     
        WHEN  (lookup  ( "b-sel" , p-bttns) > 0 )
        b-help
        b-mark    
        WHEN  (lookup  ( "b-mark" , p-bttns) > 0 )
        b-add     
        WHEN  (lookup  ( "b-add" , p-bttns) > 0 )
        b-chg     
        WHEN  (lookup  ( "b-add" , p-bttns) > 0 )
        b-del     
        WHEN  (lookup  ( "b-add" , p-bttns) > 0 )
        rs-scope  
        WHEN  (lookup  ( "rs-scope" , p-bttns) > 0 )
        b-toggle  
        WHEN  (lookup  ( "b-add" , p-bttns) > 0 )
        browse-action-role browse-action-item
        WITH FRAME Dialog-Frame.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_actn-update':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      FALSE
      v-ok
    }
    if v-ok = FALSE or 
      (v-on-gbl and v-cntxt-db-num <> 0)
        then 
    do:
        disable
            b-add
            b-chg
            b-del
            b-toggle
            WITH FRAME Dialog-Frame.
    end.

    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-get-action-role-context Dialog-Frame 
PROCEDURE procedure-get-action-role-context :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    define input  parameter p-action-context as character no-undo .
    define output parameter p-action-name    as character no-undo .

    do
        on error undo, return error return-value
        :
        case p-action-context
            :
            when {&cntxt-global}
            then 
                do:
                    assign
                        p-action-name = "Без привязки"
                        .
                end.
            when {&cntxt-firm}
            then 
                do:
                    assign
                        p-action-name = "фирма"
                        .
                end.
            when {&cntxt-object}
            then 
                do:
                    assign
                        p-action-name = "объект"
                        .
                end.
            otherwise 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Незвестное значение контекста" skip
                    "p-action-context" p-action-context skip
                    view-as alert-box error .
            end.

        end case .
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE procedure-get-action-role-item-state Dialog-Frame 
PROCEDURE procedure-get-action-role-item-state :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    define input  parameter p-action-item-code       as integer   no-undo .
    define output parameter p-action-role-item-state as character no-undo .

    define buffer buf_action-role-item for ub.action-role-item .

    do
        on error undo, return error return-value
        :
        if available action-role
            then 
        do:
            find first buf_action-role-item no-lock
                where buf_action-role-item.db-num           = action-role.db-num
                and buf_action-role-item.action-head-code = action-role.action-head-code
                and buf_action-role-item.action-role-code = action-role.action-role-code
                and buf_action-role-item.action-item-code = p-action-item-code
                no-error .
            if available buf_action-role-item
                then 
            do:
                assign
                    p-action-role-item-state = '*':U
                    .
            end.
            else 
            do:
                assign
                    p-action-role-item-state = '':U
                    .
            end.
        end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query-action-item Dialog-Frame 
PROCEDURE refresh-query-action-item :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    do
        on error undo, return error return-value
        :
        run local-open-query-action-item in this-procedure .

        if available action-item then 
        do:
            assign
                item-editor = action-item.action-item-description
                .
            display
                item-editor
                with frame {&frame-name}.
        end.
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query-action-role Dialog-Frame 
PROCEDURE refresh-query-action-role :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/

    do
        on error undo, return error return-value
        :
        run local-open-query-action-role in this-procedure .
        if available action-role then 
        do:
            assign
                role-editor = action-role.action-role-description
                .
            display
                role-editor
                with frame {&frame-name}.
        end.
        run refresh-query-action-item in this-procedure .
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-brw-pos Dialog-Frame 
PROCEDURE set-brw-pos :
    /* -----------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    -------------------------------------------------------------*/
    define input parameter p-recid        as integer no-undo.
    do
        on error undo, return error return-value
        :
        if p-recid <> ? then 
        do:
            reposition browse-action-role to recid p-recid.

        end.
    end.
END PROCEDURE. /* set-brw-pos */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-users-for-role Dialog-Frame 
PROCEDURE show-users-for-role :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-db-num             as integer          no-undo.
    define input parameter p-action-head-code   as integer          no-undo.
    define input parameter p-action-role-code   as integer          no-undo.
    define input parameter p-action-role-name   as character        no-undo.

    define variable v-accepted    as logical   no-undo.
    define variable v-cur-ext-key as character no-undo.

    define buffer buf_user-login-action-role for user-login-action-role.
    define buffer buf_temp_actnrole-user     for temp_actnrole-user.
    define buffer buf_user-account           for user-account.
    define buffer buf_user-login             for user-login.
    do
        for buf_user-login-action-role
        , buf_temp_actnrole-user
        , buf_user-account
        , buf_user-login
        on error undo, return error
        :

        run onewin_clear in this-procedure.

        empty temp-table buf_temp_actnrole-user.

        for each buf_user-login-action-role no-lock
            where buf_user-login-action-role.db-num              = p-db-num
            and buf_user-login-action-role.action-head-code    = p-action-head-code
            and buf_user-login-action-role.action-role-code    = p-action-role-code
            use-index ie03
            on error undo, return error
            :
            find first buf_temp_actnrole-user
                where buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                no-error.
            if not available buf_temp_actnrole-user
                then 
            do:
                create buf_temp_actnrole-user.
                assign
                    buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                    .
                find first buf_user-account no-lock
                    where buf_user-account.user-id = buf_user-login-action-role.user-id
                    .
                assign
                    buf_temp_actnrole-user.nik        = buf_user-account.nik
                    buf_temp_actnrole-user.lastName   = buf_user-account.last-name
                    buf_temp_actnrole-user.firstName  = buf_user-account.first-name
                    buf_temp_actnrole-user.secondName = buf_user-account.second-name
                    .
            end.
        end.        /* for each buf_user-login-action-role */
        for each buf_temp_actnrole-user
            on error undo, return error
            :
            run onewin_add-item in this-procedure (
                input buf_temp_actnrole-user.user-id
                , input ( if buf_temp_actnrole-user.nik = "":U then buf_temp_actnrole-user.lastName else buf_temp_actnrole-user.nik )
                , input substitute( "&1 &2 &3", buf_temp_actnrole-user.lastName, buf_temp_actnrole-user.firstName, buf_temp_actnrole-user.secondName )
                , input no
                ).
        end.        /* for each buf_temp_actnrole-user */
        run gbl/onewin.w (
            input parparentproc
            , input 0
            , input substitute( "Список пользователей для группы прав < &1 >", p-action-role-name )
            , input "":U
            , input "&Тест"
            , input table temp_onewin_items
            , output table temp_onewin_itemsSelected
            , output v-cur-ext-key
            , output v-accepted
            ).
    end.
END PROCEDURE. /* show-users-for-role */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-users-for-role-item Dialog-Frame 
PROCEDURE show-users-for-role-item :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter p-db-num             as integer          no-undo.
    define input parameter p-action-head-code   as integer          no-undo.
    define input parameter p-action-item-code   as integer          no-undo.
    define input parameter p-action-item-name   as character        no-undo.

    define variable v-accepted    as logical   no-undo.
    define variable v-cur-ext-key as character no-undo.

    define buffer buf_action-role-item       for action-role-item.
    define buffer buf_user-login-action-role for user-login-action-role.
    define buffer buf_temp_actnrole-user     for temp_actnrole-user.
    define buffer buf_user-account           for user-account.
    define buffer buf_user-login             for user-login.
    do
        for buf_action-role-item
        , buf_user-login-action-role
        , buf_temp_actnrole-user
        , buf_user-account
        , buf_user-login
        on error undo, return error
        :
        run onewin_clear in this-procedure.

        empty temp-table buf_temp_actnrole-user.

        for each buf_action-role-item no-lock
            where buf_action-role-item.db-num           = p-db-num
            and buf_action-role-item.action-head-code = p-action-head-code
            and buf_action-role-item.action-item-code = p-action-item-code
            on error undo, return error
            :
            for each buf_user-login-action-role no-lock
                where buf_user-login-action-role.db-num              = buf_action-role-item.db-num
                and buf_user-login-action-role.action-head-code    = buf_action-role-item.action-head-code
                and buf_user-login-action-role.action-role-code    = buf_action-role-item.action-role-code
                use-index ie03
                on error undo, return error
                :
                find first buf_temp_actnrole-user
                    where buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                    no-error.
                if not available buf_temp_actnrole-user
                    then 
                do:
                    create buf_temp_actnrole-user.
                    assign
                        buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                        .
                    find first buf_user-account no-lock
                        where buf_user-account.user-id = buf_user-login-action-role.user-id
                        .
                    assign
                        buf_temp_actnrole-user.nik        = buf_user-account.nik
                        buf_temp_actnrole-user.lastName   = buf_user-account.last-name
                        buf_temp_actnrole-user.firstName  = buf_user-account.first-name
                        buf_temp_actnrole-user.secondName = buf_user-account.second-name
                        .
                end.
            end.        /* for each buf_user-login-action-role */
        end.        /* for each buf_action-role-item */
        for each buf_temp_actnrole-user
            on error undo, return error
            :
            run onewin_add-item in this-procedure (
                input buf_temp_actnrole-user.user-id
                , input ( if buf_temp_actnrole-user.nik = "":U
                then buf_temp_actnrole-user.lastName else buf_temp_actnrole-user.nik )
                , input substitute( "&1 &2 &3 (&4)"
                , buf_temp_actnrole-user.lastName
                , buf_temp_actnrole-user.firstName
                , buf_temp_actnrole-user.secondName
                , buf_temp_actnrole-user.user-id )
                , input no
                ).
        end.        /* for each buf_temp_actnrole-user */
        run gbl/onewin.w (
            input parparentproc
            , input 0
            , input substitute( "Список пользователей для права < &1 >", p-action-item-name )
            , input "":U
            , input "&Тест"
            , input table temp_onewin_items
            , output table temp_onewin_itemsSelected
            , output v-cur-ext-key
            , output v-accepted
            ).
    end.
END PROCEDURE. /* show-users-for-role-item */

/*==========================================================================*/
procedure init-filter-item :

    do
        on error undo, return error
        :
        define buffer buf_action-item             for action-item .
        define buffer buf_temp_filter-fields-item for temp_filter-fields-item .

        for each buf_action-item no-lock
            :
            find first buf_temp_filter-fields-item
                where buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                no-error.
            if not available buf_temp_filter-fields-item
                then 
            do:
                create buf_temp_filter-fields-item.
                assign
                    buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                    buf_temp_filter-fields-item.record-on        = no
                    .
            end.
        END.

    end. /* do on error */
end procedure. /* init-filter-item */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action-role-context Dialog-Frame 
FUNCTION get-action-role-context RETURNS CHARACTER
    ( BUFFER buf_action-role FOR action-role ) :
    /*------------------------------------------------------------------------------
       Purpose:
        Notes:
    ------------------------------------------------------------------------------*/

    define variable v-return-value as character no-undo .

    run procedure-get-action-role-context in this-procedure
        (input  buf_action-role.action-role-context
        ,output v-return-value
        ) .

    return v-return-value .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action-role-item-state Dialog-Frame 
FUNCTION get-action-role-item-state RETURNS CHARACTER
    ( BUFFER buf_action-item FOR action-item ) :
    /*------------------------------------------------------------------------------
      Purpose:
        Notes:
    ------------------------------------------------------------------------------*/
    define variable v-return-value as character no-undo .

    run procedure-get-action-role-item-state in this-procedure
        (input  buf_action-item.action-item-code
        ,output v-return-value
        ) .
    return v-return-value .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


