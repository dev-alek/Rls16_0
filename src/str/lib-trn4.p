block-level on error undo, throw.
/*

$Revision: f29df1d5f130, 3104, rls $
$Author: DRuban $
$Date: 2022/08/09 06:15:01 $
$Workfile: lib-trn4.p $
$Archive: str/lib-trn4.p $

библиотека процедур для работы со складскими документами (4)

Автор: Чернова Светлана Александровна
Дата создания: 12/04/06
Author: Svetlana Chernova
Creation date: 12/04/06

Create: Булгаков Андрей Николаевич
Дата создания: 04/21/06


*/

using ibs.th.gbl.gbl-hndllib from propath.

define variable vss-revision    as character no-undo initial "$Revision: f29df1d5f130, 3104, rls $":U .
define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/08/09 06:15:01 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-trn4.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/lib-trn4.p $":U .
define variable vss-description as character no-undo initial "библиотека процедур для работы со складскими документами (4)":U .

define temp-table tt-techLoss
field temperatura as decimal
field masdol as decimal
field coef as decimal
.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/lib-trn.i  }
{ cmp/library.i  }
{ gbl/usrfulnf.i }
{ gbl/waitfram.i }
{ str/lib-def.i  }
{ cmp/gds-list.i gds-list def }
{ gbl/getsect.i def }
{ str/cont-ms-def.i }
{ str/is-mes.i }
{ str/trdcalib.i }
{ str/placelib.i}
{ rep/spr-sug.i }

{ utl/gtin.i    }
{ str/utd-typemark.i }

