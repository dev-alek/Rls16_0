/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость (без остатков)

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05


*/

define input parameter x-store-code like ub.clients.obj-code no-undo.
define input parameter x-store-type like ub.clients.obj-type no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter classify  as int no-undo.
define input parameter Itog      as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость (без остатков)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ rep/lkp-font.i }

define buffer clients-p for ub.clients .
define buffer alt-ot-line for ub.ot-line .
define buffer crsa-ot-line for ub.ot-line .
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .


define work-table wt no-undo
field doc-code like ub.ot-line.doc-code
.
define buffer buf-tdedt for tdedt  .
/*поля формы*/
define variable     F-fact-date      as char no-undo.
define variable  Fact-order-1 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.

define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.


define variable  Fact-order-2 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2       like ub.stk-tot.sum-rubl   no-undo.

define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.

define variable  Quantity3    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast5       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast6       like ub.stk-tot.sum-rubl   no-undo.

define variable  Coast3         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4         like ub.stk-tot.sum-rubl   no-undo.
define variable  find-str       as char no-undo.
define variable  temp-find-str  like find-str NO-UNDO.
define variable  tPrintRubl    as log no-undo .
define variable  startdate     as date no-undo.
define variable  enddate       as date no-undo.
define variable xTog-obj as logical no-undo init false  .

define stream  OutStream .

define variable    ObjName           as char no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as  char     no-undo.

define variable tot_tqnty as decimal format "->>>,>>>,>>9.99" no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

define variable    iI        as   integer no-undo.
define variable    i         as   integer no-undo .
define variable    j         as   integer no-undo.
define variable    K         as   integer no-undo.
define variable    acc-i     as   integer no-undo .
define variable    acc-j     as   integer no-undo.
define variable   v-vat_pc   as   char no-undo.
define variable   v-vat_sum  as   decimal format "->>>,>>>,>>9.99" no-undo.
define variable   v-slt_pc   as   char no-undo.
define variable   v-slt_sum  as   decimal format "->>>,>>>,>>9.99" no-undo.
define variable tmpact as decimal format "->>>>>>>>9.999" no-undo.
/* Local Variable Definitions ---                                       */

define variable stat     as log no-undo .
define variable InpError as log no-undo .

define variable rid-list as character no-undo .
define variable curr-rep as char no-undo.

define variable listtd as char no-undo.
define variable NO-PRISE as logical no-undo  init true .
define variable Discnt-base# as decimal init 0  no-undo .
define variable n-nn as integer init 0 no-undo .
define variable n-nm as integer init 0 no-undo .
define variable n-no as integer init 0 no-undo .
define variable var-client as character no-undo .

define variable  nn                as character no-undo .
define variable    f-artic         as character no-undo .
define variable    f-gds-name      as character no-undo .
define variable    f-qnty          as decimal no-undo .
define variable    f-qnty1         as decimal no-undo .
define variable    f-qnty2         as decimal no-undo .
define variable    f-cost-sum      as decimal  no-undo .
define variable    f-cost-vat      as decimal no-undo .
define variable    f-cost-sum-novat as decimal no-undo .
define variable    f-sale-sum       as decimal no-undo .
define variable    f-sale-other     as decimal no-undo .
define variable    f-sale-vat       as decimal no-undo .
define variable    f-sale-slt       as decimal no-undo .
define variable    f-disc           as decimal no-undo .
define variable    f-disc-prc       as decimal no-undo .
define variable    f-crsa-sum       as decimal no-undo .
define variable    f-crsa-sum1      as decimal no-undo .
define variable    f-crsa-sum2      as decimal no-undo .

define variable    c-nn               as WIDGET-HANDLE no-undo .
define variable    c-f-artic          as WIDGET-HANDLE no-undo .
define variable    c-f-gds-name       as WIDGET-HANDLE no-undo .
define variable    c-f-qnty           as WIDGET-HANDLE no-undo .
define variable    c-f-qnty1          as WIDGET-HANDLE no-undo .
define variable    c-f-qnty2          as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum       as WIDGET-HANDLE no-undo .
define variable    c-f-cost-vat       as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum-novat as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum       as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-vat       as WIDGET-HANDLE no-undo .
define variable    c-f-sale-slt       as WIDGET-HANDLE no-undo .
define variable    c-f-disc           as WIDGET-HANDLE no-undo .
define variable    c-f-disc-prc       as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum       as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum1      as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum2      as WIDGET-HANDLE no-undo .


