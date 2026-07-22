/*

$Revision: f7f4e950f623, 0, rls $
$Author: expertek $
$Date: 2012/10/22 17:03:47 $
$Workfile: basecodeClass.i $
$Archive: basecodeClass.i $

Определение кода базовой валюты по коду фирмы

*/

method public integer baseCode (p-host-code  as integer) :

  define variable p-ok        as logical no-undo.
  define variable p-base-code as integer no-undo .
  do
    on error undo, return error return-value
    :

    define buffer buf_sysconf for ub.sysconf .
    for first buf_sysconf field (base-code) no-lock
      where buf_sysconf.host-code = p-host-code :
    assign
      p-base-code = buf_sysconf.base-code
      p-ok        = yes
      .
  end.
  if not p-ok
    then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена фирма" skip
      "host-code" p-host-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  else return p-base-code .
end.

end method. /* basecode */

method public character hostName (p-obj-type as character, p-obj-code as integer):
  do
    on error undo, return error return-value
    :
    define variable p-host-code               like ub.price-doc.host-code no-undo .
    define variable p-host-name               like ub.clients.obj-name no-undo .
    define variable l-last-hostname-exist     as logical no-undo initial false .
    define variable v-last-hostname-obj-type  like ub.price-doc.obj-type no-undo .
    define variable v-last-hostname-obj-code  like ub.price-doc.obj-code no-undo .
    define variable v-last-hostname-host-name like ub.clients.obj-name no-undo .

    define variable l-last-hostcode-exist     as logical no-undo initial false .
    define variable v-last-hostcode-obj-type  like ub.price-doc.obj-type no-undo .
    define variable v-last-hostcode-obj-code  like ub.price-doc.obj-code no-undo .
    define variable v-last-hostcode-host-code like ub.price-doc.host-code no-undo .

    if  l-last-hostname-exist = true
      and p-obj-type            = v-last-hostname-obj-type
      and p-obj-code            = v-last-hostname-obj-code
      then 
    do:
      assign
        p-host-code = v-last-hostcode-host-code
        p-host-name = v-last-hostname-host-name
        .
      return p-host-name. /* --->>>--- */
    end.
    if  l-last-hostname-exist = true
      and p-obj-type = {&cmp}
      and v-last-hostcode-host-code = p-obj-code then 
    do:
      assign
        p-host-code = v-last-hostcode-host-code
        p-host-name = v-last-hostname-host-name
        .
      return p-host-name. /* --->>>--- */
    end.


    define buffer buf_store   for ub.store .
    define buffer buf_shop    for ub.shop .
    define buffer buf_clients for ub.clients.
    define buffer buf_sysconf for ub.sysconf .

    case p-obj-type :
      when {&stock}
      then 
        do:
          find first buf_store no-lock
            where buf_store.obj-code = p-obj-code
            no-error .
          if not available buf_store
            then 
          do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найден склад" skip
              "p-obj-type" p-obj-type skip
              "p-obj-code" p-obj-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-host-code = buf_store.host-code
            .
        end.
      when {&shop}
      then 
        do:
          find first buf_shop no-lock
            where buf_shop.obj-code = p-obj-code
            no-error .
          if not available buf_shop
            then 
          do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найден магазин" skip
              "p-obj-type" p-obj-type skip
              "p-obj-code" p-obj-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-host-code = buf_shop.host-code
            .
        end.
      when {&cmp}
      then 
        do:
          find first buf_sysconf no-lock
            where buf_sysconf.host-code = p-host-code
            no-error.
          if not available buf_sysconf
            then 
          do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена СВОЯ фирма" skip
              "p-obj-type" p-obj-type skip
              "p-obj-code" p-obj-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-host-code = buf_sysconf.host-code
            .
        end.
      otherwise 
      do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип объекта" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if p-obj-type <> {&cmp} then 
    do:
      assign
        l-last-hostcode-exist     = true
        v-last-hostcode-obj-type  = p-obj-type
        v-last-hostcode-obj-code  = p-obj-code
        v-last-hostcode-host-code = p-host-code
        .
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
      and buf_clients.obj-code = p-host-code
      no-error.
    if not available buf_clients
      then 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена фирма" skip
        "p-host-code" p-host-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-host-name = buf_clients.obj-name
      .
    if p-obj-type <> {&cmp} then 
    do:
      assign
        l-last-hostname-exist     = true
        v-last-hostname-obj-type  = p-obj-type
        v-last-hostname-obj-code  = p-obj-code
        v-last-hostname-host-name = p-host-name
        .
    end.
  end.
  return p-host-name .
end method. /* hostname */

method public integer objdnpay (p-obj-type as character, p-obj-code as integer):

  /* определение кода оплаты списания для объекта  */
  define variable p-down-pay like ub.store.down-pay no-undo .

  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .

  if p-obj-type = {&stock}
    then 
  do:
    for buf_store field (down-pay) no-lock
        where buf_store.obj-code = p-obj-code
      .
      assign
        p-down-pay = buf_store.down-pay
        .
    end.
  end.
  else 
  do:
    for buf_shop field (down-pay) no-lock
        where buf_shop.obj-code = p-obj-code
      .
      assign
        p-down-pay = buf_shop.down-pay
        .
    end.
  end.
  return p-down-pay .
end method. /* objdnpay */

method public character  setCurrentUser():
  define variable vSystemUser as ibs.th.file.asyncparam no-undo.
  define variable vSystemPass as ibs.th.file.asyncparam no-undo.
  define variable mAsyncProc  as class                  ibs.th.file.asyncproc no-undo.
  define variable myUser      as character              initial ? no-undo .
  
  mAsyncProc = new ibs.th.file.asyncproc().
  vSystemUser = mAsyncProc:getParamObj("SystemUser").
  vSystemPass = mAsyncProc:getParamObj("SystemPass").
             
  run utl/syspwd.p(input vSystemUser, input vSystemPass)no-error.
  myUser = vSystemUser:valueParam.
  delete object mAsyncProc.
  return myUser .
end.

method public integer gen-b-code(type-code as character):
  define variable p-b-code like ub.bar-code.b-code no-undo . /* выходное значение баркода                 */
  define buffer buf_config     for ub.config .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_code-range for ub.code-range .

  define variable l-code         as integer no-undo .
  define variable v-db-num       like ub.db.db-num no-undo .
  define variable cfg-param-code like ub.config.param-code no-undo .

  if type-code = {&loc-ss-code}
    or type-code = {&gbl-ss-code}
    then 
  do:
    /* диапазон локальных взвешиваемых кодов */
    message
      "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
      "Обратитесь к администратору системы."
      view-as alert-box error .
    undo, return error (if type-code = {&loc-ss-code} then "loc-ss-code":U else "gbl-ss-code" ) .
  end.

  run trg/getpcode.p ( input  type-code
    ,output cfg-param-code
    ).
  l-code = get-next-seq( type-code ).

  find first buf_sys-ctrl no-lock.
  if type-code = {&loc-sc-code}
    or type-code = {&loc-pg-code}
    then 
  do:
    /* диапазон локальных весовых кодов всегда привязан к ГБД */
    assign
      v-db-num = 0
      .
  end.
  else 
  do:
    assign
      v-db-num = buf_sys-ctrl.db-num
      .
  end.
  find first buf_code-range no-lock
    where buf_code-range.db-num     = v-db-num
    and buf_code-range.range-type = type-code
    and buf_code-range.stts       = "a"
    use-index stts
    no-error .
  if available buf_code-range
    and l-code <= buf_code-range.last-code
    and l-code >= buf_code-range.first-code then 
  do:
    /* значение внутри активного диапазона - выставляем его по sequence */
    assign
      p-b-code = l-code
      .
  end.
  else 
  do:
    if available buf_code-range
      and l-code < buf_code-range.last-code then 
    do:
      message
        substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error "sequence":U .
    end.
    /* завхватываем config */
    /* чтобы никто другой не мог одновременно менять диапазон */
    do transaction
      on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
      :
      find first buf_config exclusive-lock
        where buf_config.param-code = cfg-param-code
        and buf_config.host-code  = 0
        and buf_config.obj-type   = ""
        and buf_config.obj-code   = 0
        and buf_config.beg-date   = {&beg-unlim-lcns}
        and buf_config.end-date   = {&end-unlim-lcns}
        and buf_config.db-num     = buf_sys-ctrl.db-num
        no-error .
      if not available buf_config then 
      do:
        if not locked buf_config then 
        do:
          message
            substitute( "Отсутствует конфигурационный параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
            "Он должен быть без привязки и с неограниченным сроком действия лицензии."
            "Обратитесь к администратору системы."
            view-as alert-box error .
        end.
        /* если пользователь отказался подождать, */
        /* то ему не дадим менять диапазон и баркод не дадим ! */
        undo, return error "config":U .
      end.

      l-code = get-next-seq( type-code ).
      /* если диапазон сменился другим пользователем */
      /* то надо перечитать значение sequence, */
      /* если не сменился, то требуется смена диапазона и смена sequence */
      find first buf_code-range
        where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
        use-index stts
        no-error .
      if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then 
      do:
        assign
          p-b-code = l-code
          .
      end.
      else 
      do:
        if available buf_code-range then 
        do:
          /* диапазон никто не сменил */
          /* sequence за пределами диапазона */
          /* помечаем его как использованный */
          assign
            buf_code-range.stts = "u"
            .
        end.
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
          and buf_code-range.range-type = type-code
          and buf_code-range.stts       = "f"
          use-index stts
          no-error .
        if not available buf_code-range then 
        do:
          message
            substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
            "Обратитесь к администратору системы"
            view-as alert-box error .
          undo, return error "code-range":U .
        end.

        /* создаем новый диапазон и присваиваем новое значение seq */
        assign
          buf_code-range.stts = "a"
          .
        if buf_code-range.first-code = 1 then 
        do:
          set-seq-cr( type-code, buf_code-range.first-code ).
          assign
            p-b-code = 1
            .
        end.
        else 
        do:
          set-seq-cr( type-code, ( buf_code-range.first-code - 1 )).
          p-b-code = get-next-seq( type-code ).
        end.
      end.
    end.
  end.
end method.

method public integer get-next-seq (type-code as character):
  
  define variable next-seq as integer no-undo .

    case type-code:
      when {&gbl-bc-code} then do:
        assign
          next-seq = next-value(s-bcgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-sc-code} then do:
        assign
          next-seq = next-value(s-scgb-code, {&db-name_schema})
        .
      end.
      when {&loc-sc-code} then do:
        assign
          next-seq = next-value(s-sclc-code, {&db-name_schema})
        .
      end.
      when {&loc-pg-code} then do:
        assign
          next-seq = next-value(s-pglc-code, {&db-name_schema})
        .
      end.
      when {&gbl-dc-code} then do:
        assign
          next-seq = next-value(s-dcgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-ct-code} then do:
        assign
          next-seq = next-value(s-ctgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-dr-code} then do:
        assign
          next-seq = next-value(s-drgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-fm-code} then do:
        assign
          next-seq = next-value(s-fmgb-code, {&db-name_schema})
        .
      end.
      when {&gbl-pn-code} then do:
        assign
          next-seq = next-value(s-pngb-code, {&db-name_schema})
        .
      end.
      when {&gbl-ca-code} then do:
        assign
          next-seq = next-value(s-cagb-code, {&db-name_schema})
        .
      end.
      when {&gbl-fd-code} then do:
        assign
          next-seq = next-value(s-fin-doc, {&db-name_schema})
        .
      end.
    end case.
  return next-seq .
end method. /* get-next-seq */

method public void set-seq-cr (type-code as character, set-val as integer) :
    case type-code:
      when {&gbl-bc-code} then do:
        assign
          current-value(s-bcgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-sc-code} then do:
        assign
          current-value(s-scgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&loc-sc-code} then do:
        assign
          current-value(s-sclc-code, {&db-name_schema}) = set-val
        .
      end.
      when {&loc-pg-code} then do:
        assign
          current-value(s-pglc-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-dc-code} then do:
        assign
          current-value(s-dcgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-ct-code} then do:
        assign
          current-value(s-ctgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-dr-code} then do:
        assign
          current-value(s-drgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-fm-code} then do:
        assign
          current-value(s-fmgb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-pn-code} then do:
        assign
          current-value(s-pngb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-ca-code} then do:
        assign
          current-value(s-cagb-code, {&db-name_schema}) = set-val
        .
      end.
      when {&gbl-fd-code} then do:
        assign
          current-value(s-fin-doc, {&db-name_schema}) = set-val
        .
      end.
    end case.

end method. /* set-seq-cr */

method public decimal pftxvalg (pargds-code as integer, 
  partax-code as integer, par-date as date, parhost-code as integer,
  parobj-type as character, parobj-code as integer):

  define variable partax-value    as decimal   no-undo .
  DEFINE VARIABLE v-fact-order    as decimal   no-undo .
  define buffer buf_tax-rate-gds for ub.tax-rate-gds.
  define buffer buf_goods        for ub.goods.

    assign
      partax-value = ?
      .

    if not can-find (first buf_goods no-lock
      where buf_goods.gds-code = pargds-code) /*not available buf_goods*/
      then 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Код товара" pargds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if par-date = ?
      then 
    do:
      assign
        par-date = today
        .
    end.

     v-fact-order = factord-end-day (par-date).

    find last buf_tax-rate-gds no-lock
      where buf_tax-rate-gds.gds-code   = pargds-code
      and buf_tax-rate-gds.tax-code   = partax-code
      and buf_tax-rate-gds.host-code  = 0
      and buf_tax-rate-gds.obj-type   = ""
      and buf_tax-rate-gds.obj-code   = 0
      and buf_tax-rate-gds.fact-order <= v-fact-order
      no-error .

    /*налог на товар определен глобально*/

    IF AVAIL buf_tax-rate-gds
      then 
    do:
      partax-value = pftxvalo(?, buf_tax-rate-gds.tax-code, buf_tax-rate-gds.rate-code,
        v-fact-order, parhost-code, parobj-type, parobj-code) .
      return partax-value.
    end.

  end method.

method public decimal pftxvalo (par-rc as recid, partax-code as integer, parrate-code  as integer,
  parfact-order as decimal, parhost-code as integer, parobj-type as character, parobj-code   as integer):

  define variable partax-value    as decimal   no-undo .
  define buffer buf_tax-rate       for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.

    assign
      partax-value = ?
      .

    if partax-code  = 0
      or parrate-code = 0
      then 
    do:
      if par-rc = ?
        then 
      do:
        undo, return error "Неверный параметр - recid tax-rate" .
      end.
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
        then 
      do:
        undo, return error "Не найдена ставка налога " + "recid " + string(par-rc) .
      end.
      if buf_tax-rate.status_ = {&deleted-status}
        then 
      do:
        undo, return error "Ставка налога недействительна "
          + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .
      end.
      assign
        partax-code  = buf_tax-rate.tax-code
        parrate-code = buf_tax-rate.rate-code
        .
    end.

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
      and buf_tax-rate-value.rate-code  = parrate-code
      and buf_tax-rate-value.host-code  = parhost-code
      and buf_tax-rate-value.obj-type   = parobj-type
      and buf_tax-rate-value.obj-code   = parobj-code
      and buf_tax-rate-value.fact-order <= parfact-order
      and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value
      then 
    do:
      assign
        partax-value = buf_tax-rate-value.rate-value
        .
      return partax-value.
    end.

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
      and buf_tax-rate-value.rate-code  = parrate-code
      and buf_tax-rate-value.host-code  = parhost-code
      and buf_tax-rate-value.obj-type   = ""
      and buf_tax-rate-value.obj-code   = 0
      and buf_tax-rate-value.fact-order <= parfact-order
      and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value
      then 
    do:
      assign
        partax-value = buf_tax-rate-value.rate-value
        .
      return partax-value.
    end.

    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
      and buf_tax-rate-value.rate-code  = parrate-code
      and buf_tax-rate-value.host-code  = 0
      and buf_tax-rate-value.obj-type   = ""
      and buf_tax-rate-value.obj-code   = 0
      and buf_tax-rate-value.fact-order <= parfact-order
      and buf_tax-rate-value.status_    = {&current-status}
      no-error .
    if available buf_tax-rate-value
      then 
    do:
      assign
        partax-value = buf_tax-rate-value.rate-value
        .
      return partax-value.
    end.
end method. /* pftaxval */

method public decimal st-sltpc (p-goods-recid    as recid, p-trn-doc-recid  as recid, p-cash-pay as integer):
  define variable p-st-sltpc-slt like ub.doc-line.SLT-pc no-undo.

  def    var      v-host-code    like ub.sysconf.host-code no-undo.
  define variable varslt-yes     as logical no-undo.
  def buffer buf_st-sltpc_goods   for ub.goods.
  def buffer buf_st-sltpc_trn-doc for ub.trn-doc.

  find first buf_st-sltpc_goods   where recid(buf_st-sltpc_goods)     = p-goods-recid.
  find first buf_st-sltpc_trn-doc where recid(buf_st-sltpc_trn-doc)   = p-trn-doc-recid.

  { str/chpsltpc.i
  buf_st-sltpc_trn-doc.internal
  buf_st-sltpc_trn-doc.doc-type
  buf_st-sltpc_trn-doc.pay-code
  p-cash-pay
  buf_st-sltpc_trn-doc.slt-type
  buf_st-sltpc_trn-doc.ext-doc-type
  varslt-yes
  no-error
}
  if error-status :error then 
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке установки налога с продаж " skip
      " для товара " buf_st-sltpc_goods.artic buf_st-sltpc_goods.prod-type buf_st-sltpc_goods.prod-code skip
      " в документе " buf_st-sltpc_trn-doc.doc-code skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
      view-as alert-box error.
    undo, return error .
  end.
  if varslt-yes
    then 
  do:
    v-host-code = hostcode(buf_st-sltpc_trn-doc.obj-type, buf_st-sltpc_trn-doc.obj-code) .
    p-st-sltpc-slt = pftxvalg(buf_st-sltpc_goods.gds-code, 2, ?, v-host-code,
      buf_st-sltpc_trn-doc.obj-type, buf_st-sltpc_trn-doc.obj-code) .
  end.
  else 
  do:
    assign
      p-st-sltpc-slt = 0
      .
  end.
end method. /* st-sltpc */

method public integer hostcode (p-obj-type  as character, p-obj-code  as integer):
  define variable p-host-code     as integer   no-undo .
  define variable p-ok            as logical   no-undo .
    define variable l-last-hostcode-exist     as logical no-undo initial false .
    define variable v-last-hostcode-obj-type  like ub.price-doc.obj-type no-undo .
    define variable v-last-hostcode-obj-code  like ub.price-doc.obj-code no-undo .
    define variable v-last-hostcode-host-code like ub.price-doc.host-code no-undo .

  if  l-last-hostcode-exist = true
    and p-obj-type            = v-last-hostcode-obj-type
    and p-obj-code            = v-last-hostcode-obj-code
    then 
  do:
    assign
      p-host-code = v-last-hostcode-host-code
      .
    return p-host-code. /* --->>>--- */
  end.

  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop .

  case p-obj-type :
    when {&stock}
    then 
      do:
        /*find first buf_store no-lock
          where buf_store.obj-code = p-obj-code
          no-error .*/
        for first buf_store field (host-code) no-lock
        where buf_store.obj-code = p-obj-code :
        assign
          p-host-code = buf_store.host-code
          p-ok        = yes
          .
      end.
    if not p-ok
      then 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден склад" skip
        "p-obj-type" p-obj-type skip
        "p-obj-code" p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
    when {&shop}
    then do:
/*find first buf_shop no-lock
  where buf_shop.obj-code = p-obj-code
  no-error .*/
for first buf_shop field (host-code) no-lock
        where buf_shop.obj-code = p-obj-code :
assign
  p-host-code = buf_shop.host-code
  p-ok        = yes
  .
end.
if not p-ok
  then 
do:
  message
    vss-workfile vss-revision vss-description skip
    "Не найден магазин" skip
    "p-obj-type" p-obj-type skip
    "p-obj-code" p-obj-code skip
    view-as alert-box error .
  undo, return error return-value .
end.
end.
    otherwise do:
message
  vss-workfile vss-revision vss-description skip
  "Неизвестный тип объекта" skip
  "p-obj-type" p-obj-type skip
  "p-obj-code" p-obj-code skip
  view-as alert-box error .
undo, return error return-value .
end.
end.

assign
  l-last-hostcode-exist     = true
  v-last-hostcode-obj-type  = p-obj-type
  v-last-hostcode-obj-code  = p-obj-code
  v-last-hostcode-host-code = p-host-code
  .

end method. /* hostcode */

method public decimal factord-end-day(p-fact-date            as date) :
  define variable  p-day-end-fact-order   as decimal no-undo . /* номер конца дня                      */
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.

    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
end method. /* factord-end-day */