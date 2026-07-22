block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: docsrepo.p $
$Archive: rep/docsrepo.p $

Печать документов из списка документов стара

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06


A u t h o r :  Черных

*/

define input  parameter p-title             as character no-undo .
define input  parameter pVal-BruttoSaleSum  as logical   no-undo .
define input  parameter pRubl-BruttoSaleSum as logical   no-undo .
define input  parameter pVal-NettoSaleSum   as logical   no-undo .
define input  parameter pRubl-NettoSaleSum  as logical   no-undo .
define input  parameter pVal-DiscntSum      as logical   no-undo .
define input  parameter pRubl-DiscntSum     as logical   no-undo .
define input  parameter pVal-CostSum        as logical   no-undo .
define input  parameter pRubl-CostSum       as logical   no-undo .
define input  parameter pVal-Effect         as logical   no-undo .
define input  parameter pRubl-Effect        as logical   no-undo .
define input  parameter pDiscnt-PC          as logical   no-undo .
define input  parameter pTorgPred           as logical   no-undo .
define input  parameter pUp-PC              as logical   no-undo .
define input  parameter pOperator           as logical   no-undo .
define input  parameter pPayType            as logical   no-undo .
define input  parameter pKurs               as logical   no-undo .
define input  parameter pOur-Obj            as logical   no-undo .
define input  parameter pKladov             as logical   no-undo .
define input  parameter pIspName            as logical   no-undo .
define input  parameter pPayWaitDate        as logical   no-undo .
define input  parameter pNDS-Val            as logical   no-undo .
define input  parameter pNDS-Rubl           as logical   no-undo .
define input  parameter pNums               as logical   no-undo .
define input  parameter p-continue          as logical   no-undo .
define input  parameter g#report-num        as integer   no-undo .
define output parameter p-frame-width       as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: docsrepo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/docsrepo.p $":U .
define variable vss-description as character no-undo init " Печать документов из списка документов стара     ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-pril.i   }
{ rep/wt-docs.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ cmp/r-page1.i new }
{ rep/dincol.i def }
{ rep/opclexcl.i }

DEFINE stream DocsStream .


define buffer  b-wt-docs           for     wt-docs .

define variable DifferentTypes      as logical   no-undo .
define variable Line                as character no-undo .
define variable By-Opt              as character no-undo .
define variable sym1                as character no-undo init ":" .
define variable sym10               as character no-undo init ":" .
define variable i                   as integer   no-undo .
define variable Qnty                as decimal   no-undo .
define variable Val-BruttoSaleSum   as decimal   no-undo .
define variable Rubl-BruttoSaleSum  as decimal   no-undo .
define variable Val-NettoSaleSum    as decimal   no-undo .
define variable Rubl-NettoSaleSum   as decimal   no-undo .
define variable Val-DiscntSum       as decimal   no-undo .
define variable Rubl-DiscntSum      as decimal   no-undo .
define variable Val-CostSum         as decimal   no-undo .
define variable Rubl-CostSum        as decimal   no-undo .
define variable Val-Effect          as decimal   no-undo .
define variable Rubl-Effect         as decimal   no-undo .
define variable Discnt-PC           as character no-undo .
define variable TorgPred            as character no-undo .
define variable Up-PC               as character no-undo .
define variable Operator            as character no-undo .
define variable PayType             as character no-undo .
define variable Kurs                as decimal   no-undo .
define variable Our-Obj             as character no-undo .
define variable KladovName          as character no-undo .
define variable IspName             as character no-undo .
define variable PayWaitDate         as date      no-undo .
define variable NDS-Val             as decimal   no-undo .
define variable NDS-Rubl            as decimal   no-undo .
define variable v-ind               as integer   no-undo .
DEFINE VARIABLE for-doc-attr like   wt-docs.doc-attr no-undo .
DEFINE VARIABLE for-doc-date like   wt-docs.doc-date no-undo .
DEFINE VARIABLE for-fact-date like  wt-docs.fact-date no-undo .
DEFINE VARIABLE for-doc-code like   wt-docs.doc-code no-undo .
DEFINE VARIABLE for-cli-name like   wt-docs.cli-name no-undo .

DEFINE VARIABLE fill8               as character no-undo .
DEFINE VARIABLE fill11              as character no-undo .
DEFINE VARIABLE fill12              as character no-undo .
DEFINE VARIABLE fill15              as character no-undo .
DEFINE VARIABLE fill18              as character no-undo .
DEFINE VARIABLE fill19              as character no-undo .
DEFINE VARIABLE fill21              as character no-undo .

