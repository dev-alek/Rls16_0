/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Оборотная ведомость отчет

Автор: Чернова Светлана Александровна
Дата создания: 09/01/01
Author: Svetlana Chernova
Creation date: 09/01/01

*/

/* Parameters Definitions ---                                           */
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter xClassify      as char no-undo.
define input parameter xSortType      as char no-undo.
define input parameter xSumsOnly      as logical  no-undo.
define input parameter xShowZero      as logical  no-undo.
define input parameter xShowZero-2    as logical  no-undo.
define input parameter xTog-obj       as logical  no-undo.
define input parameter xShowCost      as logical  no-undo.
define input parameter xShowCostNDS   as logical  no-undo.
define input parameter xShowCrsa      as logical  no-undo.
define input parameter xShowCrsaNDS   as logical  no-undo.
define input parameter xShowSale      as logical  no-undo.
define input parameter xShowSaleNDS   as logical  no-undo.
define input parameter xtog-lavel     as logical  no-undo.
define input parameter xvar-lavel     as int  no-undo.
define input parameter xserv          as char no-undo.
define input parameter print-o        as char no-undo.
define input parameter xShowmediator  as logical  no-undo.
define input parameter xShowSaleSlt   as logical  no-undo.
define input parameter x-vat          as logical  no-undo.
define input parameter xlongname      as logical   no-undo .
define input parameter x-tog-wt       as logical   no-undo .
define input parameter x-tog-ms       as logical   no-undo .
define input parameter p-is-petrol    as logical   no-undo .

define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }

 &scop e-col 12
{ rep/rep-bt.i   }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/r-gl.i {3} }
{ rep/procobor.i func-vat }
{ gbl/cur-time.i }

define temp-table temp#sum-type no-undo
    FIELD sum-type as char
    FIELD xi as int .

define variable v-name-type as character no-undo .
if x-vat then x-vat = false .
         else x-vat = true .

if x-vat then v-name-type = "учет.".
else  v-name-type = "учет-НДС".


&scop l-frame 340
&scop l-frame-1 319

define variable  long-p         as logical  no-undo .
define variable  Null-str#      as decimal  no-undo.
define variable  Null-str2#     as decimal  no-undo.
define variable  b1-Null-str#   as decimal  no-undo.
define variable  b1-Null-str2#  as decimal  no-undo.
define variable  b2-Null-str#   as decimal  no-undo.
define variable  b2-Null-str2#  as decimal  no-undo.

define variable  tPrintRubl as logical no-undo.

define stream  OutStream.
define variable    ObjName           as   char no-undo.
define variable    Select-Good       as   integer no-undo.
define variable    ChosedType        as   integer no-undo.
define variable    PayType           as   integer no-undo.
define variable    RetClassify       as   char  no-undo.
define variable    RetSortType       as   char  no-undo.
define variable    Show-Negativ      as   logical  no-undo.
define variable    Show-Negativ-2    as   logical  no-undo.
define variable    Sums-Only         as   logical  no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as   char        no-undo.
define variable    Line2             as   char        no-undo.
define variable    FirstLine         as   logical     no-undo.

define variable mediator-host-code as integer no-undo .
define variable f-flag             as logical no-undo .

define variable tot_tqnty as decimal  no-undo.

define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.

define variable stat      as logical    no-undo .
define variable InpError  as logical    no-undo .
define variable i         as integer    no-undo .
define variable p         as integer    no-undo init 0 .
define variable kk        as integer    no-undo init 0 .
define variable old-page  as integer    no-undo .
define variable new-page  as integer    no-undo .
define variable rid-list  as character  no-undo .

define variable gds-zap-unit-base     like ub.goods.unit-base     no-undo.
define variable gds-zap-prt-root      like ub.goods.prt-root      no-undo .
define variable gds-zap-gds-name      like ub.goods.gds-name      no-undo .
define variable gds-zap-prod-type     like ub.goods.prod-type     no-undo .
define variable gds-zap-prod-code     like ub.goods.prod-code     no-undo .
define variable gds-zap-artic         like ub.goods.artic         no-undo .
define variable gds-zap-b-code        like ub.bar-code.b-code     no-undo .
define variable gds-type              as char no-undo.
define variable gds-zap-type          like ub.goods.gds-type     no-undo .
define variable gds-zap-grp-name      like ub.goods.grp-name     no-undo .
define variable gds-zap-prod-name     like ub.clients.obj-name   no-undo .
define variable gds-zap-price-base    like ub.stk-tot.sum-base   no-undo.
define variable gds-zap-stoim-base    like ub.stk-tot.sum-base   no-undo.
define variable gds-zap-qnty          like ub.stk-tot.fact-qnty  no-undo.
define variable gds-zap-Nds           like ub.stk-tot.sum-base   no-undo.
define variable gds-zap-Np            like ub.stk-tot.sum-base   no-undo.
define variable gds-wt-base           like ub.goods.wt-base      no-undo .
define variable gds-ms-base           like ub.goods.ms-base      no-undo .

/* def  var F-ostatok-start    as   char  no-undo. */
define variable F-ostatok-End      as   char  no-undo.

define variable ostatok-start      as   decimal EXTENT {&e-col}  no-undo .
define variable ostatok-End        as   decimal EXTENT {&e-col}  no-undo.
define variable B1-ostatok-start   as   decimal EXTENT {&e-col}  no-undo.
define variable B1-ostatok-End     as   decimal EXTENT {&e-col}  no-undo.
define variable B2-ostatok-start   as   decimal EXTENT {&e-col}  no-undo.
define variable B2-ostatok-End     as   decimal EXTENT {&e-col}  no-undo.
define variable Bi-ostatok-start   as   decimal EXTENT {&e-col}  no-undo.
define variable Bi-ostatok-End     as   decimal EXTENT {&e-col}  no-undo.

define variable Bo-ostatok-start   as   decimal EXTENT {&e-col}  no-undo.
define variable Bo-ostatok-End     as   decimal EXTENT {&e-col}  no-undo.

define variable c-s-bar-code        AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-artic     AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-gds-name  AS   WIDGET-HANDLE  no-undo.
define variable c-gds-zap-unit-base AS   WIDGET-HANDLE  no-undo.
define variable c-gds-type          AS   WIDGET-HANDLE  no-undo.
define variable C-ostatok-start     AS   WIDGET-HANDLE  no-undo.
define variable C-ostatok-End       AS   WIDGET-HANDLE  no-undo.
define variable c-str-num           AS   WIDGET-HANDLE  no-undo.

define variable v-gds-num          as integer   no-undo .

define variable l-col-type         as character no-undo .
define variable l-col-pos          as integer no-undo .
define variable l-col-len          as integer no-undo .
define variable l-col-format       as character no-undo .
define variable l-col-lable        as character no-undo .

define variable first-lavel as integer no-undo .
define variable v-Format-string as character no-undo .
&glob bef-Disc disc
&glob bef-eff  eff
&glob bef-prc  prc
&glob bef-r-v  r-v
&glob bef-sum-cost sum-cost
&glob bef-sum-crsa sum-crsa
&glob bef-sum-sale sum-sale

{ rep/def-ob.i TDEDT_Pri_Vnesh}
{ rep/def-ob.i TDEDT_Ras_Vnesh}
{ rep/def-ob.i TDEDT_RAS_Vnesh_VP}
{ rep/def-ob.i TDEDT_Ras_Vnesh_Kass}
{ rep/def-ob.i TDEDT_Vozvrat_Vnesh}
{ rep/def-ob.i TDEDT_Vozvrat_Vnesh_Kass}
{ rep/def-ob.i TDEDT_Spi_Vnesh}
{ rep/def-ob.i TDEDT_Inv}
{ rep/def-ob.i TDEDT_Pri_Perem}
{ rep/def-ob.i TDEDT_Ras_Perem}
{ rep/def-ob.i TDEDT_Vozvrat_Perem}
{ rep/def-ob.i TDEDT_Ras_Prvo}
{ rep/def-ob.i TDEDT_Spi_Prvo}
{ rep/def-ob.i TDEDT_Pri_Prvo}
{ rep/def-ob.i TDEDT_Overturn}
{ rep/def-ob.i TDEDT_Chg_Purch_Code }
{ rep/def-ob.i TDEDT_Corr_Acc_Price }
{ rep/def-ob.i Disc}
{ rep/def-ob.i eff}
{ rep/def-ob.i prc}
{ rep/def-ob.i r-v}

{ rep/def-ob.i sum-cost}
{ rep/def-ob.i sum-crsa}
{ rep/def-ob.i sum-sale}
{ rep/procobor.i def-tt }

define variable NN      as   int  no-undo.
define variable report1 as int no-undo.
define variable report2 as int no-undo.
define variable ErrorLevel as int no-undo.

define variable  Fact-order-1   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.

define variable  Fact-order-2   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.


define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R     like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V     like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_R       like ub.stk-tot.sum-rubl   no-undo.
define variable  SLT_V       like ub.stk-tot.sum-rubl   no-undo.


define variable  Coast3       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4       like ub.stk-tot.sum-rubl   no-undo.
define variable  temp-str as char no-undo.

