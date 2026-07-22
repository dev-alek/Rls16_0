block-level on error undo, throw.
class Ibs.Th.Rul.dis-card-property_:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: dis-card-property_.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_gc as handle no-undo.
  define protected variable v_cnt as widget-handle no-undo.
  define protected buffer buf_dis-card-property_ for ub.dis-card-property.
  define protected temp-table t-dis-card-property_ no-undo like ub.dis-card-property
  field recid_ as recid
  field h-n-action as integer
  field ordinal as integer
  field init-value-character as character
  field init-value-date as date
  field init-value-decimal as decimal
  field init-value-integer as integer
  field init-value-logical as logical
  .
  define protected buffer buft_dis-card-property_ for t-dis-card-property_.
  define public variable v_bh as handle no-undo.
  define protected variable v_tbh as handle no-undo.
  define private variable v-error-flag as logical no-undo .
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
  define protected variable sum-id as character no-undo .
  define protected variable num-members as integer no-undo .
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
  define protected variable property-value-character# as character no-undo .
  define protected variable property-value-date# as date no-undo .
  define protected variable property-value-decimal# as decimal no-undo .
  define protected variable property-value-integer# as integer no-undo .
  define protected variable property-value-logical# as logical no-undo .
  CONSTRUCTOR PUBLIC dis-card-property_(
                               input parparentproc as widget-handle
                              ,input p-parent-handle as handle
                              ,input p-log-handle as handle
                              ,input p-gc-handle as handle
                              ,input p-cont-handle as handle
                              ,input p-lock as integer
                              ,input p-wait as integer
                              ,input p-temp as integer
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
run garbcoll_create-gc-entry in p-gc-handle (input 'dis-card-property_',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта dis-card-property_", vss-include-info0).
end.
v_bh = buffer buf_dis-card-property_:handle.
v_tbh = buffer buft_dis-card-property_:handle.
    assign
    d-card = '':U
    dtm-code  = 0
    dt-code = 0
    node-code# = 0
    .
  end constructor.
  CONSTRUCTOR PUBLIC dis-card-property_(
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
run garbcoll_create-gc-entry in p-gc-handle (input 'dis-card-property_',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта dis-card-property_", vss-include-info0).
end.
v_bh = buffer buf_dis-card-property_:handle.
v_tbh = buffer buft_dis-card-property_:handle.
    d-card = '':U.
    dtm-code = p-dtm-code.
    for each buf_prop-map  where buf_prop-map.dtm-code = p-dtm-code
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1))
    :
      create buft_dis-card-property_.
      assign
      buft_Dis-card-property_.dtm-code = buf_prop-map.dtm-code
      buft_Dis-card-property_.node-code = buf_prop-map.node-code
      buft_Dis-card-property_.ordinal = buf_prop-map.ordinal
      buft_Dis-card-property_.init-value-character = buf_prop-map.init-value-character
      buft_Dis-card-property_.init-value-date      = buf_prop-map.init-value-date
      buft_Dis-card-property_.init-value-decimal   = buf_prop-map.init-value-decimal
      buft_Dis-card-property_.init-value-integer   = buf_prop-map.init-value-integer
      buft_Dis-card-property_.init-value-logical   = buf_prop-map.init-value-logical
      .
    end.
  end constructor.
  destructor public dis-card-property_():
    define variable glog as logical no-undo .
    for each buft_dis-card-property_:
      delete buft_dis-card-property_.
    end.
    find_dis-card-property_ ( input '':U).
  end destructor.
  method public void dis-card-property_release_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_dis-card-property_ ( ):
    return v_bh.
  end method.
  method public logical set_dis-card-property_ ( input p-bh as handle):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-copy ( p-bh).
    return glog.
  end method.
  method public logical find_dis-card-property_date ( p-d-card as character
                                      , p-date as date
                                      , p-caller-id as character
                                          ):
    define variable glog as logical no-undo .
    define variable v-date-char as character no-undo .
    define buffer buf_prop-ref for ub.prop-ref.
    assign
    v-date-char = string(year(p-date), "9999") + "/" +
                  string(month(p-date), "99") + "/" +
                  string(day(p-date), "99")
     v-date-char = v-date-char + "-" + v-date-char
     .
     find last buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = dtm-code
            and buf_prop-ref.sum-id <= v-date-char
            and buf_prop-ref.caller_id = p-caller-id use-index idtsum no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден Период для даты &2 в справочнике итогов&3"
                                       , vss-include-info0
                                       , string(p-date, "99/99/9999")
                                       , chr(10)
                                       ).
     end.
     assign
     dt-code = buf_prop-ref.dt-code
     sum-id = buf_prop-ref.sum-id
     .
     glog = find_dis-card-property_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return yes.
   end method.
   method public logical dis-card-property_save ( ):
   define variable glog as logical no-undo .
   define buffer buf_dis-card for ub.dis-card.
    if d-card <> '':U then do:
      for each buft_dis-card-property_
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1))
      :
        if v-error-flag then do:
          glog = v_bh:buffer-release() no-error .
        end.
        else do:
          if buft_dis-card-property_.h-n-action = integer('2':U)
          or buft_dis-card-property_.h-n-action = integer('1':U)
          then do:
            if temp >= 0 then do:
              if buft_dis-card-property_.recid_ <> ? then do:
                find first buf_dis-card-property_ exclusive-lock where
                    recid(buf_Dis-card-property_) = buft_dis-card-property_.recid_.
              end.
              else do:
                glog = v_bh:buffer-create().
              end.
              run disproph_write-dis-card-property-rul in v_gc ( buffer buf_dis-card-property_
                                                      ,input type#
                                                      ,input emitent-host-code#
                                                      ,input 1
                                                      ,input buft_dis-card-property_.h-n-action) no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
              end.
              glog = v_bh:buffer-copy( v_tbh).
              run disproph_send-dis-card-property-rul in v_gc ( buffer buf_dis-card-property_
                                                      ,input type#
                                                      ,input emitent-host-code#
                                                      ,input 1
                                                      ,input buft_dis-card-property_.h-n-action) no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
              end.
            end.
            v_bh:buffer-field("trg-param"):buffer-value = 'no-callnews':U + chr(44) + 'no-hist':U.
            glog = v_bh:buffer-release() no-error .
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
            if temp < 0 then do:
              run tempcont_create-changes in v_cnt (
                                              input 'dis-card-property':U
                                             ,input v_bh
                                             ,input v_tbh
                                             ,input buft_dis-card-property_.h-n-action) no-error.
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
              end.
            end.
          end.
        end.
      end.
      v-error-flag = no.
    end.
    return yes.
  end method.
   method public logical find_dis-card-property_ ( p-d-card as character):
   define variable glog as logical no-undo .
   define buffer buf_dis-card for ub.dis-card.
    dis-card-property_release_().
    clear_().
    if p-d-card <> '':U then do:
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card no-error.
      if not available buf_dis-card then do:
         return error substitute("Не найдена ДК &1", p-d-card).
      end.
      assign
      card-num                 = buf_dis-card-property_.card-num
      d-card                   = buf_dis-card-property_.d-card
      first-card               = buf_dis-card-property_.first-card
      first-main-card          = buf_dis-card-property_.first-main-card
      main-card                = buf_dis-card-property_.main-card
      emitent-host-code#       = buf_dis-card.emitent-host-code
      type#                    = buf_dis-card.type
      .
      define variable v-ii as integer no-undo .
      _buft_dis-card-property:
      for each buft_dis-card-property_
      on error undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1))
      :
        assign
        v-ii = v-ii + 1
        buft_dis-card-property_.recid_ = ?
        buft_dis-card-property_.d-card = '':U
        buft_dis-card-property_.main-card = '':U
        buft_dis-card-property_.first-main-card = '':U
        buft_dis-card-property_.first-card = '':U
        buft_dis-card-property_.card-num = 0
        buft_dis-card-property_.h-n-action = 0
        buft_dis-card-property_.property-value-character = buft_dis-card-property_.init-value-character
        buft_dis-card-property_.property-value-date      = buft_dis-card-property_.init-value-date
        buft_dis-card-property_.property-value-decimal = buft_dis-card-property_.init-value-decimal
        buft_dis-card-property_.property-value-integer = buft_dis-card-property_.init-value-integer
        buft_dis-card-property_.property-value-logical = buft_dis-card-property_.init-value-logical
        .
        assign
        glog =  v_bh:find-first( substitute('where d-card = "&1" and host-code = 0 and and obj-type = "" and obj-code = 0 and dt-code = &2 and node-code = &3'
                                , p-d-card
                                , dt-code
                                , buft_dis-card-property_.node-code
                                )
                                , lock
                                , wait) no-error .
        if not glog then do:
          if wait = NO-WAIT
          and v_bh:locked then do:
            return error substitute("Запись свойств ДК &1 занята", p-d-card).
          end.
          assign
          buft_dis-card-property_.h-n-action = integer('1':U).
          next _buft_dis-card-property.
        end.
        glog = v_tbh:buffer-copy( v_bh).
        if v-ii = 1 then do:
           assign
           property-value-character# = buft_dis-card-property_.property-value-character
           property-value-date#      = buft_dis-card-property_.property-value-date
           property-value-decimal#   = buft_dis-card-property_.property-value-decimal
           property-value-integer#   = buft_dis-card-property_.property-value-integer
           property-value-logical#   = buft_dis-card-property_.property-value-logical
           node-code#                = buft_dis-card-property_.node-code
           .
        end.
      end.
      if v-ii = 0 then do:
        return no.
      end.
    end.
    return yes.
  end method.
  method public logical create_dis-card-property_date ( input p-d-card as character
                                             ,input p-date as date
                                             ,input p-caller-id as character
                                          ):
    define variable glog as logical no-undo .
    define variable v-date-char as character no-undo .
    define buffer buf_prop-ref for ub.prop-ref.
    assign
    v-date-char = string(year(p-date), "9999") + "/" +
                  string(month(p-date), "99") + "/" +
                  string(day(p-date), "99")
     v-date-char = v-date-char + "-" + v-date-char
     .
     find last buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = dtm-code
            and buf_prop-ref.sum-id <= v-date-char
            and buf_prop-ref.caller_id = p-caller-id use-index idtsum no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден Период для даты &2 в справочнике итогов&3"
                                       , vss-include-info0
                                       , string(p-date, "99/99/9999")
                                       , chr(10)
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     glog = create_dis-card-property_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
  end.
  method public logical create_dis-card-property_ ( input p-d-card as character ):
    define buffer buft2_ for t-dis-card-property_.
    for each buft2_ :
      if buft2_.recid_ = ?
      and buft2_.init-value-character <> '':U
      then do:
        assign
        buft2_.h-n-action     = integer('1':U)
        .
      end.
      if buft2_.recid_ = ?
      and buft2_.init-value-date <> ?
      then do:
        assign
        buft2_.h-n-action     = integer('1':U)
        .
      end.
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
      if buft2_.recid_ = ?
      and buft2_.init-value-logical <> no
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
  end method.
  method public override character ToString( ):
    return substitute("ДК &1 объект-операнд &2, срез &2, свойство &4"
                      , d-card
                      , dtm-code
                      , dt-code
                      , node-code#).
  end method.
  method public character get-property-value-character ( input p-node-code as integer):
     if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       property-value-character# = buft_dis-card-property_.property-value-character
       node-code# = buft_dis-card-property_.node-code
       .
     end.
     return property-value-character#.
  end method.
  method public void set-property-value-character  ( input p-character as character, input p-node-code as integer):
    if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       node-code# = p-node-code.
    end.
    assign
    buft_dis-card-property_.property-value-character = p-character
    property-value-character# = p-character
    buft_dis-card-property_.h-n-action = (if buft_dis-card-property_.recid_ = ?
                                          then integer('1':U)
                                          else buft_dis-card-property_.h-n-action)
    .
  end method.
  method public date get-property-value-date ( input p-node-code as integer):
     if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       property-value-date# = buft_dis-card-property_.property-value-date
       node-code# = buft_dis-card-property_.node-code
       .
     end.
     return property-value-date#.
  end method.
  method public void set-property-value-date  ( input p-date as date, input p-node-code as integer):
    if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       node-code# = p-node-code.
    end.
    assign
    buft_dis-card-property_.property-value-date = p-date
    property-value-date# = p-date
    buft_dis-card-property_.h-n-action = (if buft_dis-card-property_.recid_ = ?
                                          then integer('1':U)
                                          else buft_dis-card-property_.h-n-action)
    .
  end method.
  method public decimal get-property-value-decimal ( input p-node-code as integer):
     if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       property-value-decimal# = buft_dis-card-property_.property-value-decimal
       node-code# = buft_dis-card-property_.node-code
       .
     end.
     return property-value-decimal#.
  end method.
  method public void set-property-value-decimal  ( input p-decimal as decimal, input p-node-code as integer):
    if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       node-code# = p-node-code.
    end.
    assign
    buft_dis-card-property_.property-value-decimal = p-decimal
    property-value-decimal# = p-decimal
    buft_dis-card-property_.h-n-action = (if buft_dis-card-property_.recid_ = ?
                                          then integer('1':U)
                                          else buft_dis-card-property_.h-n-action)
    .
  end method.
  method public integer get-property-value-integer ( input p-node-code as integer):
     if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       property-value-integer# = buft_dis-card-property_.property-value-integer
       node-code# = buft_dis-card-property_.node-code
       .
     end.
     return property-value-integer#.
  end method.
  method public void set-property-value-integer  ( input p-integer as integer, input p-node-code as integer):
    if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       node-code# = p-node-code.
    end.
    assign
    buft_dis-card-property_.property-value-integer = p-integer
    property-value-integer# = p-integer
    buft_dis-card-property_.h-n-action = (if buft_dis-card-property_.recid_ = ?
                                          then integer('1':U)
                                          else buft_dis-card-property_.h-n-action)
    .
  end method.
  method public logical get-property-value-logical ( input p-node-code as integer):
     if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       property-value-logical# = buft_dis-card-property_.property-value-logical
       node-code# = buft_dis-card-property_.node-code
       .
     end.
     return property-value-logical#.
  end method.
  method public void set-property-value-logical  ( input p-logical as logical, input p-node-code as integer):
    if p-node-code <> node-code# then do:
       find first buft_dis-card-property_ where
                 buft_dis-card-property_.dt-code = dt-code
             and buft_dis-card-property_.node-code = p-node-code.
       assign
       node-code# = p-node-code.
    end.
    assign
    buft_dis-card-property_.property-value-logical = p-logical
    property-value-logical# = p-logical
    buft_dis-card-property_.h-n-action = (if buft_dis-card-property_.recid_ = ?
                                          then integer('1':U)
                                          else buft_dis-card-property_.h-n-action)
    .
  end method.
end class.
