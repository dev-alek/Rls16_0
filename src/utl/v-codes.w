&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME v-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS v-codes
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Коды используемые в диапазонах

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/01
Author: Dmitry Ukhanov
Creation date: 03/23/01

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-first-code like ub.code-range.first-code no-undo .
define input parameter p-type-code  as   character                no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Коды используемые в диапазонах".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

define temp-table list-code no-undo
 field gds-name as character column-label "Товар" format "X(40)"
 field b-code   as character column-label "Код" format "X(10)"
 field bc-on    as logical   column-label "Вкл" format "+/-"
 index bc b-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME v-codes
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES list-code

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 list-code.bc-on list-code.b-code list-code.gds-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH list-code BY b-code.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 list-code
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 list-code


/* Definitions for DIALOG-BOX v-codes                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-v-codes ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-help BROWSE-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-find-code AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Найдено"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      list-code SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 v-codes _FREEFORM
  QUERY BROWSE-1 DISPLAY
      list-code.bc-on
list-code.b-code
list-code.gds-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 57.25 BY 17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-codes
     b-quit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 45.5
     BROWSE-1 AT ROW 2.5 COL 2.13
     f-find-code AT ROW 1.42 COL 21.88 COLON-ALIGNED
     SPACE(22.36) SKIP(17.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Коды"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX v-codes
                                                                        */
