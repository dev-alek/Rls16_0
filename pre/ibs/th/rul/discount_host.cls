block-level on error undo, throw.
class Ibs.Th.Rul.Discount_host:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: discount_host.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_gc as handle no-undo.
  define protected variable v_cnt as widget-handle no-undo.
  define protected buffer buf_Discount_host for ub.dis-card-property.
  define protected temp-table t-Discount_host no-undo like ub.dis-card-property
  field recid_ as recid
  field h-n-action as integer
  field ordinal as integer
  field init-value-character as character
  field init-value-date as date
  field init-value-decimal as decimal
  field init-value-integer as integer
  field init-value-logical as logical
  field node-name as character
 .
  define protected buffer buft_Discount_host for t-Discount_host.
  define public variable v_bh as handle no-undo.
  define protected variable v_tbh as handle no-undo.
  define protected variable v_tcbh as handle no-undo .
  define public variable temp as integer no-undo.
  define public property lock as integer
  get.
  set.
  define public property wait as integer
  get.
  set.
  define private buffer buf_prop-map for ub.prop-map.
  define protected variable dtm-code as integer no-undo .
  define protected variable node-code# as integer no-undo .
  define protected variable dt-code as integer no-undo .
  define protected variable num-members as integer no-undo .
  define private variable v-error-flag as logical no-undo.
  define public variable card-num as integer no-undo .
  define public variable d-card as character no-undo .
  define public variable first-card as character no-undo .
  define public variable first-main-card as character no-undo .
  define public variable main-card as character no-undo .
  define public variable type# as character no-undo .
  define public variable emitent-host-code# as integer no-undo .
  define public variable host-code as integer no-undo .
  define public variable d-pcnt as decimal no-undo .
  define public variable cash-d-pcnt as decimal no-undo .
  define public variable category as integer no-undo .
  CONSTRUCTOR PUBLIC Discount_host(
                               input parparentproc as widget-handle
                              ,input p-parent-handle as handle
                              ,input p-log-handle as handle
                              ,input p-gc-handle as handle
                              ,input p-cont-handle as handle
                              ,input p-lock as integer
                              ,input p-wait as integer
                              ,input p-temp as integer
                              ,input p-dtm-code as integer
                            ):
define variable glog as logical no-undo .
assign
v_pp = parparentproc
v_lh = p-log-handle
v_ph = p-parent-handle
v_gc = p-gc-handle
v_cnt = p-cont-handle
lock = p-lock
wait = p-wait
temp = p-temp
.
run garbcoll_create-gc-entry in p-gc-handle (input 'Discount_host',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта Discount_host", vss-include-info0).
end.
v_bh = buffer buf_Discount_host:handle.
v_tbh = buffer buft_Discount_host:handle.
    if temp < 0 then do:
      run tempcont_get-buffer-handle in v_cnt ( input 'dis-card-property':U
                                                ,output v_tcbh).
    end.
    define buffer buf_prop-ref for ub.prop-ref.
    find first buf_prop-ref no-lock where
             buf_prop-ref.dtm-code = p-dtm-code no-error .
    if error-status:error then do:
       undo, return error substitute( "&1. Не найден срез &2 в справочнике итогов для ОБЪЕКТА СКИДКА-КАТЕГОРИЯ ПО ФИРМЕ-ОБЪЕКТУ&4"
                                       , vss-include-info0
                                       , chr(10)
                                       ).
    end.
    assign
    d-card = '':U
    dtm-code = p-dtm-code
    dt-code = buf_prop-ref.dt-code
    node-code# = 0
   .
    for each buf_prop-map  where buf_prop-map.dtm-code = p-dtm-code
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1))
    :
      create buft_Discount_host.
      assign
      buft_Discount_host.dtm-code = buf_prop-map.dtm-code
      buft_Discount_host.node-code = buf_prop-map.node-code
      buft_Discount_host.node-name = buf_prop-map.node-name
      buft_Discount_host.ordinal = buf_prop-map.ordinal
      buft_Discount_host.init-value-character = buf_prop-map.init-value-character
      buft_Discount_host.init-value-date      = buf_prop-map.init-value-date
      buft_Discount_host.init-value-decimal   = buf_prop-map.init-value-decimal
      buft_Discount_host.init-value-integer   = buf_prop-map.init-value-integer
      buft_Discount_host.init-value-logical   = buf_prop-map.init-value-logical
      num-members = num-members + 1
      .
    end.
  end constructor.
  destructor public Discount_host():
    define variable glog as logical no-undo .
    for each buft_Discount_host:
      delete buft_Discount_host.
    end.
    find_Discount_host ( input '':U
                       ,input host-code
                         ).
  end destructor.
  method public void Discount_hostrelease_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_Discount_host ( ):
    return v_bh.
  end method.
  method public logical set_Discount_host ( input p-bh as handle):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-copy ( p-bh).
    return glog.
  end method.
  method public logical Discount_hostsave ( ):
   define variable glog as logical no-undo .
   define variable v-tosave as logical no-undo .
   define buffer buf_dis-card for ub.dis-card.
    if d-card <> '':U then do:
        _save:
        for each buft_Discount_host
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1))
        :
          v-tosave = no.
          if buft_Discount_host.node-name = "d-pcnt"
          then do:
            if buft_Discount_host.init-value-decimal = d-pcnt then next _save.
            assign
            buft_Discount_host.property-value-decimal = d-pcnt
            .
          end.
          if buft_Discount_host.node-name = "cash-d-pcnt" then do:
            if buft_Discount_host.init-value-decimal = cash-d-pcnt then next _save.
            assign
            buft_Discount_host.property-value-decimal = cash-d-pcnt
            .
          end.
          if buft_Discount_host.node-name = "category" then do:
            if buft_Discount_host.init-value-integer = category then next _save.
            assign
            buft_Discount_host.property-value-integer = category
            .
          end.
          if buft_Discount_host.h-n-action = integer('2':U)
          or buft_Discount_host.h-n-action = integer('1':U)
          then do:
            if temp >= 0 then do:
              if buft_Discount_host.recid_ <> ? then do:
                find first buf_Discount_host exclusive-lock where
                    recid(buf_Discount_host) = buft_Discount_host.recid_.
                v-tosave = not (v_bh:buffer-compare(v_tbh)).
              end.
              else do:
                glog = v_bh:buffer-create().
                glog = v_bh:buffer-copy( v_tbh, "property-value-character,property-value-date,property-value-decimal,property-value-integer,property-value-logical").
                v-tosave = yes.
              end.
              if temp = 1 then do:
                run tempcont_create-changes in v_cnt (
                                               input 'dis-card-property':U
                                              ,input v_bh
                                              ,input v_tbh
                                              ,input buft_discount_host.h-n-action
                                              ) no-error.
                if error-status:error then do:
                  undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
                end.
              end.
              if v-tosave then do:
              run disproph_write-dis-card-property-rul in v_gc ( buffer buf_Discount_host
                                                      ,input type#
                                                      ,input emitent-host-code#
                                                      ,input 26
                                                      ,input buft_Discount_host.h-n-action) no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
              end.
              glog = v_bh:buffer-copy( v_tbh).
              run disproph_send-dis-card-property-rul in v_gc ( buffer buf_Discount_host
                                                      ,input type#
                                                      ,input emitent-host-code#
                                                        ,input 26
                                                      ,input buft_Discount_host.h-n-action) no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
              end.
              end.
            end.
            v_bh:buffer-field("trg-param"):buffer-value = 'no-callnews':U + chr(44) + 'no-hist':U.
            if temp >= 0
            and v-tosave then do:
              run cb_create-dc-list in v_ph ( input v_bh) no-error.
            end.
            glog = v_bh:buffer-release() no-error .
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
            if temp = -1 then do:
              run tempcont_create-changes in v_cnt (
                                              input 'dis-card-property':U
                                             ,input v_bh
                                             ,input v_tbh
                                             ,input buft_Discount_host.h-n-action) no-error.
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
              end.
            end.
            if temp = -2 then do:
              run tempcont_create-record in v_cnt (
                                              input 'dis-card-property':U
                                             ,input v_tbh
                                             ,input buft_discount_host.h-n-action) no-error.
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
              end.
            end.
          end.
        end.
    end.
    return yes.
  end method.
   method public logical find_Discount_host ( input p-d-card as character
                                             ,input p-host-code as integer
                                            ):
   define variable glog as logical no-undo .
   define variable v-jj as integer no-undo .
   define variable v-where as character no-undo .
   define buffer buf_dis-card for ub.dis-card.
   define buffer buf_sysconf for ub.sysconf.
    Discount_hostrelease_().
    clear_().
    if p-d-card <> '':U then do:
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card no-error.
      if not available buf_dis-card then do:
         return error substitute("Не найдена ДК &1", p-d-card).
      end.
      find first buf_sysconf no-lock where
                buf_sysconf.host-code = p-host-code no-error.
      if not available buf_sysconf then do:
        run set-error in v_gc (substitute("Неверно задан объект для создания свойства <Скидка по фирме> - не найдена фирма &2 (ДК &1)"
                                          , d-card
                                          , p-host-code
                                          )).
        return no.
      end.
      assign
      card-num                 = buf_dis-card.card-num
      d-card                   = buf_dis-card.d-card
      first-card               = buf_dis-card.first-card
      first-main-card          = buf_dis-card.first-main-card
      main-card                = buf_dis-card.main-card
      emitent-host-code#       = buf_dis-card.emitent-host-code
      type#                    = buf_dis-card.type
      host-code                = p-host-code
      .
      define variable v-ii as integer no-undo .
      _buft_dis-card-property:
      for each buft_Discount_host
      by buft_Discount_host.dt-code
      by buft_Discount_host.node-code
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1))
      :
        if temp < 0 then do:
          v-where =  substitute('where d-card = "&1" and host-code = &4 and obj-type = "" and obj-code = 0 and dt-code = &2 and node-code = &3'
                                , p-d-card
                                , dt-code
                                , buft_Discount_host.node-code
                                , p-host-code
                                ).
          assign
          glog = v_tcbh:find-first( v-where) no-error .
          if v_tcbh:available then do:
            glog = v_tbh:buffer-copy( v_tcbh).
            assign
            buft_discount_host.h-n-action             = integer('2':U)
            v-jj = v-jj + 1
            .
          end.
        end.
        if temp >= 0 or v_tcbh:available = no then do:
        assign
        buft_Discount_host.card-num                 = buf_dis-card.card-num
        buft_Discount_host.d-card                   = buf_dis-card.d-card
        buft_Discount_host.first-card               = buf_dis-card.first-card
        buft_Discount_host.first-main-card          = buf_dis-card.first-main-card
        buft_Discount_host.main-card                = buf_dis-card.main-card
        buft_Discount_host.recid_ = ?
        buft_Discount_host.h-n-action = 0
        buft_Discount_host.property-value-decimal   = buft_Discount_host.init-value-decimal
        buft_Discount_host.property-value-integer   = buft_Discount_host.init-value-integer
        buft_Discount_host.dt-code                  = dt-code
        buft_Discount_host.sum-id                   = 'Discount'
        buft_Discount_host.host-code                = p-host-code
        buft_Discount_host.obj-type                 = ''
        buft_Discount_host.obj-code                 = 0
        v-jj = v-jj + 1
        .
        v-where =  substitute('where d-card = "&1" and host-code = &4 and obj-type = "" and obj-code = 0 and dt-code = &2 and node-code = &3'
                                , p-d-card
                                , dt-code
                                , buft_Discount_host.node-code
                                , p-host-code
                                ).
        assign
        glog =  v_bh:find-first( v-where
                                , lock
                                , wait) no-error .
        if not glog then do:
          if wait = NO-WAIT
          and v_bh:locked then do:
            return error substitute("Запись свойств ДК &1 занята", p-d-card).
          end.
          assign
          buft_Discount_host.h-n-action = integer('1':U).
          if v-jj = num-members then leave _buft_dis-card-property.
          next _buft_dis-card-property.
        end.
        else do:
          assign
          buft_Discount_host.h-n-action = integer('2':U)
          .
        end.
        assign
        v-ii = v-ii + 1
        buft_Discount_host.recid_ = recid(buf_Discount_host)
        .
        glog = v_tbh:buffer-copy( v_bh).
        end.
        if buft_Discount_host.node-name = "d-pcnt" then do:
           assign
           d-pcnt = buft_Discount_host.property-value-decimal
           node-code#                = buft_Discount_host.node-code
           .
        end.
        if buft_Discount_host.node-name = "cash-d-pcnt" then do:
           assign
           cash-d-pcnt = buft_Discount_host.property-value-decimal
           node-code#                = buft_Discount_host.node-code
           .
        end.
        if buft_Discount_host.node-name = "category" then do:
           assign
           category = buft_Discount_host.property-value-integer
           node-code#                = buft_Discount_host.node-code
           .
        end.
        if v-jj = num-members then leave _buft_dis-card-property.
      end.
      if v-ii = 0 then do:
        return no.
      end.
    end.
    return yes.
  end method.
  method public logical create_Discount_host ( input p-d-card as character
                                             ,input p-host-code as integer
                                               ):
    define buffer buft2_ for t-Discount_host.
    for each buft2_ :
      if buft2_.recid_ = ?
      and buft2_.init-value-decimal <> 0.0
      then do:
        assign
        buft2_.h-n-action     = integer('1':U)
        .
      end.
      if buft2_.recid_ = ?
      and buft2_.init-value-integer <> 0
      then do:
        assign
        buft2_.h-n-action     = integer('1':U)
        .
      end.
    end.
    return yes.
  end method.
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    assign
    d-card = ''
    .
    for each buft_Discount_host:
      assign
      buft_Discount_host.card-num                 = 0
      buft_Discount_host.d-card                   = '':U
      buft_Discount_host.first-card               = '':U
      buft_Discount_host.first-main-card          = '':U
      buft_Discount_host.main-card                = '':U
      buft_Discount_host.recid_ = ?
      buft_Discount_host.h-n-action = 0
      buft_Discount_host.property-value-decimal = buft_Discount_host.init-value-decimal
      buft_Discount_host.property-value-integer = buft_Discount_host.init-value-integer
      buft_Discount_host.dt-code                 = 0
      buft_Discount_host.sum-id                  = '':U
      buft_Discount_host.obj-type                = '':U
      buft_Discount_host.obj-code                = 0
      buft_Discount_host.host-code                = 0
      .
    end.
  end method.
  method public override character ToString( ):
    return substitute("ДК &1 объект-операнд &2, фирма &3, свойство &4"
                      , d-card
                      , dtm-code
                      , host-code
                      , node-code#).
  end method.
end class.
