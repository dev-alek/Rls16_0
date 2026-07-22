/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запасы по признакам

Автор: Чернова Светлана Александровна
Дата создания: 09/09/05
Author: Svetlana Chernova
Creation date: 09/09/05

*/
DEFINE TEMP-TABLE tt-season NO-UNDO LIKE season.

define input parameter x-store-code like clients.obj-code no-undo.
define input parameter x-store-type like clients.obj-type no-undo.
define input parameter x-base-type  like currency.curr-abbr no-undo.
define input parameter x-base-code  like currency.curr-code no-undo.
define input parameter classify  as int no-undo.
define input parameter p-zero as logical no-undo .
define input parameter p-zero-ost as logical no-undo .
define input parameter Itog as logical no-undo .
define input parameter p-tog-obj as logical   no-undo .
define input PARAMETER TABLE FOR tt-season .
define input parameter p-prizn      as  character no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запасы по признакам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ rep/procobor.i func-vat }
{ trg/prdoclib.i }
{ rep/f-fdec.i   }
{ gbl/dtm.i      }
{ str/prl-vat.i  }
{ rep/lkp-font.i }

define buffer clients-p for clients .
define buffer alt-ot-line for ot-line .
define buffer crsa-ot-line for ot-line .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_prt-obj for ub.prt-obj  .
define temp-table sl-obj-list no-undo like ub.clients .
define buffer buf_sl-obj-list for sl-obj-list .
define buffer buf_parts for ub.parts  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buff_doc-line for ub.doc-line  .
define buffer bufd_doc-line for ub.doc-line  .
define buffer buf_gds-dtl for ub.gds-dtl  .
define buffer bufd_gds-dtl for ub.gds-dtl  .
define buffer bufi_gds-dtl for ub.gds-dtl  .
define buffer bufi_trn-doc for ub.trn-doc  .
define variable  F-fact-date as char no-undo.
define variable tot-v-sale-sum as decimal no-undo init 0.
define variable tot-v-cost-sum as decimal no-undo init 0.

define temp-table t-trn-doc no-undo
field doc-code as character
index pi doc-code
.
define temp-table temp_gds-dtl no-undo like ub.gds-dtl
field cost-sum as decimal
field sale-sum as decimal
index pi doc-code
artic
prod-type
prod-code
prt-code
.
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
define variable xTog-obj as logical no-undo .

define  stream  OutStream .

define variable    ObjName           as char no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as  char     no-undo.

define variable v-var as character no-undo .

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
define variable  Prtroot        like gds-prt.node-code no-undo.
define variable v-prizn as character no-undo.
v-prizn = p-prizn.
define variable    nn              as character no-undo .
define variable    f-artic         as character no-undo .
define variable    f-b-code        as character no-undo .
define variable    f-gds-name      as character no-undo .
define variable    f-prt-name      as character no-undo .
define variable    f-qnty          as decimal no-undo .
define variable    f-cost-sum      as decimal no-undo .
define variable    f-sale-sum      as decimal no-undo .
define variable    f-cost-pr      as decimal no-undo .
define variable    f-sale-pr      as decimal no-undo .
define variable    f-sale-other    as decimal no-undo .
define variable    f-free-qnty     as decimal no-undo .
define variable    f-wait-qnty     as decimal no-undo .
define variable f-rez-qnty    as decimal   no-undo .
define variable f-rez-cost    as decimal   no-undo .
define variable f-rez-sale    as decimal   no-undo .
define variable f-rez-cost-pr as decimal   no-undo .

define variable    c-nn             as WIDGET-HANDLE no-undo .
define variable    c-f-artic        as WIDGET-HANDLE no-undo .
define variable    c-f-b-code       as WIDGET-HANDLE no-undo .
define variable    c-f-gds-name     as WIDGET-HANDLE no-undo .
define variable    c-f-prt-name     as WIDGET-HANDLE no-undo .
define variable    c-f-qnty         as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-cost-pr     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-pr     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other   as WIDGET-HANDLE no-undo .
define variable    c-f-free-qnty    as WIDGET-HANDLE no-undo .
define variable    c-f-wait-qnty    as WIDGET-HANDLE no-undo .
define variable c-f-rez-qnty    as WIDGET-HANDLE no-undo .
define variable c-f-rez-cost    as WIDGET-HANDLE no-undo .
define variable c-f-rez-sale    as WIDGET-HANDLE no-undo .
define variable c-f-rez-cost-pr as WIDGET-HANDLE no-undo .


