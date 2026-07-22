/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: discount_obj.cls $
$Archive: ibs/th/rul/discount_obj.cls $

Класс скидка по ДК с дифференциацией по объектам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/01/10
Author: Bakhtadze Natalya
Creation date: 11/01/10

*/

block-level on error undo, throw.
class Ibs.Th.Rul.discount_obj:
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: discount_obj.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_pp as widget-handle no-undo. /*parparentproc*/
  define protected variable v_ph as handle no-undo.        /*p-parent-handle*/
  define protected variable v_lh as widget-handle no-undo. /*p-log-handle*/
  define protected variable v_gc as handle no-undo.
  define protected variable v_cnt as widget-handle no-undo. /*p-cont-handle*/
  define protected buffer buf_discount_obj for ub.dis-card-property.
  define protected temp-table t-discount_obj no-undo like ub.dis-card-property
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
  define protected buffer buft_discount_obj for t-discount_obj.
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
  define public variable obj-type as character no-undo .
  define public variable obj-code as integer no-undo .
  define public variable d-pcnt as decimal no-undo .
  define public variable cash-d-pcnt as decimal no-undo .
  define public variable category as integer no-undo .
  CONSTRUCTOR PUBLIC discount_obj(
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
    { ibs/th/rul/cr-cls.i discount_obj  ~{&table_dis-card-property~} }
    if temp < 0 then do:
      run tempcont_get-buffer-handle in v_cnt ( input {&table_dis-card-property}
                                                ,output v_tcbh).
    end.
    define buffer buf_prop-ref for ub.prop-ref.
    find first buf_prop-ref no-lock where
             buf_prop-ref.dtm-code = p-dtm-code no-error .
    if error-status:error then do:
       undo, return error substitute( "&1. Не найден срез &2 в справочнике итогов для ОБЪЕКТА СКИДКА-КАТЕГОРИЯ ПО ФИРМЕ-ОБЪЕКТУ&4"
                                       , vss-include-info{&vssseq}
                                       , {&new-line}
                                       ).
    end.
    assign
    d-card = '':U
    dtm-code = p-dtm-code
    dt-code = buf_prop-ref.dt-code
    node-code# = 0
   .
    for each buf_prop-map  where buf_prop-map.dtm-code = p-dtm-code
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
    :
      create buft_discount_obj.
      assign
      buft_discount_obj.dtm-code = buf_prop-map.dtm-code
      buft_discount_obj.node-code = buf_prop-map.node-code
      buft_discount_obj.node-name = buf_prop-map.node-name
      buft_discount_obj.ordinal = buf_prop-map.ordinal
      buft_discount_obj.init-value-character = buf_prop-map.init-value-character
      buft_discount_obj.init-value-date      = buf_prop-map.init-value-date
      buft_discount_obj.init-value-decimal   = buf_prop-map.init-value-decimal
      buft_discount_obj.init-value-integer   = buf_prop-map.init-value-integer
      buft_discount_obj.init-value-logical   = buf_prop-map.init-value-logical
      num-members = num-members + 1
      .
    end.
  end constructor.
  destructor public discount_obj():
    define variable glog as logical no-undo .
    for each buft_discount_obj:
      delete buft_discount_obj.
    end.
    find_discount_obj ( input '':U
                       ,input obj-type
                       ,input obj-code
                         ).
  end destructor.
  method public void Discount_objrelease_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_discount_obj ( ):
    return v_bh.
  end method.
  method public logical set_discount_obj ( input p-bh as handle):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-copy ( p-bh).
    return glog.
  end method.
  method public logical discount_objsave ( ):
   define variable glog as logical no-undo .
   define variable v-tosave as logical no-undo .
   define buffer buf_dis-card for ub.dis-card.
    if d-card <> '':U then do:
        _save:
        for each buft_discount_obj
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
        :
          v-tosave = no.
          if buft_discount_obj.node-name = "d-pcnt"
          then do:
            if buft_discount_obj.init-value-decimal = d-pcnt then next _save.
            assign
            buft_discount_obj.property-value-decimal = d-pcnt
            .
          end.
          if buft_discount_obj.node-name = "cash-d-pcnt" then do:
            if buft_discount_obj.init-value-decimal = cash-d-pcnt then next _save.
            assign
            buft_discount_obj.property-value-decimal = cash-d-pcnt
            .
          end.
          if buft_discount_obj.node-name = "category" then do:
            if buft_discount_obj.init-value-integer = category then next _save.
            assign
            buft_discount_obj.property-value-integer = category
            .
          end.
          if buft_discount_obj.h-n-action = integer({&hn-update})
          or buft_discount_obj.h-n-action = integer({&hn-create})
          then do:
            if temp >= 0 then do:
              /*надо послать primary и с-*/
              if buft_discount_obj.recid_ <> ? then do:
                find first buf_discount_obj exclusive-lock where
                    recid(buf_discount_obj) = buft_discount_obj.recid_.
                v-tosave = not (v_bh:buffer-compare(v_tbh)).
              end.
              else do:
                glog = v_bh:buffer-create().
                glog = v_bh:buffer-copy( v_tbh, "property-value-character,property-value-date,property-value-decimal,property-value-integer,property-value-logical").
                v-tosave = yes.
              end.
              if temp = 1 then do:
                run tempcont_create-changes in v_cnt (
                                                input {&table_dis-card-property}
                                              ,input v_bh
                                              ,input v_tbh
                                              ,input buft_discount_obj.h-n-action
                                              ) no-error.
                if error-status:error then do:
                  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
                end.
              end.
              if v-tosave then do:
              run disproph_write-dis-card-property-rul in v_gc ( buffer buf_discount_obj
                                                      ,input type#
                                                      ,input emitent-host-code#
                                                      ,input 26 /*p-dtm-code*/
                                                      ,input buft_discount_obj.h-n-action) no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
              end.
              glog = v_bh:buffer-copy( v_tbh).
              run disproph_send-dis-card-property-rul in v_gc ( buffer buf_discount_obj
                                                      ,input type#
                                                      ,input emitent-host-code#
                                                        ,input 26 /*p-dtm-code*/
                                                      ,input buft_discount_obj.h-n-action) no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
              end.
              end.
            end. /*if temp >= 0 then do:*/
            v_bh:buffer-field("trg-param"):buffer-value = {&trg-param-no-callnews} + {&comma-char} + {&trg-param-no-hist}.
            if temp >= 0
            and v-tosave
            then do:
              run cb_create-dc-list in v_ph ( input v_bh) no-error.
            end.
            glog = v_bh:buffer-release() no-error .
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
            end.
            if temp = -1 then do:
              run tempcont_create-changes in v_cnt (
                                              input {&table_dis-card-property}
                                             ,input v_bh
                                             ,input v_tbh
                                             ,input buft_discount_obj.h-n-action) no-error.
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
              end.
            end.
            if temp = -2 then do:
              run tempcont_create-record in v_cnt (
                                              input {&table_dis-card-property}
                                             ,input v_tbh
                                             ,input buft_discount_obj.h-n-action) no-error.
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
              end.
            end. /*if temp < 0 then do:*/
          end. /*если изменилось*/
        end. /*      for each buft_dis-card-property*/
    end. /*if d-card <> '':U then do:*/
    return yes.
  end method.
   method public logical find_discount_obj ( input p-d-card as character
                                           , input p-obj-type as character
                                           , input p-obj-code as integer

                                            ):
   define variable glog as logical no-undo .
   define variable v-jj as integer no-undo .
   define variable v-where as character no-undo .
   define buffer buf_dis-card for ub.dis-card.
   define buffer buf_sysconf for ub.sysconf.
   define buffer buf_clients for ub.clients.
    discount_objrelease_().
    clear_().
    if p-d-card <> '':U then do:
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card no-error.
      if not available buf_dis-card then do:
         return error substitute("Не найдена ДК &1", p-d-card).
      end.
      find first buf_clients no-lock where
                buf_clients.obj-type = p-obj-type
            and buf_clients.obj-code = p-obj-code no-error.
      if not available buf_clients
      or not (p-obj-type = {&shop} or p-obj-type = {&stock})
      then do:
        run set-error in v_gc (substitute("Неверно задан объект для создания свойства <Скидка по объекту> (ДК &1 &2&3)"
                                          , d-card
                                          , p-obj-type
                                          , p-obj-code)).
        return no.
      end.
      find first buf_sysconf no-lock where
                buf_sysconf.host-code = buf_clients.host-code no-error.
      if not available buf_clients then do:
        run set-error in v_gc (substitute("Неверно задан объект для создания свойства <Скидка по объекту> - не найдена фирма &4(ДК &1 &2&3)"
                                          , d-card
                                          , p-obj-type
                                          , p-obj-code
                                          , buf_clients.host-code
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
      host-code                = buf_sysconf.host-code
      obj-type                 = p-obj-type
      obj-code                 = p-obj-code
      .
      define variable v-ii as integer no-undo .
      _buft_dis-card-property:
      for each buft_discount_obj
      by buft_discount_obj.dt-code
      by buft_discount_obj.node-code

      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
      :
        if temp < 0 then do:
          /*надо заполнить записью из контейнера*/
          /*запись сначала надо найти*/
          v-where =  substitute('where d-card = "&1" and host-code = &6 and obj-type = "&4" and obj-code = &5 and dt-code = &2 and node-code = &3'
                                , p-d-card
                                , dt-code
                                , buft_discount_obj.node-code
                                , p-obj-type
                                , p-obj-code
                                , buf_sysconf.host-code
                                ).
          assign
          glog = v_tcbh:find-first( v-where) no-error .
          if v_tcbh:available then do:
            glog = v_tbh:buffer-copy( v_tcbh).
            assign
            buft_discount_obj.h-n-action             = integer({&hn-update})
            v-jj = v-jj + 1
            .
          end.
        end.
        if temp >= 0 or v_tcbh:available = no then do:
        assign
        buft_discount_obj.card-num                 = buf_dis-card.card-num
        buft_discount_obj.d-card                   = buf_dis-card.d-card
        buft_discount_obj.first-card               = buf_dis-card.first-card
        buft_discount_obj.first-main-card          = buf_dis-card.first-main-card
        buft_discount_obj.main-card                = buf_dis-card.main-card
        buft_discount_obj.recid_ = ?
        buft_discount_obj.h-n-action = 0
        buft_discount_obj.property-value-decimal   = buft_discount_obj.init-value-decimal
        buft_discount_obj.property-value-integer   = buft_discount_obj.init-value-integer
        buft_discount_obj.dt-code                  = dt-code
        buft_discount_obj.sum-id                   = 'Discount'
        buft_discount_obj.host-code                = buf_sysconf.host-code
        buft_discount_obj.obj-type                 = p-obj-type
        buft_discount_obj.obj-code                 = p-obj-code
        v-jj = v-jj + 1
        .
        v-where =  substitute('where d-card = "&1" and host-code = &6 and obj-type = "&4" and obj-code = &5 and dt-code = &2 and node-code = &3'
                                , p-d-card
                                , dt-code
                                , buft_discount_obj.node-code
                                , p-obj-type
                                , p-obj-code
                                , buf_sysconf.host-code
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
          buft_discount_obj.h-n-action = integer({&hn-create}).
          if v-jj = num-members then leave _buft_dis-card-property.
          next _buft_dis-card-property.
        end.
        else do:
          assign
          buft_discount_obj.h-n-action = integer({&hn-update})
          .
        end.
        assign
        v-ii = v-ii + 1
        buft_discount_obj.recid_ = recid(buf_discount_obj)
        .
        glog = v_tbh:buffer-copy( v_bh).
        end. /*if temp >= 0 or v_tcbh:available = no then do:*/
        if buft_discount_obj.node-name = "d-pcnt" then do:
           assign
           d-pcnt = buft_discount_obj.property-value-decimal
           node-code#                = buft_discount_obj.node-code
           .
        end.
        if buft_discount_obj.node-name = "cash-d-pcnt" then do:
           assign
           cash-d-pcnt = buft_discount_obj.property-value-decimal
           node-code#                = buft_discount_obj.node-code
           .
        end.
        if buft_discount_obj.node-name = "category" then do:
           assign
           category = buft_discount_obj.property-value-integer
           node-code#                = buft_discount_obj.node-code
           .
        end.
        if v-jj = num-members then leave _buft_dis-card-property.
      end. /*for each buf_dis-card-property where*/
      if v-ii = 0 then do:
        /*нет ни одной записи и объекта нет*/
        return no.
      end.
    end. /*if p-d-card <> '':U then do:*/
    return yes.
  end method.
  method public logical create_discount_obj ( input p-d-card as character
                                             ,input p-obj-type as character
                                             ,input p-obj-code as integer
                                               ):
    define buffer buft2_ for t-discount_obj.
    for each buft2_ :
      if buft2_.recid_ = ?
      and buft2_.init-value-decimal <> 0.0
      then do:
        assign
        buft2_.h-n-action     = integer({&hn-create})
        .
      end.
      if buft2_.recid_ = ?
      and buft2_.init-value-integer <> 0
      then do:
        assign
        buft2_.h-n-action     = integer({&hn-create})
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
    for each buft_discount_obj:
      assign
      buft_discount_obj.card-num                 = 0
      buft_discount_obj.d-card                   = '':U
      buft_discount_obj.first-card               = '':U
      buft_discount_obj.first-main-card          = '':U
      buft_discount_obj.main-card                = '':U
      buft_discount_obj.recid_ = ?
      buft_discount_obj.h-n-action = 0
      buft_discount_obj.property-value-decimal = buft_discount_obj.init-value-decimal
      buft_discount_obj.property-value-integer = buft_discount_obj.init-value-integer
      buft_discount_obj.dt-code                 = 0
      buft_discount_obj.sum-id                  = '':U
      buft_discount_obj.obj-type                = '':U
      buft_discount_obj.obj-code                = 0
      buft_discount_obj.host-code                = 0
      .
    end.
  end method.
  method public override character ToString( ):
    return substitute("ДК &1 объект-операнд &2, фирма &3 &4&5, свойство &6"
                      , d-card
                      , dtm-code
                      , host-code
                      , obj-type
                      , obj-code
                      , node-code#).
  end method.
end class.
