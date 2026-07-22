block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-26.p $
$Archive: cus/torg-26.p $

Печать формы заказа

Автор: Чернова Светлана Александровна
Дата создания: 01/21/02
Author: Svetlana Chernova
Creation date: 01/21/02

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-26.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/torg-26.p $":U .
define variable vss-description as character no-undo init "Формы печати заказа ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new   }
{ rep/r-cliprp.i def }
{ str/out-vatp.i def }
{ gbl/waitfram.i     }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter rec_id         as recid.

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .

{ gbl/getcntxt.i get }

define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }


find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

run get-report-num in parParentProc ( output g#report-num ).
run get-gds-engl in parParentProc ( output g#gds-engl ) .

&SCOP f-l Word-Sum,Total-Word,RedLine
{ gbl/std-func.i {&f-l} }


&glob format-sl "X(136)"


DEFINE  SHARED VARIABLE Sort-gr AS LOGICAL
     LABEL "Сортировать по группам товаров"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

DEFINE Shared VARIABLE print-graft AS LOGICAL
     LABEL "Отладочная печать"
     VIEW-AS TOGGLE-BOX
     size 42.25 by 0.75 NO-UNDO.

def stream OutStream.
define variable    NAme1   as character no-undo .
define variable    Adres1 as character no-undo .
define variable    NAme2   as character no-undo .
define variable    Adres2  as character no-undo .


define variable PrintScale      as   logical     no-undo.
define variable CostPrice      as   logical     no-undo.
define buffer This_Object for  ub.clients .
define buffer gds-prt-1 for  ub.gds-prt .
define buffer bar-code-1 for ub.bar-code .

define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.

define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.

define variable     tdoc-date     like ub.ord-doc.doc-date no-undo.
define variable     tdoc-code     like ub.ord-doc.doc-code no-undo.

define variable  Control_sUM       as  dec no-undo.
define variable  Control_Qnty      as  dec no-undo.
define variable  PgQnty            as  dec no-undo.
define variable  PgSum             as  dec no-undo.
define variable  PgQnty-b          as  dec no-undo.
define variable  PgSum-b           as  dec no-undo.
define variable  SQnty             as  dec no-undo.
define variable  SSum              as  dec no-undo.
define variable  SQnty-b           as  dec no-undo.
define variable  SSum-b            as  dec no-undo.
define variable  PropisQnty        as  char no-undo.
define variable  PropisSum         as  char no-undo.
define variable  PropisQnty-b      as  char no-undo.
define variable  PropisSum-b       as  char no-undo.
define variable B-Sum1             as decimal format ">>>>>>>>>>9.99" no-undo .
define variable B-Sum              as decimal no-undo .
define variable B-Sum-qnty         as decimal no-undo .

define variable B-adress like ub.firm.addres1 no-undo .
define variable B-phone  like ub.firm.phone no-undo .

define variable  Propiscount       as  char no-undo.
define variable  PropiscountP      as  char no-undo.
define variable  abbr              as  char no-undo.

define variable tt    as int no-undo.

define variable sym1 as char  init ":"   no-undo.
define variable sym2 as char  init ":"   no-undo.
define variable sym3 as char  init ":"   no-undo.
define variable sym4 as char  init ":"   no-undo.
define variable sym5 as char  init ":"   no-undo.
define variable sym6 as char  init ":"   no-undo.
define variable sym7 as char  init ":"   no-undo.
define variable sym8 as char  init ":"   no-undo.
define variable sym9 as char  init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.
define variable sym11 as char init ":"   no-undo.
define variable sym12 as char init ":"   no-undo.
define variable sym13 as char init ":"   no-undo.
define variable sym14 as char init ":"   no-undo.

define variable tb-code       as char    no-undo.
define variable Price         as decimal no-undo.
define variable UBL           as decimal no-undo .
define variable b-qnty        as decimal no-undo.
define variable b-stoim       as character no-undo .
define variable b-price       as character no-undo .
define variable B-service     as decimal no-undo.
define variable B-ship        as decimal no-undo.
define variable OKEI          as char    no-undo.
define variable ProdName      as char    no-undo.
define variable pp as character no-undo .


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
        ub.units.unit-name COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-qnty COLUMN-LABEL "Количество ! ! ! ! " format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-PRICE COLUMN-LABEL "Цена           ! ! ! ! " format "x(14)" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        B-stoim COLUMN-LABEL "Сумма ! ! ! ! " format "x(15)" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "Заказ N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 90 format "X(19)"
        string( " Лист " + string( PAGE-NUMBER(OutStream) , ">>9") ) format "X(13)" SKIP
        UndLine format {&format-sl} AT 1
        with width {&A4_CW0} down stream-io use-text NO-BOX.

FIND ub.ord-doc WHERE recid(ub.ord-doc) = rec_id NO-LOCK .
assign
    tdoc-date = (if ub.ord-doc.status_ <> {&fact} then ub.ord-doc.doc-date else ub.ord-doc.fact-date)
    tdoc-code = ub.ord-doc.doc-code .

if session:set-wait-state("compiler") then.
{ cmp/open-out.i STREAM OutStream " " {&CS_PS} }

assign
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
if ub.ord-doc.exch-code = 0 then
    assign
        PrintRubl = true
        pp = "{&abbr_rub}"
    .
else do:
   FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = ub.ord-doc.exch-code.
   assign
        PrintRubl = false
        pp = ub.currency.curr-abbr
        .
        end.

.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .


FIND This_Object  WHERE This_Object.obj-type = v-cntxt-obj-type
                    AND This_Object.obj-code = v-cntxt-obj-code NO-LOCK.

FIND ub.clients  WHERE ub.clients.obj-type = {&cmp}
                AND ub.clients.obj-code = ub.ord-doc.host-code NO-LOCK.

Case ub.ord-doc.cli-type :
    when  {&cmp} then do :
        FIND ub.firm  WHERE ub.firm.firm-code = ub.ord-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.firm.addres1
          b-phone  = ub.firm.phone .
        end.

    when  {&prs} then do :
        FIND ub.person  WHERE ub.person.psn-code = ub.ord-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.person.address
          b-phone  = ub.person.phone1 .
        end.

    when  {&shop} then do :
        FIND ub.shop  WHERE ub.shop.obj-code = ub.ord-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.shop.addres1
          b-phone  = ub.shop.phone .
        end.

    when  {&stock} then do :
        FIND ub.store  WHERE ub.store.obj-code = ub.ord-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.store.addres1
          b-phone  = ub.store.phone .
        end.
 End case.

 IF ub.ord-doc.doc-type = {&income} Then
  Assign
   NAme1   = "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
   Adres1 = t-addres + " " + t-phone
   NAme2   = ub.ord-doc.cli-name
   Adres2  = b-adress + '  ' + b-phone .
   Else
  Assign
   NAme2   = "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
   Adres2 = t-addres + " " + t-phone
   NAme1   = ub.ord-doc.cli-name
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
    space(0) "" format "X(26)" AT 53 + 38                               "| " AT 42 + 76 ub.ord-doc.doc-date
                                                                           format "99/99/9999"        "|" AT 60 + 76 skip
    space(0) "" format "X(29)" AT 50 + 38                               "| " AT 42 + 76
                            (if ub.ord-doc.status_ <> {&fact} then tdoc-date else ?) format "99/99/9999" "|" AT 60 + 76 skip
    space(0) "Вид операции" format "X(12)" AT 67 + 38                   "| " AT 42 + 76 "  " format "X(16)"    "|" AT 60 + 76 skip

                                                                     space(5) Line format  "X(19)" AT 42 + 76 skip(2)
                                       space(79) Line format "X(33)" skip
    space(56) string( "З А К А З ") format "x(10)"
                                      " | " at 79
                                        ( string( tdoc-code , "X(16)" ) + " | "
                                        + string( tdoc-date , "99/99/9999" )
                                    + " | "  + (if ub.ord-doc.status_ <> {&fact} then string( "(" + CAPS(ub.ord-doc.status_) + ")" ) else ""))
                                    + " " + entry(1, ub.ord-doc.cli-out-doc, {&delim-par})
                                           format "X(116)" skip
                                         space(79) Line format "X(33)" skip
    space(0) "Заказчик " name2  format "X(130)" skip(1)
    space(0) "Адрес " adres2 format "X(40)"  skip(1)
    space(0) "Заказ принял "
                UndLine format "X(25)" AT 25 UndLine format "X(50)" at 60 SKIP
                  "должность" format "X(25)" AT 25 "фамилия,имя,отчество" format "X(50)" AT 60 SKIP(1)
    "Заказ передал отборщику " UndLine format "X(25)" AT 25 UndLine format "X(50)" at 60 SKIP
    "должность" format "X(25)" AT 25 "фамилия,имя,отчество" format "X(50)"  AT 60 SKIP(1)
    space(0) "Подготовить и доставить на дом к "  String(ub.ord-doc.ship-time,"hh:mm")
                                                                String(ub.ord-doc.ship-date , "99/99/9999")
                                                                format "X(193)"  SKIP(2)
    .

/* ... конец создания заголовка. --- */

 /* PAGE stream OutStream. */
 FORM with frame sl .
 { rep/r-formh.i {&format-sl} {&dos_CW_2}}
/* по строкам документа-------------------------------------------------------------------------------------------- */

   run waitfram-show in this-procedure( {&MyWaitMess} ) .
      { cus/torg-26.i {&format-sl} sl}

/* ---- Суммы прописью ------------------------------------------------------------------------------------------- */
run rep/wp-qnty.p ( Lines_counter, output PropisCount).
run rep/wp-qnty.p ( B-Sum-qnty, output PropisQnty).




if NOT PrintRubl then
    ASSIGN
    PropisSum = Total-Word( B-Sum, ub.currency.curr-abbr, ub.currency.part-abbr )
    abbr = pp
    .
else
    run rep/wp-rub.p ( B-Sum , output PropisSum, output abbr).

/* ... Подвал. --- */
 run on-same-page in this-procedure (input 23) .
 HIDE stream OutStream FRAME BottomFrame .
 PUT  STREAM OutStream
            "Итого по заказу :" Skip
              "а) количество порядковых номеров: " + string(Lines_Counter) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
              "б) общее количество единиц : " + string(B-Sum-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
              if B-Sum = ? then "" else
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
            "Деньги в сумме " +
            ( if B-Sum = ? then " " else
            trim(string(b-Sum, "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + PropisSum + ")"
            )         format "x(179)"  SKIP(1)
            "получил"
            LineBuf format "X(25)"                              AT 18 LineBuf format "X(25)"   AT 48 LineBuf format "X(50)"               AT 78 SKIP
            "должность" format "X(25)"                          AT 18 "подпись" format "X(25)" AT 48 "расшифровка подписи" format "X(50)" AT 78 SKIP
            .
/* ... конец создания Подвал. --- */

output stream OutStream CLOSE .
run waitfram-hide in this-procedure  .
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable DisabledOptions as integer   no-undo .
DisabledOptions = 0 .

run gbl/prnfilen.w
  (input  ""
  ,input  DisabledOptions
  ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
  ,input  7
  ,output v-user-action
  ,output v-printed
  ) .

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