&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt00-dis-card-type NO-UNDO LIKE ub.dis-card-type.
DEFINE TEMP-TABLE tt00-dis-dct-rule NO-UNDO LIKE ub.dis-dct-rule.
DEFINE BUFFER X_clients-obj FOR ub.clients.
DEFINE BUFFER X_dis-card-type FOR ub.dis-card-type.
DEFINE BUFFER X_dis-cfg-rule FOR ub.dis-cfg-rule.
DEFINE BUFFER X_dis-dct-rule FOR ub.dis-dct-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список скидок по типам ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/07
Author: Bakhtadze Natalya
Creation date: 01/26/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define INPUT PARAMETER bttn AS CHARACTER NO-UNDO.
define INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
/*список возможных list-mode
({&all}
"pos"
"templ-rl-root"
"discnt-role"
{&g___object}
({&g___Object} + {&comma-char} + "pos-type":U)
({&g___Object} + {&comma-char} + "templ-rl-root":U)
({&g___Object} + {&comma-char} + "discnt-role":U)
"rule-num":U
"rl-root":U
) , {&delim-par}
{&table_dis-card-type}
{&table_dis-card-type} + {&comma-char} + "temp"
)
*/
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-type as character no-undo .
define input parameter p-curr-host-code as integer no-undo .
define INPUT PARAMETER p-curr-obj-type AS CHARACTER NO-UNDO.
define INPUT PARAMETER p-curr-obj-code AS integer NO-UNDO.
define INPUT PARAMETER p-templ-rl-root AS integer NO-UNDO.
define INPUT PARAMETER p-pos-type AS character NO-UNDO.
define INPUT PARAMETER p-discnt-role AS character NO-UNDO.
define input parameter p-rule-num as integer no-undo .
define INPUT-OUTPUT PARAMETER p-rid-list AS CHARACTER NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список скидок по типам ДК".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i DEF }
{ cmp/r-pril.i new }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/prn-lib.i }
{ cmp/mrk-strf.i }
{ gbl/cur-time.i }
{ gbl/fltopend.i defproc }

DEFINE VARIABLE gds-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable filter-label as character no-undo init "Скидки по типам ДК" .
define variable filter-label0 as character no-undo init "Скидки по типам ДК" .
define variable filter-point as character no-undo init "dis-dcts" .
define variable filter-point0 as character no-undo init "dis-dcts" .
define variable sort-column-name as character no-undo .
define variable v-rid-list as character no-undo .
define variable temp-mode as logical no-undo.
DEFINE BUFFER par_dis-rule FOR ub.dis-rule.
DEFINE BUFFER par_dis-cfg-rule FOR ub.dis-cfg-rule.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer tt0-dis-dct-rule for tt00-dis-dct-rule.
define buffer tt0-dis-card-type for tt00-dis-card-type.


&SCOPED-DEFINE sort-clmn_1 mark-string(recid(X_dis-dct-rule), v-rid-list)
&scoped-define label-clmn_1 '*'
&SCOPED-DEFINE sort-clmn_2 X_dis-card-type.emitent-host-code
&scoped-define label-clmn_2 'Эмитент'
&SCOPED-DEFINE sort-clmn_3 X_dis-card-type.type
&scoped-define label-clmn_3 'Тип'
&SCOPED-DEFINE sort-clmn_4 X_dis-dct-rule.templ-rl-root
&scoped-define label-clmn_4 'Тип правила'
&SCOPED-DEFINE sort-clmn_5  cd-type-name(X_dis-dct-rule.pos-type)
&scoped-define label-clmn_5 'Место использ.'
&SCOPED-DEFINE sort-clmn_6 X_dis-dct-rule.obj-type
&scoped-define label-clmn_6 'Тип объ'
&SCOPED-DEFINE sort-clmn_7 X_dis-dct-rule.obj-code
&scoped-define label-clmn_7 'Код объ'
&SCOPED-DEFINE sort-clmn_8 dis-dct-rule-name(X_dis-dct-rule.discnt-role)
&SCOPED-DEFINE dyn_sort-clmn_8  substitute('dynamic-function(&1dis-dct-rule-name&1, X_dis-dct-rule.discnt-role)', ~{&double-quote~})
&scoped-define label-clmn_8 'Тип скидки'
&SCOPED-DEFINE sort-clmn_9 X_dis-dct-rule.rule-num
&scoped-define label-clmn_9 '№ правила'
&SCOPED-DEFINE sort-clmn_10 X_dis-dct-rule.rl-root
&scoped-define label-clmn_10 '№ корн.!правила'


