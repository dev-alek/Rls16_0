/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

экспорт списка товаров в формате EXCEL

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/05/05
Author: Bakhtadze Natalya
Creation date: 11/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


{ rep/opclexcl.i }
{ gbl/prtmpldf.i }
{ gbl/waitfram.i }
{ ref/gds-attr.i }
{ ref/gdsoattr.i }
{ ref/gdshattr.i }
{ str/bc-gnrt.i new bc }
{ gbl/usr-flt.i }

DEFINE VARIABLE iColumn                 AS INTEGER no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-rec as recid no-undo .
define variable jj as integer no-undo .
define variable jj-1 as integer no-undo .
define variable j-n as integer no-undo .
define variable f-value as character no-undo .
define variable f-value-1 as character no-undo .
define variable f-name as character no-undo .
define variable t-name as character no-undo .
define variable f-name-1 as character no-undo .
define variable f-n as character no-undo .
define variable V-LENGTH as integer no-undo .
define variable V-NUM-CLMN as integer no-undo .
define variable v-bc-ne as integer no-undo .
define variable v-pbc-ne as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-f-name like ub.gds-prt.f-name no-undo .
define variable v-osn-frm as character no-undo .
define variable v-eng-frm as character no-undo .
define variable v-curr-r-b as character no-undo .
DEFINE VARIABLE bar-code-field-handle as HANDLE no-undo .
DEFINE VARIABLE prod-bc-field-handle as HANDLE no-undo .
define variable v-frm-set as logical no-undo .
define variable v-dop0 as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
define buffer buf_custom-labels for ub.custom-labels.
define buffer buf_usr-flt_custom-labels for usr-flt_custom-labels.

define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_filter for ubflt.filter.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_trn-doc  for ub.trn-doc.

{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }

{ ref/gdsreffi.i goo-doc gds-list p-curr-obj-type p-curr-obj-code anyl-xls }
&if "{2}" = "bb-list" &then
{ str/barcodfi.i }
&endif
{ gbl/curr-r-b.i v-curr-r-b }


FUNCTION get-function returns character(
input p-f-name as character,
input p-format as character
):

define variable main-b-code like ub.bar-code.b-code no-undo .
define variable bar_code as character no-undo .
define variable bar_bar_code as character no-undo .
define variable price-sale as decimal no-undo .
define variable for-road as decimal no-undo .
define variable for-excise as decimal no-undo .
define variable v-doc-num as character no-undo .
define variable v-last-inv-date-num as character no-undo.

  do
  on error undo, return error
  :
    CASE p-f-name:
      when "iColumn":U then do:
        return string(iColumn, p-format).
      end.
      when "qnty":U then do:
        return string({1}.qnty,  p-format).
      end.
      when "vat-value":U then do:
        return string(vat-value, p-format).
      end.
      when "slt-value":U then do:
        return string(slt-value, p-format).
      end.
      when "price-sale":U then do:
        /*получим главный код товара*/
        { gbl/gdsbcode.i {1}.gds-code ? main-b-code }

&if "{2}" = "bb-list" &then
    { gbl/bcodeprc.i
      p-curr-obj-type
      p-curr-obj-code
      {1}.b-code
      main-b-code
      0
      v-doc-num
      price-sale
      for-road
      for-excise
      no-error
    }
&else
    { gbl/bcodeprc.i
      p-curr-obj-type
      p-curr-obj-code
      main-b-code
      main-b-code
      0
      v-doc-num
      price-sale
      for-road
      for-excise
      no-error
    }

&endif
        return string(price-sale, p-format).
      end.
      when "node-name":U then do:
        return string(v-f-name, p-format).
      end.
      when "gdsbcode-graphic":U then do:
        /*получим главный код товара*/
        { gbl/gdsbcode.i {1}.gds-code ? main-b-code }
        /*преобразуем в что-то EAN по настройке*/
        RUN gen-bc in this-procedure ( input main-b-code, output bar_code ).
        run gbl/bctotext.p (
                        input (if length(bar_code) = 13 then {&barcode-ean13} else {&barcode-ean8})
                       ,input bar_code
                       ,output bar_bar_code) no-error .
        return ({&delim-par} + bar_bar_code).
      end.
      when "last-inv" then do :
        find last buf_doc-line no-lock where
                  buf_doc-line.artic = {1}.artic
              and buf_doc-line.prod-code = {1}.prod-code
              and buf_doc-line.prod-type = {1}.prod-type
              and buf_doc-line.obj-code = p-curr-obj-code
              and buf_doc-line.obj-type = p-curr-obj-type
              and buf_doc-line.status_ = {&fact}
              and buf_doc-line.ext-doc-type = {&TDEDT_Inv} no-error.
        if available buf_doc-line then do :
          find first buf_trn-doc no-lock where
                    buf_trn-doc.doc-code = buf_doc-line.doc-code no-error.
          if available buf_trn-doc then do :
            assign
              v-last-inv-date-num = string(buf_trn-doc.fact-date) + " № " + buf_trn-doc.doc-code
            .
          end.
        end.
        else do :
          assign
            v-last-inv-date-num = "[!!Нет инвентаризаций по данному товару]"
          .
        end.
        return v-last-inv-date-num.
      end.
    END CASE.

  end.

