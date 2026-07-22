block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-pret.p $
$Archive: rep/r-pret.p $

Форма Претензия на возврат поставщику

Автор: Демин Алексей Сергеевич
Дата создания: 07/18/07
Author: Alexey Demin
Creation date: 07/18/07

*/

define input parameter p-mainmenu-handle  as handle         no-undo.
define input parameter rec_id             as recid          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-pret.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-pret.p $":U .
define variable vss-description as character no-undo init "Претензия".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i     }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ str/trdcalib.i    }
{ gbl/prn-lib.i }

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle ( output g#report-num ).
run get-quest-print in p-mainmenu-handle ( output g#quest-print ).

    define stream PrnLibStream .

    define variable v-line-counter  as integer      no-undo.
    define variable v-single-line   as character    no-undo.

    define variable v-obj-name      as character    no-undo.
    define variable v-cli-name      as character    no-undo.
    define variable v-host-name     as character    no-undo.

    define variable v-first-line    as logical      no-undo.

    define buffer buf_trn-doc   for trn-doc.
    define buffer buf1_trn-doc  for trn-doc.
    define buffer buf_clients   for clients.
    define buffer buf_doc-line  for doc-line.
    define buffer buf_parts for parts.

    define variable v-qnty as decimal   no-undo .
    define variable v-sum as decimal   no-undo .
    define variable str-qnty  as character no-undo .
    define variable s1  as character no-undo .
    define variable s2  as character no-undo .
    define variable str  as character no-undo .

    find first buf_trn-doc no-lock where recid(buf_trn-doc) = rec_id .

    find first buf_clients no-lock where buf_clients.obj-type = buf_trn-doc.obj-type and buf_clients.obj-code = buf_trn-doc.obj-code .
    assign  v-obj-name = buf_clients.obj-name .

    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = buf_trn-doc.host-code .
    assign  v-host-name = buf_clients.obj-name .

    find first buf_clients no-lock where buf_clients.obj-type = buf_trn-doc.cli-type and buf_clients.obj-code = buf_trn-doc.cli-code .
    assign  v-cli-name = buf_clients.obj-name .

    assign
        v-single-line       = fill( "-", 132 )
        v-line-counter      = 0
    .

    { cmp/open-out.i stream PrnLibStream " " {&CS_PS} }
    { gbl/working.i }

    for each buf_doc-line no-lock where buf_doc-line.doc-code  = buf_trn-doc.doc-code :
      assign
        v-line-counter      = v-line-counter    + 1
        v-qnty = v-qnty + buf_doc-line.fact-qnty
      .
    end.
    assign v-sum = buf_trn-doc.tot-rubl .

    run rep/wp-rub.p ( v-sum, output s1, output s2 ) .
    run rep/wp-qnty.p ( input v-qnty , output str-qnty ).

    assign str = "по накладной № "  . /* надо проверить, все ли партии одного прихода */
    define variable v-num as character no-undo .
    for each buf_parts no-lock where buf_parts.out-code = buf_trn-doc.doc-code :
      if v-num = "" then assign v-num = buf_parts.in-code .
      else do:
        if v-num <> buf_parts.in-code then do:
          assign v-num = "" .
          leave .
        end.
      end.
    end.
    if v-num <> "" then do:
      find first buf1_trn-doc no-lock where buf1_trn-doc.doc-code = v-num no-error .
      if available buf1_trn-doc then do:
        assign str = str + buf1_trn-doc.doc-code + " от " + string(buf1_trn-doc.doc-date,"99/99/9999") .
      end.
    end.

/*    define variable v-attr-value  as character no-undo .*/
/*    define variable v-attr-type   as character no-undo .*/
/*    { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }*/
/*    assign str = str + v-attr-value .*/
/*    { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }*/
/*    assign str = str + " от " + v-attr-value .*/

    put stream PrnLibStream         "ПРЕТЕНЗИЯ"  at 60  skip (2)
       space(10)  "<______>  _______________ 20_____ г."      v-cli-name format "X(60)" at 70 skip (2)
       space(10)  string(v-host-name + " уведомляет Вас о ненадлежащем качестве товаров, поставленных Вашей организацией")  format "X(120)"   skip
       space(10)  str  format "X(120)"       skip
       space(10)  "При приемке выявлены следующие недостатки товаров ________________________________________________________________" skip
       space(10)  "                                                               (нарушена упаковка товара, ненадлежащее" skip
       space(10)  "__________________________________________________________________________________________________________________" skip
       space(10)  "качество товара, истек срок реализации товара и т.д.)" skip (2)
       space(10)  "В соответствии с условиями договора поставки " v-host-name format "X(60)" skip
       space(10)  "возвращает товар в количестве "   string( string(v-qnty) + " (" + str-qnty + ") штук" )  format "X(120)"  skip
       space(10)  string("на сумму " + string(v-sum,">>,>>>,>>>,>>>.99") + s2 + " (" + s1 + ")" )   format "X(120)"                       skip (2)
       space(10)  "Уполномоченный представитель" skip
       space(10)  v-host-name   format "X(60)"    "___________  ______________________" at 80 skip
                                                  "  подпись     расшифровка подписи"   at 80 skip  (2)
                                                  "            Место печати, штампа"    at 90 skip  (2)
       space(10)  "Претензия получена:"           "___________  ______________________" at 80 skip
                                                  "  подпись     расшифровка подписи"   at 80 skip  (2)
    .
/* две претензии на листе */
    put stream PrnLibStream         "ПРЕТЕНЗИЯ"  at 60  skip (2)
       space(10)  "<______>  _______________ 20_____ г."      v-cli-name format "X(60)" at 70 skip (2)
       space(10)  string(v-host-name + " уведомляет Вас о ненадлежащем качестве товаров, поставленных Вашей организацией")  format "X(120)"   skip
       space(10)  str  format "X(120)"       skip
       space(10)  "При приемке выявлены следующие недостатки товаров ________________________________________________________________" skip
       space(10)  "                                                               (нарушена упаковка товара, ненадлежащее" skip
       space(10)  "__________________________________________________________________________________________________________________" skip
       space(10)  "качество товара, истек срок реализации товара и т.д.)" skip (2)
       space(10)  "В соответствии с условиями договора поставки " v-host-name format "X(60)" skip
       space(10)  "возвращает товар в количестве "   string( string(v-qnty) + " (" + str-qnty + ") штук" )  format "X(120)"  skip
       space(10)  string("на сумму " + string(v-sum,">>,>>>,>>>,>>>.99") + s2 + " (" + s1 + ")" )   format "X(120)"                       skip (2)
       space(10)  "Уполномоченный представитель" skip
       space(10)  v-host-name   format "X(60)"    "___________  ______________________" at 80 skip
                                                  "  подпись     расшифровка подписи"   at 80 skip  (2)
                                                  "            Место печати, штампа"    at 90 skip  (2)
       space(10)  "Претензия получена:"           "___________  ______________________" at 80 skip
                                                  "  подпись     расшифровка подписи"   at 80 skip  (2)
    .

    hide stream PrnLibStream frame BottomFrame .
    output stream PrnLibStream close.
    { gbl/stopwork.i }

    { rep/q-print.i 4}