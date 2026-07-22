&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
using ibs.th.gbl.storage.*.
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-all-r-docs


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER r-doc FOR rvs-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-all-r-docs 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$ 

Список документов сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/11/06
Author: Dmitry Ukhanov
Creation date: 12/11/06

Create1: Суслов Алексей Юрьевич
Дата создания1: 09/20/05

*/
/*----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as handle    no-undo.
define input parameter parlist-mode  as character no-undo.
define input parameter parstatus     as character no-undo.
define output parameter out-rec      as recid     no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Список документов сверки":U .
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/waitfram.i noprocess }
{ gbl/flt-def.i  }
{ cmp/gds-list.i gds-list def }
{ cmp/operlist.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ str/lib-rvs.i  }
{ gbl/fltopend.i defproc }
{ ref/gds-attr.i }
{ str/is-gas.i }
{ str/placelib.i }
{ cmp/trg-def.i  }
{ str/temp_suspChk.i NEW}

define buffer buf-inv_trn-doc for ub.trn-doc .
define buffer buf-spi_trn-doc for ub.trn-doc .

&scop no-rvs ~
  if not available r-doc then do: ~
    message ~
      "Неправильный выбор документа сверки." ~
      view-as alert-box . ~
    return no-apply. ~
  end. ~
  else do: ~
    assign ~
      rvs-rec = recid (r-doc) ~
    . ~
  end.

{str/autorvs.i}


define temp-table autorvs no-undo
field attr-code like doc-attr.attr-code
field attr-value like doc-attr.attr-value
field rvs-code  like r-doc.rvs-code
field auto as logical
.


define variable br-handle        as handle    no-undo.
define variable bcol             as handle    extent 34 no-undo.

define variable ii               as integer.
define variable sch-field        as char      no-undo.
define variable del-list         as char      no-undo.
define variable mark             as char      no-undo.
define variable auto             as char      no-undo.
define variable hd-rvs           as handle    no-undo.

define variable varobj-type      like ub.rvs-doc.obj-type no-undo .
define variable varobj-code      like ub.rvs-doc.obj-code no-undo .
define variable varhost-code     like ub.rvs-doc.host-code no-undo .
define variable varstatus_       like ub.rvs-doc.status_ no-undo .
define variable vartest-asi      like ub.rvs-doc.rvs-type no-undo .

/* для вирт рез */
define variable is-vir           as logical   no-undo.
define variable v-value          as character no-undo.
define variable v-ok             as logical   no-undo.

define variable sort-column-name as character no-undo.
define variable filter-point     as character no-undo.
define variable varstr           as character no-undo.
define variable varrecid         as recid     no-undo.
define variable rvs-rec          as recid     no-undo.
define variable varlog           as logical   no-undo.
define variable p-auto           as char      no-undo.
define variable rvsinvstrObj     as class rvsinvstr no-undo.
/*define variable p-autorvs as logical no-undo.*/





&scop label-clmn_1-br-dtl     '*'
&scop label-clmn_2-br-dtl     ' Tип '
&scop label-clmn_3-br-dtl     ' '
&scop label-clmn_4-br-dtl     'Стат'
&scop label-clmn_5-br-dtl     'Документ'
&scop label-clmn_6-br-dtl     'Дата'
&scop label-clmn_7-br-dtl     'Факт'
&scop label-clmn_8-br-dtl     'Время'
&scop label-clmn_9-br-dtl     'Документ'
&scop label-clmn_10-br-dtl     'Смена'
&scop label-clmn_11-br-dtl    '№'
&scop label-clmn_35-br-dtl    'тв'

&scop sort-clmn_1-br-dtl        mark-string (recid( r-doc)) @ mark
&scop dyn_sort-clmn_1-br-dtl    substitute('dynamic-function(&1mark-string&1, recid(r-doc)) ', ~{&double-quote~} )
&scop sort-clmn_2-br-dtl        (substring (r-doc.rvs-type, 1, 9))
&scop sort-clmn_3-br-dtl         autorvs (recid(r-doc))
&scop dyn_sort-clmn_3-br-dtl    substitute('dynamic-function(&1autorvs&1, recid(r-doc)) ', ~{&double-quote~} )
&scop sort-clmn_4-br-dtl        r-doc.status_
&scop sort-clmn_5-br-dtl        r-doc.rvs-code
&scop sort-clmn_6-br-dtl        (substring ((string (r-doc.doc-date)), 1, 5))
&scop sort-clmn_7-br-dtl        r-doc.fact-date
&scop sort-clmn_8-br-dtl        string(r-doc.fact-time,'hh:mm:ss')
&scop sort-clmn_9-br-dtl        r-doc.out-code
&scop sort-clmn_10-br-dtl       (substring ((string (r-doc.shift-date)), 1, 5))
&scop sort-clmn_11-br-dtl       shift-name (recid(r-doc))
&scop dyn_sort-clmn_11-br-dtl   substitute('dynamic-function(&1shift-name&1, recid( r-doc)) ', ~{&double-quote~} )
&scop sort-clmn_12-br-dtl       r-doc.state-measure-qnty 
&scop sort-clmn_13-br-dtl       r-doc.measure-qnty
&scop sort-clmn_14-br-dtl       r-doc.state-brutto-qnty
&scop sort-clmn_15-br-dtl       r-doc.brutto-qnty
&scop sort-clmn_16-br-dtl       r-doc.system-qnty
&scop sort-clmn_17-br-dtl       r-doc.system-cli-qnty
&scop sort-clmn_18-br-dtl       r-doc.system-cli-avrg-qnty
&scop sort-clmn_19-br-dtl       r-doc.measure-cli-qnty
&scop sort-clmn_20-br-dtl       r-doc.state-measure-cli-qnty
&scop sort-clmn_21-br-dtl       r-doc.brutto-cli-qnty
&scop sort-clmn_22-br-dtl       r-doc.state-brutto-cli-qnty
&scop sort-clmn_23-br-dtl       r-doc.meas-mh-qnty
&scop sort-clmn_24-br-dtl       r-doc.state-mh-qnty
&scop sort-clmn_25-br-dtl        r-doc.meas-am-qnty
&scop sort-clmn_26-br-dtl       r-doc.state-am-qnty
&scop sort-clmn_27-br-dtl       r-doc.meas-cf-qnty
&scop sort-clmn_28-br-dtl       r-doc.state-cf-qnty
&scop sort-clmn_29-br-dtl       r-doc.level-petrol
&scop sort-clmn_30-br-dtl       r-doc.state-level-petrol
&scop sort-clmn_31-br-dtl       r-doc.level-total
&scop sort-clmn_32-br-dtl       r-doc.state-level-total
&scop sort-clmn_33-br-dtl       r-doc.level-water
&scop sort-clmn_34-br-dtl       r-doc.state-level-water
&scop sort-clmn_35-br-dtl       get-input-type (recid( r-doc))
&scop dyn_sort-clmn_35-br-dtl   substitute('dynamic-function(&1get-input-type&1, recid(r-doc)) ', ~{&double-quote~} )
&scop enabled-clmn              {&sort-clmn_34-br-dtl}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-all-r-docs
&Scoped-define BROWSE-NAME br-r-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES r-doc

/* Definitions for BROWSE br-r-docs                                     */
&Scoped-define FIELDS-IN-QUERY-br-r-docs {&sort-clmn_1-br-dtl} {&sort-clmn_2-br-dtl} {&sort-clmn_3-br-dtl} {&sort-clmn_4-br-dtl} {&sort-clmn_5-br-dtl} {&sort-clmn_6-br-dtl} {&sort-clmn_7-br-dtl} {&sort-clmn_8-br-dtl} {&sort-clmn_9-br-dtl} {&sort-clmn_10-br-dtl} {&sort-clmn_11-br-dtl} {&sort-clmn_12-br-dtl} {&sort-clmn_13-br-dtl} {&sort-clmn_14-br-dtl} {&sort-clmn_15-br-dtl} {&sort-clmn_16-br-dtl} {&sort-clmn_17-br-dtl} {&sort-clmn_18-br-dtl} {&sort-clmn_19-br-dtl} {&sort-clmn_20-br-dtl} {&sort-clmn_21-br-dtl} {&sort-clmn_22-br-dtl} {&sort-clmn_23-br-dtl} {&sort-clmn_24-br-dtl} {&sort-clmn_25-br-dtl} {&sort-clmn_26-br-dtl} {&sort-clmn_27-br-dtl} {&sort-clmn_28-br-dtl} {&sort-clmn_29-br-dtl} {&sort-clmn_30-br-dtl} {&sort-clmn_31-br-dtl} {&sort-clmn_32-br-dtl} {&sort-clmn_33-br-dtl} {&sort-clmn_34-br-dtl}   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-r-docs {&enabled-clmn}   
&Scoped-define SELF-NAME br-r-docs
&Scoped-define QUERY-STRING-br-r-docs FOR EACH r-doc
&Scoped-define OPEN-QUERY-br-r-docs OPEN QUERY {&SELF-NAME} FOR EACH r-doc .
&Scoped-define TABLES-IN-QUERY-br-r-docs r-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-r-docs r-doc


