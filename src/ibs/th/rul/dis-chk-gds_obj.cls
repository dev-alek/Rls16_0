/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-chk-gds_obj.cls $
$Archive: ibs/th/rul/dis-chk-gds_obj.cls $

Класс  Строка чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/28/07
Author: Bakhtadze Natalya
Creation date: 01/28/07

*/

block-level on error undo, throw.
class Ibs.Th.Rul.Dis-chk-gds_obj:
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: dis-chk-gds_obj.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_gc as handle no-undo.
  define protected variable v_ph as handle no-undo. /*p-parent-handle*/
  define protected variable v_pp as widget-handle no-undo. /*p-parent-proc*/
  define protected variable v_lh as widget-handle no-undo. /*p-log-handle*/
  define protected variable v_cnt as widget-handle no-undo. /*p-cont-handle*/
  define protected variable v_qh as handle no-undo.
  define public variable v_bh as handle no-undo.
  define public variable v_bdh as handle no-undo.
  define public variable v_bbh as handle no-undo.
  define protected buffer buf_dis-chk-gds_obj for ub.chk-gds.
  define protected buffer buf_dis-chk-doc_obj for ub.chk-doc.
  define protected buffer buf_bar-code_ for ub.bar-code.
  define protected temp-table t-dis-chk-gds_obj no-undo like ub.chk-gds.
  define protected buffer buft_dis-chk-gds_obj for t-dis-chk-gds_obj.
  define protected temp-table t-dis-chk-doc_obj no-undo like ub.chk-doc.
  define protected buffer buft_dis-chk-doc_obj for t-dis-chk-doc_obj.
  define protected temp-table t-bar-code_ no-undo like ub.bar-code.
  define protected buffer buft_bar-code_ for t-bar-code_.
  define protected buffer bufq_dis-chk-gds_obj for ub.chk-gds.
  define protected buffer bufq_dis-chk-doc_obj for ub.chk-doc.
  define query query_dis-chk-gds_obj for bufq_dis-chk-doc_obj, bufq_dis-chk-gds_obj scrolling.
  define public variable v_tbh as handle no-undo.
  define public variable v_tbdh as handle no-undo.
  define public variable v_tbbh as handle no-undo.
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
  define public variable line-num as integer no-undo .
  define public variable d-card as character no-undo .
  define public variable discnt as decimal no-undo .
  define public variable price-base as decimal no-undo .
  define public variable doc-qnty as decimal no-undo .
  define public variable b-code as integer no-undo .
  define public variable gds-code# as integer no-undo .
  define public variable chk-type# as integer no-undo .
  define public variable obj-type# as character no-undo .
  define public variable obj-code# as integer no-undo .
  define public variable base-rate# as decimal no-undo .
  define public variable base-scale# as integer no-undo .
  define public variable chk-date# as date no-undo .
  define public variable chk-time# as integer no-undo .
  { ibs/th/rul/crdrcall.i deftt }
  CONSTRUCTOR PUBLIC dis-chk-gds_obj(
                               input parparentproc as widget-handle
                              ,input p-parent-handle as handle
                              ,input p-log-handle as handle
                              ,input p-gc-handle as handle
                              ,input p-cont-handle as handle
                              ,input p-lock as integer
                              ,input p-wait as integer
                              ,input p-temp as integer
                            ):
   { ibs/th/rul/cr-cls.i dis-chk-gds_obj  ~{&table_chk-gds~} }
    doc-code = '':U .
    line-num = 0 .
    v_qh = query query_dis-chk-gds_obj:handle.
    v_bdh = buffer buf_dis-chk-doc_obj:handle.
    v_tbdh = buffer buft_dis-chk-doc_obj:handle.
    v_bbh = buffer buf_bar-code_:handle.
    v_tbbh = buffer buft_bar-code_:handle.

  end constructor.
  destructor public dis-chk-gds_obj():
    define buffer buf_temp-call-param for temp-call-param.
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    assign
    glog = v_tbdh:empty-temp-table() no-error .
    assign
    glog = v_tbbh:empty-temp-table() no-error .
    find_dis-chk-gds_obj ( input '':U, input 0).
    for each buf_temp-call-param:
      if buf_temp-call-param.param-number = 0 then do:
        delete object buf_temp-call-param.call-handle_.
      end.
      delete buf_temp-call-param.
    end.
  end destructor.
  method public logical find_dis-chk-gds_obj ( p-doc-code as character, p-line-num as integer):
   define variable glog as logical no-undo .
   dis-chk-gds_objrelease_().
   clear_().
    if p-doc-code <> '':U then do:
      assign
      glog =  v_bh:find-first( substitute('where doc-code = "&1" and line-num = &2'
                                          , p-doc-code
                                          , p-line-num
                                          ), lock, wait) no-error .
      if not glog then do:
        if find_no-error then do:
          return no.
        end.
        if lock = No-LOCK then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          return error substitute("Не найдена строка чека &1 &2", p-doc-code, p-line-num).
        end.
        if wait = NO-WAIT
        and v_bh:locked then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("&2 строка чека &1 занята", p-doc-code, p-line-num).
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
      glog =  v_bbh:find-first( substitute('where b-code = "&1"'
                                          , buf_dis-chk-gds_obj.b-code
                                          ), no-lock, wait) no-error .
      if not glog then do:
        return error substitute("Не найден баркод &1 для строки &2 чека &3"
                                , buf_dis-chk-gds_obj.b-code
                                ,line-num
                                ,p-doc-code
                                ).
      end.
      assign
      doc-code             = buf_dis-chk-gds_obj.doc-code
      line-num             = buf_dis-chk-gds_obj.line-num
      d-card               = buf_dis-chk-gds_obj.d-card
      discnt               = buf_dis-chk-gds_obj.discnt
      price-base           = buf_dis-chk-gds_obj.price-base
      doc-qnty             = buf_dis-chk-gds_obj.doc-qnty
      b-code               = buf_dis-chk-gds_obj.b-code
      gds-code#            = buf_bar-code_.gds-code
      chk-type#            = buf_dis-chk-doc_obj.chk-type
      obj-type#            = buf_dis-chk-doc_obj.obj-type
      obj-code#            = buf_dis-chk-doc_obj.obj-code
      base-rate#           = buf_dis-chk-doc_obj.base-rate
      base-scale#          = 1
      chk-date#            = buf_dis-chk-doc_obj.chk-date
      chk-time#            = buf_dis-chk-doc_obj.chk-time
      .
      glog = v_tbh:buffer-create( ).
      glog = v_tbh:buffer-copy( v_bh).
      glog = v_tbbh:buffer-create( ).
      glog = v_tbbh:buffer-copy( v_bbh).
      glog = v_tbdh:buffer-create( ).
      glog = v_tbdh:buffer-copy( v_bdh).
    end.
    return yes.
  end method.
  method public logical select_dis-chk-gds_obj ( input p-prepare-phrase-doc as character
                                               , input p-prepare-phrase-gds as character):
    define variable glog as logical no-undo.
    assign
    glog = v_qh:query-prepare( substitute("for each bufq_dis-chk-doc_obj no-lock where &1, " +
                                               "each bufq_dis-chk-gds_obj no-lock where " +
                                                "bufq_dis-chk-gds_obj.doc-code = bufq_dis-chk-doc_obj.doc-code and &2"
                             ,p-prepare-phrase-doc
                             ,p-prepare-phrase-gds)
                             ) no-error .
    if not glog then do:
      return error substitute("Ошибка подготовки выборки по строкам чека:&1&2&1&3&1&4"
                               , {&new-line}
                               , error-status:get-message(1)
                               , p-prepare-phrase-doc
                               , p-prepare-phrase-gds
                               ).
    end.
    assign
    glog = v_qh:query-open no-error .
    if error-status:error then do:
      return error substitute("Ошибка открытия выборки по строкам чека:&1&2&1&3"
                               , {&new-line}
                               , error-status:get-message(1)
                               , v_qh:prepare-string ).
    end.
  end method.
  method public logical get_dis-chk-gds_obj( input p-rec-pos as character):
    define variable glog as logical no-undo .
    if not v_qh:is-open then do:
      return error substitute("Выборка по строкам чека:&1(&2)&1еще на открыта"
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
       glog = find_dis-chk-gds_obj ( input bufq_dis-chk-gds_obj.doc-code, input bufq_dis-chk-gds_obj.line-num) no-error .
    end.
    return glog.
  end method.
  method public logical has_dis-rule( input  p-rule-num as integer):
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    if doc-code = '':U
    or line-num = 0 then do:
      return error substitute("Остутствует строка чека").
    end.
    find first buf_dis-gds-rule no-lock where
              buf_dis-gds-rule.gds-code = gds-code#
          and buf_dis-gds-rule.rule-num = p-rule-num no-error .
    return (available buf_dis-gds-rule).
  end method.
  method public logical run_dis-rule ( input p-rule-num as integer
                                           ,input p-discnt-role as character
                                           ,input p-pos-type as character
                                           ):
    define variable jj as integer no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    { ibs/th/rul/crdrcall.i def }
    if doc-code = '':U
    or line-num = 0 then do:
      return error substitute("Остутствует строка чека").
    end.
    do jj = 1 to 2:
      if jj = 1 then do:
        find first buf_dis-gds-rule no-lock where
                  buf_dis-gds-rule.gds-code = gds-code#
              and (p-rule-num = 0 or buf_dis-gds-rule.rule-num = p-rule-num)
              and (p-pos-type = '':U or buf_dis-gds-rule.pos-type = p-pos-type)
              and buf_dis-gds-rule.discnt-role = p-discnt-role
              and buf_dis-gds-rule.obj-type = obj-type#
              and buf_dis-gds-rule.obj-code = obj-code#
              no-error .
      end.
      if jj = 2 then do:
        find first buf_dis-gds-rule no-lock where
                  buf_dis-gds-rule.gds-code = gds-code#
              and (p-rule-num = 0 or buf_dis-gds-rule.rule-num = p-rule-num)
              and (p-pos-type = '':U or buf_dis-gds-rule.pos-type = p-pos-type)
              and buf_dis-gds-rule.discnt-role = p-discnt-role
              and buf_dis-gds-rule.obj-type = '':U
              and buf_dis-gds-rule.obj-code = 0
              no-error .
      end.
      if available buf_Dis-gds-rule then do:
        { ibs/th/rul/crdrcall.i create-new-record buf_dis-gds-rule.templ-rl-root }
        for each buf_temp-call-param where
                buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))
        on error  undo , return error substitute( "&1. &2&3&4", vss-include-info{&vssseq},  return-value, {&new-line}, error-status :get-message (1))
        on stop   undo , return error substitute( "&1. stop", vss-include-info{&vssseq} )
        on endkey undo , return error substitute( "&1. endkey", vss-include-info{&vssseq} )
        :
          case buf_temp-call-param.param-name_:
            when "p-rule-num" then do:
              assign
              buf_temp-call-param.integer_ = p-rule-num
              .
            end.
            when "p-date" then do:
              assign
              buf_temp-call-param.date_ = chk-date#
              .
            end.
            when "p-time" then do:
              assign
              buf_temp-call-param.integer_ = chk-time#
              .
            end.
            when "p-doc-qnty" then do:
              assign
              buf_temp-call-param.decimal_ = doc-qnty
              .
            end.
            when "p-tot-sum" then do:
              assign
              buf_temp-call-param.decimal_ = doc-qnty * price-base
              .
            end.
            when "p-grp-code" then do:
              /*надо получить код группы */
              /*
              assign
              buf_temp-call-param.__integer = v-grp-code
              .
              */
            end.
            when "p-dis-kat" then do:
              /*надо получить dis-kat для карты */
              /*
              assign
              buf_temp-call-param.__integer = v-dis-kat
              .
              */
            end.
          end case. /*case buf_temp-call-param.param-name_:*/
        end. /*      for each buf_temp-call-param where*/
        { ibs/th/rul/crdrcall.i create-call buf_dis-gds-rule.templ-rl-root }
        { ibs/th/rul/crdrcall.i invoke }
        RETURN  YES.
      end. /*if available buf_Dis-gds-rule then do:*/
    end. /*do jj*/
    return no.
  end method.
  { ibs/th/rul/crdrcall.i return-value-methods }
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    if v_tbh:available then
    glog = v_tbh:buffer-delete() no-error .
    if v_tbbh:available then
    glog = v_tbbh:buffer-delete() no-error .
    if v_tbdh:available then
    glog = v_tbdh:buffer-delete() no-error .
    assign
    doc-code = ''
    line-num = 0
    gds-code# = 0
    chk-type# = 0
    base-rate# = 0
    base-scale# = 0
    .
  end method.
  method public void Dis-chk-gds_objrelease_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    glog = v_bdh:buffer-release() no-error .
    glog = v_bbh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_dis-chk-gds_obj ( ):
    return v_bh.
  end method.
  method public override character ToString( ):
    return substitute("Чек &1, строка &2", doc-code, line-num).
  end method.

end class.