define variable str as char format "X(60)" no-undo.
define variable i#i as int no-undo.
define variable xLavel as int  no-undo.
define variable list-field as char no-undo.
define variable str10 as char no-undo.
define buffer kg-obj-list for obj-list .


DEFINE new shared VARIABLE t-1 AS CHARACTER INITIAL "|||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.

/* lables frame zapas */



DEFINE new shared FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
     cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "{&abbr_rub_allshift}" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") ) AT 110 format "X(16)" SKIP
     WITH {&l-frame} DOWN stream-io
         NO-UNDERLINE use-text NO-BOX no-label
         AT COL 1 ROW 1
         SIZE {&l-frame} BY 35  .


DEFINE new shared FRAME zapas
   with width {&l-frame} down stream-io use-text NO-BOX no-label.

{ rep/repfrm.i def}
{ rep/repfrm.i on 25 }
{ rep/repfrm.i disp i "'Оборотная ведомость по всем типам'" objname }

{ rep/r-ob1cr.i def 1     s-bar-code                 "new shared" }
{ rep/r-ob1cr.i def  2    gds-zap-artic              "new shared"  }
{ rep/r-ob1cr.i def  3    gds-zap-gds-name           "new shared"  }
{ rep/r-ob1cr.i def  4    gds-zap-unit-base          "new shared"  }
{ rep/r-ob1cr.i def  5    gds-type                   "new shared"  }
{ rep/r-ob1cr.i def  6    ostatok-start                "new shared" }
{ rep/r-ob1cr.i def  7    oborot-{&bef-TDEDT_Pri_Vnesh} "new shared" }
{ rep/r-ob1cr.i def  8    oborot-{&bef-TDEDT_Pri_Perem} "new shared" }
{ rep/r-ob1cr.i def  9    oborot-{&bef-TDEDT_Pri_Prvo}  "new shared" }
{ rep/r-ob1cr.i def  10   oborot-{&bef-TDEDT_Ras_Vnesh} "new shared" }
{ rep/r-ob1cr.i def  11   oborot-{&bef-TDEDT_Ras_Perem} "new shared" }
{ rep/r-ob1cr.i def  12   oborot-{&bef-TDEDT_Ras_Prvo}  "new shared" }
{ rep/r-ob1cr.i def  13   oborot-{&bef-TDEDT_Spi_Vnesh} "new shared" }
{ rep/r-ob1cr.i def  14   oborot-{&bef-TDEDT_Ras_Vnesh_Kass}    "new shared" }
{ rep/r-ob1cr.i def  15   oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass} "new shared" }
{ rep/r-ob1cr.i def  16   oborot-{&bef-TDEDT_Vozvrat_Vnesh}     "new shared" }
{ rep/r-ob1cr.i def  17   oborot-{&bef-TDEDT_RAS_Vnesh_VP}      "new shared" }
{ rep/r-ob1cr.i def  18   oborot-{&bef-TDEDT_Vozvrat_Perem}     "new shared" }
{ rep/r-ob1cr.i def  19   oborot-{&bef-TDEDT_Inv}               "new shared" }
{ rep/r-ob1cr.i def  20   oborot-{&bef-TDEDT_Overturn}          "new shared" }
{ rep/r-ob1cr.i def  21   oborot-{&bef-disc}                    "new shared" }
{ rep/r-ob1cr.i def  22   ostatok-end                           "new shared" }
{ rep/r-ob1cr.i def  23   oborot-{&bef-eff}                     "new shared" }
{ rep/r-ob1cr.i def  24   oborot-{&bef-prc}                     "new shared" }
{ rep/r-ob1cr.i def  25   oborot-{&bef-TDEDT_Corr_Acc_Price}    "new shared" }
{ rep/r-ob1cr.i def  26   oborot-{&bef-TDEDT_Chg_Purch_Code}    "new shared" }
{ rep/r-ob1cr.i def  27   oborot-{&bef-r-v}                     "new shared"  }
{ rep/r-ob1cr.i def  28   str-num                               "new shared"  }

  run rep/r-in-ob.p (
   input          x-base-type
 , input          x-base-code
 , input          tprintrubl
 , input-output   c-s-bar-code
 , input-output   c-gds-zap-artic
 , input-output   c-gds-zap-gds-name
 , input-output   c-gds-zap-unit-base
 , input-output   c-gds-type
 , input-output   c-ostatok-start
 , input-output   c-ostatok-end
 , input-output   c-oborot-{&bef-tdedt_pri_vnesh            }
 , input-output   c-oborot-{&bef-tdedt_ras_vnesh            }
 , input-output   c-oborot-{&bef-tdedt_ras_vnesh_vp         }
 , input-output   c-oborot-{&bef-tdedt_ras_vnesh_kass       }
 , input-output   c-oborot-{&bef-tdedt_vozvrat_vnesh        }
 , input-output   c-oborot-{&bef-tdedt_vozvrat_vnesh_kass   }
 , input-output   c-oborot-{&bef-tdedt_spi_vnesh            }
 , input-output   c-oborot-{&bef-tdedt_inv                  }
 , input-output   c-oborot-{&bef-tdedt_pri_perem            }
 , input-output   c-oborot-{&bef-tdedt_ras_perem            }
 , input-output   c-oborot-{&bef-tdedt_vozvrat_perem        }
 , input-output   c-oborot-{&bef-tdedt_ras_prvo             }
 , input-output   c-oborot-{&bef-tdedt_spi_prvo             }
 , input-output   c-oborot-{&bef-tdedt_pri_prvo             }
 , input-output   c-oborot-{&bef-tdedt_overturn             }
 , input-output   c-oborot-{&bef-tdedt_chg_purch_code       }
 , input-output   c-oborot-{&bef-tdedt_corr_acc_price       }
 , input-output   c-oborot-{&bef-disc                       }
 , input-output   c-oborot-{&bef-eff                        }
 , input-output   c-oborot-{&bef-prc                        }
 , input-output   c-oborot-{&bef-r-v                        }
 , input-output   c-str-num
 , input-output   l-col-type
 , input-output   l-col-pos
 , input-output   l-col-len
 , input-output   l-col-format
 , input-output   l-col-lable
  ).

  define variable time-start as integer no-undo .
  Run init-proc in this-procedure .
  if f-flag = false then RETURN .
  Run report-execute   in this-procedure .


/*-----------------------------------------------------------------------------------------------------------------------*/
&if  "{3}" = "lavel"  &then
{ rep/f-flav.i }
&endif


procedure init-proc :
 time-start = time.
