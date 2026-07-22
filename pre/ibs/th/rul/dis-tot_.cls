block-level on error undo, throw.
class Ibs.Th.Rul.Dis-tot_:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: dis-tot_.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_gc as handle no-undo.
  define protected variable v_cnt as widget-handle no-undo.
  define protected buffer buf_dis-tot_ for ub.dis-host.
  define protected temp-table t-dis-tot_ no-undo like ub.dis-host.
  define protected buffer buft_dis-tot_ for t-dis-tot_.
  define public variable v_bh as handle no-undo.
  define protected variable v_tbh as handle no-undo.
  define protected variable v-byfm as logical no-undo .
  define protected variable v-bym as logical no-undo .
  define protected variable v-byf as logical no-undo .
  define private variable v-h-action as integer no-undo .
  define private variable v-error-flag as logical no-undo .
  define public variable temp as integer no-undo.
  define public property lock as integer
  get.
  set.
  define public property wait as integer
  get.
  set.
  define protected variable dtm-code as integer no-undo .
  define protected variable dt-code as integer no-undo .
  define protected variable caller_id as character no-undo .
  define public variable sum-id as character no-undo .
  define public variable card-num as integer no-undo .
  define public variable d-card as character no-undo .
  define public variable first-card as character no-undo .
  define public variable first-main-card as character no-undo .
  define public variable main-card as character no-undo .
  define public variable gds-dis-base as decimal no-undo .
  define public variable gds-dis-rubl as decimal no-undo .
  define public variable gds-tot-base as decimal no-undo .
  define public variable gds-tot-rubl as decimal no-undo .
  define public variable num-chk as integer      no-undo .
  define public variable pay-tot-base as decimal no-undo .
  define public variable pay-tot-rubl as decimal no-undo .
  define public property gds-dis-base_byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return gds-dis-base_byfm#.
  end get.
  private set.
  define public property gds-dis-rubl_Byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return gds-dis-rubl_byfm#.
  end get.
  private set.
  define public property gds-tot-base_Byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return gds-tot-base_byfm#.
  end get.
  private set.
  define public property gds-tot-rubl_Byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return gds-tot-rubl_byfm#.
  end get.
  private set.
  define public property num-chk_Byfm# as integer
  get():
    if not v-byfm then get-byfm().
    return num-chk_byfm#.
  end get.
  private set.
  define public property pay-tot-base_Byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return pay-tot-base_byfm#.
  end get.
  private set.
  define public property pay-tot-rubl_Byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return pay-tot-rubl_byfm#.
  end get.
  private set.
  define public property gds-dis-base_byf# as decimal
  get():
    if not v-byf then get-byf().
    return gds-dis-base_byf#.
  end get.
  private set.
  define public property gds-dis-rubl_byf# as decimal
  get():
    if not v-byf then get-byf().
    return gds-dis-rubl_byf#.
  end get.
  private set.
  define public property gds-tot-base_byf# as decimal
  get():
    if not v-byf then get-byf().
    return gds-tot-base_byf#.
  end get.
  private set.
  define public property gds-tot-rubl_byf# as decimal
  get():
    if not v-byf then get-byf().
    return gds-tot-rubl_byf#.
  end get.
  private set.
  define public property num-chk_byf# as integer
  get():
    if not v-byf then get-byf().
    return num-chk_byf#.
  end get.
  private set.
  define public property pay-tot-base_byf# as decimal
  get():
    if not v-byf then get-byf().
    return pay-tot-base_byf#.
  end get.
  private set.
  define public property pay-tot-rubl_byf# as decimal
  get():
    if not v-byf then get-byf().
    return pay-tot-rubl_byf#.
  end get.
  private set.
  define public property gds-dis-base_bym# as decimal
  get():
    if not v-bym then get-bym().
    return gds-dis-base_bym#.
  end get.
  private set.
  define public property gds-dis-rubl_bym# as decimal
  get():
    if not v-bym then get-bym().
    return gds-dis-rubl_bym#.
  end get.
  private set.
  define public property gds-tot-base_bym# as decimal
  get():
    if not v-bym then get-bym().
    return gds-tot-base_bym#.
  end get.
  private set.
  define public property gds-tot-rubl_bym# as decimal
  get():
    if not v-bym then get-bym().
    return gds-tot-rubl_bym#.
  end get.
  private set.
  define public property num-chk_bym# as integer
  get():
    if not v-bym then get-bym().
    return num-chk_bym#.
  end get.
  private set.
  define public property pay-tot-base_bym# as decimal
  get():
    if not v-bym then get-bym().
    return pay-tot-base_bym#.
  end get.
  private set.
  define public property pay-tot-rubl_bym# as decimal
  get():
    if not v-bym then get-bym().
    return pay-tot-rubl_bym#.
  end get.
  private set.
  define public property  type# as character
  get.
  private set.
  define public property  emitent-host-code# as integer
  get.
  private set.
  CONSTRUCTOR PUBLIC dis-tot_(
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
run garbcoll_create-gc-entry in p-gc-handle (input 'dis-tot_',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта dis-tot_", vss-include-info0).
end.
v_bh = buffer buf_dis-tot_:handle.
v_tbh = buffer buft_dis-tot_:handle.
    assign
    d-card = '':U
    dtm-code  = 1
    dt-code = 0
    caller_id = '':U
    .
  end constructor.
  CONSTRUCTOR PUBLIC dis-tot_(
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
run garbcoll_create-gc-entry in p-gc-handle (input 'dis-tot_',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта dis-tot_", vss-include-info0).
end.
v_bh = buffer buf_dis-tot_:handle.
v_tbh = buffer buft_dis-tot_:handle.
    d-card = '':U.
    dtm-code = p-dtm-code.
  end constructor.
  destructor public dis-tot_():
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    find_dis-tot_ ( input '':U).
  end destructor.
  method public void Dis-tot_release_ (  ):
    define variable glog as logical no-undo .
    do transaction :
      glog = v_bh:buffer-release() no-error .
    end.
    clear_().
  end method.
  method public handle get_dis-tot_ ( ):
    return v_bh.
  end method.
  method public logical set_dis-tot_ ( input p-bh as handle):
    define variable glog as logical no-undo .
    do transaction :
      glog = v_bh:buffer-copy ( p-bh).
    end.
    return glog.
  end method.
  method public character get_prev-sum-id( ):
    define buffer buf_prop-ref for ub.prop-ref.
    if sum-id = '':U then do:
       if dtm-code = 0 then do:
         return '':U.
       end.
       else do:
         return error substitute("(Еще)не задан объект-операнд - невозможно получить идентификатор предыдущего итога").
       end.
    end.
    find first buf_prop-ref no-lock where
              buf_prop-ref.dtm-code = dtm-code
          and buf_prop-ref.sum-id < sum-id
          and buf_prop-ref.caller_id = caller_id
          no-error.
    if not available buf_prop-ref then do:
      return chr(63).
    end.
    return buf_prop-ref.sum-id.
  end method.
  method public logical find_dis-tot_sum-id ( p-d-card as character
                                      , p-sum-id as character
                                      , p-caller-id as character
                                          ):
    define variable glog as logical no-undo .
    define buffer buf_prop-ref for ub.prop-ref.
     find first buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = dtm-code
            and buf_prop-ref.sum-id  = p-sum-id
            and buf_prop-ref.caller_id = p-caller-id
            no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден ИТОГ(СРЕЗ) c ID &2 (доп иден-р &3) в справочнике итогов&4" +
                                       "Код объекта-операнда &5"
                                       , vss-include-info0
                                       , p-sum-id
                                       , p-caller-id
                                       , chr(10)
                                       , dtm-code
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     sum-id = buf_prop-ref.sum-id.
     caller_id = buf_prop-ref.caller_id.
     glog = find_dis-tot_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
   end method.
  method public logical find_dis-tot_date ( p-d-card as character
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
            and buf_prop-ref.caller_id = p-caller-id use-index idtsum
            no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден Период для даты &2 в справочнике итогов&3"
                                       , vss-include-info0
                                       , string(p-date, "99/99/9999")
                                       , chr(10)
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     sum-id = buf_prop-ref.sum-id.
     caller_id = buf_prop-ref.caller_id.
     glog = find_dis-tot_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
   end method.
   method public logical dis-tot_save ( ):
   define variable glog as logical no-undo .
   define variable loc-action  as integer no-undo .
   define buffer buf_dis-card for ub.dis-card.
    if d-card <> '':U then do:
        assign
        buft_Dis-tot_.gds-dis-base  = gds-dis-base
        buft_Dis-tot_.gds-dis-rubl  = gds-dis-rubl
        buft_Dis-tot_.gds-tot-base  = gds-tot-base
        buft_Dis-tot_.gds-tot-rubl  = gds-tot-rubl
        buft_Dis-tot_.pay-tot-base  = pay-tot-base
        buft_Dis-tot_.pay-tot-rubl  = pay-tot-rubl
        buft_Dis-tot_.num-chk       = num-chk
        .
        glog = no.
        if v_bh:available then  do:
          glog = v_bh:buffer-compare(v_tbh).
        end.
        if not glog
        or v-h-action = integer('1':U)
        then do:
          if temp >= 0 then do:
            loc-action = v-h-action.
            if v-h-action = integer('1':U) then do:
              find first buf_Dis-card no-lock where
                        buf_Dis-card.d-card = d-card no-error.
              if not available buf_dis-card then do:
                undo, return error substitute( "&1. Не найдена ДК &2 при создании итога по ДК"
                                              , vss-include-info0
                                              , d-card
                                              ).
              end.
              assign
              type#                         = buf_dis-card.type
              emitent-host-code#            = buf_dis-card.emitent-host-code
              .
              do transaction :
                glog = v_tbh:buffer-copy( buffer buf_Dis-card:handle).
                glog = v_bh:buffer-create( ).
                glog = v_bh:buffer-copy( v_tbh).
              end.
              if dt-code = 0 then do:
                do transaction :
                  v_bh::whole-send-news = integer('-1':U).
                end.
              end.
              v-h-action = integer('2':U) .
            end.
            run dis-hsth_write-dis-host-rul in v_gc ( buffer buf_dis-tot_
                                                    ,input type#
                                                    ,input emitent-host-code#
                                                    ,input 1
                                                    ,input loc-action) no-error .
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
            do transaction :
              glog = v_bh:buffer-copy( v_tbh, "whole-send-news").
            end.
            run dis-hsth_send-dis-host-rul in v_gc ( buffer buf_dis-tot_
                                                    ,input type#
                                                    ,input emitent-host-code#
                                                    ,input 1
                                                    ,input loc-action) no-error .
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
            do transaction :
              v_bh::whole-send-news = integer('0':U).
            end.
          end.
          do transaction :
            glog = v_bh:buffer-release() no-error .
          end.
          if error-status:error then do:
            undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
          end.
          if temp < 0 then do:
            run tempcont_create-changes in v_cnt (
                                            input 'dis-host':U
                                           ,input v_bh
                                           ,input v_tbh
                                           ,input v-h-action
                                           ) no-error.
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
          end.
        end.
     end.
     return yes.
   end method.
   method public logical find_dis-tot_ ( p-d-card as character):
   define variable glog as logical no-undo .
   define buffer buf_dis-card for ub.dis-card.
    dis-tot_release_().
    clear_().
    if p-d-card <> '':U then do:
      v-h-action           = integer('2':U).
      do transaction :
        assign
        glog =  v_bh:find-first( substitute('where d-card = "&1" and host-code = 0 and dt-code = &2'
                                , p-d-card
                                , dt-code
                                )
                                , lock
                                , wait) no-error .
      end.
      if not glog then do:
        if wait = NO-WAIT
        and v_bh:locked then do:
          if v_tbh:available then do:
            do transaction :
              assign glog = v_tbh:buffer-delete() no-error .
            end.
          end.
          return error substitute("Запись глобальных итогов ДК &1 занята", p-d-card).
        end.
        if v_tbh:available then do:
          do transaction :
            assign glog = v_tbh:buffer-delete() no-error .
          end.
        end.
        return no.
      end.
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card no-error.
      if not available buf_dis-card then do:
         if v_tbh:available then do:
          do transaction :
             assign glog = v_tbh:buffer-delete() no-error .
           end.
         end.
         return error substitute("Не найдена ДК &1", p-d-card).
      end.
      assign
      v-h-action           = integer('2':U)
      card-num             = buf_dis-tot_.card-num
      gds-dis-base         = buf_dis-tot_.gds-dis-base
      gds-dis-rubl         = buf_dis-tot_.gds-dis-rubl
      gds-tot-base         = buf_dis-tot_.gds-tot-base
      gds-tot-rubl         = buf_dis-tot_.gds-tot-rubl
      pay-tot-base         = buf_dis-tot_.pay-tot-base
      pay-tot-rubl         = buf_dis-tot_.pay-tot-rubl
      num-chk              = buf_dis-tot_.num-chk
      d-card               = buf_dis-tot_.d-card
      first-card           = buf_dis-tot_.first-card
      first-main-card      = buf_dis-tot_.first-main-card
      main-card            = buf_dis-tot_.main-card
      v-byfm               = no
      v-bym                = no
      v-byf                = no
      emitent-host-code#   = buf_dis-card.emitent-host-code
      type#                = buf_dis-card.type
      .
      do transaction :
        glog = v_tbh:buffer-create( ).
        glog = v_tbh:buffer-copy( v_bh).
      end.
    end.
    return yes.
  end method.
  method public logical create_dis-tot_date ( input p-d-card as character
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
            and buf_prop-ref.caller_id = p-caller-id use-index idtsum
            no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден Период для даты &2 (доп.иден-р &3) в справочнике итогов&4"
                                       , vss-include-info0
                                       , string(p-date, "99/99/9999")
                                       , p-caller-id
                                       , chr(10)
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     caller_id = buf_prop-ref.caller_id.
     glog = create_dis-tot_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
  end.
  method public logical create_dis-tot_sum-id ( input p-d-card as character
                                             ,input p-sum-id as character
                                             ,input p-caller-id as character
                                          ):
    define variable glog as logical no-undo .
    define buffer buf_prop-ref for ub.prop-ref.
     find last buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = dtm-code
            and buf_prop-ref.sum-id   = p-sum-id
            and buf_prop-ref.caller_id = p-caller-id use-index idtsum
            no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден ИТОГ &2 (доп.иден-р &3) в справочнике итогов&4"
                                       , vss-include-info0
                                       , p-sum-id
                                       , p-caller-id
                                       , chr(10)
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     caller_id = buf_prop-ref.caller_id.
     glog = create_dis-tot_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
  end.
  method public logical create_dis-tot_ ( input p-d-card as character ):
    define variable glog as logical no-undo .
    define buffer buf_sysconf for ub.sysconf.
    define buffer buf_dis-card for ub.dis-card.
    find first buf_dis-card no-lock where
             buf_dis-card.d-card = p-d-card no-error.
    do transaction :
      glog = v_tbh:buffer-create().
    end.
    if not available buf_dis-card then do:
      glog = no.
      run can-find_dis-card_ in v_gc ( input p-d-card
                                      ,output glog) no-error .
      if not glog then do:
        run set-error in v_gc (substitute("Неверно задана ДК для создания итогов по ДК(ДК &1)"
                                        , d-card
                                          )).
        return no.
      end.
      assign
      d-card               = p-d-card
      buft_dis-tot_.d-card = p-d-card
      buft_dis-tot_.host-code = 0
      buft_dis-tot_.dt-code        = dt-code
      .
    end.
    else do:
      assign
      d-card               = p-d-card
      first-card           = buf_dis-card.first-card
      first-main-card      = buf_dis-card.first-main-card
      main-card            = buf_dis-card.main-card
      card-num             = buf_dis-card.card-num
      buft_dis-tot_.d-card = p-d-card
      buft_dis-tot_.host-code = 0
      buft_dis-tot_.first-card     = buf_dis-card.first-card
      buft_dis-tot_.first-main-card = buf_dis-card.first-main-card
      buft_dis-tot_.main-card      = buf_dis-card.main-card
      buft_dis-tot_.card-num       = buf_dis-card.card-num
      buft_dis-tot_.dt-code        = dt-code
      type#                        = buf_dis-card.type
      emitent-host-code#           = buf_dis-card.emitent-host-code
      .
    end.
    assign
    gds-dis-base         = 0.0
    gds-dis-rubl         = 0.0
    gds-tot-base         = 0.0
    gds-tot-rubl         = 0.0
    pay-tot-base         = 0.0
    pay-tot-rubl         = 0.0
    num-chk              = 0
    v-byfm = no
    v-bym = no
    v-byf = no
    v-h-action           = integer('1':U)
    .
    return yes.
  end method.
  method private void get-byfm():
    define variable v-dis-base as decimal no-undo.
    define variable v-dis-rubl as decimal no-undo.
    define variable v-tot-base as decimal no-undo.
    define variable v-tot-rubl as decimal no-undo.
    define variable v-pay-base as decimal no-undo.
    define variable v-pay-rubl as decimal no-undo.
    define variable v-num-chk as integer no-undo .
    define buffer buf_dis-host for ub.dis-host.
    if not v-byfm then do:
      for each buf_dis-host no-lock where
              buf_dis-host.first-main-card = first-main-card
           and buf_dis-host.host-code = 0
           and buf_dis-host.dt-code = dt-code:
        assign
        v-dis-base = v-dis-base + buf_dis-host.gds-dis-base
        v-dis-rubl = v-dis-rubl + buf_dis-host.gds-dis-rubl
        v-tot-base = v-tot-base + buf_dis-host.gds-tot-base
        v-tot-rubl = v-tot-rubl + buf_dis-host.gds-tot-rubl
        v-pay-base = v-pay-base + buf_dis-host.pay-tot-base
        v-pay-rubl = v-pay-rubl + buf_dis-host.pay-tot-rubl
        v-num-chk = v-num-chk + buf_dis-host.num-chk
        .
      end.
      assign
      gds-dis-base_byfm#  = v-dis-base
      gds-dis-rubl_byfm#  = v-dis-rubl
      gds-tot-base_byfm#  = v-tot-base
      gds-tot-rubl_byfm#  = v-tot-rubl
      pay-tot-base_byfm#  = v-pay-base
      pay-tot-rubl_byfm#  = v-pay-rubl
      num-chk_byfm#  = v-num-chk
      v-byfm = yes
      .
    end.
  end method.
  method private void get-bym():
    define variable v-dis-base as decimal no-undo.
    define variable v-dis-rubl as decimal no-undo.
    define variable v-tot-base as decimal no-undo.
    define variable v-tot-rubl as decimal no-undo.
    define variable v-pay-base as decimal no-undo.
    define variable v-pay-rubl as decimal no-undo.
    define variable v-num-chk as integer no-undo .
    define buffer buf_dis-host for ub.dis-host.
    if not v-bym then do:
      for each buf_dis-host no-lock where
              buf_dis-host.main-card = main-card
           and buf_dis-host.host-code = 0
           and buf_dis-host.dt-code = dt-code:
        assign
        v-dis-base = v-dis-base + buf_dis-host.gds-dis-base
        v-dis-rubl = v-dis-rubl + buf_dis-host.gds-dis-rubl
        v-tot-base = v-tot-base + buf_dis-host.gds-tot-base
        v-tot-rubl = v-tot-rubl + buf_dis-host.gds-tot-rubl
        v-pay-base = v-pay-base + buf_dis-host.pay-tot-base
        v-pay-rubl = v-pay-rubl + buf_dis-host.pay-tot-rubl
        v-num-chk = v-num-chk + buf_dis-host.num-chk
        .
      end.
      assign
      gds-dis-base_bym#  = v-dis-base
      gds-dis-rubl_bym#  = v-dis-rubl
      gds-tot-base_bym#  = v-tot-base
      gds-tot-rubl_bym#  = v-tot-rubl
      pay-tot-base_bym#  = v-pay-base
      pay-tot-rubl_bym#  = v-pay-rubl
      num-chk_bym#  = v-num-chk
      v-bym = yes
      .
    end.
  end method.
  method private void get-byf():
    define variable v-dis-base as decimal no-undo.
    define variable v-dis-rubl as decimal no-undo.
    define variable v-tot-base as decimal no-undo.
    define variable v-tot-rubl as decimal no-undo.
    define variable v-pay-base as decimal no-undo.
    define variable v-pay-rubl as decimal no-undo.
    define variable v-num-chk as integer no-undo .
    define buffer buf_dis-host for ub.dis-host.
    if not v-byf then do:
      for each buf_dis-host no-lock where
              buf_dis-host.first-card = first-card
           and buf_dis-host.host-code = 0
           and buf_dis-host.dt-code = dt-code:
        assign
        v-dis-base = v-dis-base + buf_dis-host.gds-dis-base
        v-dis-rubl = v-dis-rubl + buf_dis-host.gds-dis-rubl
        v-tot-base = v-tot-base + buf_dis-host.gds-tot-base
        v-tot-rubl = v-tot-rubl + buf_dis-host.gds-tot-rubl
        v-pay-base = v-pay-base + buf_dis-host.pay-tot-base
        v-pay-rubl = v-pay-rubl + buf_dis-host.pay-tot-rubl
        v-num-chk = v-num-chk + buf_dis-host.num-chk
        .
      end.
      assign
      gds-dis-base_byf#  = v-dis-base
      gds-dis-rubl_byf#  = v-dis-rubl
      gds-tot-base_byf#  = v-tot-base
      gds-tot-rubl_byf#  = v-tot-rubl
      pay-tot-base_byf#  = v-pay-base
      pay-tot-rubl_byf#  = v-pay-rubl
      num-chk_byf#  = v-num-chk
      v-byf = yes
      .
    end.
  end method.
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    if v_tbh:available then do:
      do transaction :
        glog = v_tbh:buffer-delete() no-error .
      end.
    end.
    assign
    d-card = ''
    v-h-action = 0
    .
  end method.
  method public override character ToString( ):
    return substitute("ДК &1 глобальный итог срез &2", d-card, dt-code ).
  end method.
end class.
