&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGOKCAN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGOKCAN
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет Реестр документов по секциям

Автор: Чернова Светлана Александровна
Дата создания: 03/06/06
Author: Svetlana Chernova
Creation date: 03/06/06

Created: 16/10/00

*/


define input  parameter parParentProc  as widget-handle no-undo.
/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Реестр документов по секциям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ cmp/r-pril.i new }
{ rep/r-sym.i    }
{ gbl/cur-time.i }
{ rep/gn-extp.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable v-log as logical   no-undo .

define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }


find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

run get-report-num  in parParentProc ( output g#report-num ).
run get-gds-engl in parParentProc ( output g#gds-engl ) .

/* Local Variable Definitions ---                                       */
&scop n-ost Остаток
define variable v-archive-ok as logical   no-undo .
define variable v-comment    as character no-undo .
define variable v-can-print  as logical   no-undo .
define variable Log-Res as log   no-undo .
define variable Prev-Per as log   no-undo .

define variable qnty            as  decimal   no-undo.
define variable d-qnty          as  decimal   no-undo.
define variable doc-sum         as  decimal     no-undo.
define variable cost-sum        as  decimal     no-undo.
define variable sale-sum        as  decimal     no-undo.
define variable ret-sale-sum    as  decimal     no-undo.
define variable ov-sum          as  decimal     no-undo.
define variable ret-ov-sum      as  decimal     no-undo.
define variable SumSLT          as  decimal     no-undo.
define variable ret-SumSLT      as  decimal     no-undo.
define variable VAT_pc         as  decimal     no-undo.
define variable SLT_pc         as  decimal     no-undo.
define variable VAT-sum        as  decimal     no-undo.
define variable SLT-sum        as  decimal     no-undo.
define variable VAT-cost       as  decimal     no-undo.
define variable SLT-cost       as  decimal     no-undo.
define variable VAT-sale       as  decimal     no-undo.
define variable SLT-sale       as  decimal     no-undo.
define variable VAT-salePr     as  decimal     no-undo.
define variable SLT-salePr     as  decimal     no-undo.
define variable SumSale        as  decimal     no-undo.
define variable SumCrsa        as  decimal     no-undo.
define variable SumOv          as  decimal     no-undo.
define variable SumDisc        as  decimal     no-undo.
define variable SumVat         as  decimal     no-undo.
define variable UpFact         as  decimal     no-undo.

define variable tot-qnty              as  decimal   no-undo.
define variable tot-doc-sum      as  decimal     no-undo.
define variable tot-cost-sum      as  decimal     no-undo.
define variable tot-sale-sum      as  decimal     no-undo.
define variable Line       as char    no-undo.
define variable curr-rep as char no-undo.

def stream OutStream .


define variable NAmeoper as char no-undo.
define variable NAmenode as char no-undo.

define variable T-NAme-node as char no-undo.
define variable T-fact-date as date no-undo.
define variable T-doc-num as char no-undo.
define variable t-cli-name as char no-undo.
define variable PayType as int no-undo.

define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.

define variable  Fact-order-1 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast1       like ub.stk-tot.sum-rubl   no-undo.

define variable  Fact-order-2 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity3    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat       like ub.stk-tot.sum-rubl   no-undo.
define variable  CoastSLT       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat3-1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat1       like ub.stk-tot.sum-rubl   no-undo.
define variable  coast-vat2       like ub.stk-tot.sum-rubl   no-undo.
define variable  CoastSLT-1       like ub.stk-tot.sum-rubl   no-undo.

define variable  Quantity3-1  like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast3-1     like ub.stk-tot.sum-rubl   no-undo.
define variable  QuantityCrsa    like ub.stk-tot.fact-qnty  no-undo.
define variable  CoastCrsa       like ub.stk-tot.sum-rubl   no-undo.
define variable  QuantityCrsa-1  like ub.stk-tot.fact-qnty  no-undo.
define variable  CoastCrsa-1     like ub.stk-tot.sum-rubl   no-undo.



define variable RootGrp like  ub.gds-grp.node-code  no-undo.

define variable FL as int init 0 no-undo.

define variable ii as int init 0 no-undo.
define variable hh as int init 0 no-undo.
define variable grp-name-temp as char init '' no-undo.

define variable Sum-qnty  like ub.ot-line.fact-qnty no-undo.   /* Количество         */
define variable Sum-Coast like ub.ot-line.sum-rubl no-undo.    /* Сумма в док        */
define variable Sum-NDS   like ub.ot-line.VAT-rubl no-undo.    /* НДС в док          */
define variable Sum-SLT   like ub.ot-line.SLT-rubl no-undo.    /* НП в док           */
define variable Sum-Disc  like ub.ot-line.other-rubl no-undo.  /* Скидка в док       */
define variable Sum-ov    like ub.ot-line.other-rubl no-undo.  /* авт переоц в док   */
define variable Sum-Crsa  like ub.ot-line.other-rubl no-undo.  /* сумма в продажных  */

define variable v-today   as date      no-undo.

DEFINE WORK-TABLE tdedt no-undo
  FIELD id AS char
  FIELD NAme AS char FORMAT "x(40)"
  FIELD n AS char .

DEFINE TEMP-TABLE TMP NO-UNDO
 FIELD           T-NAme-node_   as char
 FIELD           T-doc-num_     as char
 FIELD           T-fact-date_   as DAte
 FIELD           T-cli-name_    as char
 FIELD           qnty_          as decimal
 FIELD           SumSale_    as decimal
 FIELD           SumCrsa_    as decimal
 FIELD           SumOv_      as decimal
 FIELD           SumDisc_    as decimal
 FIELD           SumVat_     as decimal
 FIELD           SumSLT_     as decimal.

define buffer ot-line-crsa for  ub.ot-line .
define buffer ot-line-sale for  ub.ot-line .
define buffer stk-tot2 for  ub.stk-tot .
define buffer stk-line2 for  ub.stk-line .

define variable  Quantity-Itog0    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast-Itog0       like ub.stk-tot.sum-rubl  no-undo.
define variable  Coast-ItogOther       like ub.stk-tot.sum-rubl  no-undo.
define variable  Coast-ItogVAT       like ub.stk-tot.sum-rubl  no-undo.
define variable  Coast-ItogSLT       like ub.stk-tot.sum-rubl  no-undo.

define variable  Quantity-ItogCrsa    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast-ItogCrsa       like ub.stk-tot.sum-rubl  no-undo.


define variable  Quantity-Itog1    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast-Itog1       like ub.stk-tot.sum-rubl  no-undo.

define variable res as char INIT {&all} no-undo.

DEF VAR TEMPSTR AS CHAR NO-UNDO.
/* фрайм отчета*/
DEFINE FRAME DocsRep
    sym11 column-label ":!:" format "X(1)" space(0)
    T-NAme-node column-label "Секция! ":C40 format "x(40)" space(0)
    sym1 column-label ":!:" format "X(1)" space(0)
    t-fact-date column-label "Дата!закрытия":C10 format "99/99/9999" space(0)
    sym2 column-label ":!:" format "X(1)" space(0)
    t-doc-num column-label "Номер!документа":C10 format "X(10)" space(0)
    sym3 column-label ":!:" format "X(1)" space(0)
    t-cli-name column-label "Контрагент! ":C28 format "X(28)" space(0)
    sym4 column-label ":!:" format "X(1)" space(0)
    qnty column-label "Количество! ":C13 format "->>>>>>>9.999" space(0)
    sym5 column-label ":!:" format "X(1)" space(0)
    SumSale column-label "Сумма! ":C14 format "->>>>>>>>>9.99" space(0)
    sym6 column-label ":!:" format "X(1)" space(0)
    SumVat column-label " НДС! ":C14 format "->>>>>>>>>9.99" space(0)
    sym7 column-label ":!:" format "X(1)" space(0)
    SumSLT column-label "НП! ":C14 format "->>>>>>>>>9.99" space(0)
    sym8 column-label ":!:" format "X(1)" space(0)

    SumDisc column-label "Скидка! ":C14 format "->>>>>>>>>9.99" space(0)
    sym9 column-label ":!:" format "X(1)" space(0)
    SumOv column-label "Автоматическая!переоценка":C14 format "->>>>>>>>>9.99" space(0)
    sym10 column-label ":!:" format "X(1)" space(0)
    SumCrsa column-label "Сумма!в прод.ценах":C14 format "->>>>>>>>>9.99" space(0)
    sym12 column-label ":!:" format "X(1)" space(0)

    HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "Реестр документов (товарный отчет) ") AT 50 format "X(35)"
        string( "цены и суммы указаны в {&abbr_rub}." ) AT 90 format "X(27)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>9" ) ) AT 145 format "X(13)" SKIP
        Line format "X(197)" AT 1
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

