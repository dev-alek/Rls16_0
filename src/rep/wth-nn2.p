block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-nn2.p $
$Archive: rep/wth-nn2.p $

Форма НН-2-ДО

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
define variable vss-workfile    as character no-undo init "$Workfile: wth-nn2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/wth-nn2.p $":U .
define variable vss-description as character no-undo init "Форма НН-2-ДО.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ cmp/library.i  }
{ str/wthgds.i  }
{ str/wthcalib.i  }
{ gbl/prn-lib.i }

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle ( output g#report-num ).
run get-quest-print in p-mainmenu-handle ( output g#quest-print ).

&scoped-define left-margin 1
&scoped-define right-margin 133
&scoped-define max-width 133
&scoped-define tab-stop1 12
&scoped-define bottom-page-line-size 2
&scoped-define group-line-size 2
&scoped-define page-result-line-size 2

/*----S----- Таблица --------------------------------*/
&GLOB P-S 1
&GLOB P-X 132        /*длина линии*/
&GLOB P-X0 130       /*длина внутренней линии = длина линии - 2*/

&GLOB P-C2-S    {&P-S} + 20
&GLOB P-C3-S    {&P-S} + 70
&GLOB P-C4-S    {&P-S} + 78
&GLOB P-C5-S    {&P-S} + 95
&GLOB P-C6-S    {&P-S} + 112
&GLOB P-E       {&P-S} + 132

&GLOB C1     40
&GLOB C2     80
&GLOB C3     98
&GLOB C4    118
&GLOB C5    133
/*----E----- Таблица --------------------------------*/

    define shared variable sort-name    as logical          no-undo.
    define shared variable sort-gr      as logical          no-undo.

    define stream PrnLibStream .

    define variable v-line-counter  as integer      no-undo.
    define variable v-single-line   as character    no-undo.

    define variable v-cli-name      as character    no-undo.
    define variable v-obj-name      as character    no-undo.
    define variable v-host-name     as character    no-undo.

    define variable v-first-line    as logical      no-undo.

    define buffer buf_wth-doc   for wth-doc.
    define buffer buf_goods     for goods.
    define buffer buf_wth-parts for wth-parts.
    define buffer buf_clients   for clients.
    define buffer buf_wth-ser   for wth-ser.
    define buffer buf_wealth    for wealth.
    define buffer buf_sysconf   for sysconf.
    define buffer buf_firm      for firm.
    define buffer buf_shop      for shop.

    define variable talon-qnty as decimal   no-undo .
    define variable talon-sum as decimal   no-undo .
    define variable str-qnty  as character no-undo .
    define variable s1  as character no-undo .
    define variable s2  as character no-undo .

    find first buf_wth-doc no-lock where buf_wth-doc.doc-code = p-doc-code .

    if buf_wth-doc.doc-type <> {&income} and buf_wth-doc.doc-type <> {&expense} and buf_wth-doc.doc-type <> {&return} then return.

    find first buf_clients no-lock where buf_clients.obj-type = buf_wth-doc.obj-type and buf_clients.obj-code = buf_wth-doc.obj-code .
    assign  v-obj-name = buf_clients.obj-name .

    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = buf_wth-doc.host-code .
    assign  v-host-name = buf_clients.obj-name .

    find first buf_clients no-lock where buf_clients.obj-type = buf_wth-doc.cli-type and buf_clients.obj-code = buf_wth-doc.cli-code .
    if available buf_clients then  assign  v-cli-name = buf_clients.obj-name .
    else                           assign  v-cli-name = "" .

    define variable v-receiver  as character no-undo .
    define variable v-deliver   as character no-undo .
    define variable v-dover     as character no-undo .
    define variable v-reason    as character no-undo .
    define variable v-doc-code  as character no-undo .
    define variable v-doc-date  as character no-undo .
    define variable v-attr-type as character no-undo .
    { str/wthatval.i  buf_wth-doc.doc-code  {&wthcattr-proxy}     v-dover     v-attr-type }
    { str/wthatval.i  buf_wth-doc.doc-code  {&wthcattr-reason}    v-reason    v-attr-type }
    { str/wthatval.i  buf_wth-doc.doc-code  {&wthcattr-nsf}       v-doc-code  v-attr-type }
    if v-doc-code = ? or v-doc-code = "" then assign v-doc-code = buf_wth-doc.doc-code .
    { str/wthatval.i  buf_wth-doc.doc-code  {&wthcattr-dsf}       v-doc-date  v-attr-type }
    if v-doc-date = ? or v-doc-date = "" then assign v-doc-date = string(buf_wth-doc.doc-date,"99/99/9999") .

    find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = buf_wth-doc.receiver no-error .
    if available buf_clients then  assign  v-receiver = buf_clients.obj-name .
    else do:
      { str/wthatval.i  buf_wth-doc.doc-code  {&wthcattr-receiver}  v-receiver  v-attr-type }
    end.
    find first buf_clients no-lock where buf_clients.obj-type = {&prs} and buf_clients.obj-code = buf_wth-doc.deliver no-error .
    if available buf_clients then  assign  v-deliver = buf_clients.obj-name .
    else assign  v-deliver = "______________________" .

    define variable v-main-boss  as character     no-undo.
    define variable v-main-buh   as character     no-undo.

    if buf_wth-doc.obj-type <> {&shop} then do:
      find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = buf_wth-doc.host-code .
      find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code .
      assign v-main-boss = buf_firm.director .
      find first buf_sysconf no-lock where buf_sysconf.host-code = buf_wth-doc.host-code  .
      assign v-main-buh  = buf_sysconf.snr-accnt .
    end.
    else do:
      find first buf_shop no-lock where buf_shop.obj-code = buf_wth-doc.obj-code .
      assign
        v-main-boss = buf_shop.director
        v-main-buh  = entry(1,buf_shop.acct,"|")
      .
    end.

/*Отпуск разрешил - директор объекта*/
/*Главный бухгалтер - Объект\Доп.информация\Бухгалтер*/

    assign
        v-single-line       = fill( "-", 132 )
        v-line-counter      = 0
    .

    { cmp/open-out.i stream PrnLibStream " " {&CS_PS} }

    form header
        space({&P-S}) v-single-line format "X({&P-X})" skip    'Продолжение - на следующей странице' at 90 skip
        with frame BottomFrame width {&A4_CW0} page-bottom no-labels no-box .
    view stream PrnLibStream frame BottomFrame .

    { gbl/working.i }

    put stream PrnLibStream         "Форма НН-2-ДО"  at 90  if buf_wth-doc.doc-type = {&expense} then "" else " (возврат)"  skip
       space(1)  v-host-name  format "X(60)"
                "_________________________________________________________________" at 70 skip
                "| Вид операции | Склад |   Корреспондирующий счет   |     |     |" at 70 skip
                "|              |       |----------------------------|     |     |" at 70 skip
                "|              |       |номер субсчета|шифр аналити |     |     |" at 70 skip
                "|              |       |              |ческого счета|     |     |" at 70 skip
                "|______________|_______|______________|_____________|_____|_____|" at 70 skip
                "|              |       |              |             |     |     |" at 70 skip
                "|______________|_______|______________|_____________|_____|_____|" at 70 skip
        space( 50 ) "НАКЛАДНАЯ № "   v-doc-code   format "X(60)"  skip
    .
    if buf_wth-doc.doc-type = {&expense} then put stream PrnLibStream     space( 35 ) "НА ОТПУСК ТАЛОНОВ НА НЕФТЕПРОДУКТЫ (литровые)" skip .
    else  put stream PrnLibStream     space( 38 ) "НА ВОЗВРАТ ТАЛОНОВ НА НЕФТЕПРОДУКТЫ (литровые)" skip .

    put stream PrnLibStream     space( 55 ) v-doc-date  format "X(12)" skip
         " Основание " v-reason format "X(100)" skip
         if buf_wth-doc.doc-type = {&expense} then  " Кому " else " От кого "  format "X(9)" v-cli-name format "X(60)" " через кого " v-receiver  format "X(40)" skip
         " Фондодержатель " v-obj-name format "X(60)" " доверенность No. " v-dover format "X(40)" skip .

    run print-header in this-procedure .

    /* заполняем tt */
    run wthgds-calc-price-group ( input buf_wth-doc.doc-code ) .

    for each temp_wthgds_price-group :
      run print-line in this-procedure .
    end.

    run print-total-result in this-procedure .

    run rep/wp-rub.p ( talon-sum, output s1, output s2 ) .
    run rep/wp-qnty.p ( input talon-qnty , output str-qnty).

    put stream PrnLibStream   skip  space(1)
      string("Всего " + (if buf_wth-doc.doc-type = {&expense} then  "отпущено " else "возвращено ") + str-qnty + " талонов" )  format "X(130)"  skip
      space(1) string("на сумму " + s1 )  format "X(130)"  skip
    .
    if buf_wth-doc.doc-type = {&expense} then put stream PrnLibStream  skip(1) space({&tab-stop1})  string("Отпуск разрешил " + v-main-boss )  format "X(50)"  string("Главный бухгалтер " + v-main-buh )  format "X(50)" .
    else  put stream PrnLibStream  skip(1) space({&tab-stop1})                                      string("Возврат разрешил " + v-main-boss )   format "X(50)"  string("Главный бухгалтер " + v-main-buh )  format "X(50)" .

    run print-note in this-procedure .

    if line-counter( PrnLibStream ) + {&bottom-page-line-size} + {&page-result-line-size} > page-size( PrnLibStream ) then do:
      page stream PrnLibStream .
    end.

    if buf_wth-doc.doc-type = {&expense} then put stream PrnLibStream  skip (2)  space(35)  "РАСШИФРОВКА ОТПУЩЕННЫХ ТАЛОНОВ НА НЕФТЕПРОДУКТЫ ПО"   skip .
    else                                      put stream PrnLibStream  skip (2)  space(35)  "РАСШИФРОВКА ВОЗВРАЩЕННЫХ ТАЛОНОВ НА НЕФТЕПРОДУКТЫ ПО"   skip .
    put stream PrnLibStream       space(35)  "КУПЮРАМ, СЕРИЯМ И НОМЕРАМ (ЕДИНЫХ, РЫНОЧНОГО ФОНДА)"  skip .

    run print-header2 in this-procedure .

    for each buf_wth-parts no-lock where buf_wth-parts.out-code = buf_wth-doc.doc-code :
      run print-line2 in this-procedure .
    end.

    run print-total-result in this-procedure .

    run print-note in this-procedure .

    hide stream PrnLibStream frame BottomFrame .
    output stream PrnLibStream close.
    { gbl/stopwork.i }

    { rep/q-print.i 4}



procedure PrintTitul :
  do on error undo, return error return-value :
    if line-counter( PrnLibStream ) + {&bottom-page-line-size} < page-size( PrnLibStream ) then do:
      put stream PrnLibStream skip space({&P-S}) "|" v-single-line format "X({&P-X0})" "|" .
    end.
    page stream PrnLibStream .
    run print-header in this-procedure .
  end.
end procedure. /* PrintTitul */


/*==========================================================================*/
procedure print-header :
  do on error undo, return error:
    assign  v-first-line = yes .

    put stream PrnLibStream
    skip
    space({&P-S})       v-single-line   format "X({&P-X})"
    skip space({&P-S})  "|"
        "Номенклатурный №"      at center-field({&P-S} + 1, {&P-C2-S}, 17)
        "|"                     at {&P-C2-S}
        "Наименование нефтепродуктов"   at center-field({&P-C2-S}, {&P-C3-S}, 30)
        "|"                     at {&P-C3-S}
        "Ед.изм."               at center-field({&P-C3-S}, {&P-C4-S}, 7)
        "|"                     at {&P-C4-S}
        "Кол-во"                at center-field({&P-C4-S}, {&P-C5-S}, 6)
        "|"                     at {&P-C5-S}
        "Цена за ед."           at center-field({&P-C5-S}, {&P-C6-S}, 10)
        "|"                     at {&P-C6-S}
        "Сумма"                 at center-field({&P-C6-S}, {&P-E}, 11)
        "|"                     at {&P-E}
    skip space({&P-S})
        "|" v-single-line format "X({&P-X0})" "|"
    .
  end.
end procedure. /* print-header */

procedure print-header2 :
  do on error undo, return error:
    assign  v-first-line = yes .

    put stream PrnLibStream
    skip
    space({&P-S})       v-single-line   format "X({&P-X})"
    skip space({&P-S})  "|"
        "Наименование нефтепродуктов"      at center-field(2, {&C1}, 35)
        "|"                     at {&C1}
        "Купюры"                at center-field({&C1}, {&C2}, 8)
        "|"                     at {&C2}
        "Серия"                 at center-field({&C2}, {&C3}, 5)
        "|"                     at {&C3}
        "№ талона"              at center-field({&C3}, {&C4}, 8)
        "|"                     at {&C4}
        "Кол-во талонов"        at center-field({&C4}, {&C5}, 14)
        "|"                     at {&C5}
    skip space({&P-S})
        "|" v-single-line format "X({&P-X0})" "|"
    .
  end.
end procedure. /* print-header2 */



/*==========================================================================*/
procedure print-line :
    find first buf_goods no-lock where buf_goods.gds-code = temp_wthgds_price-group.gds-code .
    put stream PrnLibStream
            skip space({&P-S})  "|"
                buf_goods.artic               format "X(17)"
                "|"   at {&P-C2-S}
                buf_goods.gds-name            format "X(48)"
                "|"   at {&P-C3-S}
                buf_goods.unit-base           format "X(6)"
                "|"   at {&P-C4-S}
                temp_wthgds_price-group.qnty format "->>,>>>,>>>,>>9.<<<"
                "|"   at {&P-C5-S}
                temp_wthgds_price-group.price-rubl format "->>>>,>>>,>>9.99"
                "|"   at {&P-C6-S}
                temp_wthgds_price-group.sum-rubl format "->>>,>>>,>>>,>>9.99"
                "|"   at {&P-E}
        .

      assign
        v-line-counter      = v-line-counter    + 1
        talon-sum  = talon-sum  + temp_wthgds_price-group.sum-rubl
        talon-qnty = talon-qnty + temp_wthgds_price-group.fact-qnty
      .
      if line-counter( PrnLibStream ) + {&bottom-page-line-size} + {&page-result-line-size} > page-size( PrnLibStream ) then do:
        page stream PrnLibStream .
        run print-header in this-procedure .
      end.
end procedure. /* print-line */

procedure print-line2 :

    find first buf_goods   no-lock where buf_goods.gds-code   = buf_wth-parts.gds-code .
    find first buf_wth-ser no-lock where buf_wth-ser.ser-code = buf_wth-parts.ser-code .
    find first buf_wealth  no-lock where buf_wealth.wth-code  = buf_wth-parts.wth-code .

    define variable ss as character no-undo .
    if buf_wth-parts.fact-rangeFrom = buf_wth-parts.fact-rangeTo then assign ss = string(buf_wth-parts.fact-rangeFrom) .
    else assign ss = string(buf_wth-parts.fact-rangeFrom) + "-" + string(buf_wth-parts.fact-rangeTo).
    put stream PrnLibStream
            skip space({&P-S})  "|"
                buf_goods.gds-name            format "X(37)"
                "|"   at {&C1}
                buf_wealth.wth-name           format "X(37)"
                "|"   at {&C2}
                buf_wth-ser.series            format "X(17)"
                "|"   at {&C3}
                ss                            format "X(18)"
                "|"   at {&C4}
                buf_wth-parts.fact-qnty format "->>>>>,>>>,>>9"
                "|"   at {&C5}
        .

      assign v-line-counter      = v-line-counter    + 1  .
      if line-counter( PrnLibStream ) + {&bottom-page-line-size} + {&page-result-line-size} > page-size( PrnLibStream ) then do:
        page stream PrnLibStream .
        run print-header in this-procedure .
      end.
end procedure. /* print-line2 */







/*==========================================================================*/
procedure print-group-line :
  define input parameter p-grp-name   as character no-undo .

  if line-counter( PrnLibStream ) + {&bottom-page-line-size} + {&group-line-size} + 1 > page-size( PrnLibStream ) then do:
    page stream PrnLibStream.
    run print-header in this-procedure .
  end.
  if v-first-line <> yes then do:
    put stream PrnLibStream  skip space({&P-S}) "|" v-single-line format "X({&P-X0})" "|" .
  end.        /* p-print-type <> "no-line" */
  put stream PrnLibStream  skip space({&P-S}) "|   ***  Группа:  "  + p-grp-name format "X(110)" "|" at {&P-E} .
end procedure. /* print-group-line */


/*==========================================================================*/
procedure print-total-result :
  do on error undo, return error :
    put stream PrnLibStream  skip space({&P-S})  v-single-line format "X({&P-X})" .
  end.
end procedure. /* print-total-result */



/*==========================================================================*/
procedure print-note :
  do on error undo, return error :
    if buf_wth-doc.doc-type = {&expense} then put stream PrnLibStream  skip(1) space({&tab-stop1})  string("Отпустил " + v-deliver)   format "X(50)"  string("Получил " + v-receiver)  format "X(50)" .
    else  put stream PrnLibStream  skip(1) space({&tab-stop1})                                      string("Возвратил " + v-receiver)   format "X(50)"  string("Получил " + v-deliver)  format "X(50)" .
  end.
end procedure. /* print-total-result */