block-level on error undo, throw.
class Ibs.Th.Rul.clients_:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: clients_.cls $ $Revision: aea5316774be, 0, rls $".
  define protected variable v_gc as handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_cnt as widget-handle no-undo.
  define public variable v_bh as handle no-undo.
  define public variable v_bfh as handle no-undo.
  define public variable v_bph as handle no-undo.
  define protected buffer buf_clients_ for ub.clients.
  define protected temp-table t-clients_ no-undo like ub.clients.
  define protected buffer buft_clients_ for t-clients_.
  define protected buffer buf_person_ for ub.person.
  define protected temp-table t-person_ no-undo like ub.person.
  define protected buffer buft_person_ for t-person_.
  define protected buffer buf_firm_ for ub.firm.
  define protected temp-table t-firm_ no-undo like ub.firm.
  define protected buffer buft_firm_ for t-firm_.
  define public variable v_tbh as handle no-undo.
  define public variable v_tbfh as handle no-undo.
  define public variable v_tbph as handle no-undo.
  define private variable v-h-action as integer no-undo .
  define private variable v-callpoint as character no-undo .
  define private variable v-error-flag as logical no-undo .
  define public variable temp as integer no-undo.
  define public property lock as integer
  get.
  set.
  define public property wait as integer
  get.
  set.
  define protected variable find_no-error as logical no-undo .
  define public variable obj-type as character no-undo .
  define public variable obj-code as integer no-undo .
  define public variable obj-name as character no-undo .
  define public variable grp-code as integer no-undo .
  define public variable PS as character no-undo .
  define public variable stts as integer no-undo .
  define public variable phone   as character no-undo .
  define public variable name1 as character no-undo .
  define public variable name2 as character no-undo .
  CONSTRUCTOR PUBLIC clients_(
                               input parparentproc as widget-handle
                              ,input p-parent-handle as handle
                              ,input p-log-handle as handle
                              ,input p-gc-handle as handle
                              ,input p-cont-handle as handle
                              ,input p-lock as integer
                              ,input p-wait as integer
                              ,input p-temp as integer
                              ,input p-callpoint as character
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
run garbcoll_create-gc-entry in p-gc-handle (input 'clients_',  input this-object) no-error.
if error-status:error then do:
  return error substitute("&1 Ошибка создания объекта clients_", vss-include-info0).
end.
v_bh = buffer buf_clients_:handle.
v_tbh = buffer buft_clients_:handle.
    v_bfh = buffer buf_firm_:handle.
    v_tbfh = buffer buft_firm_:handle.
    v_bph = buffer buf_person_:handle.
    v_tbph = buffer buft_person_:handle.
    assign
    obj-type = '':U
    obj-code = 0
    v-callpoint = p-callpoint
    .
  end constructor.
  destructor public clients_():
    define variable glog as logical no-undo .
    assign
    glog = v_tbh:empty-temp-table() no-error .
    assign
    glog = v_tbfh:empty-temp-table() no-error .
    assign
    glog = v_tbph:empty-temp-table() no-error .
    find_clients_ ( input '':U, input 0).
  end destructor.
  method public void clients_release_ ( ):
    define variable glog as logical no-undo .
    define variable glogf as logical no-undo .
    define variable glogp as logical no-undo .
    glog = v_bh:buffer-release() no-error .
    if obj-type = 'орг':U then do:
      glogf = v_bfh:buffer-release() no-error .
    end.
    if obj-type = 'чел':U then do:
      glogp = v_bph:buffer-release() no-error .
    end.
    clear_().
  end method.
  method public handle get_clients_ ( ):
    return v_bh.
  end method.
  method public logical find_clients_no-error ( p-obj-type as character, p-obj-code as integer):
    define variable glog as logical no-undo .
    assign
    find_no-error = yes.
    glog = find_clients_ ( input p-obj-type, input p-obj-code) no-error.
    return glog.
  end method.
  method public logical clients_save ( ):
   define variable glog as logical no-undo .
   define variable glogf as logical no-undo .
   define variable glogp as logical no-undo .
   define variable loc-action as integer no-undo .
    if obj-code <> 0
    or v-h-action = integer('1':U) then do:
      assign
      buft_clients_.obj-name    = obj-name
      buft_clients_.PS          = PS
      buft_clients_.stts        = stts
      buft_clients_.grp-code    = grp-code
      .
      if obj-type = 'орг':U then do:
        assign
        buft_firm_.phone = phone
        .
      end.
      if obj-type = 'чел':U then do:
        assign
        buft_person_.phone1 = phone
        buft_person_.name1  = name1
        buft_person_.name2  = name2
        .
      end.
      glog = no.
      if v_bh:available then do:
        glog = v_bh:buffer-compare(v_tbh).
        glogf = yes.
        glogp = yes.
        if obj-type = 'орг':U then
        glogf = v_bfh:buffer-compare(v_tbfh).
        if obj-type = 'чел':U then
        glogp = v_bph:buffer-compare(v_tbph).
      end.
      if not glog
      or not glogf
      or not glogp
      or v-h-action = integer('1':U)
      then do:
        if temp >= 0 then do:
          loc-action = v-h-action .
          if v-h-action = integer('1':U) then do:
            define variable v-rid as recid no-undo .
            if obj-type = 'орг':U then do:
              run ref/firm1.p (
                            input v_pp
                            ,input-output v-rid
                            ,input 'ДОБАВЛЕНИЕ-ИМПОРТ':U
                            ,input v-callpoint
                            ,input yes
                            ,input - buft_firm_.firm-code
                            ,input buft_clients_.stts
                            ,input buft_clients_.obj-name
                            ,input buft_clients_.lim-kr
                            ,input buft_clients_.PS
                            ,input buft_clients_.grp-code
                            ,input buft_firm_.addres1
                            ,input buft_firm_.addres2
                            ,input buft_firm_.city
                            ,input buft_firm_.contact-psn
                            ,input buft_firm_.director
                            ,input buft_firm_.e-mail
                            ,input buft_firm_.engl-name
                            ,input buft_firm_.fax
                            ,INPUT buft_firm_.given-by
                            ,input buft_firm_.ind
                            ,input buft_firm_.inn
                            ,INPUT yes
                            ,INPUT buft_firm_.is-pboul
                            ,input buft_firm_.kpp
                            ,input buft_firm_.okonh
                            ,input buft_firm_.okpo
                            ,INPUT buft_firm_.passp-num
                            ,INPUT buft_firm_.passp-ser
                            ,input buft_firm_.phone
                            ,input buft_firm_.phone1-note
                            ,input buft_firm_.post-addr1
                            ,input buft_firm_.post-addr2
                            ,input buft_firm_.post-city
                            ,input buft_firm_.post-ind
                            ,input buft_clients_.reg-code
                            ,input buft_firm_.telex
                            ,input buft_firm_.tobj-code
                            ,input buft_clients_.turnover-buyer
                            ,input buft_clients_.turnover-buyer-gds
              ) no-error .
            end.
            if obj-type = 'чел':U then do:
              run ref/person1.p (
                            input v_pp
                          ,input v_ph
                          ,input-output v-rid
                          ,input 'ДОБАВЛЕНИЕ-ИМПОРТ':U
                          ,input v-callpoint
                          ,input yes
                          ,input - buft_person_.psn-code
                          ,input buft_clients_.stts
                          ,input buft_clients_.obj-name
                          ,input buft_clients_.lim-kr
                          ,input buft_clients_.PS
                          ,input buft_clients_.grp-code
                          ,input buft_person_.address
                          ,input buft_person_.city
                          ,input buft_person_.date-birth
                          ,input buft_person_.e-mail
                          ,input buft_person_.fax
                          ,input buft_person_.firm-code
                          ,input buft_person_.firm-name
                          ,input buft_person_.gender
                          ,input buft_person_.given-by
                          ,input buft_person_.ind
                          ,input buft_person_.inn
                          ,input yes
                          ,input buft_person_.is-pboul
                          ,input buft_person_.kpp
                          ,input buft_person_.name1
                          ,input buft_person_.name2
                          ,input buft_person_.okonh
                          ,input buft_person_.okpo
                          ,input buft_person_.passp-num
                          ,input buft_person_.passp-ser
                          ,input buft_person_.phone1
                          ,input buft_person_.phone1-note
                          ,input buft_person_.position
                          ,input buft_person_.post-box
                          ,input buft_person_.post-address
                          ,input buft_person_.post-city
                          ,input buft_person_.post-ind
                          ,input buft_clients_.reg-code
                          ,input buft_clients_.turnover-buyer
                          ,input buft_clients_.turnover-buyer-gds
                          ) no-error .
            end.
            if error-status:error then do:
              run set-error in v_gc (substitute("Ошибка при создании клиента с типом &1:&2&3&2&4"
                                    , obj-type
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    )).
              return no.
            end.
            assign
            glog =  v_bh:find-first( substitute('where recid(buf_clients_) = &1', v-rid), lock, wait) no-error .
            if not glog then do:
              run set-error in v_gc (substitute("Ошибка при создании клиента с типом &1:&2не найден Клиент с recid &3"
                                    , obj-type
                                    , chr(10)
                                    , string(v-rid)
                                    )).
              return no.
            end.
            assign
            obj-code = buf_clients_.obj-code
            buft_clients_.obj-code = obj-code
            v-h-action = integer('2':U).
            if available buft_person_ then do:
               buft_person_.psn-code = obj-code.
            end.
            if available buft_firm_ then do:
               buft_firm_.firm-code = obj-code.
            end.
            if obj-type = 'орг':U then do:
              assign
              glog =  v_bfh:find-first( substitute('where buf_firm_.firm-code = &1', obj-code), lock, wait) no-error .
              if not glog then do:
                run set-error in v_gc (substitute("Ошибка при создании клиента с типом &1:&2не найдена &1 с кодом &3"
                                      , obj-type
                                      , chr(10)
                                      , obj-code
                                      )).
                return no.
              end.
            end.
            if obj-type = 'чел':U then do:
              assign
              glog =  v_bph:find-first( substitute('where buf_person_.psn-code = &1', obj-code), lock, wait) no-error .
              if not glog then do:
                run set-error in v_gc (substitute("Ошибка при создании клиента с типом &1:&2не найден &1 с кодом &3"
                                      , obj-type
                                      , chr(10)
                                      , obj-code
                                      )).
                return no.
              end.
            end.
            glog = v_bh:buffer-copy( v_tbh).
            run clientsh_send-clients-rul in v_gc ( buffer buf_clients_
                                                  ,input loc-action).
            if obj-type = 'орг':U then do:
              glogf = v_tbfh:buffer-copy( v_bfh).
              run clientsh_send-firm-rul in v_gc ( buffer buf_firm_
                                                  ,input loc-action).
            end.
            if obj-type = 'чел':U then do:
              glogp = v_tbph:buffer-copy( v_bph).
              run clientsh_send-person-rul in v_gc ( buffer buf_person_
                                                    ,input loc-action).
            end.
          end.
          else do:
            if glog then do:
              run clientsh_write-clients-rul in v_gc ( buffer buf_clients_
                                                      ,input loc-action).
              glog = v_bh:buffer-copy( v_tbh).
              run clientsh_send-clients-rul in v_gc ( buffer buf_clients_
                                                    ,input loc-action).
              v_bh:buffer-field("trg-param"):buffer-value = 'no-callnews':U.
              glog = v_bh:buffer-release() no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0 , return-value, chr(10), error-status :get-message (1)).
              end.
            end.
            if glogf and obj-type = 'орг':U then do:
              run clientsh_write-firm-rul in v_gc (
                                                      buffer buf_firm_
                                                      ,input loc-action).
              glogf = v_bfh:buffer-copy( v_tbfh).
              run clientsh_send-firm-rul in v_gc ( buffer buf_firm_
                                                  ,input loc-action).
              v_bfh:buffer-field("trg-param"):buffer-value = 'no-callnews':U + chr(44) + 'no-hist':U.
              glogf = v_bfh:buffer-release() no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0 , return-value, chr(10), error-status :get-message (1)).
              end.
            end.
            if glogp and obj-type = 'чел':U then do:
              run clientsh_write-person-rul in v_gc (
                                                      buffer buf_person_
                                                      ,input loc-action).
              glogp = v_bph:buffer-copy( v_tbph).
              run clientsh_send-person-rul in v_gc ( buffer buf_person_
                                                    ,input loc-action).
              v_bph:buffer-field("trg-param"):buffer-value = 'no-callnews':U + chr(44) + 'no-hist':U.
              glogp = v_bph:buffer-release() no-error .
              if error-status:error then do:
                undo, return error substitute( "&1. &2&3&4", vss-include-info0 , return-value, chr(10), error-status :get-message (1)).
              end.
            end.
          end.
        end.
        if temp < 0 then do:
          run tempcont_create-changes in v_cnt (
                                         input 'clients':U
                                        ,input v_bh
                                        ,input v_tbh
                                        ,input v-h-action
                                        ) no-error.
          if error-status:error then do:
            undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
          end.
          if obj-type = 'орг':U then do:
            run tempcont_create-changes in v_cnt (
                                            input 'firm':U
                                           ,input v_bfh
                                           ,input v_tbfh
                                           ,input v-h-action
                                           ) no-error.
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
          end.
          if obj-type = 'чел':U then do:
            run tempcont_create-changes in v_cnt (
                                            input 'person':U
                                           ,input v_bph
                                           ,input v_tbph
                                           ,input v-h-action
                                           ) no-error.
            if error-status:error then do:
              undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
            end.
          end.
        end.
      end.
    end.
    return yes.
  end method.
  method public logical find_clients_ ( p-obj-type as character, p-obj-code as integer):
   define variable glog as logical no-undo .
   define variable glogf as logical no-undo .
   define variable glogp as logical no-undo .
    clients_release_().
    clear_().
    if p-obj-code <> 0 then do:
      v-h-action           = integer('2':U).
      assign
      glog =  v_bh:find-first( substitute('where obj-type = "&1" and obj-code = &2', p-obj-type, p-obj-code), lock, wait) no-error .
      if not glog then do:
        if lock = No-LOCK then do:
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("Не найден клиент &1&2", p-obj-type, p-obj-code).
          end.
        end.
        if wait = NO-WAIT
        and v_bh:locked then do:
          if find_no-error then do:
            return no.
          end.
          else do:
            return error substitute("Клиент &1&2 занят", p-obj-type, p-obj-code).
          end.
        end.
      end.
      if v_tbh:available then
      glog = v_tbh:buffer-create().
      if v_tbfh:available then
        glogf = v_tbfh:buffer-delete() no-error .
      if v_tbph:available then
      glogp = v_tbph:buffer-delete() no-error .
      if p-obj-type  = 'орг':U then do:
        assign
        glogf =  v_bfh:find-first( substitute('where firm-code = &1', p-obj-code), lock, wait) no-error .
      end.
      if p-obj-type  = 'чел':U then do:
        assign
        glogp =  v_bph:find-first( substitute('where psn-code = &1', p-obj-code), lock, wait) no-error .
      end.
      glogf = v_tbfh:buffer-create().
      glogp = v_tbph:buffer-create().
      assign
      v-h-action           = integer('2':U)
      obj-type             = buf_clients_.obj-type
      obj-code             = buf_clients_.obj-code
      obj-name             = buf_clients_.obj-name
      PS                   = buf_clients_.ps
      grp-code             = buf_clients_.grp-code
      stts                 = buf_clients_.stts
      .
      glog = v_tbh:buffer-copy( v_bh).
      if obj-type = 'орг':U then do:
        glogf = v_tbfh:buffer-copy( v_bfh).
        assign
        phone       = buft_firm_.phone
        .
      end.
      if obj-type = 'чел':U then do:
        glogp = v_tbph:buffer-copy( v_bph).
        assign
        phone = buft_person_.phone1
        name1 = buft_person_.name1
        name2 = buft_person_.name2
        .
      end.
    end.
    return yes.
  end method.
  method public logical create_clients_ (
                                             input p-obj-type as character
                                            ,input p-obj-code as integer
                                            ,input p-obj-name as character
                                            ,input p-grp-code as integer
                                            ):
    define variable glog as logical no-undo .
    define variable glogf as logical no-undo .
    define variable glogp as logical no-undo .
    DEFINE VARIABLE v-today as date no-undo .
    DEFINE VARIABLE v-time as integer no-undo .
    define buffer buf_clients for ub.clients.
    define buffer buf_cli-grp  for ub.cli-grp.
    define buffer buf2_cli-grp  for ub.cli-grp.
    if p-obj-type <> 'орг':U
    and p-obj-type <> 'чел':U then do:
      run set-error in v_gc (substitute("Нельзя создать клиента с типом &1", p-obj-type)).
      return no.
    end.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-code = p-grp-code no-error.
    if not available buf_cli-grp then do:
      run set-error in v_gc (substitute("Неверно задана группа клиента - нет группы с вн.кодом &1", p-grp-code)).
      return no.
    end.
    find first buf2_cli-grp no-lock where
             buf2_cli-grp.upper-code = buf_cli-grp.node-code no-error.
    if available buf2_cli-grp then do:
      run set-error in v_gc (substitute("Неверно задана группа клиента -  группа с вн.кодом &1 - нетерминальная", p-grp-code)).
      return no.
    end.
    find first buf_clients no-lock where
             buf_clients.obj-type = p-obj-type
         and buf_clients.obj-code = p-obj-code no-error.
    if available buf_clients then do:
      return no.
    end.
    glog = v_tbh:buffer-create().
    if p-obj-type = 'орг':U then do:
      glogf = v_tbfh:buffer-create().
    end.
    if p-obj-type = 'чел':U then do:
      glogp = v_tbph:buffer-create().
    end.
    assign
    obj-type                        = p-obj-type
    obj-code                        = p-obj-code
    obj-name                        = p-obj-name
    grp-code                        = p-grp-code
    buft_clients_.obj-type          = obj-type
    buft_clients_.obj-code          = obj-code
    buft_clients_.obj-name          = obj-name
    v-h-action                      = integer('1':U)
    .
    if p-obj-type = 'орг':U then do:
      assign
      buft_firm_.firm-code = obj-code
      .
    end.
    if p-obj-type = 'чел':U then do:
      assign
      buft_person_.psn-code = obj-code
      .
    end.
    if obj-code > 0 then do:
      run create_clients_ in v_gc ( input obj-type, input obj-code) no-error .
    end.
    return yes.
  end method.
  method public override character ToString( ):
    return substitute("&1&2", obj-type, obj-code).
  end method.
  method protected void clear_():
    define variable glog as logical no-undo .
    define variable glogf as logical no-undo .
    define variable glogp as logical no-undo .
    v-error-flag = no.
    if v_tbh:available then
    glog = v_tbh:buffer-delete() no-error .
    if obj-type  = 'орг':U then do:
      if v_tbfh:available then
      glogf = v_tbfh:buffer-delete() no-error .
    end.
    if obj-type = 'чел':U then do:
      if v_tbph:available then
      glogp = v_tbph:buffer-delete() no-error .
    end.
    assign
    obj-type = ''
    obj-code = 0
    v-h-action = 0
    .
  end method.
end class.
