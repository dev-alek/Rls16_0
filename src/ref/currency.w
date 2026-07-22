&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-currency


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_curr-accnt FOR ub.curr-accnt.
DEFINE BUFFER X_curr-bank FOR ub.curr-bank.
DEFINE BUFFER X_currency FOR ub.currency.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-currency 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник валют

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/05
Author: Bakhtadze Natalya
Creation date: 09/13/05

Description:
вызов для выбора: run ref/currency.w ( parparentproc, "b-sel", output <recid> ).

Author: ILY , модификатор Черных В.

*/

/* ***************************  Definitions  ************************** */



/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input  parameter bttns as character no-undo .
define input-output parameter rid-sel  as recid no-undo .

def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник валют" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */
define variable  ri  as recid  no-undo.
define variable log-res as log no-undo.
define variable tek-browse as integer initial 0 no-undo.
define variable v-is-deploy as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-currency
&Scoped-define BROWSE-NAME br-curr-accnt

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_curr-accnt X_curr-bank X_currency

/* Definitions for BROWSE br-curr-accnt                                 */
&Scoped-define FIELDS-IN-QUERY-br-curr-accnt X_curr-accnt.exch-date ~
X_curr-accnt.exch-rate X_curr-accnt.exch-scale 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-curr-accnt 
&Scoped-define QUERY-STRING-br-curr-accnt FOR EACH X_curr-accnt ~
      WHERE X_curr-accnt.curr-code = X_currency.curr-code NO-LOCK ~
    BY X_curr-accnt.exch-date DESCENDING
&Scoped-define OPEN-QUERY-br-curr-accnt OPEN QUERY br-curr-accnt FOR EACH X_curr-accnt ~
      WHERE X_curr-accnt.curr-code = X_currency.curr-code NO-LOCK ~
    BY X_curr-accnt.exch-date DESCENDING.
&Scoped-define TABLES-IN-QUERY-br-curr-accnt X_curr-accnt
&Scoped-define FIRST-TABLE-IN-QUERY-br-curr-accnt X_curr-accnt


/* Definitions for BROWSE br-curr-bank                                  */
&Scoped-define FIELDS-IN-QUERY-br-curr-bank X_curr-bank.exch-date ~
X_curr-bank.exch-rate X_curr-bank.exch-scale 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-curr-bank 
&Scoped-define QUERY-STRING-br-curr-bank FOR EACH X_curr-bank ~
      WHERE X_curr-bank.curr-code =  X_currency.curr-code NO-LOCK ~
    BY X_curr-bank.exch-date DESCENDING
&Scoped-define OPEN-QUERY-br-curr-bank OPEN QUERY br-curr-bank FOR EACH X_curr-bank ~
      WHERE X_curr-bank.curr-code =  X_currency.curr-code NO-LOCK ~
    BY X_curr-bank.exch-date DESCENDING.
&Scoped-define TABLES-IN-QUERY-br-curr-bank X_curr-bank
&Scoped-define FIRST-TABLE-IN-QUERY-br-curr-bank X_curr-bank


/* Definitions for BROWSE br-currency                                   */
&Scoped-define FIELDS-IN-QUERY-br-currency X_currency.curr-code X_currency.curr-abbr X_currency.okv-code (IF num-entries(X_currency.curr-eng-name, {&delim-par}) > 1 THEN entry(2, X_currency.curr-eng-name, {&delim-par}) ELSE '')   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-currency   
&Scoped-define SELF-NAME br-currency
&Scoped-define QUERY-STRING-br-currency FOR EACH X_currency NO-LOCK
&Scoped-define OPEN-QUERY-br-currency OPEN QUERY {&SELF-NAME} FOR EACH X_currency NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-currency X_currency
&Scoped-define FIRST-TABLE-IN-QUERY-br-currency X_currency