if valid-handle( g#lib-trn4 ) = yes and
   g#lib-trn4 <> this-procedure :handle and
   g#lib-trn4 :get-signature( 'lib-trn4_gdnorsrv':U ) <> "":U
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Попытка повторной загрузки библиотеки для работы со складскими документами (4)" skip( 0 )
          g#lib-trn4                      skip( 0 )
          g#lib-trn4 :type                skip( 0 )
          g#lib-trn4 :file-name           skip( 0 )
          valid-handle( g#lib-trn4     )  skip( 0 )
          this-procedure :handle          skip( 0 )
          this-procedure :type            skip( 0 )
          this-procedure :file-name       skip( 0 )
          valid-handle( this-procedure )  skip( 1 )
  view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-trn4 = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn4", g#lib-trn4).
  delete object gbl-hndllibObj.
end.

on delete of this-procedure do:
  assign
    g#lib-trn4 = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn4", g#lib-trn4).
  delete object gbl-hndllibObj.
end.

define stream str-err .
define variable v-mess as character no-undo.

/* Какие товары, требующие резервирования по складским местам, можно включать в документ без резервирования. */
procedure lib-trn4_gdnorsrv :
  define  input parameter p-artic     like ub.goods.artic      no-undo .
  define  input parameter p-prod-type like ub.goods.prod-type  no-undo .
  define  input parameter p-prod-code like ub.goods.prod-code  no-undo .
  define  input parameter p-doc-code  like ub.trn-doc.doc-code no-undo .
  define output parameter p-process   as   logical             no-undo initial no .

  define variable is-petrol as logical no-undo .
  define variable is-pieces as logical no-undo .
  define variable is-hold   as logical no-undo .

  define buffer bf_trn-doc for ub.trn-doc .

  do
  on error undo, return error return-value
  :
    { str/is-petrl.i
        p-artic
        p-prod-type
        p-prod-code
        is-petrol
        is-pieces
        no-error
    }
    if error-status :error or
       is-petrol = ?       or
       is-pieces = ?
    then do:
      return error substitute( 'Не могу определить признак топлива для товара &1 &2 &3.&4&5&4&6'
                             , p-artic
                             , p-prod-type
                             , p-prod-code
                             , {&new-line}
                             , return-value
                             , error-status :get-message( 1 )
                             ) .
    end.
    if is-petrol <> yes or
       is-pieces <> no
    then do:
      return .
    end.
    find bf_trn-doc no-lock where
         bf_trn-doc.doc-code = p-doc-code no-error .
    if not available bf_trn-doc
    then do:
      return error substitute( 'Не найден документ № "&1".'
                             , p-doc-code
                             ) .
    end.
    if lookup( bf_trn-doc.ext-doc-type, '{&bef-TDEDT_Pri_Vnesh},{&bef-TDEDT_Ras_Vnesh},{&bef-TDEDT_Vozvrat_Vnesh}':U ) > 0
    then do:
      { gbl/hold-doc.i
          bf_trn-doc.doc-code
          is-hold
          no-error
      }
      if error-status :error or
        is-hold = ?
      then do:
        assign
          is-hold = no
        .
        return error substitute( 'Не могу определить признак межфирменности для документа № "&1".&2&3&2&4'
                               , p-doc-code
                               , {&new-line}
                               , return-value
                               , error-status :get-message( 1 )
                               ) .
      end.
      assign
        p-process = is-hold
      .
    end.
    else do:
      assign
        p-process = lookup( bf_trn-doc.ext-doc-type, '{&bef-TDEDT_Pri_Perem},{&bef-TDEDT_Ras_Perem},{&bef-TDEDT_Ras_Object},{&bef-TDEDT_Vozvrat_Perem}':U ) > 0
      .
    end.
  end. /* on error */
end procedure. /* lib-trn4_gdnorsrv */

/* В какие документы можно включать товары без резервирования по складским местам */
procedure lib-trn4_chk4rsrv :
  define  input parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
  define  input parameter p-is-hold-doc  as   logical                 no-undo .
  define output parameter p-can-process  as   logical                 no-undo initial no .

  do
  on error undo, return error return-value
  :
    if lookup( p-ext-doc-type, '{&bef-TDEDT_Pri_Vnesh},{&bef-TDEDT_Ras_Vnesh},{&bef-TDEDT_Vozvrat_Vnesh}':U ) > 0 or
       lookup( p-ext-doc-type, '{&bef-TDEDT_Pri_Perem},{&bef-TDEDT_Ras_Perem},{&bef-TDEDT_Pri_Object},{&bef-TDEDT_Ras_Object},{&bef-TDEDT_Vozvrat_Perem}':U ) > 0 and
       p-is-hold-doc = yes
    then do:
      assign
        p-can-process = yes
      .
    end.
  end. /* on error */
end procedure. /* lib-trn4_chk4rsrv */

/* ---------------------------------------------------------------------------------------------------------------------------
  Purpose:     Копирование во внеш. ПН или запрос из любого источника.

  В ПН из внешнего запроса копирует остаток от заказанного без
  уже внесенного в другие ПН (кол-во по док-ту, а не факт)
  - чтобы можно было вычислить разницу в cli-qnty.

  В ПН из др. внешней ПН копирует все количество (по док-ту)
  - чтоб работать с cli-qnty.

  В ПН из любых других док-тов копирует все количество (факт)
  - чтоб можно было делать междуфирменные перемещения через копирование.
------------------------------------------------------------------------------------------------------------------------------ */
define temp-table tt-ci_ret-doc        no-undo like lib-trn_ret-doc.
define temp-table tt-ci_ret-line       no-undo like lib-trn_ret-line.
define temp-table tt-ci_ret-line-attr  no-undo like lib-trn_ret-line-attr.
define temp-table tt-ci_ret-dtl        no-undo like lib-trn_ret-dtl.
define temp-table tt-ci_ret-parts      no-undo like lib-trn_ret-parts.

define temp-table tt-loc_ret-line      no-undo like lib-trn_ret-line.
define temp-table tt-loc_ret-line-attr no-undo like lib-trn_ret-line-attr.
define temp-table tt-loc_ret-dtl       no-undo like lib-trn_ret-dtl.
define temp-table tt-loc_ret-parts     no-undo like lib-trn_ret-parts.

procedure lib-trn4_copy-in :
define input parameter parparentproc    AS WIDGET-HANDLE           NO-UNDO.
define input parameter parrec-doc       as recid                   no-undo.
define input parameter table for tt-ci_ret-doc.
define input parameter table for tt-ci_ret-line.
define input parameter table for tt-ci_ret-line-attr.
define input parameter table for tt-ci_ret-dtl.
define input parameter table for tt-ci_ret-parts.
define input parameter parquestions       as logical                no-undo.
define input parameter parwait-on         as logical                no-undo.
define input parameter parrigid-rsrv      as logical                no-undo.
define input parameter parrsrv-fact-qnty  as logical                no-undo.
define input parameter parhandle-waitfram as handle                 no-undo.
define variable mode-create             as   logical               no-undo.
define variable rec-old                 as   recid                 no-undo.
define variable delta-line-vat          like ub.trn-doc.vat-base      no-undo.
define variable delta-line-slt          like ub.trn-doc.vat-base      no-undo.
define variable price-vat               like ub.trn-doc.vat-base      no-undo.
define variable line-rec                as   integer               no-undo.
define variable g-log                   as   logical               no-undo.
define variable varprice-cli-old        like ub.doc-line.price-cli no-undo.
define variable varprice-rubl-old       like ub.doc-line.price-cli no-undo.
define variable varprice-base-old       like ub.doc-line.price-cli no-undo.
define variable varcli-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varcli-base-rate-old    like ub.doc-line.cli-qnty  no-undo.
define variable varfact-qnty-old        like ub.doc-line.cli-qnty  no-undo.
define variable vardoc-qnty-old         like ub.doc-line.cli-qnty  no-undo.
define variable varvat-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varslt-pc-old           like ub.doc-line.vat-pc    no-undo.
define variable varroad-tax-old         like ub.doc-line.price-cli no-undo.
define variable varexcise-old           like ub.doc-line.price-cli no-undo.
define variable vartransport-rubl-old   like ub.doc-line.price-cli no-undo.
define variable varother-rubl-old       like ub.doc-line.price-cli no-undo.
define variable varlns-cnt              as   integer               no-undo.
define buffer ci_trn-doc  for ub.trn-doc.
define buffer ci_doc-line for ub.doc-line.
define buffer ci_goods    for ub.goods.

c-i:
do transaction on error undo c-i, return error return-value :
find first ci_trn-doc where recid(ci_trn-doc) = parrec-doc.
find tt-ci_ret-doc.
if ci_trn-doc.exch-code <> tt-ci_ret-doc.exch-code then do:
  if parquestions = no then do:
    return error "Валюта документа - источника не совпадает с валютой заполняемого документа.".
  end.
  else do:
    assign
    g-log = no.
    message "Валюта документа - источника не совпадает с валютой заполняемого документа !" skip
            "Цены по ТТН в добавленых строках будут неправильными !!!  Продолжать ?"
             view-as alert-box question buttons OK-Cancel update g-log.
    if not g-log then return error.
  end.
end.
if tt-ci_ret-doc.doc-type = {&income} and
   not tt-ci_ret-doc.internal then do:
  if ci_trn-doc.inv-num = ? then ci_trn-doc.inv-num = tt-ci_ret-doc.inv-num.
  if ci_trn-doc.ord-num = ? or
     ci_trn-doc.ord-num = "" then do:
    if ci_trn-doc.status_ = {&wayb} and
       tt-ci_ret-doc.status_ = {&inquiry} then do:
      ci_trn-doc.ord-num = tt-ci_ret-doc.doc-code.
    end.
    else do:
      assign
      ci_trn-doc.ord-num = tt-ci_ret-doc.ord-num.
    end.
  end.
  if ci_trn-doc.ship-date  = ?  then ci_trn-doc.ship-date  = tt-ci_ret-doc.ship-date.
  if ci_trn-doc.ship-num   = ?  then ci_trn-doc.ship-num   = tt-ci_ret-doc.ship-num.
  if ci_trn-doc.exch-date  = ?  then ci_trn-doc.exch-date  = tt-ci_ret-doc.exch-date.
  if ci_trn-doc.exch-rate  = ?  then ci_trn-doc.exch-rate  = tt-ci_ret-doc.exch-rate.
  if ci_trn-doc.exch-scale = ?  then ci_trn-doc.exch-scale = tt-ci_ret-doc.exch-scale.
end.
if ci_trn-doc.agnt       = ? then ci_trn-doc.agnt       = tt-ci_ret-doc.agnt.
if ci_trn-doc.boss       = ? then ci_trn-doc.boss       = tt-ci_ret-doc.boss.
if ci_trn-doc.wrkr       = ? then ci_trn-doc.wrkr       = tt-ci_ret-doc.wrkr.
if ci_trn-doc.base-rate  = ? then ci_trn-doc.base-rate  = tt-ci_ret-doc.base-rate.
if ci_trn-doc.base-scale = ? then ci_trn-doc.base-scale = tt-ci_ret-doc.base-scale.
if ci_trn-doc.exch-code  = ? then ci_trn-doc.exch-code  = tt-ci_ret-doc.exch-code.
assign
varlns-cnt = 0.
if parwait-on then do:
  run waitfram-show in parhandle-waitfram ("Добавление строк из документа - источника. ЖДИТЕ ...") no-error.
end.

for each tt-ci_ret-line use-index line-num on error undo, return error return-value :
   find first ci_goods where ci_goods.artic     = tt-ci_ret-line.artic         and
                             ci_goods.prod-type = tt-ci_ret-line.prod-type and
                             ci_goods.prod-code = tt-ci_ret-line.prod-code no-lock.
   { str/goods-tr.i
     recid(ci_trn-doc)
     recid(ci_goods)
     no-error }
   if error-status :error then do:
     if parrigid-rsrv then do:
       undo, return error substitute ("&1 &2", error-status :get-message(1), return-value).
     end.
     else do:
       message
       error-status :get-message(1) skip
       return-value
       view-as alert-box.
       undo, next.
     end.
   end.
   find first ci_doc-line where ci_doc-line.doc-code  = ci_trn-doc.doc-code     and
                                ci_doc-line.artic     = ci_goods.artic      and
                                ci_doc-line.prod-type = ci_goods.prod-type  and
                                ci_doc-line.prod-code = ci_goods.prod-code  no-error.
   if available ci_doc-line then do:
      assign
      mode-create = no
      varprice-cli-old       = ci_doc-line.price-cli
      varprice-rubl-old      = ci_doc-line.price-rubl
      varprice-base-old      = ci_doc-line.price-base
      varcli-qnty-old        = ci_doc-line.cli-qnty
      varcli-base-rate-old   = ci_doc-line.cli-base-rate
      varfact-qnty-old       = ci_doc-line.fact-qnty
      vardoc-qnty-old        = ci_doc-line.doc-qnty
      varvat-pc-old          = ci_doc-line.vat-pc
      varslt-pc-old          = ci_doc-line.slt-pc
      varroad-tax-old        = ci_doc-line.road-tax
      varexcise-old          = ci_doc-line.excise
      vartransport-rubl-old  = ci_doc-line.transport-rubl
      varother-rubl-old      = ci_doc-line.other-rubl.
   end.
   else mode-create = yes.
   line-rec = ?.
   for each tt-loc_ret-line on error undo, return error return-value :
     delete tt-loc_ret-line.
   end.
   for each tt-loc_ret-line-attr on error undo, return error return-value :
     delete tt-loc_ret-line-attr.
   end.
   for each tt-loc_ret-dtl on error undo, return error return-value :
     delete tt-loc_ret-dtl.
   end.
   for each tt-loc_ret-parts on error undo, return error return-value :
     delete tt-loc_ret-parts.
   end.
   create tt-loc_ret-line.
   buffer-copy tt-ci_ret-line to tt-loc_ret-line.
   for each tt-ci_ret-line-attr where tt-ci_ret-line-attr.doc-code  = tt-loc_ret-line.doc-code  and
                                      tt-ci_ret-line-attr.gds-code  = ci_goods.gds-code on error undo, return error return-value     :
      create tt-loc_ret-line-attr.
      buffer-copy tt-ci_ret-line-attr to tt-loc_ret-line-attr.
   end.

   for each tt-ci_ret-dtl where tt-ci_ret-dtl.doc-code  = tt-loc_ret-line.doc-code  and
                                tt-ci_ret-dtl.artic     = tt-loc_ret-line.artic     and
                                tt-ci_ret-dtl.prod-type = tt-loc_ret-line.prod-type and
                                tt-ci_ret-dtl.prod-code = tt-loc_ret-line.prod-code on error undo, return error return-value :
     create tt-loc_ret-dtl.
     buffer-copy tt-ci_ret-dtl to tt-loc_ret-dtl.
   end.
   for each tt-ci_ret-parts where tt-ci_ret-parts.out-code  = tt-loc_ret-line.doc-code  and
                                  tt-ci_ret-parts.obj-type  = tt-ci_ret-doc.obj-type    and
                                  tt-ci_ret-parts.obj-code  = tt-ci_ret-doc.obj-code    and
                                  tt-ci_ret-parts.artic     = tt-loc_ret-line.artic     and
                                  tt-ci_ret-parts.prod-type = tt-loc_ret-line.prod-type and
                                  tt-ci_ret-parts.prod-code = tt-loc_ret-line.prod-code on error undo, return error return-value :
     create tt-loc_ret-parts.
     buffer-copy tt-ci_ret-parts to tt-loc_ret-parts.
   end.
   { str/copy-inh.i
     parparentproc
     recid(ci_trn-doc)
     "'copy':U"
     yes
     parrsrv-fact-qnty
     tt-ci_ret-doc
     tt-loc_ret-line
     tt-loc_ret-line-attr
     tt-loc_ret-dtl
     tt-loc_ret-parts
     no-error
   }
   if error-status :error then do:
      if parrigid-rsrv then do:
        undo c-i, return error return-value.
      end.
      else do:
        if parquestions then do:
          assign g-log = no.
          message "Ошибка при копировании в документ." skip
                  return-value skip
                  "Будем обрабатывать другие строки документа?"
                  view-as alert-box question buttons yes-no update g-log.
          if g-log = yes then do:
            next.
          end.
          else do:
            run waitfram-hide in parhandle-waitfram no-error.
            undo, return error return-value .
          end.
        end.
        else do:
          next.
        end.
      end.
   end.
   find first ci_doc-line where ci_doc-line.doc-code  = ci_trn-doc.doc-code and
                                ci_doc-line.artic     = ci_goods.artic      and
                                ci_doc-line.prod-type = ci_goods.prod-type  and
                                ci_doc-line.prod-code = ci_goods.prod-code  no-error.
  if available ci_doc-line then do:

    /* проверяем ситуацию, когда в линии накладной пустая строчка вместо единиц измерения */  
    if ci_doc-line.unit-cli = ? OR ci_doc-line.unit-cli = "" then do:
        ci_doc-line.unit-cli = ci_goods.unit-cli.
    end. 

    if mode-create then do:
     { str/clcintrn.i
       parparentproc
        recid(ci_doc-line)
        ci_doc-line.doc-code
        ci_doc-line.artic
        ci_doc-line.prod-type
        ci_doc-line.prod-code
        0
        0
        0
        0
        0
        0
        0
        0
        0
        0
        0
        0
        0
       "'create'"
       "''"
       no-error
     }
     if error-status :error then undo c-i, return error return-value.
    end.
    else do:
      { str/clcintrn.i
        parparentproc
        recid(ci_doc-line)
        ci_doc-line.doc-code
        ci_doc-line.artic
        ci_doc-line.prod-type
        ci_doc-line.prod-code
        varprice-cli-old
        varprice-rubl-old
        varprice-base-old
        varcli-qnty-old
        varcli-base-rate-old
        varfact-qnty-old
        vardoc-qnty-old
        varvat-pc-old
        varslt-pc-old
        varroad-tax-old
        varexcise-old
        vartransport-rubl-old
        varother-rubl-old
        "'update'"
        "''"
        no-error
      }
      if error-status :error then undo c-i, return error return-value.
    end.
    run str/chk-prt.p (recid(ci_doc-line), no, buffer ci_trn-doc).
  end.
  varlns-cnt = varlns-cnt + 1.
  if parwait-on then do:
    run waitfram-show in parhandle-waitfram ("Добавление из документа - источника. Обработано : " + string (varlns-cnt)) no-error.
  end.
end.
if parwait-on then do:
  run waitfram-hide in parhandle-waitfram no-error.
end.
end.
end procedure.


procedure lib-trn4_int-clos :

  define input  parameter parparentproc as widget-handle no-undo.
  define input  parameter p-doc-code    as character no-undo .
  define output parameter table for gds-list .

  define variable varmode            as   character           no-undo.
  define variable varstatus          like ub.trn-doc.status_  no-undo.
  define variable varflag            like ub.trn-doc.flag_    no-undo.
  define variable varcopystatus      like ub.trn-doc.status_  no-undo.
  define variable varcopyflag        like ub.trn-doc.flag_    no-undo.
  define variable varpercent-expense as decimal   no-undo .
  define variable varperc-expvalue   as character no-undo .
  define variable varperc-exptype    as character no-undo .
  define variable varchg-inv         as logical   no-undo .
  define variable varvalue           as character no-undo .
  DEFINE VARIABLE varvalue_massa-sug as character no-undo .
  DEFINE VARIABLE varvalue_teh-loss  as character no-undo .
  DEFINE VARIABLE varvalue_err-allow as character no-undo .
  define variable vartype            as character no-undo .
  define variable skip-all           as logical   no-undo initial no .
  define variable skip-zero          as logical   no-undo initial no .
  define variable v-num              as integer   no-undo initial ? .
  define variable l_can-close_ee-ep  as logical   no-undo .
  define variable l_is-hold-doc      as logical   no-undo .
  define variable vardb-num          like ub.clients.db-num   no-undo.
  define variable varfact-date       as date      no-undo .
  define variable varshift-date      as date      no-undo .
  define variable varshift-num       as integer   no-undo .
  define variable varshift-name      as character no-undo .
  define variable varlog             as logical   no-undo .
  define variable varcheck-return    as logical   no-undo .
  define variable v-error            as logical   no-undo .
  define variable v-user-action      as character no-undo .
  define variable v-printed          as logical   no-undo .
  define variable v-event-code       as character no-undo .
  define variable v-close-type       as integer   no-undo .
  define variable v-not-eq-count     as int       no-undo .
  define variable v-is-petrl         as logical   no-undo .
  define variable v-is-pieces        as logical   no-undo .

  /* два комплекта переменных для проверки если тип = Товар платёжного агента */
  define variable v-pay-agent-gd1    as integer no-undo .
  define variable v-pay-agent-nm1    as character no-undo .
  define variable v-pay-agent-ar1    as character no-undo .
  define variable v-pay-agent-fl1    as logical no-undo .
  define variable v-pay-agent-gd2    as integer no-undo .
  define variable v-pay-agent-nm2    as character no-undo .
  define variable v-pay-agent-ar2    as character no-undo .
  define variable v-pay-agent-fl2    as logical no-undo .
  
  { gbl/getcntxt.i def }
  { str/getctxtp.i def }

define buffer bf-db_clients for ub.clients.
define buffer buf_trn-doc   for ub.trn-doc .
define buffer exp_trn-doc   for ub.trn-doc .
define buffer buf_parts     for ub.parts  .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_gds-dtl   for ub.gds-dtl .
define buffer buf_goods for ub.goods .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_marking for ub.marking .

define variable var-ok-assort-pol   as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-file-n as character no-undo .
define variable v-ischg-ext-type as logical no-undo .
define variable v-is-exemplar-goods as logical   no-undo .
define variable v-mark-weight as decimal   no-undo .
define variable v-isweighed as logical   no-undo .
define variable v-message           as character no-undo .
define variable v-scan-qnty as  integer   no-undo. 
define variable v-GTIN     as character no-undo .
define variable v-codident as character no-undo.

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Номер документа" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    
    if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
    then do:
      buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}.
      buf_trn-doc.internal = false.
      buf_trn-doc.discnt-type = "".
      v-ischg-ext-type = true.
      buf_trn-doc.tot-cli = buf_trn-doc.tot-calc.
      buf_trn-doc.fact-date = today.
      for first buf_parts no-lock where buf_parts.out-code = buf_trn-doc.doc-code :
        buf_trn-doc.slt-type = buf_parts.slt-type .
      end .
    end.
    

    v-file-n = replace( buf_trn-doc.doc-code, "*", "$" ) .
    v-file-n = replace( v-file-n , ".", "$" ) .
    v-file-n = replace( v-file-n , "/", "$" ) .
    v-file-n = replace( v-file-n, "\", "$" ) .
    v-file-n = replace( v-file-n, "=", "$" ) .


    { gbl/getcntxt.i get }
    { str/getctxtp.i get }

    { gbl/hold-doc.i
      buf_trn-doc.doc-code
      l_is-hold-doc
      no-error }
    if error-status :error or l_is-hold-doc = ? then do:
       assign l_is-hold-doc = no
       .
    end.

    if  buf_trn-doc.doc-type = {&expense}
    and not buf_trn-doc.flag_
    and buf_trn-doc.status_ <> {&permitted}
    then do:
      define buffer buf_user-login for ub.user-login .
      find buf_user-login no-lock
        where buf_user-login.db-num  = v-cntxt-db-num
          and buf_user-login.user-id = v-cntxt-userid
        .
      if  buf_trn-doc.discnt-pc > buf_user-login.max-discnt
      and lookup(buf_trn-doc.discnt-type, {&cash-desk_card_group}) = 0
      then do:
          message "Скидка по документу " buf_trn-doc.discnt-pc skip
                  " превышает максимально допустимую величину для данного пользователя (" buf_user-login.max-discnt "%).".
          return error.
      end.
    end.
    find first bf-db_clients where bf-db_clients.obj-type = buf_trn-doc.obj-type and
                                  bf-db_clients.obj-code = buf_trn-doc.obj-code no-lock.
    /* Проверка, что документ внутреннего прихода не был раньше документа внутреннего расхода */
    if buf_trn-doc.doc-type = {&income} and
       buf_trn-doc.status_  = {&wayb}   and
       buf_trn-doc.internal = yes       and
       buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Object} then do:
      find first exp_trn-doc where exp_trn-doc.doc-code = buf_trn-doc.doc-code no-lock no-error.
      { gbl/objdtget.i buf_trn-doc.obj-type buf_trn-doc.obj-code varfact-date no-error }
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении текущей даты объекта" skip
          return-value skip
          trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
          trim(error-status :get-message(4))
          trim(error-status :get-message(5)) skip
          view-as alert-box error.
          return error .
      end.
      define variable l-shift-on as logical no-undo .
      { gbl/objat.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        "'shift-on=request'"
        l-shift-on
      }
      if l-shift-on then do:
      { gbl/curshift.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          varshift-date
          varshift-num
          varshift-name
          no-error
        }
        if error-status:error then do:
          message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении текущей сменной даты объекта" skip
          return-value skip
          trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
          trim(error-status :get-message(4))
          trim(error-status :get-message(5)) skip
          view-as alert-box error.
          return error .
        end.
      end.
      if available exp_trn-doc and
        exp_trn-doc.fact-date < varfact-date then do:
        assign varlog = no.
        message "Внутренний приход " buf_trn-doc.doc-code " будет закрыт с фактической календарной датой: " varfact-date skip
                "Внутренний расход " exp_trn-doc.doc-code " с объекта " exp_trn-doc.obj-type " " exp_trn-doc.doc-code " был календарной датой " exp_trn-doc.fact-date skip
                "Дата расхода меньше даты прихода. Продолжить?" view-as alert-box question update varlog.
        if not varlog then  return error.
      end.
      if available exp_trn-doc and
        (exp_trn-doc.shift-date < varshift-date or
          exp_trn-doc.shift-date = varshift-date and exp_trn-doc.shift-num < varshift-num) then do:
        assign varlog = no.
        message "Внутренний приход " buf_trn-doc.doc-code " будет закрыт с фактической сменой: " varshift-date " " varshift-num skip
                "Внутренний расход " exp_trn-doc.doc-code " с объекта " exp_trn-doc.obj-type " " exp_trn-doc.doc-code " был сменной датой " exp_trn-doc.shift-date " " exp_trn-doc.shift-num skip
                "Смена расхода меньше смены прихода. Продолжить?" view-as alert-box question update varlog.
        if not varlog then  return error.
      end.
    end.
    if  buf_trn-doc.doc-type = {&income}
    and not buf_trn-doc.internal
    and not buf_trn-doc.flag_
    and buf_trn-doc.status_ = {&wayb}
    then do:
        /*
      if buf_trn-doc.tot-cli = 0 then do:
        message "Вы не ввели сумму для проверки." view-as alert-box information.
        return error.
      end.
      */
      if v-cntxt-db-num  = bf-db_clients.db-num then do:
        run gbl/d-askw.w
          (input "Вопрос" /* Заголовок окна */
          ,input "Закрытие приходной накладной" + {&new-line} /* Общее сообщение */
            + substitute("ПН        &1", buf_trn-doc.doc-code) + {&new-line}
            + substitute("Дата      &1", string(buf_trn-doc.doc-date, '99/99/9999':u)) + {&new-line}
            + (if buf_trn-doc.fact-date <> ? then substitute("Факт дата &1", string(buf_trn-doc.fact-date, '99/99/9999':u)) else "") + {&new-line}
            + substitute("Оператор  &1 (&2)", usrfulnf( buf_trn-doc.user-name) , buf_trn-doc.user-name )
          ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                      /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                      /* второй символ - разделитель атрибутов в описании кнопок */
          ,input "Накл+" + '|':u
              + "Факт+" + '|':u
              + "Отмена" /* список названий кнопок  */
                          /* каждая кнопка может иметь необязательный */
                          /* список атрибутов, влияющих на поведение кнопки */
          ,input "С редактированием фактически принятого количества (накл+)|" /* список описаний кнопок */
              + "Без редактирования (факт+)|"
              + "Отмена закрытия приходной накладной"
          ,input 1 /* значение возвращаемое при нажатии enter */
          ,input 3 /* значение возвращаемое при нажатии escape */
          ,output v-close-type /* выбор пользователя */
          ).
        case v-close-type
        :
          when 1
          then do:
            define buffer buf_utd for ub.utd .
            if can-find(first buf_utd no-lock where buf_utd.doc-code = buf_trn-doc.doc-code)
            then do :
              message "Для накладных созданных на основе электронных документов возможно только закрытие на Факт!" view-as alert-box .
              return error .
            end .
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_income_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
            /* 05/III-2019 остальные не используются: Сверху if buf_trn-doc.doc-type = {&income} в строке 687     
            case buf_trn-doc.doc-type
            :
              when {&income}
              then do:
              end.
              when {&expense}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_expense_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&write-off}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_write-off_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&inventory}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_inventory_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&return}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_return_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            */
            if not varlog then  return error.
            assign
              varmode = {&close-doc}
            .
          end.
          when 2
          then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_income_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
            /* 05/III-2019 остальные не используются: Сверху if buf_trn-doc.doc-type = {&income} в строке 687     
            case buf_trn-doc.doc-type
            :
              when {&income}
              then do:
              end.
              when {&expense}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_expense_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&write-off}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_write-off_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&inventory}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_inventory_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&return}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_return_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            */
            if not varlog then  return error.
            assign
              varmode = {&close-fact}
            .
          end.
          when 3
          then do:
            return error.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Способ закрытия накладной" skip
              "Неизвестное значение" v-num skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
      end.
      else do:
        assign varmode = {&close-doc}. /* граф стандартных переходов */
      end.
    end.
    else if  buf_trn-doc.doc-type = {&expense}
    and not buf_trn-doc.internal
    and not buf_trn-doc.flag_
    and buf_trn-doc.status_ = {&wayb}
    and not buf_trn-doc.is-flora
    then do:
      if v-cntxt-db-num  = bf-db_clients.db-num then do:
        run gbl/d-askw.w
          (input "Вопрос" /* Заголовок окна */
          ,input "Закрытие расходной накладной" + {&new-line} /* Общее сообщение */
            + substitute("РН        &1", buf_trn-doc.doc-code) + {&new-line}
            + substitute("Дата      &1", string(buf_trn-doc.doc-date, '99/99/9999':u)) + {&new-line}
            + (if buf_trn-doc.fact-date <> ? then substitute("Факт дата &1", string(buf_trn-doc.fact-date, '99/99/9999':u)) else "") + {&new-line}
            + substitute("Оператор  &1 (&2)", usrfulnf( buf_trn-doc.user-name) , buf_trn-doc.user-name )
          ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                      /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                      /* второй символ - разделитель атрибутов в описании кнопок */
          ,input "Накл+" + '|':u
               + "Факт+" + '|':u
               + "Отмена" /* список названий кнопок  */
                          /* каждая кнопка может иметь необязательный */
                          /* список атрибутов, влияющих на поведение кнопки */
          ,input "Без редактирования фактического количества (накл+)|" /* список описаний кнопок */
               + "Без редактирования (факт+)|"
               + "Отмена закрытия расходной накладной"
          ,input 1 /* значение возвращаемое при нажатии enter */
          ,input 3 /* значение возвращаемое при нажатии escape */
          ,output v-close-type /* выбор пользователя */
          ).
        case v-close-type
        :
          when 1
          then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_expense_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
            /* 05/III-2019 остальные не используются: Сверху if buf_trn-doc.doc-type = {&expense} в строке 963     
            case buf_trn-doc.doc-type
            :
              when {&income}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_income_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&expense}
              then do:
              end.
              when {&write-off}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_write-off_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&inventory}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_inventory_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&return}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_return_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            */
            if not varlog then  return error.
            assign
              varmode = {&close-doc}
            .
          end.
          when 2
          then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_expense_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
            /* 05/III-2019 остальные не используются: Сверху if buf_trn-doc.doc-type = {&expense} в строке 963     
            case buf_trn-doc.doc-type
            :
              when {&income}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_income_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&expense}
              then do:
              end.
              when {&write-off}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_write-off_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&inventory}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_inventory_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&return}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_return_fact':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            */
            if not varlog then  return error.
            assign
              varmode = {&close-fact}
            .
          end.
          when 3
          then do:
            return error.
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Способ закрытия накладной" skip
              "Неизвестное значение" v-num skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
      end.
      else do:
        assign varmode = {&close-doc}. /* граф стандартных переходов */
      end.
    end. /*внешний расход сразу до статуса*/
    else do:
        assign varmode = {&close-doc}. /* граф стандартных переходов */
    end.

    run str/trn-graf.p (input  buf_trn-doc.doc-code,
                    input  v-cntxt-db-num,
                    input  varmode,
                    output varstatus,
                    output varflag,
                    output varcopystatus,
                    output varcopyflag
                    ) no-error.

    if error-status:error then do:
      if error-status :get-message(1) <> "" or
          return-value = ""                  then do:
        message "Ошибка при вызове trn-graf.p." skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      end.
      else do:
        message return-value
        view-as alert-box error.
      end.
      return error.
    end.


    /* проверка закрытие документа задним числом за определенную дату */
    if buf_trn-doc.fact-date <> ?
    then do:
      if varstatus = {&fact}
      then do:
        run str/chk-back.p
          (input buf_trn-doc.doc-code  /* p-doc-code  */
          ,input buf_trn-doc.fact-date /* p-fact-date */
          ) no-error .
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          or return-value = ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры chk-back.p" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          else do:
            message
              return-value skip
              view-as alert-box error .
          end.
          return error .
        end.
      end.
    end.

    /* проверка, что товары с типом Товар платежного агента не пересекается в документе с обычными товарами
    
       Товар платёжного агента привязан к оператору сотовой связи.
       У обычного товара привязка к оператору сотовой связи отсутствует.
       Привязка к оператору сотовой связи хранится в goods-attr в атрибуте attr-code = {&attr-oper-serv-id}
       Значением атрибута является string(OperServ.id)
    */
    if buf_trn-doc.doc-type = {&inventory} then do :
      assign
        v-pay-agent-fl1 = false
        v-pay-agent-fl2 = false
      .
      for each ub.doc-line where ub.doc-line.doc-code = buf_trn-doc.doc-code:
        find first ub.goods no-lock
             where ub.goods.artic     = ub.doc-line.artic
               and ub.goods.prod-type = ub.doc-line.prod-type
               and ub.goods.prod-code = ub.doc-line.prod-code no-error.
        if available ub.goods then do :
          if can-find (first ub.goods-attr
                       where ub.goods-attr.gds-code   = ub.goods.gds-code
                         and ub.goods-attr.attr-code  = {&attr-oper-serv-id})
          then do :
            assign
              v-pay-agent-gd1 = ub.goods.gds-code
              v-pay-agent-nm1 = ub.goods.gds-name
              v-pay-agent-ar1 = ub.doc-line.artic
              v-pay-agent-fl1 = true
            .
            if v-pay-agent-fl2 then leave .
          end .
          else do :
            assign
              v-pay-agent-gd2 = ub.goods.gds-code
              v-pay-agent-nm2 = ub.goods.gds-name
              v-pay-agent-ar2 = ub.doc-line.artic
              v-pay-agent-fl2 = true
            .
            if v-pay-agent-fl1 then leave .
          end .
        end . /* end_of available_goods */
      end. /* end_of for_each_doc-line */
      if v-pay-agent-fl1 and v-pay-agent-fl2 then do :
        message
          substitute("Ошибка закрытия документа &1", buf_trn-doc.doc-code) skip
          substitute("Товар платёжного агента &1 &2 (арт. &3) " +
                     "должен проводиться отдельным документом от обычного товара &4 &5 (арт. &6)",
            v-pay-agent-gd1, v-pay-agent-nm1, v-pay-agent-ar1,
            v-pay-agent-gd2, v-pay-agent-nm2, v-pay-agent-ar2
                    )
        view-as alert-box .
        return error.
      end . 
    end . /* end_of doc-type={&inventory} */

    if varstatus = {&fact} and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}) 
    then do:


      if can-find (ub.doc-attr where ub.doc-attr.doc-code = buf_trn-doc.doc-code and ub.doc-attr.attr-code = {&trdcattr-negais})
      then do:
      
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_egais-chg-sts-doc':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          false
          varlog
        }
        if not varlog
        then do:
          if not can-find (ub.doc-attr where ub.doc-attr.doc-code = buf_trn-doc.doc-code and ub.doc-attr.attr-code = {&trdcattr-egais} and ub.doc-attr.attr-value = "Accepted" ) 
          then do:
            message 'Для закрытия накладной на факт, которая отправлена в ЕГАИС и отсутствует акт подтверждения от контрагента, требуется право "Изменение статуса документа ЕГАИС".'
            view-as alert-box error.
            return error.
          end.
        end.
        else do:
          varlog = false.
          message "Вы уверены что хотите закрыть накладную, которая отправлена в ЕГАИС и отсутствует акт подтверждения от контрагента?"
                "Вы уверены ?" view-as alert-box question buttons OK-Cancel update varlog.
          if not varlog 
            then return error. 
        end.
      
      
      end.
    end.


    if buf_trn-doc.flag_                and
      buf_trn-doc.status_ = {&inquiry} then do:
    varlog = no.
    message "Создание накладной по запросу №" buf_trn-doc.doc-code skip (2)
            (if buf_trn-doc.doc-type  = {&income} and
                buf_trn-doc.internal = no then "В новую ПН будет скопировано из запроса все, что еще не включено в другие ПН по этому запросу."
              else "При недостатке товара запрос по некоторым товарам (признакам) может быть удовлетворен ЧАСТИЧНО.")
            "Вы уверены ?" view-as alert-box question buttons OK-Cancel update varlog.
    if not varlog then  return error.
      case buf_trn-doc.doc-type
      :
        when {&income}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_income_preparation':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        when {&expense}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_expense_preparation':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        when {&write-off}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_write-off_preparation':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        when {&inventory}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_inventory_preparation':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        when {&return}
        then do:
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_return_preparation':U
            {&cntxt-object}
            buf_trn-doc.host-code
            buf_trn-doc.obj-type
            buf_trn-doc.obj-code
            0
            0
            0
            true
            varlog
          }
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" skip
            "Тип документа" buf_trn-doc.doc-type skip
            "Код документа" buf_trn-doc.doc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .

    if not varlog then  return error.
    end. /*запр+*/
    else do:
      if varstatus = {&fact} then do:
        if v-cntxt-db-num <> bf-db_clients.db-num then do:
          message "Накладную можно закрыть на факт только на базе данных объекта"
          view-as alert-box error.
          return error.
        end.
        varlog = no.
        if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object} then do :
            varlog = yes.
        end.
        else do :
          if is-mes(buf_trn-doc.doc-code) then do:
            varlog = false .
          end.
          else do:
          if buf_trn-doc.reason-code = 99 then
          do:  
          varvalue = "" . /* закрытие накладной по СУГ и основание «Финальный слив СУГ», то проверим данные по тех.потерям */
            { str/tdat-val.i
              buf_trn-doc.doc-code
              {&sugtpattr-massa-sug}
              varvalue_massa-sug
              vartype
              no-error
            }
            { str/tdat-val.i
              buf_trn-doc.doc-code
              {&sugtpattr-teh-loss}
              varvalue_teh-loss
              vartype
              no-error
            }
             { str/tdat-val.i
              buf_trn-doc.doc-code
              {&sugtpattr-err-allow}
              varvalue_err-allow
              vartype
              no-error
            }       
            if varvalue_err-allow = '' or varvalue_teh-loss = '' or varvalue_massa-sug = '' then                
            varvalue = "Не заполнены данные для расчета технологических потерь.~n" .
              else varvalue = "".
          end.
          message varvalue
                  "Закрыть накладную № " buf_trn-doc.doc-code " до статуса ФАКТ?" skip (2)
                  view-as alert-box question buttons OK-Cancel title "Вопрос" update varlog.
        end.
        if not varlog then  return error.
        case buf_trn-doc.doc-type
        :
          when {&income}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_income_fact':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&expense}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_expense_fact':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&write-off}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_write-off_fact':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&inventory}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_inventory_fact':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&return}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_return_fact':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" skip
              "Тип документа" buf_trn-doc.doc-type skip
              "Код документа" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if not varlog then  return error.

       end.
       end.
      else do:
        if can-do ({&expense_write-off_return}, buf_trn-doc.doc-type) and
                  buf_trn-doc.status_   = {&wayb}                     and
                  buf_trn-doc.flag_                                   then do:
            message "Разрешение по накладной № " buf_trn-doc.doc-code skip (2)
                    "Вы уверены ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
            if not varlog then  return error.
            case buf_trn-doc.doc-type
            :
              when {&income}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_income_permission':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&expense}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_expense_permission':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&write-off}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_write-off_permission':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&inventory}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_inventory_permission':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&return}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_return_permission':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            if not varlog then  return error.
        end.
        else do:
          if buf_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
            if buf_trn-doc.status_ = {&wayb} then do:
              if buf_trn-doc.flag_   = no      then do:
                  case buf_trn-doc.doc-type
                  :
                    when {&income}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_income_preparation':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    when {&expense}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_expense_preparation':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    when {&write-off}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_write-off_preparation':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    when {&inventory}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_inventory_preparation':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    when {&return}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_return_preparation':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    otherwise do:
                      message
                        vss-workfile vss-revision vss-description skip
                        "Неизвестный тип документа" skip
                        "Тип документа" buf_trn-doc.doc-type skip
                        "Код документа" buf_trn-doc.doc-code skip
                        view-as alert-box error .
                      undo, return error return-value .
                    end.
                  end case .
                if not varlog then return error .
                varlog = no.
                /*Проверка документа, нужно сообщение или нет*/
                if not is-mes(buf_trn-doc.doc-code) then do: 
                message
                  "Документ №" buf_trn-doc.doc-code skip (2)
                  "Закрыть ОПИСЬ инвентаризации?" skip
                  "Вы уверены?"
                  view-as alert-box question buttons OK-Cancel update varlog.
                  if not varlog then return error .
				end.
              end.
              else do:
                  case buf_trn-doc.doc-type
                  :
                    when {&income}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_income_permission':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    when {&expense}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_expense_permission':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    when {&write-off}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_write-off_permission':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    when {&inventory}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_inventory_permission':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    when {&return}
                    then do:
                      { gbl/chk-actg.i
                        v-cntxt-db-num
                        v-cntxt-userid
                        {&action-head-code-main}
                        'actn_return_permission':U
                        {&cntxt-object}
                        buf_trn-doc.host-code
                        buf_trn-doc.obj-type
                        buf_trn-doc.obj-code
                        0
                        0
                        0
                        true
                        varlog
                      }
                    end.
                    otherwise do:
                      message
                        vss-workfile vss-revision vss-description skip
                        "Неизвестный тип документа" skip
                        "Тип документа" buf_trn-doc.doc-type skip
                        "Код документа" buf_trn-doc.doc-code skip
                        view-as alert-box error .
                      undo, return error return-value .
                    end.
                  end case .
                if not varlog then return error .
                varlog = no.
                if not is-mes(buf_trn-doc.doc-code) then do:
                message
                  "Документ №" buf_trn-doc.doc-code skip (2)
                  "Начать инвентаризацию по документу?" skip
                  "Вы уверены?" skip
                  view-as alert-box question buttons OK-Cancel update varlog.
                if not varlog then return error.
				end.
              end.
            end.
            else do:
                message "Ошибка при закрытии инвентаризации."
                        "Инвентаризация должна закрываться на факт."
                        view-as alert-box error.
                return error.
            end.
          end.
          else do:
            varlog = no.
            message "Документ :" buf_trn-doc.status_ "№" buf_trn-doc.doc-code skip
                    "Вы уверены, что хотите завершить ввод и редактирование ?"
                    view-as alert-box question buttons OK-Cancel update varlog.
            if not varlog then  return error.
            case buf_trn-doc.doc-type
            :
              when {&income}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_income_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&expense}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_expense_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&write-off}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_write-off_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&inventory}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_inventory_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              when {&return}
              then do:
                { gbl/chk-actg.i
                  v-cntxt-db-num
                  v-cntxt-userid
                  {&action-head-code-main}
                  'actn_return_preparation':U
                  {&cntxt-object}
                  buf_trn-doc.host-code
                  buf_trn-doc.obj-type
                  buf_trn-doc.obj-code
                  0
                  0
                  0
                  true
                  varlog
                }
              end.
              otherwise do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Неизвестный тип документа" skip
                  "Тип документа" buf_trn-doc.doc-type skip
                  "Код документа" buf_trn-doc.doc-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end case .
            if not varlog then  return error.
          end.
        end.
      end.
    end.

    if buf_trn-doc.doc-type <> {&inventory} then do:
      for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code:
        find first buf_goods where buf_goods.artic     = buf_doc-line.artic     and
                                buf_goods.prod-type = buf_doc-line.prod-type and
                                buf_goods.prod-code = buf_doc-line.prod-code no-lock.
        if varstatus         =  {&fact}            and
          buf_doc-line.doc-qnty <> buf_doc-line.fact-qnty then do:
          /* Если РН МФ то нельзя делать 0 !*/
          if buf_doc-line.fact-qnty = 0  and  l_is-hold-doc and buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} then do:
          message "Артикул: " buf_doc-line.artic " " buf_goods.gds-name skip
                  "Фактическое количество по строке: " buf_doc-line.fact-qnty " " buf_goods.unit-base skip(2)
                  "Для межфирменного перемещения это запрещено"
                  view-as alert-box error  .
             return error.
          end.
          if (v-not-eq-count <> 2) then do: /* <> Да для всех */
              
              { str/is-petrl.i
                buf_doc-line.artic
                buf_doc-line.prod-type
                buf_doc-line.prod-code
                v-is-petrl
                v-is-pieces
              }
              
              if v-is-petrl = true
                and v-is-pieces = false 
              then do:
                /*run gbl/d-askw.w(
                    input "Накладная"
                    ,"Артикул: " + string(buf_doc-line.artic) + " " + buf_goods.gds-name + {&new-line} +
                                  "Количество по строке накладной: " + string(buf_doc-line.cli-qnty) + " " + string(buf_goods.unit-cli) + {&new-line} +
                                  "Фактическое количество по строке: " + string(buf_doc-line.fact-qnty * buf_doc-line.fact-density) + " " + string(buf_goods.unit-cli) + {&new-line} +
                                  "Подтвердить количество в накладной?"
                  ,input "|^"
                  ,input "Да|Да (для всех)|Нет"
                  ,input "подтвердить для текущей позиции|подтвердить для всех позиций|отменить переход документа в статус факт"
                  ,input 1
                  ,input 3
                  ,output v-not-eq-count
                  ).*/
                  v-not-eq-count = 2.
                end.
                else do:
                  run gbl/d-askw.w(
                      input "Накладная"
                      ,"Артикул: " + string(buf_doc-line.artic) + " " + buf_goods.gds-name + {&new-line} +
                                    "Количество по строке накладной: " + string(buf_doc-line.doc-qnty) + " " + string(buf_goods.unit-base) + {&new-line} +
                                    "Фактическое количество по строке: " + string(buf_doc-line.fact-qnty) + " " + string(buf_goods.unit-base) + {&new-line} +
                                    "Подтвердить количество в накладной?"
                    ,input "|^"
                    ,input "Да|Да (для всех)|Нет"
                    ,input "подтвердить для текущей позиции|подтвердить для всех позиций|отменить переход документа в статус факт"
                    ,input 1
                    ,input 3
                    ,output v-not-eq-count
                    ).
                end.
                if (v-not-eq-count = 3) then return error.
            end.
          /*if not varlog then  return error.*/
        end.
      end.
    end.
    
    if buf_trn-doc.doc-type = {&income} and
      buf_trn-doc.internal = no        then do: /*Выделеные проверки внешнего прихода*/
      for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code:
        find first buf_goods where buf_goods.artic     = buf_doc-line.artic     and
                                buf_goods.prod-type = buf_doc-line.prod-type and
                                buf_goods.prod-code = buf_doc-line.prod-code no-lock.
          run str/chk-prt.p (recid(buf_doc-line), yes , buffer buf_trn-doc).
          if (not buf_trn-doc.flag_ and buf_doc-line.doc-qnty = 0) or
              (buf_trn-doc.flag_     and buf_doc-line.fact-qnty = 0) then do:
              varlog = no.
              message "Артикул : " buf_doc-line.artic buf_goods.gds-name ". Ед. изм. :" buf_goods.unit-base
                      skip
                      "По этой строке НУЛЕВОЕ количество !"
                      skip (2)
                      "Будем закрывать документ?"
                      view-as alert-box question buttons yes-no update varlog.
              if not varlog then  return error.
            end.
            if varstatus <> {&fact} and buf_doc-line.prt-OK = ? then do:
              varlog = yes.
              message "Артикул : " buf_doc-line.artic buf_goods.gds-name skip
                      "Не указаны количества по шкале." skip (2)
                      "Вы хотите, чтобы это было сделано на складе при ФАКТ закрытии ?" skip (2)
                      "Будем закрывать документ?"
                      view-as alert-box question buttons yes-no update varlog.
              if not varlog then  return error.
            end.
      end.
      { gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
      for each thbjattr_thbj-attr :
          if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_prc-exp} then varperc-expvalue = string(thbjattr_thbj-attr.property-value-decimal) .
      end.
      empty temp-table thbjattr_thbj-attr.
      if varperc-expvalue = ? then varpercent-expense = 5.
                              else varpercent-expense = decimal(varperc-expvalue).
      if buf_trn-doc.tot-transp / buf_trn-doc.tot-cli * 100 > varpercent-expense then do:
          varlog = no.
          message "Транспортные расходы больше " varpercent-expense "% от суммы документа." skip
                  "Продолжить?"
          view-as alert-box question buttons yes-no update varlog.
          if not varlog then return error.
      end.
      if buf_trn-doc.tot-other / buf_trn-doc.tot-cli * 100 > varpercent-expense then do:
          varlog = no.
          message "Прочие расходы больше " varpercent-expense "% от суммы документа." skip
                  "Продолжить?"
          view-as alert-box question buttons yes-no update varlog.
          if not varlog then return error.
      end.
    end.

    if buf_trn-doc.doc-type = {&write-off} then
    do:   /* при списании по товару с экземплярным типом учета проверим соответствие списываемого кол-ва и просканировнных марок*/
      v-message = "".
      for each buf_doc-line where
               buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock,
          each buf_gds-dtl where
               buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_doc-line.artic
           and buf_gds-dtl.prod-code = buf_doc-line.prod-code
           and buf_gds-dtl.prod-type = buf_doc-line.prod-type no-lock,
          first buf_goods where 
               buf_goods.artic = buf_gds-dtl.artic
           and buf_goods.prod-code = buf_gds-dtl.prod-code
           and buf_goods.prod-type = buf_gds-dtl.prod-type no-lock:
        run isExemplarGoods in g#attr-lib 
          (buf_trn-doc.obj-type, buf_trn-doc.obj-code, buf_goods.gds-code, output v-is-exemplar-goods).
        v-isweighed = WghProdVariable(buf_trn-doc.obj-type, buf_trn-doc.obj-code, buf_goods.gds-code) .
        if v-isweighed
        then do :
          v-mark-weight = 0 .
          for each buf_marking-lines no-lock where buf_marking-lines.obj-type = buf_trn-doc.obj-type
                                               and buf_marking-lines.obj-code = buf_trn-doc.obj-code
                                               and buf_marking-lines.gds-code = buf_goods.gds-code
                                               and buf_marking-lines.out-code = buf_trn-doc.doc-code
                                               and buf_marking-lines.doc-level = 1,
            first buf_marking no-lock where
                  buf_marking.mark = buf_marking-lines.mark
          :
            v-mark-weight = v-mark-weight + MarkWeight(buf_marking.mark).
          end .
          if buf_gds-dtl.doc-qnty <> v-mark-weight then
          do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_write-off_add-no-mark':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              false
              varlog
            }
            if not varlog then do :
              message "В документе присутствуют товары с помарочной прослеживаемостью в Честном Знаке. Для закрытия списания добавьте марки" view-as alert-box .
              return error.
            end .
            
            v-message = substitute(
                "&1~nПо товару &2 &3 списывается &4 просканировано &5", 
                v-message, buf_goods.artic, buf_goods.gds-name, buf_gds-dtl.doc-qnty, v-mark-weight).
          end.
        end .
        else
        if v-is-exemplar-goods then do:
          v-scan-qnty = 0.
          for each buf_marking-lines no-lock where buf_marking-lines.obj-type = buf_trn-doc.obj-type
                                               and buf_marking-lines.obj-code = buf_trn-doc.obj-code
                                               and buf_marking-lines.gds-code = buf_goods.gds-code
                                               and buf_marking-lines.out-code = buf_trn-doc.doc-code
                                               and buf_marking-lines.doc-level = 1
          :
            v-codident = GetCodeIdent(buf_marking-lines.mark).
            v-GTIN = getGtinByDM(if v-codident <> ? and v-codident <> "" then v-codident else buf_marking-lines.mark) .
            
            v-scan-qnty = v-scan-qnty +  getQntyCodeByGtin(v-GTIN) .
          end .
          if buf_gds-dtl.doc-qnty <> v-scan-qnty then
          do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_write-off_add-no-mark':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              false
              varlog
            }
            if not varlog then do :
              message "В документе присутствуют товары с помарочной прослеживаемостью в Честном Знаке. Для закрытия списания добавьте марки" view-as alert-box .
              return error.
            end .
            
            v-message = substitute(
                "&1~nПо товару &2 &3 списывается &4 просканировано &5", 
                v-message, buf_goods.artic, buf_goods.gds-name, buf_gds-dtl.doc-qnty, v-scan-qnty).
          end.
        end.
      end.
      if v-message <> "" then
      do:
        varlog = no.
        message v-message skip
          "Продолжить?"
          view-as alert-box question buttons yes-no update varlog.
        if not varlog then return error.
      end.
    end.


    if  not buf_trn-doc.flag_               and
        buf_trn-doc.status_   = {&wayb}     and
        buf_trn-doc.doc-type  = {&return}   and
        buf_trn-doc.internal  = no          and
        buf_trn-doc.out-code <> ?
    then do:
      varlog = no.
      message "Документ :" buf_trn-doc.status_ "№" buf_trn-doc.doc-code skip (2)
              "Указан документ - источник №" buf_trn-doc.out-code skip (2)
              "Проверить по нему суммарный возврат ?" skip
              "Внимание !!!  Проверка суммарного возврата по РН -"
              "ОЧЕНЬ долгая операция." skip (2)
              view-as alert-box question buttons YES-NO update varlog.
      if varlog = yes then do:
        assign varcheck-return = yes.
      end.
      else do:
        assign varcheck-return = no.
      end.
    end.

      if buf_trn-doc.creid <> v-cntxt-userid or true  then do:
        run str/trn-hist.p
           ( buffer buf_trn-doc ,
            input  v-cntxt-obj-type ,
            input  v-cntxt-obj-code ,
            input  "Закрытие документа"
            ) .

      end.

      if ( buf_trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh}      or
          buf_trn-doc.ext-doc-type =  {&TDEDT_Ras_Vnesh_VP} ) and
          buf_trn-doc.status_      <> {&inquiry}              then do:
        { str/canclsee.i buf_trn-doc.doc-code l_can-close_ee-ep no-error }
        if error-status :error or l_can-close_ee-ep <> yes then do:
          message substitute( 'Ошибка при закрытии документа "&1", тип "&2", статус "&3":',
                              buf_trn-doc.doc-code,
                              entry( lookup( buf_trn-doc.ext-doc-type, {&TDEDT_List} ), {&TDEDT_list-full} ),
                              string( string( buf_trn-doc.status_ ) + string( buf_trn-doc.flag_, "+/-":U ) ) ) skip( 0 )
                  'Не заведены номер доверенности и/или дата доверенности.' skip( 0 )
                  error-status :get-message( 1 ) skip( 0 )
                  return-value skip( 0 )
          view-as alert-box error.
          undo, return error.
        end.
      end.

      if ( varmode            = {&close-doc}    or
          varmode            = {&close-fact} ) and
          varstatus          = {&fact}         and
          buf_trn-doc.ext-doc-type = {&TDEDT_Inv}    then do:
        { str/invdnull.i buf_trn-doc.doc-code yes no-error }
        if error-status :error then do:
          message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description     skip( 1 )
                  substitute( 'Ошибка проверки нулевых строк в инвентаризации "&1".', buf_trn-doc.doc-code ) skip( 0 )
                  error-status :get-message( 1 )                                                       skip( 0 )
                  return-value                                                                         skip( 1 )
          view-as alert-box error.
          undo, return error.
        end.
      end.

      { gbl/hold-doc.i buf_trn-doc.doc-code l_is-hold-doc no-error }
      if error-status :error or l_is-hold-doc = ? then do: assign l_is-hold-doc = no. end.

      if ( varmode            = {&close-doc}             or
           varmode            = {&close-fact} )
           and
          buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}  and
          l_is-hold-doc      = yes then do:
          /* Дата обрезания */
            define variable v-cut-date as date   no-undo init ?.
            define variable v-cut-fin-date as date   no-undo .
            define variable v-status       as integer   no-undo .

            { gbl/cutd-obj.i
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              v-status
              v-cut-date
              v-cut-fin-date
              no-error }
              if not error-status :error then do:
                if v-cut-date <> ? then do:
                   for each buf_parts no-lock where buf_parts.out-code  = buf_trn-doc.doc-code :
                       if buf_parts.hold-date  = ? or buf_parts.hold-date < v-cut-date then do:
                          message substitute("Невозможно оформить межфирменный Возврат поставщику, так как было обрезание БД &1 " , string(v-cut-date,"99/99/99") )
                          view-as alert-box information
                          .
                          return error .
                       end.
                   end.
                end.
              end.
          end.

      if buf_trn-doc.doc-type = {&income} and v-ischg-ext-type then do:
          for each ub.doc-line where ub.doc-line.doc-code = buf_trn-doc.doc-code no-lock:
              { str/is-petrl.i
                ub.doc-line.artic
                ub.doc-line.prod-type
                ub.doc-line.prod-code
                v-is-petrl
                v-is-pieces
              }
              if error-status:error then do:
                  message return-value
                  	view-as alert-box.
                  undo, return error.
              end.
              
              /* refs #2901 */
              if v-is-petrl and not v-is-pieces and ub.doc-line.doc-qnty <> ub.doc-line.fact-qnty then do:
                  message "Для внутреннего прихода запрещено закрытие с разными факт. и док. количествами топливного товара"
                  	view-as alert-box.
                  undo, return error.
              end.
          end.    
      end.

      /* Ассортиментная политика  объекта приемника */
      v-error = false .

      output stream str-err to value( v-file-n + ".err" ) .
      put    stream str-err unformatted ''.
      output stream str-err close.

      if ( varmode            = {&close-doc}             or
           varmode            = {&close-fact} )          and
           varstatus          = {&fact}                  and
           lookup (buf_trn-doc.ext-doc-type ,
              {&TDEDT_Inv} + "," +
              {&TDEDT_Peresort} + "," +
              {&TDEDT_Spi_Vnesh} + "," +
              {&TDEDT_Spi_Prvo} + ","  +
              {&TDEDT_Ras_Vnesh_Kass} + ","+
              {&TDEDT_Vozvrat_Vnesh} + "," +
              {&TDEDT_Ras_Vnesh_VP} + ","  +
              {&TDEDT_Chg_Purch_Code} + ","  +
              {&TDEDT_Corr_Minus_Parts} + ","  +
              {&TDEDT_Corr_Acc_Price}   + "," +
              {&TDEDT_Vozvrat_Perem} + ","  +
              {&TDEDT_Pri_Object}   + "," +
              {&TDEDT_Ras_Object} ) = 0
           then do:
           for each buf_doc-line no-lock where buf_doc-line.doc-code =  buf_trn-doc.doc-code  and
                    buf_doc-line.fact-qnty > 0 :
                find first buf_goods where buf_goods.artic     = buf_doc-line.artic     and
                                           buf_goods.prod-type = buf_doc-line.prod-type and
                                           buf_goods.prod-code = buf_doc-line.prod-code no-lock.
                var-ok-assort-pol = true .
                if l_is-hold-doc      = yes then do:
                    v-event-code = substitute("mf_&1-" ,buf_trn-doc.ext-doc-type ) .
                end.
                else do:
                   v-event-code = substitute("&1-" ,buf_trn-doc.ext-doc-type ) .
                end.
                  { gbl/goassizt.i
                    v-event-code
                    buf_goods.gds-code
                    buf_trn-doc.obj-type
                    buf_trn-doc.obj-code
                    true
                    var-ok-assort-pol
                    var-mess-assort-pol
                  }
                if var-ok-assort-pol = false then do:
                      v-error = true .
                      output stream str-err to value( v-file-n + ".err" ) append.
                      put    stream str-err unformatted var-mess-assort-pol skip.
                      output stream str-err close.
                end.
            end.
       end.
      if ( varmode            = {&close-doc}             or
           varmode            = {&close-fact} )          and
           varstatus          = {&fact}                  and
           buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and
           l_is-hold-doc      = yes
           then do:
           for each buf_doc-line no-lock where buf_doc-line.doc-code =  buf_trn-doc.doc-code  and
                    buf_doc-line.fact-qnty > 0 :
                find first buf_goods where buf_goods.artic     = buf_doc-line.artic     and
                                           buf_goods.prod-type = buf_doc-line.prod-type and
                                           buf_goods.prod-code = buf_doc-line.prod-code no-lock.
                var-ok-assort-pol = true .
                v-event-code = substitute("cli_mf_&1-" ,buf_trn-doc.ext-doc-type ) .
                  { gbl/goassizt.i
                    v-event-code
                    buf_goods.gds-code
                    buf_trn-doc.hold-obj-type
                    buf_trn-doc.hold-obj-code
                    true
                    var-ok-assort-pol
                    var-mess-assort-pol
                  }
                if var-ok-assort-pol = false then do:
                     v-error = true .
                      output stream str-err to value(  v-file-n + ".err" ) append.
                      put    stream str-err unformatted 'МФ: ' + var-mess-assort-pol skip.
                      output stream str-err close.
                end.
            end.
       end.

      if v-error = true
      then do:
          run gbl/prnfilen.w
            (input  "Ошибки по соответствию товаров в накладной и Ассортиментной политике"
            ,input  0
            ,input  v-file-n  + ".err"
            ,input  7
            ,output v-user-action
            ,output v-printed
            ).
        return error substitute( 'Ошибки по соответствию товаров в накладной и Ассортиментной политике. ' +
                                 'Смотри файл "&1.err"'
                                , v-file-n  ).
      end. 
  
  /*
     { gbl/objat.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        "'shift-on=request'"
        l-shift-on
        } 
      if l-shift-on then do:
      { gbl/curshift.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          varshift-date
          varshift-num
          varshift-name
          no-error
        }
           if  varshift-date <> buf_trn-doc.shift-date  
            or varshift-num  <> buf_trn-doc.shift-num 
              then do: 
              message "Смена в накладной отличается от текущей!" 	view-as alert-box.
              undo, return error.
           END.
      END. */
      
      run str/trn-stat.p (
            input   parparentproc,
            input   this-procedure ,
            input   varmode,
            input   buf_trn-doc.doc-code,
            input   varcheck-return,
            input   v-cntxt-db-num,
            input   v-cntxp-in-ov,
            input   v-cntxp-rsrv-time,
            input   v-cntxp-load-time,
            input   v-cntxp-holidays,
            input   yes,
            output  varchg-inv,
            output  table gds-list )
            no-error.
      if error-status :error then do:
        v-mess = 