define variable    p-qnty          as decimal no-undo .
define variable    p-cost-sum      as decimal no-undo .
define variable    p-sale-sum      as decimal no-undo .
define variable    p-cost-pr      as decimal no-undo .
define variable    p-sale-pr      as decimal no-undo .
define variable    p-sale-other    as decimal no-undo .
define variable    p-free-qnty     as decimal no-undo .
define variable    p-wait-qnty         as decimal no-undo .
define variable p-rez-qnty    as decimal no-undo .
define variable p-rez-cost    as decimal no-undo .
define variable p-rez-sale    as decimal no-undo .
define variable p-rez-cost-pr as decimal no-undo .

define variable    l1f-artic       as character no-undo .
define variable    l1f-b-code      as character no-undo .
define variable    l1f-gds-name    as character no-undo .
define variable    l1f-prt-name    as character no-undo .
define variable    l1f-qnty        as character no-undo .
define variable    l1f-cost-sum    as character no-undo .
define variable    l1f-sale-sum    as character no-undo .
define variable    l1f-cost-pr    as character no-undo .
define variable    l1f-sale-pr    as character no-undo .
define variable    l1f-sale-other  as character no-undo .
define variable    l1f-free-qnty    as character no-undo .
define variable    l1f-wait-qnty    as character no-undo .
define variable l1f-rez-qnty    as character no-undo .
define variable l1f-rez-cost    as character no-undo .
define variable l1f-rez-cost-pr    as character no-undo .
define variable l1f-rez-sale    as character no-undo .

define variable    l2f-artic         as character no-undo .
define variable    l2f-b-code        as character no-undo .
define variable    l2f-gds-name      as character no-undo .
define variable    l2f-prt-name      as character no-undo .
define variable    l2f-qnty          as character no-undo .
define variable    l2f-cost-sum      as character no-undo .
define variable    l2f-sale-sum      as character no-undo .
define variable    l2f-cost-pr      as character no-undo .
define variable    l2f-sale-pr      as character no-undo .
define variable l2f-rez-qnty    as character no-undo .
define variable l2f-rez-cost    as character no-undo .
define variable l2f-rez-sale    as character no-undo .
define variable    l2f-sale-other    as character no-undo .
define variable    l2f-free-qnty     as character no-undo .
define variable    l2f-wait-qnty      as character no-undo .
define variable l2f-rez-cost-pr    as character no-undo .

/*суммы по обьектам*/
define variable    ff-f-qnty         as decimal no-undo .
define variable    ff-f-cost-sum     as decimal no-undo .
define variable    ff-f-sale-sum     as decimal no-undo .
define variable ff-f-rez-qnty    as decimal no-undo .
define variable ff-f-rez-cost    as decimal no-undo .
define variable ff-f-rez-sale    as decimal no-undo .
define variable    ff-f-sale-other   as decimal no-undo .
define variable    ff-f-free-qnty    as decimal no-undo .
define variable    ff-f-wait-qnty    as decimal no-undo .

define variable    tf-f-qnty        as decimal no-undo .
define variable    tf-f-cost-sum    as decimal no-undo .
define variable    tf-f-sale-sum     as decimal no-undo .

define variable    tf-f-sale-other   as decimal no-undo .
define variable    tf-f-free-qnty    as decimal no-undo .
define variable    tf-f-wait-qnty    as decimal no-undo .
define variable tf-f-rez-qnty    as decimal no-undo .
define variable tf-f-rez-cost    as decimal no-undo .
define variable tf-f-rez-sale    as decimal no-undo .

define variable x-time as integer no-undo .
define variable fix-doc-code  like ot-tot.doc-code no-undo .
define variable v-price-sale as decimal no-undo .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

/* ************** frame для формы **************** */
&scop l-frame 300
&scop l-frame-1 198
{ rep/repfrm.i def}
{ rep/repfrm.i on 100}