&SCOPED-DEFINE sort-clmn_101 mark-string(recid(tt0-dis-dct-rule), v-rid-list)
&scoped-define label-clmn_101 '*'
&SCOPED-DEFINE sort-clmn_102 tt0-dis-card-type.emitent-host-code
&scoped-define label-clmn_102 'Эмитент'
&SCOPED-DEFINE sort-clmn_103 tt0-dis-card-type.type
&scoped-define label-clmn_103 'Тип'
&SCOPED-DEFINE sort-clmn_104 tt0-dis-dct-rule.templ-rl-root
&scoped-define label-clmn_104 'Тип правила'
&SCOPED-DEFINE sort-clmn_105  cd-type-name(tt0-dis-dct-rule.pos-type)
&scoped-define label-clmn_105 'Место использ.'
&SCOPED-DEFINE sort-clmn_106 tt0-dis-dct-rule.obj-type
&scoped-define label-clmn_106 'Тип объ'
&SCOPED-DEFINE sort-clmn_107 tt0-dis-dct-rule.obj-code
&scoped-define label-clmn_107 'Код объ'
&SCOPED-DEFINE sort-clmn_108 dis-dct-rule-name(tt0-dis-dct-rule.discnt-role)
&scoped-define label-clmn_108 'Тип скидки'
&SCOPED-DEFINE sort-clmn_109 tt0-dis-dct-rule.rule-num
&scoped-define label-clmn_109 '№ правила'
&SCOPED-DEFINE sort-clmn_110 tt0-dis-dct-rule.rl-root
&scoped-define label-clmn_110 '№ корн.!правила'

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dis-dct-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-dct-rule X_dis-card-type ~
tt0-dis-dct-rule tt0-dis-card-type

/* Definitions for BROWSE BR-dis-dct-rule                               */
&Scoped-define FIELDS-IN-QUERY-BR-dis-dct-rule {&sort-clmn_1} {&sort-clmn_2} {&sort-clmn_3} {&sort-clmn_4} {&sort-clmn_5} {&sort-clmn_6} {&sort-clmn_7} {&sort-clmn_8} {&sort-clmn_9} {&sort-clmn_10}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-dct-rule   
&Scoped-define SELF-NAME BR-dis-dct-rule
&Scoped-define QUERY-STRING-BR-dis-dct-rule FOR EACH X_dis-dct-rule NO-LOCK , ~
           FIRST X_dis-card-type NO-LOCK WHERE           X_dis-card-type.type = X_dis-dct-rule.type        AND X_dis-card-type.emitent-host-code = X_dis-dct-rule.emitent-host-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-dis-dct-rule OPEN QUERY {&SELF-NAME} FOR EACH X_dis-dct-rule NO-LOCK , ~
           FIRST X_dis-card-type NO-LOCK WHERE           X_dis-card-type.type = X_dis-dct-rule.type        AND X_dis-card-type.emitent-host-code = X_dis-dct-rule.emitent-host-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-dis-dct-rule X_dis-dct-rule ~
X_dis-card-type
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-dct-rule X_dis-dct-rule
&Scoped-define SECOND-TABLE-IN-QUERY-BR-dis-dct-rule X_dis-card-type


/* Definitions for BROWSE BR-tt0-dis-dct-rule                           */
&Scoped-define FIELDS-IN-QUERY-BR-tt0-dis-dct-rule {&sort-clmn_101} {&sort-clmn_102} {&sort-clmn_103} {&sort-clmn_104} {&sort-clmn_105} {&sort-clmn_106} {&sort-clmn_107} {&sort-clmn_108} {&sort-clmn_109} {&sort-clmn_110}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tt0-dis-dct-rule   
&Scoped-define SELF-NAME BR-tt0-dis-dct-rule
&Scoped-define QUERY-STRING-BR-tt0-dis-dct-rule FOR EACH tt0-dis-dct-rule NO-LOCK , ~
           FIRST tt0-dis-card-type NO-LOCK WHERE           tt0-dis-card-type.type = tt0-dis-dct-rule.type        AND tt0-dis-card-type.emitent-host-code = tt0-dis-dct-rule.emitent-host-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-tt0-dis-dct-rule OPEN QUERY {&SELF-NAME} FOR EACH tt0-dis-dct-rule NO-LOCK , ~
           FIRST tt0-dis-card-type NO-LOCK WHERE           tt0-dis-card-type.type = tt0-dis-dct-rule.type        AND tt0-dis-card-type.emitent-host-code = tt0-dis-dct-rule.emitent-host-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-tt0-dis-dct-rule tt0-dis-dct-rule ~
tt0-dis-card-type
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tt0-dis-dct-rule tt0-dis-dct-rule
&Scoped-define SECOND-TABLE-IN-QUERY-BR-tt0-dis-dct-rule tt0-dis-card-type


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-dis-dct-rule}~
    ~{&OPEN-QUERY-BR-tt0-dis-dct-rule}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-type b-dis-rule B-sch ~
B-print b-history B-Help BR-tt0-dis-dct-rule BR-dis-dct-rule mark-num 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD cd-type-name Dialog-Frame 
FUNCTION cd-type-name RETURNS CHARACTER
  ( input p-pos-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD dis-dct-rule-name Dialog-Frame 
FUNCTION dis-dct-rule-name RETURNS CHARACTER
  ( input p-dis-dct-rule-code as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dis-rule 
     LABEL "&Правило" 
     SIZE 10 BY 1.

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-history 
     LABEL "Ис&тория" 
     SIZE 3 BY 1.

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE BUTTON B-type 
     LABEL "&Тип карты" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dis-dct-rule FOR X_dis-dct-rule, X_dis-card-type SCROLLING.


DEFINE qUERY BR-tt0-dis-dct-rule FOR tt0-dis-dct-rule, tt0-dis-card-type SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-dct-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-dct-rule Dialog-Frame _FREEFORM
  QUERY BR-dis-dct-rule NO-LOCK DISPLAY
      {&sort-clmn_1} COLUMN-LABEL {&label-clmn_1} FORMAT "X(1)"
{&sort-clmn_2} COLUMN-LABEL {&label-clmn_2} format ">>>>9"
{&sort-clmn_3} COLUMN-LABEL {&label-clmn_3}
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4} FORMAT ">>>>>>>>9"
{&sort-clmn_5} COLUMN-LABEL {&label-clmn_5} FORMAT "X(10)"
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT "X(3)"
{&sort-clmn_7} COLUMN-LABEL {&label-clmn_7} FORMAT ">>>>9"
{&sort-clmn_8} COLUMN-LABEL {&label-clmn_8} FORMAT "X(70)"
{&sort-clmn_9} COLUMN-LABEL {&label-clmn_9} FORMAT ">>>>>>>>9"
{&sort-clmn_10} COLUMN-LABEL {&label-clmn_10} FORMAT ">>>>>>>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20 FIT-LAST-COLUMN.

DEFINE BROWSE BR-tt0-dis-dct-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tt0-dis-dct-rule Dialog-Frame _FREEFORM
  QUERY BR-tt0-dis-dct-rule NO-LOCK DISPLAY
      {&sort-clmn_101} COLUMN-LABEL {&label-clmn_101} FORMAT "X(1)"
{&sort-clmn_102} COLUMN-LABEL {&label-clmn_102} format ">>>>9"
{&sort-clmn_103} COLUMN-LABEL {&label-clmn_103}
{&sort-clmn_104} COLUMN-LABEL {&label-clmn_104} FORMAT ">>>>>>>>9"
{&sort-clmn_105} COLUMN-LABEL {&label-clmn_105} FORMAT "X(10)"
{&sort-clmn_106} COLUMN-LABEL {&label-clmn_106} FORMAT "X(3)"
{&sort-clmn_107} COLUMN-LABEL {&label-clmn_107} FORMAT ">>>>9"
{&sort-clmn_108} COLUMN-LABEL {&label-clmn_108} FORMAT "X(70)"
{&sort-clmn_109} COLUMN-LABEL {&label-clmn_109} FORMAT ">>>>>>>>9"
{&sort-clmn_110} COLUMN-LABEL {&label-clmn_110} FORMAT ">>>>>>>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 10
     B-type AT ROW 1 COL 41 WIDGET-ID 14
     b-dis-rule AT ROW 1 COL 51 WIDGET-ID 16
     B-sch AT ROW 1 COL 86 WIDGET-ID 8
     B-print AT ROW 1 COL 89 WIDGET-ID 6
     b-history AT ROW 1 COL 92 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     BR-tt0-dis-dct-rule AT ROW 3 COL 1 WIDGET-ID 200
     BR-dis-dct-rule AT ROW 3 COL 1 WIDGET-ID 100
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     SPACE(78.50) SKIP(21.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Скидки по типам ДК"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt00-dis-card-type T "?" NO-UNDO ub dis-card-type
      TABLE: tt00-dis-dct-rule T "?" NO-UNDO ub dis-dct-rule
      TABLE: X_clients-obj B "?" ? ub clients
      TABLE: X_dis-card-type B "?" ? ub dis-card-type
      TABLE: X_dis-cfg-rule B "?" ? ub dis-cfg-rule
      TABLE: X_dis-dct-rule B "?" ? ub dis-dct-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-tt0-dis-dct-rule B-Help Dialog-Frame */
/* BROWSE-TAB BR-dis-dct-rule BR-tt0-dis-dct-rule Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-dct-rule
/* Query rebuild information for BROWSE BR-dis-dct-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_dis-dct-rule NO-LOCK ,
    FIRST X_dis-card-type NO-LOCK WHERE
          X_dis-card-type.type = X_dis-dct-rule.type
       AND X_dis-card-type.emitent-host-code = X_dis-dct-rule.emitent-host-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-dis-dct-rule FOR X_dis-dct-rule, X_dis-card-type SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-dis-dct-rule */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tt0-dis-dct-rule
/* Query rebuild information for BROWSE BR-tt0-dis-dct-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH tt0-dis-dct-rule NO-LOCK ,
    FIRST tt0-dis-card-type NO-LOCK WHERE
          tt0-dis-card-type.type = tt0-dis-dct-rule.type
       AND tt0-dis-card-type.emitent-host-code = tt0-dis-dct-rule.emitent-host-code INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE qUERY BR-tt0-dis-dct-rule FOR tt0-dis-dct-rule, tt0-dis-card-type SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-tt0-dis-dct-rule */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON F5 OF FRAME Dialog-Frame /* Скидки по типам ДК */
DO:
   if br-tt0-dis-dct-rule:visible in frame {&frame-name} then do:
     v-doc-rec = recid(tt0-dis-dct-rule).
     Run OpenBRtt in this-procedure ( input yes, input no, input '':U).
     REPOSITION br-tt0-dis-dct-rule to recid v-doc-rec No-ERROR.
     apply 'value-changed' to br-tt0-dis-dct-rule.


   end.
   else do:
     v-doc-rec = recid(X_dis-dct-rule).
     Run OpenBR in this-procedure ( input yes, input no, input '':U).
     REPOSITION br-dis-dct-rule to recid v-doc-rec No-ERROR.
     apply 'value-changed' to br-dis-dct-rule.


   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Скидки по типам ДК */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Скидки по типам ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-rule Dialog-Frame
ON CHOOSE OF b-dis-rule IN FRAME Dialog-Frame /* Правило */
DO:
define variable v-rule-num as integer no-undo .
  if temp-mode then do:
    if not available tt0-dis-dct-rule then return no-apply.
    v-rule-num = tt0-dis-dct-rule.rule-num.
  end.
  else do:
    IF NOT AVAILABLE X_dis-dct-rule THEN RETURN NO-APPLY.
    v-rule-num = X_dis-dct-rule.rule-num.
  end.
  run ref/show-dr.p ( INPUT parparentproc
                     ,INPUT v-rule-num) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
if not available X_dis-dct-rule then return no-apply.
  run ref/dcctypes.w ( input parparentproc
                    , input '':U
                    , input ?
                    , input X_dis-dct-rule.emitent-host-code
                    , input X_dis-dct-rule.host-code
                    , input X_dis-dct-rule.obj-type
                    , input X_dis-dct-rule.obj-code
                    , input X_dis-dct-rule.TYPE
                    , input "subject":U
                    , input {&table_dis-dct-rule}
                    , output v-rid-list ) no-error .
APPLY "ENTRY" to br-dis-dct-rule.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  RUN proc-b-mark IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-dis-dct-rule.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if temp-mode then do:
    if ( available tt0-dis-dct-rule ) then do:
      if  ( v-rid-list = "" ) or b-mark:sensitive = no
      then
      v-rid-list = string( recid( tt0-dis-dct-rule ) ) .
    end.
  end.
  else do:
    if ( available X_dis-dct-rule ) then do:
      if  ( v-rid-list = "" ) or b-mark:sensitive = no
      then
      v-rid-list = string( recid( X_dis-dct-rule ) ) .
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-type Dialog-Frame
ON CHOOSE OF B-type IN FRAME Dialog-Frame /* Тип карты */
DO:
DEFINE VARIABLE v-ref-rec AS RECID NO-UNDO.
define buffer buf_dis-card-type for ub.dis-card-type.
  IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.
  FIND FIRST buf_dis-card-type No-LOCK WHERE
            buf_dis-card-type.type = X_dis-card-type.type
        and buf_dis-card-type.emitent-host-code = X_dis-card-type.emitent-host-code  no-error .
if error-status:error then  return no-apply.
v-ref-rec = recid( buf_dis-card-type ) .
 run ref/dc-typei.w ( input parparentproc
                , input {&lookup}
                , input v-cntxt-host-code-obj
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input-output v-ref-rec ).
apply "entry" to br-dis-dct-rule in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dis-dct-rule
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-dis-dct-rule" }

{ gbl/setfltnm.i }

{ gbl/srt-clmd.i
  &browse-name    = "br-dis-dct-rule"
  &table-name    = "X_dis-dct-rule"
  &frame-name     = "{&frame-name}"
  &label-clmn_2  = "{&label-clmn_2}"
  &sort-clmn_2   = "{&sort-clmn_2}"
  &label-clmn_3  = "{&label-clmn_3}"
  &sort-clmn_3   = "{&sort-clmn_3}"
  &label-clmn_4  = "{&label-clmn_4}"
  &sort-clmn_4   = "{&sort-clmn_4}"
  &label-clmn_5  = "{&label-clmn_5}"
  &sort-clmn_5   = "{&sort-clmn_5}"
  &label-clmn_6  = "{&label-clmn_6}"
  &sort-clmn_6   = "{&sort-clmn_6}"
  &label-clmn_7  = "{&label-clmn_7}"
  &sort-clmn_7   = "{&sort-clmn_7}"
  &label-clmn_8  = "{&label-clmn_8}"
  &sort-clmn_8   = "{&sort-clmn_8}"
  &dyn_sort-clmn_8   = "{&dyn_sort-clmn_8}"
  &label-clmn_9  = "{&label-clmn_9}"
  &sort-clmn_9   = "{&sort-clmn_9}"
  &label-clmn_10  = "{&label-clmn_10}"
  &sort-clmn_10   = "{&sort-clmn_10}"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

{ gbl/brwrepos.i
  &line-num=5
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i GET }
  IF lookup(p-list-mode, ({&all} + {&delim-par} +
                          "pos" + {&delim-par} +
                          "templ-rl-root" + {&delim-par} +
                          "discnt-role" + {&delim-par} +
                          {&g___object} + {&delim-par} +
                          ({&g___Object} + {&comma-char} + "pos-type":U) + {&delim-par} +
                          ({&g___Object} + {&comma-char} + "templ-rl-root":U) + {&delim-par} +
                          ({&g___Object} + {&comma-char} + "discnt-role":U) + {&delim-par} +
                          "rule-num":U + {&delim-par} +
                          "rl-root":U + {&delim-par} +
                          {&table_dis-card-type} + {&delim-par} +
                           ({&table_dis-card-type} + {&comma-char} + "temp")) , {&delim-par}) = 0
  THEN DO:
     MESSAGE
     vss-workfile vss-revision vss-description skip
     "Неверный параметр вызова p-list-mode " p-list-mode
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
  if p-list-mode = ({&table_dis-card-type} + {&comma-char} + "temp") then do:
    temp-mode = yes.
  end.
  IF lookup({&g___object} , p-list-mode) > 0 THEN DO:
    IF p-curr-obj-type <> {&stock}
    AND p-curr-obj-type <> {&shop} THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверный параметр вызова p-curr-obj-type " p-curr-obj-type
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
    FIND FIRST X_clients-obj NO-LOCK WHERE
              X_clients-obj.obj-type = p-curr-obj-type
         AND  X_clients-obj.obj-code = p-curr-obj-code NO-ERROR.
    IF NOT AVAILABLE X_clients-obj THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверные параметры вызова p-curr-obj-type p-curr-obj-code" p-curr-obj-type p-curr-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
  end.
  IF LOOKUP( "templ-rl-root", p-list-mode) > 0 THEN DO:
      FIND FIRST PAR_dis-rule NO-LOCK WHERE
                par_dis-rule.rule-num = p-templ-rl-root no-error.
      IF NOT AVAILABLE par_Dis-rule THEN DO:
          MESSAGE
          vss-workfile vss-revision vss-description skip
          "Неверный параметр вызова p-templ-rl-root" p-templ-rl-root
          VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN ERROR.

      END.
  END.
  IF LOOKUP( "pos-type", p-list-mode) > 0
  AND lookup(p-pos-type, {&cd-type-codes-real}) = 0  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-pos-type" p-pos-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF LOOKUP( "discnt-role", p-list-mode) > 0 THEN DO:
    FIND FIRST par_dis-cfg-rule NO-LOCK WHERE
              par_dis-cfg-rule.discnt-role = p-discnt-role
          AND par_dis-cfg-rule.TABLE-name = {&TABLE_dis-dct-rule} NO-ERROR.
    IF NOT AVAILABLE par_dis-cfg-rule  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверный параметр вызова p-discnt-role" p-discnt-role
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    END.
  END.
  if lookup({&table_dis-card-type}, p-list-mode) > 0
  and not temp-mode  then do:
    find first buf_dis-card-type no-lock where
              buf_dis-card-type.emitent-host-code = p-emitent-host-code
          and buf_dis-card-type.type = p-type
          and buf_dis-card-type.host-code = 0
          and buf_dis-card-type.obj-type = '':U
          and buf_dis-card-type.obj-code = 0 no-error .
    if not available buf_dis-card-type then do:
      MESSAGE
      vss-workfile vss-revision vss-description skip(0)
      substitute("Неверные параметры вызова p-emitent-host-code=&1&2" +
                 "p-type=&3"
                 ,p-emitent-host-code
                 ,{&new-line}
                 ,p-type )
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.

    end.
  end.
  v-rid-list = p-rid-list.
  if temp-mode then do:
    run fill-tt0-dis-dct-rule in (this-procedure:instantiating-procedure) ( input (buffer tt00-dis-dct-rule:handle)).
    run fill-tt0-dis-card-type in (this-procedure:instantiating-procedure) ( input (buffer tt00-dis-card-type:handle)).
  end.
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
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
  DISPLAY mark-num 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-type b-dis-rule B-sch B-print b-history B-Help 
         BR-tt0-dis-dct-rule BR-dis-dct-rule mark-num 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
define variable v-h as handle no-undo .
v-h = BR-dis-dct-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-clmn_8} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
v-h = BR-tt0-dis-dct-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-clmn_108} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.


DISPLAY
mark-num
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark WHEN LOOKUP("b-mark", bttn) > 0
B-sel WHEN LOOKUP("b-mark", bttn) > 0
b-type when not temp-mode
b-dis-rule
B-sch when not temp-mode
B-print when not temp-mode
b-history when not temp-mode
B-Help
WITH FRAME {&frame-name}.
if temp-mode then do:
    enable
    BR-tt0-dis-dct-rule
    with frame {&frame-name}.
    hide br-dis-dct-rule in frame {&frame-name}.
    VIEW FRAME {&frame-name}.
    RUn Openbrtt in this-procedure ( input yes, input no, input '':U).
end.
else do:
    enable
    BR-dis-dct-rule
    with frame {&frame-name}.
    hide br-tt0-dis-dct-rule in frame {&frame-name}.
    VIEW FRAME {&frame-name}.
    RUn Openbr in this-procedure ( input yes, input no, input '':U).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Скидки на типы ДК".
define variable p-host-code like ub.sysconf.host-code no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

if not( p-curr-obj-type = "":U and p-curr-obj-code = 0 ) then do:
{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code p-host-code }
end.

&scop flt-open-open-query OPEN QUERY br-dis-dct-rule FOR EACH X_dis-dct-rule no-lock

&scop flt-open-DYN_open-query FOR EACH X_dis-dct-rule no-lock

&scop flt-open-query-HANDLE QUERY br-dis-dct-rule:HANDLE

&scop flt-open-open-query-tail , FIRST X_dis-card-type no-lock where X_dis-card-type.type = X_dis-dct-rule.type and ~
                                                                     X_dis-card-type.emitent-host-code = X_dis-dct-rule.emitent-host-code


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-dct-rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-NAME X_dis-dct-rule

&scop flt-open-waitfram true

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN {&all}        THEN DO:
    ASSIGN
    frame {&frame-name}:TITLE =
                                  substitute("&1"
                                  , title0
                                  )
   filter-label = substitute("&1", filter-label0)
                                  .
   { gbl/fltopend.i
      &where-cond = "  "
      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN {&g___object}        THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    )
      filter-label = substitute("&1 Один объект", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-dct-rule.obj-type = p-curr-obj-type and X_dis-dct-rule.obj-code = p-curr-obj-code "
      &DYN_where-cond = " substitute('X_dis-dct-rule.obj-type = &1&2&1 and X_dis-dct-rule.obj-code = &3 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code)"
      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN ({&g___object} + {&comma-char} + "pos-type":U)       THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3 для &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-pos-type
                                    )
     filter-label = substitute("&1 Один объект, одно место использ", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-dct-rule.obj-type = p-curr-obj-type and X_dis-dct-rule.obj-code = p-curr-obj-code ~
                      AND X_dis-dct-rule.pos-type = p-pos-type "
      &DYN_where-cond = " substitute('X_dis-dct-rule.obj-type = &1&2&1 and X_dis-dct-rule.obj-code = &3 ~
                      AND X_dis-dct-rule.pos-type = &1&4&1 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-pos-type)"

      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN ({&g___object} + {&comma-char} + "templ-rl-root":U)       THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3 тип правила &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-templ-rl-root
                                    )
     filter-label = substitute("&1 Один объект, один шаблон", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-dct-rule.obj-type = p-curr-obj-type and X_dis-dct-rule.obj-code = p-curr-obj-code ~
                      AND X_dis-dct-rule.templ-rl-root = p-templ-rl-root "
      &DYN_where-cond = " substitute('X_dis-dct-rule.obj-type = &1&2&1 and X_dis-dct-rule.obj-code = &3 ~
                      AND X_dis-dct-rule.templ-rl-root = &4 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-templ-rl-root)"

      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN ({&g___object} + {&comma-char} + "discnt-role":U)       THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 по объекту &@2 &3 тип скидки &4"
                                    , title0
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , p-discnt-role
                                    )
     filter-label = substitute("&1 Один объект, один тип скидки", filter-label0)
                                    .
     { gbl/fltopend.i
      &where-cond = " X_dis-dct-rule.obj-type = p-curr-obj-type and X_dis-dct-rule.obj-code = p-curr-obj-code ~
                      AND X_dis-dct-rule.discnt-role = p-discnt-role "
      &DYN_where-cond = " substitute('X_dis-dct-rule.obj-type = &1&2&1 and X_dis-dct-rule.obj-code = &3 ~
                      AND X_dis-dct-rule.discnt-role = &1&4&1 ', ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-discnt-role)"

      &use-ind    = "  "
      &by         = "  "
      }
  END.
  WHEN "templ-rl-root":U THEN DO:
    ASSIGN
    frame {&frame-name}:TITLE =
                                  substitute("&1 по шаблону &2"
                                  , title0
                                  , p-templ-rl-root
                                  )
    filter-label = substitute("&1 Один шаблон", filter-label0)
                                  .
    { gbl/fltopend.i
      &where-cond = " X_dis-dct-rule.templ-rl-root = p-templ-rl-root "
      &DYN_where-cond = " substitute('X_dis-dct-rule.templ-rl-root = &1', p-templ-rl-root )"
      &use-ind    = "  "
      &by         = "  "
      }

  END.
  WHEN "rule-num":U THEN DO:
    ASSIGN
    frame {&frame-name}:TITLE =
                                  substitute("&1 с номером правила &2"
                                  , title0
                                  , p-rule-num
                                  )
   filter-label = substitute("&1 Одно правило", filter-label0)
                                  .
    { gbl/fltopend.i
      &where-cond = " X_dis-dct-rule.rule-num = p-rule-num "
      &DYN_where-cond = " substitute('X_dis-dct-rule.rule-num = &1', p-rule-num )"
      &use-ind    = "  "
      &by         = "  "
      }

  END.
  WHEN "rl-root":U THEN DO:
    ASSIGN
    frame {&frame-name}:TITLE =
                                  substitute("&1 с номером корн.правила &2"
                                  , title0
                                  , p-rule-num
                                  )
   filter-label = substitute("&1 Одно правило", filter-label0)
                                  .
    { gbl/fltopend.i
      &where-cond = " X_dis-dct-rule.rl-root = p-rule-num "
      &DYN_where-cond = " substitute('X_dis-dct-rule.rl-root = &1', p-rule-num )"
      &use-ind    = "  "
      &by         = "  "
      }

  END.

  WHEN "pos":U THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 пригодные для POS &2"
                                    , title0
                                    , p-pos-type)
      filter-label = substitute("&1 Одно место использ", filter-label0)
                                    .
      { gbl/fltopend.i
        &where-cond = " X_dis-dct-rule.pos-type = p-pos-type "
        &DYN_where-cond = " substitute('X_dis-dct-rule.pos-type = &1&2&1', ~{&double-quote~}, p-pos-type )"
        &use-ind    = "  "
        &by         = "  "
        }

  END.
  WHEN {&table_dis-card-type} THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 применяемые типом ДК &2 эмитент &3"
                                    , title0
                                    , p-type
                                    , p-emitent-host-code)
      filter-label = substitute("&1 Один тип ДК", filter-label0)
                                    .
      { gbl/fltopend.i
        &where-cond = " X_dis-dct-rule.type = p-type and X_dis-dct-rule.emitent-host-code = p-emitent-host-code "
        &DYN_where-cond = " substitute('X_dis-dct-rule.type = &1&2&1 and X_dis-dct-rule.emitent-host-code = &3 ', ~{&double-quote~}, p-type, p-emitent-host-code)"
        &use-ind    = "  "
        &by         = "  "
        }

  END.

  WHEN "discnt-role":U THEN DO:
&SCOPED-DEFINE dis-dct-rule-code p-discnt-role
    ASSIGN
    frame {&frame-name}:TITLE =   substitute("&1 тип &2"
                                  , title0
                                  , {&dis-dct-rule-name})
    filter-label = substitute("&1 Один тип скидки", filter-label0)
                                  .
    { gbl/fltopend.i
      &where-cond = " X_dis-dct-rule.discnt-role = p-discnt-role "
      &DYN_where-cond = " substitute('X_dis-dct-rule.discnt-role = &1&2&1', ~{&double-quote~}, p-discnt-role )"
      &use-ind    = "  "
      &by         = "  "
      }

  END.
END CASE.

if not p-open-query then
REPOSITION br-dis-dct-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dIS-DCT-RULE:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

if error-status:error then do:
  REPOSITION br-dis-dct-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-dis-dct-rule in frame {&frame-name}.
APPLY "ENTRY" TO br-dis-dct-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbrtt Dialog-Frame 
PROCEDURE Openbrtt :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Скидки на типы ДК".
define variable p-host-code like ub.sysconf.host-code no-undo .
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

if not( p-curr-obj-type = "":U and p-curr-obj-code = 0 ) then do:
{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code p-host-code }
end.


&scop flt-open-open-query OPEN QUERY br-tt0-dis-dct-rule FOR EACH tt0-dis-dct-rule no-lock

&scop flt-open-dyn_open-query FOR EACH tt0-dis-dct-rule no-lock

&scop flt-open-query-handle QUERY br-tt0-dis-dct-rule:handle

&scop flt-open-open-query-tail , FIRST tt0-dis-card-type no-lock where tt0-dis-card-type.type = tt0-dis-dct-rule.type and ~
                                                                     tt0-dis-card-type.emitent-host-code = tt0-dis-dct-rule.emitent-host-code


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name tt0-dis-dct-rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name  tt0-dis-dct-rule

&scop flt-open-waitfram true

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + p-list-mode.
CASE p-list-mode :
  WHEN {&table_dis-card-type} + {&comma-char} + "temp" THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE =
                                    substitute("&1 применяемые типом ДК &2 эмитент &3"
                                    , title0
                                    , p-type
                                    , p-emitent-host-code)
      filter-label = substitute("&1 Один тип ДК", filter-label0)
                                    .
      { gbl/fltopend.i
        &where-cond = " tt0-dis-dct-rule.type = p-type and tt0-dis-dct-rule.emitent-host-code = p-emitent-host-code "
        &dyn_where-cond = " substitute('tt0-dis-dct-rule.type = &1&2&1 and tt0-dis-dct-rule.emitent-host-code = &3 ', ~{&double-quote~}, p-type, p-emitent-host-code)"
        &use-ind    = "  "
        &by         = "  "
        }

  END.
