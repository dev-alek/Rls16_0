block-level on error undo, throw.
class Ibs.Th.Rul.trn-doc_obj:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: trn-doc_obj.cls $ $Revision: aea5316774be, 0, rls $".
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
  define public variable v_bdh as handle no-undo.
  define public variable v_bbh as handle no-undo.
  define public variable v_bgh as handle no-undo.
  define protected buffer buf_trn-doc_obj for ub.trn-doc.
  define protected temp-table t-trn-doc_obj no-undo like ub.trn-doc.
  define protected buffer buft_trn-doc_obj for t-trn-doc_obj.
  define public variable v_tbh as handle no-undo.
  define private variable v-h-action as integer no-undo .
  define public variable temp as integer no-undo.
  define public property lock as integer
  get.
  set.
  define public property wait as integer
  get.
  set.
  define protected variable release-flag as logical no-undo .
  define private variable v-error-flag as logical no-undo .
  define protected variable find_no-error as logical no-undo .
  define public variable doc-code as character no-undo .
  define public variable d-card# as character no-undo .
  define public variable cli-type as character no-undo .
  define public variable cli-code as integer no-undo .
  define public variable tot-calc as decimal no-undo .
  define public variable tot-doc as decimal no-undo .
  define public variable discnt-rubl as decimal no-undo .
  define public variable tot-rubl as decimal no-undo .
  define public variable obj-type as character no-undo .
  define public variable obj-code as integer no-undo .
  define public variable base-rate as decimal no-undo .
  define public variable base-scale as decimal no-undo .
  define public variable doc-date as date no-undo .
  define public variable doc-time# as integer no-undo .
  define public variable discnt-pc as decimal no-undo .
  define public variable print-rubl as logical no-undo .
  define protected variable v-curr-r-b as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define protected temp-table temp-call-param no-undo
field call-number as integer
field call-name_ as character
field param-name_ as character
field param-label_ as character
field num-params_ as integer
field call-handle_ as handle
field param-number_ as integer
field param-datatype_ as character
field io-mode_ as character
field character_ as character
field date_ as date
field decimal_ as decimal
field integer_ as integer
field logical_ as logical
index pi is unique primary call-name_ param-number_.
define protected variable v-last-call-name as character no-undo .
define protected variable v-last-call-number as int64 no-undo .
  CONSTRUCTOR PUBLIC trn-doc_obj(
                               input parparentproc as widget-handle
                              ,input p-parent-handle as handle
                              ,input p-log-handle as handle
                              ,input p-gc-handle as handle
                              ,input p-cont-handle as handle
                              ,input p-lock as integer
                              ,input p-wait as integer
                              ,input p-temp as integer
                              ,input p-codex-id as integer
                              ,input p-ruleset-id as integer
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
run garbcoll_create-gc-entry in p-gc-handle (input 'trn-doc_obj',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 ќшибка создани€ объекта trn-doc_obj", vss-include-info0).
end.
v_bh = buffer buf_trn-doc_obj:handle.
v_tbh = buffer buft_trn-doc_obj:handle.
    assign
    doc-code = '':U
    .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run library-cls_get-handle in v_gc ( input "library", output g#library) no-error.   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  end constructor.
  destructor public trn-doc_obj():
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    find_trn-doc_obj ( input '':U).
  end destructor.
  method public logical find_trn-doc_obj ( input p-doc-code as character
                                         ,input-output p-cycle-id as integer
                                         ):
  define variable glog as logical no-undo .
    p-cycle-id = p-cycle-id + 1.
    if p-cycle-id > 1 then do:
      return yes.
    end.
    glog = find_trn-doc_obj ( input p-doc-code) no-error.
    return glog.
  end.
  method public logical find_trn-doc_obj ( p-doc-code as character
                                         ):
   define variable glog as logical no-undo .
   trn-doc_objrelease_().
   clear_().
    if p-doc-code <> '':U then do:
      assign
      glog =  v_bh:find-first( substitute('where doc-code = "&1" '
                                          , p-doc-code
                                          ), lock, wait) no-error .
      if not glog then do:
        if find_no-error then do:
          return no.
        end.
        if lock = No-LOCK then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          return error substitute("Ќе найдена накладна€ &1"
                                 , p-doc-code
                                 ).
        end.
        if wait = NO-WAIT
        and v_bh:locked then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("накладна€ &1 зан€та"
                                   , p-doc-code
                                   ).
          end.
        end.
      end.
      if p-doc-code <> doc-code then do:
        assign
        glog =  v_bdh:find-first( substitute('where doc-code = "&1"'
                                            , p-doc-code
                                            ), lock, wait) no-error .
        if not glog then do:
          return error substitute("Ќе найдена накладна€ &1", p-doc-code).
        end.
      end.
      assign
      doc-code             = buf_trn-doc_obj.doc-code
      d-card#              = buf_trn-doc_obj.d-card
      cli-type             = buf_trn-doc_obj.cli-type
      cli-code             = buf_trn-doc_obj.cli-code
      tot-calc             = buf_trn-doc_obj.tot-calc
      discnt-rubl          = buf_trn-doc_obj.discnt-rubl
      tot-rubl             = buf_trn-doc_obj.tot-rubl
      tot-doc              = buf_trn-doc_obj.tot-doc
      print-rubl           = buf_trn-doc_obj.print-rubl
      obj-type             = buf_trn-doc_obj.obj-type
      obj-code             = buf_trn-doc_obj.obj-code
      base-rate            = buf_trn-doc_obj.base-rate
      base-scale           = buf_trn-doc_obj.base-scale
      discnt-pc            = buf_trn-doc_obj.discnt-pc
      .
      glog = v_tbh:buffer-create( ).
      glog = v_tbh:buffer-copy( v_bh).
    end.
    return yes.
  end method.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  method public decimal get_dis-rule-value_decimal ( input p-param-name as character):
    define buffer buf_temp-call-param for temp-call-param.
    find first buf_temp-call-param where
              buf_temp-call-param.param-name_ = p-param-name
          and buf_temp-call-param.call-name_ = v-last-call-name no-error .
    if not available buf_temp-call-param then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - отсутствуют"
                                   ,vss-include-info4
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info4
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    return buf_temp-call-param.decimal_.
  end method.
  method public integer get_dis-rule-value_integer ( input p-param-name as character):
    define buffer buf_temp-call-param for temp-call-param.
    find first buf_temp-call-param where
              buf_temp-call-param.param-name_ = p-param-name
          and buf_temp-call-param.call-name_ = v-last-call-name no-error .
    if not available buf_temp-call-param then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - отсутствуют"
                                   ,vss-include-info4
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info4
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    return buf_temp-call-param.integer_.
  end method.
  method public logical get_dis-rule-value_logical ( input p-param-name as character):
    define buffer buf_temp-call-param for temp-call-param.
    find first buf_temp-call-param where
              buf_temp-call-param.param-name_ = p-param-name
          and buf_temp-call-param.call-name_ = v-last-call-name no-error .
    if not available buf_temp-call-param then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - отсутствуют"
                                   ,vss-include-info4
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info4
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    return buf_temp-call-param.logical_.
  end method.
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    if v_tbh:available then
    glog = v_tbh:buffer-delete() no-error .
    assign
    doc-code = ''
    .
  end method.
  method public void trn-doc_objrelease_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_trn-doc_obj ( ):
    return v_bh.
  end method.
  method public override character ToString( ):
    return substitute("Ќакладна€ &1"
                      , doc-code
                      ).
  end method.
end class.
