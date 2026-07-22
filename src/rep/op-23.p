block-level on error undo, throw.
/*

$Revision: f557e6fb7653, 115, rls $
$Author: EShklyar $
$Date: Tue Dec 23 19:15:09 2014 +0300 $
$Workfile: op-23.p $
$Archive: rep/op-23.p $

Печатная форма ОП-23. Производство, акт о разделке мяса-сырья.

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.
define input parameter p-print-in-rubl      as logical          no-undo.
define input parameter p-print-details      as logical          no-undo.
define input parameter p-fat                as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: f557e6fb7653, 115, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 23 19:15:09 2014 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: op-23.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/op-23.p $":U .
define variable vss-description as character no-undo init "Печатная форма ОП-23. Производство, акт о разделке мяса-сырья.".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i      }
{ str/in-vatp.i def }
{ rep/p-fmt.i       }
{ rep/r-cliprp.i def }

/*---S----- Таблицы --------------------------------*/
&scop P-S 3
&scop P-X 195        /*длина линии*/
&scop P-X0 193       /*длина внутренней линии = длина линии - 2*/
&scop P-X1 48     /*длина внутренней линии от начала  1-й колонки до начала  4-й*/
&scop P-X2 7      /*длина внутренней линии от начала  4-й колонки до начала  6-й*/
&scop P-X3 26     /*длина внутренней линии от начала  6-й колонки до начала  9-й*/
&scop P-X4 47     /*длина внутренней линии от начала  9-й колонки до начала 12-й*/
&scop P-X5 59     /*длина внутренней линии от начала 12-й колонки до начала 20-й*/
&scop P-X6 24     /*длина внутренней линии от начала 13-й колонки до начала 16-й*/
&scop P-X7 26     /*длина внутренней линии от начала 17-й колонки до начала 20-й*/
&scop P-C2-S    {&P-S} + 18
&scop P-C3-S    {&P-S} + 40
&scop P-C4-S    {&P-S} + 50
&scop P-C5-S    {&P-S} + 54
&scop P-C6-S    {&P-S} + 58
&scop P-C7-S    {&P-S} + 67
&scop P-C8-S    {&P-S} + 75
&scop P-C9-S    {&P-S} + 85
&scop P-C10-S   {&P-S} + 102
&scop P-C11-S   {&P-S} + 123
&scop P-C12-S   {&P-S} + 133
&scop P-C13-S   {&P-S} + 138
&scop P-C14-S   {&P-S} + 146
&scop P-C15-S   {&P-S} + 151
&scop P-C16-S   {&P-S} + 158
&scop P-C17-S   {&P-S} + 166
&scop P-C18-S   {&P-S} + 175
&scop P-C19-S   {&P-S} + 183
&scop P-C20-S   {&P-S} + 193
&scop P-E       {&P-S} + 195

/*Надписи в конце таблицы*/
&scop P1-S 10
&scop P1-X 185
&scop P1-C2-S  {&P1-S} + 17
&scop P1-C3-S  {&P1-S} + 37
&scop P1-C4-S  {&P1-S} + 57
&scop P1-C5-S  {&P1-S} + 97
&scop P1-C6-S  {&P1-S} + 107
&scop P1-C7-S  {&P1-S} + 127
&scop P1-C8-S  {&P1-S} + 147
&scop P1-E     {&P1-S} + 177
&scop P1-EXT1  78              /*Количество символов для суммы прописью*/

/*Маленькая верхняя таблица */
&scop P2-S 180

/*Блок документа*/
&scop P3-S      64
&scop P3-C2-S   84
&scop P3-C3-S   97
&scop P3-C4-S   117
&scop P3-E      137

