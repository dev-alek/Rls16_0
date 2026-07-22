block-level on error undo, throw.
class Ibs.Th.Rul.dis-card-type_:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: dis-card-type_.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_gc as handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_cnt as widget-handle no-undo.
  define protected variable v_qh as handle no-undo.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define protected variable g#library  as handle no-undo .
define protected variable g#library2 as handle no-undo .
define protected variable g#attr-lib as handle no-undo .
  define public variable v_bh as handle no-undo.
  define private variable v-error-flag as logical no-undo .
  define protected buffer buf_dis-card-type_ for ub.dis-card-type.
  define protected temp-table t-dis-card-type_ no-undo like ub.dis-card-type.
  define protected buffer buft_dis-card-type_ for t-dis-card-type_.
  define protected buffer bufq_dis-card-type_ for ub.dis-card-type.
  define public variable v_tbh as handle no-undo.
  define private variable v-h-action as integer no-undo .
  define public variable temp as integer no-undo.
  define public variable v-curr-obj-type as character no-undo .
  define public variable v-curr-obj-code as integer no-undo .
  define public property lock as integer
  get.
  set.
  define public property wait as integer
  get.
  set.
  define protected variable release-flag as logical no-undo .
  define protected variable find_no-error as logical no-undo .
  define public variable cardname-sent as character no-undo .
  define public variable card-media as integer no-undo .
  define public variable check-by-mask as integer no-undo .
  define public variable dc-pfx as character no-undo .
  define public variable d-pcnt-byshop as logical no-undo .
  define public variable dcbyshop as character no-undo .
  define public variable dflt-cash-pcnt# as decimal no-undo .
  define public variable dflt-pcnt-kat# as integer no-undo .
  define public variable dflt-pcnt-katd# as decimal no-undo .
  define public variable dflt-credit-card as logical no-undo .
  define public variable dflt-d-pcnt-method as integer no-undo .
  define public variable dflt-pcnt# as decimal no-undo .
  define public variable dflt-debet-card as logical no-undo .
  define public variable fiscal-pay  as logical no-undo .
  define public variable ho-join as integer no-undo .
  define public variable emitent-host-code as integer no-undo .
  define public variable lim-kr as decimal no-undo .
  define public variable mixed-pay as logical no-undo .
  define public variable pay-code as integer no-undo .
  define public variable overissue-num as integer no-undo .
  define public variable dflt-staff-card as logical no-undo .
  define public variable type as character no-undo .
  CONSTRUCTOR PUBLIC dis-card-type_(
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
run garbcoll_create-gc-entry in p-gc-handle (input 'dis-card-type_',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта dis-card-type_", vss-include-info0).
end.
v_bh = buffer buf_dis-card-type_:handle.
v_tbh = buffer buft_dis-card-type_:handle.
    emitent-host-code = 0.
    type = '':U .
  end constructor.
  destructor public dis-card-type_():
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    find_dis-card-type_ ( input 0, input '':U).
  end destructor.
  method public void dis-card-type_release_ ( input p-error-flag as logical ):
  define variable glog as logical no-undo .
    v-error-flag = p-error-flag.
    release-flag = yes.
    glog = find_dis-card-type_ ( input 0, input '':U) no-error .
    if error-status:error
    or not glog then do:
      return error return-value .
    end.
  end method.
  method public void Dis-card-type_release_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_dis-card-type_ ( ):
    return v_bh.
  end method.
  method public logical find_dis-card-type_no-error ( p-emitent-host-code as integer, p-type as character):
    define variable glog as logical no-undo .
    assign
    find_no-error = yes.
    glog = find_dis-card-type_ ( input p-emitent-host-code, input p-type) no-error .
    if error-status:error then do:
      return error .
    end.
    return glog.
  end method.
  method public logical find_dis-card-type_ ( p-emitent-host-code as integer, p-type as character):
   define variable glog as logical no-undo .
    dis-card-type_release_().
    clear_().
    if p-type <> '':U then do:
      assign
      glog =  v_bh:find-first( substitute('where emitent-host-code = &1 and type = "&2"', p-emitent-host-code, p-type), lock, wait) no-error .
      if not glog then do:
        if lock = No-LOCK then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("Не найден тип ДК: эмитент &1 тип &2", p-emitent-host-code, p-type).
          end.
        end.
        if wait = NO-WAIT
        and v_bh:locked then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("тип ДК занят: эмитент &1 тип &2", p-emitent-host-code, p-type).
          end.
        end.
      end.
      assign
      emitent-host-code    = buf_dis-card-type_.emitent-host-code
      type                 = buf_dis-card-type_.type
      cardname-sent        = buf_dis-card-type_.cardname-sent
      card-media           = buf_dis-card-type_.card-media
      check-by-mask        = buf_dis-card-type_.check-by-mask
      dc-pfx               = buf_dis-card-type_.dc-pfx
      d-pcnt-byshop        = buf_dis-card-type_.d-pcnt-byshop
      dcbyshop             = buf_dis-card-type_.dcbyshop
      dflt-credit-card     = buf_dis-card-type_.dflt-credit-card
      dflt-d-pcnt-method   = buf_dis-card-type_.dflt-d-pcnt-method
      dflt-debet-card      = buf_dis-card-type_.dflt-debet-card
      fiscal-pay           = buf_dis-card-type_.fiscal-pay
      ho-join              = buf_dis-card-type_.ho-join
      lim-kr               = buf_dis-card-type_.lim-kr
      mixed-pay            = buf_dis-card-type_.mixed-pay
      pay-code             = buf_dis-card-type_.pay-code
      dflt-staff-card      = buf_dis-card-type_.dflt-staff-card
      .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run library-cls_get-handle in v_gc ( input "library", output g#library) no-error.   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type_.type
  ,input  buf_dis-card-type_.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output dflt-pcnt#
  )  .
       if dflt-pcnt# = ? then dflt-pcnt# = 0.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run library-cls_get-handle in v_gc ( input "library", output g#library) no-error.   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type_.type
  ,input  buf_dis-card-type_.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output dflt-cash-pcnt#
  )  .
      if dflt-cash-pcnt# = ? then dflt-cash-pcnt# = 0.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run library-cls_get-handle in v_gc ( input "library", output g#library) no-error.   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type_.type
  ,input  buf_dis-card-type_.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-categ':U
  ,output dflt-pcnt-katd#
  )  .
      if dflt-pcnt-katd# = ? then dflt-pcnt-katd# = 0.
      dflt-pcnt-kat# = dflt-pcnt-katd#.
      glog = v_tbh:buffer-copy( v_bh).
    end.
    return yes.
  end method.
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    if v_tbh:available then
    glog = v_tbh:buffer-delete() no-error .
    assign
    type = ''
    v-h-action = 0
    .
  end method.
  method public override character ToString( ):
    return substitute("Тип ДК: эмитент &1, тип &2", emitent-host-code, type).
  end method.
end class.
