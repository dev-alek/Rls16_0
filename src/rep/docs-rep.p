block-level on error undo, throw.
/*

$Revision: 16a79e67eba9, 1355, rls $
$Author: EShklyar $
$Date: Fri May 18 13:28:42 2018 +0300 $
$Workfile: docs-rep.p $
$Archive: rep/docs-rep.p $

Печать документов из списка документов

Автор: Чернова Светлана Александровна
Дата создания: 10/10/05
Author: Svetlana Chernova
Creation date: 10/10/05

Author: Черных

*/

define input  parameter p-title             as character no-undo .
define input  parameter p-sale-base         as logical   no-undo .
define input  parameter p-sale-rubl         as logical   no-undo .
define input  parameter p-crsa-base-doc    as logical   no-undo .
define input  parameter p-crsa-Rubl-doc    as logical   no-undo .
define input  parameter p-sale-base-doc    as logical   no-undo .
define input  parameter p-sale-rubl-doc    as logical   no-undo .
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
define input  parameter p-detal-NDS-Val     as logical   no-undo .
define input  parameter pNDS-Rubl           as logical   no-undo .
define input  parameter p-detal-NDS-Rubl    as logical   no-undo .
define input  parameter pNums               as logical   no-undo .
define input  parameter pNums-doc           as logical   no-undo .
define input  parameter p-ps                as logical   no-undo .
define input  parameter p-continue          as logical   no-undo .
define input  parameter g#report-num        as integer   no-undo .
define output parameter p-frame-width       as integer   no-undo .

def var vss-revision    as character no-undo init "$Revision: 16a79e67eba9, 1355, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Fri May 18 13:28:42 2018 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: docs-rep.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/docs-rep.p $":U .
def var vss-description as character no-undo init "Печать документов из списка документов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/wt-docs.i  }
{ gbl/cur-time.i }
{ cmp/r-page1.i new }
{ rep/dincol.i def  }
{ rep/opclexcl.i    }
{ str/clcprtsl.i " "  doc }
{ gbl/waitfram.i }
{ str/in-vatp.i def }

DEFINE stream DocsStream .

def     buffer  b-wt-docs           for     wt-docs .

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
define variable NDS18-Val           as decimal   no-undo .
define variable NDS10-Val           as decimal   no-undo .
define variable NDS-Rubl            as decimal   no-undo .
define variable NDS18-Rubl          as decimal   no-undo .
define variable NDS10-Rubl          as decimal   no-undo .
define variable v-ind               as integer   no-undo .
DEFINE VARIABLE for-doc-attr like   wt-docs.doc-attr no-undo .
DEFINE VARIABLE for-doc-date like   wt-docs.doc-date no-undo .
DEFINE VARIABLE for-fact-date like  wt-docs.fact-date no-undo .
DEFINE VARIABLE for-doc-code like   wt-docs.doc-code no-undo .
DEFINE VARIABLE for-cli-name like   wt-docs.cli-name no-undo .
define variable v-vat18-base    as logical      no-undo.
define variable v-vat10-base    as logical      no-undo.
define variable v-vat18-rubl    as logical      no-undo.
define variable v-vat10-rubl    as logical      no-undo.
define variable sale-base       as decimal   no-undo .
define variable sale-rubl       as decimal   no-undo .
define variable sale-base-doc as decimal   no-undo .
define variable sale-rubl-doc as decimal   no-undo .
define variable crsa-base-doc as decimal   no-undo .
define variable crsa-rubl-doc as decimal   no-undo .
define variable Qnty-doc      as decimal   no-undo .
define variable comm as character no-undo .



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

if p-detal-NDS-Val = yes
then do:
    assign
        v-vat18-base = yes
        v-vat10-base = yes
    .
end.
if p-detal-NDS-Rubl = yes
then do:
    assign
        v-vat18-rubl = yes
        v-vat10-rubl = yes
    .
