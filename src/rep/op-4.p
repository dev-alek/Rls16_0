block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: op-4.p $
$Archive: rep/op-4.p $

Печатная форма ОП-4. Производство, накладная на отпуск товара

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-4.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-4.p $":U .
define variable vss-description as character no-undo init "Печатная форма ОП-4. Производство, накладная на отпуск товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i }
{ str/in-vatp.i def }
{ rep/p-fmt.i }
{ rep/r-cliprp.i def }

do
on error undo, return error
:
def shared var PrintScale as logical     no-undo.

def stream Out-Stream .

def buffer  t-doc       for trn-doc.
def buffer  buf_clients   for clients.

def var tdoc-prt              as logical                  no-undo.
def var tdoc-code             like trn-doc.doc-code       no-undo.
def var tdoc-date             like trn-doc.doc-date       no-undo.

def var rootnode_code         as integer                  no-undo.

def var v-line-counter        as integer                  no-undo.
def var txt-LC                as char                     no-undo.
def var s1                    as char                     no-undo.
def var s2                    as char                     no-undo.

def var Node_Code             like gds-prt.upper-code     no-undo.

def var CostNoNDS             as decimal                  no-undo.
def var CostNDS               as decimal                  no-undo.
def var CostWithNDS           as decimal                  no-undo.
def var tqnty                 as decimal                  no-undo.
def var SumCostNoNDS          as decimal                  no-undo.
def var SumCostNDS            as decimal                  no-undo.
def var SumCostWithNDS        as decimal                  no-undo.

def var prt-tqnty             as decimal                  no-undo.
def var prt-SumCostNoNDS      as decimal                  no-undo.
def var prt-SumCostNDS        as decimal                  no-undo.
def var prt-SumCostWithNDS    as decimal                  no-undo.

def var Pg-tqnty              as decimal   init 0 no-undo.
def var Pg-SumCostNoNDS       as decimal                  no-undo.
def var Pg-SumCostNDS         as decimal                  no-undo.
def var Pg-SumCostWithNDS     as decimal                  no-undo.
def var PrevPage              as int       init 0         no-undo.

def var tot-SumCostNoNDS      as decimal                  no-undo.
def var tot-SumCostNDS        as decimal                  no-undo.
def var tot-SumCostWithNDS    as decimal                  no-undo.

def var PrtName               as char                     no-undo.

def var v-organization        as char                     no-undo.
def var v-org-from            as char                     no-undo.
def var v-org-to              as char                     no-undo.

def var v-doc-line-counter    as integer   init 0         no-undo.
def var v-goods-artic         as char                     no-undo.
def var v-goods-name          as char                     no-undo.
def var v-bar-code            as integer                  no-undo.
def var v-unit-name           as char                     no-undo.
def var v-unit-OKEI           as char                     no-undo.
def var v-need-qnty           as decimal                  no-undo.
def var v-places-amount       as decimal                  no-undo.
def var v-qnty-in-one-place   as decimal                  no-undo.
def var v-qnty-all            as decimal                  no-undo.
def var v-cost-price          as decimal                  no-undo.
def var v-cost-sum            as decimal                  no-undo.
def var v-sale-price          as decimal                  no-undo.
def var v-sale-sum            as decimal                  no-undo.
def var v-comment             as char                     no-undo.

def var v-doc-num             as char                     no-undo.
def var v-road-tax            as decimal                  no-undo.
def var v-excise              as decimal                  no-undo.

def var v-pg-need-qnty       as decimal                  no-undo.
def var v-pg-places-amount   as decimal                  no-undo.
def var v-pg-qnty-all        as decimal                  no-undo.
def var v-pg-cost-sum        as decimal                  no-undo.
def var v-pg-sale-sum        as decimal                  no-undo.

def var v-prt-need-qnty       as decimal                  no-undo.
def var v-prt-places-amount   as decimal                  no-undo.
def var v-prt-qnty-all        as decimal                  no-undo.
def var v-prt-cost-sum        as decimal                  no-undo.
def var v-prt-sale-sum        as decimal                  no-undo.

def var sym1 as char init "|" no-undo.
def var sym2 as char init ":" no-undo.
def var sym3 as char init ":" no-undo.
def var sym4 as char init ":" no-undo.
def var sym5 as char init ":" no-undo.
def var sym6 as char init ":" no-undo.
def var sym7 as char init ":" no-undo.
def var sym8 as char init ":" no-undo.
def var sym9 as char init ":" no-undo.
def var sym10 as char init ":" no-undo.
def var sym11 as char init ":" no-undo.
def var sym12 as char init ":" no-undo.
def var sym13 as char init ":" no-undo.
def var sym14 as char init ":" no-undo.
def var sym15 as char init ":" no-undo.
def var sym16 as char init "|" no-undo.

def var v-single-line       as char          no-undo.
def var v-underline         as char          no-undo.

def var v-valut-name             as char          no-undo.

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

/*----S----- Таблицы --------------------------------*/
&scop P-S 5
&scop P-X 193        /*длина линии*/
&scop P-X0 191       /*длина внутренней линии = длина линии - 2*/
&scop P-X1 71        /*длина внутренней линии от начала  2-й колонки до начала  5-й*/
&scop P-X2 9         /*длина внутренней линии от начала  5-й колонки до начала  7-й*/
&scop P-X3 23        /*длина внутренней линии от начала  7-й колонки до начала 11-й*/
&scop P-X4 26        /*длина внутренней линии от начала 11-й колонки до начала 13-й*/
&scop P-X5 26        /*длина внутренней линии от начала 13-й колонки до начала 15-й*/
&scop P-X6 14        /*длина внутренней линии от начала  8-й колонки до начала 11-й*/
&scop P-C2-S    {&P-S} + 6
&scop P-C3-S    {&P-S} + 23
&scop P-C4-S    {&P-S} + 68
&scop P-C5-S    {&P-S} + 78
&scop P-C6-S    {&P-S} + 83
&scop P-C7-S    {&P-S} + 88
&scop P-C8-S    {&P-S} + 96
&scop P-C9-S    {&P-S} + 101
&scop P-C10-S   {&P-S} + 107
&scop P-C11-S   {&P-S} + 115
&scop P-C12-S   {&P-S} + 129
&scop P-C13-S   {&P-S} + 144
&scop P-C14-S   {&P-S} + 158
&scop P-C15-S   {&P-S} + 173
&scop P-E       {&P-S} + 193

/*Надписи в конце таблицы*/
&scop P1-S 10
&scop P1-C2-S  {&P1-S} + 17
&scop P1-C3-S  {&P1-S} + 37
&scop P1-C4-S  {&P1-S} + 57
&scop P1-C5-S  {&P1-S} + 97
&scop P1-C6-S  {&P1-S} + 107
&scop P1-C7-S  {&P1-S} + 128
&scop P1-C8-S  {&P1-S} + 148
&scop P1-E     {&P1-S} + 178
&scop P1-EXT1  78              /*Количество символов для суммы прописью*/

/*----E----- Таблицы --------------------------------*/

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first t-doc
     where recid( t-doc ) = rec_id  no-lock
.
if    t-doc.ext-doc-type <> {&TDEDT_Spi_Prvo}
  and t-doc.ext-doc-type <> {&TDEDT_Pri_Prvo}
then do:
  return.
end.

DEFINE frame f-doc
        space({&P-S})
        sym1 column-label "|" format "X(1)" space(0)
        v-doc-line-counter column-label " 1" format ">>9" space(1)
        sym2 column-label ":" format "X(1)" space(0)
        v-goods-artic column-label "        2       " format "X(16)" space(0)
        sym3 column-label ":" format "X(1)" space(0)
        v-goods-name column-label "                     3                      " format "X(44)" space(0)
        sym4 column-label ":" format "X(1)" space(0)
        v-bar-code column-label "    4    " format ">>>>>>>>9" space(0)
        sym5 column-label ":" format "X(1)" space(0)
        v-unit-name column-label "  5 " format "X(4)" space(0)
        sym6 column-label ":" format "X(1)" space(0)
        v-unit-OKEI column-label "  6 " format "X(4)" space(0)
        sym7 column-label ":" format "X(1)" space(0)
        v-need-qnty column-label "  7  " format ">>>9.99" space(0)
        sym8 column-label ":" format "X(1)" space(0)
        v-places-amount column-label "  8 " format ">>>9" space(0)
        sym9 column-label ":" format "X(1)" space(0)
        v-qnty-in-one-place column-label "  9  " format ">>9.9" space(0)
        sym10 column-label ":" format "X(1)" space(0)
        v-qnty-all column-label "  10 " format ">>>9.99" space(0)
        sym11 column-label ":" format "X(1)" space(0)
        v-cost-price column-label "     11      " format  "->,>>>,>>9.99" space(0)
        sym12 column-label ":" format "X(1)" space(0)
        v-cost-sum column-label   "      12      " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":" format "X(1)" space(0)
        v-sale-price column-label "     13      " format  "->,>>>,>>9.99" space(0)
        sym14 column-label ":" format "X(1)" space(0)
        v-sale-sum column-label   "     14       " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":" format "X(1)" space(0)
        v-comment column-label "        15         " format "X(19)" space(0)
        sym16 column-label "|" format "X(1)" space(0)
    with width {&DOS_CW} down stream-io.


/*
if not t-doc.print-rubl then
    message "Документ печатать в {&abbr_rublyah_allshift} ?"
            VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.
else
    assign PrintRubl = yes .
*/
assign
    v-valut-name   = ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" )
    v-single-line  = fill("-", 230)
    v-underline    = fill("_", 230)
    v-line-counter = 1
.
assign
    tdoc-code = t-doc.doc-code
    tdoc-date = (if t-doc.status_ <> {&fact} then t-doc.doc-date else t-doc.fact-date )
.

/*---S------ Находим подразделение - хозяина документа -------------*/
find first buf_clients no-lock
     where buf_clients.obj-type = t-doc.obj-type
       and buf_clients.obj-code = t-doc.obj-code
no-error.

case buf_clients.obj-type :
    when {&shop} then
        do:
            find first shop no-lock
                 where shop.obj-code = buf_clients.obj-code
            .
            assign
                tdoc-prt = shop.doc-prt.
            .
        end.
    when {&stock} then
        do:
            find first store no-lock
                 where store.obj-code = buf_clients.obj-code
            .
            assign
                tdoc-prt = store.doc-prt .
            .
        end.
end case.

assign
    v-org-from = buf_clients.obj-name
.

if not tdoc-prt
then
    PrintScale = no
.
/*---E------ Находим подразделение - хозяина документа -------------*/
/*---S------ Находим подразделение - получателя документа -------------*/
find first buf_clients no-lock
     where buf_clients.obj-type = t-doc.cli-type
       and buf_clients.obj-code = t-doc.cli-code
no-error.

assign
    v-org-to = buf_clients.obj-name
.
/*---E------ Находим подразделение - получателя документа -------------*/

{ gbl/working.i }
{ cmp/open-out.i stream Out-Stream " " {&LS_PS_A4} }

form header
    v-single-line format "X({&P-X})" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame BottomFrame width {&DOS_CW} page-bottom no-labels no-box .
view stream Out-Stream frame BottomFrame .

find first clients no-lock
     where clients.obj-type = {&cmp}
       and clients.obj-code = t-doc.host-code
.
{ rep/r-cliprp.i }
assign
    v-organization = string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                + t-addres + t-phone)
.

/*---S----- Шапка документа ------------------------*/
put stream Out-Stream
  skip
    string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( {&P-E}, 13)
  skip
    space({&P-S}) v-single-line format  "X(19)"             at 180
  skip
    space({&P-S}) "| "                                      at 180
                  {&g___code}                               at 188
                  "|"                                       at {&P-E}
  skip
    space({&P-S}) "Форма по ОКУД" format "X(14)"            at 166
                  "| "                                      at 180
                  "0330504"
                  "|"                                       at {&P-E}
  skip
    space({&P-S}) "Организация:                         "
             v-organization             format "X(100)"
             "по ОКПО"                  format "X(7)"       at 172
             "| "                                           at 180
             t-okpo                     format "X(16)" "|"  at {&P-E}
  skip
    space({&P-S}) "Струрное подразделение:              "
                  (if t-doc.doc-type = {&income} then v-org-to else v-org-from) format "X(80)"
                  "| "                                      at 180
                  "|"                                       at {&P-E}
  skip
    space({&P-S}) "Струрное подразделение - получатель: "
                  (if t-doc.doc-type = {&income} then v-org-from else v-org-to) format "X(80)"
                  "| "                                      at 180
                  "|"                                       at {&P-E}
  skip
    space({&P-S}) "Вид деятельности по ОКДП" format "X(25)" at 155
                  "| "                                      at 180
                  "|"                                       at {&P-E}
  skip
    space({&P-S}) "Вид операции"        format "X(12)"      at 167
                  "| "                                      at 180
                   ( if t-doc.doc-type = {&income}
                   then " приход"
                   else ( if t-doc.doc-type = {&return} then " возврат " else " расход" ) )
                                        format "X(16)"
                   "|"                                      at {&P-E}
  skip
    space({&P-S}) v-single-line         format  "X(19)"     at 180
.

put stream Out-Stream
   skip
    space(64) v-single-line format "X(33)"
   skip
    space(64) "|"
      "Номер"   at  center-field(65, 83, 5)
       "|"  at 84
       "Дата"   at  center-field(85, 96, 4)
       "|"  at 97
     format "X(33)"
   skip
    space(64) "|"
      "документа" format "X(9)" at  center-field(65, 83, 9)
       "|"  at 84
       "составления" format "X(11)" at  center-field(85, 96, 11)
       "|"  at 97
   skip
    space(64) "|"
              v-single-line format "X(31)"
              "|"  at 97
   skip
    space(54) string( "НАКЛАДНАЯ | "
                                + string( tdoc-code , "X(16)") + " | "
                                + string( tdoc-date, "99/99/9999") + " | "
                                + (if t-doc.status_ <> {&fact} then string( "(" + CAPS(t-doc.status_) + ")" ) else "")
                                ) format "X(100)"
   skip
    space(64) v-single-line format "X(33)"
   skip
    space(50) "НА ОТПУСК ТОВАРА" format "X(20)"
.
/*---E----- Шапка документа ------------------------*/
/*---S------- Заголовок таблицы --------------------*/

form with frame f-doc .
down stream Out-Stream 1 with frame f-doc no-labels.

put stream Out-Stream
    skip space({&P-S})
      string( "Цены и суммы указаны в " + trim( v-valut-name ) ) format "X(30)"
      ( if t-doc.status_ <> {&fact}
        then string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
        else " " )
                                                  at 100 format "X(30)"
.

put stream Out-Stream
   skip space({&P-S})
     v-single-line format "X({&P-X})"
   skip space({&P-S})
     "| Но-"
     ":" at {&P-C2-S}
     "Продукты и товары " at center-field( {&P-C2-S}, {&P-C5-S}, 18)
     ":" at {&P-C5-S}
     "Единица" at center-field( {&P-C5-S}, {&P-C7-S}, 7)
     ":" at {&P-C7-S}
     "Количество" at center-field( {&P-C7-S}, {&P-C11-S}, 10)
     ":" at {&P-C11-S}
     "По учетным ценам," at center-field( {&P-C11-S}, {&P-C13-S}, 17)
     ":" at {&P-C13-S}
     "По ценам продажи," at center-field( {&P-C13-S}, {&P-C15-S}, 17)
     ":" at {&P-C15-S}
     "|" at {&P-E}
   skip space({&P-S})
     "| мер"
     ":" at {&P-C2-S}
     ":" at {&P-C5-S}
     "измерения" at center-field( {&P-C5-S}, {&P-C7-S}, 9)
     ":" at {&P-C7-S}
     "(масса)" at center-field( {&P-C7-S}, {&P-C11-S}, 7)
     ":" at {&P-C11-S}
     "{&abbr_rub}.{&abbr_kop}" at center-field( {&P-C11-S}, {&P-C13-S}, 7)
     ":" at {&P-C13-S}
     "{&abbr_rub}.{&abbr_kop}" at center-field( {&P-C13-S}, {&P-C15-S}, 7)
     ":" at {&P-C15-S}
     "|" at {&P-E}
   skip
     space({&P-S})
     "| по "
     ":" at {&P-C2-S}
     v-single-line format "X({&P-X1})" at ({&P-C2-S} + 1)
     ":" at {&P-C5-S}
     v-single-line format "X({&P-X2})" at ({&P-C5-S} + 1)
     ":" at {&P-C7-S}
     v-single-line format "X({&P-X3})" at ({&P-C7-S} + 1)
     ":" at {&P-C11-S}
     v-single-line format "X({&P-X4})" at ({&P-C11-S} + 1)
     ":" at {&P-C13-S}
     v-single-line format "X({&P-X5})" at ({&P-C13-S} + 1)
     ":" at {&P-C15-S}
     "Примечание" at center-field( {&P-C15-S}, {&P-E}, 10)
     "|" at {&P-E}
   skip space({&P-S})
     "| по-"
     ":"                  at {&P-C2-S}
     ":"                  at {&P-C3-S}
     ":"                  at {&P-C4-S}
     ":"                  at {&P-C5-S}
     ":"                  at {&P-C6-S}
     "Код"                at center-field( {&P-C6-S}, {&P-C7-S}, 3)
     ":"                  at {&P-C7-S}
     "Затре"              at center-field( {&P-C7-S}, {&P-C8-S}, 5)
     ":"                  at {&P-C8-S}
     "отпущено"           at center-field( {&P-C8-S}, {&P-C11-S}, 7)
     ":"                  at {&P-C11-S}
     ":"                  at {&P-C12-S}
     ":"                  at {&P-C13-S}
     ":"                  at {&P-C14-S}
     ":"                  at {&P-C15-S}
     "|"                  at {&P-E}
   skip space({&P-S})
     "| ряд"
     ":"                  at {&P-C2-S}
     "Артикул"            at center-field( {&P-C2-S}, {&P-C3-S}, 7)
     ":"                  at {&P-C3-S}
     "Наименование, сорт" at center-field( {&P-C3-S}, {&P-C4-S}, 18)
     ":"                  at {&P-C4-S}
     "Код"                at center-field( {&P-C4-S}, {&P-C5-S}, 3)
     ":"                  at {&P-C5-S}
     "Наим"               at center-field( {&P-C5-S}, {&P-C6-S}, 4)
     ":"                  at {&P-C6-S}
     "по"                 at center-field( {&P-C6-S}, {&P-C7-S}, 2)
     ":"                  at {&P-C7-S}
     "бова-"              at center-field( {&P-C7-S}, {&P-C8-S}, 5)
     ":"                  at {&P-C8-S}
     "мест"               at center-field( {&P-C8-S}, {&P-C9-S}, 4)
     ":"                  at {&P-C9-S}
     "в одн"              at center-field( {&P-C9-S}, {&P-C10-S}, 5)
     ":"                  at {&P-C10-S}
     "все-"               at center-field( {&P-C10-S}, {&P-C11-S}, 4)
     ":"                  at {&P-C11-S}
     "цена"               at center-field( {&P-C11-S}, {&P-C12-S}, 4)
     ":"                  at {&P-C12-S}
     "сумма"              at center-field( {&P-C12-S}, {&P-C13-S}, 5)
     ":"                  at {&P-C13-S}
     "цена"               at center-field( {&P-C13-S}, {&P-C14-S}, 4)
     ":"                  at {&P-C14-S}
     "сумма"              at center-field( {&P-C14-S}, {&P-C15-S}, 5)
     ":"                  at {&P-C15-S}
     "|"                  at {&P-E}
   skip space({&P-S})
     "| ку"
     ":"                  at {&P-C2-S}
     ":"                  at {&P-C3-S}
     ":"                  at {&P-C4-S}
     ":"                  at {&P-C5-S}
     ":"                  at {&P-C6-S}
     "ОКЕИ"               at center-field( {&P-C6-S}, {&P-C7-S}, 4)
     ":"                  at {&P-C7-S}
     "но"                 at center-field( {&P-C7-S}, {&P-C8-S}, 2)
     ":"                  at {&P-C8-S}
     "штук"               at center-field( {&P-C8-S}, {&P-C9-S}, 4)
     ":"                  at {&P-C9-S}
     "месте"              at center-field( {&P-C9-S}, {&P-C10-S}, 5)
     ":"                  at {&P-C10-S}
     "го"                 at center-field( {&P-C10-S}, {&P-C11-S}, 2)
     ":"                  at {&P-C11-S}
     ":" at {&P-C12-S}
     ":" at {&P-C13-S}
     ":" at {&P-C14-S}
     ":" at {&P-C15-S}
     "|" at {&P-E}
   skip space({&P-S})
     "|"
     v-single-line format "X({&P-X0})"
     "|" at {&P-E}
.
{ rep/op-4.i head no-line}
/*---E------- Заголовок таблицы --------------------*/
/*---S------- Строки документа  --------------------*/

for each doc-line no-lock
   where doc-line.doc-code = t-doc.doc-code
   break &if "{&sort-prod}" = "yes"
           &then BY ( doc-line.prod-type + string( doc-line.prod-code ) )
           &endif
         BY doc-line.artic
:
    find first goods no-lock
         where goods.prod-type = doc-line.prod-type
           and goods.prod-code = doc-line.prod-code
           and goods.artic = doc-line.artic
    .
    find first gds-prt no-lock
         where gds-prt.upper-code = goods.prt-root
    .
    rootnode_code = gds-prt.node-code.

    { str/in-vatp.i calc doc-line. t-doc. g }

    assign
        v-goods-name = goods.gds-name
        v-goods-artic = goods.artic
        v-cost-price = ( if PrintRubl then price-rubl-with-tax-loc else price-base-with-tax-loc )
    .

    find first bar-code no-lock
         where bar-code.gds-code = goods.gds-code
           and bar-code.unit-cli = goods.unit-base
           and bar-code.node-code = rootnode_code
           and bar-code.part-code = ""
           and bar-code.in-code = ""
    .
/*  Если в документе должны быть цены продажи по прайс-листу:       */
/*    { gbl/bcodeprc.i doc-line.obj-type doc-line.obj-code goods.gds-code goods.gds-code 0 v-doc-num v-sale-price v-road-tax v-excise}*/
/*    А вообще продажные цены берутся из самого документа, gds-dtl  */
    find first gds-dtl no-lock
         where gds-dtl.doc-code = doc-line.doc-code
           and gds-dtl.prod-type = doc-line.prod-type
           and gds-dtl.prod-code = doc-line.prod-code
           and gds-dtl.artic = doc-line.artic
           and gds-dtl.prt-code = rootnode_code
    .

    assign
        v-doc-line-counter = v-doc-line-counter + 1
        v-bar-code      = goods.gds-code
        v-need-qnty     = gds-dtl.doc-qnty
        v-qnty-all      = gds-dtl.fact-qnty
        v-unit-name     = goods.unit-base
        v-cost-sum      = v-cost-price * v-qnty-all
        v-sale-price    = ( if PrintRubl then gds-dtl.price-rubl else gds-dtl.price-base )
        v-sale-sum      = v-sale-price * v-qnty-all
    .

    display stream Out-Stream
        v-doc-line-counter
        v-goods-artic
        v-goods-name
        v-bar-code
        v-unit-name
        " "         @ v-unit-OKEI
        v-need-qnty
        " "         @ v-places-amount
        " "         @ v-qnty-in-one-place
        v-qnty-all
        v-cost-price
        v-cost-sum
        v-sale-price
        v-sale-sum
        v-comment
        sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
        sym11 sym12 sym13 sym14 sym15 sym16
    with frame f-doc.
    down stream Out-Stream 1 with frame f-doc.

    { rep/op-4.i var}
    v-line-counter = v-line-counter + 1.

    accumulate
        v-cost-sum ( TOTAL )
        v-sale-sum ( TOTAL )
    .
end.        /*for  each doc-line ...*/
/*---E------- Строки документа  --------------------*/

if line-counter( Out-Stream ) + 9 > page-size( Out-Stream ) then
    do:
        { rep/op-4.i var itog}
        page stream Out-Stream .
        { rep/op-4.i head}
    end.
hide stream Out-Stream frame BottomFrame .

{ rep/op-4.i var itog}
display stream Out-Stream
    "Всего по накладной" @ v-goods-name
    t-doc.doc-qnty  @ v-need-qnty
    t-doc.fact-qnty @ v-qnty-all
    ( accum total v-cost-sum ) @ v-cost-sum
    ( accum total v-sale-sum ) @ v-sale-sum
with frame f-doc .
down stream Out-Stream 2 with frame f-doc .

if PrintRubl then
    run rep/wp-rub.p ( (accum total v-cost-sum), output s1, output s2 ) .
else
    run rep/wp.p ( input p-mainmenu-handle, (accum total v-cost-sum), output s1, output s2 ) .

put stream Out-Stream
    skip(1)
      space({&P1-S})
      "Всего на сумму"
      caps(substring(s1, 1, {&P1-EXT1})) format "X({&P1-EXT1})"
                                                at {&P1-C2-S}
      "Отпустил"                                at {&P1-C5-S}
      v-underline format "X(19)"                at {&P1-C6-S}
      v-underline format "X(19)"                at {&P1-C7-S}
      v-underline format "X(30)"                at {&P1-C8-S}
    skip
      caps(substring(s1, {&P1-EXT1} + 1)) format "X({&P1-EXT1})"
                                                at {&P1-C2-S}
      "должность"                               at center-field( {&P1-C6-S}, {&P1-C7-S}, 9)
      "подпись"                                 at center-field( {&P1-C7-S}, {&P1-C8-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C8-S}, {&P1-E}, 19)
    skip(1) space({&P1-S})
      "Отпуск разрешил:"
      "Принял"                                  at {&P1-C5-S}
      v-underline format "X(19)"                at {&P1-C6-S}
      v-underline format "X(19)"                at {&P1-C7-S}
      v-underline format "X(30)"                at {&P1-C8-S}
    skip space({&P1-S})
      "должность"                               at center-field( {&P1-C6-S}, {&P1-C7-S}, 9)
      "подпись"                                 at center-field( {&P1-C7-S}, {&P1-C8-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C8-S}, {&P1-E}, 19)
    skip(1) space({&P1-S})
      "Руководитель"
      v-underline format "X(19)"                at {&P1-C2-S}
      v-underline format "X(19)"                at {&P1-C3-S}
      v-underline format "X(30)"                at {&P1-C4-S}
      "Заведующий производством"                at {&P1-C5-S}
      v-underline format "X(19)"                at {&P1-C7-S}
      v-underline format "X(30)"                at {&P1-C8-S}
    skip space({&P1-S})
      "должность"                               at center-field( {&P1-C2-S}, {&P1-C3-S}, 9)
      "подпись"                                 at center-field( {&P1-C3-S}, {&P1-C4-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C4-S}, {&P1-C4-S} + 30, 19)
      "подпись"                                 at center-field( {&P1-C7-S}, {&P1-C8-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C8-S}, {&P1-E}, 19)
.

output stream Out-Stream close.
{ gbl/stopwork.i }
{ rep/q-print.i 8}

end.