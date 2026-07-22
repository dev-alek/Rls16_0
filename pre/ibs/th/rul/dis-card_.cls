block-level on error undo, throw.
class Ibs.Th.Rul.Dis-card_:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: dis-card_.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_gc as handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_cnt as widget-handle no-undo.
  define protected variable v_qh as handle no-undo.
  define public variable v_bh as handle no-undo.
  define protected buffer buf_dis-card_ for ub.dis-card.
  define protected temp-table t-dis-card_ no-undo like ub.dis-card.
  define protected buffer buft_dis-card_ for t-dis-card_.
  define protected buffer bufq_dis-card_ for ub.dis-card.
  define query query_dis-card_ for bufq_dis-card_ scrolling.
  define public variable v_tbh as handle no-undo.
  define protected variable v_tcbh as handle no-undo .
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
  define private variable v-error-flag as logical no-undo .
  define protected variable find_no-error as logical no-undo .
  define private temp-table tt0-dis-card-property  no-undo like ub.dis-card-property.
  define public variable card-num as integer no-undo .
  define public variable cash-d-pcnt as decimal no-undo .
  define public variable category as integer no-undo .
  define public variable cli-code as integer no-undo .
  define public variable cli-message as character no-undo .
  define public variable cli-type as character no-undo .
  define public variable credit-card as logical no-undo .
  define public variable d-card as character no-undo .
  define public variable d-pcnt-method as integer no-undo .
  define public variable d-pcnt as decimal no-undo .
  define public variable debet-card as logical no-undo .
  define public variable emitent-host-code as integer no-undo .
  define public variable first-card as character no-undo .
  define public variable first-main-card as character no-undo .
  define public variable is-subsid as logical no-undo .
  define public variable issue-code as integer no-undo .
  define public variable issue-date as date no-undo .
  define public variable lim-kr as decimal no-undo .
  define public variable main-card as character no-undo .
  define public variable mask-card as logical no-undo .
  define public variable overissue-num as integer no-undo .
  define public variable saldo-base as decimal no-undo .
  define public variable saldo-rubl as decimal no-undo .
  define public variable service-db-num as integer no-undo .
  define public variable sourced-card as character no-undo .
  define public variable staff-card as logical no-undo .
  define public variable status_ as character no-undo .
  define public variable type as character no-undo .
  define public variable valid-date as date no-undo .
  define public variable valid-from as date no-undo .
  define public property issue-date# as date
  get:
  define buffer buf_dis-card for ub.dis-card.
    if d-card = first-card then return issue-date.
    else do:
      find first buf_Dis-card no-lock where
                buf_Dis-card.d-card = first-card no-error.
      if available buf_Dis-card then do:
        return buf_dis-card.issue-date.
      end.
      else do:
        run set-error in v_gc (substitute("Неверное значение № первой карты &1 для карты &2"
                                        , first-card
                                        , d-card)).
        return ?.
      end.
    end.
  end get.
  private set.
  define public property is-over# as logical
  get.
  private set.
  define public property is-main-first-card# as logical
  get.
  private set.
  define public property is-first-card# as logical
  get.
  private set.
  CONSTRUCTOR PUBLIC dis-card_(
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
run garbcoll_create-gc-entry in p-gc-handle (input 'dis-card_',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта dis-card_", vss-include-info0).
end.
v_bh = buffer buf_dis-card_:handle.
v_tbh = buffer buft_dis-card_:handle.
   if temp < 0 then do:
      run tempcont_get-buffer-handle in v_cnt ( input 'dis-card':U
                                               ,output v_tcbh).
   end.
    d-card = '':U .
    v_qh = query query_dis-card_:handle.
  end constructor.
  destructor public dis-card_():
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    find_dis-card_ ( input '':U).
  end destructor.
  method public void Dis-card_release_ ( ):
    define variable glog as logical no-undo .
    do transaction :
      glog = v_bh:buffer-release() no-error .
    end.
    clear_().
  end method.
  method public handle get_dis-card_ ( ):
    return v_tbh.
  end method.
  method public handle get_dis-card_field ( input p-field-name as character ):
    return v_tbh:buffer-field(p-field-name).
  end method.
  method public logical find_dis-card_no-error ( p-d-card as character):
    define variable glog as logical no-undo .
    assign
    find_no-error = yes.
    glog = find_dis-card_ ( input p-d-card) no-error.
    return glog.
  end method.
  method public logical dis-card_save ( ):
   define variable glog as logical no-undo .
   define variable loc-action as integer no-undo .
   if d-card <> '':U then do:
      if cash-d-pcnt = ?
      or cash-d-pcnt > 100
      or cash-d-pcnt < 0 then do:
        run set-error in v_gc (substitute("Неверное значение % скидки на итог &1 для ДК &2"
                                        , cash-d-pcnt
                                        , d-card)).
        return no.
      end.
      if d-pcnt = ?
      or d-pcnt > 100
      or d-pcnt < 0 then do:
        run set-error in v_gc (substitute("Неверное значение % скидки &1 для ДК &2"
                                        , d-pcnt
                                        , d-card)).
        return no.
      end.
      assign
      buft_dis-card_.cash-d-pcnt =  cash-d-pcnt
      buft_dis-card_.category    =  category
      buft_dis-card_.cli-message =  cli-message
      buft_dis-card_.d-pcnt      =  d-pcnt
      buft_dis-card_.valid-date  =  valid-date
      buft_dis-card_.valid-from  =  valid-from
      buft_dis-card_.cli-code    =  (if v-h-action = integer('1':U)
                                     then cli-code
                                     else buft_dis-card_.cli-code)
      buft_dis-card_.cli-type    =  (if v-h-action = integer('1':U)
                                     then cli-type
                                     else buft_dis-card_.cli-type)
      buft_dis-card_.issue-code  =  (if v-h-action = integer('1':U)
                                     then issue-code
                                     else buft_dis-card_.issue-code)
      buft_dis-card_.issue-date  =   issue-date
      buft_dis-card_.status_     =  (if buft_dis-card_.status_ <> status_
                                     and  lookup(status_, 'тек':U + chr(4) +
                                                          'удал':U + chr(4) +
                                                          'блок':U, chr(4) ) > 0
                                     and lookup(buft_dis-card_.status_ , 'неисп':U + chr(4) + 'смкли':U, chr(4) ) = 0
                                     then status_
                                     else buft_dis-card_.status_)
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
          if temp = 1 then do:
            run tempcont_create-changes in v_cnt (
                                            input 'dis-card':U
                                          ,input v_bh
                                          ,input v_tbh
                                          ,input v-h-action
                                          ) no-error.
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
          end.
          if v-h-action = integer('1':U) then do:
            define variable dc-ri as recid no-undo .
            run ref/dcardi01.p (
                             input v_pp
                            ,input v_ph
                            ,input v_lh
                            ,input v_gc
                            ,input yes
                            ,input-output dc-ri
                            ,input 'ДОБАВЛЕНИЕ-ИМПОРТ':U
                            ,input "rum"
                            ,input v-curr-obj-type
                            ,input v-curr-obj-code
                            ,input buft_dis-card_.d-card
                            ,input buft_dis-card_.emitent-host-code
                            ,input buft_dis-card_.cli-type
                            ,input buft_dis-card_.cli-code
                            ,input 'тек':U
                            ,input buft_dis-card_.type
                            ,input buft_dis-card_.d-pcnt
                            ,input buft_dis-card_.cash-d-pcnt
                            ,input buft_dis-card_.category
                            ,input buft_dis-card_.d-pcnt-method
                            ,input buft_dis-card_.credit-card
                            ,input buft_dis-card_.lim-kr
                            ,input buft_dis-card_.debet-card
                            ,input buft_dis-card_.staff-card
                            ,input buft_dis-card_.issue-date
                            ,input buft_dis-card_.issue-code
                            ,input buft_dis-card_.valid-from
                            ,input buft_dis-card_.valid-date
                            ,input buft_dis-card_.sourced-card
                            ,input buft_dis-card_.cli-message
                            ,input buft_dis-card_.mask-card
                            ,input (if is-subsid
                                    then buft_dis-card_.main-card
                                    else buft_dis-card_.d-card)
                            ,input buft_dis-card_.is-subsid
                            ,INPUT no
                            ,INPUT table tt0-dis-card-property
                            ) no-error .
            if error-status:error then do:
              run set-error in v_gc (substitute("Ошибка при сохранении записи ДК &1:&2&3&2&4"
                                              , d-card
                                              , chr(10)
                                              , error-status:get-message(1)
                                              , return-value )).
              return no.
            end.
            do transaction:
              assign
              glog =  v_bh:find-first( substitute('where recid(buf_dis-card_) = &1', dc-ri), lock, wait) no-error .
            end.
            if not glog then do:
              run set-error in v_gc (substitute("Ошибка при создании ДК &1:&2не найдена ДК с recid &3"
                                    , d-card
                                    , chr(10)
                                    , string(dc-ri)
                                    )).
              return no.
            end.
            v-h-action = integer('2':U).
          end.
          else do:
            run discardh_write-dis-card-rul in v_gc ( buffer buf_dis-card_
                                                      ,input type
                                                      ,input emitent-host-code
                                                      ,input loc-action).
            do transaction :
              glog = v_bh:buffer-copy( v_tbh).
            end.
            run discardh_send-dis-card-rul in v_gc ( buffer buf_dis-card_
                                                      ,input type
                                                      ,input emitent-host-code
                                                      ,input loc-action).
            v_bh:buffer-field("trg-param"):buffer-value = 'no-callnews':U + chr(44) + 'no-hist':U.
            run cb_create-dc-list in v_ph ( input v_bh) no-error.
            do transaction :
              glog = v_bh:buffer-release() no-error .
            end.
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0 , return-value, chr(10), error-status :get-message (1)).
            end.
          end.
        end.
        if temp = -1 then do:
          run tempcont_create-changes in v_cnt (
                                          input 'dis-card':U
                                         ,input v_bh
                                         ,input v_tbh
                                         ,input v-h-action
                                         ) no-error.
          if error-status:error then do:
            undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
          end.
        end.
        if temp = -2 then do:
          run tempcont_create-record in v_cnt (
                                          input 'dis-card':U
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
  method public logical find_dis-card_ ( p-d-card as character):
   define variable glog as logical no-undo .
   dis-card_release_().
   clear_().
    if p-d-card <> '':U then do:
      v-h-action           = integer('2':U).
      do transaction:
        assign
        glog =  v_bh:find-first( substitute('where d-card = "&1"', p-d-card), lock, wait) no-error .
      end.
      if not glog then do:
        if find_no-error then do:
          return no.
        end.
        else do:
          run set-error in v_gc (substitute("Не найдена ДК &1", p-d-card)).
          return error .
        end.
        if lock = No-LOCK then do:
          if v_tbh:available then do:
            do transaction :
              assign glog = v_tbh:buffer-delete() no-error .
            end.
          end.
          return error substitute("Не найдена ДК &1", p-d-card).
        end.
        if wait = NO-WAIT
        and v_bh:locked then do:
          if v_tbh:available then do:
            do transaction :
              assign glog = v_tbh:buffer-delete() no-error .
            end.
          end.
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("ДК &1 занята", p-d-card).
          end.
        end.
      end.
      if temp < 0 then do:
        assign
        glog = v_tcbh:find-first( substitute( ' where d-card = "&1"', p-d-card)) no-error .
        if v_tcbh:available then do:
          glog = v_tbh:find-first( substitute( ' where d-card = "&1"', p-d-card)) no-error .
          do transaction :
            if not v_tbh:available then do:
              glog = v_tbh:buffer-create( ).
            end.
            glog = v_tbh:buffer-copy( v_tcbh).
          end.
          assign
          v-h-action           = integer('2':U)
          card-num             = buft_dis-card_.card-num
          cash-d-pcnt          = buft_dis-card_.cash-d-pcnt
          category             = buft_dis-card_.category
          cli-code             = buft_dis-card_.cli-code
          cli-message          = buft_dis-card_.cli-message
          cli-type             = buft_dis-card_.cli-type
          credit-card          = buft_dis-card_.credit-card
          d-card               = buft_dis-card_.d-card
          d-pcnt-method        = buft_dis-card_.d-pcnt-method
          d-pcnt               = buft_dis-card_.d-pcnt
          debet-card           = buft_dis-card_.debet-card
          emitent-host-code    = buft_dis-card_.emitent-host-code
          first-card           = buft_dis-card_.first-card
          first-main-card      = buft_dis-card_.first-main-card
          is-subsid            = buft_dis-card_.is-subsid
          issue-code           = buft_dis-card_.issue-code
          issue-date           = buft_dis-card_.issue-date
          lim-kr               = buft_dis-card_.lim-kr
          main-card            = buft_dis-card_.main-card
          mask-card            = buft_dis-card_.mask-card
          overissue-num        = buft_dis-card_.overissue-num
          saldo-base           = buft_dis-card_.saldo-base
          saldo-rubl           = buft_dis-card_.saldo-rubl
          sourced-card         = buft_dis-card_.sourced-card
          staff-card           = buft_dis-card_.staff-card
          status_              = buft_dis-card_.status_
          type                 = buft_dis-card_.type
          valid-from           = buft_dis-card_.valid-from
          valid-date           = buft_dis-card_.valid-date
          service-db-num       = buft_dis-card_.service-db-num
          is-over#             = (buft_dis-card_.sourced-card <> '':U)
          is-main-first-card#  = (buft_dis-card_.d-card = buft_dis-card_.first-main-card)
          is-first-card#       = (buft_dis-card_.d-card = buft_dis-card_.first-card)
          .
        end.
      end.
      if temp >= 0 or v_tcbh:available = no then do:
        assign
        v-h-action           = integer('2':U)
        card-num             = buf_dis-card_.card-num
        cash-d-pcnt          = buf_dis-card_.cash-d-pcnt
        category             = buf_dis-card_.category
        cli-code             = buf_dis-card_.cli-code
        cli-message          = buf_dis-card_.cli-message
        cli-type             = buf_dis-card_.cli-type
        credit-card          = buf_dis-card_.credit-card
        d-card               = buf_dis-card_.d-card
        d-pcnt-method        = buf_dis-card_.d-pcnt-method
        d-pcnt               = buf_dis-card_.d-pcnt
        debet-card           = buf_dis-card_.debet-card
        emitent-host-code    = buf_dis-card_.emitent-host-code
        first-card           = buf_dis-card_.first-card
        first-main-card      = buf_dis-card_.first-main-card
        is-subsid            = buf_dis-card_.is-subsid
        issue-code           = buf_dis-card_.issue-code
        issue-date           = buf_dis-card_.issue-date
        lim-kr               = buf_dis-card_.lim-kr
        main-card            = buf_dis-card_.main-card
        mask-card            = buf_dis-card_.mask-card
        overissue-num        = buf_dis-card_.overissue-num
        saldo-base           = buf_dis-card_.saldo-base
        saldo-rubl           = buf_dis-card_.saldo-rubl
        sourced-card         = buf_dis-card_.sourced-card
        staff-card           = buf_dis-card_.staff-card
        status_              = buf_dis-card_.status_
        type                 = buf_dis-card_.type
        valid-from           = buf_dis-card_.valid-from
        valid-date           = buf_dis-card_.valid-date
        service-db-num       = buf_dis-card_.service-db-num
        is-over#             = (buf_dis-card_.sourced-card <> '':U)
        is-main-first-card#  = (buf_dis-card_.d-card = buf_dis-card_.first-main-card)
        is-first-card#       = (buf_dis-card_.d-card = buf_dis-card_.first-card)
        .
        do transaction :
          glog = v_tbh:buffer-create( ).
          glog = v_tbh:buffer-copy( v_bh).
        end.
      end.
    end.
    return yes.
  end method.
  method public logical create_dis-card_ (
                                             input p-curr-obj-type as character
                                            ,input p-curr-obj-code as integer
                                            ,input p-d-card as character
                                            ,input p-emitent-host-code as integer
                                            ,input p-type as character
                                            ,input p-cli-type-code as character
                                            ):
    define variable glog as logical no-undo .
    glog = create_dis-card_ ( p-curr-obj-type
                    ,p-curr-obj-code
                    ,p-d-card
                    ,p-emitent-host-code
                    ,p-type
                    ,p-cli-type-code
                    ,p-d-card
                    ,p-d-card
                    ,p-d-card
                    ,'':U
                    ) no-error .
    return glog.
  end method.
  method public logical create_dis-card_ (
                                             input p-curr-obj-type as character
                                            ,input p-curr-obj-code as integer
                                            ,input p-d-card as character
                                            ,input p-emitent-host-code as integer
                                            ,input p-type as character
                                            ,input p-cli-type-code as character
                                            ,input p-first-main-card as character
                                            ,input p-first-card as character
                                            ,input p-main-card as character
                                            ,input p-sourced-card as character
                                            ):
    define variable glog as logical no-undo .
    DEFINE VARIABLE v-today as date no-undo .
    DEFINE VARIABLE v-time as integer no-undo .
    define buffer buf_sysconf for ub.sysconf.
    define buffer buf_dis-card for ub.dis-card.
    define buffer buf_dis-card-type for ub.dis-card-type.
    define buffer buf_clients for ub.clients.
    find first buf_dis-card no-lock where
             buf_dis-card.d-card = p-d-card no-error.
    if available buf_dis-card then do:
      return no.
    end.
    if length(p-d-card) > 19 then do:
      run set-error in v_gc (substitute("Нельзя создать ДК (&1) с номером длиннее 19 символов", p-d-card)).
      return no.
    end.
    if trim(p-d-card, "1234567890") <> '':U then do:
      run set-error in v_gc (substitute("№ ДК (&1) может состоять только из цифр", p-d-card)).
      return no.
    end.
    find first buf_dis-card-type no-lock where
              buf_dis-card-type.type = p-type
          and buf_dis-card-type.emitent-host-code = p-emitent-host-code no-error.
    if not available buf_Dis-card-type then do:
      run set-error in v_gc (substitute("Не найден тип ДК &3: эмитент &1 тип &2", p-emitent-host-code, p-type, p-d-card)).
      return no.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = substring(p-cli-type-code, 1, 3)
          and buf_clients.obj-code = integer(substring(p-cli-type-code, 4)) no-error.
    if (not available buf_clients and integer(substring(p-cli-type-code, 4)) > 0)
    or not (substring(p-cli-type-code, 1, 3) = 'чел':U
            or
            substring(p-cli-type-code, 1, 3) = 'орг':U) then do:
      run can-find_clients_  in v_gc ( input substring(p-cli-type-code, 1, 3)
                                      ,integer(substring(p-cli-type-code, 4))
                                      ,output glog) no-error .
      if not glog then do:
        run set-error in v_gc (substitute("Не найден клиент-держатель &1 или неверный тип клиента &2 для &3"
                                        , p-cli-type-code
                                        , substring(p-cli-type-code, 1, 3)
                                        , p-d-card
                                        )).
        return no.
      end.
    end.
    if p-first-main-card <> p-d-card then do:
       find first buf_dis-card no-lock where
                buf_Dis-card.d-card = p-first-main-card no-error.
       if not available buf_Dis-card then do:
        run set-error in v_gc (substitute("Не найдена ДК &1, указанная как ПЕРВАЯ ОСНОВНАЯ КАРТА для  &2"
                                        , p-first-main-card
                                        ,p-d-card
                                        )).
        return no.
       end.
    end.
    if p-main-card <> p-d-card then do:
       find first buf_dis-card no-lock where
                buf_Dis-card.d-card = p-main-card no-error.
       if not available buf_Dis-card then do:
        run set-error in v_gc (substitute("Не найдена ДК &1, указанная как ОСНОВНАЯ КАРТА для &2"
                                        , p-main-card
                                        ,p-d-card
                                        )).
        return no.
       end.
    end.
    if p-first-card <> p-d-card then do:
       find first buf_dis-card no-lock where
                buf_Dis-card.d-card = p-first-card no-error.
       if not available buf_Dis-card then do:
        run set-error in v_gc (substitute("Не найдена ДК &1, указанная как ПЕРВАЯ КАРТА для &1"
                                        , p-first-card
                                        ,p-d-card
                                        )).
        return no.
       end.
    end.
    if p-sourced-card <> '':U then do:
       find first buf_dis-card no-lock where
                buf_Dis-card.d-card = p-sourced-card no-error.
       if not available buf_Dis-card then do:
        run set-error in v_gc (substitute("Не найдена ДК &1, указанная как ПЕРЕВЫПУСКАЕМАЯ к &2"
                                        , p-sourced-card
                                        ,p-d-card)).
        return no.
       end.
    end.
    if p-curr-obj-type <> '':U
      or p-curr-obj-code <> 0 then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = p-curr-obj-type
            and buf_clients.obj-code = p-curr-obj-code no-error.
      if not available buf_clients
      or not(buf_clients.obj-type = 'маг':U
            or
            buf_clients.obj-type = 'скл':U)
      then do:
        run set-error in v_gc (substitute("Не найден текущий объект &1&2 или неверный тип объекта &2"
                                        , p-curr-obj-type
                                        , p-curr-obj-code)).
        return no.
      end.
      if p-emitent-host-code <> 0
      and buf_clients.host-code <> p-emitent-host-code then do:
        run set-error in v_gc (substitute("Текущий объект &1&2 принадлежит фирме &3, а эмитент карты - фирма &4"
                                        , p-curr-obj-type
                                        , p-curr-obj-code
                                        , buf_clients.host-code
                                        , p-emitent-host-code
                                        )).
        return no.
      end.
    end.
    assign
    v-curr-obj-type = p-curr-obj-type
    v-curr-obj-code = p-curr-obj-code
    .
    do transaction :
      glog = v_tbh:buffer-create().
    end.
    assign
    d-card                           = p-d-card
    emitent-host-code                = p-emitent-host-code
    type                             = p-type
    first-card                       = p-first-card
    first-main-card                  = p-first-main-card
    main-card                        = p-main-card
    is-subsid                        = (d-card <> main-card)
    mask-card                        = no
    card-num                         = 0
    cli-code                         = integer(substring(p-cli-type-code, 4))
    cli-type                         = substring(p-cli-type-code, 1, 3)
    sourced-card                     = p-sourced-card
    overissue-num                    = ?
    issue-code                       = 0
    issue-date                       = v-today
    cash-d-pcnt                      = 0.0
    category                         = 0
    cli-message                      = '':U
    credit-card                      = no
    d-pcnt-method                    = integer('1':U)
    d-pcnt                           = 0.0
    debet-card                       = no
    lim-kr                           = 0.0
    saldo-base                       = 0.0
    saldo-rubl                       = 0.0
    staff-card                       = no
    status_                          = 'тек':U
    valid-date                       = ?
    valid-from                       = v-today
    service-db-num                   = 0
    is-over#                         = (sourced-card <> '':U)
    is-main-first-card#              = (d-card = first-main-card)
    is-first-card#                   = (d-card = first-card)
    buft_dis-card_.d-card            = d-card
    buft_dis-card_.emitent-host-code = emitent-host-code
    buft_dis-card_.type              = type
    buft_dis-card_.first-card        = first-card
    buft_dis-card_.first-main-card   = first-main-card
    buft_dis-card_.main-card         = main-card
    buft_dis-card_.is-subsid         = is-subsid
    buft_dis-card_.card-num          = 0
    buft_dis-card_.mask-card         = mask-card
    buft_dis-card_.cli-code          = cli-code
    buft_dis-card_.cli-type          = cli-type
    buft_dis-card_.sourced-card      = sourced-card
    buft_dis-card_.overissue-num     = overissue-num
    buft_dis-card_.issue-code        = issue-code
    buft_dis-card_.issue-date        = issue-date
    buft_dis-card_.cash-d-pcnt       = cash-d-pcnt
    buft_dis-card_.category          = category
    buft_dis-card_.cli-message       = cli-message
    buft_dis-card_.credit-card       = credit-card
    buft_dis-card_.d-pcnt-method     = d-pcnt-method
    buft_dis-card_.d-pcnt            = d-pcnt
    buft_dis-card_.debet-card        = debet-card
    buft_dis-card_.lim-kr            = lim-kr
    buft_dis-card_.saldo-base        = saldo-base
    buft_dis-card_.saldo-rubl        = saldo-rubl
    buft_dis-card_.staff-card        = no
    buft_dis-card_.status_           = status_
    buft_dis-card_.valid-date        = valid-date
    buft_dis-card_.valid-from        = valid-from
    buft_dis-card_.service-db-num    = service-db-num
    v-h-action                       = integer('1':U)
    .
    run create_dis-card_ in v_gc ( input d-card) no-error .
    return yes.
  end method.
  method public logical select_dis-cards ( input p-prepare-phrase as character):
    define variable glog as logical no-undo.
    assign
    glog = v_qh:query-prepare( "for each bufq_dis-card_ where " + p-prepare-phrase) no-error .
    if not glog then do:
      return error substitute("Ошибка подготовки выборки по ДК:&1&2&1&3"
                               , chr(10)
                               , error-status:get-message(1)
                               , p-prepare-phrase).
    end.
    assign
    glog = v_qh:query-open no-error .
    if error-status:error then do:
      return error substitute("Ошибка открытия выборки по ДК:&1&2&1&3"
                               , chr(10)
                               , error-status:get-message(1)
                               , v_qh:prepare-string ).
    end.
  end method.
  method public logical get_dis-card_( input p-rec-pos as character):
    define variable glog as logical no-undo .
    if not v_qh:is-open then do:
      return error substitute("Выборка по ДК:&1(&2)&1еще на открыта"
                              , chr(10)
                              , v_qh:prepare-string
                               ).
    end.
    do transaction:
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
    end.
    if glog then do:
       assign
       glog = find_dis-card_ ( input bufq_dis-card_.d-card) no-error .
    end.
    return glog.
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
method public logical esys-add-dump (
                                          input p-esys-cmd-proc-handle as handle
                                        , input p-esys-cmd-code as integer
                                        , input p-action as character     ):
  define variable v-esys-rec-ord as integer no-undo .
  run add-dump in p-esys-cmd-proc-handle
    (input p-esys-cmd-code
    ,input 'dis-card':U
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
    return d-card.
  end method.
end class.