/* Definitions for DIALOG-BOX d-currency                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-currency ~
    ~{&OPEN-QUERY-br-currency}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel b-help b-add b-upd ~
b-add-curr-accnt b-upd-curr-accnt b-hist-curr-accnt b-add-curr-bank ~
b-upd-curr-bank b-hist-curr-bank b-hist br-curr-accnt br-curr-bank ~
br-currency 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-add-curr-accnt 
     LABEL "Д&обавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-add-curr-bank 
     LABEL "Доб&авить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1.

DEFINE BUTTON b-hist 
     LABEL "Ис&тория":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-hist-curr-accnt 
     LABEL "Ис&тория":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-hist-curr-bank 
     LABEL "Ис&тория":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-upd 
     LABEL "&Изменить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-upd-curr-accnt 
     LABEL "И&зменить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-upd-curr-bank 
     LABEL "Из&менить" 
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-curr-accnt FOR 
      X_curr-accnt SCROLLING.

DEFINE QUERY br-curr-bank FOR 
      X_curr-bank SCROLLING.

DEFINE QUERY br-currency FOR 
      X_currency SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-curr-accnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-curr-accnt d-currency _STRUCTURED
  QUERY br-curr-accnt NO-LOCK DISPLAY
      X_curr-accnt.exch-date FORMAT "99/99/9999":U
      X_curr-accnt.exch-rate FORMAT ">>,>>9.9999":U
      X_curr-accnt.exch-scale FORMAT ">>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 32 BY 14
         TITLE "Курс ММВБ".

DEFINE BROWSE br-curr-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-curr-bank d-currency _STRUCTURED
  QUERY br-curr-bank NO-LOCK DISPLAY
      X_curr-bank.exch-date FORMAT "99/99/9999":U
      X_curr-bank.exch-rate FORMAT ">>,>>9.9999":U
      X_curr-bank.exch-scale FORMAT ">>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 32 BY 14
         TITLE "Курс ЦБ".

DEFINE BROWSE br-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-currency d-currency _FREEFORM
  QUERY br-currency NO-LOCK DISPLAY
      X_currency.curr-code FORMAT ">>9":U
      X_currency.curr-abbr FORMAT "X(3)":U
      X_currency.okv-code FORMAT ">>9":U  COLUMN-LABEL "Код!ОКВ"
      (IF num-entries(X_currency.curr-eng-name, {&delim-par}) > 1
       THEN entry(2, X_currency.curr-eng-name, {&delim-par})
       ELSE '') COLUMN-LABEL "Букв.код!по ОКВ"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 22.5 BY 13.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-currency
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-help AT ROW 1 COL 71
     b-add AT ROW 3 COL 1
     b-upd AT ROW 3 COL 11
     b-add-curr-accnt AT ROW 3 COL 24
     b-upd-curr-accnt AT ROW 3 COL 34
     b-hist-curr-accnt AT ROW 3 COL 44
     b-add-curr-bank AT ROW 3 COL 57
     b-upd-curr-bank AT ROW 3 COL 67
     b-hist-curr-bank AT ROW 3 COL 77
     b-hist AT ROW 4 COL 11
     br-curr-accnt AT ROW 4 COL 24
     br-curr-bank AT ROW 4 COL 57
     br-currency AT ROW 5 COL 1
     SPACE(66.73) SKIP(0.78)
    WITH VIEW-AS DIALOG-BOX 
         SIDE-LABELS THREE-D  SCROLLABLE 
         TITLE "С П Р А В О Ч Н И К   В А Л Ю Т":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_curr-accnt B "?" ? ub curr-accnt
      TABLE: X_curr-bank B "?" ? ub curr-bank
      TABLE: X_currency B "?" ? ub currency
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-currency
   FRAME-NAME UNDERLINE                                                 */
/* BROWSE-TAB br-curr-accnt b-hist d-currency */
/* BROWSE-TAB br-curr-bank br-curr-accnt d-currency */
/* BROWSE-TAB br-currency br-curr-bank d-currency */
ASSIGN 
       FRAME d-currency:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-add-curr-accnt IN FRAME d-currency
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-add-curr-bank IN FRAME d-currency
   NO-DISPLAY                                                           */
/* SETTINGS FOR BUTTON b-sel IN FRAME d-currency
   NO-DISPLAY                                                           */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-curr-accnt
/* Query rebuild information for BROWSE br-curr-accnt
     _TblList          = "X_curr-accnt"
     _Options          = "NO-LOCK"
     _OrdList          = "X_curr-accnt.exch-date|no"
     _Where[1]         = "X_curr-accnt.curr-code = X_currency.curr-code"
     _FldNameList[1]   > Temp-Tables.X_curr-accnt.exch-date
"X_curr-accnt.exch-date" ? "99/99/9999" "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.X_curr-accnt.exch-rate
     _FldNameList[3]   = Temp-Tables.X_curr-accnt.exch-scale
     _Query            is NOT OPENED
*/  /* BROWSE br-curr-accnt */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-curr-bank
/* Query rebuild information for BROWSE br-curr-bank
     _TblList          = "X_curr-bank"
     _Options          = "NO-LOCK"
     _OrdList          = "X_curr-bank.exch-date|no"
     _Where[1]         = "X_curr-bank.curr-code =  X_currency.curr-code"
     _FldNameList[1]   > Temp-Tables.X_curr-bank.exch-date
"X_curr-bank.exch-date" ? "99/99/9999" "date" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = Temp-Tables.X_curr-bank.exch-rate
     _FldNameList[3]   = Temp-Tables.X_curr-bank.exch-scale
     _Query            is NOT OPENED
*/  /* BROWSE br-curr-bank */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-currency
/* Query rebuild information for BROWSE br-currency
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_currency NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE br-currency */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-currency
ON CHOOSE OF b-add IN FRAME d-currency /* Добавить */
DO:
  define variable v-ok as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_currency-reference_work':U
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

    if v-cntxt-db-num = 0 then do:
      run ref/currenci.w (
                      input parparentproc
                     ,input {&add-def}
                     ,input ?
                     ,input-output ri ).
      if ri <> ? then do:
        {&open-query-br-currency}
        reposition br-currency to recid ri.
        log-res = br-currency:select-focused-row( ).
        apply "ENTRY":U to br-currency.
        apply "VALUE-CHANGED":U to br-currency.
      end.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-curr-accnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-curr-accnt d-currency
ON CHOOSE OF b-add-curr-accnt IN FRAME d-currency /* Добавить */
DO:
  define variable v-ok as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_micex-rate_update':U
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

  if X_currency.curr-code = 0
  and can-find( first X_curr-accnt )
  then do:
    message
      "Для валюты с кодом 0 -  - установлен фиксированный курс - 1!" skip
      view-as alert-box WARNING.
    return no-apply.
  end.

  if v-cntxt-db-num = 0
  then do:
    run add-curr-accnt in this-procedure
      (output ri
      ).
    if ri <> ?
    then do:
      if ri <> ? then do:
        {&open-query-br-curr-accnt}
        reposition br-curr-accnt to recid ri no-error.
      end.
      apply 'entry':u to br-currency .
      apply 'iteration-changed':u to br-currency .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-curr-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-curr-bank d-currency
ON CHOOSE OF b-add-curr-bank IN FRAME d-currency /* Добавить */
DO:
  define variable v-ok as logical no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cb-rate_update':U
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

  if  X_currency.curr-code = 0
  and can-find(first X_curr-bank)
  then do:
    message
      "Для валюты с кодом 0 - {&abbr_rubli_firstshift} - установлен фиксированный курс - 1!" skip
      view-as alert-box WARNING .
    return no-apply.
  end.

  if v-cntxt-db-num = 0
  then do:
    run add-curr-bank
      (output ri
      ).
    if ri <> ?
    then do:
      apply 'entry':u to br-currency .
      apply 'iteration-changed':u to br-currency .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-currency
ON CHOOSE OF b-hist IN FRAME d-currency /* История */
DO:
define variable v-rid-list as character no-undo.
IF NOT AVAILABLE X_currency THEN RETURN NO-APPLY.
  run ref/ccurrenc.w
              (
              input parParentProc
              ,input "":U /*bttns*/
              ,input "one":U
              ,input X_currency.curr-code
              ,input-output v-rid-list
                            ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist-curr-accnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist-curr-accnt d-currency
ON CHOOSE OF b-hist-curr-accnt IN FRAME d-currency /* История */
DO:
define variable v-rid-list as character no-undo.
IF NOT AVAILABLE X_curr-accnt THEN RETURN NO-APPLY.

run ref/ccurracc.w
          (
          input parParentProc
          ,input "":U /*bttns*/
          ,input "one":U
          ,input X_curr-accnt.curr-code
          ,input X_curr-accnt.exch-date
          ,input-output v-rid-list
                        ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist-curr-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist-curr-bank d-currency
ON CHOOSE OF b-hist-curr-bank IN FRAME d-currency /* История */
DO:
define variable v-rid-list as character no-undo.
IF NOT AVAILABLE X_curr-bank THEN RETURN NO-APPLY.

  run ref/ccurrbnk.w
              (
              input parParentProc
              ,input "":U /*bttns*/
              ,input "one":U
              ,input X_curr-bank.curr-code
              ,input X_curr-bank.exch-date
              ,input-output v-rid-list
                            ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-currency
ON CHOOSE OF b-sel IN FRAME d-currency /* Выбор  */
DO:
    if available X_currency then
        do:
            rid-sel = recid( X_currency ).
            apply  "GO" to FRAME {&FRAME-NAME}.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd d-currency
ON CHOOSE OF b-upd IN FRAME d-currency /* Изменить */
DO:
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_currency-reference_work':U
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

  if not available X_currency
  then do:
    return no-apply.
  end.
  ri = recid( X_currency ).

  if v-cntxt-db-num = 0 then
      run ref/currenci.w ( input parparentproc
                      ,input {&update}
                      ,input X_currency.curr-code
                      ,input-output ri ).

  br-currency:REFRESH().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd-curr-accnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd-curr-accnt d-currency
ON CHOOSE OF b-upd-curr-accnt IN FRAME d-currency /* Изменить */
DO:
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_micex-rate_update':U
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
    if X_currency.curr-code = 0 then
        do:
            message "Для валюты с кодом 0 - {&abbr_rubli_firstshift} - установлен фиксированный курс - 1!"
                view-as alert-box WARNING.
            return no-apply.
        end.

    if v-cntxt-db-num = 0 then
        RUN upd-curr-accnt.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-upd-curr-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-upd-curr-bank d-currency
ON CHOOSE OF b-upd-curr-bank IN FRAME d-currency /* Изменить */
DO:
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cb-rate_update':U
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
    if X_currency.curr-code = 0 then
        do:
            message "Для валюты с кодом 0 - {&abbr_rubli_firstshift} - установлен фиксированный курс - 1!"
                view-as alert-box WARNING.
            return no-apply.
        end.

    if v-cntxt-db-num = 0 then
        RUN upd-curr-bank.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-curr-accnt
&Scoped-define SELF-NAME br-curr-accnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-curr-accnt d-currency
ON ENTRY OF br-curr-accnt IN FRAME d-currency /* Курс ММВБ */
DO:
  tek-browse = 2.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-curr-bank
&Scoped-define SELF-NAME br-curr-bank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-curr-bank d-currency
ON ENTRY OF br-curr-bank IN FRAME d-currency /* Курс ЦБ */
DO:
  tek-browse = 3.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-currency
&Scoped-define SELF-NAME br-currency
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-currency d-currency
ON ENTRY OF br-currency IN FRAME d-currency
DO:
  tek-browse = 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-currency d-currency
ON MOUSE-SELECT-DBLCLICK OF br-currency IN FRAME d-currency
DO:
    if b-sel:sensitive then
        apply "CHOOSE":U to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-currency d-currency
ON RETURN OF br-currency IN FRAME d-currency
DO:
    if b-sel:sensitive then
        apply "CHOOSE":U to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-currency d-currency
ON VALUE-CHANGED OF br-currency IN FRAME d-currency
DO:
    if available X_currency then
        do:
            {&OPEN-QUERY-br-curr-accnt}
            {&OPEN-QUERY-br-curr-bank}
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-curr-accnt
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-currency 


/* ***************************  Main Block  *************************** */

/* Restore the current-window if it is an icon.                         */
/* Otherwise the dialog box will be hidden                              */
IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED
THEN CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

{ gbl/app_help.i &disable_diasize=true }

{ gbl/diasize.i &browse-name=br-currency }

run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse br-curr-accnt :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'height':u
  ,input  browse br-curr-bank :handle
  ) .
run diasize_init in this-procedure .

{ gbl/brwrepos.i
  &browse-name=br-currency
  &line-num=5
}


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.
{ gbl/getcntxt.i get }
/* Now enable the interface and wait for the exit condition.            */
RUN enable_UI.
do   on endkey  undo, leave   on error undo, leave:

  if lookup('s-deploy', bttns) > 0 then do:
    assign
    v-is-deploy = yes.
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-curr-accnt d-currency 
PROCEDURE add-curr-accnt :
define output parameter rid as recid no-undo init ?.

  do
  on error undo, return error return-value
  :
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .

    run cur-time in this-procedure
      (output v-today /* p-today */
      ,output v-time  /* p-time  */
      ).

    define variable v-exch-date   as date      no-undo .
    define variable v-exch-rate   as decimal   no-undo .
    define variable v-exch-scale  as integer   no-undo .
    define variable v-data-update as logical   no-undo .

    assign
      v-exch-date  = v-today
      v-exch-rate  = 1
      v-exch-scale = 1
    .

    run ref/d-inexch.w
      (input        ?                 /* h-callback         */
      ,input        "Курс ММВБ: ВВОД" /* p-title            */
      ,input        true              /* p-enable-update    */
      ,input        true              /* p-enable-exch-date */
      ,input-output v-exch-date       /* p-exch-date        */
      ,input-output v-exch-rate       /* p-exch-rate        */
      ,input-output v-exch-scale      /* p-exch-scale       */
      ,output       v-data-update     /* p-data-update      */
      ) .

    if v-data-update = true
    then do:
      define buffer buf_currency   for ub.currency .

      find buf_currency exclusive-lock
        where rowid(buf_currency) = rowid(X_currency)
        .

      assign
        rid = ?
      .
      run ref/curracc1.p
        ( input-output rid
        , input {&add-def}
        , input false /* p-silent */
        , input X_currency.curr-code
        , input v-exch-date
        , input v-exch-rate
        , input v-exch-scale
        ) .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-curr-bank d-currency 
PROCEDURE add-curr-bank :
define output param rid as recid no-undo init ?.

  do
  on error undo, return error return-value
  :
    define variable v-today       as date      no-undo .
    define variable v-time        as integer   no-undo .
    define variable v-exch-date   as date      no-undo .
    define variable v-exch-rate   as decimal   no-undo .
    define variable v-exch-scale  as integer   no-undo .
    define variable v-data-update as logical   no-undo .

    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ).

    assign
      v-exch-date  = v-today
      v-exch-rate  = 1
      v-exch-scale = 1
    .

    run ref/d-inexch.w
      (input        ?                       /* h-callback         */
      ,input        "Банковский курс: ВВОД" /* p-title            */
      ,input        true                    /* p-enable-update    */
      ,input        true                    /* p-enable-exch-date */
      ,input-output v-exch-date             /* p-exch-date        */
      ,input-output v-exch-rate             /* p-exch-rate        */
      ,input-output v-exch-scale            /* p-exch-scale       */
      ,output       v-data-update           /* p-data-update      */
      ) .
    if v-data-update = true
    then do:
      define buffer buf_currency for ub.currency .

      find buf_currency exclusive-lock
        where rowid(buf_currency) = rowid(X_currency)
        .

      assign
        rid = ?
      .

      run ref/currbnk1.p
        ( input-output rid
        , input {&add-def}
        , input false /* p-silent */
        , input X_currency.curr-code
        , input v-exch-date
        , input v-exch-rate
        , input v-exch-scale
        ) .

    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-currency  _DEFAULT-DISABLE
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
  HIDE FRAME d-currency.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-currency 
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
  define variable log-res as log no-undo.
  ENABLE
      br-currency
      br-curr-accnt
      br-curr-bank
      b-exit
      b-help
      b-add            when lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0
      b-upd-curr-accnt when v-cntxt-db-num = 0
      b-upd            when lookup("b-add", bttns) > 0 and v-cntxt-db-num = 0
      b-upd-curr-bank  when v-cntxt-db-num = 0
      b-sel            when lookup("b-sel", bttns) > 0
      b-add-curr-accnt when v-cntxt-db-num = 0
      b-add-curr-bank  when v-cntxt-db-num = 0
      b-hist           when not v-is-deploy
      b-hist-curr-accnt when not v-is-deploy
      b-hist-curr-bank  when not v-is-deploy
      WITH FRAME d-currency.
  {&OPEN-BROWSERS-IN-QUERY-d-currency}
  if  rid-sel <> ?
  and lookup("b-sel", bttns) > 0
  then do:
    reposition br-currency to recid rid-sel no-error.
  end.
  apply "ITERATION-CHANGED":U to br-currency.
  if available X_currency
      then log-res = br-currency:select-focused-row( ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE upd-curr-accnt d-currency 
PROCEDURE upd-curr-accnt :
do
  on error undo, return error return-value
  :
    define variable rid           as recid     no-undo .
    define variable v-today       as date      no-undo .
    define variable v-time        as integer   no-undo .
    define variable v-exch-date   as date      no-undo .
    define variable v-exch-rate   as decimal   no-undo .
    define variable v-exch-scale  as integer   no-undo .
    define variable v-data-update as logical   no-undo .

    define buffer buf_currency   for ub.currency .
    define buffer buf_curr-accnt for ub.curr-accnt .

    if available X_curr-accnt then do:

      find buf_currency exclusive-lock
        where rowid(buf_currency) = rowid(X_currency)
        .

      run cur-time in this-procedure
        (output v-today
        ,output v-time
        ).
      if X_curr-accnt.exch-date < v-today
      then do:
        message
          "Разрешается редактировать курс начиная только с текущей даты!"
          view-as alert-box error.
        return .
      end.

      find current X_curr-accnt exclusive-lock .

      assign
        v-exch-date  = X_curr-accnt.exch-date
        v-exch-rate  = X_curr-accnt.exch-rate
        v-exch-scale = X_curr-accnt.exch-scale
      .

      run ref/d-inexch.w
        (input        ?                      /* h-callback         */
        ,input        "Курс ММВБ: ИЗМЕНЕНИЕ" /* p-title            */
        ,input        true                   /* p-enable-update    */
        ,input        false                  /* p-enable-exch-date */
        ,input-output v-exch-date            /* p-exch-date        */
        ,input-output v-exch-rate            /* p-exch-rate        */
        ,input-output v-exch-scale           /* p-exch-scale       */
        ,output       v-data-update          /* p-data-update      */
        ) .
      if v-data-update = true
      then do:
        assign
          rid = recid( X_curr-accnt )
        .
        run ref/curracc1.p
          ( input-output rid
          , input {&update}
          , input false /* p-silent */
          , input X_curr-accnt.curr-code
          , input v-exch-date
          , input v-exch-rate
          , input v-exch-scale
          ) .

        display
          X_curr-accnt.exch-rate
          X_curr-accnt.exch-scale
          with browse br-curr-accnt .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE upd-curr-bank d-currency 
PROCEDURE upd-curr-bank :
define buffer buf_currency  for ub.currency .
  define buffer buf_curr-bank for ub.curr-bank .

  do
  on error undo, return error return-value
  :
    define variable rid           as recid     no-undo .
    define variable v-today       as date      no-undo .
    define variable v-time        as integer   no-undo .
    define variable v-exch-date   as date      no-undo .
    define variable v-exch-rate   as decimal   no-undo .
    define variable v-exch-scale  as integer   no-undo .
    define variable v-data-update as logical   no-undo .

    if available X_curr-bank then do:

      find buf_currency exclusive-lock
        where rowid(buf_currency) = rowid(X_currency)
        .

      run cur-time in this-procedure
        (output v-today
        ,output v-time
        ).
      if X_curr-bank.exch-date <= v-today
      then do:
        message
          "Разрешается редактировать курс только с будущей датой!"
          view-as alert-box error.
        return .
      end.

      find current X_curr-bank exclusive-lock .

      assign
        v-exch-date  = X_curr-bank.exch-date
        v-exch-rate  = X_curr-bank.exch-rate
        v-exch-scale = X_curr-bank.exch-scale
      .

      run ref/d-inexch.w
        (input        ?                            /* h-callback         */
        ,input        "Банковский курс: ИЗМЕНЕНИЕ" /* p-title            */
        ,input        true                         /* p-enable-update    */
        ,input        false                        /* p-enable-exch-date */
        ,input-output v-exch-date                  /* p-exch-date        */
        ,input-output v-exch-rate                  /* p-exch-rate        */
        ,input-output v-exch-scale                 /* p-exch-scale       */
        ,output       v-data-update                /* p-data-update      */
        ) .
      if v-data-update = true
      then do:
        assign
          rid = recid( X_curr-bank )
        .
        run ref/currbnk1.p
          ( input-output rid
          , input {&update}
          , input false /* p-silent */
          , input X_curr-bank.curr-code
          , input v-exch-date
          , input v-exch-rate
          , input v-exch-scale
          ) .

        display
          X_curr-bank.exch-rate
          X_curr-bank.exch-scale
          with browse br-curr-bank .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

