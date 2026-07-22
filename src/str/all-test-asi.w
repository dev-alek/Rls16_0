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

Список документов проверки корректности работы АСИ в резервуаре

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
define variable vss-description as character no-undo initial "Список документов проверки корректности работы АСИ в резервуаре":U .
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


define buffer buf-inv_trn-doc for ub.trn-doc .
define buffer buf-spi_trn-doc for ub.trn-doc .

&scop no-rvs ~
  if not available r-doc then do: ~
    message ~
      "Неправильный выбор документа проверки корректности работы АСИ в резервуаре." ~
      view-as alert-box . ~
    return no-apply. ~
  end. ~
  else do: ~
    assign ~
      rvs-rec = recid (r-doc) ~
    . ~
  end.
&scop ERR_POKMI "Работа с документом проверки корректности работы АСИ в резервуаре ~
невозможна при выключенной интеграции с библиотекой ПОкМИ." 

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
define variable rdc-value        as character no-undo .
define variable rdc-type         as character no-undo.
/*define variable p-autorvs as logical no-undo.*/





&scop label-clmn_1-br-dtl     ' Tип '
&scop label-clmn_2-br-dtl     ' '
&scop label-clmn_3-br-dtl     'Стат'
&scop label-clmn_4-br-dtl     'Документ'
&scop label-clmn_5-br-dtl     'Дата'
&scop label-clmn_6-br-dtl     'Факт'
&scop label-clmn_7-br-dtl     'Время'
&scop label-clmn_8-br-dtl     'Смена'
&scop label-clmn_9-br-dtl     '№'
&scop label-clmn_10-br-dtl    'Объект'

&scop sort-clmn_1-br-dtl        (substring (r-doc.rvs-type, 1, 9))
&scop sort-clmn_2-br-dtl         autorvs (recid(r-doc))
&scop dyn_sort-clmn_2-br-dtl    substitute('dynamic-function(&1autorvs&1, recid(r-doc)) ', ~{&double-quote~} )
&scop sort-clmn_3-br-dtl        r-doc.status_
&scop sort-clmn_4-br-dtl        r-doc.rvs-code
&scop sort-clmn_5-br-dtl        (substring ((string (r-doc.doc-date)), 1, 5))
&scop sort-clmn_6-br-dtl        r-doc.fact-date
&scop sort-clmn_7-br-dtl        string(r-doc.fact-time,'hh:mm:ss')
&scop sort-clmn_8-br-dtl        (substring ((string (r-doc.shift-date)), 1, 5))
&scop sort-clmn_9-br-dtl       shift-name (recid(r-doc))
&scop dyn_sort-clmn_9-br-dtl   substitute('dynamic-function(&1shift-name&1, recid( r-doc)) ', ~{&double-quote~} )
&scop sort-clmn_10-br-dtl       obj-name (recid(r-doc))
&scop dyn_sort-clmn_10-br-dtl   substitute('dynamic-function(&1obj-name&1, recid( r-doc)) ', ~{&double-quote~} )

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
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-lkp ~
b-close b-print br-r-docs ed-notes 
&Scoped-Define DISPLAYED-OBJECTS ed-notes f-boss-name f-obj-name ~
f-agnt-name f-wrkr-name f-cre-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-input-type d-all-r-docs 
FUNCTION obj-name RETURNS CHARACTER
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

DEFINE BUTTON b-lkp 
     LABEL "Просмотр":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-mark 
     LABEL "*":L 
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "Печать":L 
     SIZE 7 BY 1.

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "Выход":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel 
     LABEL "Выбор":L 
     SIZE 10 BY 1.

DEFINE VARIABLE ed-notes AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 99 BY 2
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE f-agnt-name AS CHARACTER FORMAT "X(19)":U 
     LABEL "Исп" 
      VIEW-AS TEXT 
     SIZE 19.6 BY .67 NO-UNDO.

DEFINE VARIABLE f-boss-name AS CHARACTER FORMAT "X(19)":U 
     LABEL "М-р" 
      VIEW-AS TEXT 
     SIZE 19.6 BY .67 NO-UNDO.

DEFINE VARIABLE f-cre-name AS CHARACTER FORMAT "X(19)":U 
     LABEL "Опер" 
      VIEW-AS TEXT 
     SIZE 19.6 BY .67 NO-UNDO.

DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(13)":U 
     LABEL "Объект" 
      VIEW-AS TEXT 
     SIZE 62.6 BY .67 NO-UNDO.

DEFINE VARIABLE f-wrkr-name AS CHARACTER FORMAT "X(19)":U 
     LABEL "Кл-к" 
      VIEW-AS TEXT 
     SIZE 19.6 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE NEW SHARED QUERY {&browse-name} for r-doc SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-r-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-r-docs d-all-r-docs _FREEFORM
  QUERY br-r-docs DISPLAY
     {&sort-clmn_1-br-dtl}  COLUMN-LABEL {&label-clmn_1-br-dtl}  FORMAT "x(20)"
     {&sort-clmn_2-br-dtl}  COLUMN-LABEL {&label-clmn_2-br-dtl}  FORMAT "x(2)"
     {&sort-clmn_3-br-dtl}  COLUMN-LABEL {&label-clmn_3-br-dtl}  format "x(5)"
     {&sort-clmn_4-br-dtl}  column-label {&label-clmn_4-br-dtl}  format "x(15)"
     {&sort-clmn_5-br-dtl}  column-label {&label-clmn_5-br-dtl}  
     {&sort-clmn_6-br-dtl}  COLUMN-LABEL {&label-clmn_6-br-dtl}  
     {&sort-clmn_7-br-dtl}  COLUMN-LABEL {&label-clmn_7-br-dtl}
     {&sort-clmn_8-br-dtl}  COLUMN-LABEL {&label-clmn_8-br-dtl}  format "x(5)"
     {&sort-clmn_9-br-dtl}  column-label {&label-clmn_9-br-dtl}  format "x(10)"
     {&sort-clmn_10-br-dtl} column-label {&label-clmn_10-br-dtl} 
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 99 BY 16.76.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-all-r-docs
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     b-add AT ROW 1 COL 24
     b-chg AT ROW 1 COL 34
     b-del AT ROW 1 COL 44
     b-lkp AT ROW 1 COL 54
     b-close AT ROW 1 COL 64
     b-print AT ROW 1 COL 92.6
     br-r-docs AT ROW 2 COL 1
     ed-notes AT ROW 20.52 COL 1 NO-LABEL
     f-boss-name AT ROW 19 COL 5 COLON-ALIGNED
     f-obj-name AT ROW 19 COL 35 COLON-ALIGNED
     f-agnt-name AT ROW 19.76 COL 5 COLON-ALIGNED
     f-wrkr-name AT ROW 19.76 COL 35 COLON-ALIGNED
     f-cre-name AT ROW 19.76 COL 65 COLON-ALIGNED
     SPACE(13.40) SKIP(2.09)
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
/*        define buffer bf_rvs-doc  for ub.rvs-doc.                                                                     */
/*                                                                                                                      */
/*        find first bf_rvs-doc no-lock                                                                                 */
/*            where bf_rvs-doc.obj-type =  v-cntxt-obj-type                                                             */
/*            and bf_rvs-doc.obj-code =  v-cntxt-obj-code                                                               */
/*            and bf_rvs-doc.status_  <> {&fact}                                                                        */
/*            and bf_rvs-doc.rvs-type = {&test-asi}                                                                     */
/*            no-error.                                                                                                 */
/*                                                                                                                      */
/*                                                                                                                      */
/*        if available bf_rvs-doc then                                                                                  */
/*        do:                                                                                                           */
/*            message                                                                                                   */
/*                "Имеется не закрытый документ проверки корректности работы АСИ в резервуаре " bf_rvs-doc.rvs-code " ."*/
/*                view-as alert-box error.                                                                              */
/*            return no-apply.                                                                                          */
/*        end.                                                                                                          */
        if rdc-value <>  "pomi-rn" then
        do:
          message {&ERR_POKMI} view-as alert-box.
          return no-apply.  
        end.
        
        assign
            rvs-rec = ?
            .
        do
            on stop undo, return no-apply
            :
            run str/test-asi-add.p
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
            "Новый документ проверки корректности работы АСИ в резервуаре добавлен в Базу Данных."
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
  then do:
        message
            "Данный документ проверки корректности работы АСИ в резервуаре закрыт по факту или не может быть обработан в этом списке."
            view-as alert-box.
        return no-apply.
  end.
  if rdc-value <>  "pomi-rn" then
  do:
    message {&ERR_POKMI} view-as alert-box.
    return no-apply.  
  end.

  assign
      rvs-rec = recid( r-doc )
  .
  run str/test-asi-doc.w
      ( input        parparentproc
      ,input        {&update}
      ,input        ""
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
  then do:
      message
          "Данный документ проверки корректности работы АСИ в резервуаре закрыт по факту или не может быть обработан в этом списке."
          view-as alert-box.
      return no-apply.
  end.
  if r-doc.status_ = {&g___new} then 
  do:
    if rdc-value <>  "pomi-rn" then
    do:
      message {&ERR_POKMI} view-as alert-box.
      return no-apply.  
    end.
    assign
        varlog = no
        .
    message
        "Вы хотите закрыть документ проверки корректности работы АСИ в резервуаре?"
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
          "Ошибка при закрытии документа проверки корректности работы АСИ в резервуаре." skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
        undo tr, leave.
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
    if rdc-value <>  "pomi-rn" then
    do:
      message {&ERR_POKMI} view-as alert-box.
      return no-apply.  
    end.
    
    p-rvs-doc = r-doc.rvs-code.
    run proc-del in this-procedure
        no-error.

    run openbr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp d-all-r-docs
ON CHOOSE OF b-lkp IN FRAME d-all-r-docs /* Просмотр */
DO:
        br-handle = {&browse-name}:handle.
        {&no-rvs}
do
    on stop undo, return no-apply
    :
    assign 
        rvs-rec = recid( r-doc ).
    run str/test-asi-doc.w
        ( input        parparentproc
        ,input        {&lookup}
        ,input        ""
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


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-all-r-docs
ON CHOOSE OF b-print IN FRAME d-all-r-docs /* Печать */
DO:
    {&no-rvs}
    assign rvs-rec = recid (r-doc).

    run rep/r-testasidoc.p
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

{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-lkp   }
{ gbl/hot-key.i b-add   }
{ gbl/hot-key.i b-chg   }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-del   }
{ gbl/hot-key.i b-mark  }

&if defined(browse-name) > 0 and defined(disable_diasize) = 0 &then
  { gbl/diasize.i
    &browse-name="{&browse-name}"
    &frame-name="{&frame-name}"
  }
  &if defined(disable_diasize_init) = 0 &then
    run diasize_init in this-procedure .
  &endif
&endif

{ gbl/srt-clmd.i
  &browse-name   = "{&browse-name}"
  &frame-name    = "{&frame-name}"
  &table-name    = "r-doc"
  &ext-col       = 11
  &start-column  = 4
  &label-clmn_1  = "{&label-clmn_1-br-dtl}"
  &sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
  &label-clmn_2  = "{&label-clmn_2-br-dtl}"
  &sort-clmn_2   = "{&sort-clmn_2-br-dtl}"
  &dyn_sort-clmn_2   = "{&dyn_sort-clmn_2-br-dtl}"
  &label-clmn_3  = "{&label-clmn_3-br-dtl}"
  &sort-clmn_3   = "{&sort-clmn_3-br-dtl}"
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
  &label-clmn_9 = "{&label-clmn_9-br-dtl}"
  &sort-clmn_9  = "{&sort-clmn_9-br-dtl}"
  &dyn_sort-clmn_9  = "{&dyn_sort-clmn_9-br-dtl}"
  &label-clmn_10 = "{&label-clmn_10-br-dtl}"
  &sort-clmn_10  = "{&sort-clmn_10-br-dtl}"
  &dyn_sort-clmn_10  = "{&dyn_sort-clmn_10-br-dtl}"
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
  
  
    assign
        filter-point = "all-test-asi":U
        . 
    
    RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", NO, OUTPUT rdc-value, OUTPUT rdc-type) NO-ERROR.
    run UI-on in this-procedure .
    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name}.
    
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */


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
  ENABLE b-quit b-mark b-sel b-add b-chg b-del b-lkp b-close b-print br-r-docs 
         ed-notes 
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
                    frame {&frame-name}:title = "ДОКУМЕНТЫ проверки корректности работы АСИ в резервуаре".
                { gbl/fltopend.i
                  &where-cond = " r-doc.rvs-type = vartest-asi "
                  &dyn_where-cond = " substitute( '  r-doc.rvs-type = &1&2&1 ' , ~{&double-quote~} , vartest-asi ) "
                  &use-ind    = "  "
                  &by         = "  " }
            end.
        when {&company} then 
            do:
                assign 
                    frame {&frame-name}:title = "ДОКУМЕНТЫ проверки корректности работы АСИ в резервуаре Фирма : " + string(varhost-code).
                { gbl/fltopend.i
                  &where-cond = " r-doc.host-code = varhost-code and r-doc.rvs-type = vartest-asi "
                  &dyn_where-cond = " substitute( '  r-doc.host-code = &2 and r-doc.rvs-type = &1&3&1 ' , ~{&double-quote~} , varhost-code , vartest-asi ) "
                  &use-ind    = " use-index host-date "
                  &by         = "  " }
            end.
        when {&g___object} then 
            do:
                assign 
                    frame {&frame-name}:title = "ДОКУМЕНТЫ проверки корректности работы АСИ в резервуаре Объект : " + varobj-type + " " + string (varobj-code).
                { gbl/fltopend.i
                  &where-cond = " r-doc.obj-type = varobj-type and   r-doc.obj-code = varobj-code  and r-doc.rvs-type = vartest-asi "
                  &dyn_where-cond = " substitute( '  ~
                                    r-doc.obj-type =  &1&2&1 and ~
                                    r-doc.obj-code =  &3 and   ~
                                    r-doc.rvs-type = &1&4&1  ~
                                   ' , ~{&double-quote~} , varobj-type , varobj-code , vartest-asi  ) "
                  &use-ind    = "use-index stat-date "
                  &by         = "  " }
                if v-cntxt-db-num = bf_clients.db-num then
                    enable b-add b-chg b-del b-close with frame {&frame-name}.
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
                                r-doc.rvs-type = vartest-asi     "
                  &dyn_where-cond = " substitute( '  ~
                                    r-doc.obj-type =  &1&2&1 and ~
                                    r-doc.obj-code =  &3  and  ~
                                    r-doc.status_  =  &1&4&1 and ~
                                    r-doc.rvs-type =  &1&5&1  ~
                                    ' , ~{&double-quote~} , varobj-type , varobj-code , varstatus_ , vartest-asi ) "
        
                  &use-ind    = "use-index stat-date"
                  &by         = "  " }
                if v-cntxt-db-num = bf_clients.db-num and
                    parstatus <> {&fact}            then
                    enable b-add b-chg b-del b-close with frame {&frame-name}.
            end.
        when "choose-control" then 
            do :
                assign 
                    frame {&frame-name}:title = "ДОКУМЕНТЫ проверки корректности работы АСИ в резервуаре Объект : " + varobj-type + " " + string (varobj-code) + "  Статус : факт    Тип: контроль".
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
            return error   "Документ проверки корректности работы АСИ в резервуаре с типом 'смена' в данном статусе не может быть удален" .
        end.
        if r-doc.status_ = {&fact} then 
        do:
          if not v-cntxt-is-admin
          then do :
            message "Удаление доступно только пользователю с ролью технического администратора." view-as alert-box .
            return error "Удаление доступно только пользователю с ролью технического администратора." .
          end .
        end. /* r-doc.status_ = {&fact} */

        assign 
            varlog = no.
        message
            "Удалить документ проверки корректности работы АСИ в резервуаре №" r-doc.rvs-code "?" skip
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
        
        run waitfram-show in this-procedure
            ( input "Удаление документа проверки корректности работы АСИ в резервуаре № " + r-doc.rvs-code + ". Ждите..."
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
                    substitute("Ошибка при удалении документа проверки корректности работы АСИ в резервуаре.") skip
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
        ed-notes
        {&browse-name}
        WITH FRAME {&frame-name}.
    run OpenBr in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION shift-name d-all-r-docs 
FUNCTION obj-name RETURNS CHARACTER
    ( p-rec as recid ) :
    define buffer loc-rvs-doc for ub.rvs-doc  .
    define variable v-ret-val as character no-undo .
    
    find first loc-rvs-doc no-lock where  recid ( loc-rvs-doc ) = p-rec no-error  .
    if error-status :error then return '' .
    v-ret-val = loc-rvs-doc.obj-type + string(loc-rvs-doc.obj-code) .

    return v-ret-val .
    
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

