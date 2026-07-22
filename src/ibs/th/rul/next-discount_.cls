/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: next-discount_.cls $
$Archive: ibs/th/rul/next-discount_.cls $

Класс Свойства ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/28/07
Author: Bakhtadze Natalya
Creation date: 01/28/07

*/

block-level on error undo, throw.
class Ibs.Th.Rul.next-discount_:
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: next-discount_.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_pp as widget-handle no-undo. /*parparentproc*/
  define protected variable v_ph as handle no-undo.        /*p-parent-handle*/
  define protected variable v_lh as widget-handle no-undo. /*p-log-handle*/
  define protected variable v_gc as handle no-undo.
  define protected variable v_cnt as widget-handle no-undo. /*p-cont-handle*/
  define protected buffer buf_next-discount_ for ub.dis-card-property.
  define protected temp-table t-next-discount_ no-undo like ub.dis-card-property
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
  define protected buffer buft_next-discount_ for t-next-discount_.
  define public variable v_bh as handle no-undo.
  define protected variable v_tbh as handle no-undo.
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
  define protected variable caller_id as character no-undo .
  define protected variable sum-id as character no-undo .
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
  CONSTRUCTOR PUBLIC next-discount_(
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
    { ibs/th/rul/cr-cls.i next-discount_  ~{&table_dis-card-property~} }
    assign
    d-card = '':U
    dtm-code = p-dtm-code
    dt-code = 0
    node-code# = 0
    caller_id = '':U
    .
    for each buf_prop-map  where buf_prop-map.dtm-code = p-dtm-code
    on error  undo , return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
    :
      create buft_next-discount_.
      assign
      buft_next-discount_.dtm-code = buf_prop-map.dtm-code
      buft_next-discount_.node-code = buf_prop-map.node-code
      buft_next-discount_.node-name = buf_prop-map.node-name
      buft_next-discount_.ordinal = buf_prop-map.ordinal
      buft_next-discount_.init-value-character = buf_prop-map.init-value-character
      buft_next-discount_.init-value-date      = buf_prop-map.init-value-date
      buft_next-discount_.init-value-decimal   = buf_prop-map.init-value-decimal
      buft_next-discount_.init-value-integer   = buf_prop-map.init-value-integer
      buft_next-discount_.init-value-logical   = buf_prop-map.init-value-logical
      num-members = num-members + 1
      .
    end.
  end constructor.
  destructor public next-discount_():
    define variable glog as logical no-undo .
    for each buft_next-discount_:
      delete buft_next-discount_.
    end.
    find_next-discount_ ( input '':U).
  end destructor.
  method public void next-discount_release_ ( ):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    clear_().
  end method.
  method public handle get_next-discount_ ( ):
    return v_bh.
  end method.
  method public logical set_next-discount_ ( input p-bh as handle):
    define variable glog as logical no-undo .
    glog = v_bh:buffer-copy ( p-bh).
    return glog.
  end method.
  method public logical find_next-discount_sum-id ( p-d-card as character
                                      , p-sum-id as character
                                      , p-caller-id as character
                                          ):
    define variable glog as logical no-undo .
    define variable v-date-char as character no-undo .
    define buffer buf_prop-ref for ub.prop-ref.
    find first buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = dtm-code
            and buf_prop-ref.sum-id = p-sum-id
            and buf_prop-ref.caller_id = p-caller-id no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден Период &2 (доп.иден-р &3) в справочнике итогов&4"
                                       , vss-include-info{&vssseq}
                                       , p-sum-id
                                       , p-caller-id
                                       , {&new-line}
                                       ).
     end.
     assign
     dt-code = buf_prop-ref.dt-code
     sum-id = buf_prop-ref.sum-id
     caller_id = buf_prop-ref.caller_id
     .

     glog = find_next-discount_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
   end method.
  method public logical find_next-discount_date ( p-d-card as character
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
        undo, return error substitute( "&1. Не найден Период для даты &2 (доп.иден-р &3) в справочнике итогов&4"
                                       , vss-include-info{&vssseq}
                                       , string(p-date, "99/99/9999")
                                       , p-caller-id
                                       , {&new-line}
                                       ).
     end.
     assign
     dt-code = buf_prop-ref.dt-code
     sum-id = buf_prop-ref.sum-id
     caller_id = buf_prop-ref.caller_id
     .
     glog = find_next-discount_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
   end method.
   method public logical next-discount_save ( ):
   define variable glog as logical no-undo .
   define variable v-tosave as logical no-undo .
   define buffer buf_dis-card for ub.dis-card.
    if d-card <> '':U then do:
        _save:
        for each buft_next-discount_
        on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
        :
          v-tosave = no.
          if buft_next-discount_.node-name = "d-pcnt"
          then do:
            if buft_next-discount_.init-value-decimal = d-pcnt then next _save.
            assign
            buft_next-discount_.property-value-decimal = d-pcnt
            .
          end.
          if buft_next-discount_.node-name = "cash-d-pcnt" then do:
            if buft_next-discount_.init-value-decimal = cash-d-pcnt then next _save.
            assign
            buft_next-discount_.property-value-decimal = cash-d-pcnt
            .
          end.
          if buft_next-discount_.node-name = "category" then do:
            if buft_next-discount_.init-value-integer = category then next _save.
            assign
            buft_next-discount_.property-value-integer = category
            .
          end.
          if buft_next-discount_.h-n-action = integer({&hn-update})
          or buft_next-discount_.h-n-action = integer({&hn-create})
          then do:
            if temp >= 0 then do:
              /*надо послать primary и с-*/
              if buft_next-discount_.recid_ <> ? then do:
                find first buf_next-discount_ exclusive-lock where
                    recid(buf_next-discount_) = buft_next-discount_.recid_.
                v-tosave = not (v_bh:buffer-compare(v_tbh)).
              end.
              else do:
                glog = v_bh:buffer-create().
                glog = v_bh:buffer-copy( v_tbh, "property-value-character,property-value-date,property-value-decimal,property-value-integer,property-value-logical").
                v-tosave = yes.
              end.
              if v-tosave then do:
              run disproph_write-dis-card-property-rul in v_gc ( buffer buf_next-discount_
                                                      ,input type#
                                                      ,input emitent-host-code#
                                                      ,input 7 /*p-dtm-code*/
                                                      ,input buft_next-discount_.h-n-action) no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
              end.
              glog = v_bh:buffer-copy( v_tbh).
              run disproph_send-dis-card-property-rul in v_gc ( buffer buf_next-discount_
                                                      ,input type#
                                                      ,input emitent-host-code#
                                                      ,input 7 /*p-dtm-code*/
                                                      ,input buft_next-discount_.h-n-action) no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
              end.
              end.
            end. /*if temp >= 0 then do:*/
            v_bh:buffer-field("trg-param"):buffer-value = {&trg-param-no-callnews} + {&comma-char} + {&trg-param-no-hist}.
            glog = v_bh:buffer-release() no-error .
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
            end.
            if temp < 0 then do:
              run tempcont_create-changes in v_cnt (
                                              input {&table_dis-card-property}
                                             ,input v_bh
                                             ,input v_tbh
                                             ,input buft_next-discount_.h-n-action) no-error.
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
              end.
            end. /*if temp < 0 then do:*/
          end. /*если изменилось*/
        end. /*      for each buft_dis-card-property*/
    end. /*if d-card <> '':U then do:*/
    return yes.
  end method.
   method public logical find_next-discount_ ( p-d-card as character):
   define variable glog as logical no-undo .
   define variable v-jj as integer no-undo .
   define buffer buf_dis-card for ub.dis-card.
    next-discount_release_().
    clear_().
    if p-d-card <> '':U then do:
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card no-error.
      if not available buf_dis-card then do:
         return error substitute("Не найдена ДК &1", p-d-card).
      end.
      assign
      card-num                 = buf_dis-card.card-num
      d-card                   = buf_dis-card.d-card
      first-card               = buf_dis-card.first-card
      first-main-card          = buf_dis-card.first-main-card
      main-card                = buf_dis-card.main-card
      emitent-host-code#       = buf_dis-card.emitent-host-code
      type#                    = buf_dis-card.type
      .
      define variable v-ii as integer no-undo .
      _buft_dis-card-property:
      for each buft_next-discount_
      by buft_next-discount_.dt-code
      by buft_next-discount_.node-code

      on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
      :
        assign
        buft_next-discount_.card-num                 = buf_dis-card.card-num
        buft_next-discount_.d-card                   = buf_dis-card.d-card
        buft_next-discount_.first-card               = buf_dis-card.first-card
        buft_next-discount_.first-main-card          = buf_dis-card.first-main-card
        buft_next-discount_.main-card                = buf_dis-card.main-card
        buft_next-discount_.recid_ = ?
        buft_next-discount_.h-n-action = 0
        buft_next-discount_.property-value-decimal = buft_next-discount_.init-value-decimal
        buft_next-discount_.property-value-integer = buft_next-discount_.init-value-integer
        buft_next-discount_.dt-code                 = dt-code
        buft_next-discount_.sum-id                  = sum-id
        v-jj = v-jj + 1
        .
        define variable v-where as character no-undo .
        v-where =  substitute('where d-card = "&1" and host-code = 0 and obj-type = "" and obj-code = 0 and dt-code = &2 and node-code = &3'
                                , p-d-card
                                , dt-code
                                , buft_next-discount_.node-code
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
          buft_next-discount_.h-n-action = integer({&hn-create}).
          if v-jj = num-members then leave _buft_dis-card-property.
          next _buft_dis-card-property.
        end.
        else do:
          assign
          buft_next-discount_.h-n-action = integer({&hn-update})
          .
        end.
        assign
        v-ii = v-ii + 1
        buft_next-discount_.recid_ = recid(buf_next-discount_)
        .
        glog = v_tbh:buffer-copy( v_bh).
        if buft_next-discount_.node-name = "d-pcnt" then do:
           assign
           d-pcnt = buft_next-discount_.property-value-decimal
           node-code#                = buft_next-discount_.node-code
           .
        end.
        if buft_next-discount_.node-name = "cash-d-pcnt" then do:
           assign
           cash-d-pcnt = buft_next-discount_.property-value-decimal
           node-code#                = buft_next-discount_.node-code
           .
        end.
        if buft_next-discount_.node-name = "category" then do:
           assign
           category = buft_next-discount_.property-value-integer
           node-code#                = buft_next-discount_.node-code
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
  method public logical create_next-discount_date ( input p-d-card as character
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
        undo, return error substitute( "&1. Не найден Период для даты &2 (доп.иден-р &3) в справочнике итогов&4"
                                       , vss-include-info{&vssseq}
                                       , string(p-date, "99/99/9999")
                                       , p-caller-id
                                       , {&new-line}
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     caller_id = buf_prop-ref.caller_id.
     glog = create_next-discount_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
  end.
  method public logical create_next-discount_ ( input p-d-card as character ):
    define buffer buft2_ for t-next-discount_.
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
      assign
      buft2_.dt-code = dt-code
      buft2_.sum-id = sum-id
      .
    end.
    return yes.
  end method.
  method protected void clear_():
    define variable glog as logical no-undo .
    v-error-flag = no.
    assign
    d-card = ''
    .
    for each buft_next-discount_:
      assign
      buft_next-discount_.card-num                 = 0
      buft_next-discount_.d-card                   = '':U
      buft_next-discount_.first-card               = '':U
      buft_next-discount_.first-main-card          = '':U
      buft_next-discount_.main-card                = '':U
      buft_next-discount_.recid_ = ?
      buft_next-discount_.h-n-action = 0
      buft_next-discount_.property-value-decimal = buft_next-discount_.init-value-decimal
      buft_next-discount_.property-value-integer = buft_next-discount_.init-value-integer
      buft_next-discount_.dt-code                 = 0
      buft_next-discount_.sum-id                  = '':U
      .
    end.
  end method.
  method public override character ToString( ):
    return substitute("ДК &1 объект-операнд &2, срез &2, свойство &4"
                      , d-card
                      , dtm-code
                      , dt-code
                      , node-code#).
  end method.
end class.