DEFINE FRAME DocsRep-cost
    sym11 column-label ":!:" format "X(1)" space(0)
    T-NAme-node column-label "Секция! ":C40 format "x(40)" space(0)
    sym1 column-label ":!:" format "X(1)" space(0)
    t-fact-date column-label "Дата!закрытия":C10 format "99/99/9999" space(0)
    sym2 column-label ":!:" format "X(1)" space(0)
    t-doc-num column-label "Номер!документа":C10 format "X(10)" space(0)
    sym3 column-label ":!:" format "X(1)" space(0)
    t-cli-name column-label "Контрагент! ":C28 format "X(28)" space(0)
    sym4 column-label ":!:" format "X(1)" space(0)
    qnty column-label "Количество! ":C13 format "->>>>>>>9.999" space(0)
    sym5 column-label ":!:" format "X(1)" space(0)
    SumSale column-label "Сумма! ":C14 format "->>>>>>>>>9.99" space(0)
    sym6 column-label ":!:" format "X(1)" space(0)
    SumVat column-label " НДС! ":C14 format "->>>>>>>>>9.99" space(0)
    sym7 column-label ":!:" format "X(1)" space(0)
    SumSLT column-label "НП! ":C14 format "->>>>>>>>>9.99" space(0)
    sym8 column-label ":!:" format "X(1)" space(0)
    HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "Реестр документов (товарный отчет) ") AT 50 format "X(35)"
        string( "цены и суммы указаны в {&abbr_rub}." ) AT 90 format "X(27)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>9" ) ) AT 145 format "X(13)" SKIP
        Line format "X(152)" AT 1
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-11 RECT-14 RECT-15 text2 startdate ~
enddate CalcRest SET_PAY_TYPE COMBO-node b-print b-help b-quit
&Scoped-Define DISPLAYED-OBJECTS text2 startdate enddate CalcRest ~
SET_PAY_TYPE COMBO-node

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход":L
     size 10 by 1
     BGCOLOR 8 .

DEFINE VARIABLE combo-node AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          {&all}, 1,
"Выборочо", 2
     SIZE 12 BY 2.67 NO-UNDO.


DEFINE VARIABLE enddate AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     size 11 by 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE startdate AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     size 11 by 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE text2 AS CHARACTER FORMAT "X(256)":U INITIAL "Секции:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE SET_PAY_TYPE AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
 "Цены документа", 1,
 "Учетные цены", 2
     SIZE 20.75 BY 2.33 NO-UNDO.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     size 42.5 by 4.17.

DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     size 42.5 by 3.13.

DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     size 42.5 by 7.29.

DEFINE VARIABLE CalcRest AS LOGICAL INITIAL yes
     LABEL "Расчет остатков"
     VIEW-AS TOGGLE-BOX
     size 18.5 by 0.75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     text2 AT ROW 10.13 COL 17.5 COLON-ALIGNED NO-LABEL
     startdate at row 3.33 col 4 COLON-ALIGNED
     enddate at row 3.33 col 27 COLON-ALIGNED
     CalcRest at row 4.75 col 14
     SET_PAY_TYPE AT ROW 6.54 COL 12.88 NO-LABEL
     combo-node AT ROW 11.04 COL 16.63 NO-LABEL
     b-print at row 1 col 12
     b-help at row 1.04 col 33.88
     b-quit at row 1 col 2
     RECT-11 at row 2 col 1.5
     RECT-14 at row 6.29 col 1.5
     RECT-15 at row 9.71 col 1.5
          ub.gds-grp.node-name AT ROW 14.13 COL 3.25 NO-LABEL
           VIEW-AS TEXT
          SIZE 39.25 BY .96
          FGCOLOR 1
     "Период :" VIEW-AS TEXT
          size 9 by 0.75 at row 2.29 col 18.75
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D
         size 45 by 17.29
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Реестр документов  по секциям":L
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   UNDERLINE Custom                                                     */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE
       FRAME DLGOKCAN:PRIVATE-DATA     =
                "DLGCLOSE".

/* SETTINGS FOR COMBO-BOX COMBO-node IN FRAME DLGOKCAN
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX DLGOKCAN
/* Query rebuild information for DIALOG-BOX DLGOKCAN
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX DLGOKCAN */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print DLGOKCAN
ON CHOOSE OF b-print IN FRAME DLGOKCAN /* Печать */
DO:
  if INPUT FRAME {&FRAME-NAME} startdate > INPUT FRAME {&FRAME-NAME} enddate
  then do:
    message
      "Дата окончания должна быть не меньше даты начала!"
      .
  end.
  else do:
    assign
      startdate
      enddate
      .
    { gbl/curobjdt.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-today
    }

    if enddate > v-today
    then do:
      message
        "Дата окончания превышает текущую дату!"
        .
    end.
    else do:
      assign
        PayType = integer(SET_PAY_TYPE :screen-value)
      .
    end.
    /* Проверка наличия архивов */

    define variable v-start-date as date      no-undo .
    define variable v-end-date   as date      no-undo .
    assign
      v-start-date = startdate
      v-end-date   = enddate
    .

    run rep/chk-ahz.p
      (input        v-cntxt-obj-type /* p-obj-type      */
      ,input        v-cntxt-obj-code /* p-obj-code      */
      ,input        false            /* p-verify-detail */
      ,input        true             /* p-verify-arh    */
      ,input        false            /* p-verify-ahsp   */
      ,input        false            /* p-verify-aht    */
      ,input        true             /* p-check-act         */
      ,input        v-cntxt-db-num   /* p-check-act-db-num  */
      ,input        v-cntxt-userid   /* p-check-act-user-id */
      ,input-output v-start-date     /* p-date-start        */
      ,input-output v-end-date       /* p-date-end          */
      ,output       v-archive-ok     /* p-archive-ok        */
      ,output       v-comment        /* p-comment           */
      ,output       v-can-print      /* p-can-print         */
      ).
    if v-archive-ok = false
    then do:
      if v-can-print = true
      then do:
        define variable v-choice as logical   no-undo .
        message
          "ВНИМАНИЕ!" skip
          v-comment skip
          "" skip
          "Продолжить формирование отчета ?" skip
          view-as alert-box question buttons yes-no update v-choice .
        if v-choice = false
        then do:
          return . /* --->>>--- */
        end.
      end.
      else do:
        message
          "ВНИМАНИЕ !!!" skip
          "Отчет не может быть сформирован!" skip
          "На запрошенную дату нет архивов или они сжаты" skip
          v-comment skip
          view-as alert-box information .
        return . /* --->>>--- */
      end.
    end.
    else do:
      run main-proc in this-procedure .
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN

&Scoped-define SELF-NAME combo-node
ON VALUE-CHANGED OF combo-node IN FRAME DLGOKCAN
DO:

RES = {&all}.
  Assign combo-node.
  if combo-node = 2 Then DO:
    run cus/sel-grp0.w (1).
    RES = return-value .
    if RES = {&all} OR RES = '' Then DO:
            Assign combo-node = 1 RES = {&all}.
            Display combo-node  with frame {&FRAME-NAME} .
            End.

    END.
    IF RES <> {&all} THEN DO:
    find first ub.gds-grp where ub.gds-grp.node-code = integer(res) no-lock no-error.
    if available ub.gds-grp THEN DO:
      enable ub.gds-grp.node-name  with frame {&FRAME-NAME} .
      Display ub.gds-grp.node-name  with frame {&FRAME-NAME} .
      End.
    END.
    IF RES = {&all} THEN hide ub.gds-grp.node-name  in frame {&FRAME-NAME} .
    Display combo-node  with frame {&FRAME-NAME} .
END.


&UNDEFINE SELF-NAME

/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/ed_date.i Startdate}
{ gbl/ed_date.i enddate}

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

    { gbl/curobjdt.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-today
    }

ASSIGN
    startdate = v-today - 7
    enddate   = v-today .

/* список секций */
Find first ub.gds-grp where ub.gds-grp.upper-code =0 no-lock no-error.
     If AVAILABLE ub.gds-grp then Rootgrp = ub.gds-grp.node-code.
        Else DO:
             message "Отчет пуст ! Не заполнен классификатор групп товаров!".
             Return.
             End.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    if session:set-wait-state("COMPILER") then.

    run enable_ui.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.

run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Calc-Itog-node DLGOKCAN
PROCEDURE Calc-Itog-node :
/*остатки на начало и  конец интервала по секции */
if CalcRest then
    do:
      FIND LAST ub.stk-line WHERE ub.stk-line.obj-type  = v-cntxt-obj-type
                          AND ub.stk-line.obj-code   = v-cntxt-obj-code
                          AND ub.stk-line.prod-code  = ub.gds-obj.prod-code
                          AND ub.stk-line.prod-type  = ub.gds-obj.prod-type
                          AND ub.stk-line.artic      = ub.gds-obj.artic
                          AND ub.stk-line.fact-order <= fact-order-1
                          AND ub.stk-line.sum-type   =  (IF PayType = 2  then  {&arh-cost}
                                                                    else  {&arh-crsa} )
                          AND ub.stk-line.cat-id     = {&root-cat-id}

                          USE-INDEX category no-lock no-error.

      If Available ub.stk-line then Assign Quantity3-1    = Quantity3-1 + ub.stk-line.fact-qnty
                                        Coast3-1       = Coast3-1 + ub.stk-line.sum-rubl
                                        coast-vat3-1     = coast-vat3-1 + ub.stk-line.VAT-rubl
                                        CoastSLT-1     = CoastSLT-1 + ub.stk-line.SLT-rubl
                                        .

      FIND LAST stk-line2 WHERE stk-line2.obj-type  = v-cntxt-obj-type
                          AND stk-line2.obj-code   = v-cntxt-obj-code
                          AND stk-line2.prod-code  = ub.gds-obj.prod-code
                          AND stk-line2.prod-type  = ub.gds-obj.prod-type
                          AND stk-line2.artic      = ub.gds-obj.artic
                          AND stk-line2.fact-order <= fact-order-1
                          AND stk-line2.sum-type   =  {&arh-crsa} no-lock no-error.

      If Available stk-line2 then Assign QuantityCrsa-1    = QuantityCrsa-1 + stk-line2.fact-qnty
                                         CoastCrsa-1       = CoastCrsa-1 + stk-line2.sum-rubl .
   End.
 END PROCEDURE.
PROCEDURE Calc-Itog-node-end :
/*остатки   конец интервала по секции */
if CalcRest then
    do:
      FIND LAST ub.stk-line WHERE ub.stk-line.obj-type  = v-cntxt-obj-type
                          AND ub.stk-line.obj-code   = v-cntxt-obj-code
                          AND ub.stk-line.prod-code  = ub.gds-obj.prod-code
                          AND ub.stk-line.prod-type  = ub.gds-obj.prod-type
                          AND ub.stk-line.artic      = ub.gds-obj.artic
                          AND ub.stk-line.fact-order <= fact-order-2
                          AND ub.stk-line.sum-type   =  (IF PayType = 2  then  {&arh-cost}
                                                                      else  {&arh-crsa} )
                          AND ub.stk-line.cat-id     = {&root-cat-id}
                          USE-INDEX category no-lock no-error.

      If Available ub.stk-line then Assign Quantity3    = Quantity3 + ub.stk-line.fact-qnty
                                        Coast3       = Coast3 + ub.stk-line.sum-rubl
                                        coast-vat     = coast-vat + ub.stk-line.VAT-rubl
                                        CoastSLT     = CoastSLT + ub.stk-line.SLT-rubl
                                        .
      FIND LAST stk-line2 WHERE stk-line2.obj-type   = v-cntxt-obj-type
                          AND stk-line2.obj-code     = v-cntxt-obj-code
                          AND stk-line2.prod-code    = ub.gds-obj.prod-code
                          AND stk-line2.prod-type    = ub.gds-obj.prod-type
                          AND stk-line2.artic        = ub.gds-obj.artic
                          AND stk-line2.fact-order   <= fact-order-2
                          AND stk-line2.sum-type     = {&arh-crsa}
                          no-lock no-error.

      If Available stk-line2 then Assign QuantityCrsa   = QuantityCrsa + stk-line2.fact-qnty
                                        CoastCrsa       = CoastCrsa + stk-line2.sum-rubl.


   End.
 END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CalcItog DLGOKCAN
PROCEDURE CalcItog :
/*------------------------------------------------------------------------------
  Purpose:  Найти Остатки на начало и конец и соответстенные FACT-ORDER
  номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ
  А ОСТАТКИ БЕРУТСЯ НА ДАТУ ИЛИ МЕНЬШЕ БЕЗ НИЖНЕЙ ГРАНИЦЫ
------------------------------------------------------------------------------*/
FIND FIRST ub.stk-tot WHERE ub.stk-tot.obj-type = v-cntxt-obj-type
                                   AND ub.stk-tot.obj-code   = v-cntxt-obj-code
                                   AND ub.stk-tot.Fact-date >= startdate - 1
                                   AND ub.stk-tot.Fact-date <= Enddate
                                   AND ub.stk-tot.sum-type = (IF PayType = 2  then  {&arh-cost} /* учетная */
                                                                            else  {&arh-crsa} )
                                   AND ub.stk-tot.cat-id  = {&root-cat-id}

                                   USE-INDEX fact-date no-lock no-error.

If Available ub.stk-tot then Assign Fact-order-1 = ub.stk-tot.Fact-order.
                      Else Assign Fact-order-1 = 0.

/*остаток на НАЧАЛО ЭТО ОСТАТОК НА КОНЕЦ предыдущего дня*/
FIND last ub.stk-tot WHERE ub.stk-tot.obj-type = v-cntxt-obj-type
                                   AND ub.stk-tot.obj-code   = v-cntxt-obj-code
                                   AND ub.stk-tot.Fact-date <= startdate - 1
                                   AND ub.stk-tot.sum-type = (IF PayType = 2  then  {&arh-cost} /* учетная */
                                                                            else  {&arh-crsa} )
                                   AND ub.stk-tot.cat-id  = {&root-cat-id}

                                   USE-INDEX fact-date no-lock no-error.

If Available ub.stk-tot then Assign Fact-order-1 = ub.stk-tot.Fact-order
                                 Quantity1    = ub.stk-tot.fact-qnty
                                 Coast1       = ub.stk-tot.sum-rubl
                                 Coast-vat1   = ub.stk-tot.vat-rubl
                                 .
                      Else Assign Fact-order-1 = 0
                                 Quantity1    = 0
                                 Coast1       = 0
                                 Coast-vat1   = 0
                                 .


/*----------------------------------------------------------------------------------------------------------------*/
/*номер последнего Fact-ordera и остатки на конец интервала  */
/* номерА  Fact-ordera -ДОЛЖЕНЫ ЛЕЖАТЬ В ИНТЕРВАЛЕ ВРЕМЕНИ*/
/* А ОСТАТКИ БЕРУТСЯ НА ДАТУ ИЛИ МЕНЬШЕ БЕЗ НИЖНЕЙ ГРАНИЦЫ*/
FIND LAST ub.stk-tot WHERE ub.stk-tot.obj-type = v-cntxt-obj-type
                                   AND ub.stk-tot.obj-code   = v-cntxt-obj-code
                                   AND ub.stk-tot.Fact-date >= startdate
                                   AND ub.stk-tot.Fact-date <= Enddate
                                   AND ub.stk-tot.sum-type = (IF PayType = 2  then  {&arh-cost} /* учетная */
                                                                           else  {&arh-crsa} )
                                   AND ub.stk-tot.cat-id  = {&root-cat-id}

                                   USE-INDEX fact-date no-lock no-error.

If Available ub.stk-tot then Assign Fact-order-2 = ub.stk-tot.Fact-order .
                     else Assign Fact-order-2 = 0.


FIND LAST ub.stk-tot WHERE ub.stk-tot.obj-type = v-cntxt-obj-type
                                   AND ub.stk-tot.obj-code   = v-cntxt-obj-code
                                   AND ub.stk-tot.Fact-date <= Enddate
                                   AND ub.stk-tot.sum-type = (IF PayType = 2  then  {&arh-cost} /* учетная */
                                                                           else  {&arh-crsa} )
                                   AND ub.stk-tot.cat-id  = {&root-cat-id}

                                   USE-INDEX fact-date no-lock no-error.

If Available ub.stk-tot then Assign Quantity2    = ub.stk-tot.fact-qnty
                                 Coast2       = ub.stk-tot.sum-rubl
                                 Coast-vat2    = ub.stk-tot.vat-rubl
                                 .
                     else Assign Quantity2    = 0
                                 Coast2       = 0
                                 Coast-vat2   = 0
                                 .



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN _DEFAULT-DISABLE
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
  HIDE FRAME DLGOKCAN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN _DEFAULT-ENABLE
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
  DISPLAY text2 startdate enddate CalcRest SET_PAY_TYPE COMBO-node
      WITH FRAME DLGOKCAN.
  ENABLE RECT-11 RECT-14 RECT-15 text2 startdate enddate CalcRest SET_PAY_TYPE
         COMBO-node b-print b-help b-quit
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Foreach DLGOKCAN
PROCEDURE Foreach :
For each ub.gds-grp where ub.gds-grp.upper-code = Rootgrp no-lock:
  /*Название секции*/

  IF res <> {&all} Then  If ub.gds-grp.node-code <> integer(res) then NEXT.

    T-NAme-node = ub.gds-grp.node-name.
    NAmenode = ub.gds-grp.node-name.
    run u-line.
    run printdetitogo. /*пустая шапка для секции*/

For each ub.gds-obj where ub.gds-obj.grp-name begins ub.gds-grp.node-name
                           AND ub.gds-obj.obj-code = v-cntxt-obj-code
                           AND ub.gds-obj.obj-type = v-cntxt-obj-type no-lock:
  run calc-itog-node.
  run calc-itog-node-end .

  For each ot-line-crsa
                   where   ot-line-crsa.sum-type = {&arh-crsa}
                          AND ot-line-crsa.fact-order >  fact-order-1
                          AND ot-line-crsa.fact-order <= fact-order-2
                          AND ot-line-crsa.obj-code   = v-cntxt-obj-code
                          AND ot-line-crsa.obj-type   = v-cntxt-obj-type
                          AND ot-line-crsa.prod-code  = ub.gds-obj.prod-code
                          AND ot-line-crsa.prod-type  = ub.gds-obj.prod-type
                          AND ot-line-crsa.artic      = ub.gds-obj.artic
                          no-lock
                          BREAK  BY ot-line-crsa.ext-doc-type  BY ot-line-crsa.doc-code  :

                      Find  First ub.ot-line where
                              ub.ot-line.fact-order = ot-line-crsa.fact-order
                          AND ub.ot-line.obj-code   = ot-line-crsa.obj-code
                          AND ub.ot-line.obj-type   = ot-line-crsa.obj-type
                          AND ub.ot-line.prod-code  = ot-line-crsa.prod-code
                          AND ub.ot-line.prod-type  = ot-line-crsa.prod-type
                          AND ub.ot-line.artic      = ot-line-crsa.artic
                          and ub.ot-line.sum-type   =
                           (IF PayType = 2  then  {&arh-cost}  else  {&arh-sale} )
                          no-lock  no-error .
                      Find  First ot-line-sale where
                              ot-line-sale.fact-order = ot-line-crsa.fact-order
                          AND ot-line-sale.obj-code   = ot-line-crsa.obj-code
                          AND ot-line-sale.obj-type   = ot-line-crsa.obj-type
                          AND ot-line-sale.prod-code  = ot-line-crsa.prod-code
                          AND ot-line-sale.prod-type  = ot-line-crsa.prod-type
                          AND ot-line-sale.artic      = ot-line-crsa.artic
                          and ot-line-sale.sum-type   = {&arh-sale}
                          no-lock  no-error .

      ii = ii + 1.
  { rep/r-mess.i ii 25}
   if available  ub.ot-line then do :
      Accumulate ub.ot-line.fact-qnty      (TOTAL BY ot-line-crsa.doc-code).
      Accumulate ub.ot-line.sum-rubl       (TOTAL BY ot-line-crsa.doc-code).
      Accumulate ub.ot-line.VAT-rubl       (TOTAL BY ot-line-crsa.doc-code).
      Accumulate ub.ot-line.SLT-rubl       (TOTAL BY ot-line-crsa.doc-code).
      Accumulate ub.ot-line.other-rubl     (TOTAL BY ot-line-crsa.doc-code).
      Quantity-Itog0 = Quantity-Itog0    + ub.ot-line.fact-qnty.
      Coast-Itog0    = Coast-Itog0       + ub.ot-line.sum-rubl.
      Coast-ItogVAT    = Coast-ItogVAt       + ub.ot-line.VAT-rubl.
      Coast-ItogSLT    = Coast-ItogSLT       + ub.ot-line.SLT-rubl.
      Coast-ItogOther  = Coast-ItogOther     + ub.ot-line.other-rubl.
      End.

      Accumulate ot-line-crsa.sum-rubl  (TOTAL BY ot-line-crsa.doc-code).
      Coast-ItogCRSA    = Coast-ItogCRSA + ot-line-crsa.sum-rubl.

   FIND First TDEDT where tdedt.id = ot-line-crsa.ext-doc-type no-error .

   If LAST-OF (ot-line-crsa.doc-code) Then DO: /* № документа */
      Find Last ub.trn-doc where ub.trn-doc.doc-code = ot-line-crsa.doc-code no-lock no-error.
           If NOT Available ub.trn-doc then
              Find Last ub.price-doc where ub.price-doc.doc-num = ot-line-crsa.doc-code no-lock no-error.
      Create Tmp.
      Assign
           Tmp.T-fact-date_   = If Available ub.trn-doc then  ub.trn-doc.fact-date Else (If Available ub.price-doc THEN ub.price-doc.fact-date ELSE DATE(''))
           Tmp.T-cli-name_    = If Available ub.trn-doc then ub.trn-doc.cli-name Else ""
           Tmp.T-NAme-node_   = ( If available tdedt then tdedt.n + tdedt.name else ( ot-line-crsa.ext-doc-type + ' нет в справочнике!'))

           Tmp.T-doc-num_     = ot-line-crsa.doc-code.
           Tmp.qnty_          = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.fact-qnty).
           Tmp.SumSale_       = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.sum-rubl)  .
           Tmp.SumVat_        = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.VAT-rubl).
           Tmp.SumSLT_        = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.SLT-rubl).
           Tmp.SumCrsa_       = (Accum TOTAL BY ot-line-crsa.doc-code ot-line-crsa.sum-rubl).
           Tmp.SumDisc_       = (Accum TOTAL BY ot-line-crsa.doc-code ub.ot-line.other-rubl) .
           Tmp.SumOv_         = Tmp.SumCrsa_ - Tmp.SumSale_ - Tmp.SumDisc_ .

      /* ОБЪЕДИНЕНИЕ RS & ES */

      if ot-line-crsa.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or ot-line-crsa.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}  tHEN do:
         Assign  Tmp.T-NAme-node_   = "16" + "касса"
                 Tmp.T-doc-num_     = Substring(ot-line-crsa.doc-code,1, LENGTH(trim(ot-line-crsa.doc-code)) - 1 ).
         eND.

     End.
/*------------------------------------------------------------------*/

    End. /* по строкам документов*/
   End. /*по группе*/
  /* по временной таблице*/
       For each tmp Break BY Tmp.T-NAme-node_ BY Tmp.T-doc-num_:
                    Accumulate Tmp.qnty_        (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.SumSale_     (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.SumCrsa_     (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.Sumov_       (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.Sumdisc_     (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.SumVat_      (TOTAL BY Tmp.T-doc-num_).
                    Accumulate Tmp.SumSLT_      (TOTAL BY Tmp.T-doc-num_).

                    Accumulate Tmp.qnty_        (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.SumSale_     (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.SumVat_      (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.SumSLT_      (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.SumCrsa_     (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.Sumov_       (TOTAL BY Tmp.T-NAme-node_).
                    Accumulate Tmp.Sumdisc_     (TOTAL BY Tmp.T-NAme-node_).


            If FIRST-OF (Tmp.T-NAme-node_) Then DO: /*по типу документов -шапка */
              Assign
                   T-NAme-node   = ''
                   T-doc-num     = ''
                   T-fact-date   = Date('')
                   T-cli-name    = Substring(Tmp.T-NAme-node_,3)
                   qnty          = 0
                   SumSale       = 0
                   SumCrsa       = 0
                   SumDisc       = 0
                   Sumov         = 0
                   SumVat        = 0
                   SumSLT        = 0   .
                   run printdetitogo.  /*печать строки*/
                End.

           If LAST-OF (Tmp.T-doc-num_) Then DO: /*№ документа*/
               Assign
                   T-NAme-node   = ''
                   T-doc-num     = Tmp.T-doc-num_
                   T-fact-date   = Tmp.T-fact-date_
                   T-cli-name    = Tmp.T-cli-name_
                   qnty          = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.qnty_)
                   SumSale    = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumSale_)
                   SumCrsa    = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumCrsa_)
                   SumOv      = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumOv_)
                   SumDisc    = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumDisc_)
                   SumVat     = (Accum TOTAL BY Tmp.T-doc-num_ Tmp.SumVat_)
                   SumSLT     = (Accum TOTAL BY Tmp.T-doc-num_ tmp.SumSLT_).
                   if PayType = 2 then DO:
                   if NOT (qnty  = 0 and  SumSale = 0 )  then
                               run printdetaile2.  /* печать строки */
                               End.
                   Else do:
                   if NOT (qnty  = 0 and  SumSale = 0  and  SumCRSA = 0)  then
                               run printdetaile2.  /* печать строки */
                               End.

             End.

             If LAST-OF (Tmp.T-NAme-node_) Then DO: /*типы документов*/
              Assign
                   T-NAme-node = ''
                   T-doc-num   = ''
                   T-fact-date = Date('')
                   T-cli-name  = "Итого по типу " + Substring(Tmp.T-NAme-node_,3)
                   qnty       = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.qnty_)
                   SumSale    = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumSale_)
                   SumCrsa    = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumCrsa_)
                   SumOv      = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumOv_)
                   SumDisc    = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumDisc_)
                   SumVat     = (Accum TOTAL BY Tmp.T-NAme-node_ Tmp.SumVat_)
                   SumSLT     = (Accum TOTAL BY Tmp.T-NAme-node_ tmp.SumSLT_).
                   run printdetaile2.  /*печать строки*/
                   run p-line.

             End.

       End. /* For each Tmp */

    For each tmp: delete tmp. end.
    run itog0.
  End .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Itog0 DLGOKCAN
PROCEDURE Itog0 :
/*------------------------------------------------------------------------------
  Purpose: Итоги по секции   NAmenode
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run itog0start.
      Assign
           T-NAme-node = trim(NAmenode) + "   ИТОГО оборот"
           T-doc-num     = ''
           T-fact-date = Date('')
           T-cli-name    =''
           qnty       = Quantity-Itog0   /* "Количество */
           SumSale    = Coast-Itog0      /* "Сумма! "*/
           SumCrsa    = Coast-ItogCRSA      /* "Сумма! "*/
           SumDisc    = Coast-ItogOther
           SumOv      = Coast-ItogCRSA - Coast-Itog0 -  Coast-ItogOther
           SumVat     = Coast-ItogVAt                /*" НДС! " */
           SumSLT     = Coast-ItogSLT                /* "НП! " */.
           run print-o.
           Quantity-Itog0 = 0 .
           Coast-Itog0    = 0 .
           Coast-ItogCRSA = 0 .
           Coast-ItogOther = 0 .
           Coast-ItogVAT   = 0 .
           Coast-ItogSLT   = 0 .

/*Печать остатков на конец по секции*/

if CalcRest then
    do:
       Assign
           T-NAme-node = string( "   {&n-ost} на конец периода (" + string( enddate, "99/99/9999" ) + ")" )
           T-doc-num     = ''
           T-fact-date = Date('')
           T-cli-name    =''
           qnty          = Quantity3   /* "Количество */
           SumSale       = Coast3      /* "Сумма! "*/
           SumCrsa       = CoastCRSA      /* "Сумма! "*/
           SumDisc       = 0
           SumOv         = 0
           SumVat        = coast-vat                /*" НДС! " */
           SumSLT        = CoastSLT               /* "НП! " */.
           run printdetaile2. /*печать строки*/

    end.
    Quantity3 = 0 .
    Coast3    = 0 .
    CoastCRSA = 0 .
    coast-vat = 0 .
    CoastSLT = 0 .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Itog0Start DLGOKCAN
PROCEDURE Itog0Start :
/*------------------------------------------------------------------------------
  Purpose: Итоги по секции   NAmenode
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*Печать остатков на начало по секции*/
if CalcRest then
    do:
       Assign
           T-NAme-node = string( "   {&n-ost} на начало периода(" + string( startdate, "99/99/9999" ) + ")" )
           T-doc-num     = ''
           T-fact-date = Date('')
           T-cli-name    =''
           qnty          = Quantity3-1    /* "Количество */
           SumSale       = Coast3-1       /* "Сумма! "*/
           SumCrsa       = CoastCRSA-1    /* "Сумма! "*/
           SumVat        = coast-vat3-1     /*" НДС! " */
           SumDisc       = 0
           SumOv         = 0
           SumSLT        = COASTSLT-1     /* "НП! " */.
           run printdetaile2.             /*печать строки*/

    end.

    Quantity3-1 = 0 .
    Coast3-1    = 0 .
    CoastCRSA-1 = 0 .
    coast-vat3-1  = 0 .
    CoastSLT-1  = 0 .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main-proc DLGOKCAN
PROCEDURE main-proc :
run maketemptabl.

define variable last_day as integer no-undo .
define variable firstdate as date no-undo .
define variable m-str as char no-undo .

define variable doc_str   as char no-undo.
define variable doc_str1 as char no-undo.

Line = fill("-", 214).
assign frame {&FRAME-NAME}
    CalcRest Enddate startdate Set_Pay_Type combo-node.
assign
    II=0
    tot-qnty     = 0
    tot-doc-sum  = 0
    tot-cost-sum = 0
    tot-sale-sum = 0
    .
run nsum.
FIND ub.clients WHERE ub.clients.obj-type = v-cntxt-obj-type
                                   AND ub.clients.obj-code = v-cntxt-obj-code
                                   NO-LOCK . /* найти объект */


run waitfram-show ( {&mywaitmess} ) .
{ cmp/open-out.i STREAM OutStream " " {&LS_PS_A4} }
if PayType = 2 then
   FORM with FRAME DocsRep-cost .
   Else
   FORM with FRAME DocsRep .
{ rep/r-formh.i X(197) {&DOS_cw_2}}
 run calcitog.
 run printheader.
if paytype = 2 then
   form with frame docsrep-cost .
   else
   form with frame docsrep .

/*Основная таблица*/
  run foreach.
  hide stream outstream frame bottomframe .
  run printfooter.
  if paytype = 2 then
  hide stream outstream frame docsrep-cost .
  else hide stream outstream frame docsrep .
  output stream outstream close.
  run waitfram-hide .

define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 8.
run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MakeTempTabl DLGOKCAN
PROCEDURE MakeTempTabl :
/*------------------------------------------------------------------------------
  Purpose:Временная таблица для хранения названий ex-doc-type.
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ rep/r-mtdedt.i {&TDEDT_Pri_Vnesh}  01}
{ rep/r-mtdedt.i {&TDEDT_Pri_Perem}  02}
{ rep/r-mtdedt.i {&TDEDT_Pri_Prvo}   03}
{ rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh}  04}
{ rep/r-mtdedt.i {&TDEDT_Vozvrat_Perem}  05}
{ rep/r-mtdedt.i {&TDEDT_Spi_Vnesh}  06}
{ rep/r-mtdedt.i {&TDEDT_Spi_Prvo}   07}
{ rep/r-mtdedt.i {&TDEDT_Ras_Perem}  08}
{ rep/r-mtdedt.i {&TDEDT_Ras_Prvo}   09}
{ rep/r-mtdedt.i {&TDEDT_Ras_Vnesh}  10}
{ rep/r-mtdedt.i {&TDEDT_RAS_Vnesh_VP}       11}
{ rep/r-mtdedt.i {&TDEDT_Vozvrat_Vnesh_Kass} 12}
{ rep/r-mtdedt.i {&TDEDT_Ras_Vnesh_Kass}     13}
{ rep/r-mtdedt.i {&TDEDT_Overturn}           14}
{ rep/r-mtdedt.i {&TDEDT_Inv}                15}
{ rep/r-mtdedt.i {&TDEDT_Peresort}           17}
{ rep/r-mtdedt.i {&TDEDT_Corr_Minus_parts}     18}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NSum DLGOKCAN
PROCEDURE NSum :
Assign
           qnty          = 0  /* "Количество */
           SumSale    = 0  /* "Сумма! "*/
           SumCrsa    = 0  /* "Сумма! "*/
           SumVat = 0  /*" НДС! " */
           SumSLT    = 0  /* "НП! " */
           SumOv      = 0
           SumDisc      = 0
           Sum-qnty      = 0
           Sum-Coast     = 0
           Sum-NDS       = 0
           Sum-SLT       = 0.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE on-same-page DLGOKCAN
PROCEDURE on-same-page :
/* позволяет перейти к следующей странице (если это необходимо)  */
  /* необходимо применять, перед выводом блок из нескольких строк, */
  /* который должен быть размещен в предлах одной страницы         */
  define input parameter p-line-number as integer  no-undo .

  if p-line-number > page-size( OutStream ) then do:
    /* запрошенное количество строк - превышает размер страницы */
    /* не переходим на следующую страницу */
    return .
  end.

  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.

end procedure. /* on-same-page */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE P-line DLGOKCAN
PROCEDURE P-line :
if paytype = 2 then DO:
Underline stream OutStream
        sym11
        sym3 T-fact-date
        sym4 T-doc-num
        sym5 T-cli-name
        sym6 qnty
        sym7 SumSale
        sym8 SumVat
        SumSLT
        with FRAME DocsRep-cost.
        DOWN stream OutStream 1 with FRAME DocsRep-cost.
        end.
        Else do:
Underline stream OutStream
        sym11 sym12
        sym3 T-fact-date
        sym4 T-doc-num
        sym5 T-cli-name
        sym6 qnty
        sym7 SumSale
        sym8 SumVat
        sym9 SumSLT
        sym10 sumcrsa
        sumov sumdisc
        with FRAME DocsRep.
        DOWN stream OutStream 1 with FRAME DocsRep.
       End.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintDetaile2 DLGOKCAN
PROCEDURE PrintDetaile2 :
/*------------------------------------------------------------------------------
  Purpose:   Печать строки отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if paytype =  2 then
  DISPLAY stream OutStream
       T-NAme-node
       sym1  T-fact-date
       sym2  T-doc-num
       sym3  T-cli-name
       sym4  qnty    format "->>>>>>>9.999"
       sym5  SumSale format "->>>>>>>>>9.99"
       sym6  SumVat  format "->>>>>>>>>9.99"
       sym7  SumSLT  format "->>>>>>>>>9.99"
       sym8
       sym11
         with FRAME DocsRep-cost.
    ELSE
  DISPLAY stream OutStream
        T-NAme-node
       sym1  T-fact-date
       sym2  T-doc-num
       sym3  T-cli-name
       sym4  qnty    format "->>>>>>>9.999"
       sym5  SumSale format "->>>>>>>>>9.99" when NOT (TRIM(T-NAme-node)  begins "{&n-ost}")
       sym6  SumVat  format "->>>>>>>>>9.99" when NOT (TRIM(T-NAme-node)  begins "{&n-ost}")
       sym7  SumSLT  format "->>>>>>>>>9.99" when NOT (TRIM(T-NAme-node)  begins "{&n-ost}")
       sym8  SumCrsa format "->>>>>>>>>9.99"
       sym9
       SumOv   format "->>>>>>>>>9.99"       when NOT (TRIM(T-NAme-node)  begins "{&n-ost}")
       sym10
       SumDisc format "->>>>>>>>>9.99"       when NOT (TRIM(T-NAme-node)  begins "{&n-ost}")
       sym11
       sym12
         with FRAME DocsRep.
    if PayType = 2
    then DOWN stream OutStream 1 with FRAME DocsRep-cost.
    else DOWN stream OutStream 1 with FRAME DocsRep.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintDetItogo DLGOKCAN
PROCEDURE PrintDetItogo :
/*------------------------------------------------------------------------------
  Purpose:   Печать строки отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if paytype = 2 THEN
    Put Stream OutStream UNFORMATTED
    sym11
    string(T-NAme-node  ,"x(40)")
    sym1  space(10)
    sym2  space(10)
    sym3  String(T-cli-name   ,"x(28)")
    sym4  space(13)
    sym5  space(14)
    sym6  space(14)
    sym7  space(14)
    sym8
    skip.
 Else
    Put Stream OutStream UNFORMATTED
    sym11
    string(T-NAme-node  ,"x(40)")
    sym1  space(10)
    sym2  space(10)
    sym3  String(T-cli-name   ,"x(28)")
    sym4  space(13)
    sym5  space(14)
    sym6  space(14)
    sym7  space(14)
    sym8  space(14)
    sym9  space(14)
    sym10 space(14)
    sym12
    skip.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintFooter DLGOKCAN
PROCEDURE PrintFooter :
/*------------------------------------------------------------------------------
  Purpose:  Печать общих итогов
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 /*поджчеркнуть все*/
 run u-line.

  /* выводим завершающую информацию, свидетельствующую о том, что отчет завершен */
  run on-same-page in this-procedure (input 11) .
  /* делаем footer невидимым, чтобы он не напечатался на последней странице */
  hide stream OutStream frame bottomframe .

/*Печать оборота*/
    Quantity = Quantity2 - Quantity1.
    Coast = Coast2 - Coast1 .
    Coast-vat = Coast-vat2 - Coast-vat1 .
   { rep/r-reer.i }


/*Печать остатков на конец*/
if CalcRest then
    do:
        PUT STREAM OutStream "По всем секциям " skip.
       { rep/r-reer.i 2}
    end.


PUT STREAM OutStream " " SKIP(2)
    SPACE(20) "Заведующий __________________" format "X(32)"
    SPACE(20) "Ст. продавец __________________" format "X(32)"
    SPACE(20) "Бухгалтер __________________" format "X(32)" SKIP
    .

   run on-same-page in this-procedure (input 10) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintHeader DLGOKCAN
PROCEDURE PrintHeader :
/*------------------------------------------------------------------------------
  Purpose: Печать шапки отчета
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

PUT STREAM OutStream SPACE(27)
        "Р Е Е С Т Р   Д О К У М Е Н Т О В ( Т О В А Р Н Ы Й   О Т Ч Е Т )"
            format "X(80)" SKIP(1)
        SPACE(40) "за период  с  " format "X(14)" startdate format "99.99.9999"
            "  по  " enddate format "99.99.9999"
        SPACE(32) string("По объекту  : " + ub.clients.obj-name ) format "X(80)" SKIP
        If paytype = 2 Then "Суммы указаны в УЧЕТНЫХ ценах"
                       Else "Суммы указаны в ЦЕНАХ ДОКУМЕНТА"  format "X(80)"
        SKIP
        .

/*если есть подсчет остатков */
if CalcRest then
    do:
        PUT STREAM OutStream "По всем секциям " skip.
        { rep/r-reer.i 1}
    end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE u-line DLGOKCAN
PROCEDURE u-line :
if PayType = 2 then
Underline stream OutStream
        sym1 T-NAme-node
        sym2 T-fact-date
        sym3 T-doc-num
        sym4 T-cli-name
        sym5 qnty
        sym6
        SumSale
        sym7 SumVat
        sym8 SumSLT
        sym11
        with FRAME DocsRep-cost.
Else
Underline stream OutStream
        sym1 T-NAme-node
        sym2 T-fact-date
        sym3 T-doc-num
        sym4 T-cli-name
        sym5 qnty
        sym6
        SumSale
        SumCrsa
        SumOv
        SumDisc
        sym7 SumVat
        sym8 SumSLT
        sym9
        sym10
        sym11
        sym12
        with FRAME DocsRep.
 if PayType = 2 then
 DOWN stream OutStream 1 with FRAME DocsRep-cost.
 Else DOWN stream OutStream 1 with FRAME DocsRep.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Print-o DLGOKCAN
PROCEDURE Print-o :
if PayType = 2 then
Put Stream OutStream UNFORMATTED
  sym11  string(T-NAme-node  ,"x(51)")
  sym1   space(10)
  sym3   space(28)
  sym4  qnty     format "->>>>>>>9.999"
  sym5  SumSale  format "->>>>>>>>>9.99"
  sym6  SumVat   format "->>>>>>>>>9.99"
  sym7  SumSLT   format "->>>>>>>>>9.99"
  sym8
  skip.
  Else
Put Stream OutStream UNFORMATTED
  sym11  string(T-NAme-node  ,"x(51)")
  sym1   space(10)
  sym3   space(28)
  sym4  qnty     format "->>>>>>>9.999"
  sym5  SumSale  format "->>>>>>>>>9.99"
  sym6  SumVat   format "->>>>>>>>>9.99"
  sym7  SumSLT   format "->>>>>>>>>9.99"
  sym8  Sumdisc  format "->>>>>>>>>9.99"
  sym9  Sumov    format "->>>>>>>>>9.99"
  sym10 SumCrsa  format "->>>>>>>>>9.99"
  sym12
  skip.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME