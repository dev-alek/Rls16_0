&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_c-rvs-doc FOR c-rvs-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История документов сверок

Автор: Шаланин Сергей
Дата создания: 10/07/16
Author: Bakhtadze Natalya
Creation date: 10/07/16

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as handle    no-undo.
define input parameter parlist-mode  as character no-undo.
define input parameter parstatus     as character no-undo.
define output parameter out-rec      as recid     no-undo.

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "История документов сверок":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/flt-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ str/shftnmef.i c-rvs-doc shift-name }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
{ str/lib-rvs.i  }


define variable br-handle as handle no-undo.

define variable rvs-rec          as   recid            no-undo.
define variable varlog           as   logical          no-undo.
define variable filter-label as character no-undo init "История док-тов сверок" .
define variable filter-label0 as character no-undo init "История док-тов сверок" .
define variable filter-point0 as character no-undo init "rvscdocs" .
define variable filter-point as character no-undo init "rvscdocs" .
define variable sort-column-name as character no-undo .
define variable v-rid-list as character no-undo .
define variable vcli-name like ub.clients.obj-name no-undo.
define variable vhost-name like ub.clients.obj-name no-undo.
define variable print-option as character no-undo.
define variable v-r-b-abbr like ub.currency.curr-abbr no-undo .
define variable add-option as character no-undo.
define variable v-doc-rec as recid no-undo .
define buffer buf_cli for ub.clients.
define buffer buf_obj for ub.clients .
define buffer buf_rvs-doc for ub.rvs-doc.


&SCOP type-list "{&bef-income},{&bef-expense},{&bef-writeoff},{&bef-inventory}"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-rvs-doc

/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs mark-string( recid(X_c-rvs-doc), v-rid-list ) X_c-rvs-doc.doc-type X_c-rvs-doc.status_ X_c-rvs-doc.doc-code X_c-rvs-doc.fact-date shift-name-no-err (buffer X_c-rvs-doc) (substring ((string (X_c-rvs-doc.doc-date)), 1, 5))  (substring ((string (X_c-rvs-doc.shift-date)), 1, 5))  (trim (X_c-rvs-doc.obj-type) + " " + string (X_c-rvs-doc.obj-code, ">>>>9")) usrfulnf(X_c-rvs-doc.corr-user-name) X_c-rvs-doc.corr-date string(X_c-rvs-doc.corr-time, "HH:mm:ss")
/*&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs X_c-rvs-doc.bge-date*/
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-docs X_c-rvs-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-docs X_c-rvs-doc
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH X_c-rvs-doc NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH X_c-rvs-doc where  x_c-rcv-doc.obj-type = v-cntxt-obj-type and  x_c-rcv-doc.obj-code = v-cntxt-obj-code and   x_c-rcv-doc.is-del = yes and x_c-rcv-doc.action = integer({&hn-delete}) NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-docs X_c-rvs-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs X_c-rvs-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit   b-lkp B-print B-sch ~
B-Help BR-docs ED-notes sch-code sch-date sch-fact sch-num mark-num ~
v_operator v_deliver v_receiver v_creid
&Scoped-Define DISPLAYED-OBJECTS ED-notes sch-code sch-date sch-fact ~
sch-num mark-num v_operator v_deliver v_receiver v_creid

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-print
       MENU-ITEM m_one          LABEL "Документ"
       MENU-ITEM m_list         LABEL "Список"        .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просм"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 8 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.


DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "дате"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-fact AS DATE FORMAT "99/99/9999":U
     LABEL "дате факт"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-num AS INTEGER FORMAT ">>>>>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v_creid AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v_deliver AS CHARACTER FORMAT "X(256)":U
     LABEL "Передал"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v_operator AS CHARACTER FORMAT "X(256)":U
     LABEL "Исп"
      VIEW-AS TEXT
     SIZE 14 BY .71
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v_receiver AS CHARACTER FORMAT "X(256)":U
     LABEL "Получил"
      VIEW-AS TEXT
     SIZE 14 BY .79
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-docs FOR
      X_c-rvs-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs NO-LOCK DISPLAY
      mark-string( recid(X_c-rvs-doc), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
X_c-rvs-doc.rvs-type COLUMN-LABEL "Т" FORMAT "X(1)":U
X_c-rvs-doc.status_ COLUMN-LABEL "Стат" FORMAT "X(4)":U
X_c-rvs-doc.rvs-code FORMAT "X(14)":U
X_c-rvs-doc.fact-date FORMAT "99/99/99":U
shift-name-no-err (buffer X_c-rvs-doc) COLUMN-LABEL "№" FORMAT "X(6)":U
(substring ((string (X_c-rvs-doc.doc-date)), 1, 5)) COLUMN-LABEL "Дата" FORMAT "X(5)":U
/*X_c-rvs-doc.inter_ COLUMN-LABEL "В" FORMAT "+/":U*/
/*X_c-rvs-doc.exter_ COLUMN-LABEL "Ш" FORMAT "+/":U*/
/*X_c-wth-doc.auto-fill COLUMN-LABEL "А" FORMAT "+/":U*/
/*X_c-rvs-doc.cli-name FORMAT "X(27)":U*/
/*X_c-rvs-doc.doc-sum COLUMN-LABEL "Сумма по док-ту" FORMAT "->,>>>,>>>,>>9.99":U           */
/*(substring ((string (X_c-wth-doc.shift-date)), 1, 5)) COLUMN-LABEL "Смена" FORMAT "X(5)":U*/
/*X_c-rvs-doc.fact-sum FORMAT "->,>>>,>>>,>>9.99":U                                         */
/*X_c-rvs-doc.acc-date COLUMN-LABEL "Проводка" FORMAT "99/99/99":U                          */
/*X_c-rvs-doc.bge-date COLUMN-LABEL "Внеш.пров." FORMAT "99/99/99":U                        */
(trim (X_c-rvs-doc.obj-type) + " " + string (X_c-rvs-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объект" FORMAT "X(9)":U
/*X_c-rvs-doc.source-type + {&space-char} + X_c-wth-doc.source-ref COLUMN-LABEL "На документ" FORMAT "X(26)":U*/
usrfulnf(X_c-rvs-doc.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
X_c-rvs-doc.corr-date COLUMN-LABEL "Дата измен" FORMAT "99/99/9999":U
string(X_c-rvs-doc.corr-time, "HH:mm:ss") COLUMN-LABEL "Время измен." FORMAT "X(8)":U
/*ENABLE*/
/*X_c-rvs-doc.bge-date*/
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1.13
     b-lkp AT ROW 1 COL 38
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-docs AT ROW 2.5 COL 1.13
     ED-notes AT ROW 19.92 COL 1 NO-LABEL
     sch-code AT ROW 22.54 COL 17.63 COLON-ALIGNED
     sch-date AT ROW 22.54 COL 40.75 COLON-ALIGNED
     sch-fact AT ROW 22.58 COL 65.63 COLON-ALIGNED
     sch-num AT ROW 22.58 COL 80.63 COLON-ALIGNED NO-LABEL
     mark-num AT ROW 1 COL 10 COLON-ALIGNED NO-LABEL
     v_operator AT ROW 18.88 COL 4 COLON-ALIGNED
     v_deliver AT ROW 18.88 COL 29 COLON-ALIGNED
     v_receiver AT ROW 18.88 COL 54 COLON-ALIGNED
     v_creid AT ROW 18.92 COL 79 COLON-ALIGNED
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 22.54 COL 1.5
          FGCOLOR 4
     SPACE(88.38) SKIP(0.06)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "История документов сверки"
         DEFAULT-BUTTON b-lkp.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_c-wth-doc B "?" ? ub c-wth-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-wth-doc NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame 
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просм */
DO:
      define variable next-prev as character no-undo .
    
     IF NOT AVAIL x_c-rvs-doc THEN RETURN NO-apply.
    br-handle = {&browse-name}:handle.
    {&no-rvs}
    case x_c-rvs-doc.rvs-type
        :
        when {&rvs-before-doc}
        or 
        when {&rvs-after-doc}
        then 
            do:
                { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-on-doc_lookup':U
        {&cntxt-object}
        x_c-rvs-doc.host-code
        x_c-rvs-doc.obj-type
        x_c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
            end.
        when {&rvs-shift} then 
            do:
                { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-shift_lookup':U
        {&cntxt-object}
        x_c-rvs-doc.host-code
        x_c-rvs-doc.obj-type
        x_c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
            end.
        when {&rvs-control} then 
            do:
                { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-control_lookup':U
        {&cntxt-object}
        x_c-rvs-doc.host-code
        x_c-rvs-doc.obj-type
        x_c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
            end.
        otherwise 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Неизвестный тип документа сверки" skip
                "Тип документа сверки" x_c-rvs-doc.rvs-type skip
                "Код документа сверки" x_c-rvs-doc.rvs-code skip
                view-as alert-box error .
            undo, return no-apply .
        end.
    end case .
    
        if varlog <> yes then 
        do: 
            return no-apply. 
        end.
  ASSIGN
  rvs-rec = RECID( x_c-rvs-doc )
  next-prev = '':U
  .
    
    DO WHILE next-prev = '':U:
        
         if NOT available x_c-rvs-doc then do:
        message "Неправильно выбран документ сверки." view-as alert-box ERROR.
        return no-apply.
      end.
      
            run str/rvs-c-doc.w
                ( input        parparentproc
                ,input        {&lookup}
                ,input        x_c-rvs-doc.rvs-type
                ,input        no
                ,input-output rvs-rec
                ,input-output next-prev
                ,input this-procedure:handle
            
                ) no-error.
            if error-status :error then
            do:
                return no-apply.
            end.
    end.
    
    RUN OpenBr in this-procedure ( input  yes, input no, input '':U).
    reposition {&browse-name}  to recid rvs-rec no-error.
    apply "entry" to {&browse-name} in frame {&frame-name}.
    apply "value-changed" to {&browse-name} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  if not avail X_c-rvs-doc then return no-apply.
  if print-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-option = '':U then return no-apply.
  run proc-b-print in this-procedure ( input print-option) no-error.
  if error-status:error then do:
    print-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-docs.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
run proc-b-sch in this-procedure no-error.
if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define BROWSE-NAME BR-docs
&Scoped-define SELF-NAME BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON ANY-PRINTABLE OF BR-docs IN FRAME Dialog-Frame
DO:
   sch-code:screen-value = sch-code:screen-value + last-event:label.
    apply "entry" to sch-code in frame {&frame-name}.
apply "end" to sch-code in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame
ON RETURN OF BR-docs IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME {&frame-name} DO:
  apply "choose" to b-lkp in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-docs Dialog-Frame                      */
/*ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame                                   */
/*DO:                                                                                 */
/*    define buffer buf-oper for ub.clients.                                          */
/*    define buffer buf-deliver for ub.clients.                                       */
/*    define buffer buf-receiver for ub.clients.                                      */
/*                                                                                    */
/*      if available X_c-rvs-doc then do:                                             */
/*        FIND buf-oper NO-LOCK WHERE                                                 */
/*                buf-oper.obj-type = X_c-rvs-doc.obj-type AND                        */
/*                buf-oper.obj-code = X_c-rvs-doc.obj-code NO-ERROR.                  */
/*        FIND buf-deliver NO-LOCK WHERE                                              */
/*                buf-deliver.obj-type = {&prs} AND                                   */
/*                buf-deliver.obj-code = X_c-wth-doc.deliver NO-ERROR.                */
/*        FIND buf-receiver NO-LOCK WHERE                                             */
/*                buf-receiver.obj-type = {&prs} AND                                  */
/*                buf-receiver.obj-code = X_c-wth-doc.receiver NO-ERROR.              */
/*        assign                                                                      */
/*        ed-notes = X_c-wth-doc.PS                                                   */
/*        v_operator = ( IF AVAIL buf-oper THEN buf-oper.obj-name ELSE "":U ).        */
/*        v_deliver = ( IF AVAIL buf-deliver THEN buf-deliver.obj-name ELSE "":U ).   */
/*        v_receiver = ( IF AVAIL buf-receiver THEN buf-receiver.obj-name ELSE "":U ).*/
/*        .                                                                           */
/*        { gbl/usrfulnm.i                                                            */
/*        X_c-wth-doc.creid                                                           */
/*        v_creid }                                                                   */
/*                                                                                    */
/*    end.                                                                            */
/*    else do:                                                                        */
/*        assign                                                                      */
/*        ed-notes = '':U                                                             */
/*        v_operator = '':U                                                           */
/*        v_deliver = '':U                                                            */
/*        v_receiver = '':U                                                           */
/*        v_creid = '':U                                                              */
/*        .                                                                           */
/*    end.                                                                            */
/*    display                                                                         */
/*    ed-notes                                                                        */
/*    v_creid                                                                         */
/*    v_deliver                                                                       */
/*    v_operator                                                                      */
/*    v_receiver                                                                      */
/*    with frame {&frame-name}.                                                       */
/*  /*                                                                                */
/*  IF p-doc-rec <> RECID( X_c-wth-doc ) THEN DO:                                     */
/*    ASSIGN sch-num = 0.                                                             */
/*    HIDE sch-num IN FRAME {&FRAME-NAME}.                                            */
/*  END.                                                                              */
/*  */                                                                                */
/*                                                                                    */
/*                                                                                    */
/*END.                                                                                */
/*                         */
/*/* _UIB-CODE-BLOCK-END */*/
/*&ANALYZE-RESUME          */


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* Список */
DO:
 assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_one /* Документ */
DO:
 assign
  print-option = 'ONE':U.
  APPLY "CHOOSE" to b-print  in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
   run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* номеру */
DO:
   run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON CTRL-J OF sch-date IN FRAME Dialog-Frame /* дате */
DO:
   run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-date, "doc-date") no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON RETURN OF sch-date IN FRAME Dialog-Frame /* дате */
DO:
    run proc-find-date in  this-procedure ( input no, input frame {&frame-name} sch-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-fact
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact Dialog-Frame
ON CTRL-J OF sch-fact IN FRAME Dialog-Frame /* дате факт */
DO:
   run proc-find-date in this-procedure ( input yes, input frame {&frame-name} sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-fact Dialog-Frame
ON RETURN OF sch-fact IN FRAME Dialog-Frame /* дате факт */
DO:
  run proc-find-date in this-procedure ( input no, input frame {&frame-name} sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.


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
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-lkp }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }

{ gbl/brwrefre.i " v-doc-rec = recid(X_c-rvs-doc). run openbr in this-procedure ( input yes, input no, input '':U). ~
               reposition br-docS to recid v-doc-rec no-error. ~
               APPLY 'ENTRY' to br-docs. APPLY 'VALUE-CHANGED' to br-docS. " }

{ gbl/brwrepos.i
  &line-num=5
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  /*осуществим проверку входных параметров*/
  /*найдем мы в БД объекта* находимся или нет*/
  FIND FIRST ub.sys-ctrl NO-LOCK.
  if avail sys-ctrl then do:
    FIND FIRST db no-LOCK where
              db.db-num = sys-ctrl.db-num NO-ERROR.
    if not avail db then do:
      message "Отсутствует запись о БД (db)"
      view-as alert-box ERROR.
      return error.
    end.
  END.
  FIND FIRST buf_obj No-LOCK WHERE
                  buf_obj.obj-type = v-cntxt-obj-type and
                  buf_obj.obj-code = v-cntxt-obj-code No-ERROR.

    if parlist-mode =  {&g___object} then dO:
        FIND FIRST buf_cli No-LOCK WHERE
                        buf_cli.obj-type = v-cntxt-obj-type and
                        buf_cli.obj-code = v-cntxt-obj-code No-ERROR.
        if not avail buf_cli then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.
    end.

  { gbl/r-b-abbr.i  buf_obj.host-code v-r-b-abbr }
  v-rid-list = string(out-rec).
  RUN MyEnable in this-procedure .

  HIDE mark-num in frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY ED-notes sch-code sch-date sch-fact sch-num mark-num v_operator
          v_deliver v_receiver v_creid
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-lkp B-print B-sch B-Help BR-docs ED-notes
         sch-code sch-date sch-fact sch-num mark-num v_operator v_deliver
         v_receiver v_creid
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  ASSIGN
  br-docs:NUM-LOCKED-COLUMNS IN FRAME  {&FRAME-NAME}  = 4
/*  X_c-rvs-doc.bge-date:READ-ONLY IN BROWSE {&BROWSE-NAME} = YES*/
  b-print:MENU-MOUSE = 1
.
DISPLAY
ED-notes
sch-code
sch-date
sch-fact
sch-num
mark-num
v_operator
v_deliver
v_receiver
v_creid
WITH FRAME {&frame-name} .
ENABLE
b-quit 
b-lkp
B-sch
B-print
B-Help
BR-docs
ED-notes
sch-code
sch-date
sch-fact
sch-num
mark-num
v_operator
v_deliver
v_receiver
v_creid
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
RUn openbr in this-procedure ( input  yes, input no, input '':U).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "История документов сверки".
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

&scop flt-open-open-query OPEN QUERY br-docs FOR EACH X_c-rvs-doc

&scop flt-open-dyn_open-query FOR EACH X_c-rvs-doc

&scop flt-open-query-handle QUERY br-docs:handle

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_c-rvs-doc

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name X_c-rvs-doc

&scop flt-open-waitfram yes

define variable l-open-query as logical   no-undo .
define variable vartest-asi like ub.rvs-doc.rvs-type no-undo .

assign vartest-asi = {&test-asi} .

CASE parlist-mode :
WHEN {&g___object} THEN DO:
  if p-open-query then do:
    ASSIGN
    frame {&frame-name}:TITLE = title0 + " Удаленные документы: Объект: " + v-cntxt-obj-type + string(v-cntxt-obj-code).
  end.
    filter-label = substitute("&1 Удаленные документы по одному объекту", filter-label0)
    .
  { gbl/fltopend.i
    &where-cond = " ~
      X_c-rvs-doc.host-code = v-cntxt-host-code-obj AND ~
      X_c-rvs-doc.obj-type  = v-cntxt-obj-type  AND ~
      X_c-rvs-doc.obj-code  = v-cntxt-obj-code  AND ~
      X_c-rvs-doc.rvs-type <> vartest-asi       AND ~
      X_c-rvs-doc.is-del = yes and ~
     x_c-rvs-doc.action = integer({&hn-delete})
      ~ "
    &dyn_where-cond = " substitute(' X_c-rvs-doc.host-code = &1 AND ~
      X_c-rvs-doc.obj-type  = &2&3&2  AND ~
      X_c-rvs-doc.obj-code  = &4  AND  ~
      X_c-rvs-doc.rvs-type <> &2&5&2
      X_c-rvs-doc.is-del = yes ', v-cntxt-host-code-obj, ~{&double-quote~}, v-cntxt-obj-type, v-cntxt-obj-code, vartest-asi )  "

    &use-ind    = " USE-INDEX stat-fact "
    &by         = "  " }
END.

/*WHEN "auto":U THEN DO:                                                                                                                                               */
/*  if p-open-query then do:                                                                                                                                           */
/*    ASSIGN                                                                                                                                                           */
/*    frame {&frame-name}:TITLE = title0 + " Удаленные документы: Объект: " + v-cntxt-obj-type + string(v-cntxt-obj-code) + {&space-char} + "Автоматические документы".*/
/*  end.                                                                                                                                                               */
/*  filter-label = substitute("&1 Удаленные автоматические док-ты по одному объекту", filter-label0)*/
/*    .*/


END CASE.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
DEFINE INPUT PARAMETER loc-option as character no-undo.
define variable glog as logical no-undo .
if loc-option = '':U then return error.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_rvs-doc_print':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    glog
  }
IF glog <> YES
THEN DO:
RETURN ERROR.
END.


loc-option = ''.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
/*PROCEDURE proc-b-sch :                                                                    */
/*/*------------------------------------------------------------------------------          */
/*Purpose:                                                                                  */
/*Parameters:  <none>                                                                       */
/*Notes:                                                                                    */
/*------------------------------------------------------------------------------*/          */
/*assign                                                                                    */
/*tbl = 'c-wth-doc'                                                                         */
/*join-tbl = 'X_c-wth-doc'                                                                  */
/*fld = ""                                                                                  */
/*lab = ""                                                                                  */
/*spr = ""                                                                                  */
/*dim = '0'                                                                                 */
/*.                                                                                         */
/*                                                                                          */
/*run fltfield-add in this-procedure('doc-code', 'Номер', '',                               */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',       */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('doc-date', 'Дата', '',                                */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('fact-date', 'Факт', '',                               */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('doc-type', 'Тип', 'trn-type',                         */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('status_', 'Статус', 'trn-stat',                       */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('inter_', 'Внутр', '',                                 */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('exter_', 'Внеш', '',                                  */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('cli-type{&delim-flt}cli-code', 'Контрагент', 'cli',   */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('cli-name', 'Имя контраг', '',                         */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('doc-sum', 'Сумма', '',                                */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('fact-sum', 'Сумма факт', '',                          */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('shift-date', 'Дата смены', '',                        */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('shift-name', 'Номер смены', '',                       */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('shift-num', 'Порядок смены', '',                      */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('acc-date', 'Дата пров', '',                           */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('bge-date', 'Дата внеш.пров.', '',                     */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('scf-date', 'Дата сч-факт', '',                        */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('source-ref', 'Ссылка на док-т', '',                   */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('borned', 'Порожден', '',                              */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('operator', 'Исполнитель', 'cli',                      */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('deliver', 'Доставил', 'cli',                          */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('receiver', 'Получил', 'cli',                          */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('PS', 'Комментарий', '',                               */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('creid', 'Опер-р', 'usr',                              */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('credate', 'Дата создания', '',                        */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('corr-date', 'Дата корр./удаления', '',                */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('real-corr-date', 'Физическая дата корр./удаления', '',*/
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('corr-time', 'Время корр.', 'time',                    */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',                    */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*run fltfield-add in this-procedure('corr-user-db-num', '', '',                            */
/*input-output fld, input-output lab, input-output spr, input-output dim)  no-error.        */
/*                                                                                          */
/*                                                                                          */
/*                                                                                          */
/*Filter-Block:                                                                             */
/*DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block                                       */
/*  ON ERROR   UNDO Filter-Block, LEAVE Filter-Block                                        */
/*  ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :                                      */
/*run gbl/filter.w ( INPUT parparentproc                                                    */
/*             , INPUT (filter-point + {&delim-par} +                                       */
/*                      filter-label +  {&delim-par} +                                      */
/*                      string(yes))                                                        */
/*             , INPUT tbl                                                                  */
/*             , INPUT join-tbl                                                             */
/*             , INPUT fld                                                                  */
/*             , INPUT lab                                                                  */
/*             , INPUT spr                                                                  */
/*             , INPUT dim ).                                                               */
/*RUN OpenBr in this-procedure ( input  yes, input no, input '':U).                         */
/*END. /* Filter-Block */                                                                   */
/*                                                                                          */
/*                                                                                          */
/*END PROCEDURE.                                                                            */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.add-line.doc-code no-undo.
display
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
with frame {&frame-name}.

assign
pardoc-code = {&double-quote} + pardoc-code + {&double-quote}.
run OpenBr in this-procedure
  (input false /* p-open-query */
  ,input par-next  /* p-find-next  */
  ,input substitute("and X_c-rvs-doc.rvs-code   begins &1 "
    , pardoc-code)
  ).
apply "entry":u to sch-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-date Dialog-Frame
PROCEDURE proc-find-date :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.c-rvs-doc.doc-date no-undo.
define input parameter parwhat-date as character no-undo.

define variable var-datechr as character no-undo.
display
'':U @ sch-code
with frame {&frame-name}.

assign
var-datechr = string(day(par-date)) + {&slash-char} +
              string(month(par-date)) + {&slash-char} +
              string(year(par-date)).

case parwhat-date:
  when "doc-date":U then do:
    display
    "  /  /":U @ sch-fact
    with frame {&frame-name}.
    run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input true  /* p-find-next  */
    ,input substitute("and X_c-rvs-doc.doc-date = &1 "
      , var-datechr)
    ).
    apply "entry":u to sch-date in frame {&frame-name}.
  end.
  when "fact-date":U then do:
    display
    "  /  /":U @ sch-date
    with frame {&frame-name}.
    run OpenBr in this-procedure
      (input false /* p-open-query */
      ,input true  /* p-find-next  */
      ,input substitute("and X_c-rvs-doc.fact-date = &1 "
      , var-datechr)
      ).
    apply "entry":u to sch-fact in frame {&frame-name}.
  end.

END case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-list Dialog-Frame
/*PROCEDURE proc-print-list :                                               */
/*DEFINE VARIABLE vardoc-rec as recid no-undo.                              */
/*DEFINE VARIABLE for-doc-date as character no-undo.                        */
/*DEFINE VARIABLE for-shift-date as character no-undo.                      */
/*DEFINE VARIABLE for-obj as character no-undo.                             */
/*define variable accum-count as integer.                                   */
/*define variable accum-doc-sum as decimal.                                 */
/*define variable accum-fact-sum as decimal.                                */
/*define variable date_string     as      char    no-undo.                  */
/*define variable loc-v_operator  as   char    no-undo.                     */
/*define variable loc-v_deliver as      char    no-undo.                    */
/*define variable loc-v_receiver as      char    no-undo.                   */
/*define variable v-header-base-curr as character no-undo .                 */
/*define variable v-shift-name-num as character no-undo.                    */
/*define variable v-curr-r-b as character no-undo .                         */
/*define variable glog as logical no-undo .                                 */
/*{ gbl/curr-r-b.i                                                          */
/*  v-curr-r-b                                                              */
/*}                                                                         */
/*if v-curr-r-b = {&r-b-base} then do:                                      */
/*  assign                                                                  */
/*  v-header-base-curr = string( "( Б.Вал. - " + caps( v-r-b-abbr ) + " )" )*/
/*  .                                                                       */
/*end.                                                                      */
/*                                                                          */
/*define variable Line as character  no-undo.                               */
/*define buffer buf-oper for ub.clients.                                    */
/*define buffer buf-deliver for ub.clients.                                 */
/*define buffer buf-receiver for ub.clients.                                */
/*                                                                          */

/*DEFINE FRAME rvs-list                                                                        */
/*X_c-wth-doc.rvs-type COLUMN-LABEL "Т" FORMAT "X(1)"                                          */
/*X_c-wth-doc.status_ COLUMN-LABEL "Стат" FORMAT "X(4)"                                        */
/*X_c-wth-doc.rvs-code                                                                         */
/*for-doc-date  COLUMN-LABEL "Дата" FORMAT "X(5)"                                              */
/*X_c-rvs-doc.fact-date                                                                        */
/*v-shift-name-num  COLUMN-LABEL "N см." FORMAT "X(6)"                                         */
/*for-shift-date  COLUMN-LABEL "Смена" FORMAT "X(5)"                                           */
/*/*X_c-rvs-doc.inter_ COLUMN-LABEL "В"*/                                                      */
/*/*X_c-rvs-doc.exter_ COLUMN-LABEL "Ш"*/                                                      */
/*/*X_c-rvs-doc.cli-name FORMAT "X(26)"*/                                                      */
/*for-obj COLUMN-LABEL "Объект" FORMAT "X(9)"                                                  */
/*/*X_c-rvs-doc.doc-sum COLUMN-LABEL "Сумма по док-ту"*/                                       */
/*/*X_c-rvs-doc.fact-sum                              */                                       */
/*/*X_c-wth-doc.source-ref COLUMN-LABEL "На документ" */                                       */
/*/*X_c-wth-doc.acc-date COLUMN-LABEL "Проводка"  */                                           */
/*/*X_c-wth-doc.bge-date COLUMN-LABEL "Внеш.пров."*/                                           */
/*/*loc-v_operator COLUMN-LABEL "Исп" FORMAT "X(8)"     */                                     */
/*/*loc-v_deliver  COLUMN-LABEL "Передал" FORMAT "X(8)" */                                     */
/*/*loc-v_receiver  COLUMN-LABEL "Получил" FORMAT "X(8)"*/                                     */
/*/*X_c-wth-doc.creid  COLUMN-LABEL "Опер" FORMAT "X(8)"*/                                     */
/*HEADER  date_string AT 5 format "X(35)"                                                      */
/*v-header-base-curr        format "X(20)" AT 42                                               */
/*string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP*/
/*Line format "X({&A4_LS})" AT 1                                                               */
/*with width {&DOS_CW_2} down stream-io use-text    .                                          */
/*                                                                                             */
/*if b-sch:tooltip in frame {&frame-name} = '' then do:                                        */
/*    message "В списке не установлен фильтр" SKIP                                             */
/*                  "Печать списка может занять длительное время" SKIP                         */
/*                  "Продолжать?"                                                              */
/*    view-as alert-box QUESTION buttons YES-NO update glog.                                   */
/*    if not glog then return.                                                                 */
/*end.                                                                                         */
/*                                                                                             */
/*Line = fill("-", {&A4_LS}).                                                                  */
/*date_string = cur-time-print() .                                                             */
/*run prn-lib-open-stream  in this-procedure (                                                 */
/*                                             input parParentProc                             */
/*                                            ,input {&LS_PS_A4}                               */
/*                                            ,input yes /*p-is-stream*/                       */
/*                                            ,input no /*p-append*/                           */
/*                                            ).                                               */
/*                                                                                             */
/*                                                                                             */
/*PUT  STREAM PrnLibStream                                                                     */
/*SPACE(25) ( frame {&frame-name}:title )                                                      */
/*format "x(90)" SKIP(1) .                                                                     */
/*FORM HEADER                                                                                  */
/*Line format "X({&A4_LS})" AT 1 SKIP                                                          */
/*"Продолжение - на следующей странице" AT 30 SKIP                                             */
/*with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .                      */
/*VIEW  STREAM PrnLibStream FRAME BottomFrame .                                                */
/*                                                                                             */
/*FORM with FRAME wth-list  .                                                                  */
/*run waitfram-show in this-procedure ( input "Ждите...").                                     */
/*vardoc-rec = recid(X_c-wth-doc).                                                             */
/*DO WHILE available X_c-wth-doc :                                                             */
/*  GET prev br-docs.                                                                          */
/*END.                                                                                         */
/*GET next br-docs.                                                                            */
/* DO WHILE available X_c-wth-doc :                                                            */
/*        FIND buf-oper NO-LOCK WHERE                                                          */
/*                buf-oper.obj-type = {&prs} AND                                               */
/*                buf-oper.obj-code = X_c-wth-doc.operator NO-ERROR.                           */
/*        FIND buf-deliver NO-LOCK WHERE                                                       */
/*                buf-deliver.obj-type = {&prs} AND                                            */
/*                buf-deliver.obj-code = X_c-wth-doc.deliver NO-ERROR.                         */
/*        FIND buf-receiver NO-LOCK WHERE                                                      */
/*                buf-receiver.obj-type = {&prs} AND                                           */
/*                buf-receiver.obj-code = X_c-wth-doc.receiver NO-ERROR.                       */
/*        assign                                                                               */
/*        loc-v_operator = ( IF AVAIL buf-oper THEN buf-oper.obj-name ELSE "":U ).             */
/*        loc-v_deliver = ( IF AVAIL buf-deliver THEN buf-deliver.obj-name ELSE "":U ).        */
/*        loc-v_receiver = ( IF AVAIL buf-receiver THEN buf-receiver.obj-name ELSE "":U )      */
/*        /*loc-v_creid = X_c-wth-doc.creid*/                                                  */
/*        .                                                                                    */
/*  Display STREAM PrnLibStream                                                                */
/*    X_c-wth-doc.doc-type                                                                     */
/*    X_c-wth-doc.status_                                                                      */
/*    X_c-wth-doc.doc-code                                                                     */
/*    (substring ((string (X_c-wth-doc.doc-date)), 1, 5)) @ for-doc-date                       */
/*    X_c-wth-doc.fact-date                                                                    */
/*    shift-name-no-err(buffer X_c-wth-doc)  @ v-shift-name-num                                */
/*    (substring ((string (X_c-wth-doc.shift-date)), 1, 5)) @ for-shift-date                   */
/*    X_c-wth-doc.inter_                                                                       */
/*    X_c-wth-doc.exter_                                                                       */
/*    X_c-wth-doc.cli-name                                                                     */
/*    (trim (X_c-wth-doc.obj-type) + " " + string (X_c-wth-doc.obj-code, ">>>>9")) @ for-obj   */
/*    X_c-wth-doc.doc-sum                                                                      */
/*    X_c-wth-doc.fact-sum                                                                     */
/*    X_c-wth-doc.source-ref                                                                   */
/*    X_c-wth-doc.acc-date                                                                     */
/*    X_c-wth-doc.bge-date                                                                     */
/*    loc-v_operator                                                                           */
/*     loc-v_deliver                                                                           */
/*    loc-v_receiver                                                                           */
/*    X_c-wth-doc.creid                                                                        */
/*  with FRAME wth-list .                                                                      */
/*  DOWN STREAM PrnLibStream 1                                                                 */
/*  with FRAME wth-list  .                                                                     */
/*  assign                                                                                     */
/*  accum-count = accum-count + 1                                                              */
/*/*  accum-doc-sum = accum-doc-sum + X_c-wth-doc.doc-sum     */                               */
/*/*    accum-fact-sum = accum-fact-sum + X_c-wth-doc.fact-sum*/                               */
/*    .                                                                                        */
/*  GET next br-docs.                                                                          */
/*  END.                                                                                       */
/*  UNDERLINE  STREAM PrnLibStream                                                             */
/*    X_c-wth-doc.doc-type                                                                     */
/*    X_c-wth-doc.status_                                                                      */
/*    X_c-wth-doc.doc-code                                                                     */
/*    for-doc-date                                                                             */
/*    X_c-wth-doc.fact-date                                                                    */
/*    v-shift-name-num                                                                         */
/*    for-shift-date                                                                           */
/*    X_c-wth-doc.inter_                                                                       */
/*    X_c-wth-doc.exter_                                                                       */
/*    X_c-wth-doc.cli-name                                                                     */
/*    for-obj                                                                                  */
/*    X_c-wth-doc.doc-sum                                                                      */
/*    X_c-wth-doc.fact-sum                                                                     */
/*    X_c-wth-doc.source-ref                                                                   */
/*    X_c-wth-doc.acc-date                                                                     */
/*    X_c-wth-doc.bge-date                                                                     */
/*        loc-v_operator                                                                       */
/*        loc-v_deliver                                                                        */
/*        loc-v_receiver                                                                       */
/*    X_c-wth-doc.creid                                                                        */
/*  with FRAME wth-list .                                                                      */
/*  DISPLAY STREAM PrnLibStream                                                                */
/*  ("ИТОГО" + {&space-char} + string(accum-count))  @ X_c-wth-doc.doc-code                    */
/* accum-doc-sum @ X_c-wth-doc.doc-sum                                                         */
/*  accum-fact-sum @ X_c-wrsv-doc.fact-sum                                                     */
/*  with frame wth-list.                                                                       */
/*HIDE  STREAM PrnLibStream FRAME BottomFrame .                                                */
/*HIDE  STREAM PrnLibStream FRAME wth-List.                                                    */
/*output  STREAM PrnLibStream CLOSE.                                                           */
/*REPOSITION br-docs to recid vardoc-rec no-error.                                             */
/*APPLY "entry" to br-docs.                                                                    */
/*run waitfram-hide in this-procedure .                                                        */
/*run prn-lib-prn-file in this-procedure (                                                     */
/*                                          input parParentProc                                */
/*                                          ,input 8                                           */
/*                                          ).                                                 */
/*                                                                                             */
/*                                                                                             */
/*                                                                                             */
/*                                                                                             */
/*END PROCEDURE.                                                                               */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-c-rvs-doc Dialog-Frame
PROCEDURE reposition-c-rvs-doc :
define input  parameter p-direction   as character no-undo .
define output parameter p-rvs-doc-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-docs.
    end.
    when "last":U
    then do:
      get last br-docs.
    end.
    when "prev":U
    then do:
      get prev br-docs.
      if not available X_c-rvs-doc then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available X_c-rvs-doc then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-rvs-doc-recid = recid(X_c-rvs-doc)
  .
  run reposition-query in this-procedure
    (input p-rvs-doc-recid
    ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

  if p-recid <> ?
  then do:
    reposition br-docs to recid p-recid no-error.
  end.

  do with frame {&frame-name}:
    apply "entry":u to browse {&browse-name} .
    apply "VALUE-CHANGED":u to browse {&browse-name} .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
