block-level on error undo, throw.
/*

$Revision: 55cbd55c1b5e, 500, rls $
$Author: EShklyar $
$Date: Sun Feb 28 19:23:25 2016 +0400 $
$Workfile: trn-open.p $
$Archive: str/trn-open.p $

Изменение статуса складского документа - Открытие документа
выделено в отдельную процедуру т.к. в trn-stat.p ECODE

Автор: Чернова Светлана Александровна
Дата создания: 12/02/05
Author: Svetlana Chernova
Creation date: 12/02/05


*/

define input parameter parparentproc   AS   WIDGET-HANDLE       NO-UNDO.
define input parameter parmode         as   character           no-undo. /*режим обработки*/
define input parameter pardoc-code     like ub.trn-doc.doc-code no-undo. /*номер документа*/
define input parameter parcheck-return as   logical             no-undo. /*проверка старого возврата*/
define input parameter pardb-num       like ub.db.db-num        no-undo. /*номер БД на которой производим операцию*/
define input parameter parin-ov        as   logical             no-undo. /*включена переоценка по приходу*/
define input parameter parrsrv-time    as   integer             no-undo. /*интервал резервирования по расходной накладной*/
define input parameter parload-time    as   integer             no-undo. /*интервал оформления внутреннего прихода*/
define input parameter parholidays     as   character           no-undo. /*выходные дни в неделе*/
define input parameter parmessage      as   logical             no-undo. /*можно задавать вопросы*/

define variable vss-revision    as character no-undo initial "$Revision: 55cbd55c1b5e, 500, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Sun Feb 28 19:23:25 2016 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: trn-open.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/trn-open.p $":U .
define variable vss-description as character no-undo initial "Изменение статуса складского документа":U .

{ cmp/vssrevis.i "substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,parparentproc,parmode,pardoc-code,parcheck-return,pardb-num),substitute('&1|&2|&3|&4|&5':u,parin-ov,parrsrv-time,parload-time,parholidays,parmessage))" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i noprocess }
{ cmp/library.i  }
{ str/trdcalib.i }
{ str/clcprtsl.i }
{ str/get-pr.i   def }
{ str/lib-trn.i  }
/*{ str/plgdsfnd.i }*/
{ str/lib-rvs.i  }
{ str/lib-def.i  }
{ str/lib-calc.i }
{ str/doc-code.i }
{ trg/partslib.i }
{ str/lib-rwds.i }
{ str/libtfarh.i }
{ str/in-vatp.i  def }
{ cmp/gds-list.i gds-list def }
{ gbl/getsect.i def }

/* define output parameter table for gds-list. */
define buffer bf_trn-doc      for ub.trn-doc.
define buffer exp_trn-doc     for ub.trn-doc.
define buffer bf_goods        for ub.goods.
define buffer bf_doc-line     for ub.doc-line.
define buffer bf_clients      for ub.clients.
define buffer bf_pay-type     for ub.pay-type.
define buffer bf_doc-pl       for ub.doc-pl.
define buffer buf_inv-line    for ub.inv-line .
define buffer bf_gds-dtl      for ub.gds-dtl.
define buffer bf_currency     for ub.currency.
define buffer bf_parts        for ub.parts.
define buffer bf-cst_parts    for ub.parts.
define buffer bf_rvs-doc      for ub.rvs-doc.
define buffer bf_gds-prt      for ub.gds-prt.
define buffer bf_dis-card     for ub.dis-card.
define buffer bf_rvs-line     for ub.rvs-line.
define buffer bf_store        for ub.store.
define buffer bf_contract     for ub.contract.
define buffer ret-doc         for ub.trn-doc.
define buffer old-line        for ub.doc-line.
define buffer ret-dtl         for ub.gds-dtl.
define buffer old-doc         for ub.trn-doc.
define buffer unblock-rvs-doc for ub.rvs-doc.
define buffer exp-dtl         for ub.gds-dtl.
define buffer c-in            for ub.trn-doc.
define buffer del_fin-ob-trn  for ub.fin-ob-trn.
define buffer bf_fin-ob-trn   for ub.fin-ob-trn.
define buffer del_fin-ob      for ub.fin-ob.