/*          vss-workfile + vss-revision + vss-description + {&new-line} +*/
          "Ошибка при закрытии документа " + buf_trn-doc.doc-code + {&new-line} +
          return-value + {&new-line} .
        run userlogingerr in this-procedure ( buffer buf_trn-doc, 57, v-mess, v-cntxt-db-num) no-error.
        message
          v-mess
        view-as alert-box error.
        return error v-mess.
      end.
      if varchg-inv = yes then do:
        assign varlog = no.
        message "За время пребывания в статусе разр- было движение товаров, участвующих в инвентаризации." skip
                "Показать список товаров по которым было движение?"
        view-as alert-box question buttons yes-no update varlog .
        if varlog then run str/gds-list.w (input parparentproc, input buf_trn-doc.host-code, input buf_trn-doc.obj-type, input buf_trn-doc.obj-code).
      end.
      
      define buffer bf_doc-line       for ub.doc-line.
      define buffer bf_gds-dtl        for ub.gds-dtl.
      { gbl/objsrv.i }
      def var v-attr-value as character no-undo.
      def var v-attr-type as character no-undo.
      def var v-is-introduce  as logical no-undo.
      def var v-is-return     as logical no-undo.
      def var v-is-wroff-tech-m as logical no-undo.
      def var v-prev-sts        as integer no-undo.
      
      { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-inv-introduce}
        v-attr-value
        v-attr-type
        no-error
      }
      if not error-status:error and v-attr-value = "yes" then do:
        v-is-introduce = true.
      end.
      { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-is-return}
        v-attr-value
        v-attr-type
        no-error
      }
      if not error-status:error and v-attr-value = "yes" then do:
        v-is-return = true.
      end.
      
      
        if not v-is-introduce and 
          ((ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType("tabak") 
            or can-find (first ub.marking-attr where ub.marking-attr.attr-code = "inv-doc" and ub.marking-attr.attr-value = buf_trn-doc.doc-code))
          and buf_trn-doc.ext-doc-type = {&TDEDT_Inv} and varstatus = {&permitted})
        then do:
          def var chg-qnty as int no-undo.
          v-is-wroff-tech-m = true.
          /*if can-find (first buf_marking-lines no-lock where buf_marking-lines.mark begins {&tech-mark-prefix} and buf_marking-lines.out-code = {&free-code})
          then do:
            
            message "В наличии имеется немаркированная продукция. Оставить ее на остатках?" view-as alert-box buttons yes-no-cancel update varlog.
            if varlog = ?
              then undo, return error "Отмена пользователем.".

            if varlog
            then do:
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_income_petrol-сommission':U
                {&cntxt-object}
                buf_trn-doc.host-code
                buf_trn-doc.obj-type
                buf_trn-doc.obj-code
                0
                0
                0
                true
                varlog
                }
              if not varlog
                then do:
                  message 'Отсутсвует право "Включение в инвентаризацию немаркированной продукции."' view-as alert-box error.
                  undo, return error 'Отсутсвует право "Включение в инвентаризацию немаркированной продукции."'.
                end.
                else v-is-wroff-tech-m = true.
                  
            end.
          end.*/
        


        for each bf_doc-line where bf_doc-line.doc-code = buf_trn-doc.doc-code:
      
          find first ub.goods no-lock where 
            bf_doc-line.artic = ub.goods.artic
            and bf_doc-line.prod-type = ub.goods.prod-type
            and bf_doc-line.prod-code = ub.goods.prod-code.
      
    
          define variable n-c like ub.gds-prt.node-code          no-undo.
          find first bf_gds-dtl where
                     bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                     bf_gds-dtl.artic     = bf_doc-line.artic     and
                     bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                     bf_gds-dtl.prod-type = bf_doc-line.prod-type no-error.
          
          if not available bf_gds-dtl then do:
            { gbl/termnode.i ub.goods.prt-root n-c }
            { str/crgdsdtl.i
                bf_doc-line.obj-code
                bf_doc-line.obj-type
                buf_trn-doc.doc-code
                bf_doc-line.artic
                bf_doc-line.prod-code
                bf_doc-line.prod-type
                n-c
                yes
            }
            find first bf_gds-dtl where
                       bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                       bf_gds-dtl.artic     = bf_doc-line.artic     and
                       bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                       bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                       bf_gds-dtl.prt-code  = n-c.
            assign
              bf_gds-dtl.fact-qnty = bf_doc-line.doc-qnty
              bf_gds-dtl.doc-qnty  = 0
            .
          end.
          define variable old-val        like ub.gds-dtl.fact-qnty no-undo.
          old-val = bf_gds-dtl.fact-qnty.         
          chg-qnty = (bf_doc-line.fact-qnty - bf_doc-line.doc-qnty).
          run trg/rsrv-dtl.p
            ( input        parparentproc
             ,input        {&rsrv-dtl_action_reserv}
             ,buffer       bf_gds-dtl
             ,input-output chg-qnty
             ,input-output bf_doc-line.price-base
             ,input-output bf_doc-line.price-rubl
             ,input        -1
             ,input        ""
            ) no-error.
          if error-status:error
          then do:
            undo, return error return-value.
          end.
          assign bf_gds-dtl.fact-qnty  = bf_gds-dtl.fact-qnty  + chg-qnty
                bf_gds-dtl.doc-qnty   = bf_gds-dtl.fact-qnty  - old-val
                bf_doc-line.doc-qnty  = bf_doc-line.doc-qnty  + chg-qnty
                bf_doc-line.fact-qnty = bf_doc-line.fact-qnty + chg-qnty.
          for each buf_marking-lines where
            buf_marking-lines.gds-code = ub.goods.gds-code
            and buf_marking-lines.out-code = buf_trn-doc.doc-code
            and buf_marking-lines.obj-type = buf_trn-doc.obj-type
            and buf_marking-lines.obj-code = buf_trn-doc.obj-code
            :
            for each ub.marking exclusive-lock where ub.marking.mark = buf_marking-lines.mark and not ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
              and not ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB:
              ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB.
            end.
          end.

          f_ml:
          for each buf_marking-lines where
            buf_marking-lines.gds-code = ub.goods.gds-code
            and buf_marking-lines.out-code = buf_trn-doc.doc-code
            and buf_marking-lines.obj-type = buf_trn-doc.obj-type
            and buf_marking-lines.obj-code = buf_trn-doc.obj-code
            :
      
            find first ub.marking-attr where ub.marking-attr.mark = buf_marking-lines.mark 
              and ub.marking-attr.attr-code = "inv-doc-scan" 
              and ub.marking-attr.attr-value = buf_trn-doc.doc-code no-error.
            
            if available (ub.marking-attr)
              then do:
                find first ub.marking where ub.marking.mark = ub.marking-attr.mark no-error.
                if not available ( ub.marking ) 
                then do:
                  next f_ml.
                end.
                if not ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                  then do:
                    v-prev-sts = ub.marking.sts.
                    ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB.
                  end.
                  else v-prev-sts = ?.  
              end.
              else next f_ml.
            create ub.gen-attr.
              ub.gen-attr.table-name = "inv-doc-mark".
              ub.gen-attr.attr-code = bf_doc-line.doc-code.
              ub.gen-attr.p-key = ub.marking.mark.
              ub.gen-attr.attr-value = string(ub.marking.gds-code).
            chg-qnty = ub.marking.box-qnty.
                        run trg/rsrv-dtl.p
              ( input        parparentproc
               ,input        {&rsrv-dtl_action_reserv}
               ,buffer       bf_gds-dtl
               ,input-output chg-qnty
               ,input-output bf_doc-line.price-base
               ,input-output bf_doc-line.price-rubl
               ,input        -1
               ,input        buf_marking-lines.mark
              ) no-error.
            if error-status:error
            then do:
              undo, return error return-value.
            end.
            assign bf_gds-dtl.fact-qnty  = bf_gds-dtl.fact-qnty  + chg-qnty
                  bf_gds-dtl.doc-qnty   = bf_gds-dtl.fact-qnty  - old-val
                  bf_doc-line.doc-qnty  = bf_doc-line.doc-qnty  + chg-qnty
                  bf_doc-line.fact-qnty = bf_doc-line.fact-qnty + chg-qnty.
            if v-prev-sts ne ?
            then do:
              ub.marking.sts = v-prev-sts.
              v-prev-sts = ?.
            end.
            release ub.marking.
          end.
          
          if v-is-wroff-tech-m
          then do:
            f_ml2:
            for each buf_marking-lines where
              buf_marking-lines.gds-code = ub.goods.gds-code
              and buf_marking-lines.out-code = buf_trn-doc.doc-code
              and buf_marking-lines.obj-type = buf_trn-doc.obj-type
              and buf_marking-lines.obj-code = buf_trn-doc.obj-code
              and buf_marking-lines.mark begins {&tech-mark-prefix}
              :
                
              find first ub.marking where ub.marking.mark = ub.buf_marking-lines.mark no-error.
              if not available ( ub.marking ) 
              then do:
                if not ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                  then do:
                    v-prev-sts = ub.marking.sts.
                    ub.marking.sts = ObjSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB.
                  end.
                  else v-prev-sts = ?.
                next f_ml2.
              end.
              create ub.gen-attr.
                ub.gen-attr.table-name = "inv-doc-mark".
                ub.gen-attr.attr-code = bf_doc-line.doc-code.
                ub.gen-attr.p-key = ub.marking.mark.
                ub.gen-attr.attr-value = string(ub.marking.gds-code).
              chg-qnty = ub.marking.box-qnty.
              run trg/rsrv-dtl.p
                ( input        parparentproc
                 ,input        {&rsrv-dtl_action_reserv}
                 ,buffer       bf_gds-dtl
                 ,input-output chg-qnty
                 ,input-output bf_doc-line.price-base
                 ,input-output bf_doc-line.price-rubl
                 ,input        -1
                 ,input        buf_marking-lines.mark
                ) no-error.
              if error-status:error
              then do:
                undo, return error return-value.
              end.
              assign bf_gds-dtl.fact-qnty  = bf_gds-dtl.fact-qnty  + chg-qnty
                    bf_gds-dtl.doc-qnty   = bf_gds-dtl.fact-qnty  - old-val
                    bf_doc-line.doc-qnty  = bf_doc-line.doc-qnty  + chg-qnty
                    bf_doc-line.fact-qnty = bf_doc-line.fact-qnty + chg-qnty.
              if v-prev-sts ne ?
              then do:
                ub.marking.sts = v-prev-sts.
                v-prev-sts = ?.
              end.
              release ub.marking.
            end.
          end.
        end.
        run gbl/calc-trn.p ( input parparentproc, input recid( buf_trn-doc ) ).
        run str/clcsumga.p ( input buf_trn-doc.doc-code ).
      end.

      
      
      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object} and buf_trn-doc.status_ = {&fact} then do :
          define variable v-income-doc-code as character no-undo .
          v-income-doc-code = replace(buf_trn-doc.doc-code, '-', '=' ).
          { gbl/int-clos.i
            parparentproc
            v-income-doc-code
            gds-list
            no-error
          }
      end.

      if buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} and buf_trn-doc.status_ = {&fact} then 
      do :    /* для док-та СПИСАНИЯ при закрытии на ФАКТ меняем статус марок на СПИСАН */
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, 
           string(ObjSrv:Env:Marking:Sts:Mark:WrittenOff:KeyIntDB)).
      end.
      if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} and buf_trn-doc.status_ = {&fact} then 
      do :    /* для док-та РАСХОДА ПЕРЕМЕЩЕНИЯ при закрытии на ФАКТ меняем статус марок на ПЕРЕМЕЩЕН */
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, 
           string(ObjSrv:Env:Marking:Sts:Mark:Moved:KeyIntDB)).
      end.
      if v-is-return and buf_trn-doc.status_ = {&fact} then 
      do :    /* для док-та ВОЗВРАТА при закрытии на ФАКТ меняем статус марок на ВОЗВРАЩЕН ПОСТАВЩИКУ */
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, 
           string(ObjSrv:Env:Marking:Sts:Mark:Returned:KeyIntDB)).
      end.
      if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and v-ischg-ext-type and buf_trn-doc.status_ = {&fact} then 
      do :    /* для док-та ПРИХОДА ПЕРЕМЕЩЕНИЯ  при закрытии на ФАКТ меняем статус марок:  */
              /* ПРОВЕРЕН --> СЗ; ОЖИДАЕТ ПРОВЕРКУ --> ОТСУТСТВУЕТ В ПОСТАВКЕ */
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, 
           substitute("&1:&2,&3:&4",
                      ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB,
                      ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB,
                      ObjSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB,
                      ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB)
          ).
      end.
      if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} and buf_trn-doc.status_ = {&fact} then 
      do :    /* для док-та ВОЗВРАТ ПЕРЕМЕЩЕНИЯ при закрытии на ФАКТ меняем статус марок на CСВОБОДНАЯ ЗОНА */
        run change_mark_sts_trn-doc in this-procedure
          (buf_trn-doc.doc-code, buf_trn-doc.obj-type, buf_trn-doc.obj-code, 
           string(ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB)).
      end.
    if v-ischg-ext-type
    then do:
      buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}.
      buf_trn-doc.internal = true.
      buf_trn-doc.discnt-type = {&percent}.
      v-ischg-ext-type = false.
    end.

  end.
if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and varstatus = {&fact} then 
do:
{ str/tdat-val.i
             buf_trn-doc.doc-code
             {&trdcattr-is-lgas}
             varvalue
             vartype
             no-error
          }

  if varvalue = "yes" then
  do:
    /*Расчет тех потерь*/
    run spr-sug (buf_trn-doc.doc-code, buf_trn-doc.reason-code) no-error .
    run bge\send1cerp.p (?,
      this-procedure,
      this-procedure,
      "techlosses",
      (buffer buf_trn-doc:handle),
      ?,
      ?) no-error.

    if error-status:error 
      then 
    do:
      message return-value view-as alert-box.
    end.
  end.
end.
end procedure. /* lib-trn4_int-clos */

procedure lib-trn4_int-open :


  define input  parameter parparentproc as widget-handle no-undo.
  define input  parameter p-doc-code    as character no-undo .
  define output parameter table for gds-list .


  define variable varmode         as   character            no-undo.
  define variable varchg-inv      as logical              no-undo.
  define variable varstatus       like ub.trn-doc.status_   no-undo.
  define variable varflag         like ub.trn-doc.status_   no-undo.
  define variable varcopystatus   like ub.trn-doc.status_   no-undo.
  define variable varcopyflag     like ub.trn-doc.status_   no-undo.
  define variable varlog          as logical   no-undo .
  define variable varcheck-return as logical   no-undo .

  { gbl/getcntxt.i def }
  { str/getctxtp.i def }

  define buffer bf_rvs-doc for ub.rvs-doc.
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line  .

  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Номер документа" p-doc-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_trn-doc.rcv-code = "not_delete" then do:
       if not ( buf_trn-doc.ext-doc-type = {&TDEDT_Inv} and
                buf_trn-doc.status_ = {&permitted} ) then do:
              message "Этот документ запрещено открывать!" skip
                      "Номер документа" p-doc-code
                      view-as alert-box information .
              undo, return error return-value .
       end.
    end.
    { gbl/getcntxt.i get }
    { str/getctxtp.i get }

    assign varmode = {&open-doc}.
    /*Проверим на возможность открытия*/
    run str/trn-graf.p (input  buf_trn-doc.doc-code,
                    input  v-cntxt-db-num,
                    input  varmode,
                    output varstatus,
                    output varflag,
                    output varcopystatus,
                    output varcopyflag) no-error.
    if error-status:error then do:
      message "Ошибка при проверке возможности открытия документа." skip
              return-value
      view-as alert-box error.
      return error.
    end.
    case buf_trn-doc.status_:
    when {&wayb} or
    when {&inquiry} then do:
      varlog = no.
      message "Документ №" buf_trn-doc.doc-code "Открыть ?   Вы уверены ?"
                      view-as alert-box question buttons OK-Cancel update varlog.
      if not varlog then  return error.
      if buf_trn-doc.status_  = {&inquiry} and
        buf_trn-doc.doc-type = {&income}  and
        buf_trn-doc.internal = no         then do:
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_income_opening-inquiry':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          varlog
        }
        if not varlog then  return error.
      end.
      else do:
        case buf_trn-doc.doc-type
        :
          when {&income}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_income_opening':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&expense}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_expense_opening':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&write-off}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_write-off_opening':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&inventory}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_inventory_opening':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&return}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_return_opening':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" skip
              "Тип документа" buf_trn-doc.doc-type skip
              "Код документа" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if not varlog then  return error.
      end.
    end.
    when {&permitted} then do:
      if  buf_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
       if not is-mes(buf_trn-doc.doc-code) then do:
        message
          "Документ №" buf_trn-doc.doc-code skip (2)
          "Открыть инвентаризацию?   Будут потеряны все введенные остатки!" skip
          "Если необходимо добавить / удалить строки, используйте пересортицу (кнопка Резерв)." skip
          "Вы уверены, что хотите открыть инвентаризацию?"
          view-as alert-box question buttons OK-Cancel update varlog .
        if not varlog then return error.
        varlog = no.
        message
          "Документ №" buf_trn-doc.doc-code skip (2)
          "Последнее предупреждение! При открытии инвентаризации будут потеряны все введенные остатки!" skip
          "Если Вы не хотите этого, нажмите Cancel (Отмена)!"
          view-as alert-box question buttons OK-Cancel update varlog .
        if not varlog then return error.
        { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_inventory_opening':U
          {&cntxt-object}
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          0
          0
          0
          true
          varlog
        }
        if not varlog then  return error.
        end.
          for each buf_doc-line exclusive-lock where
                   buf_doc-line.doc-code =  buf_trn-doc.doc-code
                   :
              buf_doc-line.inv-peresort-qnty = 0 .
          end.
      end.
      else do:
        varlog = no.
        message "Документ №" buf_trn-doc.doc-code skip "Снять разрешение ?   Вы уверены ?"
                        view-as alert-box question buttons OK-Cancel update varlog.
        if not varlog then  return error.
        case buf_trn-doc.doc-type
        :
          when {&expense}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_expense_perm-cancellation':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&write-off}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_write-off_perm-cancellation':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          when {&return}
          then do:
            { gbl/chk-actg.i
              v-cntxt-db-num
              v-cntxt-userid
              {&action-head-code-main}
              'actn_return_perm-cancellation':U
              {&cntxt-object}
              buf_trn-doc.host-code
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Неизвестный тип документа" skip
              "Тип документа" buf_trn-doc.doc-type skip
              "Код документа" buf_trn-doc.doc-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
        if not varlog then  return error.
      end.
    end.
    otherwise do:
      message "Документ # " buf_trn-doc.doc-code " в статусе " buf_trn-doc.status_ " .Нельзя открыть документ. "
      view-as alert-box error.
      return error.
    end.
    end case.

    if buf_trn-doc.creid <> v-cntxt-userid or true then do:
      run str/trn-hist.p
            (buffer buf_trn-doc ,
            input  v-cntxt-obj-type ,
            input  v-cntxt-obj-code ,
            input  "Открытие документа"
            ) .
    end.

    /* todo - переменная varcheck-return - не была инициализирована */
    run str/trn-stat.p (input parparentproc,
                    input this-procedure ,
                    input varmode,
                    input buf_trn-doc.doc-code,
                    input varcheck-return,
                    input v-cntxt-db-num,
                    input v-cntxp-in-ov,
                    input v-cntxp-rsrv-time,
                    input v-cntxp-load-time,
                    input v-cntxp-holidays,
                    input yes,
                    output varchg-inv,
                    output table gds-list) no-error.
    if error-status:error
    then do:
        v-mess = 
          vss-workfile + vss-revision + vss-description + {&new-line} +
          "Ошибка при открытии документа " + buf_trn-doc.doc-code + {&new-line} +
          return-value + {&new-line} +
          trim( error-status :get-message( 1 ) ) +
          trim( error-status :get-message( 2 ) ) + 
          trim( error-status :get-message( 3 ) ) +
          trim( error-status :get-message( 4 ) ) +
          trim( error-status :get-message( 5 ) ) + {&new-line}.
        run userlogingerr in this-procedure ( buffer buf_trn-doc, 57, v-mess, v-cntxt-db-num) no-error.
        message v-mess
          view-as alert-box error.
      undo, return error v-mess .
    end.
  end.

end procedure.



/*
Данная процедура запускаться не должна !!!
Отключен инклудник str/corrsprc.i
по задаче 1984 в файлах
Lib-trn.p
trn-stat.p
*/
procedure lib-trn4_corrsprc :
define input  parameter p-action as character no-undo .
define input  parameter p-doc-code as character no-undo .
define output parameter p-mess as character no-undo .
  do
  on error undo, return error return-value
  :
p-mess = "" .
if not ( p-action = "-" or p-action = "+" ) then return .

define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_contract for ub.contract .
define buffer buf_contract-specif for ub.contract-specif .
define buffer buf_parts for ub.parts  .
find first buf_trn-doc no-lock where
           buf_trn-doc.doc-code = p-doc-code and
           buf_trn-doc.status_  = {&fact} no-error .

if error-status :error then return .
if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
    find first buf_contract no-lock where
               buf_contract.host-code     = buf_trn-doc.host-code and
               buf_contract.contract-code = buf_trn-doc.contract-code no-error .
               if error-status :error then return .

      for each buf_doc-line no-lock where
               buf_doc-line.doc-code = buf_trn-doc.doc-code :

/*
       for each buf_contract-specif exclusive-lock where
                buf_contract-specif.host-code    = buf_contract.host-code
            AND buf_contract-specif.contract-num = buf_contract.contract-code
*/
       {str/cont-slave-inc.i
            &FOR_ = YES
            &EACH_ = YES
            &EXCLUSIVE_LOCK=YES
            &BUFFER_SPECIF    = buf_contract-specif
            &P_HOST_CODE      = buf_contract.host-code
            &P_CONTRACT_NUM   = buf_contract.contract-code
            &NO_END = YES
       }
            AND buf_contract-specif.artic        = buf_doc-line.artic
            AND buf_contract-specif.prod-type    = buf_doc-line.prod-type
            AND buf_contract-specif.prod-code    = buf_doc-line.prod-code :
           /*  */
           if buf_contract-specif.qnty <> ? then do:
                if p-action = "+" then
                assign
                  buf_contract-specif.income-qnty =
                      ( if  buf_contract-specif.income-qnty = ? then 0 else  buf_contract-specif.income-qnty )
                        + ( buf_doc-line.fact-qnty / buf_contract-specif.cli-base-rate )
                .
                else
                assign
                  buf_contract-specif.income-qnty =
                      (if  buf_contract-specif.income-qnty = ? then 0 else buf_contract-specif.income-qnty ) -
                      ( buf_doc-line.fact-qnty / buf_contract-specif.cli-base-rate )
                .

             if buf_contract-specif.income-qnty > buf_contract-specif.qnty
                      then p-mess = p-mess +
                          buf_contract-specif.artic + " "         + buf_contract-specif.prod-type +
                          string(buf_contract-specif.prod-code)   + " Всего принято:" +
                          string(buf_contract-specif.income-qnty) + " По спецификации:" +
                          string(buf_contract-specif.qnty)        + {&new-line} .
           end.
       end.
      end.
end.

if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
  for each buf_parts no-lock where
           buf_parts.out-code = buf_trn-doc.doc-code ,
      first buf_contract no-lock where
            buf_contract.host-code     = buf_trn-doc.host-code and
            buf_contract.contract-code = buf_parts.contract-code :
/*
       for each buf_contract-specif exclusive-lock where
                buf_contract-specif.host-code    = buf_contract.host-code
            AND buf_contract-specif.contract-num = buf_contract.contract-code
*/
       {str/cont-slave-inc.i
            &FOR_ = YES
            &EACH_ = YES
            &EXCLUSIVE_LOCK=YES
            &BUFFER_SPECIF    = buf_contract-specif
            &P_HOST_CODE      = buf_contract.host-code
            &P_CONTRACT_NUM   = buf_contract.contract-code
            &NO_END = YES
       }
            AND buf_contract-specif.artic        = buf_parts.artic
            AND buf_contract-specif.prod-type    = buf_parts.prod-type
            AND buf_contract-specif.prod-code    = buf_parts.prod-code :

           if p-action = "+" then
           assign
             buf_contract-specif.income-qnty =
                 (if  buf_contract-specif.income-qnty = ? then 0 else buf_contract-specif.income-qnty ) -
                 ( buf_parts.qnty / buf_contract-specif.cli-base-rate )
           .
           else
           assign
             buf_contract-specif.income-qnty =
                 (if  buf_contract-specif.income-qnty = ? then 0 else buf_contract-specif.income-qnty ) +
                 ( buf_parts.qnty / buf_contract-specif.cli-base-rate )
           .
       end.

  end.
end.
end.
end procedure. /* lib-trn4_corrsprc */


procedure lib-trn4_linesprc :
/* Проверка не превышения приема 1 товара по спецификации */
define input  parameter p-recid-doc-line as recid no-undo .
define output parameter p-mess as character no-undo .
  do
  on error undo, return error return-value
  :
p-mess = "" .
define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_contract for ub.contract .
define buffer buf_goods    for ub.goods  .
define buffer buf_contract-specif for ub.contract-specif .
define variable v-income-qnty as decimal   no-undo .

find first buf_doc-line no-lock where recid(buf_doc-line) = p-recid-doc-line no-error .
     if error-status :error then return .
find first buf_goods no-lock where
           buf_goods.artic = buf_doc-line.artic and
           buf_goods.prod-type = buf_doc-line.prod-type and
           buf_goods.prod-code = buf_doc-line.prod-code no-error .
if error-status :error then do:
  p-mess =  substitute("Не найден товар  &1 &2&3"  ,buf_doc-line.artic,buf_doc-line.prod-type,buf_doc-line.prod-code  ) .
  return .
end.

if buf_goods.stts <> 0  then do:
   p-mess = substitute("Товар удален : &1 &2&3 &4"  ,buf_doc-line.artic,buf_doc-line.prod-type,buf_doc-line.prod-code , buf_goods.gds-name  ) .
end.


find first buf_trn-doc no-lock where
           buf_trn-doc.doc-code = buf_doc-line.doc-code
           no-error .
     if error-status :error then return .

define variable v-qnty-spec as logical   no-undo .
{ gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-contr-in} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-contr-in_contr-qnty-spec} then v-qnty-spec = thbjattr_thbj-attr.property-value-logical .
end.

if v-qnty-spec = false  then return .

    find first buf_contract no-lock where
               buf_contract.host-code     = buf_trn-doc.host-code and
               buf_contract.contract-code = buf_trn-doc.contract-code no-error .
               if error-status :error then return .

      if available buf_doc-line  then do :
       /*
       find first buf_contract-specif no-lock where
                  buf_contract-specif.host-code    = buf_contract.host-code
              AND buf_contract-specif.contract-num = buf_contract.contract-code
       */
       {str/cont-slave-inc.i
            &FIND_FIRST = YES
            &NO_LOCK=YES
            &BUFFER_SPECIF   = buf_contract-specif
            &P_HOST_CODE     = buf_contract.host-code
            &P_CONTRACT_NUM  = buf_contract.contract-code
            &NO_END=YES
       }

              AND buf_contract-specif.artic        = buf_doc-line.artic
              AND buf_contract-specif.prod-type    = buf_doc-line.prod-type
              AND buf_contract-specif.prod-code    = buf_doc-line.prod-code
           NO-ERROR.


                if not available buf_contract-specif then return .

           if buf_contract-specif.qnty <> ?  and buf_contract-specif.qnty <> 0 then do:
                assign
                p-mess = "" .
                 v-income-qnty =
                    /* Задача 1984 (if  buf_contract-specif.income-qnty = ? then 0 else buf_contract-specif.income-qnty ) + */
                    ( buf_doc-line.doc-qnty / buf_contract-specif.cli-base-rate )
                    .

                 if v-income-qnty > buf_contract-specif.qnty
                      then do:
                      p-mess =
                          buf_contract-specif.artic + " " + buf_contract-specif.prod-type +
                          string ( buf_contract-specif.prod-code ) +
                          /*  Задача 1984
                          " Всего принято:" +
                          string ( if buf_contract-specif.income-qnty = ? then 0 else buf_contract-specif.income-qnty ) + " По документу:" +
                          */
                          string ( buf_doc-line.doc-qnty ) + " (=" +  string(v-income-qnty) + ")" +
                          " По спецификации:" +
                          string ( if buf_contract-specif.qnty = ? then "неопределено" else string(buf_contract-specif.qnty)) + {&new-line} .
                      end.
           end.
       end.
 end.
end procedure. /* lib-trn4_corrsprc */

PROCEDURE userlogingerr :
  
  define parameter buffer bf_trn-doc for ub.trn-doc .
  define input parameter p-vid-action as integer no-undo.
  define input parameter p-mess as character no-undo.
  define input parameter p-db-num as integer no-undo.

  define buffer bf_clients for ub.clients .
  define variable v-vid-param       as character no-undo .
  define variable v-action          as character no-undo .
  define variable varshift-date as date      no-undo.
  define variable varshift-num  as integer   no-undo.
  define variable varshift-name as character no-undo.
  
  
  
  find first bf_clients no-lock where bf_clients.obj-type = {&prs} and  bf_clients.obj-code = bf_trn-doc.boss no-error.
  
  { gbl/curshift.i
    c-trn-doc.obj-type
    c-trn-doc.obj-code
    varshift-date
    varshift-num
    varshift-name
    no-error
  }

  
  if available (bf_trn-doc)
  then do:
    v-vid-param = "Initiator=" + "User" + {&delim-par} +
                  "ResponsiblePerson=" + ( if available (bf_clients) then bf_clients.obj-name else "" ) + {&delim-par} +
                  "SHOP_NUM=" + string(bf_trn-doc.obj-code) + {&delim-par} +
                  "Contractor=" + bf_trn-doc.cli-name + {&delim-par} +
                  "DocNum=" + string(bf_trn-doc.doc-code) + {&delim-par} +
                  "FactDate=" + (if string(bf_trn-doc.fact-date) = ? then '' else string(bf_trn-doc.fact-date)) + {&delim-par} +
                  "DocType=" + string(bf_trn-doc.doc-type) + {&delim-par} +
                  "SHIFT_NUM_DOC=" + (if string(bf_trn-doc.shift-num) = ? then '' else string(bf_trn-doc.shift-num)) + (if string(bf_trn-doc.shift-date) = ? then '' else string(bf_trn-doc.shift-date, "99999999")) + {&delim-par} +
                  "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
                  "StatusOld=" + "" + {&delim-par} +
                  "StatusNew=" + string(bf_trn-doc.status_) + (if bf_trn-doc.flag then "+" else "-" ) + {&delim-par} +
                  "RESULT=" + string( 1 ) + {&delim-par} + 
                  "Description=" + p-mess no-error.
  end.
  
  run trg/userlog.p (
        input {&nwsdochs_action_update_err}
      , input {&table_trn-doc} 
      , input buffer bf_trn-doc:handle
      , input p-vid-action
      , input v-vid-param
  ) no-error.
end procedure. /* userloging */

procedure change_mark_sts_trn-doc:
    /* смена статуса марок документа trn_doc */
    define input parameter iDocCode like ub.trn-doc.doc-code no-undo.
    define input parameter iObjType like ub.trn-doc.obj-type no-undo.
    define input parameter iObjCode like ub.trn-doc.obj-code no-undo.
    define input parameter iStatus  as   character           no-undo.
    /* Формат iStatus                                                           */
    /* Одно значение (например: 10), то статус всех марок "тупо" меняем на него */
    /* Если "*:11", статус всех марок меняем на 11                              */
    /* Если "7:10,3:6", 7 меняем на 10, 3 на 6, остальные не изменяются         */
    /* Если "7:10,3:6,*:11", 7 меняем на 10, 3 на 6, остальные на 11            */
    
    define variable vCount   as integer   no-undo.   
    define variable vElem    as character no-undo.   
    
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_goods         for ub.goods.
    define buffer buf_marking-lines for ub.marking-lines.
    define buffer buf_marking       for ub.marking.
    
    if num-entries(iStatus,":") = 1 then iStatus = substitute("*:&1",iStatus). 
    
    for each buf_doc-line no-lock where buf_doc-line.doc-code = iDocCode:
      find first buf_goods no-lock where 
                 buf_goods.artic     = buf_doc-line.artic 
             and buf_goods.prod-type = buf_doc-line.prod-type 
             and buf_goods.prod-code = buf_doc-line.prod-code.
      for each buf_marking-lines exclusive-lock where
               buf_marking-lines.gds-code = buf_goods.gds-code
           and buf_marking-lines.out-code = iDocCode
           and buf_marking-lines.obj-type = iObjType
           and buf_marking-lines.obj-code = iObjCode
      :
        for first buf_marking exclusive-lock where 
                 buf_marking.mark begins buf_marking-lines.mark:
          CHNG:
          do vCount = 1 to num-entries(iStatus):
              vElem = entry(vCount,iStatus).
              if can-do(entry(1,vElem,":"),string(buf_marking.sts)) then
              do:
                  buf_marking.sts = integer(entry(2,vElem,":")).
                  buf_marking-lines.sts = buf_marking.sts. 
                  validate buf_marking.
                  leave CHNG.
              end.
          end.
        end.
      end.
    end.
end procedure.

/* $Workfile: lib-trn4.p $   E n d */