block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-supgds.p $
$Archive: rep/r-supgds.p $

Печать текущие остатков товаров по партиям по поставщику

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER titl AS CHAR NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-supgds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-supgds.p $":U .
define variable vss-description as character no-undo init "Печать текущие остатков товаров по партиям по поставщику".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   new }
{ trg/partsfnc.i }
{ cmp/r-page1.i  new }
{ gbl/prn-lib.i  }
my-handle = parparentproc.
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
{ gbl/waitfram.i }
{ gbl/alc-lib.i  }




DEFINE SHARED BUFFER s-parts FOR ub.parts.
DEFINE SHARED BUFFER s-goods FOR ub.goods.
DEFINE SHARED QUERY br-parts FOR s-parts, s-goods  SCROLLING.

define variable object as char no-undo.
define variable stat as char no-undo.
define variable p-code as char no-undo.
define variable price like ub.parts.price-rubl no-undo.
define variable stoim like ub.parts.price-rubl no-undo.
define variable tot-qnty like ub.parts.fact-qnty no-undo.
define variable tot-stoim like ub.parts.price-rubl no-undo.

define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable sym8 as char init ":"   no-undo.
define variable sym9 as char init ":"   no-undo.

define variable Line as char no-undo.
define variable v-base-code  like ub.sysconf.base-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_currency for ub.currency.
{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code  }
{ gbl/basecode.i v-host-code v-base-code }
find first buf_currency no-lock where
         buf_currency.curr-code = v-base-code .

if v-base-code <> 0 then
    message "Печатать в {&abbr_rublyah_allshift} ?" VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.
else
    assign PrintRubl = yes .

assign
sheetf.Excel-Column-Lable =  "Артикул,Название,Объект,Факт кол-во,Статус,Партия,Цена,Стоимость"
sheetf.sizes = "16,30,10,13,16,14,14,14"
sheetf.colformat = {&delim-par} + "1=@"
Make-Excel = yes
reportname = titl
str3 = "Цены и суммы указаны в " + (if PrintRubl then "{&abbr_rub}" else buf_currency.curr-abbr)
.
run get-report-num in parparentproc(output g#report-num).

DEFINE FRAME supp-gds
      sym1 column-label ":" format "X(1)" space(0)
      s-parts.artic COLUMN-LABEL "Артикул" FORMAT "x(16)"  space(0)
      sym2 column-label ":" format "X(1)" space(0)
      s-goods.gds-name COLUMN-LABEL "Название" FORMAT "x(30)"  space(0)
      sym3 column-label ":" format "X(1)" space(0)
      object COLUMN-LABEL "Объект" FORMAT "x(10)"  space(0)
      sym4 column-label ":" format "X(1)" space(0)
      s-parts.fact-qnty COLUMN-LABEL "Факт кол-во " FORMAT "->>>,>>9.<<<" space(0)
      sym5 column-label ":" format "X(1)" space(0)
      stat COLUMN-LABEL "Статус" FORMAT "x(16)" space(0)
      sym6 column-label ":" format "X(1)" space(0)
      p-code COLUMN-LABEL "Партия" FORMAT "x(14)" space(0)
      sym7 column-label ":" format "X(1)" space(0)
      price COLUMN-LABEL "Цена" FORMAT "->>,>>>,>>9.99" space(0)
      sym8 column-label ":" format "X(1)" space(0)
      stoim COLUMN-LABEL "Стоимость" FORMAT "->>,>>>,>>9.999" space(0)
      sym9 column-label ":" format "X(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( str3  ) AT 45 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 120 format "X(13)" SKIP
        Line format "X(136)" AT 1
    with width {&DOS_CW_2} down stream-io.


run waitfram-show in this-procedure ({&MyWaitMess} ) .
if session:set-wait-state("COMPILER") then.

assign Line = fill("-", {&DOS_CW_2}).

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

RUN OpenForExcel in this-procedure .

/* Это из-за того, что в SHARED QUERY br-parts используется index reposition и,
    как следствие, не работает GET first br-parts ( ошибка 3157 ) */
DO WHILE available s-parts :
    GET prev br-parts.
END.

PUT STREAM PrnLibStream titl AT 10 format "X(136)" SKIP.

run rep/extitle.p (1).


GET next br-parts.
DO WHILE available s-parts :
    if PrintRubl then
        assign price = s-parts.price-rubl.
    else
        assign price = s-parts.price-base.
    assign stoim = price * s-parts.fact-qnty.
    DISPLAY STREAM PrnLibStream
        sym1 s-parts.artic
        sym2 s-goods.gds-name
        sym3 (s-parts.obj-type + " " + STRING (s-parts.obj-code)) @ object
        sym4 s-parts.fact-qnty
        sym5 get-parts-out-code (buffer s-parts) @ stat
        sym6 (if s-parts.part-code = "" then "------" else s-parts.part-code) @ p-code
        sym7 price
        sym8 stoim
        sym9
        with FRAME supp-gds .
    DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
    {&PutExcel}
    s-parts.artic                                                               {&tabulation}
    s-goods.gds-name                                                            {&tabulation}
    (s-parts.obj-type + " " + STRING (s-parts.obj-code))                        {&tabulation}
    s-parts.fact-qnty                                                           {&tabulation}
    get-parts-out-code (buffer s-parts)                                         {&tabulation}
    (if s-parts.part-code = "" then "------" else s-parts.part-code)            {&tabulation}
    price                                                                       {&tabulation}
    stoim
    skip.
    assign
        tot-qnty = tot-qnty + s-parts.fact-qnty
        tot-stoim = tot-stoim + stoim
        .
    GET next br-parts.
END.

PUT STREAM PrnLibStream Line format "X(136)" SKIP.

DISPLAY STREAM PrnLibStream
    "Итого :" @ object
    tot-qnty @ s-parts.fact-qnty
    tot-stoim @ stoim
    with FRAME supp-gds .
DOWN STREAM PrnLibStream 1 with FRAME supp-gds .

{&PutExcel}
                 {&tabulation}
                 {&tabulation}
"Итого :"        {&tabulation}
tot-qnty         {&tabulation}
                 {&tabulation}
                 {&tabulation}
                 {&tabulation}
tot-stoim
skip.


output STREAM PrnLibStream CLOSE.
{&CloseExcel}

run waitfram-hide in this-procedure .
if session:set-wait-state("") then.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).