{ rep/r-ob-cr.i def 4}
x-Date-End     = x-date-alone.
x-Date-Start   = x-date-alone.
xTog-obj =  p-tog-obj .

if p-tog-obj = false then do:
    for each obj-list :
        create sl-obj-list .
        buffer-copy obj-list to sl-obj-list .
    end.
end.

run cur-time in this-procedure ( output v-today
                               , output x-time
                               ).
find last ot-tot  no-lock use-index pi no-error .
if available ot-tot then fix-doc-code = ot-tot.doc-code.
                 else fix-doc-code = "".

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-row-pos = 1.
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=9  l-col-format="X(9)"               l-col-lable="N/N"                      . { rep/r-ob-cr.i cr 1  nn             }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format="X(10)"              l-col-lable="Код"                      . { rep/r-ob-cr.i cr 2  f-b-code       }
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format="X(16)"              l-col-lable="Артикул"                  . { rep/r-ob-cr.i cr 3  f-artic        }
Assign l-col-type="CHARACTER" l-col-len=40 l-col-format="X(40)"              l-col-lable="Название товара"          . { rep/r-ob-cr.i cr 4  f-gds-name     }
Assign l-col-type="CHARACTER" l-col-len=20 l-col-format="X(20)"              l-col-lable="Признак"                  . { rep/r-ob-cr.i cr 5  f-prt-name     }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Количество "              . { rep/r-ob-cr.i cr 6  f-qnty         }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="Учетная цена"            . { rep/r-ob-cr.i cr 7  f-cost-pr      }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="Сумма в учетных ценах"    . { rep/r-ob-cr.i cr 8  f-cost-sum     }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="Продажная цена"           . { rep/r-ob-cr.i cr 9  f-sale-pr      }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="Сумма в продажных ценах"  . { rep/r-ob-cr.i cr 10 f-sale-sum     }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="% наценки"                . { rep/r-ob-cr.i cr 11 f-sale-other   }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Свободное количество"     . { rep/r-ob-cr.i cr 12 f-free-qnty    }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Ожидаемое Количество"     . { rep/r-ob-cr.i cr 13 f-wait-qnty    }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Резерв Количество"        . { rep/r-ob-cr.i cr 14 f-rez-qnty     }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Сумма в учетных ценах"    . { rep/r-ob-cr.i cr 15 f-rez-cost     }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Сумма в ценах докум."     . { rep/r-ob-cr.i cr 16 f-rez-sale     }
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Учетная цена резерва"     . { rep/r-ob-cr.i cr 17 f-rez-cost-pr  }
/*===================================================================================================================*/
  find first clients no-lock where
              clients.obj-type = x-store-type   and
              clients.obj-code = x-store-code
              no-error.
  if available clients then  objname = clients.obj-name.
                       else  objname = "объект не определен".
     assign
        i=0
        startdate     = x-date-start
        enddate       = x-date-end
        v-var         = string("{3}")
        paytype       = x-set_pay_type
        valtype       = if (paytype = 1) then 0  else x-set_val_type.

        Find first gds-prt where gds-prt.node-name = {&empty-scale} no-lock no-error.
        If available  gds-prt then   Prtroot = gds-prt.prt-root.
                              Else   Prtroot = 0.

        run report-execute in this-procedure.
/*-----------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .

   NO-PRISE = true .
  if  var-report-r-b = "rubl"  Then
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
  else
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .



  If ReportPageHeight = 0 then ReportPageHeight = 43 .
 

  { cmp/open-out.i stream OutStream  " "  ReportPageHeight}
  FORM with FRAME Zapas .
  { rep/r-formh.i x(198) {&dos_CW_2}}
   Line = fill("-", 198).
  Run CalcItog in this-procedure. /*Поиск fact-order*/
  Run Print-Header in this-procedure.   /*Печать шапки*/
  if p-tog-obj = true then do:
    CAse classify :
      when 1 then do:
        &if "{&rpt-season}" = "" and "{&rep-togobj}" = "" &then
        Run Foreach1 in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 2 then do:
        &if "{&rpt-season}" = "" and "{&rep-togobj}" = "" &then
        Run Foreach2 in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 3 then do:
        &if "{&rpt-season}" = "" and "{&rep-togobj}" = "" &then
        Run Foreach3 in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 4 then do:
        &if "{&rpt-season}" = "" and "{&rep-togobj}" = "" &then
        Run Foreach4 in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 5 then do:
        &if "{&rpt-season}" <> "" &then
        Run Foreach5 in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 6 then do:
        &if "{&rpt-season}" <> "" &then
        Run Foreach6 in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 7 then do:
        &if "{&rpt-season}" <> "" &then
        Run Foreach7 in this-procedure.    /*Обработка строк*/
        &endif
      end.
    End case.
  end.
  else do:
    case classify :
      when 1 then do:
        &if "{&rpt-season}" = "" and "{&rep-togobj}" <> "" &then
        Run Foreach1t in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 2 then do:
        &if "{&rpt-season}" = "" and "{&rep-togobj}" <> "" &then
        Run Foreach2t in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 3 then do:
        &if "{&rpt-season}" = "" and "{&rep-togobj}" <> "" &then
        Run Foreach3t in this-procedure.    /*Обработка строк*/
        &endif
      end.
      when 4 then do:
        &if "{&rpt-season}" = "" and "{&rep-togobj}" <> "" &then
        Run Foreach4t in this-procedure.    /*Обработка строк*/
        &endif
      end.
      end case.
 end.

  HIDE stream OutStream FRAME BottomFrame .   /*загасить фрайм "продолжение на сл стр"*/
  Run  Print-footer in this-procedure.         /*Печать подвала */
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
   PUT stream OutStream  string(v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
         AT 50 format "X(85)" SKIP(2)
         REPORTNAME
         AT 35  format "X(100)" skip.
     PUT stream OutStream   "на "  + string(x-date-start,"99/99/9999") +
         " время " +  string(x-time,"HH:MM:SS")  AT 35 format "X(160)" SKIP.
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
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  PUT STREAM OutStream UNFORMATTED " Печать закончена : " + string(v-time,"HH:MM:SS") SKIP.

  &If "{3}"  <> "no-today"  &then
  PUT STREAM OutStream UNFORMATTED " За время формирования отчета были закрыты документы : " SKIP.
  for each obj-list :
  for each trn-doc no-lock where
      trn-doc.status_ = {&fact} and
      trn-doc.flag_= true  and
      trn-doc.obj-code = obj-list.obj-code and
      trn-doc.obj-type = obj-list.obj-type and
      trn-doc.host-code = v-cntxt-host-code-obj and
      trn-doc.fact-order > fact-order-2 .
      PUT STREAM OutStream  UNFORMATTED trn-doc.doc-code SKIP.
   end.
  end.
  PUT STREAM OutStream UNFORMATTED " ______________________________________________________" SKIP.
  &endif

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
      { rep/r-ob-cr.i full  ff  f-cost-pr      }
      { rep/r-ob-cr.i full  ff  f-cost-sum     }
      { rep/r-ob-cr.i full  ff  f-sale-pr      }
      { rep/r-ob-cr.i full  ff  f-sale-sum     }
      { rep/r-ob-cr.i full  ff  f-sale-other   }
      { rep/r-ob-cr.i full  ff  f-free-qnty    }
      { rep/r-ob-cr.i full  ff  f-wait-qnty    }
      { rep/r-ob-cr.i full  ff  f-rez-qnty     }
      { rep/r-ob-cr.i full  ff  f-rez-cost     }
      { rep/r-ob-cr.i full  ff  f-rez-sale     }
      { rep/r-ob-cr.i full  ff  f-rez-cost-pr  }

  Display stream OutStream  with FRAME Zapas no-error .
  DOWN stream OutStream  with FRAME Zapas .
      { rep/r-ob-cr.i sfull f-qnty         }
      { rep/r-ob-cr.i sfull f-cost-pr      }
      { rep/r-ob-cr.i sfull f-cost-sum     }
      { rep/r-ob-cr.i sfull f-sale-pr      }
      { rep/r-ob-cr.i sfull f-sale-sum     }
      { rep/r-ob-cr.i sfull f-sale-other   }
      { rep/r-ob-cr.i sfull f-free-qnty    }
      { rep/r-ob-cr.i sfull f-wait-qnty    }
      { rep/r-ob-cr.i sfull f-rez-qnty     }
      { rep/r-ob-cr.i sfull f-rez-cost     }
      { rep/r-ob-cr.i sfull f-rez-sale     }
      { rep/r-ob-cr.i sfull f-rez-cost-pr  }
End.

END PROCEDURE.

PROCEDURE CalcItog :
run ostatok  in this-procedure (
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

/*эти не нужны*/
    Quantity1  = 0.
    Coast_R1   = 0.
    Coast_V1   = 0.
    VAT_R1     = 0.
    VAT_V1     = 0.
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

define variable max-val like trn-doc.fact-order no-undo .
define variable max-val-old like trn-doc.fact-order no-undo .
max-val-old  = 0 .
for each obj-list :
  fact-order-2 = 0 .
  find last trn-doc no-lock where
      trn-doc.status_  = {&fact} and
      trn-doc.flag_    = true  and
      trn-doc.obj-code = obj-list.obj-code and
      trn-doc.obj-type = obj-list.obj-type
      use-index fact-order .
   if available trn-doc then   fact-order-2 = trn-doc.fact-order  .
       max-val = fact-order-2 .
   if  max-val < max-val-old then max-val =  max-val-old .
       max-val-old  =  fact-order-2.
 end.
 fact-order-2  = max-val .

&Endif

END PROCEDURE.

&if "{&rpt-season}" = "" and "{&rep-togobj}" = "" &then
/* процедуры отчета сост запаса с признаками разд по об */
procedure foreach1 :
 { rep/r-prt-z1.i no-classify "''" "''" 0 {1} {2} }
end procedure.
procedure foreach2 :
 { rep/r-prt-z1.i prod-code  gds-obj.prod-code "'по произв.'"  0  {1}  {2} }
end procedure.
procedure foreach3 :
 { rep/r-prt-z1.i grp-goods  goods.grp-name "'по группе '"  0  {1}  {2} }
end procedure.
procedure foreach4 :
 { rep/r-prt-z1.i vat-pc  gds-list.qnty "'по ставке НДС '"  0  {1}  {2} }
end procedure.
procedure display-prt :
 { rep/r-prt-z1.i display  "''" "''"  0   {1}  {2} }
end procedure.
&endif
&if "{&rpt-season}" = "" and "{&rep-togobj}" <> "" &then
/* процедуры отчета сост запаса с признаками СЛИТНО по об */
procedure foreach1t :
 { rep/r-prt-z5.i no-classify "''" "''" 0 {1} {2} }
end procedure.
procedure foreach2t :
 { rep/r-prt-z5.i prod-code  gds-obj.prod-code "'по произв.'"  0  {1}  {2} }
end procedure.
procedure foreach3t :
 { rep/r-prt-z5.i grp-goods  goods.grp-name "'по группе '"  0  {1}  {2} }
end procedure.
procedure foreach4t :
 { rep/r-prt-z5.i vat-pc gds-list.qnty "'по ставке НДС '"  0  {1}  {2} }
end procedure.
procedure display-prt-t :
 { rep/r-prt-z5.i display  "''" "''"  0   {1}  {2} }
end procedure.
&endif
&if "{&rpt-season}" <> "" &then
/* процедуры отчета сост запаса пр коллекциям */
procedure foreach5 :
 { rep/r-prt-z2.i no-classify "''" "''" 0 {1} {2} }
end procedure.
procedure foreach6 :
  { rep/r-prt-z2.i grp-goods  goods.grp-name "'по группе '"  0  {1}  {2} }
end procedure.
procedure foreach7 :
   { rep/r-prt-z3.i season  tt-season.sea-name "'коллекция'"  0  {1}  {2} }
end procedure.
procedure display-prt :
 { rep/r-prt-z1.i display  "''" "''"  0   {1}  {2} }
end procedure.
&endif

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
{ rep/ost-line.i yes yes }

procedure calc-price-sale-for-prt :
define output parameter v-cur-base as decimal no-undo .
define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
define var parrecid-prl as recid no-undo .
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
    v-cur-base = price-{1}-with-tax-sale-prl
  .
end procedure.
/* $Workfile$ e n d */