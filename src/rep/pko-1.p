block-level on error undo, throw.
/*

$Revision: b285b6565daa, 3011, rls $
$Author: EShklyar $
$Date: Ср апр 06 16:23:44 2022 +0300 $
$Workfile: pko-1.p $
$Archive: rep/pko-1.p $

Печать платежа  типа приход наличные

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
define variable vss-revision    as character no-undo init "$Revision: b285b6565daa, 3011, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pko-1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/pko-1.p $":U .
define variable vss-description as character no-undo init "Печать платежа  типа приход наличные".

&SCOP f-l MonthNameRusGen

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
define variable g#report-num  as integer no-undo .
define variable g#quest-print   as logical      no-undo.
{ gbl/cur-time.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ rep/frmlib.i }
/*{ rep/rpp1xl.i  }*/
{ gbl/db-attr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
define variable Line              as character no-undo .
define variable v-str-podr-name   as character no-undo .
define variable v-payer-name-p1   as character no-undo .
define variable v-payer-name-p2   as character no-undo .
define variable v-naznach-plat-p1 as character no-undo .
define variable v-naznach-plat-p2 as character no-undo .
define variable v-naznach-plat-p3 as character no-undo .
define variable v-naznach-plat-p4 as character no-undo .
define variable v-naznach-plat-l1 as character no-undo .
define variable v-naznach-plat-l2 as character no-undo .
define variable v-date-create     as date      no-undo .
define variable v-doc-date-f      as character no-undo .
define variable num-lines         as integer   no-undo .
define variable v-fill            as character no-undo init "_".
define variable v-sum-doc-p1      as character no-undo .
define variable v-sum-doc-p2      as character no-undo .
define variable v-sum-doc-p3      as character no-undo .
define variable v-sum-doc-l1      as character no-undo .
define variable v-sum-doc-l2      as character no-undo .
define variable v-sum-kop-p       as character no-undo .
define variable v-dops            as character no-undo .
define variable v-rub             as character no-undo .
define variable v-kop             as character no-undo .
define variable v-title-rub       as character no-undo .
define variable v-line3           as integer   no-undo .
define variable v-line2           as integer   no-undo .
define variable v-okv-code        as character no-undo .
define variable v-chernovik       as character no-undo .
define variable v-including       as character no-undo .
define variable v-inn             as character no-undo .
define variable g#log             as logical   no-undo .

define variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .
define variable o-uchet as character no-undo .
define variable v-uchet as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable par-type as character no-undo .
define variable v-tth as handle no-undo .
define variable l-ok  as logical no-undo .
define variable v-hist-name            as character no-undo .
define variable v-hist-code            as character no-undo .


define variable p-report-id          as character no-undo .
define variable v-file-name-rep-html as character no-undo .
define variable ii                   as integer   no-undo .
define variable v-name               as character no-undo .
define variable v-name-report        as character no-undo .
define variable v-obj-name           as character no-undo .
define stream Out-Stream.
define stream OutStr-html.

define buffer buf_currency for ub.currency.

do
on error undo, return error return-value
:
  
  message "Печатать отрывной лист квитанции ? " skip
  view-as alert-box question
  buttons yes-no
  update l-ok .
  
  mCashBook = new ibs.th.ref.cashbookstorage () .
      
  o-uchet    = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "uchet") .
  if o-uchet = "0"
  then v-uchet = "cal" .
  else v-uchet = "smen" .

  delete object mCashBook no-error .

  run get-report-num  (output g#report-num).
/*  run get-quest-print in parParentProc(output g#quest-print).*/
  v-file-name-rep-html = session:temp-directory + string(g#report-num) + ".html".
  
  output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
  output close.
/*  run pko1xl-init in this-procedure .*/

 if p-format <> 1
 and p-format <> ?
 and p-append
 then do:
  assign
  p-format = ?
  .
  return.
 end.
  assign
  Line = fill("_":U, 198)
  .
  assign
  v-chernovik = if buf_fin-doc.status_ = {&fin-new}
                then "Ч Е Р Н О В И К"
                else (fill( {&space-char}, 15))
  .
  if buf_fin-doc.curr-code = 0 then do:
    assign
    v-rub = " {&abbr_rub}.":U
    v-kop = " {&abbr_kop}.":U
    v-title-rub = fill({&space-char}, 3) +  v-rub + v-kop + fill({&space-char}, 4)
    .
  end.
  else do:
    find first buf_currency no-lock where
               buf_currency.curr-code = buf_fin-doc.curr-code .
    assign
    v-rub = {&space-char} + buf_currency.curr-abbr + ".":U
    v-kop = {&space-char} + buf_currency.part-abbr + ".":U
    v-title-rub = "    инвалюты     ":U
    v-okv-code = (if buf_currency.okv-code = 0
                  then "Код ОКВ?"
                  else string(buf_Currency.okv-code))
    .
  end.
  assign
  v-payer-name-p1 = Break-n-line(Buf_fin-doc.payer-name, "72,72", output num-lines)
  v-payer-name-p2 = if num-lines >=2
                   then entry(2, v-payer-name-p1, {&delim-par})
                   else "":U
  v-payer-name-p1 = entry(1, v-payer-name-p1, {&delim-par})
  .

  assign
  v-naznach-plat-p1 = Break-n-line(trim(Buf_fin-doc.naznach-plat), "28,35,35,35", output num-lines) .
  
  v-naznach-plat-p4 = if num-lines >=4
                      then entry(4, v-naznach-plat-p1, {&delim-par})
                      else "":U .
  v-naznach-plat-p3 = if num-lines >=3
                      then entry(3, v-naznach-plat-p1, {&delim-par})
                      else "":U .
  v-naznach-plat-p2 = if num-lines >=2
                      then entry(2, v-naznach-plat-p1, {&delim-par})
                      else "":U .
  v-naznach-plat-p1 = entry(1, v-naznach-plat-p1, {&delim-par})
  .
  assign
  v-naznach-plat-l1 = Break-n-line(Buf_fin-doc.naznach-plat, "95,106", output num-lines)
  v-naznach-plat-l2 = if num-lines >=2
                      then entry(2, v-naznach-plat-l1, {&delim-par})
                      else "":U
  v-naznach-plat-l1 = entry(1, v-naznach-plat-l1, {&delim-par})
  .

  assign
    v-date-create = buf_fin-doc.doc-date
    v-doc-date-f = string(buf_fin-doc.doc-date, "99.99.9999":U) + " г."
  .
  Case buf_fin-doc.str-podr-type :
    when {&shop} then do:
      find first ub.shop
      where ub.shop.obj-code = buf_fin-doc.str-podr-code
        no-error.
        if available ub.shop then do:
          assign v-str-podr-name = buf_fin-doc.str-podr-name.
        end.
    end.
    when {&stock} then do:
      find first ub.store
      where ub.store.obj-code = buf_fin-doc.str-podr-code
        no-error.
        if available ub.store then do:
          assign v-str-podr-name = buf_fin-doc.str-podr-name + " " + ub.store.addres1.
        end.
    end.
  end case.
  if v-str-podr-name = "" then v-str-podr-name = buf_fin-doc.str-podr-name .

  find first ub.firm where ub.firm.firm-code = buf_fin-doc.host-code no-error.
  if available ub.firm then do:
    assign v-inn = (if ub.firm.inn <> "" then (" ИНН " + ub.firm.inn) else "").
  end.

    assign
    v-dops = Sum-in-Words-Without-Dec(buf_fin-doc.sum-doc)
    v-sum-kop-p = string((buf_fin-doc.sum-doc - truncate(buf_fin-doc.sum-doc, 0)) * 100, "99":U)
    v-line3 = 41
    v-line2 = 66
    .

  assign
  v-sum-doc-p1 = Break-n-line(v-dops, ("41,41,":U + string(v-line3)), output num-lines)
  v-sum-doc-p3 = If num-lines >= 3
                 then entry(3, v-sum-doc-p1, {&delim-par})
                 else "":U
  v-sum-doc-p3 = v-sum-doc-p3 +  fill("-":U, 21 - length(v-sum-doc-p3))
  v-sum-doc-p2 = If num-lines >= 2
                 then entry(2, v-sum-doc-p1, {&delim-par})
                 else "":U
  v-sum-doc-p2 =  v-sum-doc-p2 +  fill("-":U, 41 - length(v-sum-doc-p2))
  v-sum-doc-p1 =  entry(1, v-sum-doc-p1, {&delim-par})
  v-sum-doc-p1 = v-sum-doc-p1 +  fill("-":U, 21 - length(v-sum-doc-p1))
  v-sum-doc-p1 = caps(substring(v-sum-doc-p1, 1, 1)) + substring(v-sum-doc-p1, 2)
  .

  assign
  v-sum-doc-l1 = Break-n-line(v-dops, ("66,":U + string(v-line2)), output num-lines)
  v-sum-doc-l2 = If num-lines >= 2
                 then entry(2, v-sum-doc-l1, {&delim-par})
                 else "":U
  v-sum-doc-l2 =  v-sum-doc-l2 +  fill("-":U, v-line2 - length(v-sum-doc-l2))
  v-sum-doc-l1 =  entry(1, v-sum-doc-l1, {&delim-par})
  v-sum-doc-l1 = v-sum-doc-l1 +  fill("-":U, 66 - length(v-sum-doc-l1))
  v-sum-doc-l1 = caps(substring(v-sum-doc-l1, 1, 1)) + substring(v-sum-doc-l1, 2)
  .
  
  assign
  v-including = replace(buf_fin-doc.including, "@":U, "":U)
  v-including = trim(v-including, {&comma-char})
  v-including = replace(v-including, "в том числе", "")
  v-including = replace(v-including, "в т.ч.:", "")
  v-including = replace(v-including, "в т.ч.", "")
  no-error .

    define variable v-sumRubKop         as character    no-undo.
    define variable v-kop-prop          as character    no-undo.
    define variable v-date-string       as character    no-undo.

    assign
        v-sumRubKop = ( if buf_fin-doc.curr-code = 0
                        then
                        trim( Sum-Rub-Kop-Digit (  INPUT buf_fin-doc.sum-doc
                                            ,INPUT 70
                                            ,INPUT 4
                                            ,INPUT " ":U
                                            ,INPUT "":U
                                            ,INPUT v-rub
                                            ,INPUT v-kop
                                            ) )
                        else
                        Sum-Invalut-Digit ( INPUT buf_fin-doc.sum-doc
                                            ,INPUT 40
                                            ,Input buf_fin-doc.curr-code
                                            ,INPUT " ":U
                                            ,INPUT "":U
                                            ))
    .
    assign
        v-kop-prop = ( if buf_fin-doc.curr-code = 0
                       then substitute( "&1 &2&3", v-rub, v-sum-kop-p, v-kop )
                       else "":U
                     )
    .
    assign
        v-date-string = substitute( '"&1" &2 &3 г.'
                                    , string( day( v-date-create ), "99":U )
                                    , MonthNameRusGen( Month( v-date-create ) )
                                    , string( Year( v-date-create ), "9999":U )
                                  )
    .
  run db-attr-value(INPUT v-cntxt-db-num,INPUT {&attr-hist-code},OUTPUT v-hist-code ,OUTPUT par-type) .
if l-ok then do:
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
    '<tr class="set_columns">' skip
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
    '<td style="width: 30px;"></td>' skip
    '<td style="width: 12px;"></td>' skip
    '<td style="width: 12px;"></td>' skip
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
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">Унифицированная форма № КО-1</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">Утверждена постановлением Госкомстата</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">России от 18.08.98 №88</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-name + " " + v-inn + '</td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="font-size: 10px; text-align: center;">(организация)</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="49" style="text-align: center;"></td>' skip
    '<td colspan="16" style="text-align: center; border: 1px solid black;">Код</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="35" style="text-align: center;"></td>' skip
    '<td colspan="13" style="text-align: right;">Форма по ОКУД</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">0310001</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;">КВИТАНЦИЯ</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-name + '</td>' skip
    '<td colspan="9" style="text-align: right;">по ОКПО</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">' + string(buf_fin-doc.receiver-okpo) + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; font-size: 10px;">(организация)</td>' skip
    '<td colspan="9" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '<td colspan="16" rowspan="2" style="text-align: center; border: 1px solid black;">' + string( v-hist-code ) + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + v-str-podr-name + '</td>' skip
    '<td colspan="10" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="27" style="text-align: left;">к приходному кассовому ордеру № </td>' skip
    '<td colspan="14" style="text-align: center; border-bottom: 1px solid black;">' + string(buf_fin-doc.prn-doc-code) + '</td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align:center; font-size: 10px;">(структурное подразделение)</td>' skip
    '<td colspan="10" style="text-align: right;"></td>' skip
    '<td colspan="16" style="text-align:center;"></td>' skip
    '<td></td>' skip
    '<td style="text-align: center; border-left: 1px solid black; border-right: 1px solid black;">л</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="4" style="text-align:right;">от "</td>' skip
    '<td colspan="4" style="text-align:center; border-bottom: 1px solid black;">' + string(day(v-date-create), "99":U) + '</td>' skip
    '<td colspan="2" style="text-align:left;">"</td>' skip
    '<td colspan="15" style="text-align:center; border-bottom: 1px solid black;">' + MonthNameRusGen(Month(v-date-create)) + '</td>' skip
    '<td colspan="1" style="text-align:left;"></td>' skip
    '<td colspan="6" style="text-align:center; border-bottom: 1px solid black;">' + string(Year(v-date-create), "9999") + '</td>' skip
    '<td colspan="2" style="text-align:left;">г.</td>' skip
    '<td colspan="6" style="text-align:left;"></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align:center;"></td>' skip
    '<td colspan="10" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Номер</td>' skip
    '<td colspan="14" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Дата</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left;"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '<td colspan="10" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black">документа</td>' skip
    '<td colspan="14" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black">составления</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">и</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="9" style="text-align: left;">Принято от</td>' skip
    '<td colspan="32" style="text-align: left; border-bottom: 1px solid black;">' + if v-payer-name-p1 = ? then " "  + '</td>' else v-payer-name-p1 + '</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;">ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР</td>' skip
    '<td colspan="10" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.prn-doc-code) + '</td>' skip
    '<td colspan="14" style="text-align: center; border: 1px solid black;">' + string(v-doc-date-f) + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; border-bottom: 1px solid black;">' + v-payer-name-p2 + '</td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted 
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '<td colspan="10" style="text-align: center;"></td>' skip
    '<td colspan="14" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">н</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="9" style="text-align: left;">Основание:</td>' skip
    '<td colspan="32" style="text-align: left; border-bottom: 1px solid black;">' + v-naznach-plat-p1 + '</td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted 
    '<tr>' skip
    '<td colspan="6" rowspan="4" style="text-align: center; border: 1px solid black;">Дебет</td>' skip
    '<td text_wrap="true" colspan="33" style="text-align: center; border: 1px solid black;">Кредит</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="9" style="text-align: center; border: 1px solid black;">Сумма, руб. коп.</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="10" style="text-align: center; border: 1px solid black;">Код целевого назначения</td>' skip
    '<td text_wrap="true" rowspan="4" colspan="7" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left; height: 12px; border-bottom: 1px solid black;">' + v-naznach-plat-p2 + '</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td text_wrap="true" rowspan="3" colspan="4" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" rowspan="3" colspan="9" style="text-align: center; border: 1px solid black;">код структурного подразделения</td>' skip
    '<td text_wrap="true" rowspan="3" colspan="9" style="text-align: center; border: 1px solid black;">корреспондирующий счет, субсчет</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="3" style="text-align: center; border: 1px solid black;">код аналитического учета</td>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">и</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left; height: 12px; border-bottom: 1px solid black;">' + v-naznach-plat-p3 + '</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; height: 12px; border-bottom: 1px solid black;"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">я</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left;">' + v-naznach-plat-p4 + '</td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted       
    '<tr>' skip
    '<td text_wrap="true" colspan="6" rowspan="2" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.cor-acc1-value) + '</td>' skip
    '<td text_wrap="true" colspan="4" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + "-" + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cor-acc-value = "" then "-"  + '</td>' else buf_fin-doc.cor-acc-value + '</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.an-uchet-value = "" then "-"  + '</td>' else buf_fin-doc.an-uchet-value + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + Sum-delim-with-defis(buf_fin-doc.sum-doc, 14) + '</td>' skip
    '<td text_wrap="true" colspan="10" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cel-nazn-value = "" then "-"  + '</td>' else buf_fin-doc.cel-nazn-value + '</td>' skip
    '<td text_wrap="true" colspan="7" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '</tr>' skip  .

      put stream OutStr-html unformatted
    '<tr>' skip
    '<td></td>' skip
    '<td text_wrap="true" style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="6" style="text-align: center;">Сумма</td>' skip
/*    '<td colspan="17" style="text-align: center; border-bottom: 1px solid black;"></td>' skip*/
    '<td colspan="34" style="text-align:left; border-bottom: 1px solid black;">' + string(v-sumRubKop) + '</td>' skip
/*    '<td colspan="3" style="text-align: center;"></td>' skip*/
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="6" style="text-align: center;"></td>' skip
    '<td colspan="34" style="text-align: center; font-size: 10px;">(цифрами)</td>' skip
/*    '<td colspan="18" style="text-align: center;"></td>' skip*/
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Принято от</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + if v-payer-name-p1 = ? then " "  + '</td>' else v-payer-name-p1 + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">о</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: left; border-bottom: 1px solid black;">' + string(v-sum-doc-p1) + '</td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: center;"></td>' skip
    '<td colspan="55" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-size: 10px;">(прописью)</td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Основание:</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-naznach-plat-l1 + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">т</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; border-bottom: 1px solid black;">' + string(v-sum-doc-p2) + '</td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: right; border-bottom: 1px solid black;">' + v-naznach-plat-l2 + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">р</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="23" style="text-align: center; border-bottom: 1px solid black;">' + string(v-sum-doc-p3) + '</td>' skip
    '<td colspan="5" style="text-align: left;">руб.</td>' skip
    '<td colspan="5" style="text-align: center; border-bottom: 1px solid black;">' + string(v-sum-kop-p) + '</td>' skip
    '<td colspan="4" style="text-align: left;">коп.</td>' skip
    '<td colspan="3" style="text-align: center;"></td>' skip            
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: left;">Сумма</td>' skip
    '<td colspan="59" style="text-align: left; border-bottom: 1px solid black;">' + v-sum-doc-l1 + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">е</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;">В том числе</td>' skip
    '<td colspan="31" text_wrap="true" style="text-align: left; border-bottom: 1px solid black;">' + replace(v-including, "@":U, "":U) + '</td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: left;"></td>' skip
    '<td colspan="59" style="text-align: center; font-size: 10px;">(прописью)</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">з</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="48" style="text-align: right; border-bottom: 1px solid black;">' + v-sum-doc-l2 + '</td>' skip
    '<td colspan="3" style="text-align: left;">руб.</td>' skip
    '<td colspan="7" style="text-align: right; border-bottom: 1px solid black;">' + string(v-sum-kop-p) + '</td>' skip
    '<td colspan="7" style="text-align: left;">коп.</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;">а</td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="2" style="text-align: right;">"</td>' skip
    '<td colspan="4" style="text-align: center; border-bottom: 1px solid black;">' + string(day(v-date-create), "99":U) + '</td>' skip
    '<td colspan="2" style="text-align: left;">"</td>' skip
    '<td colspan="15" style="text-align: center; border-bottom: 1px solid black;">' + MonthNameRusGen(Month(v-date-create)) + '</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="6" style="text-align: center; border-bottom: 1px solid black;">' + string(Year(v-date-create), "9999") + '</td>' skip
    '<td colspan="2" style="text-align: left;">г.</td>' skip
    '<td colspan="8" style="text-align: left;"></td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">В том числе</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-including + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: center;"></td>' skip
    '<td colspan="13" rowspan="2" style="text-align: center;">М.П. (штампа)</td>' skip
    '<td colspan="15" style="text-align: center;"></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Приложение</td>' skip
    '<td></td>' skip
    '<td colspan="54" style="text-align: left; border-bottom: 1px solid black;">' + buf_fin-doc.enclosure + '</td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black; text-align: center;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="3" style="text-align: center;"></td>' skip
    '<td colspan="15" style="text-align: center;"></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="align: center;"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;"></td>' skip
    '</tr>' skip   .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Главный бухгалтер</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; border-bottom: 1px solid black;">' + if buf_fin-doc.receiver-sign2 = ? then " "  + '</td>' else buf_fin-doc.receiver-sign2 + '</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;">Главный бухгалтер</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="9" style="text-align: left; border-bottom: 1px solid black;"></td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="20" text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + if buf_fin-doc.receiver-sign2 = ? then " "  + '</td>' else buf_fin-doc.receiver-sign2 + '</td>' skip
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
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;"></td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="9" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Получил кассир</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-sign3 + '</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;">Кассир</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="9" style="text-align: left; border-bottom: 1px solid black;"></td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="20" text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-sign3 + '</td>' skip
    '</tr>' skip         .
      put stream OutStr-html unformatted      
    '<tr>' skip
    '<td colspan="15" style="text-align: left;"></td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
    '<td colspan="3"></td>' skip
    '<td></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td style="border-left: 1px solid black; border-right: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="10" style="text-align: left;"></td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="9" style="text-align: center; font-size: 10px;">(подпись)</td>' skip
    '<td colspan="1" style="text-align: left;"></td>' skip
    '<td colspan="20" style="text-align: center; font-size: 10px;">(расшифровка подписи)</td>' skip
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
end.
else do:
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
    '<tr class="set_columns">' skip
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
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">Унифицированная форма № КО-1</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">Утверждена постановлением Госкомстата</td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="31" style="text-align: center;"></td>' skip
    '<td colspan="35" style="text-align: left;">России от 18.08.98 №88</td>' skip
    '</tr>' skip    .
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
    '<td colspan="16" style="text-align: center; border: 2px solid black;">0310001</td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-name + '</td>' skip
    '<td colspan="9" style="text-align: right;">по ОКПО</td>' skip
    '<td></td>' skip
    '<td colspan="16" style="text-align: center; border: 2px solid black;">' + string(buf_fin-doc.receiver-okpo) + '</td>' skip
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
    '<td colspan="10" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="39" style="text-align:center; font-size: 10px;">(структурное подразделение)</td>' skip
    '<td colspan="10" style="text-align: right;"></td>' skip
    '<td colspan="16" style="text-align:center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align:center;"></td>' skip
    '<td colspan="10" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Номер</td>' skip
    '<td colspan="14" style="text-align:center; border-left: 1px solid black; border-right: 1px solid black; border-top: 1px solid black">Дата</td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center;"></td>' skip
    '<td colspan="10" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black">документа</td>' skip
    '<td colspan="14" style="text-align: center; border-left: 1px solid black; border-right: 1px solid black; border-bottom: 1px solid black">составления</td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="41" style="text-align: center; font-weight: bold;">ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР</td>' skip
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
    '<td colspan="6" rowspan="4" style="text-align: center; border: 1px solid black;">Дебет</td>' skip
    '<td text_wrap="true" colspan="33" style="text-align: center; border: 1px solid black;">Кредит</td>' skip
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
    '<td text_wrap="true" colspan="6" rowspan="2" style="text-align: center; border: 1px solid black;">' + string(buf_fin-doc.cor-acc1-value) + '</td>' skip
    '<td text_wrap="true" colspan="4" rowspan="2" style="text-align: center; border: 1px solid black;"></td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + "-" + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cor-acc-value = "" then "-"  + '</td>' else buf_fin-doc.cor-acc-value + '</td>' skip
    '<td text_wrap="true" colspan="11" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.an-uchet-value = "" then "-"  + '</td>' else buf_fin-doc.an-uchet-value + '</td>' skip
    '<td text_wrap="true" colspan="9" rowspan="2" style="text-align: center; border: 1px solid black;">' + Sum-delim-with-defis(buf_fin-doc.sum-doc, 14) + '</td>' skip
    '<td text_wrap="true" colspan="10" rowspan="2" style="text-align: center; border: 1px solid black;">' + if buf_fin-doc.cel-nazn-value = "" then "-"  + '</td>' else buf_fin-doc.cel-nazn-value + '</td>' skip
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
    '<td colspan="10" style="text-align: left;">Принято от</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + if v-payer-name-p1 = ? then " "  + '</td>' else v-payer-name-p1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: center;"></td>' skip
    '<td colspan="55" style="text-align: right;"></td>' skip
    '<td></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Основание:</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-naznach-plat-l1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: right; border-bottom: 1px solid black;">' + v-naznach-plat-l2 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip    .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: left;">Сумма</td>' skip
    '<td colspan="59" style="text-align: left; border-bottom: 1px solid black;">' + v-sum-doc-l1 + '</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="6" style="text-align: left;"></td>' skip
    '<td colspan="59" style="text-align: center; font-size: 10px;">(прописью)</td>' skip
    '<td></td>' skip
    '</tr>' skip  .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="48" style="text-align: right; border-bottom: 1px solid black;">' + v-sum-doc-l2 + '</td>' skip
    '<td colspan="3" style="text-align: left;">руб.</td>' skip
    '<td colspan="7" style="text-align: right; border-bottom: 1px solid black;">' + string(v-sum-kop-p) + '</td>' skip
    '<td colspan="7" style="text-align: left;">коп.</td>' skip
    '<td></td>' skip
    '</tr>' skip      .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">В том числе</td>' skip
    '<td colspan="55" style="text-align: left; border-bottom: 1px solid black;">' + v-including + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="text-align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="10" style="text-align: left;">Приложение</td>' skip
    '<td></td>' skip
    '<td colspan="54" style="text-align: left; border-bottom: 1px solid black;">' + buf_fin-doc.enclosure + '</td>' skip
    '<td></td>' skip
    '</tr>' skip     .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="65" style="align: center;"></td>' skip
    '<td></td>' skip
    '</tr>' skip   .
      put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: left;">Главный бухгалтер</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" style="text-align: center; border-bottom: 1px solid black;">' + if buf_fin-doc.receiver-sign2 = ? then " "  + '</td>' else buf_fin-doc.receiver-sign2 + '</td>' skip
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
    '<td colspan="15" style="text-align: left;">Получил кассир</td>' skip
    '<td></td>' skip
    '<td colspan="20" style="text-align: center; border-bottom: 1px solid black;"></td>' skip
    '<td></td>' skip
    '<td colspan="25" text_wrap="true" style="text-align: center; border-bottom: 1px solid black;">' + buf_fin-doc.receiver-sign3 + '</td>' skip
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
  
end.          
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
    