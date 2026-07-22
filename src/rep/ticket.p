block-level on error undo, throw.
/*

$Revision: 487c9fe350a2, 3360, rls $
$Author: EShklyar $
$Date: 2023/05/19 13:37:11 $
$Workfile: ticket.p $
$Archive: rep/ticket.p $

Тело печати ценников (этикеток). Печать одного ценника (этикетки).

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/

define parameter buffer buf-par_goods for ub.goods.
define parameter buffer buf-par_bar-code       for ub.bar-code.
define parameter buffer buf-par_scales-gds     for ub.scales-gds.
define input parameter p-obj-type      like ub.clients.obj-type no-undo .
define input parameter p-obj-code      like ub.clients.obj-code no-undo .
define input parameter Action          as character no-undo .
define input parameter rootnode_code   like ub.gds-prt.node-code no-undo .
define input parameter TickOnw         as logical no-undo .
define input parameter TickOnN         as logical no-undo .
define input parameter QntyType        as character no-undo .
define input parameter PriceType       as character no-undo .
define input parameter scaleprice      as decimal no-undo init 0.
define input parameter nakl-qnty like ub.gds-dtl.fact-qnty no-undo.
define input parameter list-qnty like ub.gds-dtl.fact-qnty no-undo.
define input parameter pr-doc-rubl like ub.price-list.price-sale no-undo.
define input parameter pr-doc-rb like ub.price-list.price-sale no-undo.
define input parameter pr-doc-rubl-old like ub.price-list.price-sale no-undo.
define input parameter pr-doc-rb-old like ub.price-list.price-sale no-undo.
define input parameter v-fact-order like ub.trn-doc.fact-order     no-undo.
define input parameter ListProdBc       as character no-undo .
define input parameter curr-rate        as decimal no-undo .
define input parameter TickPS           as character no-undo .
define input parameter dflt-cd          as character no-undo .
define input parameter how-pcnt-kat     as character no-undo . /*обычная катег сикдка или по СТПЛ*/
define input-output parameter b-count   as integer no-undo .
define input parameter p-part-code      as character no-undo .
define input parameter p-doc-code       as character no-undo .
define input parameter p-promo-code     as character no-undo .
define input parameter p-ActionId       as int64     no-undo .
define input parameter p-db-num as integer no-undo .

/*
message
'bar-code'         buf-par_bar-code.b-code skip skip
'p-obj-type        '   p-obj-type      skip
'p-obj-code        '   p-obj-code      skip
'Action            '   Action          skip
'rootnode_code     '   rootnode_code    skip
'TickOnw           '   TickOnw           skip
'TickOnN           '   TickOnN           skip
'QntyType          '   QntyType          skip
'PriceType         '   PriceType          skip
'scaleprice        '   scaleprice         skip
'nakl-qnty         '   nakl-qnty       skip
'list-qnty         '   list-qnty        skip
'pr-doc-rubl       '   pr-doc-rubl      skip
'pr-doc-rb         '   pr-doc-rb        skip
'pr-doc-rubl-old   '   pr-doc-rubl-old   skip
'pr-doc-rb-old     '   pr-doc-rb-old     skip
'v-fact-order      '   v-fact-order      skip
'ListProdBc        '   ListProdBc        skip
'curr-rate         '   curr-rate         skip
'TickPS            '   TickPS            view-as alert-box information .

*/


define variable vss-revision    as character no-undo init "$Revision: 487c9fe350a2, 3360, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:11 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ticket.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/ticket.p $":U .
define variable vss-description as character no-undo init "Тело печати ценников (этикеток). Печать одного ценника (этикетки).".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/bc-gnrt.i " " bc }
{ str/bc-gnrt.i " " pl }
{ ref/gds-attr.i }
{ ref/gdsoattr.i }
{ str/alt-calc.i "func" }
{ str/dr-katp.i  }
{ str/mpl-auto.i }
{ str/doc-code.i } /*function get-doc-code-int64 returns int64*/
{ str/trdcalib.i }
{ gbl/nutro.i    }

/* наименование признака (шкалы)  */
DEFINE VARIABLE gds-prt_f-name like ub.gds-prt.f-name no-undo .
/* Полное название признака товара(за исключением корневого узла)  */
DEFINE VARIABLE gds-prt_node-name like ub.gds-prt.node-name no-undo .
/* наименование страны изготовителя  */
DEFINE VARIABLE country_name like ub.country.short-name no-undo .
/* наименование производителя  */
DEFINE VARIABLE prod_name like ub.clients.obj-name no-undo .
DEFINE VARIABLE bar_code as character no-undo .
DEFINE VARIABLE varattr-value as character no-undo .
DEFINE VARIABLE varattr-type as character no-undo .
DEFINE VARIABLE gds-qnty like ub.gds-dtl.fact-qnty no-undo.
DEFINE VARIABLE price like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price as character no-undo.
DEFINE VARIABLE price-cd  like ub.price-list.price-sale no-undo.
DEFINE VARIABLE price-old like ub.price-list.price-prev no-undo.
DEFINE VARIABLE str-price-old as character no-undo.
DEFINE VARIABLE price-alt like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price-alt as character no-undo.
DEFINE VARIABLE price-alt-one like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price-alt-one as character no-undo.
DEFINE VARIABLE price-alt-old like ub.price-list.price-prev no-undo.
DEFINE VARIABLE str-price-alt-old as character no-undo.
DEFINE VARIABLE price-rb like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price-rb as character no-undo.
DEFINE VARIABLE price-rb-old like ub.price-list.price-prev no-undo.
DEFINE VARIABLE str-price-rb-old as character no-undo.
DEFINE VARIABLE price-alt-rb like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price-alt-rb as character no-undo.
DEFINE VARIABLE price-alt-rb-old like ub.price-list.price-prev no-undo.
DEFINE VARIABLE str-price-alt-rb-old as character no-undo.
DEFINE VARIABLE rt-b-code           like ub.bar-code.b-code     no-undo .
DEFINE VARIABLE rt-price-list-recid as   recid                  no-undo.
DEFINE VARIABLE rt-cli-base-rate    like ub.bar-code.cli-base-rate no-undo.
DEFINE VARIABLE v-price-list-recid  as   recid                  no-undo.
DEFINE VARIABLE v-cli-base-rate     like ub.bar-code.cli-base-rate no-undo.
define variable v-base-code like ub.sysconf.base-code no-undo .

