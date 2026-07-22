&Scoped-define WINDOW-NAME   d-trn-pr
&Scoped-define FRAME-NAME     d-trn-pr
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр автоматического акта переоценки

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

Author1:  Исаков Андрей Валерьевич
Created: 26.09.95


*/

/* ***************************  Definitions  ************************** */
define input        parameter parparentproc as handle    no-undo.
define input        parameter pardoc-rec    as recid     no-undo.
define input        parameter pardoc-mode   as character no-undo.
define input-output parameter parnext-prev  as logical   no-undo.
define input        parameter parstat       as character no-undo.
define input        parameter partype       as character no-undo.
define input        parameter parinternal   as logical   no-undo.
define input        parameter br-handle     as handle no-undo.
define input        parameter bf-handle     as handle no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр автоматического акта переоценки":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ str/libbcrcn.i }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ str/trdcalib.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ gbl/thbjattr.i }

&global-define store-type v-cntxt-obj-type
&global-define store-code v-cntxt-obj-code

define new shared variable body-handle as handle no-undo.

define variable conf-par      as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type      as character no-undo.                  /* тип параметра конфигурации */
DEFINE VARIABLE ref-list      AS CHARACTER NO-UNDO.

define shared buffer t-doc     for trn-doc.
define        buffer l-gds-dtl for gds-dtl.                  /* для поиска  */

define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }
define variable v-temp      as decimal no-undo .
define variable varlog      as logical no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parext-doc-mode as   character               no-undo.
define variable varhold         as character no-undo.
define variable paris-hold      as   logical              no-undo.

/*затычка закончилась*/

{ cmp/doc-list.i  doc-list def "shared" }

define shared buffer temp-trn-doc for doc-list  .
define shared query br-docs for t-doc except  , temp-trn-doc scrolling.
/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define OPEN-QUERY-br-dtl ~
  OPEN QUERY br-dtl ~
  FOR EACH gds-dtl no-lock WHERE ~
           gds-dtl.doc-code = t-doc.doc-code and ~
           gds-dtl.ov = yes, ~
      EACH gds-prt no-lock WHERE ~
           gds-prt.node-code = gds-dtl.prt-code, ~
      EACH goods no-lock WHERE ~
           goods.artic     = gds-dtl.artic and ~
           goods.prod-code = gds-dtl.prod-code and ~
           goods.prod-type = gds-dtl.prod-type, ~
      FIRST bar-code no-lock WHERE ~
            bar-code.gds-code  = goods.gds-code and ~
            bar-code.node-code = gds-dtl.prt-code and ~
            bar-code.in-code   = "" and ~
            bar-code.part-code = "".

/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-notes
     LABEL "П&рим":L
     SIZE 8 BY 1.

DEFINE BUTTON b-arch
     LABEL "У&чет":L
     SIZE 8 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 8 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 8 BY 1.

DEFINE BUTTON b-history
     LABEL "Истори&я"
     SIZE 8 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 8 BY 1.

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 4 BY 1.

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 4 BY 1.

DEFINE VARIABLE loc-art  AS CHARACTER VIEW-AS FILL-IN SIZE 14 BY 1 FGCOLOR 12 NO-UNDO.
DEFINE VARIABLE loc-name AS CHARACTER VIEW-AS FILL-IN SIZE 20 BY 1 FGCOLOR 12 NO-UNDO.
DEFINE VARIABLE loc-code AS CHARACTER VIEW-AS FILL-IN SIZE 20 BY 1 FGCOLOR 12 NO-UNDO.
define variable gds-rec as recid no-undo.

DEFINE VARIABLE a-n-c AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL /* vertical */ RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1 NO-UNDO.

DEFINE QUERY br-dtl FOR gds-dtl, gds-prt, goods, bar-code SCROLLING.

DEFINE BROWSE br-dtl QUERY br-dtl NO-LOCK DISPLAY
      bar-code.b-code
      gds-dtl.artic
      goods.gds-name
      (if gds-prt.node-name = {&empty-scale} then "-" else
       if gds-prt.upper-code = goods.prt-root then "-------------------" else gds-prt.node-name)
           COLUMN-LABEL "Признак" FORMAT "x(10)"
      gds-dtl.fact-qnty COLUMN-LABEL "Факт"
      goods.unit-base
      gds-dtl.cur-base   COLUMN-LABEL "Прод. цена "
      gds-dtl.price-rubl COLUMN-LABEL "Цена док-та ({&abbr_rub_allshift})"
      gds-dtl.price-base COLUMN-LABEL "Цена док-та (Б.В)"
    WITH SIZE 98.5 BY 12 separators.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
     t-doc.fact-date AT ROW 2 COL 30 COLON-ALIGNED format "99/99/9999" LABEL "Дата"
                     VIEW-AS FILL-IN SIZE 9 BY 1 fgcolor 4
     t-doc.fact-qnty AT ROW 3 COL 30 COLON-ALIGNED LABEL "Количество по док-ту"
                     view-as fill-in size 17 by 1 fgcolor 4
     v-temp          AT ROW 2 COL 70 COLON-ALIGNED
                     VIEW-AS FILL-IN SIZE 17 BY 1 fgcolor 4
     t-doc.tot-ov    AT ROW 3 COL 70 COLON-ALIGNED
                     VIEW-AS FILL-IN SIZE 17 BY 1 fgcolor 4
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 9
     b-next AT ROW 1 COL 13
     b-print AT ROW 1 COL 17
     b-notes AT ROW 1 COL 25
     b-arch AT ROW 1 COL 33
     b-history AT ROW 1 COL 41
     b-help AT ROW 1 COL 49
     br-dtl AT ROW 4 COL 1
     loc-art AT ROW 16 COL 35 COLON-ALIGNED label "Начало артикула"
     loc-name AT ROW 16 COL 35 COLON-ALIGNED label "Начало названия" format "x(40)"
     loc-code AT ROW 16 COL 35 COLON-ALIGNED label "Бар-код (весь)" format "x(13)"
     a-n-c at row 16 col 77 no-label

     SPACE(0) SKIP(0) WITH VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE .
/*         DEFAULT-BUTTON b-exit.  */


/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
       br-dtl:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 2.

ASSIGN
       FRAME {&frame-name}:SCROLLABLE       = FALSE.

/* ************************  Control Triggers  ************************ */

{ gbl/f2.i br-dtl " " " " "parparentproc" }
{ gbl/hot-key.i b-print }

{ str/sch-line.i gds-dtl br-dtl recid(gds-dtl) }
end.

{ str/trn-tr.i pr no }

ON CHOOSE OF b-print IN FRAME {&frame-name}
DO:
  define variable print_petrol as logical no-undo.

  run CheckPetrol in this-procedure ( input t-doc.doc-code, output print_petrol ) no-error.
  if error-status :error or print_petrol = ? then do: assign print_petrol = no. end.
  if print_petrol = yes then do: run rep/autoact0.p ( input parparentproc, input recid( t-doc ), input "all":U ). end.
                        else do: run rep/avt-akt0.p ( input parparentproc, input recid( t-doc ), input "all":U ). end.

  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
  apply "ENTRY":U to br-dtl in frame {&FRAME-NAME}.
END.

ON CHOOSE OF b-arch IN FRAME {&frame-name} /* Просмотр в учетных ценах */
DO:
define variable varbase-code as integer no-undo.
define buffer bf_currency for ub.currency.

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_archive_cost':U
  {&cntxt-object}
  t-doc.host-code
  t-doc.obj-type
  t-doc.obj-code
  0
  0
  0
  true
  varlog
}

{ gbl/basecode.i t-doc.host-code varbase-code }
find first bf_currency where bf_currency.curr-code = varbase-code no-lock.
if varlog <> yes then return no-apply.
message "Сумма в учетных ценах:" skip
                string (t-doc.fact-base, "->>,>>>,>>9.99") bf_currency.curr-abbr skip
                string (t-doc.fact-rubl, "->>,>>>,>>>,>>9.99") "{&abbr_rub_allshift}" skip (2)
                "Сумма в ценах документа:" skip
                string (t-doc.tot-fact, "->>,>>>,>>9.99") bf_currency.curr-abbr skip
                string (t-doc.tot-sale, "->>,>>>,>>>,>>9.99") "{&abbr_rub_allshift}" skip (2)
                "Разница:" skip
                string (t-doc.tot-fact - t-doc.fact-base, "->>,>>>,>>9.99")
                bf_currency.curr-abbr skip
                string (t-doc.tot-sale - t-doc.fact-rubl, "->>,>>>,>>>,>>9.99")
                  "{&abbr_rub_allshift}" skip (2)
                "Наценка:"
                string ((t-doc.tot-fact - t-doc.fact-base) / t-doc.fact-base * 100, "->>9.9<%")
                view-as alert-box title "Док-т №: " + string (t-doc.doc-code) + "  от: " + string (t-doc.doc-date).
END.

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.



/* зацикливание формы */
parnext-prev = yes.
n-p: do while parnext-prev :
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
run mode-on no-error.
if error-status:error then return error.
assign
  gds-dtl.cur-base  :label      = if var-pr-r-b = 'base' then "Прод. цена (баз.вал.)"  else "Прод. цена ({&abbr_rub_allshift})"
  gds-dtl.price-rubl:visible    = if var-pr-r-b = 'rubl' then yes else no
  gds-dtl.price-base:visible    = if var-pr-r-b = 'base' then yes else no
  v-temp            :label      = if var-pr-r-b = 'base' then "Сумма ФАКТ (баз.вал.)" else "Сумма ФАКТ ({&abbr_rub_allshift})"
  t-doc.tot-ov      :label      = if var-pr-r-b = 'base' then "Сумма АКТа (баз.вал.)" else "Сумма АКТа ({&abbr_rub_allshift})"
  goods.gds-name :resizable  = true
  .

run UI-on.
WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-dtl.
END.
if parnext-prev <> ? then parnext-prev = yes.  /* просмотр акта всегда в одной форме */
end. /* do while */
RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE. /* disable_UI */

PROCEDURE UI-on :
  /* -----------------------------------------------------------
    Purpose:     включение интерфейса в нужном режиме
  ------------------------------------------------------------- */
  assign
    v-temp = ( if var-pr-r-b = "base" then t-doc.tot-fact else t-doc.tot-sale )
  .
  display v-temp
          t-doc.fact-date
          t-doc.fact-qnty
          t-doc.tot-ov
  with frame {&FRAME-NAME}.
  hide loc-art  in frame {&FRAME-NAME}
       loc-name in frame {&FRAME-NAME}
       loc-code in frame {&FRAME-NAME}.
  assign
    loc-art = "":U
  .
  enable b-exit b-help b-print br-dtl b-arch b-history a-n-c b-notes b-prev b-next with frame {&FRAME-NAME}.
  assign
    frame {&FRAME-NAME} :title = "Акт ПЕРЕОЦЕНКИ для док-та :    " + t-doc.doc-type +
                                 " № " + t-doc.doc-code + "            - " + pardoc-mode
  .
  {&OPEN-query-br-dtl}
END PROCEDURE. /* UI-on */

PROCEDURE CheckPetrol :
  DEFINE  INPUT PARAMETER p-doc-code     LIKE ub.trn-doc.doc-code NO-UNDO.
  DEFINE OUTPUT PARAMETER p-print-petrol AS   LOGICAL             NO-UNDO INITIAL NO.

  DEFINE VARIABLE j_petrol  AS INTEGER NO-UNDO.
  DEFINE VARIABLE j_total   AS INTEGER NO-UNDO.
  DEFINE VARIABLE l_answer  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE is-petrol AS LOGICAL NO-UNDO.
  DEFINE VARIABLE is-pieces AS LOGICAL NO-UNDO.

  DEFINE BUFFER buf_doc-line FOR ub.doc-line.

  DO ON ERROR UNDO, RETURN ERROR :
    FOR EACH buf_doc-line NO-LOCK WHERE buf_doc-line.doc-code = p-doc-code :
      ASSIGN j_total = j_total + 1.
      { str/is-petrl.i buf_doc-line.artic
                   buf_doc-line.prod-type
                   buf_doc-line.prod-code
                   is-petrol
                   is-pieces              NO-ERROR }
      IF ERROR-STATUS :ERROR OR is-petrol <> YES OR is-pieces <> NO THEN DO: NEXT. END.
      ASSIGN j_petrol = j_petrol + 1.
    END. /* FOR EACH buf_doc-line */
    IF j_total > 0 AND j_petrol > 0 THEN DO:
      MESSAGE "Напечатать акт переоценки только для топлива?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE l_answer.
    END.
  END. /* ON ERROR */
END PROCEDURE. /* CheckPetrol */