&SCOPED-DEFINE DISPLAY-FRAME        DISPLAY stream  DOcsStream ~
                                    with frame x1. ~
                                    DOWN 1 stream   DOcsStream ~
                                    with frame x1.

&SCOPED-DEFINE DOWN-FRAME            DOWN 1 stream DOcsStream with x1.
&SCOPED-DEFINE DOWN-EXCEL            ~{&PutExcel} skip.


&scop din-label-height 4


/*ОСНОВНАЯ ФОРМА*/
DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 5 NO-UNDO.

DEFINE FRAME top-frame
t-1       AT ROW 1 COL 1 no-label
HEADER
cur-time-print() AT 5 format "x(35)"
string( "Страница" ) AT 45 PAGE-NUMBER( DOcsStream ) AT 55 FORMAT ">>>,>>9" SKIP
    with width {&DOS_CW_2} down stream-io use-text NO-BOX.

DEFINE FRAME x1
with width {&DOS_CW_2} down stream-io use-text NO-BOX.

assign
  use-column[1] =  yes
  use-column[2] =  yes
  use-column[3] =  yes
  use-column[4] =  yes
  use-column[5] =  yes
  use-column[6] =  pNums
  use-column[7] =  pVal-BruttoSaleSum
  use-column[8] =  pRubl-BruttoSaleSum
  use-column[9] =  pVal-NettoSaleSum
  use-column[10] = pRubl-NettoSaleSum
  use-column[11] = pVal-DiscntSum
  use-column[12] = pRubl-DiscntSum
  use-column[13] = pVal-CostSum
  use-column[14] = pRubl-CostSum
  use-column[15] = pVal-Effect
  use-column[16] = pRubl-Effect
  use-column[17] = pNDS-VAL
  use-column[18] = pNDs-RUbl
  use-column[19] = PDiscnt-PC
  use-column[20] = pUP-pc
  use-column[21] = pTOrgPred
  use-column[22] = pOperator
  use-column[23] = PKladov
  use-column[24] = pIspName
  use-column[25] = pPayType
  use-column[26] = pKurs
  use-column[27] = pOur-Obj
  use-column[28] = pPayWaitDate
.

assign
  fill8  = fill("-", 8)
  fill11 = fill("-", 11)
  fill12 = fill("-", 12)
  fill15 = fill("-", 15)
  fill18 = fill("-", 18)
  fill19 = fill("-", 19)
  fill21 = fill("-", 21)
.

FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.

FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.



assign
ReportName = p-title
sheetf.Excel-Column-Lable =  ""
sheetf.sizes = ""
Make-Excel = yes.
.

CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .

l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=4 l-col-format= "x(4)"            l-col-lable="Док. атр.".
  { rep/dincol.i cr  1    for-doc-attr      x1                }
  { rep/dincol.i crx 1 }

Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/9999"            l-col-lable="Дата создания".
  { rep/dincol.i cr  2    for-doc-date      x1                }
  { rep/dincol.i crx 2 }

Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/9999"            l-col-lable="Дата закрытия".
  { rep/dincol.i cr  3    for-fact-date      x1                }
  { rep/dincol.i crx 3 }

Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"            l-col-lable="Номер документа".
  { rep/dincol.i cr  4    for-doc-code      x1                }
  { rep/dincol.i crx 4 }