assign
  i               = 0
  xlavel          = xvar-lavel
  Select-Good     = x-SelectGood
  PayType         = x-SET_PAY_TYPE
  RetClassify     = xClassify
  RetSortType     = xSortType
  Sums-Only       = xSumsOnly
  Show-Negativ    = xShowZero
  Show-Negativ-2  = xShowZero-2
  FirstLine       = FALSE
  line            = fill('-', MINIMUM(l-col-pos,189))
  line2            = fill('-', l-col-pos - 1)
  .

  if p-is-petrol = true  then
  assign
    Select-Good  = {&g-choice}
    x-SelectGood = {&g-choice}
  .

  if  x-date-end  - x-date-start > 400
      then long-p = true    .
      else  long-p = false     .
  x-SelectObject = "".
  find first ub.gds-grp where  ub.gds-grp.upper-code = 0 no-lock no-error .
  if avail ub.gds-grp then   first-lavel = ub.gds-grp.node-code.
                   else first-lavel = 0.

  ValType         = IF (PayType = 1) Then 0  else x-SET_val_TYPE.

  If (ValType=0 and x-base-code=0)  Or ValType=1
    then assign tPrintRubl = yes .
    else assign tPrintRubl = no .
  run rep/ob-sumtp.p (output table temp#sum-type ).
  Run find-mediator  in this-procedure  ( INPUT v-cntxt-host-code-obj ,input xShowmediator, OUTPUT mediator-host-code, OUTPUT f-flag) .

end procedure. /* init-proc */


PROCEDURE report-execute :
  Case print-o :
  when "A4-lansc":U then DO:
     { cmp/open-out.i stream OutStream  " " {&LS_PS_A4}} end.
  when "A4-port":U then DO:
     { cmp/open-out.i stream OutStream  " " {&CP_PS}} end.
  when "A3-lansc":U then DO:
     { cmp/open-out.i stream OutStream  " " {&CP_PS}} end.
  OTHERWISE DO:
     { cmp/open-out.i stream OutStream  " " {&LS_PS_A4}} end.
  end case.
 /*----------------------------------------------------------------------------------------------------------------------*/
 define variable gj as integer no-undo init 0.
   if xTog-obj /* раздельно по объектам */ Then DO:
            FOR each obj-list no-lock:
                x-store-type = obj-list.obj-type.
                x-store-code = obj-list.obj-code.
                gj = gj + 1 .
                Run report-exec1   in this-procedure .
            End.
           if gj > 1 then DO :
              run display-bo   in this-procedure .
              run u-line  in this-procedure .
           End.
          End.
  Else  Run report-exec1   in this-procedure .

  put stream outstream " Время составления отчета " string((time - time-start),"hh:mm:ss" ) .

  HIDE   STREAM OutStream FRAME ZAPAS .
  HIDE   STREAM OutStream FRAME top-Frame .
  Output stream OutStream close.
  { rep/repfrm.i off}


  DELETE WIDGET-POOL "My-pool".

   define variable v-user-action as character no-undo .
   define variable v-printed as logical   no-undo .
   define variable DisabledOptions as integer   no-undo .


  Case print-o :
  when "A4-lansc":U then DO:
      DisabledOptions = 8 .
     end.
  when "A4-port":U then DO:
      DisabledOptions = 0 .
     end.
  when "A3-lansc":U then DO:
      DisabledOptions = 8 .
                      end.
  OTHERWISE DO:
      DisabledOptions = 1 .
      end.
   End case.

   run gbl/prnfilen.w
     (input  ""
     ,input  DisabledOptions
     ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
     ,input  7
     ,output v-user-action
     ,output v-printed
     ) .
END PROCEDURE.


PROCEDURE foreach :
  define buffer buf_goods for ub.goods.
  find first  buf_goods no-lock where buf_goods.gds-code = gds-zap-b-code no-error .

  Assign
    p-price-med = 0
    Null-str# = 1
    Null-str2# = 1
    gds-ms-base        = if buf_goods.ms-base = ? then 0 else buf_goods.ms-base
    gds-wt-base        = if buf_goods.wt-base = ? then 0 else buf_goods.wt-base
  .
 { rep/repfrm.i disp i}

  RUN Clear-item   in this-procedure .
  /* Найдем цену посредника по этому товару */
  if xshowmediator = true then do :
       run find-last-prise-med in this-procedure (
          input gds-zap-artic ,
          input gds-zap-prod-type ,
          input gds-zap-prod-code ,
          input mediator-host-code ,
          output p-price-med   )
            .
    End.

/* Остатки  на начало */
{ rep/io.i Fact-order-1 arh-cost 0 start {3}}
    if p-is-petrol then do: /* Топливо */
    { rep/iop.i Fact-order-1 'NO' 0 start {3}}
    end.
If xshowcrsa Or xshowCrsaNDS OR use-column[23] OR use-column[24]  or xShowmediator   Then DO:
   { rep/io.i Fact-order-1 arh-crsa 3 start {3}}
   End.
   /* по документу берется crsa  а не  sale */
If xshowsale Or xshowsaleNDS Or xshowsaleSLT  Then DO:
   { rep/io.i Fact-order-1 arh-crsa 6 start {3}}
   End.


/* Остатки на конец */
{ rep/io.i Fact-order-2 arh-cost 0 end {3}}
    if p-is-petrol then do: /* Топливо */
    { rep/iop.i Fact-order-2 'NO' 0 end {3}}
    end.

If xshowCrsa Or xshowCrsaNDS OR use-column[23] OR use-column[24]  or xShowmediator Then DO:
   { rep/io.i Fact-order-2 arh-crsa 3 end {3}}
   End.

If xshowsale Or
   xshowsaleNDS Or
   xshowsaleSLT    Then DO:
   { rep/io.i Fact-order-2 arh-crsa 6 end {3}}
   End.
/* Обороты */
   if gds-zap-type = {&gds-goods}
      then { rep/r-ob-ln.i {&arh-cost} ''}
      else { rep/r-ob-ln.i {&arh-cost-service} ''}
   Run CAlc-Sub-itog   in this-procedure (0).

  If xshowCrsa Or xshowCrsaNDS  OR   use-column[23] OR use-column[24]  or xShowmediator   Then DO:
     if gds-zap-type = {&gds-goods}
        THEN { rep/r-ob-ln.i {&arh-crsa} ''}
        else { rep/r-ob-ln.i {&arh-crsa-service} ''}
     Run CAlc-Sub-itog  in this-procedure  (3).
  End.

  If xshowsale Or xshowsaleNDS   Or xshowsaleSLT
               OR use-column[21] OR use-column[23] OR use-column[24]  Then DO:
      if gds-zap-type = {&gds-goods}
         THEN { rep/r-ob-ln.i {&arh-sale} ''}
         else { rep/r-ob-ln.i {&arh-sale-service} ''}
      Run CAlc-Sub-itog   in this-procedure (6).
  End.
  if NOT Show-negativ   then  Run Null-str-pr  in this-procedure .
  if NOT Show-negativ-2 then  Run Null-str-pr2  in this-procedure .

&scop run-calc-ms-wt run calc-ms-wt in this-procedure ( input ~{&var-name}[1] ~
, input ~{&gds-base} ~
, input-output    ~{&var-name}[~{&col-num}] ~
, input-output bi-~{&var-name}[~{&col-num}] ~
, input-output bo-~{&var-name}[~{&col-num}] ~
, input-output b1-~{&var-name}[~{&col-num}] ~
, input-output b2-~{&var-name}[~{&col-num}] ~
) .
&scop run-calc-pt-ob run calc-pt-ob in this-procedure ( input '~{&n-p}' ~
, input x-store-type ~
, input x-store-code  ~
, input gds-zap-artic     ~
, input gds-zap-prod-type ~
, input gds-zap-prod-code ~
, input-output    ~{&var-name}[~{&col-num}] ~
, input-output bi-~{&var-name}[~{&col-num}] ~
, input-output bo-~{&var-name}[~{&col-num}] ~
, input-output b1-~{&var-name}[~{&col-num}] ~
, input-output b2-~{&var-name}[~{&col-num}] ~
) .


if x-tog-wt then do :
  &scop col-num 11
  &scop gds-base gds-wt-base

  &scop var-name ostatok-start
  {&run-calc-ms-wt}
  &scop var-name ostatok-end
  {&run-calc-ms-wt}
  &scop var-name oborot-~{&n-p}

  &scop  n-p {&bef-TDEDT_Pri_Vnesh}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_RAS_Vnesh_VP}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh_Kass}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh_Kass}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Spi_Vnesh}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Inv}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Pri_Perem}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Ras_Perem}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Vozvrat_Perem}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Ras_Prvo}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Pri_Prvo}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Overturn}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Corr_Acc_Price}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
  &scop  n-p {&bef-TDEDT_Chg_Purch_Code}
  {&run-calc-ms-wt}
  {&run-calc-pt-ob}
end. /* if x-tog-wt */

if x-tog-ms then do :
  &scop col-num 12
  &scop gds-base gds-ms-base

  &scop var-name ostatok-start
  {&run-calc-ms-wt}
  &scop var-name ostatok-end
  {&run-calc-ms-wt}

  &scop var-name oborot-~{&n-p}

  &scop  n-p {&bef-TDEDT_Pri_Vnesh}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_RAS_Vnesh_VP}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Ras_Vnesh_Kass}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Vozvrat_Vnesh_Kass}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Spi_Vnesh}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Inv}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Pri_Perem}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Ras_Perem}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Vozvrat_Perem}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Ras_Prvo}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Pri_Prvo}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Overturn}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Corr_Acc_Price}
  {&run-calc-ms-wt}
  &scop  n-p {&bef-TDEDT_Chg_Purch_Code}
  {&run-calc-ms-wt}
end.

END PROCEDURE.


