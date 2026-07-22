block-level on error undo, throw.
class Ibs.Th.Rul.Dis-chk-doc_obj:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: dis-chk-doc_obj.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_gc as handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_cnt as widget-handle no-undo.
  define protected variable v_qh as handle no-undo.
  define public variable v_bh as handle no-undo.
  define public variable v_bdh as handle no-undo.
  define public variable v_bbh as handle no-undo.
  define protected buffer buf_dis-chk-doc_obj for ub.chk-doc.
  define protected temp-table t-dis-chk-doc_obj no-undo like ub.chk-doc.
  define protected buffer buft_dis-chk-doc_obj for t-dis-chk-doc_obj.
  define protected buffer bufq_dis-chk-doc_obj for ub.chk-doc.
  define query query_dis-chk-doc_obj for bufq_dis-chk-doc_obj scrolling.
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
  define public variable d-card as character no-undo .
  define public variable discnt as decimal no-undo .
  define public variable tot-doc as decimal no-undo .
  define public variable netto as decimal no-undo .
  define public variable doc-qnty as decimal no-undo .
  define public variable chk-type as integer no-undo .
  define public variable obj-type  as character no-undo .
  define public variable obj-code as integer no-undo .
  define public variable base-rate as decimal no-undo .
  define public variable base-scale as integer no-undo .
  define public variable chk-date as date no-undo .
  define public variable chk-time as integer no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  CONSTRUCTOR PUBLIC dis-chk-doc_obj(
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
run garbcoll_create-gc-entry in p-gc-handle (input 'dis-chk-doc_obj',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта dis-chk-doc_obj", vss-include-info0).
end.
v_bh = buffer buf_dis-chk-doc_obj:handle.
v_tbh = buffer buft_dis-chk-doc_obj:handle.
    doc-code = '':U .
    v_qh = query query_dis-chk-doc_obj:handle.
    v_bdh = buffer buf_dis-chk-doc_obj:handle.
    v_tbh = buffer buft_dis-chk-doc_obj:handle.
  end constructor.
  destructor public dis-chk-doc_obj():
    define buffer buf_temp-call-param for temp-call-param.
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    find_dis-chk-doc_obj ( input '':U).
    for each buf_temp-call-param:
      if buf_temp-call-param.param-number = 0 then do:
        delete object buf_temp-call-param.call-handle_.
      end.
      delete buf_temp-call-param.
    end.
  end destructor.
  method public logical find_dis-chk-doc_obj ( p-doc-code as character):
   define variable glog as logical no-undo .
   dis-chk-doc_objrelease_().
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
          return error substitute("Не найден чек &1", p-doc-code).
        end.
        if wait = NO-WAIT
        and v_bh:locked then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("чек &1 занята", p-doc-code).
          end.
        end.
      end.
      if p-doc-code <> doc-code then do:
        assign
        glog =  v_bdh:find-first( substitute('where doc-code = "&1"'
                                            , p-doc-code
                                            ), lock, wait) no-error .
        if not glog then do:
          return error substitute("Не найден чек &1", p-doc-code).
        end.
      end.
      assign
      doc-code             = buf_dis-chk-doc_obj.doc-code
      d-card               = buf_dis-chk-doc_obj.d-card
      discnt               = buf_dis-chk-doc_obj.discnt
      doc-qnty             = buf_dis-chk-doc_obj.doc-qnty
      chk-type             = buf_dis-chk-doc_obj.chk-type
      obj-type             = buf_dis-chk-doc_obj.obj-type
      obj-code             = buf_dis-chk-doc_obj.obj-code
      base-rate            = buf_dis-chk-doc_obj.base-rate
      base-scale           = 1
      chk-date             = buf_dis-chk-doc_obj.chk-date
      chk-time             = buf_dis-chk-doc_obj.chk-time
      .
      glog = v_tbh:buffer-create( ).
      glog = v_tbh:buffer-copy( v_bh).
    end.
    return yes.
  end method.
  method public logical select_dis-chk-doc_obj ( input p-prepare-phrase-doc as character
                                               ):
    define variable glog as logical no-undo.
    assign
    glog = v_qh:query-prepare( substitute("for each bufq_dis-chk-doc_obj no-lock where &1 "
                             ,p-prepare-phrase-doc
                             )
                             ) no-error .
    if not glog then do:
      return error substitute("Ошибка подготовки выборки по чекам:&1&2&1&3"
                               , chr(10)
                               , error-status:get-message(1)
                               , p-prepare-phrase-doc
                               ).
    end.
    assign
    glog = v_qh:query-open no-error .
    if error-status:error then do:
      return error substitute("Ошибка открытия выборки по чекам:&1&2&1&3"
                               , chr(10)
                               , error-status:get-message(1)
                               , v_qh:prepare-string ).
    end.
  end method.
  method public logical get_dis-chk-doc_obj( input p-rec-pos as character):
    define variable glog as logical no-undo .
    if not v_qh:is-open then do:
      return error substitute("Выборка по чекам:&1(&2)&1еще на открыта"
                              , chr(10)
                              , v_qh:prepare-string
                               ).
    end.
    case p-rec-pos:
      when "first" then do:
        glog = v_qh:get-first(lock, wait)  .
      end.
      when "last" then do:
        glog = v_qh:get-last(lock, wait)  .
      end.
      when "next" then do:
        glog = v_qh:get-next(lock, wait)  .
      end.
      when "prev" then do:
        glog = v_qh:get-prev(lock, wait)  .
      end.
    end case.
    if glog then do:
       assign
       glog = find_dis-chk-doc_obj ( input bufq_dis-chk-doc_obj.doc-code) no-error .
    end.
    return glog.
  end method.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  method public decimal get_dis-rule-value_decimal ( input p-param-name as character):
    define buffer buf_temp-call-param for temp-call-param.
    find first buf_temp-call-param where
              buf_temp-call-param.param-name_ = p-param-name
          and buf_temp-call-param.call-name_ = v-last-call-name no-error .
    if not available buf_temp-call-param then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - отсутствуют"
                                   ,vss-include-info2
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info2
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
                                   ,vss-include-info2
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info2
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
                                   ,vss-include-info2
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info2
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
    chk-type = 0
    base-rate = 0
    base-scale = 0
    .
  end method.
  method public void Dis-chk-doc_objrelease_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    glog = v_bdh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_dis-chk-doc_obj ( ):
    return v_bh.
  end method.
method public logical esys-add-dump (
                                          input p-esys-cmd-proc-handle as handle
                                        , input p-esys-cmd-code as integer
                                        , input p-action as character     ):
  define variable v-esys-rec-ord as integer no-undo .
  run add-dump in p-esys-cmd-proc-handle
    (input p-esys-cmd-code
    ,input 'chk-doc':U
    ,input p-action
    ,input v_tbh
    ,input '':U
    ,output v-esys-rec-ord
    ) no-error .
  if error-status :error
  then do:
    delete procedure p-esys-cmd-proc-handle .
    run set-error in v_gc (substitute("Ошибка при добавлении записи &2 в команду с кодом &3&1&4&1&5"
                                        ,chr(10)
                                        ,'dis-card':U
                                        ,p-esys-cmd-code
                                        ,error-status:get-message(1)
                                        ,return-value
                                        )) .
    return no.
  end.
  return yes.
end method.
  method public override character ToString( ):
    return substitute("Чек &1", doc-code).
  end method.
end class.