end.

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
  use-column[18] = v-vat18-base
  use-column[19] = v-vat10-base
  use-column[20] = pNDs-RUbl
  use-column[21] = v-vat18-rubl
  use-column[22] = v-vat10-rubl
  use-column[23] = PDiscnt-PC
  use-column[24] = pUP-pc
  use-column[25] = pTOrgPred
  use-column[26] = pOperator
  use-column[27] = PKladov
  use-column[28] = pIspName
  use-column[29] = pPayType
  use-column[30] = pKurs
  use-column[31] = pOur-Obj
  use-column[32] = pPayWaitDate
  use-column[33] = p-sale-base
  use-column[34] = p-sale-rubl
  use-column[35] = pNums-doc
  use-column[36] = p-sale-base-doc
  use-column[37] = p-sale-rubl-doc
  use-column[38] = p-crsa-base-doc
  use-column[39] = p-crsa-rubl-doc
  use-column[40] = p-ps
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

Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/99"            l-col-lable="Дата создания".
  { rep/dincol.i cr  2    for-doc-date      x1                }
  { rep/dincol.i crx 2 }

Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/99"            l-col-lable="Дата закрытия".
  { rep/dincol.i cr  3    for-fact-date      x1                }
  { rep/dincol.i crx 3 }

Assign l-col-type="CHARACTER" l-col-len=15 l-col-format= "x(15)"            l-col-lable="Номер документа".
  { rep/dincol.i cr  4    for-doc-code      x1                }
  { rep/dincol.i crx 4 }

Assign l-col-type="CHARACTER" l-col-len=30 l-col-format= "x(30)"            l-col-lable="Контрагент".
  { rep/dincol.i cr  5    for-cli-name      x1                }
  assign l-col-type="CHARACTER" l-col-len=50 l-col-format= "x(70)". /* ТН-3418 Увеличение поля "Контрагент" ДЛЯ Excel (на экран - вывод по старому=30симв). Арн. 21.04.2015г */
  { rep/dincol.i crx 5 }