define variable    l1f-artic         as character no-undo .
define variable    l1f-gds-name      as character no-undo .
define variable    l1f-qnty          as character no-undo .
define variable    l1f-qnty1         as character no-undo .
define variable    l1f-qnty2         as character no-undo .
define variable    l1f-cost-sum      as character no-undo .
define variable    l1f-cost-vat      as character no-undo .
define variable    l1f-cost-sum-novat as character no-undo .
define variable    l1f-sale-sum       as character no-undo .
define variable    l1f-sale-other     as character no-undo .
define variable    l1f-sale-vat       as character no-undo .
define variable    l1f-sale-slt       as character no-undo .
define variable    l1f-disc           as character no-undo .
define variable    l1f-disc-prc       as character no-undo .
define variable    l1f-crsa-sum       as character no-undo .
define variable    l1f-crsa-sum1      as character no-undo .
define variable    l1f-crsa-sum2      as character no-undo .

define variable    l2f-artic         as character no-undo .
define variable    l2f-gds-name      as character no-undo .
define variable    l2f-qnty          as character no-undo .
define variable    l2f-qnty1         as character no-undo .
define variable    l2f-qnty2         as character no-undo .
define variable    l2f-cost-sum      as character no-undo .
define variable    l2f-cost-vat      as character no-undo .
define variable    l2f-cost-sum-novat as character no-undo .
define variable    l2f-sale-sum       as character no-undo .
define variable    l2f-sale-other     as character no-undo .
define variable    l2f-sale-vat       as character no-undo .
define variable    l2f-sale-slt       as character no-undo .
define variable    l2f-disc           as character no-undo .
define variable    l2f-disc-prc       as character no-undo .
define variable    l2f-crsa-sum       as character no-undo .
define variable    l2f-crsa-sum1      as character no-undo .
define variable    l2f-crsa-sum2      as character no-undo .

/*суммы по обьектам*/
define variable    ff-qnty         as decimal no-undo .
define variable    ff-cost-sum     as decimal no-undo .
define variable    ff-cost-vat     as decimal no-undo .
define variable    ff-cost-sum-novat as decimal no-undo .
define variable    ff-sale-sum       as decimal no-undo .
define variable    ff-sale-other     as decimal no-undo .
define variable    ff-sale-vat       as decimal no-undo .
define variable    ff-sale-slt       as decimal no-undo .
define variable    ff-disc           as decimal no-undo .
define variable    ff-disc-prc       as decimal no-undo .
define variable    ff-crsa-sum       as decimal no-undo .

define variable    tf-qnty         as decimal no-undo .
define variable    tf-cost-sum     as decimal no-undo .
define variable    tf-cost-vat     as decimal no-undo .
define variable    tf-cost-sum-novat as decimal no-undo .
define variable    tf-sale-sum       as decimal no-undo .
define variable    tf-sale-other     as decimal no-undo .
define variable    tf-sale-vat       as decimal no-undo .
define variable    tf-sale-slt       as decimal no-undo .
define variable    tf-disc           as decimal no-undo .
define variable    tf-disc-prc       as decimal no-undo .
define variable    tf-crsa-sum       as decimal no-undo .

define variable L1 as character no-undo .
define variable L2 as character no-undo .


/* ************** frame для формы **************** */
&scop l-frame 300
&scop l-frame-1 198
{ rep/repfrm.i def }
{ rep/repfrm.i on 100 }
{ rep/r-ob-cr.i def }

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=6  l-col-format= "X(6)"         l-col-lable="N/N"                      . { rep/r-ob-cr.i cr 1  nn               }
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"        l-col-lable="Артикул"                  . { rep/r-ob-cr.i cr 2  f-artic          }
Assign l-col-type="CHARACTER" l-col-len=32 l-col-format= "X(32)"        l-col-lable="Название товара"          . { rep/r-ob-cr.i cr 3  f-gds-name       }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>>>9.<<<"  l-col-lable="Количество "          . { rep/r-ob-cr.i cr 4  f-qnty           }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>9.99"  l-col-lable="Учетные цены с НДС"    . { rep/r-ob-cr.i cr 5  f-cost-sum       }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>9.99"  l-col-lable="НДС от учетной цены"   . { rep/r-ob-cr.i cr 6  f-cost-vat       }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>9.99"  l-col-lable="Учетные цены  без НДС ". { rep/r-ob-cr.i cr 7  f-cost-sum-novat }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>9.99"  l-col-lable="Цены документа"        . { rep/r-ob-cr.i cr 8  f-sale-sum       }
Assign l-col-type="DECIMAL" l-col-len=10 l-col-format="->>>>>>9.99"  l-col-lable="В т.ч. скидки"         . { rep/r-ob-cr.i cr 9  f-sale-other     }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>9.99"  l-col-lable="НДС от цены документа" . { rep/r-ob-cr.i cr 10 f-sale-vat       }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>9.99"  l-col-lable="НП от цены документа"  . { rep/r-ob-cr.i cr 11 f-sale-slt       }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>9.99"  l-col-lable="Наценка "              . { rep/r-ob-cr.i cr 12 f-disc           }
Assign l-col-type="DECIMAL" l-col-len=7 l-col-format="->>>>9.<<"  l-col-lable="% торг. наценки"   . { rep/r-ob-cr.i cr 13 f-disc-prc       }
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>9.99"  l-col-lable="Сумма продажных цен"   . { rep/r-ob-cr.i cr 14 f-crsa-sum       }

/*===================================================================================================================*/
   FIND first ub.clients where x-store-type = ub.clients.obj-type AND
            x-store-code = ub.clients.obj-code no-lock no-error.
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".
     assign
        i             = 0
        startdate     = x-date-start
        enddate       = x-date-end
        PayType       = x-SET_PAY_TYPE
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-fdec.i }
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .

   NO-PRISE = true .
  if var-report-r-b = "rubl"  Then do:
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
   end.
  else do:
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .
  end .

  { cmp/open-out.i stream OutStream  " "  ReportPageHeight}
  FORM with FRAME Zapas .

  { rep/r-formh.i x(198) {&dos_CW_2}}
   Line = fill("-", 198).
  run CalcItog in this-procedure. /*Поиск fact-order*/
  run Print-Header in this-procedure.   /*Печать шапки*/
  CAse classify :
    when 1 then do:
      run Foreach1 in this-procedure.    /*Обработка строк*/
    end.
    when 2 then do:
      run Foreach2 in this-procedure.    /*Обработка строк*/
    end.
    when 3 then do:
      run Foreach3 in this-procedure.    /*Обработка строк*/
    end.
    when 4 then do:
      run Foreach4 in this-procedure.    /*Обработка строк*/
    end.
    when 5 then do:
      run Foreach5 in this-procedure.    /*Обработка строк*/
    end.
  End case.


  HIDE stream OutStream FRAME BottomFrame .   /*загасить фрайм "продолжение на сл стр"*/
  run  Print-footer in this-procedure.         /*Печать подвала */
  HIDE STREAM OutStream FRAME Zapas .       /*загасить главный фрайм*/
  HIDE   STREAM OutStream FRAME top-Frame .
  DELETE WIDGET-POOL "My-pool".
  Output stream OutStream close.
  {&CloseExcel}
  { rep/repfrm.i off}
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .


  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .

END PROCEDURE.

PROCEDURE print-header :
   PUT stream OutStream  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
         AT 10 format "X(85)" SKIP(2)
         REPORTNAME
         AT 10  format "X(100)" skip.
     Repeat i = 1 to NUM-ENTRIES(STR1,chr(10)) :
        PUT stream OutStream  Entry(i,STR1,chr(10))  AT 1 format "X(100)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR2,chr(10)) :
        PUT stream OutStream  Entry(i,STR2,chr(10))  AT 1 format "X(100)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR3,chr(10)) :
        PUT stream OutStream  Entry(i,STR3,chr(10))  AT 1 format "X(100)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR4,chr(10)) :
        PUT stream OutStream  Entry(i,STR4,chr(10))  AT 1 format "X(100)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
        PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(100)" SKIP.
     End.
    i=0.
    run rep/extitle.p (1) .

  display STREAM OutStream     with frame top-Frame .

   END PROCEDURE.


PROCEDURE Print-Footer :
  /* выводим завершающую информацию, свидетельствующую о том, что отчет завершен */
  /* run on-same-page in this-procedure (input 6) . */
  /* делаем footer невидимым, чтобы он не напечатался на последней странице */
  /*
      hide stream OutStream frame bottomframe .
  */
  run on-same-page in this-procedure (input 1) .
PUT STREAM OutStream " " SKIP(3)
     SKIP .
   run on-same-page in this-procedure (input 1) .
   END PROCEDURE.

PROCEDURE U-LINE :
define variable ff as character no-undo .
if itog = false
Then do:
ff = fill("-",40).
      { rep/r-ob-cr.i disp  ff                nn}
      { rep/r-ob-cr.i disp  ff                f-artic}
      { rep/r-ob-cr.i disp  ff                f-gds-name}
      { rep/r-ob-cr.i full  ff               f-crsa-sum }
      { rep/r-ob-cr.i full  ff               f-sale-sum }
      { rep/r-ob-cr.i full  ff               f-cost-sum }
      { rep/r-ob-cr.i full  ff               f-cost-vat }
      { rep/r-ob-cr.i full  ff               f-cost-sum-novat}
      { rep/r-ob-cr.i full  ff               f-sale-vat }
      { rep/r-ob-cr.i full  ff               f-sale-slt }
      { rep/r-ob-cr.i full  ff               f-sale-other}
      { rep/r-ob-cr.i full  ff               f-disc }
      { rep/r-ob-cr.i full  ff               f-disc-prc}
      { rep/r-ob-cr.i full  ff               f-qnty     }
  Display stream OutStream  with FRAME Zapas no-error .
  DOWN stream OutStream  with FRAME Zapas .
      { rep/r-ob-cr.i sfull f-crsa-sum }
      { rep/r-ob-cr.i sfull f-sale-sum }
      { rep/r-ob-cr.i sfull f-cost-sum }
      { rep/r-ob-cr.i sfull f-cost-vat }
      { rep/r-ob-cr.i sfull f-cost-sum-novat}
      { rep/r-ob-cr.i sfull f-sale-vat }
      { rep/r-ob-cr.i sfull f-sale-slt }
      { rep/r-ob-cr.i sfull f-sale-other}
      { rep/r-ob-cr.i sfull f-disc }
      { rep/r-ob-cr.i sfull f-disc-prc}
      { rep/r-ob-cr.i sfull f-qnty     }

End.

END PROCEDURE.

PROCEDURE CalcItog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xTog-obj ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input xTog-obj ,

        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).
/*эти не нужны*/
          Quantity1  = 0.
          Coast_R1   = 0.
          Coast_V1   = 0.
          VAT_R1     = 0.
          VAT_V1     = 0.

END PROCEDURE.
PROCEDURE foreach1 :
{ rep/r-noost1.i no-classify "''" "''" 0 {1} {2} }
END PROCEDURE.

PROCEDURE foreach2 :
{ rep/r-noost1.i prod-code  "''" "''"  0  {1}  {2} }
END PROCEDURE.

PROCEDURE foreach3 :
{ rep/r-noost1.i vat-pc {&arh-cost} {&arh-VAT} 1 {1}  {2}  }
END PROCEDURE.

PROCEDURE foreach4 :
{ rep/r-noost1.i vat-pc {&arh-sale} "''"  1  {1} {2}  }
END PROCEDURE.

PROCEDURE foreach5 :
{ rep/r-noost1.i vat-pc {&arh-sale} "''"  2  {1} {2}  }
END PROCEDURE.


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
{ rep/ostatok.i }
/* $Workfile$ e n d */