DEFINE buffer OurObj for ub.clients.
DEFINE buffer OurHost for ub.clients.
define buffer buf_price-list for ub.price-list.
define buffer b-root_price-list for ub.price-list.
define buffer buf_trn-doc for ub.trn-doc .

define shared Stream OutStream.

define variable v-sys-key      as character no-undo . /* для чтения параметра конфигурации */
define variable par-type     as character no-undo . /* тип параметра конфигурации */

define variable v-rb-is-base as logical no-undo .

define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.

define variable v-mrtr-code as character no-undo .

define variable v-ticket-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-ticket-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-ticket-host-code     like ub.sysconf.host-code  no-undo.
define variable v-ticket-today         as date                 no-undo.

define variable v-dflt-cd as character no-undo .
define variable l-prod-bc-pgweight as logical no-undo .

{ gbl/currsysk.i
  v-sys-key
  no-error
}

find ub.gds-grp where ub.gds-grp.node-code = buf-par_goods.grp-code no-lock.

find ub.gds-prt where ub.gds-prt.node-code = buf-par_bar-code.node-code no-lock.
if ub.gds-prt.node-code <> rootnode_code then
    assign
        gds-prt_node-name = ub.gds-prt.node-name
        gds-prt_f-name = ub.gds-prt.f-name
        .
else
    assign
        gds-prt_node-name = ""
        gds-prt_f-name = ""
        .

/* Ищем информацию о стране происхождения */
find first ub.country no-lock
  where ub.country.alpha1 = buf-par_goods.alpha1
  no-error.
if available ub.country then do:
  assign
    country_name = ub.country.short-name
  .
end.
else do:
  assign
    country_name = ""
  .
end.

/* Ищем информацию о производителе */
find first ub.clients no-lock
  where ub.clients.obj-type = buf-par_goods.prod-type
    and ub.clients.obj-code = buf-par_goods.prod-code
  .
assign
  prod_name = ub.clients.obj-name
.

if available buf-par_scales-gds then do:
  find first ub.scales-gds no-lock
    where rowid( ub.scales-gds ) = rowid( buf-par_scales-gds )
    .
  release buf-par_scales-gds.
end.
else do:
  if TickOnW = true then do:
/* Попытка найти первые попавшиеся весы на текущем объекте*/
    find first ub.scales-gds no-lock
      where ub.scales-gds.b-code   = buf-par_bar-code.b-code
        and ub.scales-gds.obj-type = p-obj-type
        and ub.scales-gds.obj-code = p-obj-code
      no-error.
  end.
end.


/* создаем список доп. бар-кодов и формируем основной бар-код */
if available ub.scales-gds then do:
  assign
      bar_code = ""
      ListProdBc = (if Action <> "PROD-BC"
                    and not (action = "LIST-bb"
                    and listprodbc <> '')
                    then "":U else ListProdBc)
      .
  FIND OurObj WHERE OurObj.obj-type = ub.scales-gds.obj-type
                AND OurObj.obj-code = ub.scales-gds.obj-code NO-LOCK.
  varattr-value = "":U.
  run gdsoattr-value in this-procedure(
                                        input {&attr-scales-code-o}
                                        ,input buf-par_bar-code.gds-code
                                        ,input OurObj.obj-type
                                        ,input OurObj.obj-code
                                        ,output varattr-value
                                        ,output varattr-type
                                        ) no-error.
  if varattr-value = "":U then do:
    message "Товар ~"" buf-par_goods.gds-name "~" (арт.: " buf-par_goods.artic " произв.:" buf-par_goods.prod-type " " buf-par_goods.prod-code ") " SKIP
            "весовой, но не имеет весового кода." SKIP
            "Ценник не может быть распечатан !"
            view-as alert-box INFORMATION TITLE "".
    NEXT.
  end.
end.
else do:
  FIND ub.units WHERE ub.units.unit-name = buf-par_bar-code.unit-cli NO-LOCK.
  if lookup({&weight}, ub.units.type) > 0
    and NOT TickOnW
  then do:
    message "Товар ~"" buf-par_goods.gds-name "~" (арт.: " buf-par_goods.artic " произв.:" buf-par_goods.prod-type " " buf-par_goods.prod-code ") "
                    "весовой." SKIP
                    "Ценник не может быть распечатан ! Воспользуйтесь справочником весов."
                    view-as alert-box INFORMATION TITLE "".
    NEXT.
  end.

  RUN gen-bc( input ( if v-sys-key = "Trg" then integer( buf-par_goods.artic ) else buf-par_bar-code.b-code ), output bar_code ).

  FIND OurObj WHERE OurObj.obj-type = p-obj-type
                AND OurObj.obj-code = p-obj-code
              NO-LOCK.
  if action <> "PROD-BC":U
  and not (action = "LIST-bb"
  and listprodbc <> '')
  then do:
    assign ListProdBc = "":U .
    _prod-bc:
    FOR EACH ub.prod-bc WHERE ub.prod-bc.b-code = buf-par_bar-code.b-code
                      AND ub.prod-bc.bc-on = TRUE
                    NO-LOCK :
      if lookup({&pieces}, units.type) > 0 then do:
        l-prod-bc-pgweight = yes.
        { gbl/prodbcat.i
          ub.prod-bc
          "'pgweight=request':u"
          l-prod-bc-pgweight
          no-error
        }
        if l-prod-bc-pgweight then do:
          next _prod-bc.
        end.
      end.
        assign ListProdBc = ListProdBc + prod-bc.b-str + ",":U.
    END.
    assign
        ListProdBc = SUBSTRING( ListProdBc, 1, 200 )
        ListProdBc = RIGHT-TRIM( ListProdBc, ",":U )
        .
  end.
end.

/* поиск фирмы */
CASE OurObj.obj-type:
    WHEN {&stock} THEN
        do:
            FIND ub.store WHERE ub.store.obj-code = OurObj.obj-code NO-LOCK.
            FIND OurHost WHERE OurHost.obj-type = {&cmp}
                           AND OurHost.obj-code = ub.store.host-code
                         NO-LOCK.
           { gbl/basecode.i ub.store.host-code v-base-code }
        end.
    WHEN {&shop} THEN
        do:
            FIND ub.shop WHERE ub.shop.obj-code = OurObj.obj-code NO-LOCK.
            FIND OurHost WHERE OurHost.obj-type = {&cmp}
                                               AND OurHost.obj-code = ub.shop.host-code NO-LOCK.
            { gbl/basecode.i ub.shop.host-code v-base-code }
        end.
END CASE.

/* поиск количества */
CASE QntyType:
    WHEN "один" THEN
        assign gds-qnty = 1.
    WHEN "остаток" THEN
        do:
          assign gds-qnty = 0.
          FIND ub.prt-obj WHERE ub.prt-obj.obj-type  = OurObj.obj-type
                         AND ub.prt-obj.obj-code  = OurObj.obj-code
                         AND ub.prt-obj.artic     = buf-par_goods.artic
                         AND ub.prt-obj.prod-type = buf-par_goods.prod-type
                         AND ub.prt-obj.prod-code = buf-par_goods.prod-code
                         AND ub.prt-obj.prt-code  = buf-par_bar-code.node-code
                       NO-LOCK NO-ERROR.
          if available ub.prt-obj then
              assign gds-qnty = ub.prt-obj.fact-qnty.
        end.
    WHEN "список" THEN
        assign gds-qnty = list-qnty.
    WHEN "документ" THEN
        assign gds-qnty = nakl-qnty.
END CASE.

if gds-qnty <= 0 then
    NEXT.
/* поиск цены */
assign
    price = 0
    price-old = 0
    price-alt = 0
    price-alt-old = 0
    price-rb = 0
    price-rb-old = 0
    price-alt-rb = 0
    price-alt-rb-old = 0
    .
if PriceType <> "doc" and PriceType <> "doc-pr" then do:
  assign v-fact-order = 0.
end.

run prc-base-code( input buf-par_bar-code.b-code, output rt-b-code ).
/* ищем переоценку со спец. ценами основной единицы измерения ПРИЗНАКА */
{ gbl/bcodepls.i
  OurObj.obj-type
  OurObj.obj-code
  rt-b-code
  0
  v-fact-order
  rt-price-list-recid
  rt-cli-base-rate
  no-error
}
if rt-price-list-recid = ? then do:
  { gbl/gdsbcode.i buf-par_goods.gds-code ? rt-b-code no-error}
  /* ищем переоценку с ценой основной единицы измерения ТОВАРА */
  { gbl/bcodepls.i
    OurObj.obj-type
    OurObj.obj-code
    rt-b-code
    0
    v-fact-order
    rt-price-list-recid
    rt-cli-base-rate
    no-error
  }
end.
/* ищем переоценку со спец ценой на запрашиваемую идиницу измерения ПРИЗНАКА */
{ gbl/bcodepls.i
  OurObj.obj-type
  OurObj.obj-code
  buf-par_bar-code.b-code
  0
  v-fact-order
  v-price-list-recid
  v-cli-base-rate
  no-error
}

{ gbl/rbisbase.i
  v-rb-is-base
}

if PriceType = "doc" then do:
  assign
    price = pr-doc-rubl * ScalePrice
    price-rb = pr-doc-rb * ScalePrice
    price-old = pr-doc-rubl-old * ScalePrice
    price-rb-old = pr-doc-rb-old * ScalePrice
    .
  if v-price-list-recid <> ? then do:
    find buf_price-list where recid( buf_price-list ) = v-price-list-recid no-lock.
    assign
      price-alt-one    = round( pr-doc-rubl * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      price-alt        = round( buf-par_bar-code.cli-base-rate * pr-doc-rubl * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      price-alt-rb     = round( buf-par_bar-code.cli-base-rate * pr-doc-rb * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      price-alt-old    = round( buf-par_bar-code.cli-base-rate * pr-doc-rubl-old * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      price-alt-rb-old = round( buf-par_bar-code.cli-base-rate * pr-doc-rb-old * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      .
  end.
end.
else do:
  if v-price-list-recid = ? and rt-price-list-recid = ? then do:
    if not TickOnN then do:
      NEXT.
    end.
  end.
  else do:
    if rt-price-list-recid <> ? then do:
      find b-root_price-list where recid( b-root_price-list ) = rt-price-list-recid no-lock.
      assign
        price = b-root_price-list.price-sale * ScalePrice
        price-rb = price
      .
      { gbl/bcodeprc.i
        b-root_price-list.obj-type
        b-root_price-list.obj-code
        b-root_price-list.b-code
        0
        b-root_price-list.fact-order
        cur-dn
        cur-pr
        cur-rt
        cur-ex
        no-error }
      assign
        price-old = cur-pr * ScalePrice
        price-rb-old = price-old
      .

    end.
    if v-price-list-recid <> ? then do:
      find buf_price-list where recid( buf_price-list ) = v-price-list-recid no-lock.
      assign
        price-alt-one = buf_price-list.price-sale * ScalePrice / (if buf_price-list.b-code = buf-par_bar-code.b-code then buf-par_bar-code.cli-base-rate else 1 )
        price-alt     = buf_price-list.price-sale * ScalePrice * (if buf_price-list.b-code <> buf-par_bar-code.b-code then buf-par_bar-code.cli-base-rate else 1 )
        price-alt-rb  = price-alt
      .
      { gbl/bcodeprc.i
        buf_price-list.obj-type
        buf_price-list.obj-code
        buf_price-list.b-code
        0
        buf_price-list.fact-order
        cur-dn
        cur-pr
        cur-rt
        cur-ex
        no-error }
      assign
        price-alt-old = cur-pr
                        * (if buf_price-list.b-code <> buf-par_bar-code.b-code then buf-par_bar-code.cli-base-rate else 1 )
                        * ScalePrice
        price-alt-rb-old = price-alt-old
        .
    end.
    if v-rb-is-base = true
      and v-base-code <> 0
    then do:
      assign
        price         = price         * curr-rate
        price-old     = price-old     * curr-rate
        price-alt-one = price-alt-one * curr-rate
        price-alt     = price-alt     * curr-rate
        price-alt-old = price-alt-old * curr-rate
      .
    end.
  end.
end.

{ rep/rub-cop.i price         str-price         "{&abbr_rub}" "{&abbr_kop}" }
{ rep/rub-cop.i price-old     str-price-old     "{&abbr_rub}" "{&abbr_kop}" }
{ rep/rub-cop.i price-alt-one str-price-alt-one "{&abbr_rub}" "{&abbr_kop}" }
{ rep/rub-cop.i price-alt     str-price-alt     "{&abbr_rub}" "{&abbr_kop}" }
{ rep/rub-cop.i price-alt-old str-price-alt-old "{&abbr_rub}" "{&abbr_kop}" }

assign
  str-price-rb = trim( string( price-rb, ">>>>>>>>>>>>9.99" ) )
  str-price-rb-old = trim( string( price-rb-old, ">>>>>>>>>>>>9.99" ) )
  str-price-alt-rb = trim( string( price-alt-rb, ">>>>>>>>>>>>9.99" ) )
  str-price-alt-rb-old = trim( string( price-alt-rb-old, ">>>>>>>>>>>>9.99" ) )
  .

{ gbl/hostcode.i OurObj.obj-type OurObj.obj-code v-ticket-host-code }
{ gbl/pftxvalg.i    buf-par_goods.gds-code
                {&vat-tax-code}
                ?
                v-ticket-host-code
                OurObj.obj-type
                OurObj.obj-code
                v-ticket-vat-pc
no-error }
{ gbl/pftxvalg.i    buf-par_goods.gds-code
                {&slt-tax-code}
                ?
                v-ticket-host-code
                OurObj.obj-type
                OurObj.obj-code
                v-ticket-slt-pc
no-error }

{ gbl/curobjdt.i OurObj.obj-type OurObj.obj-code v-ticket-today }

define variable v-bc-check-price  as character no-undo .
define variable v-doc-num         as character no-undo .
define variable v-price-sale      as decimal   no-undo .
define variable v-road-tax        as decimal   no-undo .
define variable v-excise          as decimal   no-undo .

{ gbl/bcodeprc.i
  p-obj-type
  p-obj-code
  buf-par_bar-code.b-code
  0
  0
  v-doc-num
  v-price-sale
  v-road-tax
  v-excise
}
if v-price-sale <> ?
then do:
  assign
    v-bc-check-price = substitute('&1/&2', buf-par_bar-code.b-code, v-price-sale)
  .
end.
else do:
  assign
    v-bc-check-price = ""
  .
end.

assign
  ListProdBc = replace( ListProdBc, "|":U, "/":U )
.

define variable v-rt-bar_code          as character no-undo .
define variable price-rt               as decimal   no-undo .
define variable str-price-rt           as character no-undo .
define variable str-price-novat-rt     as character no-undo .
define variable v-first-pbc-rt         as character no-undo .
define variable v-rt-alt-bar_code      as character no-undo .
define variable v-rt-alt_unit-cli      as character no-undo .
define variable price-alt-rt           as decimal   no-undo .
define variable str-price-alt-rt       as character no-undo .
define variable str-price-alt-novat-rt as character no-undo .
define variable v-first-pbc-alt-rt     as character no-undo .

define buffer buf-alt-rt_bar-code for ub.bar-code .
define buffer buf-rt_bar-code     for ub.bar-code .
define buffer buf_prod-bc         for ub.prod-bc .

/* ищем для любых заданных бар-кодов цену для основного собственного кода */
if rt-price-list-recid <> ? then do:
  find first buf_prod-bc no-lock
    where buf_prod-bc.b-code = rt-b-code
      and buf_prod-bc.bc-on  = true
    no-error .
  find b-root_price-list no-lock
    where recid( b-root_price-list ) = rt-price-list-recid
  .
  assign
    price-rt           = b-root_price-list.price-sale * ScalePrice
    str-price-rt       = trim( string( price-rt, ">>>>>>>>>>>>9.99":U ) )
    str-price-novat-rt = trim( string( price-rt * 100 / ( 100 + v-ticket-vat-pc ), ">>>>>>>>>>>>9.99":U ) )
    v-first-pbc-rt     = (if available buf_prod-bc then buf_prod-bc.b-str else "":U )
  .
  run gen-bc in this-procedure
    ( input rt-b-code
     ,output v-rt-bar_code
    ).

end.

find first buf-rt_bar-code no-lock
  where buf-rt_bar-code.b-code = rt-b-code
  .

/* Тупой алгоритм по просьбе казахов поиска бар-кода на доп. единицу измерения и его цену */
if buf-par_goods.qnty-cart <> 1
  and buf-par_goods.qnty-cart <> 0
  and buf-par_goods.qnty-cart <> ?
then do:
  find first buf-alt-rt_bar-code no-lock
    where buf-alt-rt_bar-code.gds-code      = buf-par_goods.gds-code
      and buf-alt-rt_bar-code.node-code     = buf-rt_bar-code.node-code
      and buf-alt-rt_bar-code.cli-base-rate = buf-par_goods.qnty-cart
    no-error .
  if available buf-alt-rt_bar-code then do:
    find first buf_prod-bc no-lock
      where buf_prod-bc.b-code = buf-alt-rt_bar-code.b-code
        and buf_prod-bc.bc-on  = true
      no-error .
    { gbl/bcodeprc.i
      p-obj-type
      p-obj-code
      buf-alt-rt_bar-code.b-code
      0
      0
      v-doc-num
      v-price-sale
      v-road-tax
      v-excise
    }
    assign
      price-alt-rt           = v-price-sale * ScalePrice
      str-price-alt-rt       = trim( string( price-alt-rt, ">>>>>>>>>>>>9.99":U ) )
      str-price-alt-novat-rt = trim( string( price-alt-rt * 100 / ( 100 + v-ticket-vat-pc ), ">>>>>>>>>>>>9.99":U ) )
      v-first-pbc-alt-rt     = (if available buf_prod-bc then buf_prod-bc.b-str else "":U )
      v-rt-alt_unit-cli      = buf-alt-rt_bar-code.unit-cli
    .
    run gen-bc in this-procedure
      ( input buf-alt-rt_bar-code.b-code
      ,output v-rt-alt-bar_code
      ).
  end.
end.

/* определение даты последней поставки для поля 72 */
define buffer buf-t_doc-line for ub.doc-line.
define buffer buf-t_trn-doc for ub.trn-doc.
define buffer buf-t_price-list for ub.price-list.
define buffer buf-t_price-doc for ub.price-doc.

define variable v-last-doc-date as date      no-undo .

assign
  v-last-doc-date = ?
.
find last buf-t_doc-line no-lock
  where buf-t_doc-line.obj-type     = p-obj-type
    and buf-t_doc-line.obj-code     = p-obj-code
    and buf-t_doc-line.prod-type    = buf-par_goods.prod-type
    and buf-t_doc-line.prod-code    = buf-par_goods.prod-code
    and buf-t_doc-line.artic        = buf-par_goods.artic
    and buf-t_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
    and buf-t_doc-line.status_      = {&fact}
  use-index dt-fo
  no-error.
if available buf-t_doc-line then do:
  find first buf-t_trn-doc no-lock
    where buf-t_trn-doc.doc-code = buf-t_doc-line.doc-code
  .
  if v-last-doc-date = ?
     or ( v-last-doc-date <> ?
          and buf-t_trn-doc.fact-date > v-last-doc-date
        )
  then do:
    assign
      v-last-doc-date = buf-t_trn-doc.fact-date
    .
  end.
end.

find last buf-t_price-list no-lock
  where buf-t_price-list.obj-type   = p-obj-type
    and buf-t_price-list.obj-code   = p-obj-code
    and buf-t_price-list.b-code     = rt-b-code
    and buf-t_price-list.price-type = ""
  use-index fact-close
  no-error.

if available buf-t_price-list then do:
  find first buf-t_price-doc no-lock
    where buf-t_price-doc.doc-num = buf-t_price-list.doc-num
  .
  if v-last-doc-date = ?
     or ( v-last-doc-date <> ?
          and buf-t_price-doc.fact-date > v-last-doc-date
        )
  then do:
    assign
      v-last-doc-date = buf-t_price-doc.fact-date
    .
  end.
end.

if v-last-doc-date = ? then do:
  assign
    v-last-doc-date = v-ticket-today
  .
end.

/* ищем цену без первой попавшейся скидки */

price-cd = price.
run dr-katp in this-procedure
  ( input buf-par_goods.gds-code
   ,input buf-par_bar-code.b-code
   ,input p-obj-type
   ,input p-obj-code
   ,input dflt-cd
   ,input price
   ,input how-pcnt-kat
   ,input (if v-fact-order = 0 then ? else v-fact-order)
   ,output price-cd
  ) no-error.
if error-status:error then do:

end.

define variable v-calories      as decimal   no-undo .
define variable v-protein       as decimal   no-undo .
define variable v-carbohydrate  as decimal   no-undo .
define variable v-fat           as decimal   no-undo .

run nutro_get-nutrition-info
  ( input  buf-par_goods.artic
  , input  buf-par_goods.prod-type
  , input  buf-par_goods.prod-code
  , input  p-obj-type
  , input  p-obj-code
  , output v-calories
  , output v-protein
  , output v-carbohydrate
  , output v-fat
  ) .


/*ищем номер последней приходной накладной*/
define variable v-last-pri-doc as character no-undo .
define buffer buf_parts for ub.parts .
define variable v-cash-parts as logical no-undo .

find first gds-obj no-lock
     where gds-obj.artic     = buf-par_goods.artic
       and gds-obj.prod-type = buf-par_goods.prod-type
       and gds-obj.prod-code = buf-par_goods.prod-code
       and gds-obj.obj-code  = p-obj-code
       and gds-obj.obj-type  = p-obj-type no-error.
if available gds-obj then assign v-cash-parts = gds-obj.cash-parts .

assign
  v-last-pri-doc = ""
.
if v-cash-parts then do :
 for each buf-t_doc-line no-lock
    where buf-t_doc-line.obj-type     = p-obj-type
      and buf-t_doc-line.obj-code     = p-obj-code
      and buf-t_doc-line.prod-type    = buf-par_goods.prod-type
      and buf-t_doc-line.prod-code    = buf-par_goods.prod-code
      and buf-t_doc-line.artic        = buf-par_goods.artic
      and (buf-t_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
      or buf-t_doc-line.ext-doc-type = {&TDEDT_Pri_Perem})
      and buf-t_doc-line.status_      = {&fact}
      by buf-t_doc-line.fact-order descending
      :
     if buf-par_bar-code.part-code <> "" then do :
       find first buf_parts no-lock
           where buf_parts.part-code = buf-par_bar-code.part-code
             and buf_parts.artic = buf-par_goods.artic
             and buf_parts.prod-type = buf-par_goods.prod-type
             and buf_parts.prod-code = buf-par_goods.prod-code
             and buf_parts.obj-code = p-obj-code
             and buf_parts.obj-type = p-obj-type
             and buf_parts.out-code = buf-t_doc-line.doc-code
             no-error.
       if available buf_parts then do :
       v-last-pri-doc = buf_parts.out-code.
       leave.
       end.
     end.
     else do :
       find first buf_parts no-lock
            where buf_parts.artic = buf-par_goods.artic
              and buf_parts.prod-type = buf-par_goods.prod-type
              and buf_parts.prod-code = buf-par_goods.prod-code
              and buf_parts.obj-code = p-obj-code
              and buf_parts.obj-type = p-obj-type
              and buf_parts.out-code = buf-t_doc-line.doc-code
              no-error.
        if available buf_parts then do :
          v-last-pri-doc = buf_parts.out-code.
          leave.
        end.
     end.
 end.
end.
else do:
  for last buf-t_doc-line no-lock
    where buf-t_doc-line.obj-type     = p-obj-type
      and buf-t_doc-line.obj-code     = p-obj-code
      and buf-t_doc-line.prod-type    = buf-par_goods.prod-type
      and buf-t_doc-line.prod-code    = buf-par_goods.prod-code
      and buf-t_doc-line.artic        = buf-par_goods.artic
      and (buf-t_doc-line.ext-doc-type = {&TDEDT_Pri_Vnesh}
      or  buf-t_doc-line.ext-doc-type = {&TDEDT_Pri_Perem})
      and buf-t_doc-line.status_      = {&fact}
    by buf-t_doc-line.fact-order descending
    :
    v-last-pri-doc = buf-t_doc-line.doc-code.
  end.
end.
define variable v-doc-date         as character initial "":U no-undo .
define variable v-short-doc-code   as character no-undo .
define variable v-ser_on_pack      as character no-undo .
define variable v-ser_on_pack-type as character no-undo .

/* ищем документ по которому происходит печать */
if p-doc-code <> "":U then do:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if available buf_trn-doc then do:
    assign
      v-doc-date       = string( buf_trn-doc.fact-date, "99/99/9999" )
      v-short-doc-code = string( get-doc-code-int64( p-doc-code ) )
    .
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-ser_on_pack}
      v-ser_on_pack
      v-ser_on_pack-type
    }
  end.
end.

/*Промоакции*/
define variable v-promo-name      as character no-undo .
define variable v-type-sale-promo as character no-undo . /*тип скидки*/
define variable v-sale-promo      as character   no-undo . /*размер скидки*/
define variable v-promo-price     as decimal   no-undo . /*цена со скидкой*/

if p-ActionId <> 0 and p-ActionId <> ? then 
do:
   find first ub.PromoAction no-lock where ub.PromoAction.id = p-ActionId and
      ub.PromoAction.db-num = p-db-num no-error .
   if available (ub.PromoAction) then 
   do:
      v-promo-name = ub.PromoAction.nameAction .
      find first ub.PromoGoods no-lock where ub.PromoGoods.db-num = ub.PromoAction.db-num and
/*         ub.PromoGoods.type = ub.PromoAction.methodCalc and*/
         ub.PromoGoods.idAction = ub.PromoAction.id and
         ub.PromoGoods.gds-code = buf-par_goods.gds-code 
         no-error .
         find first ub.PromoCriterion no-lock where ub.PromoCriterion.db-num = ub.PromoAction.db-num and
              ub.PromoCriterion.idAction = ub.PromoAction.id no-error .
      case ub.PromoAction.methodCalc:
         /*абсолютная скидка*/
         when 2 then 
            do:
               v-type-sale-promo = " руб." .
               if available (ub.PromoCriterion) then 
               do:
                  v-sale-promo = string(ub.PromoCriterion.discont) + v-type-sale-promo .
                  v-promo-price = price - ub.PromoCriterion.discont .
               end.
            end.
         /*процентная скидка*/
         when 1 then 
            do:
               v-type-sale-promo = "%" .
               if available (ub.PromoCriterion) then 
               do:
                  v-sale-promo = string(ub.PromoCriterion.discont) + v-type-sale-promo .
                  v-promo-price = price - price * (ub.PromoCriterion.discont / 100) .
               end.
            end.
         /*фиксированная скидка*/
         when 5 then 
            do:
               v-type-sale-promo = " руб." .
               if available (ub.PromoGoods) then 
               do:
                  v-sale-promo = string(ub.PromoGoods.price) + v-type-sale-promo .
                  v-promo-price = ub.PromoGoods.price .
               end.
            end.         
      end case.
   end.
end.

PUT STREAM OutStream UNFORMATTED
/*N */ /*NF*/
/*1 */ /*  */  (if buf-par_bar-code.unit-cli <> buf-par_goods.unit-base
          and ((qntytype = "список" and action = "list")
                     or
                     (qntytype = "документ" and action = "document"))
                then integer(round(gds-qnty / buf-par_bar-code.cli-base-rate, 0))
                else gds-qnty) "|"
   /*2 */ /*0 */  replace( OurHost.obj-name, "|":U, "/":U )  "|":U
   /*3 */ /*1 */  replace( OurObj.obj-name, "|":U, "/":U ) "|":U
   /*4 */ /*2 */  replace( buf-par_goods.artic, "|":U, "/":U ) "|":U
   /*5 */ /*3 */  replace( buf-par_goods.gds-name, "|":U, "/":U ) "|":U
   /*6 */ /*4 */  replace( buf-par_goods.engl-name, "|":U, "/":U ) "|":U
   /*7 */ /*5 */  (if available ub.scales-gds then "" else bar_code ) "|":U
   /*8 */ /*6 */  replace( gds-prt_node-name, "|":U, "/":U ) "|":U
   /*9 */ /*7 */  replace( country_name, "|":U, "/":U ) "|":U
   /*10*/ /*8 */  replace( prod_name, "|":U, "/":U ) "|":U
   /*11*/ /*9 */  str-price "|":U
   /*12*/ /*10*/  "Цена за " replace( buf-par_goods.unit-base, "|":U, "/":U ) ":" "|":U
   /*13*/ /*11*/  string( v-ticket-today,"99/99/9999" ) "|":U
   /*14*/ /*12*/  (if available ub.scales-gds then string(ub.scales-gds.PLU-code) else "" ) "|":U
   /*15*/ /*13*/  (if available ub.scales-gds then string("(" + string(ub.scales-gds.scales-num) + ")") else "" ) "|":U
   /*16*/ /*14*/  "Цена за " replace( trim(buf-par_bar-code.unit-cli), "|":U, "/":U ) " (" buf-par_bar-code.cli-base-rate " " replace( buf-par_goods.unit-base, "|":U, "/":U ) "):" "|":U
   /*17*/ /*15*/  str-price-alt "|":U
   /*18*/ /*16*/  replace( buf-par_goods.destin, "|":U, "/":U ) "|":U /*назначение */
   /*19*/ /*17*/  replace( buf-par_goods.attrib, "|":U, "/":U ) "|":U /* хар-ки */
   /*20*/ /*18*/  replace( buf-par_goods.user-rule, "|":U, "/":U ) "|":U /* правила эксплуат */
   /*21*/ /*19*/  replace( buf-par_goods.sert, "|":U, "/":U ) "|":U /* сертификат */
   /*22*/ /*20*/  replace( replace(buf-par_goods.struct, {&new-line}, {&space-char}), "|":U, "/":U ) "|":U /* структура */
   /*23*/ /*21*/  buf-par_goods.deadline "|":U /*срок хранения */
   /*24*/ /*22*/  replace( buf-par_goods.sort, "|":U, "/":U )  "|":U /* сорт */
   /*25*/ /*23*/  (if available ub.scales-gds then varattr-value else bar_code )  "|":U
   /*26*/ /*24*/  ListProdBc "|":U
   /*27*/ /*25*/  replace( buf-par_goods.grp-name, "|":U, "/":U ) "|":U
   /*28*/ /*26*/  replace( gds-grp.node-name, "|":U, "/":U ) "|":U
   /*29*/ /*27*/  replace( buf-par_goods.PS, "|":U, "/":U ) "|":U
   /*30*/ /*28*/  replace( gds-prt_f-name, "|":U, "/":U ) "|":U
   /*31*/ /*29*/  str-price-rb "|":U
   /*32*/ /*30*/  str-price-alt-rb "|":U
   /*33*/ /*31*/  (if buf-par_bar-code.cli-base-rate = 1 then buf-par_goods.qnty-cart else buf-par_bar-code.cli-base-rate) " " buf-par_goods.unit-base "|":U
   /*34*/ /*32*/  buf-par_bar-code.b-code "|":U
   /*35*/ /*33*/  replace( buf-par_goods.prod-type, "|":U, "/":U ) "|":U
   /*36*/ /*34*/  buf-par_goods.prod-code "|":U
   /*37*/ /*35*/  replace( buf-par_goods.unit-cli, "|":U, "/":U )  "|":U
   /*38*/ /*36*/  buf-par_goods.cli-base-rate "|":U
   /*39*/ /*37*/  replace( TickPS, "|":U, "/":U ) "|":U
   /*40*/ /*38*/  buf-par_goods.increase-pc "|":U
   /*41*/ /*39*/  buf-par_goods.wt-cart "|":U
   /*42*/ /*40*/  buf-par_goods.ms-cart "|":U
   /*43*/ /*41*/  buf-par_goods.gds-type "|":U
   /*44*/ /*42*/  v-ticket-vat-pc "|":U
   /*45*/ /*43*/  replace( buf-par_goods.okdp, "|":U, "/":U ) "|":U
   /*46*/ /*44*/  buf-par_goods.negative-rest "|":U
   /*47*/ /*45*/  replace( buf-par_goods.cost-calc, "|":U, "/":U ) "|":U
   /*48*/ /*46*/  v-ticket-slt-pc "|":U
   /*49*/ /*47*/  replace( buf-par_goods.unit-cst, "|":U, "/":U ) "|":U
   /*50*/ /*48*/  buf-par_goods.cst-base-rate "|":U
   /*51*/ /*49*/  replace( buf-par_goods.TNVED, "|":U, "/":U ) format "x(10)" "|":U
   /*52*/ /*50*/  buf-par_goods.min-stock "|":U
   /*53*/ /*51*/  replace( buf-par_goods.nationality, "|":U, "/":U ) "|":U
   /*54*/ /*52*/  replace( buf-par_goods.label-name, "|":U, "/":U ) "|":U
   /*55*/ /*53*/  str-price-old "|":U
   /*56*/ /*54*/  str-price-alt-old "|":U
   /*57*/ /*55*/  str-price-rb-old "|":U
   /*58*/ /*56*/  str-price-alt-rb-old "|":U
   /*59*/ /*57*/  v-mrtr-code "|":U
   /*60*/ /*58*/  v-bc-check-price "|":U
   /*61*/ /*59*/  entry( 1, ListProdBc, ",":U ) "|":U
   /*62*/ /*60*/  replace( v-rt-bar_code, "|":U, "/":U ) "|":U
   /*63*/ /*61*/  replace( buf-rt_bar-code.unit-cli, "|":U, "/":U ) "|":U
   /*64*/ /*62*/  replace( v-first-pbc-rt, "|":U, "/":U ) "|":U
   /*65*/ /*63*/  str-price-rt "|":U
   /*66*/ /*64*/  str-price-novat-rt "|":U
   /*67*/ /*65*/  replace( v-rt-alt-bar_code, "|":U, "/":U ) "|":U
   /*68*/ /*66*/  replace( v-rt-alt_unit-cli, "|":U, "/":U ) "|":U
   /*69*/ /*67*/  replace( v-first-pbc-alt-rt, "|":U, "/":U ) "|":U
   /*70*/ /*68*/  str-price-alt-rt "|":U
   /*71*/ /*69*/  str-price-alt-novat-rt "|":U
   /*72*/ /*70*/  replace( string( v-last-doc-date, "99/99/9999") , "|":U, "/":U ) "|":U
   /*73*/ /*71*/  str-price-alt-one "|":U
   /*74*/ /*72*/  trim( string( price-cd, ">>>>>>>>>>>>9.99" ) ) "|":U
   /*75*/ /*73*/  trim( string( v-calories, ">>>>>>>>>>>>9.<<" ) ) "|":U
   /*76*/ /*74*/  trim( string( v-protein, ">>>>>>>>>>>>9.<<" ) ) "|":U
   /*77*/ /*75*/  trim( string( v-carbohydrate, ">>>>>>>>>>>>9.<<" ) ) "|":U
   /*78*/ /*76*/  trim( string( v-fat, ">>>>>>>>>>>>9.<<" ) ) "|":U
   /*79*/ /*77*/  trim( p-part-code ) "|":U
   /*80*/ /*78*/  trim( p-doc-code ) "|":U
   /*81*/ /*79*/  trim( v-doc-date ) "|":U
   /*82*/ /*80*/  trim( v-short-doc-code ) "|":U
   /*83*/ /*81*/  trim( v-ser_on_pack ) "|":U
   /*84*/ /*82*/  v-last-pri-doc "|":U
   /*85*/ /*83*/  p-promo-code "|":U
   /*86*/ /*84*/  v-promo-name "|":U
   /*87*/ /*85*/  v-type-sale-promo "|":U
   /*88*/ /*86*/  v-sale-promo "|":U
   /*89*/ /*87*/  string(v-promo-price,">>>>>>>>>>>>9.99")
            SKIP.

assign b-count = b-count + 1.