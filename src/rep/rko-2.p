block-level on error undo, throw.
/*

$Revision: 1b40de64e20a, 2987, rls $
$Author: EShklyar $
$Date: Ср апр 06 16:23:43 2022 +0300 $
$Workfile: rko-2.p $
$Archive: rep/rko-2.p $

Печать платежа  типа расход наличные

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define parameter buffer buf_fin-doc for ub.fin-doc.
define input parameter p-append as logical no-undo .
define input parameter p-is-last as logical no-undo .
define input parameter p-from-forms as logical no-undo .
define input-output parameter p-format as integer no-undo .
/*1 - Landscape 0 -portrait*/

&SCOP f-l MonthNameRusGen

define variable vss-revision    as character no-undo init "$Revision: 1b40de64e20a, 2987, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:43 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rko-2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/rko-2.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа расход наличные".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/frmlib.i }
{ gbl/db-attr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable g#report-num         as integer   no-undo .
define variable g#quest-print        as logical   no-undo.


define variable Line                 as character no-undo .
define variable v-enclosure-1        as character no-undo .
define variable v-enclosure-2        as character no-undo .
define variable v-doc-date-f         as character no-undo .
define variable v-date-create        as date      no-undo .
define variable v-str-podr-name      as character no-undo .
define variable num-lines            as integer   no-undo .
define variable v-fill               as character no-undo init "_".
define variable v-sum-doc-v1         as character no-undo .
define variable v-sum-doc-v2         as character no-undo .
define variable v-sum-doc-n1         as character no-undo .
define variable v-sum-doc-n2         as character no-undo .
define variable v-sum-kop-p          as character no-undo .
define variable v-dops               as character no-undo .
define variable v-head-position      as character no-undo .
define variable v-sign1              as character no-undo .
define variable v-passport-1         as character no-undo .
define variable v-passport-2         as character no-undo .
define variable v-rub                as character no-undo .
define variable v-kop                as character no-undo .
define variable v-title-rub          as character no-undo .
define variable v-line3              as integer   no-undo .
define variable v-line2              as integer   no-undo .
define variable v-okv-code           as character no-undo .
define variable v-chernovik          as character no-undo .
define variable v-naznach-plat-1     as character no-undo .
define variable v-naznach-plat-2     as character no-undo .
define variable g#log                as logical   no-undo .

define variable mCashBook            as class     ibs.th.ref.cashbookstorage no-undo .
define variable o-uchet              as character no-undo .
define variable v-uchet              as character no-undo .
define variable v-value-date         as date      no-undo .
define variable v-value-decimal      as decimal   no-undo .
define variable v-value-integer      as INTEGER   no-undo .
define variable v-value-logical      AS LOGICAL   no-undo .
define variable par-type             as character no-undo .
define variable v-tth                as handle    no-undo .
define variable v-hist-name          as character no-undo .
define variable v-hist-code          as character no-undo .

define variable p-report-id          as character no-undo .
define variable v-file-name-rep-html as character no-undo .
define variable ii                   as integer   no-undo .
define variable v-name               as character no-undo .
define variable v-name-report        as character no-undo .
define variable v-obj-name           as character no-undo .
define variable o-head-position      AS character no-undo.    /* Должность */
define stream Out-Stream.
define stream OutStr-html.

define buffer buf_currency for ub.currency.
define buffer buf_sysconf  FOR ub.sysconf.

do
  on error undo, return error return-value
  :

  mCashBook = new ibs.th.ref.cashbookstorage () .
      
  o-uchet    = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "uchet") .
  if o-uchet = "0"
    then v-uchet = "cal" .
  else v-uchet = "smen" .
  
  delete object mCashBook no-error .

  run get-report-num  (output g#report-num).
  /*  run get-quest-print in parParentProc(output g#quest-print).*/
  v-file-name-rep-html = session:temp-directory + string(g#report-num) + ".html".
  
  if p-format <> 0
    and p-format <> ?
    and p-append
    then 
  do:
    assign
      p-format = ?
      .
    return.
  end.
  assign
    Line = fill("_":U, 136)
    .
  assign
    v-chernovik = if buf_fin-doc.status_ = {&fin-new}
                then "Ч Е Р Н О В И К"
                else (fill( {&space-char}, 15))
    .
  if buf_fin-doc.curr-code = 0 then 
  do:
    assign
      v-rub       = " {&abbr_rub}.":U
      v-kop       = " {&abbr_kop}.":U
      v-title-rub = v-rub + v-kop + {&space-char} + {&space-char}
      .
  end.
  else 
  do:
    find first buf_currency no-lock where
      buf_currency.curr-code = buf_fin-doc.curr-code .
    assign
      v-rub       = {&space-char} + buf_currency.curr-abbr + ".":U
      v-kop       = {&space-char} + buf_currency.part-abbr + ".":U
      v-title-rub = "       инвалюты       ":U
      v-okv-code  = (if buf_currency.okv-code = 0
                  then "Код ОКВ?"
                  else string(buf_Currency.okv-code))
      .
  end.

  assign
    v-enclosure-1 = Break-n-line(Buf_fin-doc.enclosure, "62,73", output num-lines)
    v-enclosure-2 = if num-lines >=2
                      then entry(2, v-enclosure-1, {&delim-par})
                      else "":U
    v-enclosure-1 = entry(1, v-enclosure-1, {&delim-par})
    .
  assign
    v-passport-1 = Break-n-line(Buf_fin-doc.receiver-passport, "70,73", output num-lines)
    v-passport-2 = if num-lines >=2
                      then entry(2, v-passport-1, {&delim-par})
                      else "":U
    v-passport-1 = entry(1, v-passport-1, {&delim-par})
    .
  assign
    v-date-create = buf_fin-doc.doc-date
    v-doc-date-f = string(buf_fin-doc.doc-date, "99.99.9999":U) + " г."
  .
  Case buf_fin-doc.str-podr-type :
    when {&shop} then 
      do:
        find first ub.shop
          where ub.shop.obj-code = buf_fin-doc.str-podr-code
          no-error.
        if available ub.shop then 
        do:
          assign 
            v-str-podr-name = buf_fin-doc.str-podr-name.
        end.
      end.
    when {&stock} then 
      do:
        find first ub.store
          where ub.store.obj-code = buf_fin-doc.str-podr-code
          no-error.
        if available ub.store then 
        do:
          assign 
            v-str-podr-name = buf_fin-doc.str-podr-name + " " + ub.store.addres1.
        end.
      end.
  end case.
  if v-str-podr-name = "" then v-str-podr-name = buf_fin-doc.str-podr-name .

  assign
    v-naznach-plat-1 = Break-n-line(buf_fin-doc.naznach-plat, "125,136":U, output num-lines)
    v-naznach-plat-2 = (if num-lines >=2
                      then entry(2, v-naznach-plat-1, {&delim-par})
                      else "":U
                      )
    v-naznach-plat-1 = entry(1, v-naznach-plat-1, {&delim-par})
    .

  if buf_fin-doc.curr-code = 0 then 
  do:
    assign
      v-dops = Sum-in-Words-Without-Dec(buf_fin-doc.sum-doc)
      .
    assign
      v-sum-kop-p = string((buf_fin-doc.sum-doc - truncate(buf_fin-doc.sum-doc, 0)) * 100, "99":U)
      .
    v-line2 = 121.
  end.
  else 
  do:
    assign
      v-dops  = Sum-in-Words-Invalut(buf_fin-doc.sum-doc, buf_fin-doc.curr-code)
      v-line2 = 136
      .
  end.

  assign
    v-sum-doc-v1 = Break-n-line(v-dops, ("128,":U + string(v-line2)), output num-lines)
    v-sum-doc-v2 = If num-lines >= 2
                 then entry(2, v-sum-doc-v1, {&delim-par})
                 else "":U
    v-sum-doc-v2 = v-sum-doc-v2 +  fill("-":U, v-line2 - length(v-sum-doc-v2))
    v-sum-doc-v1 = entry(1, v-sum-doc-v1, {&delim-par})
    v-sum-doc-v1 = v-sum-doc-v1 +  fill("-":U, 128 - length(v-sum-doc-v1))
    v-sum-doc-v1 = caps(substring(v-sum-doc-v1, 1, 1)) + substring(v-sum-doc-v1, 2)
    .
  assign
    v-sum-doc-n1 = Break-n-line(v-dops, ("128,":U + string(v-line2)), output num-lines)
    v-sum-doc-n2 = If num-lines >= 2
                 then entry(2, v-sum-doc-n1, {&delim-par})
                 else "":U
    v-sum-doc-n2 = v-sum-doc-n2 +  fill("-":U, v-line2 - length(v-sum-doc-n2))
    v-sum-doc-n1 = entry(1, v-sum-doc-n1, {&delim-par})
    v-sum-doc-n1 = v-sum-doc-n1 +  fill("-":U, 128 - length(v-sum-doc-n1))
    v-sum-doc-n1 = caps(substring(v-sum-doc-n1, 1, 1)) + substring(v-sum-doc-n1, 2)
    .
  
  /*Проверить, что печатать*/

  mCashBook = new ibs.th.ref.cashbookstorage () .
  o-head-position = mCashBook:getSinglRule(0 /* tt-fin-doc.CashBookId */, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "ManagerPosition") .
  /*      o-director      = mCashBook:getSinglRule(0 /* tt-fin-doc.CashBookId */, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "ManagerFIO") .*/
  /*      o-snr-accnt     = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BuhFIO") .*/
  delete object mCashBook no-error .

  case o-head-position:
    when '1':U then 
      do:
        v-head-position = "Директор".
      end.
    when '2':U then 
      do:
        v-head-position = "Управляющий".
      end.
    when '0':U then 
      do:
        for first buf_sysconf where buf_sysconf.host-code = buf_fin-doc.host-code:
          v-head-position = buf_sysconf.head-position.
        end.
      end.
    otherwise 
    do:
      v-head-position = o-head-position .
    end.  
  end case.
  /*                                                                                                                                                                                             */
  /*  if num-entries(buf_fin-doc.payer-sign1, {&delim-par})> 1 and entry(1, buf_fin-doc.payer-sign1, {&delim-par}) <> "" then v-head-position = entry(1, buf_fin-doc.payer-sign1, {&delim-par}) .*/
  /*                    else v-head-position = "Директор" .                                                                                                                                      */
  v-sign1         = (if num-entries(buf_fin-doc.payer-sign1, {&delim-par})  > 1
    then entry(2, buf_fin-doc.payer-sign1, {&delim-par})
    else entry(1, buf_fin-doc.payer-sign1, {&delim-par})
    )

    .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-code},OUTPUT v-hist-code ,OUTPUT par-type) .
  output stream OutStr-html to value(v-file-name-rep-html) convert target 'UTF-8'.
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    ' <html>' skip
    '  <head>' skip
    '   <meta charset="utf-8">' skip
    '    <style type="text/css">' skip
                        
    '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
    '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
    '   </style>' skip
    '  </head>' skip
    '<body>' skip
    .

  /*Печать*/
  put stream OutStr-html unformatted
    '<TABLE fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0" name="Отчет">'skip
    .

  put stream OutStr-html unformatted
    '<thead>' skip
    '<tr  class="set_columns">' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '<td style="width: 6px;"></td>' skip
    '</tr>' skip
    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="21" style="text-align: center;"></td>' skip
    '<td colspan="45" style="text-align: left;">Унифицированная форма № КО-2</td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="21" style="text-align: center;"></td>' skip
    '<td colspan="45" style="text-align: left;">Утверждена постановлением Госкомстата России от 18.08.98 №88</td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;"></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="49" style="text-align: center;"></td>' skip
    '<td colspan="16" style="text-align: center; border: 1px solid black;">Код</td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="35" style="text-align: center;"></td>' skip
    '<td colspan="13" style="text-align: right;">Форма по ОКУД</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">0310002</td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.payer-name + '</td>' skip
    '<td colspan="9" style="text-align: right;">по ОКПО</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">' + string(buf_fin-doc.payer-okpo) + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; font-size: 10px;">(организация)</td>' skip
    '<td colspan="9" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '<td colspan="16" rowspan="2" style="text-align: center; border: 1px solid black;">' + string( v-hist-code ) + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + v-str-podr-name + '</td>' skip
    '<td colspan="9" style="text-align: right; border-bottom: 0px solid white;"></td>' skip
    '<td></td>' skip
    '</tr>' skip    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align:center; font-size: 10px;">(структурное подразделение)</td>' skip
    '<td colspan="9" style="text-align: right; border-bottom: 0px solid white;"></td>' skip
    '<td colspan="16" style="text-align:center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip    .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align:center;"></td>' skip
    '<td colspan="10" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Номер документа</td>' skip
    '<td colspan="14" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Дата составления</td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;">РАСХОДНЫЙ КАССОВЫЙ ОРДЕР</td>' skip
    '<td colspan="10" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.prn-doc-code) + '</td>' skip
    '<td colspan="14" style="text-align: center; border: 1px solid black;">' + string(v-doc-date-f) + '</td>' skip
    '<td></td>' skip
    '</tr>' skip      .
  put stream OutStr-html unformatted 
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '<td colspan="10" style="text-align: center;"></td>' skip
    '<td colspan="14" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip    .
  put stream OutStr-html unformatted 
    '<tr>' skip
    '<td colspan="33" style="text-align: center; border: 1px solid black;">Дебет</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="6" style="text-align: center; border: 1px solid black;">Кредит</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="9" style="text-align: center; border: 1px solid black;">Сумма, руб. коп.</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="10" style="text-align: center; border: 1px solid black;">Код целевого назначения</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="7" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td text_wrap="true" rowspan="3" colspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" rowspan="3" colspan="9" style="text-align: center; border: 1px solid black;">код структурного подразделения</td>' skip
    '<td text_wrap="true" rowspan="3" colspan="9" style="text-align: center; border: 1px solid black;">корреспондирующий счет, субсчет</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="3" style="text-align: center; border: 1px solid black;">код аналитического учета</td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '</tr>' skip      .
  put stream OutStr-html unformatted       
    '<tr>' skip
    '<td text_wrap="true" colspan="4" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + "-"  + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.cor-acc-value) + '</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.an-uchet-value = "" then "-"  + '</td>' else buf_fin-doc.an-uchet-value + '</td>' skip
    '<td text_wrap="true" colspan="6" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cor-acc1-value = "" then "-"  + '</td>' else buf_fin-doc.cor-acc1-value + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + Sum-delim-with-defis(buf_fin-doc.sum-doc, 15) + '</td>' skip
    '<td text_wrap="true" colspan="10" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cel-nazn-value = "" then "-" + '</td>' else buf_fin-doc.cel-nazn-value + '</td>' skip
    '<td text_wrap="true" colspan="7" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td></td>' skip
    '</tr>' skip  .

  put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '</tr>' skip      .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="5" style="text-align: left;">Выдать</td>' skip
    '<td colspan="60" style="text-align: left; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-name + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="5" style="text-align: center;"></td>' skip
    '<td colspan="60" style="text-align: center; font-size: 10px;">(фамилия, имя, отчество)</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Основание:</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-naznach-plat-1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Сумма</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-sum-doc-v1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;"></td>' skip
    '<td colspan="55" style="text-align: center; font-size: 10px;">(прописью)</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="48" style="text-align: left; border-bottom: 1px solid black;">' + v-sum-doc-v2 + '</td>' skip
    '<td colspan="3" style="text-align: left;">руб.</td>' skip
    '<td colspan="7" style="text-align: center; border-bottom: 1px solid black;">' + string(v-sum-kop-p) + '</td>' skip
    '<td colspan="7" style="text-align: left;">коп.</td>' skip
    '<td></td>' skip
    '</tr>' skip      .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Приложение</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-enclosure-1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;">' + v-enclosure-2 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="18" style="text-align: left;">Руководитель организации</td>' skip
    '<td colspan="2" style="text-align: right;"></td>' skip
    '<td colspan="12" style="text-align: center; border-bottom: 1px solid black;">' + v-head-position + '</td>' skip
    '<td colspan="2" style="text-align: right;"></td>' skip
    '<td colspan="14" style="text-align: right; border-bottom: 1px solid black;"></td>' skip
    '<td colspan="2" style="text-align: right;"></td>' skip
    '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;">' + v-sign1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="18" style="text-align: left;"></td>' skip
    '<td colspan="2" style="text-align: right;"></td>' skip
    '<td colspan="12" style="text-align: center; font-size: 10px;">(должность)</td>' skip
    '<td colspan="2" style="text-align: right;"></td>' skip
    '<td colspan="14" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td colspan="2" style="text-align: right;"></td>' skip
    '<td colspan="15" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Главный бухгалтер</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; border-bottom: 1px solid black;">' + if buf_fin-doc.payer-sign2 = ? then " "  + '</td>' else buf_fin-doc.payer-sign2 + '</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '</tr>' skip            .
  put stream OutStr-html unformatted   
    '<tr>' skip
    '<td colspan="15" style="text-align: left;"></td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Получил</td>' skip
    '<td></td>' skip
    '<td colspan="54" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-sign3 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip         .
  put stream OutStr-html unformatted      
    '<tr>' skip
    '<td colspan="10" style="text-align: left;"></td>' skip
    '<td></td>' skip
    '<td colspan="54" style="text-align: center; font-size: 10px;">(сумма прописью)</td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted      
    '<tr>' skip
    '<td colspan="45" style="text-align: left; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="4" style="text-align: center;">руб.</td>' skip
    '<td colspan="11" style="border-bottom: 1px solid black;"></td>' skip
    '<td colspan="4" style="text-align: center;">коп.</td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted      
    '<tr>' skip
    '<td colspan="25" style="text-align: left; border-bottom: 1px solid black;">' + '"' + string(day(v-date-create), "99":U) + '" ' + MonthNameRusGen(Month(v-date-create)) + " " + string(year(v-date-create), "9999":U) + " г." + '</td>' skip
    '<td colspan="7"></td>' skip
    '<td colspan="8" style="text-align: center;"></td>' skip
    '<td colspan="11" style="border-bottom: 1px solid black;"></td>' skip
    '<td colspan="14" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="5" style="text-align: left;">По</td>' skip
    '<td colspan="60" style="text-align: left; border-bottom: 1px solid black;">' + v-passport-1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="5" style="text-align: left;"></td>' skip
    '<td colspan="60" style="text-align: center; font-size: 10px;">(наименование, номер, дата и место выдачи документа,</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;border-bottom: 1px solid black; height: 12px;">' + v-passport-2 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center; font-size: 10px;">удостоверяющего личность получателя)</td>' skip
    '<td></td>' skip
    '</tr>' skip     .    
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Выдал кассир</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; border-bottom: 1px solid black;">' + if buf_fin-doc.payer-sign3 = ? then " "  + '</td>' else buf_fin-doc.payer-sign3 + '</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '</tr>' skip            .
  put stream OutStr-html unformatted   
    '<tr>' skip
    '<td colspan="15" style="text-align: left;"></td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '</tr>' skip     
    '</thead>' skip
    '<tbody>' skip    
    .
  put stream OutStr-html unformatted
    '</tbody>' skip  
    '</table>' skip
    .

  put stream OutStr-html unformatted
        
    '</body>' skip
    '</html>' skip
    .
  output stream OutStr-html close.    
        
  run prn-lib-reportviewer-report-name in this-procedure (
    input THIS-PROCEDURE
    ,input v-file-name-rep-html
    ). 
    
    
PROCEDURE get-report-num :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  define output parameter p-report-num as integer no-undo .

  do
    on error undo, return error return-value
    :
    run gbl/getrpnum.p (output p-report-num).
  end.

END PROCEDURE.

end.    
    

/*    run rko2xl-close in this-procedure .*/
/*    if p-from-forms then do:                                                                        */
/*      { rep/q-print.i 0 }                                                                           */
/*    end. /*if from-forms*/                                                                          */
/*    else do:                                                                                        */
/*    if not p-append                                                                                 */
/*    then do:                                                                                        */
/*        os-delete                                                                                   */
/*            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )*/
/*        .                                                                                           */
/*        os-rename                                                                                   */
/*            value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )       */
/*            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )*/
/*        .                                                                                           */
/*        run prn-lib-prn-file in this-procedure (                                                    */
/*            input parParentProc                                                                     */
/*            , input 0                                                                               */
/*        ).                                                                                          */
/*        os-delete                                                                                   */
/*            value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )*/
/*        .                                                                                           */
/*        os-delete                                                                                   */
/*            value( v-rko2xl-cell-file-name )                                                        */
/*        .                                                                                           */
/*    end.                                                                                            */
/*    end. /*else if from-forms*/                                                                     */
/*end.*/