Assign l-col-type="DECIMAL" l-col-len=12 l-col-format= "->>>>,>>9.99"            l-col-lable="Количество".
  { rep/dincol.i cr  6    Qnty      x1                }
  { rep/dincol.i crx 6 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма прод. цен (без скидки) (б.вал.)".
  { rep/dincol.i cr  7    Val-BruttoSaleSum      x1                }
  { rep/dincol.i crx 7 }
Assign l-col-type="DECIMAL" l-col-len=21 l-col-format= "->,>>>,>>>,>>>,>>9.99"   l-col-lable="Сумма прод. цен (без скидки) ({&abbr_rub_allshift})".
  { rep/dincol.i cr  8    Rubl-BruttoSaleSum      x1                }
  { rep/dincol.i crx 8 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="Сумма прод. цен (со скидкой) (б.вал.)".
  { rep/dincol.i cr  9    Val-NettoSaleSum      x1                }
  { rep/dincol.i crx 9 }
Assign l-col-type="DECIMAL" l-col-len=21 l-col-format= "->,>>>,>>>,>>>,>>9.99"   l-col-lable="Сумма прод. цен (со скидкой) ({&abbr_rub_allshift})".
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
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС 18% (б.вал.)".
  { rep/dincol.i cr  18    NDS18-val      x1                }
  { rep/dincol.i crx 18 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС 10% (б.вал.)".
  { rep/dincol.i cr  19    NDS10-val      x1                }
  { rep/dincol.i crx 19 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС ({&abbr_rub_allshift})".
  { rep/dincol.i cr  20    NDS-Rubl      x1                }
  { rep/dincol.i crx 20 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС 18% ({&abbr_rub_allshift})".
  { rep/dincol.i cr  21    NDS18-Rubl    x1                }
  { rep/dincol.i crx 21 }
Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="НДС 10% ({&abbr_rub_allshift})".
  { rep/dincol.i cr  22    NDS10-Rubl    x1                }
  { rep/dincol.i crx 22 }
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "x(8)"                   l-col-lable="Процент скидки".
  { rep/dincol.i cr  23    Discnt-Pc      x1                }
  { rep/dincol.i crx 23 }
Assign l-col-type="CHARACTER" l-col-len=8 l-col-format= "x(8)"                   l-col-lable="Процент фактич. наценки".
  { rep/dincol.i cr  24    Up-Pc      x1                }
  { rep/dincol.i crx 24 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Торговый представитель".
  { rep/dincol.i cr  25    TorgPred      x1                }
  { rep/dincol.i crx 25 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Оператор".
  { rep/dincol.i cr  26    Operator      x1                }
  { rep/dincol.i crx 26 }

Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Кладовщик".
  { rep/dincol.i cr  27    KladovName      x1                }
  { rep/dincol.i crx 27 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Исполнитель".
  { rep/dincol.i cr  28    IspName      x1                }
  { rep/dincol.i crx 28 }
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "x(10)"                 l-col-lable="Вид оплаты".
  { rep/dincol.i cr  29    PayType      x1                }
  { rep/dincol.i crx 29 }
Assign l-col-type="DECIMAL" l-col-len=11 l-col-format= "->>>,>>9.<<"             l-col-lable="Курс".
  { rep/dincol.i cr  30    Kurs      x1                }
  { rep/dincol.i crx 30 }
Assign l-col-type="CHARACTER" l-col-len=18 l-col-format= "x(18)"                 l-col-lable="Свой объект".
  { rep/dincol.i cr  31    Our-Obj     x1                }
  { rep/dincol.i crx 31 }

Assign l-col-type="DATE" l-col-len=10 l-col-format= "99/99/99"                 l-col-lable="Дата ожид-мой оплаты".
  { rep/dincol.i cr  32    PayWaitDate     x1                }
  { rep/dincol.i crx 32 }

Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В ценах документа(баз.в.)".
  { rep/dincol.i cr  33    sale-base    x1                }
  { rep/dincol.i crx 33 }

Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В ценах документа({&abbr_rub_allshift})".
  { rep/dincol.i cr  34    sale-rubl    x1                }
  { rep/dincol.i crx 34 }

Assign l-col-type="DECIMAL" l-col-len=12 l-col-format= "->>>>,>>9.99"            l-col-lable="Количество (док)".
  { rep/dincol.i cr  35    Qnty-doc      x1                }
  { rep/dincol.i crx 35 }

Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В учетн.ценах (баз.в.) (док) ".
  { rep/dincol.i cr  36    sale-base-doc    x1                }
  { rep/dincol.i crx 36 }

Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В учетн.ценах({&abbr_rub_allshift}) (док)".
  { rep/dincol.i cr  37    sale-rubl-doc    x1                }
  { rep/dincol.i crx 37 }

Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В прод.ценах(баз.в.) (док) ".
  { rep/dincol.i cr  38    crsa-base-doc    x1                }
  { rep/dincol.i crx 38 }

Assign l-col-type="DECIMAL" l-col-len=15 l-col-format= "->>>,>>>,>>9.99"         l-col-lable="В прод.ценах({&abbr_rub_allshift}) (док)".
  { rep/dincol.i cr  39    crsa-rubl-doc    x1                }
  { rep/dincol.i crx 39 }

Assign l-col-type="CHARACTER" l-col-len=80 l-col-format= "x(80)"            l-col-lable="Примечание".
  { rep/dincol.i cr  40    comm    x1                }
  { rep/dincol.i crx 40 }



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
run rep/extitle.p (1).

FIND FIRST wt-docs NO-LOCK .
if can-find( first b-wt-docs where b-wt-docs.doc-type <> wt-docs.doc-type ) then do:
  assign
    DifferentTypes = TRUE
  .
end.


run waitfram-show in this-procedure  ( "Печать списка документов " ) .

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
    run waitfram-show in this-procedure  ( "Печать списка документов " + string( v-ind ) ) .
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

  run calc-line-doc in this-procedure .
  assign
    wt-docs.VAT18-base = NDS18-Val
    wt-docs.VAT10-base = NDS10-Val
    wt-docs.VAT18-rubl = NDS18-Rubl
    wt-docs.VAT10-rubl = NDS10-Rubl
  .
  assign
        Qnty        = ( if can-do( {&fact}, wt-docs.status_ )
                        then wt-docs.fact-qnty
                        else wt-docs.doc-qnty )
        Qnty-doc    = wt-docs.doc-qnty
        NDS-Val     = wt-docs.VAT-base
        NDS-Rubl    = wt-docs.VAT-rubl
        TorgPred    = wt-docs.Mngr_Name
        Operator    = wt-docs.Oper_Name
        PayType     = wt-docs.pay-name
        Kurs        = wt-docs.Course
        Our-Obj     = wt-docs.OurObjectName
        KladovName  = wt-docs.Wrkr_name
        IspName     = wt-docs.Isp-Name
        PayWaitDate = wt-docs.pay-waitdate
        comm        = wt-docs.ps
        Val-BruttoSaleSum  =  Val-NettoSaleSum  +  Val-DiscntSum
        Rubl-BruttoSaleSum =  Rubl-NettoSaleSum +  Rubl-DiscntSum
.
        if Qnty = ? then Qnty = 0 .
        if Qnty-doc = ? then Qnty-doc = 0 .
        if Val-BruttoSaleSum = ? then Val-BruttoSaleSum = 0 .
        if Rubl-BruttoSaleSum = ? then Rubl-BruttoSaleSum = 0 .
        if Val-NettoSaleSum = ? then Val-NettoSaleSum = 0 .
        if Rubl-NettoSaleSum = ? then Rubl-NettoSaleSum = 0 .
        if Val-DiscntSum = ? then Val-DiscntSum = 0 .
        if Rubl-DiscntSum = ? then Rubl-DiscntSum = 0 .
        if Val-CostSum = ? then Val-CostSum = 0 .
        if Rubl-CostSum = ? then Rubl-CostSum = 0 .
        if NDS-Val    = ? then NDS-Val    = 0 .
        if NDS18-Val  = ? then NDS18-Val  = 0 .
        if NDS10-Val  = ? then NDS10-Val  = 0 .
        if NDS-Rubl   = ? then NDS-Rubl   = 0 .
        if NDS18-Rubl = ? then NDS18-Rubl = 0 .
        if NDS10-Rubl = ? then NDS10-Rubl = 0 .
        if sale-rubl  = ? then sale-Rubl  = 0 .
        if sale-base  = ? then sale-base  = 0 .
        if sale-rubl-doc  = ? then sale-Rubl-doc  = 0 .
        if sale-base-doc  = ? then sale-base-doc  = 0 .


        if crsa-rubl-doc  = ? then crsa-Rubl-doc  = 0 .
        if crsa-base-doc  = ? then crsa-base-doc  = 0 .


        if DifferentTypes AND can-do( {&expense_write-off}, wt-docs.doc-type ) then do:
            assign
                Qnty = - Qnty
                Qnty-doc = - Qnty-doc
                Val-BruttoSaleSum = - Val-BruttoSaleSum
                Rubl-BruttoSaleSum = - Rubl-BruttoSaleSum
                Val-NettoSaleSum = - Val-NettoSaleSum
                Rubl-NettoSaleSum = - Rubl-NettoSaleSum
                Val-DiscntSum = - Val-DiscntSum
                Rubl-DiscntSum = - Rubl-DiscntSum
                Val-CostSum = - Val-CostSum
                Rubl-CostSum = - Rubl-CostSum
                NDS-Val = - NDS-Val
                NDS18-Val = - NDS18-Val
                NDS10-Val = - NDS10-Val
                NDS-Rubl = - NDS-Rubl
                NDS18-Rubl = - NDS18-Rubl
                NDS10-Rubl = - NDS10-Rubl
                sale-rubl  = - sale-rubl
                sale-base  = - sale-base
                sale-rubl-doc  = - sale-rubl-doc
                sale-base-doc  = - sale-base-doc
                crsa-rubl-doc  = - crsa-rubl-doc
                crsa-base-doc  = - crsa-base-doc
            .
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
          Qnty-doc           ( TOTAL )
          Val-BruttoSaleSum  ( TOTAL )
          Rubl-BruttoSaleSum ( TOTAL )
          Val-NettoSaleSum   ( TOTAL )
          Rubl-NettoSaleSum  ( TOTAL )
          Val-DiscntSum      ( TOTAL )
          Rubl-DiscntSum     ( TOTAL )
          Val-CostSum        ( TOTAL )
          Rubl-CostSum       ( TOTAL )
          NDS-Val            ( TOTAL )
          NDS18-Val          ( TOTAL )
          NDS10-Val          ( TOTAL )
          NDS-Rubl           ( TOTAL )
          NDS18-Rubl         ( TOTAL )
          NDS10-Rubl         ( TOTAL )
          Val-Effect         ( TOTAL )
          Rubl-Effect        ( TOTAL )
          sale-rubl          ( TOTAL )
          sale-base          ( TOTAL )
          sale-rubl-doc          ( TOTAL )
          sale-base-doc          ( TOTAL )
          crsa-rubl-doc          ( TOTAL )
          crsa-base-doc          ( TOTAL )
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
  { rep/dincol.i di 18 Nds18-Val
                  Nds18-Val }
  { rep/dincol.i di 19 Nds10-Val
                  Nds10-Val }
  { rep/dincol.i di 20 Nds-Rubl
                  Nds-Rubl }
  { rep/dincol.i di 21 Nds18-Rubl
                  Nds18-Rubl }
  { rep/dincol.i di 22 Nds10-Rubl
                  Nds10-Rubl }
  { rep/dincol.i di 23 Discnt-PC
                  "if Val-DiscntSum <> 0  AND Val-BruttoSaleSum <> 0  then Discnt-Pc else '' " }
  { rep/dincol.i di 24 Up-Pc
                  "if Val-Effect <> 0 AND Val-CostSum <> 0 then UP-PC else '' " }
  { rep/dincol.i di 25 TorgPred
                  TorgPred }

  { rep/dincol.i di 26 Operator
                  Operator }
  { rep/dincol.i di 27 KladovName
                  KladovName }
  { rep/dincol.i di 28 IspName
                  IspName }
  { rep/dincol.i di 29 PayType
                  PayType }
  { rep/dincol.i di 30 Kurs
                  Kurs }
  { rep/dincol.i di 31 Our-Obj
                  Our-Obj }
  { rep/dincol.i di 32 PayWaitDAte
                  PayWaitDate }
  { rep/dincol.i di 33 sale-base
                  sale-base }
  { rep/dincol.i di 34 sale-rubl
                  sale-rubl }
  { rep/dincol.i di 35  Qnty-doc
                   Qnty-doc }
  { rep/dincol.i di 36 sale-base-doc
                  sale-base-doc }
  { rep/dincol.i di 37 sale-rubl-doc
                  sale-rubl-doc }
  { rep/dincol.i di 38 crsa-base-doc
                  crsa-base-doc }
  { rep/dincol.i di 39 crsa-rubl-doc
                  crsa-rubl-doc }
  { rep/dincol.i di 40 comm
                  comm }

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

  /*{ rep/dincol.i dix 5  for-cli-name*/ /* ТН-3417 21.04.2015 Арн. Откл инклуд и заменил его кодом ниже (из инклуда, но с модиф). */
  /*                wt-docs.cli-name }*/ /* ТН-3417 21.04.2015 Арн. Теперь - на экране поле "Контрагент" = 30симв, а в Excel = 70 симв, что и требует Заказчик. */
                                                                                                        /* ТН-3417 21.04.2015 Арн. */
  /*в Excel*/                                                                                           /* ТН-3417 21.04.2015 Арн. */
  if use-column[5]                                                                                      /* ТН-3417 21.04.2015 Арн. */
  then (reg-output(                                                                                     /* ТН-3417 21.04.2015 Арн. */
                    string(wt-docs.cli-name, entry(1, "x(70)"/*c-for-cli-name:private-data*/, chr(4)))  /* ТН-3417 21.04.2015 Арн. */
                   ,c-for-cli-name:private-data                                                         /* ТН-3417 21.04.2015 Арн. */
                   ,v-reg-replace                                                                       /* ТН-3417 21.04.2015 Арн. */
                                                                                                        /* ТН-3417 21.04.2015 Арн. */
                   ,no                                                                                  /* ТН-3417 21.04.2015 Арн. */
                                                                                                        /* ТН-3417 21.04.2015 Арн. */
                   ,v-dec-sep                                                                           /* ТН-3417 21.04.2015 Арн. */
                   ,v-th-sep)  +                                                                        /* ТН-3417 21.04.2015 Арн. */
        (if 5 < last-col-num                                                                            /* ТН-3417 21.04.2015 Арн. */
         then CHR(9)                                                                                    /* ТН-3417 21.04.2015 Арн. */
         else ""))                                                                                      /* ТН-3417 21.04.2015 Арн. */
  else "":U                                                                                             /* ТН-3417 21.04.2015 Арн. */

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
  { rep/dincol.i dix 18 Nds18-Val
                  Nds18-Val }
  { rep/dincol.i dix 19 Nds10-Val
                  Nds10-Val }
  .
  {&PutExcel}
  { rep/dincol.i dix 20 Nds-Rubl
                  Nds-Rubl }
  { rep/dincol.i dix 21 Nds18-Rubl
                  Nds18-Rubl }
  { rep/dincol.i dix 22 Nds10-Rubl
                  Nds10-Rubl }
  { rep/dincol.i dix 23 Discnt-PC
                  "if Val-DiscntSum <> 0  AND Val-BruttoSaleSum <> 0  then Discnt-Pc else '' " }
  { rep/dincol.i dix 24 Up-Pc
                  "if Val-Effect <> 0 AND Val-CostSum <> 0 then UP-PC else '' " }
  { rep/dincol.i dix 25 TorgPred
                  TorgPred }
                  .
  {&PutExcel}
  { rep/dincol.i dix 26 Operator
                   Operator }
  { rep/dincol.i dix 27 KladovName
                   KladovName }
  { rep/dincol.i dix 28 IspName
                   IspName }
  { rep/dincol.i dix 29 PayType
                   PayType }
  { rep/dincol.i dix 30 Kurs
                   Kurs }
  { rep/dincol.i dix 31 Our-Obj
                   Our-Obj }
  { rep/dincol.i dix 32 PayWaitDAte
                   PayWaitDate }
  { rep/dincol.i dix 33 sale-base
                   sale-base }
  { rep/dincol.i dix 34 sale-rubl
                   sale-rubl }
  { rep/dincol.i dix 35  Qnty-doc
                   Qnty-doc }
  { rep/dincol.i dix 36 sale-base-doc
                  sale-base-doc }
  { rep/dincol.i dix 37 sale-rubl-doc
                  sale-rubl-doc }
  { rep/dincol.i dix 38 crsa-base-doc
                  crsa-base-doc }
  { rep/dincol.i dix 39 crsa-rubl-doc
                  crsa-rubl-doc }
  { rep/dincol.i dix 40 comm
                   comm }

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
&scop  n-col3 NDS18-Val
{&under-l }
&scop  n-col2 19
&scop  n-col3 NDS10-Val
{&under-l }
&scop  n-col2 20
&scop  n-col3 NDS-Rubl
{&under-l }
&scop  n-col2 21
&scop  n-col3 NDS18-Rubl
{&under-l }
&scop  n-col2 22
&scop  n-col3 NDS10-Rubl
{&under-l }
&scop  n-col2 33
&scop  n-col3 sale-base
{&under-l }
&scop  n-col2 34
&scop  n-col3 sale-rubl
{&under-l }
&scop  n-col2 35
&scop  n-col3  Qnty-doc
{&under-l }
&scop  n-col2 36
&scop  n-col3 sale-base-doc
{&under-l }
&scop  n-col2 37
&scop  n-col3 sale-rubl-doc
{&under-l }
&scop  n-col2 38
&scop  n-col3 crsa-base-doc
{&under-l }
&scop  n-col2 39
&scop  n-col3 crsa-rubl-doc
{&under-l }
&scop  n-col2 40
&scop  n-col3 comm
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
  { rep/dincol.i di 18 NDS18-Val          "ACCUM TOTAL NDS18-Val         " }
  { rep/dincol.i di 19 NDS10-Val          "ACCUM TOTAL NDS10-Val         " }
  { rep/dincol.i di 20 NDS-Rubl           "ACCUM TOTAL NDS-Rubl          " }
  { rep/dincol.i di 21 NDS18-Rubl         "ACCUM TOTAL NDS18-Rubl        " }
  { rep/dincol.i di 22 NDS10-Rubl         "ACCUM TOTAL NDS10-Rubl        " }
  { rep/dincol.i di 33 sale-base          "ACCUM TOTAL sale-base         " }
  { rep/dincol.i di 34 sale-rubl          "ACCUM TOTAL sale-rubl         " }
  { rep/dincol.i di 35  Qnty-doc          "ACCUM TOTAL Qnty-doc        " }
  { rep/dincol.i di 36 sale-base-doc      "ACCUM TOTAL sale-base-doc   " }
  { rep/dincol.i di 37 sale-rubl-doc      "ACCUM TOTAL sale-rubl-doc   " }
  { rep/dincol.i di 38 crsa-base-doc      "ACCUM TOTAL crsa-base-doc   " }
  { rep/dincol.i di 39 crsa-rubl-doc      "ACCUM TOTAL crsa-rubl-doc   " }


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
  { rep/dincol.i dix 18 NDS18-Val          "ACCUM TOTAL NDS18-Val         " }
  { rep/dincol.i dix 19 NDS10-Val          "ACCUM TOTAL NDS10-Val         " }
  { rep/dincol.i dix 20 NDS-Rubl           "ACCUM TOTAL NDS-Rubl          " }
  { rep/dincol.i dix 21 NDS18-Rubl         "ACCUM TOTAL NDS18-Rubl        " }
  { rep/dincol.i dix 22 NDS10-Rubl         "ACCUM TOTAL NDS10-Rubl        " }
  { rep/dincol.i dix 33 sale-base          "ACCUM TOTAL sale-base         " }
  { rep/dincol.i dix 34 sale-rubl          "ACCUM TOTAL sale-rubl         " }
  .
  {&PutExcel}
  { rep/dincol.i dix 35 qnty-doc           "ACCUM TOTAL qnty-doc        " }
  { rep/dincol.i dix 36 sale-base-doc      "ACCUM TOTAL sale-base-doc   " }
  { rep/dincol.i dix 37 sale-rubl-doc      "ACCUM TOTAL sale-rubl-doc   " }
  { rep/dincol.i dix 38 crsa-base-doc      "ACCUM TOTAL crsa-base-doc   " }
  { rep/dincol.i dix 39 crsa-rubl-doc      "ACCUM TOTAL crsa-rubl-doc   " }
  .

HIDE stream DocsStream FRAME BottomFrame .
HIDE stream DocsStream FRAME x1 .
HIDE stream DocsStream FRAME top-frame .
delete widget-pool "My-pool".
output stream DocsStream CLOSE.
/* for each sheetf:
  message
  Excel-Column-Lable
  Excel-Row-Heder
  Excel-Row-Title
  Sizes
  Make-correct
  Rights-column
  MergeCellsH
  MergeCellsV
  sheet-num
  skip "fff" ColFormat
  skip "-"
  Bas-FIle
  Bas-Params

  .
end.
  */
{&CloseExcel}
run waitfram-hide in this-procedure .

define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .

DisabledOptions = 8 .
if l-col-pos >= 195 then DisabledOptions = 20.
run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .

procedure calc-line-doc :
 define buffer buf_parts     for parts.
 do
 for buf_parts
 on error undo, return error return-value
 :
 assign
    Val-BruttoSaleSum  = 0
    Rubl-BruttoSaleSum = 0
    Val-NettoSaleSum   = 0
    Rubl-NettoSaleSum  = 0
    Val-DiscntSum      = 0
    Rubl-DiscntSum     = 0
    Val-CostSum        = 0
    Rubl-CostSum       = 0
    NDS18-Val          = 0
    NDS10-Val          = 0
    NDS18-Rubl         = 0
    NDS10-Rubl         = 0
    sale-rubl          = 0
    sale-base          = 0
    sale-rubl-doc      = 0
    sale-base-doc      = 0
    crsa-rubl-doc      = 0
    crsa-base-doc      = 0
 .
 for each doc-line no-lock
    where doc-line.doc-code = wt-docs.doc-code
 :
    run clcprtsl_calc-line in this-procedure (
        input recid( doc-line )
    ).
    find first tt-allsum-line
         where tt-allsum-line.sum-type = {&sum-general}
    no-error.
    if not available tt-allsum-line
    then do:
    end.
    else do:
        if ( wt-docs.doc-type = {&income}  and wt-docs.internal = false ) or
           ( wt-docs.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  )
            then do:
                assign
                    Val-NettoSaleSum   = Val-NettoSaleSum   +  tt-allsum-line.sum-dsc-base-cur
                    Rubl-NettoSaleSum  = Rubl-NettoSaleSum  +  tt-allsum-line.sum-dsc-rubl-cur
                    Val-DiscntSum      = Val-DiscntSum      +  tt-allsum-line.dsc-base-cur
                    Rubl-DiscntSum     = Rubl-DiscntSum     +  tt-allsum-line.dsc-rubl-cur
                    crsa-base-doc      = crsa-base-doc      +  tt-allsum-line.sum-dsc-base-doc-cur
                    crsa-rubl-doc      = crsa-rubl-doc      +  tt-allsum-line.sum-dsc-rubl-doc-cur

                .
            end.
            else do:
                assign
                    Val-NettoSaleSum   = Val-NettoSaleSum   +  tt-allsum-line.sum-dsc-base-doc
                    Rubl-NettoSaleSum  = Rubl-NettoSaleSum  +  tt-allsum-line.sum-dsc-rubl-doc
                    Val-DiscntSum      = Val-DiscntSum      +  tt-allsum-line.dsc-base-doc
                    Rubl-DiscntSum     = Rubl-DiscntSum     +  tt-allsum-line.dsc-rubl-doc
                    crsa-base-doc      = crsa-base-doc      +  tt-allsum-line.sum-dsc-base-doc-doc
                    crsa-rubl-doc      = crsa-rubl-doc      +  tt-allsum-line.sum-dsc-rubl-doc-doc

                .
            end.
        assign
            Val-CostSum   = Val-CostSum        +  tt-allsum-line.sum-dsc-base-acc
            Rubl-CostSum  = Rubl-CostSum       +  tt-allsum-line.sum-dsc-rubl-acc
            sale-base     = sale-base          +  tt-allsum-line.sum-dsc-base-doc
            sale-rubl     = sale-rubl          +  tt-allsum-line.sum-dsc-rubl-doc
            sale-base-doc = sale-base-doc      +  tt-allsum-line.sum-dsc-base-doc-acc
            sale-rubl-doc = sale-rubl-doc      +  tt-allsum-line.sum-dsc-rubl-doc-acc
        .
        /*
        message tt-allsum-line.doc-qnty  tt-allsum-line.sum-dsc-rubl-doc-doc skip
                tt-allsum-line.doc-qnty  tt-allsum-line.sum-dsc-rubl-doc-cur skip
                tt-allsum-line.fact-qnty tt-allsum-line.sum-dsc-rubl-cur .
                */

    end.


    if p-detal-NDS-Val  = yes
    or p-detal-NDS-Rubl = yes
    then do:
        for each buf_parts no-lock
           where buf_parts.out-code   = wt-docs.doc-code
             and buf_parts.obj-type   = doc-line.obj-type
             and buf_parts.obj-code   = doc-line.obj-code
             and buf_parts.prod-type  = doc-line.prod-type
             and buf_parts.prod-code  = doc-line.prod-code
             and buf_parts.artic      = doc-line.artic
/*             and buf_parts.status_    = true*/
        on error undo, return error return-value
        :
            if round( buf_parts.VAT-pc, 0 ) = 18
            then do:
                { str/in-vatp.i calc-parts buf_parts. " " loc}
                assign
                    NDS18-Val          = NDS18-Val          + ( vat-base-loc * buf_parts.fact-qnty )
                    NDS18-Rubl         = NDS18-Rubl         + ( vat-rubl-loc * buf_parts.fact-qnty )
                .
            end.
            if round( buf_parts.VAT-pc, 0 ) = 10
            then do:
                { str/in-vatp.i calc-parts buf_parts. " " loc}
                assign
                    NDS10-Val          = NDS10-Val          + ( vat-base-loc * buf_parts.fact-qnty )
                    NDS10-Rubl         = NDS10-Rubl         + ( vat-rubl-loc * buf_parts.fact-qnty )
                .
            end.
        end.        /* for each buf_parts */

    end.
end.

 end. /* do */
end procedure. /* calc-line-doc */