PROCEDURE display-line :

  i = i + 1.
   IF NOT  (NOT Show-Negativ   AND Null-Str#  = 0  ) then DO:
      IF NOT  (NOT Show-Negativ-2 AND Null-Str2# = 0  ) then DO:
        new-page = PAGE-NUMBER( OutStream).
        If old-page <> new-page then p = 0.
        IF NOT Sums-Only then  do:
            if fr0 = true then do:
              PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
              fr0 = false .
            end.

            if fr = true then dO:
              PUT stream OutStream space(6) temp-str format "X(100)" SKIP.
              fr = false .
            end.
            Run Display-str1  in this-procedure .
            end.
      End.
    END.
    old-page = new-page.
END PROCEDURE.


PROCEDURE print-header :
if NOT FirstLine Then  Run Display-Title  in this-procedure .
    FirstLine = TRUE .
    if xTog-obj and   x-SelectObject <> "currency":U   Then  DO:
          {&PUT-u1}
          string(  "ПО ОБЪЕКТУ : (" + x-store-type  + string(x-store-code)  +  ") " + ObjName)
          AT 30 format "X(170)" SKIP.
          End.
          FORM {&WFz} .   {&FRAME-d} .

      RUN Clear-B1  in this-procedure .
      RUN Clear-B2  in this-procedure .
      RUN Clear-Bi  in this-procedure .
      break_group = true.
      break_group1 = true.
      display STREAM OutStream     with frame top-Frame .
      display STREAM OutStream     with frame top-2 .
END PROCEDURE.


PROCEDURE Print-Footer :
      If RetClassify = "no-classify":U  then Run U-line  in this-procedure .
       gds-zap-artic = "ИТОГО" .
       Run display-BI  in this-procedure .
       Run U-line  in this-procedure .
       END PROCEDURE.
PROCEDURE U-LINE :
        /*{&PUT-u1}  line2 format "X({&l-frame-1})" SKIP.*/
        {&PUT-u1}  line2 SKIP.
END PROCEDURE.

PROCEDURE P-LINE :
        END PROCEDURE.
PROCEDURE CalcItog :
    run ostatok   in this-procedure (
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
    run ostatok   in this-procedure (
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
PROCEDURE display-str1  :
  assign
    v-gds-num = v-gds-num + 1
  .
  { rep/di-qnty.i "кол-во" 1   s-bar-code gds-zap-artic gds-zap-gds-name gds-zap-unit-base  " " v-gds-num {3} }
  if x-tog-wt then do : { rep/di-qnty.i "вес"    11  " " " " " " " " " " 0 {3} } end.
  if x-tog-ms then do : { rep/di-qnty.i "объем"  12  " " " " " " " " " " 0 {3} } end.
  if xShowCost    Then DO: run PRICE-VAT in this-procedure ('').  end.
  if xShowCostNDS Then DO:  { rep/di-qnty.i "НДС учет."  3  " " " " " " " " " " 0 {3} } End.
  if xShowCrsa    Then DO:  { rep/di-qnty.i "прод."      5  " " " " " " " " " " 0 {3} } End.
  if xShowCrsaNds Then DO:  { rep/di-qnty.i "НДС прод."  6  " " " " " " " " " " 0 {3} } End.
  if xShowSAle    Then DO:  { rep/di-qnty.i "док."       8  " " " " " " " " " " 0 {3} } End.
  if xShowSaleNds Then DO:  { rep/di-qnty.i "НДС док."   9  " " " " " " " " " " 0 {3} } End.
  if xShowSaleSLT Then DO:  { rep/di-qnty.i "НсП док."   10 " " " " " " " " " " 0 {3} } End.
  if xShowMediator Then DO: { rep/di-qnty.i "поср."      4  " " " " " " " " " " 0 {3} }  End.
END PROCEDURE.
PROCEDURE display-Bi  :
  { rep/di-qnty.i "кол-во" 1  "''" gds-zap-artic     "''"  "''"  Bi- 0 {3} }
  if x-tog-wt then do : { rep/di-qnty.i "вес"    11  " " " " " " " "  Bi- 0 {3} } end.
  if x-tog-ms then do : { rep/di-qnty.i "объем"  12  " " " " " " " "  Bi- 0 {3} } end.
  if xShowCost    Then DO:  run PRICE-VAT in this-procedure ('Bi').  end.
  if xShowCostNDS Then DO: { rep/di-qnty.i "НДС учет."  3 "''"  "''"  "''"  "''"  Bi- 0 {3} } End.
  if xShowCrsa    Then DO: { rep/di-qnty.i "прод."  5     "''"  "''"  "''"  "''"  Bi- 0 {3} } End.
  if xShowCrsaNds Then DO: { rep/di-qnty.i "НДС прод."  6 "''"  "''"  "''"  "''"  Bi- 0 {3} } End.
  if xShowSAle    Then DO: { rep/di-qnty.i "док."  8      "''"  "''"  "''"  "''"  Bi- 0 {3} } End.
  if xShowSaleNds Then DO: { rep/di-qnty.i "НДС док."  9  "''"  "''"  "''"  "''"  Bi- 0 {3} } End.
  if xShowSaleSlt Then DO: { rep/di-qnty.i "НсП док."  10  "''"  "''"  "''"  "''"  Bi- 0 {3} } End.
  if xShowmediator Then DO: { rep/di-qnty.i "поср."  4  "''"  "''"  "''"  "''"  Bi- 0 {3} } End.
END PROCEDURE.
PROCEDURE display-Bo  :
  { rep/di-qnty.i "кол-во" 1  "''" "'ИТОГО ПО'"  "'ОБЪЕКТАМ'"  "''"  Bo- 0 {3}}
  if x-tog-wt then do : { rep/di-qnty.i "вес"    11  " " " " " " " " Bo- 0 {3} } end.
  if x-tog-ms then do : { rep/di-qnty.i "объем"  12  " " " " " " " " Bo- 0 {3} } end.
  if xShowCost    Then DO:  run PRICE-VAT in this-procedure ('Bo').  end.
  if xShowCostNDS Then DO: { rep/di-qnty.i "НДС учет."  3 "''"  "''"  "''"  "''"  Bo-  0 {3}} End.
  if xShowCrsa    Then DO: { rep/di-qnty.i "прод."  5     "''"  "''"  "''"  "''"  Bo-  0 {3}} End.
  if xShowCrsaNds Then DO: { rep/di-qnty.i "НДС прод."  6 "''"  "''"  "''"  "''"  Bo-  0 {3}} End.
  if xShowSAle    Then DO: { rep/di-qnty.i "док."  8      "''"  "''"  "''"  "''"  Bo-  0 {3}} End.
  if xShowSaleNds Then DO: { rep/di-qnty.i "НДС док."  9  "''"  "''"  "''"  "''"  Bo-  0 {3}} End.
  if xShowSaleslt Then DO: { rep/di-qnty.i "НсП док."  10 "''"  "''"  "''"  "''"  Bo- 0 {3}} End.
  if xShowmediator Then DO: { rep/di-qnty.i "поср."  4    "''"  "''"  "''"  "''"  Bo-    0 {3}} End.
END PROCEDURE.


PROCEDURE display-B1  :
  b1-Null-str# = 1.
  b1-Null-str2# = 1.

  if not show-negativ   then  run b1-null-str-pr   in this-procedure .
  if not show-negativ-2 then  run b1-null-str-pr2  in this-procedure .

   if not     ( not show-negativ   and b1-null-str#  = 0  ) then do :
      if not  ( not show-negativ-2 and b1-null-str2# = 0  ) then do :
              /*шапка для верхней группы  когда только итоги ++++  */
              if Sums-Only THEN do:
                  if fr0 = true then do:
                      PUT stream  OutStream  tmp#stroka0 format "X(100)" SKIP.
                      fr0 = false .
                    end.
               end.

        { rep/di-qnty.i "кол-во" 1  s-bar-code gds-zap-artic gds-zap-gds-name "''" b1- 0 {3}}
        assign
            sf1:screen-value = ""
            sf2:screen-value = ""
            no-error .
          if x-tog-wt then do : { rep/di-qnty.i "вес"    11  " " " " " " " " B1- 0 {3} } end.
          if x-tog-ms then do : { rep/di-qnty.i "объем"  12  " " " " " " " " B1- 0 {3} } end.
          if xShowCost     Then  DO:  run PRICE-VAT in this-procedure ('B1').                 End.
          if xShowCostNDS  Then  DO:  { rep/di-qnty.i "НДС учет."  3  "''" "''" "''" "''" B1- 0 {3}} End.
          if xShowCrsa     Then  DO:  { rep/di-qnty.i "прод."  5      "''" "''" "''" "''" B1- 0 {3}} End.
          if xShowCrsaNds  Then  DO:  { rep/di-qnty.i "НДС прод."  6  "''" "''" "''" "''" B1- 0 {3}} End.
          if xShowSAle     Then  DO:  { rep/di-qnty.i "док."  8       "''" "''" "''" "''" B1- 0 {3}} End.
          if xShowSaleNds  Then  DO:  { rep/di-qnty.i "НДС док."  9   "''" "''" "''" "''" B1- 0 {3}} End.
          if xShowSaleSlt  Then  DO:  { rep/di-qnty.i "НсП док."  10  "''" "''" "''" "''" B1- 0 {3}} End.
          if xShowmediator Then  DO:  { rep/di-qnty.i "поср."      4  "''" "''" "''" "''" B1- 0 {3}} End.
      end.
   end.
END PROCEDURE.


PROCEDURE display-B2  :
  b2-Null-str#  = 1 .
  b2-Null-str2# = 1 .

  if not show-negativ   then  run b2-null-str-pr   in this-procedure .
  if not show-negativ-2 then  run b2-null-str-pr2  in this-procedure .

   if not  (not show-negativ   and b2-null-str#  = 0  ) then do :
      if not  (not show-negativ-2 and b2-null-str2# = 0  ) then do :

        { rep/di-qnty.i "кол-во" 1  s-bar-code gds-zap-artic gds-zap-gds-name "''" b1- 0 {3}}
        if x-tog-wt then do : { rep/di-qnty.i "вес"    11  " " " " " " " " B2- 0 {3} } end.
        if x-tog-ms then do : { rep/di-qnty.i "объем"  12  " " " " " " " " B2- 0 {3} } end.
        if xShowCost    Then DO:  run PRICE-VAT in this-procedure ('B2').  end.
        if xShowCostNDS Then DO: { rep/di-qnty.i "НДС учет."  3  "''" "''" "''" "''"  B2- 0 {3}} End.
        if xShowCrsa    Then DO: { rep/di-qnty.i "прод."  5      "''" "''" "''" "''"  B2- 0 {3}}  End.
        if xShowCrsaNds Then DO: { rep/di-qnty.i "НДС прод."  6  "''" "''" "''" "''"  B2- 0 {3}} End.
        if xShowSAle    Then DO: { rep/di-qnty.i "док."  8       "''" "''" "''" "''"  B2- 0 {3}}  End.
        if xShowSaleNds Then DO: { rep/di-qnty.i "НДС док."  9   "''" "''" "''" "''"  B2- 0 {3}} End.
        if xShowSaleslt Then DO: { rep/di-qnty.i "НсП док."  10   "''" "''" "''" "''"  B2- 0 {3}} End.
        if xShowmediator Then DO: { rep/di-qnty.i "поср."  4   "''" "''" "''" "''"  B2- 0 {3}} End.
  if NOT xSumsOnly THEN Run u-line  in this-procedure .
end.
end.
END PROCEDURE.


PROCEDURE Clear-B1  :
 { rep/o-clear.i B1}
END PROCEDURE.
PROCEDURE Clear-B2  :
 { rep/o-clear.i B2}
END PROCEDURE.
PROCEDURE Clear-Bi  :
 { rep/o-clear.i Bi}
END PROCEDURE.

PROCEDURE Display-title :
   {&PUT-u1}  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName) AT 50 format "X(85)" SKIP(2)
          REPORTNAME  AT 1 format "X(133)" SKIP
          Trim(str1)  AT 35 format "X(75)" SKIP.
     Repeat i = 1 to NUM-ENTRIES(str2,chr(10)) :
      {&PUT-u1}  Entry(i,str2,chr(10))  AT 1 format "X(130)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(str3,chr(10)) :
      {&PUT-u1}  Entry(i,str3,chr(10))  AT 1 format "X(130)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(str4,chr(10)) :
      {&PUT-u1}  Entry(i,str4,chr(10))  AT 1 format "X(130)" SKIP.
     End.
    i=0.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
      {&PUT-u1}  Entry(i,ReportHeader,chr(10))  AT 1 format "X(130)" SKIP.
     End.
    i=0.
END PROCEDURE.
PROCEDURE ob-line  :
 { rep/ob-line.i }
END PROCEDURE.

PROCEDURE report-exec1  :
   FIND FIRST clients where x-store-type = clients.obj-type AND
                            x-store-code = clients.obj-code no-lock no-error.

           If available clients then  ObjName = clients.obj-name.
                                         else  ObjName="объект не определен".
  FORM with FRAME zapas .

  { rep/r-formh.i X(197) {&l-frame}}

  Run CalcItog  in this-procedure .

  Run Print-Header  in this-procedure .   /* проход по списку товаров 1 2 3-№ поиска */
   CASE RetClassify :
      &if {1} = 1 &then when "no-classify":U  then    Run Run1  in this-procedure . &endif
      &if {1} = 2 &then when "grp-goods":U then       Run Run2  in this-procedure . &endif
      &if {1} = 3 &then when "prod":U  then           Run Run3  in this-procedure . &endif
      &if {1} = 4 &then when "prod/grp-goods":U then  Run Run4  in this-procedure . &endif
      &if {1} = 5 &then when "grp-goods/prod":U then  Run Run5  in this-procedure . &endif
      &if {1} = 7 &then when "vat-ps":U         then  Run Run7  in this-procedure . &endif
      otherwise do:
        message "" view-as alert-box error .
      end.
   End case.

  HIDE stream OutStream FRAME BottomFrame .
  Run Print-footer  in this-procedure .
  END PROCEDURE.

PROCEDURE Calc-Sub-itog :
define input parameter tt as int no-undo.
define variable tt2 as integer no-undo .
define variable ji as integer no-undo .
  if tt = 6 then tt2 = 7 .
            else tt2 = tt.
Repeat i# = 1 + tt to 3 + tt2 :
  { rep/run-ii.i TDEDT_Inv           TDEDT_Pri_Vnesh tt      }
  { rep/run-ii.i TDEDT_Pri_Perem     TDEDT_Ras_Vnesh tt      }
  { rep/run-ii.i TDEDT_Ras_Perem     TDEDT_RAS_Vnesh_VP tt   }
  { rep/run-ii.i TDEDT_Vozvrat_Perem TDEDT_Ras_Vnesh_Kass tt }
  { rep/run-ii.i TDEDT_Ras_Prvo      TDEDT_Vozvrat_Vnesh tt  }
  { rep/run-ii.i TDEDT_Pri_Prvo      TDEDT_Vozvrat_Vnesh_Kass tt }
  { rep/run-ii.i TDEDT_Corr_Acc_Price      TDEDT_Chg_Purch_Code tt }
  { rep/run-ii.i TDEDT_Overturn             TDEDT_Spi_Vnesh tt       }

  B1-oborot-{&bef-TDEDT_Ras_Prvo}[ i#] = B1-oborot-{&bef-TDEDT_Ras_Prvo}[ i#] + oborot-{&bef-TDEDT_spi_Prvo}[ i#].
  B2-oborot-{&bef-TDEDT_Ras_Prvo}[ i#] = B2-oborot-{&bef-TDEDT_Ras_Prvo}[ i#] + oborot-{&bef-TDEDT_spi_Prvo}[ i#].
  Bi-oborot-{&bef-TDEDT_Ras_Prvo}[ i#] = Bi-oborot-{&bef-TDEDT_Ras_Prvo}[ i#] + oborot-{&bef-TDEDT_spi_Prvo}[ i#].
  Bo-oborot-{&bef-TDEDT_Ras_Prvo}[ i#] = Bo-oborot-{&bef-TDEDT_Ras_Prvo}[ i#] + oborot-{&bef-TDEDT_spi_Prvo}[ i#].

  Bo-ostatok-start[ i#]  = Bo-ostatok-start[i#]  + ostatok-start[ i#]  .
  Bo-ostatok-end[ i#]    = Bo-ostatok-end[i#]    + ostatok-end[ i#]    .

  if i# = 7 then B1-oborot-{&bef-Disc}[1 ]  = B1-oborot-{&bef-Disc}[1]  + oborot-{&bef-Disc}[1]  .
  if i# = 7 then B2-oborot-{&bef-Disc}[1 ]  = B2-oborot-{&bef-Disc}[1]  + oborot-{&bef-Disc}[1]  .
  if i# = 7 then Bi-oborot-{&bef-Disc}[1 ]  = Bi-oborot-{&bef-Disc}[1]  + oborot-{&bef-Disc}[1]  .
  if i# = 7 then Bo-oborot-{&bef-Disc}[1 ]  = Bo-oborot-{&bef-Disc}[1]  + oborot-{&bef-Disc}[1]  .


  if i# = 8 then
    assign
      bi-oborot-sum-Sale[ i#]  = Bi-oborot-{&bef-TDEDT_Ras_Vnesh}[ i#] +
                              Bi-oborot-{&bef-TDEDT_Vozvrat_Vnesh}[ i#]         +
                              Bi-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ i#]    +
                              Bi-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}[ i#]

      b1-oborot-sum-Sale[ i#]  = B1-oborot-{&bef-TDEDT_Ras_Vnesh}[ i#] +
                              B1-oborot-{&bef-TDEDT_Vozvrat_Vnesh}[ i#]         +
                              B1-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ i#]    +
                              B1-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}[ i#]

      b2-oborot-sum-Sale[ i#]  = B2-oborot-{&bef-TDEDT_Ras_Vnesh}[ i#] +
                              B2-oborot-{&bef-TDEDT_Vozvrat_Vnesh}[ i#]         +
                              B2-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ i#]    +
                              B2-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}[ i#]
      bo-oborot-sum-Sale[ i#]  = Bo-oborot-{&bef-TDEDT_Ras_Vnesh}[ i#] +
                              Bo-oborot-{&bef-TDEDT_Vozvrat_Vnesh}[ i#]         +
                              Bo-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ i#]    +
                              Bo-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}[ i#]
      .

  if i# = 2 and  xShowmediator = false   then do:
      ji = 2.
      assign
        bi-oborot-sum-cost[ i#]  = Bi-oborot-{&bef-TDEDT_Ras_Vnesh}[ ji] +
                                Bi-oborot-{&bef-TDEDT_Vozvrat_Vnesh}[ ji]         +
                                Bi-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ ji]    +
                                Bi-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}[ ji]

        b1-oborot-sum-cost[ i#]  = B1-oborot-{&bef-TDEDT_Ras_Vnesh}[ ji] +
                                B1-oborot-{&bef-TDEDT_Vozvrat_Vnesh}[ ji]         +
                                B1-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ ji]    +
                                B1-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}[ ji]

        b2-oborot-sum-cost[ i#]  = B2-oborot-{&bef-TDEDT_Ras_Vnesh}[ ji] +
                                B2-oborot-{&bef-TDEDT_Vozvrat_Vnesh}[ ji]         +
                                B2-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ ji]    +
                                B2-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}[ ji]
        bo-oborot-sum-cost[ i#]  = Bo-oborot-{&bef-TDEDT_Ras_Vnesh}[ ji] +
                                Bo-oborot-{&bef-TDEDT_Vozvrat_Vnesh}[ ji]         +
                                Bo-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}[ ji]    +
                                Bo-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}[ ji]
        .
  end.
  if  xShowmediator = true  then do:
  if i# = 8 then B1-oborot-sum-cost[2 ]  = B1-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  if i# = 8 then B2-oborot-sum-cost[2 ]  = B2-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  if i# = 8 then Bi-oborot-sum-cost[2 ]  = Bi-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  if i# = 8 then Bo-oborot-sum-cost[2 ]  = Bo-oborot-sum-cost[2]  + oborot-sum-cost[1]  .
  end.

  if i# = 8 then B1-oborot-{&bef-EFF}[1 ]  = B1-oborot-{&bef-EFF}[1]  + oborot-{&bef-EFF}[1]  .
  if i# = 8 then B2-oborot-{&bef-EFF}[1 ]  = B2-oborot-{&bef-EFF}[1]  + oborot-{&bef-EFF}[1]  .
  if i# = 8 then Bi-oborot-{&bef-EFF}[1 ]  = Bi-oborot-{&bef-EFF}[1]  + oborot-{&bef-EFF}[1]  .
  if i# = 8 then Bo-oborot-{&bef-EFF}[1 ]  = Bo-oborot-{&bef-EFF}[1]  + oborot-{&bef-EFF}[1]  .

  if i# = 8 then    if  Bi-oborot-sum-cost[2] <>  0 then
                        Bi-oborot-{&bef-prc}[1] = 100 * (BI-oborot-sum-sale[8] - BI-oborot-sum-cost[2] ) / Bi-oborot-sum-cost[2] .
                   else Bi-oborot-{&bef-prc}[1] = 0.

  if i# = 8 then    if  Bo-oborot-sum-cost[2] <>  0 then
                        BO-oborot-{&bef-prc}[1] = 100 * (Bo-oborot-sum-sale[8] - Bo-oborot-sum-cost[2] ) / Bo-oborot-sum-cost[2] .
                   else BO-oborot-{&bef-prc}[1] = 0.

  if i# = 8 then    if  B1-oborot-sum-cost[2] <>  0 then
                        B1-oborot-{&bef-prc}[1] = 100 * (B1-oborot-sum-sale[8] - B1-oborot-sum-cost[2] ) / B1-oborot-sum-cost[2] .
                   else B1-oborot-{&bef-prc}[1] = 0.

  if i# = 8 then    if  B2-oborot-sum-cost[2] <>  0 then
                        B2-oborot-{&bef-prc}[1] = 100 * (B2-oborot-sum-sale[8] - B2-oborot-sum-cost[2] ) / B2-oborot-sum-cost[2] .
                   else B2-oborot-{&bef-prc}[1] = 0.
 End.
END PROCEDURE.

PROCEDURE Sum-i :
define input parameter ob like oborot-{&bef-tdedt_overturn}[1] no-undo.
define input parameter tt as int  no-undo.
define input-output parameter b1 like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter b2 like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter bi like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter bo like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.

define input parameter ob2 like oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter b1- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter b2- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter bi- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
define input-output parameter bo- like b1-oborot-{&bef-tdedt_overturn}[1] no-undo.
Assign
  B1 = B1 + ob
  B2 = B2 + ob
  B1- = B1- + ob2
  B2- = B2- + ob2
  Bi = Bi + ob
  Bo = Bo + ob
  Bi- = Bi- + ob2
  Bo- = Bo- + ob2
.
END PROCEDURE.

PROCEDURE Clear-item :
define variable kk as int no-undo.
 REPEAT kk = 1 to {&e-col} :
 Assign
    oborot-{&bef-TDEDT_Pri_Vnesh }                 [kk]    = 0
    oborot-{&bef-TDEDT_Ras_Vnesh }                 [kk]    = 0
    oborot-{&bef-TDEDT_RAS_Vnesh_VP }              [kk]    = 0
    oborot-{&bef-TDEDT_Ras_Vnesh_Kass }            [kk]    = 0
    oborot-{&bef-TDEDT_Vozvrat_Vnesh }             [kk]    = 0
    oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass }        [kk]    = 0
    oborot-{&bef-TDEDT_Spi_Vnesh }                 [kk]    = 0
    oborot-{&bef-TDEDT_Inv }                       [kk]    = 0
    oborot-{&bef-TDEDT_Pri_Perem }                 [kk]    = 0
    oborot-{&bef-TDEDT_Ras_Perem }                 [kk]    = 0
    oborot-{&bef-TDEDT_Vozvrat_Perem }             [kk]    = 0
    oborot-{&bef-TDEDT_Ras_Prvo }                  [kk]    = 0
    oborot-{&bef-TDEDT_Spi_Prvo }                  [kk]    = 0
    oborot-{&bef-TDEDT_Pri_Prvo }                  [kk]    = 0
    oborot-{&bef-TDEDT_Overturn }                  [kk]    = 0
    oborot-{&bef-disc }                            [kk]    = 0
    oborot-{&bef-eff  }                            [kk]    = 0
    oborot-{&bef-prc  }                            [kk]    = 0
    oborot-{&bef-TDEDT_Corr_Acc_Price}            [kk]    = 0
    oborot-{&bef-TDEDT_Chg_Purch_Code}            [kk]    = 0
    oborot-r-v                                    [kk]    = 0
    ostatok-end      [kk] =   0
    ostatok-start    [kk] =   0   .
       End.
 END PROCEDURE.

PROCEDURE Item-Goods :
 define input parameter  par-3 as char no-undo.
 define input parameter  par-4 as char no-undo.
 if line-counter( OutStream )  > page-size( OutStream ) then DO :
                 display STREAM OutStream    with frame top-frame .
                 display STREAM OutStream    with frame top-2 .
                 end.

     if par-4 = "goods":U  Then  assign
                gds-zap-unit-base  = goods.unit-base
                gds-zap-prt-root   = Goods.prt-root
                gds-zap-prod-type  = Goods.prod-type
                gds-zap-prod-code  = Goods.prod-code
                gds-zap-artic      = Goods.artic
                gds-zap-type       = Goods.gds-type
                gds-zap-grp-name   = Goods.grp-name
                gds-zap-b-code     = Goods.gds-code
                gds-zap-gds-name   = if g#gds-engl then Goods.engl-name
                                                    else Goods.gds-name.
     if par-4 = "gds-list":U  Then  assign
                  gds-zap-unit-base  = gds-list.unit-base
                  gds-zap-prt-root   = gds-list.prt-root
                  gds-zap-prod-type  = gds-list.prod-type
                  gds-zap-prod-code  = gds-list.prod-code
                  gds-zap-artic      = gds-list.artic
                  gds-zap-type       = gds-list.gds-type
                  gds-zap-grp-name   = gds-list.grp-name
                  gds-zap-b-code     = gds-list.gds-code
                  gds-zap-gds-name   = if g#gds-engl then Gds-list.engl-name
                                                      else Gds-list.gds-name.

  Run foreach  in this-procedure .
  { rep/r-obreak.i }
  Run display-line   in this-procedure .

END PROCEDURE.

Procedure Null-str-pr :
 if (
     oborot-{&bef-TDEDT_Pri_Prvo } [1]                  = 0 and
     oborot-{&bef-TDEDT_Spi_Prvo } [1]                  = 0 and
     oborot-{&bef-TDEDT_Ras_Prvo } [1]                  = 0 and
     oborot-{&bef-TDEDT_Pri_Vnesh}     [1]             = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh}                 [1] = 0  and
     oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [1] = 0  and
     oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [1] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [1] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [1] = 0  and
     oborot-{&bef-TDEDT_Spi_Vnesh}                 [1] = 0  and
     oborot-{&bef-TDEDT_Inv}                       [1] = 0  and
     oborot-{&bef-TDEDT_Pri_Perem }                 [1] = 0  and
     oborot-{&bef-TDEDT_Ras_Perem }                 [1] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Perem }             [1] = 0  and
     oborot-{&bef-TDEDT_Overturn }                  [2] = 0  and
     oborot-{&bef-TDEDT_Corr_Acc_Price}            [1]    = 0 and
     oborot-{&bef-TDEDT_Chg_Purch_Code}            [1]    = 0 and
     ostatok-end[1]                                     = 0  and
     ostatok-start[1]                                   = 0 and
     oborot-{&bef-TDEDT_Pri_Prvo } [2]                  = 0 and
     oborot-{&bef-TDEDT_Spi_Prvo } [2]                  = 0 and
     oborot-{&bef-TDEDT_Ras_Prvo } [2]                  = 0 and
     oborot-{&bef-TDEDT_Pri_Vnesh}     [2]             = 0 and
     oborot-{&bef-TDEDT_Ras_Vnesh}                [2] = 0  and
     oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [2] = 0  and
     oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [2] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [2] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [2] = 0  and
     oborot-{&bef-TDEDT_Spi_Vnesh}                 [2] = 0  and
     oborot-{&bef-TDEDT_Inv}                       [2] = 0  and
     oborot-{&bef-TDEDT_Pri_Perem }                 [2] = 0  and
     oborot-{&bef-TDEDT_Ras_Perem }                 [2] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Perem }             [2] = 0  and
      oborot-{&bef-TDEDT_Corr_Acc_Price}            [2]    = 0 and
     oborot-{&bef-TDEDT_Chg_Purch_Code}            [2]    = 0 and
     ostatok-end[2]                                     = 0  and
     ostatok-start[2]                                   = 0

      ) then   Null-str# = 0    .
END PROCEDURE.


Procedure Null-str-pr2 :
 if (
     oborot-{&bef-TDEDT_Pri_Prvo }                 [1] = 0 and
     oborot-{&bef-TDEDT_Spi_Prvo }                 [1] = 0 and
     oborot-{&bef-TDEDT_Ras_Prvo } [1]                  = 0 and
     oborot-{&bef-TDEDT_Pri_Vnesh}                 [1] = 0  and
     oborot-{&bef-TDEDT_Ras_Vnesh}                 [1] = 0  and
     oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [1] = 0  and
     oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [1] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [1] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [1] = 0  and
     oborot-{&bef-TDEDT_Spi_Vnesh}                 [1] = 0  and
     oborot-{&bef-TDEDT_Inv}                       [1] = 0  and
     oborot-{&bef-TDEDT_Pri_Perem }                [1] = 0  and
     oborot-{&bef-TDEDT_Ras_Perem }                [1] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Perem }            [1] = 0  and
     oborot-{&bef-TDEDT_Overturn }                 [1] = 0  and
     oborot-{&bef-TDEDT_Overturn }                 [2] = 0  and
    oborot-{&bef-TDEDT_Corr_Acc_Price}            [1]    = 0 and
    oborot-{&bef-TDEDT_Chg_Purch_Code}            [1]    = 0 and
     oborot-{&bef-TDEDT_Pri_Prvo }                 [2] = 0 and
     oborot-{&bef-TDEDT_Spi_Prvo }                 [2] = 0 and
     oborot-{&bef-TDEDT_Ras_Prvo } [2]                  = 0 and
     oborot-{&bef-TDEDT_Pri_Vnesh}                 [2] = 0  and
     oborot-{&bef-TDEDT_Ras_Vnesh}                 [2] = 0  and
     oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [2] = 0  and
     oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [2] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [2] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [2] = 0  and
     oborot-{&bef-TDEDT_Spi_Vnesh}                 [2] = 0  and
     oborot-{&bef-TDEDT_Inv}                       [2] = 0  and
     oborot-{&bef-TDEDT_Pri_Perem }                [2] = 0  and
     oborot-{&bef-TDEDT_Ras_Perem }                [2] = 0  and
     oborot-{&bef-TDEDT_Vozvrat_Perem }            [2] = 0  and
    oborot-{&bef-TDEDT_Corr_Acc_Price}            [2]    = 0 and
    oborot-{&bef-TDEDT_Chg_Purch_Code}            [2]    = 0

     ) then   Null-str2# = 0    .
END PROCEDURE.

Procedure b1-Null-str-pr :
 if (
     b1-oborot-{&bef-TDEDT_Pri_Prvo } [1]                  = 0 and
     b1-oborot-{&bef-TDEDT_Spi_Prvo } [1]                  = 0 and
     b1-oborot-{&bef-TDEDT_Ras_Prvo } [1]                  = 0 and
     b1-oborot-{&bef-TDEDT_Pri_Vnesh}     [1]             = 0 and
     b1-oborot-{&bef-TDEDT_Ras_Vnesh}                 [1] = 0  and
     b1-oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [1] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [1] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [1] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [1] = 0  and
     b1-oborot-{&bef-TDEDT_Spi_Vnesh}                 [1] = 0  and
     b1-oborot-{&bef-TDEDT_Inv}                       [1] = 0  and
     b1-oborot-{&bef-TDEDT_Pri_Perem }                 [1] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Perem }                 [1] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Perem }             [1] = 0  and
     b1-oborot-{&bef-TDEDT_Overturn }                  [2] = 0  and
     b1-oborot-{&bef-TDEDT_Corr_Acc_Price}            [1]    = 0 and
     b1-oborot-{&bef-TDEDT_Chg_Purch_Code}            [1]    = 0 and
     b1-ostatok-end[1]                                     = 0  and
     b1-ostatok-start[1]                                   = 0  and
     b1-oborot-{&bef-TDEDT_Pri_Prvo } [2]                  = 0 and
     b1-oborot-{&bef-TDEDT_Spi_Prvo } [2]                  = 0 and
     b1-oborot-{&bef-TDEDT_Ras_Prvo } [2]                  = 0 and
     b1-oborot-{&bef-TDEDT_Pri_Vnesh}     [2]             = 0 and
     b1-oborot-{&bef-TDEDT_Ras_Vnesh}                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [2] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [2] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [2] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [2] = 0  and
     b1-oborot-{&bef-TDEDT_Spi_Vnesh}                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Inv}                       [2] = 0  and
     b1-oborot-{&bef-TDEDT_Pri_Perem }                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Perem }                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Perem }             [2] = 0  and
     b1-oborot-{&bef-TDEDT_Corr_Acc_Price}            [2]    = 0 and
     b1-oborot-{&bef-TDEDT_Chg_Purch_Code}            [2]    = 0 and
     b1-ostatok-end[2]                                     = 0  and
     b1-ostatok-start[2]                                   = 0

     ) then  b1-Null-str# = 0    .
END PROCEDURE.


Procedure b1-Null-str-pr2 :
 if (
     b1-oborot-{&bef-TDEDT_Pri_Prvo }                 [1] = 0 and
     b1-oborot-{&bef-TDEDT_Spi_Prvo }                 [1] = 0 and
     b1-oborot-{&bef-TDEDT_Ras_Prvo }                 [1] = 0 and
     b1-oborot-{&bef-TDEDT_Pri_Vnesh}                 [1] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Vnesh}                 [1] = 0  and
     b1-oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [1] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [1] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [1] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [1] = 0  and
     b1-oborot-{&bef-TDEDT_Spi_Vnesh}                 [1] = 0  and
     b1-oborot-{&bef-TDEDT_Inv}                       [1] = 0  and
     b1-oborot-{&bef-TDEDT_Pri_Perem }                [1] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Perem }                [1] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Perem }            [1] = 0  and
     b1-oborot-{&bef-TDEDT_Overturn }                 [1] = 0  and
     b1-oborot-{&bef-TDEDT_Corr_Acc_Price}            [1] = 0  and
     b1-oborot-{&bef-TDEDT_Chg_Purch_Code}            [1] = 0  and
     b1-oborot-{&bef-TDEDT_Overturn }                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Pri_Prvo }                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Spi_Prvo }                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Prvo }                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Pri_Vnesh}                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Vnesh}                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [2] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [2] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [2] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [2] = 0  and
     b1-oborot-{&bef-TDEDT_Spi_Vnesh}                 [2] = 0  and
     b1-oborot-{&bef-TDEDT_Inv}                       [2] = 0  and
     b1-oborot-{&bef-TDEDT_Pri_Perem }                [2] = 0  and
     b1-oborot-{&bef-TDEDT_Ras_Perem }                [2] = 0  and
     b1-oborot-{&bef-TDEDT_Vozvrat_Perem }            [2] = 0  and
     b1-oborot-{&bef-TDEDT_Corr_Acc_Price}            [2] = 0  and
     b1-oborot-{&bef-TDEDT_Chg_Purch_Code}            [2] = 0

     ) then   b1-Null-str2# = 0    .
    END PROCEDURE.
Procedure b2-Null-str-pr :
 if (
     b2-oborot-{&bef-TDEDT_Pri_Prvo } [1]                  = 0 and
     b2-oborot-{&bef-TDEDT_Spi_Prvo } [1]                  = 0 and
     b2-oborot-{&bef-TDEDT_Ras_Prvo } [1]                  = 0 and
     b2-oborot-{&bef-TDEDT_Pri_Vnesh}     [1]             = 0 and
     b2-oborot-{&bef-TDEDT_Ras_Vnesh}                 [1] = 0  and
     b2-oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [1] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [1] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [1] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [1] = 0  and
     b2-oborot-{&bef-TDEDT_Spi_Vnesh}                 [1] = 0  and
     b2-oborot-{&bef-TDEDT_Inv}                       [1] = 0  and
     b2-oborot-{&bef-TDEDT_Pri_Perem }                 [1] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Perem }                 [1] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Perem }             [1] = 0  and
     b2-oborot-{&bef-TDEDT_Overturn }                  [2] = 0  and
     b2-oborot-{&bef-TDEDT_Corr_Acc_Price}            [1]    = 0 and
     b2-oborot-{&bef-TDEDT_Chg_Purch_Code}            [1]    = 0 and
     b2-ostatok-end[1]                                     = 0  and
     b2-ostatok-start[1]                                   = 0  and
     b2-oborot-{&bef-TDEDT_Pri_Prvo } [2]                  = 0 and
     b2-oborot-{&bef-TDEDT_Spi_Prvo } [2]                  = 0 and
     b2-oborot-{&bef-TDEDT_Ras_Prvo } [2]                  = 0 and
     b2-oborot-{&bef-TDEDT_Pri_Vnesh}     [2]             = 0 and
     b2-oborot-{&bef-TDEDT_Ras_Vnesh}                 [2] = 0  and
     b2-oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [2] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [2] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [2] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [2] = 0  and
     b2-oborot-{&bef-TDEDT_Spi_Vnesh}                 [2] = 0  and
     b2-oborot-{&bef-TDEDT_Inv}                       [2] = 0  and
     b2-oborot-{&bef-TDEDT_Pri_Perem }                 [2] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Perem }                 [2] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Perem }             [2] = 0  and
     b2-oborot-{&bef-TDEDT_Corr_Acc_Price}             [2]    = 0 and
     b2-oborot-{&bef-TDEDT_Chg_Purch_Code}             [2]    = 0 and
     b2-ostatok-end[2]                                     = 0  and
     b2-ostatok-start[2]                                   = 0

     ) then  b2-Null-str# = 0    .
