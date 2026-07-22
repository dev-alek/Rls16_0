/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dis-tot_obj.cls $
$Archive: ibs/th/rul/dis-tot_obj.cls $

Класс ИТОГИ ПО ДК ПО ОБЪЕКТУ dt-code = 0

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/28/07
Author: Bakhtadze Natalya
Creation date: 01/28/07

*/

block-level on error undo, throw.
class Ibs.Th.Rul.Dis-tot_obj:
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: dis-tot_obj.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_pp as widget-handle no-undo. /*parparentproc*/
  define protected variable v_ph as handle no-undo.        /*p-parent-handle*/
  define protected variable v_lh as widget-handle no-undo. /*p-log-handle*/
  define protected variable v_gc as handle no-undo.
  define protected variable v_cnt as widget-handle no-undo. /*p-cont-handle*/
  define public variable v_bh as handle no-undo.
  define protected buffer buf_dis-tot_obj for ub.dis-obj.
  define protected temp-table t-dis-tot_obj no-undo like ub.dis-obj.
  define protected buffer buft_dis-tot_obj for t-dis-tot_obj.
  define public variable v_tbh as handle no-undo.
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
  define protected variable base-code as integer no-undo .
  define protected variable sum-id as character no-undo .
  define public variable card-num as integer no-undo .
  define public variable d-card as character no-undo .
  define public variable first-card as character no-undo .
  define public variable first-main-card as character no-undo .
  define public variable main-card as character no-undo .
  define public variable gds-dis-base as decimal no-undo .
  define public variable gds-dis-rubl as decimal no-undo .
  define public variable gds-tot-b0 as decimal   no-undo .
  define public variable gds-tot-base as decimal no-undo .
  define public variable gds-tot-r0 as decimal   no-undo .
  define public variable gds-tot-rubl as decimal no-undo .
  define public variable num-chk as integer      no-undo .
  define public variable pay-tot-base as decimal no-undo .
  define public variable pay-tot-rubl as decimal no-undo .
  define public variable host-code as integer no-undo .
  define public variable obj-code as integer no-undo .
  define public variable obj-type as character no-undo.
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
  define public property gds-tot-b0_Byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return gds-tot-b0_byfm#.
  end get.
  private set.
  define public property gds-tot-base_Byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return gds-tot-base_byfm#.
  end get.
  private set.
  define public property gds-tot-r0_Byfm# as decimal
  get():
    if not v-byfm then get-byfm().
    return gds-tot-r0_byfm#.
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
  define public property gds-tot-b0_byf# as decimal
  get():
    if not v-byf then get-byf().
    return gds-tot-b0_byf#.
  end get.
  private set.
  define public property gds-tot-base_byf# as decimal
  get():
    if not v-byf then get-byf().
    return gds-tot-base_byf#.
  end get.
  private set.
  define public property gds-tot-r0_byf# as decimal
  get():
    if not v-byf then get-byf().
    return gds-tot-r0_byf#.
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
  define public property gds-tot-b0_bym# as decimal
  get():
    if not v-bym then get-bym().
    return gds-tot-b0_bym#.
  end get.
  private set.
  define public property gds-tot-base_bym# as decimal
  get():
    if not v-bym then get-bym().
    return gds-tot-base_bym#.
  end get.
  private set.
  define public property gds-tot-r0_bym# as decimal
  get():
    if not v-bym then get-bym().
    return gds-tot-r0_bym#.
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
  CONSTRUCTOR PUBLIC dis-tot_obj(
                               input parparentproc as widget-handle
                              ,input p-parent-handle as handle
                              ,input p-log-handle as handle
                              ,input p-gc-handle as handle
                              ,input p-cont-handle as handle
                              ,input p-lock as integer
                              ,input p-wait as integer
                              ,input p-temp as integer
                            ):
    { ibs/th/rul/cr-cls.i dis-tot_obj  ~{&table_dis-obj~} }
    d-card = '':U.
    dtm-code  = 1.
    dt-code = 0.
    caller_id = '':U.
  end constructor.
  CONSTRUCTOR PUBLIC dis-tot_obj(
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
    { ibs/th/rul/cr-cls.i dis-tot_obj  ~{&table_dis-obj~} }
    d-card = '':U.
    dtm-code = p-dtm-code.
  end constructor.
  destructor public dis-tot_obj():
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    find_dis-tot_obj ( input '':U, input '':U, input 0).
  end destructor.
  method public void Dis-tot_objrelease_ (  ):
    define variable glog as logical no-undo .
    do transaction :
      glog = v_bh:buffer-release() no-error .
    end.
    clear_().
  end method.
  method public handle get_dis-tot_obj ( ):
    return v_bh.
  end method.
  method public logical set_dis-tot_obj ( input p-bh as handle):
    define variable glog as logical no-undo .
    do transaction :
      glog = v_bh:buffer-copy ( p-bh).
    end.
    return glog.
  end method.
  method public logical find_dis-tot_obj_sum-id ( p-d-card as character
                                      , p-obj-type as character
                                      , p-obj-code as integer
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
                                       , vss-include-info{&vssseq}
                                       , p-sum-id
                                       , p-caller-id
                                       , {&new-line}
                                       ,dtm-code
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     sum-id = buf_prop-ref.sum-id.
     caller_id = buf_prop-ref.caller_id.
     glog = find_dis-tot_obj ( p-d-card, p-obj-type, p-obj-code ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
   end method.

   method public logical find_dis-tot_obj_date ( p-d-card as character
                                          , p-obj-type as character
                                          , p-obj-code as integer
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
     dt-code = buf_prop-ref.dt-code.
     caller_id = buf_prop-ref.caller_id.
     glog = find_dis-tot_obj ( p-d-card , p-obj-type , p-obj-code ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
   end method.
   method public logical dis-tot_objsave ( ):
   define variable glog as logical no-undo .
   define variable loc-action as integer no-undo .
   define buffer buf_dis-card for ub.dis-card.
    if d-card <> '':U then do:
        if (pay-tot-base + pay-tot-rubl +
            gds-dis-base + gds-dis-rubl +
            gds-tot-base + gds-tot-rubl +
            num-chk) = ? then do:
          run set-error in v_gc (substitute("Не задано ( =  ?) значение одной из сумм или кол-во чеков для ДК &1 &2&3"
                                            , d-card
                                            , obj-type
                                            , obj-code
                                            )).
          return no.
        end.
        if (pay-tot-base = 0.0) <> (pay-tot-rubl = 0.0) then do:
          run set-error in v_gc (substitute("Если сумма оплат в нац.вал. = 0, то сумма оплат в баз.вал. тоже должна = 0 и наборот (ДК &1 &2&3)"
                                            , d-card
                                            , obj-type
                                            , obj-code)).
          return no.
        end.
        assign
        buft_Dis-tot_obj.gds-dis-base  = gds-dis-base
        buft_Dis-tot_obj.gds-dis-rubl  = gds-dis-rubl
        buft_Dis-tot_obj.gds-tot-base  = gds-tot-base
        buft_Dis-tot_obj.gds-tot-rubl  = gds-tot-rubl
        buft_Dis-tot_obj.pay-tot-base  = pay-tot-base
        buft_Dis-tot_obj.pay-tot-rubl  = pay-tot-rubl
        buft_dis-tot_obj.gds-tot-b0    = gds-tot-b0
        buft_dis-tot_obj.gds-tot-r0    = gds-tot-r0
        buft_Dis-tot_obj.num-chk       = num-chk
        .
        glog = no.
        if v_bh:available then  do:
          glog = v_bh:buffer-compare(v_tbh).
        end.
        if not glog
        or v-h-action = integer({&hn-create})
        then do:
          if temp >= 0 then do:
            loc-action = v-h-action .
            if v-h-action = integer({&hn-create}) then do:
              find first buf_Dis-card no-lock where
              buf_Dis-card.d-card = d-card no-error.
              if not available buf_dis-card then do:
                undo, return error substitute( "&1. Не найдена ДК &2 при создании итога по ДК по &3&4"
                                              , vss-include-info{&vssseq}
                                              , d-card
                                              , obj-type
                                              , obj-code
                                              ).
              end.
              assign
              type#                        = buf_dis-card.type
              emitent-host-code#           = buf_dis-card.emitent-host-code
              .
              do transaction :
                glog = v_tbh:buffer-copy( buffer buf_Dis-card:handle).
                glog = v_bh:buffer-create( ).
                glog = v_bh:buffer-copy( v_tbh).
              end.
              v-h-action = integer({&hn-update}) .
          end.
            /*надо послать primary и с-*/
            run dis-objh_write-dis-obj-rul in v_gc ( buffer buf_dis-tot_obj
                                                    ,input type#
                                                    ,input emitent-host-code#
                                                    ,input 1 /*p-dtm-code*/
                                                    ,input loc-action).
            do transaction :
              glog = v_bh:buffer-copy( v_tbh).
            end.
            run dis-objh_send-dis-obj-rul in v_gc ( buffer buf_dis-tot_obj
                                                    ,input type#
                                                    ,input emitent-host-code#
                                                    ,input 1 /*p-dtm-code*/
                                                    ,input loc-action).
          end. /*if temp >= 0 then do:*/
          do transaction :
            glog = v_bh:buffer-release() no-error .
          end.
          if error-status:error then do:
            undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
          end.
          if temp < 0 then do:
            run tempcont_create-changes in v_cnt (
                                            input {&table_dis-obj}
                                           ,input v_bh
                                           ,input v_tbh
                                           ,input v-h-action) no-error.
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1)).
            end.
          end. /*if temp < 0 then do:*/
        end. /*если изменилось*/
    end. /*if d-card <> '':U then do:*/
  end method.
   method public logical find_dis-tot_obj ( p-d-card as character, p-obj-type as character, p-obj-code as integer):
   define variable glog as logical no-undo .
   define buffer buf_dis-card for ub.dis-card.
    dis-tot_objrelease_().
    clear_().
    if p-d-card <> '':U then do:
      v-h-action           = integer({&hn-update}).
      do transaction :
        assign
        glog =  v_bh:find-first( substitute('where d-card = "&1" and obj-type = "&2" and obj-code = &3 and dt-code = &4'
                                , p-d-card
                                , p-obj-type
                                , p-obj-code
                                , dt-code
                                ), lock, wait) no-error .
      end.
      if not glog then do:
        if lock = No-LOCK then do:
          if v_tbh:available then do:
            do transaction :
              assign glog = v_tbh:buffer-delete() no-error .
            end.
          end.
          return no.
        end.
        if wait = NO-WAIT
        and v_bh:locked then do:
          if v_tbh:available then do:
            do transaction :
              assign glog = v_tbh:buffer-delete() no-error .
            end.
          end.
          return error substitute("Запись итогов ДК &1 по &2&3 занята", p-d-card, p-obj-type, p-obj-code).
        end.
        if v_tbh:available then do:
          do transaction :
            assign glog = v_tbh:buffer-delete() no-error .
          end.
        end.
        return no.
      end.
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card no-error .
      if not available buf_dis-card then do:
         return error substitute("Не найдена ДК &1", p-d-card).
      end.
      assign
      v-h-action           = integer({&hn-update})
      card-num             = buf_dis-tot_obj.card-num
      gds-dis-base         = buf_dis-tot_obj.gds-dis-base
      gds-dis-rubl         = buf_dis-tot_obj.gds-dis-rubl
      gds-tot-base         = buf_dis-tot_obj.gds-tot-base
      gds-tot-rubl         = buf_dis-tot_obj.gds-tot-rubl
      gds-tot-b0           = buf_dis-tot_obj.gds-tot-b0
      gds-tot-r0           = buf_dis-tot_obj.gds-tot-r0
      pay-tot-base         = buf_dis-tot_obj.pay-tot-base
      pay-tot-rubl         = buf_dis-tot_obj.pay-tot-rubl
      num-chk              = buf_dis-tot_obj.num-chk
      d-card               = buf_dis-tot_obj.d-card
      first-card           = buf_dis-tot_obj.first-card
      first-main-card      = buf_dis-tot_obj.first-main-card
      main-card            = buf_dis-tot_obj.main-card
      obj-type             = buf_dis-tot_obj.obj-type
      obj-code             = buf_dis-tot_obj.obj-code
      host-code            = buf_dis-tot_obj.host-code
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
  method public logical create_dis-tot_obj_date ( input p-d-card as character
                                             ,input p-obj-type as character
                                             ,input p-obj-code as integer
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
        undo, return error substitute( "&1. Не найден Период для даты &2 в справочнике итогов&3"
                                       , vss-include-info{&vssseq}
                                       , string(p-date, "99/99/9999")
                                       , {&new-line}
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     caller_id = buf_prop-ref.caller_id.
     glog = create_dis-tot_obj ( p-d-card , p-obj-type , p-obj-code ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
  end.
  method public logical create_dis-tot_obj_sum-id ( input p-d-card as character
                                             ,input p-obj-type as character
                                             ,input p-obj-code as integer
                                             ,input p-sum-id as character
                                             ,input p-caller-id as character
                                          ):
    define variable glog as logical no-undo .
    define buffer buf_prop-ref for ub.prop-ref.
     find last buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = dtm-code
            and buf_prop-ref.sum-id = p-sum-id
            and buf_prop-ref.caller_id = p-caller-id use-index idtsum
            no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден ИТОГ &2 в справочнике итогов&3"
                                       , vss-include-info{&vssseq}
                                       , p-sum-id
                                       , {&new-line}
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     caller_id = buf_prop-ref.caller_id.
     glog = create_dis-tot_obj ( p-d-card , p-obj-type , p-obj-code ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
  end.
  method public logical create_dis-tot_obj ( input p-d-card as character
                                             ,input p-obj-type as character
                                             ,input p-obj-code as integer):
    define variable glog as logical no-undo .
    define buffer buf_clients for ub.clients.
    define buffer buf_dis-card for ub.dis-card.
    define buffer buf_sysconf for ub.sysconf.
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code no-error.
    if not available buf_clients
    or not (p-obj-type = {&shop} or p-obj-type = {&stock})
    then do:
      run set-error in v_gc (substitute("Неверно задан объект для создания итого по ДК(ДК &1 &2&3)"
                                        , d-card
                                        , p-obj-type
                                        , p-obj-code)).
      return no.
    end.
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = buf_clients.host-code no-error.
    if not available buf_clients then do:
      run set-error in v_gc (substitute("Неверно задан объект для создания итогов по ДК - не найдена фирма &4(ДК &1 &2&3)"
                                        , d-card
                                        , p-obj-type
                                        , p-obj-code
                                        , buf_clients.host-code
                                        )).
      return no.
    end.
    find first buf_dis-card no-lock where
             buf_dis-card.d-card = p-d-card no-error.
    do transaction :
      glog = v_tbh:buffer-create( ).
    end.
    if not available buf_dis-card then do:
      glog = no.
      run can-find_dis-card_ in v_gc ( input p-d-card
                                      ,output glog) no-error .
      if not glog then do:
        run set-error in v_gc (substitute("Неверно задана ДК для создания итогов по ДК(ДК &1 &2&3)"
                                        , d-card
                                        , p-obj-type
                                        , p-obj-code
                                          )).
        return no.
      end.
      assign
      d-card = p-d-card
      host-code            = buf_clients.host-code
      base-code            = buf_sysconf.base-code
      obj-type             = p-obj-type
      obj-code             = p-obj-code
      buft_dis-tot_obj.d-card = p-d-card
      buft_dis-tot_obj.obj-type = p-obj-type
      buft_dis-tot_obj.obj-code = p-obj-code
      buft_dis-tot_obj.host-code = buf_clients.host-code
      .
    end.
    else do:
      assign
      d-card = p-d-card
      card-num             = buf_dis-card.card-num
      first-card           = buf_dis-card.first-card
      first-main-card      = buf_dis-card.first-main-card
      main-card            = buf_dis-card.main-card
      host-code            = buf_clients.host-code
      base-code            = buf_sysconf.base-code
      obj-type             = p-obj-type
      obj-code             = p-obj-code
      buft_dis-tot_obj.d-card = p-d-card
      buft_dis-tot_obj.obj-type = p-obj-type
      buft_dis-tot_obj.obj-code = p-obj-code
      buft_dis-tot_obj.host-code = buf_clients.host-code
      buft_dis-tot_obj.card-num = buf_dis-card.card-num
      buft_dis-tot_obj.first-card     = buf_dis-card.first-card
      buft_dis-tot_obj.first-main-card = buf_dis-card.first-main-card
      buft_dis-tot_obj.main-card      = buf_dis-card.main-card
      type#                        = buf_dis-card.type
      emitent-host-code#           = buf_dis-card.emitent-host-code
      .
    end.
    assign
    buft_dis-tot_obj.dt-code        = dt-code
    gds-dis-base         = 0.0
    gds-dis-rubl         = 0.0
    gds-tot-base         = 0.0
    gds-tot-rubl         = 0.0
    gds-tot-b0           = 0.0
    gds-tot-r0           = 0.0
    pay-tot-base         = 0.0
    pay-tot-rubl         = 0.0
    num-chk              = 0
    v-byfm = no
    v-bym = no
    v-byf = no
    v-h-action           = integer({&hn-create})
    .
    return yes.
  end method.
  method private void get-byfm():
    define variable v-dis-base as decimal no-undo.
    define variable v-dis-rubl as decimal no-undo.
    define variable v-tot-base as decimal no-undo.
    define variable v-tot-rubl as decimal no-undo.
    define variable v-tot-b0 as decimal no-undo.
    define variable v-tot-r0 as decimal no-undo.
    define variable v-pay-base as decimal no-undo.
    define variable v-pay-rubl as decimal no-undo.
    define variable v-num-chk as integer no-undo .
    define buffer buf_dis-obj for ub.dis-obj.
    if not v-byfm then do:
      for each buf_dis-obj no-lock where
              buf_dis-obj.first-main-card = first-main-card
           and buf_dis-obj.dt-code = dt-code:
        assign
        v-dis-base = v-dis-base + buf_dis-obj.gds-dis-base
        v-dis-rubl = v-dis-rubl + buf_dis-obj.gds-dis-rubl
        v-tot-base = v-tot-base + buf_dis-obj.gds-tot-base
        v-tot-rubl = v-tot-rubl + buf_dis-obj.gds-tot-rubl
        v-pay-base = v-pay-base + buf_dis-obj.pay-tot-base
        v-pay-rubl = v-pay-rubl + buf_dis-obj.pay-tot-rubl
        v-tot-b0 = v-tot-b0 + buf_dis-obj.gds-tot-b0
        v-tot-r0 = v-tot-r0 + buf_dis-obj.gds-tot-r0
        v-num-chk = v-num-chk + buf_dis-obj.num-chk
        .
      end.
      assign
      gds-dis-base_byfm#  = v-dis-base
      gds-dis-rubl_byfm#  = v-dis-rubl
      gds-tot-base_byfm#  = v-tot-base
      gds-tot-rubl_byfm#  = v-tot-rubl
      gds-tot-b0_byfm#  = v-tot-b0
      gds-tot-r0_byfm#  = v-tot-r0
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
    define variable v-tot-b0 as decimal no-undo.
    define variable v-tot-r0 as decimal no-undo.
    define variable v-pay-base as decimal no-undo.
    define variable v-pay-rubl as decimal no-undo.
    define variable v-num-chk as integer no-undo .
    define buffer buf_dis-obj for ub.dis-obj.
    if not v-bym then do:
      for each buf_dis-obj no-lock where
              buf_dis-obj.main-card = main-card
           and buf_dis-obj.dt-code = dt-code:
        assign
        v-dis-base = v-dis-base + buf_dis-obj.gds-dis-base
        v-dis-rubl = v-dis-rubl + buf_dis-obj.gds-dis-rubl
        v-tot-base = v-tot-base + buf_dis-obj.gds-tot-base
        v-tot-rubl = v-tot-rubl + buf_dis-obj.gds-tot-rubl
        v-pay-base = v-pay-base + buf_dis-obj.pay-tot-base
        v-pay-rubl = v-pay-rubl + buf_dis-obj.pay-tot-rubl
        v-tot-b0 = v-tot-b0 + buf_dis-obj.gds-tot-b0
        v-tot-r0 = v-tot-r0 + buf_dis-obj.gds-tot-r0
        v-num-chk = v-num-chk + buf_dis-obj.num-chk
        .
      end.
      assign
      gds-dis-base_bym#  = v-dis-base
      gds-dis-rubl_bym#  = v-dis-rubl
      gds-tot-base_bym#  = v-tot-base
      gds-tot-rubl_bym#  = v-tot-rubl
      gds-tot-b0_bym#  = v-tot-b0
      gds-tot-r0_bym#  = v-tot-r0
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
    define variable v-tot-b0 as decimal no-undo.
    define variable v-tot-r0 as decimal no-undo.
    define variable v-pay-base as decimal no-undo.
    define variable v-pay-rubl as decimal no-undo.
    define variable v-num-chk as integer no-undo .
    define buffer buf_dis-obj for ub.dis-obj.
    if not v-byf then do:
      for each buf_dis-obj no-lock where
              buf_dis-obj.first-card = first-card
           and buf_dis-obj.dt-code = dt-code:
        assign
        v-dis-base = v-dis-base + buf_dis-obj.gds-dis-base
        v-dis-rubl = v-dis-rubl + buf_dis-obj.gds-dis-rubl
        v-tot-base = v-tot-base + buf_dis-obj.gds-tot-base
        v-tot-rubl = v-tot-rubl + buf_dis-obj.gds-tot-rubl
        v-pay-base = v-pay-base + buf_dis-obj.pay-tot-base
        v-pay-rubl = v-pay-rubl + buf_dis-obj.pay-tot-rubl
        v-tot-b0 = v-tot-b0 + buf_dis-obj.gds-tot-b0
        v-tot-r0 = v-tot-r0 + buf_dis-obj.gds-tot-r0
        v-num-chk = v-num-chk + buf_dis-obj.num-chk
        .
      end.
      assign
      gds-dis-base_byf#  = v-dis-base
      gds-dis-rubl_byf#  = v-dis-rubl
      gds-tot-base_byf#  = v-tot-base
      gds-tot-rubl_byf#  = v-tot-rubl
      gds-tot-b0_byf#  = v-tot-b0
      gds-tot-r0_byf#  = v-tot-r0
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
    return substitute("&1 &2&3 срез", d-card , obj-type, obj-code, dt-code ).
  end method.
end class.