END CASE.

if not p-open-query then
REPOSITION br-tt0-dis-dct-rule to recid v-doc-rec No-ERROR.
if error-status:error then do:
  REPOSITION br-tt0-dis-dct-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-tt0-dis-dct-rule in frame {&frame-name}.
APPLY "ENTRY" TO br-tt0-dis-dct-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame 
PROCEDURE proc-b-mark :
define variable loc#log as logical no-undo .
if available X_dis-dct-rule then do:
  { gbl/markstrn.i X_dis-dct-rule v-rid-list }
  loc#log = br-dis-dct-rule:refresh() IN FRAME {&FRAME-NAME} .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      loc#log = br-dis-dct-rule:select-next-row ().
      apply "VALUE-CHANGED" to br-dis-dct-rule in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-dis-dct-rule in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame 
PROCEDURE proc-b-print :
define variable Line                as char         no-undo.
define variable v-rec as recid no-undo .
define variable ii as integer no-undo .
define variable v-mark as character no-undo .
define variable v-prod as character no-undo .
define variable v-d-name as character no-undo .
define variable v-pos-type as character no-undo .
Line = fill( "-" , 140 ) .
/*
{&sort-clmn_1} COLUMN-LABEL {&label-clmn_1} FORMAT "X(1)"
{&sort-clmn_5} COLUMN-LABEL {&label-clmn_5} FORMAT "X(12)"
{&sort-clmn_10} COLUMN-LABEL {&label-clmn_10} FORMAT "X(20)"
*/

&scop cd-type-code X_dis-dct-rule.pos-type
define frame list
v-mark COLUMN-LABEL {&label-clmn_1} FORMAT "X(1)"
{&sort-clmn_2} COLUMN-LABEL {&label-clmn_2} FORMAT ">>>>9"
{&sort-clmn_3} COLUMN-LABEL {&label-clmn_3}
{&sort-clmn_4} COLUMN-LABEL {&label-clmn_4} FORMAT ">>>>>>>>9"
v-pos-type COLUMN-LABEL {&label-clmn_5} FORMAT "X(10)"
{&sort-clmn_6} COLUMN-LABEL {&label-clmn_6} FORMAT "X(3)"
{&sort-clmn_7} COLUMN-LABEL {&label-clmn_7} FORMAT ">>>>>>>>9"
v-d-name COLUMN-LABEL {&label-clmn_8} FORMAT "X(20)"
{&sort-clmn_9} COLUMN-LABEL {&label-clmn_9} FORMAT ">>>>>>>>9"
{&sort-clmn_10} COLUMN-LABEL {&label-clmn_10} FORMAT ">>>>>>>>9"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>9") )
AT 86 format "X(15)" SKIP
Line format "x(130)" AT 1
with width {&DOS_CW} down use-text stream-io no-box .
v-rec = recid(X_dis-dct-rule).
DO WHILE available X_dis-dct-rule :
  GET prev br-dis-dct-rule NO-LOCK .