END PROCEDURE.


Procedure b2-Null-str-pr2 :
 if (
     b2-oborot-{&bef-TDEDT_Pri_Prvo }                 [1] = 0 and
     b2-oborot-{&bef-TDEDT_Spi_Prvo }                 [1] = 0 and
     b2-oborot-{&bef-TDEDT_Ras_Prvo } [1]                  = 0 and
     b2-oborot-{&bef-TDEDT_Pri_Vnesh}                 [1] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Vnesh}                 [1] = 0  and
     b2-oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [1] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [1] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [1] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [1] = 0  and
     b2-oborot-{&bef-TDEDT_Spi_Vnesh}                 [1] = 0  and
     b2-oborot-{&bef-TDEDT_Inv}                       [1] = 0  and
     b2-oborot-{&bef-TDEDT_Pri_Perem }                [1] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Perem }                [1] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Perem }            [1] = 0  and
     b2-oborot-{&bef-TDEDT_Overturn }                 [1] = 0  and
     b2-oborot-{&bef-TDEDT_Corr_Acc_Price}            [1]    = 0 and
     b2-oborot-{&bef-TDEDT_Chg_Purch_Code}            [1]    = 0 and
     b2-oborot-{&bef-TDEDT_Overturn }                 [2] = 0 and
     b2-oborot-{&bef-TDEDT_Pri_Prvo }                 [2] = 0 and
     b2-oborot-{&bef-TDEDT_Spi_Prvo }                 [2] = 0 and
     b2-oborot-{&bef-TDEDT_Ras_Prvo } [2]                 = 0 and
     b2-oborot-{&bef-TDEDT_Pri_Vnesh}                 [2] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Vnesh}                 [2] = 0  and
     b2-oborot-{&bef-TDEDT_RAS_Vnesh_VP}              [2] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Vnesh_Kass}            [2] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Vnesh}             [2] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Vnesh_Kass}        [2] = 0  and
     b2-oborot-{&bef-TDEDT_Spi_Vnesh}                 [2] = 0  and
     b2-oborot-{&bef-TDEDT_Inv}                       [2] = 0  and
     b2-oborot-{&bef-TDEDT_Pri_Perem }                [2] = 0  and
     b2-oborot-{&bef-TDEDT_Ras_Perem }                [2] = 0  and
     b2-oborot-{&bef-TDEDT_Vozvrat_Perem }            [2] = 0  and
     b2-oborot-{&bef-TDEDT_Overturn }                 [2] = 0  and
     b2-oborot-{&bef-TDEDT_Corr_Acc_Price}            [2]    = 0 and
     b2-oborot-{&bef-TDEDT_Chg_Purch_Code}            [2]    = 0
      ) then   b2-Null-str2# = 0    .
