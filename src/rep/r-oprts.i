/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет оборотка по признакам

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

*/
define temp-table tt-season no-undo like ub.season.

define input parameter x-store-code like ub.clients.obj-code no-undo.
define input parameter x-store-type like ub.clients.obj-type no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter classify  as int no-undo.
define input parameter Itog as logical no-undo .
define input parameter x-zero as logical no-undo .
define input parameter table for tt-season .


define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет оборотка по признакам".
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  " "  100  }
{ cmp/r-pril.i   }
{ rep/rep-bt.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ rep/procobor.i func-vat }
{ rep/ostatok.i }
{ rep/lkp-font.i }
define buffer clients-p for ub.clients .
define buffer alt-ot-line for ub.ot-line .
define buffer crsa-ot-line for ub.ot-line .

define variable v-var as character no-undo .
define variable v-price-sale as decimal no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable t-qnty as decimal   no-undo .
define variable t-qnty-all as decimal   no-undo .



define work-table temp-doc-code no-undo
  field doc-code like ub.ot-line.doc-code
  field ext-doc-type like ub.ot-line.ext-doc-type
  field si as integer
  field si2 as integer
  .
define work-table TEMP-DOC-CODE-all no-undo
  field doc-code like ub.ot-line.doc-code
  field EXT-doc-type like ub.ot-line.EXT-doc-type
  field si as integer
  field si2 as integer
  .


define buffer buf-tdedt for tdedt  .
/*поля формы*/
define variable     F-fact-date      as char no-undo.

define variable  Fact-order-1 like stk-tot.Fact-order no-undo.
define variable  Quantity1    like stk-tot.fact-qnty  no-undo.
define variable  Coast1       like stk-tot.sum-rubl   no-undo.
define variable  Coast_R1       like stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like stk-tot.sum-rubl   no-undo.
define variable  SLT_R1         like stk-tot.sum-rubl   no-undo.
define variable  SLT_V1         like stk-tot.sum-rubl   no-undo.


define variable  Coast_R2       like stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like stk-tot.sum-rubl   no-undo.


define variable  Fact-order-2 like stk-tot.Fact-order no-undo.
define variable  Quantity2    like stk-tot.fact-qnty  no-undo.
define variable  Coast2       like stk-tot.sum-rubl   no-undo.

define variable  Quantity    like stk-tot.fact-qnty  no-undo.
define variable  Coast       like stk-tot.sum-rubl   no-undo.

define variable  Quantity3    like stk-tot.fact-qnty  no-undo.
define variable  Coast5       like stk-tot.sum-rubl   no-undo.
define variable  Coast6       like stk-tot.sum-rubl   no-undo.

define variable  Coast3         like stk-tot.sum-rubl   no-undo.
define variable  Coast4         like stk-tot.sum-rubl   no-undo.
define variable  find-str       as char no-undo.
define variable  temp-find-str  like find-str NO-UNDO.
define variable  tPrintRubl    as log no-undo .
define variable  startdate     as date no-undo.
define variable  enddate       as date no-undo.
define variable xTog-obj as logical no-undo init true .

define stream  OutStream .

define   variable    ObjName           as char no-undo.
define   variable    PayType           as   integer no-undo.
define   variable    ValType           as   integer no-undo.
define   variable    Line              as  char     no-undo.


define variable tot_tqnty as decimal format "->>>,>>>,>>9.99" no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

define   variable    iI        as   integer no-undo.
define   variable    i         as   integer no-undo .
define   variable    j         as   integer no-undo.
define   variable    K         as   integer no-undo.
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
define variable  Prtroot        like ub.gds-prt.node-code no-undo.


define variable    nn              as character no-undo .
define variable    f-artic         as character no-undo .
define variable    f-b-code        as character no-undo .
define variable    f-gds-name      as character no-undo .
/*оборот выборочно */
define variable    f-qnty          as decimal no-undo .
define variable    f-cost-sum      as decimal no-undo .
define variable    f-sale-sum      as decimal no-undo .
define variable    f-sale-other    as decimal no-undo .
define variable    f-crsa-sum      as decimal no-undo .
/*оборот весь */
define variable    f-qnty-all          as decimal no-undo .
define variable    f-cost-sum-all      as decimal no-undo .
define variable    f-sale-sum-all      as decimal no-undo .
define variable    f-sale-other-all    as decimal no-undo .
define variable    f-crsa-sum-all      as decimal no-undo .
/*остатки */
define variable    f-qnty-o          as decimal no-undo .
define variable    f-cost-sum-o      as decimal no-undo .
define variable    f-crsa-sum-o      as decimal no-undo .

define variable    c-nn             as WIDGET-HANDLE no-undo .
define variable    c-f-artic        as WIDGET-HANDLE no-undo .
define variable    c-f-b-code       as WIDGET-HANDLE no-undo .
define variable    c-f-gds-name     as WIDGET-HANDLE no-undo .
define variable    c-f-qnty         as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other   as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-qnty-all     as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum-all as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum-all as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum-all as WIDGET-HANDLE no-undo .
define variable    c-f-qnty-o       as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum-o   as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum-o   as WIDGET-HANDLE no-undo .

define variable    p-qnty          as decimal no-undo .
define variable    p-cost-sum      as decimal no-undo .
define variable    p-sale-sum      as decimal no-undo .
define variable    p-sale-other    as decimal no-undo .
define variable    p-crsa-sum      as decimal no-undo .
/*оборот весь */
define variable    p-qnty-all          as decimal no-undo .
define variable    p-cost-sum-all      as decimal no-undo .
define variable    p-sale-sum-all      as decimal no-undo .
define variable    p-sale-other-all    as decimal no-undo .
define variable    p-crsa-sum-all      as decimal no-undo .
define variable    p-qnty-o          as decimal no-undo .
define variable    p-cost-sum-o      as decimal no-undo .
define variable    p-crsa-sum-o      as decimal no-undo .


define variable    l1f-artic       as character no-undo .
define variable    l1f-b-code      as character no-undo .
define variable    l1f-gds-name    as character no-undo .
define variable    l1f-qnty        as character no-undo .
define variable    l1f-cost-sum    as character no-undo .
define variable    l1f-sale-sum    as character no-undo .
define variable    l1f-sale-other  as character no-undo .
define variable    l1f-crsa-sum     as character no-undo .
define variable    l1f-qnty-all     as character no-undo .
define variable    l1f-cost-sum-all as character no-undo .
define variable    l1f-sale-sum-all as character no-undo .
define variable    l1f-crsa-sum-all as character no-undo .
define variable    l1f-qnty-o       as character no-undo .
define variable    l1f-cost-sum-o   as character no-undo .
define variable    l1f-crsa-sum-o   as character no-undo .

define variable    l2f-artic         as character no-undo .
define variable    l2f-b-code        as character no-undo .
define variable    l2f-gds-name      as character no-undo .
define variable    l2f-qnty          as character no-undo .
define variable    l2f-cost-sum      as character no-undo .
define variable    l2f-sale-sum      as character no-undo .
define variable    l2f-sale-other    as character no-undo .
define variable    l2f-crsa-sum      as character no-undo .
define variable    l2f-qnty-all       as character no-undo .
define variable    l2f-cost-sum-all   as character no-undo .
define variable    l2f-sale-sum-all   as character no-undo .
define variable    l2f-crsa-sum-all   as character no-undo .
define variable    l2f-qnty-o         as character no-undo .
define variable    l2f-cost-sum-o     as character no-undo .
define variable    l2f-crsa-sum-o     as character no-undo .



/*суммы по объектам*/
define variable    ff-f-qnty         as decimal no-undo .
define variable    ff-f-cost-sum     as decimal no-undo .
define variable    ff-f-sale-sum     as decimal no-undo .
define variable    ff-f-sale-other   as decimal no-undo .
define variable    ff-f-crsa-sum     as decimal no-undo .

define variable    ff-f-qnty-all     as decimal no-undo .
define variable    ff-f-cost-sum-all as decimal no-undo .
define variable    ff-f-sale-sum-all as decimal no-undo .
define variable    ff-f-crsa-sum-all as decimal no-undo .

define variable    ff-f-qnty-o       as decimal no-undo .
define variable    ff-f-cost-sum-o   as decimal no-undo .
define variable    ff-crsa-sum-o     as decimal no-undo .

define variable    tf-f-qnty        as decimal no-undo .
define variable    tf-f-cost-sum    as decimal no-undo .
define variable    tf-f-sale-sum     as decimal no-undo .
define variable    tf-f-sale-other   as decimal no-undo .
define variable    tf-f-crsa-sum     as decimal no-undo .
define variable    tf-f-qnty-all     as decimal no-undo .
define variable    tf-f-cost-sum-all as decimal no-undo .
define variable    tf-f-sale-sum-all as decimal no-undo .
define variable    tf-f-crsa-sum-all as decimal no-undo .
define variable    tf-f-qnty-o       as decimal no-undo .
define variable    tf-f-cost-sum-o   as decimal no-undo .
define variable    tf-crsa-sum-o   as decimal no-undo .
define variable x-time as integer no-undo .
define variable fix-doc-code  like ub.ot-tot.doc-code no-undo .

/* ************** frame для формы **************** */
&scop l-frame 300
&scop l-frame-1 198

{ rep/repfrm.i def}
{ rep/repfrm.i on 100}
{ rep/r-ob3cr.i def 6     " "         "new shared"     }
{ rep/r-ob3cr.i def-cr 1  nn          "new shared"     }
{ rep/r-ob3cr.i def-cr 2  f-b-code  "new shared"       }
{ rep/r-ob3cr.i def-cr 3  f-artic   "new shared"       }
{ rep/r-ob3cr.i def-cr 4  f-gds-name  "new shared"     }
{ rep/r-ob3cr.i def-cr 5  f-qnty      "new shared"     }
{ rep/r-ob3cr.i def-cr 6  f-cost-sum  "new shared"     }
{ rep/r-ob3cr.i def-cr 7  f-sale-sum  "new shared"     }
{ rep/r-ob3cr.i def-cr 8  f-sale-other   "new shared"  }
{ rep/r-ob3cr.i def-cr 9  f-crsa-sum     "new shared"  }
{ rep/r-ob3cr.i def-cr 10 f-qnty-all     "new shared"  }
{ rep/r-ob3cr.i def-cr 11 f-cost-sum-all "new shared"  }
{ rep/r-ob3cr.i def-cr 12 f-crsa-sum-all "new shared"  }
{ rep/r-ob3cr.i def-cr 13   f-qnty-o     "new shared"  }
{ rep/r-ob3cr.i def-cr 14   f-cost-sum-o "new shared"  }
{ rep/r-ob3cr.i def-cr 15   f-crsa-sum-o "new shared"  }
{ rep/r-ob3cr.i def-cr2 16  top-frame    "new shared"  }
{ rep/r-ob3cr.i def-cr2 17  top-frame    "new shared"  }
{ rep/r-ob3cr.i def-cr2 18  top-frame    "new shared"  }
{ rep/r-ob3cr.i def-cr2 19  top-frame    "new shared"  }

run rep/r-in-cr.p
 ( input x-base-type
, input x-base-code
, input-output c-nn
, input-output c-f-artic
, input-output c-f-b-code
, input-output c-f-gds-name
, input-output c-f-qnty
, input-output c-f-cost-sum
, input-output c-f-sale-sum
, input-output c-f-sale-other
, input-output c-f-crsa-sum
, input-output c-f-qnty-all
, input-output c-f-cost-sum-all
, input-output c-f-sale-sum-all
, input-output c-f-crsa-sum-all
, input-output c-f-qnty-o
, input-output c-f-cost-sum-o
, input-output c-f-crsa-sum-o
, input    tPrintRubl
) .

run init-p2 in this-procedure .
run report-execute in this-procedure .
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ trg/prdoclib.i }
{ rep/f-fdec.i   }
{ gbl/dtm.i      }
{ str/prl-vat.i  }
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .

   NO-PRISE = true .
  if var-report-r-b = "rubl"  Then
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
  else
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .


  If ReportPageHeight = 0 then ReportPageHeight = 43 .

  { cmp/open-out.i stream OutStream  " "  ReportPageHeight }
  FORM with FRAME Zapas .

  { rep/r-formh.i x(198) {&dos_CW_2}}
   Line = fill("-", 198).
  run calcitog in this-procedure. /*Поиск fact-order*/
  run print-header in this-procedure.   /*Печать шапки*/
  If x-zero = false then do:
    CAse classify :
      when 5 then do:
        run foreach5 in this-procedure.    /*Обработка строк*/
      end.
      when 6 then do:
        run foreach6 in this-procedure.    /*Обработка строк*/
      end.
      when 7 then do:
        run foreach7 in this-procedure.    /*Обработка строк*/
      end.
    End case.
 End.
 Else do:
    CAse classify :
      when 5 then do:
        run foreach5_1 in this-procedure.    /*Обработка строк*/
      end.
      when 6 then do:
        run foreach6_1 in this-procedure.    /*Обработка строк*/
      end.
      when 7 then do:
        run foreach7_1 in this-procedure.    /*Обработка строк*/
      end.

    End case.

 End.

  HIDE stream OutStream FRAME BottomFrame .   /*загасить фрайм "продолжение на сл стр"*/
  run  print-footer in this-procedure.         /*Печать подвала */
  HIDE STREAM OutStream FRAME Zapas .       /*загасить главный фрайм*/
  HIDE   STREAM OutStream FRAME top-Frame .
  DELETE WIDGET-POOL "My-pool".
  Output stream OutStream close.
  {&CloseExcel}
  { rep/repfrm.i off }
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
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .

END PROCEDURE.

PROCEDURE print-header :
   PUT stream OutStream  string(v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
         AT 50 format "X(85)" SKIP(2)
         REPORTNAME
         AT 35  format "X(100)" skip.
     PUT stream OutStream   "за период с "  + string(x-date-start,"99/99/9999") +
         " по "  + string(x-date-end,"99/99/9999") +
         " дата и время формирования " + cur-time-string-sec()
                                                    AT 35 format "X(160)" SKIP.
     Repeat i = 1 to NUM-ENTRIES(STR2,chr(10)) :
        PUT stream OutStream  Entry(i,STR2,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR3,chr(10)) :
        PUT stream OutStream  Entry(i,STR3,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR4,chr(10)) :
        PUT stream OutStream  Entry(i,STR4,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
        PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(160)" SKIP.
     End.
    i=0.
    run rep/extitle.p (1) .
    display STREAM OutStream     with frame top-Frame .

END PROCEDURE.

PROCEDURE Print-Footer :
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  PUT STREAM OutStream UNFORMATTED " Печать закончена : " + string(v-time,"HH:MM:SS") SKIP.
  &If "{3}"  <> "no-today"  &then
  PUT STREAM OutStream UNFORMATTED " За время формирования отчета были закрыты документы : " SKIP.
  for each ub.trn-doc no-lock where
      ub.trn-doc.status_ = {&fact} and
      ub.trn-doc.flag_= true and
      ub.trn-doc.host-code = v-cntxt-host-code-obj
      by ub.trn-doc.fact-order DESCENDING :
      If ub.trn-doc.fact-order <= fact-order-2 then leave.
      PUT STREAM OutStream  UNFORMATTED ub.trn-doc.doc-code SKIP.
  end.
  &endif
  PUT STREAM OutStream UNFORMATTED " ______________________________________________________" SKIP.
   run on-same-page in this-procedure (input 1) .
END PROCEDURE.

PROCEDURE U-LINE :
define variable ff as character no-undo .
if itog = false
Then do:
ff = fill("-",40).
      { rep/r-ob3cr.i disp  ff  nn             }
      { rep/r-ob3cr.i disp  ff  f-b-code       }
      { rep/r-ob3cr.i disp  ff  f-artic        }
      { rep/r-ob3cr.i disp  ff  f-gds-name     }
      { rep/r-ob3cr.i full  ff  f-qnty         }
      { rep/r-ob3cr.i full  ff  f-cost-sum     }
      { rep/r-ob3cr.i full  ff  f-sale-sum     }
      { rep/r-ob3cr.i full  ff  f-sale-other   }
      { rep/r-ob3cr.i full  ff  f-crsa-sum     }
      { rep/r-ob3cr.i full  ff  f-qnty-all     }
      { rep/r-ob3cr.i full  ff  f-cost-sum-all }
      { rep/r-ob3cr.i full  ff  f-crsa-sum-all }
      { rep/r-ob3cr.i full  ff  f-qnty-o       }
      { rep/r-ob3cr.i full  ff  f-cost-sum-o   }
      { rep/r-ob3cr.i full  ff  f-crsa-sum-o   }

  Display stream OutStream  with FRAME Zapas no-error .
  DOWN stream OutStream  with FRAME Zapas .
      { rep/r-ob3cr.i sfull f-qnty     }
      { rep/r-ob3cr.i sfull f-cost-sum     }
      { rep/r-ob3cr.i sfull f-sale-sum     }
      { rep/r-ob3cr.i sfull f-sale-other   }
      { rep/r-ob3cr.i sfull f-crsa-sum     }
      { rep/r-ob3cr.i sfull f-qnty-all     }
      { rep/r-ob3cr.i sfull f-cost-sum-all }
      { rep/r-ob3cr.i sfull f-crsa-sum-all }
      { rep/r-ob3cr.i sfull f-qnty-o       }
      { rep/r-ob3cr.i sfull f-cost-sum-o   }
      { rep/r-ob3cr.i sfull f-crsa-sum-o   }

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

&If "{3}"  = "no-today"  &then
run ostatok  in this-procedure (
    input x-store-code  ,
    input x-store-type  , x-TOG-Shift,
    input x-date-start ,
    input x-date-end   , x-Shift-Start,x-Shift-End,
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
&else
  for each ub.trn-doc no-lock where
      ub.trn-doc.status_ = {&fact} and
      ub.trn-doc.flag_= true  and
      ub.trn-doc.host-code = v-cntxt-host-code-obj
      by ub.trn-doc.fact-order DESCENDING :
        fact-order-2 = ub.trn-doc.fact-order  .
        leave.
  end.
&Endif
END PROCEDURE.



PROCEDURE foreach5 :
   { rep/r-o-prt3.i no-classify "''" "''" 0 {1} {2} }
END PROCEDURE.

PROCEDURE foreach6 :
   { rep/r-o-prt3.i grp-goods  goods.grp-name "'по группе '"  0  {1}  {2} }
END PROCEDURE.


PROCEDURE foreach7 :
   { rep/r-o-prt5.i grp-goods  goods.grp-name "'по группе'"  0  {1}  {2} }
END PROCEDURE.

PROCEDURE foreach5_1 :
   { rep/r-o-prt4.i no-classify "''" "''" 0 {1} {2} }
END PROCEDURE.

PROCEDURE foreach6_1 :
   { rep/r-o-prt4.i grp-goods  goods.grp-name "'по группе '"  0  {1}  {2} }
END PROCEDURE.

PROCEDURE foreach7_1 :
   { rep/r-o-prt6.i grp-goods  goods.grp-name "'по группе'"  0  {1}  {2} }
END PROCEDURE.

PROCEDURE Display-prt :
{ rep/r-o-prt1.i display  "''" "''"  0   {1}  {2} }
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

{ rep/ost-line.i yes yes }

procedure calc-price-sale-for-prt :
define output parameter v-cur-base as decimal no-undo .
&if "{3}" = "no-today" &then
define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
define variable parrecid-prl as recid no-undo .
{ str/out-vatp.i def " " " " " " -prl " " }
/*   определяем сумму в продажных ценах    */
/* определяем продажную цену на дату инициализации архива */
        { gbl/bcodepls.i
          gds-obj.obj-type
          gds-obj.obj-code
          v-bar-code
          0
          fact-order-2
          parrecid-prl
          v-cli-base-rate
          no-error
        }
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении цены бар-кода" skip
                  "Объект" gds-obj.obj-type gds-obj.obj-code skip
                  "Бар-код" v-bar-code skip
                  "fact-order" fact-order-2 skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
              end.
        if parrecid-prl <> ? then do:
          run prl-vat in this-procedure
            (input  parrecid-prl
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
                if error-status :error then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при вызове процеды prl-vat" skip
                    "Документ" ub.doc-line.doc-code skip
                    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
          .
        end.

  assign
    v-cur-base = (if var-report-r-b = "rubl" then  price-rubl-with-tax-sale-prl
                                            else  price-base-with-tax-sale-prl )
  .
&endif
end procedure.



Procedure display-str-cr :
  { rep/r-ob3cr.i disp  string(n-nn)                       nn         }
  { rep/r-ob3cr.i disp  ub.ot-line.artic                      f-artic    }
  { rep/r-ob3cr.i disp  string(v-bar-code,"'999999999'")   f-b-code   }
  { rep/r-ob3cr.i disp  goods.gds-name                     f-gds-name }
  { rep/r-ob3cr.i disp  f-qnty             f-qnty         }
  { rep/r-ob3cr.i disp  f-cost-sum         f-cost-sum     }
  { rep/r-ob3cr.i disp  f-sale-sum         f-sale-sum     }
  { rep/r-ob3cr.i disp  f-sale-other       f-sale-other   }
  { rep/r-ob3cr.i disp  f-crsa-sum         f-crsa-sum     }
  { rep/r-ob3cr.i disp  f-qnty-all         f-qnty-all     }
  { rep/r-ob3cr.i disp  f-cost-sum-all     f-cost-sum-all }
  { rep/r-ob3cr.i disp  f-crsa-sum-all     f-crsa-sum-all }
  { rep/r-ob3cr.i disp  f-qnty-o           f-qnty-o       }
  { rep/r-ob3cr.i disp  f-cost-sum-o       f-cost-sum-o   }
  { rep/r-ob3cr.i disp  f-crsa-sum-o       f-crsa-sum-o   }

  display stream OutStream   with frame zapas  no-error  .
  DOWN stream OutStream  with frame zapas .

  {&PutExcel}
    string(n-nn)                      {&tabulation}
    v-bar-code                        {&tabulation}
    (ub.ot-line.artic)  {&tabulation}
    goods.gds-name                    {&tabulation}
    excel-qnty(f-qnty        )        {&tabulation}
    excel-sum (f-cost-sum    )        {&tabulation}
    excel-sum (f-sale-sum    )        {&tabulation}
    excel-sum (f-sale-other  )        {&tabulation}
    excel-sum (f-crsa-sum    )        {&tabulation}
    excel-sum (f-qnty-all    )        {&tabulation}
    excel-sum (f-cost-sum-all)        {&tabulation}
    excel-sum (f-crsa-sum-all)        {&tabulation}
    excel-sum (f-qnty-o      )        {&tabulation}
    excel-qnty(f-cost-sum-o  )        {&tabulation}
    excel-qnty(f-crsa-sum-o  )        {&new-line} .
end procedure.
procedure init-p2 :
run cur-time in this-procedure ( output v-today
                            , output x-time
                            ).
find last ub.ot-tot  no-lock use-index pi .
if avail  ub.ot-tot then fix-doc-code = ub.ot-tot.doc-code.
              else fix-doc-code = "".

FIND first clients where x-store-type = clients.obj-type AND
        x-store-code = clients.obj-code no-lock no-error.
        If available clients then  ObjName = clients.obj-name.
                                      else  ObjName="объект не определен".
  assign
    i=0
    startdate     = x-date-start
    enddate       = x-date-end
    PayType       = x-SET_PAY_TYPE
    v-var         = string("{3}")
    ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.

    Find first ub.gds-prt where ub.gds-prt.node-name = {&empty-scale} no-lock no-error.
    If available  ub.gds-prt then   Prtroot = ub.gds-prt.prt-root.
                          Else   Prtroot = 0.

end procedure.

procedure in-proc:
  if can-find( first tdedt where  ub.ot-line.ext-doc-type = tdedt.id no-lock ) then DO:
      Case  ub.ot-line.sum-type :
          When {&arh-cost} then do:
              f-cost-sum = f-cost-sum + ub.ot-line.sum-{1} .
          End.
          When {&arh-sale} then do:
              f-sale-sum   = f-sale-sum   +  ub.ot-line.sum-{1} .
              f-sale-other = f-sale-other + ub.ot-line.other-{1} .
          End.
          When  {&arh-crsa} then do:
              f-crsa-sum = f-crsa-sum + ub.ot-line.sum-{1}  .
              f-qnty     = f-qnty     + ub.ot-line.fact-qnty .
              IF itog = false then do:
                  Create temp-doc-code .
                  Assign  temp-doc-code.doc-code = ub.ot-line.doc-code
                          temp-doc-code.ext-doc-type = ub.ot-line.ext-doc-type
                  .
              End.
          End.
      End case.
    End.
      Case  ub.ot-line.sum-type :
          when {&arh-cost} then do:
            f-cost-sum-all = f-cost-sum-all + ub.ot-line.sum-{1} .
          end.
          when  {&arh-crsa} then do:
            f-crsa-sum-all = f-crsa-sum-all + ub.ot-line.sum-{1}  .
            f-qnty-all     = f-qnty-all     + ub.ot-line.fact-qnty .
          end.
      End case.
end procedure.

procedure last-of-artic :
        n-nm = n-nm + 1.
        { rep/repfrm.i n-nm }
        Assign
          f-qnty-o     = gds-obj.fact-qnty
          f-cost-sum-o = gds-obj.fact-{1}
          f-crsa-sum-o = gds-obj.fact-sale.
        if itog = false and
          ( x-zero  or
          not(f-qnty        = 0 and
              f-cost-sum    = 0 and
              f-sale-sum    = 0 and
              f-sale-other  = 0 and
              f-crsa-sum    = 0 and
              f-qnty-all    = 0 and
              f-cost-sum-all =0 and
              f-crsa-sum-all =0 and
              f-qnty-o       =0 and
              f-cost-sum-o   =0 and
              f-crsa-sum-o   =0 ))
          Then DO:
          if x-zero = true and v-show-all-goods = false and
             (f-qnty        = 0 and
              f-cost-sum    = 0 and
              f-sale-sum    = 0 and
              f-sale-other  = 0 and
              f-crsa-sum    = 0 and
              f-qnty-all    = 0 and
              f-cost-sum-all =0 and
              f-crsa-sum-all =0 and
              f-qnty-o       =0 and
              f-cost-sum-o   =0 and
              f-crsa-sum-o   =0 ) then next.

              n-nn = n-nn + 1 .
              { gbl/gdsbcode.i gds-obj.gds-code ? v-bar-code  }
              { rep/r-ob-cr.i disp  string(n-nn)                       nn         }
              { rep/r-ob-cr.i disp  gds-obj.artic                      f-artic    }
              { rep/r-ob-cr.i disp  string(v-bar-code,"'999999999'")   f-b-code   }
              { rep/r-ob-cr.i disp  goods.gds-name                     f-gds-name }
              { rep/r-ob-cr.i disp  f-qnty             f-qnty         }
              { rep/r-ob-cr.i disp  f-cost-sum         f-cost-sum     }
              { rep/r-ob-cr.i disp  f-sale-sum         f-sale-sum     }
              { rep/r-ob-cr.i disp  f-sale-other       f-sale-other   }
              { rep/r-ob-cr.i disp  f-crsa-sum         f-crsa-sum     }
              { rep/r-ob-cr.i disp  f-qnty-all         f-qnty-all     }
              { rep/r-ob-cr.i disp  f-cost-sum-all     f-cost-sum-all }
              { rep/r-ob-cr.i disp  f-crsa-sum-all     f-crsa-sum-all }
              { rep/r-ob-cr.i disp  f-qnty-o           f-qnty-o       }
              { rep/r-ob-cr.i disp  f-cost-sum-o       f-cost-sum-o   }
              { rep/r-ob-cr.i disp  f-crsa-sum-o       f-crsa-sum-o   }

              display stream OutStream with FRAME Zapas  no-error .
              DOWN stream OutStream with FRAME Zapas.

              {&PutExcel}
                string(n-nn)                      {&tabulation}
                v-bar-code                        {&tabulation}
                (gds-obj.artic)                   {&tabulation}
                goods.gds-name                    {&tabulation}
                excel-qnty(f-qnty        )        {&tabulation}
                excel-sum (f-cost-sum    )        {&tabulation}
                excel-sum (f-sale-sum    )        {&tabulation}
                excel-sum (f-sale-other  )        {&tabulation}
                excel-sum (f-crsa-sum    )        {&tabulation}
                excel-sum (f-qnty-all    )        {&tabulation}
                excel-sum (f-cost-sum-all)        {&tabulation}
                excel-sum (f-crsa-sum-all)        {&tabulation}
                excel-sum (f-qnty-o      )        {&tabulation}
                excel-qnty(f-cost-sum-o  )        {&tabulation}
                excel-qnty(f-crsa-sum-o  )        {&new-line} .
                run display-prt in this-procedure .

         End. /* if itog false */
end procedure.

/* $Workfile$ e n d */