END.
GET next br-dis-dct-rule NO-LOCK .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM HEADER
Line format "X(130)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
VIEW stream PrnLibStream FRAME CliBottomFrame .
PUT stream PrnLibStream space(30)
frame {&frame-name}:title format "X(100)" SKIP(2) .
FORM with frame List .
DO WHILE available X_dis-dct-rule :
  DISPLAY stream PrnLibStream
  {&sort-clmn_1} @ v-mark
  {&sort-clmn_2}
  {&sort-clmn_3}
  {&sort-clmn_4}
  {&sort-clmn_5} @ v-pos-type
  {&sort-clmn_6}
  {&sort-clmn_7}
  {&sort-clmn_8} @ v-d-name
  {&sort-clmn_9}
  {&sort-clmn_10}
  with frame List .
  DOWN stream PrnLibStream 1 with frame List .
  ii =  ii + 1 .
  if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
  run waitfram-show in this-procedure ( input ("Просмотрено строк : " + string( ii )) ) .
  GET next br-dis-dct-rule .
END.
run waitfram-hide in this-procedure .
PUT stream PrnLibStream Line format "X(130)" SKIP.
HIDE stream PrnLibStream FRAME BottomFrame .
output stream PrnLibStream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

reposition br-dis-dct-rule to recid v-rec no-error.
if error-status:error then do:
  reposition br-dis-dct-rule to row 1 no-error.
end.
APPLy "ENTRY" to br-dis-dct-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
assign
  tbl = 'dis-dct-rule'
  join-tbl = 'X_dis-dct-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('rule-num', '№ правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('rl-root', '№ корн.правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pos-type', 'Место использ.', 'cd-types-discnt',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('discnt-role', 'Тип скидки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('type', 'Тип карты', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('emitent-host-code', 'Код эмитента', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                     ,INPUT (filter-point + {&delim-par} + filter-label)
                     ,INPUT tbl
                     ,INPUT join-tbl
                     ,INPUT fld
                     ,INPUT lab
                     ,INPUT spr
                     ,INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION cd-type-name Dialog-Frame 
FUNCTION cd-type-name RETURNS CHARACTER
  ( input p-pos-type as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
&SCOPED-DEFINE cd-type-code p-pos-type
RETURN {&cd-type-name}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION dis-dct-rule-name Dialog-Frame 
FUNCTION dis-dct-rule-name RETURNS CHARACTER
  ( input p-dis-dct-rule-code as character ) :

&scop dis-dct-rule-code p-dis-dct-rule-code
return {&dis-dct-rule-name}.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