END PROCEDURE.

PROCEDURE PRICE-VAT :
define input parameter PP as character no-undo .
if pp = '' THEN DO:
      { rep/di-qnty3.i v-name-type  2  " " " " " " " " " " {3} }  End.
run PRICE-VAT-1 (pp).
END PROCEDURE.

PROCEDURE PRICE-VAT-1 :
define input parameter PP as character no-undo .
if pp = 'Bi' THEN DO:
    { rep/di-qnty3.i v-name-type  2  "''"  "''"  "''"  "''"  Bi- {3} } End.
run PRICE-VAT-2(pp).
END PROCEDURE.

PROCEDURE PRICE-VAT-2 :
define input parameter PP as character no-undo .
if pp = 'Bo' THEN DO:
    { rep/di-qnty3.i v-name-type  2  "''"  "''"  "''"  "''"  Bo- {3} } End.
run PRICE-VAT-3(pp).
END PROCEDURE.

PROCEDURE PRICE-VAT-3 :
define input parameter PP as character no-undo .
if pp =  'B1' THEN DO:
    { rep/di-qnty3.i v-name-type  2  "''"  "''"  "''"  "''"  B1- {3} } End.
run PRICE-VAT-4(pp).
END PROCEDURE.

PROCEDURE PRICE-VAT-4 :
define input parameter PP as character no-undo .
if pp =   'B2' THEN DO:
    { rep/di-qnty3.i v-name-type  2  "''"  "''"  "''"  "''"  B2- {3} }
