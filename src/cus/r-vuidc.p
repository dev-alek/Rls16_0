block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-vuidc.p $
$Archive: cus/r-vuidc.p $

ОТЧЕТ ПО ПОКУПКАМ ПОСТОЯННЫХ КЛИЕНТОВ ( С ДИС.КАРТАМИ) для Lui Vuitton - данные и печать

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/23/03
Author: Bakhtadze Natalya
Creation date: 09/23/03

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-vuidc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-vuidc.p $":U .
define variable vss-description as character no-undo init "ОТЧЕТ ПО ПОКУПКАМ ПОСТОЯННЫХ КЛИЕНТОВ ( С ДИС.КАРТАМИ) для Lui Vuitton - данные и печать".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new}
{ gbl/prn-lib.i }
{ cmp/r-page1.i }
{ gbl/cur-time.i }
/*данные по продажам и клиентам*/
{ cus/r-vuidcd.i "NEW SHARED" }
{ gbl/waitfram.i }

define variable sheets              as integer no-undo.
define variable Line                as character no-undo .
define variable num-g#              as integer no-undo.
define variable FixProdAttr         as character no-undo.
define variable v-name like ub.clients.obj-name no-undo .
define variable v-first-date        like ub.chk-doc.chk-date no-undo .
define variable v-first-time        like ub.chk-doc.chk-time no-undo .
define variable v-first-obj-type    like ub.chk-doc.obj-type no-undo .
define variable v-first-obj-code    like ub.chk-doc.obj-code no-undo .
define variable g#report-num        as integer no-undo .


define buffer buf_person for ub.person.
define buffer buf_firm for ub.firm.
define buffer buf_clients for ub.clients.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_obj for ub.clients.


run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


CASE X-selectgood:
  when {&g-prod} then do:
    For each g#cli no-lock:
        num-g# = num-g# + 1.
        if num-g#= 1 then
        FixProdAttr = g#cli.obj-type + string( g#cli.obj-code ) .
        if num-g# > 1 then leave.
    end.
  end.
  when {&g-grp} then do:
    For each tmp#grp no-lock:
        num-g# = num-g# + 1.
        if num-g# = 1 then
        FixProdAttr = tmp#grp.grp-name .
        if num-g# > 1 then leave.
    end.
  end.
  when {&g-choice} then do:
    For each gds-list no-lock:
        num-g# = num-g# + 1.
        if num-g# = 1 then
        FixProdAttr = string( gds-list.gds-code ) .
        if num-g# > 1 then leave.
    end.
  end.
  when {&g-one} then do:
    num-g# = 1.
    for each gds-list:
      FixProdAttr = string( gds-list.gds-code ) .
      leave.
    end.
  end.
END CASE.



/*заполним временные таблицы*/
run cus/r-vuidcr.p (
                 input my-handle
                ,input X-SelectGood
                ,input FixProdAttr
                ,input X-date-Start
                ,input X-date-End
                ,input (if X-SelectGood = {&g-all}
                        then "ALL":U
                        else (IF num-g# > 1 then "LIST:U" else "ONE":U)
                        )
                ,input ", обработано чеков :"
                ,input this-procedure:handle
).

if not can-find(first temp-cards no-lock) then do:
  message
  "Нет данных для отчета"
  view-as alert-box .
  run waitfram-hide in this-procedure .
  return.
end.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .


FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
            sheetf.sheet-num = 1 No-ERROR.
sheetf.sizes = "".



assign
Sheetf.Excel-Column-Lable =
                            "Дисконтная карта" + {&comma-char} +
                            "Код" + {&comma-char} +
                            "Дата перв.покупки" + {&comma-char} +
                            "Маг перв.покупки" + {&comma-char} +
                            "Дата посл.покупки(за период)" + {&comma-char} +
                            "Маг посл.покупки" + {&comma-char} +
                            "Фамилия" + {&comma-char} +
                            "Имя" + {&comma-char} +
                            "Отчество" + {&comma-char} +
                            "Организация" + {&comma-char} +
                            "Должность" + {&comma-char} +
                            "{&abbr_inn_allshift}" +   {&comma-char} +
                            "Телефон" + {&comma-char} +
                            "Факс" + {&comma-char} +
                            "E-mail" + {&comma-char} +
                            "Город" + {&comma-char} +
                            "Индекс" + {&comma-char} +
                            "Адрес" + {&comma-char} +
                            "А/я" + {&comma-char} +
                            "Паспортные данные" + {&comma-char} +
                            "Примечание"

Sheetf.Sizes = "16,12,10,8,10,8,40,20,20,40,20,21,20,20,20,40,6,60,8,60,60"
sheetf.colformat = "3=dd/mm/yyyy;5=dd/mm/yyyy":U + {&delim-par} + "1=@;12=@"
.

run rep/extitle.p (1) no-error.

/*печать первой страницы*/

for each temp-cards no-lock
break
by temp-cards.cli-type
by temp-cards.cli-code:
  /*найдем последнюю покупку*/
  assign
  v-first-date = ?
  v-first-time = 0
  v-first-obj-type = "":U
  v-first-obj-code = 0
  .
  _chk-doc:
  for each buf_obj no-lock where
          buf_obj.obj-type = {&shop}
       OR buf_obj.obj-type = {&stock}:
    _chk-doc2:
    for each buf_chk-doc no-lock where
          buf_chk-doc.obj-type = buf_obj.obj-type
      AND buf_chk-doc.obj-code = buf_obj.obj-code
      AND buf_chk-doc.d-card = temp-cards.d-card
    by buf_chk-doc.chk-date
    by buf_chk-doc.chk-time
    :
      if lookup(string(buf_chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then next _chk-doc2.
      if v-first-date = ? then do:
        assign
        v-first-date = buf_chk-doc.chk-date
        v-first-time = buf_chk-doc.chk-time
        v-first-obj-type = buf_chk-doc.obj-type
        v-first-obj-code = buf_chk-doc.obj-code
        .
      end.
      else do:
        if (v-first-date < buf_chk-doc.chk-date)
        or ((v-first-date = buf_chk-doc.chk-date)  AND
            (v-first-time <= buf_chk-doc.chk-time))
        then NEXT _chk-doc.
        else do:
          assign
          v-first-date = buf_chk-doc.chk-date
          v-first-time = buf_chk-doc.chk-time
          v-first-obj-type = buf_chk-doc.obj-type
          v-first-obj-code = buf_chk-doc.obj-code
          .
          NEXT _chk-doc.
        end.
      end.
    end.
  end. /*for each buf_obj*/

  if first-of(temp-cards.cli-code) then do:
    find first buf_clients no-lock where
               buf_clients.obj-type = temp-cards.cli-type
           and buf_clients.obj-code = temp-cards.cli-code.
    CASE temp-cards.cli-type:
      when {&prs} then do:
        find first buf_person no-lock where
                   buf_person.psn-code = temp-cards.cli-code.
        {&PutExcel}
        ({&delim-par} + temp-cards.d-card)                  {&tabulation}
        (temp-cards.cli-type + string(temp-cards.cli-code)) {&tabulation}
        string(v-first-date, "99/99/9999")                  {&tabulation}
        (v-first-obj-type + string(v-first-obj-code))       {&tabulation}
        string(temp-cards.last-date, "99/99/9999")          {&tabulation}
        (temp-cards.last-obj-type + string(temp-cards.last-obj-code))       {&tabulation}
        buf_clients.obj-name                                {&tabulation}
        buf_person.name1                                    {&tabulation}
        buf_person.name2                                    {&tabulation}
        buf_person.firm-name                                {&tabulation}
        buf_person.position                                 {&tabulation}
        ({&delim-nws} + buf_person.inn)                     {&tabulation}
        buf_person.phone1                                   {&tabulation}
        buf_person.fax                                      {&tabulation}
        buf_person.e-mail                                   {&tabulation}
        buf_person.city                                     {&tabulation}
        buf_person.ind                                      {&tabulation}
        buf_person.address                                  {&tabulation}
        buf_person.post-box                                 {&tabulation}
        (buf_person.passp-num + {&space-char} +
        buf_person.passp-ser + {&space-char} +
        buf_person.given-by)                                {&tabulation}
        buf_clients.PS
        skip.
      end.
      when {&cmp} then do:
        find first buf_firm no-lock where
                   buf_firm.firm-code = temp-cards.cli-code.
        {&PutExcel}
        ({&delim-nws} + temp-cards.d-card)                  {&tabulation}
        (temp-cards.cli-type + string(temp-cards.cli-code)) {&tabulation}
        string(v-first-date, "99/99/9999")                  {&tabulation}
        (v-first-obj-type + string(v-first-obj-code))       {&tabulation}
        string(temp-cards.last-date, "99/99/9999")          {&tabulation}
        (temp-cards.last-obj-type + string(temp-cards.last-obj-code))       {&tabulation}
        buf_clients.obj-name                                {&tabulation}
        buf_firm.engl-name                                  {&tabulation}
                                                            {&tabulation}
                                                            {&tabulation}
        buf_firm.director                                   {&tabulation}
        ({&delim-nws} + buf_firm.inn)                       {&tabulation}
        buf_firm.phone                                      {&tabulation}
        buf_firm.fax                                        {&tabulation}
        buf_firm.e-mail                                     {&tabulation}
        buf_firm.city                                       {&tabulation}
        buf_firm.ind                                        {&tabulation}
        buf_firm.addres1                                    {&tabulation}
                                                            {&tabulation}
                                                            {&tabulation}
        (buf_clients.Ps + {&space-char} + buf_firm.contact-psn)
        skip.
      end.
    END CASE.
  end.
  else do:
    {&PutExcel}
    ({&delim-nws} + temp-cards.d-card) {&tabulation}
    (temp-cards.cli-type + string(temp-cards.cli-code)) {&tabulation}
    string(v-first-date, "99/99/9999")                  {&tabulation}
    (v-first-obj-type + string(v-first-obj-code))       {&tabulation}
    string(temp-cards.last-date, "99/99/9999")          {&tabulation}
    (temp-cards.last-obj-type + string(temp-cards.last-obj-code))       {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    skip.
  end. /*not first*/
END. /*for each temp-cards*/


{&pageExcel}
FInd first Sheetf where
            Sheetf.sheet-num = 2 No-ERROR.
if not avail sheetf then
create sheetf.
assign
Sheetf.Sheet-num = 2.
assign
Sheetf.Excel-Column-Lable =
                            "Дисконтная карта" + {&comma-char} +
                            "Код" + {&comma-char} +
                            "Фамилия" + {&comma-char} +
                            "Скидка клиента%" + {&comma-char} +
                            "Дата чека" + {&comma-char} +
                            "Номер магазина" + {&comma-char} +
                            "Код продавца" + {&comma-char} +
                            "Код кассира" +  {&comma-char} +
                            "Скидка итоговая (%)" +  {&comma-char} +
                            "Код товара" +  {&comma-char} +
                            "Артикул товара" +  {&comma-char} +
                            "Наименование товара" +  {&comma-char} +
                            "Кол-во" +  {&comma-char} +
                            "Цена брутто" + {&comma-char} +
                            "Цена нетто" + {&comma-char} +
                            "Скидка" + {&comma-char} +
                            "Сумма нетто" + {&comma-char} +
                            "Курс валюты" + {&comma-char} +
                            "Масштаб"
Sheetf.Sizes = "12,40,16,5,10,5,4,4,5,9,16,48,5,8,8,8,16,15,7"
sheetf.colformat = "5=dd/mm/yyyy" + {&delim-nws} + "1=@"
.

run rep/extitle.p (2) .

/*печать второй страницы*/
for each temp-gds no-lock
break
by temp-gds.cli-type
by temp-gds.cli-code
by temp-gds.d-card
:
  if first-of(temp-gds.cli-code) then do:
    find first buf_clients no-lock where
               buf_clients.obj-type = temp-gds.cli-type
           and buf_clients.obj-code = temp-gds.cli-code no-error .
    if avail buf_clients then do:
      assign
      v-name = buf_clients.obj-name
      .
    end.
    else do:
      assign
      v-name = temp-gds.cli-type + string(temp-gds.cli-code)
      .
    end.
  end.
  {&PutExcel}
  ({&delim-nws} + temp-gds.d-card)                             {&tabulation}
  (temp-gds.cli-type + string(temp-gds.cli-code))     {&tabulation}
  v-name                                              {&tabulation}
  temp-gds.src-d-pcnt                                 {&tabulation}
  string(temp-gds.chk-date, "99/99/9999")                                   {&tabulation}
  temp-gds.obj-code                                   {&tabulation}
  temp-gds.sales-man                                  {&tabulation}
  temp-gds.cashier                                    {&tabulation}
  temp-gds.d-pcnt                                     {&tabulation}
  temp-gds.gds-code                                   {&tabulation}
  temp-gds.artic                                      {&tabulation}
  temp-gds.gds-name                                   {&tabulation}
  temp-gds.doc-qnty                                   {&tabulation}
  temp-gds.price-base                                 {&tabulation}
  (temp-gds.price-base - temp-gds.discnt)             {&tabulation}
  temp-gds.discnt                                     {&tabulation}
  round((temp-gds.price-base - temp-gds.discnt) *
          temp-gds.doc-qnty, 2)                        {&tabulation}
  temp-gds.cash-rate                                  {&tabulation}
  temp-gds.cash-scale
  skip.
END. /*for each temp-cards*/

output stream PrnLibStream CLOSE .
{&closeExcel}

run waitfram-hide in this-procedure .
run get-report-num in my-handle (output g#report-num).
run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").