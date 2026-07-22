/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-card-sale_obj.cls $
$Archive: ibs/th/rul/dis-card-sale_obj.cls $

Класс Суммы по ДК по одной продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/04/07
Author: Bakhtadze Natalya
Creation date: 03/04/07

*/
block-level on error undo, throw.
class Ibs.Th.Rul.Dis-card-sale_obj:
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: dis-card-sale_obj.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_pp as widget-handle no-undo. /*parparentproc*/
  define protected variable v_ph as handle no-undo.        /*p-parent-handle*/
  define protected variable v_lh as widget-handle no-undo. /*p-log-handle*/
  define protected variable v_gc as handle no-undo.
  define protected variable v_cnt as widget-handle no-undo. /*p-cont-handle*/
  define public variable v_tbh as handle no-undo.
  define private variable v-error-flag as logical no-undo.
  define public variable gds-dis-base as decimal no-undo .
  define public variable gds-dis-rubl as decimal no-undo .
  define public variable gds-tot-b0 as decimal   no-undo .
  define public variable gds-tot-base as decimal no-undo .
  define public variable gds-tot-r0 as decimal   no-undo .
  define public variable gds-tot-rubl as decimal no-undo .
  define public variable num-chk as integer      no-undo .
  define public variable pay-tot-base as decimal no-undo .
  define public variable pay-tot-rubl as decimal no-undo .
  define public variable obj-code as integer no-undo.
  define public variable obj-type as character no-undo.
  define public variable host-code as integer no-undo.
  define public variable d-card as character no-undo .
  define public variable sale-doc as character no-undo.
  define public variable doc-date as date no-undo.
  define public variable base-code as integer no-undo.
  define public variable type as character no-undo.
  define public variable emitent-host-code as integer no-undo.
  define public variable cli-type as character no-undo.
  define public variable cli-code as integer no-undo.
  define public variable sale-type as character no-undo.
  define public variable action as integer no-undo.
  define protected variable codex_id as integer no-undo.
  define protected variable ruleset_id as integer no-undo.
  define private variable v-h-action as integer no-undo .
  CONSTRUCTOR PUBLIC dis-card-sale_obj(
                                       input parparentproc as widget-handle
                                      ,input p-parent-handle as handle
                                      ,input p-log-handle as handle
                                      ,input p-gc-handle as handle
                                      ,input p-tbh as handle
                                      ,input p-codex-id as integer
                                      ,input p-ruleset-id as integer
                                      ):
    define variable glog as logical no-undo .
    run garbcoll_create-gc-entry in p-gc-handle (input "dis-card-sale_obj",  input this-object) no-error.
    if error-status:error then do:
      message error-status:get-message(1) view-as alert-box .
      return error "Ошибка создания объекта итоги ДК по одной продаже".
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
  destructor public dis-card-sale_obj():
    find_dis-card-sale_obj ( input '':U).
  end destructor.
  method public handle get_dis-card-sale_obj ( ):
    return v_tbh.
  end method.
  method public logical set_dis-card-sale_obj ( input p-src-bh as handle):
    define variable glog as logical no-undo .
    if v_tbh:available = no then do:
      undo, return error substitute("В настоящий момент в буфере-приемнике нет записи").
    end.
    do transaction :
      assign
      glog = v_tbh:buffer-copy( p-src-bh, "d-card,obj-type,obj-code")
      no-error .
    end.
    if glog then  do:
      setfields_from_bh().
    end.
    return glog.
  end method.
  method public handle get_dis-card-sale_obj_field ( input p-field-name as character ):
    return v_tbh:buffer-field(p-field-name).
  end method.
  method public void Dis-card-sale_objrelease_ (  ):
    define variable glog as logical no-undo .
    do transaction :
      glog = v_tbh:buffer-release() no-error .
    end.
    clear_().
  end method.
  method public logical dis-card-sale_objsave ():
   define variable glog as logical no-undo .
   define variable v-rate as decimal no-undo .
   define buffer buf_curr-shop for ub.curr-shop.
   define buffer buf_curr-accnt for ub.curr-accnt.
   define buffer buf_dis-card for ub.dis-card.
    if d-card <> '':U then do:
        find first buf_dis-card no-lock where
                buf_dis-card.d-card = d-card no-error.
        if not available buf_dis-card then do:
          run set-error in v_gc (substitute("Не найдена ДК для создания итогов по ДК(ДК &1 &2&3)"
                                            , d-card
                                            , obj-type
                                            , obj-code)).
          return no.
        end.
        if (pay-tot-base + pay-tot-rubl +
            gds-dis-base + gds-dis-rubl +
            gds-tot-base + gds-tot-rubl +
            num-chk) = ? then do:
          run set-error in v_gc (substitute("Не задано ( =  ?) значение одной из сумм или кол-во чеков для ДК &1 &2&3"
                                            , d-card
                                            , obj-type
                                            , obj-code
                                            )).
          return no.
        end.
        if (pay-tot-base = 0.0) <> (pay-tot-rubl = 0.0) then do:
          run set-error in v_gc (substitute("Если сумма оплат в нац.вал. = 0, то сумма оплат в баз.вал. тоже должна = 0 и наборот (ДК &1 &2&3)"
                                            , d-card
                                            , obj-type
                                            , obj-code)).
          return no.
        end.
        if codex_id = 4 then do:
          if base-code = 0
          and pay-tot-base <> pay-tot-rubl then do:
            run set-error in v_gc (substitute("Баз.вал. фирмы = нац.вал. но сумма оплат в баз.вал. <> сумме оплат в нац.вал.(ДК &1 &2&3)"
                                              , d-card
                                              , obj-type
                                              , obj-code)).
            return no.
          end.
          if doc-date = ? then do:
            run set-error in v_gc (substitute("Не задана дата итогов по ДК(ДК &1 &2&3)"
                                              , d-card
                                              , obj-type
                                              , obj-code)).
            return no.
          end.
          if base-code <> 0 then do:
            if obj-type = {&shop} then do:
              find first buf_curr-shop no-lock where
                        buf_curr-shop.obj-type = {&shop}
                    and buf_curr-shop.obj-code = obj-code
                    and buf_curr-shop.curr-code = base-code
                    and buf_curr-shop.exch-date <= doc-date no-error .
              if not available buf_curr-shop then do:
                run set-error in v_gc (substitute("Невозможно определить курс для баз. вал. на день импорта итогов по ДК(ДК &1 &2&3 код.баз.вал. &4 )"
                                                  , d-card
                                                  , obj-type
                                                  , obj-code
                                                  , base-code
                                                  , doc-date
                                                  )).
                return no.
              end.
              v-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale.
            end.
            else do:
              find first buf_curr-accnt no-lock where
                      buf_curr-accnt.curr-code = base-code
                    and buf_curr-accnt.exch-date <= doc-date no-error .
              if not available buf_curr-accnt then do:
                run set-error in v_gc (substitute("Невозможно определить курс для баз. вал. на день импорта итогов по ДК(ДК &1 &2&3 код.баз.вал. &4 )"
                                                  , d-card
                                                  , obj-type
                                                  , obj-code
                                                  , base-code
                                                  , doc-date
                                                  )).
                return no.
              end.
              v-rate = buf_curr-accnt.exch-rate / buf_curr-accnt.exch-scale.
            end.
            if ((pay-tot-base = pay-tot-rubl
            and v-rate <> 0 )
            or pay-tot-base * v-rate / pay-tot-rubl > 1.5
            or pay-tot-base * v-rate / pay-tot-rubl < 0.5)
            and
            not (pay-tot-base = 0 and pay-tot-rubl = 0)
            then do:
              run set-error in v_gc (substitute("Суммы итогов указаны неверно: сумма в баз.вал. не совпадает с рассчитанной по курсу в пределах погрешности&6(ДК &1 &2&3 код.баз.вал. &4 )"
                                                , d-card
                                                , obj-type
                                                , obj-code
                                                , base-code
                                                , doc-date
                                                , {&new-line}
                                                )).
              return no.
            end.
          end. /*if base-code <> 0 then do:*/
        end. /*if codex_id = 4 then do:*/
        assign
        v_tbh:buffer-field("gds-dis-base"):buffer-value  = gds-dis-base
        v_tbh:buffer-field("gds-dis-rubl"):buffer-value  = gds-dis-rubl
        v_tbh:buffer-field("gds-tot-base"):buffer-value  = gds-tot-base
        v_tbh:buffer-field("gds-tot-rubl"):buffer-value  = gds-tot-rubl
        v_tbh:buffer-field("pay-tot-base"):buffer-value  = pay-tot-base
        v_tbh:buffer-field("pay-tot-rubl"):buffer-value  = pay-tot-rubl
        v_tbh:buffer-field("gds-tot-b0"):buffer-value    = gds-tot-b0
        v_tbh:buffer-field("gds-tot-r0"):buffer-value    = gds-tot-r0
        v_tbh:buffer-field("num-chk"):buffer-value       = num-chk
        v_tbh:buffer-field("type"):buffer-value          = type
        v_tbh:buffer-field("emitent-host-code"):buffer-value = emitent-host-code
        v_tbh:buffer-field("cli-type"):buffer-value      = cli-type
        v_tbh:buffer-field("cli-code"):buffer-value      = cli-code
        v_tbh:buffer-field("sale-type"):buffer-value      = sale-type
        v_tbh:buffer-field("obj-type"):buffer-value      = obj-type
        v_tbh:buffer-field("obj-code"):buffer-value      = obj-code
        .
        if codex_id = 4 then do:
          run 00040000_set-vpay-chk in v_gc( input v_tbh) no-error.
        end.
        if not error-status :error then do:
          glog = yes.
        end.
    end. /*if d-card <> '':U then do:*/
    return glog.
  end method.
  method public logical find_dis-card-sale_obj_no-error ( p-d-card as character):
    define variable glog as logical no-undo .
    glog = find_dis-card-sale_obj( input p-d-card, input '':U, input 0) no-error .
    if error-status:error then return no .
    return glog.
  end method.
  method public logical find_dis-card-sale_obj ( p-d-card as character):
    define variable glog as logical no-undo .
    glog = find_dis-card-sale_obj( input p-d-card, input '':U, input 0) no-error .
    if error-status:error then return error return-value .
    return glog.
  end method.
  method public logical find_dis-card-sale_obj ( p-d-card as character, p-obj-type as character, p-obj-code as integer):
   define variable glog as logical no-undo .
   define variable v-rate as decimal no-undo .
   define buffer buf_curr-shop for ub.curr-shop.
   define buffer buf_curr-accnt for ub.curr-accnt.
   define buffer buf_dis-card for ub.dis-card.
    dis-card-sale_objrelease_().
    clear_().
    if p-d-card <> '':U then do:
      v-h-action = integer({&hn-update}).
      if p-obj-type = '':U
      or p-obj-code = 0 then do:
        assign
        glog =  v_tbh:find-first( substitute('where d-card = "&1"'
                                , p-d-card)
                                ) no-error .
      end.
      else do:
        assign
        glog =  v_tbh:find-first( substitute('where d-card = "&1" and obj-type = "&2" and obj-code = &3'
                                , p-d-card
                                ,p-obj-type
                                ,p-obj-code
                                )
                                ) no-error .

      end.
      if not glog then do:
        return error substitute("Не найдены итоги по ДК &1 по продаже", p-d-card).
      end.
      assign
      v-h-action = integer({&hn-update})
      .
      setfields_from_bh ().
    end.
    return glog.
  end method.
  method private void setfields_from_bh ():
      assign
      gds-dis-base         = v_tbh:buffer-field("gds-dis-base"):buffer-value
      gds-dis-rubl         = v_tbh:buffer-field("gds-dis-rubl"):buffer-value
      gds-tot-base         = v_tbh:buffer-field("gds-tot-base"):buffer-value
      gds-tot-rubl         = v_tbh:buffer-field("gds-tot-rubl"):buffer-value
      gds-tot-b0           = v_tbh:buffer-field("gds-tot-b0"):buffer-value
      gds-tot-r0           = v_tbh:buffer-field("gds-tot-r0"):buffer-value
      pay-tot-base         = v_tbh:buffer-field("pay-tot-base"):buffer-value
      pay-tot-rubl         = v_tbh:buffer-field("pay-tot-rubl"):buffer-value
      num-chk              = v_tbh:buffer-field("num-chk"):buffer-value
      d-card               = v_tbh:buffer-field("d-card"):buffer-value
      sale-doc             = v_tbh:buffer-field("sale-doc"):buffer-value
      doc-date             = v_tbh:buffer-field("doc-date"):buffer-value
      base-code            = v_tbh:buffer-field("base-code"):buffer-value
      obj-code             = v_tbh:buffer-field("obj-code"):buffer-value
      obj-type             = v_tbh:buffer-field("obj-type"):buffer-value
      type                 = v_tbh:buffer-field("type"):buffer-value
      emitent-host-code    = v_tbh:buffer-field("emitent-host-code"):buffer-value
      cli-type             = v_tbh:buffer-field("cli-type"):buffer-value
      cli-code             = v_tbh:buffer-field("cli-code"):buffer-value
      sale-type            = v_tbh:buffer-field("sale-type"):buffer-value
      action               = v_tbh:buffer-field("action"):buffer-value
      .
  end.
  method public logical create_dis-card-sale_obj ( input p-d-card as character
                                             ,input p-obj-type as character
                                             ,input p-obj-code as integer
                                             ,input p-doc-code as character
                                             ,input p-doc-date as date
                                             ):
    define variable glog as logical no-undo .
    define buffer buf_clients for ub.clients.
    define buffer buf_dis-card for ub.dis-card.
    define buffer buf_sysconf for ub.sysconf.
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code no-error.
    if not available buf_clients
    or not (p-obj-type = {&shop} or p-obj-type = {&stock})
    then do:
      run set-error in v_gc (substitute("Неверно задан объект для создания итогов по ДК(ДК &1 &2&3)"
                                        , d-card
                                        , p-obj-type
                                        , p-obj-code)).
      return no.
    end.
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = buf_clients.host-code no-error.
    if not available buf_clients then do:
      run set-error in v_gc (substitute("Неверно задан объект для создания итогов по ДК - не найдена фирма &4(ДК &1 &2&3)"
                                        , d-card
                                        , p-obj-type
                                        , p-obj-code
                                        , buf_clients.host-code
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
        run set-error in v_gc (substitute("Неверно задана ДК для создания итогов по ДК(ДК &1 &2&3)"
                                        , d-card
                                        , p-obj-type
                                        , p-obj-code
                                          )).
        return no.
      end.
    end.
    do transaction :
      glog = v_tbh:buffer-create( ).
    end.
    assign
    d-card = p-d-card
    v-h-action = integer({&hn-create})
    host-code            = buf_clients.host-code
    base-code            = buf_sysconf.base-code
    obj-type             = p-obj-type
    obj-code             = p-obj-code
    sale-doc             = p-doc-code
    doc-date             = p-doc-date
    sale-type            = '':U
    v_tbh:buffer-field("d-card"):buffer-value = d-card
    v_tbh:buffer-field("host-code"):buffer-value = host-code
    v_tbh:buffer-field("base-code"):buffer-value = base-code
    v_tbh:buffer-field("obj-type"):buffer-value = obj-type
    v_tbh:buffer-field("obj-code"):buffer-value = obj-code
    v_tbh:buffer-field("sale-doc"):buffer-value = sale-doc
    v_tbh:buffer-field("doc-date"):buffer-value = doc-date
    v_tbh:buffer-field("sale-type"):buffer-value = sale-type
    gds-dis-base         = 0.0
    gds-dis-rubl         = 0.0
    gds-tot-base         = 0.0
    gds-tot-rubl         = 0.0
    gds-tot-b0           = 0.0
    gds-tot-r0           = 0.0
    pay-tot-base         = 0.0
    pay-tot-rubl         = 0.0
    num-chk              = 0
    action               = 0
    type                 = (if available buf_Dis-card
                            then buf_Dis-card.type
                            else '')
    emitent-host-code    = (if available buf_Dis-card
                            then buf_Dis-card.emitent-host-code
                            else 0)
    cli-type             = (if available buf_Dis-card
                            then buf_Dis-card.cli-type
                            else '')
    cli-code             = (if available buf_Dis-card
                            then buf_Dis-card.cli-code
                            else 0)
    v_tbh:buffer-field("emitent-host-code"):buffer-value = emitent-host-code
    v_tbh:buffer-field("type"):buffer-value = type
    v_tbh:buffer-field("cli-type"):buffer-value = cli-type
    v_tbh:buffer-field("cli-code"):buffer-value = cli-code
    .
    return yes.
  end method.
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    assign
    d-card = ''
    v-h-action = 0
    .
  end method.

  method public override character ToString( ):
    return substitute("&1 &2", d-card, sale-doc).
  end method.
method public logical esys-add-dump (
                                          input p-esys-cmd-proc-handle as handle
                                        , input p-esys-cmd-code as integer
                                        , input p-action as character     ):
  define variable v-esys-rec-ord as integer no-undo .
  run add-dump in p-esys-cmd-proc-handle
    (input p-esys-cmd-code
    ,input {&table_dis-host}
    ,input p-action
    ,input v_tbh
    ,input '':U
    ,output v-esys-rec-ord
    ) no-error .
  if error-status :error
  then do:
    delete procedure p-esys-cmd-proc-handle .
    run set-error in v_gc (substitute("Ошибка при добавлении записи &2 в команду с кодом &3&1&4&1&5"
                                        ,{&new-line}
                                        ,{&table_dis-host}
                                        ,p-esys-cmd-code
                                        ,error-status:get-message(1)
                                        ,return-value
                                        )) .
    return no.
  end.
  return yes.
end method.
end class.
