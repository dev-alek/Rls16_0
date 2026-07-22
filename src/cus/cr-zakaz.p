block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание заказа

Автор: Комаров Иван Сергеевич
Дата создания: 08/04/11
Author: Ivan Komarov
Creation date: 08/04/11

*/

define input parameter parparentproc    as widget-handle .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-day-before-rvs as integer   no-undo. /* дней до поставки */
define input parameter p-day-sale       as integer   no-undo. /* дней продажи */
define input parameter p-grp-code       as character no-undo. /* список групп товаров */
define input parameter p-method-calc    as character no-undo. /* метод расчета из   o r d - m . w */
define input parameter p-send-esys      as logical   no-undo. /* отправлять во внешние системы? */
define input parameter p-delnull        as logical   no-undo. /* удалять нулевые позиции? */
define input parameter p-addextart      as logical   no-undo. /* добавлять товары только с артикулом поставщика? */
define input parameter p-cli-code       as integer   no-undo. /* код поставщика */
define input parameter p-cli-type       as character no-undo. /* тип поставщика */
define input parameter p-contra-code    as integer   no-undo. /* код договора */
define input parameter p-obj-code       as integer   no-undo. /* код объекта */
define input parameter p-obj-type       as character no-undo. /* тип объекта */
define input parameter p-g#type         as character no-undo. /*тип заказа*/


define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "создание заказа" .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cus/df-zakaz.i     }
{ cmp/r-page1.i      }
{ gbl/cur-time.i     }
{ ref/gdsoattr.i     }
{ cus/ord-lib.i  def }
{ cus/ord-code.i def }
{ cus/z-qnty.i   def }
{ cus/ord-lib.i last-price }
{ cus/str-edi.i      }
{ gbl/getcntxt.i def } /*get нельзя, т.к. автопроцесс */
{ str/cont-ms-def.i }

define temp-table temp-abc-day no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.

define temp-table tt-date no-undo
field exch-date as date
index pi is unique primary   exch-date
.

/*define variable g#type       as character no-undo .*/
define variable log-file-name       as character no-undo init "calc-ord.log".
define variable g#host-code         like ub.trn-doc.host-code no-undo .
define variable v-i-doc             as character no-undo .
define variable g#out-pay           as integer   no-undo .
define variable g#db-remote         as logical   no-undo .
define variable g#type              as character no-undo .
define variable v-base-rate         as decimal   no-undo .
define variable v-base-scale        as decimal   no-undo .
define variable v#doc-code          as character no-undo .

define buffer for-cli             for ub.clients.
define buffer buf_clients         for ub.clients.
define buffer bf-units-cli        for ub.units.
define buffer buf_doc-line        for ub.doc-line .
define buffer buf_contract-specif for ub.contract-specif .
define buffer buf_sysconf         for ub.sysconf  .
define buffer buf_cli-gds         for ub.cli-gds.
run get-db-num in parparentproc ( output v-cntxt-db-num).
find first buf_clients no-lock
where buf_clients.obj-code = p-obj-code
  and buf_clients.obj-type = p-obj-type
  no-error.
assign
  v-cntxt-host-code-obj = buf_clients.host-code
  v-cntxt-obj-code = p-obj-code
  v-cntxt-obj-type = p-obj-type
  p-val            = p-method-calc
  g#host-code      = buf_clients.host-code
.
find first buf_sysconf no-lock where buf_sysconf.host-code = g#host-code .
g#out-pay = buf_sysconf.out-pay.

define variable v-round-m   as character no-undo .
define variable v-round-base as decimal   no-undo .

define variable i            as integer no-undo .
define variable R-algoritm   as integer no-undo .
define variable R-min-rest   as integer no-undo .
define variable  date-p-1    as date no-undo .
define variable  date-p-2    as date no-undo .
define variable  R-algoritm2 as integer no-undo .
define variable  R-min-rest3 as logical no-undo .
define variable  p-code      like ub.tmp-sale.tmp-code no-undo .
define variable  t-rv        as logical no-undo .
define variable  t-rvz       as logical no-undo .
define variable  t-rvc       as logical no-undo .
define variable  t-rvzc      as logical no-undo .
define variable  t-sp        as logical no-undo .
define variable  t-sppv      as logical no-undo .
define variable  t-sppv-2    as logical no-undo .
define variable  t-sppv-3    as logical no-undo .
define variable  t-sppv-4    as logical no-undo .
define variable  t-way       as logical no-undo .
define variable  t-rcv       as logical no-undo .
define variable  t-clos      as logical no-undo .
define variable  p-neg-sale  as logical no-undo .
define variable  t-gar       as logical no-undo .
define variable  t-min-zapas as logical no-undo .
define variable  t-min-ost   as logical no-undo .
define variable SelectObject as character no-undo .
define variable v-nn as integer   no-undo .
define variable par-type as character no-undo .
define variable is-edoc-nn      as logical   no-undo .
define variable par-is-edoc-nn  as character no-undo .
define variable is-edi          as logical   no-undo .
define variable par-is-edi      as character no-undo .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-dm-edi  as integer no-undo .

/*for ord-mm.i*/
assign g#type = p-g#type .
{ cus/ord-mm.i   }

{ gbl/conf-rd.i "'edoc-nn'"  "''" "''" 0 "''" "''" "''"  no par-is-edoc-nn par-type      no-error}
{ gbl/conf-rd.i "'is-edi'"   "''" "''" 0 "''" "''" "''"  no par-is-edi     par-type      no-error}

assign
  is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
  is-edi     = lookup(par-is-edi,     "true,yes":U) > 0
  to-day = today
  loc-date-ship = to-day + p-day-before-rvs /* + 1 */
.

run create-temp-zakaz in this-procedure no-error.

/*------------------------------------------*/

procedure calc-temp-zakaz :

define input parameter p-calc-metod as character.
define input parameter p-ord-type   as character.

v-nn = num-entries(p-calc-metod) .
  do i = 1 to v-nn :
     case  entry(1,(entry(i,p-calc-metod)), "=" ) :
        when string( "v-round-m" )              then v-round-m = entry(2,(entry(i,p-calc-metod)), "=" )           .
        when string( "v-round-base" )           then v-round-base = decimal(entry(2,(entry(i,p-calc-metod)), "=" ) )          .
        when string( "R-min-rest" )             then R-min-rest = integer(entry(2,(entry(i,p-calc-metod)), "=" )).
        when string( "R-algoritm" )             then R-algoritm = integer(entry(2,(entry(i,p-calc-metod)), "=" )).
        when string( "R-algoritm2" )            then R-algoritm2 = integer(entry(2,(entry(i,p-calc-metod)), "=" )).
        when string( "tmp-sale.tmp-code" )      then do:
             find first tmp-sale no-lock where tmp-sale.tmp-code = entry(2,(entry(i,p-calc-metod)), "=" ) no-error.
             if available tmp-sale then do:
               p-code = tmp-sale.tmp-code.
             end.
             else do:
             end.
        end.

        when string( "SelectObject" ) then  do:
                SelectObject = string(entry(2,(entry(i,p-calc-metod)), "=" )) no-error .
             end.

        when string( "date-p-1" )     then  date-p-1   = date(entry(2,(entry(i,p-calc-metod)), "=" )).
        when string( "date-p-2" )     then  date-p-2   = date(entry(2,(entry(i,p-calc-metod)), "=" )).
        when string( "t-way"   )      then  t-way      = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false.
        when string( "t-rcv"   )      then  t-rcv      = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false.
        when string( "t-clos"   )     then  t-clos     = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false.
        when string( "t-rv"   )       then  t-rv       = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false.
        when string( "t-rvz"  )       then  t-rvz      = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false .
        when string( "t-rvc"  )       then  t-rvc      = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false  .
        when string( "t-rvzc" )       then  t-rvzc     = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false  .
        when string( "t-sp"   )       then  t-sp       = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false  .
        when string( "t-sppv" )       then  t-sppv     = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false  .
        when string( "t-sppv-2")      then  t-sppv-2   = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false.
        when string( "t-sppv-3")      then  t-sppv-3   = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false .
        when string( "t-sppv-4")      then  t-sppv-4   = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false .
        when string( "p-neg-sale")    then  p-neg-sale = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false .
        when string( "t-gar")         then  t-gar      = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false .
        when string( "t-min-ost")     then  t-min-ost  = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false .
        when string( "t-min-zapas")   then  t-min-zapas = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false .
        when string( "R-min-rest3")   then  R-min-rest3 = if (entry(2,(entry(i,p-calc-metod)), "=" )) = "yes" then true else false .

        otherwise do:
        end.
     end case.
  end.
  assign
  pay-day = p-day-sale
  .
   /*собираем минимальные остатки*/
   run ord-mm in this-procedure .

    if p-ord-type = {&f-p}    then  do:
      run cus/qnty-obj.p  (
            input parparentproc
          , input v-round-m
          , input v-round-base
          , input e-method
          , input "":U
          , input v#doc-code
          , input date-p-1
          , input date-p-2
          , input "" /*"calc":U*/
          , input no
          , input R-algoritm
          , input R-algoritm2
          , input R-min-rest
          , input R-min-rest3
          , input p-code
          , input t-rv
          , input t-rvz
          , input t-rvc
          , input t-rvzc
          , input t-sp
          , input t-sppv
          , input t-sppv-2
          , input t-sppv-3
          , input t-sppv-4
          , input t-way
          , input t-rcv
          , input t-clos
          , input table tt-date
          , input table temp-abc-day
          , input p-neg-sale
          , input t-gar
          , input t-min-zapas
          , input t-min-ost
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , input p-ord-type
          , input no
          ) no-error .
          if error-status :error then do:
              return error error-status :get-message(1) .
          end.
    end.
    else  do:
      run cus/qntysale.p (
            input parparentproc
          , input v-round-m
          , input v-round-base
          , input e-method
          , input "":U
          , input v#doc-code /*чтобы писался расчет в "протокол" */
          , input date-p-1
          , input date-p-2
          , input "" /*"calc":U*/
          , input no
          , input R-algoritm
          , input R-algoritm2
          , input R-min-rest
          , input R-min-rest3
          , input p-code
          , input t-rv
          , input t-rvz
          , input t-rvc
          , input t-rvzc
          , input t-sp
          , input t-sppv
          , input t-sppv-2
          , input t-sppv-3
          , input t-sppv-4
          , input t-way
          , input t-rcv
          , input t-clos
          , input table tt-date
          , input table temp-abc-day
          , input p-neg-sale
          , input t-gar
          , input t-min-zapas
          , input t-min-ost
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , input p-ord-type
          , input no
          ) no-error .
          if error-status :error then do:
              return error error-status :get-message(1) .
          end.
    end.
end procedure .

/*------------------------------------------*/

procedure create-ord-line : /* по аналогии с ord-load.p - закачка из Эксель документа в заказ */
define input parameter p-contract-code like ub.contract.contract-code no-undo.

define buffer buf_contract for ub.contract .

define variable v-e-m   as character no-undo .
define variable k            as   integer   no-undo init 0.
define variable is-edoc-nn-doc  as logical   no-undo .
define variable is-edi-doc      as logical   no-undo .

  { gbl/baserate.i
    g#host-code
    to-day
    v-base-rate
    v-base-scale
    }

  /* закачка в ord-doc ord-line */

  assign k = 0 .

  for each tmp#zakaz no-lock
   :
      v-e-m = ''.
      assign
        k = k + 1
      .
      find first bf-units-cli where bf-units-cli.unit-name = tmp#zakaz.unit-cli no-lock no-error.
      create shar_ord-line no-error.
      assign
        shar_ord-line.doc-code    = v#doc-code
        shar_ord-line.prod-type   = tmp#zakaz.prod-type
        shar_ord-line.prod-code   = tmp#zakaz.prod-code
        shar_ord-line.artic       = tmp#zakaz.artic
        shar_ord-line.gds-code    = tmp#zakaz.gds-code
        shar_ord-line.cli-art     = tmp#zakaz.cli-art
        shar_ord-line.qnty        = tmp#zakaz.qnty
        shar_ord-line.order-qnty  = tmp#zakaz.qnty
        shar_ord-line.initial-qnty  = tmp#zakaz.qnty
        shar_ord-line.cli-qnty    = ( if lookup({&pieces}, bf-units-cli.type) > 0
          and  trunc (tmp#zakaz.qnty / tmp#zakaz.cli-base-rate, 0) <> tmp#zakaz.qnty / tmp#zakaz.cli-base-rate
          then trunc (tmp#zakaz.qnty / tmp#zakaz.cli-base-rate, 0)
          else tmp#zakaz.qnty / tmp#zakaz.cli-base-rate )
        shar_ord-line.price-cli   = tmp#zakaz.price-cli * tmp#zakaz.cli-base-rate
        shar_ord-line.sum-cli     = shar_ord-line.price-cli * shar_ord-line.cli-qnty
        shar_ord-line.price-rubl  = tmp#zakaz.price-cli
        shar_ord-line.price-base  = ( tmp#zakaz.price-cli ) / v-base-rate * v-base-scale
        shar_ord-line.sum-rubl    = shar_ord-line.price-rubl * shar_ord-line.qnty
        shar_ord-line.sum-base    = shar_ord-line.price-base * shar_ord-line.qnty
        shar_ord-line.unit-cli    = tmp#zakaz.unit-cli
        shar_ord-line.line-num    = k
        shar_ord-line.vat-pc      = tmp#zakaz.vat-pc

        .

  end. /* for each */
  find first for-cli no-lock
       where for-cli.obj-code = p-cli-code
         and for-cli.obj-type = p-cli-type
         no-error.
/*  run waitfram-show in this-procedure ("Создается заказ № " + string(v#doc-code) + " для " + for-cli.obj-name ).*/

/*  to-day = today.*/
  create shar_ord-doc.
  assign
      shar_ord-doc.doc-code     = v#doc-code
      shar_ord-doc.doc-date     = to-day
      shar_ord-doc.cli-code     = for-cli.obj-code
      shar_ord-doc.cli-name     = for-cli.obj-name
      shar_ord-doc.cli-type     = for-cli.obj-type
      shar_ord-doc.creid        = "автозаказ" /*userid пользователя там обычно лежит  */
      shar_ord-doc.agnt         = ?
      shar_ord-doc.boss         = ?
      shar_ord-doc.fact-date    = ?
      shar_ord-doc.pay-code     = g#out-pay
      shar_ord-doc.ship-date    = to-day + p-day-before-rvs /*l-date*/
      shar_ord-doc.sum-service  = 0
      shar_ord-doc.sum-ship     = 0
      shar_ord-doc.flag_        = false
      shar_ord-doc.status_      = {&g___new}
      shar_ord-doc.wrkr         = ?
      shar_ord-doc.host-code    = g#host-code
      shar_ord-doc.doc-type     = p-g#type
      shar_ord-doc.order-type   = 0
      shar_ord-doc.cycle-day    = 0
      shar_ord-doc.start-date   = to-day + p-day-before-rvs              /*date-1*/
      shar_ord-doc.end-date     = max (to-day, to-day + p-day-before-rvs + p-day-sale - 1) /*date-2*/
      shar_ord-doc.date-sale-1  = to-day + p-day-before-rvs              /*date-1*/
      shar_ord-doc.date-sale-2  = max (to-day, to-day + p-day-before-rvs + p-day-sale - 1) /*date-2*/
      shar_ord-doc.pay-day      = p-day-sale /*var-l-pay-day*/
      shar_ord-doc.obj-code     = v-cntxt-obj-code
      shar_ord-doc.obj-type     = v-cntxt-obj-type
      shar_ord-doc.slt-type     = {&without-slt}
      shar_ord-doc.vat-type     = {&inc-vat}
      shar_ord-doc.exch-code    = loc-exch-code
      shar_ord-doc.exch-date    = to-day
      shar_ord-doc.e-method     = v-e-m
      shar_ord-doc.base-rate    = v-base-rate
      shar_ord-doc.base-scale   = v-base-scale
      shar_ord-doc.tot-lines    = k
      /*кол-ва и суммы в шапке заказа обсчитываются в триггере*/
      .

    find ub.currency where ub.currency.curr-code = 0 no-lock no-error.
    find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code  use-index pi no-lock no-error.
      if available ub.curr-accnt then
          assign
            shar_ord-doc.exch-rate  = ub.curr-accnt.exch-rate
            shar_ord-doc.exch-scale = ub.curr-accnt.exch-scale
          .
     find first buf_contract no-lock
          where buf_contract.contract-code = p-contract-code
            and buf_contract.host-code = g#host-code
            no-error.
     if available buf_contract then do:
       assign shar_ord-doc.contract-code = buf_contract.contract-code.
     end.


  if p-send-esys and p-g#type = {&O-P} then do: /*отправка во внешние системы */
    if can-find (first shar_ord-line
                 where shar_ord-line.doc-code = shar_ord-doc.doc-code
                   and ( shar_ord-line.cli-art  = ""
                    or shar_ord-line.cli-art  = ? )
                 ) then do:
     return error
       substitute("в заказе есть линия без артикула поставщика &1 &2&3&4, &5 заказ не может быть направлен по EDI\EDOC",
         shar_ord-line.artic
       , shar_ord-line.prod-type
       , shar_ord-line.prod-code
       , shar_ord-line.cli-art
       , {&new-line}
       )
     .
    end.
    for each shar_ord-line
       where shar_ord-line.doc-code = shar_ord-doc.doc-code
      :
      if can-find (first ub.ord-line where ub.ord-line.doc-code = shar_ord-doc.doc-code
         and recid(shar_ord-line) <> recid (ub.ord-line)
         and shar_ord-line.cli-art = ub.ord-line.cli-art
      ) then do:
        return error
         substitute( "в заказе есть линии c одинаковым артикулом поставщика &1 &2&3&4, &5 заказ не может быть направлен по EDI\EDOC",
         shar_ord-line.artic
       , shar_ord-line.prod-type
       , shar_ord-line.prod-code
       , shar_ord-line.cli-art
       , {&new-line}
        )
        .
      end.
    end.

    /*определяем по какой внешней системе работает поставщик*/
    assign
    is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                        , input p-cli-type
                                        , input p-cli-code
                                        , input p-obj-type
                                        , input p-obj-code
                                        ) .
    assign
    is-edi-doc = status-is-edi ( input is-edi
                                , input p-cli-type
                                , input p-cli-code
                                , input p-obj-type
                                , input p-obj-code
                                , output v-dm-edi
                                ) .

    if ( is-edoc-nn-doc and shar_ord-doc.ord-int1 = integer({&edoc-empty}) )
    or ( is-edi-doc     and shar_ord-doc.ord-int1 = integer({&edi-empty})  ) and
      shar_ord-doc.doc-type = {&O-P} and
      shar_ord-doc.status_  = {&g___new}
    then do:
        if is-edoc-nn-doc then do :
          assign
            shar_ord-doc.whole-send-news = integer({&doc-dm-edoc-nn})
          .
        end.
        if is-edi-doc then do :
          assign
            shar_ord-doc.whole-send-news = integer({&doc-dm-edi})
          .
        end.
        run cus/edocsord.p (  input parParentProc
                            , input recid(shar_ord-doc)
                            , input {&table_ord-doc}
                            , input yes
                            )  .
    end.
  end.
end procedure.

/*------------------------------------------*/

procedure create-temp-zakaz :
/*define output parameter p-contract-code like ub.contract.contract-code no-undo.*/

define variable v-not-contract   as logical no-undo.
define variable v-i              as integer no-undo.
define variable v-iTmp           as integer no-undo init 0 extent 3.
define variable v-contract-code  as integer no-undo.
define variable v-host-code      as integer no-undo.
define variable v-iTmp1          as integer no-undo init 0 extent 3.
define variable v-contract-code1 as integer no-undo.
define variable v-host-code1     as integer no-undo.

define buffer bf_contract  for ub.contract .
define buffer buf_goods    for ub.goods .
define buffer bf1_contract for ub.contract .
define buffer bf1_contract-specif for ub.contract-specif .

assign v-not-contract = true.

for each bf_contract no-lock /* поставщик работает с договорами */
    where bf_contract.cli-code = p-cli-code
      and bf_contract.cli-type = p-cli-type
      and bf_contract.status_ = {&current-contr}
      and bf_contract.host-code = g#host-code
      and not bf_contract.contract-date-beg > loc-date-ship
      and ( bf_contract.contract-date-end = ? or not bf_contract.contract-date-end < loc-date-ship )
      and not p-g#type = {&O-F}
      and (p-contra-code = 0 or p-contra-code = ? or bf_contract.contract-code = p-contra-code)
      break by bf_contract.contract-date-beg
:
  assign
    v-not-contract  = false
    v-contract-code = bf_contract.contract-code
    v-host-code     = bf_contract.host-code
  .

   /* Проверяем договор !!!  */
   run MS-Contract-EXTENT-3 in this-procedure(
       bf_contract.host-code,
       bf_contract.contract-code,
       output v-iTmp ).
   if v-iTmp[1] = 2 then do:
      /* подчиненный договор  */
      assign
        v-host-code     = v-iTmp[2]
        v-contract-code = v-iTmp[3]
      .
   end.

  _contract-specif :
  for each buf_contract-specif no-lock
    where buf_contract-specif.contract-num = v-contract-code
      and buf_contract-specif.host-code = v-host-code
  :
      /*Проверяем наличие товара в более свежем договоре*/
      for each bf1_contract no-lock
          where bf1_contract.cli-code = p-cli-code
            and bf1_contract.cli-type = p-cli-type
            and bf1_contract.status_ = {&current-contr}
            and bf1_contract.host-code = g#host-code
            and recid(bf1_contract) <> recid(bf_contract)
            and bf1_contract.contract-date-beg > bf_contract.contract-date-beg
            :
            assign
              v-contract-code1 = bf1_contract.contract-code
              v-host-code1     = bf1_contract.host-code
            .
            /* Проверяем договор !!!  */
            run MS-Contract-EXTENT-3 in this-procedure(
                bf1_contract.host-code,
                bf1_contract.contract-code,
                output v-iTmp1 ).
            if v-iTmp1[1] = 2 then do:
               /* подчиненный договор  */
               assign
                 v-host-code1     = v-iTmp1[2]
                 v-contract-code1 = v-iTmp1[3]
               .
            end.

            if can-find (first bf1_contract-specif
                        where bf1_contract-specif.contract-num = v-contract-code1
                          and bf1_contract-specif.host-code = v-host-code1
                          and bf1_contract-specif.gds-code  = buf_contract-specif.gds-code
            ) then do:
              next _contract-specif. /*товар участвует в более новом договоре - заказ будет сделан по нему */
            end.
      end.

    /*по списку групп товаров*/
    do v-i = 1 to num-entries(p-grp-code):
       for each goods no-lock
       where goods.artic     = buf_contract-specif.artic
         and goods.prod-code = buf_contract-specif.prod-code
         and goods.prod-type = buf_contract-specif.prod-type
         and goods.grp-code  = int(entry(v-i, p-grp-code))
         :
         run fill-temp-zakaz in this-procedure (
             input goods.gds-code
             , input ?
             , input v-contract-code /*bf_contract.contract-code*/
             , input v-host-code
         ) no-error.
       end.
    end. /*do*/

  end.


  if can-find (first tmp#zakaz ) then do:
      { cus/ord-code.i
          'main'
          v-cntxt-db-num
          v-cntxt-obj-type
          v-cntxt-obj-code
          v-i-doc
          v#doc-code
          }

    run calc-temp-zakaz in this-procedure (    /* обсчитываем временную таблицу*/
        input p-val
      , input p-g#type
      ) no-error.
    for each tmp#zakaz where p-delnull and tmp#zakaz.qnty = 0 : /*удаляем нулевые строки*/
      delete tmp#zakaz.
    end.
    for each tmp#zakaz where p-addextart and tmp#zakaz.cli-art  = ""
                    or tmp#zakaz.cli-art  = ?: /*удаляем строки без артикла поставщика*/
      delete tmp#zakaz.
    end.
    for each tmp#zakaz: /*удаляем строки без артикла поставщика*/
      if p-g#type <> {&p-o}
        and p-g#type <> {&f-p}  then 
      do:
        var-ok-assort-pol = true .
        { gbl/goassizt.i
          p-g#type
          tmp#zakaz.gds-code
          p-obj-type
          p-obj-code
          false
          var-ok-assort-pol
          var-mess-assort-pol
          }
        if var-ok-assort-pol = false then 
        do:
          delete tmp#zakaz .
        end.
      end.
    end.
    if can-find (first tmp#zakaz ) then do:
        run create-ord-line in this-procedure (  /*создаем линии заказа и сам заказ */
            input v-contract-code /*bf_contract.contract-code*/
         ) no-error.
        if not error-status:error then do:
           run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input "Создан заказ N " + v#doc-code ) .
        end.
        else do:
           run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input "Ошибка создания: " + return-value ) .
        end.
    end.
    for each tmp#zakaz :
      delete tmp#zakaz.
    end.
  end.
end.
if v-not-contract then do: /* по поставщику нет договоров - соберем по cli-gds */

  if p-g#type = {&O-P} or p-g#type = {&F-P} then do:
      for each cli-gds no-lock
      where cli-gds.cli-code = p-cli-code
      and cli-gds.cli-type = p-cli-type
      :
         /*по списку групп товаров*/
         do v-i = 1 to num-entries(p-grp-code):
             for each buf_goods no-lock
             where buf_goods.artic     = cli-gds.artic
               and buf_goods.prod-code = cli-gds.prod-code
               and buf_goods.prod-type = cli-gds.prod-type
               and buf_goods.grp-code  = int(entry(v-i, p-grp-code))
               :
               run fill-temp-zakaz in this-procedure (
                   input buf_goods.gds-code
                 , input recid(cli-gds)
                 , input ?
                 , input ?
               ) .
             end.
         end. /*do*/
      end. /*for each cli-gds*/
  end.
  else do:
     /*по списку групп товаров*/
     do v-i = 1 to num-entries(p-grp-code):
         for each buf_goods no-lock
         where buf_goods.grp-code  = int(entry(v-i, p-grp-code))
           :
           run fill-temp-zakaz-rc in this-procedure (
               input buf_goods.gds-code
           ) .
         end.
     end. /*do*/
  end.

  if can-find (first tmp#zakaz ) then do:
    { cus/ord-code.i
        'main'
        v-cntxt-db-num
        v-cntxt-obj-type
        v-cntxt-obj-code
        v-i-doc
        v#doc-code
        }
    run calc-temp-zakaz in this-procedure (    /* обсчитываем временную таблицу*/
        input p-val
      , input p-g#type
      ) no-error.
    for each tmp#zakaz where p-delnull and tmp#zakaz.qnty = 0 : /*удаляем нулевые строки*/
      delete tmp#zakaz.
    end.
    for each tmp#zakaz where p-addextart and tmp#zakaz.cli-art  = ""
                    or tmp#zakaz.cli-art  = ?: /*удаляем строки без артикла поставщика*/
      delete tmp#zakaz.
    end.
    for each tmp#zakaz: /*удаляем строки без артикла поставщика*/
      if p-g#type <> {&p-o}
        and p-g#type <> {&f-p}  then 
      do:
        var-ok-assort-pol = true .
        { gbl/goassizt.i
          p-g#type
          tmp#zakaz.gds-code
          p-obj-type
          p-obj-code
          false
          var-ok-assort-pol
          var-mess-assort-pol
          }
        if var-ok-assort-pol = false then 
        do:
          delete tmp#zakaz .
        end.
      end.
    end.
    if can-find (first tmp#zakaz ) then do:
        run create-ord-line in this-procedure (  /*создаем линии заказа и сам заказ */
            input ?
          ) no-error.
        if not error-status:error then do:
           run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input "Создан заказ N " + v#doc-code ) .
        end.
        else do:
           run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input "Ошибка создания: " + return-value ) .
        end.
    end.
    for each tmp#zakaz :
      delete tmp#zakaz.
    end.
  end.
end.



end procedure.

/*------------------------------------------*/

procedure fill-temp-zakaz :

define input parameter p-gds-code like ub.goods.gds-code no-undo.
define input parameter p-recid    as recid no-undo.
define input parameter p-contract-code like ub.contract.contract-code no-undo.
define input parameter p-host-code as integer no-undo.

define buffer ll-tmp#zakaz for tmp#zakaz .
define buffer bufff-units  for ub.units  .
define buffer sb-cli-gds   for ub.cli-gds  .
define buffer buf_contract for ub.contract  .
define buffer buf_contract-specif for ub.contract-specif  .



define variable max-num as integer no-undo .

for each goods no-lock
where goods.gds-code = p-gds-code
:

find first tmp#zakaz
     where tmp#zakaz.prod-type = goods.prod-type
       and tmp#zakaz.prod-code = goods.prod-code
       and tmp#zakaz.artic     = goods.artic
       no-error.
  if not available tmp#zakaz then do: /* создаем таблицу, которую обсчитывают процедуры, согласно методам расчета */
    assign max-num = 0.
    for each  ll-tmp#zakaz  where ll-tmp#zakaz.doc-code = loc-ord-num and
                                  ll-tmp#zakaz.gds-code <> goods.gds-code :
        if max-num < ll-tmp#zakaz.line-num then
           max-num = ll-tmp#zakaz.line-num .
    end.
    create tmp#zakaz .
    assign
      tmp#zakaz.doc-code        = loc-ord-num
      tmp#zakaz.prod-type       = goods.prod-type
      tmp#zakaz.prod-code       = goods.prod-code
      tmp#zakaz.artic           = goods.artic
      tmp#zakaz.line-num        = max-num + 1
    .
  end.

  assign
    tmp#zakaz.doc-code        = loc-ord-num
    tmp#zakaz.gds-code        = goods.gds-code
    tmp#zakaz.gds-name        = goods.gds-name
    tmp#zakaz.negative-rest   = goods.negative-rest
    tmp#zakaz.deadline        = goods.deadline
    tmp#zakaz.unit-base       = goods.unit-base
    tmp#zakaz.unit-cli        = goods.unit-cli
    tmp#zakaz.cli-base-rate   = goods.cli-base-rate
    tmp#zakaz.ms-cart         = goods.qnty-cart
    .
  find first ext-artic no-lock   /*внешний артикул поставщика*/
        where ext-artic.cli-type    = p-cli-type
          and ext-artic.cli-code    = p-cli-code
          and ext-artic.gds-code    = goods.gds-code
          and ext-artic.status_    <> {&deleted-status} no-error .
  if available ext-artic then do:
    assign tmp#zakaz.cli-art = ext-artic.ext-artic.
  end.
  else do:
    assign tmp#zakaz.cli-art = ''.
  end.

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error. /*ед.изм.*/
  if available bufff-units then
  assign tmp#zakaz.unit-type       = bufff-units.type .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error. /*ед.изм.поставщика*/
  if available bufff-units then
  assign tmp#zakaz.unit-cli-type   = bufff-units.type .


  if p-recid <> ? then do: /*если нет договоров */
    find first sb-cli-gds where recid(sb-cli-gds) = p-recid no-lock no-error .
    if available sb-cli-gds then do:
          assign
            tmp#zakaz.cancel-date     = sb-cli-gds.cancel-date
            tmp#zakaz.in-qnty         = sb-cli-gds.in-qnty
            tmp#zakaz.out-qnty        = sb-cli-gds.out-qnty
            tmp#zakaz.ret-qnty        = sb-cli-gds.ret-qnty
            tmp#zakaz.in-base         = sb-cli-gds.in-base
            tmp#zakaz.in-rubl         = sb-cli-gds.in-rubl
            tmp#zakaz.out-sum         = sb-cli-gds.out-sum
            tmp#zakaz.ret-sum         = sb-cli-gds.ret-sum
            tmp#zakaz.in-code         = sb-cli-gds.in-code
            tmp#zakaz.last-curr-code  = sb-cli-gds.exch-code
            tmp#zakaz.supp-qnty       = sb-cli-gds.supp-qnty
            tmp#zakaz.supp-base       = sb-cli-gds.supp-base
            tmp#zakaz.supp-rubl       = sb-cli-gds.supp-rubl
            loc-exch-code             = sb-cli-gds.exch-code
          .
          find first buf_doc-line no-lock where
                    buf_doc-line.doc-code  = sb-cli-gds.in-code and
                    buf_doc-line.artic     = sb-cli-gds.artic and
                    buf_doc-line.prod-type = sb-cli-gds.prod-type and
                    buf_doc-line.prod-code = sb-cli-gds.prod-code
                    no-error .
          if available buf_doc-line  then do:
              assign
                tmp#zakaz.unit-cli        = buf_doc-line.unit-cli
                tmp#zakaz.cli-base-rate   = buf_doc-line.cli-base-rate
                .
          end.
    end.
    { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? g#host-code p-obj-type p-obj-code tmp#zakaz.vat-pc no-error } /*текущие налоги*/
    if error-status :error then return error error-status :get-message(1) .
    run last-price (
        input  g#host-code ,
        input  tmp#zakaz.artic ,
        input  tmp#zakaz.prod-type ,
        input  tmp#zakaz.prod-code ,
        input  p-cli-code  ,
        input  p-cli-type  ,
        input  tmp#zakaz.cli-base-rate ,
        input  loc-exch-code ,
        output tmp#zakaz.price-base ,
        output tmp#zakaz.price-rubl ,
        output tmp#zakaz.price-cli   )
    no-error  .

  end.  /*по cli-gds*/
  else do:
    { gbl/baserate.i
    g#host-code
    to-day
    loc-exch-rate
    loc-base-scale }
    for each buf_contract no-lock
       where buf_contract.contract-code = p-contract-code
         and buf_contract.host-code     = p-host-code ,
        first buf_contract-specif no-lock
       where buf_contract-specif.contract-num = p-contract-code
         and buf_contract-specif.host-code    = p-host-code
         and buf_contract-specif.gds-code     = goods.gds-code
         :

          assign
          loc-exch-code           = buf_contract.curr-code
          tmp#zakaz.vat-pc        = buf_contract-specif.vat-pc
          tmp#zakaz.price-cli     = buf_contract-specif.price-cli
          tmp#zakaz.cli-base-rate = buf_contract-specif.cli-base-rate
          tmp#zakaz.unit-cli      = buf_contract-specif.unit-base

/*          tmp#zakaz.qnty       =  tmp#zakaz.cli-qnty   * tmp#zakaz.cli-base-rate*/
/*          tmp#zakaz.price-rubl =  tmp#zakaz.price-cli  * loc-exch-rate / loc-exch-scale / tmp#zakaz.cli-base-rate*/
/*          tmp#zakaz.price-base =  tmp#zakaz.price-rubl / loc-base-rate * loc-base-scale*/
/*          tmp#zakaz.sum        =  tmp#zakaz.price-rubl * tmp#zakaz.qnty*/
/*          tmp#zakaz.sum-rubl   =  tmp#zakaz.price-rubl * tmp#zakaz.qnty*/
/*          tmp#zakaz.sum-base   =  tmp#zakaz.price-base * tmp#zakaz.qnty*/
/*          tmp#zakaz.sum-cli    =  tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty*/

          .

    end.
  end.
end.

end procedure.


procedure fill-temp-zakaz-rc :

define input parameter p-gds-code like ub.goods.gds-code no-undo.

define buffer ll-tmp#zakaz for tmp#zakaz .
define buffer bufff-units  for ub.units  .

define variable max-num as integer no-undo .

for each goods no-lock
where goods.gds-code = p-gds-code
:

find first tmp#zakaz
     where tmp#zakaz.prod-type = goods.prod-type
       and tmp#zakaz.prod-code = goods.prod-code
       and tmp#zakaz.artic     = goods.artic
       no-error.
  if not available tmp#zakaz then do: /* создаем таблицу, которую обсчитывают процедуры, согласно методам расчета */
    assign max-num = 0.
    for each  ll-tmp#zakaz  where ll-tmp#zakaz.doc-code = loc-ord-num and
                                  ll-tmp#zakaz.gds-code <> goods.gds-code :
        if max-num < ll-tmp#zakaz.line-num then
           max-num = ll-tmp#zakaz.line-num .
    end.
    create tmp#zakaz .
    assign
      tmp#zakaz.doc-code        = loc-ord-num
      tmp#zakaz.prod-type       = goods.prod-type
      tmp#zakaz.prod-code       = goods.prod-code
      tmp#zakaz.artic           = goods.artic
      tmp#zakaz.line-num        = max-num + 1
    .
  end.

  assign
    tmp#zakaz.doc-code        = loc-ord-num
    tmp#zakaz.gds-code        = goods.gds-code
    tmp#zakaz.gds-name        = goods.gds-name
    tmp#zakaz.negative-rest   = goods.negative-rest
    tmp#zakaz.deadline        = goods.deadline
    tmp#zakaz.unit-base       = goods.unit-base
    tmp#zakaz.unit-cli        = goods.unit-cli
    tmp#zakaz.cli-base-rate   = goods.cli-base-rate
    tmp#zakaz.ms-cart         = goods.qnty-cart
    .
    assign tmp#zakaz.cli-art = ''.

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error. /*ед.изм.*/
  if available bufff-units then
  assign tmp#zakaz.unit-type       = bufff-units.type .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error. /*ед.изм.поставщика*/
  if available bufff-units then
  assign tmp#zakaz.unit-cli-type   = bufff-units.type .

      { gbl/basecode.i
        g#host-code
        loc-exch-code
      }

    { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? g#host-code p-obj-type p-obj-code tmp#zakaz.vat-pc no-error } /*текущие налоги*/
    if error-status :error then return error error-status :get-message(1) .
    run last-price (
        input  g#host-code ,
        input  tmp#zakaz.artic ,
        input  tmp#zakaz.prod-type ,
        input  tmp#zakaz.prod-code ,
        input  p-cli-code  ,
        input  p-cli-type  ,
        input  tmp#zakaz.cli-base-rate ,
        input  loc-exch-code ,
        output tmp#zakaz.price-base ,
        output tmp#zakaz.price-rubl ,
        output tmp#zakaz.price-cli   )
    no-error  .

    { gbl/baserate.i
    g#host-code
    to-day
    loc-exch-rate
    loc-base-scale }
end.

end procedure.