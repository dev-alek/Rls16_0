block-level on error undo, throw.
/*

$Revision: 099a383cf864, 290, rls $
$Author: PGridchina $
$Date: Tue Dec 01 19:11:24 2015 +0300 $
$Workfile: orl-aktp.p $
$Archive: rep/orl-aktp.p $

Акт приемки-передачи нефтепродуктов

Автор: Демин Алексей Сергеевич
Дата создания: 09/09/05
Author: Alexey Demin
Creation date: 09/09/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 099a383cf864, 290, rls $":U .
define variable vss-author      as character no-undo initial "$Author: PGridchina $":U .
define variable vss-date        as character no-undo initial "$Date: Tue Dec 01 19:11:24 2015 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: orl-aktp.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/orl-aktp.p $":U .
define variable vss-description as character no-undo initial "Акт приемки-передачи нефтепродуктов":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ rep/r-c-sale.i }
{ str/trdcalib.i }
{ str/lib-trn.i  }

&scop left-margin 14
&scop right-margin 130
&scop max-width 119
&scop tab-stop1 54
&scop max-width-from-tab1 76
&scop tab-stop2 70
&scop max-width-from-tab2 60
&scop tab-stop3 90
&scop tab-stop4 110

/*----START----- Таблица --------------------------------*/
&GLOB P-S 15
&GLOB P-X 120        /*длина линии*/
&GLOB P-X0 117       /*длина внутренней линии = длина линии - 2*/
&GLOB P-X1 58        /*длина внутренней линии от начала 2-й колонки до начала 6-й*/
&GLOB P-X2 18        /*длина внутренней линии от начала 6-й колонки до конца*/
&GLOB P-E     {&P-S} + 118
&GLOB P-C2-S  {&P-S} + 25
&GLOB P-C3-S  {&P-S} + 41
&GLOB P-C4-S  {&P-S} + 52
&GLOB P-C5-S  {&P-S} + 68
&GLOB P-C6-S  {&P-S} + 84
&GLOB P-C7-S  {&P-S} + 99
/*----END----- Таблица --------------------------------*/



&scop extend-temp-string ~
  assign temp-position = center-field( {&left-margin}, {&right-margin}, length(temp-string) )~
         temp-string   = fill(" ", temp-position) + temp-string.


/*----START----- Блок описания переменных ---------------*/

define stream out-stream .

define variable v-operator      as character            no-undo.
define variable v-expl-name     as character            no-undo.
define variable v-store-man     as character            no-undo.
define variable v-main-boss     as character            no-undo.
define variable v-main-buh      as character            no-undo.

define variable temp-string   as character        no-undo.
define variable v-sum-string  as character        no-undo.
define variable temp-position as integer          no-undo.
define variable single-line   as character        no-undo.
define variable v-is-petrol   as logical init no  no-undo.
define variable v-is-pieces   as logical init no  no-undo.
define variable v-have-petrol as logical init no  no-undo.

define variable v-ship-org          like doc-line-attr.attr-value no-undo.
define variable v-autoent-obj-code  like doc-line-attr.attr-value no-undo.
define variable v-autoent-obj-type  like doc-line-attr.attr-value no-undo.
define variable v-dids              like doc-line-attr.attr-value no-undo.
define variable v-nids              like doc-line-attr.attr-value no-undo.
define variable v-attr-type         as character                  no-undo.
define variable v-car-num           like doc-line-attr.attr-value no-undo.
define variable v-car-vol           like doc-line-attr.attr-value no-undo.
define variable v-item-pour         like doc-line-attr.attr-value no-undo.
define variable v-tank-density      like doc-line-attr.attr-value no-undo.
define variable v-tank-temp         like doc-line-attr.attr-value no-undo.
define variable v-tank-vol          like doc-line-attr.attr-value no-undo.
define variable v-tank-water        like doc-line-attr.attr-value no-undo.
define variable v-tank-weight       like doc-line-attr.attr-value no-undo.
define variable v-time-pour         like doc-line-attr.attr-value no-undo.
define variable v-time-income       like doc-line-attr.attr-value no-undo.
define variable v-time-start        like doc-line-attr.attr-value no-undo.
define variable v-time-end          like doc-line-attr.attr-value no-undo.
define variable v-type-inp-vat      like doc-line-attr.attr-value no-undo.
define variable v-delta-mass        as decimal                    no-undo.
define variable v-delta-volume      as decimal                    no-undo.

define variable v-have-rvs-before   as logical init no  no-undo.
define variable v-have-rvs-after    as logical init no  no-undo.
define variable before_real-time    as integer          no-undo.
define variable after_real-time     as integer          no-undo.

define variable before_qnty         like ub.rvs-line.state-measure-qnty     no-undo.
define variable before_temperature  like ub.rvs-line.state-temperature      no-undo.
define variable before_density      like ub.rvs-line.state-density          no-undo.
define variable before_cli-qnty     like ub.rvs-line.state-measure-cli-qnty no-undo.
define variable after_qnty          like ub.rvs-line.state-measure-qnty     no-undo.
define variable after_temperature   like ub.rvs-line.state-temperature      no-undo.
define variable after_density       like ub.rvs-line.state-density          no-undo.
define variable after_cli-qnty      like ub.rvs-line.state-measure-cli-qnty no-undo.

define variable v-tank-vol-dec      like rvs-line.state-measure-qnty     no-undo.
define variable v-tank-temp-dec     like rvs-line.state-temperature      no-undo.
define variable v-tank-density-dec  like rvs-line.state-density          no-undo.
define variable v-tank-weight-dec   like rvs-line.state-measure-cli-qnty no-undo.
define variable v-tank-water-dec    like rvs-line.state-measure-qnty     no-undo.

define variable v-fact-qnty         as   decimal                  no-undo .
define variable v-price             as   decimal                  no-undo .
define variable v-sum-price         as   decimal                  no-undo .
define variable v-void              as   decimal                  no-undo .
define variable v-host-code         as   integer                  no-undo .
define variable v-fio               like doc-line-attr.attr-value no-undo .
define variable g#report-num        as   integer                  no-undo .
define variable g#quest-print       as   logical                  no-undo .
define variable g#log               as   logical                  no-undo .
define variable doc-line_1st-run    as   logical                  no-undo .

define buffer buf_trn-doc        for trn-doc.
define buffer buf_doc-line       for doc-line.
define buffer buf_goods          for goods.
define buffer buf_clients        for clients.
define buffer buf_clients_ship   for clients.
define buffer buf_doc-line-attr  for doc-line-attr.
define buffer buf_doc-attr       for doc-attr.
define buffer buf_rvs-doc_before  for ub.rvs-doc.
define buffer buf_rvs-doc_after   for ub.rvs-doc.
define buffer buf_rvs-line_before for rvs-line.
define buffer buf_rvs-line_after  for rvs-line.
define buffer buf_host_clients  for clients.
define buffer buf_obj_clients   for clients.
define buffer buf_shop          for shop.
define buffer buf_store         for store.
define buffer buf_firm          for firm.
define buffer buf_sysconf       for sysconf.

do
for buf_trn-doc
  , buf_doc-line
  , buf_goods
  , buf_clients
  , buf_clients_ship
  , buf_doc-line-attr
  , buf_rvs-doc_before
  , buf_rvs-line_before
  , buf_rvs-doc_after
  , buf_rvs-line_after
  , buf_host_clients
  , buf_obj_clients
  , buf_shop
  , buf_store
  , buf_firm
  , buf_sysconf
on error undo, return error
:
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
assign single-line = fill("-", {&max-width}).
/*----END----- Блок описания переменных ---------------*/


define variable varstfactpl     as character no-undo .
define variable varstfactpltype as character no-undo .
define variable pogresh         as decimal   no-undo initial 0 .

{ gbl/conf-rd.i "'stfactpl'" "''" "''" 0 "''" "''" "''" no varstfactpl varstfactpltype no-error }
assign
  varstfactpl = replace( varstfactpl,  "read-only;", "":U )
  varstfactpl = replace( varstfactpl, ";read-only",  "":U )
  varstfactpl = replace( varstfactpl,  "read-only",  "":U )
  varstfactpl = replace( varstfactpl,  "inv-set;", "":U )
  varstfactpl = replace( varstfactpl, ";inv-set",  "":U )
  varstfactpl = replace( varstfactpl,  "inv-set",  "":U )
  varstfactpl = replace( varstfactpl, ";",           "":U )
.
if num-entries( varstfactpl, ";" ) > 1 then do: assign varstfactpl = entry( 1, varstfactpl, ";" ). end.
assign pogresh     = ( if num-entries( varstfactpl, '=' ) = 2 then decimal( entry( 2, varstfactpl, '=' ) ) * 0.01 else 0 )
       varstfactpl = entry( 1, varstfactpl, "=" ).

if session:set-wait-state("compiler") then.
{ cmp/open-out.i stream out-stream " " {&CS_PS} }

find first buf_trn-doc no-lock
     where recid( buf_trn-doc ) = rec_id
.
find first buf_host_clients no-lock
     where buf_host_clients.obj-type = {&cmp}
       and buf_host_clients.obj-code = buf_trn-doc.host-code
.
find first buf_firm no-lock
     where buf_firm.firm-code = buf_host_clients.obj-code
.
{ gbl/hostcode.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    v-host-code
}
find first buf_sysconf no-lock
     where buf_sysconf.host-code = v-host-code
.
assign
    v-main-boss = buf_firm.director
    v-main-buh  = buf_sysconf.snr-accnt
.
find first buf_obj_clients no-lock
     where buf_obj_clients.obj-type = buf_trn-doc.obj-type
       and buf_obj_clients.obj-code = buf_trn-doc.obj-code
no-error.
case buf_obj_clients.obj-type :
    when {&shop}
    then do:
        find first buf_shop no-lock
             where buf_shop.obj-code = buf_obj_clients.obj-code
        .
        assign
            v-expl-name = buf_shop.director
            v-store-man = buf_shop.store-man
        .
    end.
    when {&stock}
    then do:
        find first buf_store no-lock
             where buf_store.obj-code = buf_obj_clients.obj-code
        .
        assign
            v-expl-name = buf_store.store-boss
            v-store-man = buf_store.store-man
        .
    end.
end case.

find first buf_clients no-lock      /* Оператор */
    where buf_clients.obj-type = {&prs}
      and buf_clients.obj-code = buf_trn-doc.wrkr
no-error.
if available buf_clients
then do:
    assign
        v-operator = buf_clients.obj-name
    .
end.
else do:
    assign
        v-operator = ""
    .
end.

find first buf_clients no-lock      /* Поставщик */
    where buf_clients.obj-type = buf_trn-doc.obj-type
      and buf_clients.obj-code = buf_trn-doc.obj-code
.
{ str/tdat-val.i
    buf_trn-doc.doc-code
    {&trdcattr-dids}
    v-dids
    v-attr-type
}
{ str/tdat-val.i
    buf_trn-doc.doc-code
    {&trdcattr-nids}
    v-nids
    v-attr-type
}
/*---START----- Для каждой линии документа печатаем отдельный лист ----*/
for each buf_doc-line no-lock
     where buf_doc-line.doc-code = buf_trn-doc.doc-code
:
    { rep/akt-topl.i init-attr}
    find first buf_goods no-lock
        where buf_goods.artic      = buf_doc-line.artic
          and buf_goods.prod-type  = buf_doc-line.prod-type
          and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    { str/is-petrl.i
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        v-is-petrol
        v-is-pieces
    }
    if v-is-petrol <> yes then next.

    assign                /*Если сюда дошли, значит хоть один топливный товар есть*/
        v-have-petrol = yes
    .
    for each buf_doc-line-attr no-lock
       where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
         and buf_doc-line-attr.gds-code = buf_goods.gds-code
    :
        case buf_doc-line-attr.attr-code:
          { rep/akt-topl.i when car-vol      }
          { rep/akt-topl.i when tank-density }
          { rep/akt-topl.i when tank-temp    }
          { rep/akt-topl.i when tank-vol     }
          { rep/akt-topl.i when tank-water   }
          { rep/akt-topl.i when tank-weight  }
          { rep/akt-topl.i when time-pour    }
          { rep/akt-topl.i when type-inp-vat }
        end case.
    end.

    for each buf_doc-attr no-lock where
             buf_doc-attr.doc-code = buf_trn-doc.doc-code:
      case buf_doc-attr.attr-code :
        { rep/akt-topl.i when-doc-attr trdcattr-autoent }
        { rep/akt-topl.i when-doc-attr trdcattr-car-num }
        { rep/akt-topl.i when-doc-attr trdcattr-time-income }
        { rep/akt-topl.i when-doc-attr trdcattr-ptb-item-pour }
        { rep/akt-topl.i when-doc-attr trdcattr-fio-driver }
      end case. /* buf_doc-attr.attr-code */
    end. /* for each buf_doc-attr */

    /*---START---- Переводим табличные значения в Decimal --------*/
          { rep/akt-topl.i dec tank-vol      }
          { rep/akt-topl.i dec tank-temp     }
          { rep/akt-topl.i dec tank-density  }
          { rep/akt-topl.i dec tank-weight   }
          { rep/akt-topl.i dec tank-water    }
    /*---END---- Переводим табличные значения в Decimal --------*/

    find first buf_clients_ship no-lock
        where buf_clients_ship.obj-type = v-autoent-obj-type
          and buf_clients_ship.obj-code = integer(v-autoent-obj-code)
    no-error.

    if available clients
    then assign
        v-ship-org = clients.obj-name
    .
    else assign
        v-ship-org = ""
    .
/*---START--------- Цены и суммы для строки документа ---------------------*/
    run r-c-sale in this-procedure (
                                    input buf_doc-line.doc-code
                                  , input buf_doc-line.artic
                                  , input buf_doc-line.prod-type
                                  , input buf_doc-line.prod-code
                                  , output v-fact-qnty    /*v-fact-qnty       */
                                  , output v-void         /*v-vat-pc          */
                                  , output v-void         /*v-slt-pc          */
                                  , output v-sum-price    /*v-sum-r-b         */
                                 ).
      assign
          v-price = ( if v-fact-qnty = 0 then 0 else v-sum-price / v-fact-qnty )
      .
/*---END----------- Цены и суммы для строки документа ---------------------*/

/*----START----------------- Печать: Шапка документа ------------------------*/

    { rep/akt-topl.i real-time before }
    { rep/akt-topl.i real-time after  }

    put stream out-stream unformatted
    skip (1)
        "А К Т"            format "X(5)"    at center-field( {&left-margin}, {&right-margin}, 5 )
        skip
        "приемки-передачи нефтепродуктов " + CAPS( trim( buf_host_clients.obj-name ) )
                            at center-field( {&left-margin}, {&right-margin}, 32 + length( trim( buf_host_clients.obj-name ) ) )
        skip "предпринимателю " + v-expl-name
                            at center-field( {&left-margin}, {&right-margin}, 16 + length( v-expl-name ) )
    .

/*    if buf_trn-doc.flag_ then  /*накладная закрыта по факту - выводим дату fact-date*/*/
/*    do:*/
      if buf_trn-doc.fact-date <> ?
      then do:
          assign
            temp-string = '" '  + string(day(buf_trn-doc.fact-date))
                          + ' " ' + entry(month(buf_trn-doc.fact-date), {&month-list-for-date})
                          + " " + string(year(buf_trn-doc.fact-date), "9999") + " г."
          .
          {&extend-temp-string}
      end.
      else assign
          temp-string = ""
      .
/*    end.*/
/*    else do:*/
/*      temp-string = fill(" ", 45 + {&left-margin}) + "Приходная накладная не закрыта".*/
/*    end.*/

    put stream out-stream
        skip
        temp-string format "X({&right-margin})"
        skip (2)
        space ({&left-margin}) "ТТН N "
        string(buf_trn-doc.doc-code) + " от " + string(buf_trn-doc.doc-date)
                                    format "X({&max-width-from-tab1})"         at {&tab-stop1}
        skip
        space ({&left-margin}) "Основание: накладная поставщика"
        string( "N " + v-nids + " от " + v-dids )
                                    format "X({&max-width-from-tab1})"         at {&tab-stop1}
        skip
        space ({&left-margin}) "Гос.N автоцистерны "
        v-car-num                       format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Объем по паспорту в литрах "
        v-car-vol                       format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) "Поставщик "
        buf_trn-doc.cli-name            format "X({&max-width-from-tab1})"     at {&tab-stop1}
        skip
        space ({&left-margin}) if not( buf_trn-doc.PS BEGinS "@") then buf_trn-doc.PS else "" format "X({&max-width-from-tab1})"
        skip
        space ({&left-margin}) "Нефтепродукт "
        buf_goods.gds-name              format "X({&max-width-from-tab1})"     at {&tab-stop1}
    .
    /*----END----- Шапка документа ------------------------*/

    /*----START----- Шапка таблицы --------------------------*/
    put stream out-stream
      skip (2)
        single-line        format "X({&max-width})"        at {&P-S}
      skip
        ":"         format "X(1)"           at {&P-S}
        ":"         format "X(1)"           at {&P-C2-S}
        "Нефтепродукт"  format "X(12)" at center-field( {&P-C2-S}, {&P-C6-S}, 12)
        ":"         format "X(1)"           at {&P-C6-S}
        ":"         format "X(1)"           at {&P-C7-S}
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        ":"         format "X(1)"           at {&P-C2-S}
        single-line        format "X({&P-X1})"
        ":"         format "X(1)"           at {&P-C6-S}
        "Цена"                              at center-field( {&P-C6-S}, {&P-C7-S}, 4)
        ":"         format "X(1)"           at {&P-C7-S}
        "Сумма"                             at center-field( {&P-C7-S}, {&P-E}, 5)
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        ":"         format "X(1)"           at {&P-C2-S}
        "Объем,"    format "X(6)"           at center-field( {&P-C2-S}, {&P-C3-S}, 6)
        ":"         format "X(1)"           at {&P-C3-S}
        "t,"        format "X(2)"           at center-field( {&P-C3-S}, {&P-C4-S}, 2)
        ":"         format "X(1)"           at {&P-C4-S}
        "Плотность," format "X(10)"         at center-field( {&P-C4-S}, {&P-C5-S}, 10)
        ":"         format "X(1)"           at {&P-C5-S}
        "Масса,"    format "X(6)"           at center-field( {&P-C5-S}, {&P-C6-S}, 6)
        ":"         format "X(1)"           at {&P-C6-S}
        "по объекту" format "X(10)"         at center-field( {&P-C6-S}, {&P-C7-S}, 10)
        ":"         format "X(1)"           at {&P-C7-S}
        "по объекту" format "X(10)"         at center-field( {&P-C7-S}, {&P-E}, 10)
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        ":"         format "X(1)"           at {&P-C2-S}
        "л"         format "X(1)"           at center-field( {&P-C2-S}, {&P-C3-S}, 1)
        ":"         format "X(1)"           at {&P-C3-S}
        "град.C"    format "X(6)"           at center-field( {&P-C3-S}, {&P-C4-S}, 6)
        ":"         format "X(1)"           at {&P-C4-S}
        "г/см.куб"  format "X(8)"           at center-field( {&P-C4-S}, {&P-C5-S}, 8)
        ":"         format "X(1)"           at {&P-C5-S}
        "кг"        format "X(2)"           at center-field( {&P-C5-S}, {&P-C6-S}, 2)
        ":"         format "X(1)"           at {&P-C6-S}
        "за л"      format "X(4)"           at center-field( {&P-C6-S}, {&P-C7-S}, 4)
        ":"         format "X(1)"           at {&P-C7-S}
        substitute( "(&1)", string( "{&abbr_rub}", "X(3)" ) )
                    format "X(5)"           at center-field( {&P-C7-S}, {&P-E}, 5)
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        single-line format "X({&P-X0})"
        ":"         format "X(1)"
    .
    /*----END----- Шапка таблицы --------------------------*/

    /*----START----- Таблица --------------------------------*/
    put stream out-stream
      skip
        ":"         format "X(1)"           at {&P-S}
        "По ТТН"    format "X(6)"           at {&P-S} + 2
        ":"         format "X(1)"           at {&P-C2-S}
        buf_doc-line.doc-qnty           format "zz,zz9.999"      at right-field( {&P-C3-S} - 1, 10)
        ":"         format "X(1)"           at {&P-C3-S}
        buf_doc-line.temperature        format "->>9.99"         at right-field( {&P-C4-S} - 1, 7)
        ":"         format "X(1)"           at {&P-C4-S}
        buf_doc-line.doc-density        format "9.9999999999"    at right-field( {&P-C5-S} - 1, 12)
        ":"         format "X(1)"           at {&P-C5-S}
        buf_doc-line.doc-qnty * buf_doc-line.doc-density
                                        format "zz,zzz,zz9.999" at right-field( {&P-C6-S}, 14)
        ":"         format "X(1)"           at {&P-C6-S}
        v-price     format "z,zzz,zz9.99"   at right-field( {&P-C7-S}, 12)
        ":"         format "X(1)"           at {&P-C7-S}
        v-sum-price format "z,zzz,zzz,zz9.99"  at right-field( {&P-E}, 16)
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        single-line format "X({&P-X0})"
        ":"         format "X(1)"
      skip
        ":"         format "X(1)"           at {&P-S}
        single-line format "X({&P-X0})"
        ":"         format "X(1)"
      skip
        ":"         format "X(1)"           at {&P-S}
        "По замеру в"    format "X(11)"     at {&P-S} + 2
        ":"         format "X(1)"           at {&P-C2-S}
        ":"         format "X(1)"           at {&P-C3-S}
        ":"         format "X(1)"           at {&P-C4-S}
        ":"         format "X(1)"           at {&P-C5-S}
        ":"         format "X(1)"           at {&P-C6-S}
        ":"         format "X(1)"           at {&P-C7-S}
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        "автоцистерне"    format "X(12)"    at {&P-S} + 2
        ":"         format "X(1)"           at {&P-C2-S}
    .
    if v-tank-vol-dec <> ?
    then put stream out-stream
        v-tank-vol-dec
                                    format "zz,zz9.999"    at right-field( {&P-C3-S} - 1, 10)
    .
    put stream out-stream
        ":"         format "X(1)"           at {&P-C3-S}
    .
    if v-tank-temp-dec <> ?
    then put stream out-stream
        v-tank-temp-dec
                                    format "->>9.99"           at right-field( {&P-C4-S} - 1, 7)
    .
    put stream out-stream
        ":"         format "X(1)"           at {&P-C4-S}
    .
    if v-tank-density-dec <> ? then
    put stream out-stream
        v-tank-density-dec
                                    format "9.9999999999"      at right-field( {&P-C5-S} - 1, 12)
    .
    put stream out-stream
        ":"         format "X(1)"           at {&P-C5-S}
    .
    if v-tank-weight-dec <> ?
    then put stream out-stream
        v-tank-weight-dec
                                    format "zz,zzz,zz9.999"  at right-field( {&P-C6-S}, 14)
    .
    put stream out-stream
        ":"         format "X(1)"           at {&P-C6-S}
        ":"         format "X(1)"           at {&P-C7-S}
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        single-line format "X({&P-X0})"
        ":"         format "X(1)".
    /* ---START----- Находим строки топливного документа до слива -------- */
    { rep/akt-topl.i rvs-line before }
    put stream out-stream
      skip
        ":"         format "X(1)"           at {&P-S}
        single-line format "X({&P-X0})"
        ":"         format "X(1)"
      skip
        ":"         format "X(1)"           at {&P-S}
        "По замеру в резервуаре"    format "X(22)"           at {&P-S} + 2
        ":"         format "X(1)"           at {&P-C2-S}
        ":"         format "X(1)"           at {&P-C3-S}
        ":"         format "X(1)"           at {&P-C4-S}
        ":"         format "X(1)"           at {&P-C5-S}
        ":"         format "X(1)"           at {&P-C6-S}
        ":"         format "X(1)"           at {&P-C7-S}
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        "ДО слива"  format "X(8)"           at {&P-S} + 2
        ":"         format "X(1)"           at {&P-C2-S}
    .
    { rep/akt-topl.i print-field buf_rvs-line_before.state-measure-qnty     "zz,zz9.999"      "{&P-C3-S}" 1 10 before }
    { rep/akt-topl.i print-field buf_rvs-line_before.state-temperature      "->>9.99"         "{&P-C4-S}" 1  7 before }
    { rep/akt-topl.i print-field buf_rvs-line_before.state-density          "9.9999999999"    "{&P-C5-S}" 1 12 before }
    { rep/akt-topl.i print-field buf_rvs-line_before.state-measure-cli-qnty "zz,zzz,zz9.999"  "{&P-C6-S}" 0 14 before }
/*  { rep/akt-topl.i print-field "buf_rvs-line_before.state-brutto-qnty - buf_rvs-line_before.state-measure-qnty" */
/*                                                                          "zzz,zzz,zz9.999" "{&P-E}"    2 15 before } */
    put stream out-stream
        ":"         format "X(1)"           at {&P-C7-S}
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        single-line format "X({&P-X0})"
        ":"         format "X(1)".
    { rep/akt-topl.i rvs-line-end before }
    /* ---END----- Находим строки топливного документа до слива -------- */

    /* ---START----- Находим строки топливного документа после слива -------- */
    { rep/akt-topl.i rvs-line after }
    put stream out-stream
      skip
        ":"         format "X(1)"           at {&P-S}
        "По замеру в резервуаре"    format "X(22)"           at {&P-S} + 2
        ":"         format "X(1)"           at {&P-C2-S}
        ":"         format "X(1)"           at {&P-C3-S}
        ":"         format "X(1)"           at {&P-C4-S}
        ":"         format "X(1)"           at {&P-C5-S}
        ":"         format "X(1)"           at {&P-C6-S}
        ":"         format "X(1)"           at {&P-C7-S}
        ":"         format "X(1)"           at {&P-E}
      skip
        ":"         format "X(1)"           at {&P-S}
        "ПОСЛЕ слива"  format "X(11)"       at {&P-S} + 2
        ":"         format "X(1)"           at {&P-C2-S}
    .
    { rep/akt-topl.i print-field buf_rvs-line_after.state-measure-qnty     "zz,zz9.999"     "{&P-C3-S}" 1 10 after }
    { rep/akt-topl.i print-field buf_rvs-line_after.state-temperature      "->>9.99"        "{&P-C4-S}" 1  7 after }
    { rep/akt-topl.i print-field buf_rvs-line_after.state-density          "9.9999999999"   "{&P-C5-S}" 1 12 after }
    { rep/akt-topl.i print-field buf_rvs-line_after.state-measure-cli-qnty "zz,zzz,zz9.999" "{&P-C6-S}" 0 14 after }
/*  { rep/akt-topl.i print-field "buf_rvs-line_after.state-brutto-qnty - buf_rvs-line_after.state-measure-qnty" */
/*                                                                         "zzz,zzz,zz9.999" "{&P-E}"   2 15 after } */
    put stream out-stream
        ":"         format "X(1)"           at {&P-C7-S}
        ":"         format "X(1)"           at {&P-E}
      skip
        single-line        format "X({&max-width})"        at {&P-S}
    .
    { rep/akt-topl.i rvs-line-end after }
    /* ---END----- Находим строки топливного документа до слива -------- */
    /*----END----- Таблица --------------------------------*/

    /*----START----- Итог документа -------------------------*/
    put stream out-stream
        skip (2)
        space ({&left-margin}) "Объем принятого нефтепродукта "
        buf_doc-line.fact-qnty                           format "zzz,zzz,zz9.999"    at right-field( {&tab-stop3}, 15)
        " литров"
        skip
        space ({&left-margin}) "Масса принятого нефтепродукта "
        buf_doc-line.fact-qnty * v-tank-density-dec    format "zzz,zzz,zz9.999"    at right-field( {&tab-stop3}, 15)
        " кг"
    .

    run rep/wp-rub.p ( input v-sum-price , output v-sum-string, output temp-string ) .

    put stream out-stream
      skip (1) space ({&left-margin})
        "ИТОГО по акту передано на сумму     "
         + CAPS( ( if trim( v-sum-string ) begins trim( temp-string ) then string( "0 " + v-sum-string ) else v-sum-string ) )
                                                        format "X(126)"
    .
    put stream out-stream
        skip (1) space({&left-margin})
            "От владельца : "
            "От агента : "                               at 80
            v-store-man                     format "X(20)"
        skip (1) space({&left-margin})
            "Руководитель предприятия:                                             / "
            string( v-main-boss  + " /" )   format "X(40)"
        skip (1) space({&left-margin})
            "Главный бухгалтер:                                                    / "
            string( v-main-buh  + " /" )    format "X(40)"
    .
    /*----END----- Итог документа -------------------------*/
    page stream out-stream.
end.
/*---END----- Для каждой линии документа печатаем отдельный лист ----*/

output stream out-stream close.

if v-have-petrol = yes     /*А если нет ни одного топливного товара - молча вывалиться*/
then do:
    { rep/q-print.i 4}
end.

end.