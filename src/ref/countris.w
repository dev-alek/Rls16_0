&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_country FOR ub.country.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Классификатор стран

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/16/05
Author: Bakhtadze Natalya
Creation date: 11/16/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input  parameter bttns    as character no-undo .
define input-output parameter p-rid-list  as character    no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник стран".
{ cmp/vssrevis.i "substitute('&1',bttns)" }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
{ ref/cntrlist.i cntrlist def "new shared "}
{ cmp/mrk-strf.i }
define variable v-country-recid as recid  no-undo .
define variable v-rec           as recid no-undo .
DEFINE VARIABLE rum-option AS CHARACTER NO-UNDO.
define buffer buf_country for country.
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-countries

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_country

/* Definitions for BROWSE BR-countries                                  */
&Scoped-define FIELDS-IN-QUERY-BR-countries mark-string(recid(X_country), v-rid-list) X_country.alpha1 X_country.alpha2 X_country.short-name X_country.long-name X_country.num-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-countries
&Scoped-define SELF-NAME BR-countries
&Scoped-define QUERY-STRING-BR-countries FOR EACH X_country NO-LOCK     BY X_country.short-name
&Scoped-define OPEN-QUERY-BR-countries OPEN QUERY {&SELF-NAME} FOR EACH X_country NO-LOCK     BY X_country.short-name.
&Scoped-define TABLES-IN-QUERY-BR-countries X_country
&Scoped-define FIRST-TABLE-IN-QUERY-BR-countries X_country


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-countries}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-mark B-sel B-add B-chg t-pck B-rum ~
B-hist B-help a-n-c BR-countries loc-alpha-1 mark-num
&Scoped-Define DISPLAYED-OBJECTS t-pck a-n-c mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-rum
       MENU-ITEM m_xml-file-export LABEL "Экспорт в XML-файл"
       MENU-ITEM m_batchwork-routing LABEL "Маршрутизация в ВС".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-rum
     LABEL "&Операции"
     SIZE 10 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "&Вы&бор "
     SIZE 10 BY 1.

DEFINE VARIABLE loc-alpha-1 AS CHARACTER FORMAT "X(2)":U
     LABEL "Букв. код. 1"
      VIEW-AS TEXT
     SIZE 3.9 BY .67
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(40)":U
     LABEL "Назв."
     VIEW-AS FILL-IN
     SIZE 30.4 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Букв. код 1", "alpha1",
"Назв.", "name"
     SIZE 23.3 BY 1 NO-UNDO.

DEFINE VARIABLE t-pck AS LOGICAL INITIAL no
     LABEL "Пктн.рж"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-countries FOR
      X_country SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-countries
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-countries Dialog-Frame _FREEFORM
  QUERY BR-countries DISPLAY
      mark-string(recid(X_country), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_country.alpha1 COLUMN-LABEL "Код!страны-1" FORMAT "X(2)":U
      X_country.alpha2 COLUMN-LABEL "Код!страны-2" FORMAT "X(3)":U
      X_country.short-name FORMAT "X(25)":U
      X_country.long-name FORMAT "X(40)":U
      X_country.num-code COLUMN-LABEL "Цифр!код" FORMAT "999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90.4 BY 20.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 6
     B-sel AT ROW 1 COL 14
     B-add AT ROW 1 COL 24
     B-chg AT ROW 1 COL 34
     t-pck AT ROW 1 COL 48 WIDGET-ID 10
     B-rum AT ROW 1 COL 61 WIDGET-ID 4
     B-hist AT ROW 1 COL 85
     B-help AT ROW 1 COL 88
     a-n-c AT ROW 2 COL 10 NO-LABEL
     loc-name AT ROW 2 COL 60 COLON-ALIGNED
     BR-countries AT ROW 3.5 COL 1
     loc-alpha-1 AT ROW 2 COL 49 COLON-ALIGNED
     mark-num AT ROW 2.07 COL 1 NO-LABEL WIDGET-ID 8
     SPACE(85.49) SKIP(20.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Классификатор стран"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_country B "?" ? ub country
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-countries loc-name Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-rum:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rum:HANDLE.

/* SETTINGS FOR FILL-IN loc-alpha-1 IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
/* SETTINGS FOR FILL-IN loc-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       loc-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-countries
/* Query rebuild information for BROWSE BR-countries
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_country NO-LOCK
    BY X_country.short-name.
     _END_FREEFORM
     _OrdList          = "ub.country.short-name|yes"
     _Query            is OPENED
*/  /* BROWSE BR-countries */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Классификатор стран */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Классификатор стран */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME a-n-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL a-n-c Dialog-Frame
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
  case input frame {&frame-name} a-n-c :
    when "alpha1" then do:
      apply "entry" to br-countries in frame {&frame-name}.
      hide loc-name in frame {&frame-name}.
      loc-alpha-1 = "".
    end.
    when "name" then do:
      enable loc-name with frame {&frame-name}.
      disp loc-name with frame {&frame-name}.
      hide loc-alpha-1 in frame {&frame-name}.
      apply "entry" to loc-name in frame {&frame-name}.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  define variable v-ok as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_country-reference_work':U
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
    undo, return no-apply .
  end.
  if not ( g#db-num > 0 )
  then do:
    run ref/country.w
      (input parparentproc
      ,input        {&add-def}
      ,input 0
      ,input-output v-country-recid
      ).
    if v-country-recid <> ?
    then do:
      {&open-query-br-countries}
      reposition br-countries to recid v-country-recid .
      v-ok = br-countries:select-focused-row( ).
      apply "ENTRY":U to br-countries.
      apply "VALUE-CHANGED":U to br-countries.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_country-reference_work':U
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
    undo, return no-apply .
  end.

  if not available X_country
  then do:
    return no-apply.
  end.
  assign
    v-country-recid = recid( X_country )
  .

  if NOT ( g#db-num > 0 ) then do:
    run ref/country.w
      (input parparentproc
      ,input        {&update}
      ,input X_country.alpha1
      ,input-output v-country-recid
      ).
  end.

  DISPLAY
  X_country.alpha1
  X_country.alpha2
  X_country.short-name
  X_country.long-name
    with browse br-countries.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-undo.
    IF AVAILABLE X_country THEN DO:
      run ref/ccountrs.w (
                     INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'one':U
                    ,INPUT X_country.num-code
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
  if available X_country then do:
    { gbl/markstrn.i X_country v-rid-list }
    glog = br-countries:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-countries:select-next-row ().
        apply "VALUE-CHANGED" to br-countries in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-countries in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rum Dialog-Frame
ON CHOOSE OF B-rum IN FRAME Dialog-Frame /* Операции */
DO:
  if rum-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if rum-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
 if ( available X_country ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_country ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-countries
&Scoped-define SELF-NAME BR-countries
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-countries Dialog-Frame
ON ITERATION-CHANGED OF BR-countries IN FRAME Dialog-Frame
DO:
  if not avail X_country or recid (X_country) <> v-rec then do:
    hide loc-alpha-1 in frame {&frame-name}.
    loc-alpha-1 = "".
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-countries Dialog-Frame
ON LEFT-MOUSE-DBLCLICK OF BR-countries IN FRAME Dialog-Frame
DO:
   if b-sel:sensitive then
        apply "CHOOSE":U to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-countries Dialog-Frame
ON RETURN OF BR-countries IN FRAME Dialog-Frame
DO:
   if b-sel:sensitive then
        apply "CHOOSE":U to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-name Dialog-Frame
ON CTRL-J OF loc-name IN FRAME Dialog-Frame /* Назв. */
DO:
  assign loc-name a-n-c.
  FIND NEXT buf_country No-LOCK WHERE
             buf_country.short-name begins loc-name No-ERROR.
  if avail buf_country then do:
    assign
    v-rec = recid (buf_country).
    reposition br-countries to recid v-rec no-error.
    APPLY "ENTRY" to br-countries.
  end.
  else do:
       message "Строка не найдена.".
       apply "entry" to loc-name in frame {&frame-name}.

  end.
   return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-name Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF loc-name IN FRAME Dialog-Frame /* Назв. */
DO:
  APPLY "RETURN" to loc-name.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-name Dialog-Frame
ON RETURN OF loc-name IN FRAME Dialog-Frame /* Назв. */
DO:
  assign loc-name a-n-c.
  FIND FIRST buf_country No-LOCK WHERE
             buf_country.short-name begins loc-name No-ERROR.
  if avail buf_country then do:
    assign
    v-rec = recid (buf_country).
    reposition br-countries to recid v-rec no-error.
    APPLY "ENTRY" to br-countries.
  end.
  else do:
       message "Строка не найдена.".
       apply "entry" to loc-name in frame {&frame-name}.
   end.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_batchwork-routing
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_batchwork-routing Dialog-Frame
ON CHOOSE OF MENU-ITEM m_batchwork-routing /* Маршрутизация в ВС */
DO:
  rum-option = {&thref-proc_batchwork-routing}.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_xml-file-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_xml-file-export Dialog-Frame
ON CHOOSE OF MENU-ITEM m_xml-file-export /* Экспорт в XML-файл */
DO:
  rum-option = {&thref-proc_batchwork-export}.
  RUN proc-b-rum IN THIS-PROCEDURE ( INPUT rum-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rum-option = "".
      RETURN NO-APPLY.
  END.
  rum-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-pck
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-pck Dialog-Frame
ON VALUE-CHANGED OF t-pck IN FRAME Dialog-Frame /* Пктн.рж */
DO:
  ASSIGN
  t-pck
  b-mark:SENSITIVE IN FRAME {&FRAME-NAME} = (t-pck OR LOOKUP("b-mark", bttns) > 0)
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/brwrepos.i &line-num=10 }

on any-printable of br-countries in frame {&frame-name}
do:
  if last-event:label = " " and loc-alpha-1 = ""
  then do:
    return no-apply.
  end.
  find first buf_country no-lock
    where buf_country.alpha1 begins (loc-alpha-1 + last-event:label)
    no-error .
  if available buf_country
  then do:
    loc-alpha-1 = loc-alpha-1 + last-event:label.
    disp loc-alpha-1 with frame {&frame-name}.
    v-rec = recid (buf_country).
    reposition br-countries to recid v-rec no-error.
  end.
end.

on backspace of br-countries in frame {&frame-name}
do:
  if loc-alpha-1 = "" then do:
    return no-apply.
  end.
  assign
    loc-alpha-1 = substr (loc-alpha-1, 1, length (loc-alpha-1) - 1)
  .
  find first buf_country no-lock
    where buf_country.alpha1 begins loc-alpha-1
    no-error .
  display loc-alpha-1 with frame {&frame-name}.
  v-rec = recid (buf_country).
  reposition br-countries to recid v-rec no-error.
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN MYenable.

  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  APPLY "ENTRY" to BR-countries.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY t-pck a-n-c mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-mark B-sel B-add B-chg t-pck B-rum B-hist B-help a-n-c
         BR-countries loc-alpha-1 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
b-rum:MENU-MOUSE in frame {&frame-name} =  1
MENU-ITEM m_xml-file-export:SENSITIVE IN MENU menu-b-rum = no
.
DEFINE buffer b-country for country.
DISPLAY a-n-c
      WITH FRAME {&frame-name} .
  ENABLE
  B-exit
  B-sel when lookup("b-sel", bttns) > 0
  B-add when lookup("b-add", bttns) > 0
  B-chg when lookup("b-add", bttns) > 0
b-mark WHEN LOOKUP("b-mark", bttns) > 0
  b-hist
  B-help
  a-n-c
  BR-countries
b-rum
t-pck
  loc-alpha-1
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
IF v-rid-list <> '' then do:

    FIND FIRST b-country  No-LOCK WHERE
           recid(b-country) = integer(entry(1, v-rid-list)) No-ERROR.
    IF avail b-country then do:
        REPOSITION br-countries to recid recid(b-country) NO-ERROR.
        APPLY "Entry" to br-countries.
        APPLY "VALUE-CHANGED" to br-countries.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-rum Dialog-Frame
PROCEDURE proc-b-rum :
define input parameter p-rum-option as character no-undo .
define variable v-ii as integer no-undo .
define variable v-radio-button-parameter as character no-undo .
if p-rum-option = {&thref-proc_batchwork-export} then do:
  v-radio-button-parameter = {&thref-proc_batchwork-export}.
end.
else do:
  v-radio-button-parameter = {&thref-proc_batchwork-routing}  .
end.
if v-rid-list = '' then do:
  message
  "Не выбрана ни одной записи"
  view-as alert-box warning.
  return.
end.
for each cntrlist:
  delete cntrlist.
end.
do v-ii = 1 to num-entries(v-rid-list):
  find first buf_country no-lock where
            recid(buf_country) = integer(entry(v-ii, v-rid-list)) no-error.
  if available buf_country then do:
    { ref/cntrlist.i cntrlist assign " " buf_  }
  end.
end.
run str/diallog.w (
      input parParentProc
    , input this-procedure
    , input "utl/thbjrumr.w":U
    , input {&thref} + {&delim-par} + v-radio-button-parameter /*parameter - второй элемент списка - это radio-buttons rs-ruleset d thbjrumr*/
    , input no /*p-auto-go*/
    , input "&Стоп"
    , input substitute("Операции над странами") ) no-error .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