end FUNCTION. /* get-function */
for each buf_usr-flt_custom-labels:
  delete buf_usr-flt_custom-labels.
end.
for each  buf_custom-labels no-lock where
          buf_custom-labels.call-type = {&add-fields}
      and buf_custom-labels.call-point = {&uf-gdsreffi}:
  create buf_usr-flt_custom-labels.
  buffer-copy buf_custom-labels to buf_usr-flt_custom-labels.
end.
&if "{2}" = "bb-list" &then
for each  buf_custom-labels no-lock where
          buf_custom-labels.call-type = {&add-fields}
      and buf_custom-labels.call-point = {&uf-barcodfi}:
  create buf_usr-flt_custom-labels.
  buffer-copy buf_custom-labels to buf_usr-flt_custom-labels.
end.
&endif


if not valid-handle(my-handle) then do:
  assign
  my-handle = parparentproc.
end.
run init-prn-template in this-procedure .
run gbl/prntput.p (c-point, output v-rec).
run gbl/prntmpl.w (
                input parparentproc
              , input "":U /*bttn*/
              , input c-point
              , input Tbl
              , input join-tbl
              , input Fld
              , input Lab
              , input Spr
              , input v-size
              , input v-format
              , input Dim
              , input-output v-rec
              , OUTPUT V-LENGTH
              , OUTPUT V-NUM-CLMN
            ).
if v-rec = ? then return.
find first ubflt.filter no-lock where
           recid(ubflt.filter) = v-rec no-error .
if not avail ubflt.filter then return.

/*перекодируем*/
do jj = 1 to num-entries(ubflt.filter.Fields-sort):
  assign
  f-name-1 = "":U
  v-frm-set = no
  .
  do jj-1 = 1 to num-entries(entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U):
    if (entry(2, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".") = "artic"
        or
        entry(2, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".") = "b-str")
    and lookup(string(jj) + "=@":U, v-eng-frm) = 0
    then
    assign
    v-osn-frm = v-osn-frm + (if v-osn-frm = "":U then "":U else ";") + string(jj) + "=0":U
    v-eng-frm = v-eng-frm + (if v-eng-frm = "":U then "":U else ";") + string(jj) + "=@":U
    sheetf.colformat = v-osn-frm + {&delim-par} + v-eng-frm
    v-frm-set = yes
    .
    case entry(1, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), "."):
      when {&table_goods} or when {&table_gds-obj} then do:
        assign
        f-n = entry(2, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".")
        t-name = entry(1, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".")
        .
      end.
      when {&table_gds-obj-attr}
      or
      when {&table_gds-host-attr}
      or
      when {&table_goods-attr}
      then do:
        assign
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U)
        entry(1, f-n, ".") = "attr-value_"
        f-n = replace(f-n, ".", "")
        t-name = entry(1, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".").
      end.
      when "function":U then do:
        assign
        t-name = ''
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U)
        .
        if entry(2, entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U), ".") = 'gdsbcode-graphic':U
        then do:
          assign
          v-osn-frm = v-osn-frm + (if v-osn-frm = "":U then "":U else ";") + string(jj) + "=0":U
          v-eng-frm = v-eng-frm + (if v-eng-frm = "":U then "":U else ";") + string(jj) + "=@":U
          v-frm-set = yes
          .
          assign
          sheetf.colformat = v-osn-frm + {&delim-par} + v-eng-frm
          Sheetf.Bas-File = "exe/anyl-xls.bas"
          Sheetf.Bas-Params = Sheetf.Bas-Params +
                              (if Sheetf.Bas-Params = '':U
                               then '':U
                               else {&delim-par}) + string(jj) /*номер колонки в которой лежит бар-код для графики*/
          .
        end.
      end.
&if "{2}" = "bb-list" &then
      when {&table_bar-code}
      or
      when {&table_prod-bc}
      then do:
        assign
        f-n = entry(jj-1, entry(jj, ubflt.filter.Fields-sort), "{&delim-flt}":U)
        t-name = ''
        .
        if num-entries(f-n, ".") = 2 and
        entry(2, f-n, ".":U) = "b-str" then do:
          assign
          v-osn-frm = v-osn-frm + (if v-osn-frm = "":U then "":U else ";") + string(jj) + "=0":U
          v-eng-frm = v-eng-frm + (if v-eng-frm = "":U then "":U else ";") + string(jj) + "=@":U
          v-frm-set = yes
          .
        end.
      end.
&endif
    END CASE.
    assign
    f-name-1 = f-name-1 + (if f-name-1 = "":U then "":U else "{&delim-flt}":U) + (if t-name <> '':U then (t-name + ".") else '') + f-n
    .
    if v-frm-set = no then do:
      assign
      v-osn-frm = v-osn-frm + (if v-osn-frm = "":U then "":U else ";") + string(jj) + "=" +
                  prnfield_get-fformat(entry(jj, ubflt.filter.lst-cend)
                             ,entry(jj, ubflt.filter.where-ysl-rus, {&delim-par}))
      .
    end.
  end. /*jj-1*/

  assign
  f-name = f-name + (if f-name = "":U then "":U else {&comma-char}) + f-name-1
  .

