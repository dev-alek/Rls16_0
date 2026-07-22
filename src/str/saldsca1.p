block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: saldsca1.p $
$Archive: str/saldsca1.p $

Печать приложения к продаже - акт по скидкам - потоварно

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define output parameter p-frame-width as integer no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: saldsca1.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/saldsca1.p $":U .
def var vss-description as character no-undo init "Печать приложения к продаже - акт по скидкам-потоварно".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i new }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ rep/dincol.i }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }

DEFINE VARIABLE Line                as character                    no-undo .

define variable v-ov-base           as decimal no-undo .
define variable v-ov-rubl           as decimal no-undo .
define variable v-num as integer no-undo .
define variable v-str as character no-undo extent 7.
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-r-b-abbr as character no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log as logical no-undo .
define variable max-sections as integer no-undo .
define variable strbuf as character no-undo .
define variable v-col-delim as character no-undo .
define variable v-section-delim as character no-undo .
define variable accum-b-code-qnty as decimal no-undo .
define variable accum-b-code-sum as decimal no-undo .
define variable accum-qnty as decimal no-undo .
define variable accum-sum as decimal no-undo .
define variable accum-sum-doc as decimal no-undo .
define variable date_string  as character no-undo .


define temp-table temp-chk-gds no-undo
field b-code     like ub.chk-gds.b-code
field price-base like ub.chk-gds.price-base
field doc-qnty   like ub.chk-gds.doc-qnty
field line-num   like ub.chk-gds.line-num

field is-out     as integer
field doc-price  like ub.gds-dtl.price-rubl
field doc-discnt like ub.gds-dtl.discnt-rubl
field gds-code   like ub.goods.gds-code
field sum-base   as decimal
field discnt-base as decimal
index pi is unique primary
b-code
is-out
price-base
index iline is unique
b-code
is-out
line-num
index iout
is-out descending

.


define buffer buf_inkas for ub.inkas .
define buffer buf_shop for ub.shop.
define buffer buf_clients for ub.clients.
define buffer buf_temp-chk-gds for temp-chk-gds.
define buffer buf_goods for ub.goods.

&scop frm-artic  "X(16)"
&scop len-artic  16
&scop frm-gds-name  "X(39)"
&scop len-gds-name  39
&scop frm-barcode  ">>>>>>>>9"
&scop frm-barcode-str  "X(9)"
&scop len-barcode  9
&scop frm-price-base ">>>,>>9.999"
&scop frm-price-base-str "X(11)"
&scop len-price-base 11
&scop frm-qnty ">>>,>>9.999"
&scop frm-qnty-str "X(11)"
&scop len-qnty 11
&scop frm-sum "->>>,>>>,>>9.999"
&scop frm-sum-str "X(16)"
&scop len-sum 16
&scop frm-qnty-total "->>>,>>>,>>9.999"
&scop frm-qnty-total-str "X(16)"
&scop len-qnty-total 16
&scop frm-sum-total "->>,>>>,>>>,>>9.999"
&scop frm-sum-total-str "X(19)"
&scop len-sum-total 19

&scop underline ~
  put stream Prnlibstream unformatted                                     ~
             fill( ~{&u-symbol~}, ~{&len-artic~})                                     ~
  v-col-delim fill( ~{&u-symbol~}, ~{&len-barcode~})                                  ~
  v-col-delim fill( ~{&u-symbol~}, ~{&len-gds-name~})                                 ~
  .                                                                       ~
  do ii = 1 to max-sections:                                              ~
    put stream Prnlibstream unformatted                                   ~
    v-section-delim fill( ~{&u-symbol~}, ~{&len-price-base~})                         ~
    v-col-delim fill( ~{&u-symbol~}, ~{&len-qnty~})                                   ~
    v-col-delim fill( ~{&u-symbol~}, ~{&len-sum~})                                    ~
    .                                                                     ~
  end.                                                                    ~
  put stream Prnlibstream unformatted                                     ~
  v-section-delim fill( ~{&u-symbol~} , ~{&len-qnty-total~})                          ~
  v-col-delim fill( ~{&u-symbol~} , ~{&len-sum-total~})                               ~
  v-col-delim fill( ~{&u-symbol~} , ~{&len-sum-total~})                               ~
  v-col-delim fill( ~{&u-symbol~} , ~{&len-sum-total~})                               ~
  skip



do
on error undo, return error
:

  if not valid-handle(my-handle) then do:
    assign
    my-handle = parparentproc.
  end.
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  find first buf_inkas no-lock where
              buf_inkas.inkas-code = p-inkas-code no-error .
  if NOT available buf_inkas then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неправильный выбор кассового отчета."
    view-as alert-box WARNING .
    return error .
  end.
  { gbl/r-b-abbr.i
   buf_inkas.host-code
   v-r-b-abbr }
  find first buf_shop no-lock where
            buf_shop.obj-code = buf_inkas.obj-code no-error .
  if not available buf_shop then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден объект для кассового отчета." p-inkas-code
    view-as alert-box WARNING .
    return error .
  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = {&shop}
        AND buf_clients.obj-code = buf_shop.obj-code no-error .
  run calculate-discnt in this-procedure (
                                           input v-curr-r-b
                                         , input buf_inkas.inkas-code
                                         , output v-ov-base
                                         , output v-ov-rubl) no-error .
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при подсчете скидок по переоценке для кассового отчета." p-inkas-code skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box WARNING .
    undo, return error .
  end.
  assign
  v-col-delim = {&space-char}
  v-section-delim = "|":U
  make-excel = yes
  reportname = "Отчет по скидкам, возникшим в результате разницы в документе продажи и чеках"
  str1       = substitute("Отчет о продаже &1 &2&3"
                           , buf_inkas.inkas-code
                           , buf_inkas.obj-type
                           , buf_inkas.obj-code)

  .
  run get-report-num  in parParentProc(output g#report-num).
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).

  RUN OpenForExcel in this-procedure .



  assign
  StrBuf =              string( "Артикул", {&frm-artic} ) +
           v-col-delim + string( "Бар-код", {&frm-barcode-str} ) +
           v-col-delim + string( "Название товара", {&frm-gds-name} )
  sheetf.Excel-COlumn-Lable = string( "   Артикул", {&frm-artic} ) + {&comma-char} +
                              string( "Бар-код", {&frm-barcode-str} ) + {&comma-char} +
                              string( "     Название товара", {&frm-gds-name} ) + {&comma-char}
  sheetf.sizes = "{&len-artic}" + {&comma-char} +
                 "{&len-barcode}"  + {&comma-char} +
                 "{&len-gds-name}"  + {&comma-char}
  p-frame-width = {&len-artic} + {&len-barcode} + {&len-gds-name}

  .
  do ii = 1 to max-sections:
    assign
    StrBuf = StrBuf + v-section-delim + string( "Цена в чеке", {&frm-price-base-str} ) +
            v-col-delim + string( "К-во в чеке", {&frm-qnty-str} ) +
            v-col-delim + string( "Сумма по чеку", {&frm-sum-str} )
    sheetf.Excel-COlumn-Lable = sheetf.Excel-COlumn-Lable +
                                string( "Цена в чеке", {&frm-price-base-str} ) + {&comma-char} +
                                string( "Кол-во в чеке", {&frm-qnty-str} ) + {&comma-char} +
                                string( "Сумма по чеку", {&frm-sum-str} ) + {&comma-char}
    sheetf.sizes = sheetf.sizes +
                                    "{&len-price-base}" + {&comma-char} +
                                    "{&len-qnty}"  + {&comma-char} +
                                    "{&len-sum}"  + {&comma-char}
    p-frame-width = p-frame-width + {&len-price-base} + {&len-qnty} + {&len-sum}
    .
  end. /*do ii*/
  assign
  StrBuf = StrBuf + v-section-delim + string( "Кол-во ИТОГО", {&frm-qnty-total-str} ) +
          v-col-delim + string( "Сумма по чекам", {&frm-sum-total-str} ) +
          v-col-delim + string( "Сумма по докум-ту", {&frm-sum-total-str} ) +
          v-col-delim + string( "Разница", {&frm-sum-total-str} )
  sheetf.Excel-COlumn-Lable = sheetf.Excel-COlumn-Lable +
                              string( "Кол-во ИТОГО", {&frm-qnty-total-str} ) + {&comma-char} +
                              string( "Сумма по чекам", {&frm-sum-total-str} ) + {&comma-char} +
                              string( "Сумма по док-ту", {&frm-sum-total-str} ) + {&comma-char} +
                              string( "Разница", {&frm-sum-total-str} )
  sheetf.sizes = sheetf.sizes +
                                  "{&len-qnty-total}"  + {&comma-char} +
                                  "{&len-sum-total}"  + {&comma-char} +
                                  "{&len-sum-total}"  + {&comma-char} +
                                  "{&len-sum-total}"
  p-frame-width = p-frame-width + {&len-qnty-total} + {&len-sum-total}  + {&len-sum-total}  + {&len-sum-total}
  sheetf.colformat = sheetf.colformat + {&delim-par} + "1=@"
  Sheetf.Bas-FIle = "exe/saldsca1.bas"
  .

  run rep/extitle.p (1).
  Sheetf.Bas-Params = string(max-sections) + {&delim-par} + string(Sheetf.Excel-Row-Heder).
  /*конец шапки*/
  Line = fill("-", 198).
  date_string = cur-time-print() .

  Put stream PrnLibstream unformatted
  reportname skip
  str1
   skip(1)
   date_string AT 5 format "X(35)"
   skip(1)
   .

  Put stream PrnLibStream unformatted StrBuf SKIP .
&SCOP U-SYMBOL "-"
  {&UNDERLINE}.
  _temp-chk-gds:
  for each temp-chk-gds where
  by temp-chk-gds.is-out descending
  by temp-chk-gds.b-code
  by temp-chk-gds.line-num
  :
    if temp-chk-gds.line-num = 1  then do:
      find first buf_goods no-lock where
                buf_goods.gds-code = temp-chk-gds.b-code.
      Put stream Prnlibstream  unformatted
                 buf_goods.artic format {&frm-artic}
      v-col-delim temp-chk-gds.b-code format {&frm-barcode}
      v-col-delim buf_goods.gds-name format {&frm-gds-name}
      .
      {&PutExcel}
      ({&delim-par} + buf_goods.artic) format {&frm-artic} {&tabulation}
      temp-chk-gds.b-code format {&frm-barcode} {&tabulation}
      buf_goods.gds-name format {&frm-gds-name} {&tabulation}
      .
      assign
      accum-b-code-qnty = 0
      accum-b-code-sum = 0
      ii = 0
      .
      for each buf_temp-chk-gds no-lock where
              buf_temp-chk-gds.is-out = temp-chk-gds.is-out
          AND buf_temp-chk-gds.b-code = temp-chk-gds.b-code
      by buf_temp-chk-gds.price-base:
        assign
        ii = ii + 1
        accum-b-code-qnty = accum-b-code-qnty + buf_temp-chk-gds.doc-qnty
        accum-b-code-sum = accum-b-code-sum + buf_temp-chk-gds.sum-base
        accum-qnty = accum-qnty + buf_temp-chk-gds.doc-qnty
        accum-sum = accum-sum + buf_temp-chk-gds.sum-base
        .
        put stream Prnlibstream unformatted
        v-section-delim buf_temp-chk-gds.price-base format  {&frm-price-base}
        v-col-delim  buf_temp-chk-gds.doc-qnty   format {&frm-qnty}
        v-col-delim (buf_temp-chk-gds.doc-qnty * buf_temp-chk-gds.price-base)  format {&frm-sum}
        .
        {&PutExcel}
        buf_temp-chk-gds.price-base          {&tabulation}
        buf_temp-chk-gds.doc-qnty            {&tabulation}
        (buf_temp-chk-gds.doc-qnty * buf_temp-chk-gds.price-base)   {&tabulation}
        .

      end.
      if ii < max-sections then do:
        do jj = 1 to (max-sections - ii):
          put stream Prnlibstream
          v-section-delim fill({&space-char},  {&len-price-base})
          v-col-delim fill({&space-char},  {&len-qnty})
          fill({&space-char},  {&len-sum})
          .
          {&PutExcel}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          .
        end.
      end.
      put stream Prnlibstream unformatted
      v-section-delim accum-b-code-qnty  format {&frm-qnty-total}
      v-col-delim accum-b-code-sum  format {&frm-sum-total}
      v-col-delim temp-chk-gds.doc-price * accum-b-code-qnty format {&frm-sum-total}
      v-col-delim  (temp-chk-gds.doc-price * accum-b-code-qnty - accum-b-code-sum) format {&frm-sum-total}
      skip
      .
      {&putExcel}
      accum-b-code-qnty  {&tabulation}
      accum-b-code-sum  {&tabulation}
      temp-chk-gds.doc-price * accum-b-code-qnty {&tabulation}
      (temp-chk-gds.doc-price * accum-b-code-qnty - accum-b-code-sum) {&tabulation}
      skip.
      accum-sum-doc = accum-sum-doc + (temp-chk-gds.doc-price * accum-b-code-qnty).
    end.
    else do:
      NEXT _temp-chk-gds.
    end.
  end. /*for each temp-chk-gds*/
&SCOP U-SYMBOL "_"
  {&UNDERLINE}.
  put stream Prnlibstream unformatted
              fill( {&space-char}, {&len-artic})
  v-col-delim fill( {&space-char}, {&len-barcode})
  v-col-delim fill( {&space-char}, {&len-gds-name})
  .
  {&putexcel}
  {&tabulation}
  {&tabulation}
  {&tabulation}
  .
  do ii = 1 to max-sections:
    put stream Prnlibstream unformatted
    v-section-delim  fill( {&space-char}, {&len-price-base})
    v-col-delim      fill( {&space-char}, {&len-qnty})
    v-col-delim      fill( {&space-char}, {&len-sum})
    .

    {&putexcel}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    .
  end.
  put stream Prnlibstream unformatted
  v-section-delim fill( {&space-char} , {&len-qnty-total})
  v-col-delim accum-sum                    format {&frm-sum-total}
  v-col-delim accum-sum-doc                format {&frm-sum-total}
  v-col-delim (accum-sum-doc -  accum-sum) format {&frm-sum-total}
  skip
  .
  {&putexcel}
  {&tabulation}
  accum-sum {&tabulation}
  accum-sum-doc {&tabulation}
  (accum-sum-doc -  accum-sum) skip.
  output  STREAM PrnLibStream CLOSE.
  {&CloseExcel}
  /*run get-quest-print in parParentProc(output g#quest-print).*/

  run prn-lib-prn-file in this-procedure (
                                           input parParentProc
                                          ,input (if p-frame-width <= 198 then 8 else 9)
                                          ).

end. /*doe*/




procedure calculate-discnt :
define input parameter p-curr-r-b as character no-undo .
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define output parameter p-ov-base as decimal no-undo .
define output parameter p-ov-rubl as decimal no-undo .

define variable v-b-code like ub.bar-code.b-code no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-doc-num         like ub.price-doc.doc-num     no-undo.
define variable v-ras-price like ub.gds-dtl.price-rubl no-undo .
define variable v-ras-discnt like ub.gds-dtl.discnt-rubl no-undo .
define variable v-voz-price like ub.gds-dtl.price-rubl no-undo .
define variable v-voz-discnt like ub.gds-dtl.discnt-rubl no-undo .
define variable v-is-out    as integer no-undo .

define buffer buf_trn for ub.trn-doc.
define buffer buf_ret for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_goods  for ub.goods.
define buffer buf_bar-code  for ub.bar-code.

  do
  on error undo, return error
  :
    for each temp-chk-gds:
      delete temp-chk-gds.
    end.
    find first buf_trn no-lock where
              buf_trn.doc-code = p-inkas-code no-error .
    if not available buf_trn then do:
      undo, return error substitute("Не найдена расходная часть для кассового отчета &1", p-inkas-code).
    end.
    find first buf_ret no-lock where
            buf_ret.doc-code = buf_trn.out-code no-error .
    run waitfram-show in this-procedure ("Ждите..." ).
    _chk-gds:
    FOR EACH buf_chk-gds No-LOCK WHERE
           buf_chk-gds.out-code = p-inkas-code,
        FIRST buf_chk-doc NO-LOCK where
              buf_chk-doc.doc-code = buf_chk-gds.doc-code,
        FIRST buf_bar-code No-LOCK WHERE
              buf_bar-code.b-code = buf_chk-gds.b-code,
        FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = buf_bar-code.gds-code
    BREAK
    BY buf_chk-gds.b-code:
      run waitfram-show in this-procedure (string("Ждите ... Обработка товара " +
                                  string(buf_chk-gds.b-code, "9999999999")
                          )         ).
      IF FIRST-OF(buf_chk-gds.b-code) then do:
        FIND FIRST buf_gds-dtl WHERE
                  buf_gds-dtl.doc-code = buf_trn.doc-code
              AND buf_gds-dtl.artic = buf_goods.artic
              AND buf_gds-dtl.prod-type = buf_goods.prod-type
              AND buf_gds-dtl.prod-code = buf_goods.prod-code
              AND buf_gds-dtl.prt-code = buf_bar-code.node-code no-error.
        if available buf_gds-dtl then do:
          assign
          v-ras-price = (if v-curr-r-b = {&r-b-rubl}
                         then buf_gds-dtl.price-rubl
                         else buf_gds-dtl.price-base)
          v-ras-discnt = (if v-curr-r-b = {&r-b-rubl}
                         then buf_gds-dtl.discnt-rubl
                         else buf_gds-dtl.discnt-base).

        end.
        if available buf_ret then do:
          FIND FIRST buf_gds-dtl WHERE
                    buf_gds-dtl.doc-code = buf_ret.doc-code
                AND buf_gds-dtl.artic = buf_goods.artic
                AND buf_gds-dtl.prod-type = buf_goods.prod-type
                AND buf_gds-dtl.prod-code = buf_goods.prod-code
                AND buf_gds-dtl.prt-code = buf_bar-code.node-code no-error.
          if available buf_gds-dtl then do:
            assign
            v-voz-price = (if v-curr-r-b = {&r-b-rubl}
                          then buf_gds-dtl.price-rubl
                          else buf_gds-dtl.price-base)
            v-voz-discnt = (if v-curr-r-b = {&r-b-rubl}
                          then buf_gds-dtl.discnt-rubl
                          else buf_gds-dtl.discnt-base).

          end.
        end.
      END. /*IF FIRST-OF(buf_chk-gds.b-code) then do:*/
      CASE buf_chk-doc.chk-type:
        when integer({&rcpt-sale})
        or when integer({&rcpt-write-off})
        then do:
          if abs(buf_chk-gds.price-base - v-ras-price) < 0.005 then NEXT _chk-gds.
          v-is-out = 1.
        end.
        when integer({&rcpt-return})
        or
        when integer({&rcpt-return-write-off})
        then do:
          if abs(buf_chk-gds.price-base - v-voz-price) < 0.005 then NEXT _chk-gds.
          v-is-out = - 1.
        end.
        otherwise do:
          if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
          if buf_chk-doc.netto >= 0 then do:
            if abs(buf_chk-gds.price-base - v-ras-price) < 0.005 then NEXT _chk-gds.
            v-is-out = 1.
          end.
          if buf_chk-doc.netto < 0 then do:
            if abs(buf_chk-gds.price-base - v-voz-price) < 0.005 then NEXT _chk-gds.
            v-is-out = - 1.
          end.
        end.
      END CASE.
      find first temp-chk-gds where
                temp-chk-gds.b-code = buf_chk-gds.b-code
            AND temp-chk-gds.is-out = v-is-out
            AND temp-chk-gds.price-base = buf_chk-gds.price-base use-index pi no-error.
      if not available temp-chk-gds then do:
        find last buf_temp-chk-gds no-lock where
                  buf_temp-chk-gds.b-code = buf_chk-gds.b-code
              AND buf_temp-chk-gds.is-out = v-is-out  use-index iline no-error .
        create temp-chk-gds.
        buffer-copy buf_chk-gds
        except doc-code to
        temp-chk-gds
        assign
        temp-chk-gds.price-base = buf_chk-gds.price-base
        temp-chk-gds.sum-base = buf_chk-gds.doc-qnty * buf_chk-gds.price-base
        temp-chk-gds.discnt-base = buf_chk-gds.doc-qnty * buf_chk-gds.discnt
        temp-chk-gds.line-num = (if not available buf_temp-chk-gds then 1 else buf_temp-chk-gds.line-num + 1)
        temp-chk-gds.is-out   = v-is-out
        temp-chk-gds.doc-price = (if v-is-out = 1 then v-ras-price else v-voz-price)
        temp-chk-gds.doc-discnt = (if v-is-out = 1 then v-ras-discnt else v-voz-discnt)
        temp-chk-gds.gds-code = buf_goods.gds-code
        max-sections = maximum(temp-chk-gds.line-num, max-sections)
        .
      end.
      else do:
        assign
        temp-chk-gds.doc-qnty = temp-chk-gds.doc-qnty + buf_chk-gds.doc-qnty
        temp-chk-gds.sum-base = temp-chk-gds.sum-base +
                                    buf_chk-gds.doc-qnty * buf_chk-gds.price-base
        temp-chk-gds.discnt-base = temp-chk-gds.discnt-base +
                                       buf_chk-gds.doc-qnty * buf_chk-gds.discnt
        .
      end.
    end. /*FOR EACH buf_chk-gds No-LOCK WHERE*/
    run waitfram-hide in this-procedure .
    output to jj.txt.
    for each temp-chk-gds:
    export temp-chk-gds.
    end.
    output close.
  end. /*doe*/

end procedure. /* calculate-discnt */