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

Товары по сезонам

Автор: Чернова Светлана Александровна
Дата создания: 03/19/02
Author: Svetlana Chernova
Creation date: 03/19/02

*/
using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.

define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-sea-code   like ub.season.sea-code no-undo.
define input parameter p-db-num like ub.season.db-num no-undo.
define input parameter p-name   like ub.season.sea-name no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары с темпами    ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/chgdssea.i }

define buffer buf_season      for ub.season.
define buffer buf_season-attr for ub.season-attr.
define variable rid-list   as character no-undo . /* список recid'ов выбранных аписей */
define variable log-res    as log       no-undo.
define variable rr         as recid     no-undo.
define variable v-log      as logical   no-undo .
define variable v-cur-time as character no-undo.

define variable line-mode  as character no-undo .
define variable doc-rec    as recid     no-undo .
define variable gds-rec    as recid     no-undo .
define variable lns-cnt    as integer   no-undo .
define variable g#log      as logical   no-undo .

define variable v-value    as character no-undo .
define variable v-type     as character no-undo .
define variable is-erpRn   as logical no-undo .

define temp-table tt-gds-list no-undo like ub.goods
    field nn as integer
    index by-nn       nn
    index by_gds-code gds-code
    .

define temp-table tt-gds-sea no-undo 
    field artic       like ub.goods.artic
    field gds-name    like ub.goods.gds-name
    field unit-base   like ub.goods.unit-base
    field min-stock   like ub.gds-season.min-stock
    field season-coef as decimal label "Коэф. спр."
    field gds-code    like ub.goods.gds-code
    field is-inter    as logical
    index pi gds-code
    .

define variable varschartic like ub.price-list.artic initial " " no-undo.
define variable ref-list    as character no-undo.

define variable sch-field   as character no-undo.
define buffer buf_gds-season      for ub.gds-season.  /* для поиска по номеру, дате, факт */
define buffer buf_goods           for ub.goods.  /* для поиска по номеру, дате, факт */
define buffer buf_gds-season-attr for ub.gds-season-attr.

&Scoped-define OPEN-QUERY-BROWSE-2-alt OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea ~
      WHERE INDEX(tt-gds-sea.gds-name,s-name-cnt) > 0 ~
      NO-LOCK ~{&SORTBY-PHRASE}.

define variable sort-column-name as character no-undo .
define variable list-option      as character no-undo.
define stream sout.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds-sea

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt-gds-sea.artic tt-gds-sea.gds-name ~
tt-gds-sea.unit-base tt-gds-sea.min-stock tt-gds-sea.gds-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 ub.tt-gds-sea.min-stock
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 ub.tt-gds-sea
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 ub.tt-gds-sea
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH tt-gds-sea ~
      NO-LOCK ~
    ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH tt-gds-sea ~
      NO-LOCK ~
    ~{&SORTBY-PHRASE}.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-gds-sea
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-gds-sea


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-del b-list b-help R-sort ~
s-artic BROWSE-2 FILL-IN-2 mark-num
&Scoped-Define DISPLAYED-OBJECTS R-sort s-name s-name-cnt s-artic FILL-IN-2 ~
mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-list
    MENU-ITEM m_item1        LABEL "Сохранить"
    MENU-ITEM m_item2        LABEL "Загрузить"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
    LABEL "&Добавить":L
    SIZE 10 BY 1.

DEFINE BUTTON b-del
    LABEL "&Удалить":L
    SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
    LABEL "&Выход ":L
    SIZE 10 BY 1.

DEFINE BUTTON b-help
    LABEL "Помо&щь":L
    SIZE 10 BY 1.

DEFINE BUTTON b-list
    LABEL "Список":L
    SIZE 10 BY 1.

DEFINE BUTTON B-mark
    LABEL "&*"
    SIZE 3 BY 1.

DEFINE BUTTON b-print
    LABEL "Пе&чать":L
    SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
    LABEL "Вы&бор ":L
    SIZE 10 BY 1.

DEFINE BUTTON b-upd
    LABEL "&Изменить":L
    SIZE 10 BY 1.

DEFINE VARIABLE FILL-IN-2  AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по"
    VIEW-AS TEXT
    SIZE 8.88 BY .67
    FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE mark-num   AS CHARACTER FORMAT "X(256)":U
    VIEW-AS TEXT
    SIZE 9 BY .67
    FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE s-artic    AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 30 BY 1
    FGCOLOR 1 NO-UNDO.

DEFINE VARIABLE s-name     AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 30 BY 1
    FGCOLOR 1 NO-UNDO.

DEFINE VARIABLE s-name-cnt AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 30 BY 1
    FGCOLOR 1 NO-UNDO.

DEFINE VARIABLE R-sort     AS INTEGER
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
    "Артик", 1,
    "Нач.назв", 2,
    "Нач.слова", 3
    SIZE 34.63 BY .96 TOOLTIP "Поиск по" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
    tt-gds-sea SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
    QUERY BROWSE-2 NO-LOCK DISPLAY
    tt-gds-sea.artic FORMAT "X(16)":U
    tt-gds-sea.gds-name FORMAT "X(48)":U
    tt-gds-sea.unit-base FORMAT "X(3)":U
    tt-gds-sea.min-stock FORMAT ">>,>>9.999":U LABEL-FGCOLOR 1
    tt-gds-sea.season-coef FORMAT ">>,>>9.999":U LABEL-FGCOLOR 1
    tt-gds-sea.gds-code FORMAT "999999999":U
  ENABLE
      tt-gds-sea.min-stock
      tt-gds-sea.season-coef
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 18.33
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
    b-exit AT ROW 1 COL 1
    b-sel AT ROW 1 COL 11
    B-mark AT ROW 1 COL 21
    b-add AT ROW 1 COL 24
    b-upd AT ROW 1 COL 34
    b-del AT ROW 1 COL 44
    b-print AT ROW 1 COL 54
    b-list AT ROW 1 COL 64.13
    b-help AT ROW 1 COL 78
    R-sort AT ROW 2.04 COL 10.75 NO-LABEL
    s-name AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
    s-name-cnt AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
    s-artic AT ROW 2.04 COL 44.13 COLON-ALIGNED NO-LABEL
    BROWSE-2 AT ROW 3.71 COL 1
    FILL-IN-2 AT ROW 2.21 COL 1 NO-LABEL
    mark-num AT ROW 2.96 COL 1 NO-LABEL
    SPACE(85.00) SKIP(18.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Товары по сезону".


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
/* BROWSE-TAB BROWSE-2 s-artic Dialog-Frame */
ASSIGN
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.

ASSIGN
    b-list:POPUP-MENU IN FRAME Dialog-Frame = MENU POPUP-MENU-b-list:HANDLE.

/* SETTINGS FOR BUTTON B-mark IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-print IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-sel IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-upd IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN s-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN s-name-cnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "tt-gds-sea..."
     _Options          = "NO-LOCK SORTBY-PHRASE"
     _FldNameList[1]   = tt-gds-sea.artic
     _FldNameList[2]   = tt-gds-sea.gds-name
     _FldNameList[3]   = tt-gds-sea.unit-base
     _FldNameList[4]   > tt-gds-sea.min-stock
"tt-gds-sea.min-stock" ? ? "decimal" ? ? ? ? 1 ? yes ? no no ? yes no no "U" "" ""
     _FldNameList[5]   = tt-gds-sea.gds-code
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары по сезону */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
    DO:
        { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_collection_add-def':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
        if not v-log then return no-apply .

        assign
            line-mode = {&add-def}
            .
        run str/chsgdsls.w
            (   input parParentProc ,
            input "season" ,
            input "Сезон " + p-name  ,
            input ? ,
            input ? ,
            input v-cntxt-host-code-obj,
            input-output varschartic,
            output ref-list,
            output table tt-gds-list,
            false )
            /* no-error */.

        if ref-list <> "" then 
        do:
            run cycle-add in this-procedure no-error.
            if error-status:error then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при вызове процедуры создания товара" skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                return no-apply.
            end.
            {&OPEN-QUERY-{&BROWSE-NAME}}
        end.
        
        for each tt-gds-sea no-lock:
            find first buf_gds-season exclusive-lock where buf_gds-season.sea-code = p-sea-code 
                and buf_gds-season.db-num = p-db-num 
                and buf_gds-season.gds-code = tt-gds-sea.gds-code no-error.
            find first buf_gds-season-attr exclusive-lock where buf_gds-season-attr.sea-code = p-sea-code 
                and buf_gds-season-attr.db-num = p-db-num 
                and buf_gds-season-attr.gds-code = tt-gds-sea.gds-code
                and buf_gds-season-attr.attr-code = {&gdsseaattr-season-coef} no-error.
      
            if not available buf_gds-season then 
            do:
                create buf_gds-season.
                assign
                    buf_gds-season.sea-code = p-sea-code
                    buf_gds-season.db-num   = p-db-num
                    buf_gds-season.gds-code = tt-gds-sea.gds-code
                    .
            end.
            assign
                buf_gds-season.min-stock = tt-gds-sea.min-stock
                .
    
            if tt-gds-sea.season-coef <> 0 and tt-gds-sea.season-coef <> ? and tt-gds-sea.season-coef <> 1 then 
            do:
                if not available buf_gds-season-attr then
                    create buf_gds-season-attr.
                assign 
                    buf_gds-season-attr.sea-code   = p-sea-code
                    buf_gds-season-attr.db-num     = p-db-num
                    buf_gds-season-attr.gds-code   = tt-gds-sea.gds-code
                    buf_gds-season-attr.attr-code  = {&gdsseaattr-season-coef}
                    buf_gds-season-attr.attr-value = string (tt-gds-sea.season-coef)
                    .
            end.
            else 
            do:
                if available buf_gds-season-attr then delete buf_gds-season-attr.
            end.
    
        end.


    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
    DO:

        for each tt-gds-sea no-lock:
            find first buf_gds-season exclusive-lock where buf_gds-season.sea-code = p-sea-code 
                and buf_gds-season.db-num = p-db-num 
                and buf_gds-season.gds-code = tt-gds-sea.gds-code no-error.
            find first buf_gds-season-attr exclusive-lock where buf_gds-season-attr.sea-code = p-sea-code 
                and buf_gds-season-attr.db-num = p-db-num 
                and buf_gds-season-attr.gds-code = tt-gds-sea.gds-code
                and buf_gds-season-attr.attr-code = {&gdsseaattr-season-coef} no-error.
      
            if not available buf_gds-season then 
            do:
                create buf_gds-season.
                assign
                    buf_gds-season.sea-code = p-sea-code
                    buf_gds-season.db-num   = p-db-num
                    buf_gds-season.gds-code = tt-gds-sea.gds-code
                    .
            end.
            assign
                buf_gds-season.min-stock = tt-gds-sea.min-stock
                .
    
            if tt-gds-sea.season-coef <> 0 and tt-gds-sea.season-coef <> ? and tt-gds-sea.season-coef <> 1 then 
            do:
                if not available buf_gds-season-attr then
                    create buf_gds-season-attr.
                assign 
                    buf_gds-season-attr.sea-code   = p-sea-code
                    buf_gds-season-attr.db-num     = p-db-num
                    buf_gds-season-attr.gds-code   = tt-gds-sea.gds-code
                    buf_gds-season-attr.attr-code  = {&gdsseaattr-season-coef}
                    buf_gds-season-attr.attr-value = string (tt-gds-sea.season-coef)
                    .
            end.
            else 
            do:
                if available buf_gds-season-attr then delete buf_gds-season-attr.
            end.
    
        end.

    END.
    .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
    DO:
        define variable g-log as logical no-undo .
        { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_collection_deletion':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
        if not v-log then return no-apply .
        if not available tt-gds-sea then  return no-apply.

        message "Удалить запись ? "
            view-as alert-box question
            buttons yes-no
            update g-log.
        if g-log = false then return no-apply.

        define variable v-recid as integer no-undo .
        define variable ii      as integer no-undo .

        find first buf_gds-season exclusive-lock where buf_gds-season.sea-code = p-sea-code
            and buf_gds-season.db-num = p-db-num
            and buf_gds-season.gds-code = tt-gds-sea.gds-code no-error .
        if available buf_gds-season then delete buf_gds-season.
        find current tt-gds-sea.
        delete tt-gds-sea.
        {&BROWSE-NAME}:delete-current-row().

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-list Dialog-Frame
ON CHOOSE OF b-list IN FRAME Dialog-Frame /* Список */
    DO:
        if list-option = "" then 
        do:
            run gbl/pop-up.p (self:handle, no) no-error.
            if error-status:error then return no-apply.
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
    DO:
        v-cur-time = "Проба". 
  
        define variable v-file-name as character no-undo.
        run create-rep(output v-file-name).
        if v-file-name = ? then
            MESSAGE "Не удалось создать html-файл"
                VIEW-AS ALERT-BOX.
        else
            run open-ie(v-file-name). 
    END.


&Scoped-define SELF-NAME tt-gds-sea.season-coef
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-gds-sea.season-coef BROWSE-2
ON LEAVE OF tt-gds-sea.season-coef IN BROWSE BROWSE-2 /* Список */
    DO:
  
        define variable v-rowid as rowid no-undo.

        if tt-gds-sea.season-coef:input-value in browse browse-2 = 0 or tt-gds-sea.season-coef = ? then 
        do:
            assign
                tt-gds-sea.season-coef = 1. 
            message "Коэффициент увеличения спроса не может равняться нулю" view-as alert-box.
            v-rowid = rowid (tt-gds-sea).
            {&OPEN-QUERY-BROWSE-2}
    reposition BROWSE-2 to rowid v-rowid. 
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор  */
    DO:
        if ( available season ) AND ( rid-list = "" ) then
            rid-list = string( recid( season ) ) .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd Dialog-Frame
ON CHOOSE OF b-upd IN FRAME Dialog-Frame /* Изменить */
    DO:
        { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_collection_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-log
  }
        if not v-log then return no-apply .
        if not available season THEN return no-apply.


    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_item1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_item1 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_item1 /* Сохранить */
    DO:
        list-option = "save":U.
        run proc-b-list in this-procedure (input list-option) no-error.
        if error-status:error then return no-apply.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_item2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_item2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_item2 /* Загрузить */
    DO:
        list-option = "load":U.
        run proc-b-list in this-procedure (input list-option) no-error.
        if error-status:error then return no-apply.


    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-sort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-sort Dialog-Frame
ON VALUE-CHANGED OF R-sort IN FRAME Dialog-Frame
    DO:
        Assign frame {&frame-name} r-sort.
        case r-sort :
            when 1 then 
                do:
                    if sch-field = "s-name-cnt" then 
                    do:
                        assign 
                            frame {&frame-name}:title = "Товары >> Сезон - " + p-name.
                        {&OPEN-QUERY-BROWSE-2}
                    end.
                    enable s-artic with frame {&frame-name}.
                    Hide s-name  s-name-cnt in frame {&frame-name}.
                    display s-artic with frame {&frame-name}.
                end.
            when 2 then 
                do:
                    if sch-field = "s-name-cnt" then 
                    do:
                        assign 
                            frame {&frame-name}:title = "Товары >> Сезон - " + p-name.
                        {&OPEN-QUERY-BROWSE-2}
                    end.
                    enable s-name with frame {&frame-name}.
                    hide s-artic  s-name-cnt in frame {&frame-name}.
                    display s-name with frame {&frame-name}.
                end.
            when 3 then 
                do:
                    enable s-name-cnt with frame {&frame-name}.
                    hide s-artic  s-name in frame {&frame-name}.
                    display s-name-cnt with frame {&frame-name}.
                end.

        end case.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-artic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-artic Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF s-artic IN FRAME Dialog-Frame
    OR  RETURN OF s-artic IN FRAME {&frame-name}
    DO:
        if s-artic <> input frame {&frame-name} s-artic or sch-field <> "s-artic" then 
        do:

            sch-field = "s-artic".
            assign 
                s-artic = input frame {&frame-name} s-artic.

            doc-rec = ?.
            for each tt-gds-sea no-lock,
                first buf_goods no-lock where
                buf_goods.gds-code = tt-gds-sea.gds-code and
                buf_goods.artic begins s-artic :
                doc-rec = recid ( tt-gds-sea ) .
                leave.
            end.
            if doc-rec = ? then message "Товар не найден !"  .
            else
                reposition {&browse-name} to recid doc-rec no-error.

            return no-apply.
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-name Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF s-name IN FRAME Dialog-Frame
    OR  RETURN OF s-name IN FRAME {&frame-name}
    DO:
        if s-name <> input frame {&frame-name} s-name or sch-field <> "s-name" then 
        do:

            sch-field = "s-name".
            assign 
                s-name = input frame {&frame-name} s-name.

            doc-rec = ?.
            for each tt-gds-sea no-lock,
                first buf_goods no-lock where
                buf_goods.gds-code = tt-gds-sea.gds-code and
                buf_goods.gds-name begins s-name
                :
                doc-rec = recid(tt-gds-sea) .
                leave.
            end.
            if doc-rec = ? then message "Товар не найден !"  .
            else
                reposition {&browse-name} to recid doc-rec no-error.

            return no-apply.
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME s-name-cnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL s-name-cnt Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF s-name-cnt IN FRAME Dialog-Frame
    OR  RETURN OF s-name-cnt IN FRAME {&frame-name}
    DO:
        if s-name-cnt <> input frame {&frame-name} s-name-cnt or sch-field <> "s-name-cnt" then 
        do:

            sch-field = "s-name-cnt".
            assign 
                s-name-cnt = input frame {&frame-name} s-name-cnt.

            doc-rec = ?.
            for each tt-gds-sea no-lock,
                first buf_goods no-lock where
                buf_goods.gds-code = tt-gds-sea.gds-code  and
            INDEX (buf_goods.gds-name,s-name-cnt) > 0
                :
                doc-rec = recid(tt-gds-sea) .
                leave.
            end.
            if doc-rec = ? then message "Товар не найден !"  .
            else 
            do:
                assign 
                    frame {&frame-name}:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt .
                {&OPEN-QUERY-BROWSE-2-alt}
            /* reposition {&browse-name} to recid doc-rec no-error. */
            end.
            return no-apply.
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-2 IN FRAME Dialog-Frame
    DO:
        if available tt-gds-sea then 
        do:
            if tt-gds-sea.is-inter 
                then tt-gds-sea.artic:bgcolor in browse {&browse-name}  = 12.
            else tt-gds-sea.artic:bgcolor in browse {&browse-name}  = ?.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

assign 
    frame {&frame-name}:title = "Товары >>-  " + p-name.

{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "tt-gds-sea.artic"
  &sort-clmn_2    = "tt-gds-sea.gds-name"
  &sort-clmn_3    = "tt-gds-sea.unit-base"
  &sort-clmn_4    = "tt-gds-sea.min-stock"
  &open-query     = "run OpenBr."
  &open-query-otherwise = "run OpenBr."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no" }

ASSIGN 
    b-list:POPUP-MENU IN FRAME {&frame-name} = MENU POPUP-MENU-b-list:HANDLE.
ASSIGN 
    b-list:MENU-MOUSE = 1.

{ gbl/f2.i {&browse-name} " " " " parParentProc }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    define variable v-seaobj   as character no-undo.
    define variable v-sea-code as integer   no-undo.
    define variable v-db-num   as integer   no-undo.
    define variable v-longchar as longchar  no-undo .
    define variable v-ok       as logical   no-undo init yes.

    define buffer buf1_season for ub.season.

    find first  buf_season no-lock where
        buf_season.sea-code = p-sea-code and
        buf_season.db-num   = p-db-num
        no-error .
    if not available buf_season  then return error .
    find first buf_season-attr no-lock where buf_season-attr.sea-code = p-sea-code
        and buf_season-attr.db-num = p-db-num
        and buf_season-attr.attr-code = {&seaattr-obj}
        no-error.
    if available buf_season-attr then
        assign
            v-seaobj = buf_season-attr.attr-value
            .
    for each buf_gds-season no-lock where buf_gds-season.sea-code = p-sea-code and buf_gds-season.db-num = p-db-num, 
        each buf_goods where buf_goods.gds-code = buf_gds-season.gds-code:
        find first buf_gds-season-attr no-lock where buf_gds-season-attr.db-num = buf_gds-season.db-num 
            and buf_gds-season-attr.sea-code = buf_gds-season.sea-code 
            and buf_gds-season-attr.gds-code = buf_gds-season.gds-code
            and buf_gds-season-attr.attr-code = {&gdsseaattr-season-coef} no-error.
        create tt-gds-sea.
        assign
            tt-gds-sea.artic       = buf_goods.artic
            tt-gds-sea.gds-code    = buf_goods.gds-code
            tt-gds-sea.gds-name    = buf_goods.gds-name
            tt-gds-sea.season-coef = if available buf_gds-season-attr then decimal (buf_gds-season-attr.attr-value) else 1 
            tt-gds-sea.min-stock   = buf_gds-season.min-stock
            tt-gds-sea.unit-base   = buf_goods.unit-base
            .

        run chk-gdssea in this-procedure 
            ( input tt-gds-sea.gds-code,
            input v-seaobj,
            input buf_season.sea-month-1,
            input buf_season.sea-month-2,
            input rowid (buf_season),
            output v-sea-code,
            output v-db-num,
            output v-ok) no-error.
        if not v-ok then 
        do:
            find first buf1_season no-lock where buf1_season.sea-code = v-sea-code
                and buf1_season.db-num = v-db-num
                no-error.
            assign
                v-longchar          = v-longchar +
          substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v-sea-code, buf1_season.sea-name, {&new-line})
                v-ok                = true
                tt-gds-sea.is-inter = true
                .
        end.
    end.
  
    if v-longchar <> "" then 
    do:
        run gbl/d-longchar.w (
            ?,
            'Editor_row=2\':u
            + 'title=Проверка товарного наполнения сезона: есть пересечения\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
            ,input-output v-longchar
            ,output v-ok ) no-error .
        if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "4"
                view-as alert-box error
                .
        assign
            v-longchar = "".
    end.
  
    run enable_UI in this-procedure .
    if can-find (first tt-gds-sea) then BROWSE-2:refresh().
 
    IF BUF_SEASON.SEA-MONTH-1 = 0 THEN hide tt-gds-sea.min-stock tt-gds-sea.season-coef in browse  {&browse-name}  .
    enable  s-artic with frame {&frame-name}.
    Hide      s-name  s-name-cnt in frame {&frame-name}.
    display s-artic with frame {&frame-name}.
    /*
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-type) no-error.
    is-erpRN = logical(v-value) no-error .
    if error-status:error then is-erpRN = false .
    
    if is-erpRN
    then do :
      disable
        b-add
        b-upd
        b-del
      with FRAME {&FRAME-NAME}.
      menu-item m_item2:sensitive = false .
    end.
    */
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cycle-add Dialog-Frame
PROCEDURE cycle-add :
    define variable dct-type as character no-undo .
    define variable stp-cycl as logical   no-undo .
    define variable v-num    as integer   no-undo .
    define variable v-flag   as logical   no-undo init false .
    define buffer bb_gds-season for gds-season.
    define buffer old_season    for season.
    stp-cycl = false .

    if buf_season.sea-month-1 = 0 then dct-type = "coll". 
    else dct-type = "season" .
    if dct-type = "coll" then 
    do:
        run gbl/d-askw.w
            (input "Вопрос" /* Заголовок окна */
            ,input "Если товар уже прикреплен к коллекции, пропускаем его?"
            ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
            ,input "Не добавлять|Добавлять|Остановка" /* список названий кнопок  */
            ,input "Не добавляем товар в новую коллекцию, товар остается в старой коллекции|" /* список описаний кнопок */
            + "Добавляем товар в новую коллекцию и удаляем в старой коллекции|"
            + "Остановить добавление товаров, если встречаются товары прикрепленные к другим коллекциям."
            ,input 1 /* значение возвращаемое при нажатии enter */
            ,input 2 /* значение возвращаемое при нажатии escape */
            ,output v-num /* выбор пользователя */
            ).
        case v-num :
            when 1 then 
                do:
                    for each tt-gds-list no-lock  by tt-gds-list.nn :
                        lns-cnt  =  lns-cnt + 1 .
                        if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
                        v-flag = false .
                        for each   bb_gds-season no-lock where
                            bb_gds-season.gds-code = tt-gds-list.gds-code  ,
                            each old_season no-lock where
                            old_season.sea-code = bb_gds-season.sea-code and
                            old_season.db-num   = bb_gds-season.db-num   and
                            old_season.sea-month-1 = 0
                            :
                            v-flag = true .
                            leave.
                        end.

                        if  v-flag = false then 
                        do :
                            find first tt-gds-sea no-lock
                                where tt-gds-sea.gds-code = tt-gds-list.gds-code
                                and tt-gds-sea.min-stock = 0 no-error.
                            if not available tt-gds-sea then 
                            do :
                                create tt-gds-sea.
                                assign
                                    tt-gds-sea.gds-code  = tt-gds-list.gds-code
                                    tt-gds-sea.artic     = tt-gds-list.artic
                                    tt-gds-sea.gds-name  = tt-gds-list.gds-name
                                    tt-gds-sea.unit-base = tt-gds-list.unit-base
                                    tt-gds-sea.min-stock = 0
                                    .
                            end.
                        end.
                        if  stp-cycl = true then leave.
                    end.

                end.
            when 2 then 
                do:
                    for each tt-gds-list no-lock  by tt-gds-list.nn :
                        lns-cnt  =  lns-cnt + 1 .
                        if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
                        v-flag = false .
                        for each  bb_gds-season exclusive-lock  where
                            bb_gds-season.gds-code = tt-gds-list.gds-code ,
                            each old_season no-lock where
                            old_season.sea-code = bb_gds-season.sea-code and
                            old_season.db-num   = bb_gds-season.db-num   and
                            old_season.sea-month-1 = 0
                            :
                            delete bb_gds-season .
                        end.
                        find first tt-gds-sea no-lock
                            where tt-gds-sea.gds-code = tt-gds-list.gds-code
                            and tt-gds-sea.min-stock = 0 no-error.
                        if not available tt-gds-sea then 
                        do :
                            create tt-gds-sea.
                            assign
                                tt-gds-sea.gds-code  = tt-gds-list.gds-code
                                tt-gds-sea.artic     = tt-gds-list.artic
                                tt-gds-sea.gds-name  = tt-gds-list.gds-name
                                tt-gds-sea.unit-base = tt-gds-list.unit-base
                                tt-gds-sea.min-stock = 0
                                .
                        end.
                        if  stp-cycl = true then leave.
                    end.

                end.
            when 3 then 
                do:
                    for each tt-gds-list no-lock  by tt-gds-list.nn :
                        lns-cnt  =  lns-cnt + 1 .
                        if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
                        v-flag = false .
                        for each   bb_gds-season no-lock where
                            bb_gds-season.gds-code = tt-gds-list.gds-code  ,
                            each old_season no-lock where
                            old_season.sea-code = bb_gds-season.sea-code and
                            old_season.db-num   = bb_gds-season.db-num   and
                            old_season.sea-month-1 = 0 :
                            v-flag = true .
                            leave.
                        end.
                        if  v-flag = true  then 
                        do:
                            leave .
                        end.
                        if  stp-cycl = true then leave.
                    end.
                    if v-flag <> true then 
                    do :
                        for each tt-gds-list no-lock  by tt-gds-list.nn :
                            find first tt-gds-sea no-lock
                                where tt-gds-sea.gds-code = tt-gds-list.gds-code
                                and tt-gds-sea.min-stock = 0 no-error.
                            if not available tt-gds-sea then 
                            do :
                                create tt-gds-sea.
                                assign
                                    tt-gds-sea.gds-code  = tt-gds-list.gds-code
                                    tt-gds-sea.artic     = tt-gds-list.artic
                                    tt-gds-sea.gds-name  = tt-gds-list.gds-name
                                    tt-gds-sea.unit-base = tt-gds-list.unit-base
                                    tt-gds-sea.min-stock = 0
                                    .
                            end.
                        end.
                    end.
                end.

        end case.




    end.
    else 
    do:
        define variable v-ok       as logical   no-undo.
        define variable v-seaobj   as character no-undo.
        define variable v-sea-code as integer   no-undo.
        define variable v-db-num   as integer   no-undo.
        define variable v-longchar as longchar  no-undo .
        define buffer buf1_season for ub.season.
  
        if not available buf_season then
            return no-apply.
        find first buf_season-attr no-lock where buf_season-attr.sea-code = p-sea-code
            and buf_season-attr.db-num = p-db-num
            and buf_season-attr.attr-code = {&seaattr-obj}
            no-error.
        if available buf_season-attr then
            assign
                v-seaobj = buf_season-attr.attr-value
                .
        for each tt-gds-list no-lock  by tt-gds-list.nn :
            lns-cnt  =  lns-cnt + 1 .
            if lns-cnt > 1 then assign line-mode = "ЦИКЛ":U.
            if not can-find (first tt-gds-sea where
                tt-gds-sea.gds-code = tt-gds-list.gds-code no-lock
                ) then 
            do:
                run chk-gdssea in this-procedure 
                    ( input tt-gds-list.gds-code,
                    input v-seaobj,
                    input buf_season.sea-month-1,
                    input buf_season.sea-month-2,
                    input rowid(buf_season),
                    output v-sea-code,
                    output v-db-num,
                    output v-ok) no-error.
                if not v-ok then 
                do:
                    find first buf_goods no-lock where buf_goods.gds-code = tt-gds-list.gds-code no-error.
                    find first buf1_season no-lock where buf1_season.sea-code = v-sea-code
                        and buf1_season.db-num = v-db-num
                        no-error.
                    assign
                        v-longchar = v-longchar +
            substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v-sea-code, buf1_season.sea-name, {&new-line})
                        v-ok       = true
                        .
                    next.
                end.
                create tt-gds-sea.
                assign
                    tt-gds-sea.gds-code    = tt-gds-list.gds-code
                    tt-gds-sea.artic       = tt-gds-list.artic
                    tt-gds-sea.gds-name    = tt-gds-list.gds-name
                    tt-gds-sea.unit-base   = tt-gds-list.unit-base
                    tt-gds-sea.min-stock   = 0
                    tt-gds-sea.season-coef = 1
                    .
            end.
            if  stp-cycl = true then leave.
        end.
        if v-longchar <> "" then 
        do:
            run gbl/d-longchar.w (
                ?,
                'Editor_row=2\':u
                + 'title=Проверка товарного наполнения сезона: невозможно добавить товары\':u
                + 'Editor_col=1\':u
                + 'Editor_width=96\':u
                + 'Editor_height=21\':u
                + 'readonly=yes\':u
                ,input-output v-longchar
                ,output v-ok ) no-error .
            if error-status :error then message
                    vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    return-value skip
                    "4"
                    view-as alert-box error
                    .
            assign
                v-longchar = "".
        end.
    end.
    ASSIGN 
        lns-cnt = lns-cnt + 1 .

end procedure.

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
    DISPLAY R-sort s-name s-name-cnt s-artic FILL-IN-2 mark-num
        WITH FRAME Dialog-Frame.
    ENABLE b-exit b-add b-del b-list b-help R-sort s-artic BROWSE-2 FILL-IN-2
        mark-num b-print
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
    define variable t-ret as logical no-undo .
    t-ret =  session:SET-WAIT-STATE("GENERAL") .
&scop my-open-query     if r-sort = 3 and sch-field = "s-name-cnt" then do: ~
    assign frame ~{&frame-name}:title = "Товары >> Сезон - " + p-name + " , содержащие в названии " + s-name-cnt . ~
   ~{&OPEN-QUERY-BROWSE-2-alt}  ~
   end. ~
   else DO: ~
    assign frame ~{&frame-name}:title = "Товары >> Сезон - " + p-name. ~
   ~{&OPEN-QUERY-BROWSE-2} ~
   end.

    case sort-column-name :
        when "" then 
            do:
    &scop SORTBY-PHRASE
                {&my-open-query}
            end.

        when "tt-gds-sea.artic" then 
            do:
    &scop SORTBY-PHRASE by tt-gds-sea.artic
                {&my-open-query}
            end.

        when "tt-gds-sea.gds-name" then 
            do:
    &scop SORTBY-PHRASE by tt-gds-sea.gds-name
                {&my-open-query}
            end.

        when "tt-gds-sea.unit-base" then 
            do:
    &scop SORTBY-PHRASE by tt-gds-sea.unit-base
                {&my-open-query}
            end.

        when "tt-gds-sea.min-stock" then 
            do:
    &scop SORTBY-PHRASE by tt-gds-sea.min-stock
                {&my-open-query}
            end.

        otherwise 
        do:
    &scop SORTBY-PHRASE
            {&my-open-query}
        end.
    end case.

    t-ret =  session:SET-WAIT-STATE("") .
    apply "HOME" to {&browse-name} in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-list Dialog-Frame
PROCEDURE proc-b-list :
    define input parameter loc-list-option as character no-undo.

    define buffer loc-gds-season for ub.gds-season.

    define variable v-sea-code        like ub.gds-season.sea-code no-undo.
    define variable jj                as integer   no-undo.
    define variable varrid-gds-season as recid     no-undo.
    define variable f-name            as character init "default.cli" no-undo.
    define variable imp-type          like ub.goods.prod-type no-undo.
    define variable imp-code          like ub.goods.prod-code no-undo.
    define variable loc-gds-code      like ub.gds-season.gds-code no-undo.
    define variable loc-min-stock     like ub.gds-season.min-stock no-undo.
    define variable loc-sea-code      like ub.gds-season.sea-code no-undo.
    define variable loc-db-num        like ub.gds-season.db-num no-undo.
    v-sea-code =  p-sea-code .
    case loc-list-option:
        when "save":U then 
            do:
                g#log = yes.
                message "Сохранить все товары в файле списка"
                    view-as alert-box question buttons OK-Cancel update g#log.
                if not g#log then 
                do:
                    list-option = "":U.
                    return.
                end.
                assign
                    f-name = "default.sea"
                    g#log  = yes
                    .
                system-dialog get-file f-name
                    filters "Списки товаров  *.sea" "*.sea"
                    ask-overwrite
                    save-as
                    use-filename
                    update g#log
                    default-extension "sea".
                if not g#log then  
                do:
                    list-option = "":U.
                    return.
                end.
                g#log =  session:SET-WAIT-STATE("GENERAL") .

                output stream sout to value (f-name).
                for each loc-gds-season No-LOCK WHERE
                    loc-gds-season.sea-code = v-sea-code and
                    loc-gds-season.db-num   = p-db-num
                    :
                    export stream sout
                        loc-gds-season.gds-code
                        loc-gds-season.min-stock
                        loc-gds-season.sea-code
                        loc-gds-season.db-num
                        .
                END.
                output stream sout close.
                g#log =  session:SET-WAIT-STATE("") .
            end.


        when "load":U then 
            do:

                system-dialog get-file f-name
                    filters "Списки клиентов *.sea" "*.sea"
                    title "Выберите файл списка"
                    INITIAL-DIR "."
                    return-to-start-dir
                    must-exist
                    /* use-filename */
                    update g#log
                    default-extension "sea".
                if not g#log then 
                do:
                    list-option = "":U.
                    return.
                end.
                g#log =  session:SET-WAIT-STATE("GENERAL") .
                input stream sout from value (f-name).
                _repeat:
                repeat:
                    import stream sout
                        loc-gds-code
                        loc-min-stock
                        loc-sea-code
                        loc-db-num
                        no-error.

                    find first loc-gds-season exclusive-LOCK WHERE
                        loc-gds-season.gds-code = loc-gds-code  and
                        loc-gds-season.sea-code = v-sea-code and
                        loc-gds-season.db-num   = p-db-num
                        no-error.
                    if not available loc-gds-season then create loc-gds-season.

                    assign
                        loc-gds-season.gds-code  = loc-gds-code
                        loc-gds-season.min-stock = loc-min-stock
                        loc-gds-season.sea-code  = v-sea-code
                        loc-gds-season.db-num    = p-db-num
                        .

                end.
                run loadbrowse (input loc-gds-season.sea-code, input loc-gds-season.db-num, input '').
                input stream sout close.
                g#log =  session:SET-WAIT-STATE("") .
                {&OPEN-QUERY-BROWSE-2}
            end.
    END CASE.
    loc-list-option = "":U.

END PROCEDURE.

procedure create-rep:
    define output parameter p-filename as character no-undo.
        
    define variable v-rls-file  as character no-undo.
    define variable v-data-file as character no-undo.
    define variable v-xsl-file  as character no-undo.
    define variable v-tmp-file  as character no-undo.
    define variable hw          as handle    no-undo.
    define variable rep-out     as class     Rep-Out no-undo.
    
    assign
        v-xsl-file  = search("exe/goods-seas.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file  = session:temp-directory + string(time) + ".html"
        .
    
    
    create sax-writer hw.
    hw:formatted = true.
    hw:set-output-destination ("file", v-data-file).
    
    
    run write-data(hw) .
    rep-out = new rep-out().
    v-rls-file = rep-out:xsl-transform(v-data-file, v-xsl-file).    
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).  
    os-delete value(v-rls-file).
    delete object rep-out.
  
    p-filename = v-tmp-file.
    
end.

procedure write-data:
    define input parameter hw as handle no-undo.
    hw:start-document ().
        
    hw:start-element ("rep").
    hw:start-element ("card").
        
    hw:insert-attribute ("sea-code", if p-sea-code = ? then "" else  string(p-sea-code) ).
    hw:insert-attribute ("db-num", if p-db-num = ? then "" else  string(p-db-num) ).
    hw:insert-attribute ("name", if p-name = ? then "" else  string(p-name) ).
        
        
    for each tt-gds-sea no-lock:
        hw:start-element ("line").
        hw:insert-attribute ("gds-artic",if tt-gds-sea.artic = ? then "" else string(tt-gds-sea.artic)).   /* Артикул товара */ 
        hw:insert-attribute ("gds-name",if tt-gds-sea.gds-name = ? then "" else  string(tt-gds-sea.gds-name) ). /*Название товара*/
        hw:insert-attribute ("unit-base",if tt-gds-sea.unit-base = ? then "" else string(tt-gds-sea.unit-base)). /* Ед. изм */
        hw:insert-attribute ("min-stock",if tt-gds-sea.min-stock = ? then "" else string(tt-gds-sea.min-stock,"->>>,>>9.999")). /* Мин. ост.*/
        hw:insert-attribute ("season-coef",if tt-gds-sea.season-coef = ? then "" else string(tt-gds-sea.season-coef,"->>>,>>9.999")). /* Коэф. спр.*/
        hw:insert-attribute ("gds-code",if tt-gds-sea.gds-code = ? then "" else string(tt-gds-sea.gds-code)). /*Код товара*/        
        hw:end-element ("line"). 
    end.
       
    hw:end-element ("card").
    hw:end-element ("rep").
        
        
    hw:end-document ().

end.



procedure loadbrowse :
    define input parameter p2-sea-code   like ub.season.sea-code no-undo.
    define input parameter p2-db-num like ub.season.db-num no-undo.
    define input parameter p2-name   like ub.season.sea-name no-undo.
    define buffer tt-gds-sea2 for tt-gds-sea.
    define variable v2-sea-code as integer.
    define variable v2-db-num   as integer.
    define variable v2-ok       as logical.
    define variable v2-longchar as char.
    define buffer buf2_season for season.
    
   for each tt-gds-sea:
       delete tt-gds-sea.
       end.
       
       
    find first  buf2_season no-lock where
        buf2_season.sea-code = p2-sea-code and
        buf2_season.db-num   = p2-db-num
        no-error .
    if not available buf2_season  then return error .
    find first buf_season-attr no-lock where buf_season-attr.sea-code = p2-sea-code
        and buf_season-attr.db-num = p2-db-num
        and buf_season-attr.attr-code = {&seaattr-obj}
        no-error.
    if available buf_season-attr then
        assign
            v-seaobj = buf_season-attr.attr-value
            .
    for each buf_gds-season no-lock where buf_gds-season.sea-code = p2-sea-code and buf_gds-season.db-num = p2-db-num, 
        each buf_goods where buf_goods.gds-code = buf_gds-season.gds-code:
        find first buf_gds-season-attr no-lock where buf_gds-season-attr.db-num = buf_gds-season.db-num 
            and buf_gds-season-attr.sea-code = buf_gds-season.sea-code 
            and buf_gds-season-attr.gds-code = buf_gds-season.gds-code
            and buf_gds-season-attr.attr-code = {&gdsseaattr-season-coef} no-error.
        if not available buf_gds-season-attr then 
        do:
            create tt-gds-sea2.
            assign
                tt-gds-sea2.artic       = buf_goods.artic
                tt-gds-sea2.gds-code    = buf_goods.gds-code
                tt-gds-sea2.gds-name    = buf_goods.gds-name
                tt-gds-sea2.season-coef = if available buf_gds-season-attr then decimal (buf_gds-season-attr.attr-value) else 1 
                tt-gds-sea2.min-stock   = buf_gds-season.min-stock
                tt-gds-sea2.unit-base   = buf_goods.unit-base
                .
        end.
        run chk-gdssea in this-procedure 
            ( input tt-gds-sea2.gds-code,
            input v-seaobj,
            input buf2_season.sea-month-1,
            input buf2_season.sea-month-2,
            input rowid (buf2_season),
            output v2-sea-code,
            output v2-db-num,
            output v2-ok) no-error.
        if not v2-ok then 
        do:
            find first buf2_season no-lock where buf2_season.sea-code = v2-sea-code
                and buf2_season.db-num = v2-db-num
                no-error.
            assign
                v2-longchar         = v2-longchar +
          substitute ("Товар &1 &2 пересекается с сезоном &3 &4.&5", buf_goods.gds-code, buf_goods.gds-name, v2-sea-code, buf2_season.sea-name, {&new-line})
                v2-ok               = true
                tt-gds-sea2.is-inter = true
                .
        end.
    end.

end procedure.






procedure open-ie:
    define input parameter p-filename as character no-undo.
    
    define variable o-IE as com-handle no-undo.
   
    
    create "InternetExplorer.Application" o-IE.
    /* o-IE:menubar = false. */
    o-IE:addressbar = false.
    o-IE:Navigate(p-filename).
    o-IE:visible = true.
    release object o-IE.

end.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME