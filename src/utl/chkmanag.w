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

Утилиты проверки целостности БД

Автор: Чернова Светлана Александровна
Дата создания: 06/23/08
Author: Svetlana Chernova
Creation date: 06/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/11/01

*/

define input parameter parparentproc as widget-handle no-undo .

/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилиты проверки целостности БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/operlist.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define temp-table temp-object no-undo
  field obj-type   like ub.trn-doc.obj-type
  field obj-code   like ub.trn-doc.obj-code
  field status_    like ub.trn-doc.status_
  field fact-order like ub.trn-doc.fact-order

  index xpk is primary unique obj-type obj-code
.

define temp-table temp-procedure no-undo
  field proc-order    as integer   format ">9"    label "N"
  field proc-mark     as character format "X(1)"  label "*"
  field proc-label    as character format "x(20)" label "Проверка"
  field proc-descr    as character format "x(45)" label "Описание"
  field proc-group    as character format "x(1)"  label "Группа"
  field proc-name     as character format "x(20)" label "Процедура"

  index xpk is primary unique proc-order
.

define variable v-proc-order as integer   no-undo .
define variable del-list     as character no-undo.
define variable mark         as character no-undo COLUMN-LABEL "*"      FORMAT "x(1)"  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-procedure

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 proc-order get-mark(recid(temp-procedure)) @ mark proc-label proc-descr proc-group proc-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH temp-procedure
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH temp-procedure .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp-procedure
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp-procedure


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help b-mark b-check BROWSE-1 ~
EDITOR-Log EDITOR-Help
&Scoped-Define DISPLAYED-OBJECTS EDITOR-Log EDITOR-Help

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  ( input v-recid  as recid )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-check
     LABEL "&Проверить"
     SIZE 12 BY 1.

DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1 TOOLTIP "Подробная проверка целостности товаров".

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Подробная проверка целостности товаров".

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 4 BY 1.

DEFINE VARIABLE EDITOR-Help AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 35.88 BY 5 NO-UNDO.

DEFINE VARIABLE EDITOR-Log AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 42.38 BY 5
     BGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp-procedure SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      proc-order
      get-mark(recid(temp-procedure)) @ mark
      proc-label
      proc-descr
      proc-group
      proc-name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79.25 BY 8.5
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.5 COL 2
     b-help AT ROW 1.5 COL 12.13
     b-mark AT ROW 1.5 COL 22.13
     b-check AT ROW 1.5 COL 26.13
     BROWSE-1 AT ROW 2.71 COL 2
     EDITOR-Log AT ROW 11.5 COL 2.13 NO-LABEL
     EDITOR-Help AT ROW 11.5 COL 45.5 NO-LABEL
     SPACE(0.49) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилиты проверки БД"
         CANCEL-BUTTON b-exit.


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
/* BROWSE-TAB BROWSE-1 b-check Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

ASSIGN
       EDITOR-Help:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       EDITOR-Log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-procedure .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Утилиты проверки БД */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-check
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-check Dialog-Frame
ON CHOOSE OF b-check IN FRAME Dialog-Frame /* Проверить */
DO:
  { gbl/stdbtn.i }

  define variable lok          as logical   no-undo .
  define variable process-list as character no-undo .

  do
  on stop undo, return no-apply
  :
    if del-list = "" then do:
      if not available temp-procedure then do:
        message
          "Неправильный выбор поцедуры"
          view-as alert-box .
        return no-apply.
      end.
      assign
        process-list = string(recid(temp-procedure))
      .
    end.
    else do:
      assign
        process-list = del-list
      .
    end.
    lok = no.
    message
      "Выбрано" num-entries(process-list) "процедур проверки" skip
      "Продолжить?"
      view-as alert-box question buttons ok-cancel update lok .
    if lok <> true then do:
      return no-apply.
    end.

    define variable v-ind as integer no-undo .

    do v-ind = 1 to num-entries(process-list) :
      run make-check in this-procedure
        (input integer (entry (v-ind, process-list))
        ) .
    end.

    assign
      lok = browse {&browse-name} :refresh() .
    .

  end. /* on stop */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  { gbl/stdbtn.i }

  if not available temp-procedure then do:
    message
      "Неправильный выбор партии."
      view-as alert-box .
    return no-apply.
  end.

  define variable v-temp-procedure-recid as character no-undo .
  assign
    v-temp-procedure-recid = string (recid (temp-procedure))
  .

  if lookup( v-temp-procedure-recid, del-list ) > 0 then do:
    assign
      del-list = diff-list(del-list, v-temp-procedure-recid, "" )
    .
    disp "" @ mark with browse {&browse-name} .
  end.
  else do:
    assign
      del-list = add-list(del-list, v-temp-procedure-recid, "" )
    .
    disp "*" @ mark with browse {&browse-name} .
  end.

  define variable lok as logical no-undo .
  lok = {&browse-name} :select-next-row ().
  apply "entry":u to {&browse-name} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
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

  run fill-temp-procedure in this-procedure .

  RUN enable_UI.

  RUN show-help in this-procedure  .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-allcheck Dialog-Frame
PROCEDURE chk-allcheck :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable icount      as integer no-undo .
  define variable v-test-name as character no-undo .

  assign
    v-test-name = "Подробная проверка товара (chk-allcheck)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).

  run utl/allcheck.p (input parparentproc) .

  /* узнаем общее количество ошибок */
  assign
    icount = integer(return-value) no-error
  .

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-batchprocess Dialog-Frame
PROCEDURE chk-batchprocess :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  /* проверка таблицы batch-process */



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-doc-line Dialog-Frame
PROCEDURE chk-doc-line :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable icount      as integer no-undo .
  define variable ind         as integer no-undo .
  define variable v-artic-str as character no-undo .
  define variable v-test-name as character no-undo .

  assign
    v-test-name = "Проверка строк складских документов (chk-doc-line)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).


  run waitfram-show in this-procedure
    (input v-test-name
    ).

  run clear-temp-object in this-procedure .

  for each doc-line no-lock
  :
    assign
      ind = ind + 1
    .
    if ind mod 10 = 0 then do:
      assign
        v-artic-str = string(doc-line.artic)
                    + " " + string(doc-line.prod-type)
                    + " " + string(doc-line.prod-code)
      .
      run waitfram-show in this-procedure
        (input "Документ " + string(doc-line.doc-code, 'x(14)':u)
          + " Артикул " + string(v-artic-str, 'x(25)':u)
          + " Найдено ошибок " + STRING(icount)
        ).
    end.

    find first ub.trn-doc no-lock
      where ub.trn-doc.doc-code = ub.doc-line.doc-code
      no-error .
    if not available ub.trn-doc then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.status_
        ,input ub.doc-line.fact-order
        ).
      run log-error
        (input "doc-line"
        ,input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input 'trn-doc-not-exist '
          + ' doc-code = ' + string(ub.doc-line.doc-code)
        ).
      next . /* --->>>--- */
    end.

    find first ub.goods no-lock
      where ub.goods.artic     = ub.doc-line.artic
        and ub.goods.prod-type = ub.doc-line.prod-type
        and ub.goods.prod-code = ub.doc-line.prod-code
      no-error .
    if not available ub.goods then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.status_
        ,input ub.doc-line.fact-order
        ).
      run log-error
        (input "doc-line"
        ,input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input 'goods-not-exist '
          + ' doc-code = ' + string(ub.doc-line.doc-code)
        ).
      next . /* --->>>--- */
    end.

    if ub.doc-line.status_ <> ub.trn-doc.status_  then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.status_
        ,input ub.doc-line.fact-order
        ).
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.trn-doc.status_
        ,input ub.doc-line.fact-order
        ).
      run log-error
        (input "doc-line"
        ,input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input 'doc-line.status_ '
          + ' doc-code = ' + string(ub.doc-line.doc-code)
          + ' trn-doc.status_  = ' + string(ub.trn-doc.status_)
          + ' doc-line.status_ = ' + string(ub.doc-line.status_)
        ).
      next . /* --->>>--- */
    end.

    if ub.doc-line.obj-type <> ub.trn-doc.obj-type
    or ub.doc-line.obj-code <> ub.trn-doc.obj-code
    then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
        (input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.status_
        ,input ub.doc-line.fact-order
        ).
      run log-error
        (input "doc-line_obj-type_obj-code"
        ,input ub.doc-line.obj-type
        ,input ub.doc-line.obj-code
        ,input ub.doc-line.artic
        ,input ub.doc-line.prod-type
        ,input ub.doc-line.prod-code
        ,input 'doc-line.obj-type doc-line.obj-code '
          + ' doc-code = ' + string(ub.doc-line.doc-code)
        ).
      next . /* --->>>--- */
    end.

    if ub.trn-doc.status_ <> {&fact} then do:
      next . /* --->>>--- */
    end.


    define variable v-parts-fact-qnty    as decimal no-undo .
    define variable v-gds-dtl-fact-qnty  as decimal no-undo .

    assign
      v-parts-fact-qnty   = 0
      v-gds-dtl-fact-qnty = 0
    .

    if ub.goods.gds-type = {&gds-goods} then do:
      for each ub.parts no-lock
        where ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
      :
        assign
          v-parts-fact-qnty = v-parts-fact-qnty + parts.fact-qnty
        .
      end.
    end.
    else do:
      find first ub.parts no-lock
        where ub.parts.out-code  = ub.doc-line.doc-code
          and ub.parts.obj-type  = ub.doc-line.obj-type
          and ub.parts.obj-code  = ub.doc-line.obj-code
          and ub.parts.artic     = ub.doc-line.artic
          and ub.parts.prod-type = ub.doc-line.prod-type
          and ub.parts.prod-code = ub.doc-line.prod-code
        no-error .
      if available parts then do:
        assign
          icount = icount + 1
        .
        run register-document in this-procedure
          (input ub.doc-line.obj-type
          ,input ub.doc-line.obj-code
          ,input ub.doc-line.status_
          ,input ub.doc-line.fact-order
          ).
        run log-error
          (input "doc-line"
          ,input ub.doc-line.obj-type
          ,input ub.doc-line.obj-code
          ,input ub.doc-line.artic
          ,input ub.doc-line.prod-type
          ,input ub.doc-line.prod-code
          ,input 'not_goods_has_parts '
            + ' doc-code = ' + string(ub.doc-line.doc-code)
          ).

        next . /* --->>>--- */
      end.

      assign
        v-parts-fact-qnty = ub.doc-line.fact-qnty
      .
    end.

    for each ub.gds-dtl no-lock
      where ub.gds-dtl.doc-code  = ub.doc-line.doc-code
        and ub.gds-dtl.artic     = ub.doc-line.artic
        and ub.gds-dtl.prod-type = ub.doc-line.prod-type
        and ub.gds-dtl.prod-code = ub.doc-line.prod-code
    :
      assign
        v-gds-dtl-fact-qnty = v-gds-dtl-fact-qnty
                            + (if ub.trn-doc.doc-type <> {&inventory}
                               then ub.gds-dtl.fact-qnty
                               else ub.gds-dtl.doc-qnty
                              )
      .
    end.



    if (( ub.doc-line.fact-qnty <> v-parts-fact-qnty
     or ub.doc-line.fact-qnty <> v-gds-dtl-fact-qnty ) and
        ub.trn-doc.doc-type <> {&inventory} )
     or
      ( ub.trn-doc.doc-type = {&inventory}   and
        ub.doc-line.fact-qnty <> v-parts-fact-qnty )   then do:
      assign
        icount = icount + 1
      .
      run register-document in this-procedure
            (input ub.doc-line.obj-type
            ,input ub.doc-line.obj-code
            ,input ub.doc-line.status_
            ,input ub.doc-line.fact-order
            ).
          run log-error
            (input "doc-line"
            ,input ub.doc-line.obj-type
            ,input ub.doc-line.obj-code
            ,input ub.doc-line.artic
            ,input ub.doc-line.prod-type
            ,input ub.doc-line.prod-code
            ,input 'trn-doc-fact-qnty '
              + ' doc-code = ' + string(ub.doc-line.doc-code)
              + ' doc-line.fact-qnty = ' + string(ub.doc-line.fact-qnty)
              + ' v-parts-fact-qnty = ' + STRING(v-parts-fact-qnty)
              + ' v-gds-dtl-fact-qnty = ' + STRING(v-gds-dtl-fact-qnty)
              + ' тип документа = ' + STRING(ub.trn-doc.doc-type)
              + ' статус = ' + STRING(ub.trn-doc.status_)
            ).
    end.
  end.

  run waitfram-hide in this-procedure .

  run output-temp-object in this-procedure .

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-firm-db-num Dialog-Frame
PROCEDURE chk-firm-db-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* проверка соответствия БД объекта главной БД фирмы */
  define variable icount      as integer no-undo .
  define variable ind         as integer no-undo .
  define variable v-test-name as character no-undo .

  assign
    v-test-name = "Проверка соответствия БД объекта главной БД фирмы  (chk-firm-db-num)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).

  run utl/chkfrmdb.p (
                  input  this-procedure:handle
                 ,output icount).

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-idxinact Dialog-Frame
PROCEDURE chk-idxinact :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable icount      as integer no-undo .
  define variable v-test-name as character no-undo .

  assign
    v-test-name = "Неактивные индексы (chk-idxinact)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).

  run utl/idxinact.p .

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-price-doc Dialog-Frame
PROCEDURE chk-price-doc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  /* проверка целостности документов сверки */
  define variable icount      as integer no-undo .
  define variable ind         as integer no-undo .
  define variable v-test-name as character no-undo .

  assign
    v-test-name = "Проверка заголовков переоценок (chk-price-doc)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).

  run waitfram-show in this-procedure
    (input v-test-name
    ).

  define buffer buf_price-doc for ub.price-doc .

  for each ub.price-doc no-lock
  :
    assign
      ind = ind + 1
    .
    if ind mod 10 = 0 then do:
      run waitfram-show in this-procedure
        (input "Переоценка " + string(ub.price-doc.doc-num, 'x(8)':u)
          + " Найдено ошибок " + STRING(icount)
        ).
    end.

    if (ub.price-doc.fact-num > 0) <> (ub.price-doc.status_ = {&act-overvalue}) then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input {&table_price-doc}
        ,input price-doc.obj-type
        ,input price-doc.obj-code
        ,input ""
        ,input ""
        ,input 0
        ,input 'price-doc-status-fact-num '
          + ' doc-num = ' + string(price-doc.doc-num)
          + ' status_ = ' + string(price-doc.status_)
        ).
    end.

    if ub.price-doc.status_ = {&act-overvalue} then do:
      if ub.price-doc.fact-date = ? then do:
        assign
          icount = icount + 1
        .
        run log-error
          (input {&table_price-doc}
          ,input price-doc.obj-type
          ,input price-doc.obj-code
          ,input ""
          ,input ""
          ,input 0
          ,input 'price-doc-status-fact-date '
            + ' doc-num = ' + string(price-doc.doc-num)
            + ' status_ = ' + string(price-doc.status_)
            + ' fact-date = ' + string(price-doc.fact-date)
          ).
      end.
    end.

    if ub.price-doc.status_ = {&act-overvalue} then do:
      find last buf_price-doc no-lock
        where buf_price-doc.obj-type = ub.price-doc.obj-type
          and buf_price-doc.obj-code = ub.price-doc.obj-code
          and buf_price-doc.fact-num < ub.price-doc.fact-num
        use-index fact-close
        no-error .
      if available buf_price-doc then do:
        if buf_price-doc.fact-date > ub.price-doc.fact-date then do:
          /* нарушен порядок закрытия переоценки */
          assign
            icount = icount + 1
          .
          run log-error
            (input {&table_price-doc}
            ,input price-doc.obj-type
            ,input price-doc.obj-code
            ,input ""
            ,input ""
            ,input 0
            ,input 'price-doc-close-fact-order '
              + ' price-doc.doc-num = ' + string(price-doc.doc-num)
              + ' price-doc.fact-num = ' + string(price-doc.fact-num)
              + ' price-doc.fact-date = ' + string(price-doc.fact-date)
              + ' buf_price-doc.doc-num = ' + string(buf_price-doc.doc-num)
              + ' buf_price-doc.fact-num = ' + string(buf_price-doc.fact-num)
              + ' buf_price-doc.fact-date = ' + string(buf_price-doc.fact-date)
            ).
        end.
      end.
    end.
  end.

  run waitfram-hide in this-procedure .

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-price-list Dialog-Frame
PROCEDURE chk-price-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable icount      as integer no-undo .
  define variable ind         as integer no-undo .
  define variable v-artic-str as character no-undo .
  define variable v-test-name as character no-undo .

  assign
    v-test-name = "Проверка строк переоценок (chk-price-list)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).

  run waitfram-show in this-procedure
    (input v-test-name
    ).

  /* проверка строк документов переоценки */
  for each ub.price-list no-lock
  :
    assign
      ind = ind + 1
    .
    if ind mod 10 = 0 then do:
      assign
        v-artic-str = string(price-list.artic)
                    + " " + string(price-list.prod-type)
                    + " " + string(price-list.prod-code)
      .
      run waitfram-show in this-procedure
        (input "Переоценка " + string(price-list.doc-num, 'x(8)':u)
          + " Артикул " + string(v-artic-str, 'x(25)':u)
          + " Найдено ошибок " + STRING(icount)
        ).
    end.

    find first ub.price-doc no-lock
      where ub.price-doc.doc-num = ub.price-list.doc-num
      no-error .
    if not available ub.price-doc then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "price-list"
        ,input price-list.obj-type
        ,input price-list.obj-code
        ,input price-list.artic
        ,input price-list.prod-type
        ,input price-list.prod-code
        ,input 'price-doc-not-exist '
          + ' doc-num = ' + string(price-list.doc-num)
        ).
      next . /* --->>>--- */
    end.

    find first ub.goods no-lock
      where ub.goods.artic     = ub.price-list.artic
        and ub.goods.prod-type = ub.price-list.prod-type
        and ub.goods.prod-code = ub.price-list.prod-code
      no-error .
    if not available ub.goods then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "price-list"
        ,input price-list.obj-type
        ,input price-list.obj-code
        ,input price-list.artic
        ,input price-list.prod-type
        ,input price-list.prod-code
        ,input 'price-list-goods-not-exist '
          + ' doc-num = ' + string(price-list.doc-num)
        ).
      next . /* --->>>--- */
    end.

    if ub.price-list.obj-type <> ub.price-doc.obj-type
    or ub.price-list.obj-code <> ub.price-doc.obj-code
    then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "price-list"
        ,input price-list.obj-type
        ,input price-list.obj-code
        ,input price-list.artic
        ,input price-list.prod-type
        ,input price-list.prod-code
        ,input 'price-list-object '
          + ' price-doc.obj-type ' + ' = ' + string(price-doc.obj-type)
          + ' price-doc.obj-code ' + ' = ' + string(price-doc.obj-code)
        ).
    end.

    if ub.price-list.fact-order <> ub.price-doc.fact-order then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "price-list"
        ,input price-list.obj-type
        ,input price-list.obj-code
        ,input price-list.artic
        ,input price-list.prod-type
        ,input price-list.prod-code
        ,input 'price-list-fact-num '
          + ' price-list.fact-num ' + ' = ' + string(price-list.fact-order)
          + ' price-doc.fact-num ' + ' = ' + string(price-doc.fact-order)
        ).
    end.

  end.

  run waitfram-hide in this-procedure .

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear-temp-object Dialog-Frame
PROCEDURE clear-temp-object :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp-object for temp-object .

  for each buf_temp-object :
    delete buf_temp-object .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-temp-procedure Dialog-Frame
PROCEDURE create-temp-procedure :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-label     as character no-undo .
  define input parameter p-proc-name as character no-undo .
  define input parameter p-group     as character no-undo .
  define input parameter p-descr     as character no-undo .

  define buffer buf_temp-procedure for temp-procedure .

  assign
    v-proc-order = v-proc-order + 1
  .

  create buf_temp-procedure .
  assign
    buf_temp-procedure.proc-order = v-proc-order
    buf_temp-procedure.proc-label = p-label
    buf_temp-procedure.proc-name  = p-proc-name
    buf_temp-procedure.proc-group = p-group
    buf_temp-procedure.proc-descr = p-descr
  .

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
  DISPLAY EDITOR-Log EDITOR-Help
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-help b-mark b-check BROWSE-1 EDITOR-Log EDITOR-Help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-procedure Dialog-Frame
PROCEDURE fill-temp-procedure :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  run create-temp-procedure in this-procedure
    (input "Свободно <-> Факт"
    ,input "find-bad-goods-free-fact"
    ,input "1"
    ,input ""
    ) .

  run create-temp-procedure in this-procedure
    (input "Товар <-> Шкала"
    ,input "find-bad-goods-prt-obj"
    ,input "1"
    ,input ""
    ) .

  run create-temp-procedure in this-procedure
    (input "Товар <-> Партии"
    ,input "find-bad-goods-parts"
    ,input "1"
    ,input ""
    ) .

  run create-temp-procedure in this-procedure
    (input "Документы"
    ,input "chk-doc-line"
    ,input "1"
    ,input ""
    ) .

  run create-temp-procedure in this-procedure
    (input "Переоценка Строки"
    ,input "chk-price-list"
    ,input "1"
    ,input ""
    ) .

  run create-temp-procedure in this-procedure
    (input "Переоценка Заголовки"
    ,input "chk-price-doc"
    ,input "1"
    ,input ""
    ) .

  run create-temp-procedure in this-procedure
    (input "Товар - Подробно"
    ,input "chk-allcheck"
    ,input "2"
    ,input "Подробная проверка товара"
    ) .

  run create-temp-procedure in this-procedure
    (input "Объекты-Главная БД фирмы"
    ,input "chk-firm-db-num"
    ,input "2"
    ,input "Поиск объектов, у которых БД не равна БД фирмы"
    ) .

  run create-temp-procedure in this-procedure
    (input "Активные индексы"
    ,input "chk-idxinact"
    ,input "3"
    ,input "Поиск неактивных индексов в базе данных"
    ) .



/*

*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-bad-goods-free-fact Dialog-Frame
PROCEDURE find-bad-goods-free-fact :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define variable icount       as integer no-undo .
  define variable v-object-str as character no-undo .
  define variable v-artic-str  as character no-undo .
  define variable v-test-name as character no-undo .

  assign
    v-test-name = "Проверка свободного количества (find-bad-goods-free-fact)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).

  run waitfram-show in this-procedure
    (input v-test-name
    ).

  for each ub.gds-obj no-lock
    where ub.gds-obj.free-qnty <> ub.gds-obj.fact-qnty
  :
    assign
      v-object-str = string(ub.gds-obj.obj-type)
                  + " " + string(ub.gds-obj.obj-code)
      v-artic-str  = string(ub.gds-obj.artic)
                  + " " + string(ub.gds-obj.prod-type)
                  + " " + string(ub.gds-obj.prod-code)
    .

    run waitfram-show in this-procedure
      (input "Объект " + string(v-object-str, 'x(10)':u)
        + " Артикул " + string(v-artic-str, 'x(25)':u)
        + " Найдено ошибок " + STRING(icount)
      ).

    find first ub.parts no-lock
      where ub.parts.obj-type  = ub.gds-obj.obj-type
        and ub.parts.obj-code  = ub.gds-obj.obj-code
        and ub.parts.artic     = ub.gds-obj.artic
        and ub.parts.prod-type = ub.gds-obj.prod-type
        and ub.parts.prod-code = ub.gds-obj.prod-code
        and ub.parts.out-code  <> {&free-code}
        and ub.parts.rsrv-free = yes
        and ub.parts.status_   = no
      no-error .
    if not available ub.parts then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'free-fact gds-obj.free-qnty = ' + STRING(ub.gds-obj.free-qnty)
              + ' gds-obj.fact-qnty = ' + STRING(ub.gds-obj.fact-qnty)
        ).
    end.
  end.

  run waitfram-hide in this-procedure .

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-bad-goods-parts Dialog-Frame
PROCEDURE find-bad-goods-parts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  /*
     Проверяем, что фактическое количество совпадает
     с количеством по партиям
  */

define variable icount       as integer   no-undo .
define variable jcount       as integer   no-undo .
define variable v-object-str as character no-undo .
define variable v-artic-str  as character no-undo .
define variable v-test-name as character no-undo .
define variable v-gds-obj as decimal   no-undo .


  assign
    v-test-name = "Проверка партий свободной зоны (find-bad-goods-parts)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).

  define variable v-parts-qnty as decimal no-undo .

  run waitfram-show in this-procedure
    (input v-test-name
    ).

  for each ub.gds-obj no-lock
  :
    assign
      v-object-str  = string(ub.gds-obj.obj-type)
                    + " " + string(ub.gds-obj.obj-code)
      v-artic-str   = string(ub.gds-obj.artic)
                    + " " + string(ub.gds-obj.prod-type)
                    + " " + string(ub.gds-obj.prod-code)
    .
    run waitfram-show in this-procedure
      (input "Объект " + string(v-object-str, 'x(10)':u)
        + " Артикул " + string(v-artic-str, 'x(25)':u)
        + " Найдено ошибок " + STRING(icount)
      ).

    assign
      v-parts-qnty = 0
    .

    for each ub.parts no-lock
      where ub.parts.obj-type  = ub.gds-obj.obj-type
        and ub.parts.obj-code  = ub.gds-obj.obj-code
        and ub.parts.artic     = ub.gds-obj.artic
        and ub.parts.prod-type = ub.gds-obj.prod-type
        and ub.parts.prod-code = ub.gds-obj.prod-code
        and ub.parts.status_   = no
        and ub.parts.rsrv-free = yes
    :

      if ub.parts.out-code = {&free-code} then do:
        assign
          v-parts-qnty = v-parts-qnty + ub.parts.qnty
        .
      end.
      else do:
        find first ub.trn-doc where ub.trn-doc.doc-code = ub.parts.out-code .
        if lookup(ub.trn-doc.ext-doc-type,"{&bef-TDEDT_Ras_Vnesh},{&bef-TDEDT_Ras_Vnesh_VP},{&bef-TDEDT_Ras_Vnesh_Kass},{&bef-TDEDT_Spi_Vnesh},{&bef-TDEDT_Ras_Perem,{&bef-TDEDT_Ras_Prvo},{&bef-TDEDT_Spi_Prvo}}") > 0 then do:
            assign
              v-parts-qnty = v-parts-qnty  - ub.parts.qnty
            .
        end.
        else do:
            assign
              v-parts-qnty = v-parts-qnty + ub.parts.qnty
            .
        end.
      end.
    end.


    if v-parts-qnty <> ub.gds-obj.fact-qnty then do:
      assign
        icount = icount + 1
        v-gds-obj = ub.gds-obj.fact-qnty
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'parts free-parts-qnty = ' + STRING(v-parts-qnty)
              + ' gds-obj.fact-qnty =' + STRING(v-gds-obj)
        ).

    end.
  end.

  run waitfram-hide in this-procedure .

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-bad-goods-prt-obj Dialog-Frame
PROCEDURE find-bad-goods-prt-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define variable v-object-str as character no-undo .
  define variable v-artic-str  as character no-undo .
  define variable v-test-name as character no-undo .

  assign
    v-test-name = "Проверка количеств по шкалам (find-bad-goods-prt-obj)"
  .

  run log-test-started in this-procedure
    (input v-test-name /* p-test-name */
    ).

  define variable v-total-fact-qnty as decimal no-undo .
  define variable v-total-free-qnty as decimal no-undo .

  define variable icount as integer no-undo .

  run waitfram-show in this-procedure
    (input v-test-name
    ).

  for each gds-obj no-lock
  :
    assign
      v-object-str  = string(ub.gds-obj.obj-type)
                    + " " + string(ub.gds-obj.obj-code)
      v-artic-str   = string(ub.gds-obj.artic)
                    + " " + string(ub.gds-obj.prod-type)
                    + " " + string(ub.gds-obj.prod-code)
    .
    run waitfram-show in this-procedure
      (input "Объект " + string(v-object-str, 'x(10)':u)
        + " Артикул " + string(v-artic-str, 'x(25)':u)
        + " Найдено ошибок " + STRING(icount)
      ).

    assign
      v-total-fact-qnty = 0
      v-total-free-qnty  = 0
    .
    find first ub.goods no-lock
      where ub.goods.artic     = ub.gds-obj.artic
        and ub.goods.prod-type = ub.gds-obj.prod-type
        and ub.goods.prod-code = ub.gds-obj.prod-code
      no-error .
    if not available ub.goods then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'goods not found'
        ).
      next . /* --->>>--- */
    end.
    find first ub.gds-prt no-lock
      where ub.gds-prt.upper-code = ub.goods.prt-root
      no-error .
    if not available ub.gds-prt then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'root_node_not_found goods.prt-root=' + string(ub.goods.prt-root)
        ).
      next . /* --->>>--- */
    end.

    for each ub.prt-obj no-lock
      where ub.prt-obj.obj-type  = ub.gds-obj.obj-type
        and ub.prt-obj.obj-code  = ub.gds-obj.obj-code
        and ub.prt-obj.artic     = ub.gds-obj.artic
        and ub.prt-obj.prod-type = ub.gds-obj.prod-type
        and ub.prt-obj.prod-code = ub.gds-obj.prod-code
        and ub.prt-obj.prt-code  = ub.gds-prt.node-code
    :
      assign
        v-total-fact-qnty = v-total-fact-qnty  + ub.prt-obj.fact-qnty
        v-total-free-qnty = v-total-free-qnty  + ub.prt-obj.free-qnty
      .
    end.

    if v-total-fact-qnty <> ub.gds-obj.fact-qnty
    or v-total-free-qnty <> ub.gds-obj.free-qnty
    then do:
      assign
        icount = icount + 1
      .
      run log-error
        (input "gds-obj"
        ,input ub.gds-obj.obj-type
        ,input ub.gds-obj.obj-code
        ,input ub.gds-obj.artic
        ,input ub.gds-obj.prod-type
        ,input ub.gds-obj.prod-code
        ,input 'goods-gds-prt gds-obj.free-qnty = ' + STRING(ub.gds-obj.free-qnty)
          + ' gds-obj.fact-qnty = '            + STRING(ub.gds-obj.fact-qnty)
          + ' total prt-obj.free-qnty = '      + STRING(v-total-free-qnty)
          + ' total prt-obj.fact-qnty = '      + STRING(v-total-fact-qnty)
        ).
    end.
  end.

  run waitfram-hide in this-procedure .

  run log-test-finished in this-procedure
    (input v-test-name /* p-test-name */
    ,input icount      /* p-err-count */
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE log-error Dialog-Frame
PROCEDURE log-error :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-table-name as character no-undo .
  define input parameter v-obj-type   like ub.gds-obj.obj-type  no-undo .
  define input parameter v-obj-code   like ub.gds-obj.obj-code  no-undo .
  define input parameter v-artic      like ub.gds-obj.artic     no-undo .
  define input parameter v-prod-type  like ub.gds-obj.prod-type no-undo .
  define input parameter v-prod-code  like ub.gds-obj.prod-code no-undo .
  define input parameter v-error-msg  as character no-undo .

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  output to chkmanag.err append .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  export
    string(v-today, '99/99/9999':u) string(v-time, 'HH:MM':u)
    p-table-name
    v-obj-type v-obj-code v-artic v-prod-type v-prod-code
    v-error-msg .
  output close .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE log-information Dialog-Frame
PROCEDURE log-information :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-message as character no-undo .

  define variable lok as logical   no-undo .

  do with frame {&frame-name}:
    assign
      lok = EDITOR-Log :move-to-eof()
      lok = EDITOR-Log :insert-string(p-message + {&new-line} )
    .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE log-test-finished Dialog-Frame
PROCEDURE log-test-finished :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-test-name as character no-undo .
  define input parameter p-err-count as integer   no-undo .

  define variable v-message-text as character no-undo .

  assign
    v-message-text = (if p-err-count > 0 then "**" else "  ")
          + " " + cur-time-string()
          + " " + "ошибок" + " " + string(p-err-count)
          + " " + p-test-name
  .

  output to chkmanag.log append .
  export v-message-text .
  output close .

  run log-information
    (input v-message-text
    ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE log-test-started Dialog-Frame
PROCEDURE log-test-started :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-test-name as character no-undo .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-check Dialog-Frame
PROCEDURE make-check :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-temp-procedure-recid as recid no-undo .

  define buffer buf_temp-procedure for temp-procedure .

  find first buf_temp-procedure
    where recid(buf_temp-procedure) = p-temp-procedure-recid
    .

  run value(buf_temp-procedure.proc-name) in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE output-temp-object Dialog-Frame
PROCEDURE output-temp-object :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_temp-object for temp-object .

  output to chkmanag.obj .

  for each buf_temp-object :
    display buf_temp-object .
  end.

  output close .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE register-document Dialog-Frame
PROCEDURE register-document :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-obj-type   like ub.trn-doc.obj-type   no-undo .
  define input parameter p-obj-code   like ub.trn-doc.obj-code   no-undo .
  define input parameter p-status_    like ub.trn-doc.status_    no-undo .
  define input parameter p-fact-order like ub.trn-doc.fact-order no-undo .

  define buffer buf_temp-object for temp-object .

  if p-status_ = {&fact} then do:
    find first buf_temp-object
      where buf_temp-object.obj-type = p-obj-type
        and buf_temp-object.obj-code = p-obj-code
      no-error .
    if not available buf_temp-object then do:
      create buf_temp-object .
      assign
        buf_temp-object.obj-type = p-obj-type
        buf_temp-object.obj-code = p-obj-code
      .
    end.
    if buf_temp-object.fact-order = ?
    or buf_temp-object.fact-order < p-fact-order then do:
      assign
        buf_temp-object.fact-order = p-fact-order
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show-help Dialog-Frame
PROCEDURE show-help :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do with frame {&frame-name}:
    assign
      editor-help :screen-value = "Рекомендуемый порядок проверки базы данных: " + {&new-line}
        + "Сначала последовательно выполните тесты Группы А. "
        + "После выполнения каждого теста требуется проверить файлы ошибок chkmanag.err и chkmanag.log. "
        + "В случае обнаружения ошибок необходимо обратиться в службу поддержки пользователей. "
        + {&new-line}
        + {&new-line}
        + "Если в результате выполнения тестов Группы А не были найдены ошибки, то выполните тесты Группы Б."
        + "В случае обнаружения ошибок необходимо обратиться в службу поддержки пользователей. "
        + {&new-line}
    .
  end. /* do with frame */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  ( input v-recid  as recid ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  if lookup(string(v-recid), del-list ) > 0 then do:
    return "*".
  end.

  return "".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME