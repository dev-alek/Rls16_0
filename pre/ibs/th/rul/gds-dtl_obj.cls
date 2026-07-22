block-level on error undo, throw.
class Ibs.Th.Rul.gds-dtl_obj:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: gds-dtl_obj.cls $ $Revision: aea5316774be, 0, rls $".
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
  define protected buffer buf_gds-dtl_obj for ub.gds-dtl.
  define protected buffer buf_trn-doc_obj for ub.trn-doc.
  define protected buffer buf_bar-code_ for ub.bar-code.
  define protected buffer buf_goods_ for ub.goods.
  define protected temp-table t-gds-dtl_obj no-undo like ub.gds-dtl.
  define protected buffer buft_gds-dtl_obj for t-gds-dtl_obj.
  define protected temp-table t-trn-doc_obj no-undo like ub.trn-doc.
  define protected buffer buft_trn-doc_obj for t-trn-doc_obj.
  define protected temp-table t-bar-code_ no-undo like ub.bar-code.
  define protected buffer buft_bar-code_ for t-bar-code_.
  define protected temp-table t-goods_ no-undo like ub.goods.
  define protected buffer buft_goods_ for t-goods_.
  define protected buffer bufq_gds-dtl_obj for ub.gds-dtl.
  define protected buffer bufq_trn-doc_obj for ub.trn-doc.
  define query query_gds-dtl_obj for bufq_trn-doc_obj, bufq_gds-dtl_obj scrolling.
  define public variable v_tbh as handle no-undo.
  define public variable v_tbdh as handle no-undo.
  define public variable v_tbbh as handle no-undo.
  define public variable v_tbgh as handle no-undo.
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
  define public variable artic as character no-undo .
  define public variable prod-type as character no-undo .
  define public variable prod-code as integer no-undo .
  define public variable discnt-base as decimal no-undo .
  define public variable price-base as decimal no-undo .
  define public variable discnt-rubl as decimal no-undo .
  define public variable price-rubl as decimal no-undo .
  define public variable prt-code as integer no-undo .
  define public variable fact-qnty as decimal no-undo .
  define public variable b-code# as integer no-undo .
  define public variable gds-code# as integer no-undo .
  define public variable obj-type as character no-undo .
  define public variable obj-code as integer no-undo .
  define public variable base-rate# as decimal no-undo .
  define public variable base-scale# as decimal no-undo .
  define public variable doc-date# as date no-undo .
  define public variable doc-time# as integer no-undo .
  define public variable discnt-pc as decimal no-undo .
  define public variable discnt-type as logical no-undo .
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
  CONSTRUCTOR PUBLIC gds-dtl_obj(
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
run garbcoll_create-gc-entry in p-gc-handle (input 'gds-dtl_obj',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 ќшибка создани€ объекта gds-dtl_obj", vss-include-info0).
end.
v_bh = buffer buf_gds-dtl_obj:handle.
v_tbh = buffer buft_gds-dtl_obj:handle.
    assign
    doc-code = '':U
    artic = '':U
    prod-type = '':U
    prod-code = 0
    prt-code = 0
    .
    v_qh = query query_gds-dtl_obj:handle.
    v_bdh = buffer buf_trn-doc_obj:handle.
    v_tbdh = buffer buft_trn-doc_obj:handle.
    v_bbh = buffer buf_bar-code_:handle.
    v_bgh = buffer buf_goods_:handle.
    v_tbbh = buffer buft_bar-code_:handle.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run library-cls_get-handle in v_gc ( input "library", output g#library) no-error.   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  end constructor.
  destructor public gds-dtl_obj():
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    assign
    glog = v_tbdh:empty-temp-table() no-error .
    assign
    glog = v_tbbh:empty-temp-table() no-error .
    find_gds-dtl_obj ( input '':U, input '':U, input '':U, input 0, input 0).
  end destructor.
  method public logical find_gds-dtl_obj ( p-doc-code as character
                                         , p-artic as character
                                         , p-prod-type as character
                                         , p-prod-code as integer
                                         , p-prt-code as integer
                                         ):
   define variable glog as logical no-undo .
   gds-dtl_objrelease_().
   clear_().
    if p-doc-code <> '':U then do:
      assign
      glog =  v_bh:find-first( substitute('where doc-code = "&1" and artic = "&2" and prod-type = "&3" and prod-code = &4 '
                                          , p-doc-code
                                          , p-artic
                                          , p-prod-type
                                          , p-prod-code
                                          , p-prt-code
                                          ), lock, wait) no-error .
      if not glog then do:
        if find_no-error then do:
          return no.
        end.
        if lock = No-LOCK then do:
          if v_tbh:available then
          assign glog = v_tbh:buffer-delete() no-error .
          return error substitute("Ќе найдена строка накладной &1 &2 &3&4 (код признака &5)"
                                 , p-doc-code
                                 , p-artic
                                 , p-prod-type
                                 , p-prod-code
                                 , p-prt-code
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
            return error substitute("&2 &3&4 (код признака &5) строка накладной &1 зан€та"
                                   , p-doc-code
                                   , p-artic
                                   , p-prod-type
                                   , p-prod-code
                                   , p-prt-code
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
      glog =  v_bgh:find-first( substitute('where artic = "&1" and prod-type = "&2" and prod-code = &3'
                                          , buf_gds-dtl_obj.artic
                                          , buf_gds-dtl_obj.prod-type
                                          , buf_gds-dtl_obj.prod-code
                                          ), no-lock, wait) no-error .
      if not glog then do:
        return error substitute("Ќе найден товар &1 &2&3 (код признака &4) дл€ строки накладной &5"
                                , buf_gds-dtl_obj.artic
                                , buf_gds-dtl_obj.prod-type
                                , buf_gds-dtl_obj.prod-code
                                , buf_gds-dtl_obj.prt-code
                                ,p-doc-code
                                ).
      end.
      assign
      doc-code             = buf_gds-dtl_obj.doc-code
      d-card#              = buf_trn-doc_obj.d-card
      artic                = buf_gds-dtl_obj.artic
      prod-type            = buf_gds-dtl_obj.prod-type
      prod-code            = buf_gds-dtl_obj.prod-code
      discnt-base          = buf_gds-dtl_obj.discnt-base
      price-base           = buf_gds-dtl_obj.price-base
      discnt-rubl          = buf_gds-dtl_obj.discnt-rubl
      price-rubl           = buf_gds-dtl_obj.price-rubl
      fact-qnty            = buf_gds-dtl_obj.fact-qnty
      prt-code             = buf_gds-dtl_obj.prt-code
      gds-code#            = buf_bar-code_.gds-code
      obj-type             = buf_gds-dtl_obj.obj-type
      obj-code             = buf_gds-dtl_obj.obj-code
      base-rate#           = buf_trn-doc_obj.base-rate
      base-scale#          = buf_trn-doc_obj.base-scale
      discnt-pc            = buf_gds-dtl_obj.discnt-pc
      discnt-type          = buf_gds-dtl_obj.discnt-type
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
  method public logical select_gds-dtl_obj ( input p-prepare-phrase-doc as character
                                               , input p-prepare-phrase-gds as character):
    define variable glog as logical no-undo.
    assign
    glog = v_qh:query-prepare( substitute("for each bufq_gds-dtl_obj no-lock where &1, " +
                                               "each bufq_gds-dtl_obj no-lock where " +
                                                "bufq_gds-dtl_obj.doc-code = bufq_trn-doc_obj.doc-code and &2"
                             ,p-prepare-phrase-doc
                             ,p-prepare-phrase-gds)
                             ) no-error .
    if not glog then do:
      return error substitute("ќшибка подготовки выборки по строкам накладной:&1&2&1&3&1&4"
                               , chr(10)
                               , error-status:get-message(1)
                               , p-prepare-phrase-doc
                               , p-prepare-phrase-gds
                               ).
    end.
    assign
    glog = v_qh:query-open no-error .
    if error-status:error then do:
      return error substitute("ќшибка открыти€ выборки по строкам накладной:&1&2&1&3"
                               , chr(10)
                               , error-status:get-message(1)
                               , v_qh:prepare-string ).
    end.
  end method.
  method public logical get_gds-dtl_obj( input p-rec-pos as character):
    define variable glog as logical no-undo .
    if not v_qh:is-open then do:
      return error substitute("¬ыборка по строкам накладной:&1(&2)&1еще на открыта"
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
       glog = find_gds-dtl_obj ( input bufq_gds-dtl_obj.doc-code
                                ,input bufq_gds-dtl_obj.artic
                                ,input bufq_gds-dtl_obj.prod-type
                                ,input bufq_gds-dtl_obj.prod-code
                                ,input bufq_gds-dtl_obj.prt-code
                                ) no-error .
    end.
    return glog.
  end method.
  method public logical has_dis-rule( input  p-rule-num as integer):
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    if doc-code = '':U
    or artic = '':U
    or prod-type = '':U
    or prod-code = 0
    then do:
      return error substitute("ќстутствует строка накладной").
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ii as integer no-undo .
define buffer buf_temp-call-param for temp-call-param.
define buffer buf2_temp-call-param for temp-call-param.
define buffer buf_drt-prop for ub.drt-prop.
    if doc-code = '':U
    or artic = '':U
    or prod-type = '':U
    or prod-code = 0  then do:
      return error substitute("ќстутствует строка док-та").
    end.
    do jj = 1 to 2:
      if jj = 1 then do:
        find first buf_dis-gds-rule no-lock where
                  buf_dis-gds-rule.gds-code = gds-code#
              and (p-rule-num = 0 or buf_dis-gds-rule.rule-num = p-rule-num)
              and (p-pos-type = '':U or buf_dis-gds-rule.pos-type = p-pos-type)
              and buf_dis-gds-rule.discnt-role = p-discnt-role
              and buf_dis-gds-rule.obj-type = obj-type
              and buf_dis-gds-rule.obj-code = obj-code
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first buf_temp-call-param where
        buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))
    and buf_temp-call-param.param-num = 0 no-error .
if not available buf_temp-call-param then do:
  if v_gc:get-signature(substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))) = '':u then do:
    undo, return error substitute("ќпределение &1 отсутствует в &2"
                                   ,substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))
                                   , v_gc:file-name).
  end.
  create buf_temp-call-param.
  assign
  buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))
  buf_temp-call-param.param-number_ = 0
  .
  for each buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = buf_dis-gds-rule.templ-rl-root
      and buf_drt-prop.upper-prop-code = "Call-params"
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info5,  return-value, chr(10), error-status :get-message (1))
    on stop   undo , return error substitute( "&1. stop", vss-include-info5 )
    on endkey undo , return error substitute( "&1. endkey", vss-include-info5 ):
    if integer(buf_drt-prop.prop-code) = 0 then do:
      assign
      buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))
      buf_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      .
    end.
    else do:
      create buf2_temp-call-param.
      assign
      v-ii = v-ii + 1
      buf2_temp-call-param.call-name_ = substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))
      buf2_temp-call-param.param-number_ = integer(buf_drt-prop.prop-code)
      buf2_temp-call-param.param-name_ = entry(1, buf_drt-prop.property-value)
      buf2_temp-call-param.param-datatype_ = entry(2, buf_drt-prop.property-value)
      buf2_temp-call-param.io-mode_ = entry(3, buf_drt-prop.property-value)
      buf2_temp-call-param.param-label_ = entry(4, buf_drt-prop.property-value)
      .
    end.
  end.
  assign
  buf_temp-call-param.num-params = v-ii
  .
end.
        for each buf_temp-call-param where
                buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))
        on error  undo , return error substitute( "&1. &2&3&4", vss-include-info0,  return-value, chr(10), error-status :get-message (1))
        on stop   undo , return error substitute( "&1. stop", vss-include-info0 )
        on endkey undo , return error substitute( "&1. endkey", vss-include-info0 )
        :
          case buf_temp-call-param.param-name_:
            when "p-rule-num" then do:
              assign
              buf_temp-call-param.integer_ = p-rule-num
              .
            end.
            when "p-date" then do:
              assign
              buf_temp-call-param.date_ = doc-date#
              .
            end.
            when "p-time" then do:
              assign
              buf_temp-call-param.integer_ = doc-time#
              .
            end.
            when "p-doc-qnty" then do:
              assign
              buf_temp-call-param.decimal_ = fact-qnty
              .
            end.
            when "p-tot-sum" then do:
              assign
              buf_temp-call-param.decimal_ = fact-qnty * (if v-curr-r-b = 'rubl':U
                                                          then price-base
                                                          else price-rubl)
              .
            end.
            when "p-grp-code" then do:
            end.
            when "p-dis-kat" then do:
            end.
          end case.
        end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  find first buf_temp-call-param where
            buf_temp-call-param.call-name_ = substitute("dis-rule_&1", string(buf_dis-gds-rule.templ-rl-root, "99999"))
        and buf_temp-call-param.param-number = 0.
  if not valid-handle(buf_temp-call-param.call-handle_) then do:
    create call buf_temp-call-param.call-handle_.
    assign
    buf_temp-call-param.call-handle_:call-name = buf_temp-call-param.call-name_
    buf_temp-call-param.call-handle_:call-type = FUNCTION-CALL-TYPE
    buf_temp-call-param.call-handle_:in-handle = v_gc
    buf_temp-call-param.call-handle_:num-parameters = buf_temp-call-param.num-params
    .
  end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  for each buf2_temp-call-param where
          buf2_temp-call-param.param-num > 0
  on error  undo , return error substitute( "&1. &2&3&4", vss-include-info7,  return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-include-info7 )
  on endkey undo , return error substitute( "&1. endkey", vss-include-info7 ):
    buf_temp-call-param.call-handle_:set-parameter( buf2_temp-call-param.param-num
                                                    ,buf2_temp-call-param.param-datatype_
                                                    ,buf2_temp-call-param.io-mode
                                                    ,buffer buf2_temp-call-param:buffer-field( substitute("&1_", buf2_temp-call-param.param-datatype_)):buffer-value).
  end.
  assign
  buf_temp-call-param.call-number = buf_temp-call-param.call-number + 1
  v-last-call-number = buf_temp-call-param.call-number
  v-last-call-name = buf_temp-call-param.call-name_
  .
  buf_temp-call-param.call-handle_:invoke.
  assign
  buf_temp-call-param.param-datatype_ = buf_temp-call-param.call-handle_:return-value-data-type.
  case buf_temp-call-param.param-datatype_:
      when 'character':U then do:
        assign
        buf_temp-call-param.character_ = buf_temp-call-param.call-handle_:return-value.
      end.
      when 'date':U then do:
        assign
        buf_temp-call-param.date_ = buf_temp-call-param.call-handle_:return-value.
      end.
      when 'decimal':U then do:
        assign
        buf_temp-call-param.decimal_ = buf_temp-call-param.call-handle_:return-value.
      end.
      when 'integer':U then do:
        assign
        buf_temp-call-param.integer_ = buf_temp-call-param.call-handle_:return-value.
      end.
      when 'logical':U then do:
        assign
        buf_temp-call-param.logical_ = buf_temp-call-param.call-handle_:return-value.
      end.
  end case.
        RETURN  YES.
      end.
    end.
    return no.
  end method.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  method public decimal get_dis-rule-value_decimal ( input p-param-name as character):
    define buffer buf_temp-call-param for temp-call-param.
    find first buf_temp-call-param where
              buf_temp-call-param.param-name_ = p-param-name
          and buf_temp-call-param.call-name_ = v-last-call-name no-error .
    if not available buf_temp-call-param then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - отсутствуют"
                                   ,vss-include-info8
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info8
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
                                   ,vss-include-info8
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info8
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
                                   ,vss-include-info8
                                   ,v-last-call-name
                                   ,p-param-name).
    end.
    if buf_temp-call-param.call-number <> v-last-call-number then do:
      undo, return error substitute("&1 данные о результатах расчета &2 по правилу скидки - параметр &3 - уже затерты"
                                   ,vss-include-info8
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
    if v_tbbh:available then
    glog = v_tbbh:buffer-delete() no-error .
    if v_tbdh:available then
    glog = v_tbdh:buffer-delete() no-error .
    if v_tbgh:available then
    glog = v_tbgh:buffer-delete() no-error .
    assign
    doc-code = ''
    artic = '':U
    prod-type = '':U
    prod-code = 0
    gds-code# = 0
    .
  end method.
   method public logical gds-dtl_obj_save ( ):
   define variable glog as logical no-undo .
   define variable loc-action  as integer no-undo .
   define buffer buf_dis-card for ub.dis-card.
    if artic <> '':U then do:
        assign
        buft_gds-dtl_obj.discnt-rubl  = discnt-rubl
        buft_gds-dtl_obj.discnt-base  = discnt-base
        buft_gds-dtl_obj.discnt-pc  = discnt-pc
        buft_gds-dtl_obj.discnt-type  = discnt-type
        .
        glog = no.
        if v_bh:available then  do:
          glog = v_bh:buffer-compare(v_tbh).
        end.
        if not glog
        then do:
          if temp >= 0 then do:
            assign
            glog = v_bh:buffer-copy( v_tbh) no-error .
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
          end.
          glog = v_bh:buffer-release() no-error .
          if error-status:error then do:
            undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
          end.
        end.
     end.
     return yes.
   end method.
  method public void gds-dtl_objrelease_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    glog = v_bdh:buffer-release() no-error .
    glog = v_bbh:buffer-release() no-error .
    glog = v_bgh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_gds-dtl_obj ( ):
    return v_bh.
  end method.
  method public override character ToString( ):
    return substitute("Ќакладна€ &1, товар &2 &3&4 (код признака &5)"
                      , doc-code
                      , artic
                      , prod-type
                      , prod-code
                      , prt-code
                      ).
  end method.
end class.