/* BROWSE-TAB BROWSE-1 b-help v-codes */
ASSIGN
       FRAME v-codes:SCROLLABLE       = FALSE
       FRAME v-codes:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-find-code IN FRAME v-codes
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f-find-code:HIDDEN IN FRAME v-codes           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH list-code BY b-code.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX v-codes
/* Query rebuild information for DIALOG-BOX v-codes
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX v-codes */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME v-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-codes v-codes
ON WINDOW-CLOSE OF FRAME v-codes /* Диапазоны кодов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK v-codes


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

  define buffer buf1_code-range for ub.code-range .

  find first buf1_code-range no-lock
    where buf1_code-range.range-type = p-range-type
      and buf1_code-range.first-code = p-first-code
  .

  assign
    FRAME {&FRAME-NAME}:title = substitute( "Коды в диапазоне &1 c &2 по &3", p-type-code, p-first-code, buf1_code-range.last-code )
  .

  RUN enable_UI.

  run fill-tt in this-procedure
    ( input p-range-type
     ,input p-first-code
     ,output f-find-code
    )
  .
  display
    f-find-code
    with frame {&frame-name}
  .
  {&OPEN-BROWSERS-IN-QUERY-v-codes}

  WAIT-FOR GO OF FRAME {&FRAME-NAME} focus browse {&browse-name}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI v-codes _DEFAULT-DISABLE
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
  HIDE FRAME v-codes.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI v-codes _DEFAULT-ENABLE
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
  ENABLE b-quit b-help BROWSE-1
      WITH FRAME v-codes.
  VIEW FRAME v-codes.
  {&OPEN-BROWSERS-IN-QUERY-v-codes}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt v-codes
PROCEDURE fill-tt :
define input  parameter p1-range-type like ub.code-range.range-type no-undo .
  define input  parameter p1-first-code like ub.code-range.first-code no-undo .
  define output parameter p-find-code   as   integer                  no-undo .

  do
  on error undo, return error
  :
    define variable v-integer   as integer   no-undo .
    define variable v-ind       as integer   no-undo .
    define variable v-str       as character no-undo .
    define variable v-view-code as integer   no-undo .
    define variable v-find-code as integer   no-undo .

    define frame inf
      v-view-code label "Просмотрено" skip
      v-find-code label "Найдено" skip
      with view-as dialog-box side-labels 1 columns three-d title "Поиск кодов".

    define buffer buf_code-range for ub.code-range .
    define buffer buf_goods for ub.goods .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc for ub.prod-bc .
    define buffer buf_dis-card for ub.dis-card.
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer buf_dis-time-rule for ub.dis-time-rule.
    define buffer buf_firm  for ub.firm .
    define buffer buf_person  for ub.person .
    define buffer buf_clients for ub.clients.
    define buffer buf_contract for ub.contract .
    define buffer buf_rule-by-call for ub.rule-by-call.
    define buffer buf_sysconf for ub.sysconf.
    define buffer buf_fin-doc for ub.fin-doc.

    find first buf_code-range no-lock
      where buf_code-range.range-type = p1-range-type
        and buf_code-range.first-code = p1-first-code
    .

    assign
      v-view-code = 0
      v-find-code = 0
    .
    view frame inf.

    case buf_code-range.range-type :
      when {&gbl-bc-code}
      then do:
        for each buf_bar-code no-lock
          where buf_bar-code.b-code >= buf_code-range.first-code
            and buf_bar-code.b-code <= buf_code-range.last-code
        on error undo, return error
        :
          find first buf_goods no-lock
            where buf_goods.gds-code = buf_bar-code.gds-code
            no-error
          .

          create list-code .
          assign
            list-code.gds-name = (if available buf_goods then buf_goods.gds-name else "":U)
            list-code.b-code   = string( buf_bar-code.b-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .

          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when {&gbl-sc-code}
      or when {&loc-sc-code}
      or when {&loc-pg-code}
      or when {&loc-pt-code}
      or when {&loc-ss-code}
      or when {&gbl-ss-code}
      then do:
        for each buf_prod-bc no-lock
        on error undo, return error
        :
          if length( buf_prod-bc.b-str ) < 6 then do:
            find first buf_bar-code no-lock
              where buf_bar-code.b-code = buf_prod-bc.b-code
            .
            if available buf_bar-code then do:
              find first buf_goods no-lock
                where buf_goods.gds-code = buf_bar-code.gds-code
                no-error
              .
            end.

            assign
              v-integer = integer( buf_prod-bc.b-str ) no-error
            .
            assign
              v-str     = buf_prod-bc.b-str
              v-ind     = 6 - length( v-str )
            .
            do while v-ind > 0
            on error undo, return error
            :
              assign
                v-str = "0" + v-str
                v-ind = v-ind - 1
              .
            end.
            if string( v-integer, "999999" ) = v-str
              and v-integer >= buf_code-range.first-code
              and v-integer <= buf_code-range.last-code
            then do:
              create list-code .
              assign
                list-code.gds-name = (if available buf_goods then buf_goods.gds-name else "":U)
                list-code.b-code   = string( buf_prod-bc.b-str )
                list-code.bc-on    = buf_prod-bc.bc-on
                v-find-code = v-find-code + 1
              .
            end.
          end.
          assign
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when {&gbl-dc-code}
      then do:
        for each buf_dis-card no-lock
          where buf_dis-card.card-num >= buf_code-range.first-code
            and buf_dis-card.card-num <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_dis-card.d-card  + {&space-char} + buf_dis-card.cli-type + string(buf_dis-card.cli-code)
            list-code.b-code   = string( buf_dis-card.card-num )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when {&gbl-ct-code}
      then do:
        for each buf_contract no-lock
          where buf_contract.contract-code >= buf_code-range.first-code
            and buf_contract.contract-code <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_contract.contract-prn-code  + {&space-char} + buf_contract.cli-type + string(buf_contract.cli-code)
            list-code.b-code   = string( buf_contract.contract-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when {&gbl-fm-code}
      then do:
        for each buf_firm no-lock
          where buf_firm.firm-code >= buf_code-range.first-code
            and buf_firm.firm-code <= buf_code-range.last-code
        on error undo, return error
        :
          find first buf_clients no-lock where
                    buf_clients.obj-type = {&cmp}
                and buf_clients.obj-code = buf_firm.firm-code.
          create list-code .
          assign
            list-code.gds-name = substitute("&1&2 &3"
                                             , buf_clients.obj-type
                                             , buf_clients.obj-code
                                             , buf_clients.obj-name)
            list-code.b-code   = string( buf_firm.firm-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when {&gbl-pn-code}
      then do:
        for each buf_person no-lock
          where buf_person.psn-code >= buf_code-range.first-code
            and buf_person.psn-code <= buf_code-range.last-code
        on error undo, return error
        :
          find first buf_clients no-lock where
                    buf_clients.obj-type = {&prs}
                and buf_clients.obj-code = buf_person.psn-code.
          create list-code .
          assign
            list-code.gds-name = substitute("&1&2 &3"
                                             , buf_clients.obj-type
                                             , buf_clients.obj-code
                                             , buf_clients.obj-name)
            list-code.b-code   = string( buf_person.psn-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when {&gbl-dr-code} then do:
        for each buf_dis-rule no-lock
          where buf_dis-rule.rule-num >= buf_code-range.first-code
            and buf_dis-rule.rule-num <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_dis-rule.des
            list-code.b-code   = string( buf_dis-rule.rule-num )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
        for each buf_dis-time-rule no-lock
          where buf_dis-time-rule.time-rule-num >= buf_code-range.first-code
            and buf_dis-time-rule.time-rule-num <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_dis-time-rule.des
            list-code.b-code   = string( buf_dis-time-rule.time-rule-num )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      when {&gbl-ca-code}
      then do:
        for each buf_rule-by-call no-lock
          where buf_rule-by-call.call#_id >= buf_code-range.first-code
            and buf_rule-by-call.call#_id <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = buf_rule-by-call.call_id
            list-code.b-code   = string( buf_rule-by-call.call#_id )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
     when {&gbl-fd-code}
      then do:
        for each buf_sysconf no-lock,
           each buf_fin-doc no-lock where
                buf_fin-doc.host-code = buf_sysconf.host-code
            and buf_fin-doc.fin-doc-code >= buf_code-range.first-code
            and buf_fin-doc.fin-doc-code <= buf_code-range.last-code
        on error undo, return error
        :
          create list-code .
          assign
            list-code.gds-name = substitute("Фирма &1 фин.док-нт &2 (&3)"
                                           ,buf_fin-doc.host-code
                                           ,buf_fin-doc.prn-doc-code
                                           ,buf_fin-doc.fin-doc-code
                                           )
            list-code.b-code   = string( buf_fin-doc.fin-doc-code )
            list-code.bc-on    = true
            v-find-code = v-find-code + 1
            v-view-code = v-view-code + 1
          .
          if ( v-view-code modulo 100 ) = 0 then do:
            display
              v-view-code
              v-find-code
              with frame inf.
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Нет обработки диапазонов с типом &1", buf_code-range.range-type )
          view-as alert-box error .
        return error .
      end.
    end case.

    assign
      p-find-code = v-find-code
    .
    hide frame inf.

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME