block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение статуса складского документа

Автор: Чернова Светлана Александровна
Дата создания: 10/05/06
Author: Svetlana Chernova
Creation date: 10/05/2006

*/
using ibs.th.str.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
 
define input  parameter parparentproc   as   widget-handle       no-undo.
define input  parameter parparenthandle as   handle              no-undo.
define input  parameter parmode         as   character           no-undo. /* режим обработки */
define input  parameter pardoc-code     like ub.trn-doc.doc-code no-undo. /* номер документа */
define input  parameter parcheck-return as   logical             no-undo. /* проверка старого возврата */
define input  parameter pardb-num       like ub.db.db-num        no-undo. /* номер БД на которой производим операцию */
define input  parameter parin-ov        as   logical             no-undo. /* включеiна переоценка по приходу */
define input  parameter parrsrv-time    as   integer             no-undo. /* интервал резервирования по расходной накладной */
define input  parameter parload-time    as   integer             no-undo. /* интервал оформления внутреннего прихода */
define input  parameter parholidays     as   character           no-undo. /* выходные дни в неделе */
define input  parameter parmessage      as   logical             no-undo. /* можно задавать вопросы */
define output parameter parchg-inv      as   logical             no-undo. /* Если в статусе разр- было движение товаров, то yes и выходит временная табличка со списком товаров */


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Изменение статуса складского документа":U .

{ cmp/vssrevis.i "substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,parparentproc,parmode,pardoc-code,parcheck-return,pardb-num),substitute('&1|&2|&3|&4|&5':u,parin-ov,parrsrv-time,parload-time,parholidays,parmessage) )" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i noprocess }
{ cmp/library.i  }
{ str/trdcalib.i }
{ str/clcprtsl.i }
{ str/get-pr.i   def }
{ str/lib-trn.i  }
{ str/plgdsfnd.i }
{ str/lib-def.i  }
{ str/lib-calc.i }
{ str/doc-code.i }
{ trg/partslib.i }
{ str/lib-rwds.i }
{ str/libtfarh.i }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ cmp/gds-list.i gds-list def }
{ str/lib-rvs.i  }
/* { gbl/getcntxt.i def } контекст здесь неуместен. Работаем с конкретным документом на конкретном объекте */
{ gbl/thbjattr.i     }
{ str/valddnst.i def }
{ gbl/clntattr.i   }
{ ref/gds-attr.i }
{ gbl/getsect.i  def }
{ gbl/key-rec.i }
{str/utdreturn.i }
{ str/fbrhist.i main }
{ str/tt-fbr-line.i }
{ str/temp_upd.i }
{ str/utd-typemark.i }
define output parameter table for gds-list.

define buffer bf_trn-doc      for ub.trn-doc.
define buffer bf2_trn-doc     for ub.trn-doc.
define buffer exp_trn-doc     for ub.trn-doc.
define buffer in_trn-doc      for ub.trn-doc.
define buffer bf_goods        for ub.goods.
define buffer bf_doc-line     for ub.doc-line.
define buffer bf2_doc-line    for ub.doc-line.
define buffer in_doc-line     for ub.doc-line.
define buffer bf_inv-line     for ub.inv-line.
define buffer bf_clients      for ub.clients.
define buffer bf_pay-type     for ub.pay-type.
define buffer bf_doc-pl       for ub.doc-pl.
define buffer bf_gds-dtl      for ub.gds-dtl.
define buffer bf_currency     for ub.currency.
define buffer bf_parts        for ub.parts.
define buffer bf-cst_parts    for ub.parts.
define buffer bf_gds-prt      for ub.gds-prt.
define buffer bf_dis-card     for ub.dis-card.
define buffer bf_rvs-doc      for ub.rvs-doc.
define buffer bf_rvs-line     for ub.rvs-line.
define buffer bf_store        for ub.store.
define buffer bf_contract     for ub.contract.
define buffer buf_contract-attr for ub.contract-attr.
define buffer ret-doc         for ub.trn-doc.
define buffer old-line        for ub.doc-line.
define buffer ret-dtl         for ub.gds-dtl.
define buffer old-doc         for ub.trn-doc.
define buffer exp-dtl         for ub.gds-dtl.
define buffer c-in            for ub.trn-doc.
define buffer bf-cnt_parts    for ub.parts.
define buffer bf_fin-ob-trn   for ub.fin-ob-trn.
define buffer bf_doc-line-attr  for ub.doc-line-attr.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_cash-pay      for ub.cash-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer bf_utd            for ub.utd.
define buffer bf_utd-l          for ub.utd-lines.
define buffer sep_auto-tank-attr  for ub.auto-tank-attr.

define variable inv-shipvalue                as   logical                     no-undo.
define variable par-gen-mrgn-ie              as   character                   no-undo.
define variable par-gen-mrgn-iv              as   character                   no-undo.
define variable par-gen-mrgn-im              as   character                   no-undo.
define variable par-gen-mrgn-ie-parts        as   character                   no-undo.
define variable par-gen-mrgn-iv-parts        as   character                   no-undo.
define variable par-gen-mrgn-im-parts        as   character                   no-undo.
define variable is-add-charg                 as   character                   no-undo .
define variable varrnd-znk                   as   character initial ?         no-undo.
define variable varrnd-type                  as   character initial ?         no-undo.
define variable clsreserv-pl-code            as   logical                     no-undo.
define variable clspl-code                   like ub.place.pl-code            no-undo.
define variable fact-ok                      as   logical initial yes         no-undo.  /* факт закрытие без коррекции */
define variable varstatus                    like ub.trn-doc.status_          no-undo.
define variable varflag                      like ub.trn-doc.flag_            no-undo.
define variable varoldstatus                 like ub.trn-doc.status_          no-undo.
define variable varoldflag                   like ub.trn-doc.flag_            no-undo.
define variable varcopystatus                like ub.trn-doc.status_          no-undo.
define variable varcopyflag                  like ub.trn-doc.flag_            no-undo.
define variable is-ok                        as   logical                     no-undo.
define variable is-no                        as   logical                     no-undo.
define variable varis-petrol                 as   logical                     no-undo.
define variable varis-pieces                 as   logical                     no-undo.
define variable is-custmvalue                as   character                   no-undo.
define variable is-custmtype                 as   character                   no-undo.
define variable v-today                      as   date                        no-undo.
define variable v-user-action                as   character                   no-undo.
define variable v-printed                    as   logical                     no-undo.
define variable varfact-order                like ub.trn-doc.fact-order       no-undo.
define variable varznak                      as   integer initial -1          no-undo.
define variable varchk-prs                   as   logical                     no-undo.
define variable varchk-prs-type              as   character                   no-undo.
define variable varmy-obj                    as   logical                     no-undo.
define variable varlns-cnt                   as   integer                     no-undo.
define variable lns-cnt                      as   integer                     no-undo.
define variable line-rec                     as   recid                       no-undo.
define variable varnocurbas                  as   character                   no-undo.
define variable varnocurbas-type             as   character                   no-undo.
define variable varprt-b-code                like ub.bar-code.b-code          no-undo.
define variable vardoc-num                   like ub.price-list.doc-num       no-undo.
define variable varprice-sale                like ub.price-list.price-sale    no-undo.
define variable varroad-tax                  like ub.price-list.road-tax      no-undo.
define variable varexcise                    like ub.price-list.excise        no-undo.
define variable varlog                       as   logical                     no-undo.
define variable varcount                     as   integer                     no-undo.
define variable vartime                      as   integer                     no-undo.
define variable l-in-ov                      as   logical                     no-undo.
define variable varcontract                  as   logical                     no-undo.
define variable varcontract-type             as   character                   no-undo.
define variable is-recalc                    as   logical                     no-undo.
define variable varcontract-code             like ub.contract.contract-code   no-undo.
define variable varr-b                       as   character                   no-undo.
define variable varobj-shift-date            as   date                        no-undo.
define variable varobj-shift-num             as   integer                     no-undo.
define variable varobj-shift-name            as   character                   no-undo.
define variable varhold-doc                  as   logical                     no-undo.
define variable vartpsi                      as   character                   no-undo.
define variable vartpsi-type                 as   character                   no-undo.
define variable is-fin                       as   character                   no-undo.
define variable parcontract-code             as   character                   no-undo.
define variable parcontract-type             as   character                   no-undo.
define variable p-status                     as   date                        no-undo .
define variable varminus-parts               as   logical                     no-undo .
define variable varminus-parts-type          as   character                   no-undo.
define variable varerr                       as   logical                     no-undo.
define variable v-mess                       as character                     no-undo .
define variable conf-attr                    as   character                   no-undo.
define variable conf-par                     as   character                   no-undo.
define variable vartechproliv                as   logical                     no-undo.
define variable ii                           as   integer                     no-undo.
define variable v-entry                      as   character                   no-undo.
define variable v-doc-kind                   as   character                   no-undo.
define variable v-obj-type                   as   character                   no-undo.
define variable v-obj-code                   as   integer                     no-undo.
define variable v-tth             as handle no-undo .
define variable v-tth-contr       as handle no-undo .
define variable v-kol-doc as integer   no-undo .
define variable v-is-add-doc as logical   no-undo init false  .
define variable v-reasonm as logical   no-undo init false .
define variable v-reasonme as character no-undo .
define variable v-reasons-for-return as character no-undo . 
define variable v-attr-mandat-wayb  as character no-undo .
define variable v-attr-dop-info  as character no-undo .
define variable v-is-ord-doc as logical   no-undo init false .
define variable v-event-code as character no-undo .
define variable v-is-hold as logical   no-undo .
define variable v-is-negostmess as logical   no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .
define variable v-curr-userid as character no-undo .
define variable varprice-check               as   decimal                     no-undo.
define variable v-not_ver-spec               as   logical                     no-undo.
define variable varvat-type                  as   character                   no-undo.
define variable var-host-code                like ub.trn-doc.contract-code    no-undo.
define variable varinv-prs     as character no-undo.
define variable varinv-prstype as character no-undo.
define variable v-attr-value   as character no-undo.
define variable v-attr-type    as character no-undo.
define variable v-is-foreign-producer as logical no-undo.
define variable p-cons        as integer no-undo .
define variable v-iskp              as logical no-undo .
define variable v-kpsecs       as character no-undo.
define variable v-needsavesec  as logical no-undo.
define variable v-vid-action        as integer no-undo .
define variable v-vid-param         as longchar no-undo .
{ str/initiator.i }
define temp-table tt-trn no-undo like ub.trn-doc.
define variable res        as character no-undo .
define variable infoSectionsTotal as class InfoSectionsTotal no-undo.
define variable vsdSubsObj as class vsdsubs no-undo.
define variable vsdSubCurr as class vsdsub no-undo.
define variable vsdSts as class vsdstatustype no-undo.
define variable vsdStr as class vsdtostorage no-undo.
define variable keyrecObj as class keyrec no-undo.
define variable v-error-attr  as character no-undo .
define variable is-fuel          as   character            no-undo.
def var isFuel as logical no-undo init false. /* топливо и СУГ*/
define variable parisfueltype    as   character            no-undo.
define variable v-valuetype    as   character            no-undo.
define variable v-value        as   character            no-undo.
define variable v-show-str       as character no-undo .
define variable v-add-nat-gas    as logical no-undo .
define variable var-is-auto-trn  as logical no-undo .
define variable v-return-qnty    as decimal no-undo .
define variable varvalue                    as   character              no-undo.
define variable vartype                     as   character              no-undo.
define variable stfactplvalue as character no-undo.
define variable stfactpltype as character no-undo.

define variable varupd-fact-qnty       as logical      no-undo initial yes .
define variable varrevision            as logical      no-undo initial no  .
define variable varpercrev             as decimal      no-undo initial ?   .
define variable varauto-tank           as logical      no-undo initial no  .
define variable varpercauto            as decimal      no-undo initial ?   .
define variable varinv                 as logical      no-undo initial no  .
define variable varpercinv             as decimal      no-undo initial ?   .
define variable varinv-set             as logical      no-undo initial no  .

define variable v-mercury-value as character no-undo .
define variable v-mercury-type  as character no-undo .
define variable v-mercury-prod as logical init false.
define variable keypart as character init false.
define variable v-close as logical.
define variable v-expense-return as logical no-undo init false .

{str/tt-nomark.i}


define stream str-err.

/*define temp-table tt-doc-pl no-undo like ub.doc-pl .*/

  vartime = time. /* время начала процесса для хронометрирования */

do transaction
on error undo, return error return-value
:

  v-show-str = substitute ( '&1 документа "&2"', 
    (if parmode = {&open-doc} then "Открытие" else "Закрытие"),
    pardoc-code 
  ) .
  run waitfram-show in this-procedure ( v-show-str ) no-error.

  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
  if not available bf_trn-doc
  then do:
    run waitfram-hide in this-procedure no-error.
    return error substitute( 'Не найден документ с номером "&1".', pardoc-code ).
  end.

  if bf_trn-doc.status_ = {&fact}
  or bf_trn-doc.status_ = {&ready}
  or bf_trn-doc.status_ = {&rejected}
  then do:
    run waitfram-hide in this-procedure no-error.
    return error substitute( 'Документ "&1" в статусе "&2". Операции с ним невозможны.'
                          , bf_trn-doc.doc-code
                          , bf_trn-doc.status_ ).
  end.

  
{ gbl/curr-r-b.i varr-b }

if valid-handle(parparentproc)
  and lookup( "get-db-num":U, parparentproc:internal-entries ) > 0
  and lookup( "get-userid":U, parparentproc:internal-entries ) > 0
then do:
  run get-db-num in parparentproc
    ( output v-curr-db-num
    ) .
  run get-userid in parparentproc
    ( output v-curr-userid
    ) .
end.
else do:
  assign
    v-curr-db-num = ibs.th.gbl.gbl-var:g#db-num
    v-curr-userid = ibs.th.gbl.gbl-var:g#userid
  .
end.

assign
  varoldstatus = bf_trn-doc.status_
  varoldflag = bf_trn-doc.flag_ 
  .

define variable v-trn-doc-code as character no-undo .
v-trn-doc-code = replace( bf_trn-doc.doc-code, "*", "$" ) .
if search( v-trn-doc-code + ".err" ) <> ?
then do:
  os-delete value( v-trn-doc-code + ".err" ).
 if bf_trn-doc.ext-doc-type = {&TDEDT_Inv}
 then do:
    os-delete value(v-trn-doc-code + "-чеки.err").
  end.
end.

var-is-auto-trn = false.
{ str/tdat-val.i                                    
   bf_trn-doc.doc-code
   {&trdcattr-is-auto-trn}
   v-value 
   v-valuetype no-error}

assign
  var-is-auto-trn = yes when v-value = "yes".



/* Получим из ТПЛ автопереоценок нужные переменные */
{ gbl/gtplmrgn.i
    parparentproc
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    par-gen-mrgn-ie
    par-gen-mrgn-iv
    par-gen-mrgn-im
   no-error }
   if error-status :error then do:
      run waitfram-hide in this-procedure no-error.
      return error substitute( 'На объекте &1 &2  не определен ГТПЛ для автопереоценок.'
                                ,bf_trn-doc.obj-type
                                ,bf_trn-doc.obj-code
                              ).
   end.
{ gbl/partmrgn.i
    parparentproc
    bf_trn-doc.obj-type
    bf_trn-doc.obj-code
    par-gen-mrgn-ie-parts
    par-gen-mrgn-iv-parts
    par-gen-mrgn-im-parts
   no-error }
   if error-status :error then do:
      run waitfram-hide in this-procedure no-error.
      return error substitute( 'На объекте &1 &2  не определен ГТПЛ для автопереоценок.'
                                ,bf_trn-doc.obj-type
                                ,bf_trn-doc.obj-code
                              ).
   end.


/* параметры накладных */
{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_nocurbas}  then varnocurbas = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_rnd-znk}   then varrnd-znk = string(thbjattr_thbj-attr.property-value-integer) .
    if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_chk-prs}   then varchk-prs     = thbjattr_thbj-attr.property-value-logical .
     
end.

{ str/tdat-val.i                                    
 bf_trn-doc.doc-code
 {&trdcattr-is-fuel}
 is-fuel 
 parisfueltype no-error}
assign
  isFuel = yes when is-fuel = "yes".

if not isFuel then do:
  { str/tdat-val.i                                    
   bf_trn-doc.doc-code
   {&trdcattr-is-lgas}
   is-fuel 
   parisfueltype no-error}
  assign
    isFuel = yes when is-fuel = "yes".
end.
if not isFuel
then do:
  { str/tdat-val.i                                    
   bf_trn-doc.doc-code
   {&trdcattr-is-lgas-corr}
   is-fuel 
   parisfueltype no-error}
  assign
    isFuel = yes when is-fuel = "yes".
end.



v-reasonme  = "".
v-attr-mandat-wayb = "".
v-attr-dop-info = "".
{ gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-Code {&attr-nakl_par} }
find first bf_doc-line no-lock where bf_doc-line.doc-code = bf_trn-doc.doc-code no-error.
if error-status :error
then do:
  undo, return error error-status:get-message(1).
end.
{ str/is-petrl.i
  bf_doc-line.artic
  bf_doc-line.prod-type
  bf_doc-line.prod-code
  varis-petrol
  varis-pieces
  no-error
}
if error-status :error
then do:
  undo, return error return-value.
end.
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_minusprt}  then varminus-parts = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_reasonm}   then v-reasonm      = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_reasonme}  then v-reasonme     = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_inv-ship}  then inv-shipvalue  = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = {&attr-nakl_par_reasons-for-return}  then v-reasons-for-return     = thbjattr_thbj-attr.property-value-character .
    if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} 
    then do:
      if isFuel 
      then do:
        if thbjattr_thbj-attr.prop-code = 'attr-PN' then v-attr-mandat-wayb =  thbjattr_thbj-attr.property-value-character .
      end.
      else do:
        if thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-in-wayb' then v-attr-mandat-wayb =  thbjattr_thbj-attr.property-value-character .
      end.
    end.
    if not (varis-petrol and
      not varis-pieces) /*применяеться только если есть хотя бы один не топливный товар в накладной*/
    then do:
      case bf_trn-doc.ext-doc-type:
      when {&TDEDT_Ras_Vnesh_VP} then
        if thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-ret-wayb' then v-attr-mandat-wayb =  thbjattr_thbj-attr.property-value-character .
      when {&TDEDT_Ras_Vnesh} then
        if thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-exp-wayb' then v-attr-mandat-wayb =  thbjattr_thbj-attr.property-value-character .
      end case.
    end.
end.
{ gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-Code {&attr-petrol} }
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = {&attr-petrol_dop-info} then v-attr-dop-info = thbjattr_thbj-attr.property-value-character .  
end.

{ gbl/conf-rd.i  "'is-addch'"  bf_trn-doc.host-code  bf_trn-doc.obj-type  bf_trn-doc.obj-code  "''"  "''"  "''"  no  is-add-charg  par-type  no-error}
if is-add-charg <> 'yes' then is-add-charg = 'no' .

run str/my-obj.p (input bf_trn-doc.obj-type, input bf_trn-doc.obj-code, input pardb-num, output varmy-obj).
run waitfram-show in this-procedure ( input substitute( 'Определяем статус для установки в документе "&1".'
                                                      , pardoc-code ) ) no-error.
run str/trn-graf.p ( input bf_trn-doc.doc-code,
                 input pardb-num,
                 input parmode,
                output varstatus,
                output varflag,
                output varcopystatus,
                output varcopyflag ) no-error.
if error-status :error
then do:
   run waitfram-hide in this-procedure no-error.
   return error return-value.
end.

{ gbl/hold-doc.i
  bf_trn-doc.doc-code
  varhold-doc
}

if varhold-doc = true then do:
  assign
    varcount = 0.
  for each bf_doc-line
    where bf_doc-line.doc-code = bf_trn-doc.doc-code
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure (substitute ("Проверка документа на наличие топливного товара. Проверено строк: &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss"))) no-error.
    assign
      varcount = varcount + 1
    .
    { str/is-petrl.i
      bf_doc-line.artic
      bf_doc-line.prod-type
      bf_doc-line.prod-code
      varis-petrol
      varis-pieces
      no-error
    }
    if error-status :error then do:
      undo, return error return-value.
    end.
    if varis-petrol = true
      and varis-pieces = false
    then do:
      undo, return error substitute("Топливный товар нельзя использовать в межфирменном перемещении! Артикул : &1" , bf_doc-line.artic ).
    end.
  end. /*for each*/
end.

{ gbl/conf-rd.i
  "'stfactpl'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  stfactplvalue
  stfactpltype
  no-error
}

if stfactplvalue <> ""  then 
do:
  { str/chkqtpl.i
   stfactplvalue
   varupd-fact-qnty
   varrevision
   varpercrev
   varauto-tank
   varpercauto
   varinv
   varpercinv
   varinv-set
   no-error
 }
  if error-status :error then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Разборе строки параметра stfactpl" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.
end.

for first buf_doc-attr no-lock where buf_doc-attr.doc-code = bf_trn-doc.doc-code
                                 and buf_doc-attr.attr-code = {&trdcattr-is-return}
:
  if logical(buf_doc-attr.attr-value) then v-expense-return = yes .
end .

if varstatus = {&fact}
and (bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
  or bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
  or bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} 
/*  or v-expense-return*/
    )
then do:
  { gbl/conf-rd.i
    "'mercuri':u"
    "0"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-mercury-value
    v-mercury-type
    no-error
  }
  if  not error-status :error
  and lookup(v-mercury-value, 'th':u) > 0
  then do:
    { gbl/getsect.i run bf_trn-doc.obj-type bf_trn-doc.obj-code {&attr-mercur} }
    
    for each thbjattr_thbj-attr :
      case thbjattr_thbj-attr.prop-code :
        when "close" then v-close = thbjattr_thbj-attr.property-value-logical.
      end case.
    end.

    
    vsdSts = new vsdstatustype ().
    vsdSubsObj = new vsdsubs ().
    vsdStr = new vsdtostorage ().
    keyrecObj = new keyrec ().

    for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code:
      
      if bf_parts.fact-qnty <= 0 then next .
      
      find first bf_goods where 
        bf_goods.artic = bf_parts.artic and
        bf_goods.prod-type = bf_parts.prod-type and
        bf_goods.prod-code = bf_parts.prod-code no-error.
      
      { gbl/gdscdat.i
        bf_goods.gds-code
        "'mercur_FGIS=request':u"
        v-mercury-prod
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Код товара" bf_goods.gds-code skip
          'mercur_FGIS=request':u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      if  bf_trn-doc.fact-date  <> ?
      and bf_trn-doc.shift-date <> ?
      and bf_trn-doc.shift-num  <> ? 
      and bf_trn-doc.shift-name <> ? 
      then do:
       run corr-date in this-procedure
          ( input bf_trn-doc.obj-type
          , input bf_trn-doc.obj-code
          , input bf_trn-doc.fact-date
          , input bf_trn-doc.shift-date
          , input bf_trn-doc.shift-num
          , input bf_trn-doc.shift-name
          ).
      end.
      
      keyrecObj:GenKeyRec({&table_parts}, buffer bf_parts:handle, output keypart).
      vsdsubsObj = vsdStr:getVSDsubs(input "part-key", input keypart).
      if not (vsdSubsObj:iCounter = 0)
      then do:
          vsdSubsObj:GetItem(1).
        end.
      if (vsdSubsObj:iCounter = 0 or vsdSubsObj:VsdObjCurr:UUID = "")
      and v-mercury-prod
      and not var-is-auto-trn
      then do:
        varlog = false.
        if v-close = true
        then do:
          if parmessage then do:
            message   "В документе " bf_trn-doc.doc-code skip
                      "На объекте  " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                      "По товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
                      "Подконтрольного ФГИС Меркурий не заведен ВСД."
                      "Продолжить закрытие документа?"
                      view-as alert-box buttons yes-no update varlog.
            if varlog <> yes
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error.
            end.
          end.
        end.
        else do:
          message   "В документе " bf_trn-doc.doc-code skip
                    "На объекте  " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                    "По товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
                    "Подконтрольного ФГИС Меркурий не заведен ВСД."
                    view-as alert-box error.

          run waitfram-hide in this-procedure no-error.
          undo, return error.
        end.
      end.
      do ii = 1 to vsdSubsObj:GetItem(ii):
        vsdSubCurr = vsdSubsObj:VsdObjCurr.
        vsdSubCurr:FactDatetime = now.
        vsdStr:updateDB(input vsdSubCurr ).
      end.
      
    end.
    
    delete object vsdSts .
    delete object vsdSubsObj .
    delete object vsdStr .
    delete object keyrecObj .
    
  end.
  
  
end.

if ((varstatus = {&wayb} and varflag) or varstatus = {&fact}) and varauto-tank = true and stfactplvalue <> ""
then do:
  define variable v-dec as decimal no-undo .
  v-kpsecs = "" .
  for each bf_doc-line-attr where bf_doc-line-attr.doc-code = bf_trn-doc.doc-code
                              and bf_doc-line-attr.attr-code = "n" 
                              break by bf_doc-line-attr.gds-code :
    def var infoSectionObj as class InfoSection no-undo.
    infoSectionsTotal = new InfoSectionsTotal().
    infoSectionsTotal:Initialization(bf_trn-doc.doc-code, bf_doc-line-attr.gds-code).
/*    infoSectionsTotal:GetDBAllAttr().*/
    { str/tdat-val.i
      bf_trn-doc.doc-code
      {&trdcattr-car-num}
      v-attr-value
      v-attr-type
    }
    if v-attr-value > ""
    then do :
      find first sep_auto-tank-attr no-lock where sep_auto-tank-attr.auto-num = v-attr-value
                                              and sep_auto-tank-attr.attr-code = "auto-sep"
                                              no-error.
      if available sep_auto-tank-attr
      and logical(sep_auto-tank-attr.attr-value)
      then do :
        infoSectionsTotal:IsSGDKK = yes .
      end .
    end .
/*    infoSectionsTotal:CalculateTotal().*/
    find first bf_goods no-lock where bf_goods.gds-code = bf_doc-line-attr.gds-code. 
    find first bf_doc-line no-lock where
                               bf_doc-line.doc-code = bf_trn-doc.doc-code
                           and bf_goods.artic= bf_doc-line.artic
                           and bf_goods.prod-code = bf_doc-line.prod-code
                           and bf_goods.prod-type = bf_doc-line.prod-type no-error.

    run gds-attr-value in this-procedure
      (  input bf_doc-line-attr.gds-code
        ,input {&attr-fuel-type}
        ,output v-attr-value
        ,output v-attr-type
       ) .
    if v-attr-value = "lgas" then 
    do:
      infoSectionObj = infoSectionsTotal:GetInfoSectionProp(1).
      infoSectionObj:FactKgQnty = bf_doc-line.fact-qnty * bf_doc-line.fact-density.
      infoSectionObj:FactQnty = bf_doc-line.fact-qnty.
      infoSectionObj:FactDensity = bf_doc-line.fact-density.
      infoSectionsTotal:SaveDB().
    end.
    else do:
        if absolute (infoSectionsTotal:DocQntyTotal - bf_doc-line.doc-qnty) > 1
        or absolute (infoSectionsTotal:DocDensityAvg - bf_doc-line.doc-density) > 1
        or absolute (infoSectionsTotal:CliQntyTotal - bf_doc-line.cli-qnty) > 1
        then do:
          v-mess = substitute("Кол-во по линии накладной не совпадает с общим кол-вом по доп. инфо! Артикул : &2.&1По линии накладной:&1    по ТТН - &3&1    плотность - &4&1    по накл. - &5&1По доп. инфо:&1    по ТТН - &6&1    плотность - &7&1    по накл. - &8",
                                          {&new-line}, 
                                          bf_doc-line.artic,
                                          bf_doc-line.doc-qnty,
                                          bf_doc-line.doc-density,
                                          bf_doc-line.cli-qnty,
                                          infoSectionsTotal:DocQntyTotal,
                                          infoSectionsTotal:DocDensityAvg,
                                          infoSectionsTotal:CliQntyTotal
                                          ).
          delete object infoSectionsTotal.
          undo, return error v-mess.
        end.
        if varstatus = {&fact} then do:
          if (infoSectionsTotal:FactQntyTotal = ? or infoSectionsTotal:FactKgQntyTotal = ? ) or (absolute (infoSectionsTotal:FactQntyTotal - bf_doc-line.fact-qnty) > 1
           or absolute (infoSectionsTotal:FactKgQntyTotal - bf_doc-line.fact-density * bf_doc-line.fact-qnty) > 1)
          then do:
            v-mess = substitute("Кол-во по линии накладной не совпадает с общим кол-вом по доп. инфо! Артикул : &2.&1По линии накладной:&1    факт. кол-во - &3&1    Факт. кол-во, вес - &4&1По доп. инфо:&1    факт. кол-во - &5&1    Факт. кол-во, вес - &6",
                                            {&new-line}, 
                                            bf_doc-line.artic,
                                            bf_doc-line.fact-qnty,
                                            bf_doc-line.fact-density * bf_doc-line.fact-qnty,
                                            infoSectionsTotal:FactQntyTotal,
                                            infoSectionsTotal:FactKgQntyTotal
                                            ).
            delete object infoSectionsTotal.
            undo, return error v-mess.
          end.
        end.
        v-iskp = no .
        v-needsavesec = no .
        do ii = 1 to infoSectionsTotal:SectionNum : 
          infoSectionObj = infoSectionsTotal:GetInfoSectionProp(ii).
          if varstatus = {&fact}
          then do :
            if infoSectionObj:IsKP
            then do :
              { gbl/chk-actg.i
                v-curr-db-num
                v-curr-userid
                {&action-head-code-main}
                'actn_income_petrol-сommission':U
                {&cntxt-object}
                bf_trn-doc.host-code
                bf_trn-doc.obj-type
                bf_trn-doc.obj-code
                0
                0
                0
                true
                varlog
              }
              if not varlog
              then do:
                undo, return error substitute( 'По секциям включен комиссионный прием нефтепродукта. Отсутствует право.').
              end.
            end .
          
            if infoSectionsTotal:IsSGDKK
            then do :
              
            end .
            else do :
              if not infoSectionObj:KPnoMeas
              then do :
                v-dec = decimal(infoSectionObj:TankWeight) no-error .
                if error-status:error
                or v-dec = 0
                then do :
                  v-mess = "Не произведён расчёт измеренной массы НП (" + string(infoSectionsTotal:GdsCode) + ") в секции АЦ (" + infoSectionObj:SectionName + "). Закрытие документа невозможно".
                  delete object infoSectionsTotal .
                  undo, return error v-mess.
                end .
              end .
            end .
            
          end .
          else do :
            if first-of(bf_doc-line-attr.gds-code)
            then do :
              if infoSectionsTotal:IsSGDKK
              then do :
                if infoSectionObj:alarm-SGDKK
                then do :
                  v-kpsecs = v-kpsecs + infoSectionObj:SectionName + " (" + bf_goods.gds-name + "), " .
                  if not infoSectionObj:IsKP
                  then do :
                    infoSectionObj:IsKP = yes .
                    v-needsavesec = yes .
                  end .
                end .
                else do :
                  if infoSectionObj:IsKP
                  then do :
                    infoSectionObj:IsKP = no .
                    v-needsavesec = yes .
                  end .
                end .
              end .
              else do :
                if infoSectionObj:KPnoMeas
                then do :
                  v-kpsecs = v-kpsecs + infoSectionObj:SectionName + " (" + bf_goods.gds-name + "), " .
                  if not infoSectionObj:IsKP
                  then do :
                    infoSectionObj:IsKP = yes .
                    v-needsavesec = yes .
                  end .
                end .
                else do :
/*                  if infoSectionObj:IsKP*/
/*                  then do :             */
                    infoSectionObj:IsKP = no .
                    infoSectionObj:TankWeight = 0 .
                    v-needsavesec = yes .
/*                  end .*/
                end .
              end .
            end .
          end .
          if not v-iskp 
          and not infoSectionsTotal:IsSGDKK
          then do:
            v-iskp = infoSectionObj:IsKP.
          end.
        end.
        if v-needsavesec
        then do :
          infoSectionsTotal:SaveDB().
        end .
        
        delete object infoSectionsTotal.
        
/*        if v-iskp                                                                                                     */
/*        then do:                                                                                                      */
/*          { gbl/chk-actg.i                                                                                            */
/*            v-curr-db-num                                                                                             */
/*            v-curr-userid                                                                                             */
/*            {&action-head-code-main}                                                                                  */
/*            'actn_income_petrol-сommission':U                                                                         */
/*            {&cntxt-object}                                                                                           */
/*            bf_trn-doc.host-code                                                                                      */
/*            bf_trn-doc.obj-type                                                                                       */
/*            bf_trn-doc.obj-code                                                                                       */
/*            0                                                                                                         */
/*            0                                                                                                         */
/*            0                                                                                                         */
/*            true                                                                                                      */
/*            varlog                                                                                                    */
/*          }                                                                                                           */
/*          if not varlog                                                                                               */
/*          then do:                                                                                                    */
/*            undo, return error substitute( 'По секциям включен комиссионный прием нефтепродукта. Отсутствует право.').*/
/*          end.                                                                                                        */
/*        end.                                                                                                          */
      end.
    
  end.
  v-kpsecs = trim(v-kpsecs, ", ") .
  if v-kpsecs > ""
  then do :
    message "Для секций " v-kpsecs " установлен признак «Комиссионный прием НП». После перевода накладной в статус «накл+» продолжение работы с секциями с комиссионным приемом НП будет доступно только пользователю с правами комиссионной приемки." skip
            "Вы уверены, что хотите закрыть накладную?"
    view-as alert-box question buttons yes-no update varlog .
    if not varlog
    then do :
      undo, return .
    end .
  end .
end.


if  varstatus = {&fact}
and bf_trn-doc.doc-type = {&expense}
and bf_trn-doc.internal = false
and bf_trn-doc.is-flora = true
then do:
   run ie-date in this-procedure.
end.


assign varlns-cnt = 0 .
run waitfram-show in this-procedure ( input substitute( "Переход документа в статус &1&2."
                                                      , varstatus
                                                      , ( if varstatus = {&fact} then ''  else
                                                         (if varflag   = yes     then "+" else "-" ) ) ) ).

  case parmode:
    when {&close-doc}  or
    when {&close-fact}
    then do:
      /* Общие проверки при закрытии */

      if not( bf_trn-doc.status_ = {&inquiry}  )
      then do :
        { str/resvinqv.i bf_trn-doc.doc-code  is-no }
          if is-no = false
          then do:
              { str/delnabor.i parparentproc bf_trn-doc.doc-code no-error }
              if error-status :error
              then do:
                  undo, return error substitute( 'Ошибка при удалении наборов в документе  "&1" .', bf_trn-doc.doc-code ).
              end.
          end.
      end.


  /* Проверим АссПолитику */
  define variable v-kol-e as integer   no-undo .
  v-kol-e = 0.
  if  bf_trn-doc.status_ = {&wayb} and bf_trn-doc.flag_ = false
  then do :
  varerr = false .
  for each bf_doc-line no-lock where
            bf_doc-line.doc-code =  bf_trn-doc.doc-code
            :
       v-kol-e = v-kol-e + 1.
       if g#auto <> yes and not g#esys then do:
         run verify-assort-pol
         ( bf_doc-line.artic ,
           bf_doc-line.prod-type ,
           bf_doc-line.prod-code ) no-error .
            if error-status :error
            then do:
              assign
                varerr = true .
            end.
       end.
  end.

  if v-kol-e = 0 then do:
    run waitfram-hide in this-procedure no-error.
    return error substitute( 'Документ &1 пуст !' ,  bf_trn-doc.doc-code ).
  end.

  if varerr = true
  then do:
    run gbl/prnfilen.w
      (input  "Ошибки по соответствию товаров в накладной и Ассортиментной политике"
      ,input  0
      ,input  replace(bf_trn-doc.doc-code, "*", "$") + ".err"
      ,input  7
      ,output v-user-action
      ,output v-printed
      ).
    run waitfram-hide in this-procedure no-error.
    return error substitute( 'Ошибки по соответствию товаров в накладной и Ассортиментной политике. ' +
                             'Смотри файл "&1.err"'
                            , replace( bf_trn-doc.doc-code, "*", "$" ) ).
    
  end.
  end.
  assign
     vartechproliv = no.
  if bf_trn-doc.obj-type = {&shop} then do:
     run adm/shattri.p (
               input "get":U
              ,input  bf_trn-doc.obj-type
              ,input  bf_trn-doc.obj-code
              ,input  {&attr-autosale}
              ,input  {&attr-autosale_sale-add} /*p-param-code*/
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output par-type
              ,input-output table-handle v-tth
              ) no-error .
     if error-status:error then do:
        if valid-object(v-tth) then delete object v-tth.
        undo, return error return-value + error-status :get-message(1) .
     end.
     if valid-object(v-tth) then delete object v-tth.

     _ii:
     do ii = 1 to num-entries(v-value-character, ';':U):
        assign
            v-entry    =  ENTRY(ii, v-value-character, ';':U)
            v-doc-kind = ENTRY(1, v-entry)
            v-obj-type = entry (2, v-entry)
            v-obj-code = integer(entry (3, v-entry))
        .
        if v-doc-kind = {&sale-add-tech-refuell} and
           bf_trn-doc.cli-type = v-obj-type      and
           bf_trn-doc.cli-code = v-obj-code      
        then do:
          vartechproliv = yes.
          { str/tdat-wrt.i                                    
             bf_trn-doc.doc-code
             {&trdcattr-techpass}
             "yes" 
          no-error}
        end.
        if v-doc-kind = {&sale-add-nat-gas} and
           bf_trn-doc.cli-type = v-obj-type      and
           bf_trn-doc.cli-code = v-obj-code      
        then do:
          v-add-nat-gas = true.
        end.
      end. /*do ii*/
      
      _cpa:
      for each buf_cash-pay-attr where buf_cash-pay-attr.attr-code = "dop-doc" no-lock:

        v-value-character = buf_cash-pay-attr.attr-value.
        
        case entry(1, v-value-character, ','):
          when {&sale-add-write-off} then do: /* Списание */
            if entry(2, v-value-character, ',') = bf_trn-doc.cli-type and integer (entry(3, v-value-character, ',')) = bf_trn-doc.cli-code 
            then do:
              vartechproliv = yes.
              { str/tdat-wrt.i                                    
                 bf_trn-doc.doc-code
                 {&trdcattr-techpass}
                 "yes" 
              no-error}
              leave _cpa.
            end.
          end.
          when {&sale-add-tech-refuell} then do: /* Техпролив */
            if entry(2, v-value-character, ',') = bf_trn-doc.cli-type and integer (entry(3, v-value-character, ',')) = bf_trn-doc.cli-code 
            then do:
              vartechproliv = yes.
              { str/tdat-wrt.i                                    
                 bf_trn-doc.doc-code
                 {&trdcattr-techpass}
                 "yes" 
              no-error}
              leave _cpa.
            end.
          end.
/*          when {&sale-add-vir-res} then do: /* Перемещение в вирт.рез. */                                                                 */
/*            if entry(2, v-value-character, ',') = bf_trn-doc.cli-type and integer (entry(3, v-value-character, ',')) = bf_trn-doc.cli-code*/
/*            then do:                                                                                                                      */
/*              vartechproliv = yes.                                                                                                        */
/*              { str/tdat-wrt.i                                                                                                            */
/*                 bf_trn-doc.doc-code                                                                                                      */
/*                 {&trdcattr-techpass}                                                                                                     */
/*                 "yes"                                                                                                                    */
/*              no-error}                                                                                                                   */
/*              leave _cpa.                                                                                                                 */
/*            end.                                                                                                                          */
/*          end.                                                                                                                            */
        end case.
      end.
  end.
  /*проверка на заполнение обязательных атрибутов в накладной*/
  
  if not var-is-auto-trn and not v-add-nat-gas and not vartechproliv and v-attr-mandat-wayb <> "" and not bf_trn-doc.doc-code matches "*=*" then do:
      v-error-attr = "" .
      if not can-find (first buf_doc-attr no-lock where buf_doc-attr.doc-code = pardoc-code 
        and lookup (buf_doc-attr.attr-code, v-attr-mandat-wayb) > 0)
      then v-error-attr = "empty".

      if bf_trn-doc.VAT-rubl = 0
      then do:
         if 
             (num-entries (v-attr-mandat-wayb) = 2 and lookup ({&trdcattr-nsf}, v-attr-mandat-wayb) > 0 and lookup ({&trdcattr-dsf}, v-attr-mandat-wayb) > 0)
          or (num-entries (v-attr-mandat-wayb) = 1 and lookup ({&trdcattr-nsf}, v-attr-mandat-wayb) > 0 or lookup ({&trdcattr-dsf}, v-attr-mandat-wayb) > 0)
          then v-error-attr = "".
      end.
      
      for each buf_doc-attr no-lock where buf_doc-attr.doc-code = pardoc-code 
        and lookup (buf_doc-attr.attr-code, v-attr-mandat-wayb) > 0 
        and not lookup (buf_doc-attr.attr-code, {&trdcattr-nsf} + "," + {&trdcattr-dsf}) > 0
        and buf_doc-attr.attr-value = "":
        v-error-attr = v-error-attr + ", " + buf_doc-attr.attr-code .
      end.
      
      
      for each buf_doc-attr no-lock where
        bf_trn-doc.VAT-rubl > 0
        and buf_doc-attr.doc-code = pardoc-code
        and lookup (buf_doc-attr.attr-code, v-attr-mandat-wayb) > 0 
        and lookup (buf_doc-attr.attr-code, {&trdcattr-nsf} + "," + {&trdcattr-dsf}) > 0
        and buf_doc-attr.attr-value = "":
        v-error-attr = v-error-attr + ", " + buf_doc-attr.attr-code .
      end.
      
      if v-error-attr <> "" then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error "Не все атрибуты накладной заполнены.".
      end.  
  end.
  v-error-attr = "".
  if not var-is-auto-trn and not vartechproliv and isFuel and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
  then do:
    do ii = 1 to num-entries (v-attr-dop-info):
      find first buf_doc-attr no-lock 
        where buf_doc-attr.doc-code = pardoc-code 
          and buf_doc-attr.attr-code = entry (ii, v-attr-dop-info) no-error. 
      
      if not available (buf_doc-attr) or (available (buf_doc-attr) and 
        (buf_doc-attr.attr-value = "" 
        or buf_doc-attr.attr-value = "" or buf_doc-attr.attr-value = ? or buf_doc-attr.attr-value = "?")
        )
      then do:
        v-error-attr = v-error-attr + ", " + entry (ii, v-attr-dop-info).
      end.
    end.
    if v-error-attr <> "" then do:
      run waitfram-hide in this-procedure no-error.
      undo, return error "Не все обязательные поля по доп. информации накладной заполнены".
    end.
  end.
    
  if bf_trn-doc.status_ <> {&inquiry}  then do:
  /* */
    define variable v-reasonm-type-n as character no-undo.

    if v-reasonm and
             lookup( bf_trn-doc.ext-doc-type ,v-reasonme) = 0 and
             lookup( bf_trn-doc.ext-doc-type ,{&TDEDT_List-not-ver-reason}) = 0
    then do:
      if bf_trn-doc.reason-code = 0 or bf_trn-doc.reason-code = ? then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error "Не задано поле ПРИЧИНА СОЗДАНИЯ ДОКУМЕНТА.".
      end.
    end.
    
    if lookup( string(bf_trn-doc.reason-code), v-reasons-for-return) > 0
    and bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
    and not v-expense-return
    then do : 
      /*Возврат через расход*/
      find first in_trn-doc no-lock where in_trn-doc.doc-code = bf_trn-doc.out-code no-error .
      if not available in_trn-doc
      then do :
        run waitfram-hide in this-procedure no-error.
        undo, return error "Не задано поле Источник.".
      end.
      else do :
        if in_trn-doc.cli-type <> bf_trn-doc.cli-type
        or in_trn-doc.cli-code <> bf_trn-doc.cli-code
        then do :
          run waitfram-hide in this-procedure no-error.
          undo, return error ("Поставщик не совпадает с поставщиком из источника (ПН " + in_trn-doc.doc-code + ").").
        end.
        for each bf_doc-line no-lock where bf_doc-line.doc-code = bf_trn-doc.doc-code,
        first ub.goods no-lock where  ub.goods.artic      = bf_doc-line.artic
                                  and ub.goods.prod-type  = bf_doc-line.prod-type
                                  and ub.goods.prod-code  = bf_doc-line.prod-code :
          find first in_doc-line no-lock where in_doc-line.doc-code   = in_trn-doc.doc-code
                                           and in_doc-line.artic      = bf_doc-line.artic
                                           and in_doc-line.prod-type  = bf_doc-line.prod-type
                                           and in_doc-line.prod-code  = bf_doc-line.prod-code
                                           no-error.
          if not available in_doc-line
          then do :
            run waitfram-hide in this-procedure no-error.
            undo, return error ("Товара с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name + " нет в документе-источнике (ПН " + in_trn-doc.doc-code + ").") .
          end. 
          else do :
            find first bf_gds-dtl no-lock where bf_gds-dtl.doc-code   = bf_doc-line.doc-code
                                            and bf_gds-dtl.artic      = bf_doc-line.artic  
                                            and bf_gds-dtl.prod-type  = bf_doc-line.prod-type
                                            and bf_gds-dtl.prod-code  = bf_doc-line.prod-code
                                            no-error .
            if not available bf_gds-dtl
            then do :
              run waitfram-hide in this-procedure no-error.
              undo, return error ("Отсутствет детализация по товару с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name ) .
            end.                                
            if in_doc-line.price-rubl <> bf_gds-dtl.price-rubl
            or in_doc-line.price-base <> bf_gds-dtl.price-base
            then do :
              run waitfram-hide in this-procedure no-error.
              undo, return error ("У товара с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name + " цена не совпадает с ценой в документе-источнике (ПН " + in_trn-doc.doc-code + ").") .
            end.
            if in_doc-line.fact-qnty < bf_doc-line.fact-qnty
            then do :
              run waitfram-hide in this-procedure no-error.
              undo, return error ("У товара с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name + " количество превышает количество в документе-источнике (ПН " + in_trn-doc.doc-code + ").") .
            end.
            
            assign v-return-qnty = 0 .
            for each bf2_trn-doc no-lock where bf2_trn-doc.out-code = bf_trn-doc.out-code
                                           and bf2_trn-doc.status_  = {&fact} :
              if lookup( string(bf2_trn-doc.reason-code), v-reasons-for-return) > 0
              then do :
                for each bf2_doc-line no-lock where bf2_doc-line.doc-code   = bf2_trn-doc.doc-code
                                                and bf2_doc-line.artic      = bf_doc-line.artic
                                                and bf2_doc-line.prod-type  = bf_doc-line.prod-type
                                                and bf2_doc-line.prod-code  = bf_doc-line.prod-code :
                  assign v-return-qnty = v-return-qnty + bf2_doc-line.fact-qnty .                               
                end.
              end.                               
            end.     /* for each bf2_trn-doc */
            if in_doc-line.fact-qnty < (bf_doc-line.fact-qnty + v-return-qnty)
            then do :
              run waitfram-hide in this-procedure no-error.
              undo, return error ("Товар с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name + {&new-line} +
                                  "Общее количество уже возвращенного товара по ПН " + in_trn-doc.doc-code + ":  " + string(v-return-qnty) + {&new-line} +
                                  "Количество в ПН:  " + string(in_doc-line.fact-qnty) + {&new-line} +
                                  "Максимальное количество, которое можно указать для возврата:  " + string(in_doc-line.fact-qnty - v-return-qnty) + {&new-line} +
                                  "Вы указали:  " + string(bf_doc-line.fact-qnty)
                                   ) .
            end. 
          end. /* available in_doc-line */
        end. /* for each bf_doc-line, goods */
      end. /* available in_trn-doc */
    end. /*Возврат через расход*/
  end. 
  
  define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
  if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
  then do :
    find first ub.contract no-lock where ub.contract.contract-code = bf_trn-doc.contract-code
                                     and ub.contract.host-code = bf_trn-doc.host-code
                                     no-error .
    find first ub.utd no-lock where ub.utd.doc-code = bf_trn-doc.doc-code no-error .                                 
    if available ub.contract
    and not available ub.utd
    then do :
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code).
      find first buf_contract-attr no-lock where buf_contract-attr.host-code = ub.contract.host-code
                                                 and buf_contract-attr.contract-code = ub.contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
      if EDOParSec:IsEdo
      and available buf_contract-attr
      and logical(buf_contract-attr.attr-value) = true 
      then do :
        run waitfram-hide in this-procedure no-error.
        undo, return error ("Договор " + ub.contract.contract-name + " рассчитан на поставки через ЭДО. Ручной приход по нему невозможен!") .
      end .
    end . 
    /* Приемка СУГ */
    for first doc-attr no-lock where doc-attr.doc-code  = bf_trn-doc.doc-code 
                                 and doc-attr.attr-code = {&trdcattr-is-lgas}       
                                 :
      if logical(doc-attr.attr-value)
      then do :
        define variable v-trn-reas-sug as logical no-undo .
        define variable v-trn-reas-sug-type as character no-undo .
        delete object v-tth no-error.
        run adm/shattri.p (
             input "get":U
            ,input bf_trn-doc.obj-type
            ,input bf_trn-doc.obj-code
            ,input {&attr-petrol}
            ,input  "trn-reas-sug"
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-trn-reas-sug
            ,output v-trn-reas-sug-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        if error-status :error  then v-trn-reas-sug = true .
        delete object v-tth no-error.
        if v-trn-reas-sug
        and (bf_trn-doc.reason-code = 0 or bf_trn-doc.reason-code = ?)
        then do :
          run waitfram-hide in this-procedure no-error.
          undo, return error "Не задано поле по этапу приема СУГ - укажите финальный или не финальный слив газовоза".
        end .
      end .                             
    end .                                 
  end .

  if bf_trn-doc.status_ <> {&inquiry}                           and
        not (bf_trn-doc.status_  = {&wayb}   and
              bf_trn-doc.doc-type = {&return} and
              bf_trn-doc.internal)                                  and
        not (
              bf_trn-doc.status_ = {&wayb}                          and
              (bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or
              bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}       ) and
              varhold-doc = yes
              )
  then do:
     if varchk-prs and not (bf_trn-doc.status_ = {&wayb} and varflag = true)
     then do:
        define buffer buf_sale-doc for ub.sale-doc.
        if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
            /*это приход по техпроливу по продаже*/
            find first buf_sale-doc no-lock where
                      buf_sale-doc.doc-code = bf_trn-doc.doc-code no-error.
        end.
        if not available buf_sale-doc
          or (available buf_sale-doc and buf_sale-doc.doc-kind <> {&sale-add2-in-tech-refuell})
        then do:
            /*проверяем если документы не по продаже*/
           find first bf_clients where bf_clients.obj-type = {&prs}          and
                                       bf_clients.obj-code = bf_trn-doc.boss no-lock no-error.
           if not available bf_clients
           then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Не указан или неправильный менеджер.".
           end.
           find first bf_clients where bf_clients.obj-type = {&prs}          and
                                        bf_clients.obj-code = bf_trn-doc.agnt no-lock no-error.
           if not available bf_clients
           then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Не указан или неправильный исполнитель.".
           end.
        end.
     end.
  end.

  /* Параметр "is-fin" (Доступна группа меню Взаиморасчёты) задаётся через
    'АРМ Администратор/Справочники/Настройки и конфигурация системы'
     или при первоначальной настройке системы */
  { gbl/conf-rd.i "'is-fin'"  "''" "''" 0 "''" "''" "''" no is-fin par-type no-error }

  if is-fin = "yes" or
     bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or
     bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
  then do:
     run adm/shattri.p (
         input "get":U
        ,input  bf_trn-doc.obj-type
        ,input  bf_trn-doc.obj-code
        ,input  {&attr-contr-in}
        ,input  (if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} then "contr-in-expense" else "contr-in-income")
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output varcontract
        ,output v-value-character
        ,input-output table-handle v-tth-contr
        ) no-error  .
     if error-status:error then do:
        if valid-object(v-tth-contr) then delete object v-tth-contr.
        undo, return error return-value + error-status :get-message(1) .
     end.
     if valid-object(v-tth-contr) then delete object v-tth-contr.
  end.

     if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} and
        bf_trn-doc.status_      = {&wayb}            and
        (bf_trn-doc.flag_ = no and varhold-doc = no or bf_trn-doc.flag_ = yes and varhold-doc = yes) and
        varcontract   = yes and
        vartechproliv = no
        and not isFuel
        and not bf_trn-doc.doc-code matches "*=*" 
      then do:
        if is-fin = "yes":u
        then do:
            if (bf_trn-doc.contract-code = 0 or bf_trn-doc.contract-code = ?)
            then do:
              run waitfram-hide in this-procedure .
              /* Почему не даёт закрывать приходную накладную без указания договора:
  
bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} = ie   = приход внешний
bf_trn-doc.status_      = {&wayb}            = wayb = накл

hold-doc-01: определяет тип документа - холдинговый или нет
varhold-doc = gbl/hold-doc.i = (
    ( buf_trn-doc.hold-doc-code-child  <> ""
  and buf_trn-doc.hold-doc-code-child  <> "no-hold":u )
or
    ( buf_trn-doc.hold-doc-code-parent <> ""
  and buf_trn-doc.hold-doc-code-parent <> "no-hold":u )
                               ) - холдинговый 

(bf_trn-doc.flag_ = no  and varhold-doc = no or - незакрытый и нехолдинговый, или
 bf_trn-doc.flag_ = yes and varhold-doc = yes)  - закрытый и холдинговый
         
        ,input  bf_trn-doc.obj-type
        ,input  bf_trn-doc.obj-code
varcontract  = attr-contr-in (Настройки для Накладных в разрезе ВЗАИМОРАСЧЕТОВ) +
               contr-in-income (Обязательная ссылка на договор в приходной накладной)
        
vartechproliv = no
              */              
              undo, return error "Не указан номер договора. В Настройках для Накладных в разрезе ВЗАИМОРАСЧЕТОВ установлена Обязательная ссылка на договор в приходной накладной.".
            end.
        end.
        else do:
          { str/tdat-val.i bf_trn-doc.doc-code
                        {&trdcattr-ndog}
                        parcontract-code
                        parcontract-type    no-error }
          if error-status :error
          then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error return-value.
          end.
          if (parcontract-code = "" or parcontract-code = ?)
          then do:
            run waitfram-hide in this-procedure .
            undo, return error "Не указан номер договора. В Настройках для Накладных в разрезе ВЗАИМОРАСЧЕТОВ установлена Обязательная ссылка на договор в приходной накладной.".
          end.
        end.
      end.
      
      if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and
        bf_trn-doc.status_      = {&wayb}            and
        varhold-doc             = no                 and
        varcontract             = yes
      then do:
        if is-fin = "yes":u
        then do:
            if (bf_trn-doc.contract-code = 0 or bf_trn-doc.contract-code = ?)
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Не указан номер договора для РН.".
            end.
        end.
      end.

      if bf_trn-doc.status_ <> {&inquiry}
      then do:
        find first bf_pay-type where bf_pay-type.obj-code = bf_trn-doc.pay-code no-lock no-error.
        if not available bf_pay-type
        then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error "Не указан или неправильный вид оплаты.".
        end.
      end.
      if bf_trn-doc.doc-type <> {&inventory}
      then do:
        for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value:
          if varstatus          = {&fact}            and
            bf_doc-line.doc-qnty <> bf_doc-line.fact-qnty
          then do:
            fact-ok = no.
          end.
        end.
      end.
      if bf_trn-doc.ext-doc-type = {&TDEDT_Inv} and varstatus = {&fact}
      then do:

        { gbl/getsect.i run "''" 0  {&attr-inv-global} }
        for each thbjattr_thbj-attr :
            if thbjattr_thbj-attr.prop-code = 'inv-prs'  then varinv-prs = string( thbjattr_thbj-attr.property-value-integer).
        end.
        if integer(varinv-prs) <> 0 then do :
          if integer(varinv-prs) = bf_trn-doc.reason-code then do:
            for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value:
              if bf_doc-line.fact-qnty <> 0
              then do:
                message
                  "Инвентаризация используется в качестве документа пересортицы" skip
                  "Для товара с артикулом" bf_doc-line.artic "разница не равна 0" skip
                  "Документ не может быть закрыт до статуса" {&fact} skip
                view-as alert-box error.
                undo,return error.
              end.
            end.
          end.
          else do :
            assign
              varlog = no
            .
            { gbl/chk-actg.i
              v-curr-db-num
              v-curr-userid
              {&action-head-code-main}
              'actn_inventory_fact_not-peresort':U
              {&cntxt-object}
              bf_trn-doc.host-code
              bf_trn-doc.obj-type
              bf_trn-doc.obj-code
              0
              0
              0
              true
              varlog
            }
            if varlog <> yes
            then do:
              undo, return error.
            end.
          end.
        end.
        { str/tdat-val.i
          bf_trn-doc.doc-code
          {&trdcattr-inv-introduce}
          v-attr-value
          v-attr-type
          no-error
        }
        
        def var v-minus as logical no-undo.
        run adm/shattri.p (
           input "get":U
          ,input bf_trn-doc.obj-type
          ,input bf_trn-doc.obj-code
          ,input {&attr-inv-obj}
          ,input  "minus"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-minus
          ,output v-attr-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
        
        if not v-minus
        then do:
          for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code 
            and bf_doc-line.doc-qnty < 0 on error undo, return error return-value:
            
            find first bf_goods where bf_goods.artic = bf_doc-line.artic
              and bf_goods.prod-type = bf_doc-line.prod-type
              and bf_goods.prod-code = bf_doc-line.prod-code no-lock.
            
            assign
              varerr = true.
            
            output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
            put    stream str-err unformatted substitute ("Товар &1 &2 имеет отрицательное фактическое кол-во: было &3, стало &4", bf_goods.artic, bf_goods.gds-name, (bf_doc-line.doc-qnty - bf_doc-line.fact-qnty), bf_doc-line.doc-qnty) skip.
            output stream str-err close.
            
          end.
        end.
        
        if varerr
        then do:
          if g#auto <> yes then do:

            run gbl/prnfilen.w
              (input  "Ошибкa. Имеются товары с отрицательным фактическим кол-вом"
              ,input  0
              ,input  replace(bf_trn-doc.doc-code, "*", "$") + ".err"
              ,input  7
              ,output v-user-action
              ,output v-printed
              ).
          end.
          return error substitute( 'Ошибкa. Имеются товары с отрицательным фактическим кол-вом' +
                                  'Смотри файл "&1.err"'
                                , replace( bf_trn-doc.doc-code, "*", "$" ) ).
        end.
        
        if not error-status:error and v-attr-value = "yes" then do:
          find first bf_utd where bf_utd.doc-code = bf_trn-doc.doc-code no-error.
          if available bf_utd 
          then do:
            bf_utd.sts = objSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB.
            
            for each bf_utd-l no-lock where bf_utd-l.db-num = bf_utd.db-num 
              and bf_utd-l.doc-id = bf_utd.doc-id 
              :
              
              find first bf_goods no-lock where bf_goods.gds-code = bf_utd-l.gds-code no-error.
              if not available (bf_goods)
              then do:
                message
                "По документу" bf_trn-doc.doc-code skip
                "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                "В документе первоначального ввода неизвестный товар " bf_utd-l.gds-code
                view-as alert-box information .
                  run waitfram-hide in this-procedure no-error.
                  undo, return error.
              end.
              find first bf_doc-line no-lock where
                               bf_doc-line.doc-code = bf_trn-doc.doc-code
                           and bf_goods.artic= bf_doc-line.artic
                           and bf_goods.prod-code = bf_doc-line.prod-code
                           and bf_goods.prod-type = bf_doc-line.prod-type no-error.
              if not available (bf_doc-line)
              then do:
                message
                "По документу" bf_trn-doc.doc-code skip
                "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                "В инвентаризации отсутсвует линия из первоначального ввода с товаром " bf_utd-l.gds-code
                view-as alert-box information .
                  run waitfram-hide in this-procedure no-error.
                  undo, return error.
              end.
              
              create ub.utd-lines-attr.
                ub.utd-lines-attr.doc-id = bf_utd-l.doc-id.
                ub.utd-lines-attr.db-num = bf_utd-l.db-num.
                ub.utd-lines-attr.LineNum = bf_utd-l.LineNum.
                ub.utd-lines-attr.attr-code = "NoMarking".
                ub.utd-lines-attr.attr-value = string (bf_doc-line.doc-qnty - bf_utd-l.Quantity).
                if bf_doc-line.doc-qnty - bf_utd-l.Quantity > 0
                then do:
                  create tt-no-marking-gds.
                  tt-no-marking-gds.artic = bf_goods.artic.
                  tt-no-marking-gds.qnty = ub.utd-lines-attr.attr-value.
                  tt-no-marking-gds.gds-name = bf_goods.gds-name.
                end.

              create ub.utd-lines-attr.
              ub.utd-lines-attr.doc-id = bf_utd-l.doc-id.
              ub.utd-lines-attr.db-num = bf_utd-l.db-num.
              ub.utd-lines-attr.LineNum = bf_utd-l.LineNum.
              ub.utd-lines-attr.attr-code = "utd-fact-qnty".
              ub.utd-lines-attr.attr-value = string (bf_doc-line.doc-qnty).

              if bf_doc-line.doc-qnty - bf_utd-l.Quantity < 0 and not g#news
              then do:
                message
                "По документу" bf_trn-doc.doc-code skip
                "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                "Товар " bf_goods.gds-code skip
                bf_goods.gds-name skip
                substitute ("Кол-во марок &1 больше кол-ва товара &2.", bf_utd-l.Quantity,  bf_doc-line.doc-qnty)
                view-as alert-box information .
                  run waitfram-hide in this-procedure no-error.
                  undo, return error.
              end.
              
            end.
            define variable v-not-accept as logical no-undo.
            find first tt-no-marking-gds no-lock where integer (tt-no-marking-gds.qnty) > 0 no-error.
            if not g#news and available (tt-no-marking-gds)
              then run str/inv-br1.w (input table tt-no-marking-gds, output v-not-accept).
            if v-not-accept
              then undo, return.
            
          end.
        end.
        for each ub.marking-attr where (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan") and ub.marking-attr.attr-value = bf_trn-doc.doc-code:
          delete ub.marking-attr.
        end.
        
      end.
      /*Проверка цен в документе*/
      { str/chkprdtl.i bf_trn-doc.doc-code no-error }
      if error-status :error then do:
         undo, return error return-value  .
      end.
      { gbl/curobjdt.i bf_trn-doc.obj-type bf_trn-doc.obj-code v-today }
      run waitfram-show in this-procedure ( input substitute( "Локирование товаров при закрытии документа. Время: &1"
                                                            , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
      run trg/lock-gds.p
        (input bf_trn-doc.doc-code /* v-trn-doc-doc-code     */
        ,input no               /* p-check-inv            */
        ,input no               /* p-check-inv-rasr-minus */
        ,input 0                /* p-document-fact-order  */
        ,input 0                /* p-document-fact-order-price  */
        ,input false            /* p-fact-close           */
        ,input false            /* p-is-news              */
        ) no-error .
      if error-status :error
      then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error .
      end.

      /* ----------------------------------Внешний приход--------------------------------------------------------------------------------------------- */
      case bf_trn-doc.ext-doc-type:
      when {&TDEDT_Pri_Vnesh}
      then do:
        if varhold-doc
        then do:
          run hold-check no-error.
          if error-status :error
          then do:
            return error return-value.
          end.
        end.
        { gbl/conf-rd.i
          "'tpsi'"
          0
          "''"
          0
          "''"
          "''"
          "''"
          no
          vartpsi
          vartpsi-type
        }
        if vartpsi = "yes":u and varhold-doc = no
        then do:
          for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code,
            first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                                bf_goods.prod-type = bf_doc-line.prod-type and
                                bf_goods.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
            { str/igdstpsi.i
              bf_goods.gds-code
              bf_trn-doc.obj-type
              bf_trn-doc.obj-code
              no-error
            }
            if error-status :error
            then do:
              return error return-value.
            end.
          end.
        end.
        if bf_trn-doc.status_ = {&wayb} and bf_trn-doc.flag_ = yes  or
          parmode = {&close-fact}
        then do:


          find first bf-cnt_parts where bf-cnt_parts.out-code      = bf_trn-doc.doc-code and
                                        bf-cnt_parts.contract-code > 0                   and
                                        bf-cnt_parts.fact-qnty    <> 0                   no-lock no-error.
          if available bf-cnt_parts
          then do:
          v-not_ver-spec = false .
          run need-ver-spec ( output v-not_ver-spec ) no-error .

            assign
              varerr = no.
            bf_parts_cycle:
            for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code and
                                    bf_parts.fact-qnty <> 0                 no-lock on error undo, return error return-value :
              if bf_parts.contract-code = 0 then next.
              find first bf_goods where bf_goods.artic     = bf_parts.artic     and
                                        bf_goods.prod-type = bf_parts.prod-type and
                                        bf_goods.prod-code = bf_parts.prod-code no-lock.
              { str/in-vatp.i calc-parts bf_parts. bf_trn-doc. }
              assign
                varprice-check = (price-cli-with-tax-loc + road-tax-cli-loc
                                  + (if bf_parts.vat-type <> {&inc-vat} then vat-cli-loc else 0)
                                  + (if bf_parts.slt-type <> {&inc-slt} then slt-cli-loc else 0) ) / bf_parts.cli-base-rate.


              assign
              var-host-code = bf_parts.host-code
/*                var-host-code = ( if varhold-doc then bf_trn-doc.host-code  else bf_parts.host-code )*/
              .
              { str/ckcntspc.i
                var-host-code
                bf_parts.contract-code
                bf_goods.gds-code
                varprice-check
                bf_parts.VAT-type
                bf_parts.VAT-pc
                no-error
              }

              if error-status :error
              then do:
                assign
                  varerr = yes.
                output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
                put    stream str-err unformatted return-value skip.
                output stream str-err close.
                next bf_parts_cycle.
              end.
            end.
            if varerr = yes
            then do:
              if v-not_ver-spec = false then do:
              if g#auto <> yes and not g#esys then do:

                run gbl/prnfilen.w
                  (input  "Ошибки по соответствию товаров в накладной и спецификации к договору"
                  ,input  0
                  ,input  replace(bf_trn-doc.doc-code, "*", "$") + ".err"
                  ,input  7
                  ,output v-user-action
                  ,output v-printed
                  ).
              end.
              return error substitute( 'Есть ошибки по соответствию товаров в накладной и спецификации к договору. ' +
                                      'Смотри файл "&1.err"'
                                    , replace( bf_trn-doc.doc-code, "*", "$" ) ).

              end.
            end.
         end.
        end.
        /*накл -*/
        if not bf_trn-doc.flag_ and
          bf_trn-doc.status_ = {&wayb}
        then do:
          if bf_trn-doc.tot-cli = ?
          then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error "Не указана сумма в валюте поставщика.".
          end.

          if inv-shipvalue = true and not varhold-doc
          then do:
              if (bf_trn-doc.inv-num = ? or bf_trn-doc.ship-date = ? or bf_trn-doc.ship-num = ?)
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error "Не указан инвойс или отгрузка.".
              end.
          end.
          { gbl/conf-rd.i
            "'is-custm':u"
            0
            "''"
            0
            "''"
            "''"
            "''"
            no
            is-custmvalue
            is-custmtype
          }
          if is-custmvalue = "yes"
          then do:
            find first bf-cst_parts where bf-cst_parts.out-code = bf_trn-doc.doc-code and
                                          bf-cst_parts.cst-code = ""                  or
                                          bf-cst_parts.out-code = bf_trn-doc.doc-code and
                                          bf-cst_parts.cst-code = ?                   no-error.
            if available bf-cst_parts
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( 'В документе "&1" есть партия товара &2 &3 &4 с кодом &5, '
                                            + 'имеющая некорректный номер ГТД: "&6".'
                                            , bf-cst_parts.out-code
                                            , bf-cst_parts.artic
                                            , bf-cst_parts.prod-type
                                            , bf-cst_parts.prod-code
                                            , bf-cst_parts.part-code
                                            , bf-cst_parts.cst-code ).
            end.
          end.
        end.
        if varstatus          =  {&fact}   and
          bf_trn-doc.status_ =  {&wayb}   and
          not varmy-obj
        then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error "Закрыть накладную по ФАКТУ можно только для объекта своей базы данных или пассивного объекта.".
        end.
        
        
         { str/tdat-val.i
            bf_trn-doc.doc-code
            {&trdcattr-is-lgas}
            v-attr-value
            v-attr-type
            no-error 
         }
        if not v-attr-value = "yes"
        then do:
         { str/tdat-val.i
            bf_trn-doc.doc-code
            {&trdcattr-is-lgas-corr}
            v-attr-value
            v-attr-type
            no-error 
         }
        end.
        
        if v-attr-value = "yes"
        then do:
          
          { str/tdat-val.i
              bf_trn-doc.doc-code
              {&trdcattr-date-start}
              v-attr-value
              v-attr-type
              no-error 
          }
          
          if v-attr-value = "" or v-attr-value = ? or error-status:error
          then do:
            find first bf_rvs-doc exclusive-lock
              where bf_rvs-doc.rvs-type = {&rvs-before-doc}
                and bf_rvs-doc.out-code = bf_trn-doc.doc-code
              no-error .
            
            for first bf_rvs-line no-lock
              where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code
                and bf_rvs-line.obj-type = bf_rvs-doc.obj-type
                and bf_rvs-line.obj-code = bf_rvs-doc.obj-code
                by bf_rvs-line.real-date
                by bf_rvs-line.real-time:
              
              if bf_rvs-line.real-date <> ?
              then do:
              
                v-attr-value = string (bf_rvs-line.real-date).
                
                { str/tdat-wrt.i
                    bf_trn-doc.doc-code
                    {&trdcattr-date-start}
                    v-attr-value
                    no-error
                }
                v-attr-value = string (bf_rvs-line.real-time, "HH:MM").
                { str/tdat-wrt.i
                    bf_trn-doc.doc-code
                    {&trdcattr-time-start}
                    v-attr-value
                    no-error
                }
              end.
            end.
            find first bf_rvs-doc exclusive-lock
              where bf_rvs-doc.rvs-type = {&rvs-after-doc}
                and bf_rvs-doc.out-code = bf_trn-doc.doc-code
              no-error .
            for last bf_rvs-line no-lock
              where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code
                and bf_rvs-line.obj-type = bf_rvs-doc.obj-type
                and bf_rvs-line.obj-code = bf_rvs-doc.obj-code
                by bf_rvs-line.real-date
                by bf_rvs-line.real-time:
                  
              if bf_rvs-line.real-date <> ?
              then do:
              
                v-attr-value = string (bf_rvs-line.real-date).
                
                { str/tdat-wrt.i
                    bf_trn-doc.doc-code
                    {&trdcattr-date-end}
                    v-attr-value
                    no-error
                }
                v-attr-value = string (bf_rvs-line.real-time, "HH:MM").
                { str/tdat-wrt.i
                    bf_trn-doc.doc-code
                    {&trdcattr-time-end}
                    v-attr-value
                    no-error
                }
              end.
            end.
          end.
        end.
      
        
        /* проверяем по строчкам */
        if bf_trn-doc.status_ <> {&inquiry}
        then do:
          { str/chklinst.i this-procedure:handle bf_trn-doc.doc-code varstatus fact-ok no-error }
            if error-status :error
            then do:
              return error return-value.
            end.
          if round (bf_trn-doc.tot-cli,  (if varrnd-znk = ? then 2 else integer(varrnd-znk) ) ) <>
            round (bf_trn-doc.tot-calc, (if varrnd-znk = ? then 2 else integer(varrnd-znk) ) )
          then do:
            find first bf_currency where bf_currency.curr-code = bf_trn-doc.exch-code no-lock.
            run waitfram-hide in this-procedure no-error.
            undo, return error "Неправильно указана сумма в валюте поставщика, или ошибка при заполнении накладной !" + {&new-line} +
                              substitute( "Сумма по накладной : &1 &2."
                                        , string( round( bf_trn-doc.tot-cli,  if varrnd-znk = ? then 2 else integer( varrnd-znk ) ) )
                                        , bf_currency.curr-abbr ) + {&new-line} +
                              substitute( "Сумма по всем строкам : &1 &2."
                                        , string( round( bf_trn-doc.tot-calc, if varrnd-znk = ? then 2 else integer( varrnd-znk ) ) )
                                        , bf_currency.curr-abbr ) + {&new-line} +
                              "Эти суммы должны совпадать !"
                              .
          end.
        end.
        if varstatus           = {&fact} and
          bf_trn-doc.obj-type = {&shop} and
          can-find (first ub.scales no-lock where ub.scales.db-num = g#db-num)
        then do:
          { str/add-scal.i parparentproc bf_trn-doc.obj-type bf_trn-doc.obj-code bf_trn-doc.doc-code bf_trn-doc.doc-type this-procedure no-error }
          if error-status :error
          then do:
            undo, return error return-value .
          end.
        end.
        if varstatus = {&fact} then do :
            run adm/shattri.p (
                input "get":U
                ,input bf_trn-doc.obj-type
                ,input bf_trn-doc.obj-code
                ,input {&attr-nakl_par}
                ,input  "gtd-to-imp-prod"
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output v-value-logical
                ,output par-type
                ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
                ) no-error .
            if not error-status :error and v-value-logical = true then do :
              for each bf_doc-line no-lock
                 where bf_doc-line.obj-code = bf_trn-doc.obj-code
                   and bf_doc-line.obj-type = bf_trn-doc.obj-type
                   and bf_doc-line.doc-code = bf_trn-doc.doc-code
                   :
                   run clntattr-value in this-procedure ( input bf_doc-line.prod-type, input bf_doc-line.prod-code, input {&attr-foreign-producer}, output v-attr-value, output v-attr-type ) .
                   assign v-is-foreign-producer = logical( v-attr-value ) .
                   if v-is-foreign-producer = true then do :
                      find first bf-cst_parts
                            where bf-cst_parts.obj-type  = bf_trn-doc.obj-type   and
                                  bf-cst_parts.obj-code  = bf_trn-doc.obj-code   and
                                  bf-cst_parts.prod-type = bf_doc-line.prod-type and
                                  bf-cst_parts.prod-code = bf_doc-line.prod-code and
                                  bf-cst_parts.artic     = bf_doc-line.artic     and
                                  bf-cst_parts.out-code  = bf_trn-doc.doc-code   no-lock no-error.
                      if available bf-cst_parts and ( bf-cst_parts.cst-code = "" or bf-cst_parts.cst-code = ? )
                      then do :
                        undo, return error substitute ("Закрытие накладной по ФАКТУ невозможно. Для товара &1 &2 &3 не указан номер ГТД."  ,
                                                        bf_doc-line.artic     ,
                                                        bf_doc-line.prod-type ,
                                                        bf_doc-line.prod-code ) .
                      end.
                   end.
              end.
            end.
            run adm/shattri.p (
                input "get":U
                ,input bf_trn-doc.obj-type
                ,input bf_trn-doc.obj-code
                ,input {&attr-nakl_par}
                ,input  "exc-max-qnty"
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output v-value-logical
                ,output par-type
                ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
                ) no-error .
            if not error-status :error and v-value-logical = true then do :
              for each bf_doc-line no-lock
                 where bf_doc-line.obj-code = bf_trn-doc.obj-code
                   and bf_doc-line.obj-type = bf_trn-doc.obj-type
                   and bf_doc-line.doc-code = bf_trn-doc.doc-code
                   :
                   find first gds-obj no-lock
                        where gds-obj.obj-type  = bf_trn-doc.obj-type
                          and gds-obj.obj-code  = bf_trn-doc.obj-code
                          and gds-obj.artic     = bf_doc-line.artic
                          and gds-obj.prod-type = bf_doc-line.prod-type
                          and gds-obj.prod-code = bf_doc-line.prod-code no-error .
                   if available gds-obj then do :
                      find first gds-obj-prop no-lock
                            where gds-obj-prop.obj-type = gds-obj.obj-type
                              and gds-obj-prop.obj-code = gds-obj.obj-code
                              and gds-obj-prop.gds-code = gds-obj.gds-code no-error .
                      if available gds-obj-prop and gds-obj-prop.grop-max-stock <> ?
                                                and gds-obj-prop.grop-max-stock <> 0 then do :
                        if gds-obj-prop.grop-max-stock < gds-obj.fact-qnty + bf_doc-line.cli-qnty then do :
                            undo, return error substitute ("Закрытие накладной по ФАКТУ невозможно.Для товара &1 &2 &3 будет превышен максимальный остаток на объекте."  ,
                                                            bf_doc-line.artic     ,
                                                            bf_doc-line.prod-type ,
                                                            bf_doc-line.prod-code ) .
                        end.
                      end.
                   end.
               end.
            end.
        end.
        /*блок закрытия внешнего прихода*/
        if is-add-charg = 'yes' then do:
          /* Проверим баз. валюту */
              for each ub.add-trn no-lock where
                        ub.add-trn.trn-doc-code = bf_trn-doc.doc-code ,
                        first ub.add-doc no-lock where
                              ub.add-doc.doc-code = ub.add-trn.doc-code
                        :
                        if not  ( bf_trn-doc.base-rate  = ub.add-doc.base-rate  and
                                  bf_trn-doc.base-scale = ub.add-doc.base-scale ) then do:
                            run waitfram-hide in this-procedure no-error.
                            undo, return error substitute ( "Курс базовой валюты ПН &2 должен совпадать с курсом ДопРасха &1 .", ub.add-doc.doc-code ,bf_trn-doc.doc-code ).
                        end.
              end.
        end.


        if varstatus = {&fact}
        then do:
          if bf_trn-doc.tot-other  <> 0 or
             bf_trn-doc.tot-transp <> 0
          then do:
            define variable v-not-calc as logical   no-undo .
               v-not-calc = false .

            if is-add-charg = 'yes' then do:

              find first ub.add-trn no-lock where
                         ub.add-trn.trn-doc-code = bf_trn-doc.doc-code no-error .
              find first ub.add-doc no-lock where
                         ub.add-doc.doc-code = ub.add-trn.doc-code no-error .
              if available ub.add-doc then do:
                /* просчитаются в своем блоке */
                v-not-calc = true .
              end.
            end.
            if v-not-calc = false then do:  /*Размазка старым способом СМОТРИ еще в add-docs */
                run waitfram-show in this-procedure ( input substitute( "Расчет транспортных и прочих расходов. Время: &1"
                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run str/add-exp.p (input parparentproc,
                                input bf_trn-doc.doc-code ,
                                input bf_trn-doc.tot-other  * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale,
                                input bf_trn-doc.tot-transp * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute ( "Ошибка при установке дополнительных расходов &1 &2.", return-value ).
                end.
            end.
          end.

          /*  Дополнительные расходы c документом  */
          if is-add-charg = 'yes' then do:
             find first ub.add-trn no-lock where
                        ub.add-trn.trn-doc-code = bf_trn-doc.doc-code no-error .
             if available ub.add-trn then do:
             find first ub.add-doc no-lock where
                        ub.add-doc.doc-code = ub.add-trn.doc-code no-error .
             if not available ub.add-doc then do:
                  if parmessage = yes
                  then do:
                    assign
                      varlog = no.
                    message
                    "На документ" bf_trn-doc.doc-code skip
                    "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                    "Нет документа дополнительных расходов."
                    view-as alert-box information .
                      run waitfram-hide in this-procedure no-error.
                      undo, return error.
                  end.
                  else do:
                      run waitfram-hide in this-procedure no-error.
                      undo, return error "Нет документа дополнительных расходов.".
                  end.
             end.
             end.

             find first ub.add-doc no-lock where
                        ub.add-doc.doc-code = ub.add-trn.doc-code no-error .
             if not available ub.add-doc then do:
                  if parmessage = yes
                  then do:
                    assign
                      varlog = no.
                    message
                    "На документ" bf_trn-doc.doc-code skip
                    "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                    "Не создан документ дополнительных расходов."
                    "Продолжить закрытие документа?"
                    view-as alert-box buttons yes-no update varlog.
                    if varlog <> yes
                    then do:
                      run waitfram-hide in this-procedure no-error.
                      undo, return error.
                    end.
                  end.
             end.
             else do:
             /* есть допрасходы */
                if ub.add-doc.status_ <> {&add-close}
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute ( "Не закрыт документ дополнительного расхода &1 для ПН &2.", ub.add-doc.doc-code ,bf_trn-doc.doc-code ).
                end.


                v-is-add-doc = false .
                run many-add-docs in parparenthandle (output v-is-add-doc) no-error .
                if error-status :error then v-is-add-doc = false .
                if v-is-add-doc <> true  then do:
                    v-kol-doc = 0 .
                    for each ub.add-trn no-lock where
                             ub.add-trn.doc-code = ub.add-doc.doc-code :
                        v-kol-doc = v-kol-doc + 1 .
                    end.
                    if v-kol-doc = 1 then do:
                        run str/add-exp.p (input parparentproc,
                                        input bf_trn-doc.doc-code ,
                                        input bf_trn-doc.tot-other  * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale,
                                        input bf_trn-doc.tot-transp * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) no-error.
                        if error-status :error
                        then do:
                          run waitfram-hide in this-procedure no-error.
                          undo, return error substitute ( "Ошибка при установке дополнительных расходов &1 &2.", return-value , error-status :get-message(1) ).
                        end.

                        run str/addsuper.p
                          (input parparentproc,
                                input ub.add-doc.doc-code
                              ) no-error.
                        if error-status :error
                        then do:
                          run waitfram-hide in this-procedure no-error.
                          undo, return error substitute ( "Ошибка при размазывании дополнительных расходов в учетной цене &1 Документ ДопРасхода &2 ПН &3 .",  return-value ,ub.add-doc.doc-code , bf_trn-doc.doc-code ).
                        end.
                        run str/addclos.p
                            ( input Parparentproc,
                              recid(ub.add-doc)
                            ) no-error .
                        if error-status :error
                        then do:
                          run waitfram-hide in this-procedure no-error.
                          undo, return error substitute ( "Ошибка при закрытии ДопРасхода &1 &2.", return-value , ub.add-doc.doc-code).
                        end.

                    end.
                    else do:
                        run waitfram-hide in this-procedure no-error.
                        undo, return error  "К одному документу ДопРасхода привязано несколько ПН . Закрыть Приходные накладные можно только из интерфейса Документов ДопРасходав" .
                    end.
                end.
                else do:
                   /* все ОК размазано уже из интерфейса add-docs */
                end.
             end.
          end.
          /*-----------------------------------------------------------*/

          run waitfram-show in this-procedure ( input substitute( "Установка фактической даты в документе. Время: &1"
                                                                , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
          /* оформление внешнего прихода задним числом */
          run ie-date in this-procedure no-error.
          if error-status :error
          then do:
            return error return-value.
          end.

          /* закрытие документов сверки <<перед документом>> */
          run waitfram-show in this-procedure
            ( input substitute( "Закрытие документа сверки '&1'. Время: &2.", {&rvs-before-doc}, string( time - vartime, "hh:mm:ss":U ) )
            ) no-error.
          run close-rvs in this-procedure
            ( input bf_trn-doc.doc-code
             ,input {&rvs-before-doc}
             ,input bf_trn-doc.fact-date
             ,input bf_trn-doc.fact-time
             ,input bf_trn-doc.shift-date
             ,input bf_trn-doc.shift-num
             ,input bf_trn-doc.shift-name
            ) no-error .
          if error-status :error then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error return-value.
          end.

          run waitfram-show in this-procedure ( input substitute( "Резервирование товаров по складским местам. Время &1."
                                                                , string(time - vartime, "hh:mm:ss") ) ) no-error.
          { str/rsrplgds.i bf_trn-doc.doc-code }
          run waitfram-hide in this-procedure no-error.
/*1----------------------внешний ПН */
          run str/in-pr.p ( input parparentproc, input recid( bf_trn-doc ), input "cost-price":U ) no-error.
          if error-status :error
          then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error return-value.
          end.
          if ( par-gen-mrgn-ie = {&typeprice_before-margin} and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} ) or
             ( par-gen-mrgn-iv = {&typeprice_before-margin} and bf_trn-doc.ext-doc-type =  {&TDEDT_Pri_Perem} )

          then do:
            run str/in-pr.p ( input parparentproc, input recid( bf_trn-doc ), input "before-margin" ) no-error .
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( 'Ошибка при создании автоматической переоценки. Документ "&1". '
                                          + 'Тип переоценки: &2 &3 &4.'
                                          , bf_trn-doc.doc-code
                                          , {&typeprice_before-margin}
                                          , return-value
                                          , bf_trn-doc.ext-doc-type ).
            end.
          end.
/*1----------------------*/

          if varnocurbas <> "yes"
          then do:
            assign
              varcount = 0.
            for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_trn-doc.doc-code on error undo, return error return-value :
              run waitfram-show in this-procedure ( input substitute( "Установка продажных цен в признаках документа. "
                                                                    + "Обработано признаков: &1. Время &2."
                                                                    , varcount
                                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
              assign
              varcount = varcount + 1.
              find first bf_goods where bf_goods.artic     = bf_gds-dtl.artic     and
                                        bf_goods.prod-type = bf_gds-dtl.prod-type and
                                        bf_goods.prod-code = bf_gds-dtl.prod-code no-lock.
              /*Проверка наличия текущей продажной цены*/
              { gbl/gdsbcode.i
                bf_goods.gds-code
                bf_gds-dtl.prt-code
                varprt-b-code
                no-error
              }
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( 'Ошибка при определении бар-кода признака. Документ "&1". Товар &2 &3 &4. '
                                            + 'Код признака &5. &7'
                                            , bf_trn-doc.doc-code
                                            , bf_goods.artic
                                            , bf_goods.prod-type
                                            , bf_goods.prod-code
                                            , bf_gds-dtl.prt-code
                                            , return-value ).
              end.
              { gbl/bcodeprc.i
                bf_trn-doc.obj-type
                bf_trn-doc.obj-code
                varprt-b-code
                0
                bf_trn-doc.fact-order
                vardoc-num
                varprice-sale
                varroad-tax
                varexcise
                no-error
              }
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( 'Ошибка &1 при определении цены бар-кода. Документ "&2". Объект &3 &4. '
                                            + 'Товар &5 &6 &7. Бар-код &8.'
                                            , return-value
                                            , bf_trn-doc.doc-code
                                            , bf_trn-doc.obj-type
                                            , bf_trn-doc.obj-code
                                            , bf_goods.artic
                                            , bf_goods.prod-type
                                            , bf_goods.prod-code
                                            , varprt-b-code ).
              end.
              if varprice-sale = 0 or
                varprice-sale = ?
              then do:
                  
                run gds-attr-value in this-procedure (input bf_goods.gds-code
                                         ,input {&attr-null-price}
                                         ,output v-attr-value
                                         ,output v-attr-type ) no-error.
                                                                                  
                if (varnocurbas = "no"       or
                  varnocurbas = "no_today") and bf_trn-doc.fact-date = v-today and not logical(v-attr-value)
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( 'Не задана текущая продажная цена. Закрытие документа отменяется. '
                                              + 'Документ "&1". Объект &2 &3. Товар &4 &5 &6. Бар-код &7.'
                                              , bf_trn-doc.doc-code
                                              , bf_trn-doc.obj-type
                                              , bf_trn-doc.obj-code
                                              , bf_goods.artic
                                              , bf_goods.prod-type
                                              , bf_goods.prod-code
                                              , varprt-b-code ).
                end.
                else do:
                  if parmessage = yes
                  then do:
                    assign
                      varlog = no.
                    message
                    "В документе " bf_trn-doc.doc-code skip
                    "На объекте  " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                    "По товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
                    "Не задана продажная цена."
                    "Продолжить закрытие документа?"
                    view-as alert-box buttons yes-no update varlog.
                    if varlog <> yes
                    then do:
                      run waitfram-hide in this-procedure no-error.
                      undo, return error.
                    end.
                  end.
                end.
              end.
            end. /* for each */
          end. /* проверять продажные цены */

          assign
            bf_trn-doc.status_ = varstatus
            bf_trn-doc.flag_   = fact-ok
          .
          run cus/rcvsttr.p  ( input parparentproc, input recid(bf_trn-doc) ) no-error .
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( "Ошибка при обработке заказа: &1.", return-value ).
              end.
        end. /* статус fact */
        else do: /* статус не fact */
          if bf_trn-doc.status_ = {&inquiry} and
            bf_trn-doc.flag_
          then do:
            /* Генерация ПН из запроса */
            /* Создаем копию запроса */
            run waitfram-show in this-procedure ( input substitute( "Генерация приходной накладной из запроса. Время: &1"
                                                                  , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
            create c-in.
            /* подбираем уникальный номер - для документа - щепки */
            run doc-code in this-procedure
            (input  "chip",
            input  bf_trn-doc.obj-type,
            input  bf_trn-doc.obj-code,
            input  bf_trn-doc.doc-code,
            output c-in.doc-code  ) no-error.
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибка при генерации номера документа &1.", return-value ).
            end.
            buffer-copy bf_trn-doc
            except doc-code      out-code
                  acc-date      creid
                  discnt-type   discnt-pc
                  tot-calc      discnt-rubl
                  tot-lines     doc-qnty
                  fact-base     fact-rubl
                  fact-num      fact-qnty
                  cli-qnty
                  fact-date     ov
                  tot-doc       tot-fact
                  tot-ov        tot-rubl
                  tot-sale      VAT-base
                  VAT-rubl
            to c-in.
            assign
              c-in.doc-type  = {&income}
              c-in.internal  = no
              c-in.office    = no
              c-in.status_   = varcopystatus
              c-in.flag_     = varcopyflag
              c-in.doc-date  = v-today
              c-in.ord-num   = bf_trn-doc.doc-code  /* ! */
              c-in.VAT-type  = bf_trn-doc.vat-type
              c-in.SLT-type  = bf_trn-doc.slt-type
              c-in.PS = "@  ПН получена из запроса : " + bf_trn-doc.doc-code + chr (10) +
                            "Для расчета итогов по документу нажмите Измен.".
            run waitfram-show in this-procedure ( input substitute( "Заполнение данных перед копированием в документ. "
                                                + "Время: &1"
                                                , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
            run fill-tt (input bf_trn-doc.doc-code) no-error.
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Ошибка при копировании данных в накладную.".
            end.
            { str/copy-in.i
              parparentproc
              recid(c-in)
              lib-trn_ret-doc
              lib-trn_ret-line
              lib-trn_ret-line-attr
              lib-trn_ret-dtl
              lib-trn_ret-parts
              yes
              yes
              no
              yes
              this-procedure
              no-error
            }
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Ошибка при копировании данных в накладную.".
            end.
            if not can-find (first bf_doc-line where bf_doc-line.doc-code = c-in.doc-code no-lock)
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "На основании запроса уже созданы приходные накладные. Копирование отменяется.".
            end.
          end. /*запрос +*/
          if bf_trn-doc.status_ = {&wayb} and
            bf_trn-doc.flag_   = yes
          then do:
            assign
              varcount = 0.
            for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error :
              find first bf_goods where bf_goods.artic     = bf_doc-line.artic
                                    and bf_goods.prod-code = bf_doc-line.prod-code
                                    and bf_goods.prod-type = bf_doc-line.prod-type no-lock .
              run waitfram-show in this-procedure ( input substitute( "Проверка цен в признаках документа. "
                                                                    + "Проверено признаков: &1. Время &2."
                                                                    , varcount
                                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
              assign
                varcount = varcount + 1.
              { str/is-petrl.i
                bf_goods.artic
                bf_goods.prod-type
                bf_goods.prod-code
                varis-petrol
                varis-pieces
                no-error
              }
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error return-value.
              end.
              if varis-petrol     and
                  not varis-pieces
              then do:
                  { str/lnfactqt.i
                    parparentproc
                    recid(bf_doc-line)
                    yes
                    bf_trn-doc.status_
                    bf_trn-doc.flag_
                    no-error
                  }
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
                run gbl/calc-trn.p (input parparentproc, input recid(bf_trn-doc) ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
              end.
            end.

          end.
          assign
            bf_trn-doc.status_  = varstatus
            bf_trn-doc.flag_    = varflag.
        end. /*статус не fact*/
        run fill-mol .
      end. /* приход внешний */
      when {&TDEDT_Ras_Vnesh}     or
      when {&TDEDT_Ras_Vnesh_VP}  or
      when {&TDEDT_Ras_Perem}     or
      when {&TDEDT_Spi_Vnesh}     or
      when {&TDEDT_Vozvrat_Vnesh} or
      when {&TDEDT_Vozvrat_Perem} or
      when {&TDEDT_Pri_Perem}     or
      when {&TDEDT_Ras_Object}    or
      when {&TDEDT_Pri_Object}     
      then do:
        if ( bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}    or
            bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
            bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} ) and
          varhold-doc
        then do:
          run hold-check.
        end.
        /* проверка на превышение лимита кредита по договору */
        if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and  bf_trn-doc.contract-code > 0 and ( parmode = {&close-doc} or parmode = {&close-fact}) then do:
          find first bf_contract where bf_contract.contract-code = bf_trn-doc.contract-code and bf_contract.host-code = bf_trn-doc.host-code 
          and bf_contract.usl-opl <> '{&bef-contr-pay-nodef}' or bf_contract.usl-opl <> '{&bef-contr-buyer-ord}' or bf_contract.usl-opl <> '{&bef-contr-buyer-ord}'
          no-error .
          if not available bf_contract then do:
          find first bf_fin-ob-trn where bf_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code and (bf_fin-ob-trn.sum-rubl = bf_trn-doc.tot-fact or bf_fin-ob-trn.sum-rubl = (bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl)) no-error.
            if not available bf_fin-ob-trn then do: 
              run str/limcontr.p ( input bf_trn-doc.host-code, input bf_trn-doc.contract-code, input 0, input bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl, input bf_trn-doc.tot-fact ) no-error .
              if error-status :error then return error return-value .
            end.
          end.  
          end.
        if (bf_trn-doc.status_ = {&wayb} and bf_trn-doc.flag_ = yes  or
          parmode = {&close-fact})
          and (bf_trn-doc.contract-code <> 0  and bf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} )       /*Если не указан договор, то и не нужно ничего проверять. Если возврат, то возвращаем все что есть, в независимости от спецификации */
        then do:

          v-not_ver-spec = false .
          run need-ver-spec ( output v-not_ver-spec ) no-error .
            assign
              varerr = no.
            bf_doc-line_cycle:
            for each bf_doc-line no-lock
               where bf_doc-line.doc-code   = bf_trn-doc.doc-code
                 and bf_doc-line.fact-qnty  <> 0
               :
/*            if bf_trn-doc.contract-code = 0 then next.*/

              for each bf_gds-dtl no-lock
                where bf_gds-dtl.prod-type  = bf_doc-line.prod-type
                  and bf_gds-dtl.prod-code  = bf_doc-line.prod-code
                  and bf_gds-dtl.artic      = bf_doc-line.artic
                  and bf_gds-dtl.doc-code   = bf_doc-line.doc-code
              :

                find first bf_goods where bf_goods.artic     = bf_gds-dtl.artic     and
                                          bf_goods.prod-type = bf_gds-dtl.prod-type and
                                          bf_goods.prod-code = bf_gds-dtl.prod-code no-lock.

                { str/out-vatp.i calc-gds-dtl bf_doc-line. bf_trn-doc. bf_gds-dtl. }

                assign
                  varprice-check = price-rubl-with-tax-sale
                  .

                if ( bf_trn-doc.vat-type <> "" and bf_trn-doc.vat-type <> ? )
                then do :
                  varvat-type = substitute("&1,&2", bf_trn-doc.vat-type, bf_trn-doc.doc-code).
                end.
                else do :
                  varvat-type = substitute("&1,&2", {&inc-vat}, bf_trn-doc.doc-code).
                end.
                assign
                  var-host-code = bf_trn-doc.host-code 
/*                  var-host-code = ( if varhold-doc then bf_trn-doc.cli-code  else bf_trn-doc.host-code )*/
                .

                if not v-expense-return
                then do :
                  { str/ckcntspc.i
                    var-host-code
                    bf_trn-doc.contract-code
                    bf_goods.gds-code
                    varprice-check
                    varvat-type
                    bf_doc-line.VAT-pc
                    no-error
                  }
                  if error-status :error
                  then do:
                    assign
                      varerr = yes.
                    output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
                    put    stream str-err unformatted return-value skip.
                    output stream str-err close.
                    next bf_doc-line_cycle.
                  end.
                end .
              end.
            end.
            if varerr = yes
            then do:
              if v-not_ver-spec = false then do:
              if g#auto <> yes and not g#esys then do:

                run gbl/prnfilen.w
                  (input  "Ошибки по соответствию товаров в накладной и спецификации к договору"
                  ,input  0
                  ,input  replace(bf_trn-doc.doc-code, "*", "$") + ".err"
                  ,input  7
                  ,output v-user-action
                  ,output v-printed
                  ).
              end.
              return error substitute( 'Есть ошибки по соответствию товаров в накладной и спецификации к договору. ' +
                                      'Смотри файл "&1.err"'
                                    , replace( bf_trn-doc.doc-code, "*", "$" ) ).

              end.
            end.
        end.

        if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
        and lookup( string(bf_trn-doc.reason-code), v-reasons-for-return) = 0
        and not v-expense-return
        then do:
          { gbl/chk-actg.i
            v-curr-db-num
            v-curr-userid
            {&action-head-code-main}
            'actn_expense_chkslpr':U
            {&cntxt-object}
            bf_trn-doc.host-code
            bf_trn-doc.obj-type
            bf_trn-doc.obj-code
            0
            0
            0
            false
            varlog
          }
          if varlog <> yes
          then do:
            for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
              { str/chkslpr.i
                bf_doc-line.doc-code
                bf_doc-line.artic
                bf_doc-line.prod-type
                bf_doc-line.prod-code
                no-error
              }
              if error-status :error
              then do:
                assign
                  varerr = yes.
                output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
                put    stream str-err unformatted return-value skip.
                output stream str-err close.
              end.
            end.
          end.
          if varerr = yes
          then do:
            if g#auto <> yes
            then do:
              run gbl/prnfilen.w
                (  input "Ошибки по товарам, у которых цена реализации ниже цены в учетных ценах."
                ,  input 0
                ,  input replace( bf_trn-doc.doc-code, "*", "$" ) + ".err"
                ,  input 7
                , output v-user-action
                , output v-printed
                ).
            end.
            return error substitute( 'Есть ошибки по товарам, у которых цена реализации ниже цены в учетных ценах. '
                                  + 'Смотри файл "&1.err"'
                                  , replace( bf_trn-doc.doc-code, "*", "$" ) ).
          end.
        end.


        /* запрос-, накл- */
        if not bf_trn-doc.flag_                and
          (bf_trn-doc.status_ = {&wayb}       or
            bf_trn-doc.status_ = {&inquiry} )
        then do:
          run waitfram-show in this-procedure ( input substitute( "Расчет шапки документа. Время: &1"
                                                                , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
          run gbl/calc-trn.p (input parparentproc, input recid( bf_trn-doc ) ) no-error.
          if error-status :error
          then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error substitute( 'Ошибка при расчете документа "&1"', bf_trn-doc.doc-code ).
          end.
          if parcheck-return
          then do:
            /* Проверка суммарного возврата */
            if bf_trn-doc.doc-type = {&return}  and
              bf_trn-doc.status_ <> {&inquiry} and
              bf_trn-doc.out-code <> ?
            then do:
              assign
                varlns-cnt = 0.
              for each bf_gds-dtl
                where bf_gds-dtl.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
                run waitfram-show in this-procedure ( input substitute( "Проверка суммарного возврата. "
                                                                      + "Проверено признаков: &1. Время &2."
                                                                      , varlns-cnt
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                assign
                  varlns-cnt = varlns-cnt + 1.
                run waitfram-show in this-procedure ( input "Проверка суммарного возврата...   Строка : " + string( varlns-cnt ) ).
                /* считаем сумму ФАКТ возвращенных по этой накл. количеств - в т.ч. текущую
                (включая незакрытые новые возвр. накл. - требуется, чтоб в них fact-qnty было = doc-qnty */
                for each ret-doc
                  where ret-doc.out-code = bf_trn-doc.out-code
                    and ret-doc.status_ <> {&inquiry} no-lock,
                  each ret-dtl where ret-dtl.doc-code  = ret-doc.doc-code and
                                    ret-dtl.artic     = bf_gds-dtl.artic and
                                    ret-dtl.prod-code = bf_gds-dtl.prod-code and
                                    ret-dtl.prod-type = bf_gds-dtl.prod-type and
                                    ret-dtl.prt-code  = bf_gds-dtl.prt-code no-lock on error undo, return error return-value :
                    accumulate ret-dtl.fact-qnty (total).
                end.
                /* находим количество по РН - она дб {&fact} */
                find exp-dtl where exp-dtl.doc-code  = bf_trn-doc.out-code  and
                                  exp-dtl.artic     = bf_gds-dtl.artic     and
                                  exp-dtl.prod-code = bf_gds-dtl.prod-code and
                                  exp-dtl.prod-type = bf_gds-dtl.prod-type and
                                  exp-dtl.prt-code  = bf_gds-dtl.prt-code no-error.
                /* ret-dtl мб недоступен при копировании в ВН из нескольких РН - проверка отключается */
                if  available exp-dtl
                and (accum total ret-dtl.fact-qnty) > exp-dtl.doc-qnty
                then do:
                  find bf_goods where bf_goods.artic     = bf_gds-dtl.artic
                                  and bf_goods.prod-code = bf_gds-dtl.prod-code
                                  and bf_goods.prod-type = bf_gds-dtl.prod-type no-lock.
                  find bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Артикул : &1 &2 Признак : &3 Количество : &4 &5 не может быть возвращено, "
                                              + "т.к. общее количество по всем возвратным накладным тогда станет: &6 &5 - "
                                              + "больше, чем было количество в расходной накладной : &7 &5 ."
                                              , bf_goods.artic
                                              , bf_goods.gds-name
                                              , bf_gds-prt.node-name
                                              , bf_gds-dtl.fact-qnty
                                              , bf_goods.unit-base
                                              , ( accum total ret-dtl.fact-qnty )
                                              , exp-dtl.doc-qnty ).
                end. /* Если признак только в одной расходной накладной */
              end. /* по всем признакам */
            end. /* только для возвратных накладных со ссылкой */
          end. /* Проверка суммарного возврата */
          /* Проверка на переоценку */
          if can-do ({&expense_write-off}, bf_trn-doc.doc-type)
          then do:
            assign
              varcount = 0.
            for each bf_doc-line
              where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
              run waitfram-show in this-procedure ( input substitute( "Проверка переоценки по новому приходу. "
                                                                    + "Проверено строк: &1. Время &2."
                                                                    , varlns-cnt
                                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
              assign
                varcount = varcount + 1.
              find first bf_goods no-lock
                where bf_goods.prod-type = bf_doc-line.prod-type
                  and bf_goods.prod-code = bf_doc-line.prod-code
                  and bf_goods.artic     = bf_doc-line.artic.

              { gbl/gdsobjat.i
              bf_doc-line.obj-type
              bf_doc-line.obj-code
              bf_doc-line.artic
              bf_doc-line.prod-type
              bf_doc-line.prod-code
              "'in-ov=request'"
              l-in-ov
              no-error}
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                return error substitute( "Ошибка получения признака товара на объекте &1.", return-value ).
              end.
              if  bf_trn-doc.status_ <> {&inquiry}
              and l-in-ov
              and parin-ov
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( "Артикул : &1 &2 По товару был новый приход. Требуется переоценка. "
                                            + "Закрытие невозможно. &3&4 "
                                            , bf_doc-line.artic
                                            , bf_goods.gds-name
                                            , bf_doc-line.obj-type
                                            , bf_doc-line.obj-code
                                            ).
              end.
            end. /* на каждый товар в документе */
          end. /* проверка на переоценку */
          if bf_trn-doc.doc-type = {&expense} and
            bf_trn-doc.status_  = {&wayb}
          then do:
            bf_trn-doc.rsrv-date = v-today + parrsrv-time.  /* новый срок резервирования */
          end.
          /* упрощенное разрешение при внутренних перемещениях */
          if bf_trn-doc.internal              and
            bf_trn-doc.doc-type = {&expense} and
            bf_trn-doc.status_  = {&wayb}
          then do:
            if bf_trn-doc.obj-type = {&stock} then
              bf_trn-doc.rsrv-date = v-today + parload-time.
            do while can-do (parholidays, string (weekday (bf_trn-doc.rsrv-date) ) ) :
              bf_trn-doc.rsrv-date = bf_trn-doc.rsrv-date + 1.
            end.
            if substr (bf_trn-doc.PS, 1, 1) = "@" then bf_trn-doc.PS = bf_trn-doc.PS + "          Время отгрузки :   9 час 00 мин".
          end.
          /* установка факт.даты и смен.даты при закрытии расх.накл сразу на факт */
          if ( bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or
               bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
              )
          and parmode = {&close-fact} and bf_trn-doc.status_ = {&wayb} then do:
              run ie-date in this-procedure.
          end.
          assign
            bf_trn-doc.status_ = varstatus
            bf_trn-doc.flag_   = varflag.
            if     bf_trn-doc.status_ eq {&fact} 
                   and bf_trn-doc.flag_
            then do:
               crUtdReturn(bf_trn-doc.doc-code).
            end.
           /* На внутренний приходный запрос создадим внутренний расходный запрос Если Контрагент АКТИВЕН
             , если нет то  и в новостях */
           if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem } and
              bf_trn-doc.status_      = {&inquiry} and
              bf_trn-doc.flag_        = true then do:
              define variable v-obj-is-active as logical   no-undo .
                { gbl/objat.i
                  bf_trn-doc.cli-type
                  bf_trn-doc.cli-code
                  "'active=request'"
                  v-obj-is-active
                  no-error
                }
                if v-obj-is-active = true then do:
                     run cus/ord-mrz.p ( parparentproc , recid(bf_trn-doc)) no-error .
                end.
           end.
           if varstatus = {&fact} then do:
              if (bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} OR
                  bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}) and
                (bf_trn-doc.d-card       <> "" and
                bf_trn-doc.d-card       <> ?)
              then do:
                find first bf_dis-card where bf_dis-card.d-card = bf_trn-doc.d-card no-lock no-error.
                if available bf_dis-card
                then do:
                  run waitfram-show in this-procedure ( input substitute( "Обновление информации о дисконтной карте. "
                                                                        + "Время: &1"
                                                                        , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                  run str/saledc.p ( INPUT parparentproc
                              ,input ? /*this-procedure:handle*/
                              ,input ? /*p-log-handle*/
                              ,input {&dct-proc_trn-doc-close} /*p-doc-type*/
                              ,input ? /*p-emitent-host-code*/
                              ,input "" /*p-type*/
                              ,input 0 /*p-profile-id*/
                              ,input 0 /*p-codex-id*/
                              ,input 0 /*p-ruleset-id*/
                              ,INPUT pardb-num
                              ,INPUT bf_trn-doc.doc-code
                              ,input bf_trn-doc.doc-date
                              ,input bf_trn-doc.fact-date
                              ,input ? /*cre-pay*/
                              ,input 1 /*p-sign*/
                              ,input (if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                                      then -1
                                      else  1) /*p-direction*/
                              ,input yes  /*p-save*/
                              ) no-error .
                  if error-status :error
                  then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error substitute("Ошибка при проведении платежа по дисконтной карте.&1&2&1&3"
                                                  , {&new-line}
                                                  , error-status:get-message(1)
                                                  , return-value ).
                  end.
                end.
                else do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Не найдена дисконтная карта &1 по документу.", bf_trn-doc.d-card ).
                end.
              end. 
           end.
        end. /* запрос-, накл- */
        else do: /* запрос+, накл+, разрешен+ */
          case bf_trn-doc.status_ :
            when {&inquiry}
            then do:
              { str/resvinqv.i bf_trn-doc.doc-code  is-no }
              if is-no = true
              then do:
                run waitfram-show in this-procedure ( input substitute( "Резервирование по запросу. Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.

                v-is-ord-doc = false .

                run cloce-ord in parparenthandle (output v-is-ord-doc) no-error .
                if error-status :error then v-is-ord-doc = false .

                v-is-negostmess = true .
                run cb_cloce-quest-neg in parparenthandle (output v-is-negostmess) no-error .
                if error-status :error then v-is-negostmess = true .

                if v-is-ord-doc then
                   run str/rv-out.p ( input parparentproc, input this-procedure , input bf_trn-doc.doc-code , yes, v-is-negostmess ) no-error.
                else
                   run str/rv-out.p ( input parparentproc, input this-procedure , input bf_trn-doc.doc-code , no , v-is-negostmess ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error  substitute("Ошибка из процедуры резервирования по запросу rv-out.p &1 &2" , return-value ,  error-status :get-message(1) ) .
                end.
                run waitfram-show in this-procedure ( input substitute( "Пересчет шапки документа. Время: &1"
                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run gbl/calc-trn.p ( input parparentproc, input recid( bf_trn-doc ) ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при расчете документа &1 &2 &3.", bf_trn-doc.doc-code , return-value , error-status :get-message(1) ).
                end.
              end.
              else do: /* flora */
                run waitfram-show in this-procedure ( input substitute( "Создание накладной по запросу. Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run str/fl-out.p ( input parparentproc, input bf_trn-doc.doc-code ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error "Ошибка из процедуры создания запроса по нетоварным позициям fl-out.p." + return-value + error-status :get-message(1)  .
                end.
                run waitfram-hide in this-procedure no-error.
              end.
            end. /*запрос+*/
            when {&wayb} or
            when {&permitted}
            then do:
              if bf_trn-doc.doc-type <> {&income} and bf_trn-doc.status_ = {&wayb}
              then do:
                /* проверка величины скидки */
                run waitfram-show in this-procedure ( input substitute( "Пересчет шапки документа. Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run gbl/calc-trn.p ( input parparentproc, input recid( bf_trn-doc ) ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при расчете документа &1 &2 &3.", bf_trn-doc.doc-code , return-value , error-status :get-message(1) ).
                end.
                if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object} then do :
                    run ie-date in this-procedure.    
                end.
                assign bf_trn-doc.status_ = varstatus.
                if bf_trn-doc.doc-type = {&expense}
                then do:
                  if bf_trn-doc.obj-type = {&stock}
                  then do:
                    assign
                        bf_trn-doc.rsrv-date = v-today + parload-time
                    .
                  end.
                  do while can-do( parholidays, string( weekday( bf_trn-doc.rsrv-date ) ) ) :
                    assign
                      bf_trn-doc.rsrv-date = bf_trn-doc.rsrv-date + 1.
                  end.
                  /* Делаем возможность подставлять произвольное примечание из примечания объекта */
                  find bf_clients where bf_clients.obj-type = bf_trn-doc.obj-type
                                  and bf_clients.obj-code = bf_trn-doc.obj-code no-lock.
                  if substr (bf_trn-doc.PS, 1, 1) = "@"
                  then do:
                    if substr (bf_clients.PS, 1, 1) = "@"
                    then do:
                      bf_trn-doc.PS = "  Курс : " + string (bf_trn-doc.base-rate) + "    " + substr (bf_clients.PS, 2).
                    end.
                    else do:
                      assign
                        bf_trn-doc.PS = bf_trn-doc.PS + "          Время отгрузки :   9 час 00 мин".
                    end.
                  end.
                end.
              end.
              else do:
              if bf_trn-doc.status_ = {&permitted} or
                  (bf_trn-doc.doc-type = {&income}  and
                  bf_trn-doc.status_  = {&wayb}    and
                  bf_trn-doc.doc-type <> {&inventory})
              then do:
                assign
                  varcount = 0.
                for each  bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code
                  on error undo, return error return-value :
                  find first bf_goods where bf_goods.artic     = bf_doc-line.artic
                                        and bf_goods.prod-code = bf_doc-line.prod-code
                                        and bf_goods.prod-type = bf_doc-line.prod-type no-lock.
                  run waitfram-show in this-procedure ( input substitute( "Проверка количеств в строках документа. "
                                                                        + "Проверено строк: &1. Время &2."
                                                                        , varcount
                                                                        , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                  assign
                    varcount = varcount + 1.
                  if bf_doc-line.doc-qnty <> bf_doc-line.fact-qnty
                  then do:
                    fact-ok = no.
                    { str/is-petrl.i
                      bf_goods.artic
                      bf_goods.prod-type
                      bf_goods.prod-code
                      varis-petrol
                      varis-pieces
                      no-error
                    }
                    if error-status :error
                    then do:
                      undo, return error return-value.
                    end.
                    if varis-petrol     and
                      not varis-pieces
                    then do:
                      if round(bf_doc-line.doc-qnty, 1) < round(bf_doc-line.fact-qnty, 1)
                      then do:
                        undo, return error substitute("Артикул : &1 &2 Количество по строке накладной: &3 &4 Фактическое количество по строке: &5 &6. Фактическое количество не может быть быть больше !" ,
                                                bf_doc-line.artic,
                                                bf_goods.gds-name,
                                                bf_doc-line.doc-qnty,
                                                bf_goods.unit-base,
                                                bf_doc-line.fact-qnty,
                                                bf_goods.unit-base).
                      end.
                    end.
                    else do:
                      if bf_doc-line.doc-qnty < bf_doc-line.fact-qnty
                      then do:
                        run waitfram-hide in this-procedure no-error.
                        undo, return error substitute( "Артикул : &1 &2 Количество по строке накладной: &3 &4 "
                                                    + "Фактическое количество по строке: &5 &4. "
                                                    + "Фактическое количество не может быть больше !"
                                                    , bf_doc-line.artic
                                                    , bf_goods.gds-name
                                                    , bf_doc-line.doc-qnty
                                                    , bf_goods.unit-base
                                                    , bf_doc-line.fact-qnty ).
                      end.
                    end.
                  end.
                end. /* for each bf_doc-line */

                run str/raspdelv.p (input parparentproc, input bf_trn-doc.doc-code) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при размазывании наценки &1.", bf_trn-doc.doc-code ).
                end.
                run waitfram-show in this-procedure ( input substitute( "Пересчет шапки документа. Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run gbl/calc-trn.p ( input parparentproc, input recid( bf_trn-doc ) ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при расчете документа &1.", bf_trn-doc.doc-code ).
                end.
                run str/fltransp.p (input parparentproc, input bf_trn-doc.doc-code  ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при включении доставки (транспортные расходы) в цену &1."
                                              , bf_trn-doc.doc-code ).
                end.
                if varstatus           = {&fact}
                and bf_trn-doc.internal
                and bf_trn-doc.doc-type = {&income}
                and bf_trn-doc.obj-type = {&shop}
                and can-find (first ub.scales-grp no-lock)
                then do:
                  { str/add-scal.i parparentproc bf_trn-doc.obj-type bf_trn-doc.obj-code bf_trn-doc.doc-code bf_trn-doc.doc-type this-procedure no-error}
                  if error-status :error
                  then do:
                    undo, return error return-value.
                  end.
                end.
                run waitfram-show in this-procedure ( input substitute( "Проверка и установка фактической даты в документе. "
                                                                      + "Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                /*Документы в которых можно проставить заднее число*/
                if (bf_trn-doc.fact-date <> ? or bf_trn-doc.shift-date <> ?)
                then do:
                  if not
                    (bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}          or
                      bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}       or
                      bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}      or
                      bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or
                      bf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}          or
                      bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object}           )
                  then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error substitute( "Для расширенного типа документа &1 недопустима установка фактической даты."
                                                , bf_trn-doc.ext-doc-type ).
                  end.
                end.
                run ie-date in this-procedure.
                if (bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} OR
                    bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}) and
                  (bf_trn-doc.d-card       <> "" and
                  bf_trn-doc.d-card       <> ?)
                then do:
                  find first bf_dis-card where bf_dis-card.d-card = bf_trn-doc.d-card no-lock no-error.
                  if available bf_dis-card
                  then do:
                    run waitfram-show in this-procedure ( input substitute( "Обновление информации о дисконтной карте. "
                                                                          + "Время: &1"
                                                                          , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                    run str/saledc.p ( INPUT parparentproc
                                ,input ? /*this-procedure:handle*/
                                ,input ? /*p-log-handle*/
                                ,input {&dct-proc_trn-doc-close} /*p-doc-type*/
                                ,input ? /*p-emitent-host-code*/
                                ,input "" /*p-type*/
                                ,input 0 /*p-profile-id*/
                                ,input 0 /*p-codex-id*/
                                ,input 0 /*p-ruleset-id*/
                                ,INPUT pardb-num
                                ,INPUT bf_trn-doc.doc-code
                                ,input bf_trn-doc.doc-date
                                ,input bf_trn-doc.fact-date
                                ,input ? /*cre-pay*/
                                ,input 1 /*p-sign*/
                                ,input (if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                                        then -1
                                        else  1) /*p-direction*/
                                ,input yes  /*p-save*/
                                ) no-error .
                    if error-status :error
                    then do:
                      run waitfram-hide in this-procedure no-error.
                      undo, return error substitute("Ошибка при проведении платежа по дисконтной карте.&1&2&1&3"
                                                    , {&new-line}
                                                    , error-status:get-message(1)
                                                    , return-value ).
                    end.
                  end.
                  else do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error substitute( "Не найдена дисконтная карта &1 по документу.", bf_trn-doc.d-card ).
                  end.
                end.

                if varstatus = {&fact} then do:
                  /* закрытие документов сверки <<перед документом>> */
                  run waitfram-show in this-procedure
                    ( input substitute( "Закрытие документа сверки '&1'. Время: &2.", {&rvs-before-doc}, string( time - vartime, "hh:mm:ss":U ) )
                    ) no-error.
                  run close-rvs in this-procedure
                    ( input bf_trn-doc.doc-code
                     ,input {&rvs-before-doc}
                     ,input bf_trn-doc.fact-date
                     ,input bf_trn-doc.fact-time
                     ,input bf_trn-doc.shift-date
                     ,input bf_trn-doc.shift-num
                     ,input bf_trn-doc.shift-name
                    ) no-error .
                  if error-status :error then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error return-value.
                  end.
                  run waitfram-hide in this-procedure no-error.
                end.
/*2----------------------внутренний приход */
                run str/in-pr.p ( parparentproc, recid (bf_trn-doc) , "cost-price") no-error .
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при создании автоматической переоценки. Документ &1 Тип переоценки 'cost-price2' &2 &3.",
                                                bf_trn-doc.doc-code,
                                                return-value,
                                                bf_trn-doc.ext-doc-type).
                end.
                if ( par-gen-mrgn-ie = {&typeprice_before-margin} and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} )  or
                   ( par-gen-mrgn-iv = {&typeprice_before-margin} and bf_trn-doc.ext-doc-type =  {&TDEDT_Pri_Perem} ) then do:
                  run str/in-pr.p (parparentproc, recid (bf_trn-doc) , "before-margin" ) no-error .
                  if error-status :error
                  then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error substitute( "Ошибка при создании автоматической переоценки. Документ &1 Тип переоценки:: &2 &3 &4 .",
                                                  bf_trn-doc.doc-code,
                                                  {&typeprice_before-margin},
                                                  return-value,
                                                  bf_trn-doc.ext-doc-type).
                  end.
                end.
/*2----------------------*/
                if varstatus               = {&fact}            and
                  bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
                then do:
                  run waitfram-show in this-procedure (substitute( "Формирование документа смены типа приобретения. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                  run str/parts-pc.p (
                      input parparentproc
                    , input bf_trn-doc.doc-code
                    , input {&bef-responsible-storage-code}
                    , input {&bef-repayment-code}
                    , input {&fact}
                    , input bf_trn-doc.fact-date
                    , input bf_trn-doc.fact-time
                    , input bf_trn-doc.shift-date
                    , input bf_trn-doc.shift-num
                    , input bf_trn-doc.shift-name
                    ) no-error .
                  if error-status :error
                  then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error return-value.
                  end.
                end.
                assign
                  bf_trn-doc.status_ = varstatus
                  bf_trn-doc.flag_   = fact-ok
                .
                if     bf_trn-doc.status_ eq {&fact} 
                   and bf_trn-doc.flag_
                then do:
                   crUtdReturn(bf_trn-doc.doc-code).
                end.
                run cus/rcvsttr.p  ( parparentproc , recid(bf_trn-doc) ) no-error .
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при обработке заказа: &1.", return-value ).
                end.
              end.
              end.
            end. /* накл+, разрешен+*/
            otherwise do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибочный статус &1 для закрытия.", bf_trn-doc.status_).
            end.
          end case. /* bf_trn-doc.status_ */
        end. /* запрос+, накл+, разрешен+ */
        if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
        or bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}
        or bf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
        then do :
          run fill-mol .
        end .
      end.  /* рас возврат спи, при внутр ------------------------------------------------- */
      when {&TDEDT_Inv}              or
      when {&TDEDT_Corr_Acc_Price}   or
      when {&TDEDT_Chg_Purch_Code}   or
      when {&TDEDT_Corr_Minus_Parts} or
      when {&TDEDT_Peresort}
      then do:
        /* ---------------стандартная инвентаризация--------------------------- */
        if bf_trn-doc.ext-doc-type = {&TDEDT_Inv}
        then do:
          if bf_trn-doc.status_ = {&wayb}
          then do:
              if bf_trn-doc.flag_ = no
              then do:
                assign
                  bf_trn-doc.flag_   = varflag
                  bf_trn-doc.status_ = varstatus.
              end.
              else do:
                run waitfram-show in this-procedure (substitute( "Заполнение документа инвентаризации. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                { str/filinvon.i
                  bf_trn-doc.doc-code
                  bf_trn-doc.status_
                  bf_trn-doc.flag_
                  yes
                  this-procedure
                  parchg-inv
                  gds-list
                  no-error
                }
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
                assign
                  bf_trn-doc.flag_   = varflag
                  bf_trn-doc.status_ = varstatus
                .
              end.
          end.
          else do:
            if bf_trn-doc.status_ = {&permitted}
            then do:
                run waitfram-show in this-procedure (substitute( "Заполнение и закрытие документа инвентаризации на факт. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run inv-fact ( input  recid(bf_trn-doc),
                              input  bf_trn-doc.status_,
                              input  bf_trn-doc.flag_,
                              output varflag) no-error .
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
                assign
                bf_trn-doc.flag_   = varflag
                bf_trn-doc.status_ = varstatus.
            end.
            else do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибочный статус &1 для закрытия.", bf_trn-doc.status_).
            end.
          end.
          run fill-mol .
        end.
        else do:
          /*Документ коррекции приходных цен*/
          if bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}   or
            bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} or
            bf_trn-doc.ext-doc-type = {&TDEDT_Peresort}
          then do:
            if bf_trn-doc.status_ = {&wayb} and
              bf_trn-doc.flag_   = no
            then do:
              run waitfram-show in this-procedure (substitute( "Заполнение документа инвентаризации. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
              { str/filinvon.i
                bf_trn-doc.doc-code
                bf_trn-doc.status_
                bf_trn-doc.flag_
                yes
                this-procedure
                parchg-inv
                gds-list
                no-error
              }
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error return-value.
              end.
              run waitfram-show in this-procedure (substitute( "Пересчет шапки документа инвентаризации. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
              { str/calc-inv.i
                recid(bf_trn-doc)
                this-procedure
                no-error }
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error return-value.
              end.
              if bf_trn-doc.fact-date  <> ? or
                  bf_trn-doc.shift-date <> ? then do:
                run gbl/chk-date.p
                  ( input bf_trn-doc.obj-type
                  , input bf_trn-doc.obj-code
                  , input bf_trn-doc.fact-date
                  , input bf_trn-doc.fact-time
                  , input bf_trn-doc.shift-date
                  , input bf_trn-doc.shift-num
                  , yes).
                run corr-date in this-procedure
                    ( input bf_trn-doc.obj-type
                    , input bf_trn-doc.obj-code
                    , input bf_trn-doc.fact-date
                    , input bf_trn-doc.shift-date
                    , input bf_trn-doc.shift-num
                    , input bf_trn-doc.shift-name
                  ).
                if bf_trn-doc.fact-date < v-today then do:
                  assign
                    bf_trn-doc.is-back-date = yes.
                end.
                else do:
                  if bf_trn-doc.shift-date <> ? then do:
                    { gbl/curshift.i
                      bf_trn-doc.obj-type
                      bf_trn-doc.obj-code
                      varobj-shift-date
                      varobj-shift-num
                      varobj-shift-name
                    }
                    if not (bf_trn-doc.shift-date = varobj-shift-date and
                            bf_trn-doc.shift-num  = varobj-shift-num  )   then do:
                      assign
                        bf_trn-doc.is-back-date = yes.
                    end.
                  end.
                end.
              end.
              else do:
                run ver-inv-date-close (bf_trn-doc.doc-code , v-today ) no-error .
                if error-status :error then do:
                  undo, return error  substitute(" Ошибка при установке даты закрытия в документе Инвентаризации &1" , return-value   ) .
                end.
                run gbl/factdate.p (input        bf_trn-doc.obj-type,
                                input        bf_trn-doc.obj-code,
                                input-output bf_trn-doc.fact-date,
                                input-output bf_trn-doc.fact-time,
                                input-output bf_trn-doc.shift-date,
                                input-output bf_trn-doc.shift-num,
                                input-output bf_trn-doc.shift-name,
                                input        yes) no-error.
                if error-status :error then do:
                  undo, return error substitute(" Ошибка при установке даты в документе(trn-doc) &1 &2" , return-value , error-status :get-message(1)  ) .
                end.
              end.
              assign
                bf_trn-doc.flag_   = varflag
                bf_trn-doc.status_ = varstatus.
            end.
            else do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибочный статус-флаг &1-&2 для закрытия.", bf_trn-doc.status_, bf_trn-doc.flag_).
            end.
          end.
          else do:
            run waitfram-hide in this-procedure no-error.
            undo, return error substitute( "Некорректный тип-расширенный_тип-статус-флаг &1-&2-&3-&4 документа &5.", bf_trn-doc.doc-type, bf_trn-doc.ext-doc-type, bf_trn-doc.status_, bf_trn-doc.flag_, bf_trn-doc.doc-code).
          end.
        end.

        if bf_trn-doc.status_ = {&fact} /* Инвентаризаци проверка на наличие предварительной даты закрытия */
        then do:
            run ver-inv-date-close (bf_trn-doc.doc-code , v-today ) no-error .
            if error-status :error then do:
              undo, return error  substitute(" Ошибка при установке даты закрытия в документе Инвентаризации: &2&1" , return-value , {&new-line}   ) .
            end.
        end.
      end.
      when {&TDEDT_Ras_Prvo}           or
      when {&TDEDT_Pri_Prvo}           or
      when {&TDEDT_Ras_Vnesh_Kass}     or
      when {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
      /**/
      end.
      otherwise do:
        run waitfram-hide in this-procedure no-error.
        undo, return error substitute( "Неизвестный расширенный тип документа &1.",bf_trn-doc.ext-doc-type).
      end.
      end case.

        { str/st-fo.i bf_trn-doc.doc-code }
      if bf_trn-doc.status_ = {&fact}
      then do:
        
        define buffer buf_parts for ub.parts  .
        
        /* Формируем информацию по количествам в разрезе GTIN для товаров с объемно-артикульным (ОСУ) типом учёта */
        if bf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} 
        or bf_trn-doc.ext-doc-type = {&TDEDT_Inv}
        then do:
          define buffer buf_doc-line for ub.doc-line  .
          define buffer buf_doc-line-attr for ub.doc-line-attr  .
          define buffer buf_goods for ub.goods .
          
          define variable v-gtin-qnty as character no-undo .
          define variable v-gtin as character no-undo .
          
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code).
          
          LK_RECEIPT_ :
          for each buf_doc-line no-lock where buf_doc-line.doc-code = bf_trn-doc.doc-code,
          first buf_goods no-lock  where buf_goods.artic = buf_doc-line.artic
                                     and buf_goods.prod-code = buf_doc-line.prod-code
                                     and buf_goods.prod-type = buf_doc-line.prod-type
          :
            if bf_trn-doc.ext-doc-type = {&TDEDT_Inv}
            and buf_doc-line.fact-qnty >= 0
            then next LK_RECEIPT_ .
            
            v-gtin-qnty = "" .
            RUN gds-attr-value (
                                INPUT buf_goods.gds-code,
                                INPUT {&attr-mark-type},
                                OUTPUT varvalue,
                                OUTPUT vartype
                                ).
            if varvalue = "antiseptic" then next LK_RECEIPT_ .
            if varvalue > ""
            and EDOParSec:GetIsArticForType(varvalue)
            then do:
              for each buf_parts no-lock where buf_parts.out-code = buf_doc-line.doc-code
                                           and buf_parts.obj-type = buf_doc-line.obj-type
                                           and buf_parts.obj-code = buf_doc-line.obj-code
                                           and buf_parts.artic = buf_doc-line.artic
                                           and buf_parts.prod-type = buf_doc-line.prod-type
                                           and buf_parts.prod-code = buf_doc-line.prod-code
              :
                if num-entries(buf_parts.part-code, "_") = 2
                then do :
                  v-gtin = entry(1, buf_parts.part-code, "_") .
                  if length(v-gtin) = 8
                  or length(v-gtin) = 12
                  or length(v-gtin) = 13
                  or length(v-gtin) = 14
                  then do :
                    v-gtin-qnty = v-gtin-qnty + v-gtin + "=" + string(integer(abs(buf_parts.qnty))) + ";" .
                  end .
                end .
              end .
            end .
            v-gtin-qnty = trim(v-gtin-qnty, ";") .
          
            if v-gtin-qnty > ""
            then do :
              find first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                                                            and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                                            and buf_doc-line-attr.attr-code = "GTIN-qnty"
                                                            no-error .
              if not available buf_doc-line-attr
              then do :
                create buf_doc-line-attr .
                assign
                  buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                  buf_doc-line-attr.gds-code = buf_goods.gds-code
                  buf_doc-line-attr.attr-code = "GTIN-qnty"
                .
              end .
              buf_doc-line-attr.attr-value = v-gtin-qnty .
            end .
          end .
        end .

        /* Отпускаем запись ub.trn-doc. Больше редактировать нельзя. */
        release bf_trn-doc.

        find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
        

        for each buf_parts no-lock where
                buf_parts.out-code = bf_trn-doc.doc-code and
                buf_parts.obj-type = bf_trn-doc.obj-type and
                buf_parts.obj-code = bf_trn-doc.obj-code :
          if buf_parts.status_ <> true then do:
            message  'Нарушена целостность документа ! Проверьте свободную , расходную зону и партии документа'  view-as alert-box error .
            undo, return error "Документ закрыть нельзя. Требуется проверка" .
          end.
        end.

        run waitfram-show in this-procedure (substitute( "Локирование товаров при закрытии документа. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
        run trg/lock-gds.p
          (input bf_trn-doc.doc-code /* v-trn-doc-doc-code     */
          ,input no               /* p-check-inv            */
          ,input no               /* p-check-inv-rasr-minus */
          ,input 0                /* p-document-fact-order  */
          ,input 0                /* p-document-fact-order-price  */
          ,input false            /* p-fact-close           */
          ,input false            /* p-is-news              */
          ) no-error .
        if error-status :error
        then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error .
        end.
        /*проверяем возможность добавления по каждой линии после установки fact-order в документ*/
        /*пересчитываем сверки при закрытии документа задним числом.
        собственные сверки для приходного документа пересчитать не можем поэтому проставляем знак вопроса*/
        if bf_trn-doc.is-back-date = yes
        then do:
          if search ("add-doc.err") <> ?
          then do:
            os-delete "add-doc.err".
          end.
          assign varcount  = 0 .
          for each bf_doc-line
            where bf_doc-line.doc-code = bf_trn-doc.doc-code
          on error undo, return error
          :
            run waitfram-show in this-procedure (substitute( "Проверка возможности добавления линии документа. Проверено признаков: &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss") ) ) no-error.
            assign
              varcount = varcount + 1.
            { str/chkaddln.i
                v-curr-db-num
                v-curr-userid
                bf_trn-doc.obj-type
                bf_trn-doc.obj-code
                bf_doc-line.artic
                bf_doc-line.prod-type
                bf_doc-line.prod-code
                bf_doc-line.doc-code
                bf_trn-doc.fact-order
                bf_trn-doc.doc-type
                bf_trn-doc.ext-doc-type
                bf_trn-doc.shift-date
                bf_trn-doc.shift-num
                bf_doc-line.fact-qnty
                "'add-doc.err'"
                no-error
            }
            if error-status :error
            then do:
              if search ("add-doc.err") <> ?
              then do:
                run gbl/prnfilen.w
                  (input  "Ошибка при проверке возможности добавления линии в документ прошедшей датой"
                  ,input  0
                  ,input  "add-doc.err"
                  ,input  7
                  ,output v-user-action
                  ,output v-printed
                  ).
              end.
              run waitfram-hide in this-procedure no-error.
              undo, return error "Ошибка при проверке возможности добавления линии в документ прошедшей датой.".
            end.
          end.
        end.

        /*закрытие документа сверки <<после документа>>*/
        run waitfram-show in this-procedure
          ( input substitute( "Закрытие документа сверки '&1'. Время: &2.", {&rvs-after-doc}, string( time - vartime, "hh:mm:ss":U ) )
          ) no-error.
        run close-rvs in this-procedure
          ( input bf_trn-doc.doc-code
           ,input {&rvs-after-doc}
           ,input bf_trn-doc.fact-date
           ,input bf_trn-doc.fact-time
           ,input bf_trn-doc.shift-date
           ,input bf_trn-doc.shift-num
           ,input bf_trn-doc.shift-name
          ) no-error .
        if error-status :error then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error return-value.
        end.
        
/*        if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then 
        do:
          define variable g-log as logical no-undo .              
          /*ЗИ 7700183417: Отчет «Прием с превышением допустимого объема резервуара»*/
          if can-find (first ub.doc-pl-attr where ub.doc-pl-attr.obj-code  = bf_trn-doc.obj-code
            and ub.doc-pl-attr.obj-type  = bf_trn-doc.obj-type
            and ub.doc-pl-attr.out-code  = bf_trn-doc.doc-code
            and ub.doc-pl-attr.attr-code = "free-vol-exceed" 
            and ub.doc-pl-attr.attr-value = string(yes)) then 
          do:
                
      /*Проверка на права техподдержки*/
            { gbl/chk-actg.i
    v-curr-db-num
    v-curr-userid
    {&action-head-code-main}
    'actn_global-trn_update':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    false
    g-log
  }                  
            if g-log then 
            do:
              message "Выполнена приемка с превышением свободного объема." skip
                "Вы уверены, что хотите закрыть данную накладную до факт?"
                view-as alert-box question buttons yes-no update lChoice as logical .
              if not lChoice then undo, return error .
            end.
            else 
            do:
              message "Выполнена приемка с превышением свободного объема." skip
                "Закрыть накладную невозможно"
                view-as alert-box.
                undo, return error .
            end.
  
          end.
        end.          */ 
        if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or
          bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
        then do:
    /*3----------------------*/
          /* генерация открытой переоценки - вне транзакции */
          if ( par-gen-mrgn-ie = {&typeprice_after-margin} and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} ) or
             ( par-gen-mrgn-iv = {&typeprice_after-margin} and bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} )
          then do:
            run str/in-pr.p ( parparentproc, recid (bf_trn-doc) , "after-margin" ) no-error .
            if error-status :error
          /* генерация открытой переоценки - вне транзакции */
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибка при создании автоматической переоценки. Документ &1. Тип переоценки 'after-margin' &2 &3 .",
                                            bf_trn-doc.doc-code,
                                            return-value,
                                            bf_trn-doc.ext-doc-type) .
            end.
          end. /*after-margin*/
          
        end.
        /*делаем корректировку отрицательных партий
          приход производство и возврат через кассу обрабатываются вне trn-stat.p*/

        if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}     or
          bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or
          bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}     or
          bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem}
        then do:
          if varminus-parts = yes
          then do:
            run waitfram-show in this-procedure (substitute( "Формирование документа автоматической компенсации отрицательных партий. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
            run str/deadprts.p ( bf_trn-doc.doc-code, parparentproc) no-error.
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error return-value.
            end.
            run waitfram-show in this-procedure (substitute( "Формирование документа смены типа приобретения. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
            run str/parts-pc.p (
                input parparentproc
              , input bf_trn-doc.doc-code
              , input {&bef-responsible-storage-code}
              , input {&bef-repayment-code}
              , input {&fact}
              , input bf_trn-doc.fact-date
              , input bf_trn-doc.fact-time
              , input bf_trn-doc.shift-date
              , input bf_trn-doc.shift-num
              , input bf_trn-doc.shift-name
              ) no-error .
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error return-value.
            end.
          end.
        end.
        run waitfram-show in this-procedure (substitute( "Формирование оборотов покупателей. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
        run ref/calctur3.p ( input bf_trn-doc.doc-code) no-error .
        run str/vtrecalc.p ( input parparentproc , input recid (bf_trn-doc)) no-error .
        if error-status :error then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error return-value.
        end.
/*
        { str/corrsprc.i
          "'+'"
          bf_trn-doc.doc-code
          v-mess
        }
        if v-mess <> "" then message v-mess  view-as alert-box information TITLE "Сверка со с спецификацией договора".
*/

        if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}  then do:
        run cus/edocsord.p (  input parParentProc
                            , input recid(bf_trn-doc)
                            , input {&table_trn-doc}
                            , input yes
                            ) no-error  .
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибка при обработке заказа: &1.", return-value ).
            end.
        end.
        
        if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
        or bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
        then do:
          /* генерация документа производства для товаров с атрибутом "только производство" */
          define buffer buf_recipe-gds for ub.recipe-gds .
          define buffer buf_recipe for ub.recipe .
          define buffer buf_marking-lines for ub.marking-lines .
          define buffer buf_marking for ub.marking .
          
          define variable v-production-only as logical no-undo .
          define variable v-num-recipes as integer no-undo .
          define variable v-0-recipes-gds-list as character no-undo .
          define variable v-many-recipes-gds-list as character no-undo .
          define variable v-recipe-code like ub.recipe.recipe-code .
          define variable v-ingr-gds-code as integer no-undo .
          define variable v-koef-qnty as decimal no-undo .
          define variable v-isweighed as logical no-undo .
          
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code).
          
          doc-line_ :
          for each bf_doc-line no-lock where bf_doc-line.doc-code = bf_trn-doc.doc-code,
          first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic
                                   and bf_goods.prod-type = bf_doc-line.prod-type
                                   and bf_goods.prod-code = bf_doc-line.prod-code
          :
            if bf_doc-line.fact-qnty <= 0 then next doc-line_ .
            { gbl/gdscdat.i
              bf_goods.gds-code
              "'production-only=request':u"
              v-production-only
              no-error
            }
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении атрибута товара" skip
                "Код товара" bf_goods.gds-code skip
                'production-only=request':u skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            if v-production-only
            then do :
              assign v-num-recipes = 0 .
              for each buf_recipe-gds no-lock where buf_recipe-gds.artic     = bf_goods.artic
                                                and buf_recipe-gds.prod-type = bf_goods.prod-type
                                                and buf_recipe-gds.prod-code = bf_goods.prod-code,
              each buf_recipe no-lock where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
                                        and buf_recipe.recipe-type = {&alternative}
                                        and buf_recipe.stts       <> 2
              :
                assign
                  v-num-recipes   = v-num-recipes + 1
                  v-recipe-code   = buf_recipe.recipe-code
                  v-ingr-gds-code = buf_recipe.gds-code
                  v-koef-qnty     = buf_recipe-gds.qnty
                .
              end .
              if v-num-recipes = 0
              then do :
                assign v-0-recipes-gds-list = v-0-recipes-gds-list + string(bf_goods.gds-code) + " " + bf_goods.gds-name + ", " .
              end .
              else
              if v-num-recipes <> 1
              then do :
                assign v-many-recipes-gds-list = v-many-recipes-gds-list + string(bf_goods.gds-code) + " " + bf_goods.gds-name + ", " .
              end .
              else do : /* v-num-recipes = 1 */
                create tt-fbr-line .
                assign
                  tt-fbr-line.gds-code = bf_goods.gds-code
                  tt-fbr-line.gds-name = bf_goods.gds-name
                  tt-fbr-line.qnty     = bf_doc-line.fact-qnty * v-koef-qnty
                  tt-fbr-line.recipe-code = v-recipe-code
                  tt-fbr-line.recipe-type = {&alternative}
                  tt-fbr-line.ingr-gds-code = v-ingr-gds-code
                .  
              
                v-isweighed = WghProdVariable(bf_trn-doc.obj-type, bf_trn-doc.obj-code, bf_goods.gds-code) .
                RUN gds-attr-value (
                                    INPUT bf_goods.gds-code,
                                    INPUT {&attr-mark-type},
                                    OUTPUT varvalue,
                                    OUTPUT vartype
                                    ).
                if (varvalue > ""
                and EDOParSec:GetIsEdoForType(varvalue))
                or v-isweighed
                then do:
                  mark-lines_ :
                  for each buf_marking-lines no-lock where buf_marking-lines.out-code   = bf_doc-line.doc-code
                                                       and buf_marking-lines.gds-code   = bf_goods.gds-code
                  :
                    for first buf_marking no-lock where buf_marking.mark begins buf_marking-lines.mark :
                      if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
                      and not(index(bf_trn-doc.doc-code, "=") > 0 and buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB)
                      then
                        next mark-lines_
                      .
                    end .
                    create tt-marking-lines .
                    assign
                      tt-marking-lines.mark = buf_marking-lines.mark
                      tt-marking-lines.gds-code = bf_goods.gds-code
                      tt-marking-lines.gds-name = bf_goods.gds-name
                      tt-marking-lines.obj-type = bf_trn-doc.obj-type
                      tt-marking-lines.obj-code = bf_trn-doc.obj-code
                      tt-marking-lines.doc-level = buf_marking-lines.doc-level
                    .
                    for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                      assign
                        buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                      .
                    end .
                  end .
                end . /* EDOParSec:GetIsEdoForType(varvalue) */
              end . /* v-num-recipes = 1 */
            end . /* v-production-only */
          end . /* for each doc-line */
          assign
            v-0-recipes-gds-list = trim(v-0-recipes-gds-list, ", ")
            v-many-recipes-gds-list = trim(v-many-recipes-gds-list, ", ")
          .
          if v-0-recipes-gds-list > ""
          then do :
            message "Для товаров " + v-0-recipes-gds-list + " отсутствует рецепт «Альтернатива». Обратитесь в офис для создания рецепта, после чего создайте документ производства вручную"
            view-as alert-box .
          end .
          if v-many-recipes-gds-list > ""
          then do :
            message "Для товаров " + v-many-recipes-gds-list + " найдено более одного рецепта «Альтернатива», поэтому автоматический выбор рецепта невозможен, товар не добавлен. Создайте документ производства с этим товаром вручную. Обратитесь в офис для корректировки рецептов"
            view-as alert-box .
          end .
          find first tt-fbr-line no-error .
          if available tt-fbr-line
          then do :
            run waitfram-show in this-procedure (input "Ждите... Идёт создание и закрытие документа производства").
            
            run str/cr-fbr-doc-mark.p ( input parparentproc
                                      , input this-procedure
                                      , input table tt-fbr-line by-reference
                                      , input table tt-marking-lines by-reference
                                      ) .
            
            run waitfram-hide in this-procedure .
          end .
        end .

      end. /*автоматическая переоценка после  закрытия на факт*/

    end. /*закрытие документов*/

    when {&open-doc}
    then do:
      run str/trn-open.p
      ( input parparentproc
      , input parmode
      , input pardoc-code
      , input parcheck-return
      , input pardb-num
      , input parin-ov
      , input parrsrv-time
      , input parload-time
      , input parholidays
      , input parmessage
      )  no-error .
      if error-status :error
      then do:
        undo, return error return-value  .
      end.
    end.
    when {&reserv-doc}
    then do:
      if bf_trn-doc.ext-doc-type = {&TDEDT_Inv}
      then do:
        case bf_trn-doc.status_:
          when {&wayb}
          then do:
            case bf_trn-doc.flag_:
              when yes
              then do:
                run inv-nakl-reserv in this-procedure no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
              end.
              otherwise do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( "Ошибочный статус-флаг &1-&2 для резервирования.", bf_trn-doc.status_, bf_trn-doc.flag_ ).
              end.
            end case.
          end.
          when {&permitted}
          then do:
            if varstatus = {&fact} then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Данная операция не может закрывать документ до статуса &1.", varstatus ).
            end.
            if bf_trn-doc.flag_ = false then do:
                run waitfram-show in this-procedure (substitute( "Заполнение документа инвентаризации. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                { str/filinvon.i
                  bf_trn-doc.doc-code
                  bf_trn-doc.status_
                  bf_trn-doc.flag_
                  yes
                  this-procedure
                  parchg-inv
                  gds-list
                }
                { str/calc-inv.i
                  recid(bf_trn-doc)
                  this-procedure
                  no-error }
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
                run str/clcsumga.p (input bf_trn-doc.doc-code) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
            end.
            assign
              bf_trn-doc.flag_   = varflag
              bf_trn-doc.status_ = varstatus
            .
          end.
          otherwise do:
            run waitfram-hide in this-procedure no-error.
            undo, return error substitute( "Ошибочный статус-флаг &1-&2 для резервирования.", bf_trn-doc.status_, bf_trn-doc.flag_ ).
          end.
        end case.
      end.
      else do:
        run waitfram-hide in this-procedure no-error.
        undo, return error substitute( "Неверная операция: резервирование-переход по статусам для документа &1 с расширенным типом &2 .", bf_trn-doc.doc-code, bf_trn-doc.ext-doc-type).
      end.
    end.
    otherwise do:
      run waitfram-hide in this-procedure no-error.
      undo, return error substitute( "Неизвестный режим &1 обработки документа.", parmode).
    end.
  end case.
run waitfram-hide in this-procedure.

/*генерация ФО для расходных накладных*/
for each tt-trn: delete tt-trn. end. /* for each */
        define variable v-sum like ub.fin-ob-trn.sum-rubl no-undo .
        if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} and bf_trn-doc.contract-code <> 0 and bf_trn-doc.contract-code <> ? then do:
                p-cons = 0.
                
            find first bf_contract no-lock where bf_contract.contract-code = bf_trn-doc.contract-code no-error .
              if available bf_contract then do:
                if  bf_contract.usl-opl <> '{&bef-contr-pay-nodef}' then do:
                define variable v-fo-gen as integer no-undo.
                    { gbl/getsect.i run "''" 0  {&attr-fin-global} }
                    for each thbjattr_thbj-attr exclusive-lock:
                        if thbjattr_thbj-attr.prop-code = {&attr-fin-global_fo-gen}  then v-fo-gen = thbjattr_thbj-attr.property-value-integer .
                    end.
                    if ((varstatus = {&wayb} and bf_trn-doc.flag_ = yes and (v-fo-gen = 3 or v-fo-gen = 2 )) or (varstatus = {&permitted} and (v-fo-gen = 4 or v-fo-gen = 5) ) or (varstatus = {&fact} and v-fo-gen > 1 )) or ((bf_contract.usl-opl = '{&bef-contr-buyer-ord}' or bf_contract.usl-opl = '{&bef-contr-buyer-ord-prc}') and varstatus = {&permitted}) then do:
                                  for each bf_fin-ob-trn where bf_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code exclusive-lock:
                                    v-sum = v-sum + bf_fin-ob-trn.sum-rubl .
                                  end.
                                  if (abs (v-sum) <> bf_trn-doc.tot-fact and abs (v-sum) <> (bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl)) or (bf_contract.usl-opl = '{&bef-contr-buyer-ord}' or bf_contract.usl-opl = '{&bef-contr-buyer-ord-prc}') and (varstatus = {&permitted} or (varstatus = {&fact} and v-fo-gen > 1 )) then do:
 
                        if bf_contract.usl-opl = '{&bef-contr-buyer-ord}' or bf_contract.usl-opl = '{&bef-contr-buyer-ord-prc}' then p-cons = 1. /*Предоплата*/
                        if bf_contract.usl-opl = '{&bef-contr-buyer-in}'  then p-cons = 2. /*По факту поставки*/
                        if bf_contract.usl-opl = '{&bef-contr-buyer-in-delay}'  then p-cons = 3. /*По всем*/
                        if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} then do:
                         if bf_contract.usl-opl <> '{&bef-contr-buyer-ord}' and bf_contract.usl-opl <> '{&bef-contr-buyer-ord-prc}' then do:
                             find first bf_fin-ob-trn where bf_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code and v-sum > (bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl) no-error.
                                if not available bf_fin-ob-trn then do:
                                    run str/limcontr.p ( input bf_trn-doc.host-code, input bf_trn-doc.contract-code, input 0, input bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl - v-sum, input bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl - v-sum ) no-error .
                                    if error-status :error then return error return-value .
                                end.      
                          end.
                         if (bf_contract.usl-opl = '{&bef-contr-buyer-ord}' or bf_contract.usl-opl = '{&bef-contr-buyer-ord-prc}') and varstatus = {&permitted} then do:
                                    
                                    run str/limcontr.p ( input bf_trn-doc.host-code, input bf_trn-doc.contract-code, input 0, input 0, input  bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl ) no-error .
                                    if error-status :error then return error return-value .
                         end.
                         if (bf_contract.usl-opl = '{&bef-contr-buyer-ord}' or bf_contract.usl-opl = '{&bef-contr-buyer-ord-prc}') and (varstatus = {&fact} and v-fo-gen > 1 ) then do:
                           if abs (v-sum) <> bf_trn-doc.tot-fact and abs (v-sum) <> (bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl) then do:
                             if (bf_trn-doc.fact-qnty <> bf_trn-doc.doc-qnty) or v-sum = 0 then do:
                                find first bf_fin-ob-trn where bf_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code and v-sum > (bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl) no-error.
                                if not available bf_fin-ob-trn then do:
                                      run str/limcontr.p ( input bf_trn-doc.host-code, input bf_trn-doc.contract-code, input 0, input bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl, input bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl ) no-error .
                                      if error-status :error then return error return-value .
                                end.      
                             end.   
                                   
                           end.
                         end.
                        end.
                        if abs (v-sum) <> (bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl) and abs (v-sum) <> (bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl) then do:
                        BUFFER-COPY bf_trn-doc to tt-trn.
                      run str/genbfotr.p (
                          input parParentProc ,
                          input bf_contract.host-code ,
                          input bf_trn-doc.doc-date  ,
                          input ? ,
                          input p-cons ,              /* условие оплаты */
                          input 1 ,
                          input table tt-trn ,
                          input-output res ,
                          input 2,
                          input yes
                          ) no-error .
                     end.
                     end.           
                     end. 
      end. /*               if  bf_trn-doc.status_ = {&fact} and bf_contract.usl-opl <> {&bef-contr-pay-nodef} then do:*/
    end.
  end. /*if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}) and (bf_trn-doc.contract-code <> 0 or bf_trn-doc.contract-code <> ?) then do:*/
  
  find first bf_clients no-lock where bf_clients.obj-type = {&prs} and  bf_clients.obj-code = bf_trn-doc.boss no-error.
  find last ub.c-trn-doc no-lock where ub.c-trn-doc.doc-code = bf_trn-doc.doc-code and ub.c-trn-doc.corr-user-db-num = v-curr-db-num no-error.
  
  if available bf_trn-doc
  then do:
  
    { gbl/curshift.i
      bf_trn-doc.obj-type
      bf_trn-doc.obj-code
      varobj-shift-date
      varobj-shift-num
      varobj-shift-name
      no-error
    }
  
    v-vid-action = 57 .
    v-vid-param = "Initiator=" + v-initiator + {&delim-par} +
                  "ResponsiblePerson=" + (if available (bf_clients) then bf_clients.obj-name else "") + {&delim-par} +
                  "SHOP_NUM=" + string(bf_trn-doc.obj-code) + {&delim-par} +
                  "Contractor=" + bf_trn-doc.cli-name + {&delim-par} +
                  "DocNum=" + string(bf_trn-doc.doc-code) + {&delim-par} +
                  "FactDate=" + (if string(bf_trn-doc.fact-date) = ? then '' else string(bf_trn-doc.fact-date)) + {&delim-par} +
                  "DocType=" + string(bf_trn-doc.doc-type) + {&delim-par} +
                  "SHIFT_NUM_DOC=" + (if string(bf_trn-doc.shift-num) = ? then '' else string(bf_trn-doc.shift-num)) + (if string(bf_trn-doc.shift-date) = ? then '' else string(bf_trn-doc.shift-date, "99999999")) + {&delim-par} +
                  "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + {&delim-par} +
                  "StatusOld=" + varoldstatus + (if varoldflag then "+" else "-" ) + {&delim-par} +
                  "StatusNew=" + string(bf_trn-doc.status_) + (if bf_trn-doc.flag then "+" else "-" ) + {&delim-par} +
                  "RESULT=0" + {&delim-par} + 
                  "Description=" no-error.
    
    if available (ub.c-trn-doc)
      then 
      run trg/userlog.p (
            input {&nwsdochs_action_update}
          , input {&table_c-trn-doc}
          , input ( buffer ub.c-trn-doc :handle )
          , input v-vid-action
          , input v-vid-param
      ) no-error.
      else
      run trg/userlog.p (
          input {&nwsdochs_action_update}
        , input {&table_trn-doc}
        , input ( buffer bf_trn-doc :handle )
        , input v-vid-action
        , input v-vid-param
      ) no-error.
    
  end.
  
end. /* transaction */


procedure inv-fact :
define input  parameter par-if-rec-doc  as recid no-undo.
define input  parameter par-if-status   like ub.trn-doc.status_ no-undo.
define input  parameter par-if-flag     like ub.trn-doc.flag_   no-undo.
define output parameter par-if-flag-out as logical              no-undo.

define buffer if_sysconf    for ub.sysconf.
define buffer if_trn-doc    for ub.trn-doc.
define buffer if_curr-accnt for ub.curr-accnt.
define buffer if_doc-line   for ub.doc-line.
define buffer if_goods      for ub.goods.
define variable if_cnt-lns       as   integer              no-undo.
define variable varinvclcspvalue as   character            no-undo.
define variable varinvclcsptype  as   character            no-undo.
define variable parwtvalue       as   character            no-undo.
define variable parasvalue       as   character            no-undo.
define variable parwttype        as   character            no-undo.
define variable parastype        as   character            no-undo.
define variable var-if-cur-qnty  like ub.doc-line.doc-qnty no-undo.
define variable var-if-chg-inv   as   logical              no-undo.
do on error undo, return error return-value :
  assign par-if-flag-out = yes.
  find first if_trn-doc where recid(if_trn-doc) = par-if-rec-doc.
  { gbl/getsect.i run if_trn-doc.obj-type if_trn-doc.obj-code {&attr-inv-obj} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
  end.

  find first if_sysconf where if_sysconf.host-code = if_trn-doc.host-code.
  find last if_curr-accnt where if_curr-accnt.curr-code = if_sysconf.base-code
                            and if_curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
  if not available if_curr-accnt
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error "На дату " + string(v-today) + " неизвестен курс базовой валюты.".
  end.
  assign
    if_trn-doc.base-rate  = if_curr-accnt.exch-rate
    if_trn-doc.base-scale = if_curr-accnt.exch-scale.
  /*Локируем все ub.gds-obj перед заданием кол-во по строкам(было)
    Надо бы перегнать на Inv-on!!!*/
  run waitfram-show in this-procedure (substitute( "Локирование товаров при закрытии документа. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
  run trg/lock-gds.p
    (input if_trn-doc.doc-code /* v-trn-doc-doc-code     */
    ,input no               /* p-check-inv            */
    ,input no               /* p-check-inv-rasr-minus */
    ,input 0                /* p-document-fact-order  */
    ,input 0                /* p-document-fact-order-price  */
    ,input false            /* p-fact-close           */
    ,input false            /* p-is-news              */
    ) no-error .
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error .
  end.
  if par-if-status = {&permitted} and
     par-if-flag   = no
  then do:
     define variable varchg-inv as logical no-undo.
     { str/filinvon.i
       if_trn-doc.doc-code
       if_trn-doc.status_
       if_trn-doc.flag_
       yes
       this-procedure:handle
       varchg-inv
       gds-list
       no-error
     }
     if error-status :error
     then do:
       run waitfram-hide in this-procedure no-error.
       undo, return error return-value.
     end.
  end.

  { str/tdat-val.i if_trn-doc.doc-code
               {&trdcattr-clcaswt}
               parwtvalue
               parwttype           no-error }
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error return-value.
  end.

  { str/tdat-val.i if_trn-doc.doc-code
               {&trdcattr-clcasol}
               parasvalue
               parastype           no-error }
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error return-value.
  end.
  run waitfram-show in this-procedure (substitute( "Пересчет сумм документа по закрытию на факт. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
  { str/rcallfct.i if_trn-doc.doc-code
               "parwtvalue = 'no'"
               "parasvalue = 'no'"
               "this-procedure :handle"
               tt-wast-line
               tt-allsum-line
               tt-doc-line-sum
               tt-clcparts
               temp-parts               no-error }
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Ошибка при вызове lib-rwds_rcallfct: &1.", return-value ).
  end.
  assign
    varcount = 0.
  for each if_doc-line
    where if_doc-line.doc-code = if_trn-doc.doc-code
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure (substitute( "Обрабатываем строки при закрытии. Обработано строк: &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss") ) ) no-error.
    assign
      varcount = varcount + 1.
    find first if_goods no-lock
      where if_goods.artic     = if_doc-line.artic
        and if_goods.prod-type = if_doc-line.prod-type
        and if_goods.prod-code = if_doc-line.prod-code  .
    if if_doc-line.fact-qnty <> 0
    or if_doc-line.prt-ok
    then do:
      par-if-flag-out = no.
      accumulate if_doc-line.prt-ok (count).
    end.
    assign
      if_cnt-lns = if_cnt-lns + 1.
    if if_cnt-lns modulo 10 = 0
    then do:
      run waitfram-show in this-procedure ("Обработано строк : " + string (if_cnt-lns) ).
    end.
  end.
  if substr (if_trn-doc.PS, 1, 1) = "@"
  then do:
    assign
      if_trn-doc.PS = if_trn-doc.PS + " Всего строк по инвентаризации : " + string (if_cnt-lns, ">>>>>>9") +
                       chr (10) + "Из них закрыто с коррекцией : " + string ( (accum count if_doc-line.prt-ok), ">>>>>>9")
    .
  end.
  run waitfram-show in this-procedure (substitute( "Пересчет шапки документа. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
  { str/calc-inv.i
    recid(if_trn-doc)
    this-procedure
    no-error }
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error return-value.
  end.
  run ie-date in this-procedure.
end.
end procedure.

procedure corr-date:
define input parameter parobj-type    like ub.trn-doc.obj-type   no-undo.
define input parameter parobj-code    like ub.trn-doc.obj-code   no-undo.
define input parameter parfact-date   like ub.trn-doc.fact-date  no-undo.
define input parameter parshift-date  like ub.trn-doc.shift-date no-undo.
define input parameter parshift-num   like ub.trn-doc.shift-num  no-undo.
define input parameter parshift-name  like ub.trn-doc.shift-name no-undo.

define variable l-shift-on as logical no-undo .
define buffer bf_shift-obj for ub.shift-obj.
do on error undo, return error return-value :
{ gbl/objat.i
  parobj-type
  parobj-code
  "'shift-on=request'"
  l-shift-on
}
if l-shift-on = yes
then do:
  find first bf_shift-obj where bf_shift-obj.obj-type   = parobj-type   and
                                bf_shift-obj.obj-code   = parobj-code   and
                                bf_shift-obj.shift-date = parshift-date and
                                bf_shift-obj.shift-num  = parshift-num  no-lock no-error.
  if not available bf_shift-obj
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Нет смены &1 &2 на объекте &3 &4.", parshift-date, parshift-name + string(parshift-num), parobj-type, parobj-code).
  end.
  if bf_shift-obj.status_ <> {&sht-closed}  and
     bf_shift-obj.status_ <> {&sht-current}
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Смена &1 &2 на объекте &3 &4 имеет статус &5. Оформлять документы можно только в смене со статусом &6 или &7.",
                              bf_shift-obj.shift-date,
                              bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                              bf_shift-obj.obj-type,
                              bf_shift-obj.obj-code,
                              bf_shift-obj.status_,
                              {&sht-closed},
                              {&sht-current}).
  end.
  if parfact-date < bf_shift-obj.open-date
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Фактическая дата документа должна быть больше либо равна дате открытия смены. Фактическая дата: &1. Дата открытия смены &2 &3 на объекте &4 &5: &6.",
                             parfact-date,
                             bf_shift-obj.shift-date,
                             bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                             bf_shift-obj.obj-type,
                             bf_shift-obj.obj-code,
                             bf_shift-obj.open-date).
  end.
  if bf_shift-obj.status_ = {&sht-closed}
  then do:
    if parfact-date > bf_shift-obj.close-date
    then do:
      run waitfram-hide in this-procedure no-error.
      undo, return error substitute( "Фактическая дата документа должна быть меньше либо равна дате закрытия смены. Фактическая дата: &1. Дата закрытия смены &2 &3 на объекте &4 &5: &6.",
                               parfact-date,
                               bf_shift-obj.shift-date,
                               bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                               bf_shift-obj.obj-type,
                               bf_shift-obj.obj-code,
                               bf_shift-obj.close-date).
    end.
  end.
end.
end.
end procedure.

procedure fill-tt :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_doc-line      for ub.doc-line.
define buffer bf_doc-line-attr for ub.doc-line-attr.
define buffer bf_gds-dtl       for ub.gds-dtl.
define buffer bf_parts         for ub.parts.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
for each lib-trn_ret-doc on error undo, return error return-value :
  delete lib-trn_ret-doc.
end.
create lib-trn_ret-doc.
buffer-copy bf_trn-doc to lib-trn_ret-doc.
for each lib-trn_ret-line on error undo, return error return-value :
  delete lib-trn_ret-line.
end.
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock on error undo, return error return-value :
  create lib-trn_ret-line.
  buffer-copy bf_doc-line to lib-trn_ret-line.
  assign
    lib-trn_ret-line.cst-code = bf_trn-doc.cst-code.
end.
for each lib-trn_ret-line-attr on error undo, return error return-value :
  delete lib-trn_ret-line-attr.
end.
for each bf_doc-line-attr where bf_doc-line-attr.doc-code = bf_trn-doc.doc-code no-lock
  on error undo, return error return-value :
  create lib-trn_ret-line-attr.
  buffer-copy bf_doc-line-attr to lib-trn_ret-line-attr.
end.
for each lib-trn_ret-dtl on error undo, return error return-value :
  delete lib-trn_ret-dtl.
end.
for each bf_gds-dtl where bf_gds-dtl.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
  create lib-trn_ret-dtl.
  buffer-copy bf_gds-dtl to lib-trn_ret-dtl.
end.
for each lib-trn_ret-parts on error undo, return error return-value :
  delete lib-trn_ret-parts.
end.
for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code on error undo, return error return-value :
  create lib-trn_ret-parts.
  buffer-copy bf_parts to lib-trn_ret-parts.
end.
end.
end procedure.

procedure ie-date:
  do
  on error undo, return error substitute("&1 &2" , return-value , error-status :get-message(1) )
  :
    if bf_trn-doc.fact-date  <> ?
      or bf_trn-doc.shift-date <> ?
    then do:
  
     if bf_trn-doc.fact-time = 0 or bf_trn-doc.fact-time = ? then
        bf_trn-doc.fact-time = time.
      if bf_trn-doc.fact-date = ?
      and (bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Object}
        or bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
        or bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem})
      then do :
        { gbl/curobjdt.i bf_trn-doc.obj-type bf_trn-doc.obj-code bf_trn-doc.fact-date }    
      end.
      
      if g#esys and bf_trn-doc.fact-date = ?
        then do: 
          bf_trn-doc.fact-date = now.
          return.
        end.
      
      run gbl/chk-date.p
          ( input bf_trn-doc.obj-type
          , input bf_trn-doc.obj-code
          , input bf_trn-doc.fact-date
          , input bf_trn-doc.fact-time
          , input bf_trn-doc.shift-date
          , input bf_trn-doc.shift-num
          , yes).
      run corr-date in this-procedure
          ( input bf_trn-doc.obj-type
          , input bf_trn-doc.obj-code
          , input bf_trn-doc.fact-date
          , input bf_trn-doc.shift-date
          , input bf_trn-doc.shift-num
          , input bf_trn-doc.shift-name
          ).
      if bf_trn-doc.fact-date < v-today then do:
        assign
          bf_trn-doc.is-back-date = yes
        .
      end.
      else do:
        if bf_trn-doc.shift-date <> ? then do:
          { gbl/curshift.i
            bf_trn-doc.obj-type
            bf_trn-doc.obj-code
            varobj-shift-date
            varobj-shift-num
            varobj-shift-name
          }
          if not ( bf_trn-doc.shift-date = varobj-shift-date
                   and bf_trn-doc.shift-num  = varobj-shift-num
                 )
          then do:
            assign
              bf_trn-doc.is-back-date = yes
            .
          end.
        end.
      end.
    end.
    else do:
      run gbl/factdate.p
        ( input        bf_trn-doc.obj-type
         ,input        bf_trn-doc.obj-code
         ,input-output bf_trn-doc.fact-date
         ,input-output bf_trn-doc.fact-time
         ,input-output bf_trn-doc.shift-date
         ,input-output bf_trn-doc.shift-num
         ,input-output bf_trn-doc.shift-name
         ,input        NOT(g#auto OR g#oxml OR g#esys OR g#news) 
        ).
        run str/chk-back.p
          (input bf_trn-doc.doc-code  /* p-doc-code  */
          ,input bf_trn-doc.fact-date /* p-fact-date */
          ) no-error .
          if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
          return error return-value .
          end.
    end.
  end.
end procedure.

procedure inv-nakl-reserv :
  do on error undo, return error return-value :
    run waitfram-show in this-procedure ( input substitute( "Заполнение документа инвентаризации. Время: &1"
                                                          , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
    { str/filinvon.i
      bf_trn-doc.doc-code
      bf_trn-doc.status_
      bf_trn-doc.flag_
      yes
      this-procedure
      parchg-inv
      gds-list
    }
    { str/calc-inv.i
      recid(bf_trn-doc)
      this-procedure
    }
    run str/clcsumga.p (input bf_trn-doc.doc-code).
    assign
      bf_trn-doc.flag_   = varflag
      bf_trn-doc.status_ = varstatus.
  end.
end procedure.

procedure hold-check:
define buffer bf-src_doc-line for ub.doc-line.
define buffer bf-src_goods    for ub.goods.
define buffer bf-src_units    for ub.units.
define buffer bf-src_gds-dtl  for ub.gds-dtl.
define buffer bf-src_parts    for ub.parts.
do on error undo, return error return-value :
  /* Нельзя перемещать товар по двум единицам измерения и серийный товар */
  for each bf-src_doc-line where bf-src_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
    find first bf-src_goods where bf-src_goods.artic     = bf-src_doc-line.artic     and
                                  bf-src_goods.prod-type = bf-src_doc-line.prod-type and
                                  bf-src_goods.prod-code = bf-src_doc-line.prod-code no-lock.
    find first bf-src_units where bf-src_units.unit-name = bf-src_goods.unit-base no-lock.
    if lookup({&twounit}, bf-src_units.type) <> 0
    then do:
      undo, return error substitute( "В документе межфирменного перемещения не допускается товар с двумя единицами измерения. Товар: &1 &2 &3", bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
    if lookup({&serial}, bf-src_units.type) <> 0
    then do:
      undo, return error substitute( "В документе межфирменного перемещения не допускается серийный товар. Товар: &1 &2 &3",bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
    if bf-src_doc-line.fact-qnty > bf-src_doc-line.doc-qnty
    then do:
      undo, return error substitute( "Фактическое количество по строке &1 не может быть больше документарного &2. Товар: &3 &4 &5", bf-src_doc-line.fact-qnty, bf-src_doc-line.doc-qnty, bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
  end.
  /*Если перемещается товар с признаками, то в документе межфирменного перемещения должен быть только один признак.
    При копировании в приход цена берется из первого признака, а в признаки прихода пишется средняя по партиям. Структура партий сохраняется.
    */
  for each bf-src_gds-dtl where bf-src_gds-dtl.doc-code = bf_trn-doc.doc-code on error undo, return error return-value:
    find first bf_gds-dtl where bf_gds-dtl.doc-code  = bf-src_gds-dtl.doc-code  and
                                bf_gds-dtl.artic     = bf-src_gds-dtl.artic     and
                                bf_gds-dtl.prod-type = bf-src_gds-dtl.prod-type and
                                bf_gds-dtl.prod-code = bf-src_gds-dtl.prod-code and
                                recid(bf_gds-dtl)    <> recid(bf-src_gds-dtl)   no-error.
    if available bf_gds-dtl
    then do:
      undo, return error substitute( "В документе межфирменного перемещения не допускается чтобы в одном документе товар шел по нескольким признакам. Товар: &1 &2 &3", bf_gds-dtl.artic, bf_gds-dtl.prod-type, bf_gds-dtl.prod-code).
    end.
    if bf-src_gds-dtl.fact-qnty > bf-src_gds-dtl.doc-qnty
    then do:
      undo, return error substitute( "Фактическое количество по признаку &1 не может быть больше документарного &2. Товар: &3 &4 &5", bf-src_gds-dtl.fact-qnty, bf-src_gds-dtl.doc-qnty, bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
  end.
  for each bf-src_parts where bf-src_parts.out-code = bf_trn-doc.doc-code on error undo, return error return-value:
    if bf-src_parts.fact-qnty > bf-src_parts.qnty
    then do:
      undo, return error substitute( "Фактическое количество по партии &1 не может быть больше документарного &2. Товар: &3 &4 &5", bf-src_parts.fact-qnty, bf-src_parts.qnty, bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
  end.
end.
end procedure.


procedure close-rvs :

  define input  parameter p-trn-doc-code like ub.trn-doc.doc-code   no-undo.
  define input  parameter p-rvs-type     like ub.rvs-doc.rvs-type   no-undo.
  define input  parameter p-fact-date    like ub.trn-doc.fact-date  no-undo.
  define input  parameter p-fact-time    like ub.trn-doc.fact-time  no-undo.
  define input  parameter p-shift-date   like ub.trn-doc.shift-date no-undo.
  define input  parameter p-shift-num    like ub.trn-doc.shift-num  no-undo.
  define input  parameter p-shift-name   like ub.trn-doc.shift-name no-undo.

  do
  on error  undo, return error substitute( "&1 (close-rvs). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (close-rvs). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (close-rvs). endkey", vss-workfile )
  :
    define buffer buf_rvs-doc for ub.rvs-doc .

    for each buf_rvs-doc
      where buf_rvs-doc.rvs-type = p-rvs-type
        and buf_rvs-doc.out-code = p-trn-doc-code
    :
      run str/rvs-stat.p
        ( input parparentproc
         ,input recid(buf_rvs-doc)
         ,input "unfroze":U
        ) no-error.
      if error-status :error then do:
        undo, return error substitute( "Ошибка при изменении статуса &1.", return-value ).
      end.
      assign
        buf_rvs-doc.fact-date  = p-fact-date
        buf_rvs-doc.fact-time  = p-fact-time
        buf_rvs-doc.shift-date = p-shift-date
        buf_rvs-doc.shift-num  = p-shift-num
        buf_rvs-doc.shift-name = p-shift-name
      .
      { str/rvsclose.i
        parparentproc
        recid(buf_rvs-doc)
        no
        no-error
      }
      if error-status :error then do:
        undo, return error  substitute( "Ошибка при закрытии документа сверки: &1 &2.", buf_rvs-doc.rvs-code, return-value ).
      end.

      release buf_rvs-doc no-error .
      if error-status :error then do:
        undo, return error  substitute( "Ошибка при закрытии документа сверки: &1 &2.", buf_rvs-doc.rvs-code, return-value ).
      end.
    end.
  end.
end procedure. /* close-rvs */


procedure verify-assort-pol :
define input  parameter p-artic     as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .

define variable v-min-ass-exist  as logical   no-undo init false .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define buffer buf_goods for ub.goods  .

  do
  on error undo, return error return-value
  :

  find first buf_goods no-lock where
            buf_goods.artic     = p-artic    and
            buf_goods.prod-type = p-prod-type and
            buf_goods.prod-code = p-prod-code  .


    /* Проверка ассортиментной матрицы для объекта приемника  с НАКЛ- */
    if lookup (bf_trn-doc.ext-doc-type,
              {&TDEDT_Ras_Vnesh} + "," +
              {&TDEDT_Ras_Perem} ) <> 0  and
              ((bf_trn-doc.status_ = {&wayb} and bf_trn-doc.flag_ = false  ) )
      then do:
      var-ok-assort-pol = true .
      if not (bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&prs}) then do:
         v-event-code = substitute("cli_&1-" , bf_trn-doc.ext-doc-type ) .
        { gbl/goassizt.i
          v-event-code
          buf_goods.gds-code
          bf_trn-doc.cli-type
          bf_trn-doc.cli-code
          false
          var-ok-assort-pol
          var-mess-assort-pol
        }
        end.
        else do:
            { gbl/hold-doc.i
              bf_trn-doc.doc-code
              v-is-hold
            }
         if v-is-hold then do:
            v-event-code = substitute("cli_mf_&1-" ,bf_trn-doc.ext-doc-type ) .
            { gbl/goassizt.i
              v-event-code
              buf_goods.gds-code
              bf_trn-doc.hold-obj-type
              bf_trn-doc.hold-obj-code
              false
              var-ok-assort-pol
              var-mess-assort-pol
            }
         end.
         end.

       if var-ok-assort-pol = false then do:
            varerr = true .
            output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
            put    stream str-err unformatted var-mess-assort-pol skip.
            output stream str-err close.
       end.
    end.
    /* Ассортиментная политика по объекту с НАКЛ- */
    if lookup (bf_trn-doc.ext-doc-type,
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
              {&TDEDT_Vozvrat_Perem}  + "," +
              {&TDEDT_Ras_Object}  + "," +
              {&TDEDT_Pri_Object} ) = 0  and
              ((bf_trn-doc.status_ = {&wayb}    and bf_trn-doc.flag_ = false  ))
    then do:
      var-ok-assort-pol = true .
            { gbl/hold-doc.i
              bf_trn-doc.doc-code
              v-is-hold
            }
         if v-is-hold then do:
            v-event-code = substitute("mf_&1-" ,bf_trn-doc.ext-doc-type ) .
         end.
         else do:
            v-event-code = substitute("&1-" ,bf_trn-doc.ext-doc-type ) .
         end.

        { gbl/goassizt.i
          v-event-code
          buf_goods.gds-code
          bf_trn-doc.obj-type
          bf_trn-doc.obj-code
          false
          var-ok-assort-pol
          var-mess-assort-pol
        }
       if var-ok-assort-pol = false then do:
            varerr = true .
            output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
            put    stream str-err unformatted var-mess-assort-pol skip.
            output stream str-err close.
       end.
    end.


    /* Проверка мин остатка в ассортиментной матрице */
    /*
    if bf_trn-doc.status_ = {&fact} then do:
      if v-min-ass-exist = false then do:
       { str/ch-amin.i
         bf_trn-doc.obj-type
         bf_trn-doc.obj-code
         buf_goods.gds-code
         false
         v-min-ass-exist
         }
         end.
            output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
            put    stream str-err unformatted return-value skip.
            output stream str-err close.
    end.
    */
  end.

end procedure. /* verify-assort-pol */

procedure ver-inv-date-close :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-date as date          no-undo .
define variable v-date as date      no-undo .
  do
  on error undo, return error return-value
  :

  find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = p-doc-code and
             ub.doc-attr.attr-code = {&trdcattr-dateinv} no-error .

   if available ub.doc-attr then do:
      v-date =  date (ub.doc-attr.attr-value) .
      if  v-date <  p-date then do:
          return error substitute("Предполагаемая дата закрытия инвентаризации &1 уже просрочена ! Инвентаризацию &2 закрыть нельзя." , string(v-date , "99/99/9999") , p-doc-code ) .
      end.
      if  v-date >  p-date then do:
          return error substitute("Предполагаемая дата закрытия инвентаризации &1 еще не настала ! Инвентаризацию &2 закрыть нельзя." , string(v-date , "99/99/9999") , p-doc-code ) .
      end.
   end.

  end.

end procedure. /* ver-inv-date-close */

procedure fill-mol:
  find first ub.user-account no-lock where ub.user-account.user-id = v-curr-userid.
  if ub.user-account.psn-code <> 0 and ub.user-account.psn-code <> ?
    then 
  do:
    if bf_trn-doc.agnt = ? then do:
      bf_trn-doc.agnt = ub.user-account.psn-code.
    end.
    if bf_trn-doc.wrkr = ?
    then do:
      bf_trn-doc.wrkr = ub.user-account.psn-code.
    end.
    bf_trn-doc.boss = ub.user-account.psn-code.
  end.
  release ub.user-account.    
end procedure.

procedure need-ver-spec :
define output parameter v-is-nover as logical   no-undo .
define variable v-uh as handle no-undo .

  do
  on error undo, return error return-value
  :
  assign
  v-uh = this-procedure:instantiating-procedure
  v-is-nover = false
  .
  if v-uh:persistent then return .
  do while valid-handle(v-uh):
    if v-uh:persistent then return .
    if lookup("cb_close-without-verify", v-uh:internal-entries) > 0 then do:
      run cb_close-without-verify in v-uh ( output v-is-nover ) no-error.
      leave.
    end.
    v-uh = v-uh:instantiating-procedure.
  end.
  end.

end procedure. /* need-ver-spec */