/*    DISPLAY stream  OutStream  {&WFz} .*/
End.
END PROCEDURE.

{ rep/procobor.i pp {3} }
{ rep/procobor.i find-last-prise-med }
{ rep/procobor.i find-mediator }
{ rep/ost-line.i {2} {2}}
{ rep/ostatok.i }
{ rep/obr-runn.i {1} {2} {3}  }
{ rep/procobor.i ob-line-stk }

procedure create-pul:
end procedure.

procedure calc-ms-wt :

define input        parameter p-oborot-num      as decimal   no-undo .
define input        parameter p-gds-wt-ms-base  as decimal   no-undo .
define input-output parameter p-oborot          as decimal   no-undo .
define input-output parameter p-bi-oborot       as decimal   no-undo .
define input-output parameter p-bo-oborot       as decimal   no-undo .
define input-output parameter p-b1-oborot       as decimal   no-undo .
define input-output parameter p-b2-oborot       as decimal   no-undo .

do
on error undo, return error return-value
:
if p-is-petrol = true then return .
  assign
    p-oborot    = p-oborot-num * p-gds-wt-ms-base
    p-bi-oborot = p-bi-oborot + p-oborot
    p-bo-oborot = p-bo-oborot + p-oborot
    p-b1-oborot = p-b1-oborot + p-oborot
    p-b2-oborot = p-b2-oborot + p-oborot
  .
end.
end procedure. /* calc-ms-wt */

procedure calc-pt-ob :
define input  parameter p-ext-doc-type  as character no-undo .
define input  parameter x-store-type as character no-undo .
define input  parameter x-store-code as integer   no-undo .
define input  parameter p-artic         as character no-undo .
define input  parameter p-prod-type     as character no-undo .
define input  parameter p-prod-code     as integer   no-undo .
define input-output parameter p-oborot          as decimal   no-undo .
define input-output parameter p-bi-oborot       as decimal   no-undo .
define input-output parameter p-bo-oborot       as decimal   no-undo .
define input-output parameter p-b1-oborot       as decimal   no-undo .
define input-output parameter p-b2-oborot       as decimal   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-oborot as decimal   no-undo .
define buffer buf_inv-line for ub.inv-line  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf1_obj-list for obj-list .
v-oborot = 0 .
if p-is-petrol = false   then return .
  for each buf1_obj-list no-lock :

   if  xtog-obj then
       if   not(x-store-type     = buf1_obj-list.obj-type
            and x-store-code     = buf1_obj-list.obj-code ) then next.

    for each buf_doc-line  no-lock where
          buf_doc-line.obj-type     = buf1_obj-list.obj-type and
          buf_doc-line.obj-code     = buf1_obj-list.obj-code and
          buf_doc-line.artic        = p-artic and
          buf_doc-line.prod-type    = p-prod-type and
          buf_doc-line.prod-code    = p-prod-code and
          buf_doc-line.ext-doc-type = p-ext-doc-type and
          buf_doc-line.status_      = {&fact}        and
          buf_doc-line.fact-order   <= fact-order-2  and
          buf_doc-line.fact-order   >= fact-order-1
          :
          for each buf_inv-line no-lock where
                  buf_inv-line.doc-code  =  buf_doc-line.doc-code  and
                  buf_inv-line.artic     =  buf_doc-line.artic     and
                  buf_inv-line.prod-type =  buf_doc-line.prod-type and
                  buf_inv-line.prod-code =  buf_doc-line.prod-code
                  :
                  if p-ext-doc-type = {&tdedt_inv}  then v-oborot = v-oborot + buf_doc-line.cli-qnty .
                      else do:
                      if p-ext-doc-type = {&tdedt_Spi_Vnesh}    or
                         p-ext-doc-type = {&tdedt_Ras_Vnesh}    or
                         p-ext-doc-type = {&tdedt_Ras_Perem}    or
                         p-ext-doc-type = {&tdedt_Ras_Vnesh_VP} or
                         p-ext-doc-type = {&tdedt_Ras_Prvo}     or
                         p-ext-doc-type = {&tdedt_Spi_Prvo}     or
                         p-ext-doc-type = {&tdedt_Ras_Vnesh_Kass}   then
                           v-oborot = v-oborot - buf_inv-line.wast-cli-qnty .
                           else v-oborot = v-oborot + buf_inv-line.wast-cli-qnty .

                      end.
          end.
    end.
    assign
      p-oborot    = v-oborot
      p-bi-oborot = p-bi-oborot + p-oborot
      p-bo-oborot = p-bo-oborot + p-oborot
      p-b1-oborot = p-b1-oborot + p-oborot
      p-b2-oborot = p-b2-oborot + p-oborot
    .

end.
end.
end procedure. /* calc-pt-ob */


/* $Workfile$ e n d */