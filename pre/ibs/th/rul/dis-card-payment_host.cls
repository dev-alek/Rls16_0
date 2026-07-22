block-level on error undo, throw.
class Ibs.Th.Rul.dis-card-payment_host:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: dis-card-payment_host.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_gc as handle no-undo.
  define protected variable v_cnt as widget-handle no-undo.
  define private variable v_tbh as handle no-undo.
  define private variable v-error-flag as logical no-undo.
  define public variable pay-tot-base as decimal no-undo .
  define public variable pay-tot-rubl as decimal no-undo .
  define public variable host-code as integer no-undo.
  define public variable d-card as character no-undo .
  define public variable sale-doc as character no-undo.
  define public variable doc-date as date no-undo.
  define public variable base-code as integer no-undo.
  define protected variable codex_id as integer no-undo.
  define protected variable ruleset_id as integer no-undo.
  define private variable v-h-action as integer no-undo .
  CONSTRUCTOR PUBLIC dis-card-payment_host(
                                       input parparentproc as widget-handle
                                      ,input p-parent-handle as handle
                                      ,input p-log-handle as handle
                                      ,input p-gc-handle as handle
                                      ,input p-tbh as handle
                                      ,input p-codex-id as integer
                                      ,input p-ruleset-id as integer
                                      ):
    define variable glog as logical no-undo .
    run garbcoll_create-gc-entry in p-gc-handle (input "dis-card-payment_host",  input this-object) no-error.
    if error-status:error then do:
      message error-status:get-message(1) view-as alert-box .
      return error "Ошибка создания объекта платеж на ДК".
    end.
    assign
    v_ph = p-parent-handle
    v_gc = p-gc-handle
    v_tbh = p-tbh
    d-card = '':U
    codex_id = p-codex-id
    ruleset_id = p-ruleset-id
    .
  end constructor.
  destructor public dis-card-payment_host():
    find_dis-card-payment_host ( input '':U).
  end destructor.
  method public handle get_dis-card-payment_host ( ):
    return v_tbh.
  end method.
  method public void dis-card-payment_hostrelease_ (  ):
    define variable glog as logical no-undo .
    glog = v_tbh:buffer-release() no-error .
    clear_().
  end method.
  method public logical dis-card-payment_hostsave ():
   define variable glog as logical no-undo .
   define variable v-rate as decimal no-undo .
   define buffer buf_curr-shop for ub.curr-shop.
   define buffer buf_curr-accnt for ub.curr-accnt.
   define buffer buf_dis-card for ub.dis-card.
    if d-card <> '':U then do:
        find first buf_dis-card no-lock where
                buf_dis-card.d-card = d-card no-error.
        if not available buf_dis-card then do:
          run set-error in v_gc (substitute("Не найдена ДК для создания итогов по ДК(ДК &1 фирма &2)"
                                            , d-card
                                            , host-code)).
          return no.
        end.
        if (pay-tot-base + pay-tot-rubl ) = ? then do:
          run set-error in v_gc (substitute("Не задано ( =  ?) значение одной из сумм для ДК &1 фирма &2"
                                            , d-card
                                            , host-code
                                            )).
          return no.
        end.
        if (pay-tot-base = 0.0) <> (pay-tot-rubl = 0.0) then do:
          run set-error in v_gc (substitute("Если сумма оплат в нац.вал. = 0, то сумма оплат в баз.вал. тоже должна = 0 и наборот (ДК &1 фирма &2)"
                                            , d-card
                                            , host-code)).
          return no.
        end.
        if base-code = 0
        and pay-tot-base <> pay-tot-rubl then do:
          run set-error in v_gc (substitute("Баз.вал. фирмы = нац.вал. но сумма оплат в баз.вал. <> сумме оплат в нац.вал.(ДК &1 фирма &2)"
                                            , d-card
                                            , host-code)).
          return no.
        end.
        if doc-date = ? then do:
          run set-error in v_gc (substitute("Не задана дата итогов по ДК(ДК &1 фирма &2)"
                                            , d-card
                                            , host-code)).
          return no.
        end.
        assign
        v_tbh:buffer-field("pay-tot-base"):buffer-value  = pay-tot-base
        v_tbh:buffer-field("pay-tot-rubl"):buffer-value  = pay-tot-rubl
        .
    end.
    return glog.
  end method.
  method public logical find_dis-card-payment_host ( p-d-card as character):
    define variable glog as logical no-undo .
    glog = find_dis-card-payment_host( input p-d-card, input 0) no-error .
    if error-status:error then return error return-value .
    return glog.
  end method.
  method public logical find_dis-card-payment_host ( p-d-card as character, p-host-code as integer):
   define variable glog as logical no-undo .
   define variable v-rate as decimal no-undo .
   define buffer buf_curr-accnt for ub.curr-accnt.
   define buffer buf_dis-card for ub.dis-card.
    dis-card-payment_hostrelease_().
    clear_().
    if p-d-card <> '':U then do:
      v-h-action = integer('2':U).
      assign
      glog =  v_tbh:find-first( substitute('where d-card = "&1" and host-code = &2'
                              , p-d-card
                              ,p-host-code
                              )
                              ) no-error .
      if not glog then do:
        return error substitute("Не найдены платеж по ДК &1", p-d-card).
      end.
      assign
      v-h-action = integer('2':U)
      pay-tot-base         = v_tbh:buffer-field("pay-tot-base"):buffer-value
      pay-tot-rubl         = v_tbh:buffer-field("pay-tot-rubl"):buffer-value
      d-card               = v_tbh:buffer-field("d-card"):buffer-value
      sale-doc             = v_tbh:buffer-field("sale-doc"):buffer-value
      doc-date             = v_tbh:buffer-field("doc-date"):buffer-value
      base-code            =  v_tbh:buffer-field("base-code"):buffer-value
      host-code            =  v_tbh:buffer-field("host-code"):buffer-value
      .
    end.
    return glog.
  end method.
  method public logical create_dis-card-payment_host ( input p-d-card as character
                                             ,input p-host-code as integer
                                             ,input p-sale-doc as character
                                             ,input p-doc-date as date
                                             ):
    define variable glog as logical no-undo .
    define buffer buf_clients for ub.clients.
    define buffer buf_dis-card for ub.dis-card.
    define buffer buf_sysconf for ub.sysconf.
    find first buf_clients no-lock where
              buf_clients.obj-type = 'орг':U
          and buf_clients.obj-code = p-host-code no-error.
    if not available buf_clients
    then do:
      run set-error in v_gc (substitute("Неверно задана фирма для создания платежа по ДК(ДК &1 фирма &2)"
                                        , d-card
                                        , p-host-code)).
      return no.
    end.
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = buf_clients.obj-code no-error.
    if not available buf_clients then do:
      run set-error in v_gc (substitute("Неверно задана фирма для создания платежа по ДК - клиент &2&3  не является фирмой IBS TH(ДК &1)"
                                        , d-card
                                        , buf_clients.obj-type
                                        , p-host-code
                                        )).
      return no.
    end.
    find first buf_Dis-card no-lock where
              buf_Dis-card.d-card = p-d-card no-error.
    if not available buf_dis-card then do:
      glog = no.
      run can-find_dis-card_ in v_gc ( input p-d-card
                                      ,output glog) no-error .
      if not glog then do:
        run set-error in v_gc (substitute("Неверно задана ДК для создания платежа по ДК(ДК &1 фирма &2)"
                                        , d-card
                                        , p-host-code
                                          )).
        return no.
      end.
    end.
    glog = v_tbh:buffer-create( ).
    assign
    d-card = p-d-card
    v-h-action = integer('1':U)
    host-code            = buf_clients.host-code
    base-code            = buf_sysconf.base-code
    host-code            = p-host-code
    sale-doc             = p-sale-doc
    doc-date             = p-doc-date
    v_tbh:buffer-field("d-card"):buffer-value = d-card
    v_tbh:buffer-field("host-code"):buffer-value = host-code
    v_tbh:buffer-field("base-code"):buffer-value = base-code
    v_tbh:buffer-field("host-code"):buffer-value = obj-code
    v_tbh:buffer-field("sale-doc"):buffer-value = sale-doc
    v_tbh:buffer-field("doc-date"):buffer-value = doc-date
    pay-tot-base         = 0.0
    pay-tot-rubl         = 0.0
    .
    return yes.
  end method.
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    glog = v_tbh:buffer-delete() no-error .
    assign
    d-card = ''
    v-h-action = 0
    .
  end method.
  method public override character ToString( ):
    return substitute("&1 &2", d-card, sale-doc).
  end method.
end class.
