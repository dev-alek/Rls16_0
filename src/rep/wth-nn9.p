block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-nn9.p $
$Archive: rep/wth-nn9.p $

Форма НН-9-ДО

Автор: Демин Алексей Сергеевич
Дата создания: 07/18/07
Author: Alexey Demin
Creation date: 07/18/07

*/

define input parameter p-mainmenu-handle  as handle           no-undo.
define input parameter p-doc-code           as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-nn9.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wth-nn9.p $":U .
define variable vss-description as character no-undo init "Форма НН-9-ДО.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ cmp/library.i  }
define variable g#report-num    as integer      no-undo.
{ str/wthgds.i  }
{ gbl/prn-lib.i }
{ str/wthcalib.i  }

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
    define variable v-host-name     as character    no-undo.

    define variable v-first-line    as logical      no-undo.

    define buffer buf_wth-doc   for wth-doc.
    define buffer buf_goods     for goods.
    define buffer buf_wth-parts for wth-parts.
    define buffer buf_clients   for clients.
    define buffer buf_wth-ser   for wth-ser.
    define buffer buf_wealth    for wealth.

    define variable talon-qnty as decimal   no-undo .
    define variable talon-sum as decimal   no-undo .
    define variable str-qnty  as character no-undo .
    define variable s1  as character no-undo .
    define variable s2  as character no-undo .
    define variable v-operator  as character no-undo .
    define variable v-receiver  as character no-undo .
    define variable v-deliver   as character no-undo .
    define variable v-attr-type as character no-undo .

    find first buf_wth-doc no-lock where buf_wth-doc.doc-code = p-doc-code .

    find first buf_clients no-lock where buf_clients.obj-type = buf_wth-doc.obj-type and buf_clients.obj-code = buf_wth-doc.obj-code .
    assign  v-obj-name = string( buf_clients.obj-name )  .

    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = buf_wth-doc.host-code .
    assign  v-host-name = string( buf_clients.obj-name )  .

    find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = buf_wth-doc.receiver no-error .
    if available buf_clients then  assign  v-receiver = buf_clients.obj-name .
    else do:
      { str/wthatval.i  buf_wth-doc.doc-code  {&wthcattr-receiver}  v-receiver  v-attr-type }
    end.
    find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = buf_wth-doc.deliver no-error .
    if available buf_clients then  assign  v-deliver = buf_clients.obj-name .
    else assign  v-deliver =  "___________________________________________" .
    find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = buf_wth-doc.operator no-error .
    if available buf_clients then  assign  v-operator = buf_clients.obj-name .
    else assign  v-operator = "___________________________________________" .

    assign
        v-single-line       = fill( "-", 132 )
        v-line-counter      = 0
    .

    { cmp/open-out.i stream PrnLibStream " " {&CS_PS} }

    form header
        v-single-line format "X(120)" skip    'Продолжение - на следующей странице' at 90 skip
        with frame BottomFrame width {&A4_CW0} page-bottom no-labels no-box .
    view stream PrnLibStream frame BottomFrame .

    { gbl/working.i }

    /* заполняем tt */
    run wthgds-calc-price-group ( input buf_wth-doc.doc-code ) .

    for each temp_wthgds_price-group :
      assign
        v-line-counter      = v-line-counter    + 1
        talon-sum  = talon-sum  + temp_wthgds_price-group.sum-rubl
        talon-qnty = talon-qnty + temp_wthgds_price-group.fact-qnty
      .
    end.

    run rep/wp-rub.p ( talon-sum, output s1, output s2 ) .
    run rep/wp-qnty.p ( input talon-qnty , output str-qnty).

    put stream PrnLibStream         "Форма НН-9-ДО"  at 100  skip (2)
       space(10)  v-host-name  format "X(60)"      "УТВЕРЖДАЮ" at 90 skip (2)
       space(10)  v-obj-name   format "X(60)"     "___________________________________" at 80 skip
                                                  "             должность"              at 80 skip  (2)
                                                  "___________  ______________________" at 80 skip
                                                  "  подпись     расшифровка подписи"   at 80 skip  (2)
                                                  "'____' ___________________ 20 ____г" at 80 skip  (3)
       space( 60 ) "АКТ № "   buf_wth-doc.doc-code   format "X(14)"  skip
       space( 40 ) "уничтожения талонов на нефтепродукты от "  string(buf_wth-doc.doc-date,"99/99/9999") skip (2)
       space(10)   "Составлен комиссией из: представителей предприятия, назначенных приказом № ___ от ___________ в составе:"  skip (3)
       space(10)   "Председатель: "  v-operator format "x(50)"                       "______________________________________"  skip
       space(10)   "                                                                            (инициалы, фамилия)"           skip
       space(10)   "Члены комиссии: "                                                                                          skip
       space(10)   "              "  v-deliver  format "x(50)"                       "______________________________________"  skip
       space(10)   "                                                                            (инициалы, фамилия)"           skip (2)
       space(10)   "              "  v-receiver format "x(50)"                       "______________________________________"  skip
       space(10)   "                                                                            (инициалы, фамилия)"           skip (2)
       space(10)   string("На погашение талонов на нефтепродукты в количестве " + string(talon-qnty) + " (" + str-qnty +  ") штук")  format "X(120)"  skip
       space(10)   string("на сумму " + string(talon-sum,">>,>>>,>>>,>>9.99") + s2 + " (" + s1 + ")" )   format "X(120)"                       skip
       space(10)   "Пакеты/мешки, в которых хранились талоны были вскрыты, наличие талонов в них проверено, после чего  талоны" skip
       space(10)   "пересчитаны и сожжены"   skip
       space(10)   "Подписи:"                                                                                                  skip (2)
       space(10)   "Председатель: " v-operator format "x(30)"   "        ___________        ________________________________"  skip
       space(10)   "                                                      (подпись)               (инициалы, фамилия)"         skip (2)
       space(10)   "Члены комиссии:"                                                                                     skip
       space(10)   "              " v-deliver  format "x(30)"   "        ___________        ________________________________"  skip
       space(10)   "                                                      (подпись)               (инициалы, фамилия)"         skip (2)
       space(10)   "              " v-receiver format "x(30)"   "        ___________        ________________________________"  skip
       space(10)   "                                                      (подпись)               (инициалы, фамилия)"         skip
    .

    hide stream PrnLibStream frame BottomFrame .
    output stream PrnLibStream close.
    { gbl/stopwork.i }

    { rep/q-print.i 4}