end. /* jj */
assign
j-n = num-entries(f-name)
.
Sheetf.Bas-Params = string(5) + {&delim-par} + Sheetf.Bas-Params.
Make-excel = yes.
run get-report-num  in parParentProc(output g#report-num).
if Make-Excel then
RUN OpenForExcel in this-procedure .


FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.

FIND FIRST sheetf where
           sheetf.sheet-num = 1 No-ERROR.


assign
ReportName = "Список товаров"
str1 = substitute("(&1&2, фирма &3)", p-curr-obj-type, p-curr-obj-code, v-host-code)
sheetf.Excel-Column-Lable = ubflt.filter.Fields-sort-rus
sheetf.sizes = ubflt.filter.Where-ysl
.

run waitfram-show in this-procedure ("Экспорт в EXCEL. Ждите ...").
run rep/extitle.p (1).
iColumn = 0.  /* Начинаем писать со второй строки, 1-я - заголовок */
FOR EACH {1} no-lock,
    first ub.goods no-lock where
          ub.goods.gds-code = {1}.gds-code:
&if "{2}" = "bb-list" &then
  find first ub.bar-code no-lock  where ub.bar-code.b-code = {1}.b-code no-error.
  if not available ub.bar-code then do:
    assign
    v-bc-ne = v-bc-ne + 1.
    release ub.prod-bc.
  end.
  if not {1}.loc-ean and available ub.bar-code then
  find first ub.prod-bc no-lock where ub.prod-bc.b-str = {1}.b-str and ub.prod-bc.b-code = ub.bar-code.b-code no-error.
  if not available ub.prod-bc then do:
    assign
    v-pbc-ne = v-pbc-ne + 1.
  end.
  find first buf_gds-prt no-lock where
            buf_gds-prt.node-code = ub.bar-code.node-code no-error .
  if available buf_gds-prt then do:
    assign
    v-f-name = buf_gds-prt.f-name.
  end.
  else do:
    v-f-name = "!!!Неизвестный признак".
  end.
&endif
  if (iColumn modulo 10) = 0 then
    run waitfram-show in this-procedure ("Экспортировано в EXCEL строк : " + string (iColumn)).
  assign
  iColumn = iColumn + 1
  v-osn-frm = "":U
  v-eng-frm = "":U

  .
  { gbl/pftxvalg.i {1}.gds-code {&vat-tax-code} ? v-host-code p-curr-obj-type p-curr-obj-code vat-value no-error}
  { gbl/pftxvalg.i {1}.gds-code {&slt-tax-code} ? v-host-code p-curr-obj-type p-curr-obj-code slt-value no-error}

  do jj = 1 to j-n:
    assign
    f-value = "":U
    v-dop0 = entry(jj, f-name)
    v-dop1 = entry(1, entry(jj, f-name), ".")
    v-dop2 = entry(2, entry(jj, f-name), ".")
    .
    CASE v-dop1 :
      when "function":U then do:
        {&PutExcel}
        get-function(substr(v-dop0 ,10 ), entry(jj, ubflt.filter.Where-ysl-rus, {&delim-par}))
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end.
&if "{2}" = "bb-list" &then
      when {&table_bar-code} then do:
        if index(v-dop0, "{&delim-flt}":U) > 0 then do:
          do jj-1 = 1 to num-entries(v-dop0, "{&delim-flt}":U):
            assign
            f-value-1 = "":U.
            run barcodfi in this-procedure (
                             buffer bar-code
                            ,INPUT entry(jj-1, v-dop0, "{&delim-flt}":U)
                            ,INPUT-OUTPUT f-value-1
                            )  NO-ERROR .
            assign
            f-value = f-value + (if f-value = "":U then "":U else {&space-char}) + f-value-1
            .
          end.
        end. /*if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        else do:
          run barcodfi in this-procedure (
                           buffer bar-code
                          ,INPUT v-dop0
                          ,INPUT-OUTPUT f-value
                          )  NO-ERROR .
        end. /*else if index(v-dop0, "{&delim-flt}":U) > 0 then do:*/
        {&PutExcel}
        string(f-value, substitute("X(&1)", entry(jj, ubflt.filter.Where-ysl)))
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end.
      when {&table_prod-bc} then do:
          if available prod-bc then  do:
            prod-bc-field-handle = BUFFER prod-bc:BUFFER-FIELD(v-dop2 ).
            {&PutExcel}
            string((if v-dop2 = "b-str":U
                    then {&delim-par}
                    else "":U) + prod-bc-field-handle:buffer-value
                  , ({&double-quote} + entry(jj, ubflt.filter.Where-ysl-rus, {&delim-par}) + {&double-quote}))
            (if jj < j-n
            then
            {&tabulation}
            else {&new-line})
            .
          end.
          else do:
            if {1}.loc-ean or {1}.b-str <> "":U then do:
              CASE v-dop2:
                when "b-str" then do:
                  f-value-1 = {&delim-par} + {1}.b-str.
                end.
                when "b-on" then do:
                  f-value-1 = "yes":U.
                end.
              END CASE.
              {&PutExcel}
              string(f-value-1, ({&double-quote} + entry(jj, ubflt.filter.Where-ysl-rus, {&delim-par}) + {&double-quote}))
              (if jj < j-n
              then
              {&tabulation}
              else {&new-line})
              .
            end.
            else do:
              {&PutExcel}
              "":U
              (if jj < j-n
              then
              {&tabulation}
              else {&new-line})
              .
            end.
          end.
      end.
&endif
      otherwise do:
        if index(v-dop0, "{&delim-flt}":U) > 0 then do:
          do jj-1 = 1 to num-entries(v-dop0, "{&delim-flt}":U):
            assign
            f-value-1 = "":U.
            run gds-ref-fi in this-procedure (
                             buffer ub.goods
                            ,buffer ub.gds-obj
                            ,input p-curr-obj-type
                            ,input p-curr-obj-code
                            ,INPUT entry(jj-1, v-dop0, "{&delim-flt}":U)
                            ,input yes /*p-excel*/
                            ,INPUT-OUTPUT f-value-1
                            )  NO-ERROR .
            assign
            f-value = f-value + (if f-value = "":U then "":U else {&space-char}) + f-value-1
            .
          end.
        end.
        else do:
          run gds-ref-fi in this-procedure (
                           buffer ub.goods
                          ,buffer ub.gds-obj
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                          ,INPUT v-dop0
                          ,input yes /*p-excel*/
                          ,INPUT-OUTPUT f-value
                          )  NO-ERROR .
        end.
        {&PutExcel}
        if entry(jj, f-name) = "artic" then {&delim-par} else "":U
        string(replace(f-value, {&new-line}, ""), substitute("X(&1)", entry(jj, ubflt.filter.Where-ysl)))
        (if jj < j-n
        then
        {&tabulation}
        else {&new-line})
        .
      end. /*      if index(f-name, "{&delim-flt}":U) = 0 */
    END CASE.
  end. /*do jj = 1 to j-n:*/
END.

&if "{1}" = "gds-list" or "{1}" = "scn-list" or "{1}" = "bb-list" or "{1}" = "scnblist" &then

{&pageExcel}

FInd first Sheetf where
           Sheetf.sheet-num = 2 No-ERROR.
if not avail sheetf then
create sheetf.
assign
Sheetf.Sheet-num = 2
sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
sheetf.sizes = "9,9,9,12,155"
.


run rep/extitle.p (2).
run waitfram-show in this-procedure ("Экспорт в EXCEL истории").
for each {1}-hist:
  {&PutExcel}
  (if {1}-hist.line = 0
   then string({1}-hist.id, ">>>>>>>>9")
   else '':U)
  {&tabulation}
  (if {1}-hist.item_ <> '':U
   then {1}-hist.hist-mode
   else '':U)  {&tabulation}
   (if {1}-hist.item_ <> '':U
   then string({1}-hist.num-add, "->>>>>>>>9")
   else '':U)  {&tabulation}
  (if {1}-hist.item_ <> '':U
  then string({1}-hist.num-recs, ">>>>>>>>9")
  else '':U)  {&tabulation}
  {1}-hist.des
  skip.
end.
run waitfram-hide in this-procedure .
&endif


{&CloseExcel}
run waitfram-hide in this-procedure .
/*непосредственно открытие Excel*/

if Make-Excel then do:
   run rep/runexcel.p (
                   string( session:temp-directory +
                         {&DF_Name} +
                         string( g#report-num ) + ".txt":U )
                 ) .
end.

if Make-Excel then
RUN CLoseForExcel in this-procedure .

procedure init-prn-template :
define variable na                   as integer            no-undo .
DEFINE VARIABLE vtooltip             as character           no-undo.
DEFINE VARIABLE vlabel               as character           no-undo .
DEFINE VARIABLE vtype                as character           no-undo .
DEFINE VARIABLE vformat              as character           no-undo .
DEFINE VARIABLE vuser-can-edit       as character           no-undo .
DEFINE VARIABLE voutput-display      as character           no-undo .
DEFINE VARIABLE vother               as character           no-undo .


  do
  on error undo, return error
  :
    assign
&if "{2}" = "bb-list" &then
    join-tbl = 'Товары,Бар-коды,ДопБК,Глоб. атрибуты,Атр-ты на объ.,Атр-ты на фирме,Другое'
    tbl = {&table_goods} + {&comma-char} +
          {&table_bar-code} + {&comma-char} +
          {&table_prod-bc} + {&comma-char} +
          {&table_goods-attr} + {&comma-char} +
          {&table_gds-obj-attr} + {&comma-char} +
          {&table_gds-host-attr} + {&comma-char} + 'function'
    c-point = "Список кодов" + {&delim-par} +  "PRNT":u  + {&delim-par} + substitute("Список кодов - &1&2 фирма &3", p-curr-obj-type, p-curr-obj-code, v-host-code)
&else
    join-tbl = 'Товары,Глоб. атрибуты,Атр-ты на объ.,Атр-ты на фирме,Другое'
    tbl = {&table_goods} + {&comma-char} +
          {&table_goods-attr} + {&comma-char} +
          {&table_gds-obj-attr} + {&comma-char} +
          {&table_gds-host-attr} + {&comma-char} +
          'function'
    c-point = "Список товаров" + {&delim-par} +  "PRNT":u + {&delim-par} + substitute("Список товаров - &1&2 фирма &3", p-curr-obj-type, p-curr-obj-code, v-host-code)
&endif
    fld = ""
    lab = ""
    spr = ""
    dim = '0'
    v-size = "":U
    v-format = "":U
    .

    for each buf_usr-flt_custom-labels where
           buf_usr-flt_custom-labels.call-type = {&add-fields}
       and buf_usr-flt_custom-labels.call-point = {&uf-gdsreffi}
       and buf_usr-flt_custom-labels.tbl-name = {&table_goods}
    by buf_usr-flt_custom-labels.custom-label
       :

      run prnfield-add in this-procedure(input buf_usr-flt_custom-labels.fld-name
                                        ,input buf_usr-flt_custom-labels.custom-label
                                        ,input (if buf_usr-flt_custom-labels.custom-view-func <> ''
                                                or buf_usr-flt_custom-labels.fld-name begins "attr-value_"
                                                then substitute("attr.&1", buf_usr-flt_custom-labels.fld-data-type)
                                                else '')
                                        ,input integer(buf_usr-flt_custom-labels.widget-width)
                                        ,input buf_usr-flt_custom-labels.custom-format
                                        ,input-output fld
                                        ,input-output lab
                                        ,input-output spr
                                        ,input-output v-size
                                        ,input-output v-format
                                        ,input-output dim)  no-error.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
&if "{2}" = "bb-list" &then
    for each buf_usr-flt_custom-labels where
           buf_usr-flt_custom-labels.call-type = {&add-fields}
       and buf_usr-flt_custom-labels.call-point = {&uf-barcodfi}
       and buf_usr-flt_custom-labels.tbl-name = {&table_bar-code}
    by buf_usr-flt_custom-labels.custom-label
       :
      run prnfield-add in this-procedure(input buf_usr-flt_custom-labels.fld-name
                                        ,input buf_usr-flt_custom-labels.custom-label
                                        ,input (if buf_usr-flt_custom-labels.custom-view-func <> ''
                                                then substitute("attr.&1", buf_usr-flt_custom-labels.fld-data-type)
                                                else '')
                                        ,input integer(buf_usr-flt_custom-labels.widget-width)
                                        ,input buf_usr-flt_custom-labels.custom-format
                                        ,input-output fld
                                        ,input-output lab
                                        ,input-output spr
                                        ,input-output v-size
                                        ,input-output v-format
                                        ,input-output dim)  no-error.
    end.
    /*
    run prnfield-add in this-procedure('b-code', 'Бар-код', '', 9, "999999999":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('node-code', 'Признак', '', 40, "X(40)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('unit-cli', 'Ед.изм', 'unit', 6, "X(6)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('cli-base-rate', 'Коэфф', '', 13, ">>>,>>>9.9999":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    */
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
    run prnfield-add in this-procedure('b-str', 'ДопБК/лок.EAN', '', 18, "X(18)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('bc-on', 'Вкл', '', 6, "+/-":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .


&endif
    do na = 1 to num-entries({&gds-attr-list}):
      run gds-attr-name in this-procedure (
                         input entry(na, {&gds-attr-list})
                        ,output vtype
                        ,output vformat
                        ,output vlabel
                        ,output vuser-can-edit
                        ,output voutput-display
                        ,output vother) no-error.
      if NOT error-status:error and voutput-display = "yes":U then do:
        run prnfield-add in this-procedure(entry(na, {&gds-attr-list}), vlabel, 'ATTR.' + VTYPE, prnfield_get-fsize(vtype, vformat, vlabel), vformat,
        input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
      end.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
    /*добавим атрибуты товара на объекте*/
    do na = 1 to num-entries({&gdsoattr-list}):
      run gdsoattr-name in this-procedure (
                         input entry(na, {&gdsoattr-list})
                        ,output vtype
                        ,output vformat
                        ,output vlabel
                        ,output vuser-can-edit
                        ,output voutput-display
                        ,output vother) no-error.
      if NOT error-status:error and voutput-display = "yes":U then do:
        run prnfield-add in this-procedure(entry(na, {&gdsoattr-list}), vlabel, 'ATTR.' + VTYPE, prnfield_get-fsize(vtype, vformat, vlabel), vformat,
        input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
      end.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
    /*добавим атрибуты товара на фирме*/
    do na = 1 to num-entries({&gdshattr-list}):
      run gdshattr-name(
                         input entry(na, {&gdshattr-list})
                        ,output vtype
                        ,output vformat
                        ,output vlabel
                        ,output vuser-can-edit
                        ,output voutput-display
                        ,output vother) no-error.
      if NOT error-status:error and voutput-display = "yes":U then do:
        run prnfield-add in this-procedure(entry(na, {&gdshattr-list}), vlabel, 'ATTR.' + VTYPE, prnfield_get-fsize(vtype, vformat, vlabel), vformat,
        input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
      end.
    end.
    assign
    fld = fld
    lab = lab
    dim = dim + {&comma-char}
    .
    run prnfield-add in this-procedure('iColumn', '№', 'function.integer', 7, ">>>>>>9":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('gdsbcode-graphic', 'Главный код товара-штрихкод', 'function.character', 30, "X(30)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('qnty', 'Кол-во', 'function.integer', 12, "->>>,>>9.999":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('vat-value', 'НДС', 'function.decimal', 6, "99.99%":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('slt-value', 'НП', 'function.decimal', 6, "99.99%":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('price-sale', 'Цена', 'function.decimal', 6, ">>>,>>9.99":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.
    run prnfield-add in this-procedure('last-inv', '№ и дата посл.инв.', 'function.character', 45, "X(45)":U,
    input-output fld, input-output lab, input-output spr, input-output v-size, input-output v-format, input-output dim)  no-error.

  end.
end procedure. /* init-prn-template */

/* $Workfile$ e n d */