define variable inv-shipvalue-string         as   character                   no-undo.
define variable inv-shiptype                 as   character                   no-undo.
define variable varrnd-znk                   as   character initial ?         no-undo.
define variable varrnd-type                  as   character initial ?         no-undo.
define variable clsreserv-pl-code            as   logical                     no-undo.
define variable clspl-code                   like ub.place.pl-code            no-undo.
define variable vardoc-code                  like ub.trn-doc.doc-code         no-undo.
define variable varfact-date                 like ub.trn-doc.fact-date        no-undo.
define variable varfact-time                 like ub.trn-doc.fact-time        no-undo.
define variable varshift-date                like ub.trn-doc.shift-date       no-undo.
define variable varshift-num                 like ub.trn-doc.shift-num        no-undo.
define variable unblock-rvs-code             like ub.rvs-doc.rvs-code         no-undo.
define variable rvs-doc-rvs-code             like ub.rvs-doc.rvs-code         no-undo.
define variable fact-ok                      as   logical initial yes         no-undo.  /* факт закрытие без коррекции */
define variable varstatus                    like ub.trn-doc.status_          no-undo.
define variable varflag                      like ub.trn-doc.flag_            no-undo.
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
define variable varflag-add-err              as   logical                     no-undo.
define variable varchk-prs                   as   character                   no-undo.
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
define variable varcontract                  as   character                   no-undo.
define variable varcontract-type             as   character                   no-undo.
define variable is-recalc                    as   logical                     no-undo.
define variable varcontract-code             like ub.contract.contract-code   no-undo.
define variable varr-b                       as   character                   no-undo.
define variable varobj-shift-date            as   date                        no-undo.
define variable varobj-shift-num             as   integer                     no-undo.
define variable varhold-doc                  as   logical                     no-undo.
define variable vartpsi                      as   character                   no-undo.
define variable vartpsi-type                 as   character                   no-undo.
define variable is-fin                       as   character                   no-undo.
define variable parcontract-code             as   character                   no-undo.
define variable parcontract-type             as   character                   no-undo.
define variable p-status                     as   date                        no-undo .
define variable varminus-parts               as   character                   no-undo.
define variable varminus-parts-type          as   character                   no-undo.
define variable varerr                       as   logical                     no-undo.
define variable rec-inv-line                 as   recid                       no-undo .
define variable v-fo-gen                     as   integer                     no-undo .
define variable v-del-fo                     as   logical                     no-undo .
define variable v-kol-trn-fo                 as   integer                     no-undo .
define stream str-err.

define temp-table tt-doc-pl no-undo like ub.doc-pl
  field wast-cli-qnty like ub.doc-line.cli-qnty.

find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
if not available bf_trn-doc then do:
  run waitfram-hide in this-procedure no-error.
  return error substitute ("Не найден документ с номером &1.", bf_trn-doc.doc-code).
end.
run str/my-obj.p (input bf_trn-doc.obj-type, input bf_trn-doc.obj-code, input pardb-num, output varmy-obj).
run waitfram-show in this-procedure (substitute ("Определяем статус для установки в документе &1.", pardoc-code)) no-error.
run str/trn-graf.p (input  bf_trn-doc.doc-code,
                input  pardb-num,
                input  parmode,
                output varstatus,
                output varflag,
                output varcopystatus,
                output varcopyflag) no-error.
if error-status:error then do:
   run waitfram-hide in this-procedure no-error.
   return error return-value.
end.


assign varlns-cnt = 0 .
run waitfram-show in this-procedure (substitute("Переход документа в статус &1&2.", varstatus, (if varstatus = {&fact} then '' else (if varflag = yes then "+" else "-")))).
{ gbl/hold-doc.i
  bf_trn-doc.doc-code
  varhold-doc
}

  /*Если существуют документы сверки по документы, то его открыть нельзя*/
  find first bf_rvs-doc where bf_rvs-doc.out-code = bf_trn-doc.doc-code no-lock no-error.
  if available bf_rvs-doc then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error "По накладной имеются документы сверки. Удалите сначала сверки.".
  end.
  case bf_trn-doc.doc-type:
  when {&income} then do:
     if not bf_trn-doc.internal                          and
        lookup (bf_trn-doc.status_, {&wayb_inquiry}) > 0 then do:
        run waitfram-show in this-procedure (substitute ("Очистка документа. Время: &1", string (time - vartime, "hh:mm:ss"))) no-error.
        run clear-fact in this-procedure no-error.
        if error-status:error then do:
          return error return-value.
        end.
        assign
          is-ok     = yes
          is-recalc = yes.
     end.
     if bf_trn-doc.internal             and
        bf_trn-doc.status_ = {&inquiry} then do:
       assign
         is-ok     = yes
         is-recalc = no.
     end.
  end.
  /* открытие внутреннего ПРИходного запроса */
  when {&expense}   or
  when {&write-off} or
  when {&return}    then do:
    if bf_trn-doc.status_ =  {&permitted} and
       not varmy-obj    then do:
      run waitfram-hide in this-procedure no-error.
      undo, return error substitute("Статус &1 можно изменить только в своей базы данных или для пассивного объекта",bf_trn-doc.status_) .
    end.
    if bf_trn-doc.status_ <> {&permitted} then do:
      run waitfram-show in this-procedure (substitute ("Очистка документа. Время: &1", string (time - vartime, "hh:mm:ss"))) no-error.
      run clear-fact in this-procedure no-error.
      if error-status:error then do:
        undo, return error return-value.
      end.
    end.
    if bf_trn-doc.status_ = {&wayb}      OR
       bf_trn-doc.status_ = {&inquiry}   OR
       bf_trn-doc.status_ = {&permitted} then do:
      assign
        is-ok     = yes
        is-recalc = yes.
    end.
     /*       Обработка связанных ФО     */
    v-del-fo = true .
    v-kol-trn-fo = 0.
    { gbl/getsect.i run "''" 0  {&attr-fin-global} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = {&attr-fin-global_fo-gen}  then v-fo-gen = thbjattr_thbj-attr.property-value-integer .
    end.
    if bf_trn-doc.status_ = {&wayb} or
       (bf_trn-doc.status_ = {&permitted} and (v-fo-gen = 4 or v-fo-gen = 5))
       then do :
        bf_trn-doc.need-buyer = 0.
        for each del_fin-ob-trn where del_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code  and
                                      del_fin-ob-trn.host-code    = bf_trn-doc.host-code exclusive-lock,
                each del_fin-ob where del_fin-ob.doc-code = del_fin-ob-trn.doc-code  exclusive-lock
                :
                for each bf_fin-ob-trn where bf_fin-ob-trn.doc-code = del_fin-ob.doc-code no-lock,
                    each exp_trn-doc where exp_trn-doc.doc-code = bf_fin-ob-trn.trn-doc-code no-lock :
                      v-kol-trn-fo = v-kol-trn-fo + 1.
                end.
                    if v-kol-trn-fo > 1 then do :
                      assign
                        v-del-fo = false .
                      /* v-mod-fo = true .  */
                      message substitute ("ФО №&1 по данной накладной не будет удалено, т.к. сформированно по нескольким накладным", del_fin-ob.doc-code) view-as alert-box .
                    end.
                if del_fin-ob.status_ <> {&fact}  and v-del-fo then do :
                  assign
                    del_fin-ob.is-doc-del = yes.
                    del_fin-ob-trn.is-doc-del = yes.
                  delete del_fin-ob.
                  if available del_fin-ob-trn then delete del_fin-ob-trn.
                end.
                else if del_fin-ob.status_ = {&fact} then do :
                    message substitute ("ФО №&1 по данной накладной не будет удалено, т.к. закрыто на факт", del_fin-ob.doc-code) view-as alert-box .
                end.
        end.
    end.
  end.
  when {&inventory} then do:
    if bf_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
      if bf_trn-doc.status_ = {&wayb} then do:
         if bf_trn-doc.flag_ = yes then do:
            assign
              bf_trn-doc.flag_   = varflag
              bf_trn-doc.status_ = varstatus
              is-ok              = yes
              is-recalc          = no.
         end.
         else do:
           run waitfram-hide in this-procedure no-error.
           undo, return error substitute ("Нельзя открыть документ &1.", bf_trn-doc.doc-code).
         end.
      end.
      else do:
        if bf_trn-doc.status_ = {&permitted} then do:
          run waitfram-show in this-procedure (substitute ("Сброс флагов строк инвентаризации с кассы. Время: &1", string (time - vartime, "hh:mm:ss"))) no-error.
          run str/incdstat.p ( input parparentproc, buffer bf_trn-doc, input -1) no-error .
          run waitfram-show in this-procedure (substitute ("Открытие инвентаризации. Время: &1", string (time - vartime, "hh:mm:ss"))) no-error.
          run str/inv-open.p (input recid(bf_trn-doc),
                          input bf_trn-doc.status_,
                          input bf_trn-doc.flag_) no-error.
          if error-status :error then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error return-value.
          end.
          assign
           bf_trn-doc.flag_   = varflag
           bf_trn-doc.status_ = varstatus
           is-ok              = yes
           is-recalc          = yes          .
        end.
        else do:
          run waitfram-hide in this-procedure no-error.
          undo, return error substitute ("Нельзя открыть документ &1.", bf_trn-doc.doc-code).
        end.
      end.
    end.
    else do:
      run waitfram-hide in this-procedure no-error.
      undo, return error substitute ("Нельзя открыть документ &1.", bf_trn-doc.doc-code).
    end.
  end.
  otherwise do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute ("Нельзя открыть документ &1.", bf_trn-doc.doc-code).
  end.
  end case.
  if is-ok = no then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute ("Нельзя открыть документ &1.", bf_trn-doc.doc-code).
  end.
  if is-ok = yes then do:
    assign
    bf_trn-doc.status_ = varstatus
    bf_trn-doc.flag_   = varflag.
    if is-recalc = yes then do:
      run waitfram-show in this-procedure (substitute ("Пересчет шапки документа. Время: &1", string (time - vartime, "hh:mm:ss"))) no-error.
      run gbl/calc-trn.p (input parparentproc, input recid(bf_trn-doc)) no-error.
      if error-status:error then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error substitute("Ошибка при расчете документа &1.", bf_trn-doc.doc-code).
      end.
    end.
  end.

procedure clear-fact :
do on error undo, return error return-value :
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error :
  run waitfram-show in this-procedure (substitute( "Очистка строк. Всего строк: &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss") ) ) no-error.
  assign
    varcount = varcount + 1
  .
  if bf_doc-line.doc-qnty = 0
  then do:
    delete bf_doc-line.
  end.
  else do:
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
                          and bf_gds-dtl.artic     = bf_doc-line.artic
                          and bf_gds-dtl.prod-type = bf_doc-line.prod-type
                          and bf_gds-dtl.prod-code = bf_doc-line.prod-code on error undo, return error:
      accumulate bf_gds-dtl.doc-qnty (total).
      if bf_gds-dtl.doc-qnty = 0
      then do:
        delete bf_gds-dtl.
      end.
      else do:
        bf_gds-dtl.fact-qnty = bf_gds-dtl.doc-qnty.
      end.
    end.
    for each bf_parts where bf_parts.out-code  = bf_doc-line.doc-code
                        and bf_parts.artic     = bf_doc-line.artic
                        and bf_parts.prod-type = bf_doc-line.prod-type
                        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error
    :
      if bf_parts.qnty = 0
      then do:
        delete bf_parts.
      end.
      else do:
        bf_parts.fact-qnty = bf_parts.qnty.
      end.
    end.
    assign
      bf_doc-line.fact-qnty    = bf_doc-line.doc-qnty
      bf_doc-line.fact-density = bf_doc-line.doc-density
    .
    if bf_trn-doc.doc-type = {&income} and
       not bf_trn-doc.internal         and
       (accum total bf_gds-dtl.doc-qnty) = 0
    then do:
      /* на внеш ПН разбивали по признакам только по факт */
      bf_doc-line.prt-OK = ?.
    end.
    find first bf_goods no-lock
      where bf_goods.prod-type = bf_doc-line.prod-type
        and bf_goods.prod-code = bf_doc-line.prod-code
        and bf_goods.artic     = bf_doc-line.artic
      .
    for each bf_doc-pl
      where bf_doc-pl.obj-type = bf_doc-line.obj-type
        and bf_doc-pl.obj-code = bf_doc-line.obj-code
        and bf_doc-pl.out-code = bf_doc-line.doc-code
        and bf_doc-pl.gds-code = bf_goods.gds-code
    on error undo, return error return-value
    :
      assign
        bf_doc-pl.fact-qnty     = bf_doc-pl.doc-qnty
        bf_doc-pl.cli-fact-qnty = bf_doc-pl.cli-doc-qnty
      .
    end. /* for each bf_doc-pl */
    find first buf_inv-line no-lock
      where buf_inv-line.doc-code  = bf_doc-line.doc-code
        and buf_inv-line.artic     = bf_doc-line.artic
        and buf_inv-line.prod-type = bf_doc-line.prod-type
        and buf_inv-line.prod-code = bf_doc-line.prod-code
      no-error .
    if available buf_inv-line then do:
      { str/corinvln.i
        bf_doc-line.doc-code
        bf_doc-line.artic
        bf_doc-line.prod-type
        bf_doc-line.prod-code
        0
        0
        0
        0
        "bf_doc-line.doc-qnty * bf_doc-line.doc-density"
        bf_doc-line.doc-density
        rec-inv-line
        no-error
      }
      if error-status :error then do:
        return error return-value .
      end.
    end.
  end.
end.
end.
end procedure.