/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запасы по признакам

Автор: Чернова Светлана Александровна
Дата создания: 09/09/01
Author: Svetlana Chernova
Creation date: 09/09/01

*/
define input parameter x-store-code like ub.clients.obj-code no-undo.
define input parameter x-store-type like ub.clients.obj-type no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter classify  as int no-undo.
define input parameter Itog as logical no-undo .
define input parameter show-zero as logical no-undo .
define input parameter sorttype as character no-undo .
define input  parameter p-show-qnty as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет Запасы по признакам".
{ cmp/vssrevis.i }
/* Parameters Definitions ---                                           */
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/rep-bt.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ rep/lkp-font.i }
{ rep/procobor.i func-vat }

define buffer clients-p for ub.clients .
define buffer alt-ot-line for ub.ot-line .
define buffer crsa-ot-line for ub.ot-line .

define  shared temp-table alt-obj-list  NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    .

/*поля формы*/
define variable F-fact-date      as char no-undo.
define variable sss as integer no-undo .
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
define variable xTog-obj as logical no-undo init true .

define  stream  OutStream .

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
define variable    f-prt-name      as character no-undo .
define variable    f-qnty          as decimal no-undo .
define variable    f-cost-sum      as decimal no-undo .
define variable    f-sale-sum      as decimal no-undo .
define variable    f-sale-other    as decimal no-undo .
define variable    f-qnty-alt          as decimal no-undo .
define variable    f-cost-sum-alt      as decimal no-undo .
define variable    f-sale-sum-alt      as decimal no-undo .
define variable    f-sale-other-alt    as decimal no-undo .

define variable    c-nn             as WIDGET-HANDLE no-undo .
define variable    c-f-artic        as WIDGET-HANDLE no-undo .
define variable    c-f-b-code       as WIDGET-HANDLE no-undo .
define variable    c-f-gds-name     as WIDGET-HANDLE no-undo .
define variable    c-f-prt-name     as WIDGET-HANDLE no-undo .
define variable    c-f-qnty         as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other   as WIDGET-HANDLE no-undo .
define variable    c-f-qnty-alt         as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum-alt     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum-alt     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other-alt   as WIDGET-HANDLE no-undo .


define variable    p-qnty          as decimal no-undo .
define variable    p-cost-sum      as decimal no-undo .
define variable    p-sale-sum      as decimal no-undo .
define variable    p-sale-other    as decimal no-undo .
define variable    p-qnty-alt          as decimal no-undo .
define variable    p-cost-sum-alt      as decimal no-undo .
define variable    p-sale-sum-alt      as decimal no-undo .
define variable    p-sale-other-alt    as decimal no-undo .


define variable    l1f-artic       as character no-undo .
define variable    l1f-b-code      as character no-undo .
define variable    l1f-gds-name    as character no-undo .
define variable    l1f-prt-name    as character no-undo .
define variable    l1f-qnty        as character no-undo .
define variable    l1f-cost-sum    as character no-undo .
define variable    l1f-sale-sum    as character no-undo .
define variable    l1f-sale-other  as character no-undo .
define variable    l1f-qnty-alt        as character no-undo .
define variable    l1f-cost-sum-alt    as character no-undo .
define variable    l1f-sale-sum-alt    as character no-undo .
define variable    l1f-sale-other-alt  as character no-undo .

define variable    l2f-artic         as character no-undo .
define variable    l2f-b-code        as character no-undo .
define variable    l2f-gds-name      as character no-undo .
define variable    l2f-prt-name      as character no-undo .
define variable    l2f-qnty          as character no-undo .
define variable    l2f-cost-sum      as character no-undo .
define variable    l2f-sale-sum      as character no-undo .
define variable    l2f-sale-other    as character no-undo .
define variable    l2f-qnty-alt          as character no-undo .
define variable    l2f-cost-sum-alt    as character no-undo .
define variable    l2f-sale-sum-alt    as character no-undo .
define variable    l2f-sale-other-alt  as character no-undo .



/*суммы по объектам*/
define variable    ff-f-qnty         as decimal no-undo .
define variable    ff-f-cost-sum     as decimal no-undo .
define variable    ff-f-sale-sum     as decimal no-undo .
define variable    ff-f-sale-other   as decimal no-undo .
define variable    ff-f-qnty-alt         as decimal no-undo .
define variable    ff-f-cost-sum-alt     as decimal no-undo .
define variable    ff-f-sale-sum-alt     as decimal no-undo .
define variable    ff-f-sale-other-alt   as decimal no-undo .

define variable    tf-f-qnty        as decimal no-undo .
define variable    tf-f-cost-sum    as decimal no-undo .
define variable    tf-f-sale-sum     as decimal no-undo .
define variable    tf-f-sale-other   as decimal no-undo .
define variable    tf-f-qnty-alt        as decimal no-undo .
define variable    tf-f-cost-sum-alt    as decimal no-undo .
define variable    tf-f-sale-sum-alt     as decimal no-undo .
define variable    tf-f-sale-other-alt   as decimal no-undo .

define variable x-time as integer no-undo .
define variable fix-doc-code  like ub.ot-tot.doc-code no-undo .

/* ************** frame для формы **************** */
&scop l-frame 300
&scop l-frame-1 198

{ rep/r-ob-cr.i def 6}
run cur-time in this-procedure ( output x-Date-End
                               , output x-time
                               ).
x-Date-Start   = x-date-alone.

find last ub.ot-tot  no-lock use-index pi .
if avail  ub.ot-tot then fix-doc-code = ub.ot-tot.doc-code .
                 else fix-doc-code = "" .
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-row-pos = 3.
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=9  l-col-format= "X(9)"         l-col-lable="N/N"                      . { rep/r-ob-cr.i cr 1  nn               }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"        l-col-lable="Код"                      . { rep/r-ob-cr.i cr 2  f-b-code         }
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"        l-col-lable="Артикул"                  . { rep/r-ob-cr.i cr 3  f-artic          }
Assign l-col-type="CHARACTER" l-col-len=40 l-col-format= "X(40)"        l-col-lable="Название товара"          . { rep/r-ob-cr.i cr 4  f-gds-name       }
Assign l-col-type="CHARACTER" l-col-len=20 l-col-format= "X(20)"        l-col-lable="Признак"                  . { rep/r-ob-cr.i cr 5  f-prt-name       }
Assign l-col-type="DECIMAL"   l-col-len=12 l-col-format="->>>>>>>>>9.<<<" l-col-lable="Количество "           . { rep/r-ob-cr.i cr 6  f-qnty           }
Assign l-col-type="DECIMAL"   l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в учетных ценах"   . { rep/r-ob-cr.i cr 7  f-cost-sum       }
Assign l-col-type="DECIMAL"   l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" . { rep/r-ob-cr.i cr 8  f-sale-sum       }
Assign l-col-type="DECIMAL"   l-col-len=7 l-col-format="->>>>9.<<"         l-col-lable="% наценки"               . { rep/r-ob-cr.i cr 9  f-sale-other     }
Assign l-col-type="DECIMAL"   l-col-len=12 l-col-format="->>>>>>>>>9.<<<"  l-col-lable="Количество "           . { rep/r-ob-cr.i cr 10 f-qnty-alt           }
Assign l-col-type="DECIMAL"   l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в учетных ценах"   . { rep/r-ob-cr.i cr 11 f-cost-sum-alt       }
Assign l-col-type="DECIMAL"   l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" . { rep/r-ob-cr.i cr 12 f-sale-sum-alt       }
Assign l-col-type="DECIMAL"   l-col-len=7 l-col-format="->>>>9.<<"         l-col-lable="% наценки"               . { rep/r-ob-cr.i cr 13 f-sale-other-alt     }
l-row-pos = 1.
l-col-pos = 1.
Assign l-col-type="CHARACTER"
       l-col-len= -1 +
                  (if  c-nn         <> ? then  c-nn:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-b-code   <> ? then  c-f-b-code:WIDTH-CHARS  + 1     Else 0 ) +
                  (if  c-f-artic    <> ? then  c-f-artic:WIDTH-CHARS  + 1      Else 0 ) +
                  (if  c-f-gds-name <> ? then  c-f-gds-name:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-prt-name <> ? then  c-f-prt-name:WIDTH-CHARS + 1    Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Товар"                .
       { rep/r-ob-cr.i cr2 14  top-frame  }
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty       <> ? then  c-f-qnty:WIDTH-CHARS  + 1       Else 0 ) +
                  (if  c-f-cost-sum   <> ? then  c-f-cost-sum:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-sum   <> ? then  c-f-sale-sum:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-other <> ? then  c-f-sale-other:WIDTH-CHARS + 1  Else 0 )

       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Объект 1"   .
       { rep/r-ob-cr.i cr2 15  top-frame  }
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty-alt       <> ? then  c-f-qnty-alt:WIDTH-CHARS  + 1       Else 0 ) +
                  (if  c-f-cost-sum-alt   <> ? then  c-f-cost-sum-alt:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-sum-alt   <> ? then  c-f-sale-sum-alt:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-other-alt <> ? then  c-f-sale-other-alt:WIDTH-CHARS + 1  Else 0 )

       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Объект 2"   .
       { rep/r-ob-cr.i cr2 16  top-frame  }

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

        Find first ub.gds-prt where ub.gds-prt.node-name = {&empty-scale} no-lock no-error.
        If available  ub.gds-prt then   Prtroot = ub.gds-prt.prt-root.
                              Else   Prtroot = 0.

        run init-gds-list.
        Run report-execute.
/*-----------------------------------------------------------------------------------------------------------------------------*/
{ rep/f-fdec.i }
{ gbl/dtm.i }
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .

   NO-PRISE = true .
  if var-report-r-b = "rubl"  Then
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
  else
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .

  RUN waitfram-show( {&MyWaitMess} ) .

  If ReportPageHeight = 0 then ReportPageHeight = 43 .

  { cmp/open-out.i stream OutStream  " "  ReportPageHeight}
  FORM with FRAME Zapas .

  { rep/r-formh.i x(198) {&dos_CW_2}}

    if ReportPageHeight > 43  then Line = fill("-", 120).
       else Line = fill("-", 198).



  Run CalcItog in this-procedure. /*Поиск fact-order*/
  Run Print-Header in this-procedure.   /*Печать шапки*/
    CAse classify :
      when 1 then do:
        Run Foreach1 in this-procedure.    /*Обработка строк*/
      end.
      when 2 then do:
        Run Foreach2 in this-procedure.    /*Обработка строк*/
      end.
      when 3 then do:
        Run Foreach3 in this-procedure.    /*Обработка строк*/
      end.
      when 4 then do:
        Run Foreach4 in this-procedure.    /*Обработка строк*/
      end.
    End case.

  HIDE stream OutStream FRAME BottomFrame .   /*загасить фрайм "продолжение на сл стр"*/
  Run  Print-footer in this-procedure.         /*Печать подвала */
  HIDE STREAM OutStream FRAME Zapas .       /*загасить главный фрайм*/
  HIDE   STREAM OutStream FRAME top-Frame .
  DELETE WIDGET-POOL "My-pool".
  Output stream OutStream close.
  {&CloseExcel}
  RUN waitfram-hide .
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
   PUT stream OutStream  string(v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
         AT 50 format "X(85)" SKIP(2)
         REPORTNAME
         AT 35  format "X(100)" skip.
     PUT stream OutStream   "на "  + string(x-date-start,"99/99/9999") +
         " время " +  string(x-time,"HH:MM:SS")  AT 35 format "X(160)" SKIP.
      Repeat i = 1 to NUM-ENTRIES(STR2,chr(10)) :
        if LENGTH(trim(Entry(i,STR2,chr(10)))) > 1 then  PUT stream OutStream  Entry(i,STR2,chr(10))  AT 1 format "X(120)" SKIP.
      End.

     Repeat i = 1 to NUM-ENTRIES(STR3,chr(10)) :
       if LENGTH(trim(Entry(i,STR3,chr(10)))) > 1 then PUT stream OutStream  Entry(i,STR3,chr(10))  AT 1 format "X(120)" SKIP.
     End.

     Repeat i = 1 to NUM-ENTRIES(STR4,chr(10)) :
       if LENGTH(trim(Entry(i,STR4,chr(10)))) > 1 then PUT stream OutStream  Entry(i,STR4,chr(10))  AT 1 format "X(120)" SKIP.
     End.

     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
       if LENGTH(trim(Entry(i,ReportHeader,chr(10)))) > 1 then PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(120)" SKIP.
     End.

    i=0.
  run rep/extitle.p (1) .
    display STREAM OutStream     with frame top-Frame .

   END PROCEDURE.


PROCEDURE Print-Footer :
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  PUT STREAM OutStream UNFORMATTED " Печать закончена : " + string(v-time,"HH:MM:SS") SKIP.
  PUT STREAM OutStream UNFORMATTED " За время формирования отчета были закрыты документы : " SKIP.
  for each obj-list :
      for each ub.trn-doc no-lock where
          ub.trn-doc.status_ = {&fact} and
          ub.trn-doc.flag_= true and
          ub.trn-doc.obj-code = obj-list.obj-code and
          ub.trn-doc.obj-type = obj-list.obj-type
          by ub.trn-doc.fact-order DESCENDING :
             If ub.trn-doc.fact-order <= fact-order-2 then leave.
             PUT STREAM OutStream  UNFORMATTED ub.trn-doc.doc-code SKIP.
      end.
  end.
  PUT STREAM OutStream UNFORMATTED " ______________________________________________________" SKIP.
   run on-same-page in this-procedure (input 1) .
   END PROCEDURE.

PROCEDURE U-LINE :
define variable ff as character no-undo .
if itog = false
Then do:
ff = fill("-",40).
      { rep/r-ob-cr.i disp  ff  nn             }
      { rep/r-ob-cr.i disp  ff  f-b-code       }
      { rep/r-ob-cr.i disp  ff  f-artic        }
      { rep/r-ob-cr.i disp  ff  f-gds-name     }
      { rep/r-ob-cr.i disp  ff  f-prt-name     }
      { rep/r-ob-cr.i full  ff  f-qnty         }
      { rep/r-ob-cr.i full  ff  f-cost-sum     }
      { rep/r-ob-cr.i full  ff  f-sale-sum     }
      { rep/r-ob-cr.i full  ff  f-sale-other   }
      { rep/r-ob-cr.i full  ff  f-qnty-alt         }
      { rep/r-ob-cr.i full  ff  f-cost-sum-alt     }
      { rep/r-ob-cr.i full  ff  f-sale-sum-alt     }
      { rep/r-ob-cr.i full  ff  f-sale-other-alt   }

  Display stream OutStream  with FRAME Zapas no-error .
  DOWN stream OutStream  with FRAME Zapas .
      { rep/r-ob-cr.i sfull f-qnty         }
      { rep/r-ob-cr.i sfull f-cost-sum     }
      { rep/r-ob-cr.i sfull f-sale-sum     }
      { rep/r-ob-cr.i sfull f-sale-other   }
      { rep/r-ob-cr.i sfull f-qnty-alt         }
      { rep/r-ob-cr.i sfull f-cost-sum-alt     }
      { rep/r-ob-cr.i sfull f-sale-sum-alt     }
      { rep/r-ob-cr.i sfull f-sale-other-alt   }

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

  for each ub.trn-doc no-lock where
      ub.trn-doc.status_   = {&fact}  and
      ub.trn-doc.flag_     = true     and
      ub.trn-doc.host-code = v-cntxt-host-code-obj
      by ub.trn-doc.fact-order DESCENDING :
        fact-order-2 = ub.trn-doc.fact-order  .
        leave.
  end.

/*эти не нужны*/
          Quantity1  = 0.
          Coast_R1   = 0.
          Coast_V1   = 0.
          VAT_R1     = 0.
          VAT_V1     = 0.
END PROCEDURE.


PROCEDURE foreach1 :
{ rep/r-z-alt1.i no-classify "''" "''" 0 {1} {2} }
END PROCEDURE.

PROCEDURE foreach2 :
{ rep/r-z-alt1.i prod-code  gds-list.prod-code "'по произв.'"  0  {1}  {2} }
END PROCEDURE.

PROCEDURE foreach3 :
{ rep/r-z-alt1.i grp-goods  gds-list.grp-name "'по группе '"  0  {1}  {2} }
END PROCEDURE.

PROCEDURE foreach4 :
{ rep/r-z-alt1.i VAT-pc  gds-list.qnty   "'по ставке НДС '"  0  {1}  {2} }
END PROCEDURE.


PROCEDURE Display-prt :
{ rep/r-z-alt1.i display  "''" "''"  0   {1}  {2} }
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
procedure init-gds-list :

  do
  on error undo, return error return-value
  :
  run waitfram-show ( "Подготовка списка товара..." ).

    if x-SelectGood <> {&g-all} then do:
        for each obj-list :
           for each ub.gds-obj no-lock where ub.gds-obj.obj-type =  obj-list.obj-type and
                                          ub.gds-obj.obj-code =  obj-list.obj-code   :
                find first gds-list      where gds-list.gds-code = ub.gds-obj.gds-code no-error .
                if available gds-list then do:
                    if gds-list.gds-type   <> {&gds-goods} or (p-show-qnty = true  and ub.gds-obj.{&qnty-type} <= 0 ) then do:
                          delete gds-list .
                    end.
                    else do:
                       if classify = 4 then
                       gds-list.qnty = func-vat (gds-list.gds-code,ub.gds-obj.obj-type,ub.gds-obj.obj-code) .
                    end.
                end.
           end.
        end. /* obj-list */
    end.
    else do:
        for each obj-list :
           for each ub.gds-obj no-lock where ub.gds-obj.obj-type =  obj-list.obj-type and
                                          ub.gds-obj.obj-code =  obj-list.obj-code   :
                find first gds-list      where gds-list.gds-code = ub.gds-obj.gds-code no-error .
                if not available gds-list then do:
                    if (p-show-qnty = true  and ub.gds-obj.{&qnty-type} > 0) or p-show-qnty = false then do:
                        find first ub.goods no-lock where ub.goods.gds-code = ub.gds-obj.gds-code no-error .
                        create gds-list.
                        BUFFER-COPY ub.goods TO gds-list.
                        /* если по ндс*/
                         if classify = 4 then
                         gds-list.qnty = func-vat (gds-list.gds-code,ub.gds-obj.obj-type,ub.gds-obj.obj-code) .
                    end.
                end.
           end.
        end. /* obj-list */
    end. /*if */

    if p-show-qnty = false  and x-SelectGood = {&g-all}  then do:
        for each alt-obj-list :
          for each ub.gds-obj no-lock where ub.gds-obj.obj-type =  alt-obj-list.obj-type and
                                          ub.gds-obj.obj-code =  alt-obj-list.obj-code
          :
            find first gds-list      where gds-list.gds-code = ub.gds-obj.gds-code no-error .
            if not available gds-list then do:
                find first ub.goods no-lock where ub.goods.gds-code = ub.gds-obj.gds-code no-error .
                create gds-list.
                BUFFER-COPY ub.goods TO gds-list.
                /* если по ндс*/
                  if classify = 4 then
                  gds-list.qnty = func-vat (gds-list.gds-code,ub.gds-obj.obj-type,ub.gds-obj.obj-code) .

            end.
          end.
        end. /* alt-obj-list */
    end.


end.
end procedure. /* init-gds-list */
/* $Workfile$ e n d */