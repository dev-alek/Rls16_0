&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_contract FOR ub.contract.
DEFINE BUFFER X_contract-specif FOR ub.contract-specif.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории спецификаций договоров

Автор: Чернова Светлана Александровна
Дата создания: 10/13/09
Author: Svetlana Chernova
Creation date: 10/13/09

Автор1: Кочетков Михаил Юрьевич

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code    as integer   no-undo .
define input parameter p-contract-code as integer   no-undo .
define input parameter p-gds-code as integer   no-undo .
/*define input parameter bttns  as char   no-undo .*/
/*define input-output param p-rid-list    as  char no-undo .*/


/* Local Variable Definitions ---                                       */
DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "Список истории спецификаций договоров":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }
{ cmp/library.i  }
{ gbl/usrfulnf.i }


define temp-table temp-changes no-undo
  field f_name as character
  field l_name as character
  field v_old as character
  field v_new as character
index pi is unique primary f_name.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-c-contract

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.c-contract-specif temp-changes

/* Definitions for BROWSE br-c-contract                                 */
&Scoped-define FIELDS-IN-QUERY-br-c-contract ub.c-contract-specif.contract-num ub.c-contract-specif.host-code ub.c-contract-specif.chip-num ub.c-contract-specif.corr-user-db-num ub.c-contract-specif.corr-date STRING (ub.c-contract-specif.corr-time,"HH:MM:ss") usrfulnf(ub.c-contract-specif.corr-user-name)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-c-contract
&Scoped-define SELF-NAME br-c-contract
&Scoped-define QUERY-STRING-br-c-contract FOR EACH ub.c-contract-specif NO-LOCK       WHERE       ub.c-contract-specif.contract-num = p-contract-code AND       ub.c-contract-specif.gds-code = p-gds-code and       ub.c-contract-specif.host-code = p-host-code      BY ub.c-contract-specif.corr-date DESCENDING      BY ub.c-contract-specif.corr-time DESCENDING
&Scoped-define OPEN-QUERY-br-c-contract OPEN QUERY {&SELF-NAME} FOR EACH ub.c-contract-specif NO-LOCK       WHERE       ub.c-contract-specif.contract-num = p-contract-code AND       ub.c-contract-specif.gds-code = p-gds-code and       ub.c-contract-specif.host-code = p-host-code      BY ub.c-contract-specif.corr-date DESCENDING      BY ub.c-contract-specif.corr-time DESCENDING.
&Scoped-define TABLES-IN-QUERY-br-c-contract ub.c-contract-specif
&Scoped-define FIRST-TABLE-IN-QUERY-br-c-contract ub.c-contract-specif


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-c-contract}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-Help br-c-contract BR-changes
&Scoped-Define DISPLAYED-OBJECTS artic prod gds-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE artic AS CHARACTER FORMAT "X(15)":U
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 13.5 BY 1 NO-UNDO.

DEFINE VARIABLE gds-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Наименование"
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE prod AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-c-contract FOR
      ub.c-contract-specif SCROLLING.