/* Definitions for DIALOG-BOX d-all-r-docs                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-all-r-docs ~
    ~{&OPEN-QUERY-br-r-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-lkp b-chg b-del ~
b-close b-open b-hist b-help Btn_Copy b-inv b-sch b-print br-r-docs ~
ed-notes 
&Scoped-Define DISPLAYED-OBJECTS ed-notes f-boss-name f-obj-name ~
f-agnt-name f-wrkr-name f-cre-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string d-all-r-docs 
FUNCTION mark-string RETURNS CHARACTER
    ( p-rec as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-input-type d-all-r-docs 
FUNCTION get-input-type RETURNS CHARACTER
    ( p-rec as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD shift-name d-all-r-docs 
FUNCTION shift-name RETURNS CHARACTER
    ( p-rec as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "Изменить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-close 
     LABEL "Закрыть":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-del 
     LABEL "Удалить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помощь":L 
     SIZE 7 BY 1.

DEFINE BUTTON b-hist 
     LABEL "История" 
     SIZE 3 BY 1.

DEFINE BUTTON b-inv 
     LABEL "Инвент." 
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp 
     LABEL "Просмотр":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "*":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-open 
     LABEL "Открыть" 
     SIZE 10 BY 1.

DEFINE BUTTON b-print 
     LABEL "Печать":L 
     SIZE 7 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "Выход":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-sch 
     LABEL "&Фильтр":L 
     SIZE 7 BY 1.

DEFINE BUTTON b-sel 
     LABEL "Выбор":L 
     SIZE 10 BY 1.

DEFINE BUTTON Btn_Copy 
     LABEL "&Ст.Смен." 
     SIZE 10 BY 1 TOOLTIP "Сделать сменную сверку на основе контрольной (полной)".

DEFINE VARIABLE ed-notes AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 99 BY 2
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE f-agnt-name AS CHARACTER FORMAT "X(19)":U 
     LABEL "Исп" 
      VIEW-AS TEXT 
     SIZE 19.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-boss-name AS CHARACTER FORMAT "X(19)":U 
     LABEL "М-р" 
      VIEW-AS TEXT 
     SIZE 19.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-cre-name AS CHARACTER FORMAT "X(19)":U 
     LABEL "Опер" 
      VIEW-AS TEXT 
     SIZE 19.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(13)":U 
     LABEL "Объект" 
      VIEW-AS TEXT 
     SIZE 62.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-wrkr-name AS CHARACTER FORMAT "X(19)":U 
     LABEL "Кл-к" 
      VIEW-AS TEXT 
     SIZE 19.5 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY {&browse-name} for r-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-r-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-r-docs d-all-r-docs _FREEFORM
  QUERY br-r-docs DISPLAY
      {&sort-clmn_1-br-dtl} COLUMN-LABEL {&label-clmn_1-br-dtl}  FORMAT "x(1)"
     {&sort-clmn_2-br-dtl}  COLUMN-LABEL {&label-clmn_2-br-dtl}  FORMAT "x(9)"
     {&sort-clmn_3-br-dtl}  COLUMN-LABEL {&label-clmn_3-br-dtl}  format "x(1)"
     {&sort-clmn_35-br-dtl} COLUMN-LABEL {&label-clmn_35-br-dtl}  format "x(2)" 
     {&sort-clmn_4-br-dtl}  column-label {&label-clmn_4-br-dtl}  format "x(5)"
     {&sort-clmn_5-br-dtl}  column-label {&label-clmn_5-br-dtl}  format "x(12)"
     {&sort-clmn_6-br-dtl}  COLUMN-LABEL {&label-clmn_6-br-dtl}  format "x(5)"
     {&sort-clmn_7-br-dtl}  COLUMN-LABEL {&label-clmn_7-br-dtl}
     {&sort-clmn_8-br-dtl}  COLUMN-LABEL {&label-clmn_8-br-dtl}
     {&sort-clmn_9-br-dtl}  column-label {&label-clmn_9-br-dtl}
     {&sort-clmn_10-br-dtl} column-label {&label-clmn_10-br-dtl} format "x(5)"
     {&sort-clmn_11-br-dtl} column-label {&label-clmn_11-br-dtl} format "x(6)"
     {&sort-clmn_12-br-dtl} 
     {&sort-clmn_13-br-dtl} 
     {&sort-clmn_14-br-dtl}
     {&sort-clmn_15-br-dtl}
     {&sort-clmn_16-br-dtl}
     {&sort-clmn_17-br-dtl}
     {&sort-clmn_18-br-dtl}
     {&sort-clmn_19-br-dtl} format "->>,>>>,>>>,>>>.<<<"
     {&sort-clmn_20-br-dtl} format "->>,>>>,>>>,>>>.<<<"
     {&sort-clmn_21-br-dtl}
     {&sort-clmn_22-br-dtl}
     {&sort-clmn_23-br-dtl} format "->>,>>>,>>>,>>>.<<<"
     {&sort-clmn_24-br-dtl} format "->>,>>>,>>>,>>>.<<<"
     {&sort-clmn_25-br-dtl} format "->>,>>>,>>>,>>>.<<<"
     {&sort-clmn_26-br-dtl} format "->>,>>>,>>>,>>>.<<<"
     {&sort-clmn_27-br-dtl}
     {&sort-clmn_28-br-dtl}
     {&sort-clmn_29-br-dtl}
     {&sort-clmn_30-br-dtl} format "->>,>>>,>>>.<<<"
     {&sort-clmn_31-br-dtl}
     {&sort-clmn_32-br-dtl}
     {&sort-clmn_33-br-dtl}
     {&sort-clmn_34-br-dtl}
     ENABLE {&enabled-clmn}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 99 BY 16.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-all-r-docs
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-lkp AT ROW 2 COL 24
     b-chg AT ROW 2 COL 34
     b-del AT ROW 2 COL 44
     b-close AT ROW 1 COL 34
     b-open AT ROW 1 COL 44
     b-hist AT ROW 1 COL 89.5 WIDGET-ID 64
     b-help AT ROW 1 COL 92.5
     Btn_Copy AT ROW 2 COL 54
     b-inv AT ROW 1 COL 74
     b-sch AT ROW 2 COL 85.5
     b-print AT ROW 2 COL 92.5
     br-r-docs AT ROW 3 COL 1
     ed-notes AT ROW 21.5 COL 1 NO-LABEL
     f-boss-name AT ROW 20 COL 5 COLON-ALIGNED
     f-obj-name AT ROW 20 COL 35 COLON-ALIGNED
     f-agnt-name AT ROW 20.75 COL 5 COLON-ALIGNED
     f-wrkr-name AT ROW 20.75 COL 35 COLON-ALIGNED
     f-cre-name AT ROW 20.75 COL 65 COLON-ALIGNED
     SPACE(13.50) SKIP(2.08)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "<insert dialog title>".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: r-doc B "NEW SHARED" NO-UNDO ub rvs-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-all-r-docs
   FRAME-NAME                                                           */
/* BROWSE-TAB br-r-docs b-print d-all-r-docs */
ASSIGN 
       FRAME d-all-r-docs:SCROLLABLE       = FALSE
       FRAME d-all-r-docs:HIDDEN           = TRUE.

ASSIGN 
       br-r-docs:NUM-LOCKED-COLUMNS IN FRAME d-all-r-docs     = 4
       br-r-docs:COLUMN-RESIZABLE IN FRAME d-all-r-docs       = TRUE.

/* SETTINGS FOR FILL-IN f-agnt-name IN FRAME d-all-r-docs
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-boss-name IN FRAME d-all-r-docs
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-cre-name IN FRAME d-all-r-docs
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-obj-name IN FRAME d-all-r-docs
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-wrkr-name IN FRAME d-all-r-docs
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-r-docs
/* Query rebuild information for BROWSE br-r-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH r-doc .
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE NEW SHARED QUERY {&browse-name} for r-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Query            is OPENED
*/  /* BROWSE br-r-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-all-r-docs
/* Query rebuild information for DIALOG-BOX d-all-r-docs
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-all-r-docs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-all-r-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-all-r-docs d-all-r-docs
ON WINDOW-CLOSE OF FRAME d-all-r-docs /* <insert dialog title> */
DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-all-r-docs
ON CHOOSE OF b-add IN FRAME d-all-r-docs /* Добавить */
DO:
        define buffer bf_icnt-doc for ub.icnt-doc.
        define buffer bf_rvs-doc  for ub.rvs-doc.
        find first bf_icnt-doc no-lock
            where bf_icnt-doc.obj-type  = v-cntxt-obj-type
            and bf_icnt-doc.obj-code  = v-cntxt-obj-code
            and bf_icnt-doc.doc-type  = {&icnt-doc}
            AND bf_icnt-doc.status_  <> {&fact}
            no-error.
        if available bf_icnt-doc then 
        do:
            message
                "Имеется не закрытый документ инвентаризации счетчиков ТРК " bf_icnt-doc.doc-code " ."
                view-as alert-box error.
            return no-apply.
        end.
        find first bf_rvs-doc no-lock
            where bf_rvs-doc.obj-type =  v-cntxt-obj-type
            and bf_rvs-doc.obj-code =  v-cntxt-obj-code
            and bf_rvs-doc.status_  <> {&fact}
            and ( bf_rvs-doc.rvs-type = {&rvs-shift}
            or bf_rvs-doc.rvs-type = {&rvs-control}
            and bf_rvs-doc.is-full  = yes
            )
            no-error.
    
    
        if available bf_rvs-doc then 
        do:
            message
                "Имеется не закрытый документ сверки " bf_rvs-doc.rvs-code " ."
                view-as alert-box error.
            return no-apply.
        end.

        assign
            rvs-rec = ?
            .
        do
            on stop undo, return no-apply
            :
            run str/rvs-add.w
                ( input parparentproc
                ,input {&add-def}
                ,output rvs-rec
                ) no-error.
            if error-status :error then 
            do:
                undo, return no-apply.
            end.
        end.
        if rvs-rec = ? then 
        do:
            return no-apply.
        end.
        message
            "Новый документ сверки добавлен в Базу Данных."
            view-as alert-box information.
        run UI-on in this-procedure.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-all-r-docs
ON CHOOSE OF b-chg IN FRAME d-all-r-docs /* Изменить */
DO:
        define buffer bf_trn-doc for ub.trn-doc.
        {&no-rvs}
  if r-doc.status_ = {&fact}
    or r-doc.status_ = {&rvs-froze}
  then do:
        message
            "Данный документ сверки закрыт по факту или не может быть обработан в этом списке."
            view-as alert-box.
        return no-apply.
    end.


find first bf_trn-doc
    where bf_trn-doc.out-code = r-doc.rvs-code
    no-error.
if available bf_trn-doc then 
do:
    message
        "По сверке есть инвентаризация. Изменять сверку нельзя."
        view-as alert-box.
    return no-apply.
end.
assign
    rvs-rec = recid( r-doc )
    .
run str/rvs-doc.w
    ( input        parparentproc
    ,input        {&update}
    ,input        r-doc.rvs-type
    ,input        no
    ,input-output rvs-rec
    ) no-error.
if error-status :error then 
do:
    find r-doc no-lock
        where recid (r-doc) = rvs-rec
        .
    return no-apply.
end.
apply "entry" to {&browse-name} in frame {&frame-name}.
run UI-on in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close d-all-r-docs
ON CHOOSE OF b-close IN FRAME d-all-r-docs /* Закрыть */
DO:
        define variable varchg-inv as logical   no-undo.
        define variable v-inv-doc  as character no-undo .

        {&no-rvs}
  if r-doc.status_ = {&fact}
    or r-doc.status_ = {&rvs-froze}
  then do:
        message
            "Данный документ сверки закрыт по факту или не может быть обработан в этом списке."
            view-as alert-box.
        return no-apply.
    end.
if r-doc.status_ = {&g___new} then 
do:
    assign
        varlog = no
        .
    message
        "Вы хотите завершить редактирование документа сверки?"
        view-as alert-box question buttons yes-no update varlog .
    if varlog <> yes then 
    do:
        return no-apply.
    end.
    tr:
    do transaction
        on error   undo tr, leave
        on end-key undo tr, leave
        on stop    undo tr, leave
        :
        { str/rvsclose.i
        parparentproc
        recid(r-doc)
        yes
        no-error
      }
   
      if error-status :error then do:
       
        message
          "Ошибка при закрытии документа сверки." skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
        run userlogrvs(58, return-value + error-status:get-message(1) ) .
        undo tr, leave.
      end.
    end.
end.
else 
do:
    find first buf-inv_trn-doc no-lock
        where buf-inv_trn-doc.out-code = r-doc.rvs-code
        no-error.
    if ambiguous buf-inv_trn-doc then 
    do:
        message
            "Найдено более одного складского документа связанного со сверкой."
            view-as alert-box error.
        return no-apply.
    end.
    if available buf-inv_trn-doc then 
    do:
        if buf-inv_trn-doc.doc-type <> {&inventory} then 
        do:
            message
                "Документ связанный с документом сверки не яв-ся инвентаризацией."
                view-as alert-box error.
            return no-apply.
        end.
        if buf-inv_trn-doc.status_ <> {&doc-froze}
            or buf-inv_trn-doc.flag_ <> yes
            then 
        do:
            message
                substitute( "Ошибка в документе инвентаризации &1 по сверке.", buf-inv_trn-doc.doc-code ) skip
                substitute( "Связанный со сверкой документ инвентаризации не находится в статусе &1", {&doc-froze} )
                view-as alert-box error.
            return no-apply.
        end.
        assign
            varstr    = " документ инвентаризации"
            v-inv-doc = buf-inv_trn-doc.doc-code
            .
    end.
    assign
        varlog = no
        .
    message
        substitute( "Вы хотите закрыть документ сверки &1?", (if varstr <> "" then "и" else "") + varstr )
        view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then 
    do:
        return no-apply.
    end.

    find first ub.rvs-line no-lock
        where ub.rvs-line.rvs-code           = r-doc.rvs-code
        and ub.rvs-line.state-measure-qnty = ?
        no-error.
    if available ub.rvs-line then 
    do:
        find first ub.goods no-lock
            where ub.goods.gds-code = ub.rvs-line.gds-code.
      
        run placelib_get-attr(input {&place-virtual}
            ,input rvs-line.obj-code
            ,input rvs-line.obj-type
            ,input rvs-line.pl-code
            ,output v-value
            ,output v-ok) no-error.

        is-vir = if (v-ok and logical(v-value)) then true else false.
  
        if not is-gas(ub.rvs-line.gds-code) and not is-vir then 
        do:
            message
                substitute( "Не заданы фактические остатки по товару &1 (&2)", ub.goods.gds-code, ub.goods.gds-name )
                view-as alert-box error.
            return no-apply.
        end.
    end.
    tr:
    do transaction
        on error   undo tr, leave
        on end-key undo tr, leave
        on stop    undo tr, leave
        :
        { str/rvsclose.i
        parparentproc
        recid(r-doc)
        yes
        no-error
      }
        if error-status :error then 
        do:
            message
                "Ошибка при закрытии документа сверки." skip
                error-status:get-message(1) skip
                return-value
                view-as alert-box error.
            run userlogrvs(58, return-value + error-status:get-message(1) ) .
            undo tr, leave.
        end.

        release r-doc no-error .
        if error-status :error then 
        do:
            message
                "Ошибка при закрытии документа сверки." skip
                error-status:get-message(1) skip
                return-value
                view-as alert-box error.
            undo tr, leave.
        end.

        /* Закрытие инвентаризации */
        find first buf-inv_trn-doc exclusive-lock
            where buf-inv_trn-doc.doc-code = v-inv-doc
            no-error.
        if available buf-inv_trn-doc then 
        do:
            assign
                buf-inv_trn-doc.status_ = {&permitted}
                buf-inv_trn-doc.flag_   = yes
                .
    /* Проверка на заполнение атрибутов */
    define variable is-pos   as logical   no-undo .
    define variable is-date  as logical   no-undo .
    define variable is-fio   as logical   no-undo .
    define variable is-check as logical   no-undo .
    define variable is-mes   as character no-undo .

    define buffer fio_inv-doc-attr    for ub.inv-doc-attr .
    define buffer pos_inv-doc-attr    for ub.inv-doc-attr .
    define buffer prikaz_inv-doc-attr for ub.inv-doc-attr .
  
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = v-inv-doc and
      ub.inv-doc-attr.attr-code = "invTech" and
      ub.inv-doc-attr.attr-value = string(true) no-error .
    if not available (ub.inv-doc-attr) then 
    do:
      if not can-find (first prikaz_inv-doc-attr no-lock where prikaz_inv-doc-attr.doc-code = v-inv-doc and
        prikaz_inv-doc-attr.attr-code = {&trdcattr-prikaz-date} and
        prikaz_inv-doc-attr.attr-value <> "") then 
      do:
        is-date = true .
        is-check = true .
      end.
      if not can-find (first fio_inv-doc-attr no-lock where fio_inv-doc-attr.doc-code = v-inv-doc and
        (fio_inv-doc-attr.attr-code = {&trdcattr-fio-agent} or
        fio_inv-doc-attr.attr-code = {&trdcattr-fio-player1} or
        fio_inv-doc-attr.attr-code = {&trdcattr-fio-player2} or
        fio_inv-doc-attr.attr-code = {&trdcattr-fio-player3}) and
        fio_inv-doc-attr.attr-value <> "") then 
      do:
        is-fio = true .
        is-check = true .
      end.
      if not can-find (first fio_inv-doc-attr no-lock where fio_inv-doc-attr.doc-code = v-inv-doc and
        (fio_inv-doc-attr.attr-code = {&trdcattr-pos-agent} or
        fio_inv-doc-attr.attr-code = {&trdcattr-pos-player1} or
        fio_inv-doc-attr.attr-code = {&trdcattr-pos-player2} or
        fio_inv-doc-attr.attr-code = {&trdcattr-pos-player3}) and
        fio_inv-doc-attr.attr-value <> "")then 
      do:
        is-pos = true .
        is-check = true .
      end.
      
      if is-check then 
      do:

        is-mes = "Ошибка при закрытии документа инвентаризации." .

        if is-date then 
        do:
          is-mes = is-mes + {&new-line} + "Не указана дата приказа." .
        end.
        if is-fio then 
        do:
          is-mes = is-mes + {&new-line} + "Не указано ФИО." .
        end.
        if is-pos then 
        do:
          is-mes = is-mes + {&new-line} + "Не указана должность." .
        end.
      
      end.
      /* Проверка на заполнение по парам ФИО и должность */
      
      find first fio_inv-doc-attr no-lock where 
        fio_inv-doc-attr.doc-code = v-inv-doc and
        fio_inv-doc-attr.attr-code = {&trdcattr-fio-agent} and 
        fio_inv-doc-attr.attr-value <> "" no-error .
      if not available (fio_inv-doc-attr) then 
      do:
        find first pos_inv-doc-attr no-lock where 
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = {&trdcattr-pos-agent} and 
          pos_inv-doc-attr.attr-value <> "" no-error . 
        if available (pos_inv-doc-attr) then 
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .  
          is-mes = is-mes + "Не заполнена ФИО председателя комиссии." + {&new-line}. 
        end.         
      end. 
      else 
      do:
        find first pos_inv-doc-attr no-lock where 
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = {&trdcattr-pos-agent} and 
          pos_inv-doc-attr.attr-value <> "" no-error . 
        if not available (pos_inv-doc-attr) then 
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
          is-mes = is-mes + "Не заполнена должность председателя комиссии." + {&new-line}.                
        end. 
      end.
        
      find first fio_inv-doc-attr no-lock where 
        fio_inv-doc-attr.doc-code = v-inv-doc and
        fio_inv-doc-attr.attr-code = {&trdcattr-fio-player1} and 
        fio_inv-doc-attr.attr-value <> "" no-error .
      if not available (fio_inv-doc-attr) then 
      do:
        find first pos_inv-doc-attr no-lock where 
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = {&trdcattr-pos-player1} and 
          pos_inv-doc-attr.attr-value <> "" no-error . 
        if available (pos_inv-doc-attr) then 
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
          is-mes = is-mes + "Не заполнена ФИО первого участника комиссии." + {&new-line}.          
        end. 
      end.
      else 
      do:
        find first pos_inv-doc-attr no-lock where 
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = {&trdcattr-pos-player1} and 
          pos_inv-doc-attr.attr-value <> "" no-error . 
        if not available (pos_inv-doc-attr) then 
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
          is-mes = is-mes + "Не заполнена должность первого участника комиссии." + {&new-line}.                
        end.           
      end.

      find first fio_inv-doc-attr no-lock where 
        fio_inv-doc-attr.doc-code = v-inv-doc and
        fio_inv-doc-attr.attr-code = {&trdcattr-fio-player2} and 
        fio_inv-doc-attr.attr-value <> "" no-error .
      if not available (fio_inv-doc-attr) then 
      do:
        find first pos_inv-doc-attr no-lock where 
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = {&trdcattr-pos-player2} and 
          pos_inv-doc-attr.attr-value <> "" no-error . 
        if available (pos_inv-doc-attr) then 
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
          is-mes = is-mes + "Не заполнена ФИО второго участника комиссии." + {&new-line}.          
        end.
      end. 
      else 
      do:
        find first pos_inv-doc-attr no-lock where 
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = {&trdcattr-pos-player2} and 
          pos_inv-doc-attr.attr-value <> "" no-error . 
        if not available (pos_inv-doc-attr) then 
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
          is-mes = is-mes + "Не заполнена должность второго участника комиссии." + {&new-line}.  
        end.              
      end.   

      find first fio_inv-doc-attr no-lock where 
        fio_inv-doc-attr.doc-code = v-inv-doc and
        fio_inv-doc-attr.attr-code = {&trdcattr-fio-player3} and 
        fio_inv-doc-attr.attr-value <> "" no-error .
      if not available (fio_inv-doc-attr) then 
      do:
        find first pos_inv-doc-attr no-lock where 
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = {&trdcattr-pos-player3} and 
          pos_inv-doc-attr.attr-value <> "" no-error . 
        if available (pos_inv-doc-attr) then 
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
          is-mes = is-mes + "Не заполнена ФИО третьего участника комиссии." + {&new-line}.          
        end. 
      end.
      else 
      do:
        find first pos_inv-doc-attr no-lock where 
          pos_inv-doc-attr.doc-code = v-inv-doc and
          pos_inv-doc-attr.attr-code = {&trdcattr-pos-player3} and 
          pos_inv-doc-attr.attr-value <> "" no-error . 
        if not available (pos_inv-doc-attr) then 
        do:
          if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
          is-mes = is-mes + "Не заполнена должность третьего участника комиссии." + {&new-line}.                
        end.   
      end.
      if is-mes <> "" then do:
      message
        is-mes
        view-as alert-box .
      undo tr, leave.
      end.
    end.                 
                
            run str/trn-stat.p
                ( input parparentproc
                , input this-procedure
                , input {&close-doc}
                , input v-inv-doc
                , input ?
                , input v-cntxt-db-num
                , input ?
                , input ?
                , input ?
                , input ?
                , input yes
                , output varchg-inv
                , output table gds-list
                ) no-error.
            if error-status :error then 
            do:
                message
                    "Не удалось закрыть инвентаризацию." skip
                    return-value                         skip
                    error-status :get-message(1)         skip
                    view-as alert-box error.
                undo tr, leave.
            end.
            release buf-inv_trn-doc no-error .
            if error-status :error then 
            do:
                message
                    "Ошибка при закрытии документа интвентаризации." skip
                    error-status:get-message(1) skip
                    return-value
                    view-as alert-box error.
                undo tr, leave.
            end.

            find first buf-spi_trn-doc exclusive-lock
                where buf-spi_trn-doc.out-code = v-inv-doc
                and buf-spi_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
                no-error .
            /* Закрытие списания */
            if available buf-spi_trn-doc then 
            do:
                assign
                    buf-spi_trn-doc.status_ = {&permitted}
                    buf-spi_trn-doc.flag_   = yes
                    .
                run str/trn-stat.p
                    ( input parparentproc
                    , input this-procedure
                    , input {&close-doc}
                    , input buf-spi_trn-doc.doc-code
                    , input ?
                    , input v-cntxt-db-num
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input yes
                    , output varchg-inv
                    , output table gds-list
                    ) no-error.
                if error-status :error then 
                do:
                    message
                        "Не удалось закрыть документ списания." skip
                        return-value                            skip
                        error-status:get-message(1)             skip
                        view-as alert-box error.
                    undo tr, leave.
                end.
                release buf-spi_trn-doc no-error .
                if error-status :error then 
                do:
                    message
                        "Ошибка при закрытии документа списания." skip
                        error-status:get-message(1) skip
                        return-value
                        view-as alert-box error.
                    undo tr, leave.
                end.
            end.
        end.
    end.
end.
find first r-doc no-lock
    where recid (r-doc) = rvs-rec
    .
run UI-on in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-all-r-docs
ON CHOOSE OF b-del IN FRAME d-all-r-docs /* Удалить */
DO:
    define variable v-person as character no-undo.
    define variable v-vid-action as integer  no-undo .
    define variable v-vid-param  as longchar no-undo .
    define variable v-mess as char no-undo.
    define variable p-rvs-doc as character no-undo.

        if not available r-doc then 
        do:
            message "Не выбрана сверка, которую нужно удалить." view-as alert-box.
            return no-apply.
        end.
                p-rvs-doc = r-doc.rvs-code.
        run proc-del in this-procedure
            no-error.
        if error-status :error then 
        do:
    run userlogrvs(60, return-value + error-status:get-message(1) ) no-error.
      /*  v-mess = return-value.
        for first  ub.clients where ub.clients.obj-type = {&prs} and  ub.clients.obj-code = ub.c-rvs-doc.boss no-lock : 
            v-person = clients.obj-name.
        end.
        v-vid-action = 60.
        v-vid-param =
            "Initiator=" + "User" + {&delim-par} +
            "ResponsiblePerson=" + (if v-person <> ?  then v-person else "") + {&delim-par} + 
            "SHOP_NUM=" + string(r-doc.obj-code) + {&delim-par} +
            "DocNum=" + string(r-doc.rvs-code) + {&delim-par} +
            "FactDate=" + (if string(r-doc.fact-date) = ? then '' else string(r-doc.fact-date)) + {&delim-par} +
            "DocType=" + string(r-doc.rvs-type) + {&delim-par} +
            "ShiftNum=" + string(r-doc.shift-num) + {&delim-par} +
            "ShiftDate=" + string(r-doc.shift-date) + {&delim-par} +
            /*                "ShiftNumCurr=" + (if string(parshift-num) = ? then '' else string(parshift-num)) + {&delim-par} +   */
            /*                "ShiftDateCurr=" + (if string(parshift-date) = ? then '' else string(parshift-date)) + {&delim-par} +*/
            "Status=" + string(r-doc.status_) + {&delim-par} +
            "RESULT=0" + {&delim-par} +
            "Description=" + v-mess.
        
         
        run trg/userlog.p (
            input {&nwsdochs_action_delete_err}
            , input {&table_rvs-doc}
            , input ( buffer r-doc :handle )
            , input v-vid-action
            , input v-vid-param
            ) no-error.
            */
        if error-status :error
            then 
        do:
            message substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ) 
                view-as alert-box.
            return no-apply.
        end.
        
    end.

        run openbr in this-procedure .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-all-r-docs
ON CHOOSE OF b-hist IN FRAME d-all-r-docs /* История */
DO:
    define variable v-list as character no-undo.

  if available r-doc then do:
    run str/rvscdocs.w ( input        parparentproc,
                     input        "":U,
                     input        "one":U,
                     input        r-doc.rvs-code,
                     input-output v-list                  ).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-inv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-inv d-all-r-docs
ON CHOOSE OF b-inv IN FRAME d-all-r-docs /* Инвент. */
DO:

  define variable v-docs-info as character no-undo .
{ gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_inventory_add':U
              {&cntxt-object}
              r-doc.host-code
              r-doc.obj-type
              r-doc.obj-code
              0
              0
              0
              true
              varlog
            }
    if varlog <> yes then do:
      return no-apply.
    end.               
  {&no-rvs}
  if r-doc.status_ <> {&permitted} then do:
        message
            substitute( "Инвентаризацию можно проводить только по документам сверки в статусе &1.", {&permitted} )
            view-as alert-box.
        return no-apply.
    end.
find first ub.rvs-line no-lock
    where ub.rvs-line.rvs-code           = r-doc.rvs-code
    and ub.rvs-line.state-measure-qnty = ?
    no-error.
if available ub.rvs-line then 
do:
    find first ub.goods no-lock
        where ub.goods.gds-code = ub.rvs-line.gds-code.
      
    run placelib_get-attr(input {&place-virtual}
        ,input rvs-line.obj-code
        ,input rvs-line.obj-type
        ,input rvs-line.pl-code
        ,output v-value
        ,output v-ok) no-error.

    is-vir = if (v-ok and logical(v-value)) then true else false.
      
    if not is-gas(ub.rvs-line.gds-code) and not is-vir then 
    do:
        message
            substitute( "Не заданы фактические остатки по товару &1 (&2)", ub.goods.gds-code, ub.goods.gds-name )
            view-as alert-box error.
        return no-apply.
    end.
end.
find first buf-inv_trn-doc no-lock
    where buf-inv_trn-doc.out-code = r-doc.rvs-code
    no-error.
if ambiguous buf-inv_trn-doc then 
do:
    message
        "Найдено более одного складского документа связанного со сверкой."
        view-as alert-box error.
    return no-apply.
end.
if available buf-inv_trn-doc then 
do:
    if buf-inv_trn-doc.doc-type <> {&inventory} then 
    do:
        message
            "Документ связанный с документом сверки не яв-ся инвентаризацией."
            view-as alert-box error.
        return no-apply.
    end.
    if buf-inv_trn-doc.status_ <> {&doc-froze}
        or buf-inv_trn-doc.flag_ <> yes
        then 
    do:
        message
            substitute( "Ошибка в документе инвентаризации &1 по сверке.", buf-inv_trn-doc.doc-code ) skip
            substitute( "Связанный со сверкой документ инвентаризации не находится в статусе &1", {&doc-froze} )
            view-as alert-box error.
        return no-apply.
    end.
    assign
        varstr = " документ инвентаризации"
        .
end.
if available buf-inv_trn-doc then 
do:
    assign 
        varlog = no.
    message
        "Вы хотите удалить документ инвентаризации?"
        view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then 
    do: 
        return no-apply. 
    end.
    /* удаление документа инвентаризации */
    run delete-doc-inv in this-procedure
        ( input recid(buf-inv_trn-doc)
        ) no-error.
    if error-status :error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении привязанных документов" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
    end.
    else 
    do:
        message
            "Удаление завершено."
            view-as alert-box information.
    end.
end.
else 
do:
    run str/rvscrdcs.p
        ( input parparentproc
        ,input rowid( r-doc )
        ,output v-docs-info
        ) no-error.
    if error-status :error then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании документов" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-all-r-docs
ON CHOOSE OF b-lkp IN FRAME d-all-r-docs /* Просмотр */
DO:
        br-handle = {&browse-name}:handle.
        {&no-rvs}
  case r-doc.rvs-type
            :
    when {&rvs-before-doc}
    or when {&rvs-after-doc}
    then do:
{ gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-on-doc_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
end.
    when {&rvs-shift} then do:
{ gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-shift_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
end.
    when {&rvs-control} then do:
{ gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-control_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
end.
    otherwise do:
message
    vss-workfile vss-revision vss-description skip
    "Неизвестный тип документа сверки" skip
    "Тип документа сверки" r-doc.rvs-type skip
    "Код документа сверки" r-doc.rvs-code skip
    view-as alert-box error .
undo, return no-apply .
end.
end case .
if varlog <> yes then 
do: 
    return no-apply. 
end.
do
    on stop undo, return no-apply
    :
    assign 
        rvs-rec = recid( r-doc ).
    run str/rvs-doc.w
        ( input        parparentproc
        ,input        {&lookup}
        ,input        r-doc.rvs-type
        ,input        no
        ,input-output rvs-rec
        ) no-error.
    if error-status :error then 
    do:
        return no-apply.
    end.
end.
if br-handle = ? then 
do:
    reposition {&browse-name} to recid rvs-rec no-error.
end.
apply "entry" to {&browse-name} in frame {&frame-name}.
apply "value-changed" to {&browse-name} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-all-r-docs
ON CHOOSE OF b-mark IN FRAME d-all-r-docs /* * */
DO:
        run local-mark in this-procedure .
        assign
            varlog = {&browse-name}:select-next-row ()
            .
        apply "entry" to {&browse-name} in frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-open d-all-r-docs
ON CHOOSE OF b-open IN FRAME d-all-r-docs /* Открыть */
DO:
        {&no-rvs}
  if r-doc.status_ <> {&permitted} then do:
        message
            "Данный документ сверки закрыт по факту или не может быть обработан в этом списке."
            view-as alert-box error .
        return no-apply.
    end.

find first buf-inv_trn-doc no-lock
    where buf-inv_trn-doc.out-code = r-doc.rvs-code
    no-error.
if ambiguous buf-inv_trn-doc then 
do:
    message
        "Найдено более одного складского документа связанного со сверкой."
        view-as alert-box error.
    return no-apply.
end.
if available buf-inv_trn-doc then 
do:
    if buf-inv_trn-doc.doc-type <> {&inventory} then 
    do:
        message
            "Документ связанный с документом сверки не яв-ся инвентаризацией."
            view-as alert-box error.
        return no-apply.
    end.
    if buf-inv_trn-doc.status_ <> {&doc-froze}
        or buf-inv_trn-doc.flag_ <> yes
        then 
    do:
        message
            substitute( "Ошибка в документе инвентаризации &1 по сверке.", buf-inv_trn-doc.doc-code ) skip
            substitute( "Связанный со сверкой документ инвентаризации не находится в статусе &1", {&doc-froze} )
            view-as alert-box error.
        return no-apply.
    end.
    assign
        varstr = " документ инвентаризации"
        .
end.
assign
    varlog = no
    .
message
    substitute( "Вы хотите открыть документ сверки &1?", (if varstr <> "" then "и" else "") + varstr ) skip
    view-as alert-box question buttons yes-no update varlog.
if varlog <> yes then 
do:
    return no-apply.
end.
tr:
do transaction
    on error   undo tr, return no-apply
    on end-key undo tr, return no-apply
    on stop    undo tr, return no-apply
    :
    if available buf-inv_trn-doc then 
    do:
        run delete-doc-inv in this-procedure
            ( input recid(buf-inv_trn-doc)
            ) no-error.
        if error-status :error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении привязанных документов" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo tr, return no-apply .
        end.
    end.
    run str/rvs-stat.p
        ( input parparentproc
        ,input recid(r-doc)
        ,input "open":U
        ) no-error.
    if error-status :error then 
    do:
        message
            "Ошибка при изменении статуса." skip
            return-value
            view-as alert-box error.
        undo tr, return no-apply.
    end.

    release r-doc no-error .
    if error-status :error then 
    do:
        message
            "Ошибка при открытии документа сверки." skip
            error-status:get-message(1) skip
            return-value
            view-as alert-box error.
        undo tr, leave.
    end.
end.
find r-doc no-lock
    where recid (r-doc) = rvs-rec
    .
run UI-on in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-all-r-docs
ON CHOOSE OF b-print IN FRAME d-all-r-docs /* Печать */
DO:
        {&no-rvs}
  assign rvs-rec = recid (r-doc).
        case r-doc.rvs-type
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
        'actn_rvs-on-doc_print':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
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
        'actn_rvs-shift_print':u
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
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
        'actn_rvs-control_print':u
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
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
                    "Тип документа сверки" r-doc.rvs-type skip
                    "Код документа сверки" r-doc.rvs-code skip
                    view-as alert-box error .
                undo, return no-apply .
            end.
        end case .
        if varlog <> yes then 
        do:
            return no-apply.
        end.
        run rep/r-rvsdoc.p
            ( input parparentproc
            ,input rvs-rec
            ).
        apply "entry" to {&browse-name} in frame {&frame-name}.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-all-r-docs
ON CHOOSE OF b-quit IN FRAME d-all-r-docs /* Выход */
DO:
        assign 
            rvs-rec = ?.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch d-all-r-docs
ON CHOOSE OF b-sch IN FRAME d-all-r-docs /* Фильтр */
DO:
        assign
            filter-point = "all-rvs"
            tbl          = 'rvs-doc'
            join-tbl     = 'r-doc'
            fld          = 'host-code,obj-code,obj-type,rvs-code,status_,rvs-type,out-code,fact-date,shift-date,shift-name,shift-num'
            lab          = 'Фирма,Код_объекта,Тип_Объекта,Код_сверки,Статус_сверки,Тип_сверки,Код_накладной,Дата_факт,Дата_смены,Номер_смены,Порядок_смены'
            spr          = ',,,,,,,,,'
            dim          = '10'
            .
        do
            on stop undo, leave
            :
            run gbl/filter.w
                ( input parparentproc
                ,input filter-point
                ,input tbl
                ,input join-tbl
                ,input fld
                ,input lab
                ,input spr
                ,input dim
                ).
            run openbr in this-procedure .
        end .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-all-r-docs
ON CHOOSE OF b-sel IN FRAME d-all-r-docs /* Выбор */
DO:
        {&no-rvs}
  assign
    out-rec = recid( r-doc )
            .
        apply "go" to frame {&frame-name}.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-r-docs
&Scoped-define SELF-NAME br-r-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-r-docs d-all-r-docs
ON RETURN OF br-r-docs IN FRAME d-all-r-docs
OR mouse-select-dblclick of {&browse-name} in frame {&frame-name} 
    do:
        apply "choose" to b-lkp in frame {&frame-name}.
    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-r-docs d-all-r-docs
ON ROW-DISPLAY OF br-r-docs IN FRAME d-all-r-docs
DO:
        
   
    if   autorvs(recid(r-doc)) = "А"
       then
        do:

            do ii = 1 to 34:

                bcol[ii]:FGcolor  = 7.


            end.

        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-r-docs d-all-r-docs
ON VALUE-CHANGED OF br-r-docs IN FRAME d-all-r-docs
DO:
        define buffer buf_clients for ub.clients .

        if available r-doc then 
        do:
            assign
                f-boss-name = ?
                f-agnt-name = ?
                f-wrkr-name = ?
                f-obj-name  = ?
                f-cre-name  = ?
                .
            { gbl/usrfulnm.i
      r-doc.creid
      f-cre-name
    }
            find first buf_clients no-lock
                where buf_clients.obj-type = {&prs}
                and buf_clients.obj-code = r-doc.boss
                no-error.
            if available buf_clients then 
            do:
                assign
                    f-boss-name = buf_clients.obj-name
                    .
            end.
            find first buf_clients no-lock
                where buf_clients.obj-type = {&prs}
                and buf_clients.obj-code = r-doc.agnt
                no-error.
            if available buf_clients then 
            do:
                assign
                    f-agnt-name = buf_clients.obj-name
                    .
            end.
            find first buf_clients no-lock
                where buf_clients.obj-type = {&prs}
                and buf_clients.obj-code = r-doc.wrkr
                no-error.
            if available buf_clients then 
            do:
                assign
                    f-wrkr-name = buf_clients.obj-name
                    .
            end.
            find first buf_clients no-lock
                where buf_clients.obj-type = r-doc.obj-type
                and buf_clients.obj-code = r-doc.obj-code
                no-error.
            if available buf_clients then 
            do:
                assign
                    f-obj-name = buf_clients.obj-name
                    .
            end.

            assign
                ed-notes = r-doc.ps
                .
            display
                ed-notes
                f-obj-name
                f-boss-name
                f-agnt-name
                f-wrkr-name
                f-cre-name
                with frame {&frame-name}.
        end.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Copy d-all-r-docs
ON CHOOSE OF Btn_Copy IN FRAME d-all-r-docs /* Ст.Смен. */
DO:
        if not available r-doc then 
        do:
            message
                "Не выбрана сверка, из которой нужно сделать сменную."
                view-as alert-box.
            return no-apply.
        end.
        run proc-copy in this-procedure
            no-error.
        if error-status :error then 
        do:
            return no-apply.
        end.
        run UI-on in this-procedure.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ed-notes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-notes d-all-r-docs
ON ENTRY OF ed-notes IN FRAME d-all-r-docs
DO:
        if not available r-doc then 
        do:
            message
                "Неправильный выбор документа."
                view-as alert-box .
            return no-apply.
        end.
        assign
            rvs-rec = recid( r-doc )
            .
        if r-doc.status_ <> {&fact} and substring (r-doc.PS, 1, 1) = "@" then 
        do:
            message
                "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @."
                view-as alert-box .
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-notes d-all-r-docs
ON LEAVE OF ed-notes IN FRAME d-all-r-docs
DO:
        define buffer bf-rvs for ub.rvs-doc.
        do
            on stop  undo, return no-apply
            on error undo, return no-apply
            :
            find first bf-rvs exclusive-lock
                where recid (bf-rvs) = rvs-rec
                .
            assign
                bf-rvs.PS = input frame {&frame-name} ed-notes
                .
        end.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ed-notes d-all-r-docs
ON RETURN OF ed-notes IN FRAME d-all-r-docs
OR mouse-select-dblclick of {&self-name} in frame {&frame-name}
    DO:
        apply "entry" to {&browse-name} in frame {&frame-name}.
        return no-apply.

    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-all-r-docs 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
    THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp   }
{ gbl/hot-key.i b-add   }
{ gbl/hot-key.i b-chg   }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-open  }
{ gbl/hot-key.i b-del   }
{ gbl/hot-key.i b-mark  }
{ gbl/setfltnm.i }


{ gbl/srt-clmd.i
  &browse-name   = "{&browse-name}"
  &frame-name    = "{&frame-name}"
  &table-name    = "r-doc"
  &ext-col       = 34
  &start-column  = 4
  &label-clmn_1  = "{&label-clmn_1-br-dtl}"
  &sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
  &dyn_sort-clmn_1   = "{&dyn_sort-clmn_1-br-dtl}"
  &label-clmn_2  = "{&label-clmn_2-br-dtl}"
  &sort-clmn_2   = "{&sort-clmn_2-br-dtl}"
  &label-clmn_35  = "{&label-clmn_35-br-dtl}"
  &sort-clmn_35   = "{&sort-clmn_35-br-dtl}"
  &dyn_sort-clmn_35   = "{&dyn_sort-clmn_35-br-dtl}"
  &label-clmn_3  = "{&label-clmn_3-br-dtl}"
  &sort-clmn_3   = "{&sort-clmn_3-br-dtl}"
    &dyn_sort-clmn_3   = "{&dyn_sort-clmn_3-br-dtl}"
  &label-clmn_4  = "{&label-clmn_4-br-dtl}"
  &sort-clmn_4   = "{&sort-clmn_4-br-dtl}"
  &label-clmn_5  = "{&label-clmn_5-br-dtl}"
  &sort-clmn_5   = "{&sort-clmn_5-br-dtl}"
  &label-clmn_6  = "{&label-clmn_6-br-dtl}"
  &sort-clmn_6   = "{&sort-clmn_6-br-dtl}"
  &label-clmn_7  = "{&label-clmn_7-br-dtl}"
  &sort-clmn_7   = "{&sort-clmn_7-br-dtl}"
  &label-clmn_8  = "{&label-clmn_8-br-dtl}"
  &sort-clmn_8   = "{&sort-clmn_8-br-dtl}"
  &label-clmn_9  = "{&label-clmn_9-br-dtl}"
  &sort-clmn_9   = "{&sort-clmn_9-br-dtl}"
  &label-clmn_10 = "{&label-clmn_10-br-dtl}"
  &sort-clmn_10  = "{&sort-clmn_10-br-dtl}"
  &label-clmn_11 = "{&label-clmn_11-br-dtl}"
  &sort-clmn_11  = "{&sort-clmn_11-br-dtl}"
  &dyn_sort-clmn_11  = "{&dyn_sort-clmn_11-br-dtl}"
  &sort-clmn_12  = "{&sort-clmn_12-br-dtl}"
  &sort-clmn_13  = "{&sort-clmn_13-br-dtl}"
  &sort-clmn_14  = "{&sort-clmn_14-br-dtl}"
  &sort-clmn_15  = "{&sort-clmn_15-br-dtl}"
  &sort-clmn_16  = "{&sort-clmn_16-br-dtl}"
  &sort-clmn_17  = "{&sort-clmn_17-br-dtl}"
  &sort-clmn_18  = "{&sort-clmn_18-br-dtl}"
  &sort-clmn_19  = "{&sort-clmn_19-br-dtl}" 
  &sort-clmn_20  = "{&sort-clmn_20-br-dtl}"
  &sort-clmn_21  = "{&sort-clmn_21-br-dtl}"
  &sort-clmn_22  = "{&sort-clmn_22-br-dtl}"
  &sort-clmn_23  = "{&sort-clmn_23-br-dtl}"
  &sort-clmn_24  = "{&sort-clmn_24-br-dtl}"
  &sort-clmn_25  = "{&sort-clmn_25-br-dtl}"
  &sort-clmn_26  = "{&sort-clmn_26-br-dtl}"
  &sort-clmn_27  = "{&sort-clmn_27-br-dtl}"
  &sort-clmn_28  = "{&sort-clmn_28-br-dtl}"
  &sort-clmn_29  = "{&sort-clmn_29-br-dtl}"
  &sort-clmn_30  = "{&sort-clmn_30-br-dtl}"
  &sort-clmn_31  = "{&sort-clmn_31-br-dtl}"
  &sort-clmn_32  = "{&sort-clmn_32-br-dtl}"
  &sort-clmn_33  = "{&sort-clmn_33-br-dtl}"
  &sort-clmn_34  = "{&sort-clmn_34-br-dtl}"
  &open-query           = "run OpenBr"
  &open-query-otherwise = "run OpenBr."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/mv-clmn.i
    &browse-name = "{&browse-name}"
    &frame-name  = "{&frame-name}"
    &start-column = 4
    &ext-col = 34
  }
  
  
  

    /*    gh-journal-egais:query-prepare ("for each tt_journal-egais").*/
    /*    create query   hd-rvs.    */
    /*                              */
    /*   hd-rvs:QUERY-OPEN.         */
    /*    br-r-docs:QUERY =  hd-rvs.*/

    do ii = 1 to 34:
 
        bcol[ii] = br-r-docs:get-browse-column(ii).
          
  
    end.
  
    assign
        filter-point = "all-rvs":U
        . 
        
    run UI-on in this-procedure .
    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
    
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-doc-inv d-all-r-docs 
PROCEDURE delete-doc-inv :
define input parameter pardoc-rec as recid no-undo.

    do
        on error  undo, return error substitute( "&1 (delete-doc-inv). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
        on stop   undo, return error substitute( "&1 (delete-doc-inv). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (delete-doc-inv). endkey", vss-workfile )
        :
        define variable varchg-inv    as logical   no-undo.
        define variable v-docs-list   as character no-undo .
        define variable v-ind         as integer   no-undo .
        define variable v-num-entries as integer   no-undo .
        define variable v-doc-code    as character no-undo .
        define variable v-chip-num    as integer   no-undo .
        define variable v-user-action as character no-undo .
        define variable v-printed     as logical   no-undo .

        define buffer buf_parts       for ub.parts .
        define buffer buf-inv_trn-doc for ub.trn-doc .
        define buffer buf-add_trn-doc for ub.trn-doc .

        find first buf-inv_trn-doc exclusive-lock
            where recid( buf-inv_trn-doc ) = pardoc-rec
            .
        assign
            v-docs-list = buf-inv_trn-doc.doc-code
            .
        for each buf-add_trn-doc
            where buf-add_trn-doc.out-code = buf-inv_trn-doc.doc-code
            on error undo, return error return-value
            :
            assign
                v-docs-list = buf-add_trn-doc.doc-code + ",":U + v-docs-list
                .
        end.

        assign
            v-num-entries = num-entries( v-docs-list )
            .
        do v-ind = 1 to v-num-entries
            on error undo, return error return-value
            :
            assign
                v-doc-code = entry( v-ind, v-docs-list )
                .
            find first buf-add_trn-doc exclusive-lock
                where buf-add_trn-doc.doc-code = v-doc-code
                .
            assign
                buf-add_trn-doc.status_ = {&permitted}
                buf-add_trn-doc.flag_   = yes
                .
            /* разр+ - накл+ */
            run str/trn-stat.p
                ( input parparentproc
                , input this-procedure
                ,input {&open-doc}
                ,input buf-add_trn-doc.doc-code
                ,input ?
                ,input v-cntxt-db-num
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input yes
                ,output varchg-inv
                ,output table gds-list
                ) no-error.
            if error-status :error then 
            do:
                undo, return error return-value.
            end.
            /* накл+ - накл- */
            release buf-add_trn-doc.

            find first buf-add_trn-doc exclusive-lock
                where buf-add_trn-doc.doc-code = v-doc-code
                .
            run str/trn-stat.p
                ( input parparentproc
                , input this-procedure
                ,input {&open-doc}
                ,input buf-add_trn-doc.doc-code
                ,input ?
                ,input v-cntxt-db-num
                ,input ?
                ,input ?
                ,input ?
                ,input ?
                ,input yes
                ,output varchg-inv
                ,output table gds-list
                ) no-error.
            if error-status :error then 
            do:
                undo, return error return-value.
            end.
            case buf-add_trn-doc.doc-type :
                when {&income} then 
                    do:
                        { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income_preparation':U
            {&cntxt-object}
            buf-add_trn-doc.host-code
            buf-add_trn-doc.obj-type
            buf-add_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
                    end.
                when {&expense} then 
                    do:
                        { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense_preparation':U
            {&cntxt-object}
            buf-add_trn-doc.host-code
            buf-add_trn-doc.obj-type
            buf-add_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
                    end.
                when {&write-off} then 
                    do:
                        { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_write-off_preparation':U
            {&cntxt-object}
            buf-add_trn-doc.host-code
            buf-add_trn-doc.obj-type
            buf-add_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
                    end.
                when {&inventory} then 
                    do:
                        { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_inventory_delete':U
            {&cntxt-object}
            buf-add_trn-doc.host-code
            buf-add_trn-doc.obj-type
            buf-add_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
                    end.
                when {&return} then 
                    do:
                        { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_return_preparation':U
            {&cntxt-object}
            buf-add_trn-doc.host-code
            buf-add_trn-doc.obj-type
            buf-add_trn-doc.obj-code
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
                        "Неизвестный тип документа" skip
                        "Тип документа" buf-add_trn-doc.doc-type skip
                        "Код документа" buf-add_trn-doc.doc-code skip
                        view-as alert-box error .
                    undo, return no-apply .
                end.
            end case .
            if varlog <> yes
                then 
            do:
                undo, return error.
            end.

            run waitfram-show in this-procedure ( input "Удаление документа № " + buf-add_trn-doc.doc-code + ". Ждите..." ).

            if search ("del-doc.err") <> ? then 
            do:
                os-delete "del-doc.err".
            end.
            run str/del-doc.p
                ( input  parparentproc
                , input  buf-add_trn-doc.doc-code
                , input  v-cntxt-db-num
                , input  "del-doc.err":U
                , input  ?
                , input  ?
                , input  v-cntxt-userid
                , input  0
                , input  ?
                , output v-chip-num
                ) no-error.
            if error-status:error then 
            do:
                run waitfram-hide in this-procedure .
                message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при удалении документа." skip
                    return-value
                    view-as alert-box error.
                if search ("del-doc.err") <> ? then 
                do:
                    run gbl/prnfilen.w
                        (input  "Ошибки при удалении документа"
                        ,input  0
                        ,input  "del-doc.err"
                        ,input  7
                        ,output v-user-action
                        ,output v-printed
                        ).
                end.
                undo, return error.
            end.
            rvsinvstrObj = new rvsinvstr ().
            rvsinvstrObj:DeleteDB(r-doc.rvs-code, r-doc.obj-type, r-doc.obj-code).

            run waitfram-hide in this-procedure .
        end.
    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-all-r-docs  _DEFAULT-DISABLE
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
  HIDE FRAME d-all-r-docs.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-all-r-docs  _DEFAULT-ENABLE
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
  DISPLAY ed-notes f-boss-name f-obj-name f-agnt-name f-wrkr-name f-cre-name 
      WITH FRAME d-all-r-docs.
  ENABLE b-quit b-mark b-sel b-add b-lkp b-chg b-del b-close b-open b-hist 
         b-help Btn_Copy b-inv b-sch b-print br-r-docs ed-notes 
      WITH FRAME d-all-r-docs.
  VIEW FRAME d-all-r-docs.
  {&OPEN-BROWSERS-IN-QUERY-d-all-r-docs}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-mark d-all-r-docs 
PROCEDURE local-mark :
if not available r-doc then 
    do:
        message "Неправильный выбор строки.".
        return .
    end.
    { gbl/markstrn.i r-doc del-list }
    {&browse-name}:refresh() in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr d-all-r-docs 
PROCEDURE Openbr :
define variable sort-column-phrase as character no-undo .
    define variable l-query-was-opened as logical   no-undo .

    define buffer bf_clients for ub.clients.



    run waitfram-show in this-procedure
        (input "Ждите..."
        ).

    case sort-column-name :
        when "" then 
            do:
                assign
                    sort-column-phrase = ""
                    .
            end.
        otherwise 
        do:
            assign
                sort-column-phrase = "by " + sort-column-name
                .
        end.
    end case.

  &scop flt-open-open-query         open query {&browse-name} for each r-doc
  &scop flt-open-dyn_open-query     FOR EACH r-doc
  &scop flt-open-query-handle       query {&browse-name}:handle
  &scop flt-open-find-buffer-name   r-doc
  &scop flt-open-open-query-tail      
  &scop flt-open-query-was-opened   l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point         filter-point
  &scop flt-open-set-filter-name    set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition

  


    assign
        varobj-type  = v-cntxt-obj-type
        varobj-code  = v-cntxt-obj-code
        varhost-code = v-cntxt-host-code-obj
        vartest-asi  = {&test-asi}   
    .
    find first bf_clients  where bf_clients.obj-type = v-cntxt-obj-type and
        bf_clients.obj-code = v-cntxt-obj-code no-lock.
        
    case parlist-mode:
        
        when {&work} then 
            do:
                assign 
                    frame {&frame-name}:title = "ДОКУМЕНТЫ СВЕРКИ".
                { gbl/fltopend.i
                  &where-cond = " r-doc.rvs-type <> vartest-asi "
                  &dyn_where-cond = " substitute( '  r-doc.rvs-type <> &1&2&1 ' , ~{&double-quote~} , vartest-asi ) "
                  &use-ind    = "  "
                  &by         = "  " }
            end.
        when {&company} then 
            do:
                assign 
                    frame {&frame-name}:title = "ДОКУМЕНТЫ СВЕРКИ Фирма : " + string(varhost-code).
                { gbl/fltopend.i
                  &where-cond = " r-doc.host-code = varhost-code and r-doc.rvs-type <> vartest-asi "
                  &dyn_where-cond = " substitute( '  r-doc.host-code = &2 and r-doc.rvs-type <> &1&3&1 ' , ~{&double-quote~} , varhost-code , vartest-asi ) "
                  &use-ind    = " use-index host-date "
                  &by         = "  " }
            end.
        when {&g___object} then 
            do:
                assign 
                    frame {&frame-name}:title = "ДОКУМЕНТЫ СВЕРКИ Объект : " + varobj-type + " " + string (varobj-code).
                { gbl/fltopend.i
                  &where-cond = " r-doc.obj-type = varobj-type and   r-doc.obj-code = varobj-code  and r-doc.rvs-type <> vartest-asi "
                  &dyn_where-cond = " substitute( '  ~
                                    r-doc.obj-type =  &1&2&1 and ~
                                    r-doc.obj-code =  &3 and   ~
                                    r-doc.rvs-type <> &1&4&1  ~
                                   ' , ~{&double-quote~} , varobj-type , varobj-code , vartest-asi  ) "
                  &use-ind    = "use-index stat-date "
                  &by         = "  " }
                if v-cntxt-db-num = bf_clients.db-num then
                    enable b-add b-chg b-del b-close b-open b-inv btn_copy with frame {&frame-name}.
            end.
            
        when {&status} then 
            do:
                assign 
                    varstatus_ = parstatus.
                assign 
                    frame {&frame-name}:title = "Объект : " + varobj-type + " " + string (varobj-code) + "  Статус : " + varstatus_.
                { gbl/fltopend.i
                  &where-cond = "r-doc.obj-type = varobj-type and
                                r-doc.obj-code = varobj-code and
                                r-doc.status_  = varstatus_ and
                                r-doc.rvs-type <> vartest-asi     "
                  &dyn_where-cond = " substitute( '  ~
                                    r-doc.obj-type =  &1&2&1 and ~
                                    r-doc.obj-code =  &3  and  ~
                                    r-doc.status_  =  &1&4&1 and ~
                                    r-doc.rvs-type <> &1&5&1  ~
                                    ' , ~{&double-quote~} , varobj-type , varobj-code , varstatus_ , vartest-asi ) "
        
                  &use-ind    = "use-index stat-date"
                  &by         = "  " }
                if v-cntxt-db-num = bf_clients.db-num and
                    parstatus <> {&fact}            then
                    enable b-add b-chg b-del b-close b-open b-inv btn_copy with frame {&frame-name}.
            end.
        when "choose-control" then 
            do :
                assign 
                    frame {&frame-name}:title = "ДОКУМЕНТЫ СВЕРКИ Объект : " + varobj-type + " " + string (varobj-code) + "  Статус : факт    Тип: контроль".
                { gbl/fltopend.i
                  &where-cond = "r-doc.obj-type = varobj-type and
                                r-doc.obj-code = varobj-code and
                                r-doc.status_  = {&fact}     and
                                r-doc.rvs-type = {&rvs-control} "
                  &dyn_where-cond = " substitute( '  ~
                                    r-doc.obj-type =  &1&2&1 and ~
                                    r-doc.obj-code =  &3  and  ~
                                    r-doc.status_  =  &1&4&1  ~
                                    r-doc.rvs-type =  &1&5&1  ~
                                    ' , ~{&double-quote~} , varobj-type , varobj-code , {&fact}, {&rvs-control} ) "
        
                  &use-ind    = "  "
                  &by         = "  " }
                enable b-sel with frame {&frame-name}.   
            end.    
    end case.

    apply "entry" to {&browse-name} in frame {&frame-name}.

    if rvs-rec <> ? then 
    do:
        reposition {&browse-name} to recid rvs-rec no-error.
    end.

    if available r-doc then 
    do:
  apply "value-changed" to {&browse-name} in frame {&frame-name}. 
    end.

    run waitfram-hide in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-copy d-all-r-docs 
PROCEDURE proc-copy :
define variable v-str as character no-undo.
    define variable jj    as integer   no-undo.

    do
        on error   undo, return error
        on end-key undo, return error
        on stop    undo, return error
        :
        if not available r-doc then 
        do:
            message "Не выбрана сверка, из которой нужно сделать сменную." view-as alert-box.
            return error.
        end.
        run str/ctrc2sht.p
            ( input parparentproc
            ,input recid( r-doc )
            ) no-error.
        if error-status :error then 
        do:
            assign 
                v-str = "":U.
            do jj = 1 to error-status :num-messages :
                assign 
                    v-str = v-str + ( if v-str = "":U then "":U else {&new-line} ) + error-status :get-message( jj ).
            end.
            assign 
                v-str = v-str + ( if v-str = "":U then "":U else {&new-line} ) + return-value.
            message
                "Ошибка создания сверки." skip
                v-str
                view-as alert-box error title " О Ш И Б К А ! ! ! ".
            for each tt-susp-chk:
                find first ub.susp-chk exclusive-lock where ub.susp-chk.doc-code = tt-susp-chk.doc-code no-error .
                if not available (ub.susp-chk) then 
                do:
                    create ub.susp-chk .
                    buffer-copy tt-susp-chk to ub.susp-chk .
                end.
                else do:
                    ub.susp-chk.reason-name = tt-susp-chk.reason-name .
                    ub.susp-chk.link-chk = tt-susp-chk.link-chk .
                end.
            end. 
            return error.
        end.
    end. /* on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-del d-all-r-docs 
PROCEDURE proc-del :
define variable del-rec   as recid   no-undo.
    define variable unrv-qnty as decimal no-undo. /* количество из gds-dtl, по которому снимаются резервы перед удалением */
    define variable varfind   as logical no-undo.

    define buffer bf-prev_rvs-doc  for ub.rvs-doc.
    define buffer bf_trn-doc       for ub.trn-doc.
    define buffer bf_doc-line      for ub.doc-line.
    define buffer bf_goods         for ub.goods.
    define buffer bf_rvs-line      for ub.rvs-line.
    define buffer bf-prev_rvs-line for ub.rvs-line.

    do
        on error   undo, return error
        on end-key undo, return error
        on stop    undo, return error
        :
        if r-doc.status_ <> {&g___new}
            and r-doc.status_ <> {&fact}
            then 
        do:
            message
                "Документ в данном статусе не может быть удален."
                view-as alert-box.
            return error   "Документ сверки с типом 'смена' в данном статусе не может быть удален" .
        end.
        if r-doc.status_ = {&fact} then 
        do:
            if r-doc.rvs-type = {&rvs-shift} then 
            do:
                message
                    "Документ сверки с типом 'смена' в данном статусе не может быть удален"
                    view-as alert-box.
                return error   "Документ сверки с типом 'смена' в данном статусе не может быть удален" .
            end.
            else 
            do:
                if r-doc.rvs-type <> {&rvs-control} then 
                do:
                    message
                        "Закрытый документ сверки с типом, отличным от 'контроль', не может быть удален"
                        view-as alert-box.
                    return error "Закрытый документ сверки с типом, отличным от 'контроль', не может быть удален" .
                end.
                else 
                do:
                    case r-doc.rvs-type :
                        when {&rvs-control} then 
                            do:
                                { gbl/chk-actg.i
                                  v-cntxt-db-num
                                  v-cntxt-userid
                                  {&action-head-code-main}
                                  'actn_rvs-control_del-fact':U
                                  {&cntxt-object}
                                  r-doc.host-code
                                  r-doc.obj-type
                                  r-doc.obj-code
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
                                "Тип документа сверки" r-doc.rvs-type skip
                                "Код документа сверки" r-doc.rvs-code skip
                                view-as alert-box error .
                            undo, return no-apply .
                        end.
                    end case .
                    if varlog <> yes then 
                    do: 
                        return error. 
                    end.
                    for each bf_rvs-line no-lock
                        where bf_rvs-line.rvs-code = r-doc.rvs-code
                        on error undo, return error
                        :
                        assign
                            varfind = no
                            .
                        for each bf-prev_rvs-doc no-lock
                            where bf-prev_rvs-doc.obj-type   = r-doc.obj-type
                            and bf-prev_rvs-doc.obj-code   = r-doc.obj-code
                            and bf-prev_rvs-doc.fact-order < r-doc.fact-order
                            ,first bf-prev_rvs-line no-lock
                            where bf-prev_rvs-line.rvs-code = bf-prev_rvs-doc.rvs-code
                            and bf-prev_rvs-line.gds-code = bf_rvs-line.gds-code
                            on error undo, return error
                            :
                            assign 
                                varfind = yes.
                            leave.
                        end. /* for each bf-prev_rvs-doc */

                        /* первая сверка */
                        if varfind <> yes then 
                        do:
                            find first bf_goods no-lock
                                where bf_goods.gds-code = bf_rvs-line.gds-code
                                .
                            find first bf_doc-line no-lock
                                where bf_doc-line.obj-type  = r-doc.obj-type
                                and bf_doc-line.obj-code  = r-doc.obj-code
                                and bf_doc-line.artic     = bf_goods.artic
                                and bf_doc-line.prod-type = bf_goods.prod-type
                                and bf_doc-line.prod-code = bf_goods.prod-code
                                no-error.
                            if available bf_doc-line then 
                            do:
                                message
                                    "Нельзя удалить сверку, являющуюся первой контрольной для товара."
                                    "На объекте есть складские документы по этому товару. Номер документа " bf_doc-line.doc-code
                                    " Товар " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code
                                    view-as alert-box.
                                return error substitute (      "Нельзя удалить сверку, являющуюся первой контрольной для товара.
                  На объекте есть складские документы по этому товару. Номер документа  &1 
                  Товар &2&3&4 " , bf_doc-line.doc-code , bf_doc-line.artic , bf_doc-line.prod-type, bf_doc-line.prod-code).
                            end.
                        end.
                        find first bf_trn-doc no-lock where bf_trn-doc.out-code = r-doc.rvs-code no-error.
                        if available bf_trn-doc then 
                        do:
                            message "К сверке есть привязанные складские документы. Удалить нельзя."
                                "Номер документа " bf_trn-doc.doc-code " ."
                                view-as alert-box.
                            return error "К сверке есть привязанные складские документы. Удалить нельзя." .
                        end.
                    end. /* for each bf_rvs-line */
                end. /* r-doc.rvs-type = {&rvs-control} */
            end. /* r-doc.rvs-type <> {&rvs-shift} */
        end. /* r-doc.status_ = {&fact} */

        assign 
            varlog = no.
        message
            "Удалить документ сверки №" r-doc.rvs-code "?" skip
            "   Вы уверены ?"
            view-as alert-box question buttons OK-Cancel update varlog.
        assign
            rvs-rec = recid( r-doc )
            .
        if not varlog then 
        do:
            find first r-doc no-lock
                where recid (r-doc) = rvs-rec
                .
            return no-apply.
        end.
        case r-doc.rvs-type
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
          'actn_rvs-on-doc_deletion':U
          {&cntxt-object}
          r-doc.host-code
          r-doc.obj-type
          r-doc.obj-code
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
          'actn_rvs-shift_deletion':U
          {&cntxt-object}
          r-doc.host-code
          r-doc.obj-type
          r-doc.obj-code
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
          'actn_rvs-control_deletion':U
          {&cntxt-object}
          r-doc.host-code
          r-doc.obj-type
          r-doc.obj-code
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
                    "Тип документа сверки" r-doc.rvs-type skip
                    "Код документа сверки" r-doc.rvs-code skip
                    view-as alert-box error .
                undo, return no-apply .
            end.
        end case .
        if not varlog then 
        do:
            find first r-doc no-lock
                where recid (r-doc) = rvs-rec
                .
            return no-apply.
        end.
        run waitfram-show in this-procedure
            ( input "Удаление документа сверки № " + r-doc.rvs-code + ". Ждите..."
            ).
        assign
            br-handle = {&browse-name} :handle in frame {&FRAME-NAME}
            del-rec   = recid( r-doc )
            .

        if valid-handle( br-handle ) then 
        do:
            assign
                varlog = br-handle :select-next-row( )
                .
            if varlog <> true then 
            do:
                assign
                    varlog = br-handle :select-prev-row( )
                    .
            end.
            if varlog = true then 
            do:
                assign
                    rvs-rec = recid( r-doc )
                    .
            end.
        end.

        del-doc:
        do transaction
            on stop    undo del-doc, retry del-doc
            on error   undo del-doc, retry del-doc
            on end-key undo del-doc, retry del-doc
            :
            if retry then 
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    substitute("Ошибка при удалении сверки.") skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                leave del-doc .
            end.
            find first r-doc exclusive-lock
                where recid( r-doc ) = del-rec
                .
            assign
                r-doc.is-del = true
                .
            delete r-doc.
        end. /* del-doc */
        run waitfram-hide in this-procedure .
    end. /* on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI-on d-all-r-docs 
PROCEDURE UI-on :
ENABLE
        b-quit
        b-lkp
        b-print
        b-sch
        b-hist
        b-help
        ed-notes
        {&browse-name}
        WITH FRAME {&frame-name}.
    ASSIGN
        {&enabled-clmn}:READ-ONLY in browse {&browse-name} = YES
    .
    run OpenBr in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE userlogrvs d-all-r-docs 
PROCEDURE userlogrvs :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define input parameter p-vid-action as integer  no-undo .
define input parameter p-mess as char no-undo.
    define variable v-person as character no-undo.  
    define variable v-vid-param  as longchar no-undo .
  define variable v-result as integer no-undo.
  define variable varshift-date as date no-undo.
  define variable  varshift-num as integer no-undo.
  define variable varshift-name as char no-undo.
  
    
    { gbl/curshift.i
    r-doc.obj-type
    r-doc.obj-code
    varshift-date
    varshift-num
    varshift-name
    no-error
  }
        for first  ub.clients where ub.clients.obj-type = {&prs} and  ub.clients.obj-code = ub.c-rvs-doc.boss no-lock : 
            v-person = clients.obj-name.
        end.
    v-vid-param =
        "Initiator=" + "User" + {&delim-par} +
        "ResponsiblePerson=" + (if v-person <> ?  then v-person else "") + {&delim-par} + 
        "SHOP_NUM=" + string(r-doc.obj-code) + {&delim-par} +
        "DocNum=" + string(r-doc.rvs-code) + {&delim-par} +
        "FactDate=" + (if string(r-doc.fact-date) = ? then '' else string(r-doc.fact-date)) + {&delim-par} +
        "DocType=" + string(r-doc.rvs-type) + {&delim-par} +
        "SHIFT_NUM_DOC=" + (if string(r-doc.shift-num) = ? then '' else string(r-doc.shift-num)) + (if string(r-doc.shift-date) = ? then '' else string(r-doc.shift-date ,  "99999999" )) + {&delim-par} + 
        "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
        "Status=" + string(r-doc.status_) + {&delim-par} +
        "RESULT=" + string( 1 ) + {&delim-par} + 
        "Description=" + p-mess no-error.
        
         
        run trg/userlog.p (
            input if p-vid-action = 60 then {&nwsdochs_action_delete_err} else {&nwsdochs_action_update_err}
            , input {&table_rvs-doc}
            , input ( buffer r-doc :handle )
            , input p-vid-action
            , input v-vid-param
            ) no-error.
        if error-status :error
            then 
        do:
            message substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ) 
                view-as alert-box.
            return no-apply.
        end. 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string d-all-r-docs 
FUNCTION mark-string RETURNS CHARACTER
    ( p-rec as recid ) :
    def buffer loc-rvs-doc for ub.rvs-doc  .
    find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
    if error-status :error then return '' .

    if can-do (del-list, string (recid (loc-rvs-doc))) then RETURN "*".
    else RETURN "".
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-input-type d-all-r-docs 
FUNCTION get-input-type RETURNS CHARACTER
    ( p-rec as recid ) :
    def buffer loc-rvs-doc for ub.rvs-doc  .
    define buffer loc-rvs-line for ub.rvs-line .
    define buffer loc-rvs-line-attr for ub.rvs-line-attr .
    define variable v-doc-input-type as character no-undo .
    define variable v-input-type-list as character no-undo .
    
    find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
    for each loc-rvs-line no-lock where loc-rvs-line.rvs-code = loc-rvs-doc.rvs-code :
      find first loc-rvs-line-attr no-lock
            where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
            and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
            and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
            and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
            and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
            and loc-rvs-line-attr.attr-code = 'input-type'
            no-error.
      if available loc-rvs-line-attr
      then do :
        v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
      end.
    end.
    if trim(v-input-type-list) = ""
    then do :
      for each loc-rvs-line no-lock where loc-rvs-line.rvs-code = loc-rvs-doc.rvs-code :
        find first loc-rvs-line-attr no-lock
              where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
              and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
              and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
              and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
              and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
              and loc-rvs-line-attr.attr-code = 'input-type-p'
              no-error.
        if available loc-rvs-line-attr
        then do :
          v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
        end.
        find first loc-rvs-line-attr no-lock
              where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
              and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
              and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
              and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
              and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
              and loc-rvs-line-attr.attr-code = 'input-type-t'
              no-error.
        if available loc-rvs-line-attr
        then do :
          v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
        end.
        find first loc-rvs-line-attr no-lock
              where loc-rvs-line-attr.obj-code  = loc-rvs-line.obj-code
              and loc-rvs-line-attr.obj-type  = loc-rvs-line.obj-type
              and loc-rvs-line-attr.gds-code  = loc-rvs-line.gds-code
              and loc-rvs-line-attr.pl-code   = loc-rvs-line.pl-code
              and loc-rvs-line-attr.rvs-code  = loc-rvs-line.rvs-code
              and loc-rvs-line-attr.attr-code = 'input-type-l'
              no-error.
        if available loc-rvs-line-attr
        then do :
          v-input-type-list = v-input-type-list + ',' + loc-rvs-line-attr.attr-value .
        end.
      end.
    end .
    v-input-type-list = left-trim(v-input-type-list, ",") .
    
    if can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п') 
    then v-doc-input-type = 'а'.
    
    if can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'фк')
    and not can-do(v-input-type-list, 'п') 
    then v-doc-input-type = 'ф'.
    
    if  not can-do(v-input-type-list, 'ф')
    and can-do(v-input-type-list, 'ак')
    and not can-do(v-input-type-list, 'п') 
    then v-doc-input-type = 'ак'.
    
    if ((can-do(v-input-type-list, 'ф')
    or can-do(v-input-type-list, 'п')) 
    and can-do(v-input-type-list, 'а'))
    or can-do(v-input-type-list, 'фк')
    then v-doc-input-type = 'фк'.
    
    if can-do(v-input-type-list, 'р')
    and not can-do(v-input-type-list, 'а')
    and not can-do(v-input-type-list, 'ф')
    and not can-do(v-input-type-list, 'к')
    and not can-do(v-input-type-list, 'п') 
    then v-doc-input-type = 'р'.
    
    if v-doc-input-type = 'а'
    and (can-do(v-input-type-list, 'р')  
      or can-do(v-input-type-list, ''))
    then v-doc-input-type = 'ак'.
    
    if v-doc-input-type = 'ф'
    and (can-do(v-input-type-list, 'р')  
      or can-do(v-input-type-list, ''))
    then v-doc-input-type = 'фк'.
    
    if v-doc-input-type = ? then v-doc-input-type = '' .
    return v-doc-input-type .
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION shift-name d-all-r-docs 
FUNCTION shift-name RETURNS CHARACTER
    ( p-rec as recid ) :
    def buffer loc-rvs-doc for ub.rvs-doc  .
    find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
    if error-status :error then return '' .

    if loc-rvs-doc.shift-date = ? then 
    do:
        return "":u.
    end.
    else 
    do:
        if loc-rvs-doc.shift-num = integer(loc-rvs-doc.shift-name) then 
        do:
            return loc-rvs-doc.shift-name.
        end.
        else 
        do:
            return loc-rvs-doc.shift-name + "(" + string(loc-rvs-doc.shift-num) + ")".
        end.
    end.
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

