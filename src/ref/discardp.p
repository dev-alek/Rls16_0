block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: discardp.p $
$Archive: ref/discardp.p $

Печать из справочника ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/29/05
Author: Bakhtadze Natalya
Creation date: 10/29/05

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-frame-title as character no-undo .
define input  parameter p-pravo       as logical   no-undo .
define input  parameter p-rs-val      as character no-undo .
define input  parameter p-host-code-obj like ub.sysconf.host-code no-undo .
define input  parameter p-obj-type      like ub.clients.obj-type  no-undo .
define input  parameter p-obj-code      like ub.clients.obj-code  no-undo .
define parameter buffer X_dis-card    for ub.dis-card  .
define input  parameter p-qh as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: discardp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/discardp.p $":U .
define variable vss-description as character no-undo init "Печать из справочника ДК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i new }
{ gbl/cur-time.i }
{ cmp/getdpcnt.i }
{ ref/discards.i }
define variable g#report-num as integer   no-undo .
{ rep/opclexcl.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }



define variable Line                    as char         no-undo.
define variable cli-attr                 as char         no-undo.
define variable ii                  as integer   no-undo.
define variable StartRowid as rowid  no-undo extent 18.
define variable for-type as char no-undo.
define variable for-status as char no-undo.
define variable dop-num-chk as integer no-undo.
define variable dop-gds-sum as decimal no-undo.
define variable dop-disc-sum as decimal no-undo.
define variable dop-netto-sum as decimal no-undo.
define variable dop-pay-sum as decimal no-undo.
define variable dop-credit-sum as decimal no-undo.
define variable dop-saldo-sum as decimal no-undo.
define variable for-d-pcnt as character no-undo.
define variable loc-d-pcnt like ub.dis-card.d-pcnt no-undo .
define variable cli-name like ub.clients.obj-name no-undo .
define variable v-ii as integer   no-undo .


DEFINE FRAME List
X_dis-card.d-card column-label "Карта" format "X(16)"
for-d-pcnt column-label "% скидки" format "X(11)"
X_dis-card.d-pcnt column-label "% ск-ки!на объ." format "->9.99%":u
X_dis-card.category column-label "Катег" format "9999"
cli-attr column-label "Клиент" format "X(12)"
cli-name column-label "Название (ФИО)" format "x(32)"
X_dis-card.issue-code COLUMN-LABEL "Выдал!маг-н"
X_dis-card.issue-date COLUMN-LABEL "Дата" format "99/99/9999"
X_dis-card.valid-date COLUMN-LABEL "Оконч" format "99/99/9999"
for-type column-LABEL "Тип!карты" format "X(8)"
X_dis-card.credit-card column-label "Кред" format "да/нет"
for-status column-LABEL "Ста!тус" format "X(5)"
X_dis-card.emitent-host-code COLUMn-LABEL "Код!фирмы"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>>>9") ) AT 56 format "X(15)" SKIP
Line format "x(136)" AT 1
with width {&A4_CW0} down use-text stream-io no-box .

DEFINE FRAME List-pravo
X_dis-card.d-card column-label "Карта" format "X(16)"
for-d-pcnt column-label "% скидки" format "X(11)"
X_dis-card.d-pcnt column-label "% ск-ки!на объ." format "->9.99%":u
X_dis-card.category column-label "Катег" format "9999"
cli-attr column-label "Клиент" format "X(12)"
cli-name column-label "Название (ФИО)" format "x(32)"
X_dis-card.issue-code COLUMN-LABEL "Выдал!маг-н"
X_dis-card.issue-date COLUMN-LABEL "Дата" format "99/99/9999"
X_dis-card.valid-date COLUMN-LABEL "Оконч" format "99/99/9999"
for-type column-LABEL "Тип!карты" format "X(6)"
X_dis-card.credit-card COLUMn-label "Кред" format "да/нет"
for-status column-LABEL "Ста!тус" format "X(5)"
X_dis-card.emitent-host-code COLUMn-LABEL "Код!фирмы"
num-chk column-label "Кол-во!чеков" format "->>>>>>>9 "
gds-sum column-label "Сумма покупок!брутто" format "->>>,>>>,>>9.99"
disc-sum column-label "Скидка" format "->>>,>>>,>>9.99"
netto-sum column-label "Сумма покупок!нетто" format "->>>,>>>,>>9.99"
credit-sum column-label "Сумма в кредит" format "->>>,>>>,>>9.99"
saldo-sum column-label "Сальдо" format "->>>,>>>,>>9.99"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>>>9") )  AT 56 format "X(15)" SKIP
Line format "x(231)" AT 1
with width {&DOS_CW_2} down use-text stream-io no-box .



if p-qh:num-results = 0 then do:
  message
  "Список  П У С Т !" skip
  view-as alert-box information .
  return error .
end.

if session:set-wait-state( "compiler" ) then .
Line = fill( "-" , (if p-pravo then 231 else 136 )).
/*
    Это из-за того, что в QUERY br-discard используется index reposition и,
    как следствие, не работает GET first br-discard  ( ошибка 3157 )
*/

{ gbl/getcntxt.i get }

do v-ii = 1 to p-qh:num-buffers:
 StartRowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid .
end.
DO WHILE available X_dis-card :
  p-qh:GET-prev(NO-LOCK) .
END.
p-qh:GET-next ( NO-LOCK ).
assign
ii = 0
Make-excel = yes
reportname = p-frame-title.
if p-pravo then do:
  assign
  sheetf.Excel-COlumn-Lable = "Карта" + {&comma-char} +
                              "% скидки"  + {&comma-char} +
                              "% скидки на объ-те" + {&comma-char} +
                              "Категория ДК" + {&comma-char} +
                              "Клиент" + {&comma-char} +
                              "Название (ФИО)" + {&comma-char} +
                              "Выдал маг-н" + {&comma-char} +
                              "Дата выдачи" + {&comma-char} +
                              "Дата оконч" + {&comma-char} +
                              "Тип карты" + {&comma-char} +
                              "Кредит" + {&comma-char} +
                              "Статус" + {&comma-char} +
                              "Код фирмы" + {&comma-char} +
                              "Кол-во чеков" + {&comma-char} +
                              "Сумма покупок брутто" + {&comma-char} +
                              "Скидка" + {&comma-char} +
                              "Сумма покупок нетто" + {&comma-char} +
                              "Сумма в кредит"  + {&comma-char} +
                              "Сальдо"
  sheetf.Sizes = "19,11,7,4,12,35,5,10,10,8,3,5,5,8,15,15,15,15,15"
  sheetf.colformat = "1=0;8=dd/mm/yyyy" + {&delim-par} + "1=@"
  .
end.
else do:
  assign
  sheetf.Excel-COlumn-Lable = "Карта" + {&comma-char} +
                              "% скидки"  + {&comma-char} +
                              "% скидки на объ-те" + {&comma-char} +
                              "Категория ДК" + {&comma-char} +
                              "Клиент" + {&comma-char} +
                              "Название (ФИО)" + {&comma-char} +
                              "Выдал маг-н" + {&comma-char} +
                              "Дата выдачи" + {&comma-char} +
                              "Дата оконч" + {&comma-char} +
                              "Тип карты" + {&comma-char} +
                              "Кредит" + {&comma-char} +
                              "Статус" + {&comma-char} +
                              "Код фирмы"
   sheetf.Sizes = "19,11,7,4,12,35,5,10,10,8,3,5,5"
   sheetf.colformat = "1=0;8=dd/mm/yyyy" + {&delim-par} + "1=@"
   .
end.

run get-report-num in parparentproc(output g#report-num).
RUN OpenForExcel in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input (if p-pravo then {&LS_PS_A4} else {&CS_PS})
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

if p-pravo then do:
  FORM HEADER
  Line format "X(136)" SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME CliBottomFramep width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
end.
else do:
  FORM HEADER
  Line format "X(231)" SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME CliBottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS no-box.
end.
run rep/extitle.p (1).
if p-pravo then do:
  VIEW stream PrnLibStream FRAME CliBottomFramep .
end.
else do:
  VIEW stream PrnLibStream FRAME CliBottomFrame .
end.
PUT stream PrnLibStream space(20)
p-frame-title format "X(100)" SKIP(2) .
if p-pravo then do:
  FORM with frame List-pravo .
end.
else do:
  FORM with frame List .
end.
DO WHILE available X_dis-card :
  if p-pravo then
  num-chk = integer(get-num-chk(input p-rs-val, input p-pravo, buffer X_dis-card , input v-cntxt-db-num)).
  assign
  dop-num-chk = dop-num-chk + num-chk
  dop-gds-sum = dop-gds-sum + gds-sum
  dop-disc-sum = dop-disc-sum + disc-sum
  dop-netto-sum = dop-gds-sum - dop-disc-sum
  dop-pay-sum = dop-pay-sum + pay-sum
  dop-credit-sum = dop-netto-sum - dop-pay-sum
  dop-saldo-sum = dop-saldo-sum + saldo-sum
  .
  for-d-pcnt = get-d-pcnt(buffer X_dis-card
                         ,input p-host-code-obj
                         ,input p-obj-type
                         ,input p-obj-code
                         ,input {&ddctr-def-pcnt}
                         ,output loc-d-pcnt).
  if p-pravo then do:
    DISPLAY stream PrnLibStream
    X_dis-card.d-card
    for-d-pcnt
    loc-d-pcnt @ X_dis-card.d-pcnt
    X_dis-card.category
    ( X_dis-card.cli-type + " " +  STRING ( X_dis-card.cli-code ) ) @ cli-attr
    get-cli-name(X_dis-card.cli-type,  X_dis-card.cli-code) @ cli-name
    X_dis-card.issue-code
    X_dis-card.issue-date
    X_dis-card.valid-date
    X_dis-card.type @ for-type
    X_dis-card.credit-card
    X_dis-card.status_ @ for-status
    X_dis-card.emitent-host-code
    num-chk
    gds-sum
    disc-sum
    netto-sum
    credit-sum
    saldo-sum
    with frame List-pravo .
    DOWN stream PrnLibStream
    1 with frame List-pravo .
    {&putExcel}
    X_dis-card.d-card                                                        {&tabulation}
    for-d-pcnt                                                               {&tabulation}
    loc-d-pcnt                                                               {&tabulation}
    ( X_dis-card.cli-type + " " +  STRING ( X_dis-card.cli-code ) )          {&tabulation}
    get-cli-name(X_dis-card.cli-type, X_dis-card.cli-code)                   {&tabulation}
    X_dis-card.issue-code                                                    {&tabulation}
    X_dis-card.issue-date                                                    {&tabulation}
    X_dis-card.type                                                          {&tabulation}
    X_dis-card.credit-card                                                   {&tabulation}
    X_dis-card.status_                                                       {&tabulation}
    X_dis-card.emitent-host-code                                             {&tabulation}
    num-chk                                                                  {&tabulation}
    gds-sum                                                                  {&tabulation}
    disc-sum                                                                 {&tabulation}
    netto-sum                                                                {&tabulation}
    credit-sum                                                               {&tabulation}
    saldo-sum
    skip.
  end.
  else do:
    DISPLAY  stream PrnLibStream
    X_dis-card.d-card
    for-d-pcnt
    loc-d-pcnt @ X_dis-card.d-pcnt
    X_dis-card.category
    ( X_dis-card.cli-type + " " +  STRING ( X_dis-card.cli-code ) ) @ cli-attr
    get-cli-name(X_dis-card.cli-type, X_dis-card.cli-code)  @ cli-name
    X_dis-card.issue-code
    X_dis-card.issue-date
    X_dis-card.valid-date
    X_dis-card.type @ for-type
    X_dis-card.credit-card
    X_dis-card.status_ @ for-status
    X_dis-card.emitent-host-code
    with frame List .
    DOWN stream PrnLibStream 1
    with frame List .
    {&putExcel}
    X_dis-card.d-card                                                        {&tabulation}
    for-d-pcnt                                                               {&tabulation}
    loc-d-pcnt                                                               {&tabulation}
    X_dis-card.category                                                      {&tabulation}
    ( X_dis-card.cli-type + " " +  STRING ( X_dis-card.cli-code ) )          {&tabulation}
    get-cli-name(X_dis-card.cli-type, X_dis-card.cli-code)                   {&tabulation}
    X_dis-card.issue-code                                                    {&tabulation}
    X_dis-card.issue-date                                                    {&tabulation}
    X_dis-card.type                                                          {&tabulation}
    X_dis-card.credit-card                                                   {&tabulation}
    X_dis-card.status_                                                       {&tabulation}
    X_dis-card.emitent-host-code
    skip.
  end.
  ii =  ii + 1 .
  if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
  run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
  p-qh:GET-next (no-lock) .
END.
if p-pravo then do:
  UNDERLINE stream PrnLibStream
  X_dis-card.d-card
  for-d-pcnt
  X_dis-card.d-pcnt
  X_dis-card.category
  cli-attr
  cli-name
  X_dis-card.issue-code
  X_dis-card.issue-date
  X_dis-card.valid-date
  for-type
  for-status
  X_dis-card.emitent-host-code
  num-chk
  gds-sum
  disc-sum
  netto-sum
  credit-sum
  saldo-sum
  with frame List-pravo .
  DISPLAY stream PrnLibStream
  substitute("Итого &1 карт", ii) @ X_dis-card.d-card
  dop-num-chk @ num-chk
  dop-gds-sum  @ gds-sum
  dop-disc-sum @ disc-sum
  dop-netto-sum @ netto-sum
  dop-credit-sum @ credit-sum
  dop-saldo-sum @ saldo-sum
  with frame List-pravo .
  {&putExcel}
  skip
  substitute("Итого &1 карт", ii)                                     {&tabulation}
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
  dop-num-chk                                                         {&tabulation}
  dop-gds-sum                                                         {&tabulation}
  dop-disc-sum                                                        {&tabulation}
  dop-netto-sum                                                       {&tabulation}
  dop-credit-sum                                                      {&tabulation}
  dop-saldo-sum
  skip.
end.

run waitfram-hide in this-procedure .
if p-pravo then do:
  PUT stream PrnLibStream Line format "X(231)" SKIP.
  HIDE stream PrnLibStream FRAME CliBottomFramep .
end.
else do:
  PUT stream PrnLibStream Line format "X(136)" SKIP.
  HIDE stream PrnLibStream FRAME CliBottomFrame .
end.

output stream PrnLibStream close .
{&CloseExcel}
run prn-lib-prn-file in this-procedure (
                                           input parparentproc
                                          ,input (if p-pravo then 1 else 8)
                                          ).


p-qh:reposition-to-rowid( StartRowid ) no-error .
/*

assign
            g#rep-tblname = ""
            g#rep-tblrid = -132
            g#rep-updflds = "Список дисконтных карт| " .
*/