DEFINE QUERY BR-changes FOR
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-c-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-c-contract Dialog-Frame _FREEFORM
  QUERY br-c-contract NO-LOCK DISPLAY
      ub.c-contract-specif.contract-num
      ub.c-contract-specif.host-code format ">>>>>>>>>>>>9":U
      ub.c-contract-specif.chip-num  COLUMN-LABEL "Щепка!изменения"
      ub.c-contract-specif.corr-user-db-num  COLUMN-LABEL "БД!изменения"
      ub.c-contract-specif.corr-date COLUMN-LABEL "Дата!изменения" FORMAT "99/99/99":U      WIDTH 9
      STRING (ub.c-contract-specif.corr-time,"HH:MM:ss") COLUMN-LABEL "Время!изменения" FORMAT "X(8)":U
      usrfulnf(ub.c-contract-specif.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.21 ROW-HEIGHT-CHARS .58.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(34)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(30)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(30)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-Help AT ROW 1 COL 89
     artic AT ROW 2 COL 16.5 COLON-ALIGNED
     prod AT ROW 2 COL 46.5 COLON-ALIGNED
     gds-name AT ROW 3 COL 14 COLON-ALIGNED
     br-c-contract AT ROW 4.04 COL 1.38
     BR-changes AT ROW 13.5 COL 1.38
     "Товар" VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 2.21 COL 2
          FGCOLOR 4
     SPACE(90.88) SKIP(19.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список договоров"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_contract B "?" ? ub contract
      TABLE: X_contract-specif B "?" ? ub ub.contract-specif
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-c-contract gds-name Dialog-Frame */
/* BROWSE-TAB BR-changes br-c-contract Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN artic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       artic:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       br-c-contract:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* SETTINGS FOR FILL-IN gds-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       gds-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN prod IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       prod:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-c-contract
/* Query rebuild information for BROWSE br-c-contract
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ub.c-contract-specif NO-LOCK
      WHERE
      ub.c-contract-specif.contract-num = p-contract-code AND
      ub.c-contract-specif.gds-code = p-gds-code and
      ub.c-contract-specif.host-code = p-host-code
     BY ub.c-contract-specif.corr-date DESCENDING
     BY ub.c-contract-specif.corr-time DESCENDING.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,"
     _OrdList          = "ub.c-contract-specif.corr-date|no,ub.c-contract-specif.corr-time|no"
     _Where[1]         = "ub.c-contract-specif.contract-num = p-contract-code
 AND ub.c-contract-specif.gds-code = p-gds-code"
     _Query            is OPENED
*/  /* BROWSE br-c-contract */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define BROWSE-NAME br-c-contract
&Scoped-define SELF-NAME br-c-contract
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-c-contract Dialog-Frame
ON VALUE-CHANGED OF br-c-contract IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
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

  find first X_contract-specif no-lock  where X_contract-specif.host-code = p-host-code and X_contract-specif.contract-num = p-contract-code and X_contract-specif.gds-code = p-gds-code no-error .
  if not available X_contract-specif then do:
    message  vss-workfile vss-revision vss-description skip  "Неверное значение параметра вызова p-host-code и/или p-contract-code"  p-host-code p-contract-code
    view-as alert-box ERROR.
    return.
  end.
  find first X_contract no-lock  where X_contract.host-code = p-host-code and X_contract.contract-code = p-contract-code .
  find first ub.clients no-lock where ub.clients.obj-code = p-host-code and ub.clients.obj-type = {&cmp} .
  find first ub.goods no-lock where ub.goods.gds-code = p-gds-code .
  assign frame Dialog-Frame:title = "История спецификации" + {&space-char}  + substitute("Фирма: (&1) &2 Договор : &3 от &4", p-host-code, ub.clients.obj-name,  X_contract.contract-prn-code, string(X_contract.contract-date,"99/99/9999")) .
  assign
    artic    = ub.goods.artic
    prod     = ub.goods.prod-type + " " + string(goods.prod-code)
    gds-name = ub.goods.gds-name
  .

  RUN enable_UI.
  apply "VALUE-CHANGED" to br-c-contract.
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
  DISPLAY artic prod gds-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help br-c-contract BR-changes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer new_c-contract-specif for ub.c-contract-specif.
  define buffer current_contract-specif for ub.contract-specif.

  define variable v-chg-fields as character no-undo.
  define variable v-old-fields as character no-undo.
  define variable v-new-fields as character no-undo.
  define variable ii as integer no-undo.

  for each temp-changes:  delete temp-changes.  END.
  if available ub.c-contract-specif then do:
    find first new_c-contract-specif no-lock
      where new_c-contract-specif.host-code    = ub.c-contract-specif.host-code
        and new_c-contract-specif.contract-num = ub.c-contract-specif.contract-num
        and new_c-contract-specif.gds-code     = ub.c-contract-specif.gds-code
        and new_c-contract-specif.corr-user-db-num  = ub.c-contract-specif.corr-user-db-num
        and new_c-contract-specif.chip-num     > ub.c-contract-specif.chip-num
      no-error.

    if not available new_c-contract-specif then do:
      find first current_contract-specif no-lock
        where current_contract-specif.host-code   = ub.c-contract-specif.host-code
        and current_contract-specif.contract-num = ub.c-contract-specif.contract-num
        and current_contract-specif.gds-code     = ub.c-contract-specif.gds-code
      no-error.
      if not available current_contract-specif then return error.
      buffer-compare ub.c-contract-specif to current_contract-specif save result in v-chg-fields.
    end.
    else do:
      buffer-compare new_c-contract-specif except chip-num to ub.c-contract-specif save result in v-chg-fields.
    end.

    &scop  disp-field ~
      when "~{&field-name~}":U then do: ~
      create temp-changes. ~
      assign ~
      temp-changes.f_name = "~{&field-name~}":U ~
      temp-changes.l_name = ~{&field-label~} ~
      temp-changes.v_old = string(ub.c-contract-specif.~{&field-name~}) ~
      temp-changes.v_new = (if available new_c-contract-specif  ~
                              then string(new_c-contract-specif.~{&field-name~})  ~
                              else string(current_contract-specif.~{&field-name~})) ~
      . ~
      end. ~

    do ii = 1 to num-entries(v-chg-fields):
      CASE entry(ii, v-chg-fields):
        &scop field-name prc
        &scop field-label "Процент отклонения"
        {&disp-field}
        &scop field-name price-cli
        &scop field-label "Цена поставки"
        {&disp-field}
        &scop field-name qnty
        &scop field-label "Количество"
        {&disp-field}
        &scop field-name cli-base-rate
        &scop field-label "Коэф."
        {&disp-field}
        &scop field-name sum-cli
        &scop field-label "Сумма"
        {&disp-field}
        &scop field-name VAT-pc
        &scop field-label "НДС"
        {&disp-field}
        &scop field-name VAT-type
        &scop field-label "тип НДС"
        {&disp-field}
        &scop field-name income-qnty
        &scop field-label "Принятое кол-во"
        {&disp-field}
      END CASE.
    end.
  end.

  Open QUery br-changes for each temp-changes.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( input par-recid as recid, input mark-list as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
RETURN ( IF LOOKUP( STRING( par-recid ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME