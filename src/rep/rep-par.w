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

Форма настройки печати списка документов

Автор: Чернова Светлана Александровна
Дата создания: 10/10/05
Author: Svetlana Chernova
Creation date: 10/10/05

Author: VGC .
Created: 03/03/94 -  5:03 pm

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-title as character no-undo .
define input  parameter qh as handle no-undo . /* handle query  */
define input  parameter bh as handle no-undo . /* handle buffer  */


def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Форма настройки печати списка документов    ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ cmp/breakstr.i }
{ cmp/r-pril.i  new  }
{ rep/wt-docs.i new  }
{ gbl/waitfram.i     }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* Local Variable Definitions ---                                       */
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define buffer buf_rep_currency for ub.currency.
define variable v-cntxt-host-name-obj as character no-undo .
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }
find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .
run get-report-num  in parParentProc ( output g#report-num ).

define buffer t-doc for ub.trn-doc  .
define variable l as logical   no-undo .




def var v-ind           as integer   no-undo .

def var Log-Res1         as logical   no-undo .
def var Log-Res2         as logical   no-undo .

def buffer object for ub.clients .

define variable v-continue as logical   no-undo .
assign
  v-continue = true
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel Btn_OK b-help IMAGE-1 v-sale-base ~
v-sale-rubl v-sale-base-doc v-sale-rubl-doc Val-BruttoSaleSum ~
Rubl-BruttoSaleSum Val-NettoSaleSum Rubl-NettoSaleSum Val-crsa-doc ~
Rubl-crsa-doc Val-DiscntSum Rubl-DiscntSum Val-CostSum Rubl-CostSum ~
Val-Effect Rubl-Effect NDS-Val tg-vat-base NDS-Rubl tg-vat-rubl Discnt-PC ~
TorgPred Up-PC Operator PayType Kladov Kurs IspName Our-Obj Nums ps ~
Nums-doc ValText SumText RubText
&Scoped-Define DISPLAYED-OBJECTS v-sale-base v-sale-rubl v-sale-base-doc ~
v-sale-rubl-doc Val-BruttoSaleSum Rubl-BruttoSaleSum Val-NettoSaleSum ~
Rubl-NettoSaleSum Val-crsa-doc Rubl-crsa-doc Val-DiscntSum Rubl-DiscntSum ~
Val-CostSum Rubl-CostSum Val-Effect Rubl-Effect NDS-Val tg-vat-base ~
NDS-Rubl tg-vat-rubl Discnt-PC TorgPred Up-PC Operator PayType Kladov Kurs ~
IspName Our-Obj Nums ps Nums-doc ValText SumText RubText

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "В&ыход":L
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK
     LABEL "&Выполнить ":L
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE RubText AS CHARACTER FORMAT "X(256)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE 12.88 BY .83
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE SumText AS CHARACTER FORMAT "X(256)":U INITIAL "Суммы"
      VIEW-AS TEXT
     SIZE 7.88 BY .83 NO-UNDO.

DEFINE VARIABLE ValText AS CHARACTER FORMAT "X(256)":U INITIAL "ВАЛЮТНЫЕ :"
      VIEW-AS TEXT
     SIZE 12.88 BY .83
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "cmp/blank":U
     SIZE 36.38 BY 11.29.

DEFINE VARIABLE Discnt-PC AS LOGICAL INITIAL no
     LABEL "Процент скидки"
     VIEW-AS TOGGLE-BOX
     SIZE 22.13 BY .75 NO-UNDO.

DEFINE VARIABLE IspName AS LOGICAL INITIAL no
     LABEL "Исполнитель"
     VIEW-AS TOGGLE-BOX
     SIZE 21.63 BY .75 NO-UNDO.

DEFINE VARIABLE Kladov AS LOGICAL INITIAL no
     LABEL "Кладовщик"
     VIEW-AS TOGGLE-BOX
     SIZE 14.63 BY .75 NO-UNDO.

DEFINE VARIABLE Kurs AS LOGICAL INITIAL no
     LABEL "Курс"
     VIEW-AS TOGGLE-BOX
     SIZE 8.63 BY .75 NO-UNDO.

DEFINE VARIABLE NDS-Rubl AS LOGICAL INITIAL no
     LABEL "НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 8.63 BY .75 NO-UNDO.

DEFINE VARIABLE NDS-Val AS LOGICAL INITIAL no
     LABEL "НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 8 BY .75 NO-UNDO.

DEFINE VARIABLE Nums AS LOGICAL INITIAL no
     LABEL "Количество"
     VIEW-AS TOGGLE-BOX
     SIZE 16.38 BY .75 NO-UNDO.

DEFINE VARIABLE Nums-doc AS LOGICAL INITIAL no
     LABEL "Количество (док)"
     VIEW-AS TOGGLE-BOX
     SIZE 21.5 BY .75 NO-UNDO.

DEFINE VARIABLE Operator AS LOGICAL INITIAL no
     LABEL "Оператор"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .75 NO-UNDO.

DEFINE VARIABLE Our-Obj AS LOGICAL INITIAL no
     LABEL "Название своего объекта"
     VIEW-AS TOGGLE-BOX
     SIZE 29.25 BY .75 NO-UNDO.

DEFINE VARIABLE PayType AS LOGICAL INITIAL no
     LABEL "Вид оплаты"
     VIEW-AS TOGGLE-BOX
     SIZE 19.25 BY .75 NO-UNDO.

DEFINE VARIABLE ps AS LOGICAL INITIAL no
     LABEL "Примечание"
     VIEW-AS TOGGLE-BOX
     SIZE 29.25 BY .75 NO-UNDO.

DEFINE VARIABLE Rubl-BruttoSaleSum AS LOGICAL INITIAL no
     LABEL "Продажных цен ( без скидки )"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 NO-UNDO.

DEFINE VARIABLE Rubl-CostSum AS LOGICAL INITIAL no
     LABEL "Учетных цен"
     VIEW-AS TOGGLE-BOX
     SIZE 17.25 BY .75 NO-UNDO.

DEFINE VARIABLE Rubl-crsa-doc AS LOGICAL INITIAL no
     LABEL "Продажных цен (док)"
     VIEW-AS TOGGLE-BOX
     SIZE 31.38 BY .75 NO-UNDO.

DEFINE VARIABLE Rubl-DiscntSum AS LOGICAL INITIAL no
     LABEL "Скидок"
     VIEW-AS TOGGLE-BOX
     SIZE 10.63 BY .75 NO-UNDO.

DEFINE VARIABLE Rubl-Effect AS LOGICAL INITIAL no
     LABEL "Эффективности"
     VIEW-AS TOGGLE-BOX
     SIZE 20.88 BY .75 NO-UNDO.

DEFINE VARIABLE Rubl-NettoSaleSum AS LOGICAL INITIAL no
     LABEL "Продажных цен ( со скидкой )"
     VIEW-AS TOGGLE-BOX
     SIZE 31.38 BY .75 NO-UNDO.

DEFINE VARIABLE tg-vat-base AS LOGICAL INITIAL no
     LABEL "по ставкам"
     VIEW-AS TOGGLE-BOX
     SIZE 13.5 BY .83 NO-UNDO.

DEFINE VARIABLE tg-vat-rubl AS LOGICAL INITIAL no
     LABEL "по ставкам"
     VIEW-AS TOGGLE-BOX
     SIZE 13.5 BY .83 NO-UNDO.

DEFINE VARIABLE TorgPred AS LOGICAL INITIAL no
     LABEL "Торговый представитель"
     VIEW-AS TOGGLE-BOX
     SIZE 27.13 BY .75 NO-UNDO.

DEFINE VARIABLE Up-PC AS LOGICAL INITIAL no
     LABEL "Процент фактической наценки"
     VIEW-AS TOGGLE-BOX
     SIZE 33.63 BY .75 NO-UNDO.

DEFINE VARIABLE v-sale-base AS LOGICAL INITIAL no
     LABEL "Цен документа"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 NO-UNDO.

DEFINE VARIABLE v-sale-base-doc AS LOGICAL INITIAL no
     LABEL "Учет.Цен (док)"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 NO-UNDO.

DEFINE VARIABLE v-sale-rubl AS LOGICAL INITIAL no
     LABEL "Цен документа"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 NO-UNDO.

DEFINE VARIABLE v-sale-rubl-doc AS LOGICAL INITIAL no
     LABEL "Учет.Цен (док)"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 NO-UNDO.

DEFINE VARIABLE Val-BruttoSaleSum AS LOGICAL INITIAL no
     LABEL "Продажных цен ( без скидки )"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 NO-UNDO.

DEFINE VARIABLE Val-CostSum AS LOGICAL INITIAL no
     LABEL "Учетных цен"
     VIEW-AS TOGGLE-BOX
     SIZE 18.63 BY .75 NO-UNDO.

DEFINE VARIABLE Val-crsa-doc AS LOGICAL INITIAL no
     LABEL "Продажных цен (док)"
     VIEW-AS TOGGLE-BOX
     SIZE 31.38 BY .75 NO-UNDO.

DEFINE VARIABLE Val-DiscntSum AS LOGICAL INITIAL no
     LABEL "Скидок"
     VIEW-AS TOGGLE-BOX
     SIZE 10.63 BY .75 NO-UNDO.

DEFINE VARIABLE Val-Effect AS LOGICAL INITIAL no
     LABEL "Эффективности"
     VIEW-AS TOGGLE-BOX
     SIZE 20.75 BY .75 NO-UNDO.

DEFINE VARIABLE Val-NettoSaleSum AS LOGICAL INITIAL yes
     LABEL "Продажных цен ( со скидкой )"
     VIEW-AS TOGGLE-BOX
     SIZE 31.38 BY .75 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     Btn_Cancel AT ROW 1 COL 1
     Btn_OK AT ROW 1 COL 13
     b-help AT ROW 1 COL 66
     v-sale-base AT ROW 3.58 COL 4.5
     v-sale-rubl AT ROW 3.58 COL 40.63
     v-sale-base-doc AT ROW 4.38 COL 4.5
     v-sale-rubl-doc AT ROW 4.38 COL 40.63
     Val-BruttoSaleSum AT ROW 5.67 COL 4.5
     Rubl-BruttoSaleSum AT ROW 5.67 COL 40.88
     Val-NettoSaleSum AT ROW 6.5 COL 4.5
     Rubl-NettoSaleSum AT ROW 6.5 COL 40.88
     Val-crsa-doc AT ROW 7.29 COL 4.5
     Rubl-crsa-doc AT ROW 7.29 COL 41
     Val-DiscntSum AT ROW 8.79 COL 4.5
     Rubl-DiscntSum AT ROW 8.79 COL 40.88
     Val-CostSum AT ROW 9.58 COL 4.5
     Rubl-CostSum AT ROW 9.58 COL 40.88
     Val-Effect AT ROW 10.38 COL 4.5
     Rubl-Effect AT ROW 10.38 COL 40.88
     NDS-Val AT ROW 11.17 COL 4.5
     tg-vat-base AT ROW 11.17 COL 14
     NDS-Rubl AT ROW 11.17 COL 40.88
     tg-vat-rubl AT ROW 11.17 COL 58
     Discnt-PC AT ROW 13.21 COL 4.5
     TorgPred AT ROW 13.21 COL 41.13
     Up-PC AT ROW 14.13 COL 4.5
     Operator AT ROW 14.13 COL 41.13
     PayType AT ROW 15 COL 4.5
     Kladov AT ROW 15 COL 41.13
     Kurs AT ROW 15.88 COL 4.5
     IspName AT ROW 15.88 COL 41.13
     Our-Obj AT ROW 16.83 COL 41.13
     Nums AT ROW 17.17 COL 4.5
     ps AT ROW 17.75 COL 41
     Nums-doc AT ROW 18 COL 4.5
     ValText AT ROW 2.42 COL 14.75 COLON-ALIGNED NO-LABEL
     SumText AT ROW 2.42 COL 41.88 COLON-ALIGNED NO-LABEL
     RubText AT ROW 2.42 COL 51.13 COLON-ALIGNED NO-LABEL
     "Суммы" VIEW-AS TEXT
          SIZE 7 BY .83 AT ROW 2.42 COL 8.88
          FGCOLOR 0
     IMAGE-1 AT ROW 1.96 COL 39.63
     SPACE(0.11) SKIP(6.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 0 "Параметры отчета по документам":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   UNDERLINE                                                            */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel DLGOKCAN
ON CHOOSE OF Btn_Cancel IN FRAME DLGOKCAN /* Выход */
DO:
    return "NO" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DLGOKCAN
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN /* Выполнить  */
DO:

  def var CurrWidth as integer no-undo .
  def var var-frame-width as integer no-undo .

  assign
    ps
    Nums
    Nums-doc
    Val-BruttoSaleSum
    Rubl-BruttoSaleSum
    Val-NettoSaleSum
    Rubl-NettoSaleSum
    Val-DiscntSum
    Rubl-DiscntSum
    Val-CostSum
    Rubl-CostSum
    Val-Effect
    Rubl-Effect
    Discnt-PC
    TorgPred
    Up-PC
    Operator
    PayType
    Kladov
    Kurs
    Our-Obj
    IspName
    NDS-Val
    tg-vat-base
    NDS-Rubl
    tg-vat-rubl
    v-sale-base
    v-sale-rubl
    Rubl-crsa-doc
    Val-crsa-doc
    v-sale-base-doc
    v-sale-rubl-doc

  .

    run waitfram-show in this-procedure ( "Обработка документов" ) .


    /* документы не были обработаны - создается список документов */

    if not can-find( first wt-docs ) then do:

        l = qh:get-first() .
        find  t-doc no-lock where rowid(t-doc) =  bh:rowid no-error .
        assign
          v-ind = 0
        .

        DO WHILE available t-doc :
            FIND ub.pay-type NO-LOCK
              WHERE ub.pay-type.obj-code = t-doc.pay-code no-error
              .
            FIND Object NO-LOCK
              WHERE Object.obj-type = t-doc.obj-type
                AND Object.obj-code = t-doc.obj-code
              .
            CREATE wt-docs .
            BUFFER-COPY t-doc TO wt-docs.
            assign
              wt-docs.doc-attr = ( substr( t-doc.doc-type, 1, 1 ) +
                              substr( t-doc.status_ , 1, 1 ) +
                              ( if t-doc.flag_    then "+" else "-" ) +
                              ( if t-doc.internal     then "в" else " " ) )
              wt-docs.pay-name = if not available ub.pay-type then string(t-doc.pay-code) else ub.pay-type.obj-name
              wt-docs.pay-waitdate = wt-docs.fact-date
              wt-docs.Oper_Name = t-doc.creid
              wt-docs.OurObjectName = Object.obj-name
            .
            if base-code <> 0 then   /* т.е. не  " Р У Б " , определение курса : */
                wt-docs.Course = t-doc.base-rate / t-doc.base-scale .

            run rep/get-psn.p ( input t-doc.boss, output wt-docs.Mngr_Name) .
            run rep/get-psn.p ( input t-doc.wrkr, output wt-docs.Wrkr_name) .
            run rep/get-psn.p ( input t-doc.agnt, output wt-docs.Isp-Name ) .

            assign
              v-ind = v-ind + 1
            .
            if ( v-ind modulo 10 ) = 0
            then do:
               run waitfram-show in this-procedure( "Обработка документов : " + string( v-ind ) ) .
            end.

            if v-ind modulo 1000 = 0
            and v-continue <> ?
            then do:
              /* просим подтвердить формирование большого отчета */
              message
                "Уже распечатано строк" v-ind skip
                "Вы желаете продолжить формирование отчета?" skip
                "Yes"    {&tabulation} "Продолжить формирование отчета" skip
                "No"     {&tabulation} "Прервать отчет" skip
                "Cancel" {&tabulation} "Продолжить формирование отчета" skip
                ""       {&tabulation} "и больше не показывать это сообщение" skip
                view-as alert-box question buttons yes-no-cancel update v-continue .
              if v-continue = false then do:
                leave .
              end.
            end.


            l = qh:get-next() .
            find  t-doc no-lock where rowid(t-doc) =  bh:rowid no-error .
        end.
    end.

    run waitfram-hide in this-procedure .
    run rep/docs-rep.p
      ( input "Отчет по документам. " + p-title   /* p-title             */
      , input v-sale-base
      , input v-sale-rubl
      , input Val-crsa-doc
      , input Rubl-crsa-doc
      , input v-sale-base-doc
      , input v-sale-rubl-doc
      , input Val-BruttoSaleSum                   /* pVal-BruttoSaleSum  */
      , input Rubl-BruttoSaleSum                  /* pRubl-BruttoSaleSum */
      , input Val-NettoSaleSum                    /* pVal-NettoSaleSum   */
      , input Rubl-NettoSaleSum                   /* pRubl-NettoSaleSum  */
      , input Val-DiscntSum                       /* pVal-DiscntSum      */
      , input Rubl-DiscntSum                      /* pRubl-DiscntSum     */
      , input Val-CostSum                         /* pVal-CostSum        */
      , input Rubl-CostSum                        /* pRubl-CostSum       */
      , input Val-Effect                          /* pVal-Effect         */
      , input Rubl-Effect                         /* pRubl-Effect        */
      , input Discnt-PC                           /* pDiscnt-PC          */
      , input TorgPred                            /* pTorgPred           */
      , input Up-PC                               /* pUp-PC              */
      , input Operator                            /* pOperator           */
      , input PayType                             /* pPayType            */
      , input Kurs                                /* pKurs               */
      , input Our-Obj                             /* pOur-Obj            */
      , input Kladov                              /* pKladov             */
      , input IspName                             /* pIspName            */
      , input no                                  /* pPayWaitDate        */
      , input NDS-Val                             /* pNDS-Val            */
      , input ( if NDS-Val = yes and Val-CostSum = yes then tg-vat-base else no )
      , input NDS-Rubl                            /* pNDS-Rubl           */
      , input ( if NDS-Rubl = yes and Rubl-CostSum = yes then tg-vat-rubl else no )
      , input Nums                                /* pNums               */
      , input Nums-doc                            /* pNums               */
      , input ps
      , input v-continue                          /* p-continue          */
      , input g#report-num
      , output var-frame-width                     /* p-frame-width       */
      ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME NDS-Rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NDS-Rubl DLGOKCAN
ON VALUE-CHANGED OF NDS-Rubl IN FRAME DLGOKCAN /* НДС */
DO:
    assign
        NDS-Rubl
        Rubl-CostSum
    .
    run manage-tg-vat in this-procedure (
        input no
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME NDS-Val
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NDS-Val DLGOKCAN
ON VALUE-CHANGED OF NDS-Val IN FRAME DLGOKCAN /* НДС */
DO:
    assign
        NDS-Val
        Val-CostSum
    .
    run manage-tg-vat in this-procedure (
        input yes
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rubl-CostSum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rubl-CostSum DLGOKCAN
ON VALUE-CHANGED OF Rubl-CostSum IN FRAME DLGOKCAN /* Учетных цен */
DO:
    assign
        NDS-Rubl
        Rubl-CostSum
    .
    run manage-tg-vat in this-procedure (
        input no
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Val-CostSum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Val-CostSum DLGOKCAN
ON VALUE-CHANGED OF Val-CostSum IN FRAME DLGOKCAN /* Учетных цен */
DO:
    assign
        NDS-Val
        Val-CostSum
    .
    run manage-tg-vat in this-procedure (
        input yes
    ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    RubText = "{&abbr_rublevye_allshift} :".
    RUN enable_UI.
    run manage-tg-vat in this-procedure (
        input yes
    ).
    run manage-tg-vat in this-procedure (
        input no
    ).
    if base-code = 0 then do:
      HIDE
        SumText RubText ValText Rubl-BruttoSaleSum
        Rubl-NettoSaleSum Rubl-DiscntSum
        Rubl-CostSum Rubl-Effect NDS-Rubl
        Rubl-crsa-doc
        v-sale-Rubl  v-sale-Rubl-doc
        tg-vat-rubl
        in frame {&frame-name} .
    end.
    else do:
      HIDE IMAGE-1    in frame {&frame-name} .
    end.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_document-reports-sale_print':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      false
      Log-Res1
    }
    if not Log-Res1 then do:
      DISABLE
        Nums Val-BruttoSaleSum Rubl-BruttoSaleSum Val-NettoSaleSum
        Rubl-NettoSaleSum Val-DiscntSum Rubl-DiscntSum
        Discnt-PC TorgPred Up-PC Operator
        PayType Kladov Kurs Our-Obj IspName
        WITH FRAME DLGOKCAN.
    end.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_document-reports-cost_print':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      false
      Log-Res2
    }
    if not Log-Res2 then do:
      DISABLE
        Rubl-CostSum Val-CostSum Val-Effect Rubl-Effect
        WITH FRAME DLGOKCAN.
    end.

    if not ( Log-Res1 OR Log-Res2 ) then do:
      message
        "У Вас недостаточно ПРАВ" skip
        "для выполнения данного действия." skip
        "Обратитесь к администратору системы."
        view-as alert-box error.
      LEAVE MAIN-BLOCK .
    end.

    if qh:num-results = 0 then do:
      message "Список П У С Т !" view-as alert-box information .
      LEAVE MAIN-BLOCK .
    end.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN  _DEFAULT-ENABLE
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
  DISPLAY v-sale-base v-sale-rubl v-sale-base-doc v-sale-rubl-doc
          Val-BruttoSaleSum Rubl-BruttoSaleSum Val-NettoSaleSum
          Rubl-NettoSaleSum Val-crsa-doc Rubl-crsa-doc Val-DiscntSum
          Rubl-DiscntSum Val-CostSum Rubl-CostSum Val-Effect Rubl-Effect NDS-Val
          tg-vat-base NDS-Rubl tg-vat-rubl Discnt-PC TorgPred Up-PC Operator
          PayType Kladov Kurs IspName Our-Obj Nums ps Nums-doc ValText SumText
          RubText
      WITH FRAME DLGOKCAN.
  ENABLE Btn_Cancel Btn_OK b-help IMAGE-1 v-sale-base v-sale-rubl
         v-sale-base-doc v-sale-rubl-doc Val-BruttoSaleSum Rubl-BruttoSaleSum
         Val-NettoSaleSum Rubl-NettoSaleSum Val-crsa-doc Rubl-crsa-doc
         Val-DiscntSum Rubl-DiscntSum Val-CostSum Rubl-CostSum Val-Effect
         Rubl-Effect NDS-Val tg-vat-base NDS-Rubl tg-vat-rubl Discnt-PC
         TorgPred Up-PC Operator PayType Kladov Kurs IspName Our-Obj Nums ps
         Nums-doc ValText SumText RubText
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-tg-vat DLGOKCAN
PROCEDURE manage-tg-vat :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-is-base as logical          no-undo.

do
on error undo, return error
:
    if p-is-base = no
    then do:
        if NDS-Rubl = yes
        and Rubl-CostSum = yes
        then do:
            assign
                tg-vat-rubl :sensitive in frame {&frame-name} = yes
            .
        end.
        else do:
            assign
                tg-vat-rubl :sensitive in frame {&frame-name} = no
            .
        end.
    end.        /* if p-is-base = no */
    else do:
        if NDS-Val = yes
        and Val-CostSum
        then do:
            assign
                tg-vat-base :sensitive in frame {&frame-name} = yes
            .
        end.
        else do:
            assign
                tg-vat-base :sensitive in frame {&frame-name} = no
            .
        end.
    end.        /* NOT ( if p-is-base = no ) */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME