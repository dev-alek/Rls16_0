block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: order2.p $
$Archive: rep/order2.p $

Формы печати заказа

Автор: Чернова Светлана Александровна
Дата создания: 02.03.01
Author: Svetlana Chernova
Creation date: 02.03.01

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: order2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/order2.p $":U .
define variable vss-description as character no-undo init "Формы печати заказа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-page1.i new }
{ cmp/r-pril.i  }
{ rep/r-cliprp.i def }
{ str/out-vatp.i def }
{ gbl/waitfram.i }
&glob format-sl "X(136)"

DEFINE SHARED VARIABLE Sort-gr AS LOGICAL
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

DEFINE Shared VARIABLE print-graft AS LOGICAL
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

define stream OutStream.
define variable    NAme1   as character no-undo .
define variable    Adres1 as character no-undo .
define variable    NAme2   as character no-undo .
define variable    Adres2  as character no-undo .


define variable     PrintScale      as   logical     no-undo.
define variable     CostPrice      as   logical     no-undo.
define buffer This_Object for  ub.clients .
define buffer gds-prt-1   for  ub.gds-prt .
define buffer bar-code-1  for  ub.bar-code .

define variable LineBuf    as character    no-undo.
define variable Line       as character    no-undo.
define variable UndLine    as character    no-undo.

define variable Lines_Counter as   integer  init 0  no-undo.
define variable Tmp_Counter   as   integer  init 0  no-undo.

define variable tdoc-date     like ub.trn-doc.doc-date no-undo.
define variable tdoc-code     like ub.trn-doc.doc-code no-undo.

define variable Control_sUM       as  decimal no-undo.
define variable Control_Qnty      as  decimal no-undo.
define variable PgQnty            as  decimal no-undo.
define variable PgSum             as  decimal no-undo.
define variable PgQnty-b          as  decimal no-undo.
define variable PgSum-b           as  decimal no-undo.
define variable SQnty             as  decimal no-undo.
define variable SSum              as  decimal no-undo.
define variable SQnty-b           as  decimal no-undo.
define variable SSum-b            as  decimal no-undo.
define variable PropisQnty        as  character no-undo.
define variable PropisSum         as  character no-undo.
define variable PropisQnty-b      as  character no-undo.
define variable PropisSum-b       as  character no-undo.
define variable B-Sum1 as decimal no-undo .
define variable B-Sum as decimal no-undo .
define variable B-Sum-qnty as decimal no-undo .

define variable B-adress like ub.firm.addres1 no-undo .
define variable B-phone  like ub.firm.phone no-undo .

define variable  Propiscount       as  character no-undo.
define variable  PropiscountP      as  character no-undo.
define variable  abbr              as  character no-undo.

define variable tt    as integer no-undo.

define variable sym1 as character  init ":"   no-undo.
define variable sym2 as character  init ":"   no-undo.
define variable sym3 as character  init ":"   no-undo.
define variable sym4 as character  init ":"   no-undo.
define variable sym5 as character  init ":"   no-undo.
define variable sym6 as character  init ":"   no-undo.
define variable sym7 as character  init ":"   no-undo.
define variable sym8 as character  init ":"   no-undo.
define variable sym9 as character  init ":"   no-undo.
define variable sym10 as character init ":"   no-undo.
define variable sym11 as character init ":"   no-undo.
define variable sym12 as character init ":"   no-undo.
define variable sym13 as character init ":"   no-undo.
define variable sym14 as character init ":"   no-undo.

define variable tb-code       as character    no-undo.
define variable Price         as decimal no-undo.
define variable UBL           as decimal no-undo .
define variable b-qnty        as decimal no-undo.
define variable b-stoim       as decimal no-undo.
define variable b-price       as decimal no-undo.
define variable B-service     as decimal no-undo.
define variable B-ship        as decimal no-undo.
define variable OKEI          as character    no-undo.
define variable ProdName      as character    no-undo.
define variable pp as character no-undo .

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

{ rep/f-fdec.i }

DEFINE FRAME sl
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! " format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(16)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X(39)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(10)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.sort COLUMN-LABEL "Сорт! ! ! ! " format "X(4)" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.units.OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format ">>>>" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        ub.goods.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-qnty COLUMN-LABEL "Количество ! ! ! ! " format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-PRICE COLUMN-LABEL "Цена           ! ! ! ! " format "->>>>>>>>>.<<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-stoim COLUMN-LABEL "Сумма ! ! ! ! " format "->>>,>>>,>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Заказ N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 90 format "X(19)"
        string( " Лист " + string( PAGE-NUMBER(OutStream) , ">>9") ) format "X(13)" SKIP
        UndLine format {&format-sl} AT 1
        with width {&A4_CW0} down stream-io use-text NO-BOX.

FIND ub.trn-doc WHERE recid(ub.trn-doc) = rec_id NO-LOCK .
assign
    tdoc-date = (if ub.trn-doc.status_ <> {&fact} then ub.trn-doc.doc-date else ub.trn-doc.fact-date)
    tdoc-code = ub.trn-doc.doc-code .

if PrintRubl = ? AND CostPrice = ? AND PrintScale = ? then
    RETURN.
if NOT ub.trn-doc.internal and PrintScale then DO:
   message "Внешние запросы печатаются без разбиения по признакам !" view-as alert-box . PrintScale = false .
End.

{ cmp/open-out.i STREAM OutStream " " {&CP_PS} }

Make-Excel = true .

Assign
  Line    = fill("-", 136)
  UndLine = fill("_", 136)
  LineBuf = fill("_", 136) .
 if  CostPrice then DO:
                   IF PrintRubl
                     THEN Assign PP = "Учетные цены ".
                     Else Assign PP = "Учетные цены (б.в.)" .
                   End.
   Else DO:
                IF PrintRubl
                     THEN Assign PP = "Цены док-та".
                     Else Assign PP = "Цены док-та (б.в.)" .
        End.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .


FIND This_Object  WHERE This_Object.obj-type = ub.trn-doc.obj-type
                    AND This_Object.obj-code = ub.trn-doc.obj-code NO-LOCK.

FIND ub.clients  WHERE ub.clients.obj-type = {&cmp}
                AND ub.clients.obj-code = ub.trn-doc.host-code NO-LOCK.

Case ub.trn-doc.cli-type :
    when  {&cmp} then do :
        FIND ub.firm  WHERE ub.firm.firm-code = ub.trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.firm.addres1
          b-phone  = ub.firm.phone .
        end.

    when  {&prs} then do :
        FIND ub.person  WHERE ub.person.psn-code = ub.trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.person.address
          b-phone  = ub.person.phone1 .
        end.

    when  {&shop} then do :
        FIND ub.shop  WHERE ub.shop.obj-code = ub.trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.shop.addres1
          b-phone  = ub.shop.phone .
        end.

    when  {&stock} then do :
        FIND ub.store  WHERE ub.store.obj-code = ub.trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.store.addres1
          b-phone  = ub.store.phone .
        end.
 End case.
 IF ub.trn-doc.doc-type = {&income} Then
  Assign
   NAme1   = "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
   Adres1 = t-addres + " " + t-phone
   NAme2   = ub.trn-doc.cli-name
   Adres2  = b-adress + '  ' + b-phone .
   Else
  Assign
   NAme2   = "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
   Adres2 = t-addres + " " + t-phone
   NAme1   = ub.trn-doc.cli-name
   Adres1  = b-adress + '  ' + b-phone .

/* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
{ rep/r-cliprp.i }
PUT STREAM OutStream
                                                                     space(5) Line format  "X(19)" AT 42 + 76 skip
    space(0)                                                        "| " AT 42 + 76 {&g___code}  AT 50 + 76   "|" AT 60 + 76 skip
    space(0) "Форма по ОКУД" format "X(14)"                  AT 66 + 38  "| " AT 42 + 76 "0330226"            "|" AT 60 + 76 skip
    space(0) string( Name1 + ' ' + Adres1 ) format "X(100)"
                                     "по ОКПО" format "X(7)" AT  72 + 38 "| " AT  42 + 76 t-okpo format "X(16)" "|" AT 60 + 76 skip
    space(0) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "X(100)"
                                                                    "| " AT 42 + 76                        "|" AT 60 + 76 skip
    space(0) "Вид деятельности по ОКДП" format "X(25)" AT 55 + 38       "| " AT 42 + 76                        "|" AT 60 + 76 skip
    space(0) "" format "X(26)" AT 53 + 38                               "| " AT 42 + 76 ub.trn-doc.doc-date
                                                                           format "99/99/9999"        "|" AT 60 + 76 skip
    space(0) "" format "X(29)" AT 50 + 38                               "| " AT 42 + 76
                            (if ub.trn-doc.status_ <> {&fact} then tdoc-date else ?) format "99/99/9999" "|" AT 60 + 76 skip
    space(0) "Вид операции" format "X(12)" AT 67 + 38                   "| " AT 42 + 76 "  " format "X(16)"    "|" AT 60 + 76 skip

                                                                     space(5) Line format  "X(19)" AT 42 + 76 skip(2)
                                       space(79) Line format "X(33)" skip
    space(56) string( "З А К А З ") format "x(10)"
                                      " | " at 79
                                        ( string( tdoc-code , "X(16)" ) + " | "
                                        + string( tdoc-date , "99/99/9999" )
                                    + " | "  + (if ub.trn-doc.status_ <> {&fact} then string( "(" + CAPS(ub.trn-doc.status_) + ")" ) else ""))
                                           format "X(100)" skip
                                         space(79) Line format "X(33)" skip
    space(0) "Заказчик " name2  format "X(130)" skip(1)
    space(0) "Адрес " adres2 format "X(40)"  skip(1)
    space(0) "Заказ принял "
                UndLine format "X(25)" AT 25 UndLine format "X(50)" at 60 SKIP
                  "должность" format "X(25)" AT 25 "фамилия,имя,отчество" format "X(50)" AT 60 SKIP(1)
    "Заказ передал отборщику " UndLine format "X(25)" AT 25 UndLine format "X(50)" at 60 SKIP
    "должность" format "X(25)" AT 25 "фамилия,имя,отчество" format "X(50)"  AT 60 SKIP(2)

    .

   os-delete value( string( session:temp-directory ) +
                              {&DF_Name} + string( g#report-num ) + ".txt":U ) .
   output stream forexcel to value( string( session:temp-directory ) +
                              {&DF_Name} + string( g#report-num ) + ".txt":U ) .
REPORTNAME =   string( "З А К А З    ") +
                                        ( string( tdoc-code , "X(16)" ) + "   "
                                        + string( tdoc-date , "99/99/9999" )
                                    + "  "  + (if ub.trn-doc.status_ <> {&fact} then string( "(" + CAPS(ub.trn-doc.status_) + ")" ) else "")).

sheetf.Sizes = "10,16,60,7,13,13,13,13,13,13,13,13,13,13,13,".
sheetf.Excel-Column-Lable =  "N п/п,Артикул,Наименование товара,Код товара,Код ед.изм. по ОКЕИ, Наим ед.изм. ,Количество в упаковке,Вес упаковки,Объем  упаковки, Цена ,Количество , Сумма ,Ед.изм.пост-ка ,Количество единиц(пост.),Цена за един.(вал. пост-ка),".
sheetf.ColFormat = "2=@;3=@;" .
   str1 = string( Name1 + ' ' + Adres1 ) .
    str2 = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ).
    str3 = "Заказчик " +  name2 .
    str4 = "Адрес " + adres2  .
 run rep/extitle.p (1).
/* ... конец создания заголовка. --- */

 /* PAGE stream OutStream. */
 FORM with frame sl .
 { rep/r-formh.i {&format-sl} {&dos_CW_2}}
/* по строкам документа-------------------------------------------------------------------------------------------- */

   run waitfram-show in this-procedure ( {&MyWaitMess} ) .
      { rep/order2.i {&format-sl} sl}

/* ---- Суммы прописью ------------------------------------------------------------------------------------------- */
run rep/wp-qnty.p ( Lines_counter, output PropisCount).
B-Sum-qnty = accum TOTAL b-qnty .
run rep/wp-qnty.p ( B-Sum-qnty, output PropisQnty).
b-sum = accum TOTAL b-stoim  .
if NOT PrintRubl then
    run rep/wp.p ( input p-mainmenu-handle, B-Sum , output PropisSum, output abbr).
else
    run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).

/* ... Подвал. --- */
 run on-same-page in this-procedure (input 23) .
 HIDE stream OutStream FRAME BottomFrame .
 PUT  STREAM OutStream
            "Итого по заказу :" Skip
              "а) количество порядковых номеров: " + string(Lines_Counter) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
              "б) общее количество единиц : " + string(B-Sum-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
              "в) на сумму : " + trim(string(B-Sum , "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr +
                            " (" + PropisSum + ")"  format "x(179)"  at 18 SKIP(1)
            "Расчет проверил "
            LineBuf format "X(25)"     AT 18 LineBuf format "X(25)"   AT 48 LineBuf format "X(50)"               AT 78 SKIP
            "должность" format "X(25)" AT 18 "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP(1)


            "Отобранный товар проверил контролер-упаковщик : "  LineBuf format "X(25)" AT 48 LineBuf format "X(50)"               AT 78 SKIP
                                                              "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP(1)

            "Товар выдал"  Skip
            LineBuf format "X(25)"                              AT 18 LineBuf format "X(25)"   AT 48 LineBuf format "X(50)"               AT 78 SKIP
            "должность" format "X(25)" AT 18 "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP(2)

            "Заказчик стоимость заказа оплатил" format "X(35)"  LineBuf   AT 48 format "X(25)" skip
                                                                "подпись заказчика" AT 48 format "X(25)" SKIP
            "Деньги в сумме " + trim(string(b-Sum, "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr +
                            " (" + PropisSum + ")"  format "x(179)"  SKIP(1)
            "получил"
            LineBuf format "X(25)"                              AT 18 LineBuf format "X(25)"   AT 48 LineBuf format "X(50)"               AT 78 SKIP
            "должность" format "X(25)"                          AT 18 "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP
            .
/* ... конец создания Подвал. --- */

output stream OutStream CLOSE .
output Stream  ForExcel close.

run waitfram-hide .

define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 0 .

run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  , 7
  ,output v-user-action
  ,output v-printed
  ) .

os-delete value( string( session:temp-directory ) +
                           {&DF_Name} + string( g#report-num ) + ".txt":U ) .

procedure calc-sl :
define input parameter tt as character no-undo .
if tt = "artic":U THEN DO:
End.
if tt = "scala":U THEN DO:
End.
end procedure.
PROCEDURE on-same-page :
/* позволяет перейти к следующей странице (если это необходимо)  */
  /* необходимо применять, перед выводом блок из нескольких строк, */
  /* который должен быть размещен в предлах одной страницы         */
  define input parameter p-line-number as integer  no-undo .

  if p-line-number > page-size( OutStream ) then do:
    /* запрошенное количество строк - превышает размер страницы */
    /* не переходим на следующую страницу */
    return .
  end.

  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.

end procedure. /* on-same-page */