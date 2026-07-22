/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-chk-doc_obj.cls $
$Archive: ibs/th/rul/dis-chk-doc_obj.cls $

Класс  Чек

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/01/08
Author: Bakhtadze Natalya
Creation date: 01/01/08

*/

block-level on error undo, throw.
class Ibs.Th.Rul.Dis-chk-doc_obj:
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: dis-chk-doc_obj.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_gc as handle no-undo.
  define protected variable v_ph as handle no-undo. /*p-parent-handle*/
  define protected variable v_pp as widget-handle no-undo. /*p-parent-proc*/
  define protected variable v_lh as widget-handle no-undo. /*p-log-handle*/
  define protected variable v_cnt as widget-handle no-undo. /*p-cont-handle*/
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
  { ibs/th/rul/crdrcall.i deftt }
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
   { ibs/th/rul/cr-cls.i dis-chk-doc_obj  ~{&table_chk-doc~} }
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
                               , {&new-line}
                               , error-status:get-message(1)
                               , p-prepare-phrase-doc
                               ).
    end.
    assign
    glog = v_qh:query-open no-error .
    if error-status:error then do:
      return error substitute("Ошибка открытия выборки по чекам:&1&2&1&3"
                               , {&new-line}
                               , error-status:get-message(1)
                               , v_qh:prepare-string ).
    end.
  end method.
  method public logical get_dis-chk-doc_obj( input p-rec-pos as character):
    define variable glog as logical no-undo .
    if not v_qh:is-open then do:
      return error substitute("Выборка по чекам:&1(&2)&1еще на открыта"
                              , {&new-line}
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
  { ibs/th/rul/crdrcall.i return-value-methods }
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
    ,input {&table_chk-doc}
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
                                        ,{&table_dis-card}
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