/*---E----- Таблицы --------------------------------*/

    define stream out-stream .

    define variable v-doc-code             like trn-doc.doc-code       no-undo.
    define variable v-doc-date             like trn-doc.doc-date       no-undo.
    define variable v-fact-date            like trn-doc.fact-date      no-undo.

    define variable v-root-node-code      as integer                  no-undo.

    define variable v-line-counter        as integer                  no-undo.
    define variable s1                    as char                     no-undo.
    define variable s2                    as char                     no-undo.

    define variable v-organization        as char                     no-undo.
    define variable v-org-name            as char                     no-undo.

    define variable v-bar-code            as integer                  no-undo.

    define variable v-in-goods-artic      as char                     no-undo.
    define variable v-in-goods-name       as char                     no-undo.
    define variable v-in-bar-code         as integer                  no-undo.
    define variable v-in-unit-name        as char                     no-undo.
    define variable v-in-unit-OKEI        as char                     no-undo.
    define variable v-in-price            as decimal                  no-undo.
    define variable v-in-mass           as decimal                  no-undo.
    define variable v-in-sum              as decimal                  no-undo.
    define variable v-out-goods-artic     as char                     no-undo.
    define variable v-out-goods-name      as char                     no-undo.
    define variable v-out-bar-code        as integer                  no-undo.
    define variable v-out-norm-prc        as decimal                  no-undo.
    define variable v-out-norm-mass       as decimal                  no-undo.
    define variable v-out-norm-prc-emp    as char    init "         " no-undo.
    define variable v-out-norm-mass-emp   as char    init "         " no-undo.
    define variable v-out-sum-norm-mass   as decimal                  no-undo.
    define variable v-out-price           as decimal                  no-undo.
    define variable v-out-fact-mass       as decimal                  no-undo.
    define variable v-out-sum             as decimal                  no-undo.
    define variable v-deviation           as char    init ""          no-undo.

    define variable v-pg-in-mass          as decimal                  no-undo.
    define variable v-pg-in-sum           as decimal                  no-undo.
    define variable v-pg-out-norm-mass    as decimal                  no-undo.
    define variable v-pg-out-fact-mass    as decimal                  no-undo.
    define variable v-pg-out-fact-sum     as decimal                  no-undo.

    define variable v-sum-in-mass          as decimal                  no-undo.
    define variable v-sum-in-sum           as decimal                  no-undo.
    define variable v-sum-out-norm-mass    as decimal                  no-undo.
    define variable v-sum-out-fact-mass    as decimal                  no-undo.
    define variable v-sum-out-fact-sum     as decimal                  no-undo.

    define variable sym1  as char init "|" no-undo.
    define variable sym2  as char init ":" no-undo.
    define variable sym3  as char init ":" no-undo.
    define variable sym4  as char init ":" no-undo.
    define variable sym5  as char init ":" no-undo.
    define variable sym6  as char init ":" no-undo.
    define variable sym7  as char init ":" no-undo.
    define variable sym8  as char init ":" no-undo.
    define variable sym9  as char init ":" no-undo.
    define variable sym10 as char init ":" no-undo.
    define variable sym11 as char init ":" no-undo.
    define variable sym12 as char init ":" no-undo.
    define variable sym13 as char init ":" no-undo.
    define variable sym14 as char init ":" no-undo.
    define variable sym15 as char init ":" no-undo.
    define variable sym16 as char init ":" no-undo.
    define variable sym17 as char init ":" no-undo.
    define variable sym18 as char init ":" no-undo.
    define variable sym19 as char init ":" no-undo.
    define variable sym20 as char init ":" no-undo.
    define variable sym21 as char init "|" no-undo.

    define variable v-single-line       as char          no-undo.
    define variable v-underline         as char          no-undo.

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define buffer  buf_fbr-doc       for fbr-doc.
    define buffer  buf_fbr-line      for fbr-line.
    define buffer  buf_recipe        for recipe.
    define buffer  buf_recipe-gds    for recipe-gds.
    define buffer  buf_goods         for goods.
    define buffer  buf_clients       for clients.
    define buffer  buf_units         for units.

do
for buf_fbr-doc
  , buf_fbr-line
  , buf_recipe
  , buf_recipe-gds
  , buf_goods
  , buf_clients
  , buf_units
on error undo, return error
:
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
find first buf_fbr-doc no-lock
     where recid(buf_fbr-doc) = p-recid
.
DEFINE frame f-doc
        space({&P-S})
        sym1  format "X(1)" space(0)   v-in-goods-artic    format "X(16)"     space(0)
        sym2  format "X(1)" space(0)   v-in-goods-name     format "X(21)"     space(0)
        sym3  format "X(1)" space(0)   v-in-bar-code       format ">>>>>>>>9" space(0)
        sym4  format "X(1)" space(0)   v-in-unit-name      format "X(3)"      space(0)
        sym5  format "X(1)" space(0)   v-in-unit-OKEI      format "X(3)"      space(0)
        sym6  format "X(1)" space(0)   v-in-price          format ">>>>9.99"  space(0)
        sym7  format "X(1)" space(0)   v-in-mass           format ">>>9.99"   space(0)
        sym8  format "X(1)" space(0)   v-in-sum            format ">>>>>9.99" space(0)
        sym9  format "X(1)" space(0)   v-out-goods-artic   format "X(16)"     space(0)
        sym10 format "X(1)" space(0)   v-out-goods-name    format "X(20)"     space(0)
        sym11 format "X(1)" space(0)   v-out-bar-code      format ">>>>>>>>9" space(0)
        sym12 format "X(1)" space(0)   v-out-norm-prc      format  ">9.9"     space(0)
        sym13 format "X(1)" space(0)   v-out-norm-mass     format ">>>9.99"   space(0)
        sym14 format "X(1)" space(0)   v-out-norm-prc-emp  format "X(4)"      space(0)
        sym15 format "X(1)" space(0)   v-out-norm-mass-emp format "X(6)"      space(0)
        sym16 format "X(1)" space(0)   v-out-sum-norm-mass format ">>>9.99"   space(0)
        sym17 format "X(1)" space(0)   v-out-price         format ">>>>9.99"  space(0)
        sym18 format "X(1)" space(0)   v-out-fact-mass     format ">>>9.99"   space(0)
        sym19 format "X(1)" space(0)   v-out-sum           format ">>>>>9.99" space(0)
        sym20 format "X(1)" space(0)   v-deviation         format "X(1)"      space(0)
        sym21 format "X(1)" space(0)
with width {&DOS_CW} down stream-io.


assign
    v-single-line  = fill("-", 230)
    v-underline    = fill("_", 230)
    v-line-counter = 1
.
assign
    v-doc-code  = buf_fbr-doc.doc-code
    v-doc-date  = buf_fbr-doc.doc-date
    v-fact-date = (if buf_fbr-doc.status_ <> {&fact} then ? else buf_fbr-doc.fact-date )
.

/*---S------ Находим подразделение - хозяина документа -------------*/
find first buf_clients no-lock
     where buf_clients.obj-type = buf_fbr-doc.obj-type
       and buf_clients.obj-code = buf_fbr-doc.obj-code
no-error.

case buf_clients.obj-type :
    when {&shop} then
        do:
            find first shop no-lock
                 where shop.obj-code = buf_clients.obj-code
            .
        end.
    when {&stock} then
        do:
            find first store no-lock
                 where store.obj-code = buf_clients.obj-code
            .
        end.
end case.

assign
    v-org-name = buf_clients.obj-name
.
/*---E------ Находим подразделение - хозяина документа -------------*/

if session:set-wait-state("compiler") then.
{ cmp/open-out.i stream Out-Stream " " {&LS_PS_A4} }

form header
    v-single-line format "X({&P-X})" at 1 skip
    "Продолжение - на следующей странице" at 30 skip
    with frame BottomFrame width {&DOS_CW} page-bottom no-labels no-box .
view stream Out-Stream frame BottomFrame .

find first clients no-lock
     where clients.obj-type = {&cmp}
       and clients.obj-code = buf_fbr-doc.host-code
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
    space({&P-S}) v-single-line format  "X(19)"             at {&P2-S}
  skip
    space({&P-S}) "| "                                      at {&P2-S}
                  {&g___code}                               at 188
                  "|"                                       at {&P-E}
  skip
    space({&P-S}) "Форма по ОКУД" format "X(14)"            at 166
                  "| "                                      at {&P2-S}
                  "0330523"
                  "|"                                       at {&P-E}
  skip
    space({&P-S}) "Организация:                         "
             v-organization             format "X(100)"
             "по ОКПО"                  format "X(7)"       at 172
             "| "                                           at {&P2-S}
             t-okpo                     format "X(16)" "|"  at {&P-E}
  skip
    space({&P-S}) "Струрное подразделение:              "
                  v-org-name            format "X(100)"
                  "| "                                      at {&P2-S}
                  "|"                                       at {&P-E}
    space({&P-S}) "Вид деятельности по ОКДП" format "X(25)" at 155
                  "| "                                      at {&P2-S}
                  "|"                                       at {&P-E}
  skip
    space({&P-S}) "Вид операции"        format "X(12)"      at 167
                  "| "                                      at {&P2-S}
                   ( if buf_fbr-doc.doc-type = {&income}
                   then " приход"
                   else ( if buf_fbr-doc.doc-type = {&return} then " возврат " else " расход" ) )
                                        format "X(16)"
                   "|"                                      at {&P-E}
  skip
    space({&P-S}) v-single-line         format  "X(19)"     at {&P2-S}
.

put stream Out-Stream
   skip
      "УТВЕРЖДАЮ" at center-field({&P3-E}, {&P-E}, 9)
   skip space({&P3-S})
      v-single-line format "X(73)"
      "Руководитель" at center-field({&P3-E}, {&P-E}, 12)
   skip
    space({&P3-S}) "|"
      "|"  at {&P3-C2-S}
      "|"  at {&P3-C3-S}
      "Отчетный период"   at  center-field({&P3-C3-S}, {&P3-E}, 15)
      "|"  at {&P3-E}
   skip space({&P3-S})
      "|"
      "Номер"   at  center-field({&P3-S}, {&P3-C2-S}, 5)
      "|"  at {&P3-C2-S}
      "Дата"   at  center-field({&P3-C2-S}, {&P3-C3-S}, 4)
      "|"  at {&P3-C3-S}
      v-single-line format "X(39)"
      "|"  at {&P3-E}
      v-underline format "X(25)" at center-field({&P3-E}, {&P-E}, 25)
   skip space({&P3-S})
      "|"
      "документа" format "X(9)" at  center-field({&P3-S}, {&P3-C2-S}, 9)
      "|"  at {&P3-C2-S}
      "составления" format "X(11)" at  center-field({&P3-C2-S}, {&P3-C3-S}, 11)
      "|"  at {&P3-C3-S}
      "с"                          at  center-field({&P3-C3-S}, {&P3-C4-S}, 1)
      "|"  at {&P3-C4-S}
      "по"                         at  center-field({&P3-C4-S}, {&P3-E}, 2)
      "|"  at {&P3-E}
      "должность" format "X(9)" at center-field({&P3-E}, {&P-E}, 9)
   skip space({&P3-S})
      "|"
      v-single-line format "X(71)"
      "|"  at {&P3-E}
   skip
      space(58) "А К Т | "
      v-doc-code format "X(16)"
      " | "
      v-doc-date format "99/99/9999"
      "|" at {&P3-C3-S}
      v-doc-date format "99/99/9999" at  center-field({&P3-C3-S}, {&P3-C4-S}, 10)
      "|" at {&P3-C4-S}
      v-fact-date format "99/99/9999" at  center-field({&P3-C4-S}, {&P3-E}, 10)
      "|"  at {&P3-E}
      "______________  _____________________________" format "X(45)" at center-field({&P3-E}, {&P-E}, 45)
   skip
      space(64) v-single-line format "X(73)"
      "    подпись          расшифровка подписи     " format "X(45)" at center-field({&P3-E}, {&P-E}, 45)
   skip
      space(43) "О РАЗДЕЛКЕ МЯСА-СЫРЬЯ НА ПОЛУФАБРИКАТЫ" format "X(41)"
      "<    > ________________         г."            format "X(34)" at center-field({&P3-E}, {&P-E}, 34)
.
/*---E----- Шапка документа ------------------------*/
/*---S------- Заголовок таблицы --------------------*/

form with frame f-doc .
down stream Out-Stream 1 with frame f-doc no-labels.

put stream Out-Stream
    skip space({&P-S})
      string( "Цены и суммы указаны в {&abbr_rublyah}"  ) format "X(30)"
      ( if buf_fbr-doc.status_ <> {&fact}
        then string( "Статус документа: " + buf_fbr-doc.status_ )
        else " " )
                                                  at 100 format "X(30)"
.

put stream Out-Stream
   skip space({&P-S})
     v-single-line format "X({&P-X})"
   skip space({&P-S})
     "|"
     "Мясо-сырье, поступившее в разделку" at center-field( {&P-S}, {&P-C4-S}, 34)
     ":"                                  at {&P-C4-S}
     "Единица"                            at center-field( {&P-C4-S}, {&P-C6-S}, 7)
     ":"                                  at {&P-C6-S}
     "Расход мяса-сырья"                  at center-field( {&P-C6-S}, {&P-C9-S}, 17)
     ":"                                  at {&P-C9-S}
     "Полуфабрикаты"                      at center-field( {&P-C9-S}, {&P-C12-S}, 13)
     ":"                                  at {&P-C12-S}
     "Выход полуфабрикатов"               at center-field( {&P-C12-S}, {&P-C20-S}, 20)
     ":"                                  at {&P-C20-S}
     "О"
     "|"                                  at {&P-E}
   skip space({&P-S})
     "|"
     v-single-line format "X({&P-X1})"
     ":"                                  at {&P-C4-S}
     v-single-line format "X({&P-X2})"
     ":"                                  at {&P-C6-S}
     v-single-line format "X({&P-X3})"
     ":"                                  at {&P-C9-S}
     v-single-line format "X({&P-X4})"
     ":"                                  at {&P-C12-S}
     v-single-line format "X({&P-X5})"
     ":"                                  at {&P-C20-S}
     "т"
     "|"                                  at {&P-E}
   skip space({&P-S})
     "|"
     ":"                                  at {&P-C2-S}
     ":"                                  at {&P-C3-S}
     ":"                                  at {&P-C4-S}
     ":"                                  at {&P-C5-S}
     ":"                                  at {&P-C6-S}
     ":"                                  at {&P-C7-S}
     ":"                                  at {&P-C8-S}
     ":"                                  at {&P-C9-S}
     ":"                                  at {&P-C10-S}
     ":"                                  at {&P-C11-S}
     ":"                                  at {&P-C12-S}
     "по норме"                           at center-field( {&P-C12-S}, {&P-C16-S}, 8)
     ":"                                  at {&P-C16-S}
     ":"                                  at {&P-C17-S}
     "фактически"                         at center-field( {&P-C17-S}, {&P-C20-S}, 10)
     ":"                                  at {&P-C20-S}
     "к"
     "|"                                  at {&P-E}
   skip space({&P-S})
     "|"
     ":"                                  at {&P-C2-S}
     ":"                                  at {&P-C3-S}
     ":"                                  at {&P-C4-S}
     "наи"
     ":"                                  at {&P-C5-S}
     "код"
     ":"                                  at {&P-C6-S}
     "цена"                               at center-field( {&P-C6-S}, {&P-C7-S}, 4)
     ":"                                  at {&P-C7-S}
     "масса"
     ":"                                  at {&P-C8-S}
     "сумма"                              at center-field( {&P-C8-S}, {&P-C9-S}, 5)
     ":"                                  at {&P-C9-S}
     ":"                                  at {&P-C10-S}
     ":"                                  at {&P-C11-S}
     ":"                                  at {&P-C12-S}
     v-single-line format "X({&P-X6})"    at {&P-C12-S} + 1
     ":"                                  at {&P-C16-S}
     "итого"
     ":"                                  at {&P-C17-S}
     v-single-line format "X({&P-X7})"    at {&P-C17-S} + 1
     ":"                                  at {&P-C20-S}
     "л"
     "|"                                  at {&P-E}
   skip space({&P-S})
     "|"
     "Артикул"                            at center-field( {&P-S}, {&P-C2-S}, 7)
     ":"                                  at {&P-C2-S}
     "Наименование"                       at center-field( {&P-C2-S}, {&P-C3-S}, 12)
     ":"                                  at {&P-C3-S}
     "Код"                                at center-field( {&P-C3-S}, {&P-C4-S}, 3)
     ":"                                  at {&P-C4-S}
     "мен"
     ":"                                  at {&P-C5-S}
     "ОК"
     ":"                                  at {&P-C6-S}
     "{&abbr_rub}.{&abbr_kop}"                            at center-field( {&P-C6-S}, {&P-C7-S}, 7)
     ":"                                  at {&P-C7-S}
     "кг"                                 at center-field( {&P-C7-S}, {&P-C8-S}, 2)
     ":"                                  at {&P-C8-S}
     "{&abbr_rub}.{&abbr_kop}"                            at center-field( {&P-C8-S}, {&P-C9-S}, 7)
     ":"                                  at {&P-C9-S}
     "Артикул"                            at center-field( {&P-C9-S}, {&P-C10-S}, 7)
     ":"                                  at {&P-C10-S}
     "Наименование"                       at center-field( {&P-C10-S}, {&P-C11-S}, 12)
     ":"                                  at {&P-C11-S}
     "Код"                                at center-field( {&P-C11-S}, {&P-C12-S}, 3)
     ":"                                  at {&P-C12-S}
     " в"
     ":"                                  at {&P-C13-S}
     "масса"
     ":"                                  at {&P-C14-S}
     " в"
     ":"                                  at {&P-C15-S}
     "масса"
     ":"                                  at {&P-C16-S}
     "масса"
     ":"                                  at {&P-C17-S}
     "цена"                               at center-field( {&P-C17-S}, {&P-C18-S}, 4)
     ":"                                  at {&P-C18-S}
     "масса"
     ":"                                  at {&P-C19-S}
     "сумма"                              at center-field( {&P-C19-S}, {&P-C20-S}, 5)
     ":"                                  at {&P-C20-S}
     "о"
     "|"                                  at {&P-E}
   skip space({&P-S})
     "|"
     ":"                                  at {&P-C2-S}
     ":"                                  at {&P-C3-S}
     ":"                                  at {&P-C4-S}
     ":"                                  at {&P-C5-S}
     "ЕИ"
     ":"                                  at {&P-C6-S}
     ":"                                  at {&P-C7-S}
     ":"                                  at {&P-C8-S}
     ":"                                  at {&P-C9-S}
     ":"                                  at {&P-C10-S}
     ":"                                  at {&P-C11-S}
     ":"                                  at {&P-C12-S}
     " %"
     ":"                                  at {&P-C13-S}
     " кг"
     ":"                                  at {&P-C14-S}
     " %"
     ":"                                  at {&P-C15-S}
     " кг"
     ":"                                  at {&P-C16-S}
     " кг"
     ":"                                  at {&P-C17-S}
     "{&abbr_rub}.{&abbr_kop}"                            at center-field( {&P-C17-S}, {&P-C18-S}, 7)
     ":"                                  at {&P-C18-S}
     "кг"                                 at center-field( {&P-C18-S}, {&P-C19-S}, 2)
     ":"                                  at {&P-C19-S}
     "{&abbr_rub}.{&abbr_kop}"                            at center-field( {&P-C19-S}, {&P-C20-S}, 7)
     ":"                                  at {&P-C20-S}
     "н"
     "|"                                  at {&P-E}
/*     Шаблон строки заголовка таблицы
   skip space({&P-S})
     "|"
     "Артикул"                            at center-field( {&P-S}, {&P-C2-S}, 7)
     ":"                                  at {&P-C2-S}
     ":"                                  at {&P-C3-S}
     ":"                                  at {&P-C4-S}
     ":"                                  at {&P-C5-S}
     ":"                                  at {&P-C6-S}
     ":"                                  at {&P-C7-S}
     ":"                                  at {&P-C8-S}
     ":"                                  at {&P-C9-S}
     ":"                                  at {&P-C10-S}
     ":"                                  at {&P-C11-S}
     ":"                                  at {&P-C12-S}
     ":"                                  at {&P-C13-S}
     ":"                                  at {&P-C14-S}
     ":"                                  at {&P-C15-S}
     ":"                                  at {&P-C16-S}
     ":"                                  at {&P-C17-S}
     ":"                                  at {&P-C18-S}
     ":"                                  at {&P-C19-S}
     ":"                                  at {&P-C20-S}
     "|"                                  at {&P-E}
*/
   skip space({&P-S})
     "|"
     v-single-line format "X({&P-X0})"
     "|" at {&P-E}
.
run write-header ( input v-single-line
                  ,input no
                 ).
/*---E------- Заголовок таблицы --------------------*/
/*---S------- Строки документа  --------------------*/
for each buf_fbr-line
   where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
   ,each buf_recipe
   where buf_recipe.recipe-code = buf_fbr-line.recipe-code
     and buf_recipe.recipe-type = {&dressing}
   ,each buf_goods
   where buf_goods.artic      = buf_fbr-line.artic
     and buf_goods.prod-type  = buf_fbr-line.prod-type
     and buf_goods.prod-code  = buf_fbr-line.prod-code
break by buf_recipe.recipe-code
      by buf_fbr-line.is-comp descending
:
    { gbl/gdsbcode.i buf_goods.gds-code ? v-bar-code no-error}.
    if error-status:error then
    do:
    message
      vss-workfile + ". Не найден бар-код товара " + buf_goods.artic
    view-as alert-box error.
        undo, return error .
    end.

    if buf_fbr-line.is-comp = yes
    then do:
        find first buf_units no-lock
             where buf_units.unit-name = buf_goods.unit-base
        .
        assign
            v-in-price    = (if buf_fbr-line.price-rubl = ? then 0 else buf_fbr-line.price-rubl)
            v-in-sum      = (if buf_fbr-line.price-rubl * buf_fbr-line.rsrv-qnty = ?
                             then 0
                             else buf_fbr-line.price-rubl * buf_fbr-line.rsrv-qnty
                            )
            v-in-mass     = buf_fbr-line.rsrv-qnty
            v-pg-in-mass  = v-pg-in-mass + v-in-mass
            v-pg-in-sum   = v-pg-in-sum + v-in-sum
        .
        display stream out-stream
          sym1    buf_goods.artic         @ v-in-goods-artic
          sym2    buf_goods.gds-name      @ v-in-goods-name
          sym3    v-bar-code              @ v-in-bar-code
          sym4    buf_goods.unit-base     @ v-in-unit-name
          sym5    buf_units.OKEI          @ v-in-unit-OKEI
          sym6    v-in-price
          sym7    v-in-mass
          sym8    v-in-sum
        with frame f-doc.
    end.
    else do:
        find first buf_recipe-gds no-lock
             where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
               and buf_recipe-gds.prod-type   = buf_goods.prod-type
               and buf_recipe-gds.prod-code   = buf_goods.prod-code
               and buf_recipe-gds.artic       = buf_goods.artic
        .
        assign
/*            v-deviation = (if (buf_fbr-line.fact-qnty - buf_fbr-line.rsrv-qnty) < 0*/
/*                           then "-"*/
/*                           else (if (buf_fbr-line.fact-qnty - buf_fbr-line.rsrv-qnty) > 0 then "+" else "")*/
/*                          )*/

            v-out-norm-prc  = buf_recipe-gds.qnty / buf_recipe.qnty * 100
/*            v-out-norm-mass = (if buf_recipe-gds.is-waste = yes then buf_fbr-line.fact-qnty else buf_fbr-line.rsrv-qnty)*/
            v-out-norm-mass = buf_recipe-gds.qnty / buf_recipe.qnty * v-in-mass

            v-out-norm-mass = (if v-out-norm-mass = ? then 0 else v-out-norm-mass )
            v-out-price     = (if buf_fbr-line.price-rubl = ? then 0 else buf_fbr-line.price-rubl)
            v-out-sum       = (if buf_fbr-line.price-rubl * buf_fbr-line.rsrv-qnty = ?
                               then 0
                               else buf_fbr-line.price-rubl * buf_fbr-line.rsrv-qnty
                              )
            v-out-fact-mass     = buf_fbr-line.fact-qnty

            v-pg-out-norm-mass  = v-pg-out-norm-mass  + v-out-norm-mass
            v-pg-out-fact-mass  = v-pg-out-fact-mass  + v-out-fact-mass
            v-pg-out-fact-sum   = v-pg-out-fact-sum   + v-out-sum
            v-deviation = (if (v-out-fact-mass - v-out-norm-mass) < 0
                           then "-"
                           else (if (v-out-fact-mass - v-out-norm-mass) > 0 then "+" else "")
                          )
        .
        display stream out-stream
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8
          sym9    buf_goods.artic         @ v-out-goods-artic
          sym10   buf_goods.gds-name      @ v-out-goods-name
          sym11   v-bar-code              @ v-out-bar-code
          sym12   v-out-norm-prc
          sym13   v-out-norm-mass
          sym14
          sym15
          sym16   v-out-norm-mass         @ v-out-sum-norm-mass
          sym17   v-out-price
          sym18   v-out-fact-mass
          sym19   v-out-sum
          sym20   v-deviation
          sym21
        with frame f-doc.
        down stream out-stream 1 with frame f-doc.
    end.
    if line-counter( Out-Stream ) + 1 > page-size( Out-Stream )
    then do:
        run write-itog( input "Итого"
                       ,input v-pg-in-mass
                       ,input v-pg-in-sum
                       ,input v-pg-out-norm-mass
                       ,input v-pg-out-fact-mass
                       ,input v-pg-out-fact-sum
                      ).
        assign
            v-sum-in-mass       = v-sum-in-mass       + v-pg-in-mass
            v-sum-in-sum        = v-sum-in-sum        + v-pg-in-sum
            v-sum-out-norm-mass = v-sum-out-norm-mass + v-pg-out-norm-mass
            v-sum-out-fact-mass = v-sum-out-fact-mass + v-pg-out-fact-mass
            v-sum-out-fact-sum  = v-sum-out-fact-sum  + v-pg-out-fact-sum

            v-pg-in-mass        = 0
            v-pg-in-sum         = 0
            v-pg-out-norm-mass  = 0
            v-pg-out-fact-mass  = 0
            v-pg-out-fact-sum   = 0
        .
        down stream out-stream 1 with frame f-doc.
        run write-header(   input v-single-line
                          , input yes
                        ).
    end.

end.

/*---E------- Строки документа  --------------------*/

hide stream Out-Stream frame BottomFrame .
if line-counter( Out-Stream ) + 9 > page-size( Out-Stream )
then do:
    run write-itog(   input "Итого"
                    , input v-pg-in-mass
                    , input v-pg-in-sum
                    , input v-pg-out-norm-mass
                    , input v-pg-out-fact-mass
                    , input v-pg-out-fact-sum
                  ).
    assign
        v-sum-in-mass       = v-sum-in-mass       + v-pg-in-mass
        v-sum-in-sum        = v-sum-in-sum        + v-pg-in-sum
        v-sum-out-norm-mass = v-sum-out-norm-mass + v-pg-out-norm-mass
        v-sum-out-fact-mass = v-sum-out-fact-mass + v-pg-out-fact-mass
        v-sum-out-fact-sum  = v-sum-out-fact-sum  + v-pg-out-fact-sum
    .
    page stream Out-Stream .
    run write-header(   input v-single-line
                      , input yes
                    ).
end.
else do:
    run write-itog(   input "Итого"
                            , input v-pg-in-mass
                            , input v-pg-in-sum
                            , input v-pg-out-norm-mass
                            , input v-pg-out-fact-mass
                            , input v-pg-out-fact-sum
                  ).
            assign
                v-sum-in-mass       = v-sum-in-mass       + v-pg-in-mass
                v-sum-in-sum        = v-sum-in-sum        + v-pg-in-sum
                v-sum-out-norm-mass = v-sum-out-norm-mass + v-pg-out-norm-mass
                v-sum-out-fact-mass = v-sum-out-fact-mass + v-pg-out-fact-mass
                v-sum-out-fact-sum  = v-sum-out-fact-sum  + v-pg-out-fact-sum
            .

end.

run write-itog( input "Всего"
                ,input v-sum-in-mass
                ,input v-sum-in-sum
                ,input v-sum-out-norm-mass
                ,input v-sum-out-fact-mass
                ,input v-sum-out-fact-sum
              ).

down stream Out-Stream 2 with frame f-doc .

put stream Out-Stream
    skip(1) space({&P1-S})
      "Переработано мяса-сырья"
      v-sum-in-mass format ">>>>>>9.99" at  {&P1-C3-S}
      space(2) "кг"
      "Выработано полуфабрикатов"               at {&P1-C5-S}
      v-sum-out-fact-mass format ">>>>>>9.99"    at {&P1-C8-S}
      space(2) "кг"
    skip space({&P1-S})
      v-underline format "X({&P1-X})"
    skip(1) space({&P1-S})
      "Представитель администрации"
      v-underline format "X(10)"                at {&P1-C2-S} + 13
      v-underline format "X(15)"                at {&P1-C3-S} + 4
      v-underline format "X(30)"                at {&P1-C4-S}
      "Заведующий производством"                at {&P1-C5-S}
      v-underline format "X(19)"                at {&P1-C7-S}
      v-underline format "X(30)"                at {&P1-C8-S}
    skip space({&P1-S})
      "должность"                               at center-field( {&P1-C2-S} + 13, {&P1-C3-S} + 4, 9)
      "подпись"                                 at center-field( {&P1-C3-S} + 4, {&P1-C4-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C4-S}, {&P1-C4-S} + 30, 19)
      "подпись"                                 at center-field( {&P1-C7-S}, {&P1-C8-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C8-S}, {&P1-E}, 19)
    skip space({&P1-S})
      "Мастер (бригадир)"
      v-underline format "X(19)"                at {&P1-C3-S}
      v-underline format "X(30)"                at {&P1-C4-S}
      v-underline format "X(19)"                at {&P1-C6-S}
      v-underline format "X(19)"                at {&P1-C7-S}
      v-underline format "X(30)"                at {&P1-C8-S}
    skip space({&P1-S})
      "подпись"                                 at center-field( {&P1-C3-S}, {&P1-C4-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C4-S}, {&P1-C4-S} + 30, 19)
      "должность"                               at center-field( {&P1-C6-S}, {&P1-C7-S}, 9)
      "подпись"                                 at center-field( {&P1-C7-S}, {&P1-C8-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C8-S}, {&P1-E}, 19)
    skip space({&P1-S})
      "Проверил бухгалтер"
      v-underline format "X(19)"                at {&P1-C3-S}
      v-underline format "X(30)"                at {&P1-C4-S}
      "Приложение ________________________________________ документов"       at {&P1-C5-S}
    skip space({&P1-S})
      "подпись"                                 at center-field( {&P1-C3-S}, {&P1-C4-S}, 6)
      "расшифровка подписи"                     at center-field( {&P1-C4-S}, {&P1-C4-S} + 30, 19)
.

output stream Out-Stream close.
{ gbl/stopwork.i }
{ rep/q-print.i 8}

end.


/* Шапка с цифрами для каждой новой страницы */
procedure write-header :
do
on error undo, return error
:
def input parameter p-single-line as char    no-undo.
def input parameter p-need-line   as logical no-undo.

    if p-need-line = yes
    then put stream out-stream
        skip
          string( "Страница " + string( PAGE-NUMBER( Out-Stream ), ">>9" ) ) format "X(13)" at right-field( {&P-E}, 13)
        skip space({&P-S})
          p-single-line format "X({&P-X})"
    .
    put stream out-stream
        skip space({&P-S})
          "|"
          "1"                  at center-field( {&P-S}, {&P-C2-S}, 1)
          ":"                  at {&P-C2-S}
          "2"                  at center-field( {&P-C2-S}, {&P-C3-S}, 1)
          ":"                  at {&P-C3-S}
          "3"                  at center-field( {&P-C3-S}, {&P-C4-S}, 1)
          ":"                  at {&P-C4-S}
          "4"                  at center-field( {&P-C4-S}, {&P-C5-S}, 1)
          ":"                  at {&P-C5-S}
          "5"                  at center-field( {&P-C5-S}, {&P-C6-S}, 1)
          ":"                  at {&P-C6-S}
          "6"                  at center-field( {&P-C6-S}, {&P-C7-S}, 1)
          ":"                  at {&P-C7-S}
          "7"                  at center-field( {&P-C7-S}, {&P-C8-S}, 1)
          ":"                  at {&P-C8-S}
          "8"                  at center-field( {&P-C8-S}, {&P-C9-S}, 1)
          ":"                  at {&P-C9-S}
          "9"                  at center-field( {&P-C9-S}, {&P-C10-S}, 1)
          ":"                  at {&P-C10-S}
          "10"                 at center-field( {&P-C10-S}, {&P-C11-S}, 2)
          ":"                  at {&P-C11-S}
          "11"                 at center-field( {&P-C11-S}, {&P-C12-S}, 2)
          ":"                  at {&P-C12-S}
          "12"                 at center-field( {&P-C12-S}, {&P-C13-S}, 2)
          ":"                  at {&P-C13-S}
          "13"                 at center-field( {&P-C13-S}, {&P-C14-S}, 2)
          ":"                  at {&P-C14-S}
          "14"                 at center-field( {&P-C14-S}, {&P-C15-S}, 2)
          ":"                  at {&P-C15-S}
          "15"                 at center-field( {&P-C15-S}, {&P-C16-S}, 2)
          ":"                  at {&P-C16-S}
          "16"                 at center-field( {&P-C16-S}, {&P-C17-S}, 2)
          ":"                  at {&P-C17-S}
          "17"                 at center-field( {&P-C17-S}, {&P-C18-S}, 2)
          ":"                  at {&P-C18-S}
          "18"                 at center-field( {&P-C18-S}, {&P-C19-S}, 2)
          ":"                  at {&P-C19-S}
          "19"                 at center-field( {&P-C19-S}, {&P-C20-S}, 2)
          ":"                  at {&P-C20-S}
          "X"
          "|"                  at {&P-E}
        skip space({&P-S})
          "|"
          p-single-line format "X({&P-X0})"
          "|"                  at {&P-E}

    .
end.
end procedure. /* write-header */


procedure write-itog :
do
on error undo, return error
:
    define input parameter p-type          as char no-undo.     /*"Итого" или "Всего"*/
    define input parameter p-in-mass       as decimal no-undo.
    define input parameter p-in-sum        as decimal no-undo.
    define input parameter p-out-norm-mass as decimal no-undo.
    define input parameter p-out-fact-mass as decimal no-undo.
    define input parameter p-out-fact-sum  as decimal no-undo.

    put stream Out-Stream
      skip space({&P-S})
        v-single-line format "X({&P-X})"
    .
/*    down stream Out-Stream 1 with frame f-doc no-labels.*/
    display stream out-stream
              p-type                              @ v-in-price
      sym7    p-in-mass       format ">>>9.99"    @ v-in-mass
      sym8    p-in-sum        format ">>>>>9.99"  @ v-in-sum
      sym13   p-out-norm-mass format ">>>9.99"    @ v-out-norm-mass
      sym14
      sym15   p-out-norm-mass format ">>>9.99"    @ v-out-sum-norm-mass
      sym16   p-out-norm-mass format ">>>9.99"    @ v-out-norm-mass
      sym17
      sym18   p-out-fact-mass format ">>>9.99"    @ v-out-fact-mass
      sym19   p-out-fact-sum  format ">>>>>9.99"  @ v-out-sum
      sym21
    with frame f-doc.

end.
end procedure. /* write-itog */