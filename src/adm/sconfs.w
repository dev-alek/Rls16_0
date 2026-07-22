&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER find_sysconf FOR ub.sysconf.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_curr-sysconf FOR ub.sysconf.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список фирм системы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/24/05
Author: Bakhtadze Natalya
Creation date: 11/24/05

bttns - список кнопок доступных для редактировани
        кроме кнопок здесь может быть ещё ключевое слово convert ,
  convert     - это не кнопка - это особое ключевое слово, которое означает,
                что входной-выходной список p-rid-list
                надо конвертировать в список КОДОВ фирм (host-code) а не Recid
  b-sel         выбрать
  b-mark        выделить
  b-attr-copy   копировать атрибуты фирмы
  b-attr-update изменять атрибуты фирмы

todo удалить опцию convert и переделать все вызовы на использование только Кодов фирм


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc    as widget-handle no-undo.
define input  parameter bttns            as character no-undo .
define input  parameter p-lock-self-host as logical   no-undo .
define input  parameter p-curr-host-code as integer   no-undo .
define output parameter p-out-host-code  as integer   no-undo .
define input-output parameter p-rid-list as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список фирм системы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/thbjattr.i }
{ adm/shattrg.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/colwidth.i }
{ cmp/mrk-strf.i }

&scop purchase-code string(X_sysconf.purch-code)

define variable v-default-object as character no-undo format "X(9)" .
define variable v-rid-list         as character no-undo .
define variable v-host-name        as character no-undo .
define variable v-curr-name        as character no-undo .
define variable v-doc-rec          as recid     no-undo .
define variable attr-option        as character no-undo .
define variable v-object-available as character no-undo .
define variable v-host-available   as character no-undo .
DEFINE VARIABLE lkp-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE upd-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE is-fin AS CHARACTER NO-UNDO.
DEFINE VARIABLE is-fin-type AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-obj

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_clients X_sysconf

/* Definitions for BROWSE BR-obj                                        */
&Scoped-define FIELDS-IN-QUERY-BR-obj X_clients.obj-type X_clients.obj-code ~
X_clients.obj-name X_clients.db-num ~
get-object-available(X_clients.obj-type, X_clients.obj-code) @ v-object-available 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-obj 
&Scoped-define QUERY-STRING-BR-obj FOR EACH X_clients ~
      WHERE X_clients.host-code = X_sysconf.host-code and X_clients.host-code > 0 NO-LOCK ~
    BY X_clients.obj-type ~
       BY X_clients.obj-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-obj OPEN QUERY BR-obj FOR EACH X_clients ~
      WHERE X_clients.host-code = X_sysconf.host-code and X_clients.host-code > 0 NO-LOCK ~
    BY X_clients.obj-type ~
       BY X_clients.obj-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-obj X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-BR-obj X_clients


/* Definitions for BROWSE BR-sysconf                                    */
&Scoped-define FIELDS-IN-QUERY-BR-sysconf ~
mark-string(recid(X_sysconf), v-rid-list) X_sysconf.host-code ~
get-host-name(X_sysconf.host-code) @ v-host-name X_sysconf.branch ~
X_sysconf.base-code X_sysconf.firm-db-num ~
get-curr-name(X_sysconf.base-code) @ v-curr-name ~
{&purchase-input-codes-name} ~
get-default-object(X_sysconf.host-code) @ v-default-object ~
get-host-available(X_sysconf.host-code) @ v-host-available 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-sysconf 
&Scoped-define QUERY-STRING-BR-sysconf FOR EACH X_sysconf NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-sysconf OPEN QUERY BR-sysconf FOR EACH X_sysconf NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-sysconf X_sysconf
&Scoped-define FIRST-TABLE-IN-QUERY-BR-sysconf X_sysconf


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-obj}~
    ~{&OPEN-QUERY-BR-sysconf}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel b-add b-lkp b-chg B-attr ~
b-obj-init B-hist B-Help BR-sysconf B-obj BR-obj mark-num ~
fi-object-list-description 
&Scoped-Define DISPLAYED-OBJECTS mark-num fi-object-list-description 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-curr-name Dialog-Frame 
FUNCTION get-curr-name RETURNS CHARACTER
  ( input p-curr-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-default-object Dialog-Frame 
FUNCTION get-default-object RETURNS CHARACTER
  ( input p-host-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-host-available Dialog-Frame 
FUNCTION get-host-available RETURNS CHARACTER
  ( INPUT p-host-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-host-name Dialog-Frame 
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-object-available Dialog-Frame 
FUNCTION get-object-available RETURNS CHARACTER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-attr 
       MENU-ITEM m_lookup       LABEL "&Просмотр"     
       MENU-ITEM m_update       LABEL "&Изменение"    
       MENU-ITEM m_copy         LABEL "&Копирование"  .

DEFINE MENU MENU-b-chg 
       MENU-ITEM m_upd-firm     LABEL "Организация"   
       MENU-ITEM m_upd-sysconf  LABEL "СВОЯ Фирма"    
       MENU-ITEM m_upd-fin      LABEL "Параметры ВЗАИМОРАСЧЕТОВ и ФИНАНСОВЫХ ДОКУМЕНТОВ".

DEFINE MENU MENU-B-lkp 
       MENU-ITEM m_firm         LABEL "Организация"   
       MENU-ITEM m_sysconf      LABEL "СВОЯ Фирма"    
       MENU-ITEM m_fin          LABEL "Параметры ВЗАИМОРАСЧЕТОВ и ФИНАНСОВЫХ ДОКУМЕНТОВ".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-attr 
     LABEL "&Параметры" 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON b-lkp 
     LABEL "&Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON B-obj 
     LABEL "Просмотр" 
     SIZE 10 BY 1.

DEFINE BUTTON b-obj-init 
     LABEL "Для объектов" 
     SIZE 15 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "В&ыбор" 
     SIZE 10 BY 1.

DEFINE VARIABLE fi-object-list-description AS CHARACTER FORMAT "X(256)":U 
     LABEL "Объекты фирмы" 
      VIEW-AS TEXT 
     SIZE 61 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-obj FOR 
      X_clients SCROLLING.

DEFINE QUERY BR-sysconf FOR 
      X_sysconf SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-obj Dialog-Frame _STRUCTURED
  QUERY BR-obj NO-LOCK DISPLAY
      X_clients.obj-type FORMAT "X(3)":U
      X_clients.obj-code FORMAT ">>>>>>>>9":U
      X_clients.obj-name FORMAT "X(40)":U
      X_clients.db-num FORMAT ">>>>>>>>9":U
      get-object-available(X_clients.obj-type, X_clients.obj-code) @ v-object-available COLUMN-LABEL "Доступен для тек.пользователя" FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.52.

DEFINE BROWSE BR-sysconf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-sysconf Dialog-Frame _STRUCTURED
  QUERY BR-sysconf NO-LOCK DISPLAY
      mark-string(recid(X_sysconf), v-rid-list) FORMAT "X(1)":U
      X_sysconf.host-code FORMAT "999999999":U
      get-host-name(X_sysconf.host-code) @ v-host-name COLUMN-LABEL "Название" FORMAT "X(40)":U
      X_sysconf.branch FORMAT "X(40)":U
      X_sysconf.base-code COLUMN-LABEL "Код!валюты"
      X_sysconf.firm-db-num COLUMN-LABEL "Главная!БД"
      get-curr-name(X_sysconf.base-code) @ v-curr-name COLUMN-LABEL "Валюта" FORMAT "X(3)":U
      {&purchase-input-codes-name} COLUMN-LABEL "Тип!приобретения" FORMAT "X(12)":U
      get-default-object(X_sysconf.host-code) @ v-default-object COLUMN-LABEL "Главн.объект!межфирм.перем."
      get-host-available(X_sysconf.host-code) @ v-host-available COLUMN-LABEL "Доступна!для текущего пользователя" FORMAT "x(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.81.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     b-add AT ROW 1 COL 31 WIDGET-ID 2
     b-lkp AT ROW 1 COL 41
     b-chg AT ROW 1 COL 51 WIDGET-ID 4
     B-attr AT ROW 1 COL 61
     b-obj-init AT ROW 1 COL 71 WIDGET-ID 6
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-sysconf AT ROW 2.43 COL 1
     B-obj AT ROW 11.43 COL 80
     BR-obj AT ROW 12.48 COL 1
     mark-num AT ROW 1 COL 12.6 COLON-ALIGNED NO-LABEL
     fi-object-list-description AT ROW 11.52 COL 17.2 COLON-ALIGNED
     SPACE(22.37) SKIP(9.84)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Список <Своих> фирм системы"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: find_sysconf B "?" ? ub sysconf
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_curr-sysconf B "?" NO-UNDO ub sysconf
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-sysconf B-Help Dialog-Frame */
/* BROWSE-TAB BR-obj B-obj Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       B-attr:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-attr:HANDLE.

ASSIGN 
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-chg:HANDLE.

ASSIGN 
       b-lkp:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-lkp:HANDLE.

ASSIGN 
       BR-sysconf:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-obj
/* Query rebuild information for BROWSE BR-obj
     _TblList          = "X_clients"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "X_clients.obj-type|yes,X_clients.obj-code|yes"
     _Where[1]         = "X_clients.host-code = X_sysconf.host-code and X_clients.host-code > 0"
     _FldNameList[1]   = Temp-Tables.X_clients.obj-type
     _FldNameList[2]   = Temp-Tables.X_clients.obj-code
     _FldNameList[3]   = Temp-Tables.X_clients.obj-name
     _FldNameList[4]   = Temp-Tables.X_clients.db-num
     _FldNameList[5]   > "_<CALC>"
"get-object-available(X_clients.obj-type, X_clients.obj-code) @ v-object-available" "Доступен для тек.пользователя" "X(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-obj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-sysconf
/* Query rebuild information for BROWSE BR-sysconf
     _TblList          = "X_sysconf"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-string(recid(X_sysconf), v-rid-list)" ? "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"X_sysconf.host-code" ? "9999999" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"get-host-name(X_sysconf.host-code) @ v-host-name" "Название" "X(40)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"X_sysconf.branch" ? "X(40)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"X_sysconf.base-code" "Код!валюты" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"X_sysconf.firm-db-num" "Главная!БД" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"get-curr-name(X_sysconf.base-code) @ v-curr-name" "Валюта" "X(3)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > "_<CALC>"
"{&purchase-input-codes-name}" "Тип!приобретения" "X(12)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   > "_<CALC>"
"get-default-object(X_sysconf.host-code) @ v-default-object" "Главн.объект!межфирм.перем." ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[10]   > "_<CALC>"
"get-host-available(X_sysconf.host-code) @ v-host-available" "Доступна!для текущего пользователя" "x(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE BR-sysconf */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Список <Своих> фирм системы */
DO:
  if ( available X_sysconf )
  then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then do:
      assign
        v-rid-list = string( recid( X_sysconf ) )
        p-out-host-code = X_sysconf.host-code
      .
    end.
    ASSIGN
    p-rid-list = v-rid-list.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список <Своих> фирм системы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-attr Dialog-Frame
ON CHOOSE OF B-attr IN FRAME Dialog-Frame /* Параметры */
DO:
  if not available X_sysconf then return no-apply.
  if attr-option = '':U
  then do:
    run gbl/pop-up.p
      (input  self:handle
      ,input  no
      ) no-error .
  end.
  if attr-option = '':U
  then do:
     return no-apply.
  end.
  run proc-b-attr in this-procedure
    (input  attr-option
    ,input  {&cmp}
    ,input  x_sysconf.host-code
    ) no-error.
  if error-status:error
  then do:
    assign
      attr-option = '':U
    .
    return no-apply.
  end.
  assign
    attr-option = '':U
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  IF NOT AVAILABLE X_sysconf THEN RETURN NO-APPLY.
  if upd-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if upd-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-chg IN THIS-PROCEDURE ( input upd-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-loc-rid-list as character no-undo .
  if available X_sysconf
  then do:
    run ref/cclihist.w
      (input  parparentproc       /* parparentproc      */
      ,input  0                   /* p-curr-host-code   */
      ,input  '':U                /* p-curr-obj-type    */
      ,input  0                   /* p-curr-obj-code    */
      ,input  '':U                /* bttns              */
      ,input  'one':U             /* p-mode             */
      ,input  {&cmp}              /* p-obj-type         */
      ,input  X_sysconf.host-code /* p-obj-code         */
      ,input  ?                   /* p-host-code        */
      ,input  ?                   /* p-corr-user-db-num */
      ,input  '':U                /* p-corr-user-name   */
      ,input  '':U                /* p-subject          */
      ,input  g#db-num            /* p-db-num           */
      ,input-output v-loc-rid-list    /* p-rid-list         */
      ) no-error .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  DEFINE variable v-rec as recid no-undo.
  if not available X_sysconf
  then do:
    return no-apply.
  end.
  if lkp-option = '':U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status:error then do: return no-apply. end.
    if lkp-option = '':U then return no-apply.
    run proc-b-lkp in this-procedure ( input lkp-option) no-error.
    if error-status:error then do:
      lkp-option = '':U.
      return no-apply.
    end.
    lkp-option = '':U.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable loc#log as logical no-undo .
&scop seq {&sequence}
define variable v-num-entry{&seq} as integer no-undo .
if not available X_sysconf then return no-apply.
assign
  v-num-entry{&seq} = lookup(string( recid(X_sysconf) ), v-rid-list )
.
if v-num-entry{&seq} > 0
then do:
  if p-lock-self-host = yes and X_sysconf.host-code = X_curr-sysconf.host-code
  then do:
    message
      "Своя фирма уже выбрана - ее нельзя убрать из списка!"
      view-as alert-box warning.
    return no-apply.
  end.
  assign
    entry(v-num-entry{&seq}, v-rid-list) = '':U
    v-rid-list = replace( v-rid-list, {&comma-char} + {&comma-char}, {&comma-char})
  .
end.
else do:
  assign
    v-rid-list = v-rid-list
               + ( if v-rid-list = '':U
                   then '':U
                   else {&comma-char}
                 )
               + string( recid( X_sysconf) )
  .
end.
loc#log = br-sysconf:refresh() .

if last-event:function <> "MOUSE-SELECT-DBLCLICK"
then do:
  assign
    loc#log = br-sysconf:select-next-row()
  .
  run update-br-sysconf-dependent in this-procedure .
end.
if num-entries( v-rid-list ) = 0
then
    hide mark-num in frame {&frame-name}.
else
    disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
apply "entry" to br-sysconf in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-obj Dialog-Frame
ON CHOOSE OF B-obj IN FRAME Dialog-Frame /* Просмотр */
DO:
  run br-obj-show-object in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-obj-init
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-obj-init Dialog-Frame
ON CHOOSE OF b-obj-init IN FRAME Dialog-Frame /* Для объектов */
DO:
  IF NOT AVAILABLE  X_sysconf THEN RETURN NO-APPLY.
  run adm/obj-init.w ( input parparentproc
                     , INPUT X_sysconf.host-code) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  assign
  p-out-host-code =  ?
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-obj
&Scoped-define SELF-NAME BR-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-obj Dialog-Frame
ON DEFAULT-ACTION OF BR-obj IN FRAME Dialog-Frame
DO:
  run br-obj-show-object in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-sysconf
&Scoped-define SELF-NAME BR-sysconf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-sysconf Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-sysconf IN FRAME Dialog-Frame
DO:
   run br-mouse-select in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-sysconf Dialog-Frame
ON RETURN OF BR-sysconf IN FRAME Dialog-Frame
DO:
    run br-return in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-sysconf Dialog-Frame
ON VALUE-CHANGED OF BR-sysconf IN FRAME Dialog-Frame
DO:
  run update-br-sysconf-dependent in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_copy Dialog-Frame
ON CHOOSE OF MENU-ITEM m_copy /* Копирование */
DO:
  assign
    attr-option = {&add-copy}
  .
  apply "choose" to b-attr  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_fin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_fin Dialog-Frame
ON CHOOSE OF MENU-ITEM m_fin /* Параметры ВЗАИМОРАСЧЕТОВ и ФИНАНСОВЫХ ДОКУМЕНТОВ */
DO:
    if not available X_sysconf
    then do:
      return no-apply.
    end.
     ASSIGN
     lkp-option = "fin".
     run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
     ASSIGN
     lkp-option = '':U.
     IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_firm Dialog-Frame
ON CHOOSE OF MENU-ITEM m_firm /* Организация */
DO:
  if not available X_sysconf
  then do:
    return no-apply.
  end.
   ASSIGN
   lkp-option = {&table_firm}.
   run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
   ASSIGN
   lkp-option = '':U.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup Dialog-Frame
ON CHOOSE OF MENU-ITEM m_lookup /* Просмотр */
DO:
  assign
    attr-option = {&lookup}
  .
  apply "choose" to b-attr  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_sysconf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_sysconf Dialog-Frame
ON CHOOSE OF MENU-ITEM m_sysconf /* СВОЯ Фирма */
DO:
  if not available X_sysconf
  then do:
    return no-apply.
  end.
   ASSIGN
   lkp-option = {&table_sysconf}.
   run proc-b-lkp IN THIS-PROCEDURE ( INPUT lkp-option) NO-ERROR.
   ASSIGN
   lkp-option = '':U.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_upd-fin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_upd-fin Dialog-Frame
ON CHOOSE OF MENU-ITEM m_upd-fin /* Параметры ВЗАИМОРАСЧЕТОВ и ФИНАНСОВЫХ ДОКУМЕНТОВ */
DO:
  if not available X_sysconf
    then do:
      return no-apply.
    end.
     ASSIGN
     upd-option = "fin".
     run proc-b-chg IN THIS-PROCEDURE ( INPUT upd-option) NO-ERROR.
     ASSIGN
     upd-option = '':U.
     IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_upd-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_upd-firm Dialog-Frame
ON CHOOSE OF MENU-ITEM m_upd-firm /* Организация */
DO:
    if not available X_sysconf
    then do:
      return no-apply.
    end.
     ASSIGN
     upd-option = {&table_firm}.
     run proc-b-chg IN THIS-PROCEDURE ( INPUT upd-option) NO-ERROR.
     ASSIGN
     upd-option = '':U.
     IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_upd-sysconf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_upd-sysconf Dialog-Frame
ON CHOOSE OF MENU-ITEM m_upd-sysconf /* СВОЯ Фирма */
DO:
  if not available X_sysconf
  then do:
    return no-apply.
  end.
  ASSIGN
  upd-option = {&table_sysconf}.
  run proc-b-chg IN THIS-PROCEDURE ( INPUT upd-option) NO-ERROR.
  ASSIGN
  upd-option = '':U.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update Dialog-Frame
ON CHOOSE OF MENU-ITEM m_update /* Изменение */
DO:
    assign
  attr-option = {&UPDATE}.
  APPLY "CHOOSE" to b-attr  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-obj
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }

{ gbl/getcntxt.i get }

{ gbl/app_help.i
  &disable_diasize=true
}

{ gbl/diasize.i
  &browse-name="br-sysconf"
}

run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-obj :handle
  ) .
run diasize_init in this-procedure .


p-out-host-code = ? .
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:
  find first X_curr-sysconf no-lock
    where X_curr-sysconf.host-code = p-curr-host-code
    no-error .
  if not available X_curr-sysconf
  and p-lock-self-host = yes
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-curr-host-code и p-lock-seld-host"
      p-curr-host-code skip
      view-as alert-box error.
    undo, return error return-value .
  end.
  v-rid-list = p-rid-list.
  assign
    v-host-name        :resizable in browse br-sysconf = true
    x_sysconf.branch   :resizable in browse br-sysconf = true
    x_clients.obj-name :resizable in browse br-obj     = true
  .

  define variable v-colwidth-data-exist as logical   no-undo .

  { gbl/colw_rd.i
    v-cntxt-db-num
    v-cntxt-userid
    'adm/sconfs.w':U
    v-colwidth-data-exist
  }
  if v-colwidth-data-exist = true
  then do:
    assign
      v-host-name        :width in browse br-sysconf = v-colwidth-width-01
      x_sysconf.branch   :width in browse br-sysconf = v-colwidth-width-02
      x_clients.obj-name :width in browse br-obj     = v-colwidth-width-03
    .
  end.
  else do:
    assign
      v-host-name        :width in browse br-sysconf = 25
      x_sysconf.branch   :width in browse br-sysconf = 25
      x_clients.obj-name :width in browse br-obj     = 25
    .
  end.

  run myenable in this-procedure .
  wait-for go of frame {&frame-name}.
  if lookup('convert':u, bttns) > 0
  then do:
    run convert in this-procedure
      (input 'out':u
      ) no-error .
  end.
END.

assign
  v-colwidth-width-01 = v-host-name        :width in browse br-sysconf
  v-colwidth-width-02 = x_sysconf.branch   :width in browse br-sysconf
  v-colwidth-width-03 = x_clients.obj-name :width in browse br-obj
.

{ gbl/colw_wr.i }


RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE br-mouse-select Dialog-Frame 
PROCEDURE br-mouse-select :
if b-sel:sensitive in frame {&frame-name} then do:
  if b-mark:sensitive then do:
      apply "choose" to b-mark in frame {&frame-name}.
  end.
  else do:
      apply "choose" to b-sel in frame {&frame-name}.
  end.
end.
else do:
  if b-lkp:sensitive then
      apply "choose" to b-lkp in frame {&frame-name}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE br-obj-show-object Dialog-Frame 
PROCEDURE br-obj-show-object :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    if available x_clients
    then do:
      run ref/showcli.p
        (input parparentproc
        ,input x_clients.obj-type
        ,input x_clients.obj-code
        ) no-error.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE br-return Dialog-Frame 
PROCEDURE br-return :
if b-sel:sensitive in frame {&frame-name} then do:
    apply "choose" to b-sel in frame {&frame-name}.
end.
else do:
    if b-lkp:sensitive then
        apply "choose" to b-lkp in frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE convert Dialog-Frame 
PROCEDURE convert :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-convert-mode as character no-undo.

  define variable v-list as character no-undo .
  define variable v-ind  as integer   no-undo .

  define buffer buf_sysconf for ub.sysconf.

  do
  on error undo, return error return-value
  :
    case p-convert-mode
    :
      when 'in':U
      then do:
        do v-ind = 1 to num-entries(v-rid-list)
        :
          find first buf_sysconf no-lock
            where buf_sysconf.host-code = integer(entry(v-ind, v-rid-list))
            no-error.
          if available buf_sysconf
          then do:
            assign
              v-list = v-list
                     + (if v-list = '':U
                        then '':U
                        else {&comma-char}
                       )
                     + string(recid(buf_sysconf))
            .
          end.
        end.
      end.
      when 'out':U
      then do:
        do v-ind = 1 to num-entries(v-rid-list)
        :
          find first buf_sysconf no-lock
            where recid(buf_sysconf) = integer(entry(v-ind, v-rid-list))
            no-error .
          if available buf_sysconf
          then do:
            assign
              v-list = v-list
                      + (if v-list = '':U
                        then '':U
                        else {&comma-char}
                        )
                      + string(buf_sysconf.host-code)
            .
          end.
        end.
      end.
    end case.

    assign
      v-rid-list = v-list
    .
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
  DISPLAY mark-num fi-object-list-description 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-add b-lkp b-chg B-attr b-obj-init B-hist B-Help 
         BR-sysconf B-obj BR-obj mark-num fi-object-list-description 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-available-proc Dialog-Frame 
PROCEDURE get-host-available-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define input  parameter p-host-code      as integer   no-undo .
  define output parameter p-available-host as character no-undo .

  define variable v-host-available as logical   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/ushstava.i
      v-cntxt-db-num
      {&action-head-code-main}
      v-cntxt-userid
      p-host-code
      v-host-available
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/ushstava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-host-available = true
    then do:
      assign
        p-available-host = "доступна"
      .
    end.
    else do:
      assign
        p-available-host = '':U
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name-proc Dialog-Frame 
PROCEDURE get-host-name-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-host-code as integer   no-undo .
  define output parameter p-host-name as character no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = p-host-code
      no-error .
    if available buf_clients
    then do:
      assign
        p-host-name = (if buf_clients.stts = 0
                       then buf_clients.obj-name
                       else (substring (buf_clients.obj-name, 1, 20)
                            + fill (" " , 20 - length (substring (buf_clients.obj-name, 1, 20)))
                            + {&deleted-stat_}
                            )
                      )
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-object-available-proc Dialog-Frame 
PROCEDURE get-object-available-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type                 as character no-undo .
  define input  parameter p-obj-code                 as integer   no-undo .
  define output parameter p-available-object-message as character no-undo .

  define variable v-object-available as logical   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/usobjava.i
      v-cntxt-db-num
      {&action-head-code-main}
      v-cntxt-userid
      p-obj-type
      p-obj-code
      v-object-available
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if v-object-available = true
    then do:
      assign
        p-available-object-message = "доступен"
      .
    end.
    else do:
      assign
        p-available-object-message = '':U
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE host-default-object Dialog-Frame 
PROCEDURE host-default-object :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

   define input parameter p-host-code as integer no-undo .
   define output parameter p-obj-type as character no-undo .
   define output parameter p-obj-code as integer no-undo .

   define buffer buf_firm for ub.firm .

   find first buf_firm no-lock
     where buf_firm.firm-code = p-host-code
     no-error .
   if available buf_firm then do:
     assign
       p-obj-type = main-obj-type
       p-obj-code = main-obj-code
     .
   end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
do
on error undo, return error return-value
:

  /* есть ли арм взаиморасчетов */
  { gbl/conf-rd.i
  "'is-fin'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  is-fin
  is-fin-type
  no-error }

  if lookup('convert':U, bttns) > 0
  then do:
    run convert in this-procedure
      (input 'in':U
      ) no-error.
  end.
  if p-lock-self-host
  then do:
    if lookup(string(recid(X_curr-sysconf)), v-rid-list) = 0
    then do:
      assign
        v-rid-list = (if v-rid-list = '':U
                      then string(recid(X_curr-sysconf))
                      else (string(recid(X_curr-sysconf))  + {&comma-char} + v-rid-list)
                    )
      .
    end.
  end.
  if v-rid-list <> ""
  then do:
    find first find_sysconf no-lock
      where recid(find_sysconf) = integer(entry(1, v-rid-list))
      no-error.
    if not avail find_sysconf
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова v-rid-list" v-rid-list
      view-as alert-box error .
      return error.
    end.
    assign
      v-doc-rec = integer(entry(1, v-rid-list))
    .
  end.
  assign
  b-attr:MENU-MOUSE in frame {&frame-name} = 1
  b-lkp:MENU-MOUSE in frame {&frame-name} = 1
  b-chg:MENU-MOUSE in frame {&frame-name} = 1
 .

  assign
  menu-item m_update :sensitive in menu menu-b-attr = (g#db-num = 0
                                                      and lookup('b-attr-update':U, bttns) > 0
                                                      )
  menu-item m_copy   :sensitive in menu menu-b-attr = (g#db-num = 0
                                                      and lookup('b-attr-copy':U, bttns) > 0
                                                      )
  menu-item m_lookup :sensitive in menu menu-b-attr = true
  menu-item m_upd-fin:sensitive in menu menu-b-chg = g#db-num = 0
  menu-item m_fin:sensitive in menu menu-b-lkp = yes
  menu-item m_upd-firm:sensitive in menu menu-b-chg = (g#db-num = 0)
  menu-item m_upd-sysconf:sensitive in menu menu-b-chg = (g#db-num = 0)
  .
  enable
  b-quit
  b-sel  when lookup('b-sel':u, bttns)  > 0
  b-mark when lookup('b-mark':u, bttns) > 0
  b-attr
  b-lkp
  b-ADD when lookup('b-add':u, bttns) > 0 AND v-cntxt-db-num = 0 AND NOT TRANSACTION
  b-chg when lookup('b-add':u, bttns) > 0 AND v-cntxt-db-num = 0 AND NOT TRANSACTION
  b-help
  br-sysconf
  br-obj
  b-obj
  b-hist
  b-obj-init when NOT TRANSACTION
  with frame {&frame-name}.
  view frame {&frame-name}.
  hide
  mark-num
  in frame {&frame-name} .
  RUN Openbr IN THIS-PROCEDURE NO-ERROR.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame 
PROCEDURE Openbr :
{&OPEN-QUERY-BR-sysconf}

  if available X_sysconf
  then do:
    {&OPEN-QUERY-BR-obj}
  end.
  if v-doc-rec <> ?
  then do:
    reposition br-sysconf to recid v-doc-rec no-error.
  end.
  apply 'entry':U to br-sysconf in frame {&frame-name} .
  run update-br-sysconf-dependent in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
define variable v-ok as logical no-undo .
{ gbl/user-adm.i
  v-cntxt-db-num
  v-cntxt-userid
  v-ok
}
if not v-ok then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    "'actn_admin':U"
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
end.

run adm/config.w ( input parparentproc
                  ,input 0
                  ,input {&add-def}
                  ,input no ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN UNDO , RETURN ERROR.
RUN Openbr IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame 
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-upd-subject AS CHARACTER NO-UNDO.
define variable v-host-code as integer   no-undo .
define variable v-ok as logical no-undo .
define variable v-recid as recid no-undo .
define buffer buf_clients for ub.clients.
do
on error undo, return error return-value
:

v-doc-rec = recid(X_sysconf).
{ gbl/user-adm.i
  v-cntxt-db-num
  v-cntxt-userid
  v-ok
}
if not v-ok then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    "'actn_admin':U"
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    v-ok
  }
end.
if lookup(v-cntxt-level, {&cntxt-firm} + {&comma-char} + {&cntxt-object}) > 0
then do:
    IF X_sysconf.host-code <> v-cntxt-host-code-obj THEN DO:
      MESSAGE
      "Изменять можно только текущую фирму"
      VIEW-AS alert-box ERROR.
      UNDO, RETURN ERROR.
    END.
end.
else do:
  message
    "Не выбрана текущая фирма" skip
    view-as alert-box error .
end.
end.
CASE p-upd-subject:
  WHEN {&TABLE_firm} THEN DO:
    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = X_sysconf.host-code
      no-error .
    if not available buf_clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Не найдена фирма с кодом &1", X_sysconf.host-code) skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_client-reference_update':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok <> true
    then do:
      undo, return error.
    end.
    v-recid = recid(buf_clients).
    run ref/firmi.w
      (input  parparentproc
      ,input  {&update}
      ,input  buf_clients.obj-code
      ,input  buf_clients.grp-code
      ,input  {&table_sysconf}
      ,input-output v-recid
      ) no-error .
  END.
  WHEN {&TABLE_sysconf}
  or
  when "fin"
  THEN DO:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_host-reference_lookup':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok <> true
    then do:
      return no-apply.
    end.
    if p-upd-subject = {&table_sysconf} then do:
      run adm/config.w
        (input  parParentProc
        ,input  v-cntxt-host-code-obj
        ,input  {&update}
        ,input  no /*p-is-deploy*/
        ) no-error.
      if error-status :error
      then do:
        return no-apply.
      end.
    end.
    else do:
      run adm/fin-def.w ( input parParentProc
                        , input {&update}
                        , input X_sysconf.host-code
                        , input (is-fin = "yes")
                         ) no-error.
    end.
  END.
END CASE.
RUN Openbr IN THIS-PROCEDURE NO-ERROR.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame 
PROCEDURE proc-b-lkp :
DEFINE INPUT PARAMETER p-lkp-subject AS CHARACTER NO-UNDO.
define variable v-ok    as logical   no-undo .
define variable v-recid as recid     no-undo .
define buffer buf_clients for ub.clients .
v-doc-rec = recid(X_sysconf).
CASE p-lkp-subject:
  WHEN {&TABLE_firm} THEN DO:
    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
        and buf_clients.obj-code = X_sysconf.host-code
      no-error .
    if not available buf_clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Не найдена фирма с кодом &1", X_sysconf.host-code) skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_client-reference_lookup':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok <> true
    then do:
      undo, return error.
    end.
    v-recid = recid(buf_clients).
    run ref/firmi.w
      (input  parparentproc
      ,input  {&lookup}
      ,input  buf_clients.obj-code
      ,input  buf_clients.grp-code
      ,input  {&table_sysconf}
      ,input-output v-recid
      ) no-error .
  END.
  WHEN {&TABLE_sysconf}
  or when "fin"
  THEN DO:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      "'actn_host-reference_lookup':U"
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      v-ok
    }
    if v-ok <> true
    then do:
      return no-apply.
    end.
    if p-lkp-subject = {&table_sysconf} then do:
      run adm/config.w
        (input  parParentProc
        ,input  X_sysconf.host-code
        ,input  {&lookup}
        ,input  no /*p-is-deploy*/
        ) no-error.
    end.
    else do:
      run adm/fin-def.w ( input parParentProc
                        , input {&lookup}
                        , input X_sysconf.host-code
                        , input (is-fin = "yes")
                         ) no-error.
    end.
  END.
END CASE.
if error-status :error
then do:
  return no-apply.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-br-sysconf-dependent Dialog-Frame 
PROCEDURE update-br-sysconf-dependent :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if available ub.clients
      then do:
        assign
          fi-object-list-description :screen-value = ub.clients.obj-name
        .
      end.
      else do:
        assign
          fi-object-list-description :screen-value = '':U
        .
      end.
    end.
    {&OPEN-QUERY-br-obj}
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-curr-name Dialog-Frame 
FUNCTION get-curr-name RETURNS CHARACTER
  ( input p-curr-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    find first ub.currency no-lock
      where ub.currency.curr-code = p-curr-code
      no-error .
    if available ub.currency
    then do:
      return ub.currency.curr-abbr.
    end.
    else do:
      return {&question-mark}.
    end.
  end.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-default-object Dialog-Frame 
FUNCTION get-default-object RETURNS CHARACTER
  ( input p-host-code as integer ) :

  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer no-undo .

  run host-default-object
    (input p-host-code
    ,output v-obj-type
    ,output v-obj-code
    ) .
  if v-obj-type <> ""
  then do:
    return substitute('&1 &2':u, v-obj-type, v-obj-code) .
  end.
  else do:
    return "" .
  end.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-host-available Dialog-Frame 
FUNCTION get-host-available RETURNS CHARACTER
  ( INPUT p-host-code AS integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-available-host as character no-undo .
  run get-host-available-proc in this-procedure
    (input p-host-code
    ,output v-available-host
    ) .
  return v-available-host .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-host-name Dialog-Frame 
FUNCTION get-host-name RETURNS CHARACTER
  ( INPUT p-host-code AS integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-host-name as character no-undo .
  run get-host-name-proc in this-procedure
    (input  p-host-code
    ,output v-host-name
    ) .
  return v-host-name .


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-object-available Dialog-Frame 
FUNCTION get-object-available RETURNS CHARACTER
  ( INPUT p-obj-type AS CHARACTER, INPUT p-obj-code AS integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  define variable v-available-object as character no-undo .
  run get-object-available-proc in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,output v-available-object
    ) .
  return v-available-object .

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