Assign l-col-type="CHARACTER" l-col-len=40 l-col-format= "x(40)"            l-col-lable="Контрагент".
  { rep/dincol.i cr  5    for-cli-name      x1                }
  { rep/dincol.i crx 5 }
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format= "->>>>,>>9.99"            l-col-lable="Количество".
  { rep/dincol.i cr  6    Qnty      x1                }
  { rep/dincol.i crx 6 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма док. цен (без скидки) (б.вал.)".
  { rep/dincol.i cr  7    Val-BruttoSaleSum      x1                }
  { rep/dincol.i crx 7 }
Assign l-col-type="DECIMAL" l-col-len=21 l-col-format= "->,>>>,>>>,>>>,>>9.99"   l-col-lable="Сумма док. цен (без скидки) ({&abbr_rub_allshift})".
  { rep/dincol.i cr  8    Rubl-BruttoSaleSum      x1                }
  { rep/dincol.i crx 8 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма док. цен (со скидкой) (б.вал.)".
  { rep/dincol.i cr  9    Val-NettoSaleSum      x1                }
  { rep/dincol.i crx 9 }
Assign l-col-type="DECIMAL" l-col-len=21 l-col-format= "->,>>>,>>>,>>>,>>9.99"   l-col-lable="Сумма док. цен (со скидкой) ({&abbr_rub_allshift})".
  { rep/dincol.i cr  10    Rubl-NettoSaleSum      x1                }
  { rep/dincol.i crx 10 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма скидок (б.вал.)".
  { rep/dincol.i cr  11    Val-DiscntSum      x1                }
  { rep/dincol.i crx 11 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма скидок ({&abbr_rub_allshift})".
  { rep/dincol.i cr  12    Rubl-DiscntSum      x1                }
  { rep/dincol.i crx 12 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма учетных цен (б.вал.)".
  { rep/dincol.i cr  13    Val-CostSum      x1                }
  { rep/dincol.i crx 13 }
Assign l-col-type="DECIMAL" l-col-len=19 l-col-format= "->>>,>>>,>>>,>>9.99"     l-col-lable="Сумма учетных цен ({&abbr_rub_allshift})".
  { rep/dincol.i cr  14    Rubl-CostSum      x1                }
  { rep/dincol.i crx 14 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Эффективность (б.вал.)".
  { rep/dincol.i cr  15    Val-Effect      x1                }
  { rep/dincol.i crx 15 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Эффективность ({&abbr_rub_allshift})".
  { rep/dincol.i cr  16    Rubl-Effect      x1                }
  { rep/dincol.i crx 16 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС (б.вал.)".
  { rep/dincol.i cr  17    NDS-val      x1                }
  { rep/dincol.i crx 17 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС ({&abbr_rub_allshift})".
  { rep/dincol.i cr  18    NDS-Rubl      x1                }
  { rep/dincol.i crx 18 }
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "x(8)"                   l-col-lable="Процент скидки".
  { rep/dincol.i cr  19    Discnt-Pc      x1                }
  { rep/dincol.i crx 19 }
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "x(8)"                   l-col-lable="Процент фактич. наценки".

  { rep/dincol.i cr  20    Up-Pc      x1                }
  { rep/dincol.i crx 20 }
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Торговый представитель".
  { rep/dincol.i cr  21    TorgPred      x1                }
  { rep/dincol.i crx 21 }
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Оператор".

  { rep/dincol.i cr  22    Operator      x1                }
  { rep/dincol.i crx 22 }

Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Кладовщик".
  { rep/dincol.i cr  23    KladovName      x1                }
  { rep/dincol.i crx 23 }
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Исполнитель".
  { rep/dincol.i cr  24    IspName      x1                }
  { rep/dincol.i crx 24 }
Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"                 l-col-lable="Вид оплаты".
  { rep/dincol.i cr  25    PayType      x1                }
  { rep/dincol.i crx 25 }
Assign l-col-type="DECIMAL" l-col-len=11 l-col-format= "->>>,>>9.<<"             l-col-lable="Курс".
  { rep/dincol.i cr  26    Kurs      x1                }
  { rep/dincol.i crx 26 }
Assign l-col-type="CHARACTER" l-col-len=18 l-col-format= "x(18)"                 l-col-lable="Свой объект".
  { rep/dincol.i cr  27    Our-Obj     x1                }
  { rep/dincol.i crx 27 }

Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/9999"                 l-col-lable="Дата ожид-мой оплаты".
  { rep/dincol.i cr  28    PayWaitDate     x1                }
  { rep/dincol.i crx 28 }

assign
p-frame-width = l-col-pos - 1
Line = fill("-", p-frame-width)
.
if p-frame-width > 137 and p-frame-width <= {&DOS_CW_2}  then do:
{ cmp/open-out.i stream DocsStream  " "  {&LS_PS_A4} }
end.
else do:
{ cmp/open-out.i stream DocsStream }
end.

if Make-Excel then
run openforexcel in this-procedure .



FORM with FRAME x1 .

FORM HEADER
Line format "X(76)" AT 1 SKIP
"Продолжение на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .

VIEW stream DocsStream FRAME BottomFrame .
PUT stream DocsStream SPACE(10) p-title format "X(125)" SKIP(2).

display STREAM DOcsStream

with frame top-Frame .
run rep/extitle.p ( 1 ).

FIND FIRST wt-docs NO-LOCK .
if can-find( first b-wt-docs where b-wt-docs.doc-type <> wt-docs.doc-type ) then do:
  assign
    DifferentTypes = TRUE
  .
end.


run waitfram-show in this-procedure ( "Печать списка документов " ) .

assign
  v-ind = 0
.

FOR EACH wt-docs with frame x1
:
  assign
    v-ind = v-ind + 1
  .
  if v-ind modulo 10 = 0
  then do:
    run waitfram-show ( "Печать списка документов " + string( v-ind ) ) .
  end.

  if wt-docs.status_ <> {&fact} then do:
    for each doc-line no-lock
      where doc-line.doc-code = wt-docs.doc-code
    :
        accumulate
          doc-line.doc-qnty * doc-line.price-base ( total )
          doc-line.doc-qnty * doc-line.price-rubl ( total )
        .
    end.
  end.

  assign
                Qnty = ( if can-do( {&fact}, wt-docs.status_ )
                             then wt-docs.fact-qnty else wt-docs.doc-qnty )
                Val-BruttoSaleSum =
                    ( if can-do( {&inventory}, wt-docs.doc-type )
                      then ( if can-do( {&fact}, wt-docs.status_ )
                                then wt-docs.tot-doc
                                else 0 )
                      else ( if can-do( {&income}, wt-docs.doc-type ) AND ( NOT wt-docs.internal )
                                then ( if can-do( {&fact}, wt-docs.status_ )
                                          then wt-docs.fact-base
                                          else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-base ) )
                                else ( if can-do( {&fact}, wt-docs.status_ )
                                          then ( wt-docs.tot-fact /* + wt-docs.tot-ov */ )
                                          else wt-docs.tot-doc ) ) )
                Rubl-BruttoSaleSum =
                    ( if can-do( {&inventory}, wt-docs.doc-type )
                      then 0
                      else ( if can-do( {&income}, wt-docs.doc-type ) AND ( NOT wt-docs.internal )
                                then ( if can-do( {&fact}, wt-docs.status_ )
                                          then wt-docs.fact-rubl
                                          else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-rubl ) )
                                else ( if can-do( {&fact}, wt-docs.status_ )
                                          then wt-docs.tot-sale
                                          else wt-docs.tot-rubl ) ) )
                Val-NettoSaleSum =
                    ( if can-do( {&inventory}, wt-docs.doc-type )
                      then ( if can-do( {&fact}, wt-docs.status_ )
                                then wt-docs.tot-doc
                                else 0 )
                      else ( if can-do( {&income}, wt-docs.doc-type ) AND ( NOT wt-docs.internal )
                                then ( if can-do( {&fact}, wt-docs.status_ )
                                          then wt-docs.fact-base
                                          else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-base ) )
                                else ( wt-docs.tot-fact - wt-docs.tot-calc ) ) )
                Rubl-NettoSaleSum =
                    ( if can-do( {&inventory}, wt-docs.doc-type )
                      then ( if can-do( {&fact}, wt-docs.status_ )
                                then wt-docs.tot-rubl
                                else 0 )
                      else ( if can-do( {&income}, wt-docs.doc-type ) AND ( NOT wt-docs.internal )
                                then ( if can-do( {&fact}, wt-docs.status_ )
                                          then wt-docs.fact-rubl
                                          else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-rubl ) )
                                else ( wt-docs.tot-sale - wt-docs.discnt-rubl ) ) )
                Val-DiscntSum = ( if can-do( {&inventory}, wt-docs.doc-type ) OR
                                                ( can-do( {&income}, wt-docs.doc-type ) AND ( NOT wt-docs.internal ) )
                                             then 0    else wt-docs.tot-calc )
                Rubl-DiscntSum = ( if can-do( {&inventory}, wt-docs.doc-type ) OR
                                                ( can-do( {&income}, wt-docs.doc-type ) AND ( NOT wt-docs.internal ) )
                                                then 0     else wt-docs.discnt-rubl )
                Val-CostSum = ( if can-do( {&inventory}, wt-docs.doc-type )
                                          then ( if can-do( {&fact}, wt-docs.status_ )
                                                    then wt-docs.fact-base     else 0 )
                                          else ( if can-do( {&fact}, wt-docs.status_ )
                                                    then wt-docs.fact-base
                                                    else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-base ) ) )
                Rubl-CostSum =
                    ( if can-do( {&inventory}, wt-docs.doc-type )
                      then ( if can-do( {&fact}, wt-docs.status_ )
                                then wt-docs.fact-rubl
                                else 0 )
                      else ( if can-do( {&fact}, wt-docs.status_ )
                                then wt-docs.fact-rubl
                                else ( ACCUM TOTAL doc-line.doc-qnty * doc-line.price-rubl ) ) )
                NDS-Val = wt-docs.VAT-base
                NDS-Rubl = wt-docs.VAT-rubl
                TorgPred = wt-docs.Mngr_Name
                Operator = wt-docs.Oper_Name
                PayType = wt-docs.pay-name
                Kurs = wt-docs.Course
                Our-Obj = wt-docs.OurObjectName
                KladovName = wt-docs.Wrkr_name
                IspName = wt-docs.Isp-Name
                PayWaitDate = wt-docs.pay-waitdate
                .
        if Qnty = ? then Qnty = 0 .
        if Val-BruttoSaleSum = ? then Val-BruttoSaleSum = 0 .
        if Rubl-BruttoSaleSum = ? then Rubl-BruttoSaleSum = 0 .
        if Val-NettoSaleSum = ? then Val-NettoSaleSum = 0 .
        if Rubl-NettoSaleSum = ? then Rubl-NettoSaleSum = 0 .
        if Val-DiscntSum = ? then Val-DiscntSum = 0 .
        if Rubl-DiscntSum = ? then Rubl-DiscntSum = 0 .
        if Val-CostSum = ? then Val-CostSum = 0 .
        if Rubl-CostSum = ? then Rubl-CostSum = 0 .
        if NDS-Val = ? then NDS-Val = 0 .
        if NDS-Rubl = ? then NDS-Rubl = 0 .
        if DifferentTypes AND can-do( {&expense_write-off}, wt-docs.doc-type ) then do:
            assign
                Qnty = - Qnty
                Val-BruttoSaleSum = - Val-BruttoSaleSum
                Rubl-BruttoSaleSum = - Rubl-BruttoSaleSum
                Val-NettoSaleSum = - Val-NettoSaleSum
                Rubl-NettoSaleSum = - Rubl-NettoSaleSum
                Val-DiscntSum = - Val-DiscntSum
                Rubl-DiscntSum = - Rubl-DiscntSum
                Val-CostSum = - Val-CostSum
                Rubl-CostSum = - Rubl-CostSum
                NDS-Val = - NDS-Val
                NDS-Rubl = - NDS-Rubl .
        end.
        if DifferentTypes then do:
            if NOT wt-docs.internal then
                CASE wt-docs.doc-type :
                    when {&expense} OR when {&return} then
                        assign
                            Val-Effect = - ( Val-NettoSaleSum - Val-CostSum )
                            Rubl-Effect = - ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                    when {&write-off} then
                        assign
                            Val-Effect = Val-CostSum
                            Rubl-Effect = Rubl-CostSum .
                    when {&inventory} then
                        if can-do( {&fact}, wt-docs.status_ ) AND ( wt-docs.tot-doc <> 0 ) then
                            assign
                                Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                                Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        else
                            assign     Val-Effect = 0    Rubl-Effect = 0 .
                    otherwise
                        assign     Val-Effect = 0    Rubl-Effect = 0 .
                END CASE .
            else
                assign      Val-Effect = 0    Rubl-Effect = 0 .
        end.
        else do:
            if NOT wt-docs.internal then
                CASE wt-docs.doc-type :
                    when {&expense} then
                        assign
                            Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                            Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        when {&write-off} then
                            assign
                                Val-Effect = - Val-CostSum
                                Rubl-Effect = - Rubl-CostSum .
                        when {&return} then
                            assign
                                Val-Effect = - ( Val-NettoSaleSum - Val-CostSum )
                                Rubl-Effect = - ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                        when {&inventory} then
                            if can-do( {&fact}, wt-docs.status_ ) AND ( wt-docs.tot-doc <> 0 ) then
                                assign
                                    Val-Effect = ( Val-NettoSaleSum - Val-CostSum )
                                    Rubl-Effect = ( Rubl-NettoSaleSum - Rubl-CostSum ) .
                            else
                                assign     Val-Effect = 0    Rubl-Effect = 0 .
                        otherwise
                            assign     Val-Effect = 0    Rubl-Effect = 0 .
                    END CASE .
            else
                assign      Val-Effect = 0    Rubl-Effect = 0 .
        end.

        if Val-BruttoSaleSum <> 0 then do:
            if ( ( Val-DiscntSum / Val-BruttoSaleSum ) < 100 ) AND
               ( ( Val-DiscntSum / Val-BruttoSaleSum ) > -100 ) then
                Discnt-PC =
                    string( Val-DiscntSum / Val-BruttoSaleSum * 100 , "->>>9.9" ) + "%" .
            else
                if ( Val-DiscntSum / Val-BruttoSaleSum < -99.99 ) then
                    Discnt-PC = string( -9999.9 , "->>>9.9" ) + "%" .
                else
                    Discnt-PC = string( 9999.9 , "->>>9.9" ) + "%" .
        end.
        else do:
            Discnt-PC = string( 0, "->>>9.9" ) + "%" .
        end.

        if Val-CostSum <> 0 then do:
          if  ( Val-Effect / abs( Val-CostSum ) ) < 100
          AND ( Val-Effect / abs( Val-CostSum ) ) > -100 then do:
            assign
              Up-PC = string( Val-Effect / abs( Val-CostSum ) * 100 , "->>>9.9" ) + "%"
            .
          end.
          else do:
            if ( Val-Effect / abs( Val-CostSum ) ) < -99.99 then do:
              assign
                Up-PC = string( -9999.9 , "->>>9.9" ) + "%"
              .
            end.
            else do:
              assign
                Up-PC = string( 9999.9 , "->>>9.9" ) + "%"
              .
            end.
          end.
        end.
        else do:
          assign
            Up-PC = string( 0 , "->>>9.9" ) + "%"
          .
        end.

        ACCUMULATE
          Qnty               ( TOTAL )
          Val-BruttoSaleSum  ( TOTAL )
          Rubl-BruttoSaleSum ( TOTAL )
          Val-NettoSaleSum   ( TOTAL )
          Rubl-NettoSaleSum  ( TOTAL )
          Val-DiscntSum      ( TOTAL )
          Rubl-DiscntSum     ( TOTAL )
          Val-CostSum        ( TOTAL )
          Rubl-CostSum       ( TOTAL )
          NDS-Val            ( TOTAL )
          NDS-Rubl           ( TOTAL )
          Val-Effect         ( TOTAL )
          Rubl-Effect        ( TOTAL )
          for-doc-code       ( count )
          .

  { rep/dincol.i di 1  for-doc-attr
                  wt-docs.doc-attr }
  { rep/dincol.i di 2  for-doc-date
                  wt-docs.doc-date }
  { rep/dincol.i di 3  for-fact-date
                  wt-docs.fact-date }
  { rep/dincol.i di 4  for-doc-code
                  wt-docs.doc-code }
  { rep/dincol.i di 5  for-cli-name
                  wt-docs.cli-name }
  { rep/dincol.i di 6  Qnty
                   Qnty }
  { rep/dincol.i di 7  Val-BruttoSaleSum
                  Val-BruttoSaleSum }
  { rep/dincol.i di 8  Rubl-BruttoSaleSum
                  Rubl-BruttoSaleSum }
  { rep/dincol.i di 9  Val-NettoSaleSum
                  Val-NettoSaleSum }
  { rep/dincol.i di 10  Rubl-NettoSaleSum
                  Rubl-NettoSaleSum }
  { rep/dincol.i di 11  Val-DiscntSum
                  Val-DiscntSum }
  { rep/dincol.i di 12  RUbl-DiscntSum
                  Rubl-DiscntSum }
  { rep/dincol.i di 13  Val-CostSum
                  Val-CostSum }
  { rep/dincol.i di 14  RUbl-CostSum
                  Rubl-CostSum }
  { rep/dincol.i di 15 Val-Effect
                  Val-Effect }
  { rep/dincol.i di 16 RUbl-Effect
                  Rubl-Effect }
  { rep/dincol.i di 17 Nds-Val
                  Nds-Val }
  { rep/dincol.i di 18 Nds-Rubl
                  Nds-Rubl }
  { rep/dincol.i di 19 Discnt-PC
                  "(if Val-DiscntSum <> 0 AND Val-BruttoSaleSum <> 0 then Discnt-Pc else '' )" }
  { rep/dincol.i di 20 Up-Pc
                  "(if Val-Effect <> 0 AND Val-CostSum <> 0 then UP-PC else '' )" }
  { rep/dincol.i di 21 TorgPred
                  TorgPred }

  { rep/dincol.i di 22 Operator
                  Operator }
  { rep/dincol.i di 23 KladovName
                  KladovName }
  { rep/dincol.i di 24 IspName
                  IspName }
  { rep/dincol.i di 25 PayType
                  PayType }
  { rep/dincol.i di 26 Kurs
                  Kurs }
  { rep/dincol.i di 27 Our-Obj
                  Our-Obj }
  { rep/dincol.i di 28 PayWaitDAte
                  PayWaitDate }
  { rep/dincol.i dil DocsStream top-frame}
  {&DISPLAY-FRAME}

  {&PutExcel}
  { rep/dincol.i dix 1  for-doc-attr
                  wt-docs.doc-attr }
  { rep/dincol.i dix 2  for-doc-date
                  wt-docs.doc-date }
   if wt-docs.fact-date <> ?
    then
     ( { rep/dincol.i dix 3  for-fact-date  wt-docs.fact-date } )
    else
     ( { rep/dincol.i dix 3  for-fact-date  "''" } )

  { rep/dincol.i dix 4  for-doc-code
                  wt-docs.doc-code }
  { rep/dincol.i dix 5  for-cli-name
                  wt-docs.cli-name }
  { rep/dincol.i dix 6  Qnty
                  Qnty }
  { rep/dincol.i dix 7  Val-BruttoSaleSum
                  Val-BruttoSaleSum }
  { rep/dincol.i dix 8  Rubl-BruttoSaleSum
                  Rubl-BruttoSaleSum }
  { rep/dincol.i dix 9  Val-NettoSaleSum
                  Val-NettoSaleSum }
  { rep/dincol.i dix 10  Rubl-NettoSaleSum
                  Rubl-NettoSaleSum }
  { rep/dincol.i dix 11  Val-DiscntSum
                  Val-DiscntSum }
  { rep/dincol.i dix 12  RUbl-DiscntSum
                  Rubl-DiscntSum }
  { rep/dincol.i dix 13  Val-CostSum
                  Val-CostSum }
  { rep/dincol.i dix 14  RUbl-CostSum
                  Rubl-CostSum }
  { rep/dincol.i dix 15 Val-Effect
                  Val-Effect }
  { rep/dincol.i dix 16 RUbl-Effect
                  Rubl-Effect }
  { rep/dincol.i dix 17 Nds-Val
                  Nds-Val }
                   .
  {&PutExcel}

  { rep/dincol.i dix 18 Nds-Rubl
                  Nds-Rubl }
  { rep/dincol.i dix 19 Discnt-PC
                  "if Val-DiscntSum <> 0  AND Val-BruttoSaleSum <> 0  then Discnt-Pc else '' " }
  { rep/dincol.i dix 20 Up-Pc
                  "if Val-Effect <> 0 AND Val-CostSum <> 0 then UP-PC else '' " }
  { rep/dincol.i dix 21 TorgPred
                  TorgPred }
                  .
  {&PutExcel}
  { rep/dincol.i dix 22 Operator
                  Operator }
  { rep/dincol.i dix 23 KladovName
                  KladovName }
  { rep/dincol.i dix 24 IspName
                  IspName }
  { rep/dincol.i dix 25 PayType
                  PayType }
  { rep/dincol.i dix 26 Kurs
                  Kurs }
  { rep/dincol.i dix 27 Our-Obj
                  Our-Obj }
  { rep/dincol.i dix 28 PayWaitDAte
                  PayWaitDate }

  skip.
END.


/* Печать итогов */
/* Подчеркивание */
c-for-cli-name:screen-value =  line .
&scop under-l if use-column[~{&n-col2}]  then  C-~{&n-col3}:screen-value = line .
&scop  n-col2 6
&scop  n-col3  Qnty
{&under-l }
&scop  n-col2 7
&scop  n-col3 Val-BruttoSaleSum
{&under-l }
&scop  n-col2 8
&scop  n-col3 Rubl-BruttoSaleSum
{&under-l }
&scop  n-col2 9
&scop  n-col3 Val-NettoSaleSum
{&under-l }
&scop  n-col2 10
&scop  n-col3 Rubl-NettoSaleSum
{&under-l }
&scop  n-col2 11
&scop  n-col3 Val-DiscntSum
{&under-l }
&scop  n-col2 12
&scop  n-col3 Rubl-DiscntSum
{&under-l }
&scop  n-col2 13
&scop  n-col3 Val-CostSum
{&under-l }
&scop  n-col2 14
&scop  n-col3 Rubl-CostSum
{&under-l }
&scop  n-col2 15
&scop  n-col3 Val-Effect
{&under-l }
&scop  n-col2 16
&scop  n-col3 Rubl-Effect
{&under-l }
&scop  n-col2 17
&scop  n-col3 NDS-Val
{&under-l }
&scop  n-col2 18
&scop  n-col3 NDS-Rubl
{&under-l }
  {&DISPLAY-FRAME}

/* Суммы по колонкам */
  c-for-cli-name:screen-value =  "ИТОГО " + trim(string( ACCUM COUNT for-doc-code )) + " по док-м " .
  { rep/dincol.i di 6  Qnty  "ACCUM TOTAL Qnty" }
  { rep/dincol.i di 7  Val-BruttoSaleSum  "ACCUM TOTAL Val-BruttoSaleSum " }
  { rep/dincol.i di 8  Rubl-BruttoSaleSum "ACCUM TOTAL Rubl-BruttoSaleSum " }
  { rep/dincol.i di 9  Val-NettoSaleSum   "ACCUM TOTAL Val-NettoSaleSum  " }
  { rep/dincol.i di 10 Rubl-NettoSaleSum  "ACCUM TOTAL Rubl-NettoSaleSum " }
  { rep/dincol.i di 11 Val-DiscntSum      "ACCUM TOTAL Val-DiscntSum     " }
  { rep/dincol.i di 12 Rubl-DiscntSum     "ACCUM TOTAL Rubl-DiscntSum    " }
  { rep/dincol.i di 13 Val-CostSum        "ACCUM TOTAL Val-CostSum       " }
  { rep/dincol.i di 14 Rubl-CostSum       "ACCUM TOTAL Rubl-CostSum      " }
  { rep/dincol.i di 15 Val-Effect         "ACCUM TOTAL Val-Effect        " }
  { rep/dincol.i di 16 Rubl-Effect        "ACCUM TOTAL Rubl-Effect       " }
  { rep/dincol.i di 17 NDS-Val            "ACCUM TOTAL NDS-Val           " }
  { rep/dincol.i di 18 NDS-Rubl           "ACCUM TOTAL NDS-Rubl          " }
  {&DISPLAY-FRAME}
  /* суммы по колонкам в еxcel */
 {&PutExcel}
  {&tabulation} {&tabulation} {&tabulation} {&tabulation}
  { rep/dincol.i dix 5  for-cli-name       "'ИТОГО ' + trim(string( ACCUM COUNT for-doc-code )) + ' по док-м '" }
  { rep/dincol.i dix 6  Qnty               "ACCUM TOTAL Qnty"               }
  { rep/dincol.i dix 7  Val-BruttoSaleSum  "ACCUM TOTAL Val-BruttoSaleSum " }
  { rep/dincol.i dix 8  Rubl-BruttoSaleSum "ACCUM TOTAL Rubl-BruttoSaleSum" }
  { rep/dincol.i dix 9  Val-NettoSaleSum   "ACCUM TOTAL Val-NettoSaleSum  " }
  { rep/dincol.i dix 10 Rubl-NettoSaleSum  "ACCUM TOTAL Rubl-NettoSaleSum " }
  { rep/dincol.i dix 11 Val-DiscntSum      "ACCUM TOTAL Val-DiscntSum     " }
  { rep/dincol.i dix 12 Rubl-DiscntSum     "ACCUM TOTAL Rubl-DiscntSum    " }
  { rep/dincol.i dix 13 Val-CostSum        "ACCUM TOTAL Val-CostSum       " }
  { rep/dincol.i dix 14 Rubl-CostSum       "ACCUM TOTAL Rubl-CostSum      " }
  { rep/dincol.i dix 15 Val-Effect         "ACCUM TOTAL Val-Effect        " }
  { rep/dincol.i dix 16 Rubl-Effect        "ACCUM TOTAL Rubl-Effect       " }
  { rep/dincol.i dix 17 NDS-Val            "ACCUM TOTAL NDS-Val           " }
  { rep/dincol.i dix 18 NDS-Rubl           "ACCUM TOTAL NDS-Rubl          " }

  .
run waitfram-hide in this-procedure  .

HIDE stream DocsStream FRAME BottomFrame .
HIDE stream DocsStream FRAME x1 .
HIDE stream DocsStream FRAME top-frame .
delete widget-pool "My-pool".
output stream DocsStream CLOSE.

{&CloseExcel}
run waitfram-hide in this-procedure .


define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = if p-frame-width > 137 AND  p-frame-width <= {&DOS_CW_2}  then 8
                  else (if p-frame-width > {&DOS_CW_2}
                            then 9
                            else 0 ) .

run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .